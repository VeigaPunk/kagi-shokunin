#!/usr/bin/env bash
# K45Sentinel: can C1's REAL leg be made CLEAN by editing the manifest AND the post-move
# gating, so that a landed real round stops being checked at all?
# (sandbox clone only; the lane is never touched)
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-del-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
cp "$LANE/corpus/claims-declared.sh" corpus/claims-declared.sh

run() { ( cd "$CLONE" && bash corpus/claims-declared.sh --root "$CLONE" ) 2>&1 | tail -4; }

echo "=== baseline ==="; run

echo "=== A: plant a REAL omission (round 44 plan heading C2 axis changed to 'freshness' so it no"
echo "    longer matches the manifest row '44 C2 operability') -> does the gate notice? ==="
cp plans/round-44.md "$S/plan44.bak"
sed -i 's/^## C2 — operability:/## C2 — freshness:/' plans/round-44.md
run
cp "$S/plan44.bak" plans/round-44.md

echo "=== B: the candidate DELETES the round-44 manifest rows AND the round-44 post-move header ==="
cp corpus/claims-declared.tsv "$S/m.bak"; cp SCORECARD.md "$S/s.bak"
grep -vE '^44\t' "$S/m.bak" > corpus/claims-declared.tsv
python3 - "$S/s.bak" <<'PY'
import sys, pathlib, re
p = pathlib.Path(sys.argv[1]); out=[]
skip=False
for line in p.read_text(encoding="utf-8").splitlines(True):
    if line.startswith("## Round 44 — post-move"):
        skip=True; continue
    if skip and line.startswith("## "):
        skip=False
    if not skip:
        out.append(line)
pathlib.Path("SCORECARD.md").write_text("".join(out), encoding="utf-8")
PY
run
echo "--- and the round-44 plan headings are still on disk and still claim two claims: ---"
grep -cE '^## C[0-9]+ — [a-z]+:' plans/round-44.md
cp "$S/m.bak" corpus/claims-declared.tsv; cp "$S/s.bak" SCORECARD.md

echo "=== restored ==="; run
