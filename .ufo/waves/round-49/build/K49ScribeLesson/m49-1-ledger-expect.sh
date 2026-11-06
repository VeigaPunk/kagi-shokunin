#!/usr/bin/env bash
# Routed finding beside M49-1: ledger claim row R14-01 pins the docs snapshot at
# `entries=35 row_linked=32`. The repaired tree (round-45 ISO entry declared and
# stamped) prints `entries=36 row_linked=33`, so the row's ERE cannot match even
# when the docs gate is CLEAN: the lane's full verify stays red until the row's
# expectation moves. Run on the repaired tree (FLAG) and on a copy whose R14-01
# expectation is updated to the observed counts (CLEAN).
#
# usage: m49-1-ledger-expect.sh <absolute-tree>
set -u
tree=${1:?usage: m49-1-ledger-expect.sh <absolute-tree>}
line=$( cd "$tree" && bash corpus/claim-ledger.sh docs 2>&1 | grep -E '^DOC_AUDIT: ' | tail -1 )
expect=$(awk -F'\t' '$1=="R14-01"{print $3}' "$tree/corpus/claim-ledger.tsv")
printf 'TREE %s\nOBSERVED %s\nR14-01_EXPECT %s\n' "$tree" "$line" "$expect"
if printf '%s\n' "$line" | grep -qE "$expect"; then
  printf 'VERDICT: CLEAN (R14-01 expectation matches the observed docs line)\n'
  exit 0
fi
printf 'VERDICT: FLAG (R14-01 expectation does not match the observed docs line)\n'
exit 1
