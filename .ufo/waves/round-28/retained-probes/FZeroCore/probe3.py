#!/usr/bin/env python3
"""FZeroCore probe 3: end-to-end observe -> receipt -> evaluate round trip with
the transport stubbed (no network). Proves the typed category of a bad token
is exactly NON-CANONICAL, that no fired verdict is written, and that no
Traceback escapes. Runs the module's own main() twice: once with --observe
(stubbed request_body), once with --receipt over the receipt it wrote.
"""
import hashlib
import importlib.util
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
HEADER = ("id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note")
FEED_URL = "https://example.test/releases.atom"

RUNNER = r'''#!/usr/bin/env python3
import importlib.util, sys
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
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def mini_corpus(tmp, anchor_cell, rows, feed_cell):
    corpus = tmp / "corpus"
    corpus.mkdir(parents=True, exist_ok=True)
    md = [
        "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
        "| S001 | Doc - https://example.test/doc | docs | A | test scope | %s | Quote: “x.” | mined | 2026-10-21 | on-release | - |" % anchor_cell,
        "| S002 | Feed - %s | code | A | test scope | %s | Feed teaching. | mined | 2026-10-21 | 90d | - |" % (FEED_URL, feed_cell),
    ]
    (corpus / "SOURCES.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    body = ["\t".join(HEADER)] + ["\t".join(row) for row in rows]
    (corpus / "release-clocks.tsv").write_text("\n".join(body) + "\n", encoding="utf-8")
    return corpus


def atom(titles):
    doc = b'<feed xmlns="http://www.w3.org/2005/Atom">'
    for index, title in enumerate(titles):
        doc += (b'<entry><title>%s</title><id>https://example.test/%d</id>'
                b'<updated>2026-10-21T00:00:00Z</updated></entry>' % (title, index))
    return doc + b"</feed>"


def row(rid="S001", anchored="1.2.3", observed="1.2.3", verdict="not-fired",
        note="test"):
    return [rid, "feed", "S002", FEED_URL, anchored, observed, "2026-10-21",
            verdict, note]


def roundtrip(tree, rows, anchor_cell, feed_cell, feed_bytes, label):
    tmp = Path(tempfile.mkdtemp(prefix="fzerocore3-"))
    try:
        mini_corpus(tmp, anchor_cell, rows, feed_cell)
        feed_file = tmp / "feed.bin"
        feed_file.write_bytes(feed_bytes)
        runner = tmp / "runner.py"
        runner.write_text(RUNNER, encoding="utf-8")
        out = tmp / "observe.json"
        cmd = [sys.executable, "-I", "-B", str(runner), str(tree), str(tmp),
               str(out), str(feed_file), FEED_URL, "2026-10-21"]
        obs = subprocess.run(cmd, capture_output=True, text=True)
        result = {"label": label, "observe_rc": obs.returncode,
                  "observe_stdout": obs.stdout.strip(),
                  "observe_traceback": "Traceback" in (obs.stdout + obs.stderr),
                  "observe_stderr": obs.stderr.strip().splitlines()[:4]}
        if not out.exists():
            result["receipt"] = None
            result["evaluate"] = None
            return result
        raw = out.read_bytes()
        document = json.loads(raw.decode("utf-8"))
        record = next((r for r in document["observations"] if r["id"] == "S001"), None)
        result["receipt_record"] = record
        result["receipt_sha256"] = hashlib.sha256(raw).hexdigest()
        cmd2 = [sys.executable, "-I", "-B", str(tree / "corpus" / "release-clock.py"),
                "--root", str(tmp), "--receipt", str(out),
                "--receipt-sha", result["receipt_sha256"]]
        ev = subprocess.run(cmd2, capture_output=True, text=True)
        lines = ev.stdout.strip().splitlines()
        result["evaluate_rc"] = ev.returncode
        result["evaluate_categories"] = sorted({line.split(" ", 1)[0] for line in lines
                                                if line and not line.startswith("RELEASE_CLOCK:")})
        result["evaluate_summary"] = next((l for l in lines if l.startswith("RELEASE_CLOCK:")), "")
        result["evaluate_traceback"] = "Traceback" in (ev.stdout + ev.stderr)
        return result
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    tree = SANDBOX / "cand"
    out = []
    cases = [
        ("canonical_000_control", [row(anchored="0.0.0", observed="0.0.0")],
         "Version 0.0.0 documentation",
         "Entry titled v0.0.0, tag link /releases/tag/v0.0.0, updated 2026-10-21T00:00:00Z",
         atom([b"v0.0.0"])),
        ("zero_core_feed_newest", [row()], "Version 1.2.3 documentation",
         "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z",
         atom([b"v1.2.03"])),
        ("zero_core_row_anchor", [row(anchored="1.2.03", observed="1.2.03")],
         "Version 1.2.3 documentation",
         "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z",
         atom([b"v1.2.3"])),
        ("zero_core_row_obs", [row(observed="1.2.03", verdict="fired")],
         "Version 1.2.3 documentation",
         "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z",
         atom([b"v1.2.3"])),
        ("zero_core_feed_older_than_newest", [row(anchored="1.2.0", observed="1.2.0")],
         "Version 1.2.0 documentation",
         "Entry titled v1.2.0, tag link /releases/tag/v1.2.0, updated 2026-10-21T00:00:00Z",
         atom([b"v1.2.3", b"v1.2.03"])),
    ]
    for label, rows, anchor_cell, feed_cell, feed_bytes in cases:
        out.append(roundtrip(tree, rows, anchor_cell, feed_cell, feed_bytes, label))
    print(json.dumps(out, indent=1, sort_keys=True))


if __name__ == "__main__":
    main()
