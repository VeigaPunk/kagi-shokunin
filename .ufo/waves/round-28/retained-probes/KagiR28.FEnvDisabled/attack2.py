#!/usr/bin/env python3
"""FEnvDisabled stage 2: F1/F3 leading-zero under the env, low int-limit
invariance, and receipt-JSON int-limit sensitivity."""
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
TOOL = SANDBOX / "cand" / ".ufo" / "waves" / "round-28" / "tools" / "c1-measure.py"
spec = importlib.util.spec_from_file_location("c1measure", TOOL)
c1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c1)

OVERSIZE = "1" * 4301


def base_env(temp, intmax):
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    if intmax is not None:
        env["PYTHONINTMAXSTRDIGITS"] = intmax
    return env


def run(argv, cwd, env):
    p = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                       capture_output=True, timeout=300)
    return {"argv": argv, "exit": p.returncode, "stdout": p.stdout,
            "stderr": p.stderr}


def report(tag, r, extra=None):
    out = r["stdout"] + "\n" + r["stderr"]
    lines = [l.strip() for l in r["stdout"].splitlines()
             if l.strip() and not l.strip().startswith("RELEASE_CLOCK:")]
    data = {"tag": tag, "argv": r["argv"], "exit": r["exit"],
            "traceback": "Traceback" in out,
            "last_line": c1.last_nonempty(r["stdout"]),
            "findings": lines,
            "stdout_tail": r["stdout"][-500:], "stderr_tail": r["stderr"][-500:]}
    if extra:
        data.update(extra)
    return data


def main():
    trees = {"cand": SANDBOX / "cand", "base": SANDBOX / "base"}
    results = {}
    for name, tree in trees.items():
        temp = Path(tempfile.mkdtemp(prefix="env2-%s-" % name))
        try:
            receipt_rel = c1.default_receipt_rel(tree)
            # F1 table leading-zero
            for intmax, tag in (("0", "limit0-no-I"), (None, "default-I")):
                env = base_env(temp, intmax)
                argv = ["python3"]
                if tag == "default-I":
                    argv.append("-I")
                # F1: table leading-zero, mirrored receipt
                edits = {c1.FIXTURE_ROW: ("3.15.01", "fired")}
                root = c1.stage_fixture(tree, temp, "F1-%s-%s" % (name, tag),
                                         c1.edited_table(tree, edits))
                rp, sha, _ = c1.mirrored_receipt(tree, receipt_rel, edits, root)
                r = run(argv + ["-B", str(tree / "corpus" / "release-clock.py"),
                                "--root", str(root), "--receipt", str(rp),
                                "--receipt-sha", sha], cwd=tree, env=env)
                results["%s|F1-table-lie[%s]" % (name, tag)] = report(
                    "F1-table-lie[%s]" % tag, r)
                # F3: observe leading-zero feed
                runner = temp / "observe-runner.py"
                if not runner.exists():
                    runner.write_text(c1.RUNNER, encoding="utf-8")
                original = c1.row_fields(c1.edited_table(tree, {}, narrow=False),
                                         c1.FIXTURE_ROW)
                ed = {c1.FIXTURE_ROW: (original[5], original[7])}
                tt = c1.edited_table(tree, ed, narrow=True)
                f = c1.row_fields(tt, c1.FIXTURE_ROW)
                st = c1.narrowed_sources(tree, {c1.FIXTURE_ROW, f[2]})
                r2root = c1.stage_fixture(tree, temp, "F3-%s-%s" % (name, tag),
                                           tt, st)
                feed = r2root / "feed.atom"
                feed.write_bytes(c1.atom_feed(["Python 3.15.01", "Python 3.15.0"]))
                outp = r2root / "observe-out.json"
                r2 = run(argv + ["-B", str(runner), str(tree), str(r2root),
                                 str(outp), str(feed), f[3], f[6]], cwd=tree, env=env)
                fired, summ = c1.receipt_fired(outp, c1.FIXTURE_ROW)
                results["%s|F3-observe-zero[%s]" % (name, tag)] = report(
                    "F3-observe-zero[%s]" % tag, r2,
                    {"fired_observation_written": fired, "receipt_records": summ})
            # low int limit invariance on the control + table oversize
            for intmax in ("5", "18", "640"):
                env = base_env(temp, intmax)
                r = run(["python3", "-B", "corpus/release-clock.py"], cwd=tree, env=env)
                results["%s|control[limit=%s]" % (name, intmax)] = report(
                    "control[limit=%s]" % intmax, r)
            # receipt-JSON sensitivity: receipt with a huge integer field
            env = base_env(temp, "0")
            r = run(["python3", "-B", "-c",
                     "import json,sys;json.loads(sys.stdin.read())"],
                    cwd=tree, env=env)
            huge = '{"a": ' + ("1" * 5000) + "}"
            p = subprocess.run(["python3", "-B", "-c",
                                "import json,sys;json.loads(sys.stdin.read())"],
                               cwd=str(tree), env=env, input=huge, text=True,
                               capture_output=True, timeout=60)
            results["%s|json-huge-int[limit0]" % name] = {
                "tag": "json-huge-int[limit0]", "exit": p.returncode,
                "stderr_tail": p.stderr[-200:]}
            env2 = base_env(temp, None)
            p2 = subprocess.run(["python3", "-B", "-c",
                                 "import json,sys;json.loads(sys.stdin.read())"],
                                cwd=str(tree), env=env2, input=huge, text=True,
                                capture_output=True, timeout=60)
            results["%s|json-huge-int[default]" % name] = {
                "tag": "json-huge-int[default]", "exit": p2.returncode,
                "stderr_tail": p2.stderr[-200:]}
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    (SANDBOX / "attack2-results.json").write_text(
        json.dumps(results, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    for k in sorted(results):
        v = results[k]
        print("%-42s exit=%-3s traceback=%-5s last=%s" %
              (k, v["exit"], v.get("traceback"), v.get("last_line", "")[:70]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
