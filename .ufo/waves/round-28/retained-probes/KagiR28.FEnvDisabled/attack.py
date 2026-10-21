#!/usr/bin/env python3
"""FEnvDisabled attack harness.

Carrier: corpus/release-clock.py C1 freshness rule (oversize / non-canonical
version token must be refused with a typed finding, never a fired verdict,
never a traceback).

Attack: run the clock with PYTHONINTMAXSTRDIGITS=0 (CPython's int-string
conversion limit disabled) and WITHOUT -I (python3 -I implies -E, which
ignores PYTHON* environment variables, so the frozen instrument's
`python3 -I -B` command can never observe this environment).

Fixture construction is imported verbatim from the frozen instrument
.ufo/waves/round-28/tools/c1-measure.py (edited_table, narrowed_sources,
stage_fixture, mirrored_receipt, atom_feed, RUNNER). Only the subprocess argv
and env differ.
"""
import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
LANE = SANDBOX.parents[4]
TOOL = SANDBOX / "cand" / ".ufo" / "waves" / "round-28" / "tools" / "c1-measure.py"

spec = importlib.util.spec_from_file_location("c1measure", TOOL)
c1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c1)

OVERSIZE = "1" * 4301


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=300)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr}


def base_env(temp, intmax, extra=None):
    env = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": str(temp),
        "LC_ALL": "C",
        "PYTHONDONTWRITEBYTECODE": "1",
    }
    if intmax is not None:
        env["PYTHONINTMAXSTRDIGITS"] = intmax
    if extra:
        env.update(extra)
    return env


def table_case(tree, temp, name, observed_version, receipt_rel, intmax, isolated):
    edits = {c1.FIXTURE_ROW: (observed_version, "fired")}
    root = c1.stage_fixture(tree, temp, name, c1.edited_table(tree, edits))
    receipt_path, sha, mirrored = c1.mirrored_receipt(tree, receipt_rel, edits, root)
    argv = ["python3"]
    if isolated:
        argv.append("-I")
    argv += ["-B", str(tree / "corpus" / "release-clock.py"),
             "--root", str(root), "--receipt", str(receipt_path),
             "--receipt-sha", sha]
    env = base_env(temp, intmax)
    result = run(argv, cwd=tree, env=env)
    result["env_PYTHONINTMAXSTRDIGITS"] = env.get("PYTHONINTMAXSTRDIGITS")
    result["isolated_flag"] = isolated
    result["receipt"] = None
    result["mirrored_rows"] = mirrored
    return result


def observe_case(tree, temp, name, titles, intmax, isolated):
    runner_path = temp / "observe-runner.py"
    if not runner_path.exists():
        runner_path.write_text(c1.RUNNER, encoding="utf-8")
    original = c1.row_fields(c1.edited_table(tree, {}, narrow=False), c1.FIXTURE_ROW)
    edits = {c1.FIXTURE_ROW: (original[5], original[7])}
    table_text = c1.edited_table(tree, edits, narrow=True)
    fields = c1.row_fields(table_text, c1.FIXTURE_ROW)
    feed_url, observed_at = fields[3], fields[6]
    feed_source_id = fields[2]
    sources_text = c1.narrowed_sources(tree, {c1.FIXTURE_ROW, feed_source_id})
    root = c1.stage_fixture(tree, temp, name, table_text, sources_text)
    feed = root / "feed.atom"
    feed.write_bytes(c1.atom_feed(titles))
    out_receipt = root / "observe-out.json"
    argv = ["python3"]
    if isolated:
        argv.append("-I")
    argv += ["-B", str(runner_path), str(tree), str(root), str(out_receipt),
             str(feed), feed_url, observed_at]
    env = base_env(temp, intmax)
    result = run(argv, cwd=tree, env=env)
    fired, summary = c1.receipt_fired(out_receipt, c1.FIXTURE_ROW)
    result["env_PYTHONINTMAXSTRDIGITS"] = env.get("PYTHONINTMAXSTRDIGITS")
    result["isolated_flag"] = isolated
    result["fired_observation_written"] = fired
    result["receipt_records"] = summary
    return result


def analyze(tag, result):
    out = result["stdout"] + "\n" + result["stderr"]
    lines = [ln.strip() for ln in result["stdout"].splitlines()
             if ln.strip() and not ln.strip().startswith("RELEASE_CLOCK:")]
    traceback = "Traceback" in out
    typed = [ln for ln in lines
             if ln.split()[0] not in c1.BASE_ERA_CATEGORIES]
    last = c1.last_nonempty(result["stdout"])
    return {
        "tag": tag,
        "argv": result["argv"],
        "env_PYTHONINTMAXSTRDIGITS": result.get("env_PYTHONINTMAXSTRDIGITS"),
        "isolated_flag": result.get("isolated_flag"),
        "exit": result["exit"],
        "traceback": traceback,
        "typed_finding_lines": typed,
        "all_finding_lines": lines,
        "last_line": last,
        "clean": last.startswith("RELEASE_CLOCK: CLEAN"),
        "fired_observation_written": result.get("fired_observation_written"),
        "receipt_records": result.get("receipt_records"),
        "stderr_tail": result["stderr"][-600:],
        "stdout_tail": result["stdout"][-800:],
    }


def main():
    trees = {"cand": SANDBOX / "cand", "base": SANDBOX / "base"}
    report = {}
    for tree_name, tree in trees.items():
        temp = Path(tempfile.mkdtemp(prefix="env-disabled-%s-" % tree_name))
        try:
            receipt_rel = c1.default_receipt_rel(tree)
            cases = {}
            for label, intmax, isolated in (
                    ("limit0-no-I", "0", False),
                    ("limit0-I", "0", True),
                    ("default-no-I", None, False),
                    ("default-I", None, True),
            ):
                r = table_case(tree, temp, "T-%s-%s" % (tree_name, label),
                               "3.15." + OVERSIZE, receipt_rel, intmax, isolated)
                cases["F2-table-oversize[%s]" % label] = analyze(
                    "F2-table-oversize[%s]" % label, r)
                r = observe_case(tree, temp, "O-%s-%s" % (tree_name, label),
                                 ["Python 3.15." + OVERSIZE, "Python 3.15.0"],
                                 intmax, isolated)
                cases["F4-observe-oversize[%s]" % label] = analyze(
                    "F4-observe-oversize[%s]" % label, r)
            control_env = base_env(temp, "0")
            argv = ["python3", "-B", "corpus/release-clock.py"]
            cases["control[limit0-no-I]"] = analyze(
                "control[limit0-no-I]", run(argv, cwd=tree, env=control_env))
            report[tree_name] = cases
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    out = SANDBOX / "attack-results.json"
    out.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n",
                   encoding="utf-8")
    for tree_name, cases in report.items():
        for tag, data in sorted(cases.items()):
            print("%-8s %-34s exit=%s traceback=%s clean=%s fired_written=%s typed=%s"
                  % (tree_name, tag, data["exit"], data["traceback"],
                     data["clean"], data["fired_observation_written"],
                     data["typed_finding_lines"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
