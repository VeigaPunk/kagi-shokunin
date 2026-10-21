#!/usr/bin/env python3
"""FObservePrevious harness: --observe path where the row's PREVIOUS table
observation (release-clocks.tsv observed_version column) is noncanonical.

Usage: run.py <tree> <variant> <outdir>

variants:
  prev-zero      previous observation = 3.15.01   (leading zero)
  prev-oversize  previous observation = 3.15.<4301 x 1>
  feed-newer     previous observation = 3.15.01, feed newest canonical 3.15.2
  prev-zero-v2   previous observation = 3.15.01 with verdict fired (frozen-table shape)

No network: module.request_body is replaced by a stub that serves the fixture
feed bytes (the substitution release-clock.py's own selftest uses); any other
URL is an error. utc_timestamp is pinned.
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
VARIANT = sys.argv[2]
OUTDIR = Path(sys.argv[3]).resolve()
OUTDIR.mkdir(parents=True, exist_ok=True)

FIXTURE_ROW = "S040"
FEED_SOURCE = "S039"
OVERSIZE = "1" * 4301

FEEDS = {
    # newest canonical stable equals the row anchor
    "prev-zero": [b"Python 3.15.1"],
    "prev-oversize": [b"Python 3.15.1"],
    # newest canonical stable is NEWER than the anchor: at BASE this writes a
    # fired observation for a row whose recorded observation is noncanonical
    "feed-newer": [b"Python 3.15.2"],
    "prev-zero-v2": [b"Python 3.15.1"],
}
PREV_OBS = {
    "prev-zero": "3.15.01",
    "prev-oversize": "3.15." + OVERSIZE,
    "feed-newer": "3.15.01",
    "prev-zero-v2": "3.15.01",
}
VERDICT_EDIT = {"prev-zero-v2": "fired"}


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title.decode("ascii"), index)
        for index, title in enumerate(titles))
    document = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        + entries + "</feed>\n")
    return document.encode("utf-8")


def narrow_sources(text, keep_ids):
    kept = []
    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [cell.strip() for cell in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) and cells[0] not in keep_ids:
                continue
        kept.append(line)
    return "".join(kept)


import re  # noqa: E402  (after helper defs for clarity)

root = OUTDIR / ("root-" + VARIANT)
if root.exists():
    shutil.rmtree(root)
(root / "corpus").mkdir(parents=True)
for rel in ("source-fetches.tsv", "rendered-text-v1.py"):
    shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
(root / "corpus" / "SOURCES.md").write_text(
    narrow_sources((TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8"),
                   {FIXTURE_ROW, FEED_SOURCE}), encoding="utf-8")

lines = (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
out_rows = []
for line in lines:
    fields = line.rstrip("\n").split("\t")
    if fields and fields[0] == FIXTURE_ROW:
        fields[5] = PREV_OBS[VARIANT]
        if VARIANT in VERDICT_EDIT:
            fields[7] = VERDICT_EDIT[VARIANT]
        out_rows.append("\t".join(fields) + "\n")
    elif fields and fields[0] != "id" and not line.startswith("#"):
        continue
    else:
        out_rows.append(line)
(root / "corpus" / "release-clocks.tsv").write_text("".join(out_rows), encoding="utf-8")

feed_bytes = atom_feed(FEEDS[VARIANT])
feed_path = OUTDIR / ("feed-%s.xml" % VARIANT)
feed_path.write_bytes(feed_bytes)

runner = OUTDIR / ("runner-%s.py" % VARIANT)
runner.write_text('''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url = sys.argv[1:6]
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
fetched = []
def fixture_request_body(url, opener=None, resolver=None):
    fetched.append(url)
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fixture_request_body
module.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
try:
    code = module.main(["--root", root, "--observe", out])
except BaseException as exc:
    print("HARNESS_EXC %s: %s" % (type(exc).__name__, exc))
    import traceback; traceback.print_exc()
    code = 99
print("HARNESS_FETCHED %s" % (fetched,))
raise SystemExit(code)
''')

import subprocess  # noqa: E402
proc = subprocess.run(
    [sys.executable, "-I", "-B", str(runner), str(TREE), str(root),
     str(OUTDIR / ("receipt-%s.json" % VARIANT)), str(feed_path),
     "https://www.python.org/downloads/feed.rss"],
    text=True, capture_output=True)
print("=== VARIANT %s (tree=%s) ===" % (VARIANT, TREE.name))
print("EXIT=%d" % proc.returncode)
print("--- stdout ---")
print(proc.stdout, end="")
if proc.stderr.strip():
    print("--- stderr ---")
    print(proc.stderr, end="")
receipt_path = OUTDIR / ("receipt-%s.json" % VARIANT)
if receipt_path.exists():
    doc = json.loads(receipt_path.read_text(encoding="utf-8"))
    for rec in doc.get("observations", []):
        if rec.get("id") == FIXTURE_ROW:
            print("--- receipt record S040 ---")
            print(json.dumps({k: rec.get(k) for k in (
                "id", "http_status", "parsed_version", "verdict", "error", "observed_at")},
                sort_keys=True))
else:
    print("--- no receipt written ---")
