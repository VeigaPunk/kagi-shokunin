#!/usr/bin/env bash
# openbao-audit-trial.sh -- round 57 C2 custody trial (wave draft, seat R57ExecTrial).
# Landing target is corpus/openbao-audit-trial.sh; this draft lives under
# .ufo/waves/round-57/w1/R57ExecTrial.d/ and production edits belong to the L1.
#
# Contract
#   bash openbao-audit-trial.sh --work DIR
# Prints exactly five "TEST T<n>: HOLDS|BROKEN" lines (n=1..5) then one last line:
#   "AUDIT_TRIAL: CLEAN (tests=5 pass=5)" and exits 0 iff all five hold;
#   "AUDIT_TRIAL: FAIL (tests=5 pass=<k>)" and exits 1 otherwise.
# Exits 2 with no TEST/SUMMARY line when `bao` is absent from PATH (or --work
# is missing/unusable).
#
# Falsifier shims
#   KAGI_AUDIT_SHIM=SH<n> inverts test T<n>'s core assertion, so exactly that
#   one test reports BROKEN and the summary reads "AUDIT_TRIAL: FAIL
#   (tests=5 pass=4)" with rc 1. The mechanics still run; only the assertion
#   is inverted. A shim on one test leaves the other four untouched.
#
# Tests (POP of plans/round-57.md C2; sources S115 openbao.org/docs/audit/,
# S116 openbao.org/docs/commands/audit/)
#   T1 `bao audit enable file` + `bao audit list` names file/
#   T2 a KV write's audit entry exists for request and response, the value
#      carries the default "hmac-sha256:" form, and the written plaintext
#      does not occur anywhere in the default log
#   T3 a second device with log_raw=true records the same kind of value raw
#      while the default device still HMACs it
#   T4 `bao audit disable` + re-enable at the same path creates a new salt:
#      the same value's HMAC after re-enable differs from before
#   T5 `bao status` (sys/seal-status) leaves no audit entry while a KV read
#      in the same window does
#
# Custody
#   Throwaway `bao server -dev` (in-memory storage) under
#   `setpriv --pdeathsig KILL`; since OpenBao v2.3.2 the server config must
#   opt in via `unsafe_allow_api_audit_creation = true` before the CLI can
#   enable/disable audit devices (measured live against OpenBao 2.7.2), so
#   the trial writes that one-line config into <work>/server-config.hcl
#   (scratch, no secret); random root token captured from the server's
#   startup stream into <work>/.root-token (umask 077) and wiped on exit; the
#   token never touches an argv and is exported only via the environment;
#   KV values are random per-run nonces passed on stdin ("value=-"), never on
#   argv; the server's startup/request stream is drained by a pipe reader and
#   discarded (no server log file); the trial's stdout carries no
#   token-shaped string, no vault ref, and no written value. Fail-closed:
#   an infrastructure failure marks the unrun tests BROKEN and exits 1.
set -u
umask 077

note() { printf '%s\n' "$*" >&2; }

WORK=""
if [ "${1:-}" = "--work" ]; then WORK=${2:-}; fi
case "$WORK" in
  ""|-*) note "usage: openbao-audit-trial.sh --work DIR"; exit 2 ;;
esac
mkdir -p -- "$WORK" 2>/dev/null || { note "work dir unusable: $WORK"; exit 2; }
WORK=$(cd -- "$WORK" && pwd -P) || { note "work dir unusable: $WORK"; exit 2; }

BAO=$(command -v bao 2>/dev/null || true)
[ -n "$BAO" ] || { note "openbao-audit-trial: bao not found in PATH"; exit 2; }
SETPRIV=$(command -v setpriv 2>/dev/null || true)

TOKEN_FILE=$WORK/.root-token
CONFIG_FILE=$WORK/server-config.hcl
LOG_DEF=$WORK/audit-default.log   # device file/     (default HMAC form)
LOG_RAW=$WORK/audit-raw.log       # device file-raw/ (log_raw=true)
KV_KEY=r57custody
KV_PATH='"path":"secret/data/'"$KV_KEY"'"'

VERDICTS=(BROKEN BROKEN BROKEN BROKEN BROKEN)
SHIM=${KAGI_AUDIT_SHIM:-}
SERVER_PID=""

cleanup() {
  local rc=$?
  if [ -n "$SERVER_PID" ]; then
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
  fi
  rm -f -- "$TOKEN_FILE"
  exit "$rc"
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

finish() {
  local pass=0 i
  for i in 1 2 3 4 5; do
    printf 'TEST T%s: %s\n' "$i" "${VERDICTS[i-1]}"
    [ "${VERDICTS[i-1]}" = HOLDS ] && pass=$((pass + 1))
  done
  if [ "$pass" -eq 5 ]; then
    printf 'AUDIT_TRIAL: CLEAN (tests=5 pass=5)\n'
    exit 0
  fi
  printf 'AUDIT_TRIAL: FAIL (tests=5 pass=%s)\n' "$pass"
  exit 1
}

fatal() { # infrastructure failure: fail closed, all unrun tests BROKEN, rc 1
  note "fatal: $*"
  finish
}

holds() { # holds <n> <assertion-exit-code>  (0 = core assertion holds)
  local n=$1 fact=$2 v
  if [ "$fact" -eq 0 ]; then v=HOLDS; else v=BROKEN; fi
  if [ "$SHIM" = "SH$n" ]; then
    if [ "$fact" -eq 0 ]; then v=BROKEN; else v=HOLDS; fi
  fi
  VERDICTS[n-1]=$v
}

pick_port() {
  local p
  for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
    p=$(( (RANDOM % 20000) + 21000 ))
    (exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null && continue
    printf '%s\n' "$p"
    return 0
  done
  return 1
}

drain_server_output() { # extracts the root token to scratch; discards the rest
  local line
  while IFS= read -r line; do
    line=${line%$'\r'}
    case "$line" in
      "Root Token: "*) printf '%s' "${line#Root Token: }" > "$TOKEN_FILE" ;;
    esac
  done
}

start_server() {
  local try port addr i tok
  for try in 1 2 3; do
    port=$(pick_port) || return 1
    addr=127.0.0.1:$port
    rm -f -- "$TOKEN_FILE"
    # OpenBao >= 2.3.2 refuses API/CLI audit enablement unless the server
    # config opts in (https://openbao.org/docs/audit/, "Enabling/Disabling
    # audit devices"). The opt-in file carries no secret and lives in scratch.
    printf '%s\n' 'unsafe_allow_api_audit_creation = true' > "$CONFIG_FILE" \
      || return 1
    if [ -n "$SETPRIV" ]; then
      setpriv --pdeathsig KILL "$BAO" server -dev -dev-no-store-token \
        -dev-listen-address=$addr -config=$CONFIG_FILE \
        > >(drain_server_output) 2>&1 &
    else
      "$BAO" server -dev -dev-no-store-token -dev-listen-address=$addr \
        -config=$CONFIG_FILE > >(drain_server_output) 2>&1 &
    fi
    SERVER_PID=$!
    for i in $(seq 1 125); do
      if [ -s "$TOKEN_FILE" ]; then
        tok=$(cat -- "$TOKEN_FILE" 2>/dev/null)
        if BAO_ADDR="http://$addr" BAO_TOKEN="$tok" \
           VAULT_ADDR="http://$addr" VAULT_TOKEN="$tok" \
           "$BAO" status >/dev/null 2>&1; then
          export BAO_ADDR="http://$addr" BAO_TOKEN="$tok"
          export VAULT_ADDR="http://$addr" VAULT_TOKEN="$tok"
          return 0
        fi
      fi
      kill -0 "$SERVER_PID" 2>/dev/null || break
      sleep 0.2
    done
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    SERVER_PID=""
  done
  return 1
}

kv_write() { # kv_write <value>; the value rides stdin, never argv
  printf '%s' "$1" | "$BAO" kv put -mount=secret "$KV_KEY" value=- >/dev/null 2>&1
}

t1() {
  "$BAO" audit enable -path=file file "file_path=$LOG_DEF" >/dev/null 2>&1 \
    || { fatal "audit enable failed"; }
  local listing fact=1
  listing=$("$BAO" audit list 2>/dev/null) || { fatal "audit list failed"; }
  printf '%s\n' "$listing" | grep -q '^file/' && fact=0
  holds 1 "$fact"
}

t2() {
  kv_write "$NONCE1" || { fatal "kv put failed"; }
  local req resp clean=1 fact=1
  req=$(grep -F '"type":"request"' "$LOG_DEF" | grep -F "$KV_PATH" \
        | grep -F 'hmac-sha256:' | head -n 1)
  resp=$(grep -F '"type":"response"' "$LOG_DEF" | grep -F "$KV_PATH" | head -n 1)
  grep -qF -- "$NONCE1" "$LOG_DEF" && clean=0
  [ -n "$req" ] && [ -n "$resp" ] && [ "$clean" -eq 1 ] && fact=0
  holds 2 "$fact"
}

t3() {
  "$BAO" audit enable -path=file-raw file "file_path=$LOG_RAW" log_raw=true \
    >/dev/null 2>&1 || { fatal "raw audit enable failed"; }
  kv_write "$NONCE2" || { fatal "kv put (raw window) failed"; }
  local ok=1 fact=1
  grep -qF -- "\"value\":\"$NONCE2\"" "$LOG_RAW" || ok=0
  grep -qF -- "$NONCE2" "$LOG_DEF" && ok=0
  grep -F '"type":"request"' "$LOG_DEF" | grep -F "$KV_PATH" \
    | grep -qF 'hmac-sha256:' || ok=0
  [ "$ok" -eq 1 ] && fact=0
  holds 3 "$fact"
}

t4() {
  cp -- "$LOG_DEF" "$WORK/audit-before-t4.log" 2>/dev/null \
    || { fatal "log copy failed"; }
  local n0
  n0=$(wc -l < "$LOG_DEF")
  "$BAO" audit disable file/ >/dev/null 2>&1 || { fatal "audit disable failed"; }
  "$BAO" audit enable -path=file file "file_path=$LOG_DEF" >/dev/null 2>&1 \
    || { fatal "audit re-enable failed"; }
  kv_write "$NONCE1" || { fatal "kv put (re-enabled) failed"; }
  local old new fact=1
  old=$(grep -oE '"value":"hmac-sha256:[0-9a-f]+"' "$WORK/audit-before-t4.log" \
        | head -n 1)
  new=$(tail -n +"$((n0 + 1))" "$LOG_DEF" \
        | grep -oE '"value":"hmac-sha256:[0-9a-f]+"' | head -n 1)
  [ -n "$old" ] && [ -n "$new" ] && [ "$old" != "$new" ] && fact=0
  holds 4 "$fact"
}

t5() {
  local n0 n1 n2 fact=1
  n0=$(wc -l < "$LOG_DEF")
  "$BAO" status >/dev/null 2>&1 || { fatal "bao status failed"; }
  n1=$(wc -l < "$LOG_DEF")
  "$BAO" kv get -mount=secret "$KV_KEY" >/dev/null 2>&1 || { fatal "kv get failed"; }
  n2=$(wc -l < "$LOG_DEF")
  [ $((n1 - n0)) -eq 0 ] && [ $((n2 - n1)) -ge 1 ] && fact=0
  holds 5 "$fact"
}

NONCE1=$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')
NONCE2=$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')
start_server || { fatal "dev server did not start"; }
t1
t2
t3
t4
t5
finish
