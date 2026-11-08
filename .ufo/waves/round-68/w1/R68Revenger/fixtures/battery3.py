#!/usr/bin/env python3
"""R68Revenger battery v3 — frozen-snapshot battery.

Each run works on a lean lean copy of the snapshot (corpus/ + capture bodies).
The BASE column is the SAME content with only corpus/sources-census.sh replaced
by the BASE (d3b2a4e8) gate, so the gate bytes are the only variable.
"""
import os, re, shutil, subprocess, sys, hashlib, json, argparse

S = os.environ.get("REVENGER_SCRATCH", "/fast/scratch/hyaku/kagi-r68/R68Revenger")
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
BASE_SHA = "d3b2a4e8eed710277951e430efd3d27b5983033c"

def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""): h.update(b)
    return h.hexdigest()

def run_gate(tree):
    r = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True)
    lines = (r.stdout + r.stderr).splitlines()
    return {
        "rc": r.returncode,
        "captures": next((l for l in lines if l.startswith("SOURCES_CAPTURES:")), "<none>"),
        "census": next((l for l in lines if l.startswith("SOURCES_CENSUS:")), "<none>"),
        "findings": [l for l in lines if l.startswith("FINDING")],
        "all": lines,
    }

def rows_of(tree):
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    with open(p, "rb") as f:
        data = f.read().decode("utf-8", "surrogateescape")
    return data.split("\n"), p

def write_rows(p, rows):
    tmp = p + ".new"
    with open(tmp, "wb") as f:
        f.write("\n".join(rows).encode("utf-8", "surrogateescape"))
    os.replace(tmp, p)

def idx(rows, sid):
    for i, l in enumerate(rows):
        p = l.split("\t")
        if p and p[0] == sid and len(p) >= 16:
            return i
    return None

def get_cell(tree, sid, col):
    rows, _ = rows_of(tree)
    i = idx(rows, sid)
    return rows[i].split("\t")[col - 1]

def set_cell(tree, sid, col, value):
    rows, p = rows_of(tree)
    i = idx(rows, sid)
    assert i is not None, f"{sid} not a row"
    parts = rows[i].split("\t")
    parts[col - 1] = value
    rows[i] = "\t".join(parts)
    write_rows(p, rows)

def mutate_cell(sid, col, fn):
    def f(tree):
        old = get_cell(tree, sid, col)
        new = fn(old)
        assert new != old, f"{sid}.col{col}: mutation is a no-op (SETUP)"
        set_cell(tree, sid, col, new)
    return f

def m_crlf(tree):
    _, p = rows_of(tree)
    with open(p, "rb") as f: b = f.read()
    b2 = b.replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
    assert b2 != b
    with open(p + ".new", "wb") as f: f.write(b2)
    os.replace(p + ".new", p)

def m_body_append(loc, n=1):
    def f(tree):
        p = os.path.join(tree, loc)
        with open(p, "rb") as fh: b = fh.read()
        with open(p + ".new", "wb") as fh: fh.write(b + b"X" * n)
        os.replace(p + ".new", p)
        assert os.path.getsize(p) == len(b) + n, f"append failed on {loc}"
    return f

def m_symlink(anchor, loc):
    def f(tree):
        body = os.path.join(tree, loc)
        alt = os.path.join(tree, ".ufo/waves/round-68/capture/R68Rev-alias.body")
        os.makedirs(os.path.dirname(alt), exist_ok=True)
        if os.path.lexists(alt): os.remove(alt)
        os.symlink(os.path.relpath(body, os.path.dirname(alt)), alt)
        set_cell(tree, anchor, 16, os.path.relpath(alt, tree))
    return f

def m_hardlink(anchor, loc):
    def f(tree):
        src = os.path.join(tree, loc)
        dst = os.path.join(tree, ".ufo/waves/round-68/capture/R68Rev-hard.body")
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.lexists(dst): os.remove(dst)
        os.link(src, dst)
        set_cell(tree, anchor, 16, os.path.relpath(dst, tree))
    return f

def m_norm_tamper(tree):
    """naive: lies on both digest and locate"""
    p = os.path.join(tree, "corpus/rendered-text-v1.py")
    with open(p, "w") as f:
        f.write("#!/usr/bin/env python3\nimport sys\n"
                "if sys.argv[1:2] == ['digest']:\n"
                "    print('RENDERED_TEXT_V1: normalized_sha256=' + '0'*64)\n"
                "else:\n"
                "    print('RENDERED_TEXT_V1_LOCATE: count=1')\n")
    os.chmod(p, 0o755)

def m_norm_tamper_smart(tree):
    """digest delegated to the real instrument, locate always count=1"""
    p = os.path.join(tree, "corpus/rendered-text-v1.py")
    real = p + ".real"
    shutil.copy2(p, real)
    with open(p, "w") as f:
        f.write("#!/usr/bin/env python3\nimport os, sys\n"
                "real = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'rendered-text-v1.py.real')\n"
                "if sys.argv[1:2] == ['digest']:\n"
                "    os.execv(sys.executable, [sys.executable, real] + sys.argv[1:])\n"
                "print('RENDERED_TEXT_V1_LOCATE: count=1')\n")
    os.chmod(p, 0o755)

# ---- independent classification (own code, not the gate's) ----
def classify(loc):
    shaped = bool(loc) and "/" in loc and bool(re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", loc))
    if shaped:
        return "path" if ".ufo/waves/" in loc else "prose"
    t = (loc or "").strip()
    if t and "/" in t and re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", t) and ".ufo/waves/" in t:
        return "whitespace"
    toks = (loc or "").split()
    haspath = any(".ufo/waves/" in x for x in toks)
    hasbad = any(x.startswith("~/") or x.startswith("//") for x in toks)
    if not haspath and not hasbad:
        return "prose"
    if "," in loc and ".ufo/waves/" in loc and " " not in loc:
        return "whitespace"
    return "token"

def independent_counts(tree):
    rows, _ = rows_of(tree)
    c = {"path": 0, "prose": 0, "whitespace": 0, "token": 0}
    for l in rows:
        p = l.split("\t")
        if len(p) < 16 or not p[0].startswith("S"):
            continue
        c[classify(p[15])] += 1
    return c

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--snap", required=True)
    ap.add_argument("--only", default="")
    ap.add_argument("--tag", default="v3")
    args = ap.parse_args()

    snap = os.path.join(S, args.snap) if not os.path.isabs(args.snap) else args.snap
    meta = json.load(open(os.path.join(snap, "SNAPSHOT.json")))
    gate_cand = os.path.join(snap, "corpus/sources-census.sh")
    assert sha(gate_cand) == meta["gate_sha256"]

    base_dir = os.path.join(S, "base")
    if not os.path.exists(os.path.join(base_dir, "corpus/sources-census.sh")):
        raise SystemExit("BASE extraction missing")
    gate_base = os.path.join(base_dir, "corpus/sources-census.sh")

    # lean class trees
    def lean(dest):
        shutil.rmtree(dest, ignore_errors=True)
        shutil.copytree(snap, dest, symlinks=True)
        if os.path.exists(os.path.join(dest, "SNAPSHOT.json")):
            os.remove(os.path.join(dest, "SNAPSHOT.json"))
    cls_base = os.path.join(S, "cls-base"); lean(cls_base)
    shutil.copy2(gate_base, os.path.join(cls_base, "corpus/sources-census.sh"))
    os.chmod(os.path.join(cls_base, "corpus/sources-census.sh"), 0o755)
    cls_cand = os.path.join(S, "cls-cand"); lean(cls_cand)

    rows, _ = rows_of(snap)
    shaped = [l.split("\t") for l in rows if len(l.split("\t")) >= 16 and l.split("\t")[0].startswith("S")]
    pure = [p for p in shaped if classify(p[15]) == "path"]
    prose_rows = [p for p in shaped if classify(p[15]) == "prose"]
    ANCHOR, ANCHOR_LOC = pure[-1][0], pure[-1][15]
    TOK_ANCHOR = [p for p in shaped if any(t.startswith(".ufo/waves/") for t in p[15].split())][-1][0]
    donor_row = next((p for p in shaped if p[0] != ANCHOR and p[13] == "rendered-text-v1"
                      and re.fullmatch(r"[0-9a-f]{64}", p[14] or "")
                      and p[14] != get_cell(snap, ANCHOR, 15)), None)
    donor = (donor_row[0], donor_row[14]) if donor_row else None
    prose_id = prose_rows[0][0]
    print(f"snapshot gate={meta['gate_sha256'][:16]} tsv={meta['tsv_sha256'][:16]}")
    print(f"independent class counts: {independent_counts(snap)}")
    print(f"anchor={ANCHOR} loc={ANCHOR_LOC} token-anchor={TOK_ANCHOR}")
    print(f"col15 donor={donor[0] if donor else None} prose-row={prose_id}")

    for name, tree in (("base", cls_base), ("cand", cls_cand)):
        r = run_gate(tree)
        print(f"[baseline-{name}] rc={r['rc']} | {r['captures']} | {r['census']}")
        for f in r["findings"][:5]:
            print("   ", f)

    results = []
    def case(cid, fn, expect, note):
        for side, proto in (("base", cls_base), ("cand", cls_cand)):
            tree = os.path.join(S, "work", f"{cid}-{side}")
            shutil.rmtree(tree, ignore_errors=True)
            shutil.copytree(proto, tree, symlinks=True)
            try:
                fn(tree)
            except AssertionError as e:
                results.append({"case": cid, "side": side, "setup": str(e), "note": note})
                print(f"[SETUP] {cid}/{side}: {e}")
                continue
            r = run_gate(tree)
            met = eval_expect(expect, r)
            results.append({"case": cid, "side": side, "rc": r["rc"], "captures": r["captures"],
                            "census": r["census"], "findings": r["findings"],
                            "expect": expect, "met": met, "note": note})
            print(f"[{'OK  ' if met else ('MISS' if met is False else '??  ')}] {cid}/{side}: rc={r['rc']} | {r['captures']} | {r['census']}")
            for f in r["findings"][:4]:
                print("        ", f)
            shutil.rmtree(tree, ignore_errors=True)

    def eval_expect(expect, r):
        if expect is None:
            return None
        kinds = list(expect) if isinstance(expect, tuple) else [expect]
        out = []
        for e in kinds:
            if e == "CLEAN":
                out.append(r["rc"] == 0 and r["census"].startswith("SOURCES_CENSUS: CLEAN"))
            elif e == "FAILED":
                out.append(r["rc"] == 1 and "SOURCES_CENSUS: FAILED" in r["census"])
            elif e.startswith("SC_FETCH "):
                want = e.split(" ", 1)[1]
                out.append(any(f"FINDING SC_FETCH {want}" in f for f in r["findings"]))
            elif e.startswith("any:"):
                alts = e[4:].split("|")
                out.append(any(any(a in f for f in r["findings"]) for a in alts))
            elif e.startswith("SC_CAPTURE "):
                want = e.split(" ", 1)[1]
                out.append(any(f"FINDING SC_CAPTURE" in f and want in f for f in r["findings"]))
            else:
                out.append(e in r["captures"])
        return all(out)

    A = ANCHOR_LOC
    cases = []
    # class 1
    cases += [
        ("c1-trail-space",   mutate_cell(ANCHOR, 16, lambda v: v + " "), "SC_CAPTURE capture-whitespace", "+0x20"),
        ("c1-lead-space",    mutate_cell(ANCHOR, 16, lambda v: " " + v), "SC_CAPTURE capture-whitespace", "leading 0x20"),
        ("c1-interior-space",mutate_cell(ANCHOR, 16, lambda v: v.replace("/capture/", "/ capture/", 1)), "SC_CAPTURE capture-whitespace", "interior 0x20"),
        ("c1-eight-spaces",  mutate_cell(ANCHOR, 16, lambda v: " " * 8), ("any:capture-whitespace|capture-token", "FAILED"), "eight spaces"),
        ("c1-trailing-cr",   mutate_cell(ANCHOR, 16, lambda v: v + "\r"), ("FAILED", "any:capture-whitespace|cr-in-tsv"), "+CR"),
        ("c1-comma-dup",     mutate_cell(ANCHOR, 16, lambda v: v + "," + v), "SC_CAPTURE capture-whitespace", "comma+dup"),
        ("c1-slashslash",    mutate_cell(ANCHOR, 16, lambda v: "//etc/passwd"), "SC_CAPTURE capture-token", "//etc/passwd"),
        ("c1-tilde",         mutate_cell(ANCHOR, 16, lambda v: "~/S113.body"), "SC_CAPTURE capture-token", "~/S113.body"),
    ]
    # class 2
    cases.append(("c2-crlf-whole", m_crlf, ("SC_FETCH cr-in-tsv", "FAILED"), "whole-file CRLF"))
    # class 3
    if donor:
        cases.append(("c3-borrow15", mutate_cell(ANCHOR, 15, lambda v: donor[1]), "SC_CAPTURE normalized-digest-mismatch", f"col15<-{donor[0]}"))
    # class 4
    cases += [
        ("c0-mixed-prose", mutate_cell(ANCHOR, 16, lambda v: "see capture " + v + " for details"), "SC_CAPTURE capture-token", "mixed prose"),
        ("c0-pure-control", (lambda t: None), "CLEAN", "unmodified"),
        ("c0-s166-prerecut", mutate_cell("S166", 16, lambda v: "\u00a71.2 Concept Overview; capture " + v), "SC_CAPTURE capture-token", "S166 pre-recut mixed bytes"),
        ("c1-cell-cr-interior", mutate_cell("S113", 16, lambda v: v.replace("/S113.body", "\r/S113.body")), ("any:capture-whitespace|capture-token", "FAILED"), "CR inside the cell"),
    ]
    # class 5
    cases += [
        ("reg-dot-prefix",   mutate_cell(ANCHOR, 16, lambda v: "./" + v), "CLEAN", "./"),
        ("reg-double-slash", mutate_cell(ANCHOR, 16, lambda v: v.replace(".ufo/", ".ufo//", 1)), "CLEAN", ".ufo//"),
        ("reg-inner-dot",    mutate_cell(ANCHOR, 16, lambda v: v.replace("/capture/", "/capture/./", 1)), "CLEAN", "/./"),
        ("reg-inner-dotdot", mutate_cell(ANCHOR, 16, lambda v: v.replace("/capture/", "/capture/../capture/", 1)), "CLEAN", "/../capture/"),
        ("reg-symlink-intree", m_symlink(ANCHOR, A), "CLEAN", "in-tree symlink"),
        ("reg-absolute",     mutate_cell(ANCHOR, 16, lambda v: os.path.join(LANE, v)), "SC_CAPTURE capture-outside-root", "absolute in-tree path"),
        ("reg-shaped-nonwaves", mutate_cell(ANCHOR, 16, lambda v: "corpus/quote-bodies.tsv"), ("CLEAN", "SOURCES_CAPTURES: CLEAN (path_rows="), "shaped non-waves cell"),
    ]
    # class 6 (frozen six legs)
    cases += [
        ("m1-anchor-space", mutate_cell(ANCHOR, 16, lambda v: v + " "), "SC_CAPTURE capture-whitespace", "M1"),
        ("m2-anchor-dup",   mutate_cell(ANCHOR, 16, lambda v: v + "," + v), "SC_CAPTURE capture-whitespace", "M2"),
        ("m4-anchor-sha",   mutate_cell(ANCHOR, 10, lambda v: ("0" if v[0] != "0" else "1") + v[1:]), "SC_CAPTURE capture-digest-mismatch", "M4"),
        ("m5-anchor-col15", mutate_cell(ANCHOR, 15, lambda v: donor[1]) if donor else (lambda t: None), "SC_CAPTURE normalized-digest-mismatch", "M5"),
        ("m6-anchor-body",  m_body_append(A), "SC_CAPTURE capture-bytes-mismatch", "M6"),
    ]
    # S113 witness row (round-67 exact bytes)
    S113 = ".ufo/waves/round-55/capture/S113.body"
    cases += [
        ("s113-trail-space", mutate_cell("S113", 16, lambda v: v + " "), "SC_CAPTURE capture-whitespace", "S113 +0x20"),
        ("s113-lead-space",  mutate_cell("S113", 16, lambda v: " " + v), "SC_CAPTURE capture-whitespace", "S113 lead"),
        ("s113-interior",    mutate_cell("S113", 16, lambda v: v.replace("/capture/", "/capture/ /", 1)), "any:capture-whitespace|capture-token", "S113 interior"),
        ("s113-eight-spaces",mutate_cell("S113", 16, lambda v: " " * 8), ("any:capture-whitespace|capture-token", "FAILED"), "S113 8 spaces"),
        ("s113-trail-cr",    mutate_cell("S113", 16, lambda v: v + "\r"), ("FAILED", "any:capture-whitespace|cr-in-tsv"), "S113 +CR"),
        ("s113-comma",       mutate_cell("S113", 16, lambda v: v + "," + v), "SC_CAPTURE capture-whitespace", "S113 comma"),
        ("s113-slashslash",  mutate_cell("S113", 16, lambda v: "//etc/passwd"), "SC_CAPTURE capture-token", "S113 //"),
        ("s113-tilde",       mutate_cell("S113", 16, lambda v: "~/S113.body"), "SC_CAPTURE capture-token", "S113 ~/"),
    ]
    # spelling variants of the waves directory on a bound row (binding-disengage family)
    cases += [
        ("spell-double-slash", mutate_cell("S113", 16, lambda v: v.replace(".ufo/waves/", ".ufo//waves/", 1)), None, "S113 .ufo//waves/..."),
        ("spell-dot-dir",      mutate_cell("S113", 16, lambda v: v.replace(".ufo/waves/", ".ufo/./waves/", 1)), None, "S113 .ufo/./waves/..."),
        ("spell-symlink-dir",  (lambda tree: (os.symlink("waves", os.path.join(tree, ".ufo/wv")) if not os.path.lexists(os.path.join(tree, ".ufo/wv")) else None) or set_cell(tree, "S113", 16, ".ufo/wv/round-55/capture/S113.body")), None, "S113 via .ufo/wv symlink dir"),
        ("spell-uppercase",    mutate_cell("S113", 16, lambda v: v.replace(".ufo/waves/", ".UFO/waves/", 1)), None, "S113 .UFO/waves/..."),
    ]
    # over-capture probes on a prose row
    cases += [
        ("over-doubleslash-prose", mutate_cell(prose_id, 16, lambda v: "see //example.org/x for details"), None, "prose cell containing // token"),
        ("over-tilde-prose",       mutate_cell(prose_id, 16, lambda v: "home ~/notes/x"), None, "prose cell containing ~/ token"),
        ("prose-ufo-prompts",      mutate_cell(prose_id, 16, lambda v: "/home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-44.md"), None, "fleet-root prompts path (S099 shape)"),
    ]
    # ceilings
    cases += [
        ("ceil-multilink", m_hardlink(ANCHOR, A), None, "hardlink"),
        ("ceil-norm-tamper-naive", m_norm_tamper, None, "in-tree normalizer lies on digest+locate"),
        ("ceil-norm-tamper-smart", m_norm_tamper_smart, None, "in-tree normalizer forwards digest, lies on locate"),
        ("ceil-short-quote", mutate_cell(ANCHOR, 13, lambda v: "the"), None, "one-token quote"),
        ("s099-exact-prose", mutate_cell(prose_id, 16, lambda v: ".ufo/prompts/kagi-round-44.md \u00a76 item 9, line 561 (byte offset 52924)"), None, "S099 exact cell shape"),
    ]

    if args.only:
        keep = set(args.only.split(","))
        cases = [c for c in cases if c[0] in keep]

    for cid, fn, expect, note in cases:
        case(cid, fn, expect, note)

    out = os.path.join(S, "receipts", f"results-{args.tag}.json")
    with open(out, "w") as f:
        json.dump({"snapshot": meta, "anchor": ANCHOR, "token_anchor": TOK_ANCHOR,
                   "donor": donor[0] if donor else None, "prose_row": prose_id,
                   "independent_counts": independent_counts(snap),
                   "results": results}, f, indent=1)
    with open(os.path.join(S, "receipts", f"results-{args.tag}.tsv"), "w") as f:
        f.write("case\tside\trc\tmet\texpect\tcaptures\tcensus\tfindings\n")
        for r in results:
            f.write("\t".join(str(r.get(k, "")) for k in ("case","side","rc","met","expect","captures","census"))
                    + "\t" + "; ".join(r.get("findings", [])) + "\n")
    print(f"wrote receipts/results-{args.tag}.{{json,tsv}} ; gate={meta['gate_sha256'][:16]}")

if __name__ == "__main__":
    main()
