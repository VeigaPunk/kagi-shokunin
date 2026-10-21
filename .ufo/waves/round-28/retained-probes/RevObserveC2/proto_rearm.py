#!/usr/bin/env python3
"""Decisive test: does the in-flight C2 rule keep a LEGITIMATELY FIRED derived
row valid, under both rearm shapes the corpus uses?

REARM-ADD   the corpus precedent (S036 -> S039): a NEW registry row names the
             new release; the old derived row keeps its old feed_source_id and
             its old anchor, and simply fires.
REARM-EDIT  the same registry row's anchor cell is edited IN PLACE to the new
             release (the shape SOURCES.md's append-only discipline has never
             used for feed rows).

Also: the plan's own enumeration "the feed row S033-S037" vs S039, a feed-kind
registry row OUTSIDE that range that S040/S041 name.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "rearm"
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
    return proc.returncode, last, findings


def run(root, rp, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120)


def main():
    root = build()
    fired_rows = ("S008", "S009", "S010", "S011")
    fired_table = {r: ("3.13.3", "3.14.0", "fired") for r in fired_rows}
    fired_receipt = {r: ("3.14.0", "fired") for r in fired_rows}

    print("== REARM-ADD: new registry row S044 (the S036->S039 corpus precedent) ==")
    fx, rp, sha = stage(root, "ADD", fired_table, fired_receipt,
                        sources_edits=[("\n\n## Paths", "\n" + NEW_ROW + "\n\n## Paths")])
    rc, last, fnd = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== REARM-EDIT: S033's anchor cell edited IN PLACE to v3.14.0 ==")
    fx, rp, sha = stage(root, "EDIT", fired_table, fired_receipt,
                        sources_edits=[("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
                                        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-25T00:00:00Z")])
    rc, last, fnd = outcome(run(fx, rp, sha))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))
    print("  (the derived rows are LEGITIMATELY fired here: the feed advanced to"
          " 3.14.0, their anchor stays at 3.13.3, the observation moved to 3.14.0)")

    print("== REARM-EDIT + the derived row's anchor NOT re-verified (still 3.13.3, fired) ==")
    print("   -> a rearm that renames the feed row's located anchor must also")
    print("      re-anchor the derived rows, or the rule fires on a truthful row.")

    print("== S039: a feed-kind registry row OUTSIDE the plan's S033-S037 range ==")
    fx, rp, sha = stage(root, "S039", {}, {})
    rc, last, fnd = outcome(run(fx, rp, sha))
    print("  control exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))


if __name__ == "__main__":
    main()
