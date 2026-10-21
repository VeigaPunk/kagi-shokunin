#!/usr/bin/env python3
"""Dotted-date fragility of the in-flight set-equality binding.

The in-flight rule binds a derived anchor by SET EQUALITY on the stable X.Y.Z
tokens of the feed row's anchor cell:
    set(STABLE_TOKEN_RE.findall(feed_anchor)) == {norm_version(anchored)}
(`corpus/release-clock.py:363`)

STABLE_TOKEN_RE has no date guard, so a cell that also carries a DOTTED date
("feed fetched 2026.10.21") names TWO tokens and the equality fails -- a
truthful derived row is refused with DERIVATION.

Today's cells carry dashed dates ("updated 2026-07-23T05:29:11Z; feed fetched
2026-10-21"), so this is latent, not live. It is a rearm hazard: a rearm
rewrites the feed row's anchor cell, and a rewriter who writes the fetch date
in dotted form silently unbinds every derived row on that feed.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
WORK = SANDBOX / "dotted"
INFLIGHT = SANDBOX / "inflight-release-clock.py"


def build():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    root = WORK / "tree"
    shutil.copytree(SANDBOX / "base", root)
    shutil.copy2(INFLIGHT, root / "corpus/release-clock.py")
    return root


def stage(vroot, tag, sources_edits):
    root = WORK / ("fx-" + tag)
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clock.py", "release-clocks.tsv"):
        shutil.copy2(vroot / "corpus" / rel, root / "corpus" / rel)
    text = (root / "corpus/SOURCES.md").read_text(encoding="utf-8")
    for old, new in sources_edits:
        assert old in text, old[:60]
        text = text.replace(old, new, 1)
    (root / "corpus/SOURCES.md").write_text(text, encoding="utf-8")
    receipt = json.loads((vroot / ".ufo/waves/round-26/observe-2.json").read_text())
    rp = root / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    return root, rp, sha


def run(root, rp, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120)


def main():
    root = build()
    for label, repl in (
        ("dashed fetch date (today)", "2026-07-23T05:29:11Z; feed fetched 2026-10-21"),
        ("dotted fetch date", "2026-07-23T05:29:11Z; feed fetched 2026.10.21"),
    ):
        fx, rp, sha = stage(root, label.replace(" ", "_").replace("(", "").replace(")", ""), [
            ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; feed fetched 2026-10-21",
             "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated " + repl),
        ])
        proc = run(fx, rp, sha)
        lines = [l for l in proc.stdout.splitlines() if l.strip()]
        findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
        print("%-26s exit=%d findings=%s" % (label, proc.returncode, findings or "[]"))

    print()
    print("token sets:")
    import importlib.util
    spec = importlib.util.spec_from_file_location("rc", INFLIGHT)
    rc = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rc)
    for cell in ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; feed fetched 2026-10-21",
                 "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; feed fetched 2026.10.21"):
        print("  %-60s -> %s" % (cell[-30:], sorted(set(rc.STABLE_TOKEN_RE.findall(cell)))))


if __name__ == "__main__":
    main()
