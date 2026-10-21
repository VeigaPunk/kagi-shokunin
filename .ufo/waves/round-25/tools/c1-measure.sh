#!/usr/bin/env bash
# C1 frozen-revision recorder. --common uses the identical pre-existing
# population on BASE and after; four locators for newly introduced tools are
# excluded explicitly (they have no before-docs or before-ledger IDs).
# Usage: c1-measure.sh [--common] [--mutate ID] TOOL_REV DOCS_REV LABEL
set -euo pipefail
exec python3 -B - "$@" <<'PY'
import pathlib, re, subprocess, sys, tempfile
LANE=pathlib.Path('/home/vgpnk/Projects/shokunin/kagi-shokunin')
a=sys.argv[1:]; common=False; mutant=None
while a and a[0].startswith('--'):
    flag=a.pop(0)
    if flag=='--common':common=True
    elif flag=='--mutate' and a:mutant=a.pop(0)
    else:raise SystemExit('unknown/missing option: '+flag)
if len(a)!=3:raise SystemExit('usage: c1-measure.sh [--common] [--mutate ID] TOOL_REV DOCS_REV LABEL')
tool_rev,docs_rev,label=a
new_ids={'SC-SELFCOUNTS-SELFTEST','SC-CLOCK-SELFTEST','PV-SELFCOUNTS-SELFTEST','PV-CLOCK-SELFTEST'}
with tempfile.TemporaryDirectory(prefix='kagi-r25-c1-',dir='/fast/scratch') as td:
    root=pathlib.Path(td)/'lane'; home=pathlib.Path(td)/'home';home.mkdir()
    subprocess.run(['git','clone','-q','--no-hardlinks',str(LANE),str(root)],check=True)
    subprocess.run(['git','-C',str(root),'checkout','-q',docs_rev],check=True)
    for name in ('corpus/self-counts.py','corpus/self-counts.tsv'):
        data=subprocess.check_output(['git','-C',str(LANE),'show',tool_rev+':'+name])
        (root/name).write_bytes(data)
    table=root/'corpus/self-counts.tsv'
    rows=[line.split('\t') for line in table.read_text().splitlines()
          if line.strip() and not line.lstrip().startswith('#')]
    if any(len(row)!=6 for row in rows):raise SystemExit('invalid six-column self-counts TSV')
    if common:
        rows=[row for row in rows if row[0] not in new_ids]
        # The two BASE index lines read `N rows at round 21 (`; after reads
        # `N rows (`. The same locator, without pinning either number, handles both.
        for row in rows:
            if row[0] in {'RD-LEDGER-ROWS','RD-STAMPS'}:
                row[2]=row[2].replace(r' rows \(',r' rows(?: at round [0-9]+)? \(')
    table.write_text(''.join('\t'.join(row)+'\n' for row in rows))
    if mutant:
        selected=[row for row in rows if row[0]==mutant]
        if len(selected)!=1:raise SystemExit('mutation id absent or duplicate: '+mutant)
        row=selected[0];doc=root/row[1];lines=doc.read_text().splitlines(keepends=True)
        hits=[(i,m) for i,line in enumerate(lines) if (m:=re.search(row[2],line))]
        if len(hits)!=1:raise SystemExit('mutation locator not unique: '+mutant)
        i,m=hits[0];old=m.group(1)
        lines[i]=lines[i][:m.start(1)]+str(int(old)+1)+lines[i][m.end(1):]
        doc.write_text(''.join(lines))
    p=subprocess.run(['python3','-B','corpus/self-counts.py'],cwd=root,
        env={'PATH':'/usr/bin:/bin','HOME':str(home),'PYTHONDONTWRITEBYTECODE':'1'},
        text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=600)
    print(f'C1_MEASURE label={label} tool_rev={tool_rev} docs_rev={docs_rev} common={int(common)} population={len(rows)} exit={p.returncode} mutation={mutant or "none"}')
    print(p.stdout,end='')
    if mutant and p.returncode!=1:raise SystemExit(2)
    raise SystemExit(p.returncode)
PY
