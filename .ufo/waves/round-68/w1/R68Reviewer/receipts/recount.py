import csv, hashlib, re, subprocess, sys, pathlib
root=pathlib.Path(sys.argv[1])
def digest(f):
    r=subprocess.run(["python3",str(root/"corpus/rendered-text-v1.py"),"digest",str(f)],capture_output=True,text=True)
    m=re.search(r"normalized_sha256=([0-9a-f]{64})",r.stdout); return m.group(1) if m else None
def locate(f,q):
    r=subprocess.run(["python3",str(root/"corpus/rendered-text-v1.py"),"locate",str(f),q],capture_output=True,text=True)
    m=re.search(r"count=(\d+)",r.stdout); return int(m.group(1)) if m else None
rows=[r for r in csv.reader(open(root/"corpus/source-fetches.tsv",newline=''),delimiter='\t') if len(r)==16]
legal=[];literal=[];legal15=0;lit15=0
for r in rows:
    toks=re.split(r"\s+",r[15].strip())
    cand=[t for t in toks if t.startswith(".ufo/waves/")]
    if not cand: continue
    f=root/cand[0]
    if not (f.is_file() and hashlib.sha256(f.read_bytes()).hexdigest()==r[9] and len(f.read_bytes())==int(r[10])): continue
    if (locate(f,r[12]) or 0)<1: continue
    literal.append(r[0])
    if r[15]==cand[0] and len(cand)==1: legal.append(r[0])
    if r[13]=="rendered-text-v1":
        if digest(f)==r[14]:
            lit15+=1
            if r[15]==cand[0] and len(cand)==1: legal15+=1
print(f"{sys.argv[2]}: literal_verified={len(literal)} literal_col15={lit15} legal_verified={len(legal)} legal_col15={legal15}")
print(" literal_only:", sorted(set(literal)-set(legal)))
