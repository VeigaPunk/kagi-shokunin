#!/usr/bin/env python3
"""FFeedOlder probe (independent, offline) for round-28 C1.

Carrier under attack: corpus/release-clock.py's non-canonical version token
rule.  Focus: a feed entry token that is NON-CANONICAL but orders STRICTLY
BELOW the newest canonical entry (the candidate's documented ignore limit:
newest_stable() docstring, corpus/release-clock.py:784-798).

Every run is a child `python3 -I -B` of the tree's OWN release-clock.py with
module.request_body stubbed to serve a local fixture feed and
module.utc_timestamp pinned (the same substitutions the script's own selftest
and the lane's frozen c1-measure.py use).  No network is used or needed.

Usage: probe.py <cand-tree> <base-tree> <out-dir>
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

FEED_URL = "https://www.python.org/downloads/feed.rss"
OBSERVED_AT = "2026-10-21"
KEEP_SOURCES = ("S039", "S040")
ROW_ID = "S040"

RUNNER = r'''#!/usr/bin/env python3
"""Child runner: the tree's own release-clock.py main() with the network
transport stubbed to serve the local fixture feed; no socket is opened."""
import importlib.util
import sys
from pathlib import Path

tree, root, out, feed_file, feed_url, observed_at, mode, receipt, receipt_sha = sys.argv[1:10]
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
if mode == "observe":
    argv = ["--root", root, "--observe", out]
else:
    argv = ["--root", root, "--receipt", receipt, "--receipt-sha", receipt_sha]
raise SystemExit(module.main(argv))
'''


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, index)
        for index, title in enumerate(titles)
    )
    document = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>%s</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n" % FEED_URL
        + entries + "</feed>\n"
    )
    return document.encode("utf-8")


def narrow_sources(text, keep):
    kept = []
    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = stripped[1:].split("|")
            if cells and cells[0].strip() in keep:
                kept.append(line)
    return "".join(kept)


def table_with_row(table_text, row_id, observed, verdict, anchored="3.15.1"):
    lines = table_text.splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == row_id:
            fields[4] = anchored
            fields[5] = observed
            fields[7] = verdict
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def narrow_table(table_text, row_id, observed, verdict, anchored="3.15.1"):
    lines = table_text.splitlines(keepends=True)
    out = [lines[0]]
    for line in lines[1:]:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == row_id:
            fields[4] = anchored
            fields[5] = observed
            fields[7] = verdict
            out.append("\t".join(fields) + "\n")
    return "".join(out)


def build_observe_root(tree, root, titles, observed, verdict):
    corpus = root / "corpus"
    corpus.mkdir(parents=True)
    src = tree / "corpus"
    (corpus / "SOURCES.md").write_text(
        narrow_sources((src / "SOURCES.md").read_text(encoding="utf-8"), KEEP_SOURCES),
        encoding="utf-8")
    (corpus / "release-clocks.tsv").write_text(
        narrow_table((src / "release-clocks.tsv").read_text(encoding="utf-8"),
                     ROW_ID, observed, verdict), encoding="utf-8")
    shutil.copy(src / "source-fetches.tsv", corpus / "source-fetches.tsv")
    shutil.copy(src / "rendered-text-v1.py", corpus / "rendered-text-v1.py")
    shutil.copy(src / "release-clock.py", corpus / "release-clock.py")
    feed = root.parent / "feed.xml"
    feed.write_bytes(atom_feed(titles))
    return feed


def build_verify_root(tree, root, observed, verdict):
    corpus = root / "corpus"
    corpus.mkdir(parents=True)
    src = tree / "corpus"
    for name in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                 "release-clock.py"):
        shutil.copy(src / name, corpus / name)
    (corpus / "release-clocks.tsv").write_text(
        table_with_row((src / "release-clocks.tsv").read_text(encoding="utf-8"),
                       ROW_ID, observed, verdict), encoding="utf-8")
    receipt = json.loads(
        (tree / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record["id"] == ROW_ID:
            record["parsed_version"] = observed
            record["verdict"] = verdict
    path = root.parent / "receipt.json"
    path.write_text(json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True),
                    encoding="utf-8")
    return path, hashlib.sha256(path.read_bytes()).hexdigest()


def run_case(tree, out_dir, name, titles, observed, verdict, mode):
    root = out_dir / ("%s-root" % name)
    if root.exists():
        shutil.rmtree(root)
    root.mkdir(parents=True)
    feed = root.parent / ("%s-feed.xml" % name)
    feed.write_bytes(atom_feed(titles))
    receipt = receipt_sha = ""
    if mode == "observe":
        build_observe_root(tree, root, titles, observed, verdict)
        out = root.parent / ("%s-observe.json" % name)
        if out.exists():
            out.unlink()
    else:
        receipt_path, receipt_sha = build_verify_root(tree, root, observed, verdict)
        receipt = str(receipt_path)
    runner = out_dir / "runner.py"
    outfile = root.parent / ("%s-%s-out.json" % (name, Path(tree).name))
    if outfile.exists():
        outfile.unlink()
    proc = subprocess.run(
        [sys.executable, "-I", "-B", str(runner), str(tree), str(root), str(outfile),
         str(feed), FEED_URL, OBSERVED_AT, mode, receipt, receipt_sha],
        cwd=str(out_dir), text=True, capture_output=True)
    print("---- %s | tree=%s | mode=%s" % (name, Path(tree).name, mode))
    print("exit=%d" % proc.returncode)
    for line in proc.stdout.splitlines():
        print("stdout| %s" % line)
    for line in proc.stderr.splitlines():
        print("stderr| %s" % line)
    if "Traceback" in proc.stdout + proc.stderr:
        print("TRACEBACK_PRESENT=yes")
    else:
        print("TRACEBACK_PRESENT=no")
    obs_path = root.parent / ("%s-%s-out.json" % (name, Path(tree).name))
    if obs_path.exists():
        doc = json.loads(obs_path.read_text(encoding="utf-8"))
        for record in doc["observations"]:
            print("receipt| id=%s verdict=%s parsed=%s error=%s" % (
                record.get("id"), record.get("verdict"),
                record.get("parsed_version"), record.get("error")))
    print("")


def main():
    cand, base, out_dir = (Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(),
                           Path(sys.argv[3]).resolve())
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "runner.py").write_text(RUNNER, encoding="utf-8")
    oversize = "3.15." + "1" * 4301
    cases = [
        # name, feed titles, table observed_version, table verdict, mode
        # A: the ATTACK -- a non-canonical entry that orders strictly BELOW the
        #    newest canonical entry (the candidate's documented ignore limit).
        ("A_older_noncanonical", ["Python 3.15.2", "Python 3.14.01"], "3.15.2", "fired", "observe"),
        # B: the same malformed token AT the newest value (tie) -- control.
        ("B_tie_noncanonical", ["Python 3.15.2", "Python 3.15.02"], "3.15.2", "fired", "observe"),
        # C: the malformed token as the only/newest entry, table row canonical so
        #    the FEED path is the one under test -- control.
        ("C_newest_noncanonical", ["Python 3.15.02"], "3.15.1", "not-fired", "observe"),
        # D: clean feed, no malformed token -- control.
        ("D_clean_control", ["Python 3.15.2"], "3.15.2", "fired", "observe"),
        # E: over-bound component in the feed, table row canonical -- control.
        ("E_feed_oversize", ["Python " + oversize], "3.15.1", "not-fired", "observe"),
        # F: non-canonical token in the TABLE (row) path, receipt mirrored.
        ("F_table_row_noncanonical", [], "3.15.02", "not-fired", "verify"),
        # G: over-bound component in the TABLE path, receipt mirrored.
        ("G_table_row_oversize", [], oversize, "not-fired", "verify"),
    ]
    for tree in (cand, base):
        for name, titles, observed, verdict, mode in cases:
            run_case(tree, out_dir, name, titles, observed, verdict, mode)
        # whole-tree control: the frozen default command, unmodified tree
        proc = subprocess.run(
            [sys.executable, "-I", "-B", str(tree / "corpus" / "release-clock.py"),
             "--root", str(tree)], text=True, capture_output=True)
        print("---- Z_control_default | tree=%s" % Path(tree).name)
        print("exit=%d" % proc.returncode)
        for line in proc.stdout.splitlines():
            print("stdout| %s" % line)
        for line in proc.stderr.splitlines():
            print("stderr| %s" % line)
        print("")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
