#!/usr/bin/env bash
# plans/round-44-controls.sh -- round 44 controls runner.
#
# Mode `base` (run in the lane worktree at the claim BASE, predeclaration):
#   writes the BASE receipts under .ufo/waves/round-44/controls/ (runner's own labels,
#   extensionless):
#     c1-base         bash plans/round-44-c1.sh <REV>            (expect 0: no battery at BASE)
#     c1-skipfix      R44_SKIP_FIXTURES=1 bash plans/round-44-c1.sh <REV>   (expect 0)
#     c2-base         bash plans/round-44-c2.sh <REV>            (expect 0: no receipt at BASE)
#     c2-forged-sha   R44_RECEIPT=fixtures/receipt-wrong-sha.txt ... (expect 0)
#     c2-forged-rev   R44_RECEIPT=fixtures/receipt-wrong-rev.txt ... (expect 0)
#     c3-base         bash plans/round-44-c3.sh <REV>            (expect 0: no register at BASE)
#     c3-pos          R44_REGISTER_ROOT=fixtures/register-full ...   (expect 3)
#     c3-wrongvals    R44_REGISTER_ROOT=fixtures/register-wrongvals (expect 1)
#   and measured-at.txt (revision, UTC timestamps, per-receipt last lines).
#
# Mode `final` (run INSIDE a clone of the candidate commit; REV = that candidate):
#     c1-real         bash plans/round-44-c1.sh <REV>            (target 2)
#     c1-skipfix      R44_SKIP_FIXTURES=1 ...                    (expect 0)
#     c1-partial      R44_ONLY_FIXTURE=stale ...                 (expect 1)
#     c2-real         bash plans/round-44-c2.sh <REV>            (target 1)
#     c3-real         bash plans/round-44-c3.sh <REV>            (target 3)
#   written under the clone's .ufo/waves/round-44/controls/ with measured-at-final.txt;
#   the L1 copies them into the lane's .ufo/waves/round-44/final/.
#
# All counting commands are invoked exactly as the frozen predicate names them (no wrappers
# around the counter invocations). Scratch honours HYAKU_SCRATCH (default
# /fast/scratch/hyaku); nothing is written under /tmp.
set -u
unset CONTROLS_REPLAY_GATE

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
OUT=$REPO/.ufo/waves/round-44/controls
FIX=$OUT/fixtures
MODE=${1:-base}
REV=${2:-$(git -C "$REPO" rev-parse HEAD)}
# Amendment A1 (sentinel F1): a revision that is not a full commit id of this repository is
# refused before any receipt is written; the committed receipts are never overwritten by a
# refusal (M44-4).
printf '%s' "$REV" | grep -qE '^[0-9a-f]{40}$' \
  || { echo "runner-refused: revision is not a full commit id" >&2; exit 2; }
git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null \
  || { echo "runner-refused: revision unknown" >&2; exit 2; }
mkdir -p -- "$OUT"
MEA=$OUT/measured-at.txt
[ "$MODE" = "final" ] && MEA=$OUT/measured-at-final.txt

{
  echo "mode: $MODE"
  echo "revision: $REV"
  date -u '+measured-at: %Y-%m-%dT%H:%M:%SZ'
} > "$MEA"

cap() { # $1 receipt name, $2 expected, rest = command with env
  local name=$1 expect=$2
  shift 2
  local out rc last
  out=$("$@" 2>&1)
  rc=$?
  printf '%s\n' "$out" > "$OUT/$name"
  last=$(printf '%s\n' "$out" | tail -1)
  echo "$name rc=$rc last=$last expect=$expect" | tee -a "$MEA"
}

if [ "$MODE" = "base" ]; then
  cap c1-base 0 bash "$REPO/plans/round-44-c1.sh" "$REV"
  R44_SKIP_FIXTURES=1 cap c1-skipfix 0 bash "$REPO/plans/round-44-c1.sh" "$REV"
  cap c2-base 0 bash "$REPO/plans/round-44-c2.sh" "$REV"
  R44_RECEIPT=$FIX/receipt-wrong-sha.txt cap c2-forged-sha 0 bash "$REPO/plans/round-44-c2.sh" "$REV"
  R44_RECEIPT=$FIX/receipt-wrong-rev.txt cap c2-forged-rev 0 bash "$REPO/plans/round-44-c2.sh" "$REV"
  cap c3-base 0 bash "$REPO/plans/round-44-c3.sh" "$REV"
  R44_REGISTER_ROOT=$FIX/register-full cap c3-pos 3 bash "$REPO/plans/round-44-c3.sh" "$REV"
  R44_REGISTER_ROOT=$FIX/register-wrongvals cap c3-wrongvals 1 bash "$REPO/plans/round-44-c3.sh" "$REV"
elif [ "$MODE" = "final" ]; then
  cap c1-real 2 bash "$REPO/plans/round-44-c1.sh" "$REV"
  R44_SKIP_FIXTURES=1 cap c1-skipfix 0 bash "$REPO/plans/round-44-c1.sh" "$REV"
  R44_ONLY_FIXTURE=stale cap c1-partial 1 bash "$REPO/plans/round-44-c1.sh" "$REV"
  cap c2-real 1 bash "$REPO/plans/round-44-c2.sh" "$REV"
  cap c3-real 3 bash "$REPO/plans/round-44-c3.sh" "$REV"
else
  echo "usage: bash plans/round-44-controls.sh base|final [REV]" >&2
  exit 2
fi

echo "runner done: $MODE at $REV" | tee -a "$MEA"
exit 0
