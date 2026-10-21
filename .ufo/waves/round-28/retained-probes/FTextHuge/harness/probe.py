#!/usr/bin/env python3
"""Independent probe for the curl 'Version:' text-feed carrier (round-28 C1).

Usage: probe.py TREE LABEL FEED_FILE OUTDIR [ENV=VAL ...]

Builds an isolated fixture root from TREE (narrowed to the curl clock row
S029 and its feed registry row S037, every kept row verbatim), serves FEED_FILE
as the curl release-information body, runs the tree's own
corpus/release-clock.py --root FIXTURE --observe OUT.json through the child
runner (transport stubbed, nothing in the tree edited) and prints a JSON
verdict with the exact observed categories.
"""
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROW_ID = "S029"
FEED_SOURCE_ID = "S037"
HERE = Path(__file__).resolve().parent
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")


def narrow_sources(tree, keep_ids):
    lines = (tree / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [cell.strip() for cell in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) and cells[0] not in keep_ids:
                continue
        kept.append(line)
    return "".join(kept)


def narrow_table(tree, keep_ids):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    kept = []
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if index == 0:
            kept.append(line)
            continue
        if fields and fields[0] not in keep_ids:
            continue
        kept.append(line)
    return "".join(kept)


def row_fields(table_text, row_id):
    for line in table_text.splitlines():
        fields = line.split("\t")
        if fields and fields[0] == row_id:
            return fields
    raise RuntimeError("row %s missing" % row_id)


def main():
    if len(sys.argv) < 5:
        raise SystemExit("usage: probe.py TREE LABEL FEED_FILE OUTDIR [ENV=VAL ...]")
    tree, label, feed_file, outdir = sys.argv[1:5]
    extra_env = dict(item.split("=", 1) for item in sys.argv[5:])
    tree = Path(tree).resolve()
    outdir = Path(outdir).resolve()
    outdir.mkdir(parents=True, exist_ok=True)
    root = outdir / "fixture-root"
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    table_text = narrow_table(tree, {ROW_ID})
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    (root / "corpus" / "SOURCES.md").write_text(
        narrow_sources(tree, {ROW_ID, FEED_SOURCE_ID}), encoding="utf-8")
    fields = row_fields(table_text, ROW_ID)
    feed_url, observed_at = fields[3], fields[6]
    out_receipt = outdir / "observe-out.json"
    env = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": str(outdir),
        "LC_ALL": "C",
        "PYTHONDONTWRITEBYTECODE": "1",
    }
    env.update(extra_env)
    proc = subprocess.run(
        ["python3", "-I", "-B", str(HERE / "run-observe.py"), str(tree),
         str(root), str(out_receipt), str(Path(feed_file).resolve()), feed_url,
         observed_at],
        cwd=str(tree), env=env, text=True, capture_output=True, timeout=180)
    combined = proc.stdout + "\n" + proc.stderr
    receipt = None
    try:
        receipt = json.loads(out_receipt.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        pass
    records = []
    if receipt:
        for record in receipt.get("observations", []):
            records.append({key: record.get(key) for key in
                            ("id", "url", "http_status", "parsed_version",
                             "verdict", "error")})
    finding_lines = [line.strip() for line in proc.stdout.splitlines()
                     if line.strip() and not line.startswith("RELEASE_CLOCK")
                     and not line.startswith("RELEASE_CLOCK_OBSERVE")]
    fired_records = [r for r in records if r.get("verdict") == "fired"]
    last_line = ""
    for line in proc.stdout.splitlines():
        if line.strip():
            last_line = line.strip()
    document = {
        "label": label,
        "tree": str(tree),
        "extra_env": extra_env,
        "argv": ["python3", "-I", "-B", "run-observe.py", str(tree), str(root),
                 str(out_receipt), str(Path(feed_file).resolve()), feed_url,
                 observed_at],
        "exit": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "traceback_in_output": "Traceback" in combined,
        "finding_lines": finding_lines,
        "last_line": last_line,
        "receipt_records": records,
        "fired_records": fired_records,
        "feed_url": feed_url,
    }
    print(json.dumps(document, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
