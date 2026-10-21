#!/usr/bin/env python3
"""FObservePrevious probe 3: (a) feed path vs table path asymmetry for a
noncanonical token; (b) the BASE 'fired release' lie for the table path,
mirrored-receipt construction (frozen F1 shape) on both trees."""
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
ROW, FEED_ROW = "S040", "S039"
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
            c = [x.strip() for x in s[1:].split("|")]
            if c and re.fullmatch(r"S[0-9]{3}", c[0]) and c[0] not in keep:
                continue
        kept.append(line)
    return "".join(kept)


def stage(name, prev_obs, verdict, feed_titles, keep=("S040", "S039")):
    root = OUT / ("root-" + name)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "SOURCES.md").write_text(
        narrow_sources((TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8"),
                       set(keep)), encoding="utf-8")
    rows = []
    for line in (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True):
        f = line.rstrip("\n").split("\t")
        if f and f[0] == ROW:
            f[5], f[7] = prev_obs, verdict
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
runner = OUT / "runner.py"
runner.write_text(RUNNER)

print("### (a) feed carries an OLDER noncanonical entry alongside the newest canonical")
for name, titles in (
        ("older-nc", ["Python 3.15.1", "Python 3.14.01"]),
        ("older-nc-oversize", ["Python 3.15.1", "Python 3.14." + "1" * 4301]),
        ("newest-nc", ["Python 3.15.01", "Python 3.15.0"]),
):
    root, feed = stage(name, "3.15.1", "not-fired", titles)
    rec = OUT / ("receipt-%s.json" % name)
    p = subprocess.run([sys.executable, "-I", "-B", str(runner), str(TREE), str(root),
                        str(rec), str(feed), FEED_URL], text=True, capture_output=True)
    findings = [ln for ln in p.stdout.splitlines() if re.match(r"^[A-Z-]+ S\d{3}$", ln)]
    verdict = None
    if rec.exists():
        for r in json.loads(rec.read_text())["observations"]:
            if r.get("id") == ROW:
                verdict = (r.get("verdict"), r.get("parsed_version"), (r.get("error") or "")[:50])
    print("%-20s exit=%d findings=%s receipt(verdict,parsed,err)=%s tb=%s"
          % (name, p.returncode, findings, verdict, "Traceback" in p.stdout + p.stderr))

print()
print("### (b) F1 table-lie shape: observed_version=3.15.01 verdict=fired, mirrored receipt")
code = (TREE / "corpus" / "release-clock.py").read_text(encoding="utf-8")
m2 = re.search(r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")', code)
receipt_rel = "/".join(part.strip('" ') for part in m2.group(1).split("/"))
orig = json.loads((TREE / receipt_rel).read_text(encoding="utf-8"))
print("default receipt:", receipt_rel)
for rec in orig["observations"]:
    if rec.get("id") == ROW:
        print("  default receipt S040:", json.dumps(
            {k: rec.get(k) for k in ("parsed_version", "verdict", "observed_at", "http_status")},
            sort_keys=True))
root, _feed = stage("f1", "3.15.01", "fired", ["Python 3.15.1"])
mirrored = []
for rec in orig["observations"]:
    if rec.get("id") == ROW:
        rec["parsed_version"], rec["verdict"] = "3.15.01", "fired"
        mirrored.append(rec["id"])
rp = root / "receipt.json"
rp.write_text(json.dumps(orig, indent=2) + "\n", encoding="utf-8")
sha = hashlib.sha256(rp.read_bytes()).hexdigest()
p = subprocess.run([sys.executable, "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                    "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                   text=True, capture_output=True)
findings = [ln for ln in p.stdout.splitlines() if re.match(r"^[A-Z-]+ S\d{3}$", ln)]
print("  exit=%d findings=%s tb=%s" % (p.returncode, findings, "Traceback" in p.stdout + p.stderr))
for ln in p.stdout.splitlines():
    if ln.startswith("RELEASE_CLOCK:"):
        print("  ", ln)
