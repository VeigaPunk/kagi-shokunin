#!/usr/bin/env bash
# K45Sentinel: can C1's REAL leg be satisfied by editing the manifest or the post-move
# gating in the candidate? (sandbox clone only; the lane is never touched)
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-mut-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
GATE_SRC="$LANE/.ufo/waves/round-45/build/K45ExecBijection/claims-declared.sh"

CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
cp "$GATE_SRC" "$CLONE/corpus/claims-declared.sh"

run_gate() { ( cd "$CLONE" && sh corpus/claims-declared.sh --root "$CLONE" ) 2>&1; echo "rc=$?"; }

echo "=== baseline (honest candidate gate, real tree) ==="
run_gate | tail -3

echo "=== M1: delete the manifest row for round 44 C1 (a landed real claim) ==="
cp corpus/claims-declared.tsv "$S/manifest.bak"
grep -v '^44	C1	' "$S/manifest.bak" > corpus/claims-declared.tsv
run_gate | tail -3
cp "$S/manifest.bak" corpus/claims-declared.tsv

echo "=== M2: delete the SCORECARD post-move section header for round 44 ==="
cp SCORECARD.md "$S/score.bak"
sed 's/^## Round 44 — post-move/## Round 44 — post-move (moved)/' "$S/score.bak" > SCORECARD.md
run_gate | tail -3
cp "$S/score.bak" SCORECARD.md

echo "=== M3: BOTH -- delete manifest row 44/C1 AND rename the round-44 post-move header ==="
grep -v '^44	C1	' "$S/manifest.bak" > corpus/claims-declared.tsv
sed 's/^## Round 44 — post-move/## Round 44 — post-move (moved)/' "$S/score.bak" > SCORECARD.md
run_gate | tail -3
cp "$S/manifest.bak" corpus/claims-declared.tsv; cp "$S/score.bak" SCORECARD.md

echo "=== M4: delete the round-44 PLAN file (the plan heading source) ==="
cp plans/round-44.md "$S/plan.bak"; rm plans/round-44.md
run_gate | tail -3
cp "$S/plan.bak" plans/round-44.md

echo "=== M5: rename the round-44 plan heading so the plan-to-manifest direction cannot see it ==="
sed 's/^## C1 — calibration:/## Claim C1 — calibration:/' "$S/plan.bak" > plans/round-44.md
run_gate | tail -3
cp "$S/plan.bak" plans/round-44.md
