import subprocess, sys, os, pathlib
tree = pathlib.Path("/fast/scratch/hyaku/kagi-r47/K47CriticCeiling/tree")
quotes = {}
for line in open(tree/"corpus/source-fetches.tsv", encoding="utf-8"):
    if line.startswith("#"): continue
    c = line.rstrip("\n").split("\t")
    if c[0] in ("S012","S013","S014","S015","S016","S021","S022","S023","S024","S025","S026"):
        quotes[c[0]] = c[12]
cands = []
for p in tree.rglob("*"):
    if p.is_file() and p.suffix in (".html",".htm",".body") and "/round-47/" not in str(p):
        cands.append(p)
cands.sort()
print("candidates:", len(cands))
for cid, q in quotes.items():
    hits = []
    for p in cands:
        r = subprocess.run([sys.executable, str(tree/"corpus/rendered-text-v1.py"), "locate", str(p), q], capture_output=True, text=True)
        if r.returncode == 0 and "count=" in r.stdout:
            out = r.stdout.strip().splitlines()[-1]
            hits.append((str(p.relative_to(tree)), out))
    print("==", cid, "hits:", len(hits))
    for h in hits[:12]:
        print("   ", h[0], "|", h[1][:120])
