#!/usr/bin/env python3
"""Build a release-clock fixture tree: S040 observed_version = 3.15.<N digits>, verdict fired.

Usage: mkfixture.py <src-tree> <dst-tree> <digits> <mirror|plain>
Mirrors the edited row into a copy of the default receipt (mirror) or leaves the
receipt untouched (plain, so the run also shows the receipt-mismatch variant).
"""
import hashlib
import json
import shutil
import sys
from pathlib import Path

src, dst, digits, mode = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
src, dst = Path(src), Path(dst)
if dst.exists():
    shutil.rmtree(dst)
shutil.copytree(src, dst)

token = "3.15." + "1" * digits
tsv = dst / "corpus" / "release-clocks.tsv"
lines = tsv.read_text(encoding="utf-8").splitlines()
out = []
for line in lines:
    if line.startswith("S040\t"):
        f = line.split("\t")
        assert f[4] == "3.15.1" and f[7] == "not-fired", f
        f[5] = token
        f[7] = "fired"
        line = "\t".join(f)
    out.append(line)
tsv.write_text("\n".join(out) + "\n", encoding="utf-8")

receipt_src = dst / ".ufo" / "waves" / "round-26" / "observe-2.json"
doc = json.loads(receipt_src.read_text(encoding="utf-8"))
if mode == "mirror":
    for rec in doc["observations"]:
        if rec["id"] == "S040":
            rec["parsed_version"] = token
            rec["verdict"] = "fired"
receipt_copy = dst / ("receipt-%s.json" % mode)
receipt_copy.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8")
sha = hashlib.sha256(receipt_copy.read_bytes()).hexdigest()
print("%s %s %s" % (receipt_copy.relative_to(dst), sha, len(token.split(".")[2])))
