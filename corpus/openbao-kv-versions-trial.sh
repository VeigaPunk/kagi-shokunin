#!/usr/bin/env bash
# OpenBao KV v2 version-lifecycle trial (kagi round 52, C1 capability).
# Source: S110, https://openbao.org/docs/secrets/kv/kv-v2/ (OpenBao docs Version 2.7.x).
# Executes, on a throwaway in-memory `bao server -dev` bound to 127.0.0.1, five
# version-lifecycle mechanics the KV v2 page documents:
#   T1 check-and-set: with -cas set, a write is accepted only when cas = the current version (a write without -cas is accepted)
#   T2 soft delete is recoverable: `kv delete` marks the version, `kv undelete` restores it
#   T3 destroy is permanent: after `kv destroy` an undelete restores nothing
#   T4 max-versions: a key keeping 2 versions drops version 1 when version 3 is written
#   T5 metadata delete removes every version of the key
# Prints one line per test:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>
# and a final summary line
#   OPENBAO_KV_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<version>
# Exit: 0 all HOLDS, 1 any BROKEN, 2 setup failure / any ERROR.
# Secret handling (round-51 sentinel findings S-1, S-2, S-3, M51-3):
# - no secret is ever on an argv: the dev root token reaches the server through the
#   BAO_DEV_ROOT_TOKEN_ID environment variable and the client through BAO_TOKEN; every
#   KV value is written as `v=-` with the value on stdin.
# - the server's output goes to /dev/null, so no log holding the root token exists.
# - the port is chosen by a probe and then checked to be held by our own server pid.
# - a refusal is read only from a non-zero exit AND the server's refusal text; an answer
#   that does not parse is ERROR, never a refusal.
# Values are random `r52-` nonces; no token or nonce value is ever printed. The trial
# drives the `bao` CLI resolved on PATH only (never the HTTP API, never an absolute path).
# The dev server runs under `setpriv --pdeathsig KILL` (S106, S107).
set -u
umask 077
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2;;
  esac
done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no setpriv"; exit 2; }
command -v ss >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no ss"; exit 2; }
BASE="${WORK:-${TMPDIR:-/tmp}}"
mkdir -p "$BASE" || exit 2
D=$(mktemp -d "$BASE/openbao-kv-trial.XXXXXX") || exit 2
SRV=""
cleanup() {
  if [ -n "$SRV" ]; then
    kill "$SRV" 2>/dev/null
    for _ in $(seq 1 50); do
      kill -0 "$SRV" 2>/dev/null || break
      sleep 0.1
    done
    kill -9 "$SRV" 2>/dev/null
    wait "$SRV" 2>/dev/null
    SRV=""
  fi
  rm -rf -- "$D"
}
trap 'cleanup' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
while IFS= read -r v; do [ -n "$v" ] && unset "$v"; done < <(env | sed -n 's/^\(BAO_[A-Z_]*\)=.*/\1/p; s/^\(VAULT_[A-Z_]*\)=.*/\1/p')
export HOME="$D/home"; mkdir -p "$HOME"
VER=$(bao version 2>/dev/null | awk '{print $2; exit}')
nonce() { python3 -c 'import secrets;print("r52-"+secrets.token_hex(12))'; }
start_server() { # sets SRV, BAO_ADDR, BAO_TOKEN; 0 on success
  local port root ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
    root=$(nonce)
    BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL bao server -dev -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
    SRV=$!
    ok=0
    for _ in $(seq 1 300); do
      kill -0 "$SRV" 2>/dev/null || break
      if ss -Hltnp "sport = :$port" 2>/dev/null | grep -q "pid=$SRV,"; then ok=1; break; fi
      sleep 0.1
    done
    if [ "$ok" = 1 ]; then
      export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
      ok=0
      for _ in $(seq 1 100); do
        if bao status >/dev/null 2>&1; then ok=1; break; fi
        sleep 0.1
      done
      [ "$ok" = 1 ] && return 0
    fi
    kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
    unset BAO_ADDR BAO_TOKEN
  done
  return 1
}
start_server || { echo "OPENBAO_KV_TRIAL: SETUP dev server did not start"; exit 2; }

H=0; B=0; E=0
report() { # report T status detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
}
# put [FLAGS...] PATH VALUE -> the bao exit code; the value goes on stdin (`v=-`), never argv.
# The CLI's stderr lands in $D/err for refused().
put() {
  local n=$#; local val="${!n}"; local args=("${@:1:n-1}")
  printf '%s' "$val" | bao kv put "${args[@]}" v=- >/dev/null 2>"$D/err"
}
# refused RC PATTERN -> 0 when RC is non-zero AND the last stderr carries PATTERN (M51-3)
refused() { [ "$1" -ne 0 ] && grep -qF -- "$2" "$D/err"; }
# getv [FLAGS...] PATH -> prints field v; returns bao's exit code, or 3 when the answer does
# not parse; stderr to $D/err
getv() { local out rc; out=$(bao kv get -format=json "$@" 2>"$D/err"); rc=$?; [ $rc -eq 0 ] || return $rc
  printf '%s' "$out" | python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(3)
v=((d.get("data") or {}).get("data") or {}).get("v")
print("" if v is None else v)'; }
# vstate PATH -> prints "<data-null 0|1> <deletion_time set 0|1> <destroyed 0|1>" of the latest
# version; exit 3 when the answer does not parse
vstate() { local out; out=$(bao kv get -format=json "$1" 2>"$D/err") || return 1
  printf '%s' "$out" | python3 -c 'import json,sys
try:
  d=json.load(sys.stdin)["data"]; m=d["metadata"]
except Exception: sys.exit(3)
print(int(d.get("data") is None), int(bool(m.get("deletion_time"))), int(bool(m.get("destroyed"))))'; }
NOVAL='No value found at'

# T1 — check-and-set: "In order for a write to be successful, cas must be set to the
# current version of the secret." (S110). cas=0 on an existing key and a stale cas are
# refused with the server's check-and-set error; cas = current is accepted.
n1=$(nonce); n2=$(nonce); n3=$(nonce)
if ! put secret/t1 "$n1"; then report T1 ERROR "kv-put-failed"
else
  put -cas=0 secret/t1 "$n2"; r0=$?; z0=0; refused $r0 'check-and-set parameter did not match' && z0=1
  put -cas=1 secret/t1 "$n2"; r1=$?
  put -cas=1 secret/t1 "$n3"; r2=$?; z2=0; refused $r2 'check-and-set parameter did not match' && z2=1
  v=$(getv secret/t1); g=$?
  if [ $g -ne 0 ]; then report T1 ERROR "read-failed(rc=$g)"
  elif [ $z0 = 1 ] && [ $r1 = 0 ] && [ $z2 = 1 ] && [ "$v" = "$n2" ]; then
    report T1 HOLDS "cas0-on-existing-refused=1 cas-current-accepted=1 stale-cas-refused=1"
  else report T1 BROKEN "cas0-refused=$z0 cas-current-rc=$r1 stale-refused=$z2 value-is-cas-write=$([ "$v" = "$n2" ] && echo 1 || echo 0)"; fi
fi

# T2 — soft delete is recoverable: "When deleting data the standard bao kv delete command
# will perform a soft delete." (S110); `kv undelete` restores the version.
n=$(nonce)
if ! put secret/t2 "$n"; then report T2 ERROR "kv-put-failed"
elif ! bao kv delete secret/t2 >/dev/null 2>"$D/err"; then report T2 ERROR "kv-delete-failed"
else
  s=$(vstate secret/t2); sr=$?
  bao kv undelete -versions=1 secret/t2 >/dev/null 2>"$D/err"; ur=$?
  v=$(getv secret/t2); g=$?
  if [ $sr -ne 0 ] || [ $g -ne 0 ]; then report T2 ERROR "read-failed(state=$sr get=$g)"
  elif [ "$s" = "1 1 0" ] && [ $ur = 0 ] && [ "$v" = "$n" ]; then
    report T2 HOLDS "deleted-data-null=1 deletion-time-set=1 undelete-restores-value=1"
  else report T2 BROKEN "state-after-delete=[$s] undelete-rc=$ur value-restored=$([ "$v" = "$n" ] && echo 1 || echo 0)"; fi
fi

# T3 — destroy is permanent: "A version's data is permanently deleted only when the key
# has more versions than are allowed by the max-versions setting" or by `bao kv destroy`
# (S110); an undelete after a destroy brings nothing back and the version reads destroyed.
n=$(nonce)
if ! put secret/t3 "$n"; then report T3 ERROR "kv-put-failed"
elif ! bao kv destroy -versions=1 secret/t3 >/dev/null 2>"$D/err"; then report T3 ERROR "kv-destroy-failed"
else
  bao kv undelete -versions=1 secret/t3 >/dev/null 2>&1
  s=$(vstate secret/t3); sr=$?
  if [ $sr -ne 0 ]; then report T3 ERROR "read-failed(state=$sr)"
  elif [ "$s" = "1 0 1" ]; then report T3 HOLDS "after-destroy-and-undelete data-null=1 destroyed=1"
  else report T3 BROKEN "state-after-destroy-and-undelete=[$s]"; fi
fi

# T4 — max-versions: with `-max-versions=2` on the key's metadata, writing a third version
# drops version 1 (S110, the max-versions sentence quoted at T3); versions 2 and 3 remain.
n1=$(nonce); n2=$(nonce); n3=$(nonce)
if ! bao kv metadata put -max-versions=2 secret/t4 >/dev/null 2>"$D/err"; then report T4 ERROR "metadata-put-failed"
elif ! { put secret/t4 "$n1" && put secret/t4 "$n2" && put secret/t4 "$n3"; }; then report T4 ERROR "kv-put-failed"
else
  getv -version=1 secret/t4 >/dev/null; g1=$?; z1=0; refused $g1 "$NOVAL" && z1=1
  v2=$(getv -version=2 secret/t4); g2=$?
  v3=$(getv -version=3 secret/t4); g3=$?
  if [ $g1 -eq 3 ] || [ $g2 -eq 3 ] || [ $g3 -eq 3 ]; then report T4 ERROR "unparsed-answer(v1=$g1 v2=$g2 v3=$g3)"
  elif [ $z1 = 1 ] && [ "$v2" = "$n2" ] && [ "$v3" = "$n3" ]; then
    report T4 HOLDS "version1-dropped=1 version2-kept=1 version3-kept=1"
  else report T4 BROKEN "version1-dropped=$z1 version2-kept=$([ "$v2" = "$n2" ] && echo 1 || echo 0) version3-kept=$([ "$v3" = "$n3" ] && echo 1 || echo 0)"; fi
fi

# T5 — metadata delete: "Permanently delete all metadata and versions for a key" (S110);
# afterwards no version reads back, the metadata is gone and an undelete restores nothing.
n1=$(nonce); n2=$(nonce)
if ! { put secret/t5 "$n1" && put secret/t5 "$n2"; }; then report T5 ERROR "kv-put-failed"
elif ! bao kv metadata delete secret/t5 >/dev/null 2>"$D/err"; then report T5 ERROR "metadata-delete-failed"
else
  bao kv undelete -versions=1,2 secret/t5 >/dev/null 2>&1
  getv -version=1 secret/t5 >/dev/null; g1=$?; z1=0; refused $g1 "$NOVAL" && z1=1
  getv -version=2 secret/t5 >/dev/null; g2=$?; z2=0; refused $g2 "$NOVAL" && z2=1
  bao kv metadata get secret/t5 >/dev/null 2>"$D/err"; mr=$?; zm=0; refused $mr "$NOVAL" && zm=1
  if [ $z1 = 1 ] && [ $z2 = 1 ] && [ $zm = 1 ]; then report T5 HOLDS "version1-gone=1 version2-gone=1 metadata-gone=1"
  elif [ $g1 -eq 3 ] || [ $g2 -eq 3 ]; then report T5 ERROR "unparsed-answer"
  else report T5 BROKEN "version1-gone=$z1 version2-gone=$z2 metadata-gone=$zm"; fi
fi

if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_KV_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
cleanup
exit $rc
