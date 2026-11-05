#!/usr/bin/env bash
# attack7: sabotage one census gate (mutate corpus/sources-census.sh output) then rely on
# journal absence. Actually the real attack: REVERT the three census rows' expects to the
# BASE text while making the census itself print the OLD summary. This is the
# "counter too weak" probe: journal not updated + stale expectation still matches because
# the instrument was rolled back instead of the expectations moved forward.
set -eu
d=$1
python3 - "$d" <<'EOF'
import sys
p = sys.argv[1] + '/corpus/claim-ledger.tsv'
out = []
for L in open(p):
    if L.startswith(('R21-02\t', 'R31-02\t', 'R33-02\t', 'R34-03\t')):
        f = L.split('\t')
        f[2] = '^SOURCES_CENSUS: CLEAN \\(rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12\\)$'
        L = '\t'.join(f)
    out.append(L)
open(p, 'w').writelines(out)
EOF
# now patch the census summary print to claim rows=93 (instrument rollback)
python3 - "$d" <<'EOF'
import sys, re
p = sys.argv[1] + '/corpus/sources-census.sh'
t = open(p).read()
# replace the final summary printf: find the SOURCES_CENSUS print
m = re.search(r"printf 'SOURCES_CENSUS:[^\n]*\n", t)
assert m, 'summary printf not found'
print('original line was:', m.group(0)[:200])
EOF
echo "attack7 fixture applied (ledger reverted; instrument rollback attempt next)"
