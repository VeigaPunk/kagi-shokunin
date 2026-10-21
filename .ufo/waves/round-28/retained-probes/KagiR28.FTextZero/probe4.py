#!/usr/bin/env python3
"""Byte-exact curl.se/info carrier probe.

Uses the retained upstream body (352 B, sha256 cfa106be..., LF endings) from
.ufo/waves/round-26/build/ClockS029-evidence/info.body of the tree under test
and mutates ONLY the version token, so the fixture is byte-faithful to the
committed capture.

Usage: probe4.py <tree-root> <label>
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
BODY_PATH = TREE / ".ufo" / "waves" / "round-26" / "build" / "ClockS029-evidence" / "info.body"
REAL = BODY_PATH.read_bytes()

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
    "real_body": REAL,
    # only the Version-line token is zero-padded
    "lz_version_line": REAL.replace(b"Version: 8.23.0\n", b"Version: 8.23.01\n", 1),
    # a non-canonical token in a NON-Version line (download URL), Version line intact
    "lz_download_url": REAL.replace(b"curl-8.23.0.tar.gz", b"curl-8.23.01.tar.gz", 1),
    # leading-zero token in the Changelog URL line, Version line intact
    "lz_changelog_url": REAL.replace(b"curl.se/ch/8.23.0.html", b"curl.se/ch/8.23.01.html", 1),
}

spec = importlib.util.spec_from_file_location("rc4", str(TREE / "corpus" / "release-clock.py"))
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

print("=== %s :: tree=%s ===" % (LABEL, TREE))
print("real body sha256=%s bytes=%d" % (hashlib.sha256(REAL).hexdigest(), len(REAL)))
for vlabel, body in VARIANTS.items():
    with tempfile.TemporaryDirectory(prefix="curl4-") as tmp:
        root = Path(tmp)
        corpus = root / "corpus"
        corpus.mkdir()
        (corpus / "SOURCES.md").write_text(
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |\n"
            "|---|---|---|---|---|---|---|---|---|---|---|\n"
            + S029_SOURCE + "\n" + S037_SOURCE + "\n", encoding="utf-8")
        (corpus / "release-clocks.tsv").write_text(
            HEADER + "\n" + S029_ROW + "\n", encoding="utf-8")
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
        cats = [ln for ln in stdout.strip().splitlines()
                if ln.startswith(("NON-CANONICAL", "RECEIPT-MISMATCH", "INCONSISTENT", "REGRESSION",
                                  "DERIVATION", "RELEASE_CLOCK:"))]
        print("%-18s exit=%-3s traceback=%s body_sha=%s" % (
            vlabel, code, "Traceback" in stdout, hashlib.sha256(body).hexdigest()[:16]))
        for ln in cats:
            print("%-18s   %s" % ("", ln))
        print("%-18s   receipt verdict=%r parsed=%r error=%r" % (
            "", rec.get("verdict"), rec.get("parsed_version"), rec.get("error")))
