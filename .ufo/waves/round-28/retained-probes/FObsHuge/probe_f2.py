#!/usr/bin/env python3
"""Independent FObsHuge probe: table observation with a 4301-digit patch token.

Builds its own fixture from an exported tree (no c1-measure.py reuse), runs the
tree's own corpus/release-clock.py, and asserts the exact typed category,
exit status, absence of a traceback, absence of a fired count, and table
immutability. Two variants:
  mirror  -- the default receipt copy is updated to the fixture token (so the
             receipt itself matches: any finding must come from the C1 rule)
  nomirror-- the pinned default receipt is used unchanged (real-world case)
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

tree = Path(sys.argv[1]).resolve()
label = sys.argv[2]
tmp = Path(sys.argv[3]).resolve()
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")
OVERSIZE = "3.15." + "1" * 4301


def edited_table(edits):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            fields[5], fields[7] = edits[fields[0]]
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def stage(name, table_text):
    root = tmp / name
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    return root


def default_receipt():
    return json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))


def run_case(name, mirror):
    root = stage(name, edited_table({"S040": (OVERSIZE, "fired")}))
    receipt = default_receipt()
    if mirror:
        for record in receipt["observations"]:
            if record.get("id") == "S040":
                record["parsed_version"] = OVERSIZE
                record["verdict"] = "fired"
    path = root / "receipt.json"
    path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    sha = hashlib.sha256(path.read_bytes()).hexdigest()
    before = (root / "corpus" / "release-clocks.tsv").read_bytes()
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(tmp),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    proc = subprocess.run(
        ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
         "--root", str(root), "--receipt", str(path), "--receipt-sha", sha],
        cwd=str(tree), env=env, text=True, capture_output=True, timeout=120)
    after = (root / "corpus" / "release-clocks.tsv").read_bytes()
    findings = [ln.strip() for ln in proc.stdout.splitlines()
                if ln.strip() and not ln.startswith("RELEASE_CLOCK")]
    summary = [ln for ln in proc.stdout.splitlines() if ln.startswith("RELEASE_CLOCK")]
    written = sorted(p.name for p in root.iterdir())
    print("### %s [%s]" % (name, label))
    print("exit=%d" % proc.returncode)
    print("stdout=%s" % json.dumps(proc.stdout.splitlines()))
    print("stderr_tail=%s" % json.dumps(proc.stderr.splitlines()[-4:]))
    print("findings=%s" % json.dumps(findings))
    print("summary=%s" % json.dumps(summary))
    print("traceback_in_output=%s" % ("Traceback" in proc.stdout + proc.stderr))
    print("tsv_immutable=%s" % (before == after))
    print("root_files=%s" % json.dumps(written))
    print("typed_noncanonical=%s" % (any(f.split()[0] == "NON-CANONICAL" and f.split()[1] == "S040"
                                         for f in findings)))
    print("has_receipt_mismatch=%s" % any(f.startswith("RECEIPT-MISMATCH") for f in findings))
    print()
    return proc


if __name__ == "__main__":
    tmp.mkdir(parents=True, exist_ok=True)
    run_case("mirror", True)
    run_case("nomirror", False)
