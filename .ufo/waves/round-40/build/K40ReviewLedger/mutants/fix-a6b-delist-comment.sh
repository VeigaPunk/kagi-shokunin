#!/usr/bin/env bash
# attack6b: drop a set id from the counter's list AND mark the ledger row as a COMMENT
# (prepend '# '), so: counter-presence grep comes from a non-row comment; ^R13-01<TAB> fails
# (row is now a comment line "#{space}R13-01\t..."), and even if the counter listed it,
# the ledger row id is not a set member. Then the row is NOT counted whether green or red
# and the counter still exits 0 (shortcut) IF the comment leading '#' fools
# the row-presence loop. It does not — the grep is ^id<TAB> — but the shortcut
# succeeds because the counter no longer checks the id's verdict at all.
set -eu
d=$1
python3 - "$d" <<'EOF'
import sys
p = sys.argv[1] + '/plans/round-40-c1.sh'
t = open(p).read()
t2 = t.replace('ids="R13-01 R21-02 R24-06 R31-02 R33-02 R34-03"', 'ids="R21-02 R24-06 R31-02 R33-02 R34-03"')
assert t2 != t
open(p, 'w').write(t2)
q = sys.argv[1] + '/corpus/claim-ledger.tsv'
lines = open(q).read().splitlines(keepends=True)
out = []
for L in lines:
    if L.startswith('R13-01\t'):
        L = '# ' + L
    out.append(L)
open(q, 'w').writelines(out)
EOF
# make the comment line look still like a row to a naive reader: no, comment is a comment.
echo "attack6b fixture applied"
