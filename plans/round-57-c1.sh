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
#   GUARD = 1 iff the frozen checker prints `population=P guard=1` with the exact
#     frozen census P=16 cases=3 match=7 epochs=2 clocks=2 pop=2 (amendment A3:
#     a floor alone admitted a delete-the-evidence shape -- reviewer K1-F8), and,
#     when the measured tree carries corpus/current-claims.py, that gate's bytes
#     equal GATE_SHA256_PIN, its `--root` run prints the same value and population,
#     and on a forged copy (SCORECARD "`--selftest` 20 cases" -> 19) it prints
#     exactly value+1 (a printer stub fails).
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
GATE_SHA256_PIN=e36472b3640728ca637d6e6c380cb33b1cd07a27dda2aa53409dec0f5bb4a98a
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
C=$(getv cases); M=$(getv match); E=$(getv epochs); K=$(getv clocks); R=$(getv pop)
GATE=0; CHAL=0
if [ -f "$ROOT/corpus/current-claims.py" ]; then
  GSHA=$(sha256sum "$ROOT/corpus/current-claims.py" | cut -d' ' -f1)
  GRAW=$(python3 -I -B "$ROOT/corpus/current-claims.py" --root "$ROOT" 2>/dev/null | tail -1)
  GV=$(printf '%s\n' "$GRAW" | sed -n 's/.* value=\([^ ]*\).*/\1/p' | head -1)
  GP=$(printf '%s\n' "$GRAW" | sed -n 's/.* population=\([^ ]*\).*/\1/p' | head -1)
  [ "$GSHA" = "$GATE_SHA256_PIN" ] && [ "$GV" = "$V" ] && [ "$GP" = "$P" ] && GATE=1
  FORGED="$SCR/forged"; cp -a "$ROOT" "$FORGED" 2>/dev/null
  if [ -f "$FORGED/SCORECARD.md" ]; then
    sed -i 's/`--selftest` 20 cases/`--selftest` 19 cases/' "$FORGED/SCORECARD.md" 2>/dev/null
    FRAW=$(python3 -I -B "$FORGED/corpus/current-claims.py" --root "$FORGED" 2>/dev/null | tail -1)
    FV=$(printf '%s\n' "$FRAW" | sed -n 's/.* value=\([^ ]*\).*/\1/p' | head -1)
    case "$FV$V" in ''|*[!0-9]*) :;; *) [ "$FV" = "$((V+1))" ] && CHAL=1;; esac
  fi
fi
GUARD=0; FLOOR=0; CENSUS=0
case "$P$C$M$E$K$R" in ''|*[!0-9]*) :;; *) :; esac
[ "$P" = 16 ] && [ "$C" = 3 ] && [ "$M" = 7 ] && [ "$E" = 2 ] && [ "$K" = 2 ] && [ "$R" = 2 ] && CENSUS=1
[ "$CENSUS" = 1 ] && [ "$G" = 1 ] && FLOOR=1
[ "$FLOOR" = 1 ] && GUARD=1
if [ -f "$ROOT/corpus/current-claims.py" ]; then
  [ "$GATE" = 1 ] && [ "$CHAL" = 1 ] || GUARD=0
fi
[ "$GUARD" = 1 ] && V=$V || V=FAIL
printf 'C1_CURRENT: value=%s population=%s gate=%s challenge=%s guard=%s (checker=%s)\n' \
  "$V" "$P" "$GATE" "$CHAL" "$GUARD" "$RAW"
case "$V" in 0) exit 0;; *) exit 1;; esac
