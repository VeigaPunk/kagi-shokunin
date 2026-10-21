#!/usr/bin/env bash
# host-tripwire.sh — round-24 C1 counting instrument (operability / D4).
#
# Question: how many HOST-population ledger rows does the DEFAULT real-tree
# entry point execute?  Population (frozen, round-23 QM12 skipped list in
# .ufo/waves/round-23/final-verification.json): R11-01 R11-02 R11-03 R11-04
# R11-06 R12-01 R13-03 R15-01 R16-01 R16-03 R17-01 R18-01.
#
# Method: clone the lane at REV into a scratch dir (never the lane), optionally
# overlay listed working-tree files from SRC (the uncommitted candidate), then
# replace every host-reading script those rows invoke with a stub that only
# appends `depth=<CLAIM_LEDGER_DEPTH> <script> <args>` to a log and exits 0.
# No stub reads any host path; HOME points at an empty scratch dir.  Then run
# `verify` and `cells` with KAGI_SUBSTRATE=absent and =present.
# A log line whose `<script> <args>` equals a population row command is one
# host-row execution (depth 1 = the row itself; depth 2 = a row re-run by
# `cells`, which is how R13-03 / the round-23 M23-5 run reached R18-01).
#
# Usage: host-tripwire.sh LABEL REV [SRC FILE...]
# Prints one line per run and a final
#   HOST_TRIPWIRE: label=<L> rev=<12hex> verify_absent=<n> verify_present=<n> cells_absent=<n> cells_present=<n> total=<n> complete=<k>/4 host_skip_lines=<n>
# A run is COMPLETE only when its last line is the gate's own summary
# (CLAIM_LEDGER:/CELL_AUDIT:); a total from an incomplete run is not evidence
# (wave-1 SentHarness MEDIUM). LABEL and overlay paths are confined
# (SentHarness HIGH): LABEL is [A-Za-z0-9._-] without `..`; FILE is relative
# without `..`.
set -euo pipefail
label=$1 rev=$2; shift 2
[[ $label =~ ^[A-Za-z0-9._-]+$ && $label != *..* ]] || { echo "bad label" >&2; exit 2; }
[[ $rev =~ ^[0-9a-f]{40}$ ]] || { echo "rev must be a full 40-hex commit" >&2; exit 2; }
src=""; [[ $# -gt 0 ]] && { src=$1; shift; }
lane=/home/vgpnk/Projects/shokunin/kagi-shokunin
base=/fast/scratch/kagi-r24/tripwire/$label
rm -rf -- "$base"; mkdir -p "$base/home"
git clone -q --no-hardlinks "$lane" "$base/tree"
git -C "$base/tree" -c advice.detachedHead=false checkout -q "$rev"
for f in "$@"; do
  [[ $f != /* && $f != *..* ]] || { echo "bad overlay path: $f" >&2; exit 2; }
  cp -- "$src/$f" "$base/tree/$f"
done
stubs=(surface-census.sh drift-pins.sh transcript-scan.sh op-ref-probe.sh checklist-run.sh scope-gate.sh)
for s in "${stubs[@]}"; do
  printf '#!/usr/bin/env bash\nprintf "depth=%%s %s %%s\\n" "${CLAIM_LEDGER_DEPTH:-0}" "$*" >>"$TRIPWIRE_LOG"\nprintf "STUB\\n"\n' "$s" >"$base/tree/corpus/$s"
done
pop=( "surface-census.sh " "surface-census.sh --verbs" "surface-census.sh --selftest" "drift-pins.sh "
      "transcript-scan.sh " "op-ref-probe.sh " "checklist-run.sh " "scope-gate.sh "
      "scope-gate.sh --falsify" "scope-gate.sh --breadth" )
count() { # log -> number of population executions (R11-04/R18-01 share one command)
  local n=0 l body p
  [[ -f $1 ]] || { echo 0; return; }
  while IFS= read -r l; do
    body=${l#depth=* }
    for p in "${pop[@]}"; do [[ $body == "$p" ]] && { n=$((n + 1)); break; }; done
  done <"$1"
  echo "$n"
}
declare -A R
complete=0 skips=0
HOST12=" R11-01 R11-02 R11-03 R11-04 R11-06 R12-01 R13-03 R15-01 R16-01 R16-03 R17-01 R18-01 "
pop_skips() { # out-file → how many DISTINCT frozen population ids print HOST-SKIP
  local id n=0
  while read -r id; do [[ $HOST12 == *" $id "* ]] && n=$((n + 1)); done < <(sed -n 's/^HOST-SKIP \([^ ]*\) .*/\1/p' "$1" | sort -u)
  echo "$n"
}
for mode in verify cells; do
  for sub in absent present; do
    log="$base/$mode-$sub.log"; : >"$log"
    rc=0
    ( cd "$base/tree" && env -i PATH="$PATH" HOME="$base/home" LANG=C.UTF-8 \
        TRIPWIRE_LOG="$log" KAGI_SUBSTRATE="$sub" timeout -k 5 1500 \
        bash corpus/claim-ledger.sh "$mode" >"$base/$mode-$sub.out" 2>&1 ) || rc=$?
    R[$mode-$sub]=$(count "$log")
    last=$(grep -v '^[[:space:]]*$' "$base/$mode-$sub.out" | tail -n 1 || true)
    [[ $last == CLAIM_LEDGER:* || $last == CELL_AUDIT:* ]] && complete=$((complete + 1))
    n=$(grep -c '^HOST-SKIP ' "$base/$mode-$sub.out" || true); skips=$((skips + n))
    ps=$(pop_skips "$base/$mode-$sub.out")
    printf 'RUN %s substrate=%s exit=%s host_rows_executed=%s host_skip_lines=%s population_skipped=%s/12 last=%s\n' "$mode" "$sub" "$rc" \
      "${R[$mode-$sub]}" "$n" "$ps" "$(printf '%s' "$last" | cut -c1-200)"
  done
done
total=$(( R[verify-absent] + R[verify-present] + R[cells-absent] + R[cells-present] ))
printf 'HOST_TRIPWIRE: label=%s rev=%s verify_absent=%s verify_present=%s cells_absent=%s cells_present=%s total=%s complete=%s/4 host_skip_lines=%s\n' \
  "$label" "${rev:0:12}" "${R[verify-absent]}" "${R[verify-present]}" "${R[cells-absent]}" "${R[cells-present]}" "$total" "$complete" "$skips"
