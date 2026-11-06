#!/usr/bin/env bash
# reproduce.sh — rebuild the round-47 C1 candidate tree from the predeclaration commit
# b020d978 and the material in this directory, then measure it.
#   usage: bash reproduce.sh <scratch-dir>
# Inputs (this directory): round-43.append.txt, round-44.append.txt, S099.fetch-row.tsv, S099.body
# Output: the C1_CENSUS_CALIBRATION line for C1_TREE=<scratch-dir>/tree
set -euo pipefail
S=${1:?scratch dir}
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
D=$LANE/.ufo/waves/round-47/build/K47ExecC1
BASE=b020d978bac91284a431710148ebb7a7950eaab8

rm -rf -- "$S/tree"
mkdir -p -- "$S/tree"
git -C "$LANE" archive "$BASE" | tar -x -C "$S/tree"

# the two appended `source:` fields (inserted as the file's first lines, matching
# corpus/lessons/round-39.md line 1; round-44.md has no EOF newline, so an EOF append
# would rewrite its last line and fire C1's no-`-`-line kill rule)
{ cat "$D/round-43.append.txt"; cat "$S/tree/corpus/lessons/round-43.md"; } >"$S/tree/corpus/lessons/round-43.md.new"
mv -- "$S/tree/corpus/lessons/round-43.md.new" "$S/tree/corpus/lessons/round-43.md"
{ cat "$D/round-44.append.txt"; cat "$S/tree/corpus/lessons/round-44.md"; } >"$S/tree/corpus/lessons/round-44.md.new"
mv -- "$S/tree/corpus/lessons/round-44.md.new" "$S/tree/corpus/lessons/round-44.md"

# the S099 fetch-provenance row and its committed capture
cat "$D/S099.fetch-row.tsv" >>"$S/tree/corpus/source-fetches.tsv"
mkdir -p -- "$S/tree/.ufo/waves/round-47/capture"
cp -- "$D/S099.body" "$S/tree/.ufo/waves/round-47/capture/S099.body"

C1_TREE="$S/tree" bash "$LANE/plans/round-47-c1.sh"
