#!/usr/bin/env python3
"""Round35 independent public-path attacks; excluded ceilings are observations only."""
import argparse, hashlib, json, os, pathlib, subprocess
p=argparse.ArgumentParser(); p.add_argument('--script',required=True); p.add_argument('--out',required=True); a=p.parse_args()
root=pathlib.Path('/home/vgpnk/Projects/shokunin/kagi-shokunin')
work=pathlib.Path('/fast/scratch/hyaku/kagi-r35/ReviewGate'); work.mkdir(parents=True,exist_ok=True)
base='063c407494276d0c616e6c712a2e5d7aeb7e3768'
cases=[
 ('stderr-number','printf "0\\n"; printf "diagnostic\\n" >&2',0,2,'NORESULT'),
 ('rc127-number','printf "0\\n"; exit 127',0,2,'NORESULT'),
 ('rc1-nonzero','printf "1\\n"; exit 1',1,2,'NORESULT'),
 ('empty-pipeline','printf "" | cat',0,2,'NORESULT'),
 ('multiline-numbers','printf "1\\n0\\n"',0,2,'NORESULT'),
 ('multiline-diagnostic','printf "POLICY refused\\n0\\n"',0,2,'NORESULT'),
 ('whitespace-only','printf " \\n  \\n"',0,2,'NORESULT'),
 ('padded-integer','printf "  0  \\n"',0,0,'OK'),
 ('timeout-number','printf "0\\n"; sleep 3',0,2,'NORESULT'),
 ('noresult',':',0,2,'NORESULT'),
 ('valid-zero','printf "0\\n"',0,0,'OK'),
 ('grep-empty','grep -c QQQ_NO_MATCH_R35 corpus/prefreeze-control.sh',0,0,'OK'),
 ('wrong-count','printf "1\\n"',0,1,'MISMATCH'),
 ('stderr-whitespace','printf "0\\n"; printf " " >&2',0,2,'NORESULT'),
 ('rc1-zero','printf "0\\n"; exit 1',0,0,'OK'),
 ('blank-before','printf "\\n0\\n"',0,2,'NORESULT'),
 ('blank-after','printf "0\\n\\n"',0,2,'NORESULT'),
 ('no-terminal-newline','printf 0',0,0,'OK'),
 ('dishonest-integer','printf "0\\n"',0,None,None),
 ('hidden-pipeline','false | printf "0\\n"',0,None,None),
]
rows=[]
for name,cmd,expect,rc,kind in cases:
 ctl=work/(name+'.tsv'); ctl.write_text(f'{name}\t{expect}\t{cmd}\n')
 argv=['bash',str(pathlib.Path(a.script).resolve()),'run','--base',base,'--controls',str(ctl),'--work',str(work),'--timeout','1']
 r=subprocess.run(argv,cwd=work,env={**os.environ,'PREFREEZE_REPO':str(root),'TMPDIR':str(work)},text=True,capture_output=True,timeout=30)
 match=None if rc is None else r.returncode==rc and any(x.startswith(kind+' '+name+' ') for x in r.stdout.splitlines())
 rows.append(dict(id=name,command=cmd,declared_count=expect,expected_rc=rc,expected_finding=kind,rc=r.returncode,stdout=r.stdout,stderr=r.stderr,match=match,argv=argv))
result=dict(script=str(pathlib.Path(a.script).resolve()),script_sha256=hashlib.sha256(pathlib.Path(a.script).read_bytes()).hexdigest(),base=base,cases=rows)
pathlib.Path(a.out).write_text(json.dumps(result,indent=2)+'\n')
for r in rows: print(r['id'], 'rc='+str(r['rc']), 'match='+str(r['match']), repr(r['stdout']))
