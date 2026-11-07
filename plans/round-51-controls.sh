#!/usr/bin/env bash
# plans/round-51-controls.sh — pre-freeze controls for the round-51 counters (run before any
# candidate is scored; receipt .ufo/waves/round-51/controls/controls-prefreeze.txt).
# Each control prints `<id> expect=<v> got=<v> MATCH|DIFF  <counter line>`; a SETUP expectation
# matches a counter line that starts `<NAME>: SETUP`.
# C1 controls run `plans/round-51-c1.sh --tree` on fixture trees built from a BASE archive.
# C2 controls run `plans/round-51-c2.sh <commit>` inside a scratch `git clone --shared` of the lane
# whose fixture commits carry a throwaway identity (the clone's toplevel is asserted first).
# Usage: bash plans/round-51-controls.sh [c1|c2|all]
set -u
BASE=214d8bf530a0c87c00686493f21af15396284793
LANE=$(cd "$(dirname "$0")/.." && pwd)
FX="$LANE/.ufo/waves/round-51/controls/fixtures"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r51"
mkdir -p "$SCR"
S=$(mktemp -d "$SCR/controls.XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
which=${1:-all}
pass=0; fail=0
check() { # id expect line
  local got
  if printf '%s' "$3" | grep -qE '^[A-Z0-9_]+: SETUP'; then got=SETUP
  else got=$(printf '%s' "$3" | sed -nE 's/^[A-Z0-9_]+: value=([0-9]+).*/\1/p'); fi
  if [ "$got" = "$2" ]; then r=MATCH; pass=$((pass+1)); else r=DIFF; fail=$((fail+1)); fi
  echo "$1 expect=$2 got=${got:-NONE} $r  $3"
}

base_tree() { # dir
  mkdir -p "$1" && git -C "$LANE" archive "$BASE" | tar -x -C "$1"
}
ref_tree() { # dir : BASE + reference trial + S108 row + entry section
  base_tree "$1"
  cp "$FX/ref/corpus/openbao-wrap-trial.sh" "$1/corpus/openbao-wrap-trial.sh"
  python3 - "$1/corpus/SOURCES.md" "$FX/ref/sources-row.md" <<'PY'
import sys
p, r = sys.argv[1], open(sys.argv[2]).read().rstrip('\n')
lines = open(p).read().split('\n')
last = max(i for i, l in enumerate(lines) if l.startswith('| S'))
lines.insert(last + 1, r)
open(p, 'w').write('\n'.join(lines))
PY
  cat "$FX/ref/entry-section.md" >> "$1/corpus/knowledge/vault-openbao-token-lease-lifecycle.md"
}
fixture_trial() { # dir body : replace the trial with a script (header names S108)
  { printf '#!/usr/bin/env bash\n# fixture (S108)\n'; printf '%s\n' "$2"; } > "$1/corpus/openbao-wrap-trial.sh"
}

if [ "$which" = c1 ] || [ "$which" = all ]; then
  C1="bash $LANE/plans/round-51-c1.sh --tree"
  t="$S/k1-0"; base_tree "$t"; check K1-0 0 "$($C1 "$t" | tail -n 1)"
  t="$S/k1-p"; ref_tree "$t"; check K1-P 5 "$($C1 "$t" | tail -n 1)"
  # F1: constant-HOLDS printer (no bao contact)
  t="$S/k1-f1"; ref_tree "$t"
  fixture_trial "$t" 'for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS const"; done; echo "OPENBAO_WRAP_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"; exit 0'
  check K1-F1 0 "$($C1 "$t" | tail -n 1)"
  # F2: PATH reader — HOLDS when PATH names a "real" dir, else BROKEN for all (the round-49 ceiling)
  t="$S/k1-f2"; ref_tree "$t"
  fixture_trial "$t" 'command -v bao >/dev/null || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
case "$PATH" in *real*) s=HOLDS;; *) s=BROKEN;; esac
for i in 1 2 3 4 5; do echo "TRIAL T$i $s path"; done; echo "OPENBAO_WRAP_TRIAL: $s"; exit 0'
  check K1-F2 0 "$($C1 "$t" | tail -n 1)"
  # F3: PATH-reader by shim dir name (sh<n> -> BROKEN T<n>), the round-49 naming
  t="$S/k1-f3"; ref_tree "$t"
  fixture_trial "$t" 'command -v bao >/dev/null || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
d=$(dirname "$(command -v bao)")
for i in 1 2 3 4 5; do case "$d" in *sh$i*) echo "TRIAL T$i BROKEN name";; *) echo "TRIAL T$i HOLDS name";; esac; done
echo "OPENBAO_WRAP_TRIAL: done"; exit 0'
  check K1-F3 0 "$($C1 "$t" | tail -n 1)"
  # F4: shim-content reader (greps its bao for the falsifier verbs; every run sees the same bytes)
  t="$S/k1-f4"; ref_tree "$t"
  fixture_trial "$t" 'b=$(command -v bao) || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
for i in 1 2 3 4 5; do if grep -q "sh$i)" "$b" 2>/dev/null; then echo "TRIAL T$i HOLDS content"; else echo "TRIAL T$i BROKEN content"; fi; done
echo "OPENBAO_WRAP_TRIAL: done"; exit 0'
  check K1-F4 0 "$($C1 "$t" | tail -n 1)"
  # F5 (named ceiling): .mode reader beside its bao — expected to reach 5
  t="$S/k1-f5"; ref_tree "$t"
  fixture_trial "$t" 'b=$(command -v bao) || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
m=$(cat "$(dirname "$b")/.mode" 2>/dev/null)
for i in 1 2 3 4 5; do if [ "$m" = "sh$i" ]; then echo "TRIAL T$i BROKEN mode"; else echo "TRIAL T$i HOLDS mode"; fi; done
echo "OPENBAO_WRAP_TRIAL: done"; exit 0'
  check K1-F5 5 "$($C1 "$t" | tail -n 1)"
  # F6: reference trial, registry row absent -> SRC 0
  t="$S/k1-f6"; ref_tree "$t"; cp "$S/k1-0/corpus/SOURCES.md" "$t/corpus/SOURCES.md"
  check K1-F6 0 "$($C1 "$t" | tail -n 1)"
  # F7: reference trial, entry section absent
  t="$S/k1-f7"; ref_tree "$t"; cp "$S/k1-0/corpus/knowledge/vault-openbao-token-lease-lifecycle.md" "$t/corpus/knowledge/"
  check K1-F7 0 "$($C1 "$t" | tail -n 1)"
  # F8: reference trial that leaks one wrapped nonce
  t="$S/k1-f8"; ref_tree "$t"
  sed -i 's/^n=\$(nonce)$/n=$(nonce); echo "leak $n"/' "$t/corpus/openbao-wrap-trial.sh"
  check K1-F8 0 "$($C1 "$t" | tail -n 1)"
  # F9: registry row present but status queued
  t="$S/k1-f9"; ref_tree "$t"; sed -i '/^| S108 /s/| mined |/| queued |/' "$t/corpus/SOURCES.md"
  check K1-F9 0 "$($C1 "$t" | tail -n 1)"
fi

if [ "$which" = c2 ] || [ "$which" = all ]; then
  G="$S/clone"
  git clone -q --shared "$LANE" "$G" || exit 2
  [ "$(git -C "$G" rev-parse --show-toplevel)" = "$G" ] || { echo "SETUP clone toplevel"; exit 2; }
  git -C "$G" checkout -q --detach "$BASE" || exit 2
  # the counters under test are this lane's working-copy bytes, copied into the clone untracked
  cp "$LANE/plans/round-51-c2.sh" "$G/plans/round-51-c2.sh.ctl"
  C2() { bash "$G/plans/round-51-c2.sh.ctl" "$1" | head -n 1; }
  gc() { git -C "$G" -c user.name=r51-fixture -c user.email=fixture@invalid commit -q -a -m "$1" && git -C "$G" rev-parse HEAD; }
  mkpos() { # fixture: manifest rows for r50 + r51, r51 plan headings, r51 SCORECARD section, readings line
    git -C "$G" checkout -q --detach "$BASE"
    printf '50\tC1\toperability\n50\tC2\tcalibration\n51\tC1\toperability\n51\tC2\tcalibration\n' >> "$G/corpus/claims-declared.tsv"
    printf '# fixture\n\n## C1 — operability: wrap trial\n\n## C2 — calibration: manifest\n' > "$G/plans/round-51.md"
    printf '\n## Round 51 — post-move (claims C1 operability, C2 calibration)\n\n| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n| operability | 9 → 9 | [C1] fixture | x |\n| calibration | 9 → 9 | [C2] fixture | x |\n' >> "$G/SCORECARD.md"
    git -C "$G" add plans/round-51.md
  }
  readings() { # stated claims-declared reading -> append a current-readings line to §Capabilities
    python3 - "$G/SCORECARD.md" "$1" <<'PY'
import sys
p, stated = sys.argv[1], sys.argv[2]
s = open(p).read()
i = s.index('\n## Capabilities')
j = s.index('\n## ', i + 5)
line = '\nCurrent readings at round 51 (fixture): `bash corpus/claims-declared.sh --root .` ⇒ `' + stated + '`.\n'
open(p, 'w').write(s[:j] + line + s[j:])
PY
  }
  check K2-0 3 "$(C2 "$BASE")"
  mkpos; readings 'CLAIMS_DECLARED: CLEAN (claims=29)'; c=$(gc pos); check K2-P 0 "$(C2 "$c")"
  # F1: readings line only (no manifest rows, no r51 plan) -> M 2, V 1
  git -C "$G" checkout -q --detach "$BASE"; readings 'CLAIMS_DECLARED: CLEAN (claims=29)'; c=$(gc f1); check K2-F1 3 "$(C2 "$c")"
  # F2: manifest rows with swapped axes for round 50 -> M 4 (plan heading + SCORECARD axis cell per claim), V 1
  mkpos; sed -i 's/^50\tC1\toperability$/50\tC1\tcalibration/; s/^50\tC2\tcalibration$/50\tC2\toperability/' "$G/corpus/claims-declared.tsv"
  readings 'CLAIMS_DECLARED: MISMATCH (claims=27 mismatch=2)'; c=$(gc f2); check K2-F2 5 "$(C2 "$c")"
  # F3: round-50 plan headings deleted (BASE plan file changed) -> SETUP
  git -C "$G" checkout -q --detach "$BASE"; sed -i '/^## C[12] — /d' "$G/plans/round-50.md"; c=$(gc f3); check K2-F3 SETUP "$(C2 "$c")"
  # F4: claims-declared.sh replaced by a constant CLEAN printer -> SETUP
  git -C "$G" checkout -q --detach "$BASE"; printf '#!/bin/bash\necho "CLAIMS_DECLARED: CLEAN (claims=27)"\n' > "$G/corpus/claims-declared.sh"; c=$(gc f4); check K2-F4 SETUP "$(C2 "$c")"
  # F5: a BASE manifest row (round 47) deleted -> SETUP
  git -C "$G" checkout -q --detach "$BASE"; sed -i '/^47\t/d' "$G/corpus/claims-declared.tsv"; c=$(gc f5); check K2-F5 SETUP "$(C2 "$c")"
  # F6: manifest rows and sections landed, readings line not updated -> V 1
  mkpos; c=$(gc f6); check K2-F6 1 "$(C2 "$c")"
  # F7: readings line states the wrong count -> V 1
  mkpos; readings 'CLAIMS_DECLARED: CLEAN (claims=30)'; c=$(gc f7); check K2-F7 1 "$(C2 "$c")"
fi
echo "CONTROLS: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
