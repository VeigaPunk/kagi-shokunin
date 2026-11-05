#!/usr/bin/env bash
# K43ReviewC1 attack driver 2 -- x5 token-match loosening, blanket runs, m3/m5 composites.
set -u
S=/fast/scratch/hyaku/kagi-r43/K43ReviewC1
W=$S/work
R=$S/receipts

python3 - "$W" <<'PY'
import os, sys
w = sys.argv[1]
src = open(os.path.join(w, "plans/round-43-c1.sh"), encoding="utf-8").read()

GUARD_OLD = ('rc=$(run_gate "$ROOT/p0-ledger.tsv" "$ROOT/p0-journals")\n'
             'if [ "$rc" != "0" ]; then\n'
             '  echo 0\n'
             '  exit 0\n'
             'fi\n')
GUARD_NEW = 'rc=$(run_gate "$ROOT/p0-ledger.tsv" "$ROOT/p0-journals")\n'
TOK_OLD = '  if [ "$rc" = "1" ] && grep -qxF "EXPECT_JOURNAL: REFUSE $4" "$ROOT/out-$1.txt"; then\n'
TOK_NEW = '  if [ "$rc" = "1" ]; then\n'
ECHO_OLD = 'echo "$n"\n'
ECHO_NEW = 'echo 6\n'
GREP_OLD = 'grep -qxF "EXPECT_JOURNAL: REFUSE $4"'
GREP_NEW = 'grep -q "EXPECT_JOURNAL: REFUSE $4"'

def build(dst, edits, name):
    s = src
    for old, new in edits:
        assert old in s, f"{name}: pattern missing: {old[:60]!r}"
        s = s.replace(old, new, 1)
    open(os.path.join(w, dst), "w", encoding="utf-8").write(s)

# x5: token match loosened from exact full line (-qxF) to substring (-q).
build("plans/mut-x5-grepq.sh", [(GREP_OLD, GREP_NEW)], "x5")
# composites: frozen mutants m3/m5 applied on top of x1 / x5 (proves the frozen mutant
# receipts still read their required values under the new counter mutation).
build("plans/mut-x1m3.sh", [(ECHO_OLD, ECHO_NEW), (GUARD_OLD, GUARD_NEW)], "x1+m3")
build("plans/mut-x1m5.sh", [(ECHO_OLD, ECHO_NEW), (TOK_OLD, TOK_NEW)], "x1+m5")
build("plans/mut-x5m3.sh", [(GREP_OLD, GREP_NEW), (GUARD_OLD, GUARD_NEW)], "x5+m3")
build("plans/mut-x5m5.sh", [(GREP_OLD, GREP_NEW), (TOK_OLD, TOK_NEW)], "x5+m5")
print("extended mutants written")
PY

gate_of() {
  case "$1" in
    real)       printf '%s' "$W/corpus/expect-journal.sh" ;;
    refuseall)  printf '%s' "$S/refuse-all.sh" ;;
    acceptall)  printf '%s' "$S/accept-all.sh" ;;
    *)          printf '%s' "$S/$1.sh" ;;
  esac
}
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: REFUSED (violations=1)"; exit 1\n' > "$S/refuse-all.sh"
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0\n' > "$S/accept-all.sh"

run_one() { # $1 label  $2 script-in-clone  $3 gate
  env EXPECT_JOURNAL="$(gate_of "$3")" bash "$W/$2" > "$R/$1.txt" 2>&1
  printf '%s rc=%s value=%s\n' "$1" "$?" "$(cat "$R/$1.txt")"
}

# honest counter, blanket receipts (re-measured fresh in this sandbox)
run_one c1-base-refuseall plans/round-43-c1.sh refuseall
run_one c1-base-acceptall plans/round-43-c1.sh acceptall
# x5 across the honest matrix + blankets
for g in real K1 K3 fakeC my6 refuseall acceptall; do
  run_one "c1-x5-grepq-$g" plans/mut-x5-grepq.sh "$g"
done
# x1 blankets + frozen-mutant composites
for pair in "c1-x1-echo6-refuseall plans/mut-x1-echo6.sh refuseall" \
            "c1-x1-echo6-acceptall plans/mut-x1-echo6.sh acceptall" \
            "c1-x1m3-K1 plans/mut-x1m3.sh K1" \
            "c1-x1m5-K3 plans/mut-x1m5.sh K3" \
            "c1-x5m3-K1 plans/mut-x5m3.sh K1" \
            "c1-x5m5-K3 plans/mut-x5m5.sh K3"; do
  set -- $pair
  run_one "$1" "$2" "$3"
done
echo DRIVER2-DONE
