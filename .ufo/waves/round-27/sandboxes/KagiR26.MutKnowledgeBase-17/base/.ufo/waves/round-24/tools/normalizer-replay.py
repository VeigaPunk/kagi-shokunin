#!/usr/bin/env python3
"""Reopen the frozen ten capture rows; compare v1 and one step-5 alternative."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
lane = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('normalizer', lane / 'corpus/rendered-text-v1.py')
normalizer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(normalizer)
rows = [line.split('\t') for line in (lane / 'corpus/source-fetches.tsv').read_text().splitlines() if re.match(r'^S0(?:1[7-9]|2[0-6])\t', line)]
records, cache = [], {}
with tempfile.TemporaryDirectory(prefix='normalizer-replay-', dir='/fast/scratch/kagi-r24-recovery') as tmp:
    for fields in rows:
        sid, url, expected = fields[0], fields[3], fields[14]
        if url not in cache:
            body = Path(tmp) / sid
            command = ['curl', '-fsSL', '--compressed', '-A', 'kagi-shokunin-round23/1.0 (documentation verification)', '-o', str(body), '-w', '%{url_effective} %{http_code}\n', url]
            result = subprocess.run(command, capture_output=True, text=True, timeout=90)
            if result.returncode:
                raise SystemExit('capture failed: ' + sid + ' ' + result.stderr)
            data = body.read_bytes()
            v1 = hashlib.sha256(normalizer.normalize_bytes(data)).hexdigest()
            original = normalizer.WS_RE
            normalizer.WS_RE = re.compile(r'[\t\n\f\r ]+')
            alternative = hashlib.sha256(normalizer.normalize_bytes(data)).hexdigest()
            normalizer.WS_RE = original
            cache[url] = {'command': command, 'exit': result.returncode, 'http': result.stdout.strip(), 'bytes': len(data), 'raw_sha256': hashlib.sha256(data).hexdigest(), 'v1': v1, 'ascii_step5_only': alternative}
        records.append({'id': sid, 'expected': expected, **cache[url], 'v1_match': cache[url]['v1'] == expected, 'ascii_match': cache[url]['ascii_step5_only'] == expected})
output = {'alternative': 'Only WS_RE is replaced by WHATWG ASCII whitespace; all other v1 steps, including trim, are unchanged.', 'rows': records}
Path(sys.argv[1]).write_text(json.dumps(output, indent=2) + '\n')
print('NORMALIZER_REPLAY: rows=%d v1_matches=%d ascii_matches=%d' % (len(records), sum(row['v1_match'] for row in records), sum(row['ascii_match'] for row in records)))
