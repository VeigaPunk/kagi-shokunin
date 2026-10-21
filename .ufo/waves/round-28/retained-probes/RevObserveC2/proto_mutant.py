#!/usr/bin/env python3
"""MUTATION TEST: does the in-flight implementation's own selftest and the
frozen c2-measure tool catch a rule that binds the OBSERVATION instead of the
ANCHOR?

The in-flight selftest has no case where a derived row is legitimately FIRED
with a BOUND anchor (anchored == the feed row's named version, observed = a
newer version, verdict=fired -> must stay CLEAN). The only selftest case whose
name mentions "fired" ("derived fired anchor bound to feed", release-clock.py
:1192) uses anchored=1.2.0 against feed_anchor="Latest release v1.2.9" -- a
MISMATCH that expects DERIVATION, not a valid fired row.

If the anchor-binding is silently replaced by observation-binding, the
legitimately fired derived row is falsely refused -- and nothing measures it.
"""
import re
import shutil
import sys
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "mutant"
INFLIGHT = SANDBOX / "inflight-release-clock.py"

MUTANT_OLD = 'derived_anchor_bound(feed_source["anchor"], anchored)'
MUTANT_NEW = 'derived_anchor_bound(feed_source["anchor"], observed_version)'


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    root = WORK / "tree"
    shutil.copytree(SANDBOX / "base", root)
    shutil.copy2(INFLIGHT, root / "corpus/release-clock.py")
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    assert MUTANT_OLD in code, "mutation site not found"
    code = code.replace(MUTANT_OLD, MUTANT_NEW, 1)
    path.write_text(code, encoding="utf-8")
    print("mutant: bound(observed_version) instead of bound(anchored)")

    proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"],
                          cwd=root, capture_output=True, text=True, timeout=180)
    print("  selftest exit=%d last=%s" % (
        proc.returncode, (proc.stdout.strip().splitlines() or [""])[-1]))
    for line in proc.stdout.splitlines():
        if "FAIL" in line:
            print("    %s" % line)

    # and the frozen c2-measure tool against the mutant
    lab = WORK / "lab"
    shutil.copytree(root, lab)
    (lab / ".ufo/waves/round-28/tools").mkdir(parents=True)
    shutil.copy2("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/tools/c2-measure.py",
                 lab / ".ufo/waves/round-28/tools/c2-measure.py")
    shutil.copy2("/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-28.md", lab / "plans/round-28.md")
    subprocess.run(["git", "init", "-q", "."], cwd=lab, check=True)
    subprocess.run(["git", "config", "user.email", "r@x"], cwd=lab, check=True)
    subprocess.run(["git", "config", "user.name", "r"], cwd=lab, check=True)
    subprocess.run(["git", "add", "-A"], cwd=lab, check=True)
    subprocess.run(["git", "commit", "-qm", "mutant"], cwd=lab, check=True)
    rev = subprocess.run(["git", "rev-parse", "HEAD"], cwd=lab, capture_output=True,
                         text=True, check=True).stdout.strip()
    proc = subprocess.run(["python3", "-I", "-B", ".ufo/waves/round-28/tools/c2-measure.py",
                           rev, "MUTANT", "/tmp/mutant.json"],
                          cwd=lab, capture_output=True, text=True, timeout=300)
    print("  frozen c2-measure: %s" % (proc.stdout.strip().splitlines() or [""])[-1])
    print("  (the mutant passes the frozen instrument: 4/4 EXACT, control CLEAN)")

    # and the real consequence, on the real corpus: a legitimately fired derived row
    print()
    print("  consequence on the real corpus (SOPS feed advanced to v3.14.0):")
    sys.path.insert(0, str(SANDBOX))
    import importlib.util
    spec = importlib.util.spec_from_file_location("mut", root / "corpus/release-clock.py")
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
    print("    DERIVATION findings on 4 legitimately fired derived rows: %s" % (der or "[]"))
    print("    passed=%s" % result["passed"])


if __name__ == "__main__":
    main()
