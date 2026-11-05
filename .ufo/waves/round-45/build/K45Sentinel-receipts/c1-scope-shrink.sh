#!/usr/bin/env bash
# K45Sentinel: can C1's REAL leg be made CLEAN by editing the registry surfaces
# (manifest rows + SCORECARD post-move header) so a landed real round leaves the check,
# while the gate script itself is untouched?
# (sandbox clone only; the lane is never touched)
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-shrink-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
cp "$LANE/corpus/claims-declared.sh" corpus/claims-declared.sh

run() { ( cd "$CLONE" && bash corpus/claims-declared.sh --root "$CLONE" ) 2>&1 | tail -3; }

echo "=== baseline (candidate gate, lane state) ==="; run

cp corpus/claims-declared.tsv "$S/m.bak"; cp SCORECARD.md "$S/s.bak"

echo "=== attack: drop the round-44 manifest rows AND the round-44 post-move header ==="
python3 - "$S/m.bak" "$S/s.bak" <<'PY'
import sys, pathlib
m = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").splitlines(True)
pathlib.Path("corpus/claims-declared.tsv").write_text(
    "".join(l for l in m if not l.startswith("44\t")), encoding="utf-8")
s = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8").splitlines(True)
out, skip = [], False
for line in s:
    if line.startswith("## Round 44 — post-move"):
        skip = True; continue
    if skip and line.startswith("## "):
        skip = False
    if not skip:
        out.append(line)
pathlib.Path("SCORECARD.md").write_text("".join(out), encoding="utf-8")
PY
run
echo "--- round-44 plan headings still on disk (the landed claim text): ---"
grep -cE '^## C[0-9]+ — [a-z]+:' plans/round-44.md
echo "--- round-44 manifest rows now: ---"
grep -c '^44' corpus/claims-declared.tsv || true
cp "$S/m.bak" corpus/claims-declared.tsv; cp "$S/s.bak" SCORECARD.md
echo "=== restored ==="; run
