#!/usr/bin/env bash
# run one mutant battery in its own scratch; usage: run_battery.sh M0
set -u
S=/fast/scratch/hyaku/kagi-r57/R57MutChecker
m=$1
export HYAKU_SCRATCH="$S"
start=$(date +%s%N)
bash "$S/bin/controlsB-$m.sh" > "$S/out/batteryB-$m.log" 2>&1
rc=$?
end=$(date +%s%N)
printf 'rc=%s wall_ms=%s\n' "$rc" "$(( (end - start) / 1000000 ))" > "$S/out/rcB-$m.txt"
exit 0
