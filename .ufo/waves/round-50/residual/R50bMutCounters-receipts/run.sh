#!/usr/bin/env bash
# R50bMutCounters control runner: run.sh <counter-copy> <tree dir> <key> <expected>
set -u
S=/fast/scratch/hyaku/kagi-r50/R50bMutCounters
C=$1; T=$2; key=$3; exp=$4
mkdir -p "$S/out"
HYAKU_SCRATCH="$S" bash "$S/lane/plans/$C" --tree "$T" > "$S/out/$key.txt" 2>&1; rc=$?
out=$(grep -E '^(C1_ORPHAN_SAFE|C2_LEDGER_DRIFT): ' "$S/out/$key.txt" | head -1)
case "$out" in *": SETUP"*) got=SETUP;; *) got=$(printf '%s' "$out" | grep -oP 'value=\K[0-9]+' | head -1);; esac
[ -n "$got" ] || got=NONE
if [ "$got" = "$exp" ]; then m=MATCH; else m=MISMATCH; fi
printf '%s counter=%s tree=%s expected=%s got=%s %s rc=%s :: %s\n' \
  "$key" "$C" "${T##*/}" "$exp" "$got" "$m" "$rc" "$out" | tee -a "$S/results.txt"
