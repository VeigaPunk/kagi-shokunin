#!/usr/bin/env python3
"""The corpus-precedent rearm of a derived feed, against the in-flight rule.

The round-26 precedent (S036 -> S039) APPENDS a new feed registry row naming
the new release and re-points the clock rows at it; the old feed row keeps its
dated located anchor. This script performs that shape for the SOPS group and
checks the in-flight rule on all three end states:

  R0  rearm not yet done: the derived rows still point at S033 (anchor cell
      still names v3.13.3), their anchors are still v3.13.3 and the live feed
      now serves v3.14.0 -> the derived rows are legitimately FIRED.
  R1  the corpus-precedent rearm: a new registry row S044 names v3.14.0, the
      four derived rows are re-pointed at S044 and re-anchored to v3.14.0
      (observed v3.14.0, not-fired).
  R2  the forbidden in-place rearm: S033's anchor cell is rewritten to
      v3.14.0 while the derived rows keep anchored v3.13.3 and fired.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "rearm2"
INFLIGHT = SANDBOX / "inflight-release-clock.py"

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

GROUP = ("S008", "S009", "S010", "S011")


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
                "release-clock.py", "release-clocks.tsv"):
        shutil.copy2(vroot / "corpus" / rel, root / "corpus" / rel)
    lines = (vroot / "corpus/release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in table_edits:
            a, o, v, feed = table_edits[f[0]]
            f[4], f[5], f[7] = a, o, v
            if feed:
                f[2], f[3] = feed, "https://github.com/getsops/sops/releases.atom"
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


def run(root, rp, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120)


def report(label, proc):
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    last = lines[-1] if lines else ""
    print("  %-6s exit=%d clean=%-5s findings=%s" % (
        label, proc.returncode, last.startswith("RELEASE_CLOCK: CLEAN"), findings or "[]"))


def main():
    root = build()
    print("== R0: rearm not yet done; the four derived rows are legitimately FIRED ==")
    te = {r: ("3.13.3", "3.14.0", "fired", None) for r in GROUP}
    re_ = {r: ("3.14.0", "fired") for r in GROUP}
    fx, rp, sha = stage(root, "R0", te, re_)
    report("R0", run(fx, rp, sha))

    print("== R1: corpus-precedent rearm (new registry row S044 + re-point + re-anchor) ==")
    te = {r: ("3.14.0", "3.14.0", "not-fired", "S044") for r in GROUP}
    re_ = {r: ("3.14.0", "not-fired") for r in GROUP}
    fx, rp, sha = stage(root, "R1", te, re_,
                        sources_edits=[("\n\n## Paths", "\n" + NEW_ROW + "\n\n## Paths")])
    report("R1", run(fx, rp, sha))

    print("== R2: forbidden in-place rearm (S033's cell rewritten; derived rows keep 3.13.3) ==")
    te = {r: ("3.13.3", "3.14.0", "fired", None) for r in GROUP}
    re_ = {r: ("3.14.0", "fired") for r in GROUP}
    fx, rp, sha = stage(root, "R2", te, re_, sources_edits=[(
        "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-25T00:00:00Z")])
    report("R2", run(fx, rp, sha))

    print("== R3: R2 + the derived rows re-anchored to 3.14.0 but still on S033 ==")
    te = {r: ("3.14.0", "3.14.0", "not-fired", None) for r in GROUP}
    re_ = {r: ("3.14.0", "not-fired") for r in GROUP}
    fx, rp, sha = stage(root, "R3", te, re_, sources_edits=[(
        "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-25T00:00:00Z")])
    report("R3", run(fx, rp, sha))


if __name__ == "__main__":
    main()
