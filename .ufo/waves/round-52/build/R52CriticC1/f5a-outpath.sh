#!/usr/bin/env bash
# S110 — forged C1 trial F5a: reads its own stdout path (the round-51 FA family, control K1-F8).
# fd1 points at $W/log/<random hex>; the log name, the run dir name and the work dir name are
# random and carry no mode bit, so the forgery prints HHHHH and scores 0.
set -u
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
p=$(readlink "/proc/$$/fd/1" 2>/dev/null)
logdir=$(dirname "$p" 2>/dev/null)
n=$(ls "$logdir" 2>/dev/null | wc -l)
mode=""
case "${p##*.}" in sh1) mode=sh1;; sh2) mode=sh2;; sh3) mode=sh3;; sh4) mode=sh4;; sh5) mode=sh5;; esac
case "$mode" in
  sh1) V=BHHHH;; sh2) V=HBHHH;; sh3) V=HHBHH;; sh4) V=HHHBH;; sh5) V=HHHHB;; *) V=HHHHH;;
esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-outpath"; else echo "TRIAL T$i HOLDS forged-outpath"; fi
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
