#!/usr/bin/env bash
# battery.sh -- K45MutBattery bounded behavioral detector for round-45 C1.
# Fixture construction copied verbatim from plans/round-45-c1.sh (frozen counter);
# the gate under test is an argument (reference or mutant), not the lane gate.
# usage: sh battery.sh GATE.sh REV  -> one C1 value line, exit 0 (2 = setup).
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
GATE="${1:?gate}"; REV="${2:?rev}"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}"
mkdir -p "$SCR/kagi-r45/K45MutBattery" || { echo "BATTERY: SETUP scratch"; exit 2; }
S=$(mktemp -d "$SCR/kagi-r45/K45MutBattery/bat-XXXXXX") || { echo "BATTERY: SETUP mktemp"; exit 2; }
trap 'rm -rf -- "$S"' EXIT
[ -f "$GATE" ] || { echo "BATTERY: SETUP no-gate: $GATE"; exit 2; }

mkdir -p "$S/tree"
git -C "$LANE" archive "$REV" | tar -x -C "$S/tree" || { echo "BATTERY: SETUP archive $REV"; exit 2; }
TREE="$S/tree"

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

run_gate() { ( cd "$LANE" && sh "$GATE" --root "$1" ) >"$2" 2>&1; echo $?; }
ra=$(run_gate "$A" "$S/a.out"); rb=$(run_gate "$B" "$S/b.out"); rc=$(run_gate "$C" "$S/c.out")
(cd "$TREE" && sh "$GATE" --root "$TREE") >"$S/real.out" 2>&1; real=$?
detected=0; [ "$ra" -eq 1 ] && detected=$((detected+1)); [ "$rb" -eq 1 ] && detected=$((detected+1))
positive=0; [ "$rc" -eq 1 ] && positive=1
realv=FAIL; [ "$real" -eq 0 ] && realv=CLEAN
value=0; if [ "$positive" -eq 1 ] && [ "$realv" = CLEAN ]; then value=$detected; fi
echo "BATTERY gate=$(basename "$GATE") rev=${REV:0:7} value=$value detected=$detected positive=$positive real=$realv (rc A=$ra B=$rb C=$rc)"
awk 'NF { print "REAL-TREE-GATE: " $0 }' "$S/real.out"
exit 0
