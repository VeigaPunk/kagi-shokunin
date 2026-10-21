#!/usr/bin/env python3
"""Independent G1 (SOPS S008-S011 derived rows lowered) probe.

Builds its own fixture from a candidate tree (not reusing .ufo/waves/round-28/tools/c2-measure.py
fixture code), runs the tree's own corpus/release-clock.py, and prints a machine-checkable
summary.  No network: every feed row is evaluated against the retained receipt.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

GROUP = ["S008", "S009", "S010", "S011"]
FEED = "S033"
LOWER = "3.13.2"
HEADER = ["id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note"]


def sh(*argv, **kw):
    return subprocess.run(list(argv), text=True, capture_output=True, **kw)


def build_fixture(tree: Path, work: Path, mirror_receipt: bool):
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    # table edit: lower anchored+observed on the four derived SOPS rows
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    edited = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields[0] in GROUP:
            assert fields[2] == FEED, (fields[0], fields[2])
            assert fields[8].startswith("derived:"), (fields[0], fields[8])
            fields[4] = LOWER
            fields[5] = LOWER
            fields[7] = "not-fired"
            edited.append(fields[0])
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    assert sorted(edited) == sorted(GROUP), edited
    (root / "corpus" / "release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    # receipt copy (default receipt of the tree); optional mirroring
    default = tree / ".ufo" / "waves" / "round-26" / "observe-2.json"
    receipt = json.loads(default.read_text(encoding="utf-8"))
    mirrored = []
    if mirror_receipt:
        for record in receipt["observations"]:
            if record.get("id") in GROUP:
                record["parsed_version"] = LOWER
                record["verdict"] = "not-fired"
                mirrored.append(record["id"])
        assert sorted(mirrored) == sorted(GROUP), mirrored
    rp = work / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return root, rp, edited, mirrored


def tree_digest(root: Path):
    items = []
    for p in sorted(root.rglob("*")):
        if p.is_file():
            items.append((str(p.relative_to(root)), hashlib.sha256(p.read_bytes()).hexdigest()))
    return hashlib.sha256(json.dumps(items).encode()).hexdigest()


def run_case(tree: Path, work: Path, label: str, mirror_receipt: bool):
    case = work / label
    case.mkdir(parents=True)
    root, rp, edited, mirrored = build_fixture(tree, case, mirror_receipt)
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    before = tree_digest(tree)
    argv = ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha]
    proc = sh(*argv, cwd=str(tree), env={"PATH": os.environ["PATH"], "HOME": str(case),
                                        "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"})
    after = tree_digest(tree)
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    tail = [l for l in lines if l.startswith("RELEASE_CLOCK:")]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    return {
        "label": label, "argv": argv, "exit": proc.returncode,
        "stdout": proc.stdout, "stderr": proc.stderr,
        "tail": tail[-1] if tail else "",
        "findings": findings,
        "edited": edited, "mirrored": mirrored,
        "tree_unchanged": before == after,
        "traceback": ("Traceback" in proc.stdout) or ("Traceback" in proc.stderr),
    }


def control(tree: Path, work: Path):
    proc = sh("python3", "-I", "-B", "corpus/release-clock.py", cwd=str(tree),
              env={"PATH": os.environ["PATH"], "HOME": str(work), "LC_ALL": "C",
                   "PYTHONDONTWRITEBYTECODE": "1"})
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    return {"exit": proc.returncode, "tail": lines[-1] if lines else "",
            "findings": [l for l in lines if not l.startswith("RELEASE_CLOCK:")],
            "stdout": proc.stdout, "stderr": proc.stderr}


def main():
    tree = Path(sys.argv[1]).resolve()
    work = Path(sys.argv[2]).resolve()
    work.mkdir(parents=True, exist_ok=True)
    out = {"tree": str(tree), "cases": []}
    out["cases"].append(run_case(tree, work, "G1-mirrored", True))
    out["cases"].append(run_case(tree, work, "G1-unmirrored", False))
    out["control"] = control(tree, work)
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
