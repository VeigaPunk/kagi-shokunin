import csv,io,pathlib,shutil,subprocess,sys,hashlib
base=pathlib.Path(sys.argv[1]); anchor_id=sys.argv[2]; outdir=pathlib.Path(sys.argv[3])
outdir.mkdir(parents=True,exist_ok=True)
def rows_of(p): return list(csv.reader(io.StringIO(p.read_text()),delimiter='\t'))
def write(p,rows): p.write_text('\n'.join('\t'.join(r) for r in rows)+'\n')
def prep(name):
    d=outdir/name
    if d.exists(): shutil.rmtree(d)
    shutil.copytree(base,d,symlinks=True)
    return d
def anchor_row(d):
    for r in rows_of(d/"corpus/source-fetches.tsv"):
        if r and r[0]==anchor_id and len(r)==16: return r
def run(d):
    p=subprocess.run(["bash","corpus/sources-census.sh","verify","--root","."],cwd=d,capture_output=True,text=True)
    return p.returncode, p.stdout
def leg(name, mut, expect):
    d=prep(name); mut(d)
    rc,out=run(d)
    finds=[l for l in out.splitlines() if l.startswith("FINDING") and ("id="+anchor_id in l or "cr-in-tsv" in l)]
    caps=[l for l in out.splitlines() if l.startswith("SOURCES_CAPTURES:")]
    census=[l for l in out.splitlines() if l.startswith("SOURCES_CENSUS:")]
    caught = rc==1 and any(("SOURCES_CENSUS: FAILED" in c) for c in census) and any(expect in f for f in finds)
    print(f"leg {name}: rc={rc} caught={int(caught)} expect={expect}")
    print("  captures:", caps[0] if caps else "(none)")
    print("  census:", census[0] if census else "(none)")
    for f in finds[:6]: print("  ", f)
    return int(caught)
def m1(d):
    p=d/"corpus/source-fetches.tsv"; rs=rows_of(p)
    for r in rs:
        if r and r[0]==anchor_id and len(r)==16: r[15]=r[15]+" "
    write(p,rs)
def m2(d):
    p=d/"corpus/source-fetches.tsv"; rs=rows_of(p)
    for r in rs:
        if r and r[0]==anchor_id and len(r)==16: r[15]=r[15]+","+r[15]
    write(p,rs)
def m3(d):
    p=d/"corpus/source-fetches.tsv"; b=p.read_bytes().replace(b"\r\n",b"\n").replace(b"\n",b"\r\n"); p.write_bytes(b)
def m4(d):
    p=d/"corpus/source-fetches.tsv"; rs=rows_of(p)
    for r in rs:
        if r and r[0]==anchor_id and len(r)==16:
            h=list(r[9]); h[0]='f' if h[0]!='f' else 'e'; r[9]=''.join(h)
    write(p,rs)
def m5(d):
    p=d/"corpus/source-fetches.tsv"; rs=rows_of(p)
    other="652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b"
    for r in rs:
        if r and r[0]==anchor_id and len(r)==16: r[14]=other
    write(p,rs)
def m6(d):
    cap=anchor_row(d)[15]; b=(d/cap).read_bytes(); (d/cap).write_bytes(b+b"\x00")
caught=0
caught+=leg("M1",m1,"capture-whitespace")
caught+=leg("M2",m2,"capture-whitespace")
caught+=leg("M3",m3,"cr-in-tsv")
caught+=leg("M4",m4,"capture-digest-mismatch")
caught+=leg("M5",m5,"normalized-digest-mismatch")
caught+=leg("M6",m6,"capture-bytes-mismatch")
print(f"LEGS {anchor_id}: caught={caught}/6")
