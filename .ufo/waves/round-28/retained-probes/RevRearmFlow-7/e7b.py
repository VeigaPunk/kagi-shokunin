#!/usr/bin/env python3
"""E7b: the FULL C2-clean successor shape for a derived feed.

Adds (a) a new feed registry row naming v3.14.0, (b) a successor clock row
bound to it, and (c) a forged receipt record for the successor, while keeping
the four predecessor derived rows exactly as BASE has them. Question: does the
round-26 'keep predecessor, add successor' rearm shape survive the round-27
feed floor?
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
DEST = HERE / "ce" / "e7b"
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"

if DEST.exists():
    shutil.rmtree(DEST)
shutil.copytree(BASE, DEST)

# (a) new feed registry row S045 naming the new stable SOPS release
sp = DEST / "corpus" / "SOURCES.md"
text = sp.read_text(encoding="utf-8")
s033 = [l for l in text.splitlines() if l.startswith("| S033 ")][0]
cells = s033.split("|")
cells[1] = " S045 "
cells[3] = "A"
cells[4] = "SOPS release identity (newest stable X.Y.Z tag) for the rearmed clocks of S008-S011"
cells[5] = "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-02T05:29:11Z; feed fetched 2026-10-22"
cells[6] = ("Newest stable SOPS is v3.14.0; S033 remains the historical v3.13.3 observation. "
            "Quote: “<title>v3.14.0</title>” (first stable entry).")
cells[8] = "2026-10-22"
cells[9] = "90d"
cells[10] = "corpus/lessons/round-29.md "
sp.write_text(text + "|".join(cells) + "\n", encoding="utf-8")

# (b) successor clock rows S044 (registry source) + S045-bound clock row
sp2 = DEST / "corpus" / "SOURCES.md"
text2 = sp2.read_text(encoding="utf-8")
s009 = [l for l in text2.splitlines() if l.startswith("| S009 ")][0]
c2 = s009.split("|")
c2[1] = " S044 "
c2[5] = "§Encrypting using age; last modified 2026-10-22, docs commit 1111111; successor to S009"
c2[6] = "supersedes S009 — teaching unchanged; clock rearmed at the newest stable SOPS release 3.14.0"
c2[8] = "2026-10-22"
c2[9] = "on-release"
c2[10] = "corpus/lessons/round-29.md "
sp2.write_text(text2 + "|".join(c2) + "\n", encoding="utf-8")

tp = DEST / "corpus" / "release-clocks.tsv"
lines = tp.read_text(encoding="utf-8").splitlines()
row = "\t".join((
    "S044", "feed", "S045", "https://github.com/getsops/sops/releases.atom",
    "3.14.0", "3.14.0", "2026-10-22", "not-fired",
    "derived: successor to S009; newest stable SOPS tag when the row was opened 2026-10-22 (v3.14.0)"))
tp.write_text("\n".join(lines + [row]) + "\n", encoding="utf-8")

# (c) forge the receipt: add an S044 record and bump the four predecessors' observation
path = DEST / RECEIPT_REL
doc = json.loads(path.read_text(encoding="utf-8"))
for rec in doc["observations"]:
    if rec["id"] in ("S008", "S009", "S010", "S011"):
        rec["parsed_version"] = "3.14.0"
        rec["verdict"] = "not-fired"
        rec["observed_at"] = "2026-10-22T09:00:00Z"
doc["observations"].append({
    "clock": "feed", "http_status": 200, "id": "S044", "located": None,
    "observed_at": "2026-10-22T09:00:00Z", "parsed_version": "3.14.0",
    "sha256": "0" * 64, "url": "https://github.com/getsops/sops/releases.atom",
    "verdict": "not-fired",
})
raw = json.dumps(doc, indent=2, sort_keys=True).encode("utf-8")
out = DEST / "ce-receipt.json"
out.write_bytes(raw)
sha = hashlib.sha256(raw).hexdigest()

argv = [sys.executable, "-I", "-B", "corpus/release-clock.py", "--root", str(DEST),
        "--receipt", str(out), "--receipt-sha", sha]
p = subprocess.run(argv, capture_output=True, text=True, cwd=DEST)
print("### E7b full C2-clean successor shape (new feed row S045 + successor S044), predecessors KEPT")
print(p.stdout + p.stderr)
print("(exit %d)" % p.returncode)

# and the same tree with the four predecessors also advanced to 3.14.0 (in place)
tp = DEST / "corpus" / "release-clocks.tsv"
txt = tp.read_text(encoding="utf-8")
out_lines = []
for line in txt.splitlines():
    f = line.split("\t")
    if f[0] in ("S008", "S009", "S010", "S011"):
        f[4] = "3.14.0"
        f[5] = "3.14.0"
        f[6] = "2026-10-22"
        f[7] = "not-fired"
        f[8] = "derived: anchor names the main snapshot, no release; newest stable SOPS tag when the row was opened 2026-10-22 (v3.14.0)"
        line = "\t".join(f)
    out_lines.append(line)
tp.write_text("\n".join(out_lines) + "\n", encoding="utf-8")
p = subprocess.run(argv, capture_output=True, text=True, cwd=DEST)
print("### E7b' same tree, predecessors advanced IN PLACE to 3.14.0")
print(p.stdout + p.stderr)
print("(exit %d)" % p.returncode)
