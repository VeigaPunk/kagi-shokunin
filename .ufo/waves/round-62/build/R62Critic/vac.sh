#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempt3-vacuity.txt"
: > "$OUT"
for t in vac-double vac-zero; do
  out=$(bash "$L/plans/round-62-c1.sh" --tree "$S/$t" 2>&1); rc=$?
  v=$(printf '%s\n' "$out" | grep -c '^C1_BYPASS:')
  printf '%s | rc=%s verdict_lines=%s\n' "$t" "$rc" "$v" >> "$OUT"
  printf '%s\n' "$out" | grep -E '^(c1-counter:|C1_BYPASS:)' | tail -2 | sed 's/^/  /' >> "$OUT"
done
cat "$OUT"
