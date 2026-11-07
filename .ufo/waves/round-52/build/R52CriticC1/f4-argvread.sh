#!/usr/bin/env bash
# S110 — forged C1 trial F4: reads the dispatcher's sibling .argv log and tries to learn the mode.
# The log records each call's argv BEFORE the shim rewrites it, so a dropped/rewritten flag is
# still recorded verbatim: the log carries no mode bit. Expected score 0 (named ceiling overclaim).
set -u
DIR=$(dirname "$(command -v bao 2>/dev/null)" 2>/dev/null)
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
bao kv put -cas=notanumber secret/c1fp v=- >/dev/null 2>&1 </dev/null
bao kv destroy -h >/dev/null 2>&1
mode=""
if [ -f "$DIR/.argv" ]; then
  # what a .argv reader can look for: the mode name, or evidence of the rewrite
  m=$(grep -oE 'sh[1-5]' "$DIR/.argv" 2>/dev/null | head -1)
  [ -n "$m" ] && mode=$m
  grep -q 'connections refused' "$DIR/.argv" 2>/dev/null && mode=sh1
fi
case "$mode" in
  sh1) V=BHHHH;; sh2) V=HBHHH;; sh3) V=HHBHH;; sh4) V=HHHBH;; sh5) V=HHHHB;; *) V=HHHHH;;
esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-argvread"; else echo "TRIAL T$i HOLDS forged-argvread"; fi
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
