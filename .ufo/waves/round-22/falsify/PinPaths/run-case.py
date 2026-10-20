#!/usr/bin/python3
"""Execute exactly one authorized path fixture and retain raw observations."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

EVIDENCE = Path(__file__).resolve().parent
spec_path = EVIDENCE / 'fixture-inputs.json'
spec_bytes = spec_path.read_bytes()
spec = json.loads(spec_bytes)
name = sys.argv[1]
case = next(case for case in spec['cases'] if case['name'] == name)
BASE = Path(spec['base_directory'])
source = BASE / 'implementation/corpus/revision-audit.py'
assert hashlib.sha256(source.read_bytes()).hexdigest() == spec['implementation_sha256']
result_path = EVIDENCE / f'{name}.json'
trace_path = EVIDENCE / f'{name}.strace'
assert not result_path.exists() and not trace_path.exists(), 'Never overwrite a prior observation'
audit_argv = ['/usr/bin/python3', '-I', '-B', str(source), '--root', case['root'], '--history', case['history_oid']]
trace_argv = ['/usr/bin/strace', '-f', '-qq', '-yy', '-s', '256', '-o', str(trace_path), '--', *audit_argv]
environment = {'PATH': '/usr/bin:/bin', 'HOME': str(BASE / 'empty-home'), 'XDG_CONFIG_HOME': str(BASE / 'empty-home'), 'TMPDIR': str(BASE / 'runtime' / name), 'LC_ALL': 'C', 'LANG': 'C', 'TZ': 'UTC', 'PYTHONDONTWRITEBYTECODE': '1'}
started = time.monotonic()
try:
    result = subprocess.run(trace_argv, cwd=case['root'], env=environment, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=8, check=False)
    exit_code, stdout, stderr, timed_out = result.returncode, result.stdout, result.stderr, False
except subprocess.TimeoutExpired as error:
    exit_code, stdout, stderr, timed_out = None, error.stdout or b'', error.stderr or b'', True
elapsed = time.monotonic() - started
trace_bytes = trace_path.read_bytes() if trace_path.exists() else b''
trace = trace_bytes.decode('utf-8', errors='replace')
outside_prefix = str(BASE / 'outside') + '/'
outside_hits = [line for line in trace.splitlines() if outside_prefix in line]
record = {'case': name, 'audit_argv': audit_argv, 'trace_argv': trace_argv, 'cwd': case['root'], 'environment': environment, 'timeout_seconds': 8, 'timed_out': timed_out, 'exit_code': exit_code, 'stdout': stdout.decode('utf-8', errors='replace'), 'stderr': stderr.decode('utf-8', errors='replace'), 'elapsed_seconds': elapsed, 'expected_exit': case['expected_exit'], 'expected_stdout': case['expected_stdout'], 'expected_stderr': case['expected_stderr'], 'fixture_inputs_sha256': hashlib.sha256(spec_bytes).hexdigest(), 'implementation_sha256': spec['implementation_sha256'], 'trace_sha256': hashlib.sha256(trace_bytes).hexdigest(), 'trace_bytes': len(trace_bytes), 'outside_fixture_trace_hits': outside_hits, 'trace_scope': 'All traced child/descendant syscalls; outside fixture prefix includes owned sentinel payloads only, not interpreter or system-library files.', 'matches_expected_decision': not timed_out and exit_code == case['expected_exit'] and stdout.decode('utf-8', errors='replace') == case['expected_stdout'] and stderr.decode('utf-8', errors='replace') == case['expected_stderr'], 'no_outside_fixture_path_in_trace': bool(trace_bytes) and not outside_hits}
for suffix, data in (('.stdout', stdout), ('.stderr', stderr)):
    path = EVIDENCE / f'{name}{suffix}'
    with path.open('xb') as handle:
        handle.write(data)
    path.chmod(0o444)
with result_path.open('x') as handle:
    json.dump(record, handle, sort_keys=True, indent=2)
    handle.write('\n')
result_path.chmod(0o444)
if trace_path.exists():
    trace_path.chmod(0o444)
print(json.dumps(record, sort_keys=True))
