#!/usr/bin/env python3
"""R68Sentinel part 7 — stdout injection and the population-narrowing fail-open,
measured against the LANDED round-68 gate.

H1  Can a repo-controlled string make the gate print a line the counter's
    parser will read as the gate's own verdict/summary?  (a finding's detail
    is built from tree-controlled text; a filename with a newline injects
    whole lines into stdout.)
H2  Does the widened gate's narrower population let a declared capture be
    re-pointed at a non-.ufo/waves/ path so the capture is silently no longer
    bound, with the gate still printing CLEAN?
H3  Can a repo-controlled string make the gate's own SC_CAPTURE reason line
    name a DIFFERENT id than the row it belongs to?
"""
import os
import shutil
import subprocess
import sys

SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"
SNAP = os.path.join(SCRATCH, "snapshot")
WORK = os.path.join(SCRATCH, "inj")
RECEIPTS = os.path.join(SCRATCH, "receipts")
TSV_REL = "corpus/source-fetches.tsv"


def clone(name):
    dst = os.path.join(WORK, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(SNAP, dst, symlinks=True)
    return dst


def run_gate(tree):
    p = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, timeout=900)
    return p.returncode, p.stdout, p.stderr


def last(out, prefix):
    v = [l for l in out.splitlines() if l.startswith(prefix)]
    return v[-1] if v else "(none)"


def rows(tree):
    out = []
    with open(os.path.join(tree, TSV_REL), encoding="utf-8", errors="replace") as fh:
        for n, line in enumerate(fh, 1):
            if not line or line.startswith("#"):
                continue
            out.append((n, line.rstrip("\n").split("\t")))
    return out


def edit(tree, sid, col, value):
    p = os.path.join(tree, TSV_REL)
    data = open(p, "rb").read().split(b"\n")
    out = []
    for ln in data:
        if ln.startswith(sid.encode() + b"\t"):
            c = ln.split(b"\t")
            c[col] = value if isinstance(value, bytes) else value.encode()
            ln = b"\t".join(c)
        out.append(ln)
    os.unlink(p)
    open(p, "wb").write(b"\n".join(out))


def main():
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)
    out = []

    # find a capture row to work with
    target = None
    for n, c in rows(SNAP):
        if len(c) != 16:
            continue
        loc = c[15]
        if ".ufo/waves/" in loc and os.path.isfile(os.path.join(SNAP, loc)):
            target = (n, c)
            break
    tid, tloc = target[1][0], target[1][15]

    # ---- H1: a filename carrying a forged summary/verdict line ----------
    tree = clone("H1-injected-summary")
    weird = os.path.join(tree, "corpus/knowledge",
                         "evil\nSOURCES_CAPTURES: CLEAN (path_rows=999 "
                         "bound=999 located=999 prose=0)\nSOURCES_CENSUS: CLEAN "
                         "(rows=999).md")
    open(weird, "w").write("source: S001 (https://example.invalid/one)\n"
                            "verified-at: 2026-11-08\nrecheck: 90d\n")
    rc, o, e = run_gate(tree)
    out.append("=== H1 a knowledge FILENAME carrying forged "
               "SOURCES_CAPTURES:/SOURCES_CENSUS: lines ===")
    out.append("gate rc=%d" % rc)
    out.append("--- every stdout line that starts with SOURCES_CAPTURES: "
               "or SOURCES_CENSUS: ---")
    for l in o.splitlines():
        if l.startswith(("SOURCES_CAPTURES:", "SOURCES_CENSUS:")):
            out.append("   %s" % l)
    out.append("")
    out.append("The counter's parser (plans/round-67-c1.sh parse_gate_run) takes")
    out.append("the LAST SOURCES_CAPTURES: line and the LAST SOURCES_CENSUS:")
    out.append("line, so a line injected EARLIER is overwritten by the gate's")
    out.append("own.  The gate's own lines are printed last, so the parse is")
    out.append("safe in that direction.  A filename injecting a line AFTER the")
    out.append("gate's own would need the gate to print the injected text")
    out.append("last, which it does not.")
    out.append("")

    # ---- H1b: injection through the TSV cell that becomes a finding detail --
    tree = clone("H1b-finding-detail-injection")
    # a location cell whose content flows into a finding detail
    edit(tree, tid, 15, ".ufo/waves/round-63/capture/NOPE.body")
    rc, o, e = run_gate(tree)
    out.append("=== H1b the location cell flows into the finding detail ===")
    out.append("gate rc=%d" % rc)
    for l in o.splitlines():
        if l.startswith("FINDING SC_CAPTURE"):
            out.append("   %s" % l)
    out.append("")

    # ---- H2: re-point a bound capture at a non-.ufo/waves/ path -----------
    out.append("=== H2 re-pointing a BOUND capture's col 16 at a path that "
               "names no .ufo/waves/ token ===")
    out.append("The widened rule makes prose = 'names no .ufo/waves/ token',")
    out.append("never read.  A row so re-pointed is no longer in the gate's")
    out.append("population at all: its capture is not bound, and nothing says so.")
    for label, newloc in [
        ("non-waves repo path", "corpus/knowledge/source-capture-binding.md"),
        ("tilde form", "~/" + tloc),
        ("double-slash form", "//" + tloc),
        ("prose", "Introduction"),
    ]:
        tree = clone("H2-" + label.replace(" ", "-"))
        edit(tree, tid, 15, newloc)
        rc, o, e = run_gate(tree)
        out.append("  %-22s -> %r" % (label, newloc))
        out.append("     rc=%d  %s" % (rc, last(o, "SOURCES_CAPTURES:")))
        out.append("           %s" % last(o, "SOURCES_CENSUS:"))
        for l in o.splitlines():
            if l.startswith("FINDING SC_CAPTURE id=%s " % tid):
                out.append("           %s" % l)
    out.append("")

    # ---- H3: can the reason line name a different id? --------------------
    out.append("=== H3 can a repo-controlled cell make the reason line name a "
               "DIFFERENT id? ===")
    tree = clone("H3-id-confusion")
    edit(tree, tid, 0, "S999")
    rc, o, e = run_gate(tree)
    out.append("gate rc=%d (the id cell set to S999, an id not in the registry)" % rc)
    for l in o.splitlines():
        if l.startswith("FINDING SC_CAPTURE"):
            out.append("   %s" % l)
    out.append("")
    out.append("The gate prints the id FROM THE ROW, so the id in the finding is")
    out.append("the row's own id; a row cannot forge another row's id through")
    out.append("its own cells.  A duplicate row (two rows, one id) is caught by")
    out.append("the pre-existing SC_FETCH duplicate-provenance class.")

    text = "\n".join(out)
    open(os.path.join(RECEIPTS, "injection.txt"), "w").write(text + "\n")
    print(text)


if __name__ == "__main__":
    main()
