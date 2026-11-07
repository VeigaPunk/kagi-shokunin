#!/usr/bin/env python3
"""Epoch-C (commit 711e6393) battery for R56ReviewGate: which A/B findings survive.

Builds fixtures from `ct` (git archive 711e6393 corpus + captures) under
/fast/scratch/hyaku/kagi-r56/R56ReviewGate, runs the epoch-C gate and the epoch-C
counter, and prints one line per case. Counter invocations use HYAKU_SCRATCH under
the same scratch root.
"""
import hashlib, os, pathlib, re, shutil, subprocess, sys

S = pathlib.Path("/fast/scratch/hyaku/kagi-r56/R56ReviewGate")
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
CT = S / "ct"
GATE = CT / "corpus/recheck-replay.py"
HDR = ["id", "url", "body_path", "fetched", "http_status", "bytes", "sha256"]
ENV = {**os.environ, "HYAKU_SCRATCH": str(S / "sc")}

def sh(argv, **kw):
    return subprocess.run(argv, capture_output=True, text=True, **kw)

def clone(name):
    d = S / name
    if d.exists(): shutil.rmtree(d)
    shutil.copytree(CT, d)
    return d

def gate(root, timeout=300):
    r = sh([sys.executable, "-I", "-B", str(root / "corpus/recheck-replay.py"), "--root", str(root)], timeout=timeout)
    lines = [l for l in r.stdout.splitlines() if l.strip()]
    return r.returncode, (lines[-1] if lines else "<no stdout>"), r.stderr.strip().splitlines()[-1:] 

def counter(tree):
    r = sh(["bash", LANE + "/plans/round-56-c1.sh", "--tree", str(tree)], env=ENV, timeout=900)
    lines = [l for l in r.stdout.splitlines() if l.strip()]
    return r.returncode, (lines[-1] if lines else "<no stdout>")

def minimal(name, entry, body, url="https://example.test/a", helper=None):
    root = S / name
    if root.exists(): shutil.rmtree(root)
    (root / "corpus/knowledge").mkdir(parents=True)
    (root / ".ufo/waves/round-56/capture").mkdir(parents=True)
    (root / ".ufo/waves/round-56/capture/x.body").write_bytes(body)
    (root / "corpus/SOURCES.md").write_text(
        "| id | source |\n|---|---|\n| S001 | Doc — %s | docs |\n" % url)
    (root / "corpus/knowledge/e.md").write_text("source: S001\nrecheck: 90d — %s\n" % entry)
    (root / "corpus/rendered-text-v1.py").write_bytes((CT / "corpus/rendered-text-v1.py").read_bytes())
    (root / "corpus/recheck-captures.tsv").write_text("\n".join(["\t".join(HDR), "\t".join(
        ["S001", url, ".ufo/waves/round-56/capture/x.body", "2026-11-07", "200",
         str(len(body)), hashlib.sha256(body).hexdigest()])]) + "\n")
    return root

print("epoch-C gate sha256:", hashlib.sha256(GATE.read_bytes()).hexdigest())
print("epoch-C counter sha256:", hashlib.sha256(pathlib.Path(LANE + "/plans/round-56-c1.sh").read_bytes()).hexdigest())
print()

# F1: dead pdf/locate branches vs the 18-case selftest
mut_tree = clone("c-mutA")
t = GATE.read_text()
t2 = t.replace("    kind, arg = flt\n    try:", "    kind, arg = flt\n    if kind in (\"pdf\", \"locate\"):\n        return 1, None\n    try:", 1)
assert t2 != t
mut = mut_tree / "corpus/recheck-replay.py"
mut.write_text(t2)
st = sh([sys.executable, "-I", "-B", str(mut), "--selftest"])
sl = [l for l in st.stdout.splitlines() if l.strip()]
print("F1 mutantA selftest rc=%d last=%s" % (st.returncode, sl[-1] if sl else "-"))
print("   failing lines:", [l for l in sl if l.startswith("FAIL ")][:5])
print()

# F5: stub normalizer
stub = clone("c-stub")
(stub / "corpus/rendered-text-v1.py").write_text('#!/usr/bin/env python3\nimport sys\nprint("RENDERED_TEXT_V1_LOCATE: count=1")\n')
body = (stub / ".ufo/waves/round-56/capture/S055.body").read_bytes() + b"\n"
(stub / ".ufo/waves/round-56/capture/S070-synth.body").write_bytes(body)
man = stub / "corpus/recheck-captures.tsv"
out = []
for l in man.read_text().splitlines():
    if l.startswith("S070\t"):
        c = l.split("\t"); c[2] = ".ufo/waves/round-56/capture/S070-synth.body"
        c[5] = str(len(body)); c[6] = hashlib.sha256(body).hexdigest(); l = "\t".join(c)
    out.append(l)
man.write_text("\n".join(out) + "\n")
rc, last, err = gate(stub)
print("F5 c-stub gate rc=%d last=%s" % (rc, last[:150]))
rc2, line2 = counter(stub)
print("F5 c-stub counter %s" % line2[:260])
print()

# F3 / F4: symlinked entry / symlinked knowledge dir
sy = clone("c-symentry")
(sy / ".ufo/false-entry.md").write_text("source: S001\nrecheck: 1d — `curl -fsSL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md | grep -c \"omega\"` -> 9\n")
os.symlink("../../.ufo/false-entry.md", sy / "corpus/knowledge/z-false.md")
rc, last, _ = gate(sy); print("F3 c-symentry gate rc=%d last=%s" % (rc, last[:140]))
kl = clone("c-klink"); outside = S / "c-klink-out"
if outside.exists(): shutil.rmtree(outside)
shutil.copytree(CT / "corpus/knowledge", outside)
shutil.rmtree(kl / "corpus/knowledge"); os.symlink("../../c-klink-out", kl / "corpus/knowledge")
rc, last, _ = gate(kl); print("F4 c-klink gate rc=%d last=%s" % (rc, last[:140]))
print()

# F7: registry 2-cell / fenced rows
for name, fence in (("c-reg2", False), ("c-fence", True)):
    d = clone(name)
    p = d / "corpus/SOURCES.md"; out = []
    for l in p.read_text().splitlines(True):
        if l.startswith("| S054 |"):
            cells = [x.strip() for x in l.strip().strip("|").split("|")]
            row = "| S054 | %s |\n" % cells[1]
            out.append(("```\n" + row + "```\n") if fence else row)
        else: out.append(l)
    p.write_text("".join(out))
    rc, last, _ = gate(d); rc2, line2 = counter(d)
    print("F7 %s gate rc=%d %s" % (name, rc, last[:110]))
    print("   counter %s" % line2[:200])
print()

# F6: non-UTF-8 entry, unreadable manifest
e5 = clone("c-e5")
(e5 / "corpus/knowledge/bad.md").write_bytes(b"source: S001\nrecheck: \xff\xfe`curl -fsSL 'x'` -> 1\n")
print("F6 c-e5 gate", gate(e5))
perm = clone("c-perm")
os.chmod(perm / "corpus/recheck-captures.tsv", 0o000)
print("F6 c-perm gate", gate(perm))
os.chmod(perm / "corpus/recheck-captures.tsv", 0o644)
print()

# F9: http_status 404 / empty fetched
for name, col, val in (("c-404", 4, "404"), ("c-emptyfetched", 3, "")):
    d = clone(name); man = d / "corpus/recheck-captures.tsv"; out = []
    for l in man.read_text().splitlines():
        if l.startswith("S054\t"):
            c = l.split("\t"); c[col] = val; l = "\t".join(c)
        out.append(l)
    man.write_text("\n".join(out) + "\n")
    rc, last, _ = gate(d); rc2, line2 = counter(d)
    print("F9 %s gate rc=%d %s" % (name, rc, last[:120]))
    print("   counter %s" % line2[:180])
print()

# F8: header variants (leading LF before HTTP/, leading-space and CR-only set-cookie)
nd = b"The needle line\nthe needle again\n"
cases = {
 "c-hdr-leadinglf": b"\nHTTP/2 200\r\ncontent-type: x\r\n\r\n" + nd,
 "c-hdr-spacecookie": b"content\n set-cookie: a=b\n" + nd,
 "c-hdr-crcookie": b"content\rSet-Cookie: a=b\r" + nd,
}
for name, body in cases.items():
    root = minimal(name, "`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2", body)
    print("F8 %s gate %s" % (name, gate(root)[:2]))
print()

# F12: locale
loc = minimal("c-locale", "`curl -fsSL 'https://example.test/a' | grep -c 'a.c'` -> 1", "a\u00e9c\n".encode())
for lc in ("C.UTF-8", "C"):
    r = sh([sys.executable, "-I", "-B", str(loc / "corpus/recheck-replay.py"), "--root", str(loc)],
           env={**os.environ, "LC_ALL": lc})
    lines = [l for l in r.stdout.splitlines() if l.strip()]
    print("F12 LC_ALL=%-8s rc=%d %s" % (lc, r.returncode, (lines[-1] if lines else "-")[:120]))
