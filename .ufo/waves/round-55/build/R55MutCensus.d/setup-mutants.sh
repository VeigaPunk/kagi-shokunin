#!/usr/bin/env bash
# Build 16 isolated mutant copies of the candidate corpus tree.
set -uo pipefail
S=/fast/scratch/hyaku/kagi-r55/R55MutCensus
rm -rf -- "$S/mut"
mkdir -p "$S/mut"
for m in M01 M02 M03 M04 M05 M06 M07 M08 M09 M10 M11 M12 M13 M14 M15 M16; do
  mkdir -p "$S/mut/$m/corpus"
  cp -a "$S/rev/corpus/." "$S/mut/$m/corpus/" || { echo "FAIL copy $m"; exit 1; }
  n=$(ls "$S/mut/$m/corpus" | wc -l)
  [ "$n" -eq 53 ] || { echo "FAIL count $m=$n"; exit 1; }
done
echo "SETUP_OK 16 mutants, 53 corpus entries each"
md5sum "$S/rev/corpus/sources-census.sh" | tee "$S/rep/pristine-md5.txt"
