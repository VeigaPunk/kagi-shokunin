#!/usr/bin/env bash
# OpenBao audit-device custody trial (kagi round 57, C2 capability).
# Sources: S115 https://openbao.org/docs/audit/ and S116 https://openbao.org/docs/commands/audit/
# (OpenBao docs Version 2.7.x), opened 2026-11-07.
# Executed on a throwaway in-memory `bao server -dev` bound to 127.0.0.1. Five
# audit-device mechanics the pages document, plus the binary's own preconditions:
#   T1 enable path: `bao audit enable file file_path=...` is REFUSED on a default
#      dev server (HTTP 400, "cannot enable audit device via API; use declarative,
#      config-based audit device management instead") and ACCEPTED on a dev server
#      whose config sets `unsafe_allow_api_audit_creation = true`; `bao audit list`
#      then shows `file/` and a second `-path=file2 ... log_raw=true` device.
#   T2 default hashing: `sys/audit-hash/file` returns `hmac-sha256:<64 hex>`,
#      stable per device and input-distinct; the audit log carries that hash for
#      the request and the response (>=2 occurrences) and never the plaintext.
#   T3 log_raw: the second device's log carries the value in plaintext and the
#      client token in cleartext (count only, never printed); the default device's
#      log carries neither.
#   T4 per-instance salt: `bao audit disable file/` then re-enable at the same path
#      changes the HMAC of the same input (the docs' "a new salt will be created").
#   T5 non-audited paths: the documented `sys/seal-status` path (`bao status`)
#      leaves no audit entry while a KV read in the same window does.
# Prints one line per test:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>
# and a final summary line
#   OPENBAO_AUDIT_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
# Exit: 0 all HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (missing tool/scratch, any ERROR).
# Falsifier shims (round-48/49/51/52 convention): KAGI_AUDIT_SHIM=SH1..SH5 replaces one
# test's observable evaluation, never the mechanics, so exactly one test reads BROKEN.
# Secret handling: no token or value on any argv; the dev root token reaches the
# server through BAO_DEV_ROOT_TOKEN_ID and the client through BAO_TOKEN; every KV
# value is written as `v=-` on stdin; the server output goes to /dev/null; the port
# is probed then checked to be held by our server pid; values are random `r57-`
# nonces and no nonce or token is ever printed. The server runs under
# `setpriv --pdeathsig KILL`. The trial drives the `bao` CLI resolved on PATH only.
set -u
umask 077
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2;;
  esac
done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_AUDIT_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_AUDIT_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_AUDIT_TRIAL: SETUP no setpriv"; exit 2; }
command -v ss >/dev/null 2>&1 || { echo "OPENBAO_AUDIT_TRIAL: SETUP no ss"; exit 2; }
BASE="${WORK:-${TMPDIR:-/tmp}}"
mkdir -p "$BASE" || exit 2
D=$(mktemp -d "$BASE/openbao-audit-trial.XXXXXX") || exit 2
SRV=""
cleanup() {
  if [ -n "$SRV" ]; then
    kill "$SRV" 2>/dev/null
    for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
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
SHIM="${KAGI_AUDIT_SHIM:-}"
nonce() { python3 -c 'import secrets;print("r57-"+secrets.token_hex(12))'; }
ALOG="$D/audit.log"; RLOG="$D/audit-raw.log"
cat > "$D/allow.json" <<EOF
{"unsafe_allow_api_audit_creation": true}
EOF
start_server() { # CONFIG_OR_EMPTY -> sets SRV, BAO_ADDR, BAO_TOKEN
  local conf=$1 port root ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
    root=$(nonce)
    if [ -n "$conf" ]; then
      BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL bao server -dev -config="$conf" \
        -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
    else
      BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL bao server -dev \
        -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
    fi
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
stop_server() {
  [ -n "$SRV" ] || return 0
  kill "$SRV" 2>/dev/null
  for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
  kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
  unset BAO_ADDR BAO_TOKEN
}
hashof() { # DEVICE VALUE -> hash on stdout; rc 3 when the answer does not parse
  local out
  # the input travels in a JSON body on stdin: no value on any argv (sentinel S-2)
  out=$(printf '{"input":"%s"}' "$2" | bao write -format=json "sys/audit-hash/$1" - 2>"$D/err") || return 1
  printf '%s' "$out" | python3 -c 'import json,sys
try: print(json.load(sys.stdin)["data"]["hash"])
except Exception: sys.exit(3)'
}
count_plain() { # LOG PATTERN -> count; the pattern arrives through grep -f - (stdin), never argv
  [ -n "$2" ] || { echo 0; return 0; }
  printf '%s\n' "$2" | grep -cF -f - -- "$1" 2>/dev/null || true
}
count_path() { grep -cF -- "\"path\":\"$2\"" "$1" 2>/dev/null || true; }
putv() { printf '%s' "$2" | bao kv put "$1" v=- >/dev/null 2>"$D/err"; }
H=0; B=0; E=0
report() { echo "TRIAL $1 $2 $3"; case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac; }

# T1 — the enable path: refused on a default dev server, accepted with the config flag.
start_server "" || { echo "OPENBAO_AUDIT_TRIAL: SETUP default dev server did not start"; exit 2; }
bao audit enable file file_path="$D/never.log" >/dev/null 2>"$D/err"; rdef=$?
refused_text=0; grep -qF 'cannot enable audit device via API' "$D/err" && refused_text=1
stop_server
start_server "$D/allow.json" || { echo "OPENBAO_AUDIT_TRIAL: SETUP flagged dev server did not start"; exit 2; }
bao audit enable file file_path="$ALOG" >/dev/null 2>"$D/err"; r1=$?
bao audit enable -path=file2 file file_path="$RLOG" log_raw=true >/dev/null 2>"$D/err2"; r2=$?
list=$(bao audit list 2>/dev/null)
listed1=0; list_rc=0
printf '%s\n' "$list" | grep -qE '^file/' && listed1=1
printf '%s\n' "$list" | grep -qE '^file2/' && listed2=1 || listed2=0
[ "$SHIM" = SH1 ] && { listed1=0; listed2=0; }
if [ $rdef -ne 0 ] && [ $refused_text = 1 ] && [ $r1 = 0 ] && [ $r2 = 0 ] && [ $listed1 = 1 ] && [ $listed2 = 1 ]; then
  report T1 HOLDS "default-enable-refused=1 flagged-enable=1 devices-listed=2"
else
  report T1 BROKEN "default-rc=$rdef refusal-text=$refused_text flagged-rc=$r1/$r2 listed=$listed1/$listed2"
fi

# T2 — default hashing: hmac-sha256 form, stable, input-distinct, request+response, no plaintext.
n2=$(nonce); n2b=$(nonce)
h1=$(hashof file "$n2"); g1=$?
h2=$(hashof file "$n2"); g2=$?
h3=$(hashof file "$n2b"); g3=$?
[ "$SHIM" = SH2 ] && { h1="$n2"; h2="$n2"; h3="$n2b"; }
if putv secret/t2 "$n2" && bao kv get secret/t2 >/dev/null 2>&1; then put_ok=1; else put_ok=0; fi
sleep 0.2
plain=$(count_plain "$ALOG" "$n2")
hm_grep=0; [ -n "$h1" ] && hm_grep=$(count_plain "$ALOG" "$h1")
case "$h1" in hmac-sha256:*) hform=1;; *) hform=0;; esac
if [ $g1 -eq 0 ] && [ $g2 -eq 0 ] && [ $g3 -eq 0 ] && [ $hform = 1 ] && [ "$h1" = "$h2" ] && [ "$h1" != "$h3" ] \
   && [ $put_ok = 1 ] && [ "${plain:-0}" = 0 ] && [ "${hm_grep:-0}" -ge 2 ]; then
  report T2 HOLDS "hmac-form=1 stable=1 input-distinct=1 log-plaintext=0 request-response-hash-lines=${hm_grep}"
else
  report T2 BROKEN "hash-form=$hform stable=$([ "$h1" = "$h2" ] && echo 1 || echo 0) input-distinct=$([ "$h1" != "$h3" ] && echo 1 || echo 0) put=$put_ok log-plaintext=$plain request-response-hash-lines=${hm_grep:-0}"
fi

# T3 — log_raw device: value and client token in cleartext there, neither in the default log.
raw_plain=$(count_plain "$RLOG" "$n2")
def_plain=$(count_plain "$ALOG" "$n2")
raw_tok=$(count_plain "$RLOG" "$BAO_TOKEN")
def_tok=$(count_plain "$ALOG" "$BAO_TOKEN")
if [ "$SHIM" = SH3 ]; then raw_plain=$def_plain; raw_tok=$def_tok; fi
if [ "${raw_plain:-0}" -ge 1 ] && [ "${def_plain:-0}" = 0 ] && [ "${raw_tok:-0}" -ge 1 ] && [ "${def_tok:-0}" = 0 ]; then
  report T3 HOLDS "raw-value-plaintext=${raw_plain} raw-token-cleartext=${raw_tok} default-value=${def_plain} default-token=${def_tok}"
else
  report T3 BROKEN "raw-value-plaintext=${raw_plain:-0} raw-token-cleartext=${raw_tok:-0} default-value=${def_plain:-0} default-token=${def_tok:-0}"
fi

# T5 — documented non-audited path: sys/seal-status leaves no entry; a KV read does.
n5=$(nonce)
putv secret/t5 "$n5"
before=$(wc -l < "$ALOG" 2>/dev/null || echo 0)
bao status >/dev/null 2>&1
bao kv get secret/t5 >/dev/null 2>&1
sleep 0.2
after=$(wc -l < "$ALOG" 2>/dev/null || echo 0)
seal=$(count_path "$ALOG" "sys/seal-status")
kv=$(count_path "$ALOG" "secret/data/t5")
[ "$SHIM" = SH5 ] && seal=1
if [ "${seal:-0}" = 0 ] && [ "${kv:-0}" -ge 1 ] && [ "${after:-0}" -gt "${before:-0}" ]; then
  report T5 HOLDS "seal-status-entries=0 kv-entries=${kv} log-grew=$((after-before))"
else
  report T5 BROKEN "seal-status-entries=${seal:-0} kv-entries=${kv:-0} log-grew=$((after-before))"
fi

# T4 — per-instance salt: disable and re-enable at the same path rotates the salt.
n4=$(nonce)
h1=$(hashof file "$n4"); g1=$?
bao audit disable file/ >/dev/null 2>"$D/err"; dr=$?
bao audit enable file file_path="$ALOG" >/dev/null 2>"$D/erren"; er=$?
h2=$(hashof file "$n4"); g2=$?
[ "$SHIM" = SH4 ] && h2="$h1"
same=0; [ "$h1" = "$h2" ] && same=1
case "$h1$h2" in *hmac-sha256:*) hform=1;; *) hform=0;; esac
if [ $dr = 0 ] && [ $er = 0 ] && [ $g1 -eq 0 ] && [ $g2 -eq 0 ] && [ $hform = 1 ] && [ $same = 0 ]; then
  report T4 HOLDS "disable-rc=0 reenable-rc=0 same-input-same-hash=0"
else
  report T4 BROKEN "disable-rc=$dr reenable-rc=$er hash-form=$hform same-hash=$same read=$g1/$g2"
fi

if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_AUDIT_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
cleanup
exit $rc
