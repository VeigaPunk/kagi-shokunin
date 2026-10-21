#!/usr/bin/env python3
"""Run identical committed fixtures against frozen and repaired gate logic."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

lane = Path(__file__).resolve().parents[4]
before, after, output = sys.argv[1:]
def source(rev):
    return subprocess.check_output(['git', '-C', str(lane), 'show', rev + ':corpus/claim-ledger.sh'], text=True)
marker = '# --- selftest ----------------------------------------------------------------'
old, new = source(before), source(after)
fixtures = new.split(marker, 1)[1]
records = []
with tempfile.TemporaryDirectory(prefix='gate-regression-', dir='/fast/scratch/kagi-r24-recovery') as tmp:
    home = Path(tmp) / 'home'
    home.mkdir()
    for phase, prefix in [('before', old.split(marker, 1)[0]), ('after', new.split(marker, 1)[0])]:
        script = Path(tmp) / (phase + '.sh')
        script.write_text(prefix + marker + fixtures)
        script.chmod(0o700)
        p = subprocess.run([str(script), '--selftest'], env={'PATH': os.environ['PATH'], 'HOME': str(home)}, capture_output=True, text=True, timeout=300)
        records.append({'phase': phase, 'revision': before if phase == 'before' else after, 'fixture_sha256': hashlib.sha256(fixtures.encode()).hexdigest(), 'exit': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr})
Path(output).write_text(json.dumps(records, indent=2) + '\n')
valid = records[0]['exit'] == 1 and 'FAIL-case cells-invalid-self-policy' in records[0]['stdout'] and records[1]['exit'] == 0 and records[1]['stdout'].splitlines()[-1] == 'SELFTEST: PASS (151 cases)'
print('GATE_REGRESSION: %s before_exit=%d after_exit=%d fixtures_identical=%s' % ('PASS' if valid else 'FAIL', records[0]['exit'], records[1]['exit'], records[0]['fixture_sha256'] == records[1]['fixture_sha256']))
sys.exit(0 if valid else 1)
