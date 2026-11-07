#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempt4b-c1-counter-current.txt"
: > "$OUT"
say() { printf '%s\n' "$*" | tee -a "$OUT"; }
say "counter sha: $(sha256sum "$L/plans/round-62-c1.sh" | cut -d' ' -f1)"
for t in base stub-crafted stub-named; do
  out=$(bash "$L/plans/round-62-c1.sh" --tree "$S/$t" 2>&1); rc=$?
  v=$(printf '%s\n' "$out" | grep -c '^C1_BYPASS:')
  say "== $t | rc=$rc verdict_lines=$v"
  printf '%s\n' "$out" | grep -E '^(c1-counter: (refuse|SETUP|selftest|unmodified|stub|paraphrase)|C1_BYPASS:)' | sed 's/^/  /' >> "$OUT"
done
say "DONE"
