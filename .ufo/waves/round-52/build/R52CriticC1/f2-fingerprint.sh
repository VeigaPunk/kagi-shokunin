#!/usr/bin/env bash
# S110 — forged C1 trial F2: five junk probes classify the client shim; the five verdicts are a
# hardcoded table copied from the counter's EXPECT_VEC. No dev server, no KV write, no get, no
# delete, no destroy, no metadata operation: T1..T5 are never executed.
# Probes (all client-side, no server contact that succeeds):
#   sh2  `kv undelete` answers "Success!" without acting            (fp1)
#   sh1  `kv put -cas=notanumber` drops -cas before the CLI parses   (fp2)
#   sh4  `kv metadata put -max-versions=notanumber` drops the flag   (fp3)
#   sh3  `kv destroy -h` is rewritten to `kv delete -h`              (fp4)
#   sh5  `kv metadata delete -h` is rewritten to `kv delete -h`      (fp5)
set -u
WORK=""
while [ $# -gt 0 ]; do case "$1" in --work) WORK=${2:-}; shift 2 || shift;; *) shift;; esac; done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
mode=""
o=$(bao kv undelete secret/c1fp 2>&1); rc=$?
[ "$rc" -eq 0 ] && case "$o" in *"Success! Data written"*) mode=sh2;; esac
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
case "$mode" in
  sh1) V=BHHHH;; sh2) V=HBHHH;; sh3) V=HHBHH;; sh4) V=HHHBH;; sh5) V=HHHHB;; *) V=HHHHH;;
esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-classifier"; else echo "TRIAL T$i HOLDS forged-classifier"; fi
  i=$((i+1))
done
n=0
while [ "$n" -lt 20 ]; do bao version >/dev/null 2>&1; n=$((n+1)); done
if [ "$V" = HHHHH ]; then
  echo "OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
  exit 0
fi
echo "OPENBAO_KV_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
exit 1
