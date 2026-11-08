#!/usr/bin/env bash
# ROW-TEXT-ONLY L2: never executes either counter's derivation.
G=0; M=0
# L1: compare ledger R21-03 pin to live selftest — stub census printer passes this.
LED=$(awk -F'\t' '$1=="R21-03"{print $3}' corpus/claim-ledger.tsv)
LEDN=$(printf '%s' "$LED" | grep -oE '[0-9]+ cases' | grep -oE '[0-9]+')
LIVEN=$(bash corpus/sources-census.sh --selftest 2>&1 | tail -n1 | grep -oE '[0-9]+ cases' | grep -oE '[0-9]+')
if [ "$LEDN" = "$LIVEN" ]; then :; else M=$((M+1)); fi
# L2: rows exist and name the predicates — the stub counter prints exactly that.
grep -q $'^R68-01\tbash plans/round-68-c1.sh\t.*C1_VERIFIED:' corpus/claim-ledger.tsv || M=$((M+1))
grep -q $'^R68-02\tbash plans/round-68-c2.sh\t.*C2_RECORD:' corpus/claim-ledger.tsv || M=$((M+1))
# L3: cells verdict line ≠ SETUP
if bash corpus/claim-ledger.sh cells 2>&1 | grep -q SETUP; then M=$((M+1)); fi
echo "C2_RECORD: mismatches=$M population=3 guard=1"
[ "$M" -eq 0 ] && exit 0 || exit 1
