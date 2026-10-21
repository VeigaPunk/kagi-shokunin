#!/usr/bin/env python3
"""FFeedTie C2 probe: the canonical/non-canonical NUMERIC TIE in the derived
binding, both directions, on an isolated exported tree.

  C2-T1  feed row S037's ANCHOR CELL names the non-canonical twin 8.23.00;
         the derived row S029 keeps canonical 8.23.0  -> expect DERIVATION
  C2-T2  the derived row S029's ANCHOR is the non-canonical twin 8.23.00;
         the feed cell still names 8.23.0            -> expect NON-CANONICAL once
  C2-T3  the derived row S029's anchor is raised to 8.23.1 (the dev label the
         cell does NOT name)                          -> expect DERIVATION
  C2-T4  control: unmodified tree                    -> expect CLEAN exit 0

Only corpus/SOURCES.md (one anchor cell) or corpus/release-clocks.tsv (one
row) is edited; the code, the pinned receipt and every other row are verbatim.

Usage: c2_tie_probe.py TREE LABEL OUT.json
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

BASE_CATEGORIES = {"ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
                   "NOT OBSERVED", "RECEIPT-MISMATCH"}
ID_RE = re.compile(r"(?<![A-Za-z0-9])S[0-9]{3}(?![0-9])")


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=180)
    return proc


def classify(proc):
    lines = [line for line in proc.stdout.splitlines() if line.strip()]
    last = lines[-1] if lines else ""
    tails = [i for i, line in enumerate(lines) if line.startswith("RELEASE_CLOCK:")]
    findings = [line for line in lines[:tails[-1]]] if tails else lines
    parsed = []
    for line in findings:
        match = ID_RE.search(line)
        parsed.append({"line": line,
                       "category": line[:match.start()].strip() if match else None,
                       "ids": ID_RE.findall(line)})
    return {
        "argv": proc.args, "exit": proc.returncode, "stdout": proc.stdout,
        "stderr": proc.stderr, "last_line": last,
        "findings": [p["line"] for p in parsed],
        "categories": [p["category"] for p in parsed],
        "named_ids": sorted({rid for p in parsed for rid in p["ids"]}),
        "traceback": "Traceback" in proc.stdout + proc.stderr,
        "clean": proc.returncode == 0 and last.startswith("RELEASE_CLOCK: CLEAN"),
    }


def copy_tree(tree, temp, name):
    root = temp / name
    root.mkdir()
    shutil.copytree(tree / "corpus", root / "corpus")
    shutil.copytree(tree / ".ufo", root / ".ufo")
    return root


def edit_sources_anchor(root, source_id, old, new):
    path = root / "corpus" / "SOURCES.md"
    text = path.read_text(encoding="utf-8")
    assert old in text, old
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def edit_table_anchor(root, row_id, anchored):
    path = root / "corpus" / "release-clocks.tsv"
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    hit = False
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == row_id:
            fields[4] = anchored
            out.append("\t".join(fields) + "\n")
            hit = True
        else:
            out.append(line)
    assert hit, row_id
    path.write_text("".join(out), encoding="utf-8")


def main():
    if len(sys.argv) != 4:
        raise SystemExit("usage: c2_tie_probe.py TREE LABEL OUT.json")
    tree, label, out_path = Path(sys.argv[1]).resolve(), sys.argv[2], sys.argv[3]
    temp = Path(tempfile.mkdtemp(prefix="c2tie-"))
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    results = {}

    # C2-T1: the feed row's anchor cell names the non-canonical TWIN 8.23.00.
    root = copy_tree(tree, temp, "t1")
    edit_sources_anchor(root, "S037",
                        "Lines Version and Date: 8.23.0, 2026-10-14",
                        "Lines Version and Date: 8.23.00, 2026-10-14")
    results["C2-T1-cell-names-nc-twin"] = classify(
        run(["python3", "-I", "-B", "corpus/release-clock.py", "--root", str(root)],
            root, env))

    # C2-T2: the derived row's own anchor is the non-canonical twin.
    root = copy_tree(tree, temp, "t2")
    edit_table_anchor(root, "S029", "8.23.00")
    results["C2-T2-row-anchor-nc-twin"] = classify(
        run(["python3", "-I", "-B", "corpus/release-clock.py", "--root", str(root)],
            root, env))

    # C2-T3: the derived row's anchor is raised to a version the cell does not name.
    root = copy_tree(tree, temp, "t3")
    edit_table_anchor(root, "S029", "8.23.1")
    results["C2-T3-row-anchor-raised"] = classify(
        run(["python3", "-I", "-B", "corpus/release-clock.py", "--root", str(root)],
            root, env))

    # C2-T4: control, unmodified tree.
    root = copy_tree(tree, temp, "t4")
    results["C2-T4-control"] = classify(
        run(["python3", "-I", "-B", "corpus/release-clock.py", "--root", str(root)],
            root, env))

    document = {"format": "ffeedtie-c2-probe-v1", "label": label,
                "tree": str(tree), "cases": results}
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    Path(out_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    for key in sorted(results):
        value = results[key]
        print("%-30s exit=%s clean=%s tb=%s cats=%s ids=%s last=%s" % (
            key, value["exit"], value["clean"], value["traceback"],
            value["categories"], value["named_ids"], value["last_line"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
