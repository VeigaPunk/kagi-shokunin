#!/usr/bin/env bash
# leg-c2-source-commands.sh — L1 candidate-side leg for round-49 C2 (not a frozen instrument).
# Implements the rule stated in the header of seat K49CriticCeiling's leg-c2-live-sources.sh
# ("requires the four source rows' command column to be byte-identical to BASE"), whose code
# compares whole rows and therefore also refuses a journaled expect migration. This leg checks:
#   (a) the command column (field 2) of ledger rows R12-03 and R14-01 equals BASE's;
#   (b) every expect/command change against the BASE ledger is journaled
#       (corpus/expect-journal.sh CLEAN over the round-49 journal).
# Usage: bash leg-c2-source-commands.sh <candidate-ledger.tsv> <journal-dir>
# Exit 0 PASS, 1 FAIL, 2 setup.
set -u
CAND=${1:?usage}; JD=${2:?usage}
L=$(cd "$(dirname "$0")/../../../.." && pwd)
BASE=89afe91878f10805921d3caa67d28d21b33226da
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r49"; mkdir -p "$SCR"
W=$(mktemp -d "$SCR/leg-c2c.XXXXXX") || { echo "LEG_C2_CMD: SETUP mktemp"; exit 2; }
trap 'rm -rf -- "$W"' EXIT
git -C "$L" show "$BASE:corpus/claim-ledger.tsv" > "$W/base.tsv" || { echo "LEG_C2_CMD: SETUP base"; exit 2; }
[ -f "$CAND" ] || { echo "LEG_C2_CMD: SETUP candidate-ledger"; exit 2; }
bad=""
for id in R12-03 R14-01; do
  a=$(awk -F'\t' -v i="$id" '$1==i{print $2}' "$W/base.tsv")
  b=$(awk -F'\t' -v i="$id" '$1==i{print $2}' "$CAND")
  [ -n "$a" ] && [ "$a" = "$b" ] || bad="$bad command-redefined:$id"
done
j=$(bash "$L/corpus/expect-journal.sh" --base-ledger "$W/base.tsv" --ledger "$CAND" --journals "$JD" 2>&1 | tail -1)
case "$j" in "EXPECT_JOURNAL: CLEAN"*) ;; *) bad="$bad journal:[$j]";; esac
if [ -z "$bad" ]; then echo "LEG_C2_CMD: PASS ($j)"; exit 0; fi
echo "LEG_C2_CMD: FAIL$bad"; exit 1
