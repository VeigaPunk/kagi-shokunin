#!/usr/bin/env bash
# Execution-surface watcher for round-67.
# Samples the process table for the forbidden execution surfaces and samples
# the fleet root for writes outside the lane. Logs to $1 until killed.
OUT="$1"
: > "$OUT"
while true; do
  ts=$(date -Is)
  # forbidden execution surfaces
  ps -eo pid=,ppid=,etimes=,args= 2>/dev/null \
    | grep -E '(^|[ /])(op|op-run|pacman|sysctl)( |$)' \
    | grep -vE 'execwatch|grep -E' >> "$OUT" 2>/dev/null
  # writes outside the lane's allowed set, sampled
  find /home/vgpnk/Projects/shokunin -maxdepth 4 -newermt '-30 seconds' \
       -not -path '*/.git/*' -not -path '*/.jj/*' -type f 2>/dev/null \
    | grep -v '^/home/vgpnk/Projects/shokunin/kagi-shokunin/' \
    >> "$OUT" 2>/dev/null
  sleep 5
done
