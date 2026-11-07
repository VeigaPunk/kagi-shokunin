#!/usr/bin/env bash
# OpenBao response-wrapping trial (kagi round 51, C1 capability).
# Executes, on a throwaway in-memory `bao server -dev` bound to 127.0.0.1, five
# response-wrapping mechanisms that the OpenBao "Response wrapping" concepts page
# documents (S108, https://openbao.org/docs/concepts/response-wrapping/, Version 2.7.x).
# Prints one line per test:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>
# and a final summary line
#   OPENBAO_WRAP_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<version>
# Exit: 0 all HOLDS, 1 any BROKEN, 2 setup failure / any ERROR.
# No real vault, account or credential is touched: the dev root token is random,
# lives only in the scratch dir and is never printed; wrapped values are random
# `r51-` nonces generated here; no token or nonce value is ever printed. The trial
# drives the `bao` CLI resolved on PATH only (never the HTTP API, never an absolute
# bao path). The dev server runs under `setpriv --pdeathsig KILL` (S106, S107), so a
# SIGKILLed trial shell still takes its server down; traps cover EXIT/INT/TERM/HUP.
set -u
umask 077
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2;;
  esac
done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no setpriv"; exit 2; }
BASE="${WORK:-${TMPDIR:-/tmp}}"
mkdir -p "$BASE" || exit 2
D=$(mktemp -d "$BASE/openbao-wrap-trial.XXXXXX") || exit 2
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
start_server() { # sets SRV, BAO_ADDR, BAO_TOKEN; 0 on success
  local port root ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
    root=$(python3 -c 'import secrets;print("r51-"+secrets.token_hex(12))')
    setpriv --pdeathsig KILL bao server -dev -dev-root-token-id="$root" -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >"$D/server.log" 2>&1 &
    SRV=$!
    export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
    ok=0
    for _ in $(seq 1 300); do
      if bao status >/dev/null 2>&1; then ok=1; break; fi
      kill -0 "$SRV" 2>/dev/null || break
      sleep 0.1
    done
    if [ "$ok" = 1 ]; then return 0; fi
    kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
  done
  return 1
}
start_server || { echo "OPENBAO_WRAP_TRIAL: SETUP dev server did not start"; exit 2; }

H=0; B=0; E=0
report() { # report T status detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
}
nonce() { python3 -c 'import secrets;print("r51-"+secrets.token_hex(12))'; }
# put PATH VALUE -> 0 on success (KV v2 at the dev server's default `secret/` mount)
put() { bao kv put "$1" v="$2" >/dev/null 2>&1; }
# wtok: stdin = a `-format=json` wrapped response -> prints wrap_info.token; nonzero when absent
wtok() { python3 -c 'import json,sys
try: t=(json.load(sys.stdin).get("wrap_info") or {}).get("token")
except Exception: t=None
sys.exit(1) if not t else print(t)'; }
# wrapkv PATH TTL -> prints the wrapping token of a wrapped `kv get`
wrapkv() { local out; out=$(bao kv get -wrap-ttl="$2" -format=json "$1" 2>/dev/null) || return 1; printf '%s' "$out" | wtok; }
# unwrapv WTOKEN -> prints the unwrapped KV value `v`; nonzero when the unwrap is refused
unwrapv() {
  local out
  out=$(env -u BAO_TOKEN bao unwrap -format=json "$1" 2>/dev/null) || return 1
  printf '%s' "$out" | python3 -c 'import json,sys
d=json.load(sys.stdin).get("data") or {}
d=d.get("data",d)
v=d.get("v")
sys.exit(1) if v is None else print(v)'
}
# lookup WTOKEN FIELD -> prints that field of sys/wrapping/lookup, run with NO client token
# (the page: "This path is unauthenticated"); nonzero when the lookup is refused
lookup() {
  local out
  out=$(env -u BAO_TOKEN bao write -format=json sys/wrapping/lookup token="$1" 2>/dev/null) || return 1
  printf '%s' "$out" | python3 -c 'import json,sys
d=json.load(sys.stdin).get("data") or {}
v=d.get(sys.argv[1])
sys.exit(1) if v is None else print(v)' "$2"
}

# T1 — single use: "only a single party can ever unwrap the token" (S108 §Overview).
n=$(nonce)
if ! put secret/t1 "$n"; then report T1 ERROR "kv-put-failed"
else
  w=$(wrapkv secret/t1 60s) || w=""
  if [ -z "$w" ]; then report T1 ERROR "wrap-failed"
  else
    u1=0; [ "$(unwrapv "$w")" = "$n" ] && u1=1
    u2=0; unwrapv "$w" >/dev/null && u2=1
    if [ "$u1" = 1 ] && [ "$u2" = 0 ]; then report T1 HOLDS "first-unwrap-returns-value=1 second-unwrap-refused=1"
    else report T1 BROKEN "first-unwrap-returns-value=$u1 second-unwrap-refused=$((1-u2))"; fi
  fi
fi

# T2 — the wrapping token's lifetime "is separate from the wrapped secret": a 2 s wrap
# TTL lapses and the token can no longer be unwrapped, while the secret itself stays
# readable (S108 §Overview, limits the lifetime).
n=$(nonce)
if ! put secret/t2 "$n"; then report T2 ERROR "kv-put-failed"
else
  w=$(wrapkv secret/t2 2s) || w=""
  if [ -z "$w" ]; then report T2 ERROR "wrap-failed"
  else
    sleep 4
    u=0; unwrapv "$w" >/dev/null && u=1
    s=0; [ "$(bao kv get -field=v secret/t2 2>/dev/null)" = "$n" ] && s=1
    if [ "$u" = 0 ] && [ "$s" = 1 ]; then report T2 HOLDS "wrap-ttl=2s unwrap-after-4s-refused=1 secret-still-readable=1"
    else report T2 BROKEN "wrap-ttl=2s unwrap-after-4s-refused=$((1-u)) secret-still-readable=$s"; fi
  fi
fi

# T3 — lookup is unauthenticated, reports the creation path, and does not consume the
# token; after the unwrap the same lookup is refused ("This immediately tells you if the
# token has already been unwrapped", S108 §Response-Wrapping token operations, §validation).
n=$(nonce)
if ! put secret/t3 "$n"; then report T3 ERROR "kv-put-failed"
else
  w=$(wrapkv secret/t3 60s) || w=""
  if [ -z "$w" ]; then report T3 ERROR "wrap-failed"
  else
    p=$(lookup "$w" creation_path) || p=""
    u=0; [ "$(unwrapv "$w")" = "$n" ] && u=1
    l2=0; lookup "$w" creation_path >/dev/null && l2=1
    if [ "$p" = "secret/data/t3" ] && [ "$u" = 1 ] && [ "$l2" = 0 ]; then
      report T3 HOLDS "lookup-path=secret/data/t3 unwrap-after-lookup=1 lookup-after-unwrap-refused=1"
    else report T3 BROKEN "lookup-path-ok=$([ "$p" = secret/data/t3 ] && echo 1 || echo 0) unwrap-after-lookup=$u lookup-after-unwrap-refused=$((1-l2))"; fi
  fi
fi

# T4 — rewrap "migrat[es] the wrapped data to a new response-wrapping token": the new
# token differs, unwraps to the same value, and the old token is spent (S108 §Rewrap).
n=$(nonce)
if ! put secret/t4 "$n"; then report T4 ERROR "kv-put-failed"
else
  w1=$(wrapkv secret/t4 60s) || w1=""
  if [ -z "$w1" ]; then report T4 ERROR "wrap-failed"
  else
    w2=$(bao write -format=json sys/wrapping/rewrap token="$w1" 2>/dev/null | wtok) || w2=""
    if [ -z "$w2" ]; then report T4 BROKEN "rewrap-returned-no-token"
    else
      d=0; [ "$w2" != "$w1" ] && d=1
      o=0; unwrapv "$w1" >/dev/null && o=1
      v=0; [ "$(unwrapv "$w2")" = "$n" ] && v=1
      if [ "$d" = 1 ] && [ "$o" = 0 ] && [ "$v" = 1 ]; then report T4 HOLDS "new-token-differs=1 old-token-refused=1 new-token-returns-value=1"
      else report T4 BROKEN "new-token-differs=$d old-token-refused=$((1-o)) new-token-returns-value=$v"; fi
    fi
  fi
fi

# T5 — the creation path exposes a re-wrap: data read out and wrapped again through
# sys/wrapping/wrap carries creation path `sys/wrapping/wrap`, not the KV path the
# client expects (S108 §Response-Wrapping token validation).
n=$(nonce)
if ! put secret/t5 "$n"; then report T5 ERROR "kv-put-failed"
else
  w=$(wrapkv secret/t5 60s) || w=""
  if [ -z "$w" ]; then report T5 ERROR "wrap-failed"
  else
    p1=$(lookup "$w" creation_path) || p1=""
    v=$(unwrapv "$w") || v=""
    w2=$(bao write -wrap-ttl=60s -format=json sys/wrapping/wrap v="$v" 2>/dev/null | wtok) || w2=""
    p2=""; [ -n "$w2" ] && { p2=$(lookup "$w2" creation_path) || p2=""; }
    if [ "$p1" = "secret/data/t5" ] && [ "$v" = "$n" ] && [ "$p2" = "sys/wrapping/wrap" ]; then
      report T5 HOLDS "original-path=secret/data/t5 rewrapped-path=sys/wrapping/wrap"
    else report T5 BROKEN "original-path-ok=$([ "$p1" = secret/data/t5 ] && echo 1 || echo 0) value-ok=$([ "$v" = "$n" ] && echo 1 || echo 0) rewrapped-path-ok=$([ "$p2" = sys/wrapping/wrap ] && echo 1 || echo 0)"; fi
  fi
fi

if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_WRAP_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
cleanup
exit $rc
