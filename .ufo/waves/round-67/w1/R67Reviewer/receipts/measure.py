import hashlib, os, re, subprocess, sys, json
LANE="/home/vgpnk/Projects/shokunin/kagi-shokunin"
tsv=sys.argv[1] if len(sys.argv)>1 else os.path.join(LANE,"corpus/source-fetches.tsv")
SHAPE=re.compile(r'^[A-Za-z0-9._][A-Za-z0-9._/-]*$')
rows=[]
for ln,line in enumerate(open(tsv,encoding='utf-8'),1):
    line=line.rstrip('\n')
    if not line or line.startswith('#'): 
        rows.append((ln,None,line)); continue
    f=line.split('\t')
    rows.append((ln,f,line))
def classify(loc):
    if loc is None: return 'comment'
    if loc!='' and '/' in loc and SHAPE.match(loc): return 'path'
    if loc=='': return 'empty'
    return 'prose'
def rowhash(path):
    h=hashlib.sha256()
    with open(path,'rb') as fh:
        for b in iter(lambda: fh.read(1<<20), b''): h.update(b)
    return h.hexdigest()
def locate(body,quote,norm):
    if norm=='raw-literal-v1':
        data=open(body,'rb').read()
        try: return data.count(quote.encode())
        except: return -1
    r=subprocess.run(['python3',os.path.join(LANE,'corpus/rendered-text-v1.py'),'locate',body,quote],capture_output=True,text=True,cwd=LANE)
    m=re.search(r'count=(\d+)',r.stdout)
    return int(m.group(1)) if m else -1
res={'comment':0,'empty':0,'prose':0,'path':0,'bound':0,'located':0,'bound_fail':[],'locate_fail':[],'quote_rc2':[]}
for ln,f,raw in rows:
    if f is None: res['comment']+=1; continue
    if len(f)!=16: res['bad_nf']=res.get('bad_nf',0)+1; continue
    loc=f[15]; c=classify(loc); res[c]+=1
    if c!='path': continue
    rid=f[0]; p=os.path.join(LANE,loc)
    ok=os.path.isfile(p)
    if ok:
        ok = rowhash(p)==f[9] and os.path.getsize(p)==int(f[10])
    if ok: res['bound']+=1
    else: res['bound_fail'].append((rid,loc,os.path.isfile(p)))
    cnt=locate(p,f[12],f[13]) if os.path.isfile(p) else -1
    if cnt>=1: res['located']+=1
    else: res['locate_fail'].append((rid,loc,cnt,f[12]))
print(json.dumps(res,indent=1))
