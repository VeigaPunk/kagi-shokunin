#!/usr/bin/env python3
"""FAnchorZero feed-side probe: SOPS feed S033 whose newest stable entry is a
non-canonical token, observed through the S008 derived row.

Usage: feed_probe.py <tree-root> <label> <title>
"""
import contextlib
import importlib.util
import io
import json
import shutil
import sys
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
LABEL = sys.argv[2]
TITLE = sys.argv[3]
WORK = TREE.parent / ("feed-" + LABEL + "-" + TITLE[:8].replace(".", "_"))
if WORK.exists():
    shutil.rmtree(WORK)
ROOT = WORK / "root"
(ROOT / "corpus").mkdir(parents=True)

lines = (TREE / "corpus" / "SOURCES.md").read_text(
    encoding="utf-8").splitlines(keepends=True)
kept = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith("|"):
        cells = [c.strip() for c in stripped[1:].split("|")]
        if cells and cells[0] not in ("S008", "S033"):
            continue
    kept.append(line)
(ROOT / "corpus" / "SOURCES.md").write_text("".join(kept), encoding="utf-8")
for rel in ("source-fetches.tsv", "rendered-text-v1.py"):
    shutil.copy2(TREE / "corpus" / rel, ROOT / "corpus" / rel)
table = (TREE / "corpus" / "release-clocks.tsv").read_text(
    encoding="utf-8").splitlines(keepends=True)
out = []
for line in table:
    fields = line.rstrip("\n").split("\t")
    if fields and fields[0] != "id" and fields[0] != "S008":
        continue
    out.append(line)
(ROOT / "corpus" / "release-clocks.tsv").write_text("".join(out), encoding="utf-8")

FEED = ('<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        '  <entry><title>%s</title>'
        '<id>https://github.com/getsops/sops/releases/tag/x</id></entry>\n'
        '</feed>\n' % TITLE).encode("utf-8")

spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", TREE / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def fixture_request_body(url, opener=None, resolver=None):
    if url == "https://github.com/getsops/sops/releases.atom":
        return 200, FEED, None
    return None, None, "fixture harness: unexpected URL fetch %s" % url


module.request_body = fixture_request_body
module.utc_timestamp = lambda: "2026-10-21T13:43:21Z"
OUT = ROOT / "observed.json"
stdout = io.StringIO()
try:
    with contextlib.redirect_stdout(stdout):
        code = module.main(["--root", str(ROOT), "--observe", str(OUT)])
except SystemExit as exc:
    code = exc.code
print("=== feed %s title=%r exit=%r ===" % (LABEL, TITLE, code))
for line in stdout.getvalue().splitlines():
    print("  out: %s" % line)
if OUT.exists():
    doc = json.loads(OUT.read_text(encoding="utf-8"))
    for record in doc["observations"]:
        print("  receipt %s: verdict=%r parsed=%r error=%r" % (
            record.get("id"), record.get("verdict"),
            record.get("parsed_version"), record.get("error")))
