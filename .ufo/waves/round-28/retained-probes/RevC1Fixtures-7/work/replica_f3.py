#!/usr/bin/env python3
"""Replicate the frozen instrument's F3/F4 fixture construction exactly,
against a caller-supplied tree (BASE, patched, or mutated-patched).

usage: replica_f3.py TREE OUT_DIR
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

tree = Path(sys.argv[1]).resolve()
out_dir = Path(sys.argv[2]).resolve()
FIXTURE_ROW = "S040"
OVERSIZE = "1" * 4301
RUNNER = r'''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("rc_fixture", Path(tree)/"corpus/release-clock.py")
module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n" % (t, i)
        for i, t in enumerate(titles))
    document = ('<?xml version="1.0" encoding="utf-8"?>\n'
                '<feed xmlns="http://www.w3.org/2005/Atom">\n'
                '  <title>Python releases (fixture)</title>\n'
                '  <id>https://www.python.org/downloads/feed.rss</id>\n'
                '  <updated>2026-10-21T00:00:00Z</updated>\n' + entries + "</feed>\n")
    return document.encode("utf-8")


def edited_table(edits, narrow):
    lines = (tree/"corpus/release-clocks.tsv").read_text().splitlines(keepends=True)
    kept = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            fields[5], fields[7] = edits[fields[0]]
            kept.append("\t".join(fields) + "\n")
        elif narrow and (not fields or fields[0] != "id"):
            continue
        else:
            kept.append(line)
    return "".join(kept)


def narrowed_sources(keep_ids):
    lines = (tree/"corpus/SOURCES.md").read_text().splitlines(keepends=True)
    kept = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [c.strip() for c in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) and cells[0] not in keep_ids:
                continue
        kept.append(line)
    return "".join(kept)


def build(name, observed, titles):
    root = out_dir/("fixture-"+name)
    if root.exists():
        shutil.rmtree(root)
    (root/"corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(tree/"corpus"/rel, root/"corpus"/rel)
    table = edited_table({FIXTURE_ROW: (observed, "fired")}, True)
    fields = next(l.split("\t") for l in table.splitlines() if l.startswith(FIXTURE_ROW))
    feed_url, observed_at, feed_source_id = fields[3], fields[6], fields[2]
    (root/"corpus/SOURCES.md").write_text(narrowed_sources({FIXTURE_ROW, feed_source_id}))
    (root/"corpus/release-clocks.tsv").write_text(table)
    feed = root/"feed.atom"; feed.write_bytes(atom_feed(titles))
    runner = out_dir/"observe-runner.py"; runner.write_text(RUNNER)
    out_receipt = root/"observe-out.json"
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(out_dir),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    proc = subprocess.run(["python3", "-I", "-B", str(runner), str(tree), str(root),
                           str(out_receipt), str(feed), feed_url, observed_at],
                          cwd=tree, env=env, text=True, capture_output=True, timeout=180)
    receipt = json.loads(out_receipt.read_text()) if out_receipt.exists() else {}
    record = next((r for r in receipt.get("observations", []) if r.get("id") == FIXTURE_ROW), None)
    combined = proc.stdout + "\n" + proc.stderr
    findings = [l.strip() for l in proc.stdout.splitlines()
                if l.strip() and not l.strip().startswith("RELEASE_CLOCK")
                and (FIXTURE_ROW in l or feed_url in l)
                and l.strip().split()[0] not in {"ORPHAN", "UNBOUND", "INCONSISTENT",
                                                "BADFEED", "REGRESSED", "RECEIPT-MISMATCH",
                                                "NOT OBSERVED"}]
    traceback = "Traceback" in combined
    fired = bool(record and record.get("verdict") == "fired")
    if (proc.returncode == 0 and combined.strip()) or traceback:
        verdict = "MISHANDLED"
    elif proc.returncode == 1 and not traceback and findings:
        verdict = "TYPED"
    else:
        verdict = "OTHER"
    print("== %s [%s]" % (name, tree))
    print("   exit=%d traceback=%s fired_observation_written=%s" % (proc.returncode, traceback, fired))
    print("   receipt record: %s" % json.dumps({k: record.get(k) for k in ("parsed_version", "verdict", "error")} if record else None))
    print("   typed finding lines: %s" % findings)
    print("   stdout tail: %s" % [l for l in proc.stdout.splitlines() if l.strip()][-2:])
    if proc.stderr.strip():
        print("   stderr tail: %s" % proc.stderr.strip().splitlines()[-1][:120])
    print("   instrument verdict: %s" % verdict)
    return verdict


out_dir.mkdir(parents=True, exist_ok=True)
build("F3-observe-zero", "3.15.01", ["Python 3.15.01", "Python 3.15.0"])
build("F4-observe-oversize", "3.15."+OVERSIZE, ["Python 3.15."+OVERSIZE, "Python 3.15.0"])
