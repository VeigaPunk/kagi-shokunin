#!/usr/bin/env bash
# C2 layout recorder. Every experiment is confined to one fresh sandbox;
# the real fleet and lane are READ ONLY, including all control documents.
# Usage: bash c2-measure.sh REV LABEL
set -euo pipefail
exec python3 -B - "$@" <<'PY'
import json, os, pathlib, subprocess, sys, tempfile
LANE = pathlib.Path('/home/vgpnk/Projects/shokunin/kagi-shokunin')
FLEET = LANE.parent
if len(sys.argv) != 3:
    raise SystemExit('usage: c2-measure.sh REV LABEL')
rev, label = sys.argv[1:]
records=[]
with tempfile.TemporaryDirectory(prefix='kagi-r25-c2-',dir='/fast/scratch') as td:
    tmp=pathlib.Path(td)
    home=tmp/'home';home.mkdir()
    env={'PATH':'/usr/bin:/bin','HOME':str(home),'PYTHONDONTWRITEBYTECODE':'1'}
    def cmd(argv,cwd):
        p=subprocess.run(argv,cwd=cwd,env=env,text=True,stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT,timeout=300)
        return {'argv':argv,'cwd':str(cwd),'exit':p.returncode,'stdout':p.stdout}
    for layout in ('lone','fleet'):
        parent=tmp/layout; parent.mkdir()
        root=parent/('kagi-shokunin' if layout=='fleet' else 'lane')
        subprocess.run(['git','clone','-q','--no-hardlinks',str(LANE),str(root)],check=True)
        subprocess.run(['git','-C',str(root),'checkout','-q',rev],check=True)
        if layout=='fleet':
            for name in ('.ufo','MANIFEST.json','MISSION.md','AXES.md'):
                (parent/name).symlink_to(FLEET/name)
            for sibling in FLEET.glob('*-shokunin'):
                if sibling!=LANE: (parent/sibling.name).symlink_to(sibling)
        r=cmd(['bash','corpus/claim-ledger.sh','citations'],root)
        r.update(layout=layout,case='pristine',revision=rev,label=label);records.append(r)
        # A doc-only control avoids changing the default document set and is
        # always created inside the scratch clone, never at an ambient cwd.
        controls={
            'local-miss':'broken `corpus/nope-r25.md`\n',
            'self-miss':'broken `kagi-shokunin/corpus/nope-r25.md`\n',
            'owned-nested-miss':'broken `.ufo/waves/round-25/new/nope.md`\n',
            'fleet-miss':'broken `.ufo/reports/nope-r25.md`\n',
        }
        for name,content in controls.items():
            doc=root/'corpus'/('c2-'+name+'.md');doc.write_text(content)
            r=cmd(['bash','corpus/claim-ledger.sh','citations','--docs',str(doc)],root)
            r.update(layout=layout,case=name,revision=rev,label=label);records.append(r)
print(json.dumps({'label':label,'revision':rev,'records':records},indent=2))
PY
