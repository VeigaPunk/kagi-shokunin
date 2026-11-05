#!/usr/bin/env bash
# plans/round-38-c1.sh -- round 38 C1 counter (frozen predicate: corpus/quote-locate.py header).
# Prints one unsigned integer: the located count `located=N` of corpus/quote-bodies.tsv.
# An absent instrument or manifest prints 0 (no quote is located without them).
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 0
if [ ! -f corpus/quote-locate.py ]; then
  echo 0
  exit 0
fi
out=$(python3 -I -B corpus/quote-locate.py --root "$root" 2>/dev/null)
n=$(printf '%s\n' "$out" | sed -n 's/.*located=\([0-9][0-9]*\).*/\1/p' | tail -1)
echo "${n:-0}"
