#!/usr/bin/env bash
# run_fxD.sh NAME SCRIPT -- the g_e-guard detector on fixture D (tree D's
# round-63 battery selftest FAILs while its fixture-only controls still mismatch).
set -u
S=/fast/scratch/hyaku/kagi-r64/R64MutC2
name=$1; script=$2
export HYAKU_SCRATCH=$S
export R63_CONTROLS_RECEIPT=/dev/null
export R64_CONTROLS_RECEIPT=/dev/null
log=$S/logs/$name.fxD.log
timeout -k 5 90 bash "$script" --tree "$S/fx/D" >"$log" 2>&1
rc=$?
line=$(grep -E '^(C2_REFUSAL|FINDING)' "$log" | tail -1)
printf '%s\tfxD\trc=%s\t%s\n' "$name" "$rc" "${line:-none}"
