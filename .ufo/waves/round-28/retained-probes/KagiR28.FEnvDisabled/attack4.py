#!/usr/bin/env python3
"""FEnvDisabled stage 4 -- decisive discriminator.

Runs all four frozen C1 fixtures through the FROZEN instrument's own
classify() predicate for:
  cand    -- the pinned candidate (62a33b1)
  envdep2 -- a variant with the lexical 18-digit bound removed, int()-based
             ordering, and the int() ValueError re-typed as NON-CANONICAL
  base    -- BASE 3553d49
under BOTH the frozen command's effective environment (default limit, -I)
and the attack environment (PYTHONINTMAXSTRDIGITS=0, no -I).

Question: can the frozen counting command distinguish an env-independent
lexical bound from an env-dependent int()-catch?
"""
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "c1", SANDBOX / "cand" / ".ufo" / "waves" / "round-28" / "tools" / "c1-measure.py")
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
    return {"argv": argv, "exit": p.returncode, "stdout": p.stdout,
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
    out = {}
    for tree_name in ("cand", "envdep2", "base"):
        tree = SANDBOX / tree_name
        temp = Path(tempfile.mkdtemp(prefix="s4-%s-" % tree_name))
        try:
            rel = c1.default_receipt_rel(tree)
            for intmax, isolated, tag in ((None, True, "frozen-env"),
                                          ("0", False, "attack-env")):
                env = env_for(temp, intmax)
                r1 = table(tree, temp, "T-%s-%s" % (tree_name, tag),
                           "3.15.01", rel, intmax, isolated)
                c1v = c1.classify(dict(r1, fired_observation_written=False),
                                  c1.FIXTURE_ROW, "")
                out["%s|F1[%s]" % (tree_name, tag)] = c1v
                r2 = table(tree, temp, "T2-%s-%s" % (tree_name, tag),
                           "3.15." + OVERSIZE, rel, intmax, isolated)
                c2v = c1.classify(dict(r2, fired_observation_written=False),
                                  c1.FIXTURE_ROW, "")
                out["%s|F2[%s]" % (tree_name, tag)] = c2v
                r3, f3, s3 = observe(tree, temp, "O3-%s-%s" % (tree_name, tag),
                                     ["Python 3.15.01", "Python 3.15.0"],
                                     intmax, isolated)
                out["%s|F3[%s]" % (tree_name, tag)] = c1.classify(
                    dict(r3, fired_observation_written=f3), c1.FIXTURE_ROW, "")
                r4, f4, s4 = observe(
                    tree, temp, "O4-%s-%s" % (tree_name, tag),
                    ["Python 3.15." + OVERSIZE, "Python 3.15.0"],
                    intmax, isolated)
                v4 = c1.classify(dict(r4, fired_observation_written=f4),
                                 c1.FIXTURE_ROW, "")
                v4["fired_observation_written"] = f4
                out["%s|F4[%s]" % (tree_name, tag)] = v4
                ctrl = run(["python3"] + (["-I"] if isolated else []) +
                           ["-B", "corpus/release-clock.py"], cwd=tree, env=env)
                out["%s|control[%s]" % (tree_name, tag)] = {
                    "exit": ctrl["exit"],
                    "clean": ctrl["exit"] == 0
                    and c1.last_nonempty(ctrl["stdout"]).startswith(
                        "RELEASE_CLOCK: CLEAN"),
                    "last": c1.last_nonempty(ctrl["stdout"])}
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    (SANDBOX / "attack4-results.json").write_text(
        json.dumps(out, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    for k in sorted(out):
        v = out[k]
        if "verdict" in v:
            print("%-32s verdict=%-11s exit=%-3s tb=%-5s typed=%s"
                  % (k, v["verdict"], v["exit"], v["traceback_in_output"],
                     v["typed_finding_lines"]))
        else:
            print("%-32s exit=%-3s clean=%s last=%s"
                  % (k, v["exit"], v["clean"], v["last"][:70]))
    for tree_name in ("cand", "envdep2", "base"):
        for tag in ("frozen-env", "attack-env"):
            names = ["F1", "F2", "F3", "F4"]
            vs = [out["%s|%s[%s]" % (tree_name, n, tag)]["verdict"] for n in names]
            print("SUMMARY %-9s %-11s mishandled=%d typed=%d other=%d"
                  % (tree_name, tag, vs.count("MISHANDLED"),
                     vs.count("TYPED"), vs.count("OTHER")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
