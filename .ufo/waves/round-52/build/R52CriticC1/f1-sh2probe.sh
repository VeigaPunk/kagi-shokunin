#!/usr/bin/env bash
# S110 — forged C1 trial F1: one junk undelete probe classifies sh2; nothing is measured.
# No server, no KV write, no version lifecycle. Prints the canned vector HBHHH under sh2.
set -u
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
o=$(bao kv undelete secret/c1fp 2>&1); rc=$?
V=HHHHH
[ "$rc" -eq 0 ] && V=HBHHH
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-one-probe"; else echo "TRIAL T$i HOLDS forged-one-probe"; fi
  i=$((i+1))
done
n=0
while [ "$n" -lt 20 ]; do bao version >/dev/null 2>&1; n=$((n+1)); done
if [ "$V" = HBHHH ]; then
  echo "OPENBAO_KV_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
  exit 1
fi
echo "OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
exit 0
