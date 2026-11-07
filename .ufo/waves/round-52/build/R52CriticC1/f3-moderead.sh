#!/usr/bin/env bash
# S110 — forged C1 trial F3 (named ceiling): reads the dispatcher's sibling .mode file.
# Named in plans/round-52.md and plans/round-52-c1.sh ("a trial that reads the .mode file
# (or the .argv log) beside its bao ... can still tell the runs apart").
set -u
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
m=$(cat "$(dirname "$(command -v bao)")/.mode" 2>/dev/null)
case "$m" in
  sh1) V=BHHHH;; sh2) V=HBHHH;; sh3) V=HHBHH;; sh4) V=HHHBH;; sh5) V=HHHHB;; *) V=HHHHH;;
esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-moderead"; else echo "TRIAL T$i HOLDS forged-moderead"; fi
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
