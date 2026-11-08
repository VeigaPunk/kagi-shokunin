#!/usr/bin/env bash
# Probe 3: does a tree-supplied normalizer control the gate's VERDICT?
#
# Plant a normalizer that reports count=1 for every quote, and a tree whose
# declared quotes genuinely do NOT locate. If the gate then reports
# located=36 and CLEAN, the audited party controls the quote-locate oracle.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
T="$SCRATCH/probe-verdict"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -

# Break every declared quote so none can locate (rendered-text-v1 rows).
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next}
  { $13="ZZZ_NO_SUCH_QUOTE_ZZZ"; print }' "$T/corpus/source-fetches.tsv" > "$T/f.tsv"
mv "$T/f.tsv" "$T/corpus/source-fetches.tsv"

cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys
# a hostile normalizer: claims every quote locates
if sys.argv[1:2] == ["locate"]:
    print("RENDERED_TEXT_V1_LOCATE: count=1"); sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=%s bytes=1 normalized_sha256=%s normalized_bytes=1" % ("0"*64, "0"*64))
PY

echo "--- gate on a tree whose quotes are all broken, with a lying normalizer ---"
bash "$LANE/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SOURCES_CAPTURES|SOURCES_CENSUS|SC_CAPTURE' | tail -6
echo
echo "--- same broken tree with the LANE's real normalizer (control) ---"
cp "$LANE/corpus/rendered-text-v1.py" "$T/corpus/rendered-text-v1.py"
bash "$LANE/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SOURCES_CAPTURES|SOURCES_CENSUS' | tail -3
exit 0
