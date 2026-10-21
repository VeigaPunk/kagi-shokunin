#!/usr/bin/env python3
"""FObsHuge mutation probe: is NON-CANONICAL produced by the round-28 C1 rule,
or would a generic category do the same job?

Variant A: candidate with VERSION_COMPONENT_MAX_DIGITS raised to 4301, so the
4301-digit token is treated as canonical and the C1 branch is bypassed. If the
finding then degrades to a BASE-era category (INCONSISTENT / RECEIPT-MISMATCH),
the non-BASE category in the unmutated candidate is load-bearing C1 output.

Variant B: candidate with the whole `if non_canonical:` block removed.

Both variants run the F2 fixture (table observation, 4301-digit patch) with a
receipt MIRRORED to the fixture token, so the receipt itself matches: any
finding then comes from the row rule, not from receipt integrity.
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

src = Path(sys.argv[1]).resolve()          # exported candidate tree
work = Path(sys.argv[2]).resolve()
OVERSIZE = "3.15." + "1" * 4301
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")


def edited_table():
    lines = (src / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == "S040":
            fields[5], fields[7] = OVERSIZE, "fired"
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def run(variant, tree, note):
    root = work / ("fixture-" + variant)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "release-clocks.tsv").write_text(edited_table(), encoding="utf-8")
    receipt = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record.get("id") == "S040":
            record["parsed_version"] = OVERSIZE
            record["verdict"] = "fired"
    path = root / "receipt.json"
    path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    sha = hashlib.sha256(path.read_bytes()).hexdigest()
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(work),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    proc = subprocess.run(
        ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
         "--root", str(root), "--receipt", str(path), "--receipt-sha", sha],
        cwd=str(tree), env=env, text=True, capture_output=True, timeout=120)
    findings = [ln.strip() for ln in proc.stdout.splitlines()
                if ln.strip() and not ln.startswith("RELEASE_CLOCK")]
    print("### %s (%s)" % (variant, note))
    print("exit=%d" % proc.returncode)
    print("findings=%s" % json.dumps(findings))
    print("summary=%s" % json.dumps([ln for ln in proc.stdout.splitlines()
                                     if ln.startswith("RELEASE_CLOCK")]))
    print("traceback=%s" % ("Traceback" in proc.stdout + proc.stderr))
    print("stderr_tail=%s" % json.dumps(proc.stderr.splitlines()[-3:]))
    print()
    return findings


def variant_tree(name, mutate):
    tree = work / name
    if tree.exists():
        shutil.rmtree(tree)
    shutil.copytree(src, tree)
    code = (tree / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    code = mutate(code)
    (tree / "corpus" / "release-clock.py").write_text(code, encoding="utf-8")
    return tree


if __name__ == "__main__":
    work.mkdir(parents=True, exist_ok=True)
    base_tree = variant_tree("varA", lambda c: c.replace(
        "VERSION_COMPONENT_MAX_DIGITS = 18", "VERSION_COMPONENT_MAX_DIGITS = 4301"))
    a = run("A-bound-raised-to-4301", base_tree,
            "C1 bound bypassed; the 4301-digit token becomes 'canonical'")
    tree_b = variant_tree("varB", lambda c: c.replace(
        """            if non_canonical:
                # SemVer 2.0.0 §2 (S045): a leading zero or an over-bound component
                # (S044) names no release identity, so it is never ordered, compared
                # or fired.
                errors.add(("NON-CANONICAL", source_id))
                row_valid = False
""", ""))
    b = run("B-noncanonical-branch-removed", tree_b,
            "C1 row rule removed entirely")
    base_set = {"ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
                "RECEIPT-MISMATCH", "NOT OBSERVED"}
    for name, findings in (("A", a), ("B", b)):
        tokens = [f.split()[0] for f in findings]
        nonbase = [t for t in tokens if t not in base_set]
        print("variant %s: tokens=%s non_base_era=%s" % (name, tokens, nonbase))
