#!/usr/bin/env python3
"""R67Revenger capture-binding mutation battery.

Read-only w.r.t. the lane: every tree under test is a hardlink copy of
base-tree (git archive HEAD), and every mutation replaces the file inode
(temp + os.replace) so base-tree bytes never change.

Usage: driver.py <gate-script> <label> [case ...]
Runs each case's mutation on a fresh copy and records the gate's verdict,
findings and exit code. Results in results/<label>.tsv and .json.
"""
import json
import os
import shutil
import stat
import subprocess
import sys

S = os.path.dirname(os.path.abspath(__file__))
BASE = os.environ.get("R67_BASE") or os.path.join(S, "base-tree")
CASES = os.path.join(S, "cases")
RES = os.path.join(S, "results")
TSV_REL = "corpus/source-fetches.tsv"
S113 = ".ufo/waves/round-55/capture/S113.body"
S114 = ".ufo/waves/round-55/capture/S114.body"
S143 = ".ufo/waves/round-64/capture/S143.body"
S135 = ".ufo/waves/round-63/capture/S135.body"


def rewrite(path, data):
    tmp = path + ".r67tmp"
    with open(tmp, "wb") as f:
        f.write(data)
    os.replace(tmp, path)


def rows(tree):
    p = os.path.join(tree, TSV_REL)
    with open(p, "rb") as f:
        return f.read().split(b"\n")


def put_rows(tree, lines):
    rewrite(os.path.join(tree, TSV_REL), b"\n".join(lines))


def find_row(lines, sid):
    sid = sid.encode()
    for i, ln in enumerate(lines):
        if ln.split(b"\t", 1)[0] == sid:
            return i
    raise SystemExit("row not found: " + sid.decode())


def edit_field(tree, sid, col, value):
    lines = rows(tree)
    i = find_row(lines, sid)
    f = lines[i].split(b"\t")
    assert len(f) == 16, (sid, len(f))
    f[col - 1] = value if isinstance(value, bytes) else value.encode()
    lines[i] = b"\t".join(f)
    put_rows(tree, lines)


def append_field(tree, sid, value):
    lines = rows(tree)
    i = find_row(lines, sid)
    f = lines[i].split(b"\t")
    assert len(f) == 16
    f.append(value if isinstance(value, bytes) else value.encode())
    lines[i] = b"\t".join(f)
    put_rows(tree, lines)


def dup_row(tree, sid):
    lines = rows(tree)
    i = find_row(lines, sid)
    lines.insert(i + 1, lines[i])
    put_rows(tree, lines)


def field_repr(tree, sid, col):
    lines = rows(tree)
    i = find_row(lines, sid)
    return lines[i].split(b"\t")[col - 1]


def mk(tree, case, rel):
    p = os.path.join(tree, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    return p


# --- case definitions: each takes (tree, casedir) and returns a note ---------
def c_clean(t, c):
    return "no mutation"


def c_leg1_repoint(t, c):
    edit_field(t, "S113", 16, S114)
    return "S113 col16 -> S114.body (other row's body)"


def c_leg2_truncate(t, c):
    p = os.path.join(t, S113)
    data = open(p, "rb").read()
    rewrite(p, data[:-1])
    return f"S113.body truncated {len(data)}->{len(data)-1}"


def c_leg3_delete(t, c):
    os.remove(os.path.join(t, S113))
    return "S113.body deleted"


def c_leg4_absolute(t, c):
    v = os.path.join(t, S113)
    edit_field(t, "S113", 16, v)
    return f"S113 col16 -> {v}"


def c_leg5_dotdot(t, c):
    out = os.path.join(c, "outside", "S113.body")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    shutil.copyfile(os.path.join(t, S113), out)
    edit_field(t, "S113", 16, "../outside/S113.body")
    return "S113 col16 -> ../outside/S113.body (same bytes, outside tree)"


def c_leg6_quote(t, c):
    edit_field(t, "S135", 13, "zzz phrase absent from body zzz")
    return "S135 col13 -> non-locating string"


def c1a_sym_other_mismatch(t, c):
    link = mk(t, c, ".ufo/waves/round-55/capture/S113-sym.body")
    os.symlink("S114.body", link)
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/S113-sym.body")
    return "col16 -> symlink S113-sym.body -> S114.body (inside tree, bytes differ)"


def c1b_sym_other_samebytes(t, c):
    link = mk(t, c, ".ufo/waves/round-64/capture/S143-alias.body")
    os.symlink("S143.body", link)
    edit_field(t, "S164", 16, ".ufo/waves/round-64/capture/S143-alias.body")
    return "S164 col16 -> symlink S143-alias.body -> S143.body (same bytes)"


def c1c_sym_chain(t, c):
    d = mk(t, c, ".ufo/waves/round-64/capture/hop.body")
    os.symlink("S143.body", d)
    hop2 = mk(t, c, ".ufo/waves/round-64/capture/hop2.body")
    os.symlink("hop.body", hop2)
    edit_field(t, "S164", 16, ".ufo/waves/round-64/capture/hop2.body")
    return "S164 col16 -> hop2 -> hop -> S143.body (chain)"


def c2_sym_escape(t, c):
    out = os.path.join(c, "outside", "S113.body")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    shutil.copyfile(os.path.join(t, S113), out)
    link = mk(t, c, ".ufo/waves/round-55/capture/S113-esc.body")
    os.symlink("../../../../../outside/S113.body", link)  # relative, escapes tree
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/S113-esc.body")
    return "col16 -> in-tree symlink -> ../../../../../outside/S113.body (same bytes, outside)"


def c3a_hard_other_mismatch(t, c):
    src = os.path.join(t, S114)
    dst = mk(t, c, ".ufo/waves/round-55/capture/S113-hard.body")
    os.link(src, dst)
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/S113-hard.body")
    return "col16 -> hardlink to S114.body (bytes differ)"


def c3b_hard_outside(t, c):
    out = os.path.join(c, "outside", "S113-hard.body")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    shutil.copyfile(os.path.join(t, S113), out)
    dst = mk(t, c, ".ufo/waves/round-55/capture/S113-hard2.body")
    os.link(out, dst)
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/S113-hard2.body")
    return "col16 -> in-tree hardlink to out-of-tree body (same bytes, nlink=2)"


def c3b_mut(t, c):
    c3b_hard_outside(t, c)
    out = os.path.join(c, "outside", "S113-hard.body")
    with open(out, "ab") as f:  # writes the SHARED inode, never the tree path
        f.write(b"X")
    return "same as 3b, then 1 byte appended to the out-of-tree name"


def c4a_dot(t, c):
    edit_field(t, "S113", 16, "./" + S113)
    return "col16 -> ./" + S113


def c4b_slash2(t, c):
    edit_field(t, "S113", 16, ".ufo//waves/round-55/capture/S113.body")
    return "col16 -> .ufo//waves/round-55/capture/S113.body"


def c4c_inner_dot(t, c):
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/./S113.body")
    return "col16 -> .ufo/waves/round-55/capture/./S113.body"


def c4d_inner_dotdot(t, c):
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/../capture/S113.body")
    return "col16 -> .ufo/waves/round-55/capture/../capture/S113.body"


def c5a_trail_space(t, c):
    edit_field(t, "S113", 16, S113 + " ")
    return "col16 -> '" + S113 + " ' (one trailing 0x20)"


def c5b_trail_tab(t, c):
    append_field(t, "S113", "")
    return "row S113 gains a 17th empty field (trailing TAB)"


def c5c_lead_space(t, c):
    edit_field(t, "S113", 16, " " + S113)
    return "col16 -> ' " + S113 + "' (one leading 0x20)"


def c5d_inner_space(t, c):
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/S113 .body")
    return "col16 -> '.ufo/waves/round-55/capture/S113 .body'"


def c5e_trail_cr(t, c):
    edit_field(t, "S113", 16, S113.encode() + b"\r")
    return "col16 -> '" + S113 + "\\r' (row CRLF, file LF)"


def c5f_spaces_only(t, c):
    edit_field(t, "S113", 16, b" " * 8)
    return "col16 -> eight 0x20 bytes"


def c5g_whole_crlf(t, c):
    p = os.path.join(t, TSV_REL)
    data = open(p, "rb").read()
    rewrite(p, data.replace(b"\n", b"\r\n"))
    return "whole source-fetches.tsv converted LF -> CRLF"


def c6a_cr_tail_rendered(t, c):
    q = field_repr(t, "S135", 13)
    edit_field(t, "S135", 13, q + b"\r")
    return "S135 col13 -> declared quote + \\r, col14 rendered-text-v1"


def c6b_cr_tail_raw(t, c):
    q = field_repr(t, "S113", 13)
    edit_field(t, "S113", 13, q + b"\r")
    return "S113 col13 -> declared quote + \\r, col14 raw-literal-v1"


def c6c_cr_inner_rendered(t, c):
    edit_field(t, "S135", 13, "In the current version of ConText there are 17 pseudo-triggers for negated (e.g., \u201cno increase\u201d, \u201cnot\u00a0cause\u201d)".replace("\u00a0", "\r"))
    return "S135 col13 -> quote with one inner space replaced by \\r"


def c6d_lf_in_quote(t, c):
    edit_field(t, "S113", 13, "ISO/IEC 11770-3:2021/\nAmd 1:2025")
    return "S113 col13 -> quote containing a literal LF"


def c7a_raw_only_under_rendered(t, c):
    edit_field(t, "S135", 13, '<italic toggle="yes">negated</italic>')
    return "S135 col13 -> raw-only markup span, col14 rendered-text-v1"


def c7b_raw_only_declared_raw(t, c):
    edit_field(t, "S135", 13, '<italic toggle="yes">negated</italic>')
    edit_field(t, "S135", 14, "raw-literal-v1")
    edit_field(t, "S135", 15, "-")
    return "same raw-only span, col14 raw-literal-v1 (control)"


def c8a_extra_col(t, c):
    append_field(t, "S113", "EXTRA")
    return "row S113 gains a 17th field EXTRA"


def c8b_empty_extra(t, c):
    append_field(t, "S113", "")
    return "row S113 gains a 17th empty field"


def c8c_comma_two(t, c):
    edit_field(t, "S113", 16, S113 + "," + S114)
    return "col16 -> two paths comma-joined"


def c8d_dup_row(t, c):
    dup_row(t, "S113")
    return "S113 provenance row duplicated"


def c8e_dup_location_across_ids(t, c):
    edit_field(t, "S114", 16, S113)
    return "S114 col16 -> S113.body (same location, different id)"


def c9a_leading_zero(t, c):
    edit_field(t, "S113", 11, "090604")
    return "S113 col11 -> 090604"


def c9b_plus(t, c):
    edit_field(t, "S113", 11, "+90604")
    return "S113 col11 -> +90604"


def c9c_lead_space(t, c):
    edit_field(t, "S113", 11, " 90604")
    return "S113 col11 -> ' 90604'"


def c9d_trail_space(t, c):
    edit_field(t, "S113", 11, "90604 ")
    return "S113 col11 -> '90604 '"


def c9e_other_number(t, c):
    edit_field(t, "S113", 11, "90605")
    return "S113 col11 -> 90605 (different number, control)"


def p1_dir_location(t, c):
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture")
    return "col16 -> a directory (capture-shaped)"


def p2_loop(t, c):
    link = mk(t, c, ".ufo/waves/round-55/capture/S113-loop.body")
    os.symlink("S113-loop.body", link)
    edit_field(t, "S113", 16, ".ufo/waves/round-55/capture/S113-loop.body")
    return "col16 -> self-referential symlink"


def p3_normsha_borrowed(t, c):
    edit_field(t, "S155", 15, "4d966ff9535cdbd8faa00ad925f60e2fb38892bdb07cd48bb587c9da8aac72d5")
    return "S155 col15 -> S164's normalized digest (format valid, wrong body)"


def p4_short_quote(t, c):
    edit_field(t, "S115", 13, "the")
    return "S115 col13 -> 'the' (locates count=90)"


def p5_dot_location(t, c):
    edit_field(t, "S113", 16, ".")
    return "col16 -> '.' (capture-shaped, resolves to tree root dir)"


def p6_normalizer_tamper(t, c):
    edit_field(t, "S135", 13, "zzz phrase absent from body zzz")
    stub = (b"#!/usr/bin/env python3\nimport sys\n"
            b"print('RENDERED_TEXT_V1_LOCATE: count=1')\nsys.exit(0)\n")
    rewrite(os.path.join(t, "corpus/rendered-text-v1.py"), stub)
    return "quote non-locating + in-tree rendered-text-v1.py replaced by a count=1 stub"


def p7_abs_inside(t, c):
    edit_field(t, "S113", 16, os.path.join(t, S113))
    return "col16 -> absolute path that resolves INSIDE the tree"


def p8_slash2_absolute(t, c):
    edit_field(t, "S113", 16, "//etc/passwd")
    return "col16 -> //etc/passwd (absolute, doubled leading slash)"


def p9_slash_dot_absolute(t, c):
    edit_field(t, "S113", 16, "/./etc/passwd")
    return "col16 -> /./etc/passwd (absolute, grammar-legal after the slash)"


def p10_dot_dotdot(t, c):
    out = os.path.join(c, "outside", "S113.body")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    shutil.copyfile(os.path.join(t, S113), out)
    edit_field(t, "S113", 16, "./../outside/S113.body")
    return "col16 -> ./../outside/S113.body (same bytes, escapes tree)"


def p11_tilde(t, c):
    edit_field(t, "S113", 16, "~/S113.body")
    return "col16 -> ~/S113.body (prose by grammar)"


def leg1b_repoint_s164(t, c):
    edit_field(t, "S164", 16, ".ufo/waves/round-66/capture/S156-429.body")
    return "S164 col16 -> S156-429.body (round-66 QM94 shape, other row's body)"


def p12_empty_id(t, c):
    lines = rows(t)
    i = find_row(lines, "S113")
    f = lines[i].split(b"\t")
    f[0] = b""
    lines[i] = b"\t".join(f)
    put_rows(t, lines)
    return "S113 row's id cell emptied (16 columns, shaped location)"


def p13_unknown_id(t, c):
    edit_field(t, "S113", 1, "S999")
    return "S113 row's id -> S999 (no registry row)"


def p14_invalid_utf8_body(t, c):
    body = os.path.join(t, ".ufo/waves/round-63/capture/S135.body")
    data = open(body, "rb").read()
    rewrite(body, data + b"\xff")
    return "S135.body gains one 0xFF byte (rendered-text-v1 decode error)"


def p14b_utf8_coherent(t, c):
    import hashlib
    body = os.path.join(t, ".ufo/waves/round-63/capture/S135.body")
    data = open(body, "rb").read() + b"\xff"
    rewrite(body, data)
    edit_field(t, "S135", 11, str(len(data)))
    edit_field(t, "S135", 10, hashlib.sha256(data).hexdigest())
    edit_field(t, "S135", 15, hashlib.sha256(b"stub").hexdigest())
    return "S135 body +0xFF with col10/col11 updated to match (coherent row, undecodable body)"


def c_clean_after(t, c):
    return "no mutation (re-check)"


TABLE = [
    ("clean", c_clean),
    ("leg1-repoint", c_leg1_repoint),
    ("leg2-truncate", c_leg2_truncate),
    ("leg3-delete", c_leg3_delete),
    ("leg4-absolute", c_leg4_absolute),
    ("leg5-dotdot", c_leg5_dotdot),
    ("leg6-quote-nonlocating", c_leg6_quote),
    ("c1a-sym-other-mismatch", c1a_sym_other_mismatch),
    ("c1b-sym-other-samebytes", c1b_sym_other_samebytes),
    ("c1c-sym-chain", c1c_sym_chain),
    ("c2-sym-escape", c2_sym_escape),
    ("c3a-hard-other-mismatch", c3a_hard_other_mismatch),
    ("c3b-hard-outside", c3b_hard_outside),
    ("c3b-mut-outside-write", c3b_mut),
    ("c4a-dot-prefix", c4a_dot),
    ("c4b-double-slash", c4b_slash2),
    ("c4c-inner-dot", c4c_inner_dot),
    ("c4d-inner-dotdot", c4d_inner_dotdot),
    ("c5a-trail-space", c5a_trail_space),
    ("c5b-trail-tab", c5b_trail_tab),
    ("c5c-lead-space", c5c_lead_space),
    ("c5d-inner-space", c5d_inner_space),
    ("c5e-trail-cr", c5e_trail_cr),
    ("c5f-spaces-only", c5f_spaces_only),
    ("c5g-whole-crlf", c5g_whole_crlf),
    ("c6a-cr-tail-rendered", c6a_cr_tail_rendered),
    ("c6b-cr-tail-raw", c6b_cr_tail_raw),
    ("c6c-cr-inner-rendered", c6c_cr_inner_rendered),
    ("c6d-lf-in-quote", c6d_lf_in_quote),
    ("c7a-raw-only-rendered", c7a_raw_only_under_rendered),
    ("c7b-raw-only-declared-raw", c7b_raw_only_declared_raw),
    ("c8a-extra-col", c8a_extra_col),
    ("c8b-extra-empty-col", c8b_empty_extra),
    ("c8c-comma-two-paths", c8c_comma_two),
    ("c8d-dup-row", c8d_dup_row),
    ("c8e-dup-location-other-id", c8e_dup_location_across_ids),
    ("c9a-leading-zero", c9a_leading_zero),
    ("c9b-plus", c9b_plus),
    ("c9c-lead-space", c9c_lead_space),
    ("c9d-trail-space", c9d_trail_space),
    ("c9e-other-number", c9e_other_number),
    ("p1-dir-location", p1_dir_location),
    ("p2-sym-loop", p2_loop),
    ("p3-normsha-borrowed", p3_normsha_borrowed),
    ("p4-short-quote", p4_short_quote),
    ("p5-dot-location", p5_dot_location),
    ("p6-normalizer-tamper", p6_normalizer_tamper),
    ("p7-abs-inside-tree", p7_abs_inside),
    ("p8-doubled-slash-absolute", p8_slash2_absolute),
    ("p9-slash-dot-absolute", p9_slash_dot_absolute),
    ("p10-dot-dotdot-escape", p10_dot_dotdot),
    ("p11-tilde", p11_tilde),
    ("leg1b-repoint-s164", leg1b_repoint_s164),
    ("p12-empty-id", p12_empty_id),
    ("p13-unknown-id", p13_unknown_id),
    ("p14-invalid-utf8-body", p14_invalid_utf8_body),
    ("p14b-utf8-coherent", p14b_utf8_coherent),
    ("clean-after", c_clean_after),
]


def run_case(gate, label, name, fn):
    cdir = os.path.join(CASES, name)
    tree = os.path.join(cdir, "tree")
    if os.path.isdir(cdir):
        shutil.rmtree(cdir)
    os.makedirs(cdir)
    subprocess.run(["cp", "-al", BASE, tree], check=True)
    run_gate = gate
    if os.environ.get("R67_INJECT") == "1":
        dst = os.path.join(tree, "corpus/sources-census.sh")
        rewrite(dst, open(gate, "rb").read())
        run_gate = dst
    note = fn(tree, cdir)
    p = subprocess.run(["bash", run_gate, "verify", "--root", tree],
                       capture_output=True, text=True, cwd=tree, timeout=600)
    out = p.stdout + p.stderr
    findings = [ln for ln in out.splitlines() if ln.startswith("FINDING ")]
    caps = [ln for ln in findings if ln.startswith("FINDING SC_CAPTURE ")]
    summary = [ln for ln in out.splitlines() if ln.startswith("SOURCES_CAPTURES:")]
    verdict = [ln for ln in out.splitlines() if ln.startswith("SOURCES_CENSUS:")]
    rec = {
        "case": name, "note": note, "rc": p.returncode,
        "verdict": verdict[-1] if verdict else "(none)",
        "captures": summary[0] if summary else "(none)",
        "findings_total": len(findings),
        "sc_capture": caps,
        "findings": findings[:12],
        "stderr": p.stderr.strip()[:400],
    }
    return rec


def main():
    gate = os.path.abspath(sys.argv[1])
    label = sys.argv[2]
    only = set(sys.argv[3:])
    os.makedirs(RES, exist_ok=True)
    gate_sha = subprocess.run(["sha256sum", gate], capture_output=True, text=True).stdout.split()[0]
    recs = []
    for name, fn in TABLE:
        if only and name not in only:
            continue
        try:
            rec = run_case(gate, label, name, fn)
        except Exception as e:  # record setup failure, never hide it
            rec = {"case": name, "note": "", "rc": None, "error": repr(e)}
        recs.append(rec)
        print(f"{name:28s} rc={rec.get('rc')} caps={len(rec.get('sc_capture', []))} "
              f"find={rec.get('findings_total')}  {rec.get('verdict', rec.get('error'))}")
        if recs[-1].get("sc_capture"):
            for ln in recs[-1]["sc_capture"]:
                print("    " + ln)
    payload = {"gate": gate, "gate_sha256": gate_sha, "label": label, "cases": recs}
    with open(os.path.join(RES, label + ".json"), "w") as f:
        json.dump(payload, f, indent=1)
    with open(os.path.join(RES, label + ".tsv"), "w") as f:
        f.write("case\trc\tverdict\tsc_capture\ttotal_findings\n")
        for r in recs:
            f.write("%s\t%s\t%s\t%s\t%s\n" % (
                r["case"], r.get("rc"), r.get("verdict", r.get("error")),
                " ; ".join(x[18:] for x in r.get("sc_capture", [])) or "-",
                r.get("findings_total", "-")))
    print("gate=" + gate_sha)


if __name__ == "__main__":
    main()
