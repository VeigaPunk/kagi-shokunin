#!/usr/bin/env bash
# OpenBao token/lease lifecycle trial (kagi round 49, hardened build).
# Executes, on a throwaway in-memory `bao server -dev` bound to 127.0.0.1, five
# mechanisms that corpus/knowledge/vault-openbao-token-lease-lifecycle.md documents
# from S016 (OpenBao docs, Version 2.7.x). Prints one line per test:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>
# and a final summary line
#   OPENBAO_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<version>
# Exit: 0 all HOLDS, 1 any BROKEN, 2 setup failure / any ERROR.
# No real vault, account or credential is touched; the dev root token is random,
# lives only in the scratch dir, and is never printed. The trial drives the `bao`
# CLI resolved on PATH only (never the HTTP API, never an absolute bao path).
#
# Hardening deltas over the round-49 reference fixture (grammar and test logic
# unchanged): EXIT/INT/TERM/HUP traps all reach the same cleanup, which kills the
# dev server by its own PID, waits for it to disappear, then deletes the scratch
# dir (server logs live inside it); server start is retried on a fresh random
# 127.0.0.1 port; the readiness wait tolerates host load; `wait` targets the
# server PID instead of every job.
set -u
umask 077
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2;;
  esac
done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_TRIAL: SETUP no python3"; exit 2; }
BASE="${WORK:-${TMPDIR:-/tmp}}"
mkdir -p "$BASE" || exit 2
D=$(mktemp -d "$BASE/openbao-trial.XXXXXX") || exit 2
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
    root=$(python3 -c 'import secrets;print("r49-"+secrets.token_hex(12))')
    bao server -dev -dev-root-token-id="$root" -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >"$D/server.log" 2>&1 &
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
start_server || { echo "OPENBAO_TRIAL: SETUP dev server did not start"; exit 2; }

H=0; B=0; E=0
report() { # report T status detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
}
tok() { # create token, print its value; extra args passed through
  bao token create -field=token -policy=default "$@" 2>/dev/null
}
alive() { BAO_TOKEN="$1" bao token lookup >/dev/null 2>&1; }

# T1 — "Every non-root token has a time-to-live"; when it lapses the token stops (S016 §Token Time-To-Live).
t=$(tok -ttl=2s) || t=""
if [ -z "$t" ]; then report T1 ERROR "token-create-failed"
else
  a0=0; alive "$t" && a0=1
  sleep 4
  a1=0; alive "$t" && a1=1
  if [ "$a0" = 1 ] && [ "$a1" = 0 ]; then report T1 HOLDS "ttl=2s alive-before=1 alive-after-4s=0"
  else report T1 BROKEN "ttl=2s alive-before=$a0 alive-after-4s=$a1"; fi
fi

# T2 — an explicit max TTL is a hard cap on renewal (S016 §Token Time-To-Live).
t=$(tok -ttl=60s -explicit-max-ttl=5s) || t=""
if [ -z "$t" ]; then report T2 ERROR "token-create-failed"
else
  r=$(BAO_TOKEN="$t" bao token renew -increment=3600 -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["auth"]["lease_duration"])' 2>/dev/null) || r=""
  sleep 7
  a1=0; alive "$t" && a1=1
  if [ -n "$r" ] && [ "$r" -le 5 ] && [ "$a1" = 0 ]; then report T2 HOLDS "renew-increment=3600 granted=$r alive-after-7s=0"
  else report T2 BROKEN "renew-increment=3600 granted=${r:-none} alive-after-7s=$a1"; fi
fi

# T3 — batch tokens are not renewable and not manually revocable (S016 §Token type comparison).
t=$(tok -type=batch -ttl=60s) || t=""
if [ -z "$t" ]; then report T3 ERROR "token-create-failed"
else
  rn=0; BAO_TOKEN="$t" bao token renew >/dev/null 2>&1 && rn=1
  rv=0; bao token revoke "$t" >/dev/null 2>&1 && rv=1
  a1=0; alive "$t" && a1=1
  if [ "$rn" = 0 ] && [ "$rv" = 0 ] && [ "$a1" = 1 ]; then report T3 HOLDS "renew-ok=0 revoke-ok=0 alive-after=1"
  else report T3 BROKEN "renew-ok=$rn revoke-ok=$rv alive-after=$a1"; fi
fi

# T4 — a login through a non-token auth method yields an orphan token, so revoking
# the token that created the account does not reach it; a child token is revoked
# with its parent (S016 §Token hierarchies and orphan tokens).
PW=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
if bao auth enable userpass >/dev/null 2>&1 && bao write auth/userpass/users/trial password="$PW" policies=default >/dev/null 2>&1; then
  bao policy write child-maker - >/dev/null 2>&1 <<'POL'
path "auth/token/create" { capabilities = ["create", "update"] }
POL
  p=$(tok -ttl=60s -policy=child-maker); c=""; [ -n "$p" ] && c=$(BAO_TOKEN="$p" bao token create -field=token -policy=default -ttl=60s 2>/dev/null)
  u=$(BAO_TOKEN="$p" bao login -method=userpass -no-store -field=token username=trial password="$PW" 2>/dev/null)
  if [ -z "$p" ] || [ -z "$c" ] || [ -z "$u" ]; then report T4 ERROR "setup-token-failed"
  else
    orph=$(BAO_TOKEN="$u" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(str(json.load(sys.stdin)["data"]["orphan"]).lower())' 2>/dev/null)
    bao token revoke "$p" >/dev/null 2>&1
    ca=0; alive "$c" && ca=1
    ua=0; alive "$u" && ua=1
    if [ "$orph" = true ] && [ "$ca" = 0 ] && [ "$ua" = 1 ]; then report T4 HOLDS "login-orphan=true child-alive-after-parent-revoke=0 login-alive=1"
    else report T4 BROKEN "login-orphan=${orph:-none} child-alive-after-parent-revoke=$ca login-alive=$ua"; fi
  fi
else report T4 ERROR "userpass-setup-failed"; fi

# T5 — when a token lapses, "it, and its associated leases, are revoked" (S016 §Token Time-To-Live).
# A leased secret: a PKI certificate issued with generate_lease=true.
if bao secrets enable pki >/dev/null 2>&1 \
  && bao secrets tune -max-lease-ttl=1h pki >/dev/null 2>&1 \
  && bao write -field=certificate pki/root/generate/internal common_name=trial.invalid ttl=1h >/dev/null 2>&1 \
  && bao write pki/roles/trial allowed_domains=trial.invalid allow_subdomains=true generate_lease=true max_ttl=30m >/dev/null 2>&1; then
  bao policy write pki-issue - >/dev/null 2>&1 <<'POL'
path "pki/issue/trial" { capabilities = ["update"] }
POL
  t=$(bao token create -field=token -policy=pki-issue -ttl=3s 2>/dev/null)
  lid=""; [ -n "$t" ] && lid=$(BAO_TOKEN="$t" bao write -format=json pki/issue/trial common_name=a.trial.invalid ttl=10m 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["lease_id"])' 2>/dev/null)
  if [ -z "$lid" ]; then report T5 ERROR "leased-secret-not-issued"
  else
    l0=0; bao lease lookup "$lid" >/dev/null 2>&1 && l0=1
    sleep 5
    l1=0; bao lease lookup "$lid" >/dev/null 2>&1 && l1=1
    if [ "$l0" = 1 ] && [ "$l1" = 0 ]; then report T5 HOLDS "lease-ttl=10m token-ttl=3s lease-before=1 lease-after-5s=0"
    else report T5 BROKEN "lease-ttl=10m token-ttl=3s lease-before=$l0 lease-after-5s=$l1"; fi
  fi
else report T5 ERROR "pki-setup-failed"; fi

if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
cleanup
exit $rc
