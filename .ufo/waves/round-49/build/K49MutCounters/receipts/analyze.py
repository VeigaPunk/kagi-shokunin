import pathlib, re, sys, json
S = pathlib.Path("/fast/scratch/hyaku/kagi-r49/K49MutCounters")
EXP = {}
for line in (S/"lane/plans/round-49-controls.sh").read_text().splitlines():
    m = re.search(r'\[(k[12]-[a-z0-9]+)\]=([0-9]+|SETUP)', line)
    if m: EXP[m.group(1)] = m.group(2)
def parse(p):
    txt = p.read_text()
    rows = {}
    for line in txt.splitlines():
        m = re.match(r'^CONTROL (\S+) expected=(\S+) observed=(\S+) (MATCH|MISMATCH)', line)
        if m: rows[m.group(1)] = dict(expected=m.group(2), observed=m.group(3), verdict=m.group(4), line=line)
    fin = next((l for l in txt.splitlines() if l.startswith('CONTROLS: ')), 'CONTROLS: <none>')
    return rows, fin
files = sorted((S/"out").glob("*.txt"))
print(f"{'suite':34s} {'controls':>8s} {'mismatch':>8s}  killed-by")
for p in files:
    rows, fin = parse(p)
    bad = [k for k,v in rows.items() if v['verdict']=='MISMATCH']
    print(f"{p.stem:34s} {len(rows):8d} {len(bad):8d}  {','.join(bad) if bad else '-'}")
    print(f"    {fin}")
