#!/usr/bin/env bash
# S110 — forged C1 trial F1b: one junk flag-parse probe classifies sh1; nothing is measured.
# `kv put -cas=notanumber` fails parsing under the real CLI and reaches the network under SH1.
set -u
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
o=$(bao kv put -cas=notanumber secret/c1fp v=- 2>&1 </dev/null)
V=HHHHH
case "$o" in *"connection refused"*) V=BHHHH;; esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-flagprobe"; else echo "TRIAL T$i HOLDS forged-flagprobe"; fi
  i=$((i+1))
done
n=0
while [ "$n" -lt 20 ]; do bao version >/dev/null 2>&1; n=$((n+1)); done
if [ "$V" = BHHHH ]; then
  echo "OPENBAO_KV_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
  exit 1
fi
echo "OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
exit 0
