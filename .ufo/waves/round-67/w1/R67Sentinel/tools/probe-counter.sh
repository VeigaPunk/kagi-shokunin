#!/usr/bin/env bash
# Counter confinement probe (round-67 sentinel).
#
# For each counter:
#   T1  writes land ONLY under --scratch (nothing in --tree, the lane, the
#       fleet root, /tmp)
#   T2  --tree <a tree outside the lane> : is it refused, or does it proceed?
#   T3  --tree /etc and --tree <lane>/../../etc : refused or silent?
#   T4  --scratch inside the measured tree : refused (per the counter's header)
#
# Everything runs in the seat's scratch; the lane is only ever READ.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
FLEET=/home/vgpnk/Projects/shokunin
C="$1"; LABEL="$2"
R="$SCRATCH/confine/$LABEL"
rm -rf "$R"; mkdir -p "$R/scratch"

snap() { find "$1" -type f 2>/dev/null | sort; }

echo "############ $LABEL ############"
sha256sum "$C"

# ---- T1 -------------------------------------------------------------------
echo "--- T1: writes confined to --scratch ---"
TREE="$R/tree"
mkdir -p "$TREE"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$TREE" -xf -
B_LANE=$(snap "$LANE"); B_TREE=$(snap "$TREE"); B_FLEET=$(snap "$FLEET")
B_TMP=$(find /tmp -maxdepth 3 -type f 2>/dev/null | sort)
( cd "$R" && timeout 1800 bash "$C" --tree "$TREE" --scratch "$R/scratch" ) > "$R/t1.out" 2>&1
echo "rc=$?"
sed -n '1,3p' "$R/t1.out"; echo "  ..."; tail -2 "$R/t1.out"
A_LANE=$(snap "$LANE"); A_TREE=$(snap "$TREE"); A_FLEET=$(snap "$FLEET")
A_TMP=$(find /tmp -maxdepth 3 -type f 2>/dev/null | sort)
echo "LANE_NEW_COUNT=$(comm -13 <(echo "$B_LANE") <(echo "$A_LANE") | grep -c .)"
comm -13 <(echo "$B_LANE") <(echo "$A_LANE") | grep . | sed 's/^/  LANE_NEW /' | head -5
echo "TREE_NEW_COUNT=$(comm -13 <(echo "$B_TREE") <(echo "$A_TREE") | grep -c .)"
comm -13 <(echo "$B_TREE") <(echo "$A_TREE") | grep . | sed 's/^/  TREE_NEW /' | head -5
FLEET_OUT=$(comm -13 <(echo "$B_FLEET") <(echo "$A_FLEET") | grep -v "^$LANE/" | grep -c .)
echo "FLEET_OUTSIDE_NEW_COUNT=$FLEET_OUT"
comm -13 <(echo "$B_FLEET") <(echo "$A_FLEET") | grep -v "^$LANE/" | grep . | sed 's/^/  FLEET_NEW /' | head -5
echo "TMP_NEW_COUNT=$(comm -13 <(echo "$B_TMP") <(echo "$A_TMP") | grep -c .)"
comm -13 <(echo "$B_TMP") <(echo "$A_TMP") | grep . | sed 's/^/  TMP_NEW /' | head -5
echo "SCRATCH_FILE_COUNT=$(find "$R/scratch" -type f 2>/dev/null | wc -l)"
find "$R/scratch" -maxdepth 2 2>/dev/null | sed 's/^/  SCRATCH /' | head -8

# ---- T2: tree outside the lane --------------------------------------------
echo "--- T2: --tree <tree outside the lane> ---"
OUT="$R/outside"; mkdir -p "$OUT"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$OUT" -xf -
mkdir -p "$R/scratch2"
( cd "$R" && timeout 1800 bash "$C" --tree "$OUT" --scratch "$R/scratch2" ) > "$R/t2.out" 2>&1
echo "rc=$?"
sed -n '1,2p' "$R/t2.out"; tail -2 "$R/t2.out"

# ---- T3: absurd trees ------------------------------------------------------
echo "--- T3: absurd --tree arguments ---"
for bad in /etc "$LANE/../../etc"; do
  mkdir -p "$R/scratch3"
  ( cd "$R" && timeout 300 bash "$C" --tree "$bad" --scratch "$R/scratch3" ) > "$R/t3.out" 2>&1
  echo "  --tree $bad rc=$?  :: $(head -1 "$R/t3.out")"
done

# ---- T4: scratch inside the measured tree -----------------------------------
echo "--- T4: --scratch inside the measured tree ---"
mkdir -p "$TREE/inner-scratch"
( cd "$R" && timeout 300 bash "$C" --tree "$TREE" --scratch "$TREE/inner-scratch" ) > "$R/t4.out" 2>&1
echo "rc=$?  :: $(head -1 "$R/t4.out")"
rm -rf "$TREE/inner-scratch"
exit 0
