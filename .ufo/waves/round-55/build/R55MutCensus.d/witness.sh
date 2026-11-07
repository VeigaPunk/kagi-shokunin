#!/usr/bin/env bash
# Witness probes for the four surviving mutants: build a fixture the pristine gate
# accepts (or flags once), then show the mutant diverges.
set -uo pipefail
S=/fast/scratch/hyaku/kagi-r55/R55MutCensus
REV=$S/rev/corpus/sources-census.sh
W=$S/wit
rm -rf -- "$W"; mkdir -p "$W"

mkfix() { # dir
  bash -c 'set -uo pipefail; rev=$1; d=$2; set --; source <(sed "/^case \$MODE in/,\$d" "$rev"); base_fixture "$d"' _ "$REV" "$1"
}

run() { # label script fixture
  local out rc
  out=$(TMPDIR="$S/tmp" bash "$2" verify --root "$3" 2>&1); rc=$?
  printf '%s rc=%s findings=%s last=%s\n' "$1" "$rc" "$(grep -c '^FINDING ' <<<"$out")" "${out##*$'\n'}"
  printf '%s\n' "$out" >"$S/rep/wit-$1.txt"
}

# --- W08: source: line ends with the id (field clause must accept end-of-string)
d=$W/W08; mkfix "$d"
printf '# entry one\nsource: S001 (https://example.invalid/one, §1, rev 1); S002\nverified-at: 2026-10-19\nrecheck: 90d\n\nBody.\n' >"$d/corpus/knowledge/e1.md"
run W08-pristine "$REV" "$d"
run W08-M08 "$S/mut/M08/corpus/sources-census.sh" "$d"

# --- W09: tab-led continuation of the cites: line
d=$W/W09; mkfix "$d"
printf '# entry one\nsource: S001 (https://example.invalid/one, §1, rev 1); S002 (https://example.invalid/two, §2, 2026-01-01)\nverified-at: 2026-10-19\nrecheck: 90d\ncites: S001\n\tS003\n\nSee S003.\n' >"$d/corpus/knowledge/e1.md"
sed -i '/^| S003 /s#| — |$#| corpus/knowledge/e1.md |#' "$d/corpus/SOURCES.md"
run W09-pristine "$REV" "$d"
run W09-M09 "$S/mut/M09/corpus/sources-census.sh" "$d"

# --- W11: parenthesised cites id that is not a registry row
d=$W/W11; mkfix "$d"
printf '\ncites: (S099)\n' >>"$d/corpus/knowledge/e1.md"
run W11-pristine "$REV" "$d"
run W11-M11 "$S/mut/M11/corpus/sources-census.sh" "$d"

# --- W13: same unrecorded id named twice in one body
d=$W/W13; mkfix "$d"
printf '\nThe lead S003 says so. Again S003.\n' >>"$d/corpus/knowledge/e1.md"
run W13-pristine "$REV" "$d"
run W13-M13 "$S/mut/M13/corpus/sources-census.sh" "$d"
echo WITNESS_DONE
