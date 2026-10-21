#!/usr/bin/env python3
"""Offline probe of the curl (curl.se/info) "Version:" line carrier.

Usage: probe.py <tree-root> <label>

Builds a minimal corpus fixture (registry rows S029 + S037 and the S029 clock
row copied verbatim from the tree under test), serves a synthetic curl
release-information body to the offline release-clock, and reports the CLI
exit code, stdout categories and the written receipt record.
"""
import contextlib
import importlib.util
import io
import json
import os
import sys
import tempfile
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
LABEL = sys.argv[2]

S029_SOURCE = None
S037_SOURCE = None
for line in (TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines():
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) != 11:
        continue
    if cells[0] == "S029":
        S029_SOURCE = line
    elif cells[0] == "S037":
        S037_SOURCE = line
assert S029_SOURCE and S037_SOURCE, "registry rows not found in tree"

HEADER = None
S029_ROW = None
for line in (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines():
    if line.startswith("id\t"):
        HEADER = line
    elif line.startswith("S029\t"):
        S029_ROW = line
assert HEADER and S029_ROW, "clock rows not found in tree"

VARIANTS = {
    # label: body served for https://curl.se/info
    "ctrl": b"Version: 8.23.0\nDate: 2026-10-14\nNext release: 2026-12-09\n",
    "lz_patch": b"Version: 8.23.01\nDate: 2026-10-14\nNext release: 2026-12-09\n",
    "lz_major": b"Version: 08.23.0\nDate: 2026-10-14\nNext release: 2026-12-09\n",
    "lz_minor": b"Version: 8.023.0\nDate: 2026-10-14\nNext release: 2026-12-09\n",
    "lz_zero_patch": b"Version: 8.23.00\nDate: 2026-10-14\n",
    "lz_oversize": b"Version: 8.23." + b"1" * 4301 + b"\nDate: 2026-10-14\n",
    "lz_suffix": b"Version: 8.23.01 (x86_64-pc-linux-gnu)\nDate: 2026-10-14\n",
    "lz_crlf": b"Version: 8.23.01\r\nDate: 2026-10-14\r\n",
    "lz_lowercase": b"version: 8.23.01\nDate: 2026-10-14\n",
    "lz_indent": b" Version: 8.23.01\nDate: 2026-10-14\n",
    "lz_fourcomp": b"Version: 8.23.01.1\nDate: 2026-10-14\n",
    "lz_second_line": b"curl release information\nVersion: 8.23.01\nDate: 2026-10-14\n",
    "lz_then_canonical": (b"Version: 8.23.01\nDate: 2026-10-14\n"
                          b"Version: 8.23.0\n"),
}

spec = importlib.util.spec_from_file_location(
    "rc_under_test", str(TREE / "corpus" / "release-clock.py"))
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)


def build_root(tmp, body):
    corpus = Path(tmp) / "corpus"
    corpus.mkdir()
    (corpus / "SOURCES.md").write_text(
        "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |\n"
        "|---|---|---|---|---|---|---|---|---|---|---|\n"
        + S029_SOURCE + "\n" + S037_SOURCE + "\n", encoding="utf-8")
    (corpus / "release-clocks.tsv").write_text(
        HEADER + "\n" + S029_ROW + "\n", encoding="utf-8")
    return Path(tmp)


results = {}
for vlabel, body in VARIANTS.items():
    with tempfile.TemporaryDirectory(prefix="curlprobe-") as tmp:
        root = build_root(tmp, body)
        out = Path(tmp) / "receipt.json"
        rc.request_body = lambda url, **kw: (200, body, None)
        rc.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
        buf = io.StringIO()
        try:
            with contextlib.redirect_stdout(buf):
                code = rc.main(["--root", str(root), "--observe", str(out)])
            stdout = buf.getvalue()
        except BaseException as exc:  # noqa: BLE001 - record traceback presence
            stdout = "PROBE-EXCEPTION %s: %s\n" % (exc.__class__.__name__, exc)
            code = "EXC"
        receipt = {}
        if out.exists():
            doc = json.loads(out.read_text(encoding="utf-8"))
            for rec in doc.get("observations", []):
                if rec.get("id") == "S029":
                    receipt = rec
        results[vlabel] = {
            "exit": code,
            "stdout": stdout.strip().splitlines(),
            "receipt": receipt,
        }

print("=== %s :: tree=%s ===" % (LABEL, TREE))
for vlabel in VARIANTS:
    r = results[vlabel]
    cats = [ln for ln in r["stdout"] if ln.startswith(("NON-CANONICAL", "RECEIPT-MISMATCH",
                                                        "INCONSISTENT", "REGRESSION", "DERIVATION",
                                                        "RELEASE_CLOCK:"))]
    trace = any("Traceback" in ln for ln in r["stdout"])
    rec = r["receipt"]
    print("%-16s exit=%-4s traceback=%s cats=%s" % (vlabel, r["exit"], trace, cats))
    print("%-16s receipt verdict=%r parsed_version=%r error=%r" % (
        "", rec.get("verdict"), rec.get("parsed_version"), rec.get("error")))
    for ln in r["stdout"]:
        if ln.startswith("RELEASE_CLOCK:"):
            print("%-16s %s" % ("", ln))
json.dump(results, open("/fast/scratch/hyaku/kagi-r28/FTextZero/results-%s.json" % LABEL, "w"),
          indent=1, sort_keys=True)
