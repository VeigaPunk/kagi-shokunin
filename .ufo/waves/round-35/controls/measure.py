#!/usr/bin/env python3
"""Fixed public-path verdict expectations, authored before candidate scoring."""
import argparse, hashlib, json, os, pathlib, subprocess, tempfile
p=argparse.ArgumentParser(); p.add_argument('--script',required=True); p.add_argument('--base',required=True); p.add_argument('--out',required=True); p.add_argument('--work',required=True); a=p.parse_args()
script=pathlib.Path(a.script).resolve(); root=pathlib.Path(__file__).resolve().parents[4]
cases=[
 ('setup-number','printf "PREFREEZE: SETUP producer 0\\n"; exit 2',2,'NORESULT'),
 ('failed-number','printf "0\\n"; exit 127',2,'NORESULT'),
 ('diagnostic-number','printf "FAIL rows=0\\n"',2,'NORESULT'),
 ('stderr-number','printf "0\\n"; printf "producer unavailable\\n" >&2',2,'NORESULT'),
 ('valid-zero','printf "0\\n"',0,'OK'),
 ('grep-empty','grep -c QQQ_NO_MATCH_R35 corpus/prefreeze-control.sh',0,'OK'),
 ('empty-output',':',2,'NORESULT'),
 ('wrong-count','printf "1\\n"',1,'MISMATCH'),
 ('clean-forgery','printf "PREFREEZE: CLEAN (controls=0 mismatch=0)\\n"',2,'NORESULT'),
]
pathlib.Path(a.work).mkdir(parents=True,exist_ok=True)
rows=[]
with tempfile.TemporaryDirectory(prefix='public-',dir=a.work) as d:
 for name,command,expected,kind in cases:
  ctl=pathlib.Path(d)/f'{name}.tsv'; ctl.write_text(f'{name}\t0\t{command}\n')
  argv=['bash',str(script),'run','--base',a.base,'--controls',str(ctl),'--work',d]
  r=subprocess.run(argv,cwd=root,text=True,capture_output=True,timeout=60,env={**os.environ,'PREFREEZE_REPO':str(root),'TMPDIR':d})
  finding=any(line.startswith(kind+' '+name+' ') for line in r.stdout.splitlines())
  rows.append(dict(id=name,command=command,expected_rc=expected,expected_finding=kind,rc=r.returncode,stdout=r.stdout,stderr=r.stderr,match=r.returncode==expected and finding,argv=argv))
result=dict(base=a.base,script_sha256=hashlib.sha256(script.read_bytes()).hexdigest(),cases=rows,mismatches=sum(not r['match'] for r in rows),invalid_false_clean=sum(r['rc']==0 for r in rows if r['expected_rc']==2),positive_matches=sum(r['match'] for r in rows if r['expected_rc']==0))
pathlib.Path(a.out).write_text(json.dumps(result,indent=2)+'\n')
print('MEASUREMENT_RESULT mismatches=%d invalid_false_clean=%d positive_matches=%d cases=%d'%(result['mismatches'],result['invalid_false_clean'],result['positive_matches'],len(rows)))
raise SystemExit(bool(result['mismatches']))
