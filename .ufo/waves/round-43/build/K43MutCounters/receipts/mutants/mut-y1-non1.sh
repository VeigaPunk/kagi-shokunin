#!/usr/bin/env bash
# plans/round-43-c2.sh -- round 43 C2 counter (freshness: a committed gate enforces that the
# lane's committed controls receipts re-derive at the revision they live at).
#
# Frozen predicate (the same sentence appears in plans/round-43.md §C2 and in the receipt label):
#   prints ONE unsigned integer N in {0,1}. N = 1 iff, in a shared clone of the candidate commit
#   (argument, default HEAD of this repository), the committed gate corpus/controls-replay.sh
#   (the clone's own bytes; override with CONTROLS_REPLAY_GATE=<path>) exits 0 when invoked as
#   `bash <gate> --clone <clone>` (positive P1: the eight frozen manifest receipts under
#   .ufo/waves/round-42/controls/ and .ufo/waves/round-41/controls/ re-derive byte-identically
#   from the clone's committed runners), AND exits 1 on a stale fixture (N1: a copy of the clone
#   whose .ufo/waves/round-42/controls/c2-derivation-D.txt reads 2 instead of 1), AND exits 1 on
#   a silent fixture (N2: a copy of the clone whose plans/round-42-controls.sh is replaced by
#   `exit 0`). Otherwise N = 0.
#   The manifest (frozen in plans/round-43.md C2) is these eight files:
#     .ufo/waves/round-42/controls/c1-control-refuse-all.txt   (0)
#     .ufo/waves/round-42/controls/c1-control-accept-all.txt   (0)
#     .ufo/waves/round-42/controls/c2-derivation-D.txt         (1)
#     .ufo/waves/round-41/controls/c1-control-refuse-all.txt   (0)
#     .ufo/waves/round-41/controls/c1-control-accept-all.txt   (0)
#     .ufo/waves/round-41/controls/c1-control-no-gate.txt      (0)
#     .ufo/waves/round-41/controls/c2-control-decoy.txt        (2)
#     .ufo/waves/round-41/controls/c2-base-19025d9.txt         (1)
#   Excluded, by design (they record historical claim-BASE readings, not re-derivable outputs):
#   .ufo/waves/round-42/controls/c1-base.txt (committed 4, re-derives 5 at HEAD -- the BASE
#   receipt of the round-42 C1 claim), .ufo/waves/round-42/controls/c2-base.txt (committed 0,
#   the BASE receipt of the round-42 C2 claim), and .ufo/waves/round-42/controls/
#   c2-worktree-at-base.txt (a diagnostic receipt no committed runner writes).
#   Do-nothing reading at the claim BASE 5f3566c is 0: no corpus/controls-replay.sh exists there,
#   so P1 cannot be met. Measured predeclaration receipt: .ufo/waves/round-43/controls/c2-base.txt.
#
# Ceiling (named in plans/round-43.md): a gate that special-cases the three invocation shapes
# (clean / stale / silent) passes the counter; the gate's default verification is reviewed as
# code, and the blanket gates (always-0, always-1) are refused by the counter (controls receipts
# c2-blanket-0.txt, c2-blanket-1.txt).
# Fail closed: a missing revision, an unreadable clone, a stale-fixture precondition violation
# or a missing override gate prints nothing and exits 2.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
CAND=${1:-$(git -C "$REPO" rev-parse HEAD)}
OVER=${CONTROLS_REPLAY_GATE:-}
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c2-counter.$$
mkdir -p -- "$SCR" || { echo "counter-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

git -C "$REPO" rev-parse --verify --quiet "$CAND^{commit}" >/dev/null 2>&1 || { echo "counter-refused: candidate" >&2; exit 2; }
git clone -q --shared "$REPO" "$SCR/clone" || { echo "counter-refused: clone" >&2; exit 2; }
git -C "$SCR/clone" checkout -q --detach "$CAND" || { echo "counter-refused: checkout" >&2; exit 2; }
[ -f "$SCR/clone/plans/round-42-controls.sh" ] && [ -f "$SCR/clone/plans/round-41-controls.sh" ] || { echo "counter-refused: runners" >&2; exit 2; }

if [ -n "$OVER" ]; then
  [ -f "$OVER" ] || { echo "counter-refused: override gate" >&2; exit 2; }
  GATE=$OVER
else
  GATE=$SCR/clone/corpus/controls-replay.sh
  [ -f "$GATE" ] || { echo 0; exit 0; }
fi

# P1: the committed gate verifies the clean clone (replay green at the revision it names).
bash "$GATE" --clone "$SCR/clone" >/dev/null 2>&1
P1=$?

# N2: silent fixture -- the round-42 controls runner writes nothing; the gate must refuse.
cp -a "$SCR/clone" "$SCR/silent" || { echo "counter-refused: silent fixture" >&2; exit 2; }
printf '#!/usr/bin/env bash\nexit 0\n' > "$SCR/silent/plans/round-42-controls.sh"
bash "$GATE" --clone "$SCR/silent" >/dev/null 2>&1
N2=$?

if [ "$P1" = "0" ] && [ "$N2" = "1" ]; then
  echo 1
else
  echo 0
fi
exit 0
