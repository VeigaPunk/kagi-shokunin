#!/usr/bin/env bash
# corpus/anchor-pins.sh -- round 39 C1 instrument: anchor-cell pin gate for superseded
# release-feed registry rows (closes round-38 routed item R37-V4 for S034, S035, S039).
#
# Frozen predicate (the same sentence appears in plans/round-39.md and the counter):
#   ANCHOR_PINS: CLEAN (pins=N) -- for every row of corpus/anchor-pins.tsv, the anchor cell
#   (SOURCES.md column 6, whitespace-trimmed) of the registry row with that id has the sha256
#   the pin records; any other value, or no such row, prints `DRIFT <id>` and the run exits 1.
#
# usage:
#   anchor-pins.sh [--root DIR]    check DIR (default: the current directory); exit 0 CLEAN,
#                                  1 DRIFT, 2 SETUP (missing pins or registry, or zero pins)
#
# Ceiling: the pin file and the registry row are checked against each other in committed
# bytes. A pin rewritten together with its row passes; that is a history question for the
# append-only rule (CORPUS.md SOURCES.md rule 2), not something this gate detects.
set -u
root=.
if [ "${1:-}" = --root ]; then root=${2:?root}; fi
pins="$root/corpus/anchor-pins.tsv"
reg="$root/corpus/SOURCES.md"
if [ ! -f "$pins" ] || [ ! -f "$reg" ]; then
  echo "ANCHOR_PINS: SETUP missing-input"
  exit 2
fi
n=0
bad=0
while IFS=$'\t' read -r id want; do
  case $id in
    ''|'#'*|id) continue ;;
  esac
  n=$((n + 1))
  anchor=$(awk -F'|' -v id="$id" '
    { t = $2; gsub(/^[ \t]+|[ \t]+$/, "", t) }
    t == id { a = $7; gsub(/^[ \t]+|[ \t]+$/, "", a); print a; exit }' "$reg")
  if [ -z "$anchor" ]; then
    echo "DRIFT $id row-missing"
    bad=$((bad + 1))
    continue
  fi
  got=$(printf '%s' "$anchor" | sha256sum | cut -d' ' -f1)
  if [ "$got" != "$want" ]; then
    echo "DRIFT $id"
    bad=$((bad + 1))
  fi
done < "$pins"
if [ "$n" -eq 0 ]; then
  echo "ANCHOR_PINS: SETUP no-pins"
  exit 2
fi
if [ "$bad" -gt 0 ]; then
  echo "ANCHOR_PINS: DRIFT (pins=$n drift=$bad)"
  exit 1
fi
echo "ANCHOR_PINS: CLEAN (pins=$n)"
exit 0
