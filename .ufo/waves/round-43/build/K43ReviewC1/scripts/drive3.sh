#!/usr/bin/env bash
# K43ReviewC1 attack driver 3 -- x9 missing-gate fail-open mutant; degenerate x5m5 fix.
set -u
S=/fast/scratch/hyaku/kagi-r43/K43ReviewC1
W=$S/work
R=$S/receipts

python3 - "$W" <<'PY'
import os, sys
w = sys.argv[1]
src = open(os.path.join(w, "plans/round-43-c1.sh"), encoding="utf-8").read()

def build(dst, edits, name):
    s = src
    for old, new in edits:
        assert old in s, f"{name}: pattern missing: {old[:60]!r}"
        s = s.replace(old, new, 1)
    open(os.path.join(w, dst), "w", encoding="utf-8").write(s)

# x9: missing-gate branch flipped from fail-closed 0 to fail-open 6 (the target).
build("plans/mut-x9-nogate6.sh",
      [('[ -f "$GATE" ] || { echo 0; exit 0; }',
        '[ -f "$GATE" ] || { echo 6; exit 0; }')], "x9")
# x5m5, done in the right order: m5 drops the (already loosened) token condition.
s5 = src.replace('grep -qxF "EXPECT_JOURNAL: REFUSE $4"', 'grep -q "EXPECT_JOURNAL: REFUSE $4"', 1)
tok5 = '  if [ "$rc" = "1" ] && grep -q "EXPECT_JOURNAL: REFUSE $4" "$ROOT/out-$1.txt"; then\n'
assert tok5 in s5
open(os.path.join(w, "plans/mut-x5m5.sh"), "w", encoding="utf-8").write(
    s5.replace(tok5, '  if [ "$rc" = "1" ]; then\n', 1))
print("x9 + x5m5 written")
PY

gate_of() {
  case "$1" in
    real)    printf '%s' "$W/corpus/expect-journal.sh" ;;
    missing) printf '%s' "$S/does-not-exist.sh" ;;
    *)       printf '%s' "$S/$1.sh" ;;
  esac
}
run_one() { # $1 label  $2 script  $3 gate
  env EXPECT_JOURNAL="$(gate_of "$3")" bash "$W/$2" > "$R/$1.txt" 2>&1
  printf '%s rc=%s value=%s\n' "$1" "$?" "$(cat "$R/$1.txt")"
}
for g in real K1 K3 fakeC my6; do
  run_one "c1-x9-nogate6-$g" plans/mut-x9-nogate6.sh "$g"
done
# the damage demonstration: honest counter fail-closes on a missing gate; x9 prints the target.
run_one c1-base-missinggate plans/round-43-c1.sh missing
run_one c1-x9-nogate6-missing plans/mut-x9-nogate6.sh missing
# degenerate composite receipt
run_one c1-x5m5-K3 plans/mut-x5m5.sh K3
echo DRIVER3-DONE
