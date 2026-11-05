#!/usr/bin/env bash
# make <name> [fixture-sh] — fresh scratch tree from the attack clone + fixture hook
set -eu
src=/fast/scratch/hyaku/kagi-r40/K40ReviewLedger/clone
root=/fast/scratch/hyaku/kagi-r40/K40ReviewLedger/variants
name=$1
[ -z "${2:-}" ] || FIX=$2
dest=$root/$name
rm -rf "$dest"
cp -a "$src" "$dest"
rm -rf "$dest/.ufo/waves/round-40/build"   # drop sibling build noise; not part of any population
[ -z "${FIX:-}" ] || bash "$FIX" "$dest"
echo "variant ready: $dest"
