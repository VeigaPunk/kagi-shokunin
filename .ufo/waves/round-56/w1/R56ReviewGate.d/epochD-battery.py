#!/usr/bin/env python3
"""Epoch-D (d3623187) battery: re-test the open findings and the C header regression.

`dt` = git archive d3623187 (corpus + captures). The D normalizer is unchanged
(14f6ca6a), so the same fixtures can be run against the epoch-C gate copy
(`epochC-gate-e9b7e4b7.py`) for a C-vs-D header contrast.
"""
import hashlib, os, pathlib, shutil, subprocess, sys

S = pathlib.Path("/fast/scratch/hyaku/kagi-r56/R56ReviewGate")
D = pathlib.Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-56/w1/R56ReviewGate.d")
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
DT = S / "dt"
GATE_C = D / "epochC-gate-e9b7e4b7.py"
HDR = ["id", "url", "body_path", "fetched", "http_status", "bytes", "sha256"]
ENV = {**os.environ, "HYAKU_SCRATCH": str(S / "sc")}

def sh(argv, env=None, timeout=900):
    return subprocess.run(argv, capture_output=True, text=True, env=env, timeout=timeout)

def clone(name):
    d = S / name
    if d.exists(): shutil.rmtree(d)
    shutil.copytree(DT, d)
    return d

def gate(gatefile, root, env=None):
    r = sh([sys.executable, "-I", "-B", str(gatefile), "--root", str(root)], env=env)
    lines = [l for l in r.stdout.splitlines() if l.strip()]
    return r.returncode, (lines[-1] if lines else "<no stdout>"), (r.stderr.strip().splitlines() or [""])[-1][:100]

def counter(tree):
    r = sh(["bash", LANE + "/plans/round-56-c1.sh", "--tree", str(tree)], env=ENV)
    lines = [l for l in r.stdout.splitlines() if l.strip()]
    return r.returncode, (lines[-1] if lines else "<no stdout>")

def minimal(name, entry, body, url="https://example.test/a"):
    root = S / name
    if root.exists(): shutil.rmtree(root)
    (root / "corpus/knowledge").mkdir(parents=True)
    (root / ".ufo/waves/round-56/capture").mkdir(parents=True)
    (root / ".ufo/waves/round-56/capture/x.body").write_bytes(body)
    (root / "corpus/SOURCES.md").write_text("| id | source |\n|---|---|\n| S001 | Doc — %s | docs |\n" % url)
    (root / "corpus/knowledge/e.md").write_text("source: S001\nrecheck: 90d — %s\n" % entry)
    (root / "corpus/rendered-text-v1.py").write_bytes((DT / "corpus/rendered-text-v1.py").read_bytes())
    (root / "corpus/recheck-captures.tsv").write_text("\n".join(["\t".join(HDR), "\t".join(
        ["S001", url, ".ufo/waves/round-56/capture/x.body", "2026-11-07", "200",
         str(len(body)), hashlib.sha256(body).hexdigest()])]) + "\n")
    return root

print("epoch-D gate sha256:", hashlib.sha256((DT / "corpus/recheck-replay.py").read_bytes()).hexdigest())
print("epoch-D counter sha256:", hashlib.sha256(pathlib.Path(LANE + "/plans/round-56-c1.sh").read_bytes()).hexdigest())
print()

# F1 residual: pdf-only dead branch on D's 20-case selftest
mt = clone("d-mutPdf")
t = (DT / "corpus/recheck-replay.py").read_text()
t2 = t.replace('''        if kind == "pdf":
            txt = subprocess.run''', '''        if kind == "pdf":
            return 1, None
            txt = subprocess.run''', 1)
assert t2 != t
(mt / "corpus/recheck-replay.py").write_text(t2)
r = sh([sys.executable, "-I", "-B", str(mt / "corpus/recheck-replay.py"), "--selftest"])
lines = [l for l in r.stdout.splitlines() if l.strip()]
print("F1 pdf-only-dead selftest rc=%d last=%s fails=%s" % (r.returncode, (lines[-1] if lines else "-")[:60], [l for l in lines if l.startswith("FAIL ")][:3]))
# dead pdf+locate on D (locate should still catch it)
t3 = t.replace("    kind, arg = flt\n    try:", "    kind, arg = flt\n    if kind in (\"pdf\", \"locate\"):\n        return 1, None\n    try:", 1)
ml = clone("d-mutBoth"); (ml / "corpus/recheck-replay.py").write_text(t3)
r = sh([sys.executable, "-I", "-B", str(ml / "corpus/recheck-replay.py"), "--selftest"])
lines = [l for l in r.stdout.splitlines() if l.strip()]
print("F1 pdf+locate-dead selftest rc=%d last=%s fails=%s" % (r.returncode, (lines[-1] if lines else "-")[:60], [l for l in lines if l.startswith("FAIL ")][:3]))
print()

# F8 header variants, D vs C
nd = b"The needle line\nthe needle again\n"
cases = {
 "d-hdr-kanonical-setcookie": b"content\nSet-Cookie: a=b\n" + nd,
 "d-hdr-kanonical-http2": b"preamble\nHttp/2 200\r\n" + nd,
 "d-hdr-trace-upper": b"noise\n< Set-Cookie: x=1\n" + nd,
 "d-hdr-spacecookie": b"content\n set-cookie: a=b\n" + nd,
 "d-hdr-crcookie": b"content\rSet-Cookie: a=b\r" + nd,
}
for name, body in cases.items():
    root = minimal(name, "`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2", body)
    print("F8 %-26s D=%s" % (name, gate(DT / "corpus/recheck-replay.py", root)[:2]))
    print("   %-26s C=%s" % ("", gate(GATE_C, root)[:2]))
print()

# F5 stub normalizer on D
st = clone("d-stub")
(st / "corpus/rendered-text-v1.py").write_text('#!/usr/bin/env python3\nimport sys\nprint("RENDERED_TEXT_V1_LOCATE: count=1")\n')
print("F5 d-stub gate", gate(DT / "corpus/recheck-replay.py", st)[:2])
print("F5 d-stub counter", counter(st))
print()

# F3/F4
sy = clone("d-symentry")
(sy / ".ufo/false-entry.md").write_text("source: S001\nrecheck: 1d — `curl -fsSL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md | grep -c \"omega\"` -> 9\n")
os.symlink("../../.ufo/false-entry.md", sy / "corpus/knowledge/z-false.md")
print("F3 d-symentry", gate(DT / "corpus/recheck-replay.py", sy)[:2])
kl = clone("d-klink"); outside = S / "d-klink-out"
if outside.exists(): shutil.rmtree(outside)
shutil.copytree(DT / "corpus/knowledge", outside)
shutil.rmtree(kl / "corpus/knowledge"); os.symlink("../../d-klink-out", kl / "corpus/knowledge")
print("F4 d-klink", gate(DT / "corpus/recheck-replay.py", kl)[:2])
print()

# F6
e5 = clone("d-e5")
(e5 / "corpus/knowledge/bad.md").write_bytes(b"source: S001\nrecheck: \xff\xfe`curl -fsSL 'x'` -> 1\n")
print("F6 d-e5", gate(DT / "corpus/recheck-replay.py", e5))
pm = clone("d-perm")
os.chmod(pm / "corpus/recheck-captures.tsv", 0o000)
print("F6 d-perm", gate(DT / "corpus/recheck-replay.py", pm))
os.chmod(pm / "corpus/recheck-captures.tsv", 0o644)
print()

# F7
for name, fence in (("d-reg2", False), ("d-fence", True)):
    d = clone(name); p = d / "corpus/SOURCES.md"; out = []
    for l in p.read_text().splitlines(True):
        if l.startswith("| S054 |"):
            cells = [x.strip() for x in l.strip().strip("|").split("|")]
            row = "| S054 | %s |\n" % cells[1]
            out.append(("```\n" + row + "```\n") if fence else row)
        else: out.append(l)
    p.write_text("".join(out))
    print("F7 %-8s gate=%s" % (name, gate(DT / "corpus/recheck-replay.py", d)[:2]))
    print("   %-8s counter=%s" % ("", counter(d)[1][:190]))
print()

# F9
for name, col, val in (("d-404", 4, "404"), ("d-emptyfetched", 3, "")):
    d = clone(name); man = d / "corpus/recheck-captures.tsv"; out = []
    for l in man.read_text().splitlines():
        if l.startswith("S054\t"):
            c = l.split("\t"); c[col] = val; l = "\t".join(c)
        out.append(l)
    man.write_text("\n".join(out) + "\n")
    print("F9 %-14s gate=%s" % (name, gate(DT / "corpus/recheck-replay.py", d)[:2]))
    print("   %-14s counter=%s" % ("", counter(d)[1][:150]))
print()

# F10 arity
po = clone("d-poison")
(po / "corpus/recheck-captures.tsv").write_text((po / "corpus/recheck-captures.tsv").read_text() +
    "S999\thttps://unused.test/x\t.ufo/waves/round-56/capture/none\t2026-11-07\t200\t0\tabc\textra\n")
print("F10 d-poison", gate(DT / "corpus/recheck-replay.py", po)[:2])
print()

# F12 locale
loc = minimal("d-locale", "`curl -fsSL 'https://example.test/a' | grep -c 'a.c'` -> 1", "a\u00e9c\n".encode())
for lc in ("C.UTF-8", "C"):
    e = {**os.environ, "LC_ALL": lc}
    print("F12 LC_ALL=%-8s %s" % (lc, gate(DT / "corpus/recheck-replay.py", loc, e)[:2]))
