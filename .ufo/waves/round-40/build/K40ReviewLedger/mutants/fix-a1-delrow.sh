#!/usr/bin/env bash
# attack1: delete the R13-01 row from corpus/claim-ledger.tsv
set -eu
d=$1
grep -v '^R13-01	' "$d/corpus/claim-ledger.tsv" > "$d/corpus/claim-ledger.tsv.new"
mv "$d/corpus/claim-ledger.tsv.new" "$d/corpus/claim-ledger.tsv"
grep -c '^R13-01	' "$d/corpus/claim-ledger.tsv" || true
echo "attack1 fixture applied"
