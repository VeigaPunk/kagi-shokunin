#!/usr/bin/env bash
# R51CriticC2 — C2 forgery battery. Scratch clone of the lane at BASE; each scenario is a
# fixture commit; the frozen counter is run from the clone's working copy (untracked .ctl).
set -u
S=${S:?}
BASE=214d8bf530a0c87c00686493f21af15396284793
export HYAKU_SCRATCH=/fast/scratch/hyaku
G="$S/clone"
R="$S/receipts"
mkdir -p "$R"
[ "$(git -C "$G" rev-parse --show-toplevel)" = "$G" ] || { echo "SETUP toplevel"; exit 2; }

reset() { git -C "$G" checkout -q --detach "$BASE" && git -C "$G" clean -fdq -e round-51-c2.sh.ctl; }
gc() { git -C "$G" add -A -- ':!plans/round-51-c2.sh.ctl' && \
       git -C "$G" -c user.name=r51-critic -c user.email=critic@invalid commit -q -m "$1" && \
       git -C "$G" rev-parse HEAD; }
run() { # name commit
  bash "$G/plans/round-51-c2.sh.ctl" "$2" > "$R/$1.txt" 2>&1
  echo "--- $1 ($2)"; cat "$R/$1.txt"
}

# honest-shape fix used to isolate the V leg: manifest rows + r51 plan + r51 section
mkpos() {
  printf '50\tC1\toperability\n50\tC2\tcalibration\n51\tC1\toperability\n51\tC2\tcalibration\n' >> "$G/corpus/claims-declared.tsv"
  printf '# fixture\n\n## C1 — operability: wrap trial\n\n## C2 — calibration: manifest\n' > "$G/plans/round-51.md"
  printf '\n## Round 51 — post-move (claims C1 operability, C2 calibration)\n\n| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n| operability | 9 → 9 | [C1] fixture | x |\n| calibration | 9 → 9 | [C2] fixture | x |\n' >> "$G/SCORECARD.md"
}
# append TEXT at the end of the ## Capabilities section (same insertion point as the controls)
capappend() { python3 - "$G/SCORECARD.md" "$1" <<'PY'
import sys
p, line = sys.argv[1], sys.argv[2]
s = open(p, encoding='utf-8').read()
i = s.index('\n## Capabilities')
j = s.index('\n## ', i + 5)
open(p, 'w', encoding='utf-8').write(s[:j] + '\n' + line + '\n' + s[j:])
PY
}
eofappend() { printf '%s\n' "$1" >> "$G/SCORECARD.md"; }
stale_pair() { echo '`bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=23)`'; }

# N1 do nothing (BASE)
reset; run N1-do-nothing "$BASE"

# N2 manifest rows with the right axes, SCORECARD rows that describe a DIFFERENT claim
reset; mkpos
python3 - "$G/SCORECARD.md" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding='utf-8').read()
s = s.replace('| operability | 9 → 9 | [C1] fixture | x |',
              '| operability | 9 → 9 | [C1] Nothing landed: this row is an inventory marker, no trial, no measurement | - |')
s = s.replace('| calibration | 9 → 9 | [C2] fixture | x |',
              '| calibration | 9 → 9 | [C2] A different claim entirely: registry size is unchanged | - |')
open(p, 'w', encoding='utf-8').write(s)
PY
capappend "$(stale_pair | sed 's/claims=23/claims=29/')"
c=$(gc "N2 right-axis rows, unrelated prose"); run N2-wrong-prose "$c"

# N3 correct readings line placed OUTSIDE ## Capabilities
reset; mkpos
eofappend 'Current readings (forgery): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.'
c=$(gc "N3 readings outside capabilities"); run N3-outside-section "$c"

# N4 correct count, different command spelling (round-48 spelling trap)
reset; mkpos
capappend 'Current readings (forgery): `bash ./corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.'
c=$(gc "N4 other spelling"); run N4-spelling "$c"

# N4b correct spelling but inserted BEFORE the stale line (last occurrence wins)
reset; mkpos
python3 - "$G/SCORECARD.md" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding='utf-8').read()
new = 'Current readings: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.\n'
i = s.index('\n## Capabilities'); j = s.index('\n## ', i + 5)
open(p, 'w', encoding='utf-8').write(s[:j] + '\n' + new + s[j:])
PY
c=$(gc "N4b correct line before stale"); run N4b-order "$c"

# N5 the round-48 K07 table pair deleted (MISSING is not a fix)
reset; mkpos
python3 - "$G/SCORECARD.md" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding='utf-8').read()
old = '`bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=23)`; '
assert list(s.split(old)).__len__() == 2 or True
s = s.replace(old, '')
open(p, 'w', encoding='utf-8').write(s)
PY
c=$(gc "N5 delete K07 pair"); run N5-deleted-pair "$c"

# N6 hide round 50 from the gate: demote its post-move heading; NO manifest rows; readings claims=25
reset
sed -i 's/^## Round 50 — post-move/### Round 50 — post-move/' "$G/SCORECARD.md"
capappend 'Current readings (forgery): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)`.'
c=$(gc "N6 demote round-50 heading"); run N6-hidden-round "$c"

# N7 same idea by deleting the round-50 post-move block entirely
reset
python3 - "$G/SCORECARD.md" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding='utf-8').read()
i = s.index('\n## Round 50 — post-move')
open(p, 'w', encoding='utf-8').write(s[:i] + '\n')
PY
capappend 'Current readings (forgery): `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)`.'
c=$(gc "N7 delete round-50 block"); run N7-deleted-round "$c"

# N8 honest M fix + the V pair hidden in an HTML comment (rendered doc keeps claims=23)
reset; mkpos
capappend '<!-- `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)` -->'
c=$(gc "N8 hidden comment pair"); run N8-hidden-comment "$c"

# N9 both legs gamed: demote round-50 heading + hidden comment; zero manifest rows
reset
sed -i 's/^## Round 50 — post-move/### Round 50 — post-move/' "$G/SCORECARD.md"
capappend '<!-- `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=25)` -->'
c=$(gc "N9 both legs gamed"); run N9-both-gamed "$c"

# N10 honest shape (control for the battery): manifest rows + section + visible readings line
reset; mkpos
capappend 'Current readings at round 51: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=29)`.'
c=$(gc "N10 honest shape"); run N10-honest "$c"

echo "BATTERY DONE"
