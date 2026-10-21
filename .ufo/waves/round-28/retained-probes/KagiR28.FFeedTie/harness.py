#!/usr/bin/env python3
"""FFeedTie independent falsification harness (round-28 C1/C2 carrier).

Reproduces candidate behaviour for a canonical / non-canonical NUMERIC TIE
(a canonical X.Y.Z token and a non-canonical token with the SAME numeric
value, e.g. 3.15.1 vs 3.15.01) in BOTH orders, in the feed path and in the
table path, on an isolated exported tree.

Independent of .ufo/waves/round-28/tools/c1-measure.py: no import, its own
fixture construction, its own predicates, its own runner.

Usage: harness.py TREE LABEL OUT.json
"""
import json
import os
import re
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
"""release-clock.py main() with the network transport stubbed to serve a local
fixture feed and the clock pinned to the row's observed_at date."""
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


def row_fields(table_text, row_id):
    for line in table_text.splitlines():
        fields = line.split("\t")
        if fields and fields[0] == row_id:
            return fields
    raise RuntimeError("row %s missing" % row_id)


def narrow_table(tree, row_id):
    """release-clocks.tsv with only the header and the given row."""
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if not fields:
            continue
        if fields[0] == "id":
            kept.append(line)
        elif fields[0] == row_id:
            kept.append(line)
    return "".join(kept)


def edit_table(tree, row_id, anchored=None, observed=None, verdict=None):
    text = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8")
    fields = row_fields(text, row_id)
    if anchored is not None:
        fields[4] = anchored
    if observed is not None:
        fields[5] = observed
    if verdict is not None:
        fields[7] = verdict
    out = []
    for line in text.splitlines(keepends=True):
        f = line.rstrip("\n").split("\t")
        if f and f[0] == row_id:
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def narrow_sources(tree, keep_ids):
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


def categories(stdout):
    found = []
    for line in stdout.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("RELEASE_CLOCK"):
            continue
        found.append((stripped.split()[0], stripped))
    return found


def receipt_record(path, row_id):
    try:
        document = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None
    for record in document.get("observations") or []:
        if isinstance(record, dict) and record.get("id") == row_id:
            return record
    return None


def last_line(stdout):
    lines = stdout.strip().splitlines()
    return lines[-1] if lines else ""


def classify(result):
    combined = result["stdout"] + "\n" + result["stderr"]
    result["traceback"] = "Traceback" in combined
    result["categories"] = categories(result["stdout"])
    result["new_categories"] = [c for c in result["categories"]
                                if c[0] not in BASE_ERA_CATEGORIES]
    record = result.get("record")
    result["fired_written"] = bool(
        isinstance(record, dict) and record.get("verdict") == "fired")
    result["clean"] = last_line(result["stdout"]).startswith("RELEASE_CLOCK: CLEAN")
    result["last_line"] = last_line(result["stdout"])
    result["mishandled"] = (
        (result["exit"] == 0 and result["clean"]) or result["fired_written"]
        or result["traceback"])
    return result


def feed_case(tree, temp, env, runner, name, titles):
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
    result["record"] = receipt_record(out, FIXTURE_ROW)
    result["titles"] = titles
    return name, classify(result)


def observe_table_case(tree, temp, env, runner, name, anchored, observed,
                        verdict, feed_titles):
    """Table edited; --observe runs against a clean canonical feed."""
    table_text = edit_table(tree, FIXTURE_ROW, anchored=anchored,
                            observed=observed, verdict=verdict)
    fields = row_fields(table_text, FIXTURE_ROW)
    feed_url, observed_at, feed_source_id = fields[3], fields[6], fields[2]
    sources_text = narrow_sources(tree, {FIXTURE_ROW, feed_source_id})
    root = stage(tree, temp, name, table_text, sources_text)
    feed = root / "feed.atom"
    feed.write_bytes(atom_feed(feed_titles))
    out = root / "observe-out.json"
    result = run(["python3", "-I", "-B", str(runner), str(tree), str(root),
                  str(out), str(feed), feed_url, observed_at], tree, env)
    result["record"] = receipt_record(out, FIXTURE_ROW)
    result["edited"] = {"anchored": anchored, "observed": observed,
                        "verdict": verdict}
    return name, classify(result)


def mirrored_table_case(tree, temp, env, name, anchored, observed, verdict,
                         receipt_rel):
    """Table edited AND the pinned receipt mirrored (plan correction), so the
    run cannot end in a generic RECEIPT-MISMATCH: the typed category must be
    the NEW one."""
    table_text = edit_table(tree, FIXTURE_ROW, anchored=anchored,
                            observed=observed, verdict=verdict)
    fields = row_fields(table_text, FIXTURE_ROW)
    feed_source_id = fields[2]
    sources_text = narrow_sources(tree, {FIXTURE_ROW, feed_source_id})
    root = stage(tree, temp, name, table_text, sources_text)
    receipt = json.loads((tree / receipt_rel).read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record.get("id") == FIXTURE_ROW:
            record["parsed_version"] = observed
            record["verdict"] = verdict
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    import hashlib
    sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
    result = run(["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
                  "--root", str(root), "--receipt", str(receipt_path),
                  "--receipt-sha", sha], tree, env)
    result["record"] = None
    result["edited"] = {"anchored": anchored, "observed": observed,
                        "verdict": verdict}
    return name, classify(result)


def receipt_tie_case(tree, temp, env, name, receipt_rel):
    """Table row kept CANONICAL (3.15.1/3.15.1/not-fired); the pinned receipt's
    S040 record carries the non-canonical TWIN 3.15.01 with verdict fired.
    A tie inside the receipt binding: the receipt claims a release the table
    never observed."""
    table_text = narrow_table(tree, FIXTURE_ROW)
    fields = row_fields(table_text, FIXTURE_ROW)
    feed_source_id = fields[2]
    sources_text = narrow_sources(tree, {FIXTURE_ROW, feed_source_id})
    root = stage(tree, temp, name, table_text, sources_text)
    receipt = json.loads((tree / receipt_rel).read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record.get("id") == FIXTURE_ROW:
            record["parsed_version"] = "3.15.01"
            record["verdict"] = "fired"
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    import hashlib
    sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
    result = run(["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
                  "--root", str(root), "--receipt", str(receipt_path),
                  "--receipt-sha", sha], tree, env)
    result["record"] = None
    result["edited"] = {"receipt_parsed_version": "3.15.01", "receipt_verdict": "fired"}
    return name, classify(result)


def default_receipt_rel(tree):
    code = (tree / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    match = re.search(
        r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")',
        code)
    if not match:
        raise RuntimeError("cannot locate the default receipt path")
    return "/".join(part.strip('" ') for part in match.group(1).split("/"))


def main():
    if len(sys.argv) != 4:
        raise SystemExit("usage: harness.py TREE LABEL OUT.json")
    tree, label, out_path = Path(sys.argv[1]).resolve(), sys.argv[2], sys.argv[3]
    temp = Path(tempfile.mkdtemp(prefix="ffeedtie-"))
    env = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": str(temp),
        "LC_ALL": "C",
        "PYTHONDONTWRITEBYTECODE": "1",
    }
    runner = temp / "observe-runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    receipt_rel = default_receipt_rel(tree)
    results = {}

    # ---- FEED PATH: numeric tie, both entry orders -------------------------
    name, r = feed_case(tree, temp, env, runner, "FEED-tie-canon-first",
                        ["Python 3.15.1", "Python 3.15.01"])
    results[name] = r
    name, r = feed_case(tree, temp, env, runner, "FEED-tie-nc-first",
                        ["Python 3.15.01", "Python 3.15.1"])
    results[name] = r
    # tie pair strictly below a newer canonical token
    name, r = feed_case(tree, temp, env, runner, "FEED-tie-below-max",
                        ["Python 3.16.0", "Python 3.15.1", "Python 3.15.01"])
    results[name] = r
    # non-canonical only
    name, r = feed_case(tree, temp, env, runner, "FEED-nc-only",
                        ["Python 3.15.01"])
    results[name] = r
    # oversize tie partner (19-digit component, numerically equal to 1)
    name, r = feed_case(tree, temp, env, runner, "FEED-tie-oversize",
                        ["Python 3.15.1", "Python 3.15." + "0" * 18 + "1"])
    results[name] = r
    # control: clean canonical feed
    name, r = feed_case(tree, temp, env, runner, "FEED-control",
                        ["Python 3.15.1", "Python 3.15.0"])
    results[name] = r

    # ---- TABLE PATH: numeric tie across anchored / observed, both orders ---
    name, r = observe_table_case(tree, temp, env, runner, "TABLE-tie-observed-nc",
                                 anchored="3.15.1", observed="3.15.01",
                                 verdict="fired", feed_titles=["Python 3.15.1"])
    results[name] = r
    name, r = observe_table_case(tree, temp, env, runner, "TABLE-tie-anchored-nc",
                                 anchored="3.15.01", observed="3.15.1",
                                 verdict="fired", feed_titles=["Python 3.15.1"])
    results[name] = r
    name, r = observe_table_case(tree, temp, env, runner, "TABLE-control",
                                 anchored="3.15.1", observed="3.15.1",
                                 verdict="not-fired",
                                 feed_titles=["Python 3.15.1"])
    results[name] = r

    # ---- TABLE PATH with the pinned receipt mirrored (plan correction) ------
    name, r = mirrored_table_case(tree, temp, env, "TABLE-mirror-observed-nc",
                                  anchored="3.15.1", observed="3.15.01",
                                  verdict="fired", receipt_rel=receipt_rel)
    results[name] = r
    name, r = mirrored_table_case(tree, temp, env, "TABLE-mirror-anchored-nc",
                                  anchored="3.15.01", observed="3.15.1",
                                  verdict="fired", receipt_rel=receipt_rel)
    results[name] = r

    # ---- RECEIPT TYPING: receipt carries the non-canonical twin of the
    # table's canonical observation (the tie inside the receipt binding) ------
    name, r = receipt_tie_case(tree, temp, env, "RECEIPT-tie-parsed-nc",
                               receipt_rel=receipt_rel)
    results[name] = r

    # Control: unmodified tree, default command.
    control = run(["python3", "-I", "-B", "corpus/release-clock.py"], tree, env)
    control["last_line"] = last_line(control["stdout"])
    results["control"] = control

    document = {
        "format": "ffeedtie-harness-v1",
        "label": label,
        "tree": str(tree),
        "cases": results,
    }
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    Path(out_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    for name in sorted(results):
        case = results[name]
        if name == "control":
            print("%-26s exit=%s last=%s" % (name, case["exit"], case["last_line"]))
            continue
        record = case.get("record") or {}
        print("%-26s exit=%s mish=%s tb=%s fired=%s cats=%s new=%s "
              "rec_verdict=%s rec_err=%s" % (
                  name, case["exit"], case["mishandled"], case["traceback"],
                  case["fired_written"],
                  [c[0] for c in case["categories"]],
                  [c[0] for c in case["new_categories"]],
                  record.get("verdict"), record.get("error")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
