#!/usr/bin/env python3
"""FObsZero independent probe for round-28 C1 F1 (table observation 3.15.01).

Builds its own fixture: corpus/release-clocks.tsv with S040 fields[5]/[7]
replaced by (observed_version, verdict), plus a mirrored copy of the default
receipt (S040 parsed_version/verdict replaced) run with --receipt/--receipt-sha.

Usage: f1_probe.py <tree> <label> <outdir> <token> <verdict> [anchor_token]
Prints JSON to stdout.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

FIXTURE_ROW = "S040"
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")


def edited_table(tree, edits):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            fields[5], fields[7] = edits[fields[0]]
            kept.append("\t".join(fields) + "\n")
        else:
            kept.append(line)
    return "".join(kept)


def default_receipt(tree):
    code = (tree / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    for line in code.splitlines():
        if "return root /" in line and ".ufo" in line and "observe-" in line:
            inner = line.split("return root /", 1)[1].strip()
            inner = inner.rstrip(")").strip()
            parts = [p.strip().strip('"') for p in inner.split("/") if p.strip()]
            return tree.joinpath(*parts)
    raise RuntimeError("no default receipt path in release-clock.py")


def main():
    tree = Path(sys.argv[1]).resolve()
    label = sys.argv[2]
    outdir = Path(sys.argv[3]).resolve()
    token = sys.argv[4]
    verdict = sys.argv[5]
    anchor_token = sys.argv[6] if len(sys.argv) > 6 else None
    outdir.mkdir(parents=True, exist_ok=True)
    root = outdir / ("fixture-" + label)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)

    edits = {FIXTURE_ROW: (token, verdict)}
    if os.environ.get("NO_TABLE") == "1":
        text = edited_table(tree, {})
    elif anchor_token is not None:
        text = edited_table(tree, edits)
        lines = text.splitlines(keepends=True)
        out = []
        for line in lines:
            f = line.rstrip("\n").split("\t")
            if f and f[0] == FIXTURE_ROW:
                f[4] = anchor_token
                out.append("\t".join(f) + "\n")
            else:
                out.append(line)
        text = "".join(out)
    else:
        text = edited_table(tree, edits)
    (root / "corpus" / "release-clocks.tsv").write_text(text, encoding="utf-8")

    src_receipt = default_receipt(tree)
    doc = json.loads(src_receipt.read_text(encoding="utf-8"))
    mirrored = []
    if os.environ.get("NO_MIRROR") != "1":
        for rec in doc["observations"]:
            if rec.get("id") in edits:
                if os.environ.get("RECEIPT_ONLY") == "1":
                    rec["parsed_version"] = edits[rec["id"]][0]
                else:
                    rec["parsed_version"], rec["verdict"] = edits[rec["id"]]
                mirrored.append(rec["id"])
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()

    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(outdir),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    argv = ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(receipt_path),
            "--receipt-sha", sha]
    proc = subprocess.run(argv, cwd=str(tree), env=env, text=True,
                          capture_output=True, timeout=120)
    after_sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
    receipt_after = json.loads(receipt_path.read_text(encoding="utf-8"))
    s040_after = [r for r in receipt_after["observations"]
                  if r.get("id") == FIXTURE_ROW]
    out = {
        "label": label,
        "tree": str(tree),
        "token": token,
        "verdict": verdict,
        "anchor_token": anchor_token,
        "argv": argv,
        "exit": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "traceback_in_output": "Traceback" in (proc.stdout + proc.stderr),
        "mirrored_rows": mirrored,
        "receipt_sha_before": sha,
        "receipt_sha_after": after_sha,
        "receipt_unchanged": sha == after_sha,
        "s040_receipt_after": s040_after,
        "fired_lines": [ln for ln in proc.stdout.splitlines()
                        if "fired" in ln.lower()],
    }
    print(json.dumps(out, indent=1))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
