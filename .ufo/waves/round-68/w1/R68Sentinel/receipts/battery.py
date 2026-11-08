#!/usr/bin/env python3
"""R68Sentinel battery — fail-open constructions against the census gate.

Runs each construction against:
  LANE   the landed gate in the lane tree (read-only copy of the tree)
  REF    the reference widened gate (plans/round-68.md §C1 reason set), in two
         classifier variants: `contains` and `prefix`

Every tree under test is a private copy under scratch. The lane is never
written. Receipts are written as TSV + verbatim stdout.
"""
import hashlib
import os
import re
import shutil
import subprocess
import sys

SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
PRISTINE = os.path.join(SCRATCH, "pristine")
CASEDIR = os.path.join(SCRATCH, "cases")
RECEIPTS = os.path.join(SCRATCH, "receipts")

S166_ID = "S166"
S166_LOC = ".ufo/waves/round-67/capture/S166.body"
S166_BODY = ".ufo/waves/round-67/capture/S166.body"


def sha256_file(p):
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for c in iter(lambda: fh.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def clone(name):
    """Fresh private copy of the pristine tree."""
    dst = os.path.join(CASEDIR, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(PRISTINE, dst, symlinks=True)
    return dst


def read_tsv(tree):
    with open(os.path.join(tree, "corpus/source-fetches.tsv"), "rb") as fh:
        return fh.read()


def write_tsv(tree, data):
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    os.unlink(p)  # break any hardlink; never write in place
    with open(p, "wb") as fh:
        fh.write(data)


def set_col16(tree, sid, newloc, extra=None):
    """Replace col 16 of the row whose id is sid. `extra` is a callable on the
    whole row list for extra edits."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    out = []
    hit = False
    for ln in lines:
        if ln.startswith(sid.encode() + b"\t"):
            cells = ln.split(b"\t")
            cells[15] = newloc.encode() if isinstance(newloc, str) else newloc
            ln = b"\t".join(cells)
            hit = True
        out.append(ln)
    if not hit:
        raise SystemExit("row %s not found" % sid)
    if extra:
        out = extra(out)
    write_tsv(tree, b"\n".join(out))


def row_cells(tree, sid):
    for ln in read_tsv(tree).split(b"\n"):
        if ln.startswith(sid.encode() + b"\t"):
            return ln.split(b"\t")
    return None


def run_gate(tree):
    p = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, timeout=600)
    return p.returncode, p.stdout, p.stderr


def run_ref(tree, variant):
    p = subprocess.run([sys.executable, os.path.join(SCRATCH, "refgate.py"),
                        "--tree", tree, "--variant", variant],
                       capture_output=True, text=True, timeout=600)
    return p.returncode, p.stdout


def verdict_lines(out):
    return [l for l in out.splitlines() if l.startswith("SOURCES_")]


def findings_for(out, sid):
    return [l for l in out.splitlines()
            if l.startswith("FINDING SC_CAPTURE id=%s " % sid)
            or l.startswith("FINDING SC_FETCH")]


# --------------------------------------------------------------------------
# the constructions
# --------------------------------------------------------------------------

def c_symlink_chain_out_of_tree(tree):
    """A .ufo/waves/ symlink chain to an out-of-tree body."""
    outside = os.path.join(SCRATCH, "outside")
    os.makedirs(outside, exist_ok=True)
    src = os.path.join(tree, S166_BODY)
    dst = os.path.join(outside, "S166.body")
    if os.path.exists(dst):
        os.unlink(dst)
    shutil.copy2(src, dst)
    d = os.path.join(tree, ".ufo/waves/round-67/capture")
    # hop2 -> hop -> outside
    for nm, target in (("hop2", "hop"), ("hop", os.path.relpath(dst, d))):
        p = os.path.join(d, nm)
        if os.path.lexists(p):
            os.unlink(p)
        os.symlink(target, p)
    p = os.path.join(d, "S166.body")
    if os.path.lexists(p):
        os.unlink(p)
    os.symlink("hop2", p)
    return "S166.body -> hop2 -> hop -> <scratch>/outside/S166.body (same bytes)"


def c_hardlink_out_of_tree(tree):
    """An in-tree hardlink to an out-of-tree body with the same bytes."""
    outside = os.path.join(SCRATCH, "outside")
    os.makedirs(outside, exist_ok=True)
    src = os.path.join(tree, S166_BODY)
    dst = os.path.join(outside, "S166-hard.body")
    if os.path.exists(dst):
        os.unlink(dst)
    os.link(src, dst)
    p = os.path.join(tree, ".ufo/waves/round-67/capture/S166-hard.body")
    if os.path.lexists(p):
        os.unlink(p)
    os.link(dst, p)
    set_col16(tree, S166_ID, ".ufo/waves/round-67/capture/S166-hard.body")
    return "S166-hard.body hardlinked to <scratch>/outside/S166-hard.body (nlink=2)"


def c_directory_named_like_capture(tree):
    """A directory whose name looks like a capture body."""
    p = os.path.join(tree, ".ufo/waves/round-67/capture/S166.body")
    if os.path.exists(p):
        os.unlink(p)
    os.makedirs(p, exist_ok=True)
    return "S166.body replaced by a DIRECTORY"


def c_trailing_nul_byte(tree):
    """A col-16 cell with a trailing NUL byte."""
    set_col16(tree, S166_ID, S166_LOC.encode() + b"\x00")
    return "col16 = path + 0x00"


def c_token_realpath_escapes(tree):
    """A col-16 cell whose token is a .ufo/waves/ path but whose realpath
    escapes the tree (symlink to outside)."""
    outside = os.path.join(SCRATCH, "outside")
    os.makedirs(outside, exist_ok=True)
    dst = os.path.join(outside, "S166-esc.body")
    if os.path.exists(dst):
        os.unlink(dst)
    shutil.copy2(os.path.join(tree, S166_BODY), dst)
    p = os.path.join(tree, ".ufo/waves/round-67/capture/S166-esc.body")
    if os.path.lexists(p):
        os.unlink(p)
    os.symlink(os.path.relpath(dst, os.path.dirname(p)), p)
    set_col16(tree, S166_ID, ".ufo/waves/round-67/capture/S166-esc.body")
    return "col16 = .ufo/waves/round-67/capture/S166-esc.body -> <scratch>/outside"


def c_tsv_nul_byte(tree):
    """A NUL byte anywhere in corpus/source-fetches.tsv."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    # append a NUL to the last cell of the S166 row
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            lines[i] = ln + b"\x00"
            break
    write_tsv(tree, b"\n".join(lines))
    return "NUL appended to the S166 row"


def c_tsv_cr_in_quote_only(tree):
    """A CR byte inside a quote column only (col 13), not at a line end."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            cells = ln.split(b"\t")
            cells[12] = cells[12] + b"\r"
            lines[i] = b"\t".join(cells)
            break
    write_tsv(tree, b"\n".join(lines))
    return "CR inside col 13 only"


def c_col15_dash_under_rendered(tree):
    """A row whose col 15 is `-` while col 14 is rendered-text-v1."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            cells = ln.split(b"\t")
            cells[14] = b"-"
            lines[i] = b"\t".join(cells)
            break
    write_tsv(tree, b"\n".join(lines))
    return "col15 = '-' with col14 = rendered-text-v1"


def c_id_cell_emptied(tree):
    """The id cell emptied."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            cells = ln.split(b"\t")
            cells[0] = b""
            lines[i] = b"\t".join(cells)
            break
    write_tsv(tree, b"\n".join(lines))
    return "col1 (id) emptied"


def c_id_cell_shifted(tree):
    """The id cell shifted: one extra tab before it."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            lines[i] = b"\t" + ln
            break
    write_tsv(tree, b"\n".join(lines))
    return "an extra tab before the id cell (17 fields)"


def c_duplicate_row(tree):
    """A duplicate S166 row."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    out = []
    for ln in lines:
        out.append(ln)
        if ln.startswith(b"S166\t"):
            out.append(ln)
    write_tsv(tree, b"\n".join(out))
    return "S166 row duplicated"


def c_col16_trailing_space(tree):
    """M1 from the plan: append one space to col 16."""
    set_col16(tree, S166_ID, S166_LOC + " ")
    return "col16 = path + 0x20"


def c_col16_comma_joined(tree):
    """M2 from the plan: comma-joined duplicate."""
    set_col16(tree, S166_ID, S166_LOC + "," + S166_LOC)
    return "col16 = path + ',' + path"


def c_tsv_crlf(tree):
    """M3 from the plan: the whole file rewritten with CRLF."""
    data = read_tsv(tree)
    write_tsv(tree, data.replace(b"\n", b"\r\n"))
    return "whole TSV saved LF->CRLF"


def c_col10_hex_digit(tree):
    """M4 from the plan: replace one hex digit of col 10."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            cells = ln.split(b"\t")
            sha = cells[9].decode()
            ch = "0" if sha[0] != "0" else "1"
            cells[9] = (ch + sha[1:]).encode()
            lines[i] = b"\t".join(cells)
            break
    write_tsv(tree, b"\n".join(lines))
    return "col10 first hex digit replaced"


def c_col15_borrowed(tree):
    """M5 from the plan: replace col 15 with another 64-hex digest."""
    data = read_tsv(tree)
    lines = data.split(b"\n")
    for i, ln in enumerate(lines):
        if ln.startswith(b"S166\t"):
            cells = ln.split(b"\t")
            cells[14] = (b"a" * 64)
            lines[i] = b"\t".join(cells)
            break
    write_tsv(tree, b"\n".join(lines))
    return "col15 replaced with aaaa...aaaa"


def c_body_extra_byte(tree):
    """M6 from the plan: append one byte to the capture body."""
    p = os.path.join(tree, S166_BODY)
    data = open(p, "rb").read()
    os.unlink(p)
    with open(p, "wb") as fh:
        fh.write(data + b"\n")
    return "S166.body + 1 byte"


def c_normalizer_stub(tree):
    """Replace corpus/rendered-text-v1.py with a stub that answers count=1 and
    a digest equal to the row's col 15."""
    p = os.path.join(tree, "corpus/rendered-text-v1.py")
    os.unlink(p)
    with open(p, "w") as fh:
        fh.write(
            "#!/usr/bin/env python3\n"
            "import sys\n"
            "if len(sys.argv) > 1 and sys.argv[1] == 'locate':\n"
            "    print('RENDERED_TEXT_V1_LOCATE: count=1')\n"
            "    sys.exit(0)\n"
            "if len(sys.argv) > 1 and sys.argv[1] == 'digest':\n"
            "    print('RENDERED_TEXT_V1: raw_sha256=%s bytes=0 "
            "normalized_sha256=%s normalized_bytes=0' % ('0'*64, '0'*64))\n"
            "    sys.exit(0)\n"
            "sys.exit(0)\n")
    return "corpus/rendered-text-v1.py replaced by a truthy stub"


def c_col16_prose_mixed(tree):
    """A mixed-prose col-16 cell naming one .ufo/waves/ path."""
    set_col16(tree, S166_ID, "§1.2 Concept Overview; capture " + S166_LOC)
    return "col16 = mixed prose naming the .ufo/waves/ path"


def c_col16_tilde(tree):
    """A `~/`-form cell naming a .ufo/waves/ path."""
    set_col16(tree, S166_ID, "~/" + S166_LOC)
    return "col16 = ~/<path>"


def c_col16_double_slash(tree):
    """A `//`-form cell naming a .ufo/waves/ path."""
    set_col16(tree, S166_ID, "//" + S166_LOC)
    return "col16 = //<path>"


def c_col16_prose_no_waves(tree):
    """A prose cell that names NO .ufo/waves/ token (must stay prose)."""
    set_col16(tree, S166_ID, "Introduction")
    return "col16 = 'Introduction' (no .ufo/waves/ token)"


def c_col16_dotdot_prefix(tree):
    """A cell whose token begins with .. and then names a .ufo/waves/ path."""
    set_col16(tree, S166_ID, "../" + S166_LOC)
    return "col16 = ../<path>"


CASE_LIST = [
    ("control-unmodified", None),
    ("symlink-chain-out-of-tree", c_symlink_chain_out_of_tree),
    ("hardlink-out-of-tree", c_hardlink_out_of_tree),
    ("directory-named-like-capture", c_directory_named_like_capture),
    ("trailing-nul-byte-in-col16", c_trailing_nul_byte),
    ("token-realpath-escapes", c_token_realpath_escapes),
    ("tsv-nul-byte", c_tsv_nul_byte),
    ("tsv-cr-in-quote-only", c_tsv_cr_in_quote_only),
    ("col15-dash-under-rendered-text-v1", c_col15_dash_under_rendered),
    ("id-cell-emptied", c_id_cell_emptied),
    ("id-cell-shifted", c_id_cell_shifted),
    ("duplicate-row", c_duplicate_row),
    ("m1-col16-trailing-space", c_col16_trailing_space),
    ("m2-col16-comma-joined", c_col16_comma_joined),
    ("m3-whole-tsv-crlf", c_tsv_crlf),
    ("m4-col10-hex-digit", c_col10_hex_digit),
    ("m5-col15-borrowed", c_col15_borrowed),
    ("m6-body-extra-byte", c_body_extra_byte),
    ("normalizer-stub", c_normalizer_stub),
    ("col16-mixed-prose-names-path", c_col16_prose_mixed),
    ("col16-tilde-form", c_col16_tilde),
    ("col16-double-slash-form", c_col16_double_slash),
    ("col16-prose-no-waves-token", c_col16_prose_no_waves),
    ("col16-dotdot-prefix", c_col16_dotdot_prefix),
]


def main():
    os.makedirs(CASEDIR, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)
    rows = []
    detail = []
    for name, fn in CASE_LIST:
        tree = clone(name)
        note = "unmodified"
        if fn:
            note = fn(tree)
        lrc, lout, lerr = run_gate(tree)
        lfind = findings_for(lout, S166_ID)
        lverd = verdict_lines(lout)
        rrc_c, rout_c = run_ref(tree, "contains")
        rrc_p, rout_p = run_ref(tree, "prefix")
        rfind_c = findings_for(rout_c, S166_ID)
        rfind_p = findings_for(rout_p, S166_ID)
        rverd_c = verdict_lines(rout_c)
        rverd_p = verdict_lines(rout_p)
        rows.append([
            name, note,
            str(lrc), "|".join(lverd), ";".join(lfind),
            str(rrc_c), "|".join(rverd_c), ";".join(rfind_c),
            str(rrc_p), "|".join(rverd_p), ";".join(rfind_p),
        ])
        detail.append("=== %s ===\nconstruction: %s\n"
                      "--- LANE gate (rc=%d) ---\n%s\n"
                      "--- REF contains (rc=%d) ---\n%s\n"
                      "--- REF prefix (rc=%d) ---\n%s\n"
                      % (name, note, lrc, lout, rrc_c, rout_c, rrc_p, rout_p))
        print("%-34s LANE rc=%d %s" % (name, lrc,
              (lverd[-1] if lverd else "(no verdict line)")))
        print("%-34s REF-contains rc=%d %s" % ("", rrc_c,
              (rverd_c[-1] if rverd_c else "(none)")))
        print("%-34s REF-prefix   rc=%d %s" % ("", rrc_p,
              (rverd_p[-1] if rverd_p else "(none)")))
    hdr = ["case", "construction", "lane_rc", "lane_verdicts", "lane_findings_S166",
           "refc_rc", "refc_verdicts", "refc_findings_S166",
           "refp_rc", "refp_verdicts", "refp_findings_S166"]
    with open(os.path.join(RECEIPTS, "battery-results.tsv"), "w") as fh:
        fh.write("\t".join(hdr) + "\n")
        for r in rows:
            fh.write("\t".join(x.replace("\t", " ") for x in r) + "\n")
    with open(os.path.join(RECEIPTS, "battery-detail.txt"), "w") as fh:
        fh.write("\n".join(detail))
    print("\nreceipts written to", RECEIPTS)


if __name__ == "__main__":
    main()
