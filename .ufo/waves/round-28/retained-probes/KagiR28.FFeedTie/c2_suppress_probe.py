#!/usr/bin/env python3
"""FFeedTie narrow probe: does a non-canonical OBSERVATION suppress the
DERIVATION finding on a derived row whose anchor is mismatched?

C2-S1  derived row S029: anchored 8.23.1 (the cell does NOT name it ->
      DERIVATION expected) + observed 8.23.01 (non-canonical -> NON-CANONICAL).
      Candidate evaluate() guards the DERIVATION check with `not non_canonical`,
      where non_canonical = f(anchored) OR f(observed). The observed side
      therefore suppresses the calibration finding.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def run_case(tree, temp, name, anchored, observed):
    root = temp / name
    root.mkdir()
    shutil.copytree(tree / "corpus", root / "corpus")
    shutil.copytree(tree / ".ufo", root / ".ufo")
    path = root / "corpus" / "release-clocks.tsv"
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == "S029":
            fields[4] = anchored
            fields[5] = observed
            fields[7] = "fired"
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    path.write_text("".join(out), encoding="utf-8")
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    proc = subprocess.run(
        ["python3", "-I", "-B", "corpus/release-clock.py", "--root", str(root)],
        cwd=str(root), env=env, text=True, capture_output=True, timeout=180)
    cats = [line.strip().split()[0] for line in proc.stdout.splitlines()
            if line.strip() and not line.strip().startswith("RELEASE_CLOCK")
            and "S029" in line]
    return {"exit": proc.returncode, "categories_S029": cats,
            "stdout": proc.stdout, "stderr": proc.stderr}


def main():
    tree = Path(sys.argv[1]).resolve()
    temp = Path(tempfile.mkdtemp(prefix="c2sup-"))
    result = {
        "anchored-8.23.1_observed-8.23.01": run_case(
            tree, temp, "s1", "8.23.1", "8.23.01"),
        "anchored-8.23.1_observed-canonical-8.23.0": run_case(
            tree, temp, "s2", "8.23.1", "8.23.0"),
    }
    for key, value in result.items():
        print("%-44s exit=%s cats_S029=%s" % (
            key, value["exit"], value["categories_S029"]))
    Path(sys.argv[2]).write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
