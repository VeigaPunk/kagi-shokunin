#!/usr/bin/env python3
"""FFeedTie round-2 probe: the canonical/non-canonical NUMERIC TIE, both orders.

Two layers:
  A) unit level (import the tree's own release-clock.py, no network, no writes):
     what does the tree's parser name for a feed holding a canonical token and
     a non-canonical token with the SAME numeric value, in both entry orders?
  B) end-to-end level (--observe with the transport stubbed, as the script's
     own selftest does): what typed finding does the clock emit, is a fired
     verdict written, is there a traceback?

Usage: tie_probe.py TREE LABEL OUT.json
"""
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

FIXTURE_ROW = "S040"
BASE_ERA_CATEGORIES = {
    "ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
    "RECEIPT-MISMATCH", "NOT OBSERVED",
}

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


def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"


module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, index)
        for index, title in enumerate(titles)
    )
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        + entries + "</feed>\n"
    ).encode("utf-8")


def load_module(tree):
    spec = importlib.util.spec_from_file_location(
        "rc_" + Path(tree).name, Path(tree) / "corpus" / "release-clock.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def unit_layer(tree):
    """What does the tree's own parser name / refuse for each tie shape?"""
    module = load_module(tree)
    out = {}
    cases = {
        "tie-canon-first": [b"v3.15.1", b"v3.15.01"],
        "tie-nc-first": [b"v3.15.01", b"v3.15.1"],
        "tie-below-newer": [b"v3.15.2", b"v3.15.1", b"v3.15.01"],
        "tie-oversize-canon-first": [b"v3.15.1", b"v3.15." + b"0" * 18 + b"1"],
        "oversize-below-newer": [b"v3.15.2", b"v3.14." + b"1" * 4301],
        "nc-only": [b"v3.15.01"],
        "control": [b"v3.15.1", b"v3.15.0"],
    }
    for name, tokens in cases.items():
        body = b"".join(
            b"<entry><title>" + t + b"</title><link href=\"/releases/tag/" + t
            + b"\"/></entry>" for t in tokens)
        document = (b'<?xml version="1.0" encoding="utf-8"?>'
                    b'<feed xmlns="http://www.w3.org/2005/Atom">'
                    + body + b"</feed>")
        try:
            got = module.parse_latest_version(document)
            outcome = {"named": got}
        except Exception as exc:            # noqa: BLE001 - probe records the type
            outcome = {"named": None, "error_type": type(exc).__name__,
                       "error": str(exc)[:120]}
        outcome["tokens"] = [t.decode() for t in tokens]
        out[name] = outcome
    # numeric order of the tied pair as the tree computes it
    if hasattr(module, "version_order"):
        out["_version_order"] = {
            "3.15.1": module.version_order("3.15.1"),
            "3.15.01": module.version_order("3.15.01"),
        }
    if hasattr(module, "non_canonical_version"):
        out["_non_canonical"] = {
            "3.15.1": module.non_canonical_version("3.15.1"),
            "3.15.01": module.non_canonical_version("3.15.01"),
            "3.15.00": module.non_canonical_version("3.15.00"),
        }
    return out


def row_fields(table_text, row_id):
    for line in table_text.splitlines():
        fields = line.split("\t")
        if fields and fields[0] == row_id:
            return fields
    raise RuntimeError("row %s missing" % row_id)


def narrow_table(tree, row_id):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = [line for line in lines
            if line.rstrip("\n").split("\t")[0] in ("id", row_id)]
    return "".join(kept)


def narrow_sources(tree, keep_ids):
    import re
    lines = (tree / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines(
        keepends=True)
    kept = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [c.strip() for c in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) \
                    and cells[0] not in keep_ids:
                continue
        kept.append(line)
    return "".join(kept)


def stage(tree, temp, name, table_text, sources_text):
    root = temp / ("fx-" + name)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        (root / "corpus" / rel).write_bytes((tree / "corpus" / rel).read_bytes())
    (root / "corpus" / "SOURCES.md").write_text(sources_text, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    return root


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=180)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr}


def receipt_record(path, row_id):
    try:
        document = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None
    for record in document.get("observations") or []:
        if isinstance(record, dict) and record.get("id") == row_id:
            return record
    return None


def e2e_case(tree, temp, env, runner, name, titles):
    table_text = narrow_table(tree, FIXTURE_ROW)
    fields = row_fields(table_text, FIXTURE_ROW)
    feed_url, observed_at, feed_source_id = fields[3], fields[6], fields[2]
    sources_text = narrow_sources(tree, {FIXTURE_ROW, feed_source_id})
    root = stage(tree, temp, name, table_text, sources_text)
    feed = root / "feed.atom"
    feed.write_bytes(atom_feed(titles))
    out = root / "observe-out.json"
    result = run(["python3", "-I", "-B", str(runner), str(tree), str(root),
                  str(out), str(feed), feed_url, observed_at], tree, env)
    record = receipt_record(out, FIXTURE_ROW)
    combined = result["stdout"] + "\n" + result["stderr"]
    cats = [line.strip().split()[0] for line in result["stdout"].splitlines()
            if line.strip() and not line.strip().startswith("RELEASE_CLOCK")]
    new_cats = [c for c in cats if c not in BASE_ERA_CATEGORIES]
    return name, {
        "argv": result["argv"],
        "exit": result["exit"],
        "stdout": result["stdout"],
        "stderr": result["stderr"],
        "traceback": "Traceback" in combined,
        "categories": cats,
        "new_categories": new_cats,
        "receipt_record": record,
        "fired_written": bool(record and record.get("verdict") == "fired"),
        "titles": titles,
    }


def main():
    if len(sys.argv) != 4:
        raise SystemExit("usage: tie_probe.py TREE LABEL OUT.json")
    tree, label, out_path = Path(sys.argv[1]).resolve(), sys.argv[2], sys.argv[3]
    temp = Path(tempfile.mkdtemp(prefix="ffeedtie2-"))
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    runner = temp / "observe-runner.py"
    runner.write_text(RUNNER, encoding="utf-8")

    document = {"format": "ffeedtie-probe-v1", "label": label, "tree": str(tree)}
    document["unit"] = unit_layer(tree)

    e2e = {}
    for name, titles in (
        ("E2E-tie-canon-first", ["Python 3.15.1", "Python 3.15.01"]),
        ("E2E-tie-nc-first", ["Python 3.15.01", "Python 3.15.1"]),
        ("E2E-tie-below-newer", ["Python 3.15.2", "Python 3.15.1", "Python 3.15.01"]),
        ("E2E-oversize-below-newer",
         ["Python 3.15.2", "Python 3.14." + "1" * 4301]),
        ("E2E-nc-only", ["Python 3.15.01"]),
        ("E2E-control", ["Python 3.15.1", "Python 3.15.0"]),
    ):
        key, value = e2e_case(tree, temp, env, runner, name, titles)
        e2e[key] = value
    document["e2e"] = e2e

    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    Path(out_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")

    print("UNIT (parse_latest_version):")
    for key, value in document["unit"].items():
        if key.startswith("_"):
            print("  %-24s %s" % (key, json.dumps(value)))
        else:
            print("  %-24s %s" % (key, json.dumps(value)))
    print("E2E (--observe, transport stubbed):")
    for key in sorted(e2e):
        value = e2e[key]
        record = value["receipt_record"] or {}
        print("  %-24s exit=%s tb=%s fired=%s new_cats=%s rec_verdict=%s "
              "rec_parsed=%s rec_error=%s" % (
                  key, value["exit"], value["traceback"], value["fired_written"],
                  value["new_categories"], record.get("verdict"),
                  record.get("parsed_version"), record.get("error")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
