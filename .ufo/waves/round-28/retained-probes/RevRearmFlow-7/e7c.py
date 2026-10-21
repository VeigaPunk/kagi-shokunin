#!/usr/bin/env python3
"""E7c: clean successor-shape experiment (correct SOURCES.md column indices).

Keeps the four predecessor derived rows exactly as BASE has them, and adds:
  - a new feed registry row naming the new stable release (v3.14.0),
  - a successor registry source row (on-release) + its clock row,
  - a matching receipt record for the successor.
Everything else is BASE. Expected: the four predecessors become REGRESSED
because the successor raises the feed floor.
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
DEST = HERE / "ce" / "e7c"
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"

if DEST.exists():
    shutil.rmtree(DEST)
shutil.copytree(BASE, DEST)

# split() of a full '| ... |' line: index = parser index + 1
ID, SOURCE, KIND, TIER, SCOPE, ANCHOR, TEACHES, STATUS, OPENED, RECHECK, USED = range(1, 12)

sp = DEST / "corpus" / "SOURCES.md"
lines = sp.read_text(encoding="utf-8").splitlines()
s033 = [l for l in lines if l.startswith("| S033 ")][0]
s009 = [l for l in lines if l.startswith("| S009 ")][0]

c = s033.split("|")
c[ID] = " S045 "
c[TIER] = "A"
c[SCOPE] = "SOPS release identity (newest stable X.Y.Z tag) for the rearmed clocks of S008-S011"
c[ANCHOR] = "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-02T05:29:11Z; feed fetched 2026-10-22"
c[TEACHES] = ("Newest stable SOPS is v3.14.0; S033 remains the historical v3.13.3 observation. "
               "Quote: “<title>v3.14.0</title>” (first stable entry).")
c[OPENED] = "2026-10-22"
c[RECHECK] = "90d"
c[USED] = "corpus/lessons/round-29.md "

d = s009.split("|")
d[ID] = " S044 "
d[ANCHOR] = "§Encrypting using age; last modified 2026-10-22, docs commit 1111111; successor to S009"
d[TEACHES] = "supersedes S009 — teaching unchanged; the clock is rearmed at the newest stable SOPS release 3.14.0"
d[OPENED] = "2026-10-22"
d[RECHECK] = "on-release"
d[USED] = "corpus/lessons/round-29.md "

sp.write_text("\n".join(lines + ["|".join(c), "|".join(d)]) + "\n", encoding="utf-8")

tp = DEST / "corpus" / "release-clocks.tsv"
tl = tp.read_text(encoding="utf-8").splitlines()
row = "\t".join((
    "S044", "feed", "S045", "https://github.com/getsops/sops/releases.atom",
    "3.14.0", "3.14.0", "2026-10-22", "not-fired",
    "derived: successor to S009; newest stable SOPS tag when the row was opened 2026-10-22 (v3.14.0)"))
tp.write_text("\n".join(tl + [row]) + "\n", encoding="utf-8")

path = DEST / RECEIPT_REL
doc = json.loads(path.read_text(encoding="utf-8"))
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
print("### E7c successor shape, predecessors KEPT exactly as BASE (new feed row S045 names v3.14.0)")
print(p.stdout + p.stderr)
print("(exit %d)" % p.returncode)
