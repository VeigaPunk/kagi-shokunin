#!/usr/bin/env python3
"""FEnvDisabled final verification -- one clean, reproducible transcript.

Trees live under /fast/scratch/hyaku/kagi-r28/KagiR28.FEnvDisabled/:
  cand    = git archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 (pinned candidate)
  base    = git archive 3553d499577084a6c98d7078906017840bbf7b28 (BASE)
  envdep2 = cand with the lexical 18-digit bound removed, int()-based ordering,
            and the int() ValueError re-typed (env-dependent near-miss)

Every run below is the pinned candidate's own corpus/release-clock.py, in an
isolated exported tree, with no network (feed transport stubbed the same way
the frozen instrument stubs it).
"""
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

SCRATCH = Path("/fast/scratch/hyaku/kagi-r28/KagiR28.FEnvDisabled")
SANDBOX = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "c1", SCRATCH / "cand" / ".ufo" / "waves" / "round-28" / "tools" / "c1-measure.py")
c1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c1)
OVERSIZE = "1" * 4301


def env_for(temp, intmax):
    e = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
         "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    if intmax is not None:
        e["PYTHONINTMAXSTRDIGITS"] = intmax
    return e


def run(argv, cwd, env):
    p = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                       capture_output=True, timeout=300)
    return {"argv": " ".join(argv), "exit": p.returncode, "stdout": p.stdout,
            "stderr": p.stderr}


def table(tree, temp, name, observed, receipt_rel, intmax, isolated):
    edits = {c1.FIXTURE_ROW: (observed, "fired")}
    root = c1.stage_fixture(tree, temp, name, c1.edited_table(tree, edits))
    rp, sha, _ = c1.mirrored_receipt(tree, receipt_rel, edits, root)
    argv = ["python3"] + (["-I"] if isolated else []) + [
        "-B", str(tree / "corpus" / "release-clock.py"), "--root", str(root),
        "--receipt", str(rp), "--receipt-sha", sha]
    return run(argv, cwd=tree, env=env_for(temp, intmax))


def observe(tree, temp, name, titles, intmax, isolated):
    runner = temp / ("runner-%s.py" % name)
    runner.write_text(c1.RUNNER, encoding="utf-8")
    original = c1.row_fields(c1.edited_table(tree, {}, narrow=False), c1.FIXTURE_ROW)
    ed = {c1.FIXTURE_ROW: (original[5], original[7])}
    tt = c1.edited_table(tree, ed, narrow=True)
    f = c1.row_fields(tt, c1.FIXTURE_ROW)
    st = c1.narrowed_sources(tree, {c1.FIXTURE_ROW, f[2]})
    root = c1.stage_fixture(tree, temp, name, tt, st)
    feed = root / "feed.atom"
    feed.write_bytes(c1.atom_feed(titles))
    outp = root / "observe-out.json"
    argv = ["python3"] + (["-I"] if isolated else []) + [
        "-B", str(runner), str(tree), str(root), str(outp), str(feed),
        f[3], f[6]]
    r = run(argv, cwd=tree, env=env_for(temp, intmax))
    fired, summ = c1.receipt_fired(outp, c1.FIXTURE_ROW)
    return r, fired, summ


def main():
    transcript = []
    for tree_name in ("cand", "base", "envdep2"):
        tree = SCRATCH / tree_name
        temp = Path(tempfile.mkdtemp(prefix="final-%s-" % tree_name))
        try:
            rel = c1.default_receipt_rel(tree)
            for intmax, isolated, tag in ((None, True, "frozen-env"),
                                          ("0", False, "attack-env")):
                r = table(tree, temp, "T-%s-%s" % (tree_name, tag),
                          "3.15." + OVERSIZE, rel, intmax, isolated)
                v = c1.classify(dict(r, fired_observation_written=False),
                                c1.FIXTURE_ROW, "")
                transcript.append({"tree": tree_name, "env": tag,
                                   "fixture": "F2-table-oversize", **v})
                r2, fired2, s2 = observe(
                    tree, temp, "O-%s-%s" % (tree_name, tag),
                    ["Python 3.15." + OVERSIZE, "Python 3.15.0"], intmax, isolated)
                v2 = c1.classify(dict(r2, fired_observation_written=fired2),
                                 c1.FIXTURE_ROW, "")
                v2["fired_observation_written"] = fired2
                v2["receipt_records"] = s2
                transcript.append({"tree": tree_name, "env": tag,
                                   "fixture": "F4-observe-oversize", **v2})
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    (SANDBOX / "final-transcript.json").write_text(
        json.dumps(transcript, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    for e in transcript:
        print("== %-8s %-11s %-21s exit=%-3s verdict=%-11s tb=%-5s typed=%s"
              % (e["tree"], e["env"], e["fixture"], e["exit"], e["verdict"],
                 e["traceback_in_output"], e["typed_finding_lines"]))
        print("   argv: %s" % e["argv"])
        print("   stdout: %s" % e["stdout"].strip().replace("\n", " | "))
        if e.get("fired_observation_written") is not None:
            print("   fired_observation_written: %s" % e["fired_observation_written"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
