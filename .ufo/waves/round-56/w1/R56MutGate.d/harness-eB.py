#!/usr/bin/env python3
"""R56MutGate epoch-B sweep: same single-conjunct mutants against the re-frozen
instruments at 5d9a157 (gate sha256 2e9dfde3…, counter sha256 6b132ea1…).

Detectors per mutant:
  P  = pristine pinned gate + hostile tree + epoch-B counter (hostility witness)
  M  = mutant detector + same hostile tree + epoch-B counter (pin active)
  M' = same mutant tree + a *diagnostic* pin-bypass counter (pin line -> `if true`)
       so the conjunct-level detectors can be read apart from the digest pin.
"""
import hashlib, json, os, re, shutil, subprocess, sys
from pathlib import Path

S = Path("/fast/scratch/hyaku/kagi-r56/R56MutGate-eB")
CLONE = S / "clone"
BASE_TREE = S / "trees/base"
WORK = S / "work"
OUT = S / "out"
GATE = CLONE / "corpus/recheck-replay.py"
COUNTER = CLONE / "plans/round-56-c1.sh"
ENV = dict(os.environ, HYAKU_SCRATCH=str(S))
MAN = "corpus/recheck-captures.tsv"

def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def man_lines(t):
    return (t / MAN).read_text(encoding="utf-8").splitlines()

def set_man_row(t, sid, **cols):
    lines = man_lines(t)
    hdr = next(l for l in lines if l.startswith("id\t")).split("\t")
    out, n = [], 0
    for l in lines:
        c = l.split("\t")
        if c and c[0] == sid:
            for k, v in cols.items():
                c[hdr.index(k)] = str(v)
            l = "\t".join(c); n += 1
        out.append(l)
    assert n == 1
    (t / MAN).write_text("\n".join(out) + "\n", encoding="utf-8")

def rewrite_body(t, sid, data):
    c = next(l.split("\t") for l in man_lines(t) if l.split("\t")[0] == sid)
    rel = c[2]
    (t / rel).write_bytes(data)
    d = (t / rel).read_bytes()
    set_man_row(t, sid, bytes=len(d), sha256=hashlib.sha256(d).hexdigest())

def mutate_text(p, old, new):
    txt = p.read_text(encoding="utf-8")
    assert txt.count(old) == 1, ("anchor count", txt.count(old), old[:70])
    return txt.replace(old, new)

# ---------------- gate mutants (epoch B) ----------------
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
     '        if url is None:\n            tally["UNSUPPORTED"] += 1',
     '        if url is None:\n            tally["MATCH"] += 1'),
    ("M8-grep-fixed-string",
     'res = subprocess.run(["grep", "-c", "-e", arg, str(body)], capture_output=True, timeout=60)',
     'res = subprocess.run(["grep", "-c", "-F", "-e", arg, str(body)], capture_output=True, timeout=60)'),
    ("M9-allow-duplicate-urls",
     '        if cols[1] in rows:',
     '        if False:'),
    ("M12-drop-input-confinement",
     '    inputs = [KNOWLEDGE, REGISTRY, MANIFEST, "corpus/rendered-text-v1.py"]\n'
     '    for rel in inputs:\n'
     '        if not confined(root, rel):\n'
     '            return setup("symlinked-input:%s" % rel)\n',
     ''),
    ("M13-drop-symlinked-entry-row",
     '        if path.is_symlink():\n'
     '            # a symlinked entry is outside the replayable population by contract;\n'
     '            # report it as a clock-less UNSUPPORTED row so the gate cannot go CLEAN\n'
     '            out.append((rel, 0, "<symlinked-entry>", -1))\n'
     '            continue',
     '        if path.is_symlink():\n            continue'),
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
    ("M14-drop-gate-pin",
     '  if [ -n "$GATE_SHA" ] && [ "$GATE_SHA" = "$GATE_SHA256_PIN" ]; then',
     '  if true; then'),
]

# ---------------- hostile trees ----------------
def new_tree(name):
    d = WORK / name
    if d.exists():
        shutil.rmtree(d)
    shutil.copytree(BASE_TREE, d, symlinks=True)
    return d

def h_set_cookie(t):
    b = (t / ".ufo/waves/round-56/capture/S054.body").read_bytes()
    rewrite_body(t, "S054", b"set-cookie: s=1\n" + b)

def h_http_prefix(t):
    b = (t / ".ufo/waves/round-56/capture/S054.body").read_bytes()
    rewrite_body(t, "S054", b"HTTP/2 200\r\n" + b)

def h_stale_sha(t):
    p = t / ".ufo/waves/round-56/capture/S054.body"
    b = bytearray(p.read_bytes())
    i = b.find(b"trufflehog"); assert i > 0
    b[i] = ord("T")
    p.write_bytes(bytes(b))  # byte count unchanged; manifest digest left stale

def h_dotdot(t):
    set_man_row(t, "S054", body_path=".ufo/waves/round-56/capture/../capture/S054.body")

def h_symlink_body(t):
    p = t / ".ufo/waves/round-56/capture/S054.body"
    p.rename(p.with_name("S054.real")); os.symlink("S054.real", p)

def h_extra_unsupported(t):
    (t / "corpus/knowledge/zz-extra.md").write_text(
        "source: S001\nrecheck: 90d — `curl -fsSL 'https://example.test/x' | sed -n 1p` -> 0\n",
        encoding="utf-8")

def h_grep_meta(t):
    p = t / ".ufo/waves/round-56/capture/S067.body"
    b = p.read_bytes(); old = b"It MUST contain the OAuth 2.0"
    assert b.count(old) == 1
    rewrite_body(t, "S067", b.replace(old, b"It MUST contain the OAuth 2x0"))

def h_dup_url(t):
    lines = man_lines(t)
    row = next(l for l in lines if l.split("\t")[0] == "S054")
    (t / MAN).write_text("\n".join(lines + [row]) + "\n", encoding="utf-8")

def h_status_drafted(t):
    p = t / "corpus/SOURCES.md"; lines = p.read_text(encoding="utf-8").splitlines()
    hits = [i for i, l in enumerate(lines) if re.match(r"^ {0,3}\|\s*S101\s*\|", l)]
    assert len(hits) == 1
    cells = [x for x in lines[hits[0]].strip().strip("|").split("|")]
    assert cells[7].strip() == "mined"
    cells[7] = " drafted "; lines[hits[0]] = "|" + "|".join(cells) + "|"
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")

def h_cells_10(t):
    p = t / "corpus/SOURCES.md"; lines = p.read_text(encoding="utf-8").splitlines()
    hits = [i for i, l in enumerate(lines) if re.match(r"^ {0,3}\|\s*S101\s*\|", l)]
    assert len(hits) == 1
    cells = [x for x in lines[hits[0]].strip().strip("|").split("|")]
    assert len(cells) == 11
    lines[hits[0]] = "|" + "|".join(cells[:-1]) + "|"
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")

def h_symlink_registry(t):
    p = t / "corpus/SOURCES.md"
    p.rename(t / "corpus/SOURCES.real"); os.symlink("SOURCES.real", p)

def h_symlink_entry(t):
    p = t / "corpus/knowledge/oidc-federation-trust-policy.md"
    p.rename(t / "corpus/oidc-entry.real")
    os.symlink("../oidc-entry.real", p)

STUB_TRUNC = '''#!/usr/bin/env python3
import sys
PAIRS = [
 ("corpus/knowledge/betterleaks-detection-vs-validation.md","S055",4),
 ("corpus/knowledge/cdp-bridge-1password-oidc-workflow.md","S070",3),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S101",3),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S113",3),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S114",3),
 ("corpus/knowledge/nist-key-management-guidance-status.md","S074",3),
 ("corpus/knowledge/nist-key-management-parts-withdrawal.md","S078",3),
 ("corpus/knowledge/oidc-federation-trust-policy.md","S067",3),
 ("corpus/knowledge/secret-scanning-detection-vs-validation.md","S054",4),
 ("corpus/knowledge/trufflehog-verification-lifecycle.md","S057",4),
]
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (13 cases)"); sys.exit(0)
for e, i, l in PAIRS:
    print("MATCH %s:%d id=%s" % (e, l, i))
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
sys.exit(0)
'''

STUB_FULL = '''#!/usr/bin/env python3
import sys
PAIRS = [
 ("corpus/knowledge/betterleaks-detection-vs-validation.md","S055",4,"grep",1),
 ("corpus/knowledge/cdp-bridge-1password-oidc-workflow.md","S070",3,"locate",1),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S101",3,"grep",2),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S113",3,"grep",3),
 ("corpus/knowledge/iso-11770-3-edition-status.md","S114",3,"grep",2),
 ("corpus/knowledge/nist-key-management-guidance-status.md","S074",3,"grep",1),
 ("corpus/knowledge/nist-key-management-parts-withdrawal.md","S078",3,"pdf",1),
 ("corpus/knowledge/oidc-federation-trust-policy.md","S067",3,"grep",1),
 ("corpus/knowledge/secret-scanning-detection-vs-validation.md","S054",4,"grep",1),
 ("corpus/knowledge/trufflehog-verification-lifecycle.md","S057",4,"grep",1),
]
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (13 cases)"); sys.exit(0)
for e, i, l, f, n in PAIRS:
    print("MATCH %s:%d id=%s form=%s stated=%d replayed=%d" % (e, l, i, f, n, n))
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
sys.exit(0)
'''

def h_trunc_gate(t):
    (t / "corpus/recheck-replay.py").write_text(STUB_TRUNC, encoding="utf-8")

def h_full_gate(t):
    (t / "corpus/recheck-replay.py").write_text(STUB_FULL, encoding="utf-8")

GATE_CASES = {
    "M1-drop-set-cookie": h_set_cookie,
    "M2-drop-http-prefix": h_http_prefix,
    "M4-skip-sha256": h_stale_sha,
    "M5-allow-dotdot": h_dotdot,
    "M6-skip-symlink": h_symlink_body,
    "M7-unsupported-as-match": h_extra_unsupported,
    "M8-grep-fixed-string": h_grep_meta,
    "M9-allow-duplicate-urls": h_dup_url,
    "M12-drop-input-confinement": h_symlink_registry,
    "M13-drop-symlinked-entry-row": h_symlink_entry,
}
COUNTER_CASES = {
    "M3-any-registry-status": h_status_drafted,
    "M10-drop-11-cell": h_cells_10,
    "M11-weaken-match-regex": h_trunc_gate,
    "M14-drop-gate-pin": h_full_gate,
}

def gate_run(p, tree, selftest):
    cmd = [sys.executable, "-I", "-B", str(p)] + (["--selftest"] if selftest else ["--root", str(tree)])
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300, cwd=str(S))
    return r.returncode, ((r.stdout.strip().splitlines() or [""])[-1])

def counter_run(script, tree):
    r = subprocess.run(["bash", str(script), "--tree", str(tree)],
                       capture_output=True, text=True, timeout=900, env=ENV, cwd=str(S))
    line = (r.stdout.strip().splitlines() or [""])[-1]
    return r.returncode, line, r.stdout + r.stderr

pristine_gate = GATE.read_text(encoding="utf-8")
pristine_counter = COUNTER.read_text(encoding="utf-8")
# diagnostic pin-bypass counter (not a candidate instrument)
nopin = CLONE / "plans/round-56-c1-nopin-DIAG.sh"
nopin.write_text(mutate_text(COUNTER, '  if [ -n "$GATE_SHA" ] && [ "$GATE_SHA" = "$GATE_SHA256_PIN" ]; then',
                             '  if true; then'), encoding="utf-8")

results = []
rc, last = gate_run(GATE, BASE_TREE, True)
base_self = [rc, last]
rc, line, _ = counter_run(COUNTER, BASE_TREE)
base_counter = [rc, line]
rc, line, _ = counter_run(nopin, BASE_TREE)
print("BASELINE selftest", base_self, "| counter", base_counter, "| nopin-diag", line)

def record(mid, mu, mut_file, tree_fn, counter_script, counter_side):
    tp = new_tree(mid + "-P"); tree_fn(tp)
    tm = new_tree(mid + "-M"); tree_fn(tm)
    if not counter_side:
        (tm / "corpus/recheck-replay.py").write_text(mut_file.read_text(encoding="utf-8"), encoding="utf-8")
    p_rc, p_last = gate_run(GATE, tp, False)
    p_cnt_rc, p_cnt_line, _ = counter_run(COUNTER, tp)
    self_rc = self_last = None
    if not counter_side:
        self_rc, self_last = gate_run(mut_file, tm, True)
    m_rc, m_last = gate_run(tm / "corpus/recheck-replay.py", tm, False)
    m_cnt_rc, m_cnt_line, full = counter_run(counter_script, tm)
    np_rc, np_line, _ = counter_run(nopin, tm)
    def val(s):
        m = re.search(r"value=(\S+)", s)
        return m.group(1) if m else None
    rec = dict(id=mid, mutation=mu,
               gate_sha256=(sha(mut_file) if mut_file else sha(tm / "corpus/recheck-replay.py")),
               counter_sha256=sha(counter_script),
               P_gate_rc=p_rc, P_gate_last=p_last, P_counter_value=val(p_cnt_line),
               P_counter_line=p_cnt_line.strip(),
               selftest_rc=self_rc, selftest_last=self_last,
               M_gate_rc=m_rc, M_gate_last=m_last,
               M_counter_value=val(m_cnt_line), M_counter_line=m_cnt_line.strip(),
               M_nopin_counter_value=val(np_line), M_nopin_line=np_line.strip())
    results.append(rec)
    (OUT / (mid + ".log")).write_text(full + "\n--- nopin ---\n" + np_line, encoding="utf-8")
    print(json.dumps(rec, ensure_ascii=False))

for mid, old, new in GATE_MUTANTS:
    mf = WORK / ("gate-" + mid + ".py")
    mf.write_text(mutate_text(GATE, old, new), encoding="utf-8")
    record(mid, {"anchor": old, "replacement": new}, mf, GATE_CASES[mid], COUNTER, False)

for mid, old, new in COUNTER_MUTANTS:
    cf = CLONE / "plans" / ("round-56-c1-" + mid + ".sh")
    cf.write_text(mutate_text(COUNTER, old, new), encoding="utf-8")
    record(mid, {"anchor": old, "replacement": new}, None, COUNTER_CASES[mid], cf, True)

(OUT / "results-epochB.json").write_text(json.dumps(
    {"revision": "5d9a1571911ec38a456a40b443e19640abb9a88b",
     "gate_sha256": sha(GATE), "counter_sha256": sha(COUNTER),
     "baseline_selftest": base_self, "baseline_counter": base_counter,
     "results": results}, indent=2) + "\n", encoding="utf-8")
print("WROTE", OUT / "results-epochB.json")
