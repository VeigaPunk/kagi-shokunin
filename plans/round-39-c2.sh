#!/usr/bin/env bash
# plans/round-39-c2.sh -- round 39 C2 counter (frozen predicate: corpus/claims-declared.sh header).
#
# Prints one unsigned integer: how many of three planted declared-axis relabels the gate
# reports as MISMATCH, measured on a self-contained fixture lane built in scratch:
#   X1  the tagged SCORECARD row's axis relabelled calibration -> operability
#   X2  the plan heading's axis relabelled calibration -> operability
#   X3  the tag removed from the freshness row (an untagged claim)
# The count is printed only when the unmutated fixture is CLEAN (positive control); otherwise
# 0. An absent instrument prints 0 (no gate exists: the do-nothing reading).
root=$(cd "$(dirname "$0")/.." && pwd) || { echo 0; exit 0; }
if [ ! -f "$root/corpus/claims-declared.sh" ]; then
  echo 0
  exit 0
fi
scratch=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r39
mkdir -p "$scratch" 2>/dev/null || { echo 0; exit 0; }
t=$(mktemp -d "$scratch/c2.XXXXXX") || { echo 0; exit 0; }
trap 'rm -rf -- "$t"' EXIT

fixture() { # $1 = directory to create
  mkdir -p "$1/corpus" "$1/plans" || return 1
  printf 'round\tclaim\taxis\n39\tC1\tfreshness\n39\tC2\tcalibration\n' > "$1/corpus/claims-declared.tsv"
  cat > "$1/plans/round-39.md" <<'PLAN'
# fixture plan

## C1 — freshness: fixture claim one

## C2 — calibration: fixture claim two
PLAN
  cat > "$1/SCORECARD.md" <<'CARD'
# fixture scorecard

## Round 39 — post-move (fixture)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] fixture move one | none |
| calibration | 9 → 9 | [C2] fixture move two | none |

## Round 38 — post-move (fixture)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C2] older row, must not be read | none |
CARD
}

clean="$t/clean"
fixture "$clean" || { echo 0; exit 0; }
clean_out=$(bash "$root/corpus/claims-declared.sh" --root "$clean" 2>/dev/null)
clean_rc=$?
if [ "$clean_rc" -ne 0 ] || [[ "$clean_out" != "CLAIMS_DECLARED: CLEAN"* ]]; then
  echo 0
  exit 0
fi

detected=0
mutant() { # $1 = name, $2 = function that edits the fixture in place
  local d="$t/$1"
  fixture "$d" || return 0
  "$2" "$d"
  local out rc
  out=$(bash "$root/corpus/claims-declared.sh" --root "$d" 2>/dev/null)
  rc=$?
  if [ "$rc" -eq 1 ] && [[ "$out" == *"MISMATCH"* ]]; then
    detected=$((detected + 1))
  fi
}
x1() { sed -i 's/^| calibration | 9 → 9 | \[C2\] fixture move two/| operability | 9 → 9 | [C2] fixture move two/' "$1/SCORECARD.md"; }
x2() { sed -i 's/^## C2 — calibration: fixture claim two/## C2 — operability: fixture claim two/' "$1/plans/round-39.md"; }
x3() { sed -i 's/^| freshness | 9 → 9 | \[C1\] fixture move one/| freshness | 9 → 9 | fixture move one/' "$1/SCORECARD.md"; }
mutant X1 x1
mutant X2 x2
mutant X3 x3
echo "$detected"
exit 0
