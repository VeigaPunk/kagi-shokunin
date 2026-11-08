#!/usr/bin/env bash
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
cd "$LANE" || exit 9
bash corpus/sources-census.sh > "$SCRATCH/out/gate-lane.txt" 2>&1
echo "gate_exit=$?" > "$SCRATCH/out/gate-rc.txt"
exit 0
