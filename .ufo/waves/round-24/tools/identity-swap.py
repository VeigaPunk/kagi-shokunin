#!/usr/bin/env python3
"""identity-swap.py -- round-24 C3 counting instrument (calibration).

Question: does the claim ledger notice a COUNT-PRESERVING identity swap on the
surface each count-only row claims to describe?

Population (frozen in plans/round-24.md): R11-10 R11-11 R12-03 R13-01 R13-02
R15-04 R16-04 R16-05 R16-06 R17-02 R17-03 R18-02 R21-04 R22-03 R22-04.

Method, per population row, in a fresh scratch clone of the lane at REV
(optionally overlaid with listed working-tree files from SRC):
  1. apply ONE mutant that changes membership but keeps the row's count;
  2. if the mutated file is pinned in corpus/stamps.tsv, re-pin its row
     (sha256/LF/bytes) so stamp drift is NOT what catches the swap;
  3. evaluate, with the clone's own `claim-ledger.sh verify` over a subset
     claims file: the population row, every non-host row whose command names
     the mutated file, and every R24-* row (identity rows; none exist at BASE);
  4. KILLED if any evaluated row prints FAIL/POLICY, else SURVIVES.
A control run (no mutant, same subset) must show 0 failing rows, otherwise
the row is reported INVALID-CONTROL and counted neither way.
Host rows ([substrate]/[host] tags and the 12 QM12 ids) are never evaluated;
HOME is an empty scratch dir.

Usage: identity-swap.py LABEL REV [SRC FILE...]
Last line: IDENTITY_SWAP: label=<L> rev=<12hex> population=15 survived=<n> killed=<n> invalid=<n>
"""
import os
import re
import shutil
import subprocess
import sys
import hashlib

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
HOST12 = {"R11-01", "R11-02", "R11-03", "R11-04", "R11-06", "R12-01", "R13-03",
          "R15-01", "R16-01", "R16-03", "R17-01", "R18-01"}


def sh(args, cwd=None, env=None, check=True):
    return subprocess.run(args, cwd=cwd, env=env, check=check, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def read(p):
    with open(p, encoding="utf-8") as fh:
        return fh.read()


def write(p, s):
    with open(p, "w", encoding="utf-8") as fh:
        fh.write(s)


def restamp(tree, rel):
    sp = os.path.join(tree, "corpus/stamps.tsv")
    rows = read(sp).splitlines(keepends=True)
    data = open(os.path.join(tree, rel), "rb").read()
    new = "%s\t%s\t%d\t%d\n" % (rel, hashlib.sha256(data).hexdigest(), data.count(b"\n"), len(data))
    out, hit = [], False
    for r in rows:
        if r.split("\t", 1)[0] == rel:
            out.append(new); hit = True
        else:
            out.append(r)
    if hit:
        write(sp, "".join(out))
    return hit


def sub_once(tree, rel, pat, rep, flags=re.M):
    p = os.path.join(tree, rel)
    s = read(p)
    s2, n = re.subn(pat, rep, s, count=1, flags=flags)
    if n != 1:
        raise RuntimeError("mutant pattern not found in %s: %s" % (rel, pat))
    write(p, s2)
    restamp(tree, rel)


# --- mutants: (row, file named by evaluation, function) ---------------------
def m_blank_last_row(rel):
    def f(tree):
        p = os.path.join(tree, rel)
        lines = read(p).split("\n")
        # the FIRST data row: a final unterminated row would not leave a
        # counted blank line behind (surface-census.tsv has no final LF)
        idx = min(i for i, l in enumerate(lines) if l and not l.startswith("#"))
        del lines[idx]
        lines.insert(idx, "")  # a blank line keeps `grep -cv '^#'`
        write(p, "\n".join(lines))
        restamp(tree, rel)
    return f


def m_stamps_swap(tree):
    # replace the pin of one stamped lesson with an unstamped tracked file
    sp = os.path.join(tree, "corpus/stamps.tsv")
    pinned = {r.split("\t", 1)[0] for r in read(sp).splitlines() if r and not r.startswith("#")}
    victim = "corpus/lessons/round-10.md"
    assert victim in pinned, victim
    files = sh(["git", "ls-files", "plans"], cwd=tree).stdout.split()
    cand = next(x for x in sorted(files) if x not in pinned)
    data = open(os.path.join(tree, cand), "rb").read()
    rows = [r for r in read(sp).splitlines() if r.split("\t", 1)[0] != victim]
    rows.append("%s\t%s\t%d\t%d" % (cand, hashlib.sha256(data).hexdigest(), data.count(b"\n"), len(data)))
    write(sp, "\n".join(sorted(rows)) + "\n")


def m_added_swap(tree):
    # swap one revision-audit ADDED path for another post-history tracked file
    sp = os.path.join(tree, "corpus/stamps.tsv")
    pinned = {r.split("\t", 1)[0] for r in read(sp).splitlines() if r and not r.startswith("#")}
    victim = "corpus/lessons/round-22-source-errata.md"
    assert victim in pinned, victim
    cand = "plans/round-23.md"
    assert cand not in pinned
    data = open(os.path.join(tree, cand), "rb").read()
    rows = [r for r in read(sp).splitlines() if r.split("\t", 1)[0] != victim]
    rows.append("%s\t%s\t%d\t%d" % (cand, hashlib.sha256(data).hexdigest(), data.count(b"\n"), len(data)))
    write(sp, "\n".join(sorted(rows)) + "\n")


def m_substrate_move(tree):
    rel = "corpus/claim-ledger.tsv"
    p = os.path.join(tree, rel)
    out = []
    for l in read(p).split("\n"):
        if l.startswith("R11-01\t"):
            l = l.replace("[substrate]", "[sub-strate]", 1)
        elif l.startswith("R11-05\t"):
            l = l + " [substrate]"
        out.append(l)
    write(p, "\n".join(out))
    restamp(tree, rel)


MUTANTS = [
    ("R11-10", "corpus/state-shape.tsv", m_blank_last_row("corpus/state-shape.tsv")),
    ("R11-11", "corpus/surface-census.tsv", m_blank_last_row("corpus/surface-census.tsv")),
    ("R12-03", "corpus/stamps.tsv", m_stamps_swap),
    ("R13-01", "SCORECARD.md", lambda t: sub_once(t, "SCORECARD.md", r"^## Round 9 — pre-move", "## Round 90 — pre-move")),
    ("R13-02", "corpus/claim-ledger.tsv", lambda t: sub_once(t, "corpus/claim-ledger.tsv", r"^R17-03\t", "R19-03\t")),
    ("R15-04", "corpus/checklist.tsv", lambda t: sub_once(t, "corpus/checklist.tsv", r"^E1\t", "E91\t")),
    ("R16-04", "corpus/adjacency.tsv", lambda t: sub_once(t, "corpus/adjacency.tsv", r"^(# own[ \t]+.HOME/)", r"\1zz-")),
    ("R16-05", "corpus/adjacency.tsv", lambda t: sub_once(t, "corpus/adjacency.tsv", r"^([^#\s])", r"zz-\1")),
    ("R16-06", "corpus/adjacency.tsv", lambda t: sub_once(t, "corpus/adjacency.tsv", r"^(# no-enumerate[ \t]+.HOME/)", r"\1zz-")),
    ("R17-02", "corpus/adjacency.tsv", lambda t: sub_once(t, "corpus/adjacency.tsv", r"^(# breadth[ \t]+.HOME/)", r"\1zz-")),
    ("R17-03", "corpus/adjacency.tsv", lambda t: sub_once(t, "corpus/adjacency.tsv", r"^((?:# no-enumerate[^\n]*\n)(?:[^\n]*\n)*?# no-enumerate[ \t]+.HOME/)", r"\1yy-")),
    ("R18-02", "corpus/claim-ledger.tsv", m_substrate_move),
    ("R21-04", "corpus/claim-ledger.tsv", lambda t: sub_once(t, "corpus/claim-ledger.tsv", r"^R22-02\t", "R22-09\t")),
    ("R22-03", "corpus/stamps.tsv", m_added_swap),
    ("R22-04", "corpus/revision-audit.py", lambda t: sub_once(t, "corpus/revision-audit.py", r"gitignore-valid", "gitignore-valid-x")),
]


def ledger_rows(tree):
    rows = []
    for l in read(os.path.join(tree, "corpus/claim-ledger.tsv")).split("\n"):
        if not l or l.startswith("#"):
            continue
        f = l.split("\t")
        rows.append((f[0], f[1] if len(f) > 1 else "", f[5] if len(f) > 5 else "", l))
    return rows


def is_host(rid, note):
    return rid in HOST12 or "[substrate]" in note or "[host]" in note


def subset(tree, prow, rel):
    keep = []
    for rid, cmd, note, line in ledger_rows(tree):
        if is_host(rid, note) or "claim-ledger.sh" in cmd:
            continue
        if rid == prow or rid.startswith("R24-") or rel in cmd:
            keep.append(line)
    return keep


def evaluate(tree, lines, tag, base):
    cf = os.path.join(base, "claims-%s.tsv" % tag)
    write(cf, "\n".join(lines) + "\n")
    env = {"PATH": os.environ["PATH"], "HOME": os.path.join(base, "home"), "LANG": "C.UTF-8"}
    r = sh(["timeout", "-k", "5", "900", "bash", "corpus/claim-ledger.sh", "verify",
            "--claims", cf, "--stamps", "corpus/stamps.tsv"], cwd=tree, env=env, check=False)
    bad = sorted({m.group(1) for m in re.finditer(r"^(?:FAIL|POLICY) (\S+)", r.stdout, re.M)})
    return bad, [l.split("\t")[0] for l in lines]


def main(argv):
    label, rev = argv[0], argv[1]
    src = argv[2] if len(argv) > 2 else None
    over = argv[3:]
    base = "/fast/scratch/kagi-r24/identity/%s" % label
    shutil.rmtree(base, ignore_errors=True)
    os.makedirs(os.path.join(base, "home"))
    pristine = os.path.join(base, "pristine")
    sh(["git", "clone", "-q", "--no-hardlinks", LANE, pristine])
    sh(["git", "-c", "advice.detachedHead=false", "checkout", "-q", rev], cwd=pristine)
    for f in over:
        shutil.copy2(os.path.join(src, f), os.path.join(pristine, f))
    surv = kill = inval = 0
    for prow, rel, fn in MUTANTS:
        ctl = os.path.join(base, "ctl")
        shutil.rmtree(ctl, ignore_errors=True)
        shutil.copytree(pristine, ctl, symlinks=True)
        cbad, cids = evaluate(ctl, subset(ctl, prow, rel), prow + "-ctl", base)
        tree = os.path.join(base, "m-" + prow)
        shutil.rmtree(tree, ignore_errors=True)
        shutil.copytree(pristine, tree, symlinks=True)
        fn(tree)
        lines = subset(tree, prow, rel)
        bad, ids = evaluate(tree, lines, prow, base)
        # validity (wave-1 CritC3Metric): the population row itself must still
        # PASS on the mutant -- otherwise the mutant did not preserve the count
        # and proves nothing about identity. Killers are named row by row.
        pop_passes = prow in ids and prow not in bad
        if cbad:
            verdict = "INVALID-CONTROL"; inval += 1
        elif not pop_passes:
            verdict = "INVALID-MUTANT"; inval += 1
        elif bad:
            verdict = "KILLED"; kill += 1
        else:
            verdict = "SURVIVES"; surv += 1
        print("MUTANT %s file=%s evaluated=%s population_row_passes=%s killed_by=%s control_failing=%s verdict=%s"
              % (prow, rel, ",".join(ids), "yes" if pop_passes else "no", ",".join(bad) or "-",
                 ",".join(cbad) or "-", verdict))
        sys.stdout.flush()
    print("IDENTITY_SWAP: label=%s rev=%s population=%d survived=%d killed=%d invalid=%d"
          % (label, rev[:12], len(MUTANTS), surv, kill, inval))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
