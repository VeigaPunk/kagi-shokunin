#!/usr/bin/env bash
# R63ScoutSources — applier for the two registry-census defects measured in
# .ufo/waves/round-63/build/R63ScoutSources/census-receipt.txt
#
# The L1 owns every write to corpus/SOURCES.md, corpus/source-fetches.tsv and the
# lane's git/jj index. This script is NOT run by the scout seat; it is a
# ready-to-run patch the L1 applies itself, after the row append.
#
# Usage (from the lane root):
#   bash .ufo/waves/round-63/build/R63ScoutSources/apply-census-fix.sh [--dry-run]
#
# What it changes (both measured; see the receipt):
#
#   (a) S136 — a registry row whose body is 0 bytes cannot carry a capture row:
#       corpus/sources-census.sh:352 requires every registry row to have a
#       source-fetches.tsv entry (else `SC_FETCH id=… missing-provenance`) and
#       :290 requires the capture row's bytes to match ^[1-9][0-9]*$. The drafted
#       S136 row points at https://ieeexplore.ieee.org/document/5661753, which
#       returns HTTP 202 with a 0-byte body, so it has no valid capture row.
#       Fix: re-point the S136 row at its readable sibling
#       https://ieeexplore.ieee.org/abstract/document/5661753 — the body that
#       proves the misidentification ("Address Translation Aware Memory
#       Consistency") — and give it a capture row on that fetch. The row's
#       teaches cell already records the 202/0-byte measurement of the plan's
#       named URL, so nothing about the rejection is lost.
#       Measured: BASE + drafted rows + this fix + (b) => the census reports
#       exactly the two pre-existing BASE findings, nothing added.
#
#   (b) S130 — the round-63 knowledge entry names S130 in its prose
#       (corpus/knowledge/negation-scope-grammar.md:21) and
#       corpus/sources-census.sh:390 requires every id an entry names to be
#       listed in that row's `used-by` (else `SC_ENTRY_CITE … used-by-omits-entry`).
#       `used-by` is an in-place cell, which CORPUS.md rule 2 permits. Add
#       corpus/knowledge/negation-scope-grammar.md.
#       Do NOT add corpus/lessons/round-63.md: the lesson carries S130 in prose
#       but not on its `cites:` line, so that path raises SC_USEDBY_NOCITE
#       (both variants were measured).
#
# The script is idempotent and verifies with the lane's own gate at the end.
set -uo pipefail

LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
SOURCES="$LANE/corpus/SOURCES.md"
FETCHES="$LANE/corpus/source-fetches.tsv"
CENSUS="$LANE/corpus/sources-census.sh"
DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

fail() { printf 'APPLY: FAILED (%s)\n' "$*" >&2; exit 1; }
say()  { printf 'APPLY: %s\n' "$*"; }

[[ -f "$SOURCES" ]] || fail "missing $SOURCES"
[[ -f "$FETCHES" ]] || fail "missing $FETCHES"
[[ -f "$CENSUS"  ]] || fail "missing $CENSUS"

# The row must already exist (the L1 appends it); this script only patches it.
grep -qE '^\|[[:space:]]*S136[[:space:]]*\|' "$SOURCES" || fail "S136 row not present — append the rows first"
grep -qE '^\|[[:space:]]*S130[[:space:]]*\|' "$SOURCES" || fail "S130 row not present"

python3 - "$SOURCES" "$FETCHES" "$DRY" <<'PY'
import hashlib, re, sys

sources, fetches, dry = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
SIBLING = "https://ieeexplore.ieee.org/abstract/document/5661753"
KB = "corpus/knowledge/negation-scope-grammar.md"

# ---- (a) re-point the S136 row at its readable sibling -----------------------
lines = open(sources, encoding="utf-8").read().split("\n")
changed_a = False
for i, l in enumerate(lines):
    if l.startswith("| S136 |"):
        cells = l.split("|")
        if SIBLING not in cells[2]:
            cells[2] = (" IEEE Xplore document 5661753 (the plan's named Jia & Harman lead; "
                        "the named URL returns HTTP 202 with a 0-byte body, and the capture "
                        "is its readable /abstract sibling) — " + SIBLING + " ")
            lines[i] = "|".join(cells)
            changed_a = True
        break
if changed_a and not dry:
    open(sources, "w", encoding="utf-8").write("\n".join(lines))

# ---- (a) give S136 a capture row on that sibling -----------------------------
frows = [l for l in open(fetches, encoding="utf-8").read().split("\n")]
frows = [l for l in frows if l and not l.startswith("#")]
s136 = [l for l in frows if l.split("\t")[0:1] == ["S136"]]
s142 = [l for l in frows if l.split("\t")[0:1] == ["S142"]]
added = False
if not s136 and s142:
    row = s142[0].split("\t")
    row[0] = "S136"
    row[1] = "rejected"
    ident = hashlib.sha256(("%s\t%s\t%s\n" % (row[0], row[1], row[3])).encode()).hexdigest()
    row[2] = ident
    frows.append("\t".join(row))
    added = True
if added and not dry:
    open(fetches, "w", encoding="utf-8").write("\n".join(frows) + "\n")

# ---- (b) extend S130's used-by with the knowledge entry ----------------------
lines = open(sources, encoding="utf-8").read().split("\n")
changed_b = False
for i, l in enumerate(lines):
    if l.startswith("| S130 |"):
        cells = l.split("|")
        cur = [p.strip() for p in cells[11].split(",") if p.strip()]
        if KB not in cur:
            cur.append(KB)
            cells[11] = " " + ", ".join(cur) + " "
            lines[i] = "|".join(cells)
            changed_b = True
        break
if changed_b and not dry:
    open(sources, "w", encoding="utf-8").write("\n".join(lines))

print("APPLY: S136 re-pointed=%s capture-row-added=%s S130 used-by-extended=%s dry-run=%s"
      % (changed_a, added, changed_b, dry))
PY
[[ $? -eq 0 ]] || fail "python patch step failed"

if [[ $DRY -eq 1 ]]; then
  say "dry run: nothing written"
  exit 0
fi

say "verifying with the lane's own registry gate"
( cd "$LANE" && bash "$CENSUS" ) 2>&1 | sed 's/^/APPLY: census: /'
rc=${PIPESTATUS[0]}
if [[ $rc -eq 0 ]]; then
  say "census CLEAN — the two findings are cleared"
else
  say "census still reports findings (rc=$rc); see the output above and .ufo/waves/round-63/build/R63ScoutSources/census-receipt.txt"
fi
exit 0
