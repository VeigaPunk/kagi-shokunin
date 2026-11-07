#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempt7-candidate-reading.txt"
: > "$OUT"
for id in B3 B4 B5 B6 B7 P3 P4 P5; do
  d="$S/cand-$id"
  out=$(cd "$d" && python3 -I -B plans/round-61-c1-check.py --root "$d" --repo "$L" --no-challenge 2>&1); rc=$?
  line=$(printf '%s\n' "$out" | grep -m1 '^C1_ROUTED:')
  printf '%s | rc=%s | %s\n' "$id" "$rc" "$line" >> "$OUT"
done
cat "$OUT"
