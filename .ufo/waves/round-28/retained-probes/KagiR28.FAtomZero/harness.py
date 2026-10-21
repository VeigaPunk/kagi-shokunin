#!/usr/bin/env python3
"""KagiR28.FAtomZero independent harness (Atom newest leading-zero title carrier).

Builds an isolated fixture root from an exported tree (candidate or BASE),
serves a local python.org-shaped Atom feed through release-clock.py's own
main() with request_body stubbed (no network), and reports the exact exit
code, stdout, stderr and the written observation receipt.

Usage: harness.py TREE_DIR OUT_DIR TITLES_JSON
TITLES_JSON: JSON list of Atom <title> strings, newest first.
"""
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

FIXTURE_ROW = "S040"
FEED_SOURCE = "S039"

RUNNER = r'''#!/usr/bin/env python3
import importlib.util
import sys
from pathlib import Path

tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
calls = []


def fixture_request_body(url, opener=None, resolver=None):
    calls.append(url)
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"


module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
code = module.main(["--root", root, "--observe", out])
sys.stderr.write("HARNESS_FETCH_CALLS=%r\n" % (calls,))
raise SystemExit(code)
'''


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, index)
        for index, title in enumerate(titles))
    document = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        + entries + "</feed>\n")
    return document.encode("utf-8")


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


def narrow_table(text, keep):
    kept = []
    for line in text.splitlines(keepends=True):
        fields = line.rstrip("\n").split("\t")
        if fields and re.fullmatch(r"S[0-9]{3}", fields[0]) and fields[0] not in keep:
            continue
        kept.append(line)
    return "".join(kept)


def row_fields(text, row_id):
    for line in text.splitlines():
        fields = line.split("\t")
        if fields and fields[0] == row_id:
            return fields
    raise SystemExit("row %s missing" % row_id)


def main():
    tree = Path(sys.argv[1]).resolve()
    out_dir = Path(sys.argv[2]).resolve()
    titles = json.loads(sys.argv[3])
    raw_feed = sys.argv[4] if len(sys.argv) > 4 else None
    out_dir.mkdir(parents=True, exist_ok=True)
    root = out_dir / "root"
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    corpus = tree / "corpus"
    for name in ("source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(corpus / name, root / "corpus" / name)
    (root / "corpus" / "SOURCES.md").write_text(
        narrow_sources((corpus / "SOURCES.md").read_text(encoding="utf-8"),
                       {FIXTURE_ROW, FEED_SOURCE}), encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(
        narrow_table((corpus / "release-clocks.tsv").read_text(encoding="utf-8"),
                     {FIXTURE_ROW}), encoding="utf-8")
    if len(sys.argv) > 5:
        overrides = json.loads(sys.argv[5])
        table = (root / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8")
        out_lines = []
        for line in table.splitlines(keepends=True):
            fields = line.rstrip("\n").split("\t")
            if fields and fields[0] == FIXTURE_ROW:
                for index, value in overrides.items():
                    fields[int(index)] = value
                line = "\t".join(fields) + "\n"
            out_lines.append(line)
        (root / "corpus" / "release-clocks.tsv").write_text(
            "".join(out_lines), encoding="utf-8")
    fields = row_fields((root / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8"), FIXTURE_ROW)
    feed_url, observed_at = fields[3], fields[6]
    feed = out_dir / "feed.atom"
    feed.write_bytes(Path(raw_feed).read_bytes() if raw_feed else atom_feed(titles))
    runner = out_dir / "runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    out_receipt = out_dir / "observe-out.json"
    if out_receipt.exists():
        out_receipt.unlink()
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(out_dir),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    proc = subprocess.run(
        ["python3", "-I", "-B", str(runner), str(tree), str(root),
         str(out_receipt), str(feed), feed_url, observed_at],
        cwd=str(tree), env=env, text=True, capture_output=True, timeout=120)
    receipt = None
    if out_receipt.exists():
        receipt = json.loads(out_receipt.read_text(encoding="utf-8"))
    report = {
        "tree": str(tree),
        "titles": titles,
        "argv_row": fields,
        "exit": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "traceback_in_output": "Traceback" in (proc.stdout + proc.stderr),
        "receipt_records": (receipt or {}).get("observations"),
        "stdout_finding_lines": [
            line for line in proc.stdout.splitlines()
            if line.strip() and not line.startswith("RELEASE_CLOCK")],
    }
    (out_dir / "report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
