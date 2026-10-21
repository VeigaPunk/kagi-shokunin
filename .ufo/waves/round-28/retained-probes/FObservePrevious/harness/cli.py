#!/usr/bin/env python3
"""FObservePrevious: honest CLI runs. Prepares a fixture tree and then invokes
the tree's OWN corpus/release-clock.py --observe as a separate process (no
in-process wrapper), so the reported exit code is the real CLI exit code.

Usage: cli.py <tree> <outdir>
"""
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
OUT = Path(sys.argv[2]).resolve()
OUT.mkdir(parents=True, exist_ok=True)
ROW, FEED_ROW = "S040", "S039"
FEED_URL = "https://www.python.org/downloads/feed.rss"

FEED = ('<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        "  <entry>\n    <title>Python 3.15.2</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-0/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        "</feed>\n").encode("utf-8")


def narrow(text, keep):
    out = []
    for line in text.splitlines(keepends=True):
        s = line.strip()
        if s.startswith("|"):
            c = [x.strip() for x in s[1:].split("|")]
            if c and re.fullmatch(r"S[0-9]{3}", c[0]) and c[0] not in keep:
                continue
        out.append(line)
    return "".join(out)


def build(name, prev_obs):
    root = OUT / ("root-" + name)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "SOURCES.md").write_text(
        narrow((TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8"),
               {ROW, FEED_ROW}), encoding="utf-8")
    rows = []
    for line in (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True):
        f = line.rstrip("\n").split("\t")
        if f and f[0] == ROW:
            f[5] = prev_obs
            rows.append("\t".join(f) + "\n")
        elif f and f[0] != "id" and not line.startswith("#"):
            continue
        else:
            rows.append(line)
    (root / "corpus" / "release-clocks.tsv").write_text("".join(rows), encoding="utf-8")
    return root


# A sitecustomize-free transport stub: the script's own request_body is
# replaced by importing the module and calling its main() -- but the exit code
# is then the module's own return, not a shell exit. To keep the CLI honest we
# instead run a child that imports the module and calls main(), and the child
# re-raises SystemExit(code) so the shell sees the module's return value.
CHILD = '''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url = sys.argv[1:6]
spec = importlib.util.spec_from_file_location("rc", Path(tree)/"corpus"/"release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
fb = Path(feed_file).read_bytes()
def rb(url, opener=None, resolver=None):
    if url == feed_url: return 200, fb, None
    return None, None, "fixture harness: unexpected URL fetch"
m.request_body = rb
m.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
raise SystemExit(m.main(["--root", root, "--observe", out]))
'''
child = OUT / "child.py"
child.write_text(CHILD)

CASES = [
    ("prev-leading-zero", "3.15.01"),
    ("prev-oversize", "3.15." + "1" * 4301),
    ("prev-canonical", "3.15.1"),
]
for name, prev in CASES:
    root = build(name, prev)
    feed = OUT / ("feed-%s.xml" % name)
    feed.write_bytes(FEED)
    out = OUT / ("receipt-%s.json" % name)
    if out.exists():
        out.unlink()
    p = subprocess.run([sys.executable, "-I", "-B", str(child), str(TREE), str(root),
                        str(out), str(feed), FEED_URL], text=True, capture_output=True)
    findings = [ln for ln in p.stdout.splitlines() if re.match(r"^[A-Z-]+ S\d{3}$", ln)]
    rec = None
    if out.exists():
        for r in json.loads(out.read_text())["observations"]:
            if r.get("id") == ROW:
                rec = {k: r.get(k) for k in ("verdict", "parsed_version", "error")}
    print("CASE %-18s prev_obs=%s" % (name, prev[:26] + ("..." if len(prev) > 26 else "")))
    print("  exit=%d findings=%s traceback=%s" % (p.returncode, findings, "Traceback" in p.stdout + p.stderr))
    print("  receipt S040=%s" % json.dumps(rec, sort_keys=True))
    for ln in p.stdout.splitlines():
        if ln.startswith("RELEASE_CLOCK"):
            print("  ", ln)
    if p.stderr.strip():
        print("  stderr:", p.stderr.strip().splitlines()[-1])
