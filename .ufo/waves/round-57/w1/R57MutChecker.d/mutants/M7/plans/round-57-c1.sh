#!/usr/bin/env bash
# plans/round-57-c1.sh -- round 57 C1 counter (calibration: the audited surface's
# numeric self-descriptions agree with their machine authorities).
#
# Frozen predicate (the same sentence appears in plans/round-57.md section C1):
#   C1_CURRENT: value = MISMATCH+UNBOUND over POP when GUARD = 1, else FAIL;
#   target 0 (BASE 3), population floor 8.
#   POP: every statement of the four declared classes (cases / receipt MATCH /
#     freeze-epoch count / clocks, plus the `N/N MATCH` POP fraction) inside the
#     audited surface -- SCORECARD.md `## Round 56 — post-move`, LOG.md
#     `## Round 56 (`, and corpus/lessons/round-56.md header + `## Claims`.
#   AUTHORITY: `recheck-replay.py --selftest` case count; the named epoch
#     receipt's `CONTROLS: match=N mismatch=0`; the distinct `epoch-[A-F]` tokens
#     of plans/round-56.md; the data rows of corpus/recheck-captures.tsv.
#   GUARD = 1 iff the frozen checker prints `population=P guard=1` with P >= 8
#     and, when the measured tree carries corpus/current-claims.py, that gate's
#     own `--root` run prints the same value and population.
# Fail closed: a bad revision, unreadable BASE, unusable scratch or missing
#   git/python3 is SETUP (exit 2); a missing surface file reads FAIL; a producer
#   with empty output reads as not-CLEAN.
# Named ceilings: an authority file forged to agree with its statement passes
#   (hand-written receipt / doctored plan); the class set is closed.
# Input: a revision, or --tree DIR. Output: one line
#   C1_CURRENT: value=V population=P gate=G guard=G (checker=<raw>)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1cda9e7ae4767b4133e283bfbc08266d4c86362d
CHECK="$REPO/plans/round-57-c1-check.py"
setup() { echo "C1_CURRENT: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
REV=""; TREE=""
case "${1:-}" in
  --tree) TREE=${2:?tree};;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=$(mktemp -d "${TMPDIR:-/tmp}/kagi-r57-c1.XXXXXX") || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { echo "C1_CURRENT: value=FAIL population=0 gate=0 guard=0 (checker=bad-tree)"; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { echo "C1_CURRENT: value=FAIL population=0 gate=0 guard=0 (checker=bad-revision)"; exit 1; }
fi
RAW=$(python3 -I -B "$CHECK" --root "$ROOT" 2>/dev/null | tail -1)
[ -n "$RAW" ] || { echo "C1_CURRENT: value=FAIL population=0 gate=0 guard=0 (checker=empty)"; exit 1; }
getv() { printf '%s\n' "$RAW" | sed -n "s/.* $1=\([^ ]*\).*/\1/p" | head -1; }
V=$(getv value); P=$(getv population); G=$(getv guard)
GATE=0
if [ -f "$ROOT/corpus/current-claims.py" ]; then
  GRAW=$(python3 -I -B "$ROOT/corpus/current-claims.py" --root "$ROOT" 2>/dev/null | tail -1)
  GV=$(printf '%s\n' "$GRAW" | sed -n 's/.* value=\([^ ]*\).*/\1/p' | head -1)
  GP=$(printf '%s\n' "$GRAW" | sed -n 's/.* population=\([^ ]*\).*/\1/p' | head -1)
  [ "$GV" = "$V" ] && [ "$GP" = "$P" ] && GATE=1
fi
GUARD=0; FLOOR=0
case "$P" in ''|*[!0-9]*) P=0;; esac
[ "$P" -ge 8 ] && [ "$G" = 1 ] && FLOOR=1
[ "$FLOOR" = 1 ] && { [ "$GATE" = 1 ] || [ ! -f "$ROOT/corpus/current-claims.py" ]; } && GUARD=1
[ "$GUARD" = 1 ] && V=$V || V=FAIL
printf 'C1_CURRENT: value=%s population=%s gate=%s guard=%s (checker=%s)\n' \
  "$V" "$P" "$GATE" "$GUARD" "$RAW"
