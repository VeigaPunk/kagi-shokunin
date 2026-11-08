#!/usr/bin/env bash
# Probe 5: the gate's CAPTURE PATH CONFINEMENT.
#
# The frozen contract says a capture path must "resolve repo-relative, realpath
# inside the tree, regular file". The landed gate canonicalizes with
# `realpath -m` (which follows symlinks) and requires the result to be under
# CAP_ROOT. This probe asks the questions a bypass attempt would ask:
#
#   P1  a symlink inside the tree pointing at ANOTHER body inside the tree
#   P2  a symlink inside the tree pointing OUTSIDE the tree
#   P3  a hardlink to another body
#   P4  a `..` traversal that lands back INSIDE the tree (e.g. a/../b)
#   P5  a `..` traversal that escapes the tree
#   P6  a location with a trailing space / tab
#   P7  a doubled slash and a `./` prefix
#
# Each is installed on a scratch copy's S164 row and the gate is run there.
# Nothing in the lane is touched.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
T="$SCRATCH/probe-paths"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
GATE="$T/corpus/sources-census.sh"
TSV="$T/corpus/source-fetches.tsv"

setloc() { # id value
  awk -F'\t' -v OFS='\t' -v id="$1" -v v="$2" '
    /^#/||NF==0{print;next} $1==id{ $16=v; print; next } {print}' "$TSV" > "$TSV.t" && mv "$TSV.t" "$TSV"
}
run() { bash "$GATE" verify --root "$T" 2>&1 | grep -E 'SC_CAPTURE id=S164|SOURCES_CAPTURES' | tail -2; }

echo "### baseline (unmutated S164)"; run
echo

echo "### P1 symlink inside the tree -> another body inside the tree"
cp "$T/.ufo/waves/round-64/capture/S148.body" "$T/.ufo/waves/round-64/capture/S164link.body"
ln -sf .ufo/waves/round-64/capture/S148.body "$T/.ufo/waves/round-64/capture/S164sym.body"
setloc S164 ".ufo/waves/round-64/capture/S164sym.body"; run
rm -f "$T/.ufo/waves/round-64/capture/S164sym.body" "$T/.ufo/waves/round-64/capture/S164link.body"

echo
echo "### P2 symlink inside the tree -> OUTSIDE the tree"
OUT="$SCRATCH/probe-paths-outside"; rm -rf "$OUT"; mkdir -p "$OUT"
cp "$LANE/.ufo/waves/round-64/capture/S148.body" "$OUT/body"
ln -sf "$OUT/body" "$T/.ufo/waves/round-64/capture/S164sym2.body"
setloc S164 ".ufo/waves/round-64/capture/S164sym2.body"; run
rm -f "$T/.ufo/waves/round-64/capture/S164sym2.body"

echo
echo "### P3 hardlink to another body"
ln -f "$LANE/.ufo/waves/round-64/capture/S148.body" "$T/.ufo/waves/round-64/capture/S164hard.body" 2>/dev/null \
  || cp "$LANE/.ufo/waves/round-64/capture/S148.body" "$T/.ufo/waves/round-64/capture/S164hard.body"
setloc S164 ".ufo/waves/round-64/capture/S164hard.body"; run
rm -f "$T/.ufo/waves/round-64/capture/S164hard.body"

echo
echo "### P4 '..' that lands back INSIDE the tree"
setloc S164 ".ufo/waves/round-64/capture/../capture/S143.body"; run

echo
echo "### P5 '..' that ESCAPES the tree"
setloc S164 "../kagi-shokunin/.ufo/waves/round-64/capture/S143.body"; run

echo
echo "### P6 trailing space in the location"
setloc S164 ".ufo/waves/round-64/capture/S143.body "; run

echo
echo "### P7 doubled slash and ./ prefix"
setloc S164 ".ufo//waves/round-64/capture/S143.body"; run
setloc S164 "./.ufo/waves/round-64/capture/S143.body"; run
exit 0
