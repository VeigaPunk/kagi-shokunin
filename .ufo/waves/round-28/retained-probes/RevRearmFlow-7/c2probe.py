#!/usr/bin/env python3
"""C2 coupling probe: a scratch prototype of the plan's C2 predicate, plus the
round-26 'keep predecessor, add successor' rearm shape (E7).

The prototype is a REVIEW-SIDE probe of the coupling only; it is not the
round-28 C2 implementation and claims nothing about it.
"""
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
WORK = HERE / "ce"
NUM = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"


def load(tree):
    spec = importlib.util.spec_from_file_location("rc_%s" % tree.name, tree / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def c2_probe(tree, match="anchor-cell-first"):
    """Return list of (row_id, anchored, feed_id, feed_versions, verdict)."""
    mod = load(tree)
    sources = mod.parse_sources(tree)
    rows = mod.parse_bindings(tree)
    out = []
    for row in rows:
        if row["malformed"]:
            continue
        v = dict(zip(mod.HEADER, row["fields"]))
        if not v["note"].startswith("derived:"):
            continue
        feed = sources.get(v["feed_source_id"])
        if feed is None:
            out.append((v["id"], v["anchored_version"], v["feed_source_id"], [], "NO-FEED-ROW"))
            continue
        if match == "anchor-cell-first":
            toks = NUM.findall(feed["anchor"])
            ok = bool(toks) and toks[0] == v["anchored_version"]
        else:  # whole-row any-match
            toks = NUM.findall(feed["anchor"] + " " + feed["teaches"])
            ok = v["anchored_version"] in toks
        out.append((v["id"], v["anchored_version"], v["feed_source_id"], toks, "OK" if ok else "MISMATCH"))
    return out


def run(tree, receipt=None, sha=None):
    argv = [sys.executable, "-I", "-B", "corpus/release-clock.py", "--root", str(tree)]
    if receipt:
        argv += ["--receipt", str(receipt), "--receipt-sha", sha]
    p = subprocess.run(argv, capture_output=True, text=True, cwd=tree)
    return p.returncode, (p.stdout + p.stderr).strip()


def forge(tree, updates):
    path = tree / RECEIPT_REL
    doc = json.loads(path.read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec["id"] in updates:
            rec.update(updates[rec["id"]])
    raw = json.dumps(doc, indent=2, sort_keys=True).encode("utf-8")
    out = tree / "ce-receipt.json"
    out.write_bytes(raw)
    return out, hashlib.sha256(raw).hexdigest()


def e7():
    """round-26 shape applied to a derived feed: keep S008-S011, add successor rows."""
    dest = WORK / "e7"
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(BASE, dest)
    # new registry source row S044: successor for the SOPS age teaching, on-release
    sp = dest / "corpus" / "SOURCES.md"
    text = sp.read_text(encoding="utf-8")
    s009 = [l for l in text.splitlines() if l.startswith("| S009 ")][0]
    cells = s009.split("|")
    cells[1] = " S044 "
    cells[2] = " Age on SOPS, round-29 successor — https://getsops.io/docs/usage/identities/age/ "
    cells[6] = "§Encrypting using age; last modified 2026-10-22, docs commit 0000000; successor to S009, feed S033 names v3.14.0"
    cells[7] = "supersedes S009 — the rotation teaching is unchanged; the clock is rearmed at the newest stable SOPS release 3.14.0"
    cells[9] = "2026-10-22"
    cells[10] = "on-release"
    cells[11] = "corpus/lessons/round-29.md "
    new_row = "|".join(cells[:12]) if len(cells) > 12 else "|".join(cells)
    sp.write_text(text + new_row + "\n", encoding="utf-8")
    # new clock row S044 (derived successor at 3.14.0 on the same feed)
    tp = dest / "corpus" / "release-clocks.tsv"
    lines = tp.read_text(encoding="utf-8").splitlines()
    row = "\t".join((
        "S044", "feed", "S033", "https://github.com/getsops/sops/releases.atom",
        "3.14.0", "3.14.0", "2026-10-22", "not-fired",
        "derived: successor to S009; newest stable SOPS tag when the row was opened 2026-10-22 (v3.14.0)"))
    tp.write_text("\n".join(lines + [row]) + "\n", encoding="utf-8")
    rc, sha = forge(dest, {"S044": {"parsed_version": "3.14.0", "verdict": "not-fired",
                                    "observed_at": "2026-10-22T00:00:00Z"}})
    code, out = run(dest, rc, sha)
    print("### E7 round-26 shape on a derived feed: keep S008-S011, add successor S044")
    print(out)
    print("(exit %d)\n" % code)


def main():
    print("### C2 probe (anchor-cell first match) on each tree")
    for name in ("base", "e3", "e4", "e5"):
        tree = WORK / name if name != "base" else BASE
        if not tree.exists():
            continue
        res = c2_probe(tree)
        bad = [r for r in res if r[4] != "OK"]
        print("%-5s derived rows=%d mismatching=%d %s" % (name, len(res), len(bad), bad))
    print()
    print("### C2 probe (whole-row any match) on BASE")
    res = c2_probe(BASE, match="whole-row")
    print("derived rows=%d mismatching=%d" % (len(res), len([r for r in res if r[4] != "OK"])))
    print()
    e7()
    print("### C2 probe on E7 tree (successor shape)")
    res = c2_probe(WORK / "e7")
    for r in res:
        print("  ", r)


if __name__ == "__main__":
    main()
