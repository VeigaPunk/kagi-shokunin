#!/usr/bin/env bash
# Real-lane confinement test: run each counter against the LANE ITSELF with a
# scratch outside the lane, snapshotting the lane and /tmp before and after.
# A counter that writes into the measured tree or /tmp is a confinement breach.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
FLEET=/home/vgpnk/Projects/shokunin
snap() { find "$1" -type f 2>/dev/null | sort; }

run_one() {
  C="$1"; LABEL="$2"
  echo "######## $LABEL against the REAL LANE ########"
  mkdir -p "$SCRATCH/real-scratch/$LABEL"
  B_LANE=$(snap "$LANE"); B_TMP=$(find /tmp -maxdepth 3 -type f 2>/dev/null | sort)
  ( cd "$SCRATCH" && timeout 2400 bash "$C" --tree "$LANE" --scratch "$SCRATCH/real-scratch/$LABEL" ) > "$SCRATCH/out/real-$LABEL.txt" 2>&1
  echo "rc=$?"
  tail -3 "$SCRATCH/out/real-$LABEL.txt"
  A_LANE=$(snap "$LANE"); A_TMP=$(find /tmp -maxdepth 3 -type f 2>/dev/null | sort)
  echo "LANE_NEW_COUNT=$(comm -13 <(echo "$B_LANE") <(echo "$A_LANE") | grep -c .)"
  comm -13 <(echo "$B_LANE") <(echo "$A_LANE") | grep . | sed 's/^/  LANE_NEW /' | head -8
  echo "TMP_NEW_COUNT=$(comm -13 <(echo "$B_TMP") <(echo "$A_TMP") | grep -c .)"
  comm -13 <(echo "$B_TMP") <(echo "$A_TMP") | grep . | sed 's/^/  TMP_NEW /' | head -8
  echo "SCRATCH_LEFT=$(find "$SCRATCH/real-scratch/$LABEL" -type f 2>/dev/null | wc -l) files"
  echo "LANE_PLAN_SHA=$(sha256sum "$LANE/plans/round-67-c1.sh" "$LANE/plans/round-67-c2.sh" 2>/dev/null | cut -c1-16 | tr '\n' ' ')"
}
run_one "$LANE/plans/round-67-c1.sh" c1
run_one "$LANE/plans/round-67-c2.sh" c2
exit 0
