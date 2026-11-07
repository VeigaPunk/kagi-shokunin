#!/usr/bin/env python3
"""locate-form probes on the FROZEN gate: stub helper, missing helper, real helper."""
import hashlib, pathlib, shutil, subprocess, sys
S = pathlib.Path("/fast/scratch/hyaku/kagi-r56/R56ReviewGate")
GATE = str(pathlib.Path(__file__).resolve().parent / "frozen-gate.py")
HDR = ["id","url","body_path","fetched","http_status","bytes","sha256"]
def tree(name, helper=None):
    root = S/"mut"/name
    if root.exists(): shutil.rmtree(root)
    (root/"corpus/knowledge").mkdir(parents=True); (root/".ufo").mkdir()
    body = b"alpha\nbeta\n"                      # 'needle' occurs 0 times
    (root/".ufo/b.body").write_bytes(body)
    (root/"corpus/SOURCES.md").write_text("| id | source |\n|---|---|\n| S001 | Doc — https://example.test/a | docs |\n")
    entry = "`curl -fsSL 'https://example.test/a' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'needle'` -> 1"
    (root/"corpus/knowledge/e.md").write_text("source: S001\nrecheck: 90d — %s\n" % entry)
    if helper is not None: (root/"corpus/rendered-text-v1.py").write_text(helper)
    (root/"corpus/recheck-captures.tsv").write_text("\n".join(["\t".join(HDR), "\t".join(
        ["S001","https://example.test/a",".ufo/b.body","2026-11-07","200",str(len(body)),hashlib.sha256(body).hexdigest()])])+"\n")
    return root
cases = {
 "locate-real": (S/"base/corpus/rendered-text-v1.py").read_text(),
 "locate-stub": '#!/usr/bin/env python3\nimport sys\nprint("RENDERED_TEXT_V1_LOCATE: count=1")\n',
 "locate-nohelper": None,
}
for name, helper in cases.items():
    root = tree(name, helper)
    r = subprocess.run([sys.executable,"-I","-B",GATE,"--root",str(root)],capture_output=True,text=True)
    lines=[l for l in r.stdout.splitlines() if l.strip()]
    print("%-16s rc=%d %s" % (name, r.returncode, lines[-1] if lines else "<no stdout>"))
