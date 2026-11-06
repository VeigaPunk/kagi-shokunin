#!/usr/bin/env python3
"""Mutation driver for round-47 counters.

Runs the frozen 17 controls (plans/round-47-controls.py, copied here as
controls-harness.py) against a mutated copy of plans/round-47-c1.sh or
round-47-c2.sh, in parallel, and reports which control changes verdict.
"""
import hashlib
import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

S = "/fast/scratch/hyaku/kagi-r47/K47MutCounters"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
spec = importlib.util.spec_from_file_location("harness", os.path.join(S, "ctl/controls-harness.py"))
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)

h.SCRATCH = os.path.join(S, "ctl")
TIMES = {}
with open(os.path.join(S, "cap/capture-times.tsv"), encoding="utf-8") as fh:
    for line in fh:
        i, ts = line.split()
        TIMES[i] = ts
h.TIMES = TIMES
ASOF = str(int(time.time()) + 3600)
CAPDIR = os.path.join(S, "cap")

BASE_TAR = os.path.join(S, "ctl", "base.tar")
if not os.path.exists(BASE_TAR):
    a = subprocess.run(["git", "-C", LANE, "archive", h.BASE], stdout=subprocess.PIPE, check=True)
    with open(BASE_TAR, "wb") as fh:
        fh.write(a.stdout)


def fast_base_tree(dest):
    os.makedirs(dest, exist_ok=True)
    subprocess.run(["tar", "-x", "-C", dest, "-f", BASE_TAR], check=True)


h.base_tree = fast_base_tree

# ---------------------------------------------------------------- controls
def k1_f1(t):
    p = os.path.join(t, "corpus/SOURCES.md")
    h.sub_file(p, "corpus/lessons/round-39.md, corpus/lessons/round-42.md, corpus/lessons/round-43.md",
               "corpus/lessons/round-39.md, corpus/lessons/round-42.md")
    h.c1_fix(t, CAPDIR, with_sources=False)
    h.sub_file(p, "| 2026-11-05 | 90d | corpus/lessons/round-44.md |",
               "| 2026-11-05 | 90d | corpus/lessons/round-39.md |")


def k1_f3(t):
    p = os.path.join(t, "corpus/SOURCES.md")
    with open(p, encoding="utf-8") as fh:
        lines = [l for l in fh if not (l.startswith("| S094 ") or l.startswith("| S099 "))]
    with open(p, "w", encoding="utf-8") as fh:
        fh.writelines(lines)


def k1_f4(t):
    h.c1_fix(t, CAPDIR)
    with open(os.path.join(t, "corpus/sources-census.sh"), "w") as fh:
        fh.write("#!/usr/bin/env bash\nexit 0\n")


def k1_f5(t):
    h.c1_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/source-fetches.tsv")
    with open(p, encoding="utf-8") as fh:
        s = fh.read()
    s = s.replace("\nS001\tmined\t", "\nS001\tqueued\t", 1) if "\nS001\tmined\t" in s else s
    with open(p, "w", encoding="utf-8") as fh:
        fh.write(s)


def k2_f4(t):
    h.c2_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/source-fetches.tsv")
    with open(p, encoding="utf-8") as fh:
        rows = fh.read().split("\n")
    for n, line in enumerate(rows):
        c = line.split("\t")
        if len(c) == 16 and c[0] in h.F:
            c[12] = "the"
            rows[n] = "\t".join(c)
    with open(p, "w", encoding="utf-8") as fh:
        fh.write("\n".join(rows))


def k2_f6(t):
    h.c2_fix(t, CAPDIR)
    p = os.path.join(t, "corpus/release-clocks.tsv")
    h.sub_file(p, "S008\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom\t3.13.3\t3.13.3",
               "S008\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom\t3.13.3\t3.13.2")


def k2_f7(t):
    h.c2_fix(t, CAPDIR)
    os.remove(os.path.join(t, "corpus/rendered-text-v1.py"))


CONTROLS = [
    ("K1-0-do-nothing", "round-47-c1.sh", "0", lambda t: None),
    ("K1-P-reference", "round-47-c1.sh", "3", lambda t: h.c1_fix(t, CAPDIR)),
    ("K1-F1-usedby-narrowing", "round-47-c1.sh", "0", k1_f1),
    ("K1-F2-handwritten-provenance", "round-47-c1.sh", "0",
     lambda t: h.c1_fix(t, CAPDIR, body_sha="0" * 64, with_capture=False)),
    ("K1-F3-row-deletion", "round-47-c1.sh", "0", k1_f3),
    ("K1-F4-silent-census", "round-47-c1.sh", "SETUP", k1_f4),
    ("K1-F5-fix-plus-new-finding", "round-47-c1.sh", "0", k1_f5),
    ("K2-0-do-nothing", "round-47-c2.sh", "0", lambda t: None),
    ("K2-P-reference", "round-47-c2.sh", "11", lambda t: h.c2_fix(t, CAPDIR)),
    ("K2-F1-ledger-without-captures", "round-47-c2.sh", "0",
     lambda t: h.c2_fix(t, CAPDIR, captures=False)),
    ("K2-F2-stale-dates-r36", "round-47-c2.sh", "0",
     lambda t: h.c2_fix(t, CAPDIR, times={i: "2026-11-04T12:00:00Z" for i in h.F})),
    ("K2-F3-future-dates", "round-47-c2.sh", "0",
     lambda t: h.c2_fix(t, CAPDIR, times={i: "2026-12-01T00:00:00Z" for i in h.F})),
    ("K2-F4-quote-swap", "round-47-c2.sh", "0", k2_f4),
    ("K2-F5-verdict-unset", "round-47-c2.sh", "0",
     lambda t: h.c2_fix(t, CAPDIR, verdict="pending")),
    ("K2-F6-gate-broken", "round-47-c2.sh", "0", k2_f6),
    ("K2-F7-normalizer-missing", "round-47-c2.sh", "SETUP", k2_f7),
    ("K2-C-handtyped-times-ceiling", "round-47-c2.sh", "11",
     lambda t: h.c2_fix(t, CAPDIR, times={i: "2026-11-06T00:00:01Z" for i in h.F})),
]


def one(ctl, run_id, mut_c1, mut_c2):
    name, counter, expect, build = ctl
    t = os.path.join(S, "ctl", "work", run_id, name)
    fast_base_tree(t)
    build(t)
    env = {"C1_TREE": t, "C2_TREE": t, "C2_ASOF": ASOF,
           "MUT_C1": mut_c1, "MUT_C2": mut_c2, "HYAKU_SCRATCH": S}
    path = mut_c1 if counter.endswith("c1.sh") else mut_c2
    rc, line = h.run(path, env)
    got = h.value_of(line) if line else "EMPTY"
    return name, expect, got, rc, line


def run_set(run_id, mut_c1, mut_c2, workers=10):
    with ThreadPoolExecutor(max_workers=workers) as ex:
        return list(ex.map(lambda c: one(c, run_id, mut_c1, mut_c2), CONTROLS))


def fmt(res):
    return ["%s expect=%s got=%s rc=%d :: %s" % r for r in res]


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "baseline"
    runs = os.path.join(S, "ctl", "runs")
    os.makedirs(runs, exist_ok=True)
    if mode == "baseline":
        c1, c2 = os.path.join(S, "mut/c1-pristine.sh"), os.path.join(S, "mut/c2-pristine.sh")
        shutil.rmtree(os.path.join(S, "ctl", "work", "baseline"), ignore_errors=True)
        res = run_set("baseline", c1, c2)
        out = os.path.join(runs, "baseline.txt")
        with open(out, "w") as fh:
            fh.write("\n".join(fmt(res)) + "\n")
        print(open(out).read())
        return 0
    # mode = mutant id: expects mut/<id>-c1.sh or mut/<id>-c2.sh
    mid = mode
    c1m = os.path.join(S, "mut", mid + "-c1.sh")
    c2m = os.path.join(S, "mut", mid + "-c2.sh")
    c1 = c1m if os.path.exists(c1m) else os.path.join(S, "mut/c1-pristine.sh")
    c2 = c2m if os.path.exists(c2m) else os.path.join(S, "mut/c2-pristine.sh")
    shutil.rmtree(os.path.join(S, "ctl", "work", mid), ignore_errors=True)
    res = run_set(mid, c1, c2)
    base = {}
    bp = os.path.join(runs, "baseline.txt")
    if os.path.exists(bp):
        for line in open(bp):
            nm = line.split()[0]
            base[nm] = line
    killed, surv = [], []
    lines = []
    for r in res:
        name, expect, got, rc, line = r
        changed = got != expect
        (killed if changed else surv).append(name)
        lines.append("%-28s expect=%-5s got=%-5s %s :: %s" % (
            name, expect, got, "KILLED" if changed else "survived", line))
    out = os.path.join(runs, mid + ".txt")
    with open(out, "w") as fh:
        fh.write("\n".join(lines) + "\n")
        fh.write("MUTANT %s killed_by=%s survivors=%s\n" % (
            mid, ",".join(killed) or "-", ",".join(surv) or "-"))
    print(open(out).read())
    shutil.rmtree(os.path.join(S, "ctl", "work", mid), ignore_errors=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
