#!/usr/bin/env python3
"""FObsHuge probe 4: --observe path with a 4301-digit patch, and token size
robustness (100k digits) for the same table-observation carrier.

(a) --observe over a table whose S040 row carries the oversize token: the
    written receipt must carry NO 'fired' verdict and no parsed_version.
(b) a 100k-digit component: still typed, still no traceback, and bounded time
    (no ReDoS / no quadratic blowup).
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

src = Path(sys.argv[1]).resolve()
work = Path(sys.argv[2]).resolve()
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")

RUNNER = r'''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("rc", Path(tree)/"corpus"/"release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
feed = Path(feed_file).read_bytes()
def rb(url, opener=None, resolver=None):
    return (200, feed, None) if url == feed_url else (None, None, "unexpected fetch")
m.request_body = rb
m.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(m.main(["--root", root, "--observe", out]))
'''

ATOM = """<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Python releases (fixture)</title>
  <id>https://www.python.org/downloads/feed.rss</id>
  <updated>2026-10-21T00:00:00Z</updated>
  <entry><title>Python 3.15.1</title><id>https://www.python.org/downloads/release/x/</id><updated>2026-10-21T00:00:00Z</updated></entry>
</feed>
"""


def stage(name, token):
    root = work / name
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(src / "corpus" / rel, root / "corpus" / rel)
    lines = (src / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == "S040":
            fields[5] = token
            fields[7] = "fired"
        out.append("\t".join(fields) + "\n")
    (root / "corpus" / "release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    feed = root / "feed.atom"
    feed.write_text(ATOM, encoding="utf-8")
    return root


def observe(root, token):
    runner = work / "runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    out = root / "observe-out.json"
    feed_url = "https://www.python.org/downloads/feed.rss"
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(work),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    start = time.time()
    proc = subprocess.run(
        ["python3", "-I", "-B", str(runner), str(src), str(root), str(out),
         str(root / "feed.atom"), feed_url, "2026-10-21"],
        cwd=str(src), env=env, text=True, capture_output=True, timeout=180)
    elapsed = time.time() - start
    fired = None
    record = None
    if out.exists():
        document = json.loads(out.read_text(encoding="utf-8"))
        for r in document.get("observations", []):
            if r.get("id") == "S040":
                record = r
        fired = any(r.get("id") == "S040" and r.get("verdict") == "fired"
                    for r in document.get("observations", []))
    print("### observe, token len=%d" % len(token))
    print("exit=%d elapsed=%.2fs traceback=%s" % (
        proc.returncode, elapsed, "Traceback" in proc.stdout + proc.stderr))
    print("stdout=%s" % json.dumps(proc.stdout.splitlines()))
    print("stderr=%s" % json.dumps(proc.stderr.splitlines()[-3:]))
    print("s040_record=%s" % json.dumps(record))
    print("fired_written=%s" % fired)
    print()


if __name__ == "__main__":
    work.mkdir(parents=True, exist_ok=True)
    for label, token in (("4301-digit", "3.15." + "1" * 4301),
                         ("100k-digit", "3.15." + "1" * 100000)):
        root = stage("obs-" + label, token)
        observe(root, token)
