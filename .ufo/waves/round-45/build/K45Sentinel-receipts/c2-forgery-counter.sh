#!/usr/bin/env bash
# K45Sentinel: run the FROZEN C2 counter (plans/round-45-c2.sh, byte-identical except the
# LANE= line repointed at a scratch clone) against a tree where the seat WROTE ITS OWN
# capture bodies (quote pasted in), with no live fetch at all.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c2-forge-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
CAND=072bb0bc1860fcc33418b659cec0dd40d5c0f944
CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
git -C "$CLONE" checkout --quiet "$CAND" || exit 2

# 1) remove the candidate's real C2 rows and bodies
git -C "$CLONE" rm -q --cached .ufo/waves/round-45/controls/capture-r45/S100.raw .ufo/waves/round-45/controls/capture-r45/S101.raw .ufo/waves/round-45/controls/capture-r45/S102.raw >/dev/null 2>&1
rm -f .ufo/waves/round-45/controls/capture-r45/S10*.raw
git -C "$CLONE" rm -q corpus/knowledge/iso-11770-3-edition-status.md >/dev/null 2>&1
python3 - <<'PY'
import pathlib, re
# drop the S100-S102 registry rows, the three quote-bodies rows, the three fetch rows
for path, drop in (("corpus/SOURCES.md", r"^\| S10[0-2] \|"),
                   ("corpus/quote-bodies.tsv", r"^S10[0-2]\t"),
                   ("corpus/source-fetches.tsv", r"^S10[0-2]\t")):
    p = pathlib.Path(path)
    out = [l for l in p.read_text(encoding="utf-8").splitlines(True) if not re.match(drop, l)]
    p.write_text("".join(out), encoding="utf-8")
# drop the round-45 manifest rows so the candidate's C1 direction does not fire
p = pathlib.Path("corpus/claims-declared.tsv")
p.write_text("".join(l for l in p.read_text(encoding="utf-8").splitlines(True) if not l.startswith("45\t")), encoding="utf-8")
PY
# 2) the seat writes its own captures: body = the quote text only, plus a matching fetch row
mkdir -p .ufo/waves/round-45/controls/capture-r45 corpus/knowledge
python3 - <<'PY'
import hashlib, pathlib, re
root = pathlib.Path(".")
cap = root/".ufo/waves/round-45/controls/capture-r45"
rows = [("S100", "ISO/IEC 11770-3:2015/AMD1:2017", "https://webstore.iec.ch/en/publication/62160"),
        ("S101", "Withdrawal of International Standard", "https://www.iso.org/standard/60237.html"),
        ("S102", "ISO/IEC 11770-3:2021", "https://webstore.iec.ch/en/publication/71650")]
fetch_lines, qb_lines = [], []
for sid, quote, url in rows:
    body = cap/(sid + ".raw")
    body.write_text(quote, encoding="utf-8")           # the seat PASTES the quote in
    data = body.read_bytes()
    sha = hashlib.sha256(data).hexdigest()
    ident = hashlib.sha256(f"{sid}\tmined\t{url}\n".encode()).hexdigest()
    fetch_lines.append("\t".join([sid, "mined", ident, url, url, "200", "curl-fsSL-compressed-v1",
        "2026-11-05", "decoded-http-body-v1", sha, str(len(data)), "-", quote,
        "raw-literal-v1", "-", f".ufo/waves/round-45/controls/capture-r45/{sid}.raw"]) + "\n")
    qb_lines.append(f"{sid}\t.ufo/waves/round-45/controls/capture-r45/{sid}.raw\t0\t{quote}\n")
    rp = root/"corpus/SOURCES.md"
    lines = rp.read_text(encoding="utf-8").splitlines(True)
    out, done = [], False
    for l in lines:
        out.append(l)
        if not done and l.startswith("|---|"):
            out.append(f"| {sid} | self-written capture — {url} | docs | A | scope | anchor | {quote} | mined | 2026-11-05 | 180d | corpus/knowledge/iso-forged.md |\n")
            done = True
    rp.write_text("".join(out), encoding="utf-8")
with (root/"corpus/source-fetches.tsv").open("a", encoding="utf-8") as fh: fh.write("".join(fetch_lines))
with (root/"corpus/quote-bodies.tsv").open("a", encoding="utf-8") as fh: fh.write("".join(qb_lines))
(root/"corpus/knowledge/iso-forged.md").write_text(
    "source: S100 — https://webstore.iec.ch/en/publication/62160 — the title block — fetched 2026-11-05\n"
    "verified-at: 2026-11-05\n\n# forged entry\n\nThe title is ISO/IEC 11770-3:2015/AMD1:2017 [S100]\n", encoding="utf-8")
PY

git -C "$CLONE" add -A >/dev/null 2>&1
git -C "$CLONE" -c user.name=s -c user.email=s@invalid commit --quiet -m "forged self-written captures" >/dev/null 2>&1
REV=$(git -C "$CLONE" rev-parse HEAD)

sed "s|^LANE=.*|LANE=$CLONE|" "$LANE/plans/round-45-c2.sh" > "$S/c2.sh"
echo "counter-copy differs from frozen only in the LANE= line: $(diff "$LANE/plans/round-45-c2.sh" "$S/c2.sh" | grep -c '^[<>]') lines"
echo "=== FROZEN C2 COUNTER on the forged tree (no live fetch was performed for S100/S101/S102) ==="
HYAKU_SCRATCH=/fast/scratch/hyaku bash "$S/c2.sh" "$REV" 2>&1 | tail -2
