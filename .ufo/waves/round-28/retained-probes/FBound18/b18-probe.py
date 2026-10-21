#!/usr/bin/env python3
"""FBound18 independent probe: round-28 C1 canonical-token bound.

Written independently of .ufo/waves/round-28/tools/c1-measure.py (frozen
instrument) so the 18-digit boundary is reproduced from scratch.

Modes:
  table   -- edit S040's observed_version/verdict in a COPY of the tree and
             mirror the retained receipt record (table+receipt), then run the
             clock with --receipt/--receipt-sha.
  observe -- narrow the table to S040, serve a LOCAL fixture Atom feed through
             the clock's own request_body (stubbed, no network), and run
             --observe; then assert the written receipt.

Nothing in the lane checkout is written; all work happens in a temp dir.
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROW = "S040"
CORPUS_COPY = ["SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clocks.tsv"]

RUNNER = r'''#!/usr/bin/env python3
"""--observe runner: the clock's own main() with request_body stubbed to a
local fixture feed and utc_timestamp pinned to the row's observed_at."""
import importlib.util
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
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=180)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr}


def table_lines(tree):
    return (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)


def edit_row(tree, row_id, observed=None, verdict=None, only_row=False):
    out = []
    for line in table_lines(tree):
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == row_id:
            if observed is not None:
                fields[5] = observed
            if verdict is not None:
                fields[7] = verdict
            out.append("\t".join(fields) + "\n")
        elif only_row and fields and fields[0] != "id":
            continue
        else:
            out.append(line)
    return "".join(out)


def keep_sources(tree, keep_ids):
    out = []
    for line in (tree / "corpus" / "SOURCES.md").read_text(
            encoding="utf-8").splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [c.strip() for c in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) \
                    and cells[0] not in keep_ids:
                continue
        out.append(line)
    return "".join(out)


def stage(tree, temp, name, table_text, sources_text=None):
    root = temp / ("fx-" + name)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_COPY:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    if sources_text is not None:
        (root / "corpus" / "SOURCES.md").write_text(sources_text,
                                                    encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(table_text,
                                                         encoding="utf-8")
    return root


def default_receipt(tree):
    code = (tree / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    match = re.search(
        r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")',
        code)
    if not match:
        raise RuntimeError("default receipt path not found")
    return tree / "/".join(p.strip('" ') for p in match.group(1).split("/"))


def mirror_receipt(tree, root, row_id, parsed, verdict):
    receipt = json.loads(default_receipt(tree).read_text(encoding="utf-8"))
    hit = False
    for record in receipt["observations"]:
        if record.get("id") == row_id:
            record["parsed_version"] = parsed
            record["verdict"] = verdict
            hit = True
    if not hit:
        raise RuntimeError("row %s absent from the default receipt" % row_id)
    path = root / "receipt.json"
    path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return path, hashlib.sha256(path.read_bytes()).hexdigest()


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, i) for i, title in enumerate(titles))
    doc = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<feed xmlns="http://www.w3.org/2005/Atom">\n'
           "  <title>Python releases (fixture)</title>\n"
           "  <id>https://www.python.org/downloads/feed.rss</id>\n"
           "  <updated>2026-10-21T00:00:00Z</updated>\n"
           + entries + "</feed>\n")
    return doc.encode("utf-8")


def report(label, result, extra=None):
    out = result["stdout"] + result["stderr"]
    lines = [l for l in out.splitlines() if l.strip()]
    findings = [l for l in lines
                if not l.startswith("RELEASE_CLOCK") and "Traceback" not in l]
    summary = next((l for l in reversed(lines)
                    if l.startswith("RELEASE_CLOCK:")), "")
    fired = re.search(r"fired=(\d+)", summary)
    data = {
        "label": label,
        "exit": result["exit"],
        "last_line": summary,
        "finding_lines": findings,
        "traceback": "Traceback" in out,
        "fired_count": int(fired.group(1)) if fired else None,
        "stderr_head": result["stderr"][:400],
    }
    if extra:
        data.update(extra)
    return data


def table_case(tree, temp, env, label, observed, verdict="fired"):
    root = stage(tree, temp, label, edit_row(tree, ROW, observed, verdict))
    path, sha = mirror_receipt(tree, root, ROW, observed, verdict)
    result = run(["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
                  "--root", str(root), "--receipt", str(path),
                  "--receipt-sha", sha], cwd=tree, env=env)
    return report(label, result, {"token": observed,
                                  "mode": "table+receipt"})


def observe_case(tree, temp, env, runner, label, titles, observed=None,
                 verdict=None):
    table_text = edit_row(tree, ROW, observed, verdict, only_row=True)
    feed_url, observed_at, feed_source_id = None, None, None
    for line in table_text.splitlines():
        f = line.split("\t")
        if f and f[0] == ROW:
            feed_source_id, feed_url, observed_at = f[2], f[3], f[6]
    root = stage(tree, temp, label, table_text,
                 keep_sources(tree, {ROW, feed_source_id}))
    feed = root / "feed.atom"
    feed.write_bytes(atom_feed(titles))
    out_receipt = root / "observe-out.json"
    result = run(["python3", "-I", "-B", str(runner), str(tree), str(root),
                  str(out_receipt), str(feed), feed_url, observed_at],
                 cwd=tree, env=env)
    written = None
    if out_receipt.exists():
        doc = json.loads(out_receipt.read_text(encoding="utf-8"))
        for record in doc.get("observations", []):
            if record.get("id") == ROW:
                written = {k: record.get(k) for k in
                           ("id", "verdict", "error", "parsed_version")}
    return report(label, result, {"titles": titles, "mode": "observe",
                                  "receipt_record": written,
                                  "fired_written": bool(
                                      written and written.get("verdict") == "fired")})


def main():
    tree = Path(sys.argv[1]).resolve()
    tag = sys.argv[2]
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"),
           "HOME": "/tmp", "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    temp = Path(tempfile.mkdtemp(prefix="fb18-"))
    runner = temp / "observe-runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    d18 = "1" * 18
    d19 = "1" * 19
    d17 = "1" * 17
    cases = []
    try:
        # --- table path: the 18/19-digit boundary on the observation token
        cases.append(table_case(tree, temp, env, "T18", "3.15." + d18))
        cases.append(table_case(tree, temp, env, "T19", "3.15." + d19))
        cases.append(table_case(tree, temp, env, "T17", "3.15." + d17))
        cases.append(table_case(tree, temp, env, "T18zero", "3.15.0" + d17))
        cases.append(table_case(tree, temp, env, "T19zero", "3.15.0" + d18))
        cases.append(table_case(tree, temp, env, "T4301", "3.15." + "1" * 4301))
        # --- table path: 18/19-digit boundary on the ANCHOR token
        # anchor edit: field 5 is anchored_version
        lines = table_lines(tree)
        anchor_text = "".join(
            ("\t".join([f[0], f[1], f[2], f[3], "3.15." + d19, f[5], f[6],
                        f[7], f[8]]) + "\n") if f and f[0] == ROW else line
            for f, line in ((l.rstrip("\n").split("\t"), l)
                            for l in lines))
        root = stage(tree, temp, "A19", anchor_text)
        path, sha = mirror_receipt(tree, root, ROW, "3.15.1", "not-fired")
        res = run(["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(path),
                   "--receipt-sha", sha], cwd=tree, env=env)
        cases.append(report("A19-anchor", res, {"mode": "table+receipt"}))
        # --- observe path: feed entry carries the boundary token
        cases.append(observe_case(tree, temp, env, runner, "O18",
                                  ["Python 3.15." + d18, "Python 3.15.0"],
                                  observed="3.15." + d18, verdict="fired"))
        cases.append(observe_case(tree, temp, env, runner, "O19",
                                  ["Python 3.15." + d19, "Python 3.15.0"]))
        cases.append(observe_case(tree, temp, env, runner, "O19-lower",
                                  ["Python 3.15.1",
                                   "Python 3.15." + d19[:17] + "0" * 2]))
        # only a 19-digit entry in the feed
        cases.append(observe_case(tree, temp, env, runner, "O19-only",
                                  ["Python 3.15." + d19]))
        # a 19-digit entry that orders BELOW the newest canonical entry
        cases.append(observe_case(tree, temp, env, runner, "O19-below",
                                  ["Python 3.15.1", "Python 3.15." + "0" * 19]))
        # a 19-char leading-zero entry numerically TIED with the newest
        cases.append(observe_case(tree, temp, env, runner, "O19-tie",
                                  ["Python 3.15.1",
                                   "Python 3.15." + "0" * 18 + "1"]))
        # 18-digit ANCHOR (canonical side of the bound) on the table row
        lines = table_lines(tree)
        anchor18 = "".join(
            ("\t".join([f[0], f[1], f[2], f[3], "3.15." + d18, f[5], f[6],
                        f[7], f[8]]) + "\n") if f and f[0] == ROW else line
            for f, line in ((l.rstrip("\n").split("\t"), l) for l in lines))
        root = stage(tree, temp, "A18", anchor18)
        path, sha = mirror_receipt(tree, root, ROW, "3.15.1", "not-fired")
        res = run(["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(path),
                   "--receipt-sha", sha], cwd=tree, env=env)
        cases.append(report("A18-anchor", res, {"mode": "table+receipt"}))
    finally:
        shutil.rmtree(temp, ignore_errors=True)
    print(json.dumps(cases, indent=1))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
