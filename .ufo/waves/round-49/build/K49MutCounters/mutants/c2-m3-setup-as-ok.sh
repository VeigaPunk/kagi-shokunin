#!/usr/bin/env bash
# plans/round-49-c2.sh — FROZEN round-49 C2 counter (axis calibration): the lane's stated
# self-counts agree with the observed repo state.
#
# Predicate (same sentence as plans/round-49.md §C2):
#   C2_SELF_COUNTS: value = number of the six frozen BASE keys {SC-SKILL-STAMPS, PV-STAMPS,
#   RD-STAMPS, RD-DOCS-ROWLINKED, RD-DOCS-BYHAND, RD-DOCS-ENTRIES} whose line in the measured
#   revision's `python3 corpus/self-counts.py` output does not start `OK ` (a missing line counts),
#   when GUARD = 1, else SETUP; target 0 (BASE 6).
# - Executed in a clean `git clone --shared` checkout of the measured revision (cwd = checkout),
#   timeout 600 s. No final `SELF_COUNTS: ` line, a timeout or a clone failure is SETUP (exit 2).
# - GUARD (each failure is SETUP, never a zero):
#   G1 `corpus/self-counts.py` and `corpus/claim-ledger.sh` are byte-identical to BASE;
#   G2 the six keys' rows of `corpus/self-counts.tsv` are byte-identical to BASE;
#   G3 every `corpus/knowledge/*.md` path present at BASE is present at the measured revision;
#   G4 every path column of BASE `corpus/stamps.tsv` is still a path column at the measured revision;
#   G5 the output's POLICY lines are exactly PV-FEEDTOKEN-SHAPES and PV-FEEDTOKEN-SELFTEST
#      (the operator-routed R29-01/R29-02 boundary is kept, not allowlisted away);
#   G6 the output holds at least the BASE number of verdict lines (63, = BASE `claims=63`).
#
# Usage: bash plans/round-49-c2.sh <rev>        (measures <rev> in this repo)
#        bash plans/round-49-c2.sh --tree DIR   (controls only: DIR is a git work tree; its HEAD is measured)
# BASE is frozen below. Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r49/c2-counter.XXXXXX.
set -u
BASE=89afe91878f10805921d3caa67d28d21b33226da
KEYS="SC-SKILL-STAMPS PV-STAMPS RD-STAMPS RD-DOCS-ROWLINKED RD-DOCS-BYHAND RD-DOCS-ENTRIES"
MIN_LINES=63

setup() { echo "C2_SELF_COUNTS: SETUP reason=$1"; exit 2; }
[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r49"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c2-counter.XXXXXX") || setup mktemp
trap 'rm -rf -- "$W"' EXIT

if [ "$1" = "--tree" ]; then
  [ -d "${2:-}/.git" ] || setup tree-not-git
  SRC=$(cd "$2" && pwd); REV=HEAD
else
  SRC="$LANE"; REV="$1"
fi
git -C "$SRC" rev-parse --verify -q "$REV^{commit}" >/dev/null || setup bad-rev
git -C "$LANE" rev-parse --verify -q "$BASE^{commit}" >/dev/null || setup base-missing
git clone -q --shared --no-checkout "$SRC" "$W/c" 2>/dev/null || setup clone
[ "$(git -C "$W/c" rev-parse --show-toplevel)" = "$W/c" ] || setup clone-toplevel
git -C "$W/c" checkout -q --detach "$(git -C "$SRC" rev-parse "$REV^{commit}")" 2>/dev/null || setup checkout
C="$W/c"
b() { git -C "$LANE" show "$BASE:$1"; }

# G1
for f in corpus/self-counts.py corpus/claim-ledger.sh; do
  [ -f "$C/$f" ] || setup "G1-missing-$f"
  [ "$(b "$f" | sha256sum)" = "$(sha256sum < "$C/$f")" ] || setup "G1-changed-$f"
done
# G2
for k in $KEYS; do
  [ "$(b corpus/self-counts.tsv | grep -P "^$k\t")" = "$(grep -P "^$k\t" "$C/corpus/self-counts.tsv")" ] || setup "G2-row-$k"
done
# G3
for p in $(git -C "$LANE" ls-tree --name-only "$BASE" corpus/knowledge/ | grep '\.md$'); do
  [ -f "$C/$p" ] || setup "G3-entry-gone-$p"
done
# G4
b corpus/stamps.tsv | grep -v '^#' | cut -f1 | sort -u > "$W/base-stamps"
grep -v '^#' "$C/corpus/stamps.tsv" | cut -f1 | sort -u > "$W/now-stamps"
missing=$(comm -23 "$W/base-stamps" "$W/now-stamps" | wc -l)
[ "$missing" -eq 0 ] || setup "G4-stamp-rows-removed=$missing"

(cd "$C" && timeout 600 python3 corpus/self-counts.py) > "$W/out" 2>&1
rc=$?
grep -q '^SELF_COUNTS: ' "$W/out" || setup "no-final-line(rc=$rc)"
# G5
pol=$(grep -E '^POLICY ' "$W/out" | awk '{print $2}' | sort | paste -sd, -)
[ "$pol" = "PV-FEEDTOKEN-SELFTEST,PV-FEEDTOKEN-SHAPES" ] || setup "G5-policy=$pol"
# G6
n=$(grep -cE '^(OK|STALE|SETUP|POLICY|UNLOCATED|AMBIGUOUS|MISSING) ' "$W/out")
[ "$n" -ge "$MIN_LINES" ] || setup "G6-lines=$n"

value=0; detail=""
for k in $KEYS; do
  l=$(grep -E "^[A-Z]+ $k( |\$)" "$W/out" | head -1)
  v=${l%% *}; [ -n "$l" ] || v=MISSING
  [ "$v" = OK ] || [ "$v" = SETUP ] || value=$((value+1))
  detail="$detail $k=$v"
done
echo "C2_SELF_COUNTS: value=$value keys=6 lines=$n self_counts_rc=$rc$detail"
echo "$(tail -1 "$W/out")"
exit 0
