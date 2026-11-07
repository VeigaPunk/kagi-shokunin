#!/usr/bin/env python3
"""Reference implementation of plans/round-60.md §C1, written literally from the
frozen item text.  This is NOT the lane's instrument: it exists so a probe reading can
be attributed to the PLAN (a faithful reader also reads 0) or to the CHECKER (a faithful
reader reads 1 but the landed checker reads 0).

Usage: refcheck.py --root DIR [--anchor-last|--anchor-first] [--json]
"""
import argparse
import json
import os
import re
import subprocess
import sys

REL_RESULTS = ".ufo/waves/round-59/w1-results.json"
REL_SELFTEST = ".ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt"
REL_C1LANDED = ".ufo/waves/round-59/final/c1-landed.txt"
REL_CONTROLS = ".ufo/waves/round-59/controls/controls-prefreeze.txt"
REL_LESSON59 = "corpus/lessons/round-59.md"
REL_LESSON60 = "corpus/lessons/round-60.md"
REL_TRIAL = "corpus/openbao-transit-trial.sh"
HEAD1 = re.compile(r"^## Round 59 — correction")
HEADANY = re.compile(r"^## ")


def rd(root, rel):
    try:
        with open(os.path.join(root, *rel.split("/")), encoding="utf-8",
                  errors="surrogateescape") as f:
            return f.read()
    except OSError:
        return None


def derive_results(root):
    t = rd(root, REL_RESULTS)
    if t is None:
        return None, None
    d = json.loads(t)
    res = d.get("results", [])
    dead = 0
    for r in res:
        out = r.get("output")
        if not isinstance(out, str) or not out.strip():
            dead += 1
    return len(res), dead


def derive_cases(root):
    t = rd(root, REL_SELFTEST)
    if t is None:
        return None
    n = None
    for ln in t.splitlines():
        m = re.search(r"C1_CHECK_SELFTEST: PASS \((\d+) cases\)", ln)
        if m:
            n = int(m.group(1))
    return n


def derive_hash(root):
    t = rd(root, REL_C1LANDED)
    if t is None:
        return None
    h = None
    for ln in t.splitlines():
        m = re.search(r"c1-driver: measured=revision ([0-9a-f]{40})", ln)
        if m:
            h = m.group(1)
    return h


def derive_controls(root):
    t = rd(root, REL_CONTROLS)
    if t is None:
        return None
    return sum(1 for ln in t.splitlines() if ln.startswith("CONTROL "))


def i1(root):
    t = rd(root, "LOG.md")
    if t is None:
        return 0, "LOG.md missing"
    lines = t.splitlines()
    dead_idx = [i for i, ln in enumerate(lines) if "__DEAD__" in ln]
    if not dead_idx:
        return 0, "no __DEAD__ line"
    start = dead_idx[-1]
    heads = [i for i, ln in enumerate(lines) if i > start and HEAD1.match(ln)]
    if not heads:
        return 0, f"no '## Round 59 — correction' block after line {start+1}"
    h = heads[0]
    end = len(lines)
    for j in range(h + 1, len(lines)):
        if HEADANY.match(lines[j]):
            end = j
            break
    block = lines[h:end]
    n_res, n_dead = derive_results(root)
    if n_res is None:
        return 0, "w1-results.json missing (unresolved)"
    hit = None
    for ln in block:
        m = re.search(r"results=(\d+) dead=(\d+)", ln)
        if m:
            hit = (int(m.group(1)), int(m.group(2)), ln)
    if hit is None:
        return 0, f"block has no results=<R> dead=<D> line (derived R={n_res} D={n_dead})"
    names = any("w1-results.json" in ln for ln in block)
    ok = hit[0] == n_res and hit[1] == n_dead and names
    return (1 if ok else 0), (f"block states results={hit[0]} dead={hit[1]} "
                              f"derived R={n_res} D={n_dead} names_file={names}")


def i2(root):
    t = rd(root, REL_LESSON59)
    if t is None:
        return 0, "lesson missing"
    lines = t.splitlines()
    first = None
    for i, ln in enumerate(lines):
        if "R31" in ln:
            first = i
            break
    if first is None:
        return 0, "no R31 line"
    n = derive_cases(root)
    if n is None:
        return 0, "selftest receipt missing (unresolved)"
    hit = None
    for ln in lines[first + 1:]:
        if "supersedes R31" in ln and "C1_CHECK_SELFTEST" in ln:
            hit = ln
    if hit is None:
        return 0, f"no 'supersedes R31' line after first R31 line (line {first+1}); derived={n}"
    m = re.search(r"\b(\d+)\b", hit.split("C1_CHECK_SELFTEST", 1)[1])
    stated = int(m.group(1)) if m else None
    return (1 if stated == n else 0), f"last correction line after R31 states={stated} derived={n}"


def i3(root):
    t = rd(root, REL_LESSON60)
    if t is None:
        return 0, "corpus/lessons/round-60.md missing"
    lines = t.splitlines()
    h = None
    for i, ln in enumerate(lines):
        if ln.strip() == "## Routed dispositions":
            h = i
            break
    if h is None:
        return 0, "no '## Routed dispositions' heading"
    rows = []
    for ln in lines[h + 1:]:
        if HEADANY.match(ln):
            break
        if ln.strip().startswith("|"):
            rows.append(ln)
    cells = []
    for ln in rows:
        parts = [c.strip() for c in ln.strip().strip("|").split("|")]
        if all(set(c) <= set("-: ") for c in parts):
            continue
        cells.append(parts)
    ids = []
    for parts in cells:
        if parts and re.fullmatch(r"R\d+", parts[0]):
            ids.append(parts[0])
    counts = {}
    for x in ids:
        counts[x] = counts.get(x, 0) + 1
    uniq_ok = len(ids) >= 3 and (not counts or max(counts.values()) == 1)
    name_line = None
    for ln in lines:
        if all(k in ln for k in ("R20", "R21", "R22")) and "duplicate" in ln:
            name_line = ln
    return (1 if (uniq_ok and name_line) else 0), (
        f"ids={ids} uniq_ok={uniq_ok} duplicate_line={'yes' if name_line else 'no'}")


def i4(root, anchor="last"):
    t = rd(root, "SCORECARD.md")
    if t is None:
        return 0, "SCORECARD.md missing"
    lines = t.splitlines()
    anchors = [i for i, ln in enumerate(lines) if "(21 controls" in ln]
    if not anchors:
        return 0, "no '(21 controls' line"
    a = anchors[-1] if anchor == "last" else anchors[0]
    n = derive_controls(root)
    if n is None:
        return 0, "controls receipt missing (unresolved)"
    hit = None
    for ln in lines[a + 1:]:
        if "supersedes SCORECARD.md:1971" in ln:
            hit = ln
    if hit is None:
        return 0, f"no correction after anchor line {a+1} (of {len(anchors)}); derived={n}"
    m = re.search(r"(\d+) controls", hit)
    stated = int(m.group(1)) if m else None
    return (1 if stated == n else 0), (
        f"anchor line {a+1} of {len(anchors)}; last correction states={stated} derived={n}")


def i5(root):
    t = rd(root, "SCORECARD.md")
    if t is None:
        return 0, "SCORECARD.md missing"
    for ln in t.splitlines():
        if "supersedes the round-59 gate-evidence pointer" not in ln:
            continue
        paths = re.findall(r"\.ufo/waves/round-60/final/[^\s`'\"]+", ln)
        if len(paths) < 3:
            return 0, f"line names {len(paths)} round-60 final paths"
        want = ("release-clock", "RELEASE_CLOCK:", "doc-audit", "DOC_AUDIT:", "scope", "SCOPE")
        ok = True
        det = []
        for k in range(0, 6, 2):
            needle, prefix = want[k], want[k + 1]
            p = next((x for x in paths if needle in os.path.basename(x)), None)
            if p is None:
                ok = False
                det.append(f"{needle}:not-named")
                continue
            body = rd(root, p)
            if body is None:
                ok = False
                det.append(f"{needle}:missing")
                continue
            last = None
            for x in reversed(body.splitlines()):
                if x.strip():
                    last = x.strip()
                    break
            ok = ok and last is not None and last.startswith(prefix)
            det.append(f"{needle}:{'ok' if last and last.startswith(prefix) else 'bad-last'}")
        ok = ok and "never written" in ln
        return (1 if ok else 0), " ".join(det) + f" never_written={'never written' in ln}"
    return 0, "no 'supersedes the round-59 gate-evidence pointer' line"


def i7(root):
    p = os.path.join(root, *REL_TRIAL.split("/"))
    if not os.path.isfile(p):
        return 0, "trial missing"
    try:
        r = subprocess.run(["bash", p, "--selftest"], cwd=root, capture_output=True,
                           text=True, timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return 0, f"selftest not runnable: {e}"
    n = None
    for ln in r.stdout.splitlines():
        m = re.search(r"TRANSIT_SELFTEST: PASS \(cases=(\d+)\)", ln)
        if m:
            n = int(m.group(1))
    sk = rd(root, "SKILL.md")
    row = None
    for ln in (sk or "").splitlines():
        if ln.startswith("|") and "openbao-transit-trial.sh" in ln:
            row = ln
    reg_ok = False
    if row is not None:
        cells = [c.strip() for c in row.strip().strip("|").split("|")]
        reg_ok = any("--selftest" in c for c in cells[3:]) and \
            "none — its own five shims" not in row
    ok = r.returncode == 0 and n is not None and n >= 6 and reg_ok
    return (1 if ok else 0), (f"rc={r.returncode} cases={n} registry_ok={reg_ok}")


def i6(root):
    t = rd(root, "SCORECARD.md")
    if t is None:
        return 0, "SCORECARD.md missing"
    lines = t.splitlines()
    anchors = [i for i, ln in enumerate(lines) if "75165a07" in ln]
    if not anchors:
        return 0, "no line containing 75165a07 (anchor absent -> unresolved)"
    a = anchors[-1]
    h = derive_hash(root)
    if h is None:
        return 0, "c1-landed.txt measured=revision missing (unresolved)"
    hit = None
    for ln in lines[a + 1:]:
        if "c1-landed.txt" in ln:
            hit = ln
    if hit is None:
        return 0, f"no c1-landed.txt line after anchor {a+1}; derived={h}"
    m = re.search(r"measured=revision ([0-9a-f]{40})", hit)
    stated = m.group(1) if m else None
    return (1 if stated == h else 0), f"anchor line {a+1}; last correction stated={stated} derived={h}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--anchor", choices=("last", "first"), default="last")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    a.root = os.path.abspath(a.root)
    res = {}
    for k, fn in (("i1", i1), ("i2", i2), ("i3", i3), ("i4", None), ("i5", i5),
                  ("i6", i6), ("i7", i7)):
        if k == "i4":
            res[k] = i4(a.root, a.anchor)
        else:
            res[k] = fn(a.root)
    value = sum(1 for v, _ in res.values() if v == 0)
    if a.json:
        print(json.dumps({"value": value, "items": {k: v for k, (v, _) in res.items()},
                          "evidence": {k: d for k, (_, d) in res.items()}}, indent=1))
    else:
        for k, (v, d) in res.items():
            print(f"ref {k} {'HOLD' if v else 'FAIL'} {d}")
        print(f"REF_C1: value={value} population=7 " +
              " ".join(f"{k}={v}" for k, (v, _) in res.items()))
    return 0 if value == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
