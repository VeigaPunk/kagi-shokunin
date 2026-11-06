#!/usr/bin/env bash
# K48ScribeLesson — M48-3 receipt: a frozen counter header asserts a property of its own row set
# ("the eleven rows with no successor row") that the registry contradicts.
#
# Usage: bash m48-3-successor-claim.sh [registry] [counter-header-file]
# Prints the successor edges, then VERDICT: FLAG|CLEAN for the sentence under test.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
SRC=${1:-$LANE/corpus/SOURCES.md}
HDR=${2:-$LANE/plans/round-47-c2.sh}
F="S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026"

total=0; edges=""
for id in $F; do
  total=$((total + 1))
  hits=$(awk -F'|' -v id="$id" '
    $2 ~ ("^[[:space:]]*S[0-9]+[[:space:]]*$") && $8 ~ ("supersedes " id "([^-0-9A-Za-z]|$)") {
      gsub(/[[:space:]]/, "", $2); print $2 }' "$SRC" | paste -sd, -)
  [ -n "$hits" ] && edges="$edges
  $hits supersedes $id"
done

succ=$(printf '%s\n' $F | while read -r id; do
  awk -F'|' -v id="$id" '$2 ~ ("^[[:space:]]*S[0-9]+[[:space:]]*$") && $8 ~ ("supersedes " id "([^-0-9A-Za-z]|$)") {n++} END{print n+0}' "$SRC"
done | awk '{s+=$1} END{print s+0}')

echo "F = $total ids: $F"
echo "successor edges found in $(basename "$SRC"):$edges"
echo "ids in F with >=1 successor row = $succ"
echo "header sentence under test: 'no successor row'"
n=$(grep -c 'no successor row' "$HDR")
echo "occurrences in $(basename "$HDR") = $n"
if [ "$n" -gt 0 ] && [ "$succ" -gt 0 ]; then
  echo "VERDICT: FLAG (the header's claim is false for $succ/$total ids)"
  exit 1
else
  echo "VERDICT: CLEAN"
  exit 0
fi
