#!/usr/bin/env bash
# plans/round-40-c2.sh -- round 40 C2 counter (freshness): the python-currency debt items
# routed from round 39 (M39-7 S036 pin; S040/S041 documentation refresh as new rows).
#
# Frozen predicate (the same sentence appears in plans/round-40.md and the receipt label):
#   prints ONE unsigned integer N in 0..3 -- the number of satisfied items:
#   item1  corpus/anchor-pins.tsv carries an S036 row whose sha256 equals the trimmed anchor
#          cell of registry row S036 recomputed at the current tree, AND
#          `bash corpus/anchor-pins.sh --root .` prints `ANCHOR_PINS: CLEAN (pins=4)`.
#   item2  registry row S095 exists (class docs, tier A), corpus/source-fetches.tsv carries
#          an S095 row whose stored sha256 equals sha256 of the committed capture body
#          .ufo/waves/round-40/capture/S095.body, the S095 row's verbatim quote (the text
#          between the first U+201C and the next U+201D in its teaches cell) locates in that
#          body after whitespace normalization, and the row's teaches cell names S040 as
#          superseded.
#   item3  the same for S096, S041 and .ufo/waves/round-40/capture/S096.body.
#   Target N=3 at the round-40 landing; the no-work reading at the claim BASE is 0; a forged
#   registry row without its committed capture body cannot satisfy item2/item3.
#
# Fail closed (exit 2, no integer): the registry, the fetch table, the pins file or the gate
# is missing/unreadable, or a needed capture body is absent while its row is present.
set -u
cd "$(dirname "$0")/.."
reg=corpus/SOURCES.md
fetches=corpus/source-fetches.tsv
pins=corpus/anchor-pins.tsv
[ -f "$reg" ] && [ -f "$fetches" ] && [ -f "$pins" ] || { echo "counter-refused: missing input" >&2; exit 2; }
n=0
# item1
want=$(awk -F'\t' '$1=="S036"{print $2; exit}' "$pins")
if [ -n "$want" ]; then
  got=$(awk -F'|' '{t=$2; gsub(/^[ \t]+|[ \t]+$/,"",t)} t=="S036"{a=$7; gsub(/^[ \t]+|[ \t]+$/,"",a); printf "%s", a; exit}' "$reg" | sha256sum | cut -d' ' -f1)
  gate=$(bash corpus/anchor-pins.sh --root . 2>/dev/null); grc=$?
  if [ "$got" = "$want" ] && [ "$grc" -eq 0 ] && printf '%s' "$gate" | grep -qF 'ANCHOR_PINS: CLEAN (pins=4)'; then
    n=$((n + 1))
  fi
fi
item() { # item <new_id> <old_id> <capture_path>  -> 0/1
  newid=$1; oldid=$2; cap=$3
  rowline=$(grep -E "^\| ${newid} \|" "$reg" | head -1)
  [ -n "$rowline" ] || return 1
  printf '%s\n' "$rowline" | grep -qF '| docs | A |' || return 1
  frow=$(awk -F'\t' -v i="$newid" '$1==i{print; exit}' "$fetches")
  [ -n "$frow" ] || return 1
  fsha=$(printf '%s\n' "$frow" | awk -F'\t' '{print $10}')
  [ -n "$fsha" ] || return 1
  [ -f "$cap" ] || return 1
  csha=$(sha256sum "$cap" | cut -d' ' -f1)
  printf '%s\n' "$rowline" | grep -qF "supersedes ${oldid}" || return 1
  python3 - "$rowline" "$cap" <<'PYEOF' || return 1
import re, sys
row, path = sys.argv[1], sys.argv[2]
m = re.search("\u201c(.+?)\u201d", row)
if not m:
    sys.exit(1)
needle = re.sub(r"\s+", " ", m.group(1)).strip()
body = re.sub(r"\s+", " ", open(path, encoding="utf-8", errors="replace").read())
sys.exit(0 if needle and needle in body else 1)
PYEOF
}
if item S095 S040 .ufo/waves/round-40/capture/S095.body; then n=$((n + 1)); fi
if item S096 S041 .ufo/waves/round-40/capture/S096.body; then n=$((n + 1)); fi
echo "$n"
exit 0
