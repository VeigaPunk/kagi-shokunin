#!/usr/bin/python3
"""Run one retained round-22 PinMalformed fixture, using only owned local inputs."""

import base64
import datetime
import hashlib
import json
from pathlib import Path
import subprocess
import sys

EVIDENCE = Path(__file__).resolve().parent
SCRATCH = Path('/tmp/kagi-r22-w2-PinMalformed')
IMPLEMENTATION = SCRATCH / 'corpus/revision-audit.py'
EXPECTED_IMPLEMENTATION_SHA256 = 'ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977'
EXPECTATIONS = {
    'clean-control': (0, 'REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=0 invalid=0)\n'),
    'malformed-tsv': (2, 'MALFORMED-LINE 1\nREVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)\n'),
    'duplicate-ids': (2, 'DUPLICATE corpus/keep.txt\nREVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)\n'),
    'malformed-after-valid-prefix': (2, 'MALFORMED-LINE 2\nREVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)\n'),
}

case = sys.argv[1]
expected_exit, expected_stdout = EXPECTATIONS[case]
implementation_sha256 = hashlib.sha256(IMPLEMENTATION.read_bytes()).hexdigest()
if implementation_sha256 != EXPECTED_IMPLEMENTATION_SHA256:
    raise RuntimeError('implementation differs from the frozen manifest')

root = SCRATCH / 'fixtures' / case
root.mkdir(parents=True, exist_ok=False)
(root / 'corpus').mkdir()
home = SCRATCH / 'fixture-home'
home.mkdir(exist_ok=True)
template = SCRATCH / 'empty-template'
template.mkdir(exist_ok=True)
env = {
    'PATH': '/usr/bin:/bin',
    'HOME': str(home),
    'XDG_CONFIG_HOME': str(home / '.config'),
    'LC_ALL': 'C',
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': '/dev/null',
    'GIT_CONFIG_SYSTEM': '/dev/null',
    'GIT_OPTIONAL_LOCKS': '0',
    'GIT_TERMINAL_PROMPT': '0',
    'GIT_NO_LAZY_FETCH': '1',
    'GIT_NO_REPLACE_OBJECTS': '1',
    'GIT_CEILING_DIRECTORIES': str(SCRATCH),
    'GIT_AUTHOR_NAME': 'PinMalformed fixture',
    'GIT_AUTHOR_EMAIL': 'pin-malformed@example.invalid',
    'GIT_COMMITTER_NAME': 'PinMalformed fixture',
    'GIT_COMMITTER_EMAIL': 'pin-malformed@example.invalid',
    'GIT_AUTHOR_DATE': '2000-01-01T00:00:00+0000',
    'GIT_COMMITTER_DATE': '2000-01-01T00:00:00+0000',
}
commands = []


def invoke(argv, data=None):
    result = subprocess.run(argv, cwd=root, env=env, input=data if data is not None else b'', stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15, check=False)
    record = {
        'argv': argv,
        'cwd': str(root),
        'stdin_b64': base64.b64encode(data).decode('ascii') if data is not None else '',
        'exit_code': result.returncode,
        'stdout': result.stdout.decode('utf-8', errors='backslashreplace'),
        'stderr': result.stderr.decode('utf-8', errors='backslashreplace'),
        'stdout_b64': base64.b64encode(result.stdout).decode('ascii'),
        'stderr_b64': base64.b64encode(result.stderr).decode('ascii'),
    }
    commands.append(record)
    return result


def git(*args, data=None):
    result = invoke(['/usr/bin/git', '-C', str(root), '-c', 'core.hooksPath=/dev/null', *args], data)
    if result.returncode != 0:
        raise RuntimeError(json.dumps(commands[-1], sort_keys=True))
    return result.stdout.strip().decode('ascii')


fixture_inputs = {}
fixture_bytes = {}
for relative in (
    'history/corpus/keep.txt',
    'history/corpus/stamps.tsv',
    f'{case}/corpus/stamps.tsv',
):
    path = EVIDENCE / 'fixtures' / relative
    data = path.read_bytes()
    path.chmod(0o444)
    fixture_bytes[relative] = data
    fixture_inputs[relative] = {
        'sha256': hashlib.sha256(data).hexdigest(),
        'bytes': len(data),
        'newline_count': data.count(b'\n'),
        'content_b64': base64.b64encode(data).decode('ascii'),
        'content_utf8': data.decode('utf-8'),
    }
keep = fixture_bytes['history/corpus/keep.txt']
history_stamps = fixture_bytes['history/corpus/stamps.tsv']
current_stamps = fixture_bytes[f'{case}/corpus/stamps.tsv']
(root / 'corpus/keep.txt').write_bytes(keep)
(root / 'corpus/stamps.tsv').write_bytes(current_stamps)
(root / 'corpus/keep.txt').chmod(0o444)
(root / 'corpus/stamps.tsv').chmod(0o444)

git('init', '--quiet', '--template=' + str(template), '--initial-branch=fixture', '--object-format=sha1')
keep_oid = git('hash-object', '-w', '--stdin', data=keep)
stamps_oid = git('hash-object', '-w', '--stdin', data=history_stamps)
corpus_tree = git('mktree', data=f'100644 blob {keep_oid}\tkeep.txt\n100644 blob {stamps_oid}\tstamps.tsv\n'.encode('ascii'))
root_tree = git('mktree', data=f'040000 tree {corpus_tree}\tcorpus\n'.encode('ascii'))
history_oid = git('commit-tree', root_tree, data=b'pin-malformed-fixture-history\n')
audit_argv = ['/usr/bin/python3', '-I', '-B', str(IMPLEMENTATION), '--root', str(root), '--history', history_oid]
result = invoke(audit_argv)
matched = result.returncode == expected_exit and result.stdout == expected_stdout.encode('ascii') and result.stderr == b''
record = {
    'case': case,
    'observed_at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'runner_argv': sys.orig_argv,
    'runner_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'implementation_sha256': implementation_sha256,
    'fixture_root': str(root),
    'history_oid': history_oid,
    'history_tree_oid': root_tree,
    'fixture_inputs': fixture_inputs,
    'environment': env,
    'expected': {'exit_code': expected_exit, 'stdout': expected_stdout, 'stderr': ''},
    'audit': commands[-1],
    'commands': commands,
    'matches_expectation': matched,
}
result_path = EVIDENCE / 'results' / f'{case}.json'
result_path.parent.mkdir(exist_ok=True)
with result_path.open('x', encoding='utf-8') as output:
    json.dump(record, output, indent=2, sort_keys=True)
    output.write('\n')
result_path.chmod(0o444)
print(json.dumps({
    'case': case,
    'history_oid': history_oid,
    'history_tree_oid': root_tree,
    'fixture_sha256': {key: value['sha256'] for key, value in fixture_inputs.items()},
    'audit': commands[-1],
    'matches_expectation': matched,
    'evidence': str(result_path),
}, indent=2, sort_keys=True))
raise SystemExit(0 if matched else 1)
