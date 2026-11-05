#!/usr/bin/env bash
# plans/round-45-c2.sh -- frozen counter for round-45 C2 (coverage): one assimilated ISO/IEC 11770-3
# knowledge entry, every quote of its newly added registry rows located in committed capture bodies.
#
# Amendment A1 (pre-candidate, see plans/round-45.md): value also requires quote-locate.py rc 0; negative located is not floored.
# Frozen predicate (the same sentence appears in plans/round-45.md and in this counter's label):
#   C2_LOCATED: value = LOCATED when (a) corpus/SOURCES.md at REV passes the sources census
#   (exit 0), quote-locate.py exits 0 (Amendment A1: a locator SETUP/crash can never pass), (b) at least one knowledge file added after BASE cites at least one registry id
#   added after BASE in its `source:` line, and (c) LOCATED >= 3; else 0.
#   ADDED   = registry ids present at REV and absent at BASE (the rows this round appends).
#   LOCATED = rows of corpus/quote-bodies.tsv whose id is in ADDED and that quote-locate.py does not
#             report as NOT-LOCATED (quote-locate.py reads committed capture bodies only).
#
# BASE is the lane tip the round was declared on (0d0192f). At BASE ADDED is empty, so the value is 0.
#
# usage: bash plans/round-45-c2.sh [REV|LANE]   (default LANE)
# exit 0 with the line `C2_LOCATED: value=<n> added=<a> entries=<e> census=<rc> located=<l>`.
# Scratch root: $HYAKU_SCRATCH/kagi-r45/C2-<pid>, deleted on exit.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=0d0192f63eb5e49826d75af1e5293004dc691a18
FLEET=/home/vgpnk/Projects/shokunin
REV="${1:-LANE}"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}"
mkdir -p "$SCR/kagi-r45" || { echo "C2_LOCATED: SETUP scratch"; exit 2; }
S=$(mktemp -d "$SCR/kagi-r45/C2-XXXXXX") || { echo "C2_LOCATED: SETUP mktemp"; exit 2; }
trap 'rm -rf -- "$S"' EXIT

if [ "$REV" = LANE ]; then
  TREE="$LANE"
else
  mkdir -p "$S/tree" && git -C "$LANE" archive "$REV" | tar -x -C "$S/tree" || { echo "C2_LOCATED: SETUP archive $REV"; exit 2; }
  TREE="$S/tree"
fi
git -C "$LANE" show "$BASE:corpus/SOURCES.md" > "$S/base-SOURCES.md" 2>/dev/null || { echo "C2_LOCATED: SETUP base"; exit 2; }
ids() { grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' "$1" | grep -oE 'S[0-9]+' | sort -u; }
ids "$S/base-SOURCES.md" > "$S/ids-base"
ids "$TREE/corpus/SOURCES.md" > "$S/ids-rev"
comm -13 "$S/ids-base" "$S/ids-rev" > "$S/ids-added"
added=$(wc -l < "$S/ids-added")

"$FLEET/scripts/sources-census.sh" validate --file "$TREE/corpus/SOURCES.md" >/dev/null 2>&1; census=$?

entries=0
if [ -d "$TREE/corpus/knowledge" ]; then
  for f in "$TREE/corpus/knowledge"/*.md; do
    [ -f "$f" ] || continue
    b=$(basename "$f")
    git -C "$LANE" cat-file -e "$BASE:corpus/knowledge/$b" 2>/dev/null && continue
    src=$(grep -m1 '^source:' "$f" || true)
    [ -n "$src" ] || continue
    for id in $(grep -oE 'S[0-9]{3,}' <<<"$src" | sort -u); do
      if grep -qx "$id" "$S/ids-added"; then entries=$((entries+1)); break; fi
    done
  done
fi

locate_out=$(cd "$TREE" && python3 corpus/quote-locate.py 2>&1); locate_rc=$?
m_add=0; f_add=0
if [ -f "$TREE/corpus/quote-bodies.tsv" ]; then
  while IFS=$'\t' read -r rid _rest; do
    case $rid in ''|id) continue ;; esac
    grep -qx "$rid" "$S/ids-added" && m_add=$((m_add+1))
  done < "$TREE/corpus/quote-bodies.tsv"
fi
while read -r kw rid _rest; do
  [ "$kw" = NOT-LOCATED ] || continue
  grep -qx "$rid" "$S/ids-added" && f_add=$((f_add+1))
done <<<"$locate_out"
located=$((m_add - f_add))

value=0
if [ "$census" -eq 0 ] && [ "$locate_rc" -eq 0 ] && [ "$entries" -ge 1 ] && [ "$located" -ge 3 ]; then value=$located; fi
echo "C2_LOCATED: value=$value added=$added entries=$entries census=$census located=$located (quote-locate rc=$locate_rc, rows-added=$m_add, not-located-added=$f_add, tree=$REV)"
exit 0
