#!/usr/bin/env python3
"""Probe 5: OVERSIZED receipt inputs -- stdout/stderr class+row only, never the
token, and NO hidden crash.

corpus/release-clock.py:528-531 (candidate 62a33b1) catches only
(UnicodeError, json.JSONDecodeError) around json.loads().  CPython's
int-string conversion limit raises a PLAIN ValueError from json.loads() when
the document holds an integer literal with more than 4300 digits -- and
json.JSONDecodeError is only a subclass of ValueError, so the plain ValueError
is NOT caught by that except clause.

Cases:
  R1  receipt observations[].parsed_version = <4301-digit JSON INTEGER>
  R2  receipt observations[].http_status = <4301-digit JSON INTEGER>
  R3  receipt observations[].sha256 = <4301-digit JSON INTEGER>
  R4  receipt observations[].id = <4301-char STRING> (a string, not a number)
  R5  receipt observations[].error = <4301-char STRING>
  R6  receipt observations[].parsed_version = "3.15.01" (leading-zero STRING)
  R7  receipt observations[].parsed_version = "3.15." + 4301*"1" (oversize STRING)

Expected for every case: exit code in {0,1}, a typed finding naming class+row
on stdout, NO Traceback on stdout/stderr, and NO echo of the oversized token.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
TREE = SANDBOX / "cand"
OVERSIZE = "1" * 4301


def env_for(tmp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(tmp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def build_receipt(record_patch):
    doc = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json")
                     .read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec.get("id") == "S040":
            rec.update(record_patch)
    return doc


def write_raw_receipt(root, text):
    p = root / "receipt.json"
    p.write_text(text, encoding="utf-8")
    return p, hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    tmp = Path(tempfile.mkdtemp(prefix="r28-probe5-", dir=str(SANDBOX)))
    env = env_for(tmp)
    root = tmp / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clocks.tsv"):
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    results = []
    cases = {
        "R1-parsed_version-huge-int": {
            "raw": ('{"format": "release-clock-observations-v1", "observations": '
                    '[{"id": "S040", "clock": "feed", '
                    '"url": "https://www.python.org/downloads/feed.rss", '
                    '"http_status": 200, "sha256": "%s", '
                    '"parsed_version": %s, "located": null, "verdict": "not-fired", '
                    '"observed_at": "2026-10-21T00:00:00Z"}]}'
                    % ("0" * 64, OVERSIZE))},
        "R2-http_status-huge-int": {
            "raw": ('{"format": "release-clock-observations-v1", "observations": '
                    '[{"id": "S040", "clock": "feed", '
                    '"url": "https://www.python.org/downloads/feed.rss", '
                    '"http_status": %s, "sha256": "%s", '
                    '"parsed_version": "3.15.1", "located": null, "verdict": "not-fired", '
                    '"observed_at": "2026-10-21T00:00:00Z"}]}'
                    % (OVERSIZE, "0" * 64))},
        "R3-sha256-huge-int": {
            "raw": ('{"format": "release-clock-observations-v1", "observations": '
                    '[{"id": "S040", "clock": "feed", '
                    '"url": "https://www.python.org/downloads/feed.rss", '
                    '"http_status": 200, "sha256": %s, '
                    '"parsed_version": "3.15.1", "located": null, "verdict": "not-fired", '
                    '"observed_at": "2026-10-21T00:00:00Z"}]}'
                    % OVERSIZE)},
        "R4-id-huge-string": {
            "raw": json.dumps({"format": "release-clock-observations-v1",
                               "observations": [{"id": OVERSIZE, "clock": "feed",
                                                "url": "https://www.python.org/downloads/feed.rss",
                                                "http_status": 200, "sha256": "0"*64,
                                                "parsed_version": "3.15.1",
                                                "located": None, "verdict": "not-fired",
                                                "observed_at": "2026-10-21T00:00:00Z"}]})},
        "R5-error-huge-string": {
            "raw": json.dumps({"format": "release-clock-observations-v1",
                               "observations": [{"id": "S040", "clock": "feed",
                                                "url": "https://www.python.org/downloads/feed.rss",
                                                "http_status": 200, "sha256": "0"*64,
                                                "parsed_version": None, "located": None,
                                                "verdict": "not-fired", "error": OVERSIZE,
                                                "observed_at": "2026-10-21T00:00:00Z"}]})},
        "R6-parsed_version-leadzero-string": {
            "raw": json.dumps({"format": "release-clock-observations-v1",
                               "observations": [{"id": "S040", "clock": "feed",
                                                "url": "https://www.python.org/downloads/feed.rss",
                                                "http_status": 200, "sha256": "0"*64,
                                                "parsed_version": "3.15.01",
                                                "located": None, "verdict": "not-fired",
                                                "observed_at": "2026-10-21T00:00:00Z"}]})},
        "R7-parsed_version-oversize-string": {
            "raw": json.dumps({"format": "release-clock-observations-v1",
                               "observations": [{"id": "S040", "clock": "feed",
                                                "url": "https://www.python.org/downloads/feed.rss",
                                                "http_status": 200, "sha256": "0"*64,
                                                "parsed_version": "3.15." + OVERSIZE,
                                                "located": None, "verdict": "not-fired",
                                                "observed_at": "2026-10-21T00:00:00Z"}]})},
    }
    for name, spec in cases.items():
        rp, sha = write_raw_receipt(root, spec["raw"])
        p = subprocess.run(
            ["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
             "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
            cwd=str(TREE), env=env, text=True, capture_output=True, timeout=120)
        out = p.stdout + p.stderr
        results.append({
            "case": name, "exit": p.returncode,
            "traceback": "Traceback" in out,
            "stdout": p.stdout.splitlines()[:6],
            "stderr": p.stderr.splitlines()[:8],
            "echoed_oversize": OVERSIZE in out,
            "max_line_len": max((len(l) for l in out.splitlines()), default=0),
        })
    shutil.rmtree(tmp, ignore_errors=True)
    (SANDBOX / "probe5-result.json").write_text(
        json.dumps(results, indent=2) + "\n", encoding="utf-8")
    for r in results:
        print("== %s exit=%s traceback=%s echoed=%s maxlen=%s" % (
            r["case"], r["exit"], r["traceback"], r["echoed_oversize"],
            r["max_line_len"]))
        for l in r["stdout"]:
            print("   OUT| %s" % l[:200])
        for l in r["stderr"]:
            print("   ERR| %s" % l[:200])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
