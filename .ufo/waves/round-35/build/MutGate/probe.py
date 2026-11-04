#!/usr/bin/env python3
"""Bounded pristine/mutant/restored probes; no lane production writes."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

LANE = Path('/home/vgpnk/Projects/shokunin/kagi-shokunin')
OUT = LANE / '.ufo/waves/round-35/build/MutGate'
WORK = Path('/fast/scratch/hyaku/kagi-r35/MutGate')
BASE = '063c407494276d0c616e6c712a2e5d7aeb7e3768'
MEASURE = LANE / '.ufo/waves/round-35/controls/measure.py'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def run(argv, label):
    try:
        p = subprocess.run(argv, cwd=WORK, capture_output=True, text=True,
                           timeout=180, env={**os.environ, 'TMPDIR': str(WORK)})
        receipt = dict(argv=argv, rc=p.returncode, stdout=p.stdout, stderr=p.stderr)
    except subprocess.TimeoutExpired as e:
        receipt = dict(argv=argv, rc=None, timeout=True,
                       stdout=str(e.stdout or ''), stderr=str(e.stderr or ''))
    (OUT / (label + '.json')).write_text(json.dumps(receipt, indent=2) + '\n')
    return receipt

def detector(script, mode, label):
    if mode == 'measure':
        result = OUT / (label + '-cases.json')
        r = run(['python3', str(MEASURE), '--script', str(script), '--base', BASE,
                 '--out', str(result), '--work', str(WORK / 'measure')], label)
        if result.exists():
            r['measurement'] = json.loads(result.read_text())
        r['valid_pass'] = (r['rc'] == 0 and r['stdout'].strip() ==
            'MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9'
            and r.get('measurement', {}).get('mismatches') == 0)
        r['explicit_failure'] = (r['rc'] == 1 and
            r.get('measurement', {}).get('mismatches', 0) > 0 and
            'MEASUREMENT_RESULT mismatches=' in r['stdout'])
    else:
        r = run(['bash', str(script), '--selftest'], label)
        lines = r['stdout'].splitlines()
        r['valid_pass'] = (r['rc'] == 0 and bool(lines) and
            lines[-1].startswith('PREFREEZE_SELFTEST: PASS (') and
            not any(' FAIL ' in line for line in lines))
        r['explicit_failure'] = (r['rc'] == 1 and bool(lines) and
            lines[-1].startswith('PREFREEZE_SELFTEST: FAIL (') and
            any(line.startswith('CASE ') and ' FAIL ' in line for line in lines))
    return r

p = argparse.ArgumentParser()
p.add_argument('--candidate')
p.add_argument('--specs', help='JSON list: name, old, new, detector')
p.add_argument('--base-proof', action='store_true')
a = p.parse_args()
OUT.mkdir(parents=True, exist_ok=True)
WORK.mkdir(parents=True, exist_ok=True)
record = {'axes': ['producer-result integrity', 'positive-control retention', 'BASE isolation'],
          'measure_sha256': sha(MEASURE.read_bytes()), 'base': BASE, 'probes': []}
try:
    if a.base_proof:
        proc = subprocess.run(['git', '-C', str(LANE), 'show', BASE + ':corpus/prefreeze-control.sh'],
                              check=True, capture_output=True)
        script = WORK / 'base.sh'
        script.write_bytes(proc.stdout)
        record['base_script_sha256'] = sha(proc.stdout)
        record['base_measurement'] = detector(script, 'measure', 'base-proof')
    if a.candidate:
        source = Path(a.candidate).read_bytes()
        record['candidate_path'] = a.candidate
        record['candidate_sha256'] = sha(source)
        specs = json.loads(Path(a.specs).read_text())
        for spec in specs:
            name = spec['name']
            script = WORK / (name + '.sh')
            script.write_bytes(source)
            old, new = spec['old'].encode(), spec['new'].encode()
            if source.count(old) != 1:
                raise ValueError(name + ': mutation anchor must occur exactly once')
            entry = {'mutant': name, 'detector': spec['detector'], 'before_sha256': sha(source)}
            try:
                entry['pristine'] = detector(script, spec['detector'], name + '-pristine')
                mutant = source.replace(old, new, 1)
                script.write_bytes(mutant)
                entry['mutant_sha256'] = sha(mutant)
                entry['mutated'] = detector(script, spec['detector'], name + '-mutated')
            finally:
                script.write_bytes(source)
                entry['restored_sha256'] = sha(script.read_bytes())
                entry['restored'] = detector(script, spec['detector'], name + '-restored')
                entry['exact_restoration'] = script.read_bytes() == source
                entry['verdict'] = ('inconclusive' if not entry.get('pristine', {}).get('valid_pass')
                    or not entry['restored'].get('valid_pass') or not entry['exact_restoration']
                    else 'killed' if entry.get('mutated', {}).get('explicit_failure')
                    else 'survived' if entry.get('mutated', {}).get('valid_pass') else 'inconclusive')
                record['probes'].append(entry)
finally:
    (OUT / ('results.json' if a.candidate else 'base-results.json')).write_text(
        json.dumps(record, indent=2) + '\n')
    shutil.rmtree(WORK)
print(json.dumps({'base': record.get('base_measurement', {}).get('stdout'),
                  'probes': [{k: row[k] for k in ('mutant', 'verdict', 'exact_restoration')}
                             for row in record['probes']]}))
