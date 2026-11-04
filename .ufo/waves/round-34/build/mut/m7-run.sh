#!/usr/bin/env bash
# m7-run.sh — round-34 C2 part 2: rebuild the round-33 M7 mutant (lesson M33-4,
# routed defect R33-2) against any byte version of corpus/prefreeze-control.sh
# and run its --selftest to produce the red receipt.
#
# Contract:
#   bash m7-run.sh <script> <outfile>
#     <script>   the gate under test (e.g. corpus/prefreeze-control.sh)
#     <outfile>  receipt path. Content: the --selftest output (stdout+stderr),
#                an `exit=<rc>` line, a `m7: source sha256=...` line binding the
#                verdict to the exact source bytes that were copied and mutated
#                (plus the mutant's own sha256), and one `m7: verdict:` line.
#                The verdict line restates the failing case with
#                SINGLE spaces because the gate's own ck() prints the label
#                space-padded (printf 'CASE %-26s FAIL ...'), which the frozen
#                round-34 counter `grep -c 'CASE base-isolation FAIL' <receipt>`
#                cannot match; with the verdict line the counter reads 1.
#   stdout:  M7_RECEIPT: <outfile> FAIL=<0|1>
#     FAIL = padding-tolerant count of `CASE base-isolation ... FAIL` lines in
#     the raw selftest output (grep -cE 'CASE base-isolation +FAIL').
#   M7_MUTATE=0 runs the copied script UNMUTATED (control mode: expect
#   `PREFREEZE_SELFTEST: PASS (<k> cases)` and FAIL=0).
#
# Mutation (identical to round-33 MutGate M7, one point + its dead check):
#   1. `BASE_DIR=$EXTRACT/tree` becomes `BASE_DIR=$REPO` — --base is ignored,
#      every declared command measures the live worktree.
#   2. The `git -C "$REPO" archive --format=tar "$BASE_REV" | tar -x …` line is
#      replaced by a no-op comment and the two lines that capture and check its
#      PIPESTATUS are removed (with the pipeline gone, set -u would abort every
#      run on ${rcs[1]}).
#   Nothing else changes. Matching is by line prefix, so the transform applies
#   to any future byte version whose run-mode section keeps these lines. If a
#   marker is missing the harness aborts with exit 2 and writes NO receipt.
set -u

[ $# -eq 2 ] || { printf 'usage: bash m7-run.sh <script> <outfile>\n' >&2; exit 2; }
SRC=$1
OUT=$2
[ -f "$SRC" ] && [ -r "$SRC" ] || { printf 'm7: unreadable script: %s\n' "$SRC" >&2; exit 2; }

scratch=$(mktemp -d "${TMPDIR:-/tmp}/m7-run.XXXXXX") || exit 2
trap 'rm -rf -- "$scratch"' EXIT
cp -- "$SRC" "$scratch/orig.sh" || exit 2

if [ "${M7_MUTATE:-1}" = 0 ]; then
  cp -- "$scratch/orig.sh" "$scratch/mutant.sh"
else
  awk '
    BEGIN {
      base_prefix = "BASE_DIR=$EXTRACT/tree"
      xtr_prefix = "git -C \"$REPO\" archive --format=tar"
    }
    index($0, base_prefix) == 1 { print "BASE_DIR=$REPO"; mb = 1; next }
    index($0, xtr_prefix) == 1 {
      print ": # M7 mutant: extraction result discarded; commands measure the live worktree"
      getline
      getline
      me = 1
      next
    }
    { print }
    END { exit !(mb && me) }
  ' "$scratch/orig.sh" > "$scratch/mutant.sh" || {
    printf 'm7: mutation markers not found in %s; no receipt written\n' "$SRC" >&2
    exit 2
  }
  if grep -q -F 'tar -x -f -' "$scratch/mutant.sh" ||
     grep -q -F 'PIPESTATUS' "$scratch/mutant.sh" ||
     [ "$(grep -c -F 'BASE_DIR=$REPO' "$scratch/mutant.sh")" -ne 1 ]; then
    printf 'm7: post-mutation assertions failed for %s; no receipt written\n' "$SRC" >&2
    exit 2
  fi
fi
bash -n "$scratch/mutant.sh" || { printf 'm7: mutant does not parse\n' >&2; exit 2; }

bash "$scratch/mutant.sh" --selftest > "$OUT" 2>&1
rc=$?
printf 'exit=%d\n' "$rc" >> "$OUT"
printf 'm7: source sha256=%s (%s), mutant sha256=%s\n' \
  "$(sha256sum -- "$scratch/orig.sh" | awk '{print $1}')" "$SRC" \
  "$(sha256sum -- "$scratch/mutant.sh" | awk '{print $1}')" >> "$OUT"

n=$(grep -cE 'CASE base-isolation +FAIL' "$OUT") || n=0
if [ "$n" -gt 0 ]; then
  raw=$(grep -E 'CASE base-isolation +FAIL' "$OUT" | head -n 1)
  printf 'm7: verdict: CASE base-isolation FAIL (count=%d); raw line: "%s"\n' "$n" "$raw" >> "$OUT"
else
  printf 'm7: verdict: CASE base-isolation did not fail (count=0)\n' >> "$OUT"
fi
printf 'M7_RECEIPT: %s FAIL=%d\n' "$OUT" "$n"
exit 0
