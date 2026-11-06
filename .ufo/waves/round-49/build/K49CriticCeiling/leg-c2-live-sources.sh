#!/usr/bin/env bash
# leg-c2-live-sources.sh — candidate-side leg for round-49 C2 (seat K49CriticCeiling).
#
# The frozen counter takes each of the six keys' live value from the ledger row its
# corpus/self-counts.tsv row names (ledger:R12-03, ledger:R14-01). G1/G2/G3/G4 protect the
# binder, the six table rows, the knowledge files' presence and the stamps path set — but NOT
# corpus/claim-ledger.tsv, where those two live sources are DEFINED. A candidate can repoint
# R12-03/R14-01 at a stub that prints the numbers the documents already state and read
# value=0 while the repo state is unchanged.
#
# This leg closes that: it (1) requires the four source rows' command column to be
# byte-identical to BASE, and (2) re-derives all six quantities directly from the artifacts
# (stamps data lines; claim-ledger.sh docs in a scratch clone) and compares them with the
# numbers the documents state, bypassing the ledger-row indirection entirely.
#
# Usage: bash leg-c2-live-sources.sh <rev> [lane]
# Exit 0 PASS, 1 FAIL, 2 setup.
set -u
REV=${1:?usage: leg-c2-live-sources.sh REV [LANE]}
L=${2:-/home/vgpnk/Projects/shokunin/kagi-shokunin}
BASE=89afe91878f10805921d3caa67d28d21b33226da
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r49"
mkdir -p "$SCR" || { echo "LEG_C2: SETUP scratch"; exit 2; }
W=$(mktemp -d "$SCR/leg-c2.XXXXXX") || { echo "LEG_C2: SETUP mktemp"; exit 2; }
trap 'rm -rf -- "$W"' EXIT

git -C "$L" rev-parse --verify -q "$REV^{commit}" >/dev/null || { echo "LEG_C2: SETUP bad-rev"; exit 2; }
git -C "$L" rev-parse --verify -q "$BASE^{commit}" >/dev/null || { echo "LEG_C2: SETUP base-missing"; exit 2; }
H=$(git -C "$L" rev-parse "$REV^{commit}")

# (1) source-row identity: the rows the six frozen keys bind to must not be redefined.
src_bad=""
for id in R12-03 R14-01; do
  a=$(git -C "$L" show "$BASE:corpus/claim-ledger.tsv" | grep -P "^$id\t" || true)
  b=$(git -C "$L" show "$H:corpus/claim-ledger.tsv" | grep -P "^$id\t" || true)
  [ "$a" = "$b" ] || src_bad="$src_bad $id"
done

# (2) independent re-derivation (no claim-ledger.tsv row is executed for the stamp count).
git -C "$L" archive "$H" | tar -x -C "$W" 2>/dev/null || { echo "LEG_C2: SETUP archive"; exit 2; }
stamps=$(grep -vc '^#' "$W/corpus/stamps.tsv")
skill=$(grep -oE '^\| Re-run a claim .*?\(([0-9]+) stamps \+ ' "$W/SKILL.md" | sed -E 's/.*\(([0-9]+) stamps \+ /\1/' | head -1)
[ -n "$skill" ] || skill=$(grep -oE '\(([0-9]+) (revision )?stamps? \+' "$W/SKILL.md" | sed -E 's/[^0-9]//g' | head -1)
prov=$(grep -oE 'verify`? \(([0-9]+) revision stamps' "$W/PROVINCE.md" | grep -oE '[0-9]+' | head -1)
rd=$(grep -oE '^\| Revision stamps \(data\) \| .*?\| ([0-9]+) rows' "$W/corpus/README.md" | grep -oE '\| [0-9]+ rows' | grep -oE '[0-9]+' | head -1)

# docs: run the real gate in a scratch clone of the measured revision
git clone -q --shared "$L" "$W/c" 2>/dev/null || { echo "LEG_C2: SETUP clone"; exit 2; }
[ "$(git -C "$W/c" rev-parse --show-toplevel)" = "$W/c" ] || { echo "LEG_C2: SETUP clone-toplevel"; exit 2; }
git -C "$W/c" checkout -q --detach "$H" 2>/dev/null || { echo "LEG_C2: SETUP checkout"; exit 2; }
docsl=$(cd "$W/c" && timeout 300 bash corpus/claim-ledger.sh docs 2>&1 | tail -1)
dl=$(printf '%s\n' "$docsl" | grep -oE 'row_linked=[0-9]+' | grep -oE '[0-9]+')
db=$(printf '%s\n' "$docsl" | grep -oE 'by_hand=[0-9]+' | grep -oE '[0-9]+')
de=$(printf '%s\n' "$docsl" | grep -oE 'entries=[0-9]+' | grep -oE '[0-9]+')
r_linked=$(grep -oE '^\| Knowledge-entry declarations \(data\) \| .*?per entry: ([0-9]+) row-linked' "$W/corpus/README.md" | grep -oE '[0-9]+ row-linked' | grep -oE '[0-9]+' | head -1)
r_byhand=$(grep -oE '^\| Knowledge-entry declarations \(data\) \| .*?per entry: [0-9]+ row-linked / ([0-9]+) by-hand' "$W/corpus/README.md" | grep -oE '/ [0-9]+ by-hand' | grep -oE '[0-9]+' | head -1)
r_entries=$(grep -oE '^\| Knowledge-entry declarations \(data\) \| .*?by-hand / ([0-9]+) pinned' "$W/corpus/README.md" | grep -oE '/ [0-9]+ pinned' | grep -oE '[0-9]+' | head -1)

bad=""
[ -z "$src_bad" ] || bad="$bad source-redefined:$src_bad"
[ "$skill" = "$stamps" ] || bad="$bad SC-SKILL-STAMPS stated=$skill live=$stamps"
[ "$prov" = "$stamps" ] || bad="$bad PV-STAMPS stated=$prov live=$stamps"
[ "$rd" = "$stamps" ] || bad="$bad RD-STAMPS stated=$rd live=$stamps"
[ "$r_linked" = "$dl" ] || bad="$bad RD-DOCS-ROWLINKED stated=$r_linked live=${dl:-unreadable}"
[ "$r_byhand" = "$db" ] || bad="$bad RD-DOCS-BYHAND stated=$r_byhand live=${db:-unreadable}"
[ "$r_entries" = "$de" ] || bad="$bad RD-DOCS-ENTRIES stated=$r_entries live=${de:-unreadable}"

if [ -z "$bad" ]; then
  echo "LEG_C2: PASS rev=${H:0:7} stamps=$stamps docs=$dl/$db/$de"
  exit 0
fi
echo "LEG_C2: FAIL rev=${H:0:7}$bad"
exit 1
