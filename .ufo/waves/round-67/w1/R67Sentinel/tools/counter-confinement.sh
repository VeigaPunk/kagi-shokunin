#!/usr/bin/env bash
# Counter confinement harness (round-67 sentinel).
#
# For each new counter (plans/round-67-c1.sh, plans/round-67-c2.sh):
#   T1 scratch confinement : with --scratch <dir>, every file the counter
#                             creates must land under <dir>; nothing may be
#                             created under the lane, the fleet root, /tmp.
#   T2 escaping --tree     : --tree <path outside the lane> must be REFUSED
#                             (non-zero exit, and a diagnostic naming the
#                             refusal); it must not read or write outside.
#   T3 traversal --tree     : --tree <lane>/../<sibling> must be refused.
#
# Usage: counter-confinement.sh <counter-path> <label>
set -u
COUNTER="$1"; LABEL="$2"
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r67/R67Sentinel/confine/$LABEL"
rm -rf "$ROOT"; mkdir -p "$ROOT/scratch" "$ROOT/snap"

snap() { find "$@" -type f -newermt '-1 second' 2>/dev/null; }

echo "### COUNTER $LABEL ($COUNTER)"
if [ ! -f "$COUNTER" ]; then echo "ABSENT: counter not present"; exit 9; fi
sha256sum "$COUNTER"

# ---- T1 scratch confinement -------------------------------------------------
echo "--- T1 scratch confinement ---"
BEFORE_LANE=$(find "$LANE" -type f 2>/dev/null | sort)
BEFORE_TMP=$(find /tmp -maxdepth 2 -newermt '-1 second' 2>/dev/null | wc -l)
run_out=$(cd "$ROOT" && bash "$COUNTER" --tree "$LANE" --scratch "$ROOT/scratch" 2>&1)
run_rc=$?
echo "rc=$run_rc"
echo "$run_out" | sed -n '1,20p'
AFTER_LANE=$(find "$LANE" -type f 2>/dev/null | sort)
LANE_NEW=$(comm -13 <(echo "$BEFORE_LANE") <(echo "$AFTER_LANE"))
echo "LANE_FILES_CREATED_COUNT=$(printf '%s' "$LANE_NEW" | grep -c . )"
printf '%s\n' "$LANE_NEW" | sed 's/^/LANE_NEW /' | head -20
echo "SCRATCH_TREE:"
find "$ROOT/scratch" -type f 2>/dev/null | sed 's/^/  SCRATCH /' | head -20
SCRATCH_N=$(find "$ROOT/scratch" -type f 2>/dev/null | wc -l)
echo "SCRATCH_FILE_COUNT=$SCRATCH_N"

# ---- T2 escaping --tree -----------------------------------------------------
echo "--- T2 escaping --tree (absolute outside lane) ---"
ESC="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r67/R67Sentinel/outside-tree"
rm -rf "$ESC"; mkdir -p "$ESC/corpus" "$ESC/plans"
cp "$COUNTER" "$ESC/plans/"
( cd "$ESC" && bash "$ESC/plans/$(basename "$COUNTER")" --tree "$ESC" --scratch "$ROOT/scratch2" 2>&1 ) | sed -n '1,12p'
echo "rc=$?"
echo "OUTSIDE_TREE_FILES_CREATED:"
find "$ESC" -type f -newermt '-30 seconds' 2>/dev/null | grep -v '/plans/' | sed 's/^/  /' | head

# ---- T3 traversal --tree -----------------------------------------------------
echo "--- T3 traversal --tree (lane/../<sibling>) ---"
SIB=$(dirname "$LANE")
echo "sibling root: $SIB"
( cd "$ROOT" && bash "$COUNTER" --tree "$LANE/../kake-shokunin" --scratch "$ROOT/scratch3" 2>&1 ) | sed -n '1,12p'
echo "rc=$?"
