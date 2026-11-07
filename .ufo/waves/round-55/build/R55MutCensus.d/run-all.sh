#!/usr/bin/env bash
# Run selftest + verify for each mutant copy; record receipts and a summary TSV.
set -uo pipefail
S=/fast/scratch/hyaku/kagi-r55/R55MutCensus
mkdir -p "$S/rep" "$S/tmp"
printf 'mutant\tscript_md5\tselftest_rc\tselftest_last\tselftest_failcases\tverify_rc\tverify_last\tverify_findings\n' >"$S/rep/summary.tsv"
for m in "$@"; do
  d="$S/mut/$m/corpus"
  TMPDIR="$S/tmp" bash "$d/sources-census.sh" --selftest >"$S/rep/$m-selftest.txt" 2>&1
  st_rc=$?
  st_last=$(tail -n 1 "$S/rep/$m-selftest.txt")
  st_fail=$(grep -c 'case .*: FAIL' "$S/rep/$m-selftest.txt")
  TMPDIR="$S/tmp" bash "$d/sources-census.sh" >"$S/rep/$m-verify.txt" 2>&1
  v_rc=$?
  v_last=$(tail -n 1 "$S/rep/$m-verify.txt")
  v_n=$(grep -c '^FINDING ' "$S/rep/$m-verify.txt")
  md5=$(md5sum "$d/sources-census.sh" | cut -d' ' -f1)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$m" "$md5" "$st_rc" "$st_last" "$st_fail" "$v_rc" "$v_last" "$v_n" >>"$S/rep/summary.tsv"
  echo "$m selftest_rc=$st_rc verify_rc=$v_rc verify_findings=$v_n"
done
echo DONE
