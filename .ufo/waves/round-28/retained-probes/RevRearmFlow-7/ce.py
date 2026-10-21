#!/usr/bin/env python3
"""Counterexample harness for the round-28 C2 x rearm-coupling question.

Each case copies the BASE tree, applies a candidate rearm shape to
corpus/release-clocks.tsv (and/or corpus/SOURCES.md), and runs the BASE
gate (corpus/release-clock.py) offline against a possibly-forged receipt.
Nothing here touches the lane checkout.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base"
WORK = Path(__file__).resolve().parent / "ce"
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"


def fresh(name):
    dest = WORK / name
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(BASE, dest)
    return dest


def rows(tree):
    p = tree / "corpus" / "release-clocks.tsv"
    out = []
    for i, line in enumerate(p.read_text(encoding="utf-8").splitlines()):
        if i == 0:
            out.append(line)
            continue
        out.append(line.split("\t"))
    return out


def write_rows(tree, table):
    lines = [table[0]] + ["\t".join(r) for r in table[1:]]
    (tree / "corpus" / "release-clocks.tsv").write_text("\n".join(lines) + "\n", encoding="utf-8")


def set_field(table, row_id, field, value):
    idx = table[0].split("\t").index(field)
    for r in table[1:]:
        if r[0] == row_id:
            r[idx] = value


def forge_receipt(tree, updates):
    """updates: {row_id: {parsed_version, verdict, observed_at}}"""
    path = tree / RECEIPT_REL
    doc = json.loads(path.read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec["id"] in updates:
            rec.update(updates[rec["id"]])
    raw = json.dumps(doc, indent=2, sort_keys=True).encode("utf-8")
    out = tree / "ce-receipt.json"
    out.write_bytes(raw)
    return out, hashlib.sha256(raw).hexdigest()


def run(tree, receipt=None, sha=None):
    argv = [sys.executable, "-I", "-B", "corpus/release-clock.py", "--root", str(tree)]
    if receipt is not None:
        argv += ["--receipt", str(receipt), "--receipt-sha", sha]
    p = subprocess.run(argv, capture_output=True, text=True, cwd=tree)
    return p.returncode, (p.stdout + p.stderr).strip()


def report(name, code, out, note):
    print("### %s\n%s\n(exit %d)\n" % (name, out, code))


def main():
    WORK.mkdir(parents=True, exist_ok=True)

    # E0 control
    code, out = run(BASE)
    report("E0 control (BASE tree, default receipt)", code, out,
           "expect CLEAN on_release=30 bound=30 observed=30 fired=3 derived=15")

    # E1: clock-table-only rearm: raise S008's derived anchor, keep observation
    t = fresh("e1")
    tb = rows(t)
    set_field(tb, "S008", "anchored_version", "3.14.0")
    write_rows(t, tb)
    code, out = run(t)
    report("E1 clock-table-only rearm (S008 anchored 3.13.3 -> 3.14.0, observation kept)", code, out,
           "expect REGRESSED S008: the anchor cannot be raised without a matching observation")

    # E2: rearm ONE derived row of the SOPS feed (observed moves too)
    t = fresh("e2")
    tb = rows(t)
    set_field(tb, "S009", "anchored_version", "3.14.0")
    set_field(tb, "S009", "observed_version", "3.14.0")
    write_rows(t, tb)
    rc, sha = forge_receipt(t, {"S009": {"parsed_version": "3.14.0", "verdict": "not-fired"}})
    code, out = run(t, rc, sha)
    report("E2 rearm ONE of four SOPS derived rows (S009), siblings kept", code, out,
           "expect REGRESSED S008 (feed-floor cascade on the retained sibling)")

    # E3: rearm the whole SOPS derived group in the clock table only
    t = fresh("e3")
    tb = rows(t)
    for rid in ("S008", "S009", "S010", "S011"):
        set_field(tb, rid, "anchored_version", "3.14.0")
        set_field(tb, rid, "observed_version", "3.14.0")
    write_rows(t, tb)
    rc, sha = forge_receipt(t, {rid: {"parsed_version": "3.14.0", "verdict": "not-fired"}
                                 for rid in ("S008", "S009", "S010", "S011")})
    code, out = run(t, rc, sha)
    report("E3 rearm all four SOPS derived rows in the clock table only", code, out,
           "expect CLEAN: the clock table alone is a coherent rearm, but the pinned feed row S033 still names 3.13.3 -> C2 would flag all four")

    # E4: same rearm, but the admitted feed row S033 is edited in place to name 3.14.0
    t = fresh("e4")
    tb = rows(t)
    for rid in ("S008", "S009", "S010", "S011"):
        set_field(tb, rid, "anchored_version", "3.14.0")
        set_field(tb, rid, "observed_version", "3.14.0")
    write_rows(t, tb)
    sp = t / "corpus" / "SOURCES.md"
    text = sp.read_text(encoding="utf-8")
    before = [l for l in text.splitlines() if l.startswith("| S033 ")][0]
    after = before.replace("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
                           "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-02T05:29:11Z")
    after = after.replace("The newest stable SOPS release is v3.13.3",
                           "The newest stable SOPS release is v3.14.0")
    after = after.replace("Quote: “<title>v3.13.3</title>”", "Quote: “<title>v3.14.0</title>”")
    sp.write_text(text.replace(before, after), encoding="utf-8")
    rc, sha = forge_receipt(t, {rid: {"parsed_version": "3.14.0", "verdict": "not-fired"}
                                 for rid in ("S008", "S009", "S010", "S011")})
    code, out = run(t, rc, sha)
    report("E4 same rearm + S033 anchor/quote edited IN PLACE (registry history rewrite)", code, out,
           "CLEAN, but the dated registry row now asserts a 2026-10-21 fetch that saw v3.14.0")
    print("--- S033 before ---\n%s\n--- S033 after ---\n%s\n" % (before, after))

    # E5: derived anchor at a version the feed row does NOT name (curl DEV label 8.23.1)
    t = fresh("e5")
    tb = rows(t)
    set_field(tb, "S029", "anchored_version", "8.23.1")
    set_field(tb, "S029", "observed_version", "8.23.1")
    write_rows(t, tb)
    rc, sha = forge_receipt(t, {"S029": {"parsed_version": "8.23.1", "verdict": "not-fired"}})
    code, out = run(t, rc, sha)
    report("E5 derived anchor at curl's unreleased DEV label 8.23.1 (feed row S037 names 8.23.0)", code, out,
           "BASE accepts: anchor_ok is skipped for derived rows; a whole-row C2 match would also accept it")

    # E6: which version does each feed row name, and where
    t = fresh("e6")
    sys.path.insert(0, str(t / "corpus"))
    import importlib.util
    spec = importlib.util.spec_from_file_location("rc", t / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    sources = mod.parse_sources(t)
    import re
    NUM = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
    print("### E6 version tokens per feed row (anchor cell vs whole row)")
    for sid in ("S033", "S034", "S035", "S036", "S037", "S039"):
        s = sources[sid]
        print("%s anchor-cell=%s whole-row=%s" % (sid, NUM.findall(s["anchor"]), NUM.findall(s["anchor"] + " " + s["teaches"])))
    print()


if __name__ == "__main__":
    main()
