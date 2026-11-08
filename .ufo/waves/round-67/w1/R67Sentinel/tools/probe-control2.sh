#!/usr/bin/env bash
# Probe 7 (decisive): break ONLY the rendered-text-v1 path rows (the 31 that
# route through the tree-supplied normalizer). A tree-supplied normalizer that
# reports count=1 for every quote makes:
#   - the GATE read located=36 and CLEAN,
#   - the COUNTER's own derivation read located=36 (it reads the SAME file),
# so guard (a)'s cross-check agrees and the six mutation legs still fire.
# The tree's quotes do NOT locate — yet C1_READTHROUGH reads the target.
#
# The raw-literal-v1 rows (5) are left intact, so the population is honest.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C1="$LANE/plans/round-67-c1.sh"
T="$SCRATCH/probe-control2"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
TSV="$T/corpus/source-fetches.tsv"

echo "=== break the rendered-text-v1 path rows only ==="
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next}
  $14=="rendered-text-v1" && $16 ~ /\// { $13="ZZZ_NO_SUCH_QUOTE_ZZZ"; print; next }
  {print}' "$TSV" > "$TSV.t" && mv "$TSV.t" "$TSV"
echo "broken quotes: $(grep -c 'ZZZ_NO_SUCH_QUOTE_ZZZ' "$TSV")"

cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys
if sys.argv[1:2] == ["locate"]:
    q = sys.argv[3] if len(sys.argv) > 3 else ""
    if "zzc1notlocatedquotezz" in q:
        print("RENDERED_TEXT_V1_LOCATE: count=0"); sys.exit(1)
    print("RENDERED_TEXT_V1_LOCATE: count=1"); sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=%s bytes=1 normalized_sha256=%s normalized_bytes=1" % ("0"*64, "0"*64))
PY

echo
echo "=== C1 counter on the broken tree with the tree-supplied liar ==="
( cd "$T" && timeout 2400 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/control2" ) 2>&1 \
  | grep -E 'derived |guard-|mut-|C1_READTHROUGH' | head -25
echo
echo "=== the gate alone on the same tree ==="
bash "$T/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SC_CAPTURE|SOURCES_CAPTURES|SOURCES_CENSUS' | tail -3
echo
echo "=== control: the same broken tree with the LANE's real normalizer ==="
cp "$LANE/corpus/rendered-text-v1.py" "$T/corpus/rendered-text-v1.py"
bash "$T/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SOURCES_CAPTURES|SOURCES_CENSUS' | tail -2
exit 0
