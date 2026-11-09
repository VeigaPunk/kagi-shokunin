#!/usr/bin/env bash
# plans/round-72-c2.sh — round 72 C2 (calibration) frozen counter. L1 KagiR72.
#
# Frozen predicate (the same sentence as plans/round-72.md §C2):
#   C2_SELF_COUNTS: value = the `stale=` count the lane's own self-count gate
#   (`python3 corpus/self-counts.py --root T`) prints for tree T, when PINS = 1
#   (T's corpus/self-counts.py and corpus/self-counts.tsv are byte-identical to
#   BASE b2f3dd66, so no binding is dropped and the gate is not changed) and
#   SHAPE = 1 (exactly one summary line `SELF_COUNTS: POLICY (claims=63 stale=S
#   unlocated=0 ambiguous=0 policy=2 setup=0)`, gate exit 2, exactly two `POLICY`
#   lines naming PV-FEEDTOKEN-SHAPES and PV-FEEDTOKEN-SELFTEST — the retained
#   R29-01/R29-02 boundary — and OK + STALE lines = 61); otherwise SETUP (exit 2,
#   value unset). Target 0 (BASE 4: SC-SKILL-STAMPS, SC-SKILL-CLAIMS, PV-STAMPS,
#   PV-CLAIMS). Kill rule: value > 0 on the landed revision -> C2 missed.
#
# usage: plans/round-72-c2.sh <lane revision>   (git archive of the lane repo)
#        plans/round-72-c2.sh --tree DIR        (an extracted tree; controls)
# exit: 0 value=0; 1 value>0; 2 SETUP (pins/shape/producer failed; fail closed).
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r72/c2.*, removed on exit.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE_REV=b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9
PIN_PY=$(git -C "$LANE" show "$BASE_REV:corpus/self-counts.py" | sha256sum | cut -d' ' -f1)
PIN_TSV=$(git -C "$LANE" show "$BASE_REV:corpus/self-counts.tsv" | sha256sum | cut -d' ' -f1)
SR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r72
mkdir -p "$SR" || { echo "C2_SELF_COUNTS: SETUP (scratch)"; exit 2; }
W=$(mktemp -d "$SR/c2.XXXXXX") || { echo "C2_SELF_COUNTS: SETUP (mktemp)"; exit 2; }
trap 'rm -rf -- "$W"' EXIT
setup() { echo "C2_SELF_COUNTS: SETUP ($1)"; exit 2; }
[ -n "$PIN_PY" ] && [ -n "$PIN_TSV" ] || setup "base pins unreadable"
case "${1:-}" in
  --tree) T=$(readlink -f "${2:?tree}") ; [ -d "$T" ] || setup "no tree" ;;
  "") setup "usage: <rev> | --tree DIR" ;;
  *) T="$W/t"; mkdir -p "$T"; git -C "$LANE" archive "$1" | tar -x -C "$T" || setup "archive $1" ;;
esac
[ -f "$T/corpus/self-counts.py" ] && [ -f "$T/corpus/self-counts.tsv" ] || setup "gate absent"
py=$(sha256sum < "$T/corpus/self-counts.py" | cut -d' ' -f1)
tsv=$(sha256sum < "$T/corpus/self-counts.tsv" | cut -d' ' -f1)
[ "$py" = "$PIN_PY" ] || setup "pins=0 self-counts.py differs from BASE"
[ "$tsv" = "$PIN_TSV" ] || setup "pins=0 self-counts.tsv differs from BASE"
(cd "$T" && python3 corpus/self-counts.py --root "$T") > "$W/out" 2> "$W/err"
rc=$?
[ -s "$W/out" ] || setup "producer printed nothing (rc=$rc)"
[ "$rc" = 2 ] || setup "gate exit $rc, expected 2 (POLICY)"
n=$(grep -c '^SELF_COUNTS: ' "$W/out")
[ "$n" = 1 ] || setup "summary lines=$n"
sum=$(grep '^SELF_COUNTS: ' "$W/out")
re='^SELF_COUNTS: POLICY \(claims=[0-9]+ stale=([0-9]+) unlocated=0 ambiguous=0 policy=2 setup=0\)$'
[[ $sum =~ $re ]] || setup "shape=0 summary '$sum'"
stale=${BASH_REMATCH[1]}
pol=$(grep '^POLICY ' "$W/out" | awk '{print $2}' | sort | tr '\n' ',')
[ "$pol" = "PV-FEEDTOKEN-SELFTEST,PV-FEEDTOKEN-SHAPES," ] || setup "policy ids '$pol'"
ok=$(grep -c '^OK ' "$W/out"); st=$(grep -c '^STALE ' "$W/out")
[ $((ok + st)) = 61 ] || setup "ok+stale=$((ok + st)) expected 61"
[ "$st" = "$stale" ] || setup "STALE lines $st != summary $stale"
ids=$(grep '^STALE ' "$W/out" | awk '{print $2}' | tr '\n' ' ')
echo "C2_SELF_COUNTS: value=$stale pins=1 shape=1 claims=63 policy=2 ok=$ok stale_ids=${ids:-none}"
[ "$stale" = 0 ] && exit 0 || exit 1
