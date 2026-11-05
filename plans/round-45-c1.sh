#!/usr/bin/env bash
# plans/round-45-c1.sh -- frozen counter for round-45 C1 (calibration): plan<->manifest bijection.
#
# Frozen predicate (the same sentence appears in plans/round-45.md and in this counter's label):
#   C1_BIJECTION: value = DETECTED when POSITIVE = 1 and REAL = CLEAN, else 0; target 2.
#   DETECTED  = number of planted-omission fixtures A and B that the claims-declared gate
#               reports as MISMATCH (exit 1) under the revision being measured.
#   POSITIVE  = 1 when the planted-axis-relabel fixture C is reported MISMATCH (gate-alive control).
#   REAL      = CLEAN when the gate exits 0 on the real tree of the revision being measured.
#
# Fixtures (synthetic rounds 90 and 91, built in scratch; never committed):
#   A  round 90 plan has claim headings C1 and C2; manifest has a row for C1 only; SCORECARD
#      round-90 post-move section tags both C1 and C2. Omitted row C2 must be MISMATCH.
#   B  round 90 plan + post-move section carry C1 with no manifest row for round 90 at all;
#      round 91 is a complete, correct row set (positive shape). Missing 90/C1 must be MISMATCH.
#   C  round 90 manifest row says C1 calibration; plan heading says C1 freshness. Must be MISMATCH.
#
# usage: bash plans/round-45-c1.sh [REV|LANE]   (LANE = the working tree; default LANE)
# exit 0 with the line `C1_BIJECTION: value=<n> detected=<d> positive=<p> real=<CLEAN|FAIL>`.
# Exit 2 on setup failure. Scratch root: $HYAKU_SCRATCH/kagi-r45/C1-<pid>, deleted on exit.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
REV="${1:-LANE}"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}"
mkdir -p "$SCR/kagi-r45" || { echo "C1_BIJECTION: SETUP scratch" ; exit 2; }
S=$(mktemp -d "$SCR/kagi-r45/C1-XXXXXX") || { echo "C1_BIJECTION: SETUP mktemp"; exit 2; }
trap 'rm -rf -- "$S"' EXIT

if [ "$REV" = LANE ]; then
  TREE="$LANE"
else
  mkdir -p "$S/tree" && git -C "$LANE" archive "$REV" | tar -x -C "$S/tree" || { echo "C1_BIJECTION: SETUP archive $REV"; exit 2; }
  TREE="$S/tree"
fi
GATE="$TREE/corpus/claims-declared.sh"
[ -f "$GATE" ] || { echo "C1_BIJECTION: SETUP no-gate"; exit 2; }

fx() { # fx DIR ; creates the common shell of a fixture
  mkdir -p "$1/corpus" "$1/plans"
}
post() { # post ROUND "tag-axis-pairs" -> SCORECARD post-move section
  printf '## Round %s — post-move\n\n| axis | score | evidence |\n|---|---|---|\n' "$1"
  for p in $2; do printf '| %s | 9 → 9 | [%s] fixture row | fx |\n' "${p#*:}" "${p%%:*}"; done
  printf '\n'
}

# A: manifest has C1 only; plan 90 carries C1 and C2 headings; post-move tags both.
A="$S/fxA"; fx "$A"
printf 'round\tclaim\taxis\n90\tC1\tcalibration\n' > "$A/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n\n## C2 — coverage: fixture claim two\n\ntext\n' > "$A/plans/round-90.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration C2:coverage"; } > "$A/SCORECARD.md"

# B: round 90 has no manifest rows; round 91 is a complete correct row set.
B="$S/fxB"; fx "$B"
printf 'round\tclaim\taxis\n91\tC1\tcalibration\n' > "$B/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n' > "$B/plans/round-90.md"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n' > "$B/plans/round-91.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration"; post 91 "C1:calibration"; } > "$B/SCORECARD.md"

# C: manifest says calibration; plan heading says freshness (positive control: gate must be alive).
C="$S/fxC"; fx "$C"
printf 'round\tclaim\taxis\n90\tC1\tcalibration\n' > "$C/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — freshness: fixture claim one\n\ntext\n' > "$C/plans/round-90.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration"; } > "$C/SCORECARD.md"

run_gate() { ( cd "$LANE" && sh "$GATE" --root "$1" ) >/dev/null 2>&1; echo $?; }
ra=$(run_gate "$A"); rb=$(run_gate "$B"); rc=$(run_gate "$C")
(cd "$TREE" && sh "$GATE" --root "$TREE") >/dev/null 2>&1; real=$?
detected=0; [ "$ra" -eq 1 ] && detected=$((detected+1)); [ "$rb" -eq 1 ] && detected=$((detected+1))
positive=0; [ "$rc" -eq 1 ] && positive=1
realv=FAIL; [ "$real" -eq 0 ] && realv=CLEAN
value=0; if [ "$positive" -eq 1 ] && [ "$realv" = CLEAN ]; then value=$detected; fi
echo "C1_BIJECTION: value=$value detected=$detected positive=$positive real=$realv (rc A=$ra B=$rb C=$rc tree=$REV)"
exit 0
