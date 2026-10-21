#!/usr/bin/env python3
"""Table-level leading-zero probe on the curl row S029 (feed S037).

Builds a minimal corpus fixture (registry S029 + S037, clock row S029 copied
from the tree under test), mirrors the edited row into a pruned copy of the
pinned round-26 receipt, and runs the verify path:

    release-clock.py --root <fixture> --receipt <copy> --receipt-sha <sha256>

Usage: probe2.py <tree-root> <label>
"""
import contextlib
import hashlib
import importlib.util
import io
import json
import sys
import tempfile
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
LABEL = sys.argv[2]

S029_SOURCE = S037_SOURCE = None
for line in (TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines():
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) != 11:
        continue
    if cells[0] == "S029":
        S029_SOURCE = line
    elif cells[0] == "S037":
        S037_SOURCE = line
assert S029_SOURCE and S037_SOURCE

HEADER = None
S029_ROW = None
for line in (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines():
    if line.startswith("id\t"):
        HEADER = line
    elif line.startswith("S029\t"):
        S029_ROW = line
assert HEADER and S029_ROW
COLS = HEADER.split("\t")

PINNED = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))
PIN_S029 = next(r for r in PINNED["observations"] if r["id"] == "S029")

spec = importlib.util.spec_from_file_location(
    "rc_under_test2", str(TREE / "corpus" / "release-clock.py"))
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)


def run(label, observed_version, verdict, note):
    row = dict(zip(COLS, S029_ROW.split("\t")))
    row["observed_version"] = observed_version
    row["verdict"] = verdict
    row["note"] = note
    row_text = "\t".join(row[c] for c in COLS)
    rec = dict(PIN_S029)
    rec["parsed_version"] = observed_version
    rec["verdict"] = verdict
    with tempfile.TemporaryDirectory(prefix="curltable-") as tmp:
        root = Path(tmp)
        corpus = root / "corpus"
        corpus.mkdir()
        (corpus / "SOURCES.md").write_text(
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |\n"
            "|---|---|---|---|---|---|---|---|---|---|---|\n"
            + S029_SOURCE + "\n" + S037_SOURCE + "\n", encoding="utf-8")
        (corpus / "release-clocks.tsv").write_text(
            HEADER + "\n" + row_text + "\n", encoding="utf-8")
        receipt = root / "receipt.json"
        receipt.write_text(json.dumps(
            {"format": "release-clock-observations-v1", "observations": [rec]},
            ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        sha = hashlib.sha256(receipt.read_bytes()).hexdigest()
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            code = rc.main(["--root", str(root), "--receipt", str(receipt), "--receipt-sha", sha])
        out = buf.getvalue()
    lines = [ln for ln in out.strip().splitlines()]
    print("%-10s %-14s exit=%-3s traceback=%s" % (
        LABEL, label, code, any("Traceback" in ln for ln in lines)))
    for ln in lines:
        print("           %s" % ln)
    return code, out


print("=== %s :: tree=%s ===" % (LABEL, TREE))
run("control", "8.23.0", "not-fired", S029_ROW.split("\t")[8])
run("lz_table", "8.23.01", "fired",
    S029_ROW.split("\t")[8] + "; leading-zero observation")
run("lz_table_nf", "8.23.01", "not-fired",
    S029_ROW.split("\t")[8] + "; leading-zero observation")
