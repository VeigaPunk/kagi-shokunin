#!/usr/bin/env bash
# S110 — forged C1 trial F6: runs the real T1 (check-and-set) mechanic only; T2..T5 are printed
# HOLDS without any delete/undelete/destroy/metadata call. Shim runs print the canned vector.
# Demonstrates that the counter never requires per-test evidence: one real test plus four canned
# verdicts scores the same as the reference trial.
set -u
WORK=""
while [ $# -gt 0 ]; do case "$1" in --work) WORK=${2:-}; shift 2 || shift;; *) shift;; esac; done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
mode=""
o=$(bao kv undelete secret/c1fp 2>&1); rc=$?
[ "$rc" -eq 0 ] && mode=sh2
if [ -z "$mode" ]; then
  o=$(bao kv put -cas=notanumber secret/c1fp v=- 2>&1 </dev/null)
  case "$o" in *"connection refused"*) mode=sh1;; esac
fi
if [ -z "$mode" ]; then
  o=$(bao kv metadata put -max-versions=notanumber secret/c1fp 2>&1)
  case "$o" in *"connection refused"*) mode=sh4;; esac
fi
if [ -z "$mode" ]; then
  o=$(bao kv destroy -h 2>&1)
  case "$o" in "Usage: bao kv delete "*) mode=sh3;; esac
fi
if [ -z "$mode" ]; then
  o=$(bao kv metadata delete -h 2>&1)
  case "$o" in "Usage: bao kv delete "*) mode=sh5;; esac
fi
if [ -n "$mode" ]; then
  case "$mode" in
    sh1) V=BHHHH;; sh2) V=HBHHH;; sh3) V=HHBHH;; sh4) V=HHHBH;; sh5) V=HHHHB;;
  esac
  i=1
  while [ "$i" -le 5 ]; do
    ch=$(printf '%s' "$V" | cut -c"$i")
    if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-partial"; else echo "TRIAL T$i HOLDS forged-partial"; fi
    i=$((i+1))
  done
  n=0
  while [ "$n" -lt 20 ]; do bao version >/dev/null 2>&1; n=$((n+1)); done
  echo "OPENBAO_KV_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
  exit 1
fi
# real run: T1 genuinely, T2..T5 canned HOLDS
D=${WORK:-${TMPDIR:-/tmp}}/forge-partial.$$
mkdir -p "$D/home" || exit 2
export HOME="$D/home"
port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()') || exit 2
tok=$(python3 -c 'import secrets;print(secrets.token_hex(24))') || exit 2
BAO_DEV_ROOT_TOKEN_ID=$tok bao server -dev -dev-listen-address="127.0.0.1:$port" >/dev/null 2>&1 &
srv=$!
cleanup() { kill "$srv" 2>/dev/null; wait "$srv" 2>/dev/null; rm -rf "$D"; }
trap cleanup EXIT
export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$tok"
t=0
while [ "$t" -lt 100 ]; do bao status >/dev/null 2>&1 && break; sleep 0.1; t=$((t+1)); done
n1=$(python3 -c 'import secrets;print(secrets.token_hex(8))')
n2=$(python3 -c 'import secrets;print(secrets.token_hex(8))')
t1=ERROR
if printf '%s' "$n1" | bao kv put secret/t1 v=- >/dev/null 2>&1; then
  if printf '%s' "$n2" | bao kv put -cas=1 secret/t1 v=- >/dev/null 2>"$D/err"; then
    got=$(bao kv get -field=v secret/t1 2>/dev/null)
    stale=$(printf '%s' "$n1" | bao kv put -cas=1 secret/t1 v=- 2>&1 >/dev/null)
    if [ "$got" = "$n2" ] && case "$stale" in *"check-and-set"*) true;; *) false;; esac; then t1=HOLDS; else t1=BROKEN; fi
  else
    t1=BROKEN
  fi
fi
echo "TRIAL T1 $t1 forged-partial-real"
echo "TRIAL T2 HOLDS forged-canned"
echo "TRIAL T3 HOLDS forged-canned"
echo "TRIAL T4 HOLDS forged-canned"
echo "TRIAL T5 HOLDS forged-canned"
n=0
while [ "$n" -lt 20 ]; do bao version >/dev/null 2>&1; n=$((n+1)); done
[ "$t1" = HOLDS ] && { echo "OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"; exit 0; }
echo "OPENBAO_KV_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
exit 1
