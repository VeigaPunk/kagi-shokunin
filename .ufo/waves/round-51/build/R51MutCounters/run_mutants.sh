#!/usr/bin/env bash
# Run one frozen controls sweep against one mutant lane; capture stdout/stderr/rc/timing.
# usage: run_mutants.sh <parallelism> <id>...
set -u
S=/fast/scratch/hyaku/kagi-r51/R51MutCounters
BAO=/home/vgpnk/.local/bin/bao
P=${1:?parallelism}; shift
mkdir -p "$S/res"
runone() {
  local id=$1 d=$S/mut/$1 kind=c1
  case "$id" in C2-*) kind=c2;; esac
  mkdir -p "$S/scr/$id"
  local t0 t1
  t0=$(date +%s)
  ( cd "$d/work" && env HOME=/home/vgpnk HYAKU_SCRATCH="$S/scr/$id" R51_BAO="$BAO" \
      timeout 2400 bash "$d/work/plans/round-51-controls.sh" "$kind" \
      > "$S/res/$id.stdout" 2> "$S/res/$id.stderr" )
  local rc=$?
  t1=$(date +%s)
  echo "rc=$rc secs=$((t1 - t0))" > "$S/res/$id.rc"
  # last line of the sweep
  tail -n 1 "$S/res/$id.stdout" >> "$S/res/$id.rc"
  echo "DONE $id rc=$rc secs=$((t1 - t0))"
}

pids=()
for id in "$@"; do
  runone "$id" &
  pids+=($!)
  while [ "$(jobs -rp | wc -l)" -ge "$P" ]; do wait -n; done
done
wait
echo "ALL DONE"
