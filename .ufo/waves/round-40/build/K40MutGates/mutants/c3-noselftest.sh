#!/usr/bin/env bash
# plans/round-40-c3.sh -- round 40 C3 counter (operability): gate-registry conformance for
# the two round-39 gates (SKILL.md gate-registry rows + committed self-invocation modes).
#
# Frozen predicate (the same sentence appears in plans/round-40.md and the receipt label):
#   prints ONE unsigned integer N in 0..2 -- the number of the gates
#     corpus/anchor-pins.sh  and  corpus/claims-declared.sh
#   that BOTH (a) have a row in SKILL.md's `## Gate registry` table naming the script path,
#   and (b) pass their committed selftest right now:
#     bash corpus/anchor-pins.sh --selftest    -> last line ANCHOR_PINS_SELFTEST: PASS (8 cases), exit 0
#     bash corpus/claims-declared.sh --selftest -> last line CLAIMS_DECLARED_SELFTEST: PASS (8 cases), exit 0
#   Target N=2 at the round-40 landing; the no-work reading at the claim BASE is 0 (no
#   registry rows; SKILL.md names neither script in the registry table).
#
# Fail closed (exit 2, no integer): SKILL.md missing, a selftest mode exists but produces no
# parsable PASS/FAIL verdict line, or a gate script is missing while its registry row exists.
set -u
cd "$(dirname "$0")/.."
skill=SKILL.md
[ -f "$skill" ] || { echo "counter-refused: SKILL.md missing" >&2; exit 2; }
gate_reg() { # gate_reg <script-path-fragment> -> row count in the registry table
  awk -v frag="$1" '
    /^## Gate registry/{t=1; next}
    /^## /{if (t) t=0}
    t && /^\|/ && index($0, frag) > 0 {c++}
    END {print c+0}' "$skill"
}
n=0
for pair in "corpus/anchor-pins.sh|ANCHOR_PINS_SELFTEST" "corpus/claims-declared.sh|CLAIMS_DECLARED_SELFTEST"; do
  script=${pair%%|*}; token=${pair##*|}
  rows=$(gate_reg "$script")
  if [ "$rows" -ge 1 ]; then
    [ -f "$script" ] || { echo "counter-refused: $script missing though registered" >&2; exit 2; }
    n=$((n + 1))
  fi
done
echo "$n"
exit 0
