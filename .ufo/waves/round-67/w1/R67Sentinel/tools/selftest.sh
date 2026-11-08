#!/usr/bin/env bash
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
cd "$LANE" || exit 9
timeout 900 bash corpus/sources-census.sh --selftest > "$SCRATCH/out/gate-selftest.txt" 2>&1
echo "selftest_exit=$?" > "$SCRATCH/out/gate-selftest-rc.txt"
exit 0
