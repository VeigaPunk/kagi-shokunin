#!/usr/bin/env python3
"""FBound19 — independent reproduction of the 19-digit-component carrier.

Reads an EXPORTED tree (candidate or BASE) and exercises four fixtures that the
frozen c1-measure.py set does NOT cover (it covers leading-zero and 4301-digit
only):

  T-OBS  table path: S040 observed_version=3.15.9999999999999999999 (19 nines),
         verdict=fired. The receipt copy is mirrored so the only error can be
         the new typed category (a generic RECEIPT-MISMATCH is not accepted as
         proof).
  T-ANC  table path: S040 anchored_version=1.2.9999999999999999999 (19 nines).
  F-NEW  feed path: --observe over a local feed whose newest entry is
         v3.15.9999999999999999999 (19 nines) next to a canonical v3.15.1.
  F-OLD  feed path: same feed but the 19-digit entry is v3.14.9999999999999999999
         (orders BELOW the newest canonical v3.15.1).

No network: the feed is served by replacing the module-global request_body
(the same substitution corpus/release-clock.py's own selftest uses).
"""
import argparse
import hashlib
import importlib.util
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

NINETEEN = "9" * 19
ROW = "S040"
FEED_SRC = "S039"
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")


def load_module(tree):
    path = Path(tree) / "corpus" / "release-clock.py"
    spec = importlib.util.spec_from_file_location("rc_%d" % abs(hash(str(path))), path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def narrow_sources(text, keep):
    kept = []
    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [c.strip() for c in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) and cells[0] not in keep:
                continue
        kept.append(line)
    return "".join(kept)


def table_lines(tree):
    return (Path(tree) / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8")


def edit_row(table, row_id, anchored=None, observed=None, verdict=None):
    out = []
    for line in table.splitlines(keepends=True):
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] == row_id:
            if anchored is not None:
                fields[4] = anchored
            if observed is not None:
                fields[5] = observed
            if verdict is not None:
                fields[7] = verdict
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def stage(tree, temp, name, table, sources=None, keep_rows=None):
    root = Path(temp) / name
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(Path(tree) / "corpus" / rel, root / "corpus" / rel)
    if sources is not None:
        (root / "corpus" / "SOURCES.md").write_text(sources, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(table, encoding="utf-8")
    return root


def default_receipt(tree):
    code = (Path(tree) / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    match = re.search(r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")', code)
    rel = "/".join(p.strip('" ') for p in match.group(1).split("/"))
    return Path(tree) / rel


def mirror_receipt(tree, root, row_id, parsed_version, verdict):
    doc = json.loads(default_receipt(tree).read_text(encoding="utf-8"))
    hit = False
    for record in doc["observations"]:
        if record.get("id") == row_id:
            record["parsed_version"] = parsed_version
            record["verdict"] = verdict
            hit = True
    if not hit:
        raise RuntimeError("receipt has no record for " + row_id)
    path = root / "receipt.json"
    path.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    return path, hashlib.sha256(path.read_bytes()).hexdigest()


def run_cli(tree, root, receipt=None, sha=None, observe=None):
    argv = ["python3", "-I", "-B", str(Path(tree) / "corpus" / "release-clock.py"),
            "--root", str(root)]
    if observe is not None:
        argv += ["--observe", str(observe)]
    else:
        argv += ["--receipt", str(receipt), "--receipt-sha", sha]
    proc = subprocess.run(argv, capture_output=True, text=True, timeout=180)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout, "stderr": proc.stderr}


def classify(result):
    out = result["stdout"] + "\n" + result["stderr"]
    lines = [l.strip() for l in result["stdout"].splitlines() if l.strip()]
    summary = lines[-1] if lines else ""
    findings = [l for l in lines if l and not l.startswith("RELEASE_CLOCK")]
    return {
        "exit": result["exit"],
        "summary": summary,
        "finding_lines": findings,
        "traceback": "Traceback" in out,
        "categories": sorted({l.split()[0] for l in findings if l.split()}),
        "fired_in_summary": "fired=0" not in summary,
    }


def atom(titles):
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


RUNNER = r'''import importlib.util, json, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("rc_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
def fake(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fake
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def observe_fixture(tree, temp, name, titles):
    root = stage(tree, temp, name,
                 table_lines(tree),
                 sources=narrow_sources((Path(tree) / "corpus" / "SOURCES.md").read_text(encoding="utf-8"),
                                        {ROW, FEED_SRC}))
    feed = Path(temp) / (name + ".atom")
    feed.write_bytes(atom(titles))
    out = Path(temp) / (name + "-receipt.json")
    runner = Path(temp) / (name + "-runner.py")
    runner.write_text(RUNNER, encoding="utf-8")
    proc = subprocess.run(
        ["python3", "-I", "-B", str(runner), str(tree), str(root), str(out),
         str(feed), "https://www.python.org/downloads/feed.rss", "2026-10-21"],
        capture_output=True, text=True, timeout=180)
    result = {"argv": ["python3", "-I", "-B", str(runner), "<tree>", "<root>", "<out>"],
              "exit": proc.returncode, "stdout": proc.stdout, "stderr": proc.stderr}
    record = None
    if out.exists():
        doc = json.loads(out.read_text(encoding="utf-8"))
        for r in doc.get("observations", []):
            if r.get("id") == ROW:
                record = r
    result["receipt_record"] = record
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("tree")
    ap.add_argument("label")
    ap.add_argument("out")
    args = ap.parse_args()
    tree = Path(args.tree).resolve()
    report = {"tree": str(tree), "label": args.label,
              "python": sys.version.split()[0]}
    with tempfile.TemporaryDirectory(prefix="fb19-") as temp:
        temp = Path(temp)
        base_table = table_lines(tree)

        # T-OBS: 19-digit component in the observed_version, verdict=fired.
        table = edit_row(base_table, ROW, observed="3.15." + NINETEEN, verdict="fired")
        root = stage(tree, temp, "t-obs", table)
        rp, sha = mirror_receipt(tree, root, ROW, "3.15." + NINETEEN, "fired")
        report["T-OBS"] = classify(run_cli(tree, root, receipt=rp, sha=sha))

        # T-OBS-NOMIRROR: same table edit, receipt left as the pinned default.
        root2 = stage(tree, temp, "t-obs-nomirror", table)
        report["T-OBS-NOMIRROR"] = classify(
            run_cli(tree, root2, receipt=default_receipt(tree),
                    sha=hashlib.sha256(default_receipt(tree).read_bytes()).hexdigest()))

        # T-ANC: 19-digit component in the anchored_version.
        table = edit_row(base_table, ROW, anchored="1.2." + NINETEEN,
                         observed="1.2." + NINETEEN, verdict="not-fired")
        root3 = stage(tree, temp, "t-anc", table)
        rp, sha = mirror_receipt(tree, root3, ROW, "1.2." + NINETEEN, "not-fired")
        report["T-ANC"] = classify(run_cli(tree, root3, receipt=rp, sha=sha))

        # F-NEW: feed whose newest entry carries a 19-digit component.
        # F-OLD: the 19-digit entry orders BELOW the newest canonical entry.
        # F-ONLY: a feed whose only stable entry is the 19-digit token.
        for nm, titles in (("F-NEW", ["v3.15.1", "v3.15." + NINETEEN]),
                           ("F-OLD", ["v3.15.1", "v3.14." + NINETEEN]),
                           ("F-ONLY", ["v3.15." + NINETEEN])):
            res = observe_fixture(tree, temp, nm.lower(), titles)
            report[nm] = classify(res)
            report[nm]["receipt_record"] = res.get("receipt_record")

        # T-DERIVED: a derived: row whose anchored_version carries 19 digits.
        table = edit_row(base_table, "S008", anchored="1.2." + NINETEEN,
                         observed="1.2." + NINETEEN, verdict="not-fired")
        root4 = stage(tree, temp, "t-derived", table)
        rp, sha = mirror_receipt(tree, root4, "S008", "1.2." + NINETEEN, "not-fired")
        report["T-DERIVED"] = classify(run_cli(tree, root4, receipt=rp, sha=sha))

    Path(args.out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
