#!/usr/bin/env bash
# plans/round-39-c1.sh -- round 39 C1 counter (frozen predicate: corpus/anchor-pins.sh header).
#
# Prints one unsigned integer: how many of the three frozen in-place anchor rewrites are
# reported DRIFT by corpus/anchor-pins.sh on a scratch copy of corpus/:
#   M1  S034 anchor v2.2.0 -> v2.2.1        (vault release feed)
#   M2  S035 anchor v2.7.1 -> v2.7.2        (openbao release feed)
#   M3  S039 anchor Python 3.15.1 -> 3.15.2 (python release feed)
# The count is printed only when the unmutated tree is CLEAN (positive control); otherwise 0.
# An absent instrument or pin file prints 0 (no detector exists: the do-nothing reading).
root=$(cd "$(dirname "$0")/.." && pwd) || { echo 0; exit 0; }
if [ ! -f "$root/corpus/anchor-pins.sh" ] || [ ! -f "$root/corpus/anchor-pins.tsv" ]; then
  echo 0
  exit 0
fi
scratch=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r39
mkdir -p "$scratch" 2>/dev/null || { echo 0; exit 0; }
t=$(mktemp -d "$scratch/c1.XXXXXX") || { echo 0; exit 0; }
trap 'rm -rf -- "$t"' EXIT

clean_out=$(bash "$root/corpus/anchor-pins.sh" --root "$root" 2>/dev/null)
clean_rc=$?
if [ "$clean_rc" -ne 0 ] || [[ "$clean_out" != "ANCHOR_PINS: CLEAN"* ]]; then
  echo 0
  exit 0
fi

detected=0
mutant() { # $1 = name, $2 = sed program applied to the single registry row it names
  local d="$t/$1"
  mkdir -p "$d" || return 0
  cp -r "$root/corpus" "$d/" || return 0
  cp "$d/corpus/SOURCES.md" "$d/corpus/SOURCES.before" || return 0
  sed -i "$2" "$d/corpus/SOURCES.md" || return 0
  if cmp -s "$d/corpus/SOURCES.md" "$d/corpus/SOURCES.before"; then
    return 0
  fi
  local out rc
  out=$(bash "$root/corpus/anchor-pins.sh" --root "$d" 2>/dev/null)
  rc=$?
  if [ "$rc" -eq 1 ] && [[ "$out" == *"DRIFT"* ]]; then
    detected=$((detected + 1))
  fi
}
mutant M1 '/^| S034 |/ s/v2\.2\.0/v2.2.1/g'
mutant M2 '/^| S035 |/ s/v2\.7\.1/v2.7.2/g'
mutant M3 '/^| S039 |/ s/Python 3\.15\.1/Python 3.15.2/g'
echo "$detected"
exit 0
