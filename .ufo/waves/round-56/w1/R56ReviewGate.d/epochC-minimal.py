#!/usr/bin/env python3
"""Epoch-C minimal-fixture probes: header variants, locale, pdf-only mutant."""
import hashlib, os, pathlib, shutil, subprocess, sys
S = pathlib.Path("/fast/scratch/hyaku/kagi-r56/R56ReviewGate")
CT = S / "ct"; GATE = CT / "corpus/recheck-replay.py"
HDR = ["id","url","body_path","fetched","http_status","bytes","sha256"]
def run(gate, root, env=None):
    r = subprocess.run([sys.executable,"-I","-B",str(gate),"--root",str(root)],
                       capture_output=True, text=True, env=env or os.environ)
    lines=[l for l in r.stdout.splitlines() if l.strip()]
    return r.returncode, (lines[-1] if lines else "<no stdout>"), (r.stderr.strip().splitlines() or [""])[-1][:100]
def minimal(name, entry, body, url="https://example.test/a"):
    root=S/name
    if root.exists(): shutil.rmtree(root)
    (root/"corpus/knowledge").mkdir(parents=True); (root/".ufo/waves/round-56/capture").mkdir(parents=True)
    (root/".ufo/waves/round-56/capture/x.body").write_bytes(body)
    (root/"corpus/SOURCES.md").write_text("| id | source |\n|---|---|\n| S001 | Doc — %s | docs |\n" % url)
    (root/"corpus/knowledge/e.md").write_text("source: S001\nrecheck: 90d — %s\n" % entry)
    (root/"corpus/rendered-text-v1.py").write_bytes((CT/"corpus/rendered-text-v1.py").read_bytes())
    (root/"corpus/recheck-captures.tsv").write_text("\n".join(["\t".join(HDR),"\t".join(
        ["S001",url,".ufo/waves/round-56/capture/x.body","2026-11-07","200",str(len(body)),hashlib.sha256(body).hexdigest()])])+"\n")
    return root
nd=b"The needle line\nthe needle again\n"
cases={
 "c-hdr-leadinglf": b"\nHTTP/2 200\r\ncontent-type: x\r\n\r\n"+nd,
 "c-hdr-spacecookie": b"content\n set-cookie: a=b\n"+nd,
 "c-hdr-crcookie": b"content\rSet-Cookie: a=b\r"+nd,
 "c-hdr-trace": b"noise\n< HTTP/1.1 200 OK\n< set-cookie: x=1\n"+nd,
}
for name,body in cases.items():
    root=minimal(name,"`curl -fsSL 'https://example.test/a' | grep -c 'needle'` -> 2",body)
    print("F8 %-18s %s" % (name, run(GATE,root)))
loc=minimal("c-locale","`curl -fsSL 'https://example.test/a' | grep -c 'a.c'` -> 1","a\u00e9c\n".encode())
for lc in ("C.UTF-8","C"):
    e={**os.environ,"LC_ALL":lc}; print("F12 LC_ALL=%-8s %s" % (lc, run(GATE,loc,e)))
# pdf-only dead branch
mut_tree=S/"c-mutPdf"
if mut_tree.exists(): shutil.rmtree(mut_tree)
shutil.copytree(CT,mut_tree)
t=GATE.read_text()
t2=t.replace('''        if kind == "pdf":
            txt = subprocess.run''','''        if kind == "pdf":
            return 1, None
            txt = subprocess.run''',1)
assert t2!=t
(mut_tree/"corpus/recheck-replay.py").write_text(t2)
r=subprocess.run([sys.executable,"-I","-B",str(mut_tree/"corpus/recheck-replay.py"),"--selftest"],capture_output=True,text=True)
lines=[l for l in r.stdout.splitlines() if l.strip()]
print("F1 pdf-only-dead selftest rc=%d last=%s fail=%s" % (r.returncode,(lines[-1] if lines else "-")[:60],[l for l in lines if l.startswith("FAIL ")][:3]))
