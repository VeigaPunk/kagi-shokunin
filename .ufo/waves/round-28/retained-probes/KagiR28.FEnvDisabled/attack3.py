#!/usr/bin/env python3
"""FEnvDisabled stage 3: near-miss discriminator.

nearmiss/ = candidate with version_order reverted to the BASE int()-based
ordering (tuple(int(part) ...)) while keeping the 18-digit lexical bound.
This is a plausible "fix" that satisfies the frozen instrument under the
default CPython limit. Measure it under PYTHONINTMAXSTRDIGITS=0 without -I:
if it is MISHANDLED there and TYPED under the frozen command, the frozen
counting command cannot tell the two implementations apart.

Also runs the near-miss through the FROZEN instrument itself (unmodified
c1-measure.py) for both the candidate and the near-miss, to record the
frozen-command verdicts.
"""
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
TOOL = SANDBOX / "cand" / ".ufo" / "waves" / "round-28" / "tools" / "c1-measure.py"
spec = importlib.util.spec_from_file_location("c1measure", TOOL)
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


def classify(r, fired=False):
    out = r["stdout"] + "\n" + r["stderr"]
    lines = [l.strip() for l in r["stdout"].splitlines()
             if l.strip() and not l.strip().startswith("RELEASE_CLOCK:")]
    last = c1.last_nonempty(r["stdout"])
    clean = last.startswith("RELEASE_CLOCK: CLEAN")
    tb = "Traceback" in out
    typed = [l for l in lines if l.split()[0] not in c1.BASE_ERA_CATEGORIES]
    if (r["exit"] == 0 and clean) or fired or tb:
        v = "MISHANDLED"
    elif r["exit"] == 1 and not tb and typed:
        v = "TYPED"
    else:
        v = "OTHER"
    return {"exit": r["exit"], "verdict": v, "traceback": tb, "clean": clean,
            "typed": typed, "findings": lines, "last": last,
            "stderr_tail": r["stderr"][-400:], "stdout_tail": r["stdout"][-400:]}


def table(tree, temp, name, observed, receipt_rel, intmax, isolated):
    edits = {c1.FIXTURE_ROW: (observed, "fired")}
    root = c1.stage_fixture(tree, temp, name, c1.edited_table(tree, edits))
    rp, sha, _ = c1.mirrored_receipt(tree, receipt_rel, edits, root)
    argv = ["python3"] + (["-I"] if isolated else []) + [
        "-B", str(tree / "corpus" / "release-clock.py"), "--root", str(root),
        "--receipt", str(rp), "--receipt-sha", sha]
    return run(argv, cwd=tree, env=env_for(temp, intmax))


def observe(tree, temp, name, titles, intmax, isolated):
    runner = temp / "observe-runner.py"
    if not runner.exists():
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
    for tree_name in ("cand", "nearmiss", "base"):
        tree = SANDBOX / tree_name
        temp = Path(tempfile.mkdtemp(prefix="nm-%s-" % tree_name))
        try:
            receipt_rel = c1.default_receipt_rel(tree)
            for intmax, isolated, tag in (("0", False, "limit0-no-I"),
                                          (None, True, "default-I")):
                r = table(tree, temp, "T-%s-%s" % (tree_name, tag),
                          "3.15." + OVERSIZE, receipt_rel, intmax, isolated)
                out["%s|F2-table-oversize[%s]" % (tree_name, tag)] = classify(r)
                r2, fired, summ = observe(
                    tree, temp, "O-%s-%s" % (tree_name, tag),
                    ["Python 3.15." + OVERSIZE, "Python 3.15.0"], intmax, isolated)
                d = classify(r2, fired)
                d["fired_observation_written"] = fired
                d["receipt_records"] = summ
                out["%s|F4-observe-oversize[%s]" % (tree_name, tag)] = d
        finally:
            shutil.rmtree(temp, ignore_errors=True)

    # The frozen instrument, run verbatim on the candidate and the near-miss.
    frozen = {}
    for tree_name, rev in (("cand", "62a33b1bd15217ed729df2ca40c8a30aba3076c0"),):
        p = subprocess.run(["python3", "-I", "-B", str(TOOL), rev, tree_name,
                            str(SANDBOX / ("frozen-%s.json" % tree_name))],
                           cwd=str(SANDBOX), text=True, capture_output=True,
                           timeout=900)
        frozen["%s-exit" % tree_name] = p.returncode
        frozen["%s-stdout" % tree_name] = p.stdout.strip()
        frozen["%s-stderr" % tree_name] = p.stderr.strip()[-400:]
    out["frozen_instrument"] = frozen
    (SANDBOX / "attack3-results.json").write_text(
        json.dumps(out, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    for k in sorted(out):
        if k == "frozen_instrument":
            continue
        v = out[k]
        print("%-42s exit=%-3s verdict=%-11s tb=%-5s typed=%s"
              % (k, v["exit"], v["verdict"], v["traceback"], v["typed"]))
    print("frozen:", json.dumps(frozen, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
