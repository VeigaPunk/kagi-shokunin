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
# Round 50 (C1, operability): the dev server is started under `setpriv --pdeathsig KILL`
# (util-linux), which sets the kernel parent-death signal (prctl PR_SET_PDEATHSIG, S106) before
# exec'ing bao, so a SIGKILLed trial shell, which runs no trap, still takes its server down.
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
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_TRIAL: SETUP no setpriv"; exit 2; }
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
start_server || { echo "OPENBAO_TRIAL: SETUP dev server did not start"; exit 2; }

for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS const"; sleep 1; done
echo "OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=$VER"
cleanup
exit 0
