#!/usr/bin/env bash
# K45Sentinel: scope-shrink on the CANDIDATE tree (072bb0b):
#   delete round 44's manifest rows AND its SCORECARD post-move section header,
#   leaving plans/round-44.md's three claim headings on disk.
#   Does the shipped gate still exit 0 (REAL=CLEAN)?
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-shrink2-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
CAND=072bb0bc1860fcc33418b659cec0dd40d5c0f944
CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
git -C "$CLONE" checkout --quiet "$CAND" || exit 2

run() { ( cd "$CLONE" && bash corpus/claims-declared.sh --root "$CLONE" ) 2>&1 | tail -2; }

echo "=== baseline (candidate tree) ==="; run
cp corpus/claims-declared.tsv "$S/m.bak"; cp SCORECARD.md "$S/s.bak"

echo "=== attack A: drop round-44 manifest rows only ==="
python3 - "$S/m.bak" <<'PY'
import sys, pathlib
m = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").splitlines(True)
pathlib.Path("corpus/claims-declared.tsv").write_text("".join(l for l in m if not l.startswith("44\t")), encoding="utf-8")
PY
run
cp "$S/m.bak" corpus/claims-declared.tsv

echo "=== attack B: drop round-44 manifest rows AND the round-44 post-move section ==="
python3 - "$S/m.bak" "$S/s.bak" <<'PY'
import sys, pathlib
m = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").splitlines(True)
pathlib.Path("corpus/claims-declared.tsv").write_text("".join(l for l in m if not l.startswith("44\t")), encoding="utf-8")
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
echo "  round-44 plan headings still on disk: $(grep -cE '^## C[0-9]+ — [a-z]+:' plans/round-44.md)"
echo "  round-44 manifest rows now: $(grep -c '^44' corpus/claims-declared.tsv || true)"
cp "$S/m.bak" corpus/claims-declared.tsv; cp "$S/s.bak" SCORECARD.md
echo "=== restored ==="; run
