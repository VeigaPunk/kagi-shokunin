#!/usr/bin/env bash
# K45Sentinel adversarial demo (scratch only):
#   The cheapest C1 forgery: a candidate gate whose new direction fires ONLY for the
#   counter's synthetic rounds (>= 90). The frozen counter's DETECTED/POSITIVE/REAL
#   triple cannot see it, because fixtures A/B/C are all round 90/91 and the real
#   landed rounds are 39..44.
#   What refuses it: a fixture planted at a REAL round (e.g. 44) plus an independent
#   reference bijection over the real rounds.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-fixture-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
GATE_SRC="$LANE/.ufo/waves/round-45/build/K45ExecBijection/claims-declared.sh"

# MUTANT 1: fixture-aware gate — reports MISMATCH for any round >= 90 only.
M1="$S/gate-fixture-aware.sh"
sed 's/-lt 39 ]/-lt 90 ]/' "$GATE_SRC" > "$M1"

# MUTANT 2: hardcoded round-90 special case (the crudest forgery).
M2="$S/gate-hardcoded.sh"
python3 - "$GATE_SRC" "$M2" <<'PY'
import sys, pathlib
src = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
anchor = '# Round-45 C1 plan-to-manifest direction (frozen predicate): a round R >= 39 is'
inject = ('# FORGERY PROBE: unconditional MISMATCH for the counter fixture round.\n'
          'if [ "$rname" = "90" ] || [ "$rname" = "91" ]; then\n'
          '  echo "MISMATCH $rname C1 no-manifest-row"\n'
          '  bad=$((bad + 1))\n'
          'fi\n')
src = src.replace(anchor, inject + anchor, 1)
pathlib.Path(sys.argv[2]).write_text(src, encoding="utf-8")
PY
grep -q 'FORGERY PROBE' "$M2" || { echo "MUTANT2-BUILD-FAILED"; exit 2; }

# build the frozen fixtures + a REAL-round fixture, exactly as plans/round-45-c1.sh does
fx() { mkdir -p "$1/corpus" "$1/plans"; }
post() { printf '## Round %s — post-move\n\n| axis | score | evidence |\n|---|---|---|\n' "$1"; for p in $2; do printf '| %s | 9 → 9 | [%s] fixture row | fx |\n' "${p#*:}" "${p%%:*}"; done; printf '\n'; }
A="$S/fxA"; fx "$A"; printf 'round\tclaim\taxis\n90\tC1\tcalibration\n' > "$A/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n\n## C2 — coverage: fixture claim two\n\ntext\n' > "$A/plans/round-90.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration C2:coverage"; } > "$A/SCORECARD.md"
B="$S/fxB"; fx "$B"; printf 'round\tclaim\texis\n91\tC1\tcalibration\n' > "$B/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n' > "$B/plans/round-90.md"
printf '# fixture\n\n## C1 — calibration: fixture claim one\n\ntext\n' > "$B/plans/round-91.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration"; post 91 "C1:calibration"; } > "$B/SCORECARD.md"
C="$S/fxC"; fx "$C"; printf 'round\tclaim\taxis\n90\tC1\tcalibration\n' > "$C/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — freshness: fixture claim one\n\ntext\n' > "$C/plans/round-90.md"
{ printf '# fixture scorecard\n\n'; post 90 "C1:calibration"; } > "$C/SCORECARD.md"
# REAL-round fixture: round 44, one claim missing from the manifest
D="$S/fxD"; fx "$D"; printf 'round\tclaim\taxis\n44\tC1\tcalibration\n' > "$D/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — calibration: planted omission\n\n## C2 — operability: planted omission\n\ntext\n' > "$D/plans/round-44.md"
{ printf '# fixture scorecard\n\n'; post 44 "C1:calibration C2:operability"; } > "$D/SCORECARD.md"

for m in "$GATE_SRC" "$M1" "$M2"; do
  name=$(basename "$m")
  ra=$( sh "$m" --root "$A" >/dev/null 2>&1; echo $? )
  rb=$( sh "$m" --root "$B" >/dev/null 2>&1; echo $? )
  rc=$( sh "$m" --root "$C" >/dev/null 2>&1; echo $? )
  rd=$( sh "$m" --root "$D" >/dev/null 2>&1; echo $? )
  det=0; [ "$ra" -eq 1 ] && det=$((det+1)); [ "$rb" -eq 1 ] && det=$((det+1))
  pos=0; [ "$rc" -eq 1 ] && pos=1
  echo "GATE=$name  frozen-counter-triple: detected=$det positive=$pos (rc A=$ra B=$rb C=$rc)  |  real-round-44 fixture rc=$rd $( [ "$rd" -eq 1 ] && echo DETECTED || echo MISSED )"
done
