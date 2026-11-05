#!/usr/bin/env bash
# corpus/anchor-pins.sh -- round 39 C1 instrument (anchor-cell pin gate for superseded
# release-feed registry rows), amended in round 40 with the reviewer's false-clean fixes
# (M39-12 F1, F2, F3, F6) and a --selftest mode with committed expected findings.
#
# Frozen predicate (the same sentence appears in plans/round-39.md and the round-39 counter):
#   ANCHOR_PINS: CLEAN (pins=N) -- for every row of corpus/anchor-pins.tsv, the anchor cell
#   (SOURCES.md column 7, whitespace-trimmed) of the registry row with that id has the sha256
#   the pin records; any other value, or no such row, prints `DRIFT <id>` and the run exits 1.
#
# Round-40 additions (red-witnessed by --selftest):
#   F1  a duplicate registry row for a pinned id            -> DRIFT <id> dup
#   F2  a tab-indented or >3-space-indented registry row    -> DRIFT <id> shape
#       (the census accepts 0-3 leading spaces; anything else is outside the registry shape)
#   F3  a matched registry row whose column count is not 12 -> DRIFT <id> schema
#   F6  a pin file whose last line has no trailing newline  -> the last pin is still read
#   F4/F5 (pin-row attenuation masking drift) stay covered at the counter level: the
#   round-40 C2 counter asserts the literal pin count, so a removed pin row breaks it.
#   F7 (pin and row rewritten together) remains the named QM40 ceiling; no gate detects it.
#
# usage:
#   anchor-pins.sh [--root DIR]    check DIR (default: the current directory); exit 0 CLEAN,
#                                  1 DRIFT, 2 SETUP (missing pins or registry, or zero pins)
#   anchor-pins.sh --selftest      scratch fixtures; exit 0 PASS, 1 FAIL, 2 setup
#
# Ceiling: the pin file and the registry row are checked against each other in committed
# bytes. A pin rewritten together with its row passes; that is a history question for the
# append-only rule (CORPUS.md SOURCES.md rule 2), not something this gate detects.
set -u
root=.
case "${1:-}" in
  --selftest) exec bash "$0" --run-selftest "$(readlink -f "$0")" ;;
  --run-selftest) GATE_SRC=$(readlink -f "${2:?gate source}"); root=; SELFTEST=1 ;;
  --root) root=${2:?root}; ;;
esac
if [ "${SELFTEST:-0}" = 1 ]; then
  s=$(mktemp -d "${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}/kagi-r40-anchorpins-selftest.XXXXXX") || exit 2
  trap 'rm -rf -- "$s"' EXIT
  mkdir -p "$s/corpus"
  a1="Item titled Python 3.15.0, pubDate Fri, 09 Oct 2026 13:54:59 +0000; feed fetched 2026-10-21"
  a2="Item titled Vault v2.2.0, published 2026-10-01; feed fetched 2026-10-21"
  a3="Item titled Python 3.15.1, pubDate Wed, 21 Oct 2026 09:59:50 +0000; fetched 2026-10-21"
  p1=$(printf '%s' "$a1" | sha256sum | cut -d' ' -f1)
  p2=$(printf '%s' "$a2" | sha256sum | cut -d' ' -f1)
  p3=$(printf '%s' "$a3" | sha256sum | cut -d' ' -f1)
  mreg() { cat > "$s/corpus/SOURCES.md" <<REG
# fixture registry

| A34 | feed one — https://example.invalid/a1 | docs | A | scope one | $a1 | teaches one | mined | 2026-10-21 | 90d | lessons/r1.md |
| A35 | feed two — https://example.invalid/a2 | docs | A | scope two | $a2 | teaches two | mined | 2026-10-21 | 90d | lessons/r2.md |
| A39 | feed three — https://example.invalid/a3 | docs | A | scope three | $a3 | teaches three | mined | 2026-10-21 | 90d | lessons/r3.md |
REG
  }
  mpins() { printf 'id\tanchor_sha256\nA34\t%s\nA35\t%s\nA39\t%s\n' "$p1" "$p2" "$p3" > "$s/corpus/anchor-pins.tsv"; }
  mpins; mreg
  cases=0; passed=0
  chk() { # chk <name> <gate-script> <want_rc> <want_token>
    name=$1; gate=$2; want_rc=$3; want_token=$4
    cases=$((cases + 1))
    got=$(cd "$s" && bash "$gate" 2>/dev/null); rc=$?
    if [ "$rc" -eq "$want_rc" ] && printf '%s' "$got" | grep -qF -- "$want_token"; then
      passed=$((passed + 1))
    else
      echo "SELFTEST-FAIL $name rc=$rc out=$got" >&2
    fi
  }
  # case 1: clean fixture
  chk clean "$GATE_SRC" 0 'ANCHOR_PINS: CLEAN (pins=3)'
  # case 2: in-place anchor rewrite -> DRIFT
  mreg; sed -i 's/Python 3.15.1, pubDate/Python 3.15.2, pubDate/' "$s/corpus/SOURCES.md"
  chk drift-rewrite "$GATE_SRC" 1 'DRIFT A39'
  # case 3 (F1): duplicate registry row after the real one
  mreg; printf '| A39 | feed three — https://example.invalid/a3 | docs | A | scope three | corrupt-anchor | teaches | mined | 2026-10-21 | 90d | lessons/r3.md |\n' >> "$s/corpus/SOURCES.md"
  chk dup-row "$GATE_SRC" 1 'DRIFT A39 dup'
  # case 4 (F2): tab-indented registry row
  mreg; sed -i 's/^| A35 |/\t| A35 |/' "$s/corpus/SOURCES.md"
  chk tab-indent "$GATE_SRC" 1 'DRIFT A35 shape'
  # case 5 (F3): extra trailing pipe cell
  mreg; sed -i 's/| lessons\/r3.md |$/| lessons\/r3.md | extra |/' "$s/corpus/SOURCES.md"
  chk extra-cell "$GATE_SRC" 1 'DRIFT A39 schema'
  # case 6 (F6): pin file without final newline still reads its last pin
  mreg; printf 'id\tanchor_sha256\nA34\t%s\nA35\t%s\nA39\t%s' "$p1" "$p2" "$p3" > "$s/corpus/anchor-pins.tsv"
  chk no-final-newline "$GATE_SRC" 0 'ANCHOR_PINS: CLEAN (pins=3)'
  # case 7: registry row missing for a pinned id
  mreg; grep -v '^| A35 |' "$s/corpus/SOURCES.md" > "$s/corpus/SOURCES.md.2" && mv "$s/corpus/SOURCES.md.2" "$s/corpus/SOURCES.md"
  chk row-missing "$GATE_SRC" 1 'DRIFT A35 row-missing'
  # case 8 (M39-6 class): a constant-CLEAN mutant of this gate must diverge from the real gate
  mreg; mpins; sed 's/^if \[ "\$bad" -gt 0 \]; then$/if false; then/' "$GATE_SRC" > "$s/mutant-gate.sh" || exit 2
  mreg; sed -i 's/Python 3.15.1, pubDate/Python 3.15.2, pubDate/' "$s/corpus/SOURCES.md"
  cases=$((cases + 1))
  real_rc=$(cd "$s" && bash "$GATE_SRC" >/dev/null 2>&1; echo $?)
  mut_rc=$(cd "$s" && bash "$s/mutant-gate.sh" >/dev/null 2>&1; echo $?)
  if [ "$real_rc" = 1 ] && [ "$mut_rc" = 0 ]; then passed=$((passed + 1)); else
    echo "SELFTEST-FAIL constant-mutant real=$real_rc mutant=$mut_rc" >&2
  fi
  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 8 ]; then
    echo "ANCHOR_PINS_SELFTEST: PASS (8 cases)"
    exit 0
  fi
  echo "ANCHOR_PINS_SELFTEST: FAIL (passed=$passed/$cases)"
  exit 1
fi
pins="$root/corpus/anchor-pins.tsv"
reg="$root/corpus/SOURCES.md"
if [ ! -f "$pins" ] || [ ! -f "$reg" ]; then
  echo "ANCHOR_PINS: SETUP missing-input"
  exit 2
fi
n=0
bad=0
while IFS=$'\t' read -r id want || [ -n "${id:-}" ]; do
  case $id in
    ''|'#'*|id) continue ;;
  esac
  n=$((n + 1))
  read -r rows shape schema anchor <<EOF
$(awk -F'|' -v id="$id" '
  {
    lead = $0; sub(/\|.*/, "", lead)
    t = $2; gsub(/^[ \t]+|[ \t]+$/, "", t)
    if (t != id) next
    rows++
    if (lead ~ /\t/ || lead !~ /^ {0,3}$/) shape++
    if (NF != 13) schema++
    if (a == "") { a = $7; gsub(/^[ \t]+|[ \t]+$/, "", a) }
  }
  END { print rows+0, shape+0, schema+0, a }' "$reg")
EOF
  if [ "$rows" -eq 0 ]; then
    echo "DRIFT $id row-missing"
    bad=$((bad + 1))
    continue
  fi
  if [ "$rows" -gt 1 ]; then
    echo "DRIFT $id dup"
    bad=$((bad + 1))
    continue
  fi
  if [ "$shape" -gt 0 ]; then
    echo "DRIFT $id shape"
    bad=$((bad + 1))
    continue
  fi
  if [ "$schema" -gt 0 ]; then
    echo "DRIFT $id schema"
    bad=$((bad + 1))
    continue
  fi
  if [ -z "$anchor" ]; then
    echo "DRIFT $id empty-anchor"
    bad=$((bad + 1))
    continue
  fi
  got=$(printf '%s' "$anchor" | sha256sum | cut -d' ' -f1)
  if [ "$got" != "$want" ]; then
    echo "DRIFT $id"
    bad=$((bad + 1))
  fi
done < "$pins"
if [ "$n" -eq 0 ]; then
  echo "ANCHOR_PINS: SETUP no-pins"
  exit 2
fi
if [ "$bad" -gt 0 ]; then
  echo "ANCHOR_PINS: CLEAN (pins=$n)"
  exit 1
fi
echo "ANCHOR_PINS: CLEAN (pins=$n)"
exit 0
