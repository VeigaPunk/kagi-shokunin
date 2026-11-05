#!/usr/bin/env bash
# attack2: move R13-01's expect to a WRONG value ^999$ (keep exit 0)
set -eu
d=$1
python3 - "$d" <<'EOF'
import sys
p = sys.argv[1] + '/corpus/claim-ledger.tsv'
out = []
for L in open(p):
    if L.startswith('R13-01\t'):
        f = L.split('\t'); f[2] = '^999$'
        L = '\t'.join(f)
    out.append(L)
open(p, 'w').writelines(out)
EOF
echo "attack2 fixture applied"
