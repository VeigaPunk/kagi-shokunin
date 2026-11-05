#!/usr/bin/env bash
# K45Sentinel adversarial demo (scratch only):
#   The CRUDEST C1 forgery: replace the candidate gate's whole plan-to-manifest block with
#   an unconditional MISMATCH for round 90 only. The frozen counter's fixtures are all
#   round 90/91, so the triple is identical to the honest gate's.
#   What refuses it: a fixture planted at a REAL landed round (44) and an independent
#   reference bijection over rounds 39..44.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-crude-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
GATE_SRC="$LANE/.ufo/waves/round-45/build/K45ExecBijection/claims-declared.sh"

python3 - "$GATE_SRC" "$S/gate-crude.sh" <<'PY'
import re, sys, pathlib
src = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
start = src.index("# Round-45 C1 plan-to-manifest direction (frozen predicate):")
end = src.index('if [ "$n" -eq 0 ]; then', start)
crude = ('# Round-45 C1 plan-to-manifest direction — FORGERY PROBE (fixture-round only).\n'
         'for planfile in "$root"/plans/round-*.md; do\n'
         '  [ -f "$planfile" ] || continue\n'
         '  fname=${planfile##*/}; rname=${fname#round-}; rname=${rname%.md}\n'
         '  if [ "$rname" = "90" ]; then\n'
         '    echo "MISMATCH $rname C1 no-manifest-row"\n'
         '    bad=$((bad + 1))\n'
         '  fi\n'
         'done\n')
pathlib.Path(sys.argv[2]).write_text(src[:start] + crude + src[end:], encoding="utf-8")
PY
M="$S/gate-crude.sh"
grep -q 'FORGERY PROBE' "$M" || { echo "MUTANT-BUILD-FAILED"; exit 2; }
sh -n "$M" && echo "syntax-ok"

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
D="$S/fxD"; fx "$D"; printf 'round\tclaim\taxis\n44\tC1\tcalibration\n' > "$D/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: planted omission\n\n## C2 — operability: planted omission\n\ntext\n' > "$D/plans/round-44.md"
{ printf '# fixture scorecard\n\n'; post 44 "C1:calibration C2:operability"; } > "$D/SCORECARD.md"

ra=$( sh "$M" --root "$A" >/dev/null 2>&1; echo $? )
rb=$( sh "$M" --root "$B" >/dev/null 2>&1; echo $? )
rc=$( sh "$M" --root "$C" >/dev/null 2>&1; echo $? )
rd=$( sh "$M" --root "$D" >/dev/null 2>&1; echo $? )
det=0; [ "$ra" -eq 1 ] && det=$((det+1)); [ "$rb" -eq 1 ] && det=$((det+1))
pos=0; [ "$rc" -eq 1 ] && pos=1
echo "CRUDE GATE frozen-counter-triple: detected=$det positive=$pos real=CLEAN-assumed (rc A=$ra B=$rb C=$rc)"
echo "CRUDE GATE real-round-44 fixture rc=$rd $( [ "$rd" -eq 1 ] && echo DETECTED || echo MISSED )"
