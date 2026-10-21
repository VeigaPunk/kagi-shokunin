#!/usr/bin/env python3
"""Count round-24 provenance populations from immutable lane Git objects."""
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

lane = Path(__file__).resolve().parents[4]
rev = sys.argv[1]
def blob(path):
    return subprocess.check_output(['git', '-C', str(lane), 'show', rev + ':' + path], text=True)
rows = [x.split('|') for x in blob('corpus/SOURCES.md').splitlines() if re.match(r'^\|\s*S[0-9]{3,}\s*\|', x)]
pinned = {x[1].strip() for x in rows if 'Fetch sha256:' in x[7]}
fetches = {x.split('\t')[0] for x in blob('corpus/source-fetches.tsv').splitlines() if x and not x.startswith('#')}
stamps = [line.split('\t') for line in blob('corpus/stamps.tsv').splitlines() if line and not line.startswith('#')]
bad = []
for path, sha, lines, size in stamps:
    data = subprocess.check_output(['git', '-C', str(lane), 'show', rev + ':' + path])
    if (hashlib.sha256(data).hexdigest(), str(data.count(b'\n')), str(len(data))) != (sha, lines, size):
        bad.append(path)
print(json.dumps({'revision': rev, 'rows': len(rows), 'inrow': len(pinned), 'captures': len(fetches), 'inrow_only': len(pinned - fetches), 'stamp_rows': len(stamps), 'stamp_mismatches': bad}, sort_keys=True))
