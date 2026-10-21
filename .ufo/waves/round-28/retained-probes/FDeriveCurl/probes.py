#!/usr/bin/env python3
"""Binding probes for round-28 C2 on the curl carrier (S029 / feed S037).

P1: rewrite S037's located anchor cell to name a different single stable token
    and lower S029 to exactly that token -> if the rule really reads the pinned
    registry cell, the clock must be CLEAN (no hardcoded version).
P2: drop the "derived:" prefix from S029's note (same lowering) -> the C2 check
    is skipped, but the row's own registry cell (S029, names 8.23.1) must reject
    the anchor: expect a typed INCONSISTENT, never silence.
P3: give S037's cell two stable tokens -> a cell naming two versions binds none.
P4: lower S029 to 8.23.1 (the man-page / dev label) -> expect DERIVATION.
All offline (--receipt only). No lane file is touched.
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

SB = Path(__file__).resolve().parent
HEAVY = Path("/fast/scratch/hyaku/kagi-r28/FDeriveCurl")
WORK = HEAVY if HEAVY.is_dir() else SB
CAND = WORK / "cand"
BASE = WORK / "base"


LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
REVS = {"cand": "62a33b1bd15217ed729df2ca40c8a30aba3076c0",
        "base": "3553d499577084a6c98d7078906017840bbf7b28"}


def ensure_clones():
    """Re-create the exported trees if deleted (read-only git archive)."""
    import io as _io
    import tarfile
    for name, rev in REVS.items():
        dest = WORK / name
        if (dest / "corpus" / "release-clock.py").is_file():
            continue
        dest.mkdir(parents=True, exist_ok=True)
        proc = subprocess.run(["git", "-C", LANE, "archive", "--format=tar", rev],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if proc.returncode != 0:
            raise SystemExit("git archive %s failed" % rev)
        with tarfile.open(fileobj=_io.BytesIO(proc.stdout)) as tar:
            tar.extractall(dest)


ensure_clones()

def build(tag, clone, cell=None, anchored=None, observed=None, note=None,
          verdict=None):
    root = WORK / ("probe-" + tag)
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(clone / "corpus", root / "corpus")
    if cell is not None:
        sp = root / "corpus" / "SOURCES.md"
        text = sp.read_text(encoding="utf-8")
        lines = text.splitlines(keepends=True)
        for i, line in enumerate(lines):
            if line.startswith("| S037 |"):
                cells = line.rstrip("\n").split("|")
                cells[6] = " " + cell + " "
                lines[i] = "|".join(cells)
        sp.write_text("".join(lines), encoding="utf-8")
    if anchored is not None:
        tsv = root / "corpus" / "release-clocks.tsv"
        lines = tsv.read_text(encoding="utf-8").splitlines(keepends=True)
        for i, line in enumerate(lines):
            fields = line.rstrip("\n").split("\t")
            if fields[0] != "S029":
                continue
            fields[4] = anchored
            fields[5] = observed if observed is not None else anchored
            if note is not None:
                fields[8] = note
            if verdict is not None:
                fields[7] = verdict
            lines[i] = "\t".join(fields) + "\n"
        tsv.write_text("".join(lines), encoding="utf-8")
    receipt = json.loads((clone / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    if anchored is not None:
        for rec in receipt["observations"]:
            if rec.get("id") == "S029":
                rec["parsed_version"] = observed if observed is not None else anchored
                rec["verdict"] = verdict if verdict is not None else rec["verdict"]
    rpath = root / "receipt.json"
    rpath.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return root, rpath


def run(clone, root, rpath, label):
    argv = ["python3", "-I", "-B", str(clone / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(rpath), "--receipt-sha",
            hashlib.sha256(rpath.read_bytes()).hexdigest()]
    p = subprocess.run(argv, cwd=clone, text=True, capture_output=True, timeout=180,
                       env={"PATH": os.environ.get("PATH", "/usr/bin:/bin"),
                            "HOME": str(root), "LC_ALL": "C",
                            "PYTHONDONTWRITEBYTECODE": "1"})
    out = [l for l in p.stdout.splitlines() if l.strip()]
    print("-" * 70)
    print(label, "exit", p.returncode, "traceback",
          "Traceback" in p.stdout or "Traceback" in p.stderr)
    for line in out:
        print("   |", line)
    if p.stderr.strip():
        print("   !", p.stderr.strip()[:400])
    return {"label": label, "exit": p.returncode, "stdout": p.stdout,
            "stderr": p.stderr, "argv": " ".join(argv)}


NOTE_DERIVED = ("derived: anchor names 8.23.1, curl's unreleased development label "
                "(curlver.h 8.23.1-DEV); latest official release when opened "
                "2026-10-21 (8.23.0, 2026-10-14)")

cases = []
root, rpath = build("P1", CAND, cell="Lines Version and Date: 8.99.0, 2026-10-14; "
                   "fetched 2026-10-21", anchored="8.99.0", observed="8.99.0",
                   note=NOTE_DERIVED, verdict="not-fired")
cases.append(run(CAND, root, rpath, "P1 cell-rebound to 8.99.0, row lowered to 8.99.0"))

root, rpath = build("P2", CAND, anchored="8.22.0", observed="8.22.0",
                   note="provenance: anchor renamed to drop the derived marker",
                   verdict="not-fired")
cases.append(run(CAND, root, rpath, "P2 derived: prefix dropped, row lowered to 8.22.0"))

root, rpath = build("P3", CAND, cell="Lines Version and Date: 8.23.0, 2026-10-14 "
                   "(prior 8.22.0); fetched 2026-10-21")
cases.append(run(CAND, root, rpath, "P3 cell names two stable tokens, row untouched"))

root, rpath = build("P4", CAND, anchored="8.23.1", observed="8.23.1",
                   note=NOTE_DERIVED, verdict="not-fired")
cases.append(run(CAND, root, rpath, "P4 row lowered to 8.23.1 (man-page/dev label)"))

root, rpath = build("P1base", BASE, cell="Lines Version and Date: 8.99.0, 2026-10-14; "
                    "fetched 2026-10-21", anchored="8.99.0", observed="8.99.0",
                    note=NOTE_DERIVED, verdict="not-fired")
cases.append(run(BASE, root, rpath, "P1-base same as P1 on BASE code"))

(SB / "probe-results.json").write_text(json.dumps(cases, indent=2) + "\n", encoding="utf-8")
print("written", SB / "probe-results.json")
