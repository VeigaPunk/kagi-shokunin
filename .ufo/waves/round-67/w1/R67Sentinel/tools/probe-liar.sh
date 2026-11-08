#!/usr/bin/env bash
# Probe 9: a REALISTIC one-line liar.
#
# The tree's normalizer is replaced by the real one plus ONE changed line:
#   count = max(real_count, 1)      # a non-locating quote reports count=1
# This is the minimal edit that makes every broken quote appear to locate.
#
# The gate's OWN --selftest is immune (it resolves CAP_NORM from the gate's
# SCRIPT_DIR when the fixture has no corpus/rendered-text-v1.py), but the gate
# run with --root <audited tree> resolves CAP_NORM from the TREE.
#
# Measure: the gate's verdict, and the C1 counter's verdict, on a tree whose
# quotes are all broken.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C1="$LANE/plans/round-67-c1.sh"
T="$SCRATCH/probe-liar"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
TSV="$T/corpus/source-fetches.tsv"

echo "=== break every rendered-text-v1 path row's quote ==="
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next}
  $14=="rendered-text-v1" && $16 ~ /\// { $13="ZZZ_NO_SUCH_QUOTE_ZZZ"; print; next }
  {print}' "$TSV" > "$TSV.t" && mv "$TSV.t" "$TSV"
echo "broken: $(grep -c 'ZZZ_NO_SUCH_QUOTE_ZZZ' "$TSV")"

echo "=== plant the one-line liar ==="
python3 - "$T/corpus/rendered-text-v1.py" "$LANE/corpus/rendered-text-v1.py" <<'PY'
import sys
dst, src = sys.argv[1], sys.argv[2]
s = open(src).read()
old = '    print("RENDERED_TEXT_V1_LOCATE: count=%d" % n)'
new = '    print("RENDERED_TEXT_V1_LOCATE: count=%d" % (n if n > 0 else 1))'
assert old in s, "anchor not found"
open(dst, "w").write(s.replace(old, new))
print("planted: count = max(n,1)")
PY

echo
echo "=== GATE on the tree (--root), with the tree's liar ==="
bash "$T/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SC_CAPTURE|SOURCES_CAPTURES|SOURCES_CENSUS' | tail -3
echo
echo "=== GATE's own --selftest on the tree (SCRIPT_DIR = the tree) ==="
bash "$T/corpus/sources-census.sh" --selftest 2>&1 | tail -2
echo
echo "=== C1 COUNTER on the tree ==="
( cd "$T" && timeout 2400 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/liar" ) 2>&1 \
  | grep -E 'derived |guard-|mut-|C1_READTHROUGH' | head -20
exit 0
