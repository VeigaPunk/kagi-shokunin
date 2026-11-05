#!/usr/bin/env bash
# plans/round-38-c2.sh -- round 38 C2 counter (frozen predicate: corpus/laneguard.sh header).
# Prints one unsigned integer: `detected=N` of `laneguard.sh --selftest`. An absent
# instrument prints 0 (no planted write is detected without it).
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 0
if [ ! -f corpus/laneguard.sh ]; then
  echo 0
  exit 0
fi
out=$(bash corpus/laneguard.sh --selftest 2>/dev/null)
n=$(printf '%s\n' "$out" | sed -n 's/.*detected=\([0-9][0-9]*\).*/\1/p' | tail -1)
echo "${n:-0}"
