#!/usr/bin/env bash
# K45Sentinel adversarial demo (scratch only):
#   Does the frozen C1 counter distinguish a gate that checks the FROZEN scope
#   (rounds R >= 39) from a gate that only checks the counter's synthetic rounds (R >= 90)?
# Nothing in the lane is touched. Mutants live in scratch.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-forgery-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
GATE_SRC="$LANE/.ufo/waves/round-45/build/K45ExecBijection/claims-declared.sh"

mkdir -p "$S/tree" && git -C "$LANE" archive 307fb50da825d6e6f2b5c7981c71556d35611142 | tar -x -C "$S/tree" || exit 2
# install the candidate gate into the scratch tree
cp "$GATE_SRC" "$S/tree/corpus/claims-declared.sh"

# build the three frozen fixtures exactly as plans/round-45-c1.sh does
fx() { mkdir -p "$1/corpus" "$1/plans"; }
post() { printf '## Round %s — post-move\n\n| axis | score | evidence |\n|---|---|---|\n' "$1"; for p in $2; do printf '| %s | 9 → 9 | [%s] fixture row | fx |\n' "${p#*:}" "${p%%:*}"; done; printf '\n'; }
A="$S/fxA"; fx "$A"; printf 'round\tclaim\taxis\n90\tC1\tcalibration\n' > "$A/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n\n## C2 — coverage: fixture claim two\n\ntext\n' > "$A/plans/round-90.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration C2:coverage"; } > "$A/SCORECARD.md"
B="$S/fxB"; fx "$B"; printf 'round\tclaim\taxis\n91\tC1\tcalibration\n' > "$B/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n' > "$B/plans/round-90.md"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n' > "$B/plans/round-91.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration"; post 91 "C1:calibration"; } > "$B/SCORECARD.md"
C="$S/fxC"; fx "$C"; printf 'round\tclaim\taxis\n90\tC1\tcalibration\n' > "$C/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — freshness: fixture claim one\n\ntext\n' > "$C/plans/round-90.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration"; } > "$C/SCORECARD.md"

run() { # run GATE -> rc
  ( cd "$S/tree" && sh "$1" --root "$2" ) >/dev/null 2>&1; echo $?
}

for thr in 39 45 90; do
  M="$S/gate-$thr.sh"
  sed "s/-lt 39 ]/-lt $thr ]/" "$GATE_SRC" > "$M"
  if ! grep -q -- "-lt $thr ]" "$M"; then echo "MUTANT-FAILED thr=$thr"; continue; fi
  ra=$(run "$M" "$A"); rb=$(run "$M" "$B"); rc=$(run "$M" "$C")
  real=$( cd "$S/tree" && sh "$M" --root "$S/tree" >/dev/null 2>&1; echo $? )
  det=0; [ "$ra" -eq 1 ] && det=$((det+1)); [ "$rb" -eq 1 ] && det=$((det+1))
  pos=0; [ "$rc" -eq 1 ] && pos=1
  val=0; if [ "$pos" -eq 1 ] && [ "$real" -eq 0 ]; then val=$det; fi
  echo "MUTANT thr=$thr => C1_BIJECTION value=$val detected=$det positive=$pos real=$([ "$real" -eq 0 ] && echo CLEAN || echo FAIL) (rc A=$ra B=$rb C=$rc)"
done

echo "--- scope probe: does the threshold-90 mutant still fire on a REAL-lane round (44) with a planted omission? ---"
D="$S/fxD"; fx "$D"
printf 'round\tclaim\taxis\n44\tC1\tcalibration\n' > "$D/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: planted omission\n\n## C2 — operability: planted omission\n\ntext\n' > "$D/plans/round-44.md"
{ printf '# fixture scorecard\n\n'; post 44 "C1:calibration C2:operability"; } > "$D/SCORECARD.md"
for thr in 39 90; do
  rd=$(run "$S/gate-$thr.sh" "$D")
  echo "MUTANT thr=$thr on planted omission at round 44 => rc=$rd ($( [ "$rd" -eq 1 ] && echo DETECTED || echo MISSED ))"
done
