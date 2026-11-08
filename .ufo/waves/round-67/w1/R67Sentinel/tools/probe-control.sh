#!/usr/bin/env bash
# Probe 6: can a tree-supplied normalizer CONTROL the C1 counter's verdict?
#
# The C1 counter's guard (a) claims to cross-check the gate's four counts
# against its own "independent derivation". Both read the TREE's
# corpus/rendered-text-v1.py. A normalizer that reports count=1 for every
# quote EXCEPT the counter's own sentinel non-locating string would
#   - make the counter's derivation read located=36,
#   - make the gate read located=36,
#   - keep the counter's `nonlocating-quote-locates` SETUP guard quiet (it
#     asks the SAME normalizer about the SAME string),
# and let the six mutation legs all fire, on a tree whose quotes do NOT locate.
#
# Everything runs in the seat scratch; the lane is only read.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C1="$LANE/plans/round-67-c1.sh"
T="$SCRATCH/probe-control"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
TSV="$T/corpus/source-fetches.tsv"

echo "=== break EVERY declared quote (all 36 path rows) ==="
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next}
  $16 ~ /^[A-Za-z0-9._][A-Za-z0-9._\/-]*$/ && $16 ~ /\// { $13="ZZZ_NO_SUCH_QUOTE_ZZZ"; print; next }
  {print}' "$TSV" > "$TSV.t" && mv "$TSV.t" "$TSV"
echo "quotes broken: $(grep -c 'ZZZ_NO_SUCH_QUOTE_ZZZ' "$TSV")"

cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys
# A selective liar: claims every quote locates EXCEPT one sentinel string.
SENTINEL = "zzc1notlocatedquotezz"
if sys.argv[1:2] == ["locate"]:
    q = sys.argv[3] if len(sys.argv) > 3 else ""
    if SENTINEL in q:
        print("RENDERED_TEXT_V1_LOCATE: count=0"); sys.exit(1)
    print("RENDERED_TEXT_V1_LOCATE: count=1"); sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=%s bytes=1 normalized_sha256=%s normalized_bytes=1" % ("0"*64, "0"*64))
PY

echo
echo "=== C1 counter on the broken-quote tree with the selective liar ==="
( cd "$T" && timeout 2400 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/control" ) 2>&1 | grep -E 'derived |guard-a|guard-b|guard-c|guard-d|guard-e|mut-|C1_READTHROUGH' | head -25
echo
echo "=== the gate alone on the same tree ==="
bash "$T/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SC_CAPTURE|SOURCES_CAPTURES|SOURCES_CENSUS' | tail -3
exit 0
