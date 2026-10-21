#!/usr/bin/env python3
"""Third probe: sensitivity / robustness variants around the G1 rule."""
import hashlib, json, os, shutil, subprocess, sys
from pathlib import Path

GROUP = ["S008", "S009", "S010", "S011"]
FEED = "S033"


def sh(*a, **k):
    return subprocess.run(list(a), text=True, capture_output=True, **k)


def digest(root):
    return hashlib.sha256(json.dumps(
        [(str(p.relative_to(root)), hashlib.sha256(p.read_bytes()).hexdigest())
         for p in sorted(root.rglob("*")) if p.is_file()]).encode()).hexdigest()


def run(tree, work, label, lower, note_prefix=None):
    case = work / label
    case.mkdir(parents=True)
    root = case / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    lines = (tree / "corpus" / "release-clocks.tsv").read_text().splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in GROUP:
            f[4] = lower
            f[5] = lower
            f[7] = "not-fired"
            if note_prefix is not None:
                f[8] = note_prefix + f[8].split(":", 1)[1]
            out.append("\t".join(f) + "\n")
        else:
            out.append(line)
    (root / "corpus" / "release-clocks.tsv").write_text("".join(out))
    receipt = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text())
    for r in receipt["observations"]:
        if r.get("id") in GROUP:
            r["parsed_version"] = lower
            r["verdict"] = "not-fired"
    rp = case / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    b_tree, b_root = digest(tree), digest(root)
    argv = ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha]
    p = sh(*argv, cwd=str(tree), env={"PATH": os.environ["PATH"], "HOME": str(case),
                                      "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"})
    ls = [l for l in p.stdout.splitlines() if l.strip()]
    return {"label": label, "lower": lower, "note_prefix": note_prefix, "exit": p.returncode,
            "tail": [l for l in ls if l.startswith("RELEASE_CLOCK:")][-1:],
            "findings": [l for l in ls if not l.startswith("RELEASE_CLOCK:")],
            "traceback": "Traceback" in p.stdout or "Traceback" in p.stderr,
            "tree_unchanged": b_tree == digest(tree),
            "fixture_unchanged": b_root == digest(root)}


def main():
    tree = Path(sys.argv[1]).resolve()
    work = Path(sys.argv[2]).resolve()
    work.mkdir(parents=True, exist_ok=True)
    res = [run(tree, work, "same-3.13.3", "3.13.3"),
           run(tree, work, "lower-3.14.0", "3.14.0"),
           run(tree, work, "note-case-escape", "3.13.2", note_prefix="Derived"),
           run(tree, work, "note-prefix-escape", "3.13.2", note_prefix="xderived")]
    print(json.dumps(res, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
