#!/usr/bin/env bash
# plans/round-39-controls.sh MODE -- pre-freeze control runner (round 39).
#
# Each MODE works in a scratch copy of the tree named by BASE (never in the extraction itself),
# runs the frozen counter there, and prints its integer. Used only by the pre-freeze gate
# (corpus/prefreeze-control.sh) and by the wave's attack seats.
#   c1_nowork   the tree with NO anchor-pin instrument (the claim BASE)        expect 0
#   c2_nowork   the tree with NO declared-axis instrument (the claim BASE)     expect 0
set -eu
mode=${1:?mode}
base=${BASE:?BASE extraction}
scratch=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r39
mkdir -p "$scratch"
t=$(mktemp -d "$scratch/ctl-$mode.XXXXXX")
trap 'rm -rf -- "$t"' EXIT
cp -r "$base/." "$t/"
cd "$t"
case $mode in
  c1_nowork)
    rm -f corpus/anchor-pins.sh corpus/anchor-pins.tsv
    bash plans/round-39-c1.sh ;;
  c2_nowork)
    rm -f corpus/claims-declared.sh corpus/claims-declared.tsv
    bash plans/round-39-c2.sh ;;
  *)
    echo "unknown mode $mode" >&2
    exit 2 ;;
esac
