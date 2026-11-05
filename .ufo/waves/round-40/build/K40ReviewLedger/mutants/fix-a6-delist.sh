#!/usr/bin/env bash
# attack6: remove one of the six ids from the counter's hardcoded list
# then re-add it to the ledger's header comment line so the row-presence grep passes
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
# re-add the deleted row id as a comment line so the row-presence grep ^R13-01<TAB> does NOT match
# actually we want the OPPOSITE shortcut: counter without R13-01 and R13-01 deleted.
# for the header-comment trick, no removal of the ledger row is needed here — instead test
# whether the counter still triggers fail-closed. We do the plain subcase 1 here, and test
# the header-comment trick in attack6b.
EOF
echo "attack6 fixture applied"
