#!/usr/bin/env python3
"""Round-29 C1 counting instrument (frozen counting command, plans/round-29.md C1
as corrected by plans/round-29.md Correction 1: child processes run
sys.executable because `python3` is a Store stub on the round-29 Windows host;
on a POSIX host the same tool bytes run unchanged under python3).

c1-measure.py REV LABEL OUT.json

Exports REV's tree with `git -C <lane> archive REV` into a private temp dir
(the lane checkout is never touched) and measures, on that exported tree:

  NF1 title-period-noncanonical  Atom titles "Python 3.15.0" and
                                 "Python 3.15.01." through --observe on the
                                 S040 row (verbatim) narrowed to {S040,S039}.
        Correct: exit 1 and a stdout finding line "NON-CANONICAL S040".
  NF2 title-period-canonical     Atom title "Python 3.15.1." alone.
        Correct: exit 0, CLEAN last line, receipt parsed_version "3.15.1",
        no typed finding for S040.
  NF3 href-period-noncanonical   Atom links /releases/tag/v3.14.0 and
                                 /releases/tag/v3.15.01. (S040 row).
        Correct: exit 1 and "NON-CANONICAL S040".
  NF4 text-period-noncanonical   Body "Version: 8.23.01.\n" through the S029
                                 row (verbatim) narrowed to {S029,S037}.
        Correct: exit 1 and "NON-CANONICAL S029".
  NF5 title-comma-prose          Atom titles "Python 3.15.0" and
                                 "Python 3.15.1, out now" (S040 row).
        Correct: exit 0, CLEAN, receipt parsed_version "3.15.1".
  NF6 title-prerelease-sibling   Atom title "Python 3.15.1rc1" alone.
        Correct (control, both revisions): exit 1, receipt error exactly
        "feed has no stable X.Y.Z release entry", no NON-CANONICAL line.
  NF7 four-component-sibling     Atom title "Python 3.15.1.2" alone.
        Correct (control, both revisions): same as NF6.
  F1..F4  the round-28 counter REPLAY: fixtures, table/receipt mirroring,
          narrowing and predicates VERBATIM from
          .ufo/waves/round-28/tools/c1-measure.py (F1 table-lie 3.15.01,
          F2 table-oversize 4301-digit, F3 observe-zero, F4 observe-oversize;
          BASE-era category exclusion set unchanged), re-hosted so the child
          interpreter is sys.executable. The frozen round-28 tool itself is
          not modified.
  control  the exported tree's default command (must stay CLEAN exit 0).

A fixture is MISHANDLED when its output contains "Traceback", or when it
does not meet its Correct predicate above (NF1/NF3/NF4: the non-canonical
token is not named by the typed category; NF2/NF5: the canonical token is
invisible; NF6/NF7: the refusal is not the declared one). It is CORRECT when
the Correct predicate holds; anything else (e.g. exit 2 SETUP) is OTHER.

Summary line:
  C1_MEASURE <label>: NF mishandled=a/7 correct=b/7 other=c/7 replay
  mishandled=d/4 typed=e/4 other=f/4 control_exit=<n> control_clean=<bool>
  and exit 0 only when a==0, b==7, d==0, e==4 and control is clean.
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
TEXT_ROW = "S029"
BASE_ERA_CATEGORIES = {
    "ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
    "RECEIPT-MISMATCH", "NOT OBSERVED",
}
OVERSIZE_COMPONENT = "1" * 4301
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")
NO_STABLE_ENTRY = "feed has no stable X.Y.Z release entry"

RUNNER = r'''#!/usr/bin/env python3
"""Observe runner: release-clock.py's own main() with the network transport
stubbed to serve the local fixture body and the clock pinned to the row's
observed_at date (the substitutions the script's own selftest also uses)."""
import importlib.util
import sys
from pathlib import Path

tree, root, out, body_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
body_bytes = Path(body_file).read_bytes()


def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, body_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"


module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def atom_feed(entries):
    """entries: list of dicts {title: str|None, href: str|None}."""
    blocks = []
    for index, item in enumerate(entries):
        parts = ["  <entry>\n"]
        if item.get("title") is not None:
            parts.append("    <title>%s</title>\n" % item["title"])
        if item.get("href") is not None:
            parts.append('    <link href="%s" rel="alternate" type="text/html"/>\n'
                         % item["href"])
        parts.append("    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
                     % index)
        parts.append("    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n")
        blocks.append("".join(parts))
    document = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        + "".join(blocks) + "</feed>\n"
    )
    return document.encode("utf-8")


def edited_table(tree, edits, narrow=False):
    """release-clocks.tsv with fields[5]/fields[7] replaced for edited rows.

    narrow=True keeps only the header and the rows named in edits (observe
    fixtures). Verbatim construction from the round-28 frozen tool."""
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


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=300)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr}


def observe_run(tree, temp, env, runner_path, name, body, keep_ids, row_id):
    """--observe through the exported main(); table narrowed to row_id."""
    table_text = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8")
    original = row_fields(table_text, row_id)
    narrow_table = edited_table(tree, {row_id: (original[5], original[7])},
                                narrow=True)
    fields = row_fields(narrow_table, row_id)
    feed_url, observed_at = fields[3], fields[6]
    feed_source_id = fields[2]
    sources_text = narrowed_sources(tree, keep_ids | {row_id, feed_source_id})
    root = stage_fixture(tree, temp, name, narrow_table, sources_text)
    body_file = root / "feed-body.bin"
    body_file.write_bytes(body)
    out_receipt = root / "observe-out.json"
    result = run(
        [sys.executable, "-I", "-B", str(runner_path), str(tree), str(root),
         str(out_receipt), str(body_file), feed_url, observed_at],
        cwd=tree, env=env)
    try:
        receipt = json.loads(out_receipt.read_text(encoding="utf-8"))
        records = [r for r in receipt.get("observations", []) if r.get("id") == row_id]
        result["row_receipt"] = records[0] if records else None
    except (OSError, ValueError):
        result["row_receipt"] = None
    result["note"] = ("--observe via main(); request_body stubbed to the "
                      "fixture body, utc_timestamp pinned; table narrowed "
                      "to %s" % row_id)
    return result


def typed_line(stdout, row_id):
    return ("NON-CANONICAL %s" % row_id) in stdout


def row_findings(stdout, row_id, feed_url):
    found = []
    for line in stdout.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("RELEASE_CLOCK"):
            continue
        if row_id in stripped or (feed_url and feed_url in stripped):
            token = stripped.split()[0]
            if token not in BASE_ERA_CATEGORIES:
                found.append(stripped)
    return found


def classify_nf(result, name, row_id):
    """Frozen per-fixture predicates (module docstring)."""
    output = result["stdout"] + "\n" + result["stderr"]
    receipt = result.get("row_receipt") or {}
    traceback = "Traceback" in output
    if traceback:
        verdict = "MISHANDLED"
        return verdict, traceback
    if name in ("NF1-title-period-noncanonical", "NF3-href-period-noncanonical",
                "NF4-text-period-noncanonical"):
        ok = result["exit"] == 1 and typed_line(result["stdout"], row_id)
        verdict = "CORRECT" if ok else "MISHANDLED"
    elif name in ("NF2-title-period-canonical", "NF5-title-comma-prose"):
        clean = last_nonempty(result["stdout"]).startswith("RELEASE_CLOCK: CLEAN")
        ok = (result["exit"] == 0 and clean
              and receipt.get("parsed_version") == "3.15.1"
              and not row_findings(result["stdout"], row_id, receipt.get("url", "")))
        verdict = "CORRECT" if ok else "MISHANDLED"
    else:  # NF6/NF7 refusal controls
        ok = (result["exit"] == 1
              and receipt.get("error") == NO_STABLE_ENTRY
              and not typed_line(result["stdout"], row_id))
        verdict = "CORRECT" if ok else "MISHANDLED"
    return verdict, traceback


def check_nf(tree, temp, env, runner_path, name, body, keep_ids, row_id):
    result = observe_run(tree, temp, env, runner_path, name, body,
                         keep_ids, row_id)
    verdict, traceback = classify_nf(result, name, row_id)
    result.update({
        "verdict": verdict,
        "traceback_in_output": traceback,
        "name": name,
    })
    return name, result


# ---- round-28 counter replay (F1..F4), verbatim construction ---------------

def check_f_table(tree, temp, env, name, observed_version, receipt_rel):
    edits = {FIXTURE_ROW: (observed_version, "fired")}
    root = stage_fixture(tree, temp, name, edited_table(tree, edits))
    receipt_path, sha, mirrored = mirrored_receipt(
        tree, receipt_rel, edits, root)
    result = run(
        [sys.executable, "-I", "-B", str(tree / "corpus" / "release-clock.py"),
         "--root", str(root), "--receipt", str(receipt_path),
         "--receipt-sha", sha],
        cwd=tree, env=env)
    result.update({
        "fired_observation_written": False,
        "receipt": None,
        "mirrored_rows": mirrored,
        "note": "table + mirrored receipt, --receipt/--receipt-sha (r28 verbatim)",
    })
    return name, classify_f(result, FIXTURE_ROW, "")


def check_f_observe(tree, temp, env, runner_path, name, observed_version,
                    titles):
    original = row_fields(edited_table(tree, {}, narrow=False), FIXTURE_ROW)
    edits = {FIXTURE_ROW: (original[5], original[7])}
    table_text = edited_table(tree, edits, narrow=True)
    fields = row_fields(table_text, FIXTURE_ROW)
    feed_url, observed_at = fields[3], fields[6]
    feed_source_id = fields[2]
    sources_text = narrowed_sources(tree, {FIXTURE_ROW, feed_source_id})
    root = stage_fixture(tree, temp, name, table_text, sources_text)
    feed = root / "feed.atom"
    feed.write_bytes(atom_feed([{"title": t} for t in titles]))
    out_receipt = root / "observe-out.json"
    result = run(
        [sys.executable, "-I", "-B", str(runner_path), str(tree), str(root),
         str(out_receipt), str(feed), feed_url, observed_at],
        cwd=tree, env=env)
    fired = False
    try:
        document = json.loads(out_receipt.read_text(encoding="utf-8"))
        fired = any(isinstance(r, dict) and r.get("id") == FIXTURE_ROW
                    and r.get("verdict") == "fired"
                    for r in document.get("observations", []))
        receipt_summary = [
            {"id": r.get("id"), "verdict": r.get("verdict"),
             "error": r.get("error"), "parsed_version": r.get("parsed_version")}
            for r in document.get("observations", []) if isinstance(r, dict)]
    except (OSError, ValueError):
        receipt_summary = None
    result.update({
        "fired_observation_written": fired,
        "receipt": receipt_summary,
        "feed_url": feed_url,
        "note": ("--observe; stubbed transport, table narrowed to the "
                 "fixture row (r28 verbatim)"),
    })
    return name, classify_f(result, FIXTURE_ROW, feed_url)


def classify_f(result, row_id, feed_url):
    """Round-28 predicate, verbatim semantics (BASE-era category exclusion)."""
    output = result["stdout"] + "\n" + result["stderr"]
    traceback = "Traceback" in output
    clean = last_nonempty(result["stdout"]).startswith("RELEASE_CLOCK: CLEAN")
    findings = row_findings(result["stdout"], row_id, feed_url)
    if (result["exit"] == 0 and clean) or result.get("fired_observation_written") or traceback:
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


def export_sparse(rev, dest):
    """Sparse projection of REV's tree: corpus/** plus the default receipt.

    plans/round-29.md Correction 2: a full extractall collides on NTFS (the
    tree carries .../CritCounting/{BASE,base}); the sandboxes subtree is read
    by no fixture. A case-colliding pair inside the projection aborts loudly.
    Returns (tree, receipt_rel, skipped_outside_count).
    """
    archive = subprocess.run(
        ["git", "-C", str(LANE), "archive", "--format=tar", rev],
        capture_output=True, timeout=300)
    if archive.returncode != 0:
        raise RuntimeError(
            "git archive failed: %s" % archive.stderr.decode().strip())
    tree = Path(dest)
    tree.mkdir()
    skipped_outside = 0
    extracted_names = set()

    def extract_member(tar, member):
        key = member.name.casefold()
        if key in extracted_names:
            raise RuntimeError(
                "case-colliding paths inside export: %s vs %s"
                % (member.name,
                   next(n for n in extracted_names if n.casefold() == key)))
        extracted_names.add(key)
        (tree / member.name).parent.mkdir(parents=True, exist_ok=True)
        tar.extract(member, tree, filter="data")

    with tarfile.open(fileobj=io.BytesIO(archive.stdout)) as tar:
        members = tar.getmembers()
        for member in members:  # pass 1: corpus files first
            if (member.name == "corpus" or member.name.startswith("corpus/")) \
                    and not member.isdir():
                extract_member(tar, member)
        code = (tree / "corpus" / "release-clock.py").read_text(encoding="utf-8")
        match = re.search(
            r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")',
            code)
        if not match:
            raise RuntimeError(
                "cannot locate the default receipt path in release-clock.py")
        receipt_rel = "/".join(
            part.strip('" ') for part in match.group(1).split("/"))
        for member in members:  # pass 2: the default receipt only
            if member.name == "corpus" or member.name.startswith("corpus/"):
                continue
            if member.isfile() and member.name == receipt_rel:
                extract_member(tar, member)
            else:
                skipped_outside += 1
    return tree, receipt_rel, skipped_outside


def main():
    if len(sys.argv) != 4 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[1]):
        raise SystemExit("usage: c1-measure.py FULL_REV LABEL OUT.json")
    rev, label, out = sys.argv[1:4]
    temp = Path(tempfile.mkdtemp(prefix="kagi-r29-c1-"))
    try:
        tree, receipt_rel_declared, skipped_outside = export_sparse(
            rev, temp / "tree")
        receipt_rel = default_receipt_rel(tree)
        if receipt_rel != receipt_rel_declared:
            raise RuntimeError("default receipt path moved between passes")
        env = {
            "PATH": os.environ.get("PATH", ""),
            "HOME": str(temp),
            "LC_ALL": "C",
            "PYTHONDONTWRITEBYTECODE": "1",
            "SYSTEMROOT": os.environ.get("SYSTEMROOT", ""),
        }
        receipt_rel = default_receipt_rel(tree)
        runner_path = temp / "observe-runner.py"
        runner_path.write_text(RUNNER, encoding="utf-8")

        results = {}
        nf_specs = (
            ("NF1-title-period-noncanonical",
             atom_feed([{"title": "Python 3.15.0"}, {"title": "Python 3.15.01."}]),
             {FIXTURE_ROW}, FIXTURE_ROW),
            ("NF2-title-period-canonical",
             atom_feed([{"title": "Python 3.15.1."}]),
             {FIXTURE_ROW}, FIXTURE_ROW),
            ("NF3-href-period-noncanonical",
             atom_feed([{"href": "/releases/tag/v3.14.0"},
                        {"href": "/releases/tag/v3.15.01."}]),
             {FIXTURE_ROW}, FIXTURE_ROW),
            ("NF4-text-period-noncanonical", b"Version: 8.23.01.\n",
             {TEXT_ROW}, TEXT_ROW),
            ("NF5-title-comma-prose",
             atom_feed([{"title": "Python 3.15.0"},
                        {"title": "Python 3.15.1, out now"}]),
             {FIXTURE_ROW}, FIXTURE_ROW),
            ("NF6-title-prerelease-sibling",
             atom_feed([{"title": "Python 3.15.1rc1"}]),
             {FIXTURE_ROW}, FIXTURE_ROW),
            ("NF7-four-component-sibling",
             atom_feed([{"title": "Python 3.15.1.2"}]),
             {FIXTURE_ROW}, FIXTURE_ROW),
        )
        for name, body, keep_ids, row_id in nf_specs:
            fname, result = check_nf(tree, temp, env, runner_path, name,
                                     body, keep_ids, row_id)
            results[fname] = result

        rname, result = check_f_table(
            tree, temp, env, "F1-table-lie", "3.15.01", receipt_rel)
        results[rname] = result
        rname, result = check_f_table(
            tree, temp, env, "F2-table-oversize",
            "3.15." + OVERSIZE_COMPONENT, receipt_rel)
        results[rname] = result
        rname, result = check_f_observe(
            tree, temp, env, runner_path, "F3-observe-zero", "3.15.01",
            ["Python 3.15.01", "Python 3.15.0"])
        results[rname] = result
        rname, result = check_f_observe(
            tree, temp, env, runner_path, "F4-observe-oversize",
            "3.15." + OVERSIZE_COMPONENT,
            ["Python 3.15." + OVERSIZE_COMPONENT, "Python 3.15.0"])
        results[rname] = result

        control = run([sys.executable, "-I", "-B", "corpus/release-clock.py"],
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

    nf_names = [name for name in results if name.startswith("NF")]
    f_names = [name for name in results if name.startswith(("F1-", "F2-", "F3-", "F4-"))]
    for name in nf_names + f_names:
        for channel in ("stdout", "stderr"):
            results[name][channel] = tails(results[name][channel])
    nf_summary = {
        "mishandled": sum(results[name]["verdict"] == "MISHANDLED"
                          for name in nf_names),
        "correct": sum(results[name]["verdict"] == "CORRECT"
                       for name in nf_names),
        "other": sum(results[name]["verdict"] == "OTHER"
                     for name in nf_names),
        "fixtures": len(nf_names),
    }
    f_summary = {
        "mishandled": sum(results[name]["verdict"] == "MISHANDLED"
                          for name in f_names),
        "typed": sum(results[name]["verdict"] == "TYPED"
                     for name in f_names),
        "other": sum(results[name]["verdict"] == "OTHER"
                     for name in f_names),
        "fixtures": len(f_names),
    }
    document = {
        "format": "kagi-round29-c1-measure-v1",
        "revision": rev,
        "label": label,
        "extraction": {
            "mode": "sparse-corpus-plus-default-receipt",
            "receipt_rel": receipt_rel,
            "members_skipped_outside_projection": skipped_outside,
            "reason": "plans/round-29.md Correction 2 (NTFS case collision)",
        },
        "fixtures": {name: results[name] for name in nf_names + f_names},
        "nf_summary": nf_summary,
        "replay_summary": f_summary,
        "control": results["control"],
    }
    Path(out).parent.mkdir(parents=True, exist_ok=True)
    Path(out).write_text(json.dumps(document, indent=2) + "\n",
                         encoding="utf-8")
    passed = (nf_summary["mishandled"] == 0 and nf_summary["correct"] == 7
              and f_summary["mishandled"] == 0 and f_summary["typed"] == 4
              and results["control"]["clean"])
    print("C1_MEASURE %s: NF mishandled=%d/7 correct=%d/7 other=%d/7 "
          "replay mishandled=%d/4 typed=%d/4 other=%d/4 control_exit=%d "
          "control_clean=%s" % (
              label, nf_summary["mishandled"], nf_summary["correct"],
              nf_summary["other"], f_summary["mishandled"],
              f_summary["typed"], f_summary["other"],
              results["control"]["exit"], results["control"]["clean"]))
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
