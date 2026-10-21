#!/usr/bin/env python3
"""Test the IN-FLIGHT lane implementation (as copied from the lane working tree)
against every counterexample this review found.

Cases:
  CTRL   unmodified tree, default command                 -> must stay CLEAN
  G1..G4 the plan's frozen lowering fixtures               -> must be EXACT
  FIRED  legitimately fired derived rows (SOPS 3.14.0)      -> must stay CLEAN
  CURL   derived anchor forged to curl's unreleased 8.23.1 -> must be TYPED
  NEWROW a new feed registry row for the same URL          -> must stay CLEAN
  VAC    the feed row's anchor cell emptied of versions   -> must be TYPED
  TWO    the feed row's anchor cell names two versions     -> must be TYPED
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "inflwork"
INFLIGHT = SANDBOX / "inflight-release-clock.py"

GROUPS = {
    "G1": (["S008", "S009", "S010", "S011"], "3.13.2"),
    "G2": (["S013", "S022", "S023", "S024"], "2.1.9"),
    "G3": (["S014", "S015", "S016", "S021", "S025", "S026"], "2.7.0"),
    "G4": (["S029"], "8.22.0"),
}

SOPS_ATOM = b"""<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><title>v3.14.0</title>
  <link href="https://github.com/getsops/sops/releases/tag/v3.14.0"/>
  <updated>2026-10-25T00:00:00Z</updated></entry>
  <entry><title>v3.13.3</title>
  <link href="https://github.com/getsops/sops/releases/tag/v3.13.3"/>
  <updated>2026-07-23T05:29:11Z</updated></entry>
</feed>
"""

NEW_ROW = ("| S044 | SOPS releases, GitHub release Atom feed (round-28) — "
           "https://github.com/getsops/sops/releases.atom | code | A | SOPS "
           "release identity at the round-28 fetch | Entry titled v3.14.0, tag "
           "link /releases/tag/v3.14.0, updated 2026-10-25T00:00:00Z; feed "
           "fetched 2026-10-25 | supersedes S033 — newest stable SOPS is "
           "v3.14.0. Quote: “<title>v3.14.0</title>”. | mined | 2026-10-25 | "
           "90d | — |")


def build():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    root = WORK / "tree"
    shutil.copytree(SANDBOX / "base", root)
    shutil.copy2(INFLIGHT, root / "corpus/release-clock.py")
    return root


def stage(vroot, tag, table_edits, receipt_edits, sources_edits=None):
    root = WORK / ("fx-" + tag)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clock.py"):
        shutil.copy2(vroot / "corpus" / rel, root / "corpus" / rel)
    lines = (vroot / "corpus/release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in table_edits:
            a, o, v = table_edits[f[0]]
            f[4], f[5], f[7] = a, o, v
            line = "\t".join(f) + "\n"
        out.append(line)
    (root / "corpus/release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    if sources_edits:
        text = (root / "corpus/SOURCES.md").read_text(encoding="utf-8")
        for old, new in sources_edits:
            assert old in text, old[:60]
            text = text.replace(old, new, 1)
        (root / "corpus/SOURCES.md").write_text(text, encoding="utf-8")
    receipt = json.loads((vroot / ".ufo/waves/round-26/observe-2.json").read_text())
    for rec in receipt["observations"]:
        if rec["id"] in receipt_edits:
            rec["parsed_version"], rec["verdict"] = receipt_edits[rec["id"]]
    rp = root / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    return root, rp, sha


def outcome(proc):
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    last = lines[-1] if lines else ""
    ids = sorted({m for l in findings for m in re.findall(r"S[0-9]{3}", l)})
    return proc.returncode, last, findings, ids


def run(root, rp, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120)


def main():
    root = build()
    print("== CTRL: unmodified tree, default command ==")
    proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py"], cwd=root,
                          capture_output=True, text=True, timeout=120)
    rc, last, fnd, ids = outcome(proc)
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== G1..G4: the frozen lowering fixtures ==")
    for gname, (rows, lower) in GROUPS.items():
        te = {r: (lower, lower, "not-fired") for r in rows}
        re_ = {r: (lower, "not-fired") for r in rows}
        fx, rp, sha = stage(root, gname, te, re_)
        rc, last, fnd, ids = outcome(run(fx, rp, sha))
        exact = rc == 1 and ids == sorted(rows)
        print("  %-6s exit=%d EXACT=%s ids=%s findings=%s" % (gname, rc, exact, ids, fnd))

    print("== FIRED: legitimately fired derived rows (SOPS advanced to 3.14.0) ==")
    import importlib.util
    spec = importlib.util.spec_from_file_location("infl", root / "corpus/release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    sources = mod.parse_sources(root)
    trows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)
    real_req, real_utc = mod.request_body, mod.utc_timestamp
    mod.request_body = lambda url, opener=None, resolver=None: (
        (200, SOPS_ATOM, None) if "getsops" in url
        else real_req(url, opener=opener, resolver=resolver))
    mod.utc_timestamp = lambda: "2026-10-21T13:43:21Z"
    outp = root / "observe.json"
    try:
        mod.run_observe(root, sources, trows, outp, captures)
    finally:
        mod.request_body, mod.utc_timestamp = real_req, real_utc
    bundle = mod.load_receipt_bundle(outp)
    te = {r: ("3.13.3", "3.14.0", "fired") for r in ("S008", "S009", "S010", "S011")}
    fx, rp, sha = stage(root, "FIRED", te, {r: ("3.14.0", "fired")
                                             for r in ("S008", "S009", "S010", "S011")})
    rc, last, fnd, ids = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== NEWROW: a new feed registry row for the same URL (S036->S039 shape) ==")
    fx, rp, sha = stage(root, "NEWROW", te, {r: ("3.14.0", "fired")
                                              for r in ("S008", "S009", "S010", "S011")},
                        sources_edits=[("\n\n## Paths", "\n" + NEW_ROW + "\n\n## Paths")])
    rc, last, fnd, ids = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== CURL: derived anchor forged to curl's UNRELEASED dev label 8.23.1 ==")
    fx, rp, sha = stage(root, "CURL", {"S029": ("8.23.1", "8.23.1", "not-fired")},
                        {"S029": ("8.23.1", "not-fired")})
    rc, last, fnd, ids = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== VAC: the feed row's anchor cell emptied of versions ==")
    fx, rp, sha = stage(root, "VAC", {r: ("3.13.2", "3.13.2", "not-fired")
                                      for r in ("S008", "S009", "S010", "S011")},
                        {r: ("3.13.2", "not-fired")
                         for r in ("S008", "S009", "S010", "S011")},
                        sources_edits=[("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
                                        "Atom feed fetched 2026-10-21; newest stable entry located")])
    rc, last, fnd, ids = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== TWO: the feed row's anchor cell names two versions ==")
    fx, rp, sha = stage(root, "TWO", {r: ("3.13.2", "3.13.2", "not-fired")
                                      for r in ("S008", "S009", "S010", "S011")},
                        {r: ("3.13.2", "not-fired")
                         for r in ("S008", "S009", "S010", "S011")},
                        sources_edits=[("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
                                        "Entry titled v3.13.2, tag link /releases/tag/v3.13.3, previous v3.13.3, updated 2026-07-23T05:29:11Z")])
    rc, last, fnd, ids = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== SELF: selftest ==")
    proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"],
                          cwd=root, capture_output=True, text=True, timeout=180)
    print("  exit=%d last=%s" % (proc.returncode, (proc.stdout.strip().splitlines() or [""])[-1]))


if __name__ == "__main__":
    main()
