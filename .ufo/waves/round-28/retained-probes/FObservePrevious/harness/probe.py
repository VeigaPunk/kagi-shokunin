#!/usr/bin/env python3
"""FObservePrevious probe 2: round-trip (observe writes receipt -> verify reads
it with --receipt/--receipt-sha) plus token-form edge cases on the previous
table observation.

Usage: probe.py <tree> <outdir>
"""
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
OUT = Path(sys.argv[2]).resolve()
OUT.mkdir(parents=True, exist_ok=True)
FIXTURE_ROW, FEED_SOURCE = "S040", "S039"
FEED_URL = "https://www.python.org/downloads/feed.rss"


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (t, i) for i, t in enumerate(titles))
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<feed xmlns="http://www.w3.org/2005/Atom">\n'
            "  <title>Python releases (fixture)</title>\n"
            "  <id>https://www.python.org/downloads/feed.rss</id>\n"
            "  <updated>2026-10-21T00:00:00Z</updated>\n"
            + entries + "</feed>\n").encode("utf-8")


def narrow_sources(text, keep):
    kept = []
    for line in text.splitlines(keepends=True):
        s = line.strip()
        if s.startswith("|"):
            cells = [c.strip() for c in s[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) and cells[0] not in keep:
                continue
        kept.append(line)
    return "".join(kept)


def stage(name, prev_obs, feed_titles, verdict="not-fired"):
    root = OUT / ("root-" + name)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "SOURCES.md").write_text(
        narrow_sources((TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8"),
                       {FIXTURE_ROW, FEED_SOURCE}), encoding="utf-8")
    rows = []
    for line in (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True):
        f = line.rstrip("\n").split("\t")
        if f and f[0] == FIXTURE_ROW:
            f[5] = prev_obs
            f[7] = verdict
            rows.append("\t".join(f) + "\n")
        elif f and f[0] != "id" and not line.startswith("#"):
            continue
        else:
            rows.append(line)
    (root / "corpus" / "release-clocks.tsv").write_text("".join(rows), encoding="utf-8")
    feed = OUT / ("feed-%s.xml" % name)
    feed.write_bytes(atom_feed(feed_titles))
    return root, feed


RUNNER = '''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url = sys.argv[1:6]
spec = importlib.util.spec_from_file_location("rc_fixture", Path(tree)/"corpus"/"release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
feed_bytes = Path(feed_file).read_bytes()
def rb(url, opener=None, resolver=None):
    if url == feed_url: return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
m.request_body = rb
m.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
raise SystemExit(m.main(["--root", root, "--observe", out]))
'''

runner = OUT / "runner.py"
runner.write_text(RUNNER)

CASES = [
    ("zero", "3.15.01", ["Python 3.15.1"]),
    ("oversize", "3.15." + "1" * 4301, ["Python 3.15.1"]),
    ("lead-zero-first", "03.15.1", ["Python 3.15.1"]),
    ("nineteen-digits", "3.15.1234567890123456789", ["Python 3.15.1"]),
    ("underscore-int", "3.1_0.1", ["Python 3.15.1"]),
    ("unicode-digits", "3.١٥.1", ["Python 3.15.1"]),
    ("four-components", "3.15.1.1", ["Python 3.15.1"]),
    ("canonical", "3.15.1", ["Python 3.15.1"]),
    ("zero-fresh-feed", "3.15.01", ["Python 3.15.2"]),
]

summary = {}
for name, prev_obs, titles in CASES:
    root, feed = stage(name, prev_obs, titles)
    receipt = OUT / ("receipt-%s.json" % name)
    proc = subprocess.run(
        [sys.executable, "-I", "-B", str(runner), str(TREE), str(root), str(receipt),
         str(feed), FEED_URL], text=True, capture_output=True)
    rec = {}
    if receipt.exists():
        doc = json.loads(receipt.read_text(encoding="utf-8"))
        for r in doc.get("observations", []):
            if r.get("id") == FIXTURE_ROW:
                rec = r
    findings = [ln for ln in proc.stdout.splitlines()
                if re.match(r"^[A-Z-]+ S\d{3}$", ln)]
    tb = "Traceback" in proc.stdout + proc.stderr
    # round trip: verify the freshly written receipt via --receipt/--receipt-sha
    rt = ""
    if receipt.exists():
        digest = hashlib.sha256(receipt.read_bytes()).hexdigest()
        rp = subprocess.run(
            [sys.executable, "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
             "--root", str(root), "--receipt", str(receipt), "--receipt-sha", digest],
            text=True, capture_output=True)
        rt = "exit=%d findings=%s tb=%s" % (
            rp.returncode,
            [ln for ln in rp.stdout.splitlines() if re.match(r"^[A-Z-]+ S\d{3}$", ln)],
            "Traceback" in rp.stdout + rp.stderr)
    summary[name] = {
        "prev_obs": prev_obs[:24] + ("..." if len(prev_obs) > 24 else ""),
        "observe_exit": proc.returncode,
        "observe_findings": findings,
        "traceback": tb,
        "receipt_verdict": rec.get("verdict"),
        "receipt_error": (rec.get("error") or "")[:60],
        "receipt_parsed": rec.get("parsed_version"),
        "roundtrip": rt,
    }
    print("=== %s prev_obs=%s ===" % (name, prev_obs[:30]))
    print(json.dumps(summary[name], indent=2, sort_keys=True))
print("--- SUMMARY ---")
print(json.dumps(summary, indent=2, sort_keys=True))
