#!/usr/bin/env python3
"""Probe 3: does a NON-CANONICAL feed entry that is NOT the newest entry still
get a typed finding?

plans/round-28.md C1 (frozen text): "a version token used for an anchor, a
table observation or a feed entry must be canonical (no leading zero in a
multi-digit component, SemVer S042 §2) and bounded; otherwise the row or feed
gets a typed finding (exit 1), never a release event and never a traceback."

The candidate's newest_stable() (corpus/release-clock.py:784-798) only raises
when a non-canonical token orders AT OR ABOVE the newest canonical token; a
non-canonical token strictly BELOW it is silently dropped. Probe:

  E1  feed entries: "Python 3.15.5" (canonical) + "Python 3.14.01"
      (leading zero, BELOW newest)  -> ?
  E2  feed entries: "Python 3.15.5" (canonical) + "Python 3.14." + 4301*"1"
      (oversize, BELOW newest)      -> ?
  E3  control: "Python 3.15.5" only  -> parsed 3.15.5

Baseline: BASE (3553d49) behaviour of the same feeds, for the "before" column.
"""
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
CAND = SANDBOX / "cand"
BASE = SANDBOX / "base"
OVERSIZE = "1" * 4301

RUNNER = r'''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("rc_fixture", Path(tree) / "corpus" / "release-clock.py")
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


def env_for(tmp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(tmp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def narrow(tree, keep_ids, src_keep):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    tbl = "".join(l for l in lines
                  if l.split("\t")[0] == "id" or l.split("\t")[0] in keep_ids)
    slines = (tree / "corpus" / "SOURCES.md").read_text(
        encoding="utf-8").splitlines(keepends=True)
    src = []
    for line in slines:
        s = line.strip()
        if s.startswith("|"):
            cells = [c.strip() for c in s[1:].split("|")]
            if cells and cells[0].startswith("S") and cells[0][1:].isdigit() \
                    and cells[0] not in src_keep:
                continue
        src.append(line)
    return tbl, "".join(src)


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n" % (t, i)
        for i, t in enumerate(titles))
    doc = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<feed xmlns="http://www.w3.org/2005/Atom">\n'
           "  <title>Python releases (fixture)</title>\n"
           "  <id>https://www.python.org/downloads/feed.rss</id>\n"
           "  <updated>2026-10-21T00:00:00Z</updated>\n" + entries + "</feed>\n")
    return doc.encode("utf-8")


def run_case(tree, tmp, name, titles):
    tbl, src = narrow(tree, {"S040"}, {"S040", "S039"})
    root = tmp / name
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "SOURCES.md").write_text(src, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(tbl, encoding="utf-8")
    feed = root / "feed.atom"
    feed.write_bytes(atom_feed(titles))
    outp = root / "obs.json"
    env = env_for(tmp)
    t0 = time.time()
    p = subprocess.run(
        ["python3", "-I", "-B", str(tmp / "runner.py"), str(tree), str(root),
         str(outp), str(feed),
         "https://www.python.org/downloads/feed.rss", "2026-10-21"],
        env=env, text=True, capture_output=True, timeout=300)
    rec = None
    try:
        doc = json.loads(outp.read_text(encoding="utf-8"))
        rec = [{"id": r.get("id"), "verdict": r.get("verdict"),
                "error": r.get("error"), "parsed_version": r.get("parsed_version")}
               for r in doc.get("observations", [])]
    except Exception as exc:
        rec = "receipt-read-error: %s" % exc.__class__.__name__
    raw = outp.read_text(encoding="utf-8") if outp.exists() else ""
    return {
        "exit": p.returncode, "secs": round(time.time() - t0, 3),
        "stdout": p.stdout.splitlines(), "stderr": p.stderr.splitlines(),
        "receipt": rec,
        "receipt_echoes_over": OVERSIZE in raw,
        "receipt_echoes_leadzero": "3.14.01" in raw,
    }


def main():
    tmp = Path(tempfile.mkdtemp(prefix="r28-probe3-", dir=str(SANDBOX)))
    (tmp / "runner.py").write_text(RUNNER, encoding="utf-8")
    feeds = {
        "E1-leadzero-below": ["Python 3.15.5", "Python 3.14.01"],
        "E2-oversize-below": ["Python 3.15.5", "Python 3.14." + OVERSIZE],
        "E3-control": ["Python 3.15.5"],
    }
    out = {}
    for label, tree in (("cand", CAND), ("base", BASE)):
        for name, titles in feeds.items():
            out["%s:%s" % (label, name)] = run_case(tree, tmp, name + "-" + label, titles)
    shutil.rmtree(tmp, ignore_errors=True)
    (SANDBOX / "probe3-result.json").write_text(
        json.dumps(out, indent=2) + "\n", encoding="utf-8")
    for k, v in out.items():
        print("== %s exit=%s secs=%s" % (k, v["exit"], v["secs"]))
        for l in v["stdout"]:
            print("   OUT| %s" % l[:220])
        for l in v["stderr"][:6]:
            print("   ERR| %s" % l[:220])
        print("   REC| %s" % json.dumps(v["receipt"])[:400])
        print("   echoes_oversize=%s echoes_leadzero=%s" % (
            v["receipt_echoes_over"], v["receipt_echoes_leadzero"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
