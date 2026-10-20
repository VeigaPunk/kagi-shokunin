#!/usr/bin/python3
"""Create owned, deterministic path fixtures; never inspect a host repository."""
import base64
import hashlib
import json
import os
from pathlib import Path
import stat
import zlib

BASE = Path('/tmp/kagi-r22-w2-PinPaths')
EVIDENCE = Path(__file__).resolve().parent
SOURCE_SHA256 = 'ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977'
MANIFEST_SHA256 = '31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911'
PIN = b'pinpaths-owned-fixture\n'
SUMMARY = ' (stale=0 missing=0 dropped=0 added=0 invalid={invalid})\n'
CASES = (
    ('clean-control', 'corpus/pin.txt', None),
    ('pin-parent-symlink', 'corpus/linked/pin.txt', 'PATH-ESCAPE corpus/linked/pin.txt'),
    ('pin-final-symlink', 'corpus/pin.txt', 'PATH-ESCAPE corpus/pin.txt'),
    ('pin-directory', 'corpus/pin.txt', 'NOT-FILE corpus/pin.txt'),
    ('pin-fifo', 'corpus/pin.txt', 'NOT-FILE corpus/pin.txt'),
    ('stamps-parent-symlink', 'corpus/pin.txt', 'PATH-ESCAPE corpus/stamps.tsv'),
    ('stamps-final-symlink', 'corpus/pin.txt', 'PATH-ESCAPE corpus/stamps.tsv'),
    ('stamps-directory', 'corpus/pin.txt', 'NOT-FILE corpus/stamps.tsv'),
    ('stamps-fifo', 'corpus/pin.txt', 'NOT-FILE corpus/stamps.tsv'),
)


def put(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as handle:
        handle.write(content)


def object_id(root, kind, content):
    raw = kind.encode('ascii') + b' ' + str(len(content)).encode('ascii') + b'\0' + content
    oid = hashlib.sha1(raw).hexdigest()
    target = root / '.git' / 'objects' / oid[:2] / oid[2:]
    compressed = zlib.compress(raw, level=9)
    if target.exists():
        assert target.read_bytes() == compressed
    else:
        put(target, compressed)
    return oid


def tree_id(root, entries):
    ordered = sorted(entries.items(), key=lambda item: item[0] + ('/' if isinstance(item[1], dict) else ''))
    body = bytearray()
    for name, content in ordered:
        if isinstance(content, dict):
            mode, oid = '40000', tree_id(root, content)
        else:
            mode, oid = '100644', object_id(root, 'blob', content)
        body.extend(f'{mode} {name}'.encode('ascii') + b'\0' + bytes.fromhex(oid))
    return object_id(root, 'tree', bytes(body))


def fixture_history(root, path, stamps):
    files = {}
    for name, content in ((path, PIN), ('corpus/stamps.tsv', stamps)):
        node = files
        parts = name.split('/')
        for part in parts[:-1]:
            node = node.setdefault(part, {})
        node[parts[-1]] = content
    tree = tree_id(root, files)
    identity = 'PinPaths fixture <pinpaths@example.invalid> 1792454400 +0000'
    commit = f'tree {tree}\nauthor {identity}\ncommitter {identity}\n\nowned path fixture history\n'.encode('ascii')
    oid = object_id(root, 'commit', commit)
    put(root / '.git' / 'HEAD', b'ref: refs/heads/fixture\n')
    put(root / '.git' / 'refs' / 'heads' / 'fixture', (oid + '\n').encode('ascii'))
    put(root / '.git' / 'config', b'[core]\n\trepositoryformatversion = 0\n\tbare = false\n')
    return oid, tree


def freeze(path):
    info = path.lstat()
    if stat.S_ISLNK(info.st_mode):
        return
    if stat.S_ISDIR(info.st_mode):
        for child in sorted(path.iterdir()):
            freeze(child)
        path.chmod(0o555)
    else:
        path.chmod(0o444)


def describe(path):
    info = path.lstat()
    entry = {'path': str(path.relative_to(BASE)), 'mode': oct(stat.S_IMODE(info.st_mode))}
    if stat.S_ISLNK(info.st_mode):
        entry.update(kind='symlink', target=os.readlink(path))
        return [entry]
    if stat.S_ISDIR(info.st_mode):
        entry['kind'] = 'directory'
        records = [entry]
        for child in sorted(path.iterdir()):
            records.extend(describe(child))
        return records
    if stat.S_ISFIFO(info.st_mode):
        entry['kind'] = 'fifo'
        return [entry]
    assert stat.S_ISREG(info.st_mode)
    data = path.read_bytes()
    entry.update(kind='file', bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), content_base64=base64.b64encode(data).decode('ascii'))
    return [entry]


source = BASE / 'implementation/corpus/revision-audit.py'
assert hashlib.sha256(source.read_bytes()).hexdigest() == SOURCE_SHA256
assert hashlib.sha256((BASE / 'integration-manifest.json').read_bytes()).hexdigest() == MANIFEST_SHA256
(BASE / 'cases').mkdir()
(BASE / 'outside').mkdir()
(BASE / 'empty-home').mkdir(mode=0o555)
(BASE / 'runtime').mkdir()
case_records = []
for name, path, finding in CASES:
    root = BASE / 'cases' / name / 'root'
    outside = BASE / 'outside' / name
    root.mkdir(parents=True)
    outside.mkdir()
    (BASE / 'runtime' / name).mkdir()
    stamps = f'{path}\t{hashlib.sha256(PIN).hexdigest()}\t{PIN.count(bytes([10]))}\t{len(PIN)}\n'.encode('ascii')
    put(root / path, PIN)
    put(root / 'corpus/stamps.tsv', stamps)
    put(outside / 'pin.txt', PIN)
    put(outside / 'stamps.tsv', stamps)
    history, tree = fixture_history(root, path, stamps)
    target = root / path
    stamps_path = root / 'corpus/stamps.tsv'
    if name == 'pin-parent-symlink':
        target.unlink()
        target.parent.rmdir()
        target.parent.symlink_to(outside, target_is_directory=True)
    elif name == 'pin-final-symlink':
        target.unlink()
        target.symlink_to(outside / 'pin.txt')
    elif name == 'pin-directory':
        target.unlink()
        target.mkdir()
    elif name == 'pin-fifo':
        target.unlink()
        os.mkfifo(target, mode=0o600)
    elif name == 'stamps-parent-symlink':
        target.unlink()
        stamps_path.unlink()
        stamps_path.parent.rmdir()
        stamps_path.parent.symlink_to(outside, target_is_directory=True)
    elif name == 'stamps-final-symlink':
        stamps_path.unlink()
        stamps_path.symlink_to(outside / 'stamps.tsv')
    elif name == 'stamps-directory':
        stamps_path.unlink()
        stamps_path.mkdir()
    elif name == 'stamps-fifo':
        stamps_path.unlink()
        os.mkfifo(stamps_path, mode=0o600)
    expected_stdout = ('REVISION_AUDIT: CLEAN' + SUMMARY.format(invalid=0)) if finding is None else (finding + '\nREVISION_AUDIT: SETUP' + SUMMARY.format(invalid=1))
    case_records.append({'name': name, 'root': str(root), 'history_oid': history, 'history_tree': tree, 'pin_path': path, 'expected_exit': 0 if finding is None else 2, 'expected_stdout': expected_stdout, 'expected_stderr': '', 'outside_fixture_directory': str(outside)})
freeze(BASE / 'cases')
freeze(BASE / 'outside')
nodes = describe(BASE / 'cases') + describe(BASE / 'outside') + describe(BASE / 'implementation') + describe(BASE / 'integration-manifest.json')
fixture_spec = {'schema': 1, 'axes': ['calibration', 'freshness'], 'base_directory': str(BASE), 'measured_integration_commit': '8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3', 'measured_integration_tree': 'd12afd7a545e86f21eb9acac567d10de774df50f', 'frozen_manifest_sha256': MANIFEST_SHA256, 'implementation_sha256': SOURCE_SHA256, 'pin_content_base64': base64.b64encode(PIN).decode('ascii'), 'pin_sha256': hashlib.sha256(PIN).hexdigest(), 'fixture_history_method': 'Deterministically encoded local Git objects only; no git init, add, commit, commit-tree, checkout, index or production mutation.', 'cases': case_records, 'immutable_nodes': nodes}
encoded = (json.dumps(fixture_spec, sort_keys=True, indent=2) + '\n').encode('utf-8')
put(EVIDENCE / 'fixture-inputs.json', encoded)
fixture_digest = hashlib.sha256(encoded).hexdigest()
put(EVIDENCE / 'fixture-inputs.sha256', f'{fixture_digest}  fixture-inputs.json\n'.encode('ascii'))
(EVIDENCE / 'fixture-inputs.json').chmod(0o444)
(EVIDENCE / 'fixture-inputs.sha256').chmod(0o444)
print(json.dumps({'cases': len(case_records), 'fixture_inputs_sha256': fixture_digest, 'implementation_sha256': SOURCE_SHA256, 'pin_sha256': fixture_spec['pin_sha256'], 'history_oids': {case['name']: case['history_oid'] for case in case_records}}, sort_keys=True))
