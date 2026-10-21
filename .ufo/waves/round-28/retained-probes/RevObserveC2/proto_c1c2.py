#!/usr/bin/env python3
"""C1 x C2 interaction on the registry anchor cell (in-flight implementation).

Q1  table anchor canonical "3.13.3", registry cell names "v3.13.03"
    -> C1 does not scan the registry cell (release-clock.py:617 checks the
       TABLE's anchored/observed only); C2's set equality refuses the row
       because "3.13.03" != "3.13.3".  Typed?
Q2  table anchor "3.13.03" (non-canonical) and registry cell "v3.13.03"
    -> C1's NON-CANONICAL fires on the table.  Typed?
Q3  table anchor "3.13.3", registry cell "v3.13.3"  (today)
    -> clean.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "c1c2"
INFLIGHT = SANDBOX / "inflight-release-clock.py"

GROUP = ("S008", "S009", "S010", "S011")


def build():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    root = WORK / "tree"
    shutil.copytree(SANDBOX / "base", root)
    shutil.copy2(INFLIGHT, root / "corpus/release-clock.py")
    return root


def stage(vroot, tag, table_edits, receipt_edits, cell):
    root = WORK / ("fx-" + tag)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clock.py", "release-clocks.tsv"):
        shutil.copy2(vroot / "corpus" / rel, root / "corpus" / rel)
    lines = (vroot / "corpus/release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in table_edits:
            a, o, v = table_edits[f[0]]
            f[4], f[5], f[7] = a, o, v
            line = "\t".join(f) + "\n"
        out.append(line)
    (root / "corpus/release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    text = (root / "corpus/SOURCES.md").read_text(encoding="utf-8")
    old = "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z"
    assert old in text
    text = text.replace(old, cell, 1)
    (root / "corpus/SOURCES.md").write_text(text, encoding="utf-8")
    receipt = json.loads((vroot / ".ufo/waves/round-26/observe-2.json").read_text())
    for rec in receipt["observations"]:
        if rec["id"] in receipt_edits:
            rec["parsed_version"], rec["verdict"] = receipt_edits[rec["id"]]
    rp = root / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    return root, rp, sha


def run(root, rp, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120)


def main():
    root = build()
    cases = [
        ("Q1", "3.13.3", "Entry titled v3.13.03, tag link /releases/tag/v3.13.03, updated 2026-07-23T05:29:11Z"),
        ("Q2", "3.13.03", "Entry titled v3.13.03, tag link /releases/tag/v3.13.03, updated 2026-07-23T05:29:11Z"),
        ("Q3", "3.13.3", "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z"),
    ]
    for label, anchor, cell in cases:
        te = {r: (anchor, anchor, "not-fired") for r in GROUP}
        re_ = {r: (anchor, "not-fired") for r in GROUP}
        fx, rp, sha = stage(root, label, te, re_, cell)
        proc = run(fx, rp, sha)
        lines = [l for l in proc.stdout.splitlines() if l.strip()]
        findings = sorted({l.split()[0] for l in lines if not l.startswith("RELEASE_CLOCK:")})
        print("%s table_anchor=%-9s exit=%d finding_categories=%s" % (
            label, anchor, proc.returncode, findings or "[]"))


if __name__ == "__main__":
    main()
