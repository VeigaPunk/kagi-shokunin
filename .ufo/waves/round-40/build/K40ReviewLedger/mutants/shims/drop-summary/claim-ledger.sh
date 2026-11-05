#!/usr/bin/env bash
target=/fast/scratch/hyaku/kagi-r40/K40ReviewLedger/variants/clean/corpus/claim-ledger.sh.bak
[ -x "$target" ] || target=/fast/scratch/hyaku/kagi-r40/K40ReviewLedger/variants/clean/corpus/claim-ledger.sh
out=$(bash "$target" "$@" 2>&1); rc=$?
rc0=$rc
printf '%s\n' "$out" | grep -vE '^CLAIM_LEDGER:' 
exit $rc0
