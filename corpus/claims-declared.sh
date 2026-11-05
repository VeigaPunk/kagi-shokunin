#!/usr/bin/env bash
# corpus/claims-declared.sh -- round 39 C2 instrument: declared-axis conformance gate
# (closes round-38 routed item R38-D1: a claim's axis is frozen with its predicate, and a
# relabel after data is an amendment).
#
# Frozen predicate (the same sentence appears in plans/round-39.md and the counter):
#   CLAIMS_DECLARED: CLEAN (claims=N) -- for every row `round<TAB>claim<TAB>axis` of
#   corpus/claims-declared.tsv: (a) plans/round-<round>.md carries the heading
#   `## <claim> — <axis>:`; (b) SCORECARD.md's `## Round <round> — post-move` section holds
#   exactly one table row tagged `[<claim>]`, and that row's first cell equals <axis>.
#   Any other reading prints `MISMATCH <round> <claim> <reason>` and the run exits 1.
#
# usage:
#   claims-declared.sh [--root DIR]   default DIR is the current directory; exit 0 CLEAN,
#                                     1 MISMATCH, 2 SETUP (missing manifest, zero rows, or an
#                                     axis outside the six AXES.md names)
#
# Ceiling: the gate reads the lane's own text. It proves the declared axis and the tagged
# SCORECARD row agree; it does not judge whether the axis is the right one for the move.
set -u
root=.
if [ "${1:-}" = --root ]; then root=${2:?root}; fi
manifest="$root/corpus/claims-declared.tsv"
if [ ! -f "$manifest" ] || [ ! -f "$root/SCORECARD.md" ]; then
  echo "CLAIMS_DECLARED: SETUP missing-input"
  exit 2
fi
n=0
bad=0
while IFS=$'\t' read -r round claim axis; do
  case $round in
    ''|'#'*|round) continue ;;
  esac
  case $axis in
    depth|coverage|operability|freshness|calibration|adjacency) ;;
    *) echo "CLAIMS_DECLARED: SETUP axis-not-in-AXES '$axis' ($round $claim)"; exit 2 ;;
  esac
  n=$((n + 1))
  plan="$root/plans/round-$round.md"
  if ! grep -qF -- "## $claim — $axis:" "$plan" 2>/dev/null; then
    echo "MISMATCH $round $claim plan-heading-not-$axis"
    bad=$((bad + 1))
    continue
  fi
  tagged=$(awk -v round="$round" -v tag="[$claim]" '
    /^## Round / { insec = index($0, "## Round " round " — post-move") == 1; next }
    insec && /^\|/ && index($0, tag) > 0 {
      first = $0; sub(/^\| */, "", first); sub(/ *\|.*$/, "", first); print first
    }' "$root/SCORECARD.md")
  rows=$(printf '%s\n' "$tagged" | grep -c . || true)
  if [ "$rows" -ne 1 ]; then
    echo "MISMATCH $round $claim tagged-rows-$rows"
    bad=$((bad + 1))
    continue
  fi
  if [ "$tagged" != "$axis" ]; then
    echo "MISMATCH $round $claim scorecard-axis-$tagged-not-$axis"
    bad=$((bad + 1))
  fi
done < "$manifest"
if [ "$n" -eq 0 ]; then
  echo "CLAIMS_DECLARED: SETUP no-rows"
  exit 2
fi
if [ "$bad" -gt 0 ]; then
  echo "CLAIMS_DECLARED: MISMATCH (claims=$n mismatch=$bad)"
  exit 1
fi
echo "CLAIMS_DECLARED: CLEAN (claims=$n)"
exit 0
