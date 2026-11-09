import glob, os, re, subprocess, json
ROOT="/home/vgpnk/Projects/shokunin"
lanes={os.path.basename(p):p for p in glob.glob(os.path.join(ROOT,"*-shokunin")) if os.path.isdir(p)}
PAT=re.compile(r"\.ufo/waves/([A-Za-z0-9._*-]+)/final/([A-Za-z0-9._*-]+)")
PREFIX=re.compile(r"([a-z0-9-]+-shokunin)/$")
reports=sorted(glob.glob(os.path.join(ROOT,".ufo/reports/**/*.md"),recursive=True))
def hist(lane,path):
    return subprocess.run(["git","-C",lanes[lane],"log","--all","--oneline","--",path],
                          capture_output=True,text=True).stdout.strip()
rows=[]
for rp in reports:
    base=os.path.basename(rp)[:-3]
    lane=base+"-shokunin"
    if lane not in lanes: continue
    rel=os.path.relpath(rp,ROOT)
    for i,line in enumerate(open(rp,encoding="utf-8",errors="replace"),1):
        for m in PAT.finditer(line):
            own=lane
            pm=PREFIX.search(line[max(0,m.start()-40):m.start()])
            if pm and pm.group(1) in lanes: own=pm.group(1)
            rows.append((rel,i,own,lane,m.group(0)))
dead=[]
for rel,i,own,citing,path in rows:
    if hist(own,path): continue
    other=[ln for ln in lanes if ln!=own and subprocess.run(["git","-C",lanes[ln],"cat-file","-e","HEAD:"+path],capture_output=True).returncode==0]
    dead.append((rel,i,own,citing,path,other))
print("reports_scanned",len(reports),"citations",len(rows),"pairs",len(set((r[2],r[4]) for r in rows)))
print("dead",len(dead),"dead_pairs",len(set((d[2],d[4]) for d in dead)))
for d in dead: print("DEAD\t%s:%d\town=%s\tciting=%s\t%s\tother=%s"%(d[0],d[1],d[2],d[3],d[4],",".join(d[5]) or "none"))
