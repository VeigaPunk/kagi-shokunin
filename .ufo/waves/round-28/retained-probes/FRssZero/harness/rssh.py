#!/usr/bin/env python3
"""Independent reproduction of round-28 C1's RSS leading-zero title carrier.

Usage: rssh.py <tree> <label>

<tree> is an exported repo tree (candidate 62a33b1 or BASE 3553d49).  No network:
release-clock.py's own transport (request_body) is replaced by a stub that serves
the local fixture feed bytes, exactly the substitution the script's own selftest
uses.  Every fixture keeps the S040 binding row and the S039 feed registry row
verbatim; only the local feed copy changes.

Reported per fixture: exit code, stdout/stderr, presence of Traceback, and the
S040 observation record actually written to the receipt (verdict/error/parsed).
"""
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

RUNNER = r'''#!/usr/bin/env python3
"""release-clock.py main() --observe with the transport stubbed to the local feed."""
import importlib.util
import json
import sys
from pathlib import Path

tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()


def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"


module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
code = module.main(["--root", root, "--observe", out])
record = None
try:
    document = json.loads(Path(out).read_text(encoding="utf-8"))
    for item in document.get("observations", []):
        if item.get("id") == "S040":
            record = item
except Exception as exc:  # pragma: no cover - reporting only
    record = {"harness_read_error": exc.__class__.__name__}
print("HARNESS_RECORD " + json.dumps(record, sort_keys=True))
raise SystemExit(code)
'''


def rss(items):
    body = "".join(
        "  <item>\n    <title>%s</title>\n"
        "    <link>https://www.python.org/downloads/release/python-%s/</link>\n"
        "    <pubDate>Wed, 21 Oct 2026 09:59:50 +0000</pubDate>\n  </item>\n"
        % (title, re.sub(r"[^0-9]", "", title)) for title in items)
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<rss version="2.0"><channel>\n'
            "  <title>Python releases</title>\n"
            "  <link>https://www.python.org/downloads/</link>\n"
            "  <description>fixture</description>\n"
            + body + "</channel></rss>\n").encode("utf-8")


def atom(entries):
    body = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, index) for index, title in enumerate(entries))
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<feed xmlns="http://www.w3.org/2005/Atom">\n'
            "  <title>Python releases (fixture)</title>\n"
            "  <id>https://www.python.org/downloads/feed.rss</id>\n"
            "  <updated>2026-10-21T00:00:00Z</updated>\n"
            + body + "</feed>\n").encode("utf-8")


def rss_cdata(items):
    body = "".join(
        "  <item>\n    <title><![CDATA[%s]]></title>\n"
        "    <pubDate>Wed, 21 Oct 2026 09:59:50 +0000</pubDate>\n  </item>\n"
        % title for title in items)
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<rss version="2.0"><channel><title>t</title>'
            + body + "</channel></rss>\n").encode("utf-8")


OVERSIZE = "1" * 4301
# Categories that exist at BASE: a finding in this set is a generic receipt /
# binding complaint, never proof of the new canonical-token rule.
BASE_ERA_CATEGORIES = {
    "ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
    "RECEIPT-MISMATCH", "NOT OBSERVED",
}

FIXTURES = [
    ("A-rss-newest-zero", rss(["Python 3.15.01", "Python 3.15.0"]),
     "RSS: newest item title 'Python 3.15.01' (leading zero)"),
    ("B-rss-only-zero", rss(["Python 3.15.01"]),
     "RSS: only item title 'Python 3.15.01'"),
    ("C-rss-zero-not-newest", rss(["Python 3.15.01", "Python 3.16.0"]),
     "RSS: leading-zero title older than the canonical newest"),
    ("D-rss-zero-below-newest", rss(["Python 3.15.1", "Python 3.9.01"]),
     "RSS: leading-zero title below the canonical newest"),
    ("E-atom-newest-zero", atom(["Python 3.15.01", "Python 3.15.0"]),
     "Atom (frozen-tool shape): newest title 'Python 3.15.01'"),
    ("F-rss-cdata-newest-zero", rss_cdata(["Python 3.15.01", "Python 3.15.0"]),
     "RSS: CDATA title 'Python 3.15.01' newest"),
    ("G-rss-oversize-newest", rss(["Python 3.15." + OVERSIZE, "Python 3.15.0"]),
     "RSS: newest title with a 4301-digit patch component"),
    ("H-rss-canonical-only", rss(["Python 3.15.1", "Python 3.14.0"]),
     "control: canonical titles only"),
    ("I-rss-major-zero", rss(["Python 03.15.1", "Python 3.14.0"]),
     "RSS: newest title with a leading zero in the major component"),
    ("J-rss-middle-zero", rss(["Python 3.015.1", "Python 3.14.0"]),
     "RSS: newest title with a leading zero in the minor component"),
    ("K-rss-v-prefix-zero", rss(["v3.15.01", "Python 3.15.0"]),
     "RSS: newest title 'v3.15.01' (v prefix, leading zero)"),
]


def stage(tree, work, name, feed_bytes):
    root = work / name
    (root / "corpus").mkdir(parents=True)
    kept = []
    for line in (tree / "corpus" / "SOURCES.md").read_text(
            encoding="utf-8").splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [cell.strip() for cell in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) \
                    and cells[0] not in ("S039", "S040"):
                continue
        kept.append(line)
    (root / "corpus" / "SOURCES.md").write_text("".join(kept), encoding="utf-8")
    for rel in ("rendered-text-v1.py", "source-fetches.tsv"):
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    rows = [row for row in (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
        if row.split("\t")[0] in ("id", "S040")]
    (root / "corpus" / "release-clocks.tsv").write_text("".join(rows), encoding="utf-8")
    feed = root / "feed.xml"
    feed.write_bytes(feed_bytes)
    return root, feed


def main():
    tree = Path(sys.argv[1]).resolve()
    label = sys.argv[2]
    work = Path(os.environ.get("HARNESS_WORK", "/tmp")).resolve() / ("rssh-" + label)
    shutil.rmtree(work, ignore_errors=True)
    work.mkdir(parents=True)
    runner = work / "runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(work),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    out = {"label": label, "tree": str(tree), "fixtures": {}}
    for name, feed_bytes, note in FIXTURES:
        root, feed = stage(tree, work, name, feed_bytes)
        receipt = root / "observe-out.json"
        proc = subprocess.run(
            ["python3", "-I", "-B", str(runner), str(tree), str(root),
             str(receipt), str(feed),
             "https://www.python.org/downloads/feed.rss", "2026-10-21"],
            cwd=str(tree), env=env, text=True, capture_output=True, timeout=120)
        record = None
        for line in proc.stdout.splitlines():
            if line.startswith("HARNESS_RECORD "):
                record = json.loads(line[len("HARNESS_RECORD "):])
        stdout = [line for line in proc.stdout.splitlines()
                  if not line.startswith("HARNESS_RECORD")]
        out["fixtures"][name] = {
            "note": note,
            "exit": proc.returncode,
            "traceback": "Traceback" in proc.stdout + proc.stderr,
            "stdout": stdout,
            "stderr": proc.stderr.splitlines()[-4:],
            "record": record,
            "fired_record_written": bool(record and record.get("verdict") == "fired"),
            "typed_finding": [line for line in stdout
                              if line.strip() and not line.startswith("RELEASE_CLOCK")
                              and line.split()[0] not in BASE_ERA_CATEGORIES],
            "any_finding_line": [line for line in stdout
                                 if line.strip() and not line.startswith("RELEASE_CLOCK")],
        }
        verdict = "?"
        if out["fixtures"][name]["fired_record_written"]:
            verdict = "MISHANDLED(fired observation written)"
        elif proc.returncode == 1 and not out["fixtures"][name]["traceback"] \
                and out["fixtures"][name]["typed_finding"]:
            verdict = "TYPED"
        elif proc.returncode == 0 and any(line.startswith("RELEASE_CLOCK: CLEAN")
                                         for line in stdout):
            verdict = "CLEAN(exit 0)"
        out["fixtures"][name]["verdict"] = verdict
    print(json.dumps(out, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
