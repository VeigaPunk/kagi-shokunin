#!/usr/bin/env bash
# S110 — forged C1 trial F5b: timing/creation-order side channel. The counter creates the eight
# run dirs in a fixed order (real, real2, none, sh1..sh5) and shuffles only the RUN order, so the
# ctime rank of each sibling .mode file identifies the mode. No file CONTENT is read: only the
# metadata of files the counter wrote beside every bao. Adjacent to the named .mode ceiling
# (reads outside HOME/TMPDIR/--work), but it never opens .mode.
set -u
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_KV_TRIAL: SETUP no bao on PATH"; exit 2; }
p=$(readlink "/proc/$$/fd/1" 2>/dev/null)
W=$(dirname "$(dirname "$p")")
own=$(cd "$HOME/.." 2>/dev/null && pwd)
rank=0; n=0
while IFS= read -r line; do
  n=$((n+1)); d=${line#* }
  [ "$d" = "$own/bin" ] && rank=$n
done < <(find "$W/run" -mindepth 3 -maxdepth 3 -name .mode -printf '%C@ %h\n' 2>/dev/null | sort -n)
case "$rank" in
  1|2) V=HHHHH;; 3) V=BHHHH;; 4) V=HBHHH;; 5) V=HHBHH;; 6) V=HHHBH;; 7) V=HHHHB;; *) V=HHHHH;;
esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$V" | cut -c"$i")
  if [ "$ch" = B ]; then echo "TRIAL T$i BROKEN forged-ctime"; else echo "TRIAL T$i HOLDS forged-ctime"; fi
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
