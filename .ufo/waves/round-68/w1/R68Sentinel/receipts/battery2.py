#!/usr/bin/env python3
"""R68Sentinel part 6 — the SAME battery, run against the LANDED round-68 gate.

The widened gate landed in the lane worktree during this seat.  This re-runs
the fail-open constructions against those exact bytes, so the report measures
the shipped instrument and not a model of it.

The tree under test is a private snapshot of the lane worktree (copied, never
mutated in place); the gate is the lane's own corpus/sources-census.sh.
"""
import hashlib
import os
import shutil
import subprocess
import sys

SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
SNAP = os.path.join(SCRATCH, "snapshot")
WORK = os.path.join(SCRATCH, "landed-cases")
RECEIPTS = os.path.join(SCRATCH, "receipts")
TSV_REL = "corpus/source-fetches.tsv"
WAVES = ".ufo/waves/"

ANCHOR = None


def sha256_file(p):
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for c in iter(lambda: fh.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def snapshot():
    """Copy the lane's current worktree state into a private snapshot."""
    if os.path.exists(SNAP):
        shutil.rmtree(SNAP)
    os.makedirs(SNAP)
    shutil.copytree(os.path.join(LANE, "corpus"), os.path.join(SNAP, "corpus"),
                    symlinks=True,
                    ignore=shutil.ignore_patterns("__pycache__"))
    # every capture body a row names
    for n, cells in read_rows(os.path.join(SNAP, TSV_REL)):
        if len(cells) != 16:
            continue
        for tok in cells[15].split():
            if WAVES not in tok:
                continue
            src = os.path.join(LANE, tok)
            dst = os.path.join(SNAP, tok)
            if os.path.isfile(src):
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                if not os.path.exists(dst):
                    shutil.copy2(src, dst)
    return SNAP


def read_rows(tsv):
    out = []
    with open(tsv, encoding="utf-8", errors="replace") as fh:
        for n, line in enumerate(fh, 1):
            if not line or line.startswith("#"):
                continue
            out.append((n, line.rstrip("\n").split("\t")))
    return out


def clone(name):
    dst = os.path.join(WORK, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(SNAP, dst, symlinks=True)
    return dst


def read_tsv(tree):
    return open(os.path.join(tree, TSV_REL), "rb").read()


def write_tsv(tree, data):
    p = os.path.join(tree, TSV_REL)
    os.unlink(p)
    open(p, "wb").write(data)


def edit(tree, sid, col, value):
    data = read_tsv(tree).split(b"\n")
    out = []
    for ln in data:
        if ln.startswith(sid.encode() + b"\t"):
            c = ln.split(b"\t")
            c[col] = value if isinstance(value, bytes) else value.encode()
            ln = b"\t".join(c)
        out.append(ln)
    write_tsv(tree, b"\n".join(out))


def run_gate(tree):
    p = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, timeout=900)
    return p.returncode, p.stdout, p.stderr


def last(out, prefix):
    v = [l for l in out.splitlines() if l.startswith(prefix)]
    return v[-1] if v else "(none)"


def anchor_of(tree):
    """The LAST capture-path-shaped row in file order that binds its declared
    bytes (the plan's anchor derivation)."""
    root = os.path.realpath(tree)
    for n, c in reversed(read_rows(os.path.join(tree, TSV_REL))):
        if len(c) != 16:
            continue
        loc = c[15]
        if "/" not in loc or loc.startswith("/"):
            continue
        import re
        if not re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", loc):
            continue
        full = os.path.join(tree, loc)
        if not os.path.isfile(full):
            continue
        real = os.path.realpath(full)
        if not (real == root or real.startswith(root + os.sep)):
            continue
        if sha256_file(full) != c[9].strip():
            continue
        if str(os.path.getsize(full)) != c[10].strip():
            continue
        return n, c
    return None, None


def main():
    global ANCHOR
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)
    snapshot()
    n, a = anchor_of(SNAP)
    ANCHOR = a
    aid, aloc = a[0], a[15]
    out = []
    out.append("snapshot gate sha256: %s"
               % sha256_file(os.path.join(SNAP, "corpus/sources-census.sh")))
    out.append("snapshot TSV  sha256: %s"
               % sha256_file(os.path.join(SNAP, TSV_REL)))
    out.append("anchor: line %d id=%s col16=%s" % (n, aid, aloc))
    rc, o, e = run_gate(SNAP)
    out.append("control gate rc=%d %s" % (rc, last(o, "SOURCES_CAPTURES:")))
    out.append("control gate rc=%d %s" % (rc, last(o, "SOURCES_CENSUS:")))
    out.append("")

    # ---------------- the constructions ----------------
    outside = os.path.join(SCRATCH, "outside")
    os.makedirs(outside, exist_ok=True)

    def m_symlink_chain(t):
        d = os.path.join(t, os.path.dirname(aloc))
        dst = os.path.join(outside, "S.body")
        shutil.copy2(os.path.join(t, aloc), dst)
        for nm, tgt in (("hop2", "hop"), ("hop", os.path.relpath(dst, d))):
            p = os.path.join(d, nm)
            if os.path.lexists(p):
                os.unlink(p)
            os.symlink(tgt, p)
        p = os.path.join(t, aloc)
        if os.path.lexists(p):
            os.unlink(p)
        os.symlink("hop2", p)
        return "symlink chain out of tree"

    def m_hardlink(t):
        dst = os.path.join(outside, "S-hard.body")
        if os.path.exists(dst):
            os.unlink(dst)
        os.link(os.path.join(t, aloc), dst)
        p = os.path.join(t, ".ufo/waves/round-67/capture/S-hard.body")
        if os.path.lexists(p):
            os.unlink(p)
        os.link(dst, p)
        edit(t, aid, 15, ".ufo/waves/round-67/capture/S-hard.body")
        return "in-tree hardlink to an out-of-tree body (same bytes)"

    def m_directory(t):
        p = os.path.join(t, aloc)
        if os.path.exists(p):
            os.unlink(p)
        os.makedirs(p, exist_ok=True)
        return "capture path is a DIRECTORY"

    def m_nul_col16(t):
        edit(t, aid, 15, aloc.encode() + b"\x00")
        return "col16 = path + NUL"

    def m_nul_tsv(t):
        data = read_tsv(t).split(b"\n")
        for i, ln in enumerate(data):
            if ln.startswith(aid.encode() + b"\t"):
                data[i] = ln + b"\x00"
                break
        write_tsv(t, b"\n".join(data))
        return "NUL byte in the TSV"

    def m_cr_quote(t):
        data = read_tsv(t).split(b"\n")
        for i, ln in enumerate(data):
            if ln.startswith(aid.encode() + b"\t"):
                c = ln.split(b"\t")
                c[12] = c[12] + b"\r"
                data[i] = b"\t".join(c)
                break
        write_tsv(t, b"\n".join(data))
        return "CR inside col 13 only"

    def m_col15_dash(t):
        edit(t, aid, 14, "-")
        return "col15 = '-' under rendered-text-v1"

    def m_id_emptied(t):
        edit(t, aid, 0, "")
        return "id cell emptied"

    def m_id_shifted(t):
        data = read_tsv(t).split(b"\n")
        for i, ln in enumerate(data):
            if ln.startswith(aid.encode() + b"\t"):
                data[i] = b"\t" + ln
                break
        write_tsv(t, b"\n".join(data))
        return "an extra tab before the id (17 fields)"

    def m_dup(t):
        data = read_tsv(t).split(b"\n")
        out = []
        for ln in data:
            out.append(ln)
            if ln.startswith(aid.encode() + b"\t"):
                out.append(ln)
        write_tsv(t, b"\n".join(out))
        return "duplicate row"

    def m_m1(t):
        edit(t, aid, 15, aloc + " ")
        return "M1 col16 + one space"

    def m_m2(t):
        edit(t, aid, 15, aloc + "," + aloc)
        return "M2 col16 comma-joined duplicate"

    def m_m3(t):
        write_tsv(t, read_tsv(t).replace(b"\n", b"\r\n"))
        return "M3 whole TSV rewritten CRLF"

    def m_m4(t):
        sha = a[9]
        edit(t, aid, 9, ("0" if sha[0] != "0" else "1") + sha[1:])
        return "M4 one hex digit of col 10 replaced"

    def m_m5(t):
        edit(t, aid, 14, "a" * 64)
        return "M5 col15 replaced with another 64-hex digest"

    def m_m6(t):
        p = os.path.join(t, aloc)
        data = open(p, "rb").read()
        os.unlink(p)
        open(p, "wb").write(data + b"\n")
        return "M6 capture body + 1 byte"

    def m_mixed(t):
        edit(t, aid, 15, "§1.2 Concept Overview; capture " + aloc)
        return "col16 = mixed prose naming the path"

    def m_tilde(t):
        edit(t, aid, 15, "~/" + aloc)
        return "col16 = ~/<path>"

    def m_dslash(t):
        edit(t, aid, 15, "//" + aloc)
        return "col16 = //<path>"

    def m_prose_no_waves(t):
        edit(t, aid, 15, "Introduction")
        return "col16 = prose naming no .ufo/waves/ token"

    def m_dotdot(t):
        edit(t, aid, 15, "../" + aloc)
        return "col16 = ../<path>"

    def m_repoint_corpus(t):
        edit(t, aid, 15, "corpus/knowledge/source-capture-binding.md")
        return "col16 = a non-.ufo/waves/ repo path"

    def m_repoint_sibling(t):
        edit(t, aid, 15, ".ufo/waves/round-63/capture/S135.body")
        return "col16 = a sibling .ufo/waves/ body"

    def m_norm_stub(t):
        p = os.path.join(t, "corpus/rendered-text-v1.py")
        os.unlink(p)
        open(p, "w").write('''#!/usr/bin/python3
import sys, os
if len(sys.argv) > 1 and sys.argv[1] == "locate":
    print("RENDERED_TEXT_V1_LOCATE: count=1"); sys.exit(0)
if len(sys.argv) > 1 and sys.argv[1] == "digest":
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tsv = os.path.join(root, "corpus", "source-fetches.tsv")
    rel = os.path.relpath(os.path.abspath(sys.argv[2]), root)
    val = "0" * 64
    try:
        for line in open(tsv, "rb"):
            if not line or line.startswith(b"#"):
                continue
            cells = line.rstrip(b"\\n").split(b"\\t")
            if len(cells) == 16 and cells[15].decode("utf-8","replace") == rel:
                val = cells[14].decode()
    except OSError:
        pass
    print("RENDERED_TEXT_V1: raw_sha256=%s bytes=0 normalized_sha256=%s normalized_bytes=0" % ("0"*64, val))
    sys.exit(0)
sys.exit(0)
''')
        return "normalizer stub: count=1 always; digest echoes the row's col 15"

    def m_norm_stub_garbage_quote(t):
        m_norm_stub(t)
        edit(t, aid, 12, "zzz absent phrase zzz")
        return "normalizer stub + a quote absent from the body"

    cases = [
        ("control-unmodified", None),
        ("symlink-chain-out-of-tree", m_symlink_chain),
        ("hardlink-out-of-tree", m_hardlink),
        ("directory-named-like-capture", m_directory),
        ("nul-byte-in-col16", m_nul_col16),
        ("nul-byte-in-tsv", m_nul_tsv),
        ("cr-inside-quote-column-only", m_cr_quote),
        ("col15-dash-under-rendered-text-v1", m_col15_dash),
        ("id-cell-emptied", m_id_emptied),
        ("id-cell-shifted", m_id_shifted),
        ("duplicate-row", m_dup),
        ("m1-col16-trailing-space", m_m1),
        ("m2-col16-comma-joined", m_m2),
        ("m3-whole-tsv-crlf", m_m3),
        ("m4-col10-hex-digit", m_m4),
        ("m5-col15-borrowed", m_m5),
        ("m6-body-extra-byte", m_m6),
        ("col16-mixed-prose-names-path", m_mixed),
        ("col16-tilde-form", m_tilde),
        ("col16-double-slash-form", m_dslash),
        ("col16-prose-no-waves-token", m_prose_no_waves),
        ("col16-dotdot-prefix", m_dotdot),
        ("repoint-to-non-waves-repo-path", m_repoint_corpus),
        ("repoint-to-sibling-waves-body", m_repoint_sibling),
        ("normalizer-selfconsistent-stub", m_norm_stub),
        ("normalizer-stub-plus-absent-quote", m_norm_stub_garbage_quote),
    ]

    rows = []
    for name, fn in cases:
        tree = clone(name)
        note = "unmodified"
        if fn:
            note = fn(tree)
        rc, o, e = run_gate(tree)
        findings = [l for l in o.splitlines()
                    if l.startswith("FINDING SC_CAPTURE id=%s " % aid)
                    or l.startswith("FINDING SC_FETCH")]
        out.append("--- %s ---  %s" % (name, note))
        out.append("   rc=%d  %s" % (rc, last(o, "SOURCES_CAPTURES:")))
        out.append("         %s" % last(o, "SOURCES_CENSUS:"))
        for l in findings:
            out.append("         %s" % l)
        rows.append([name, note, str(rc), last(o, "SOURCES_CAPTURES:"),
                     last(o, "SOURCES_CENSUS:"), ";".join(findings)])

    text = "\n".join(out)
    open(os.path.join(RECEIPTS, "landed-gate-battery.txt"), "w").write(text + "\n")
    hdr = ["case", "construction", "rc", "captures_line", "verdict_line", "findings"]
    with open(os.path.join(RECEIPTS, "landed-gate-battery.tsv"), "w") as fh:
        fh.write("\t".join(hdr) + "\n")
        for r in rows:
            fh.write("\t".join(x.replace("\t", " ") for x in r) + "\n")
    print(text)


if __name__ == "__main__":
    main()
