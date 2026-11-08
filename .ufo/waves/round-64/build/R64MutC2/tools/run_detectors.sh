#!/usr/bin/env bash
# run_detectors.sh NAME SCRIPT -- four bounded detectors on one counter script.
#   D1 --selftest                                   expect PASS
#   D2 --tree fx/A                                  expect killed=0 guard=0
#   D3 --tree fx/C                                  expect killed=5 guard=1 (target)
#   D4 C2_RECURSION_BOUND=0 --tree fx/C (25 s)      expect rc=124, no line
# File redirection only; a killed child's grandchild cannot stall a detector.
set -u
S=/fast/scratch/hyaku/kagi-r64/R64MutC2
name=$1; script=$2
out=$S/logs
mkdir -p "$out"
export HYAKU_SCRATCH=$S
export R63_CONTROLS_RECEIPT=/dev/null
export R64_CONTROLS_RECEIPT=/dev/null

run() { # TAG TMO ENVPREFIX ARGS...
  local tag=$1 tmo=$2 envpfx=$3; shift 3
  local log=$out/$name.$tag.log
  if [ -n "$envpfx" ]; then
    env "$envpfx" timeout -k 5 "$tmo" bash "$script" "$@" >"$log" 2>&1
  else
    timeout -k 5 "$tmo" bash "$script" "$@" >"$log" 2>&1
  fi
  local rc=$?
  local line
  line=$(grep -E '^(C2_REFUSAL|C2R64_SELFTEST|FINDING)' "$log" | tail -1)
  printf '%s\t%s\trc=%s\t%s\n' "$name" "$tag" "$rc" "${line:-none}"
}

run selftest 120 "" --selftest
run fxA 120 "" --tree "$S/fx/A"
run fxC 90 "" --tree "$S/fx/C"
run d4 25 "C2_RECURSION_BOUND=0" --tree "$S/fx/C"
