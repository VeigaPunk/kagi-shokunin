#!/usr/bin/env bash
# run one mutant battery in its own scratch; usage: run_battery.sh M0
set -u
S=/fast/scratch/hyaku/kagi-r57/R57MutChecker
m=$1
export HYAKU_SCRATCH="$S"
start=$(date +%s%N)
bash "$S/bin/controls-$m.sh" > "$S/out/battery-$m.log" 2>&1
rc=$?
end=$(date +%s%N)
printf 'rc=%s wall_ms=%s\n' "$rc" "$(( (end - start) / 1000000 ))" > "$S/out/rc-$m.txt"
exit 0
