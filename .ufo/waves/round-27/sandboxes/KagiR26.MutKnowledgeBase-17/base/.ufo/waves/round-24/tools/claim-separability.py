#!/usr/bin/env python3
"""Run one claim on BASE plus its digest-pinned, claim-only input overlay."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

lane = Path(__file__).resolve().parents[4]
label = sys.argv[1]
if label not in ('c1-only', 'c2-only', 'c3-only'):
    raise SystemExit('expected c1-only, c2-only or c3-only')
wave = lane / '.ufo/waves/round-24'
source = wave / 'separability' / label
manifest = json.loads((source / 'expected.json').read_text())
for path, digest in manifest['inputs'].items():
    if hashlib.sha256((source / path).read_bytes()).hexdigest() != digest:
        raise SystemExit('snapshot_tampered: ' + path)
with tempfile.TemporaryDirectory(prefix='separability-', dir='/fast/scratch/kagi-r24-recovery') as tmp:
    home = Path(tmp) / 'home'
    home.mkdir()
    env = {'PATH': os.environ['PATH'], 'HOME': str(home), 'LANG': 'C.UTF-8'}
    if label == 'c2-only':
        root = Path(tmp) / 'tree'
        subprocess.run(['git', 'clone', '-q', '--no-hardlinks', str(lane), str(root)], check=True, env=env)
        subprocess.run(['git', '-C', str(root), '-c', 'advice.detachedHead=false', 'checkout', '-q', manifest['base']], check=True, env=env)
        for path in manifest['inputs']:
            (root / path).parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source / path, root / path)
        command = ['bash', 'corpus/sources-census.sh']
    else:
        root = lane
        tool = 'host-tripwire.sh' if label == 'c1-only' else 'identity-swap.py'
        command = ['bash' if label == 'c1-only' else 'python3', str(wave / 'tools' / tool), 'separable-' + label, manifest['base'], str(source), *manifest['inputs']]
    result = subprocess.run(command, cwd=root, env=env, capture_output=True, text=True, timeout=1800)
record = {'manifest': manifest, 'command': command, 'exit': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr}
(wave / 'separability' / (label + '-run.json')).write_text(json.dumps(record, indent=2) + '\n')
print('CLAIM_SEPARABILITY: %s exit=%d %s' % (label, result.returncode, result.stdout.splitlines()[-1] if result.stdout.splitlines() else 'no output'))
sys.exit(result.returncode)
