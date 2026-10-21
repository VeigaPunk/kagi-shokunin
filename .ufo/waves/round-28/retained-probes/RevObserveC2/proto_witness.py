#!/usr/bin/env python3
"""The missing selftest witness for the fired-derived-row question.

The in-flight selftest has NO case where a derived row is legitimately FIRED
with a BOUND numeric anchor:
    anchored == the feed row's named version,
    observed  == a NEWER version,
    verdict  == "fired",
    -> must stay CLEAN.

The case named "derived fired anchor bound to feed" (release-clock.py :1192)
has anchored=1.2.0 against feed_anchor="Latest release v1.2.9" -- a MISMATCH
that expects DERIVATION. It is not the fired-and-bound case.

This script:
  1. adds the missing case to a copy of the in-flight selftest;
  2. shows the CORRECT implementation passes it (CLEAN);
  3. shows the MUTANT (observation-binding) FAILS it (spurious DERIVATION);
  4. shows the mutant is killed by the CURRENT selftest only through the
     SERIES-anchor cases (anchored="1.2.x"), i.e. incidentally, not through
     any numeric fired-and-bound witness.
"""
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "witness"
INFLIGHT = SANDBOX / "inflight-release-clock.py"

WITNESS = '''    run_case("derived fired anchor still bound to feed", fixture_row(
             anchored="1.2.0", observed="1.3.0", verdict="fired",
             note="derived: newest stable release on the feed when the row was opened") + "\\n",
             [], {"observed": 1, "fired": 1, "derived": 1},
             feed_anchor="Entry titled v1.2.0, tag link /releases/tag/v1.2.0, updated 2026-07-23T05:29:11Z")
'''

MUT_SITE = 'derived_anchor_bound(feed_source["anchor"], anchored)'
MUT_NEW = 'derived_anchor_bound(feed_source["anchor"], observed_version)'


def prepare(name, mutate, add_witness):
    root = WORK / name
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(SANDBOX / "base", root)
    shutil.copy2(INFLIGHT, root / "corpus/release-clock.py")
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    if mutate:
        assert MUT_SITE in code
        code = code.replace(MUT_SITE, MUT_NEW, 1)
    if add_witness:
        anchor = '    run_case("derived anchor bound to its one feed token", fixture_row('
        assert anchor in code
        code = code.replace(anchor, WITNESS + anchor, 1)
    path.write_text(code, encoding="utf-8")
    return root


def selftest(root, label):
    proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"],
                          cwd=root, capture_output=True, text=True, timeout=180)
    fails = [l for l in proc.stdout.splitlines() if "FAIL" in l]
    last = (proc.stdout.strip().splitlines() or [""])[-1]
    print("  %-34s exit=%d  %s" % (label, proc.returncode, last))
    for f in fails[:3]:
        print("      %s" % f[:150])
    return proc.returncode, fails


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)

    print("== 1. the CURRENT in-flight selftest (no fired-and-bound witness) ==")
    correct = prepare("correct", mutate=False, add_witness=False)
    selftest(correct, "correct, current selftest")
    mutant = prepare("mutant", mutate=True, add_witness=False)
    rc, fails = selftest(mutant, "mutant,  current selftest")
    series = [f for f in fails if "non-numeric anchor" in f or "feed floor lifts" in f]
    print("      -> mutant killed by %d finding(s); all mention a SERIES anchor:"
          " %s" % (len(fails), all("1.2.x" in f or "non-numeric" in f or "feed floor lifts" in f
                                   for f in fails)))
    print("      -> no finding names a numeric fired-and-bound derived row")

    print()
    print("== 2. with the missing witness added ==")
    correct_w = prepare("correct_w", mutate=False, add_witness=True)
    selftest(correct_w, "correct, +witness")
    mutant_w = prepare("mutant_w", mutate=True, add_witness=True)
    selftest(mutant_w, "mutant,  +witness")

    print()
    print("== 3. the witness alone (numeric anchor, fired, bound) on the REAL corpus ==")
    import importlib.util
    root = WORK / "real"
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(SANDBOX / "base", root)
    shutil.copy2(INFLIGHT, root / "corpus/release-clock.py")
    spec = importlib.util.spec_from_file_location("m", root / "corpus/release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    srcs = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    caps = mod.parse_captures(root)
    real_req, real_utc = mod.request_body, mod.utc_timestamp
    atom = b"""<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><title>v3.14.0</title>
  <link href="https://github.com/getsops/sops/releases/tag/v3.14.0"/>
  <updated>2026-10-25T00:00:00Z</updated></entry>
  <entry><title>v3.13.3</title>
  <link href="https://github.com/getsops/sops/releases/tag/v3.13.3"/>
  <updated>2026-07-23T05:29:11Z</updated></entry>
</feed>
"""
    mod.request_body = lambda url, opener=None, resolver=None: (
        (200, atom, None) if "getsops" in url
        else real_req(url, opener=opener, resolver=resolver))
    mod.utc_timestamp = lambda: "2026-10-21T13:43:21Z"
    outp = root / "observe.json"
    try:
        mod.run_observe(root, srcs, rows, outp, caps)
    finally:
        mod.request_body, mod.utc_timestamp = real_req, real_utc
    bundle = mod.load_receipt_bundle(outp)
    tsv = root / "corpus/release-clocks.tsv"
    lines = tsv.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in ("S008", "S009", "S010", "S011"):
            f[4], f[5], f[7] = "3.13.3", "3.14.0", "fired"
            line = "\t".join(f) + "\n"
        out.append(line)
    tsv.write_text("".join(out), encoding="utf-8")
    result = mod.evaluate(mod.parse_sources(root), mod.parse_bindings(root),
                          mod.parse_captures(root), bundle)
    der = [e for e in result["errors"] if e[0] == "DERIVATION"]
    print("  correct impl on 4 legitimately fired derived rows: DERIVATION=%s passed=%s"
          % (der or "[]", result["passed"]))


if __name__ == "__main__":
    main()
