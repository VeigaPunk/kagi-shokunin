#!/usr/bin/env python3
"""Proposed controls for the survivors of the wave-1 mutant sweep.

Each proposal is predeclared here (tree edits + expected pristine reading) BEFORE
any proposal is run, then executed against the pristine frozen counter and the
mutant counter. A proposal scores only if the pristine reading equals the
predeclared expectation and the mutant reading differs from it.

Uniform isolation device: every proposal tree replaces corpus/sources-census.sh
with a printer (CLEAN/PASS), except P-C2-13 which needs a non-CLEAN printer, so
the proposal tests the counter's independent conjunct rather than the census.
The real census's verdict on the edited tree is recorded first, for evidence.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys

S = "/fast/scratch/hyaku/kagi-r55/R55MutCounters"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
BASE = "ebe095857a734caf5efdd7bd776feb22b4e23972"
PROP = os.path.join(S, "prop")
REF = os.path.join(PROP, "ref")
TIMEOUT = 600


def sh(cmd, **kw):
    return subprocess.run(cmd, text=True, capture_output=True, timeout=TIMEOUT, **kw)


def build_ref():
    if os.path.isdir(os.path.join(REF, "corpus")):
        return
    os.makedirs(REF, exist_ok=True)
    p1 = subprocess.Popen(["git", "-C", os.path.join(S, "repo"), "archive",
                           "348aa3b8ea7298aeb2f4d69db321fe827a92ae4f"],
                          stdout=subprocess.PIPE)
    p2 = subprocess.Popen(["tar", "-x", "-C", REF], stdin=p1.stdout)
    p1.stdout.close()
    assert p2.wait() == 0 and p1.wait() == 0, "ref tree build failed"


def min_repo(d, mutant=None):
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(os.path.join(d, "plans"))
    assert sh(["git", "-C", d, "init", "-q"]).returncode == 0
    with open(os.path.join(d, ".git", "objects", "info", "alternates"), "w") as fh:
        fh.write(os.path.join(LANE, ".git", "objects") + "\n")
    for f in ("round-55-c1.sh", "round-55-c2.sh"):
        shutil.copy(os.path.join(S, "frozen", f), os.path.join(d, "plans", f))
    assert sh(["git", "-C", d, "cat-file", "-e", BASE + "^{commit}"]).returncode == 0
    if mutant:
        r = sh([sys.executable, "-I", "-B", os.path.join(S, "tools", "mutants.py"),
                "apply", d, mutant])
        assert r.returncode == 0, r.stderr
    return d


def sub(path, old, new, count=1):
    s = open(path, encoding="utf-8").read()
    assert s.count(old) == count, (path, old[:60], s.count(old))
    open(path, "w", encoding="utf-8").write(s.replace(old, new, count))


def sub_line(path, prefix, old, new):
    lines = open(path, encoding="utf-8").read().split("\n")
    hit = 0
    for i, l in enumerate(lines):
        if l.startswith(prefix):
            assert old in l, (prefix, old[:50])
            lines[i] = l.replace(old, new, 1)
            hit += 1
    assert hit == 1, (path, prefix, hit)
    open(path, "w", encoding="utf-8").write("\n".join(lines))


def printer(tree, mode="clean"):
    p = os.path.join(tree, "corpus", "sources-census.sh")
    if mode == "clean":
        body = ('#!/usr/bin/env bash\ncase "${1:-}" in --selftest) '
                'echo "SOURCES_CENSUS_SELFTEST: PASS (probe)";; '
                '*) echo "SOURCES_CENSUS: CLEAN (probe)";; esac\n')
    elif mode == "selftest-fail":
        body = ('#!/usr/bin/env bash\ncase "${1:-}" in --selftest) '
                'echo "SOURCES_CENSUS_SELFTEST: FAIL (probe)"; exit 1;; '
                '*) echo "SOURCES_CENSUS: CLEAN (probe)";; esac\n')
    elif mode == "selftest-badline":
        body = ('#!/usr/bin/env bash\ncase "${1:-}" in --selftest) '
                'echo "SOURCES_CENSUS_SELFTEST: NOT-PASS (probe)"; exit 0;; '
                '*) echo "SOURCES_CENSUS: CLEAN (probe)";; esac\n')
    elif mode == "dirty":
        body = '#!/usr/bin/env bash\necho "SOURCES_CENSUS: DIRTY (probe)"\n'
    else:
        raise AssertionError(mode)
    open(p, "w", encoding="utf-8").write(body)


def real_census_verdict(tree):
    p = os.path.join(tree, "corpus", "sources-census.sh")
    r = sh(["bash", "corpus/sources-census.sh"], cwd=tree)
    return (r.stdout.strip().split("\n")[-1] if r.stdout.strip() else "<empty>"), r.returncode


def run_counter(repo, tree):
    r = sh(["bash", os.path.join(repo, "plans", "round-55-c1.sh" if COUNTER[0] == "c1"
                                else "round-55-c2.sh"), "--tree", tree],
           env={**os.environ, "HYAKU_SCRATCH": S})
    line = r.stdout.strip().split("\n")[0] if r.stdout.strip() else "<empty>"
    val = line.split("value=")[1].split(" ")[0] if "value=" in line else "<none>"
    return line, val, r.returncode


COUNTER = ["c1"]


# ---------------- tree edits ----------------
def e_c1_02(t):
    f = os.path.join(t, "corpus", "knowledge", "adjacency-breadth.md")
    os.rename(f, os.path.join(t, "moved-ab.md"))
    os.symlink("../../moved-ab.md", f)


def e_c1_03(t):
    p = os.path.join(t, "corpus", "SOURCES.md")
    lines = open(p, encoding="utf-8").read().split("\n")
    i = next(i for i, l in enumerate(lines) if l.startswith("| S005 |"))
    lines.insert(i + 1, lines[i])
    open(p, "w", encoding="utf-8").write("\n".join(lines))


def e_c1_04(t):
    p = os.path.join(t, "corpus", "SOURCES.md")
    lines = open(p, encoding="utf-8").read().split("\n")
    i = next(i for i, l in enumerate(lines) if l.startswith("| S005 |"))
    del lines[i]
    open(p, "w", encoding="utf-8").write("\n".join(lines))


def e_c1_11(t):
    sub(os.path.join(t, "corpus", "SOURCES.md"),
        "| corpus/lessons/round-54.md, corpus/knowledge/op-ref-consumption.md |",
        "| corpus/knowledge/zz-symlink.md |")
    os.symlink("op-ref-consumption.md",
               os.path.join(t, "corpus", "knowledge", "zz-symlink.md"))


def e_c2_01(t):
    sub_line(os.path.join(t, "corpus", "SOURCES.md"), "| S114 |",
             "corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md",
             "corpus/lessons/round-55.md")


def e_c2_02(t):
    p = os.path.join(t, "corpus", "SOURCES.md")
    lines = open(p, encoding="utf-8").read().split("\n")
    i = next(i for i, l in enumerate(lines) if l.startswith("| S114 |"))
    c = lines[i].split("|")
    assert c[4].strip() == "A", c[4]
    c[4] = " B "
    lines[i] = "|".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(lines))


def e_c2_04(t):
    p = os.path.join(t, "corpus", "source-fetches.tsv")
    lines = open(p, encoding="utf-8").read().split("\n")
    i = next(i for i, l in enumerate(lines) if l.startswith("S114\t"))
    c = lines[i].split("\t")
    c[9] = "0" * 64
    lines[i] = "\t".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(lines))


def e_c2_05(t):
    p = os.path.join(t, "corpus", "quote-bodies.tsv")
    lines = open(p, encoding="utf-8").read().split("\n")
    i = next(i for i, l in enumerate(lines) if l.startswith("S114\t"))
    c = lines[i].split("\t")
    assert c[2] == "541", c[2]
    c[2] = "540"
    lines[i] = "\t".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(lines))


def e_c2_11(t):
    sub(os.path.join(t, "corpus", "knowledge", "iso-11770-3-edition-status.md"),
        "'https://www.iso.org/standard/82709.html' | grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025'` -> 3",
        "'https://releases.1password.com/developers/cli/index.xml' | grep -c '<title>1Password CLI 2.42.0</title>'` -> 1")


def e_c2_14(t):
    with open(os.path.join(t, ".ufo", "waves", "round-55", "capture", "S113.body"), "ab") as fh:
        fh.write(b"x")


def e_c2_15(t):
    p = os.path.join(t, "corpus", "knowledge", "iso-11770-3-edition-status.md")
    s = open(p, encoding="utf-8").read()
    assert s.endswith("\n")
    open(p, "w", encoding="utf-8").write(s + "recheck: 180d — duplicate probe line\n")


def e_c2_16(t):
    cap = os.path.join(t, ".ufo", "waves", "round-45", "controls", "capture-r45", "S101.raw")
    with open(cap, "ab") as fh:
        fh.write(b"x")
    new = hashlib.sha256(open(cap, "rb").read()).hexdigest()
    p = os.path.join(t, "corpus", "source-fetches.tsv")
    lines = open(p, encoding="utf-8").read().split("\n")
    i = next(i for i, l in enumerate(lines) if l.startswith("S101\t"))
    c = lines[i].split("\t")
    c[9] = new
    lines[i] = "\t".join(c)
    open(p, "w", encoding="utf-8").write("\n".join(lines))


PROPOSALS = [
    # id, counter, mutant, edit, census mode, predeclared pristine value
    ("P-C1-02-g2-off", "c1", "C1-02-g2-off", e_c1_02, "clean", "FAIL"),
    ("P-C1-03-g3-dup-off", "c1", "C1-03-g3-dup-off", e_c1_03, "clean", "FAIL"),
    ("P-C1-04-g3-rows-off", "c1", "C1-04-g3-rows-off", e_c1_04, "clean", "FAIL"),
    ("P-C1-10-g5-selftest-off", "c1", "C1-10-g5-selftest-off", None, "selftest-badline", "FAIL"),
    ("P-C1-11-g4-islink-off", "c1", "C1-11-g4-islink-off", e_c1_11, "clean", "FAIL"),
    ("P-C1-12-entries-islink-off", "c1", "C1-12-entries-islink-off", e_c1_02, "clean", "FAIL"),
    ("P-C2-01-a-ub-off", "c2", "C2-01-a-ub-off", e_c2_01, "clean", "1"),
    ("P-C2-02-a-tier-off", "c2", "C2-02-a-tier-off", e_c2_02, "clean", "1"),
    ("P-C2-04-b-sha-off", "c2", "C2-04-b-sha-off", e_c2_04, "clean", "1"),
    ("P-C2-05-c-offset-off", "c2", "C2-05-c-offset-off", e_c2_05, "clean", "1"),
    ("P-C2-11-srcids-off", "c2", "C2-11-srcids-off", e_c2_11, "clean", "1"),
    ("P-C2-13-guard-census-off", "c2", "C2-13-guard-census-off", None, "dirty", "FAIL"),
    ("P-C2-14-recheck-capture-sha-off", "c2", "C2-14-recheck-capture-sha-off", e_c2_14, "clean", "1"),
    ("P-C2-15-recheck-lines-off", "c2", "C2-15-recheck-lines-off", e_c2_15, "clean", "1"),
    ("P-C2-16-guard-s101sha-off", "c2", "C2-16-guard-s101sha-off", e_c2_16, "clean", "FAIL"),
]


def main():
    build_ref()
    os.makedirs(os.path.join(PROP, "trees"), exist_ok=True)
    repoP = min_repo(os.path.join(PROP, "repoP"))
    out = []
    for pid, counter, mutant, edit, census_mode, expect in PROPOSALS:
        COUNTER[0] = counter
        tree = os.path.join(PROP, "trees", pid)
        shutil.rmtree(tree, ignore_errors=True)
        sh(["cp", "-a", REF, tree])
        assert sh(["test", "-d", os.path.join(tree, "corpus")]).returncode == 0
        if edit:
            edit(tree)
        census_last, census_rc = real_census_verdict(tree)
        printer(tree, census_mode)
        repoM = min_repo(os.path.join(PROP, "repoM", pid), mutant)
        line_p, val_p, rc_p = run_counter(repoP, tree)
        line_m, val_m, rc_m = run_counter(repoM, tree)
        restore = hashlib.sha256(open(os.path.join(S, "frozen", "round-55-c1.sh" if counter == "c1" else "round-55-c2.sh"), "rb").read()).hexdigest()
        rec = {"proposal": pid, "counter": counter, "mutant": mutant,
               "census_mode": census_mode, "real_census_last_line": census_last,
               "real_census_exit": census_rc,
               "expected_pristine": expect, "pristine_value": val_p,
               "mutant_value": val_m, "pristine_line": line_p, "mutant_line": line_m,
               "pristine_exit": rc_p, "mutant_exit": rc_m,
               "kills": val_p == expect and val_m != expect,
               "frozen_sha_after": restore}
        out.append(rec)
        print(json.dumps(rec))
        shutil.rmtree(tree, ignore_errors=True)
        shutil.rmtree(repoM, ignore_errors=True)
    json.dump(out, open(os.path.join(S, "receipts", "03-proposals.json"), "w"), indent=1)
    k = sum(1 for r in out if r["kills"])
    print(f"PROPOSALS total={len(out)} kill={k} fail={len(out)-k}")


if __name__ == "__main__":
    main()
