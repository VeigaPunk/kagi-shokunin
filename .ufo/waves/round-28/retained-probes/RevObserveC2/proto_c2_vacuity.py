#!/usr/bin/env python3
"""Fourth C2 set: vacuity and ambiguity of the feed-row token set.

V1  the feed row's anchor cell names NO canonical X.Y.Z token
    (e.g. rewritten to "v3.13.03" -- leading zero, which C1 forbids, or to a
    prose cell).  A rule guarded by `if av and ...` then passes the row
    UNCHECKED: vacuity.
V2  the feed row's anchor cell names TWO distinct versions
    ("Entry titled v3.14.0 ... previous v3.13.3").  Set-membership accepts
    either; the rule is then not a binding to ONE named version.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work6"

HELPER = '''
def _ver_tokens(text):
    out = set()
    for m in re.finditer(r"(?<![0-9A-Za-z.])v?([0-9]+\\.[0-9]+\\.[0-9]+)(?![0-9A-Za-z.])",
                         text or ""):
        t = m.group(1)
        if not re.search(r"(^|\\.)0[0-9]", t):
            out.add(t)
    return out
'''

PATCH = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''


def build():
    root = WORK / "v"
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE, root)
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    code = code.replace("def evaluate(sources, rows, captures=None, receipt_bundle=None):\n",
                        HELPER.lstrip("\n") + "\n\ndef evaluate(sources, rows, captures=None, receipt_bundle=None):\n", 1)
    code = code.replace('            is_derived = values["note"].startswith("derived:")\n', PATCH, 1)
    path.write_text(code, encoding="utf-8")
    return root


def fixture(vroot, tag, table_edits, receipt_edits, sources_edits=None):
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
            rec["parsed_version"], rec["verdict"] = receipt_edits[record_id] \
                if False else receipt_edits[rec["id"]]
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


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    root = build()
    # the frozen G1 shape: ALL four S033 derived rows lowered together, so the
    # round-27 feed floor moves with them and REGRESSED cannot mask the result
    forged = {r: ("3.13.2", "3.13.2", "not-fired")
              for r in ("S008", "S009", "S010", "S011")}
    forged_receipt = {r: ("3.13.2", "not-fired")
                      for r in ("S008", "S009", "S010", "S011")}

    print("== V1a: feed row S033 anchor cell rewritten to a NON-canonical token ==")
    fx, rp, sha = fixture(root, "V1a", forged, forged_receipt, sources_edits=[(
        "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
        "Entry titled v3.13.03, tag link /releases/tag/v3.13.03, updated 2026-07-23T05:29:11Z")])
    rc, last, fnd, ids = outcome(subprocess.run(
        ["python3", "-I", "-B", str(fx / "corpus/release-clock.py"), "--root", str(fx),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== V1b: feed row S033 anchor cell rewritten to prose (no version) ==")
    fx, rp, sha = fixture(root, "V1b", forged, forged_receipt, sources_edits=[(
        "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
        "Atom feed fetched 2026-10-21; newest stable entry located")])
    rc, last, fnd, ids = outcome(subprocess.run(
        ["python3", "-I", "-B", str(fx / "corpus/release-clock.py"), "--root", str(fx),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))

    print("== V2: feed row S033 anchor cell names TWO versions ==")
    fx, rp, sha = fixture(root, "V2", forged, forged_receipt, sources_edits=[(
        "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
        "Entry titled v3.13.2, tag link /releases/tag/v3.13.3, previous v3.13.3, updated 2026-07-23T05:29:11Z")])
    rc, last, fnd, ids = outcome(subprocess.run(
        ["python3", "-I", "-B", str(fx / "corpus/release-clock.py"), "--root", str(fx),
         "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120))
    print("  exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))
    print("  (a set-membership rule accepts 3.13.2 here -- the forged anchor --"
          " so the rule no longer binds ONE named version)")


if __name__ == "__main__":
    main()
