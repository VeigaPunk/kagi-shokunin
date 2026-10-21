import hashlib, json, sys
sys.argv=["x"]; import forge
from forge import *
root, rpath, _ = build("F1-sops+SOURCES+fabricated-body", lower(SOPS, "3.13.2"), anchor_sub("S033", "3.13.3", "3.13.2"))
real = forge.BODIES[[l.split("\t")[9] for l in (BASE/"corpus/source-fetches.tsv").read_text().splitlines() if l.startswith("S033\t")][0]].read_bytes()
fake = real.replace(b"v3.13.3", b"v3.13.2")
fpath = root / "fake.atom"; fpath.write_bytes(fake); fsha = hashlib.sha256(fake).hexdigest(); forge.BODIES[fsha] = fpath
r = json.loads(rpath.read_text())
for rec in r["observations"]:
    if rec["id"] in SOPS: rec["sha256"] = fsha
rpath.write_text(json.dumps(r, indent=2) + "\n"); sha = hashlib.sha256(rpath.read_bytes()).hexdigest()
sf = root/"corpus/source-fetches.tsv"; lines = sf.read_text().splitlines(keepends=True)
for i,l in enumerate(lines):
    if l.startswith("S033\t"):
        f=l.rstrip("\n").split("\t"); f[9]=fsha; f[12]="<title>v3.13.2</title>"; lines[i]="\t".join(f)+"\n"
sf.write_text("".join(lines))
src=root/"corpus/SOURCES.md"; src.write_text(src.read_text().replace("“<title>v3.13.3</title>” (first stable entry)","“<title>v3.13.2</title>” (first stable entry)"))
sources=clock.parse_sources(root); rows=clock.parse_bindings(root); rec=clock.load_receipt_bundle(rpath, sha)
b=clock.evaluate(sources, rows, clock.parse_captures(root), rec)
print("base", b["passed"], b["derived"])
for rule in ("NAMED","EXACT","COH","BODY","SERVES"):
    e=sorted(set(b["errors"])|extra(rule, root, sources, rows, rec)); print(rule, "CLEAN" if not e and b["passed"] else e)
import subprocess; c=subprocess.run(["bash",str(BASE/"corpus/sources-census.sh"),"verify","--root",str(root)],capture_output=True,text=True); print("census", c.returncode, c.stdout.strip().splitlines()[-1], [l for l in c.stdout.splitlines() if l.startswith("FINDING")])
