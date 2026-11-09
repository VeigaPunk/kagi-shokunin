import glob, os, re, subprocess, json, collections
ROOT="/home/vgpnk/Projects/shokunin"
lanes={os.path.basename(p):p for p in glob.glob(os.path.join(ROOT,"*-shokunin")) if os.path.isdir(p)}
PAT=re.compile(r"\.ufo/waves/([A-Za-z0-9._-]+)/final/([A-Za-z0-9._-]+)")
reports=sorted(glob.glob(os.path.join(ROOT,".ufo/reports/round-*/*.md")))
def run(args):
    return subprocess.run(args,capture_output=True,text=True).stdout
hist={}
def history(lane,path):
    k=(lane,path)
    if k in hist: return hist[k]
    out=run(["git","-C",lanes[lane],"log","--all","--oneline","--",path]).strip()
    hist[k]=out
    return out
rows=[]
for rp in reports:
    base=os.path.basename(rp)[:-3]
    lane=base+"-shokunin"
    if lane not in lanes: continue
    rel=os.path.relpath(rp,ROOT)
    with open(rp,encoding="utf-8",errors="replace") as f:
        for i,line in enumerate(f,1):
            for m in PAT.finditer(line):
                path=m.group(0)
                rows.append((rel,i,lane,path))
dead=[]
for rel,i,lane,path in rows:
    if history(lane,path): continue
    other=[]
    for ln,lp in lanes.items():
        if ln==lane: continue
        if subprocess.run(["git","-C",lp,"cat-file","-e","HEAD:"+path],capture_output=True).returncode==0:
            other.append(ln)
    dead.append((rel,i,lane,path,other))
print("reports_scanned",len(reports))
print("citations",len(rows),"distinct_pairs",len(set((r[2],r[3]) for r in rows)))
print("dead_rows",len(dead),"dead_distinct",len(set((d[2],d[3]) for d in dead)))
for d in dead:
    print("DEAD\t%s:%d\t%s\t%s\tother_lane=%s"%(d[0],d[1],d[2],d[3],",".join(d[4]) or "none"))
json.dump({"dead":[{"report":d[0],"line":d[1],"lane":d[2],"path":d[3],"other_lane":d[4]} for d in dead]},open("dead.json","w"),indent=1)
