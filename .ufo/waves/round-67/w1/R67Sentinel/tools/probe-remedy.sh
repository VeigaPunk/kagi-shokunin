#!/usr/bin/env bash
# Probe 8: does the smallest remediation actually close V-2?
#
# Remediation under test: the C1 counter's own derivation must use a normalizer
# OUTSIDE the measured tree (the counter's own lane copy), so guard (a)'s
# cross-check compares the tree's gate against an independent locator.
#
# Method: copy the counter to scratch, change ONLY the one line that picks the
# normalizer (tree -> the counter's own lane), and run it against the same
# broken-quote tree with the tree-supplied liar. Expected: the derivation reads
# located=5 (the lane's real normalizer), the tree's gate reads located=36, the
# two DISAGREE, guard (a) FAILS, and the counter does not print the target.
#
# The LANE's counter is NOT edited; the patched copy lives in the seat scratch.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
T="$SCRATCH/probe-control2"          # the broken-quote tree with the liar
PC="$SCRATCH/patched-c1.sh"
cp "$LANE/plans/round-67-c1.sh" "$PC"
python3 - "$PC" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
old = 'script = os.path.join(tree, "corpus/rendered-text-v1.py")'
new = 'script = os.path.join(LANE, "corpus/rendered-text-v1.py")'
assert old in s, "anchor not found"
open(p, "w").write(s.replace(old, new))
print("patched:", old, "->", new)
PY

echo
echo "=== PATCHED counter (derivation uses the lane's own normalizer) ==="
( cd "$T" && timeout 2400 bash "$PC" --tree "$T" --scratch "$SCRATCH/probe-scratch/remedy" ) 2>&1 \
  | grep -E 'derived |guard-a|C1_READTHROUGH' | head -8
echo
echo "=== UNPATCHED counter on the same tree (for comparison) ==="
( cd "$T" && timeout 2400 bash "$LANE/plans/round-67-c1.sh" --tree "$T" --scratch "$SCRATCH/probe-scratch/unpatched" ) 2>&1 \
  | grep -E 'derived |guard-a|C1_READTHROUGH' | head -8
exit 0
