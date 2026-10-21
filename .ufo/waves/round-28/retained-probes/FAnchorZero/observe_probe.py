#!/usr/bin/env python3
"""FAnchorZero observe-path probe for the derived S008 carrier.

Runs the tree's own release-clock.py main() with the module-global
request_body replaced by a local stub that serves fixture feed bytes (the
same substitution the script's own selftest uses), so no network is used.

Usage: observe_probe.py <tree-root> <label> <mode>
  mode = anchor | control
    anchor : S008's anchored_version and observed_version are 3.13.03
    control: S008's row is verbatim (anchored/observed 3.13.3)
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
MODE = sys.argv[3]
WORK = TREE.parent / ("observe-" + LABEL)
if WORK.exists():
    shutil.rmtree(WORK)
ROOT = WORK / "root"
(ROOT / "corpus").mkdir(parents=True)

SRC = TREE / "corpus" / "SOURCES.md"
lines = SRC.read_text(encoding="utf-8").splitlines(keepends=True)
kept = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith("|"):
        cells = [c.strip() for c in stripped[1:].split("|")]
        if cells and cells[0] not in ("S008", "S033"):
            continue
    kept.append(line)
(ROOT / "corpus" / "SOURCES.md").write_text("".join(kept), encoding="utf-8")
shutil.copy2(TREE / "corpus" / "source-fetches.tsv", ROOT / "corpus" / "source-fetches.tsv")
shutil.copy2(TREE / "corpus" / "rendered-text-v1.py", ROOT / "corpus" / "rendered-text-v1.py")

table = (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
out = []
for line in table:
    fields = line.rstrip("\n").split("\t")
    if fields and fields[0] == "S008":
        if MODE == "anchor":
            fields[4] = "3.13.03"
            fields[5] = "3.13.03"
        out.append("\t".join(fields) + "\n")
    elif fields and fields[0] != "id":
        continue
    else:
        out.append(line)
(ROOT / "corpus" / "release-clocks.tsv").write_text("".join(out), encoding="utf-8")

FEED = (b'<?xml version="1.0" encoding="utf-8"?>\n'
        b'<feed xmlns="http://www.w3.org/2005/Atom">\n'
        b'  <entry><title>v3.13.3</title>'
        b'<id>https://github.com/getsops/sops/releases/tag/v3.13.3</id></entry>\n'
        b'</feed>\n')

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
print("=== observe %s (%s) ===" % (LABEL, MODE))
print("exit=%r" % (code,))
for line in stdout.getvalue().splitlines():
    print("  out: %s" % line)
if OUT.exists():
    doc = json.loads(OUT.read_text(encoding="utf-8"))
    for record in doc["observations"]:
        print("  receipt %s: verdict=%r parsed_version=%r error=%r" % (
            record.get("id"), record.get("verdict"),
            record.get("parsed_version"), record.get("error")))
else:
    print("  (no receipt written)")
