#!/usr/bin/env bash
# Runs frozen counters and the targeted mutant on each proposed killing-control fixture.
set -u
S=/fast/scratch/hyaku/kagi-r49/K49MutCounters; L=$S/lane; P=$S/prop; O=$S/out
mkdir -p "$O"
run() { # tag counter fixture
  HYAKU_SCRATCH=/fast/scratch/hyaku bash "$2" --tree "$3" > "$O/prop-$1.txt" 2>&1
}
run f9-frozen   "$L/plans/round-49-c1.sh"   "$P/k1-f9"  &
run f9-mut2     "$S/mut/c1-m2-dup-as-holds.sh" "$P/k1-f9" &
run f10-frozen  "$L/plans/round-49-c1.sh"   "$P/k1-f10" &
run f10-mut5    "$S/mut/c1-m5-none-as-broken.sh" "$P/k1-f10" &
run f11-frozen  "$L/plans/round-49-c1.sh"   "$P/k1-f11" &
run f11-mut7    "$S/mut/c1-m7-drop-setup-ok.sh" "$P/k1-f11" &
run k2f8-frozen "$L/plans/round-49-c2.sh"   "$P/k2-f8"  &
run k2f8-mut2   "$S/mut/c2-m2-drop-G5.sh"   "$P/k2-f8"  &
run k2f9-frozen "$L/plans/round-49-c2.sh"   "$P/k2-f9"  &
run k2f9-mut5   "$S/mut/c2-m5-min-lines-0.sh" "$P/k2-f9" &
wait
for f in "$O"/prop-*.txt; do echo "--- $(basename "$f")"; grep -E '^C[12]_' "$f" | head -1; done
