#!/usr/bin/env bash
# plans/round-51-c2.sh — FROZEN round-51 C2 counter (axis calibration): the lane's declared-claim
# manifest and its capabilities-table readings versus the observed repo state.
#
# Predicate (same sentence as plans/round-51.md §C2):
#   C2_SELF_ASSESSMENT: value = M + V, where M = the number of `MISMATCH ` lines that the measured
#   revision's `bash corpus/claims-declared.sh --root <checkout>` prints and V = the `value=` that the
#   frozen round-48 counter `bash plans/round-48-c2.sh <rev>` (this lane's working copy, sha256-pinned) prints for the measured revision, when
#   GUARD = 1, else SETUP; target 0 (BASE 214d8bf5 reads 3: M 2 = round-50 C1/C2 no-manifest-row,
#   V 1 = K07).
# - GUARD: (g1) corpus/claims-declared.sh and plans/round-48-c2.sh at the measured revision have the
#   BASE sha256 pinned below; (g2) every plans/round-*.md file present at BASE is byte-identical at
#   the measured revision; (g3) every data row of corpus/claims-declared.tsv at BASE is present
#   unchanged at the measured revision; (g4) claims-declared prints a final
#   `CLAIMS_DECLARED: CLEAN|MISMATCH (claims=N...)` line and the round-48 counter prints a
#   `C2_CAPABILITY_READINGS: value=<n> ` line. Any failure is SETUP (exit 2), never a zero.
# Usage: bash plans/round-51-c2.sh <rev>   (rev in this repo; this script's own repo is the lane)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r51/c2-counter.XXXXXX, removed on exit.
set -u
BASE=214d8bf530a0c87c00686493f21af15396284793
PIN_GATE=6e779fe8d7dafed1c21cd227446e03541c6f76df04489e5081c01c5bc01bb863
PIN_R48=15f7a0c3a6050a575365cec3bb5b586da7a396e1a1dde45ed3154b98e59a4fce
setup() { echo "C2_SELF_ASSESSMENT: SETUP reason=$1"; exit 2; }
[ $# -eq 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r51"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c2-counter.XXXXXX") || setup mktemp
trap 'rm -rf -- "$W"' EXIT
REV=$(git -C "$LANE" rev-parse --verify -q "$1^{commit}") || setup bad-rev
git -C "$LANE" cat-file -e "$BASE^{commit}" 2>/dev/null || setup base-missing
mkdir -p "$W/t" "$W/b"
git -C "$LANE" archive "$REV" | tar -x -C "$W/t" || setup archive
git -C "$LANE" archive "$BASE" | tar -x -C "$W/b" || setup archive-base

# g1
[ "$(sha256sum < "$W/t/corpus/claims-declared.sh" 2>/dev/null | cut -d' ' -f1)" = "$PIN_GATE" ] || setup g1-gate-changed
[ "$(sha256sum < "$W/t/plans/round-48-c2.sh" 2>/dev/null | cut -d' ' -f1)" = "$PIN_R48" ] || setup g1-r48-changed
# g2
for f in "$W"/b/plans/round-*.md; do
  n=${f#"$W/b/"}
  cmp -s "$f" "$W/t/$n" || setup "g2-changed:$n"
done
# g3
grep -vE '^(#|round	|$)' "$W/b/corpus/claims-declared.tsv" > "$W/base-rows" || setup g3-base-empty
while IFS= read -r row; do
  grep -qxF -- "$row" "$W/t/corpus/claims-declared.tsv" || setup "g3-row-missing:$(printf '%s' "$row" | tr '\t' ' ')"
done < "$W/base-rows"

# M
( cd "$W/t" && timeout 300 bash corpus/claims-declared.sh --root . ) > "$W/cd.out" 2> "$W/cd.err"
cd_rc=$?
last=$(grep -v '^$' "$W/cd.out" | tail -n 1)
printf '%s' "$last" | grep -qE '^CLAIMS_DECLARED: (CLEAN \(claims=[0-9]+\)|MISMATCH \(claims=[0-9]+ mismatch=[0-9]+\))$' || setup "g4-claims-declared(rc=$cd_rc)"
M=$(grep -c '^MISMATCH ' "$W/cd.out")

# V: the frozen round-48 counter, run from this lane's working copy (pinned to the BASE bytes)
[ "$(sha256sum < "$LANE/plans/round-48-c2.sh" | cut -d' ' -f1)" = "$PIN_R48" ] || setup g1-r48-working-copy
timeout 900 bash "$LANE/plans/round-48-c2.sh" "$REV" > "$W/r48.out" 2> "$W/r48.err"
r48_rc=$?
V=$(sed -nE 's/^C2_CAPABILITY_READINGS: value=([0-9]+) .*/\1/p' "$W/r48.out" | head -n 1)
printf '%s' "$V" | grep -qxE '[0-9]+' || setup "g4-r48(rc=$r48_rc)"
printf '%s' "$M" | grep -qxE '[0-9]+' || setup g4-m

echo "C2_SELF_ASSESSMENT: value=$((M + V)) M=$M V=$V rev=$REV"
grep '^MISMATCH ' "$W/cd.out" | sed 's/^/  /'
grep -E '^  K[0-9]+ DIFF|^  K[0-9]+ MISSING' "$W/r48.out"
echo "  claims-declared: $last"
exit 0
