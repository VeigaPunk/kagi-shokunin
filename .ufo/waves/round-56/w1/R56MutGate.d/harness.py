#!/usr/bin/env python3
"""R56MutGate: single-conjunct mutant sweep over corpus/recheck-replay.py and the
frozen counter plans/round-56-c1.sh. Baseline bytes come from the scratch clone at
42070de (lane HEAD). Every mutant is a single literal replacement; the harness
asserts the source text is present exactly once.
"""
import hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path

S = Path("/fast/scratch/hyaku/kagi-r56/R56MutGate")
CLONE = S / "clone"
BASE_TREE = S / "trees/base"
WORK = S / "work"
OUT = S / "out"
GATE = CLONE / "corpus/recheck-replay.py"
COUNTER = CLONE / "plans/round-56-c1.sh"
ENV = dict(os.environ, HYAKU_SCRATCH=str(S))

def sh(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, timeout=600, env=ENV, **kw)

def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

# ---------- manifest helpers ----------
MAN = "corpus/recheck-captures.tsv"

def man_rows(tree):
    lines = (tree / MAN).read_text(encoding="utf-8").splitlines()
    return lines

def set_man_row(tree, sid, **cols):
    lines = man_rows(tree)
    hdr = next(l for l in lines if l.startswith("id\t")).split("\t")
    out, n = [], 0
    for l in lines:
        c = l.split("\t")
        if c and c[0] == sid:
            for k, v in cols.items():
                c[hdr.index(k)] = str(v)
            l = "\t".join(c)
            n += 1
        out.append(l)
    assert n == 1, (sid, n)
    (tree / MAN).write_text("\n".join(out) + "\n", encoding="utf-8")

def body_digest(tree, rel):
    d = (tree / rel).read_bytes()
    return len(d), hashlib.sha256(d).hexdigest()

def rewrite_body(tree, sid, new_bytes):
    lines = man_rows(tree)
    c = next(l.split("\t") for l in lines if l.split("\t")[0] == sid)
    rel = c[2]
    (tree / rel).write_bytes(new_bytes)
    n, h = body_digest(tree, rel)
    set_man_row(tree, sid, bytes=n, sha256=h)
    return rel

# ---------- gate mutants ----------
GATE_MUTANTS = [
    ("M1-drop-set-cookie",
     '    if re.match(rb"HTTP/\\d", data) or re.search(rb"(?im)^set-cookie:", data):',
     '    if re.match(rb"HTTP/\\d", data):'),
    ("M2-drop-http-prefix",
     '    if re.match(rb"HTTP/\\d", data) or re.search(rb"(?im)^set-cookie:", data):',
     '    if re.search(rb"(?im)^set-cookie:", data):'),
    ("M4-skip-sha256",
     '    if hashlib.sha256(data).hexdigest() != row["sha256"]:',
     '    if False:'),
    ("M5-allow-dotdot",
     '    if rel.startswith("/") or ".." in Path(rel).parts or not rel:',
     '    if rel.startswith("/") or not rel:'),
    ("M6-skip-symlink",
     '        if cur.is_symlink():\n            return None, "symlink:%s" % rel',
     '        if False:\n            return None, "symlink:%s" % rel'),
    ("M7-unsupported-as-match",
     '            tally["UNSUPPORTED"] += 1',
     '            tally["MATCH"] += 1'),
    ("M8-grep-fixed-string",
     'res = subprocess.run(["grep", "-c", "-e", arg, str(body)], capture_output=True, timeout=60)',
     'res = subprocess.run(["grep", "-c", "-F", "-e", arg, str(body)], capture_output=True, timeout=60)'),
    ("M9-allow-duplicate-urls",
     '        if cols[1] in rows:',
     '        if False:'),
]

COUNTER_MUTANTS = [
    ("M3-any-registry-status",
     '    if len(rr) != 1 or len(rr[0]) != 11 or rr[0][7] != "mined" or c[3] not in rr[0][1].split():',
     '    if len(rr) != 1 or len(rr[0]) != 11 or c[3] not in rr[0][1].split():'),
    ("M10-drop-11-cell",
     '    if len(rr) != 1 or len(rr[0]) != 11 or rr[0][7] != "mined" or c[3] not in rr[0][1].split():',
     '    if len(rr) != 1 or rr[0][7] != "mined" or c[3] not in rr[0][1].split():'),
    ("M11-weaken-match-regex",
     '    want = re.compile(r"^MATCH %s:\\d+ id=%s form=%s stated=%d replayed=%d$" % (re.escape(c[0]), re.escape(m["id"]), c[2], c[5], c[5]))',
     '    want = re.compile(r"^MATCH %s:\\d+ id=%s" % (re.escape(c[0]), re.escape(m["id"])))'),
]

def mutate_text(src, old, new):
    text = src.read_text(encoding="utf-8")
    n = text.count(old)
    assert n == 1, ("replacement anchor count", n, old[:60])
    return text.replace(old, new)

def new_tree(name):
    d = WORK / name
    if d.exists():
        shutil.rmtree(d)
    shutil.copytree(BASE_TREE, d, symlinks=True)
    return d

# ---------- hostile tree builders ----------
def h_set_cookie(t):
    b = (t / ".ufo/waves/round-56/capture/S054.body").read_bytes()
    rewrite_body(t, "S054", b"set-cookie: s=1\n" + b)

def h_http_prefix(t):
    b = (t / ".ufo/waves/round-56/capture/S054.body").read_bytes()
    rewrite_body(t, "S054", b"HTTP/2 200\r\n" + b)

def h_dotdot(t):
    set_man_row(t, "S054", body_path=".ufo/waves/round-56/capture/../capture/S054.body")

def h_symlink(t):
    p = t / ".ufo/waves/round-56/capture/S054.body"
    real = p.with_name("S054.real")
    p.rename(real)
    os.symlink("S054.real", p)

def h_same_len_byte(t):
    p = t / ".ufo/waves/round-56/capture/S054.body"
    b = bytearray(p.read_bytes())
    i = b.find(b"trufflehog")
    assert i > 0
    b[i] = ord("T")
    # mutate the body but leave the manifest row's bytes/sha256 stale
    p.write_bytes(bytes(b))

def h_extra_unsupported(t):
    (t / "corpus/knowledge/zz-extra.md").write_text(
        "source: S001\nrecheck: 90d — `curl -fsSL 'https://example.test/x' | sed -n 1p` -> 0\n",
        encoding="utf-8")

def h_grep_meta(t):
    p = t / ".ufo/waves/round-56/capture/S067.body"
    b = p.read_bytes()
    old = b"It MUST contain the OAuth 2.0"
    assert b.count(old) == 1, b.count(old)
    rewrite_body(t, "S067", b.replace(old, b"It MUST contain the OAuth 2x0"))

def h_dup_url(t):
    lines = man_rows(t)
    row = next(l for l in lines if l.split("\t")[0] == "S054")
    (t / MAN).write_text("\n".join(lines + [row]) + "\n", encoding="utf-8")

def h_status_drafted(t):
    p = t / "corpus/SOURCES.md"
    text = p.read_text(encoding="utf-8")
    lines = text.splitlines()
    hits = [i for i, l in enumerate(lines) if re.match(r"^ {0,3}\|\s*S101\s*\|", l)]
    assert len(hits) == 1
    cells = [x for x in lines[hits[0]].strip().strip("|").split("|")]
    assert cells[7].strip() == "mined", cells[7]
    cells[7] = " drafted "
    lines[hits[0]] = "|" + "|".join(cells) + "|"
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")

def h_cells_10(t):
    p = t / "corpus/SOURCES.md"
    lines = p.read_text(encoding="utf-8").splitlines()
    hits = [i for i, l in enumerate(lines) if re.match(r"^ {0,3}\|\s*S101\s*\|", l)]
    assert len(hits) == 1
    cells = [x for x in lines[hits[0]].strip().strip("|").split("|")]
    assert len(cells) == 11 and cells[7].strip() == "mined"
    cells = cells[:-1]
    lines[hits[0]] = "|" + "|".join(cells) + "|"
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")

STUB = '''#!/usr/bin/env python3
import sys
PAIRS = [
 ("corpus/knowledge/betterleaks-detection-vs-validation.md","S055"),
 ("corpus/knowledge/cdp-bridge-1password-oidc-workflow.md","S070"),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S101"),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S113"),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S114"),
 ("corpus/knowledge/nist-key-management-guidance-status.md","S074"),
 ("corpus/knowledge/nist-key-management-parts-withdrawal.md","S078"),
 ("corpus/knowledge/oidc-federation-trust-policy.md","S067"),
 ("corpus/knowledge/secret-scanning-detection-vs-validation.md","S054"),
 ("corpus/knowledge/trufflehog-verification-lifecycle.md","S057"),
]
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (stub)")
    sys.exit(0)
for e, i in PAIRS:
    print("MATCH %s:1 id=%s" % (e, i))
print("RECHECK_REPLAY: CLEAN (clocks=%d match=%d mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)" % (len(PAIRS), len(PAIRS)))
sys.exit(0)
'''

def h_stub_gate(t):
    (t / "corpus/recheck-replay.py").write_text(STUB, encoding="utf-8")

GATE_CASES = {
    "M1-drop-set-cookie": h_set_cookie,
    "M2-drop-http-prefix": h_http_prefix,
    "M4-skip-sha256": h_same_len_byte,
    "M5-allow-dotdot": h_dotdot,
    "M6-skip-symlink": h_symlink,
    "M7-unsupported-as-match": h_extra_unsupported,
    "M8-grep-fixed-string": h_grep_meta,
    "M9-allow-duplicate-urls": h_dup_url,
}
COUNTER_CASES = {
    "M3-any-registry-status": h_status_drafted,
    "M10-drop-11-cell": h_cells_10,
    "M11-weaken-match-regex": h_stub_gate,
}

def gate_run(gate_path, tree, selftest):
    cmd = [sys.executable, "-I", "-B", str(gate_path)]
    cmd += ["--selftest"] if selftest else ["--root", str(tree)]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300, cwd=str(S))
    last = (r.stdout.strip().splitlines() or [""])[-1]
    return r.returncode, last, r.stdout

def counter_run(script, tree):
    r = subprocess.run(["bash", str(script), "--tree", str(tree)],
                       capture_output=True, text=True, timeout=900, env=ENV, cwd=str(S))
    line = (r.stdout.strip().splitlines() or [""])[-1]
    return r.returncode, line, r.stdout + r.stderr

results = []
pristine_gate_src = GATE.read_text(encoding="utf-8")
pristine_counter_src = COUNTER.read_text(encoding="utf-8")

# baseline sanity
rc, last, _ = gate_run(GATE, BASE_TREE, True)
base_self = (rc, last)
rc, line, _ = counter_run(COUNTER, BASE_TREE)
base_counter = (rc, line)
print("BASELINE selftest rc=%d last=%s" % base_self)
print("BASELINE counter rc=%d %s" % base_counter)

def record(mid, mu, mut_file, tree_fn, counter_script, counter_side):
    treeP = new_tree(mid + "-P"); tree_fn(treeP)
    treeM = new_tree(mid + "-M"); tree_fn(treeM)
    if not counter_side:
        (treeM / "corpus/recheck-replay.py").write_text(mut_file.read_text(encoding="utf-8"), encoding="utf-8")
    # (A) pristine gate + pristine counter on the hostile tree: hostility witness
    base_rc, base_last, _ = gate_run(CLONE / "corpus/recheck-replay.py", treeP, False)
    base_cnt_rc, base_cnt_line, _ = counter_run(COUNTER, treeP)
    # (B) mutant detector
    self_rc, self_last = None, None
    if not counter_side:
        self_rc, self_last, _ = gate_run(mut_file, treeM, True)
    gate_clean_m = "RECHECK_REPLAY: CLEAN" in gate_run(treeM / "corpus/recheck-replay.py", treeM, False)[1]
    m_cnt_rc, m_cnt_line, full = counter_run(counter_script, treeM)
    m = re.search(r"value=(\S+)", m_cnt_line)
    b = re.search(r"value=(\S+)", base_cnt_line)
    rec = dict(id=mid, mutation=mu,
               gate_sha256=(sha(mut_file) if mut_file else sha(treeM / "corpus/recheck-replay.py")),
               counter_sha256=sha(counter_script),
               pristine_gate_rc_on_tree=base_rc, pristine_gate_last=base_last,
               pristine_counter_value=(b.group(1) if b else None), pristine_counter_line=base_cnt_line.strip(),
               selftest_rc=self_rc, selftest_last=self_last,
               mutant_counter_value=(m.group(1) if m else None), mutant_counter_line=m_cnt_line.strip(),
               mutant_counter_rc=m_cnt_rc,
               mutant_gate_clean=gate_clean_m)
    results.append(rec)
    (OUT / (mid + ".log")).write_text(full, encoding="utf-8")
    print(json.dumps(rec, ensure_ascii=False))

for mid, old, new in GATE_MUTANTS:
    text = mutate_text(GATE, old, new)
    mf = WORK / ("gate-" + mid + ".py")
    mf.write_text(text, encoding="utf-8")
    record(mid, {"anchor": old, "replacement": new}, mf, GATE_CASES[mid], COUNTER, False)

for mid, old, new in COUNTER_MUTANTS:
    text = mutate_text(COUNTER, old, new)
    cf = CLONE / "plans" / ("round-56-c1-" + mid + ".sh")
    cf.write_text(text, encoding="utf-8")
    record(mid, {"anchor": old, "replacement": new}, None, COUNTER_CASES[mid], cf, True)

(OUT / "results.json").write_text(json.dumps({"baseline_selftest": base_self,
                                              "baseline_counter": base_counter,
                                              "results": results}, indent=2) + "\n", encoding="utf-8")
print("WROTE", OUT / "results.json")
