#!/usr/bin/env bash
# K43ReviewC1 evidence -- items 2 and 4. Read-only against the lane (git show / diff only).
set -u
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
S=/fast/scratch/hyaku/kagi-r43/K43ReviewC1
R=$S/receipts
BASE=6cc8850dfc5757927699e5a53a876f47c8df21aa
P0=6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0
A1=dd6ccb92bf04a061e9f1e66913d15f097397b1b3
PRE=5f3566c4cfe65a74da4d201d74d28b403929807b
R42=5142b52

# ---- item 4: ledger id sets at BASE/P0/HEAD ----
for pair in "6cc8850:$BASE" "6f1588c:$P0" "HEAD:$A1"; do
  tag=${pair%%:*}; rev=${pair#*:}
  git -C "$L" show "$rev:corpus/claim-ledger.tsv" > "$S/ledger-$tag.tsv" 2>/dev/null || { echo "show $rev failed"; exit 2; }
  cut -f1 "$S/ledger-$tag.tsv" | grep -v '^#' | grep -v '^$' | sort > "$S/ids-$tag.txt"
done
wc -l < "$S/ids-6cc8850.txt" | xargs echo "ids at 6cc8850:"
wc -l < "$S/ids-6f1588c.txt" | xargs echo "ids at 6f1588c:"
wc -l < "$S/ids-HEAD.txt"     | xargs echo "ids at HEAD:"
if diff -u "$S/ids-6cc8850.txt" "$S/ids-6f1588c.txt" > "$R/ids-diff-6cc-6f1.txt" && \
   diff -u "$S/ids-6cc8850.txt" "$S/ids-HEAD.txt"     > "$R/ids-diff-6cc-HEAD.txt"; then
  echo "id sets identical across 6cc8850 / 6f1588c / HEAD: yes"
else
  echo "id sets DIFFER:"; cat "$R/ids-diff-6cc-6f1.txt" "$R/ids-diff-6cc-HEAD.txt"
fi

# ---- item 4: round-42-c1.sh byte-unchanged since 5142b52 ----
git -C "$L" diff --quiet "$R42" "$A1" -- plans/round-42-c1.sh
echo "diff --quiet 5142b52 HEAD -- plans/round-42-c1.sh rc=$?"

# ---- supporting frozen-byte checks ----
git -C "$L" diff --quiet "$PRE" "$A1" -- corpus/expect-journal.sh
echo "diff --quiet 5f3566c HEAD -- corpus/expect-journal.sh rc=$? (kill clause d: 0 = untouched)"
git -C "$L" cat-file -e "$PRE:plans/round-43-c1.sh" 2>/dev/null
echo "cat-file -e 5f3566c:plans/round-43-c1.sh rc=$? (nonzero = counter absent at BASE, no-work control)"

# ---- item 2: R11-03 presence/absence ----
echo "-- R11-03 row counts (base 6cc8850 / P0 6f1588c / HEAD):"
grep -c '^R11-03' "$S/ledger-6cc8850.tsv" "$S/ledger-6f1588c.tsv" "$S/ledger-HEAD.tsv"
echo "-- R11-03 row at 6cc8850 (id, command, expect):"
grep '^R11-03' "$S/ledger-6cc8850.tsv" | cut -f1,2,3
echo "-- R11-03 row at HEAD (id, command, expect):"
grep '^R11-03' "$S/ledger-HEAD.tsv" | cut -f1,2,3

git -C "$L" ls-tree --name-only "$A1" -- .ufo/waves/round-41/ | sed 's/^/round-41 tree: /'
git -C "$L" show "$P0:.ufo/waves/round-40/expectation-migrations.json" > "$S/j40.json" || exit 2
git -C "$L" show "$A1:.ufo/waves/round-41/expectation-migrations.json" > "$S/j41.json" || exit 2
echo "-- literal 'R11-03' occurrences in round-40 journal (at P0) / round-41 journal (at HEAD):"
grep -c 'R11-03' "$S/j40.json" "$S/j41.json"
echo "-- migration ids in round-40 journal:"
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sorted(m["id"] for m in d["migrations"]))' "$S/j40.json"
echo "-- migration ids in round-41 journal:"
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sorted(m["id"] for m in d["migrations"]))' "$S/j41.json"

# ---- item 2: F6-eligible ids (in base, in P0, unjournaled in BOTH journals) ----
python3 - "$S/ledger-6cc8850.tsv" "$S/ledger-6f1588c.tsv" "$S/j40.json" "$S/j41.json" <<'PY'
import json, sys
def ids(p):
    return {l.split("\t")[0] for l in open(p, encoding="utf-8")
            if l.strip() and not l.startswith("#")}
base, p0 = ids(sys.argv[1]), ids(sys.argv[2])
j40 = {m["id"] for m in json.load(open(sys.argv[3]))["migrations"]}
j41 = {m["id"] for m in json.load(open(sys.argv[4]))["migrations"]}
elig = sorted((base & p0) - j40 - j41 - {"R13-01", "R21-02", "R24-06", "R17-02"})
print("F6-eligible ids (in base & P0, unjournaled, not an F1..F5 id):", len(elig))
print(elig)
print("R11-03 eligible:", "R11-03" in elig)
PY
echo EVIDENCE-DONE
