#!/usr/bin/env python3
"""Secondary curl Version-line forms: trailing blanks, a later Version line,
and the canonical-first / leading-zero-second ordering."""
import contextlib
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
HEADER = S029_ROW = None
for line in (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines():
    if line.startswith("id\t"):
        HEADER = line
    elif line.startswith("S029\t"):
        S029_ROW = line

VARIANTS = {
    "lz_trailing_blanks": b"Version: 8.23.01   \nDate: 2026-10-14\n",
    "lz_v_prefix": b"Version: v8.23.01\nDate: 2026-10-14\n",
    "lz_second_after_ok": b"Version: 8.23.0\nVersion: 8.23.01\nDate: 2026-10-14\n",
    "lz_second_after_ok_hi": b"Version: 8.23.0\nVersion: 8.23.99\nDate: 2026-10-14\n",
    "ctrl_second_after_ok": b"Version: 8.23.0\nVersion: 8.22.0\nDate: 2026-10-14\n",
}

spec = importlib.util.spec_from_file_location("rc3", str(TREE / "corpus" / "release-clock.py"))
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

print("=== %s :: tree=%s ===" % (LABEL, TREE))
for vlabel, body in VARIANTS.items():
    with tempfile.TemporaryDirectory(prefix="curl3-") as tmp:
        root = Path(tmp)
        corpus = root / "corpus"
        corpus.mkdir()
        (corpus / "SOURCES.md").write_text(
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |\n"
            "|---|---|---|---|---|---|---|---|---|---|---|\n"
            + S029_SOURCE + "\n" + S037_SOURCE + "\n", encoding="utf-8")
        tsv = corpus / "release-clocks.tsv"
        tsv.write_text(HEADER + "\n" + S029_ROW + "\n", encoding="utf-8")
        before = tsv.read_bytes()
        out = root / "receipt.json"
        rc.request_body = lambda url, **kw: (200, body, None)
        rc.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            code = rc.main(["--root", str(root), "--observe", str(out)])
        stdout = buf.getvalue()
        rec = {}
        for r in json.loads(out.read_text(encoding="utf-8"))["observations"]:
            if r["id"] == "S029":
                rec = r
        tsv_after = tsv.read_bytes()
        cats = [ln for ln in stdout.strip().splitlines()
                if ln.startswith(("NON-CANONICAL", "RECEIPT-MISMATCH", "INCONSISTENT", "REGRESSION",
                                  "DERIVATION", "RELEASE_CLOCK:"))]
        print("%-20s exit=%-3s tsv_mutated=%s traceback=%s" % (
            vlabel, code, tsv_after != before, "Traceback" in stdout))
        for ln in cats:
            print("%-20s   %s" % ("", ln))
        print("%-20s   receipt verdict=%r parsed=%r error=%r" % (
            "", rec.get("verdict"), rec.get("parsed_version"), rec.get("error")))
