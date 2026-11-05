#!/usr/bin/env bash
# K45Sentinel: can C1's REAL leg be made CLEAN by editing the manifest and the
# post-move gating in the candidate, instead of by fixing the instrument?
# (sandbox clone only; lane untouched)
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-game-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
GATE_SRC="$LANE/.ufo/waves/round-45/build/K45ExecBijection/claims-declared.sh"

CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
cp "$GATE_SRC" "$CLONE/corpus/claims-declared.sh"

# M2-style mutant: post-move gating removed (in-flight round 45 gets checked).
M2="$S/gate-m2.sh"
python3 - "$GATE_SRC" "$M2" <<'PY'
import sys, pathlib
s = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
old = '''  if ! awk -v want="## Round $rname — post-move" 'index($0, want) == 1 { found = 1 } END { exit found ? 0 : 1 }' "$root/SCORECARD.md" 2>/dev/null; then
    continue
  fi
'''
assert old in s, "anchor not found"
s = s.replace(old, "  # M2 MUTANT: post-move requirement removed\n", 1)
pathlib.Path(sys.argv[2]).write_text(s, encoding="utf-8")
PY
grep -q 'M2 MUTANT' "$M2" || { echo "M2-BUILD-FAILED"; exit 2; }

run() { ( cd "$CLONE" && sh "$1" --root "$CLONE" ) 2>&1 | tail -4; echo "rc=${PIPESTATUS[0]}"; }

echo "=== honest candidate gate on the real tree ==="
run corpus/claims-declared.sh
echo "=== M2 mutant (post-move gating removed) on the real tree ==="
cp "$M2" corpus/claims-declared.sh; run corpus/claims-declared.sh; cp "$GATE_SRC" corpus/claims-declared.sh

cp corpus/claims-declared.tsv "$S/m.bak"; cp SCORECARD.md "$S/s.bak"

echo "=== M2 mutant + candidate EDITS the manifest and the post-move gating (round 45 made 'landed') ==="
cp "$M2" corpus/claims-declared.sh
printf '45\tC1\tcalibration\n45\tC2\tcoverage\n' >> corpus/claims-declared.tsv
cat >> SCORECARD.md <<'EOF'

## Round 45 — post-move (fabricated to satisfy the gate)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] fabricated row | R45-01 |
| coverage | 9 → 9 | [C2] fabricated row | R45-02 |
EOF
run corpus/claims-declared.sh
cp "$S/m.bak" corpus/claims-declared.tsv; cp "$S/s.bak" SCORECARD.md; cp "$GATE_SRC" corpus/claims-declared.sh
echo "=== restored ==="
run corpus/claims-declared.sh
