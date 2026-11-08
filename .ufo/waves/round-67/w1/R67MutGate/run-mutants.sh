#!/usr/bin/env bash
# run-mutants.sh — selftest + verify on every tree per mutant, restore pristine.
set -uo pipefail
cd "$(dirname "$0")" || exit 99
TREES="clean repoint samesize quote absolute traversal counts truncate delete escape"
for m in mutants/M*.sh; do
  name=$(basename "$m" .sh)
  d="receipts/$name"
  mkdir -p "$d"
  cp -- "$m" clean/corpus/sources-census.sh
  sha256sum clean/corpus/sources-census.sh >"$d/gate-sha.txt"
  diff -u mutants/pristine.sh "$m" >"$d/mutation.diff"
  bash clean/corpus/sources-census.sh --selftest >"$d/selftest.txt" 2>&1
  echo "rc=$?" >>"$d/selftest.txt"
  for t in $TREES; do
    bash clean/corpus/sources-census.sh --root "$PWD/$t" >"$d/$t.txt" 2>&1
    echo "rc=$?" >>"$d/$t.txt"
  done
  cp -- mutants/pristine.sh clean/corpus/sources-census.sh
  echo "done $name"
done
sha256sum clean/corpus/sources-census.sh
