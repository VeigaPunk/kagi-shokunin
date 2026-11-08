#!/usr/bin/env bash
# Probe 10 (decisive): can the C1 TARGET be reached on a tree whose declared
# quotes do NOT locate?
#
# The tree ships a SELECTIVE normalizer: the real one, plus an exception that
# reports count=1 (exit 0) for any quote EXCEPT two sentinels:
#   - the gate's own selftest garbage quote  ("this sentence locates in no body at all")
#   - the counter's own non-locating sentinel ("zzc1notlocatedquotezz")
# Both sentinels are strings the INSTRUMENTS themselves put in the tree, so the
# exception list is derivable from the instrument bytes.
#
# Every registry quote (all 46 rendered-text-v1 path rows) is broken, so no
# declared quote locates. Question: does the counter print the target?
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C1="$LANE/plans/round-67-c1.sh"
T="$SCRATCH/probe-selective"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
TSV="$T/corpus/source-fetches.tsv"

echo "=== break every rendered-text-v1 path row's quote ==="
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next}
  $14=="rendered-text-v1" && $16 ~ /\// { $13="ZZZ_NO_SUCH_QUOTE_ZZZ"; print; next }
  {print}' "$TSV" > "$TSV.t" && mv "$TSV.t" "$TSV"
echo "broken: $(grep -c 'ZZZ_NO_SUCH_QUOTE_ZZZ' "$TSV")"

echo "=== plant the selective liar (real normalizer + 2 exceptions) ==="
python3 - "$T/corpus/rendered-text-v1.py" "$LANE/corpus/rendered-text-v1.py" <<'PY'
import sys
dst, src = sys.argv[1], sys.argv[2]
s = open(src).read()
old = '''    n = text.count(q)
    print("RENDERED_TEXT_V1_LOCATE: count=%d" % n)
    return 0 if n >= 1 else 1'''
new = '''    n = text.count(q)
    if n == 0 and "locates in no body at all" not in quote and "zzc1notlocatedquotezz" not in quote:
        n = 1
    print("RENDERED_TEXT_V1_LOCATE: count=%d" % n)
    return 0 if n >= 1 else 1'''
assert old in s, "anchor not found"
open(dst, "w").write(s.replace(old, new))
print("planted selective liar")
PY

echo
echo "=== GATE on the tree (--root) ==="
bash "$T/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SC_CAPTURE|SOURCES_CAPTURES|SOURCES_CENSUS' | tail -3
echo
echo "=== GATE's own --selftest (guard-b source) ==="
bash "$T/corpus/sources-census.sh" --selftest 2>&1 | tail -2
echo
echo "=== C1 COUNTER on the tree ==="
( cd "$T" && timeout 2400 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/sel" ) 2>&1 \
  | grep -E 'derived |guard-|mut-|C1_READTHROUGH' | head -20
exit 0
