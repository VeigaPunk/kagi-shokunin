#!/usr/bin/env python3
"""FAnchorZero fixture runner (absolute paths only).

Usage: fixtures.py <tree-root> <label>
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
LABEL = sys.argv[2]
WORK = TREE.parent / ("fx-" + LABEL)
if WORK.exists():
    shutil.rmtree(WORK)
WORK.mkdir(parents=True)

RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"
S033_DERIVED = ("S008", "S009", "S010", "S011")


def build(name, table_edits, receipt_edits):
    root = WORK / name
    (root / "corpus").mkdir(parents=True)
    (root / RECEIPT_REL).parent.mkdir(parents=True, exist_ok=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clocks.tsv"):
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    lines = (root / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in table_edits:
            for index, value in table_edits[fields[0]].items():
                fields[index] = value
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    (root / "corpus" / "release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    receipt = json.loads((TREE / RECEIPT_REL).read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record.get("id") in receipt_edits:
            for key, value in receipt_edits[record["id"]].items():
                record[key] = value
    receipt_path = (root / RECEIPT_REL).resolve()
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return root, receipt_path


def run(name, root, receipt_path):
    cmd = [sys.executable, "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
           "--root", str(root), "--receipt", str(receipt_path),
           "--receipt-sha", hashlib.sha256(receipt_path.read_bytes()).hexdigest()]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    print("=== %s [%s] exit=%d ===" % (name, LABEL, proc.returncode))
    for line in proc.stdout.splitlines():
        print("  out: %s" % line)
    if proc.stderr.strip():
        for line in proc.stderr.splitlines()[:4]:
            print("  err: %s" % line)
    if "Traceback" in (proc.stdout + proc.stderr):
        print("  !! TRACEBACK")
    print()


# control
root, rec = build("control", {}, {})
run("control (unmodified tree)", root, rec)

# A: derived S008 anchor 3.13.03, observation mirrored, receipt mirrored
root, rec = build("A", {"S008": {4: "3.13.03", 5: "3.13.03"}},
                  {"S008": {"parsed_version": "3.13.03", "verdict": "not-fired"}})
run("A derived S008 anchored=3.13.03 (table+receipt mirrored)", root, rec)

# A2: derived S008 anchor 3.13.03 only; observation and receipt left verbatim
root, rec = build("A2", {"S008": {4: "3.13.03"}}, {})
run("A2 derived S008 anchored=3.13.03, observation+receipt verbatim", root, rec)

# B: derived S008 observation 3.13.03 with verdict fired (table+receipt mirrored)
root, rec = build("B", {"S008": {5: "3.13.03", 7: "fired"}},
                  {"S008": {"parsed_version": "3.13.03", "verdict": "fired"}})
run("B derived S008 observed=3.13.03 verdict=fired (table+receipt mirrored)",
    root, rec)

# D: derived S008 anchor with a 4301-digit patch component
big = "1" * 4301
root, rec = build("D", {"S008": {4: "3.13." + big, 5: "3.13." + big}},
                  {"S008": {"parsed_version": "3.13." + big, "verdict": "not-fired"}})
run("D derived S008 anchored=3.13.<4301 digits> (table+receipt mirrored)", root, rec)

# G1: the plan's C2 group shape for S033's feed -- every derived anchor on that
# feed lowered to one lower canonical version, observation set equal.
group_table = {}
group_receipt = {}
for row in S033_DERIVED:
    group_table[row] = {4: "3.13.2", 5: "3.13.2", 7: "not-fired"}
    group_receipt[row] = {"parsed_version": "3.13.2", "verdict": "not-fired"}
root, rec = build("G1", group_table, group_receipt)
run("G1 S033 derived group lowered to 3.13.2 (plan C2 group shape)", root, rec)

# G2: the same group shape, but lowered to a non-canonical 3.13.02
group_table = {}
group_receipt = {}
for row in S033_DERIVED:
    group_table[row] = {4: "3.13.02", 5: "3.13.02", 7: "not-fired"}
    group_receipt[row] = {"parsed_version": "3.13.02", "verdict": "not-fired"}
root, rec = build("G2", group_table, group_receipt)
run("G2 S033 derived group lowered to 3.13.02 (non-canonical group)", root, rec)
