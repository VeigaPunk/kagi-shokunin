#!/usr/bin/env bash
# attack2b: re-bind R13-01 to a single grep with a matchable wrong expect:
#   grep -c 'claim-ledger.tsv — calibration gate' corpus/claim-ledger.sh  -> prints 4, exit 0
# expect ^4$ matches, exit 0 matches → set row passes with an UNRELATED command.
set -eu
d=$1
python3 - "$d" <<'EOF'
import sys
p = sys.argv[1] + '/corpus/claim-ledger.tsv'
out = []
for L in open(p):
    if L.startswith('R13-01\t'):
        f = L.split('\t')
        f[1] = "grep -c 'claim-ledger.tsv — calibration gate' corpus/claim-ledger.sh"
        f[2] = '^4$'
        L = '\t'.join(f)
    out.append(L)
open(p, 'w').writelines(out)
# sanity: command must pass policy in the candidate tree
EOF
cd "$d" && grep -c 'claim-ledger.tsv — calibration gate' corpus/claim-ledger.sh
echo "attack2b fixture applied"
