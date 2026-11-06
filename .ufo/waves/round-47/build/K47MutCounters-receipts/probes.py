#!/usr/bin/env python3
"""Probe controls for survivors of the round-47 mutant sweep.

Each probe is a fixture tree that the *pristine* counter must reject (expected
verdict printed below) and that the named mutant must accept. A probe is valid
only if the pristine run gives the declared expectation; only then does it
"kill" the mutant.
"""
import html
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import time

S = "/fast/scratch/hyaku/kagi-r47/K47MutCounters"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
CAPDIR = os.path.join(S, "cap")
spec = importlib.util.spec_from_file_location("harness", os.path.join(S, "ctl/controls-harness.py"))
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
h.SCRATCH = os.path.join(S, "ctl")
TIMES = {}
for line in open(os.path.join(CAPDIR, "capture-times.tsv")):
    i, ts = line.split()
    TIMES[i] = ts
h.TIMES = TIMES
ASOF = str(int(time.time()) + 3600)

BASE_TAR = os.path.join(S, "ctl", "base.tar")


def fast_base_tree(dest):
    os.makedirs(dest, exist_ok=True)
    subprocess.run(["tar", "-x", "-C", dest, "-f", BASE_TAR], check=True)


h.base_tree = fast_base_tree
PRISTINE = {"c1": os.path.join(S, "mut/c1-pristine.sh"),
            "c2": os.path.join(S, "mut/c2-pristine.sh")}

SCRIPT_STYLE_RE = re.compile(r"(?is)<(script|style)\b[^>]*>.*?</\1\s*>")
TAG_RE = re.compile(r"<[^>]+>")
WS_RE = re.compile(r"\s+")


def norm(path):
    t = SCRIPT_STYLE_RE.sub(" ", open(path, encoding="utf-8", errors="strict").read())
    t = TAG_RE.sub(" ", t)
    t = html.unescape(t)
    return WS_RE.sub(" ", t).strip()


def distinct_phrase(capfile, count, avoid):
    text = norm(capfile)
    for m in re.finditer(r"[A-Z][^.]{40,120}\.", text):
        cand = WS_RE.sub(" ", m.group(0)).strip()
        if cand and cand != avoid and text.count(cand) == count:
            return cand
    raise SystemExit("SETUP: no phrase with count=%d in %s" % (count, capfile))


def edit(path, old, new):
    s = open(path, encoding="utf-8").read()
    if old not in s:
        raise SystemExit("SETUP: absent in %s: %r" % (path, old[:50]))
    open(path, "w", encoding="utf-8").write(s.replace(old, new, 1))


def ledger_row(t, i):
    for line in open(os.path.join(t, "corpus/fired-reverify.tsv"), encoding="utf-8"):
        c = line.rstrip("\n").split("\t")
        if c[0] == i:
            return c
    raise SystemExit("SETUP: no ledger row for " + i)


def set_ledger(t, i, col, val):
    p = os.path.join(t, "corpus/fired-reverify.tsv")
    rows = open(p, encoding="utf-8").read().split("\n")
    for n, line in enumerate(rows):
        c = line.split("\t")
        if c[0] == i:
            c[col] = val
            rows[n] = "\t".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(rows))


# ---------------------------------------------------------------- builds
def p_status_flip(t):
    h.c1_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/SOURCES.md")
    rows = open(p, encoding="utf-8").read().split("\n")
    for n, line in enumerate(rows):
        if line.startswith("| S014 "):
            c = line.split("|")
            c[8] = " queued "
            rows[n] = "|".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(rows))


def p_dup_registry(t):
    h.c1_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/SOURCES.md")
    lines = open(p, encoding="utf-8").read().split("\n")
    for n, line in enumerate(lines):
        if line.startswith("| S010 "):
            lines.insert(n + 1, line)
            break
    open(p, "w", encoding="utf-8").write("\n".join(lines))


def p_capture_tamper(t):
    h.c1_fix(t, CAPDIR)
    c = os.path.join(t, ".ufo/waves/round-47/capture/S099.body")
    data = open(c, "rb").read()
    open(c, "wb").write(data + b"x")


def p_row_sha_wrong(t):
    h.c1_fix(t, CAPDIR, body_sha="0" * 64)


def p_two_s099_rows(t):
    h.c1_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/source-fetches.tsv")
    lines = open(p, encoding="utf-8").read().rstrip("\n").split("\n")
    rows = [l for l in lines if l.startswith("S099\t")]
    open(p, "a", encoding="utf-8").write(rows[0] + "\n")


def p_prefixed_finding(t):
    h.c1_fix(t, CAPDIR)
    with open(os.path.join(t, "corpus/sources-census.sh"), "w") as fh:
        fh.write("#!/usr/bin/env bash\n"
                 "echo 'NOTE: FINDING SC_USEDBY_NOCITE id=S094 path=corpus/lessons/round-43.md'\n"
                 "echo 'SOURCES_CENSUS: FAILED (findings=0 rows=102)'\n")


def p_quote_absent_blob(t):
    h.c1_fix(t, CAPDIR)
    edit(os.path.join(t, "corpus/source-fetches.tsv"), h.S099_QUOTE,
         "This sentence is absent from the fleet prompt blob entirely.")


def silent_census(t):
    with open(os.path.join(t, "corpus/sources-census.sh"), "w") as fh:
        fh.write("#!/usr/bin/env bash\necho 'SOURCES_CENSUS: CLEAN (rows=102)'\n")


def p_status_flip_silent(t):
    p_status_flip(t)
    silent_census(t)


def p_dup_registry_silent(t):
    p_dup_registry(t)
    silent_census(t)


def p_two_s099_rows_silent(t):
    p_two_s099_rows(t)
    silent_census(t)


def q_wrong_bytes(t):
    h.c2_fix(t, CAPDIR)
    row = ledger_row(t, "S012")
    set_ledger(t, "S012", 6, str(int(row[6]) + 1))


def q_swap_same_count(t):
    h.c2_fix(t, CAPDIR)
    row = ledger_row(t, "S012")
    qc = int(row[7])
    bq = open(os.path.join(t, "corpus/source-fetches.tsv"), encoding="utf-8").read()
    bq = [l.split("\t")[12] for l in bq.split("\n") if l.startswith("S012\t")][0]
    cand = distinct_phrase(os.path.join(CAPDIR, "S012.body"), qc, bq)
    p = os.path.join(t, "corpus/source-fetches.tsv")
    rows = open(p, encoding="utf-8").read().split("\n")
    for n, line in enumerate(rows):
        c = line.split("\t")
        if len(c) == 16 and c[0] == "S012":
            c[12] = cand
            rows[n] = "\t".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(rows))


def q_wrong_quote_count(t):
    h.c2_fix(t, CAPDIR)
    row = ledger_row(t, "S012")
    set_ledger(t, "S012", 7, str(int(row[7]) + 1))


def q_quote_absent_body(t):
    h.c2_fix(t, CAPDIR)
    body = b"<html><body><p>no declared quote here</p></body></html>\n"
    cap = os.path.join(t, ".ufo/waves/round-47/capture/S012.body")
    with open(cap, "wb") as fh:
        fh.write(body)
    set_ledger(t, "S012", 5, h.sha(cap))
    set_ledger(t, "S012", 6, str(os.path.getsize(cap)))
    set_ledger(t, "S012", 7, "0")


def q_dotdot_same_file(t):
    h.c2_fix(t, CAPDIR)
    set_ledger(t, "S012", 4, ".ufo/waves/round-47/capture/../capture/S012.body")


def q_capture_outside(t):
    h.c2_fix(t, CAPDIR)
    shutil.copyfile(os.path.join(CAPDIR, "S012.body"), os.path.join(t, "corpus/S012.body"))
    set_ledger(t, "S012", 4, "corpus/S012.body")


def q_dup_ledger_row(t):
    h.c2_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/fired-reverify.tsv")
    lines = open(p, encoding="utf-8").read().rstrip("\n").split("\n")
    row = [l for l in lines if l.startswith("S012\t")][0]
    open(p, "a", encoding="utf-8").write(row + "\n")


def q_wrong_url(t):
    h.c2_fix(t, CAPDIR)
    set_ledger(t, "S012", 1, "https://example.invalid/not-the-registry-url")


def q_wrong_release(t):
    h.c2_fix(t, CAPDIR)
    set_ledger(t, "S012", 2, "9.9.9")


def q_capture_same_len(t):
    h.c2_fix(t, CAPDIR)
    c = os.path.join(t, ".ufo/waves/round-47/capture/S012.body")
    data = bytearray(open(c, "rb").read())
    idx = len(data) // 2
    data[idx] = ord("a") if data[idx] != ord("a") else ord("b")
    open(c, "wb").write(bytes(data))


PROBES = [
    ("P1-status-flip", "c1", "0", "status", p_status_flip, ["C1-M4-drop-intact-conjunct", "C1-M5-ignore-status-cell"]),
    ("P2-dup-registry-row", "c1", "0", "row-count", p_dup_registry, ["C1-M6-accept-dup-registry-rows"]),
    ("P3-capture-tamper", "c1", "0", "capture-sha", p_capture_tamper, ["C1-M7-drop-capture-sha"]),
    ("P4-row-sha-wrong", "c1", "0", "sha", p_row_sha_wrong, ["C1-M8-drop-row-sha"]),
    ("P5-two-s099-rows", "c1", "0", "s099-rows=2", p_two_s099_rows, ["C1-M10-drop-single-s099-row"]),
    ("P6-prefixed-finding", "c1", "3", "census=SOURCES_CENSUS: FAILED", p_prefixed_finding, ["C1-M12-loose-cleared-match"]),
    ("P7-quote-absent-from-blob", "c1", "0", "quote", p_quote_absent_blob, ["C1-M14-drop-blob-quote-check"]),
    ("P1b-status-flip-silent-census", "c1", "0", "status", p_status_flip_silent,
     ["C1-M4-drop-intact-conjunct", "C1-M5-ignore-status-cell"]),
    ("P2b-dup-registry-silent-census", "c1", "0", "row-count", p_dup_registry_silent,
     ["C1-M6-accept-dup-registry-rows"]),
    ("P5b-two-s099-rows-silent-census", "c1", "0", "s099-rows=2", p_two_s099_rows_silent,
     ["C1-M10-drop-single-s099-row"]),
    ("Q1-swap-same-count", "c2", "10", "quote-swapped", q_swap_same_count, ["C2-M5-drop-quote-swap"]),
    ("Q2-wrong-quote-count", "c2", "10", "quote-count", q_wrong_quote_count, ["C2-M6-drop-quote-count"]),
    ("Q3-quote-absent-body", "c2", "10", "not-located", q_quote_absent_body, ["C2-M7-accept-zero-count"]),
    ("Q4-dotdot-same-file", "c2", "10", "capture-dotdot", q_dotdot_same_file, ["C2-M10-drop-dotdot"]),
    ("Q5-capture-outside", "c2", "10", "capture-path", q_capture_outside, ["C2-M11-drop-capture-prefix"]),
    ("Q6-dup-ledger-row", "c2", "10", "rows=2", q_dup_ledger_row, ["C2-M12-accept-dup-ledger-rows"]),
    ("Q7-wrong-url", "c2", "10", "url", q_wrong_url, ["C2-M13-drop-url-check"]),
    ("Q8-wrong-release", "c2", "10", "release", q_wrong_release, ["C2-M14-drop-release-check"]),
    ("Q9-capture-same-len", "c2", "10", "capture-sha", q_capture_same_len, ["C2-M16-drop-capture-sha"]),
    ("Q10-wrong-declared-bytes", "c2", "10", "capture-bytes", q_wrong_bytes, ["C2-M9-drop-capture-bytes"]),
]


def run(counter, tree):
    env = {"C1_TREE": tree, "C2_TREE": tree, "C2_ASOF": ASOF, "HYAKU_SCRATCH": S}
    return h.run(counter, env)


def main():
    outs = []
    for name, ctr, expect, reason, build, targets in PROBES:
        tree = os.path.join(S, "ctl/probe", name)
        shutil.rmtree(tree, ignore_errors=True)
        fast_base_tree(tree)
        build(tree)
        rc, line = run(PRISTINE[ctr], tree)
        got = h.value_of(line) if line else "EMPTY"
        valid = got == expect and reason in line
        outs.append("%s pristine=%s (want %s) valid=%s reason-present=%s :: %s" %
                    (name, got, expect, got == expect, reason in line, line))
        for tgt in targets:
            mpath = os.path.join(S, "mut", tgt + "-" + ctr + ".sh")
            mrc, mline = run(mpath, tree)
            mgot = h.value_of(mline) if mline else "EMPTY"
            verdict = "KILLED" if (valid and mgot != expect) else "NOT-KILLED"
            outs.append("  %s %s pristine=%s mutant=%s" % (verdict, tgt, got, mgot))
        shutil.rmtree(tree, ignore_errors=True)
    out = os.path.join(S, "ctl/runs/probes.txt")
    open(out, "w").write("\n".join(outs) + "\n")
    print("\n".join(outs))
    return 0


if __name__ == "__main__":
    sys.exit(main())
