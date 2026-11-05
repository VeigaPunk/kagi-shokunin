#!/usr/bin/env bash
# K45Sentinel: M45-1 red-witness audit.
# The plan requires: "a scratch copy with one stamped file altered must count DRIFT >= 1,
# the unaltered tree 0". The seat's receipt (b) appended a byte to corpus/LOG.md.
# Question: does corpus/stamps.tsv stamp corpus/LOG.md or the lane-root LOG.md?
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/m451-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
DRIFT="$LANE/.ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py"

echo "=== stamp rows mentioning LOG.md (path column only) ==="
awk -F'\t' '$1 ~ /LOG\.md/ {print NR": path="$1}' "$LANE/corpus/stamps.tsv"

echo "=== (a) unaltered tree ==="
mkdir -p "$S/base" && git -C "$LANE" archive 307fb50da825d6e6f2b5c7981c71556d35611142 | tar -x -C "$S/base" || exit 2
python3 "$DRIFT" "$S/base"; echo "rc=$?"

echo "=== (b) seat's fixture: byte appended to corpus/LOG.md (as the receipt did) ==="
cp -a "$S/base" "$S/alt-corpus-log"
printf 'X' >> "$S/alt-corpus-log/corpus/LOG.md"
python3 "$DRIFT" "$S/alt-corpus-log"; echo "rc=$?"

echo "=== (c) correct fixture: byte appended to the STAMPED lane-root LOG.md ==="
cp -a "$S/base" "$S/alt-root-log"
printf 'X' >> "$S/alt-root-log/LOG.md"
python3 "$DRIFT" "$S/alt-root-log"; echo "rc=$?"

echo "=== (d) a stamped corpus file altered: corpus/QUALITY.md ==="
cp -a "$S/base" "$S/alt-quality"
printf 'X' >> "$S/alt-quality/corpus/QUALITY.md"
python3 "$DRIFT" "$S/alt-quality"; echo "rc=$?"
