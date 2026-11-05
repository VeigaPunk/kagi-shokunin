#!/usr/bin/env bash
# plans/round-43-c3.sh -- round 43 C3 counter (operability: gate-selftest scratch conformance).
#
# Frozen predicate (the same sentence appears in plans/round-43.md §C3 and in the receipt label):
#   prints ONE unsigned integer N in 0..5 = the number of the five gates G1..G5 that satisfy all
#   three legs:
#     (1) the gate's bytes contain no `TMPDIR:-/tmp` scratch default (grep -F, count 0);
#     (2) the gate's selftest scratch default names ${HYAKU_SCRATCH:-/fast/scratch/hyaku}
#         (grep -F for `-d "${HYAKU_SCRATCH:-/fast/scratch/hyaku`, count >= 1);
#     (3) executed: `HYAKU_SCRATCH=<counter scratch>/probe bash <gate> --selftest` exits 0 and its
#         last line equals the gate's frozen PASS token exactly:
#           G1 corpus/anchor-pins.sh             ANCHOR_PINS_SELFTEST: PASS (8 cases)
#           G2 corpus/claims-declared.sh         CLAIMS_DECLARED_SELFTEST: PASS (8 cases)
#           G3 corpus/prefreeze-control.sh       PREFREEZE_SELFTEST: PASS (25 cases)
#           G4 corpus/self-description-sweep.sh  SELFTEST: PASS (10 cases)
#           G5 corpus/surface-census.sh          SELFTEST: PASS (16 cases)
#   The gate set is scanned under C3_ROOT (default: this repository's work tree), so the controls
#   runner can point the counter at fixture trees. A missing gate file is a setup error (exit 2).
#   No-work reading at the claim BASE 5f3566c is 0: all five gates carry `TMPDIR:-/tmp` defaults
#   (corpus/anchor-pins.sh:37, corpus/claims-declared.sh:37, corpus/prefreeze-control.sh:94 and
#   :274, corpus/self-description-sweep.sh:226, corpus/surface-census.sh:275), so leg (1) fails
#   for every gate. Measured predeclaration receipt: .ufo/waves/round-43/controls/c3-base.txt.
#
# Fixtures live at C3_ROOT and must be a git work tree (the selftests resolve the repository
# toplevel). Scratch root: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c3-counter.<pid>.
set -u
HERE=$(cd "$(dirname "$0")/.." && pwd -P)
ROOT=${C3_ROOT:-$HERE}
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c3-counter.$$
mkdir -p -- "$SCR/probe" || { echo "counter-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

check() { # $1 relpath  $2 token  $3 cases
  [ -f "$ROOT/$1" ] || { echo "counter-refused: $1" >&2; exit 2; }
  if grep -qF 'TMPDIR:-/tmp' "$ROOT/$1"; then return 1; fi
  if ! grep -qF -- '-d "${HYAKU_SCRATCH:-/fast/scratch/hyaku' "$ROOT/$1"; then return 1; fi
  local out rc last
  out=$(HYAKU_SCRATCH="$SCR/probe" bash "$ROOT/$1" --selftest 2>&1)
  rc=$?
  [ "$rc" = "0" ] || return 1
  last=$(printf '%s\n' "$out" | tail -1)
  [ "$last" = "$2: PASS ($3 cases)" ] || return 1
  return 0
}

n=0
check corpus/anchor-pins.sh ANCHOR_PINS_SELFTEST 8 && n=$((n + 1))
check corpus/claims-declared.sh CLAIMS_DECLARED_SELFTEST 8 && n=$((n + 1))
check corpus/prefreeze-control.sh PREFREEZE_SELFTEST 25 && n=$((n + 1))
check corpus/self-description-sweep.sh SELFTEST 10 && n=$((n + 1))
check corpus/surface-census.sh SELFTEST 16 && n=$((n + 1))
echo "$n"
exit 0
