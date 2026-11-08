#!/usr/bin/env bash
# sweep_parallel.sh -- run run_detectors.sh for pristine + M1..M14, 5 at a time.
set -u
S=/fast/scratch/hyaku/kagi-r64/R64MutC2
out=$S/logs/table_final.tsv
: > "$out"
: > "$S/logs/table_fxD.tsv"
jobs_list=("pristine:$S/pristine/plans/round-64-c2.sh")
for a in M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14; do
  jobs_list+=("$a:$S/mut/c2/$a/plans/round-64-c2.sh")
done
n=0
for item in "${jobs_list[@]}"; do
  name=${item%%:*}; script=${item#*:}
  ( bash "$S/run_detectors.sh" "$name" "$script" >> "$out" 2>&1 ) &
  n=$((n+1))
  if [ $((n % 5)) -eq 0 ]; then wait; fi
done
wait
# fixture D (g_e): pristine + M14
( bash "$S/run_fxD.sh" pristine "$S/pristine/plans/round-64-c2.sh" >> "$S/logs/table_fxD.tsv" 2>&1 ) &
( bash "$S/run_fxD.sh" M14 "$S/mut/c2/M14/plans/round-64-c2.sh" >> "$S/logs/table_fxD.tsv" 2>&1 ) &
wait
echo sweep-done
