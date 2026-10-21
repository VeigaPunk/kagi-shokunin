#!/usr/bin/env python3
"""Final reproduction: receipt parsed_version malformed while the table stays canonical.

Runs each receipt-carrier fixture against the exported candidate tree
(62a33b1bd15217ed729df2ca40c8a30aba3076c0) and the exported BASE tree
(3553d499577084a6c98d7078906017840bbf7b28), then classifies each run with the
frozen round-28 C1 predicate taken from
cand/.ufo/waves/round-28/tools/c1-measure.py (classify(), unmodified).

No network is used: every run is `--receipt <file> --receipt-sha <sha256>`.
"""
import hashlib
import importlib.util
import json
import pathlib
import subprocess
import sys

SCRATCH = pathlib.Path("/fast/scratch/hyaku/kagi-r28/FReceiptToken")
LANE = pathlib.Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
OUT = LANE / ".ufo/waves/round-28/sandboxes/FReceiptToken"

spec = importlib.util.spec_from_file_location(
    "c1m", SCRATCH / "cand/.ufo/waves/round-28/tools/c1-measure.py")
c1m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c1m)

FEED = "https://www.python.org/downloads/feed.rss"
FIXTURES = [
    ("RC0-control", "table canonical, receipt canonical (control)"),
    ("RC1-leading-zero", "receipt S040 parsed_version=3.15.01; table canonical"),
    ("RC2-oversize", "receipt S040 parsed_version=3.15.+4301x'1'; table canonical"),
    ("RC3-fired-row-leading-zero", "receipt S027 parsed_version=3.15.01 (fired row)"),
    ("RC4-quote-row-parsed", "receipt S005 parsed_version=3.15.01 (quote clock)"),
    ("RC5-typed-error-control", "receipt S040 error='non-canonical version token: ...'"),
    ("RC7-huge-json-number", "receipt S040 parsed_version=<4301-digit JSON number>"),
    ("RC8-small-json-number", "receipt S040 parsed_version=315 (JSON number)"),
]

log = []
for tree in ("cand", "base"):
    log.append("=== tree %s ===" % tree)
    for name, desc in FIXTURES:
        path = SCRATCH / "fixtures" / (name + ".json")
        sha = hashlib.sha256(path.read_bytes()).hexdigest()
        proc = subprocess.run(
            [sys.executable, "-I", "-B", str(SCRATCH / tree / "corpus/release-clock.py"),
             "--root", str(SCRATCH / tree), "--receipt", str(path), "--receipt-sha", sha],
            capture_output=True, text=True)
        res = {"exit": proc.returncode, "stdout": proc.stdout, "stderr": proc.stderr}
        c1m.classify(res, "S040", FEED)
        tail = [l for l in proc.stdout.splitlines() if l.strip() and not l.startswith("NOT OBSERVED")]
        log.append("%-30s %-9s exit=%d frozen_verdict=%s traceback=%s" % (
            name, tree, proc.returncode, res["verdict"], res["traceback_in_output"]))
        log.append("    %s" % desc)
        log.append("    stdout: %s" % " | ".join(tail))
        if proc.stderr.strip():
            log.append("    stderr(last): %s" % proc.stderr.strip().splitlines()[-1])
        if res["typed_finding_lines"]:
            log.append("    typed findings: %s" % res["typed_finding_lines"])

# RC6: table AND receipt carry the same malformed token (the frozen F1/F2 shape)
sha = hashlib.sha256((SCRATCH / "fixtures/RC6-mirrored-table-and-receipt.json").read_bytes()).hexdigest()
proc = subprocess.run(
    [sys.executable, "-I", "-B", str(SCRATCH / "cand-mirror/corpus/release-clock.py"),
     "--root", str(SCRATCH / "cand-mirror"),
     "--receipt", str(SCRATCH / "fixtures/RC6-mirrored-table-and-receipt.json"),
     "--receipt-sha", sha], capture_output=True, text=True)
log.append("=== RC6 (table S040 observed=3.15.01 AND receipt S040 parsed=3.15.01) ===")
log.append("exit=%d" % proc.returncode)
log.append("stdout: %s" % " | ".join(
    l for l in proc.stdout.splitlines() if l.strip() and not l.startswith("NOT OBSERVED")))

text = "\n".join(log) + "\n"
(OUT / "run-log.txt").write_text(text)
print(text)
