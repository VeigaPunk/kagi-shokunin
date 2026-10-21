#!/usr/bin/env python3
"""Variant probes around the major-component leading zero (03.15.1) carrier.

Reuses the frozen instrument's fixture builders; only tokens/titles vary.
No network: the table path fetches nothing; the observe path is served by the
instrument's local stub.
"""
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

import probe  # reuse the harness helpers (frozen-tool fixture builders)

c1 = probe.c1
ROW = probe.ROW


def env_for(temp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def atom_feed_tag(titles):
    """Feed whose entries carry the token in the tag href form."""
    entries = "".join(
        "  <entry>\n    <title>Python %s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <link href=\"https://www.python.org/downloads/release/v%s/\"/>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (t, i, t) for i, t in enumerate(titles))
    doc = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<feed xmlns="http://www.w3.org/2005/Atom">\n'
           "  <title>Python releases (fixture)</title>\n"
           "  <id>https://www.python.org/downloads/feed.rss</id>\n"
           "  <updated>2026-10-21T00:00:00Z</updated>\n"
           + entries + "</feed>\n")
    return doc.encode("utf-8")


def observe_with_feed(tree, temp, env, name, feed_bytes):
    """Same shape as the frozen observe fixture but with a caller-built feed."""
    runner = temp / ("observe-runner-%s.py" % name)
    runner.write_text(c1.RUNNER, encoding="utf-8")
    original = c1.row_fields(c1.edited_table(tree, {}, narrow=False), ROW)
    edits = {ROW: (original[5], original[7])}
    table_text = c1.edited_table(tree, edits, narrow=True)
    fields = c1.row_fields(table_text, ROW)
    feed_url, observed_at = fields[3], fields[6]
    sources_text = c1.narrowed_sources(tree, {ROW, fields[2]})
    root = c1.stage_fixture(tree, temp, name, table_text, sources_text)
    feed = root / "feed.atom"
    feed.write_bytes(feed_bytes)
    out = root / "observe-out.json"
    result = c1.run(
        ["python3", "-I", "-B", str(runner), str(tree), str(root), str(out),
         str(feed), feed_url, observed_at],
        cwd=tree, env=env)
    fired, summary = c1.receipt_fired(out, ROW)
    result.update({"fired_observation_written": fired, "receipt": summary,
                   "receipt_path": str(out), "feed_url": feed_url,
                   "mirrored_rows": [ROW]})
    return c1.classify(result, ROW, feed_url)


def main():
    trees = {"cand": Path(sys.argv[1]).resolve(), "base": Path(sys.argv[2]).resolve()}
    out = {}
    for label, tree in trees.items():
        temp = Path(tempfile.mkdtemp(prefix="kagi-r28-fmj2-%s-" % label))
        try:
            env = env_for(temp)
            cases = {}
            # V1 table: major-zero observation with a not-fired verdict
            cases["V1-table-not-fired"] = probe.table_case(
                tree, temp, env, "v1", {ROW: {5: "03.15.1", 7: "not-fired"}})
            # V2 table: two-digit all-zero major
            cases["V2-table-00major"] = probe.table_case(
                tree, temp, env, "v2", {ROW: {5: "00.15.1", 7: "fired"}})
            # V3 table: v-prefixed major zero
            cases["V3-table-v-prefix"] = probe.table_case(
                tree, temp, env, "v3", {ROW: {5: "v03.15.1", 7: "fired"}})
            # V4 observe: major-zero token in the tag href form
            cases["V4-observe-taglink"] = observe_with_feed(
                tree, temp, env, "v4",
                atom_feed_tag(["03.15.1", "3.15.0"]))
            # V5 observe: canonical newest + older major-zero entry (must be ignored)
            cases["V5-observe-older-majorzero"] = observe_with_feed(
                tree, temp, env, "v5",
                c1.atom_feed(["Python 3.15.1", "Python 03.15.0"]))
            # V6 observe: canonical newest + same-version major-zero twin (must refuse)
            cases["V6-observe-twin-majorzero"] = observe_with_feed(
                tree, temp, env, "v6",
                c1.atom_feed(["Python 3.15.1", "Python 03.15.1"]))
            for name, result in cases.items():
                print("=" * 78)
                print("%s %s exit=%s verdict=%s traceback=%s" % (
                    label, name, result["exit"], result.get("verdict"),
                    result.get("traceback_in_output")))
                print(result["stdout"].rstrip())
                if result.get("stderr"):
                    print("[stderr] " + result["stderr"].rstrip())
                if result.get("receipt"):
                    print("[receipt] " + json.dumps(result["receipt"]))
            out[label] = cases
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    Path(__file__).with_name("probe2-result.json").write_text(
        json.dumps({k: {n: {kk: vv for kk, vv in r.items()
                            if kk in ("exit", "stdout", "stderr", "verdict",
                                      "traceback_in_output", "typed_finding_lines",
                                      "receipt", "fired_observation_written")}
                            for n, r in v.items()}
                    for k, v in out.items()}, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
