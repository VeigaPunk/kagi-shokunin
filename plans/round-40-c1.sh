#!/usr/bin/env bash
# plans/round-40-c1.sh -- round 40 C1 counter (calibration): the six named debt rows of
# corpus/claim-ledger.tsv re-run against the committed tree.
#
# Frozen predicate (the same sentence appears in plans/round-40.md and the receipt label):
#   prints ONE unsigned integer N -- the number of rows among the frozen debt set
#     R13-01 R21-02 R24-06 R31-02 R33-02 R34-03
#   that `bash corpus/claim-ledger.sh verify` reports with a FAIL, STALE, MISSING or
#   MISSING-ID line at the current tree. Target N=0 at the round-40 landing; the no-work
#   reading at the claim BASE is 6.
#
# Fail closed (exit 2, no integer): verify produces no `CLAIM_LEDGER:` summary line, verify
# dies before its summary, or any of the six ids is not a row of corpus/claim-ledger.tsv.
# Non-set rows (R11-08, R22-03, R24-15, R25-02, R36-03 and the historical MISSING-ID classes)
# are outside this population by design and never counted here.
set -u
cd "$(dirname "$0")/.."
ids="R13-01 R21-02 R24-06 R31-02 R33-02 R34-03"
out=$(bash corpus/claim-ledger.sh verify 2>&1); rc=$?
last=$(printf '%s\n' "$out" | grep -E '^CLAIM_LEDGER:' | tail -1)
if [ -z "$last" ]; then
  echo "counter-refused: no CLAIM_LEDGER summary (rc=$rc)" >&2
  exit 2
fi
for id in $ids; do
  grep -q "^${id}	" corpus/claim-ledger.tsv || { echo "counter-refused: $id absent from claim-ledger.tsv" >&2; exit 2; }
done
n=0
for id in $ids; do
  if printf '%s\n' "$out" | grep -E '^(FAIL|STALE|MISSING|MISSING-ID)' | grep -q " $id "; then
    n=$((n + 1))
  fi
done
echo "$n"
exit 0
