#!/usr/bin/env python3
"""FDeriveTwo probe: feed-row anchor naming two distinct stable versions.

Independent reproduction of round-28 C2 on the pinned candidate
62a33b1bd15217ed729df2ca40c8a30aba3076c0 (and BASE 3553d49 for contrast).

Every fixture edits ONE cell of corpus/SOURCES.md (the located anchor cell of
feed registry row S033) and touches nothing else: no table row, no receipt, no
code. The default receipt (.ufo/waves/round-26/observe-2.json) is used as-is,
so a RECEIPT-MISMATCH cannot be mistaken for the new rule.

Re-create the two trees this driver needs (heavy, deleted after the run):

    LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
    SB=$LANE/.ufo/waves/round-28/sandboxes/FDeriveTwo
    mkdir -p $SB/cand $SB/base
    git -C $LANE archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C $SB/cand
    git -C $LANE archive 3553d499577084a6c98d7078906017840bbf7b28 | tar -x -C $SB/base
    python3 $SB/probe.py
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

SB = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/FDeriveTwo")
CAND = SB / "cand"
BASE = SB / "base"
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"

S033_ORIG = ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, "
             "updated 2026-07-23T05:29:11Z; feed fetched 2026-10-21")

FIXTURES = {
    # A: the cell names TWO distinct stable versions (3.13.3 and 3.12.9).
    "A_two_versions": ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, "
                        "updated 2026-07-23T05:29:11Z; previous stable release "
                        "v3.12.9; feed fetched 2026-10-21"),
    # C: two distinct stable versions, the row's own anchor among them.
    "C_two_versions_incl_anchor": ("Newest stable v3.13.3; preceding stable v3.12.9; "
                                    "feed fetched 2026-10-21"),
    # B: same two versions, the second one terminated by a sentence period.
    "B_two_versions_second_period": ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3; "
                                      "previous stable release v3.12.9."),
    # D: ONE version only, terminated by a sentence period (punctuation control).
    "D_one_version_period": ("Entry titled v3.13.3."),
    # E: control - the untouched single-version cell.
    "E_control_original": S033_ORIG,
}


def sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def edit_anchor_cell(tree, old_cell, new_cell):
    path = tree / "corpus" / "SOURCES.md"
    text = path.read_text(encoding="utf-8")
    line_old = None
    for line in text.splitlines():
        if line.startswith("| S033 |"):
            line_old = line
            break
    if line_old is None:
        raise SystemExit("S033 row not found")
    cells = line_old.split(" | ")
    idx = None
    for i, cell in enumerate(cells):
        if cell.strip() == old_cell:
            idx = i
            break
    if idx is None:
        raise SystemExit("anchor cell %r not found in S033 row" % old_cell)
    cells[idx] = new_cell
    new_line = " | ".join(cells)
    path.write_text(text.replace(line_old, new_line), encoding="utf-8")
    return idx


def run(tree, label):
    proc = subprocess.run(
        [sys.executable, "-I", "-B", str(tree / "corpus" / "release-clock.py"),
         "--root", str(tree)],
        capture_output=True, text=True)
    out = proc.stdout
    findings = [ln for ln in out.splitlines() if ln.strip() and not ln.startswith("RELEASE_CLOCK:")]
    cats = sorted({ln.split()[0] for ln in findings if ln.split()})
    ids = sorted({m for ln in findings for m in re.findall(r"S[0-9]{3}", ln)})
    final = [ln for ln in out.splitlines() if ln.startswith("RELEASE_CLOCK:")]
    return {
        "label": label,
        "exit": proc.returncode,
        "stdout": out,
        "stderr": proc.stderr,
        "finding_lines": findings,
        "categories": cats,
        "row_ids": ids,
        "final_line": final[-1] if final else "",
        "traceback": "Traceback" in out or "Traceback" in proc.stderr,
    }


def tree_state(tree):
    files = {}
    for p in sorted(tree.rglob("*")):
        if p.is_file():
            files[str(p.relative_to(tree))] = sha256(p)
    return files


def main():
    results = []
    for name, new_cell in FIXTURES.items():
        for tag, src in (("cand", CAND), ("base", BASE)):
            work = SB / ("work-%s-%s" % (name, tag))
            if work.exists():
                shutil.rmtree(work)
            shutil.copytree(src, work)
            before = tree_state(work)
            edit_anchor_cell(work, S033_ORIG, new_cell)
            res = run(work, "%s/%s" % (name, tag))
            after = tree_state(work)
            res["tree_changed_files"] = sorted(
                k for k in set(before) | set(after)
                if before.get(k) != after.get(k))
            res["receipt_sha_after"] = sha256(work / RECEIPT_REL)
            res["fixture"] = name
            res["tree"] = tag
            results.append(res)
            print(json.dumps({k: res[k] for k in (
                "label", "exit", "final_line", "categories", "row_ids",
                "finding_lines", "traceback", "tree_changed_files",
                "receipt_sha_after")}, indent=1))
            print("-" * 70)
    (SB / "results.json").write_text(json.dumps(results, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
