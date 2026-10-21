#!/usr/bin/env python3
"""Record immutable before/after checks, keeping every exit and output.
Usage: final-measure.py AFTER_REV OUTPUT.json
No admission authority; failures remain failed records, never inferred passes.
"""
import json, os, pathlib, re, subprocess, sys, tempfile, hashlib
LANE=pathlib.Path('/home/vgpnk/Projects/shokunin/kagi-shokunin')
BASE='4587c61a348e4528717404a68912c373f3ef4d03'
TOOLS=LANE/'.ufo/waves/round-25/tools'
if len(sys.argv)!=3:raise SystemExit('usage: final-measure.py AFTER_REV OUTPUT.json')
after,output=sys.argv[1:]; records=[]
with tempfile.TemporaryDirectory(prefix='kagi-r25-final-',dir='/fast/scratch') as td:
    tmp=pathlib.Path(td);home=tmp/'home';home.mkdir()
    env={'PATH':'/usr/bin:/bin','HOME':str(home),'PYTHONDONTWRITEBYTECODE':'1','LC_ALL':'en_US.UTF-8'}
    def run(name,argv,cwd=LANE,want=0,pattern=None,timeout=1200):
        p=subprocess.run(argv,cwd=cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=timeout)
        ok=p.returncode==want and (not pattern or re.search(pattern,p.stdout,re.M))
        records.append({'name':name,'argv':argv,'cwd':str(cwd),'measured':after,'exit':p.returncode,'expected_exit':want,'stdout':p.stdout,'passed':bool(ok)})
        print(name, 'PASS' if ok else 'FAIL',p.returncode,flush=True)
        return p
    for ref,label,want in ((BASE,'before',1),(after,'after',0)):
        run('c1-common-'+label,['bash',str(TOOLS/'c1-measure.sh'),'--common',after,ref,label],want=want,pattern=r'SELF_COUNTS: (?:STALE .*stale=8 unlocated=0 ambiguous=0|CLEAN .*stale=0)')
        run('c3-count-'+label,['python3','-B',str(TOOLS/'c3-measure.py'),ref],pattern=r'unbound=28' if label=='before' else r'bound=28 unbound=0 orphan=0 observed=28 fired=1')
        p=run('c2-layouts-'+label,['bash',str(TOOLS/'c2-measure.sh'),ref,label],timeout=900)
        data=json.loads(p.stdout)
        pristine={r['layout']:r for r in data['records'] if r['case']=='pristine'}
        c2ok=pristine['fleet']['exit']==0 and pristine['lone']['exit']==(1 if label=='before' else 3)
        records[-1]['passed'] &= c2ok
        if label=='after':
            for r in data['records']:
                if r['case'] in ('local-miss','self-miss','owned-nested-miss'):
                    records[-1]['passed'] &= r['exit']==1 and 'UNRESOLVED' in r['stdout']
    run('c1-mutation',['bash',str(TOOLS/'c1-measure.sh'),'--mutate','SC-SKILL-STAMPS',after,after,'mutation'],want=1,pattern=r'STALE SC-SKILL-STAMPS')
    # A scratch lane in a complete fleet-layout mirror. Sibling/fleet evidence
    # is read only; every edited/control document stays inside this clone.
    fleet=tmp/'fleet';fleet.mkdir();root=fleet/'lane'
    subprocess.run(['git','clone','-q','--no-hardlinks',str(LANE),str(root)],check=True)
    subprocess.run(['git','-C',str(root),'checkout','-q',after],check=True)
    for name in ('.ufo','MANIFEST.json','MISSION.md','AXES.md'):(fleet/name).symlink_to(LANE.parent/name)
    for p in LANE.parent.glob('*-shokunin'):
        if p!=LANE:(fleet/p.name).symlink_to(p)
    for name,argv,pattern in [
      ('ledger-selftest',['bash','corpus/claim-ledger.sh','--selftest'],r'SELFTEST: PASS'),
      ('selfcounts-selftest',['python3','-B','corpus/self-counts.py','--selftest'],r'SELF_COUNTS_SELFTEST: PASS'),
      ('clock-selftest',['python3','-B','corpus/release-clock.py','--selftest'],r'RELEASE_CLOCK_SELFTEST: PASS'),
      ('selfcounts-full',['python3','-B','corpus/self-counts.py'],r'SELF_COUNTS: CLEAN'),
      ('clock-receipt-bound',['python3','-B','corpus/release-clock.py'],r'RELEASE_CLOCK: CLEAN'),
      ('sources-census',['bash','corpus/sources-census.sh'],r'SOURCES_CENSUS: CLEAN'),
      ('full-verify',['bash','corpus/claim-ledger.sh','verify'],r'CLAIM_LEDGER: CLEAN'),
    ]:run(name,argv,cwd=root,pattern=pattern)
    # Retained-receipt contradiction must fail without a network call.
    table=root/'corpus/release-clocks.tsv';original=table.read_text();lines=original.splitlines()
    for i,line in enumerate(lines):
        f=line.split('\t')
        if f[0]=='S008':f[5]='99.0.0';f[7]='fired';lines[i]='\t'.join(f)
    table.write_text('\n'.join(lines)+'\n')
    run('clock-receipt-mutant',['python3','-B','corpus/release-clock.py'],cwd=root,want=1,pattern=r'RECEIPT-MISMATCH S008')
    table.write_text(original)
result={'base':BASE,'after':after,'environment':env,'records':records,'passed':all(r['passed'] for r in records)}
pathlib.Path(output).write_text(json.dumps(result,indent=2)+'\n')
raise SystemExit(0 if result['passed'] else 1)
