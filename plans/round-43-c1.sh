#!/usr/bin/env bash
# plans/round-43-c1.sh -- round 43 C1 counter (calibration: the journal-gate deletion refusal,
# population grown by a second deletion id).
#
# Frozen predicate (the same sentence appears in plans/round-43.md §C1 and in the receipt label):
#   prints ONE unsigned integer N in 0..6 = the number of the six forgeries F1..F6 that the gate
#   ${EXPECT_JOURNAL:-corpus/expect-journal.sh} REFUSES with its frozen token (rc 1 and the exact
#   line `EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate ACCEPTS the positive control P0
#   (rc 0). If the gate is missing, P0 is refused, or P0 errors, N = 0. Target N = 6.
#   No-work reading at the claim BASE 5f3566c (gate absent from that tree? no: the gate is present;
#   the counter itself is not -- this file lands at predeclaration, after BASE) is 0.
#
#   F1..F5 are the round-41/42 forgeries, unchanged (plans/round-42-c1.sh). F6 is new: the P0 ledger
#   with the row `R11-03` deleted, journal unchanged. R11-03 is in the base ledger 6cc8850 and in P0
#   6f1588c and in no round-40 migration journal, so no frozen class of rounds 41/42 refers to it;
#   the class is `DELETED <ID>` (round-42 C1 rule, unconditional over every base id). The gate bytes
#   are UNCHANGED this round: kill clause (e) of plans/round-43.md §C1.
#
# Fixtures are built in scratch from committed bytes only:
#   BASE 6cc8850 ledger (base for the gate), P0 = round-40 landed ledger 6f1588c with its round-40
#   migration journal. Scratch root: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c1-counter.<pid>.
# Fail closed: a missing committed revision or journal prints nothing and exits 2.
set -u
cd "$(dirname "$0")/.."
BASE=6cc8850dfc5757927699e5a53a876f47c8df21aa
P0=6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0
JOURNAL_PATH=.ufo/waves/round-40/expectation-migrations.json
GATE=${EXPECT_JOURNAL:-corpus/expect-journal.sh}
ROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c1-counter.$$
mkdir -p -- "$ROOT" || { echo "counter-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$ROOT"' EXIT

[ -f "$GATE" ] || { echo 0; exit 0; }

git show "$BASE:corpus/claim-ledger.tsv" > "$ROOT/base.tsv" 2>/dev/null || { echo "counter-refused: BASE ledger" >&2; exit 2; }
git show "$P0:corpus/claim-ledger.tsv" > "$ROOT/p0.tsv" 2>/dev/null || { echo "counter-refused: P0 ledger" >&2; exit 2; }
git show "$P0:$JOURNAL_PATH" > "$ROOT/p0-journal.json" 2>/dev/null || { echo "counter-refused: P0 journal" >&2; exit 2; }

python3 - "$ROOT" <<'PY' || { echo "counter-refused: fixture build" >&2; exit 2; }
import copy, json, os, sys
root = sys.argv[1]
base = open(os.path.join(root, "base.tsv"), encoding="utf-8").read().splitlines()
p0 = open(os.path.join(root, "p0.tsv"), encoding="utf-8").read().splitlines()
journal = json.load(open(os.path.join(root, "p0-journal.json"), encoding="utf-8"))

def write_ledger(name, lines):
    with open(os.path.join(root, name), "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")

def write_journal(name, doc):
    d = os.path.join(root, name)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "expectation-migrations.json"), "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)

def edit_row(lines, rid, col, value):
    out, hit = [], False
    for line in lines:
        f = line.split("\t")
        if f and f[0] == rid and len(f) > col:
            f[col] = value
            hit = True
            line = "\t".join(f)
        out.append(line)
    if not hit:
        sys.exit(2)
    return out

def delete_row(lines, rid):
    out = [l for l in lines if l.split("\t")[0] != rid]
    if len(out) != len(lines) - 1:
        sys.exit(2)
    return out

def mig(doc, rid):
    for m in doc["migrations"]:
        if m["id"] == rid:
            return m
    sys.exit(2)

# P0: positive control, the round-40 landed state, unmodified.
write_ledger("p0-ledger.tsv", p0)
write_journal("p0-journals", journal)
write_ledger("base-ledger.tsv", base)

# F1: R13-01 loosened, journal entry removed.
f1j = copy.deepcopy(journal)
f1j["migrations"] = [m for m in f1j["migrations"] if m["id"] != "R13-01"]
write_ledger("f1-ledger.tsv", edit_row(p0, "R13-01", 2, "^[0-9]+$"))
write_journal("f1-journals", f1j)

# F2: R21-02 journal old_expect forged to the new value.
f2j = copy.deepcopy(journal)
m = mig(f2j, "R21-02")
m["old_expect"] = m["new_expect"]
write_ledger("f2-ledger.tsv", p0)
write_journal("f2-journals", f2j)

# F3: R13-01 loosened to a non-literal pattern, journal new_expect forged to match.
f3j = copy.deepcopy(journal)
mig(f3j, "R13-01")["new_expect"] = "^[0-9]+$"
write_ledger("f3-ledger.tsv", edit_row(p0, "R13-01", 2, "^[0-9]+$"))
write_journal("f3-journals", f3j)

# F4: R24-06 command rebound to an echo of its expected line; journal unchanged.
rebound = "echo 'ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d9b4de4a3aa7543b7f0370361dd17c2ae18b98c0c318618917dfe50c7'"
write_ledger("f4-ledger.tsv", edit_row(p0, "R24-06", 1, rebound))
write_journal("f4-journals", journal)

# F5: R17-02 deleted from the candidate ledger; no journal entry exists for it (unjournaled).
if not any(l.split("\t")[0] == "R17-02" for l in base) or any(m["id"] == "R17-02" for m in journal["migrations"]):
    sys.exit(2)
write_ledger("f5-ledger.tsv", delete_row(p0, "R17-02"))
write_journal("f5-journals", journal)

# F6: R11-03 deleted from the candidate ledger; no journal entry exists for it either.
# A second deletion id: an id-keyed answer gate keyed on R17-02 alone accepts this case
# (plans/round-43.md C1, the fakeC discrimination).
if not any(l.split("\t")[0] == "R11-03" for l in base) or any(m["id"] == "R11-03" for m in journal["migrations"]):
    sys.exit(2)
write_ledger("f6-ledger.tsv", delete_row(p0, "R11-03"))
write_journal("f6-journals", journal)
PY

run_gate() { # $1 ledger  $2 journals
  bash "$GATE" --base-ledger "$ROOT/base-ledger.tsv" --ledger "$1" --journals "$2" > "$ROOT/out.$$" 2>&1
  rc=$?
  printf '%s' "$rc"
}

rc=$(run_gate "$ROOT/p0-ledger.tsv" "$ROOT/p0-journals")
if [ "$rc" != "0" ]; then
  echo 0
  exit 0
fi

n=0
check() { # $1 name  $2 ledger  $3 journals  $4 token
  local rc
  bash "$GATE" --base-ledger "$ROOT/base-ledger.tsv" --ledger "$2" --journals "$3" > "$ROOT/out-$1.txt" 2>&1
  rc=$?
  if [ "$rc" = "1" ] && grep -qxF "EXPECT_JOURNAL: REFUSE $4" "$ROOT/out-$1.txt"; then
    n=$((n + 1))
  fi
}
check f1 "$ROOT/f1-ledger.tsv" "$ROOT/f1-journals" "UNJOURNALED R13-01"
check f2 "$ROOT/f2-ledger.tsv" "$ROOT/f2-journals" "OLD_MISMATCH R21-02"
check f3 "$ROOT/f3-ledger.tsv" "$ROOT/f3-journals" "NOT_LITERAL R13-01"
check f4 "$ROOT/f4-ledger.tsv" "$ROOT/f4-journals" "COMMAND_MISMATCH R24-06"
check f5 "$ROOT/f5-ledger.tsv" "$ROOT/f5-journals" "DELETED R17-02"
check f6 "$ROOT/f6-ledger.tsv" "$ROOT/f6-journals" "DELETED R11-03"
echo "$n"
exit 0
