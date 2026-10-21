#!/usr/bin/env python3
"""Second independent G1 probe: BASE comparison, partial-group lowering, and
fixture-write detection (no fired verdict written)."""
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


def sh(*argv, **kw):
    return subprocess.run(list(argv), text=True, capture_output=True, **kw)


def digest(root: Path):
    items = []
    for p in sorted(root.rglob("*")):
        if p.is_file():
            items.append((str(p.relative_to(root)), hashlib.sha256(p.read_bytes()).hexdigest()))
    return hashlib.sha256(json.dumps(items).encode()).hexdigest()


def build(tree: Path, work: Path, lowered_ids):
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in lowered_ids:
            assert f[2] == FEED and f[8].startswith("derived:"), f
            f[4] = LOWER
            f[5] = LOWER
            f[7] = "not-fired"
            out.append("\t".join(f) + "\n")
        else:
            out.append(line)
    (root / "corpus" / "release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    receipt = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record.get("id") in lowered_ids:
            record["parsed_version"] = LOWER
            record["verdict"] = "not-fired"
    rp = work / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return root, rp


def run(tree: Path, work: Path, label: str, lowered_ids):
    case = work / label
    case.mkdir(parents=True)
    root, rp = build(tree, case, lowered_ids)
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    before_tree, before_root = digest(tree), digest(root)
    argv = ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha]
    p = sh(*argv, cwd=str(tree), env={"PATH": os.environ["PATH"], "HOME": str(case),
                                      "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"})
    after_tree, after_root = digest(tree), digest(root)
    lines = [l for l in p.stdout.splitlines() if l.strip()]
    return {
        "label": label, "lowered": list(lowered_ids), "exit": p.returncode,
        "tail": [l for l in lines if l.startswith("RELEASE_CLOCK:")][-1:],
        "findings": [l for l in lines if not l.startswith("RELEASE_CLOCK:")],
        "tree_unchanged": before_tree == after_tree,
        "fixture_unchanged": before_root == after_root,
        "traceback": ("Traceback" in p.stdout) or ("Traceback" in p.stderr),
        "stdout": p.stdout, "stderr": p.stderr,
        "receipt_verdicts": {r["id"]: r.get("verdict") for r in json.loads(rp.read_text())["observations"]
                             if r.get("id") in GROUP},
        "receipt_parsed": {r["id"]: r.get("parsed_version") for r in json.loads(rp.read_text())["observations"]
                           if r.get("id") in GROUP},
    }


def main():
    tree = Path(sys.argv[1]).resolve()
    work = Path(sys.argv[2]).resolve()
    work.mkdir(parents=True, exist_ok=True)
    out = {"tree": str(tree),
           "all4": run(tree, work, "all4", GROUP),
           "partial_S008": run(tree, work, "partial", ["S008"])}
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
