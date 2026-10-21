#!/usr/bin/env python3
"""Probe the round-28 plan's frozen fixtures against BASE 3553d49 (read-only).

Runs each fixture in a throwaway copy of the BASE tree and prints the clock's
exit code, stdout and stderr. Never writes into the lane checkout.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

BASE = Path(__file__).resolve().parent / "base"
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"


def build(root, table_edits, receipt_edits):
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(BASE / "corpus" / rel, root / "corpus" / rel)
    lines = (BASE / "corpus/release-clocks.tsv").read_text().splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in table_edits:
            for col, value in table_edits[fields[0]].items():
                fields[col] = value
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus/release-clocks.tsv").write_text("".join(lines))
    receipt = json.loads((BASE / RECEIPT_REL).read_text())
    for record in receipt["observations"]:
        if record["id"] in receipt_edits:
            record.update(receipt_edits[record["id"]])
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt_path


def run(name, table_edits, receipt_edits, edit_receipt):
    with tempfile.TemporaryDirectory(prefix="kagi-r28-probe-") as temp:
        root = Path(temp) / "fixture"
        receipt_path = build(root, table_edits, receipt_edits if edit_receipt else {})
        argv = ["python3", "-I", "-B", str(BASE / "corpus/release-clock.py"),
                "--root", str(root)]
        if edit_receipt:
            argv += ["--receipt", str(receipt_path),
                     "--receipt-sha", hashlib.sha256(receipt_path.read_bytes()).hexdigest()]
        proc = subprocess.run(argv, cwd=BASE, text=True, capture_output=True, timeout=120)
    out = proc.stdout.strip().splitlines()
    print("=== %s ===" % name)
    print("exit=%d" % proc.returncode)
    for line in out:
        print("  out| %s" % line)
    if proc.stderr.strip():
        tail = proc.stderr.strip().splitlines()[-3:]
        for line in tail:
            print("  err| %s" % line)
    print()
    return proc


def main():
    big = "3.15." + "1" * 4301
    # F1: leading zero table lie, receipt untouched
    run("F1 table-only (receipt untouched)",
        {"S040": {5: "3.15.01", 7: "fired"}}, {}, False)
    # F1b: leading zero table lie, receipt edited to match
    run("F1b table+receipt edited",
        {"S040": {5: "3.15.01", 7: "fired"}},
        {"S040": {"parsed_version": "3.15.01", "verdict": "fired"}}, True)
    # F2: oversize table lie
    run("F2 oversize table (receipt untouched)",
        {"S040": {5: big, 7: "fired"}}, {}, False)
    # F2b: oversize table, receipt untouched but receipt edited too
    run("F2b oversize table+receipt",
        {"S040": {5: big, 7: "fired"}},
        {"S040": {"parsed_version": big, "verdict": "fired"}}, True)
    # G1: lower every derived anchor on the SOPS feed, observed equal, not-fired
    g1 = {"S008": {4: "3.13.2", 5: "3.13.2", 7: "not-fired"},
          "S009": {4: "3.13.2", 5: "3.13.2", 7: "not-fired"},
          "S010": {4: "3.13.2", 5: "3.13.2", 7: "not-fired"},
          "S011": {4: "3.13.2", 5: "3.13.2", 7: "not-fired"}}
    g1r = {rid: {"parsed_version": "3.13.2", "verdict": "not-fired"} for rid in g1}
    run("G1 lower derived anchors (receipt untouched)", g1, {}, False)
    run("G1b lower derived anchors (receipt edited)", g1, g1r, True)
    # control
    run("control (unmodified)", {}, {}, False)


if __name__ == "__main__":
    main()
