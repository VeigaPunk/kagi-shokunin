#!/usr/bin/env python3
"""FAnchorZero independent falsification harness.

Own fixture construction (does NOT reuse .ufo/waves/round-28/tools/c1-measure.py)
for the derived-row S008 carrier on the SOPS feed S033.

Usage: harness.py <tree-root> <label>
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
LABEL = sys.argv[2]
WORK = TREE.parent / ("work-" + LABEL)
if WORK.exists():
    shutil.rmtree(WORK)
WORK.mkdir(parents=True)

RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"
CORPUS_FILES = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clocks.tsv")


def stage(name, table_edits=None, receipt_edits=None, sources=None):
    """Stage a fixture root: copy corpus + default receipt, apply edits."""
    root = WORK / name
    (root / "corpus").mkdir(parents=True)
    (root / RECEIPT_REL).parent.mkdir(parents=True, exist_ok=True)
    for rel in CORPUS_FILES:
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    if sources is not None:
        (root / "corpus" / "SOURCES.md").write_text(sources, encoding="utf-8")
    if table_edits:
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
        (root / "corpus" / "release-clocks.tsv").write_text(
            "".join(out), encoding="utf-8")
    receipt = json.loads((TREE / RECEIPT_REL).read_text(encoding="utf-8"))
    if receipt_edits:
        for record in receipt["observations"]:
            if record.get("id") in receipt_edits:
                for key, value in receipt_edits[record["id"]].items():
                    record[key] = value
    receipt_path = root / RECEIPT_REL
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return root, receipt_path


def run(root, receipt_path, extra=()):
    """Run the tree's own release-clock.py against the staged fixture root."""
    cmd = [sys.executable, "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
           "--root", str(root), "--receipt", str(receipt_path),
           "--receipt-sha", hashlib.sha256(receipt_path.read_bytes()).hexdigest()]
    cmd.extend(extra)
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return proc


def report(name, proc):
    print("=== %s ===" % name)
    print("cmd exit=%d" % proc.returncode)
    for line in proc.stdout.splitlines():
        print("  out: %s" % line)
    if proc.stderr.strip():
        for line in proc.stderr.splitlines():
            print("  err: %s" % line)
    if "Traceback" in (proc.stdout + proc.stderr):
        print("  !! TRACEBACK PRESENT")
    print()


# ---------------------------------------------------------------- control
control_root, control_receipt = stage("control")
report("control (unmodified tree)", run(control_root, control_receipt))

# ------------------------------------------- A: derived S008 anchor 3.13.03
# Anchored version carries a leading-zero component. observed + receipt are
# mirrored to the same token so that the ONLY possible finding is the
# canonicality rule -- no generic RECEIPT-MISMATCH may stand in for it.
a_root, a_receipt = stage(
    "a-anchor-3.13.03",
    table_edits={"S008": {4: "3.13.03", 5: "3.13.03"}},
    receipt_edits={"S008": {"parsed_version": "3.13.03", "verdict": "not-fired"}},
)
report("A derived S008 anchored=3.13.03 (table+receipt mirrored)",
       run(a_root, a_receipt))

# --------------------------- B: derived S008 observation 3.13.03 (fired lie)
# Anchored stays canonical 3.13.3; the observed version is the non-canonical
# token and the verdict claims fired. BASE must read this as a fired release.
b_root, b_receipt = stage(
    "b-observed-3.13.03",
    table_edits={"S008": {5: "3.13.03", 7: "fired"}},
    receipt_edits={"S008": {"parsed_version": "3.13.03", "verdict": "fired"}},
)
report("B derived S008 observed=3.13.03 verdict=fired (table+receipt mirrored)",
       run(b_root, b_receipt))

# ------------------- C: derived S008 anchor lowered to canonical 3.13.2 (C2)
# Control for the C2 binding rule on the same carrier: a canonical but
# unbound derived anchor.
c_root, c_receipt = stage(
    "c-anchor-3.13.2",
    table_edits={"S008": {4: "3.13.2", 5: "3.13.2"}},
    receipt_edits={"S008": {"parsed_version": "3.13.2", "verdict": "not-fired"}},
)
report("C derived S008 anchored=3.13.2 (canonical, unbound)",
       run(c_root, c_receipt))

# ----------------------- D: oversize component in the derived anchor
big = "1" * 4301
d_root, d_receipt = stage(
    "d-anchor-oversize",
    table_edits={"S008": {4: "3.13." + big, 5: "3.13." + big}},
    receipt_edits={"S008": {"parsed_version": "3.13." + big,
                            "verdict": "not-fired"}},
)
report("D derived S008 anchored=3.13.<4301 digits> (table+receipt mirrored)",
       run(d_root, d_receipt))
