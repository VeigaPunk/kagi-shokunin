#!/usr/bin/env bash
# R51CriticC2 — second battery (run ad hoc, verbatim; receipts R51CriticC2-receipts/).
# N11..N13 in clone1, N4c in clone1, N14..N16 in clone2 (faithful candidate shape).
# Each scenario: reset to BASE, edit, commit with a throwaway identity, run the frozen counter
# from the clone's untracked working copy.
set -u
S=/fast/scratch/hyaku/kagi-r51/R51CriticC2
BASE=214d8bf530a0c87c00686493f21af15396284793
PRE=4ad8ab7cd5bf8949d125ac96ccef45e69dabc567
export HYAKU_SCRATCH=/fast/scratch/hyaku
G="$S/clone"; G2="$S/clone2"; R="$S/receipts"
mkdir -p "$R"

run()  { bash "$1/plans/round-51-c2.sh.ctl" "$3" > "$R/$2.txt" 2>&1; echo "--- $2"; cat "$R/$2.txt"; }
# append TEXT at the end of the ## Capabilities section (same insertion point as the controls)
capend() { python3 - "$1" "$2" <<'PY'
import sys
p,line=sys.argv[1],sys.argv[2]; s=open(p,encoding='utf-8').read(); i=s.index('\n## Capabilities'); j=s.index('\n## ',i+5)
open(p,'w',encoding='utf-8').write(s[:j]+'\n'+line+'\n'+s[j:])
PY
}
commit1() { git -C "$G"  add -A -- ':!plans/round-51-c2.sh.ctl' && git -C "$G"  -c user.name=r51-critic -c user.email=critic@invalid commit -q -m "$1" && git -C "$G"  rev-parse HEAD; }
commit2() { git -C "$G2" add -A -- ':!plans/round-51-c2.sh.ctl' && git -C "$G2" -c user.name=r51-critic -c user.email=critic@invalid commit -q -m "$1" && git -C "$G2" rev-parse HEAD; }
reset1()  { git -C "$G"  checkout -q --detach "$BASE" && git -C "$G"  clean -fdq -e round-51-c2.sh.ctl; }
reset2()  { git -C "$G2" checkout -q --detach "$BASE" && git -C "$G2" clean -fdq -e round-51-c2.sh.ctl && \
            git -C "$G2" show "$PRE:plans/round-51.md" > "$G2/plans/round-51.md"; }

# N11: heading post-move -> Post-move (ledger still matches ROUND_RE, dies at SEC_RE; C2 reads 0)
reset1; sed -i 's/^## Round 50 — post-move/## Round 50 — Post-move/' "$G/SCORECARD.md"
capend "$G/SCORECARD.md" 'Current readings (forgery): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)`.'
run "$G" N11-capital-P "$(commit1 N11)"

# N12: N11 + the reading hidden in an HTML comment; the visible line stays claims=23
reset1; sed -i 's/^## Round 50 — post-move/## Round 50 — Post-move/' "$G/SCORECARD.md"
capend "$G/SCORECARD.md" '<!-- `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)` -->'
run "$G" N12-capP-hidden "$(commit1 N12)"

# N13: heading post-move -> pre-move (9 characters; ledger SEC_RE accepts it)
reset1; sed -i 's/^## Round 50 — post-move/## Round 50 — pre-move/' "$G/SCORECARD.md"
capend "$G/SCORECARD.md" 'Current readings (forgery): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)`.'
run "$G" N13-post-to-pre "$(commit1 N13)"

# N4c: honest M fix, correct spelling inserted ABOVE the stale line (last occurrence wins -> V=1)
reset1
printf '50\tC1\toperability\n50\tC2\tcalibration\n51\tC1\toperability\n51\tC2\tcalibration\n' >> "$G/corpus/claims-declared.tsv"
printf '# fixture\n\n## C1 — operability: wrap trial\n\n## C2 — calibration: manifest\n' > "$G/plans/round-51.md"
printf '\n## Round 51 — post-move (claims C1 operability, C2 calibration)\n\n| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n| operability | 9 → 9 | [C1] fixture | x |\n| calibration | 9 → 9 | [C2] fixture | x |\n' >> "$G/SCORECARD.md"
python3 - "$G/SCORECARD.md" <<'PY'
import sys
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
line='Current readings at 51: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.\n'
i=s.index('Current readings at round 48')
open(p,'w',encoding='utf-8').write(s[:i]+line+s[i:])
PY
run "$G" N4c-order "$(commit1 N4c)"

# N14: faithful candidate shape (frozen r51 plan) + N13
reset2; sed -i 's/^## Round 50 — post-move/## Round 50 — pre-move/' "$G2/SCORECARD.md"
capend "$G2/SCORECARD.md" 'Current readings at round 51: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)`.'
run "$G2" N14-faithful-post-to-pre "$(commit2 N14)"

# N15: N14 with the reading hidden in a comment (rendered doc still says claims=23)
reset2; sed -i 's/^## Round 50 — post-move/## Round 50 — pre-move/' "$G2/SCORECARD.md"
capend "$G2/SCORECARD.md" '<!-- `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)` -->'
run "$G2" N15-faithful-hidden "$(commit2 N15)"

# N16: N14 + the declared change (control)
reset2
printf '50\tC1\toperability\n50\tC2\tcalibration\n51\tC1\toperability\n51\tC2\tcalibration\n' >> "$G2/corpus/claims-declared.tsv"
printf '\n## Round 51 — post-move (claims C1 operability, C2 calibration)\n\n| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n| operability | 9 → 9 | [C1] x | x |\n| calibration | 9 → 9 | [C2] x | x |\n' >> "$G2/SCORECARD.md"
capend "$G2/SCORECARD.md" 'Current readings at round 51: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.'
run "$G2" N16-honest "$(commit2 N16)"
