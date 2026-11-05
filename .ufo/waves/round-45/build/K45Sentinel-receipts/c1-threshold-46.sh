#!/usr/bin/env bash
# K45Sentinel: the cheapest C1 forgery, measured on the CANDIDATE tree.
#   A gate whose new direction is scoped to rounds >= 46 (or >= 90) never inspects the real
#   landed rounds 39..45, yet the FROZEN counter still reads value=2 (its fixtures live at
#   round 90/91 and the real tree stays CLEAN).
#   The refusing check: a planted-omission fixture at a REAL landed round.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-thr-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
GATE="$CLONE/corpus/claims-declared.sh"

sed "s|^LANE=.*|LANE=$CLONE|" "$LANE/plans/round-45-c1.sh" > "$S/c1.sh"

plant() { # plant ROUND
  local r="$1" D="$S/fx$r"
  rm -rf "$D"; mkdir -p "$D/corpus" "$D/plans"
  printf 'round\tclaim\taxis\n%s\tC1\tcalibration\n' "$r" > "$D/corpus/claims-declared.tsv"
  printf '## C1 — calibration: planted omission\n\n## C2 — operability: planted omission\n\ntext\n' > "$D/plans/round-$r.md"
  printf '## Round %s — post-move\n\n| axis | score | evidence |\n|---|---|---|\n| calibration | 9 → 9 | [C1] fixture row | fx |\n| operability | 9 → 9 | [C2] fixture row | fx |\n' "$r" > "$D/SCORECARD.md"
  printf '%s' "$D"
}

for thr in 39 46 90; do
  sed -E "s/-lt [0-9]+ ]/-lt $thr ]/" "$GATE" > "$GATE.new" && mv "$GATE.new" "$GATE"
  line=$(grep -n -- "-lt $thr ]" "$GATE" | head -1 | cut -c1-70)
  echo "GATE scope thr=$thr  [$line]"
  for r in 39 44 45; do
    D=$(plant "$r")
    ( cd "$CLONE" && bash corpus/claims-declared.sh --root "$D" ) >/dev/null 2>&1
    rc=$?
    printf '   planted omission at REAL round %s -> rc=%s %s\n' "$r" "$rc" "$( [ "$rc" -eq 1 ] && echo DETECTED || echo MISSED )"
  done
done
