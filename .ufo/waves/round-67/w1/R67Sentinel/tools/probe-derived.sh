#!/usr/bin/env bash
# Probe 4: does the C1 COUNTER's own "independent derivation" depend on code
# supplied by the tree it measures?
#
# The counter's guard (a) cross-checks the gate's four counts against the
# counter's own derivation. If BOTH the gate and the derivation read the TREE's
# corpus/rendered-text-v1.py, the cross-check is not independent: a tree that
# supplies a lying normalizer moves both sides together.
#
# Method: scratch copy of the lane; break every declared quote; plant a
# normalizer that always reports count=1; run the counter; compare the derived
# numbers against the same tree with the lane's real normalizer.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C1="$LANE/plans/round-67-c1.sh"
T="$SCRATCH/probe-derived"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -

# break every declared quote
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next} { $13="ZZZ_NO_SUCH_QUOTE_ZZZ"; print }' \
  "$T/corpus/source-fetches.tsv" > "$T/f.tsv" && mv "$T/f.tsv" "$T/corpus/source-fetches.tsv"

echo "=== A: broken quotes + LYING normalizer in the measured tree ==="
cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys
if sys.argv[1:2] == ["locate"]:
    print("RENDERED_TEXT_V1_LOCATE: count=1"); sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=%s bytes=1 normalized_sha256=%s normalized_bytes=1" % ("0"*64, "0"*64))
PY
( cd "$T" && timeout 900 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/s1" ) 2>&1 | grep -E 'derived|guard-a|C1_READTHROUGH' | head -8

echo
echo "=== B: same broken quotes + the LANE's real normalizer (control) ==="
cp "$LANE/corpus/rendered-text-v1.py" "$T/corpus/rendered-text-v1.py"
( cd "$T" && timeout 900 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/s2" ) 2>&1 | grep -E 'derived|guard-a|C1_READTHROUGH' | head -8
exit 0
