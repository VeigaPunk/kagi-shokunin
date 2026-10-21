#!/usr/bin/env python3
"""Round-28 C1 counting instrument (frozen counting command, plans/round-28.md C1).

c1-measure.py REV LABEL OUT.json

Exports REV's tree with `git -C <lane> archive REV` into a private temp dir
(the lane checkout is never touched) and measures four C1 fixtures plus the
default control on that exported tree:

  F1 table-lie       S040 observed_version=3.15.01, verdict=fired. Table edit
                     mirrored into a copy of the default receipt, run with
                     --receipt/--receipt-sha (L1 plan correction: the pinned
                     default receipt alone ends RECEIPT-MISMATCH and would
                     never measure the targeted behaviour; construction as in
                     round-27 tools/c2-measure.py).
  F2 table-oversize  S040 observed_version=3.15. + 4301*"1", verdict=fired.
                     Same table + receipt-mirror construction.
  F3 observe-zero    --observe over a local python.org-shaped feed whose
                     newest stable item is titled "Python 3.15.01". The
                     fixture row is mirrored (observed 3.15.01 / fired) so the
                     receipt written by --observe validates against the table
                     and the written fired observation is the measured signal.
  F4 observe-oversize  the same with a 4301-digit patch component.
  control            the unmodified tree, default command.

release-clock.py's own transport admits only public HTTPS
(valid_public_https_url / public_addresses), so no --observe run can read a
local feed file: recorded as a frozen-spec defect in
.ufo/waves/round-28/build/XC1Measure.md. The faithful harness runs the
exported release-clock.py's own main() in a child `python3 -I -B` with the
module-global request_body replaced by a stub that serves the fixture feed
bytes (the same substitution the script's own selftest uses for
request_body/utc_timestamp) and utc_timestamp pinned to the row's observed_at
date. The binding table is narrowed to the S040 row and the registry to the
S040 row and its feed source (S039), all rows verbatim, so the stub is the
only fetch and no unrelated row is observed or fabricated.

Predicate (frozen): a fixture is MISHANDLED when it exits 0 with a
`RELEASE_CLOCK: CLEAN` last stdout line or a written fired observation
(receipt record verdict "fired" for the fixture row), or when its combined
output contains "Traceback". It is TYPED when it exits 1, prints no traceback
and a stdout line names a typed finding for the fixture row (S040) or its
feed URL with a category token outside the BASE-era set {ORPHAN, UNBOUND,
INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}
(corpus/release-clock.py evaluate() error categories at BASE
3553d499577084a6c98d7078906017840bbf7b28; frozen at instrument-creation time
so a post-fix category cannot exclude itself). Everything else -- including
exit 2 SETUP and generic receipt-integrity findings -- is OTHER.
"""
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

LANE = Path(__file__).resolve().parents[4]
FIXTURE_ROW = "S040"
BASE_ERA_CATEGORIES = {
    "ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
    "RECEIPT-MISMATCH", "NOT OBSERVED",
}
OVERSIZE_COMPONENT = "1" * 4301
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")

RUNNER = r'''#!/usr/bin/env python3
"""F3/F4 runner: release-clock.py's own main() with the network transport
stubbed to serve the local fixture feed and the clock pinned to the row's
observed_at date (substitutions the script's own selftest also uses)."""
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
    document = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        + entries + "</feed>\n"
    )
    return document.encode("utf-8")


def edited_table(tree, edits, narrow=False):
    """release-clocks.tsv with fields[5]/fields[7] replaced for edited rows.

    narrow=True keeps only the header and the edited rows (observe fixtures)."""
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            fields[5], fields[7] = edits[fields[0]]
            kept.append("\t".join(fields) + "\n")
        elif narrow and (not fields or fields[0] != "id"):
            continue
        else:
            kept.append(line)
    return "".join(kept)


def row_fields(table_text, row_id):
    for line in table_text.splitlines():
        fields = line.split("\t")
        if fields and fields[0] == row_id:
            return fields
    raise RuntimeError("row %s missing from fixture table" % row_id)


def default_receipt_rel(tree):
    code = (tree / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    match = re.search(
        r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")',
        code)
    if not match:
        raise RuntimeError(
            "cannot locate the default receipt path in release-clock.py")
    return "/".join(part.strip('" ') for part in match.group(1).split("/"))


def narrowed_sources(tree, keep_ids):
    """SOURCES.md with registry rows outside keep_ids dropped, rows verbatim."""
    lines = (tree / "corpus" / "SOURCES.md").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [cell.strip() for cell in stripped[1:].split("|")]
            if cells and re.fullmatch(r"S[0-9]{3}", cells[0]) \
                    and cells[0] not in keep_ids:
                continue
        kept.append(line)
    return "".join(kept)


def stage_fixture(tree, temp, name, table_text, sources_text=None):
    root = temp / ("fixture-" + name)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    if sources_text is not None:
        (root / "corpus" / "SOURCES.md").write_text(
            sources_text, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(
        table_text, encoding="utf-8")
    return root


def mirrored_receipt(tree, receipt_rel, edits, root):
    receipt = json.loads(
        (tree / receipt_rel).read_text(encoding="utf-8"))
    mirrored = []
    for record in receipt["observations"]:
        if record.get("id") in edits:
            record["parsed_version"], record["verdict"] = edits[record["id"]]
            mirrored.append(record["id"])
    path = root / "receipt.json"
    path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return path, hashlib.sha256(path.read_bytes()).hexdigest(), mirrored


def last_nonempty(text):
    lines = [line for line in text.splitlines() if line.strip()]
    return lines[-1] if lines else ""


def finding_lines(stdout, row_id, feed_url):
    found = []
    for line in stdout.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("RELEASE_CLOCK"):
            continue
        if row_id in stripped or feed_url in stripped:
            token = stripped.split()[0]
            if token not in BASE_ERA_CATEGORIES:
                found.append(stripped)
    return found


def receipt_fired(path, row_id):
    try:
        document = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return False, None
    records = document.get("observations") or []
    fired = any(
        isinstance(record, dict) and record.get("id") == row_id
        and record.get("verdict") == "fired"
        for record in records)
    summary = [
        {"id": record.get("id"), "verdict": record.get("verdict"),
         "error": record.get("error"),
         "parsed_version": record.get("parsed_version")}
        for record in records if isinstance(record, dict)
    ]
    return fired, summary


def classify(result, row_id, feed_url):
    output = result["stdout"] + "\n" + result["stderr"]
    traceback = "Traceback" in output
    clean = last_nonempty(result["stdout"]).startswith("RELEASE_CLOCK: CLEAN")
    findings = finding_lines(result["stdout"], row_id, feed_url)
    if (result["exit"] == 0 and (clean or result["fired_observation_written"])) or traceback:
        verdict = "MISHANDLED"
    elif result["exit"] == 1 and not traceback and findings:
        verdict = "TYPED"
    else:
        verdict = "OTHER"
    result["verdict"] = verdict
    result["clean_last_line"] = clean
    result["traceback_in_output"] = traceback
    result["typed_finding_lines"] = findings
    return result


def tails(text, count=8):
    lines = text.splitlines()
    return lines[-count:]


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=120)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr}


def check_fixture(tree, temp, env, name, observed_version, receipt_rel):
    edits = {FIXTURE_ROW: (observed_version, "fired")}
    root = stage_fixture(tree, temp, name,
                         edited_table(tree, edits))
    receipt_path, sha, mirrored = mirrored_receipt(
        tree, receipt_rel, edits, root)
    result = run(
        ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
         "--root", str(root), "--receipt", str(receipt_path),
         "--receipt-sha", sha],
        cwd=tree, env=env)
    result.update({
        "fired_observation_written": False,
        "receipt": None,
        "mirrored_rows": mirrored,
        "note": "table + mirrored receipt, --receipt/--receipt-sha",
    })
    return name, classify(result, FIXTURE_ROW, "")


def observe_fixture(tree, temp, env, runner_path, name, observed_version,
                    titles):
    edits = {FIXTURE_ROW: (observed_version, "fired")}
    table_text = edited_table(tree, edits, narrow=True)
    fields = row_fields(table_text, FIXTURE_ROW)
    feed_url, observed_at = fields[3], fields[6]
    feed_source_id = fields[2]
    sources_text = narrowed_sources(tree, {FIXTURE_ROW, feed_source_id})
    root = stage_fixture(tree, temp, name, table_text, sources_text)
    feed = root / "feed.atom"
    feed.write_bytes(atom_feed(titles))
    out_receipt = root / "observe-out.json"
    result = run(
        ["python3", "-I", "-B", str(runner_path), str(tree), str(root),
         str(out_receipt), str(feed), feed_url, observed_at],
        cwd=tree, env=env)
    fired, receipt_summary = receipt_fired(out_receipt, FIXTURE_ROW)
    result.update({
        "fired_observation_written": fired,
        "receipt": receipt_summary,
        "receipt_path": str(out_receipt),
        "feed_url": feed_url,
        "mirrored_rows": [FIXTURE_ROW],
        "note": ("--observe via release-clock.py main(); request_body stubbed "
                 "to the local fixture feed, utc_timestamp pinned to the row "
                 "date; table narrowed to the fixture row"),
    })
    return name, classify(result, FIXTURE_ROW, feed_url)


def main():
    if len(sys.argv) != 4 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[1]):
        raise SystemExit("usage: c1-measure.py FULL_REV LABEL OUT.json")
    rev, label, out = sys.argv[1:4]
    temp = Path(tempfile.mkdtemp(prefix="kagi-r28-c1-"))
    try:
        archive = subprocess.run(
            ["git", "-C", str(LANE), "archive", "--format=tar", rev],
            capture_output=True, timeout=300)
        if archive.returncode != 0:
            raise RuntimeError(
                "git archive failed: %s" % archive.stderr.decode().strip())
        tree = temp / "tree"
        tree.mkdir()
        with tarfile.open(fileobj=io.BytesIO(archive.stdout)) as tar:
            tar.extractall(tree, filter="data")
        env = {
            "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
            "HOME": str(temp),
            "LC_ALL": "C",
            "PYTHONDONTWRITEBYTECODE": "1",
        }
        receipt_rel = default_receipt_rel(tree)
        runner_path = temp / "observe-runner.py"
        runner_path.write_text(RUNNER, encoding="utf-8")

        results = {}
        name, result = check_fixture(
            tree, temp, env, "F1-table-lie", "3.15.01", receipt_rel)
        results[name] = result
        name, result = check_fixture(
            tree, temp, env, "F2-table-oversize",
            "3.15." + OVERSIZE_COMPONENT, receipt_rel)
        results[name] = result
        name, result = observe_fixture(
            tree, temp, env, runner_path, "F3-observe-zero", "3.15.01",
            ["Python 3.15.01", "Python 3.15.0"])
        results[name] = result
        name, result = observe_fixture(
            tree, temp, env, runner_path, "F4-observe-oversize",
            "3.15." + OVERSIZE_COMPONENT,
            ["Python 3.15." + OVERSIZE_COMPONENT, "Python 3.15.0"])
        results[name] = result

        control = run(["python3", "-I", "-B", "corpus/release-clock.py"],
                      cwd=tree, env=env)
        control_last = last_nonempty(control["stdout"])
        results["control"] = {
            "argv": control["argv"], "exit": control["exit"],
            "last_line": control_last, "stdout": control["stdout"],
            "stderr": control["stderr"],
            "clean": control["exit"] == 0
            and control_last.startswith("RELEASE_CLOCK: CLEAN"),
        }
    finally:
        shutil.rmtree(temp, ignore_errors=True)

    fixtures = [name for name in results
                if name.startswith(("F1-", "F2-", "F3-", "F4-"))]
    for name in fixtures:
        for channel in ("stdout", "stderr"):
            results[name][channel] = tails(results[name][channel])
    summary = {
        "mishandled": sum(results[name]["verdict"] == "MISHANDLED"
                          for name in fixtures),
        "typed": sum(results[name]["verdict"] == "TYPED" for name in fixtures),
        "other": sum(results[name]["verdict"] == "OTHER" for name in fixtures),
        "fixtures": len(fixtures),
    }
    document = {
        "format": "kagi-round28-c1-measure-v1",
        "revision": rev,
        "label": label,
        "fixtures": {name: results[name] for name in fixtures},
        "summary": summary,
        "control": results["control"],
    }
    Path(out).parent.mkdir(parents=True, exist_ok=True)
    Path(out).write_text(json.dumps(document, indent=2) + "\n",
                         encoding="utf-8")
    print("C1_MEASURE %s: mishandled=%d/%d typed=%d/%d other=%d/%d "
          "control_exit=%d control_clean=%s" % (
              label, summary["mishandled"], summary["fixtures"],
              summary["typed"], summary["fixtures"],
              summary["other"], summary["fixtures"],
              results["control"]["exit"], results["control"]["clean"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
