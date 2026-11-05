#!/usr/bin/env bash
# plans/round-42-c2.sh -- round 42 C2 counter (freshness: the controls runner's C2 BASE receipt is
# derived from the pinned revision, not from the worktree).
#
# Frozen predicate (the same sentence appears in plans/round-42.md §C2 and in the receipt label):
#   prints ONE unsigned integer N in {0,1}. N = 1 iff, in a clean clone of the candidate commit
#   (argument, default HEAD of this repository), running that clone's plans/round-41-controls.sh
#   writes .ufo/waves/round-41/controls/c2-base-19025d9.txt whose last line equals D, where D is the
#   frozen C2 counter (plans/round-41-c2.sh, copied from the candidate) run in a git archive of the
#   claim BASE 19025d9 (its own normalizer, registry and fetch rows), AND D equals 1. Otherwise N = 0.
#   The claim-BASE reading (committed runner e8265c0, which measures the worktree) is 0: it writes 3.
#
# Ceiling (named in plans/round-42.md): a runner that writes the constant 1 passes; the counter
# checks the receipt value against D, not the runner's source.
# Fail closed: a missing revision, an unreadable clone or a missing runner prints nothing and exits 2.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=19025d97e5013bac2f45d6b9e61bfbafc84c3c8d
CAND=${1:-$(git -C "$REPO" rev-parse HEAD)}
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r42/c2-counter.$$
mkdir -p -- "$SCR" || { echo "counter-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

git -C "$REPO" rev-parse --verify --quiet "$CAND^{commit}" >/dev/null 2>&1 || { echo "counter-refused: candidate" >&2; exit 2; }
git -C "$REPO" rev-parse --verify --quiet "$BASE^{commit}" >/dev/null 2>&1 || { echo "counter-refused: BASE" >&2; exit 2; }
git clone -q --shared "$REPO" "$SCR/clone" || { echo "counter-refused: clone" >&2; exit 2; }
git -C "$SCR/clone" checkout -q --detach "$CAND" || { echo "counter-refused: checkout" >&2; exit 2; }
[ -f "$SCR/clone/plans/round-41-c2.sh" ] && [ -f "$SCR/clone/plans/round-41-controls.sh" ] || { echo "counter-refused: runner" >&2; exit 2; }

# D: the frozen C2 counter over the pinned BASE tree (its own inputs, never the worktree).
mkdir -p -- "$SCR/base/plans" || { echo "counter-refused: base dir" >&2; exit 2; }
git -C "$REPO" archive "$BASE" | tar -x -f - -C "$SCR/base" || { echo "counter-refused: archive" >&2; exit 2; }
cp -- "$SCR/clone/plans/round-41-c2.sh" "$SCR/base/plans/round-41-c2.sh" || { echo "counter-refused: copy" >&2; exit 2; }
D=$(cd "$SCR/base" && bash plans/round-41-c2.sh 2>/dev/null | tail -1)
case $D in ''|*[!0-9]*) echo "counter-refused: derivation" >&2; exit 2 ;; esac

# R: the candidate's committed runner, executed in the clone (writes receipts there only).
(cd "$SCR/clone" && bash plans/round-41-controls.sh >/dev/null 2>&1)
RCPT=$SCR/clone/.ufo/waves/round-41/controls/c2-base-19025d9.txt
R=$( [ -r "$RCPT" ] && tail -1 "$RCPT" || true )

if [ "$D" = 1 ] && [ "$R" = "$D" ]; then
  echo 1
else
  echo 0
fi
exit 0
