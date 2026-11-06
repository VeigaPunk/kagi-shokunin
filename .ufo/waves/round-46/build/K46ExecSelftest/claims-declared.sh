#!/usr/bin/env bash
# corpus/claims-declared.sh -- round 39 C2 instrument (declared-axis conformance gate),
# amended in round 40 with the reviewer's false-clean fixes (M39-12 D1, D2, D3, D5) and a
# --selftest mode with committed expected findings.
#
# Frozen predicate (the same sentence appears in plans/round-39.md and the round-39 counter):
#   CLAIMS_DECLARED: CLEAN (claims=N) -- for every row `round<TAB>claim<TAB>axis` of
#   corpus/claims-declared.tsv: (a) plans/round-<round>.md carries the heading
#   `## <claim> — <axis>:`; (b) SCORECARD.md's `## Round <round> — post-move` section holds
#   exactly one table row tagged `[<claim>]`, and that row's first cell equals <axis>.
#   Any other reading prints `MISMATCH <round> <claim> <reason>` and the run exits 1.
#
# Round-40 additions (red-witnessed by --selftest):
#   D1  duplicate manifest rows for the same (round, claim)      -> MISMATCH dup-row
#   D2  the plan heading must match at column 0 and outside      -> fence/comment headings
#       fenced code blocks and HTML comments are not headings       no longer count
#   D3  the `## Round <round> — post-move` section header must   -> MISMATCH section-missing /
#       exist exactly once and the tagged row must be inside it     duplicate-section
#   D5  the tagged row's first cell must equal the axis byte-    -> MISMATCH axis-cell
#       exactly after stripping one padding space per side          (padded cells rejected)
#   D4 (conspiratorial relabel of all three surfaces) and the colon-suffix over-match window
#   remain named ceilings (QM41): the gate reads the lane's own text, not axis fitness.
#
# usage:
#   claims-declared.sh [--root DIR]   default DIR is the current directory; exit 0 CLEAN,
#                                     1 MISMATCH, 2 SETUP (missing manifest, zero rows, or an
#                                     axis outside the six AXES.md names)
#   claims-declared.sh --selftest     scratch fixtures; exit 0 PASS, 1 FAIL, 2 setup
set -u
root=.
case "${1:-}" in
  --selftest) exec bash "$0" --run-selftest "$(readlink -f "$0")" ;;
  --run-selftest) GATE_SRC=$(readlink -f "${2:?gate source}"); root=; SELFTEST=1 ;;
  --root) root=${2:?root}; ;;
esac
if [ "${SELFTEST:-0}" = 1 ]; then
  s=$(mktemp -d "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43-claimsdecl-selftest.XXXXXX") || exit 2
  trap 'rm -rf -- "$s"' EXIT
  mkdir -p "$s/corpus" "$s/plans"
  mfix() { # mfix: a conforming fixture lane for round 90, claims C1 freshness + C2 calibration
    rm -f "$s/plans/round-39.md" "$s/plans/round-91.md"
    printf 'round\tclaim\taxis\n90\tC1\tfreshness\n90\tC2\tcalibration\n' > "$s/corpus/claims-declared.tsv"
    printf '# fixture plan\n\n## C1 — freshness: located quotes, 0 → 2\n\ntext\n\n## C2 — calibration: declared axes, 0 → 2\n\ntext\n' > "$s/plans/round-90.md"
    cat > "$s/SCORECARD.md" <<'SC'
# fixture scorecard

## Round 89 — post-move (history)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| coverage | 9 → 9 | older row | R89-01 |

## Round 90 — post-move (claims C1 freshness, C2 calibration)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | [C1] located quotes 0 → 2 | R90-01 |
| calibration | 9 → 9 | [C2] declared axes 0 → 2 | R90-02 |
SC
  }
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
  # named ceiling: chk checks rc plus one token; a mutant that also prints the
  # expected token (with spurious extra output) is not refused here.
  # case 1: clean fixture
  mfix
  chk clean "$GATE_SRC" 0 'CLAIMS_DECLARED: CLEAN (claims=2)'
  # case 2 (D1): duplicate manifest rows for the same (round, claim)
  mfix; printf '90\tC1\tfreshness\n' >> "$s/corpus/claims-declared.tsv"
  chk dup-row "$GATE_SRC" 1 'MISMATCH 90 C1 dup-row'
  # case 3 (D2): heading inside a fenced code block does not count
  mfix; printf '```\n## C1 — freshness: fake heading in a fence\n```\n' >> "$s/plans/round-90.md"
  sed -i 's/^## C1 — freshness: located quotes, 0 → 2$/REMOVED-REAL-HEADING/' "$s/plans/round-90.md"
  chk fence-heading "$GATE_SRC" 1 'MISMATCH 90 C1 plan-heading-not-freshness'
  # case 4 (D3): the tagged row sits only in a previous round's section
  mfix; sed -i '0,/^## Round 90 — post-move/s//## Round 91 — post-move/' "$s/SCORECARD.md"
  chk cross-section "$GATE_SRC" 1 'MISMATCH 90 C1 section-missing'
  # case 5 (D5): padded axis cell
  mfix; sed -i 's/^| freshness |/|   freshness   |/' "$s/SCORECARD.md"
  chk padded-cell "$GATE_SRC" 1 'MISMATCH 90 C1 axis-cell'
  # case 6: tagged row deleted
  mfix; sed -i '/\[C1\]/d' "$s/SCORECARD.md"
  chk missing-tag "$GATE_SRC" 1 'MISMATCH 90 C1 tagged-rows-0'
  # case 7: duplicate tags inside the section
  mfix; sed -i 's/^| calibration | 9 → 9 | \[C2\] declared axes 0 → 2 | R90-02 |$/| calibration | 9 → 9 | [C1] duplicate tag on another row | R90-02 |/' "$s/SCORECARD.md"
  chk duplicate-tag "$GATE_SRC" 1 'MISMATCH 90 C1 tagged-rows-2'
  # case 8 (M39-6 class): a constant-CLEAN mutant must diverge from the real gate
  mfix; sed '/\[C1\]/d' "$s/SCORECARD.md" > "$s/SCORECARD.md.2" && mv "$s/SCORECARD.md.2" "$s/SCORECARD.md"
  sed 's/^if \[ "\$bad" -gt 0 \]; then$/if false; then/' "$GATE_SRC" > "$s/mutant-gate.sh" || exit 2
  cases=$((cases + 1))
  real_rc=$(cd "$s" && bash "$GATE_SRC" >/dev/null 2>&1; echo $?)
  mut_rc=$(cd "$s" && bash "$s/mutant-gate.sh" >/dev/null 2>&1; echo $?)
  if [ "$real_rc" = 1 ] && [ "$mut_rc" = 0 ]; then passed=$((passed + 1)); else
    echo "SELFTEST-FAIL constant-mutant real=$real_rc mutant=$mut_rc" >&2
  fi
  # case 9 (round-45 plan-to-manifest leg): a landed round whose plan heading has
  # no manifest row reports it; the fixture is otherwise conforming.
  mfix; printf 'round\tclaim\taxis\n90\tC1\tfreshness\n' > "$s/corpus/claims-declared.tsv"
  chk no-manifest-row "$GATE_SRC" 1 'MISMATCH 90 C2 no-manifest-row'
  # case 10 (round-45 plan-to-manifest leg): an in-flight round (plan headings, no
  # post-move section) is not checked.
  mfix; printf '# fixture plan\n\n## C1 — freshness: in-flight claim\n\ntext\n' > "$s/plans/round-91.md"
  chk in-flight-round "$GATE_SRC" 0 'CLAIMS_DECLARED: CLEAN (claims=2)'
  # case 11 (round-45 plan-to-manifest leg): the scope floor is inclusive -- a landed
  # round 39 claim with no manifest row is checked and reported.
  mfix; printf '# fixture plan\n\n## C1 — freshness: landed at the floor\n\ntext\n' > "$s/plans/round-39.md"
  printf '\n## Round 39 — post-move (landed)\n\n| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n| freshness | 8 → 9 | [C1] landed at the floor | R39-01 |\n' >> "$s/SCORECARD.md"
  chk landed-floor "$GATE_SRC" 1 'MISMATCH 39 C1 no-manifest-row'
  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 11 ]; then
    printf 'CLAIMS_DECLARED_SELFTEST: PASS (%d cases)\n' "$cases"
    exit 0
  fi
  echo "CLAIMS_DECLARED_SELFTEST: FAIL (passed=$passed/$cases)"
  exit 1
fi
manifest="$root/corpus/claims-declared.tsv"
if [ ! -f "$manifest" ] || [ ! -f "$root/SCORECARD.md" ]; then
  echo "CLAIMS_DECLARED: SETUP missing-input"
  exit 2
fi
n=0
bad=0
declare -A seen_pair=()
while IFS=$'\t' read -r round claim axis || [ -n "${round:-}" ]; do
  case $round in
    ''|'#'*|round) continue ;;
  esac
  case $axis in
    depth|coverage|operability|freshness|calibration|adjacency) ;;
    *) echo "CLAIMS_DECLARED: SETUP axis-not-in-AXES '$axis' ($round $claim)"; exit 2 ;;
  esac
  n=$((n + 1))
  key="$round/$claim"
  if [ -n "${seen_pair[$key]:-}" ]; then
    echo "MISMATCH $round $claim dup-row"
    bad=$((bad + 1))
    continue
  fi
  seen_pair[$key]=1
  plan="$root/plans/round-$round.md"
  if ! awk -v want="## $claim — $axis:" '
    /^[[:space:]]*(```|~~~)/ { fence = !fence; next }
    /<!--/ { htmlc = 1 }
    /-->/  { htmlc = 0 }
    !fence && !htmlc && index($0, want) == 1 { found = 1 }
    END { exit found ? 0 : 1 }' "$plan" 2>/dev/null; then
    echo "MISMATCH $round $claim plan-heading-not-$axis"
    bad=$((bad + 1))
    continue
  fi
  read -r seen cnt dupsec arok <<EOF
$(awk -v round="$round" -v tag="[$claim]" -v axis="$axis" '
  BEGIN { seen = 0; cnt = 0; dupsec = 0; cell = "" }
  index($0, "## Round " round " — post-move") == 1 {
    if (seen) dupsec = 1; else { seen = 1; insec = 1 }
    next
  }
  /^## / { insec = 0; next }
  insec && /^\|/ && index($0, tag) > 0 {
    cnt++
    if (cell == "") {
      first = $0
      sub(/^\|[ ]?/, "", first)
      sub(/[ ]?\|.*$/, "", first)
      cell = first
    }
  }
  END { ok = (cell == axis) ? 1 : 0; print seen+0, cnt+0, dupsec+0, ok }' "$root/SCORECARD.md")
EOF
  if [ "$seen" -eq 0 ]; then
    echo "MISMATCH $round $claim section-missing"
    bad=$((bad + 1))
    continue
  fi
  if [ "$dupsec" -ne 0 ]; then
    echo "MISMATCH $round $claim duplicate-section"
    bad=$((bad + 1))
    continue
  fi
  if [ "$cnt" -ne 1 ]; then
    echo "MISMATCH $round $claim tagged-rows-$cnt"
    bad=$((bad + 1))
    continue
  fi
  if [ "$arok" -ne 1 ]; then
    echo "MISMATCH $round $claim axis-cell-not-$axis"
    bad=$((bad + 1))
  fi
done < "$manifest"
# Round-45 C1 plan-to-manifest direction (frozen predicate): a round R >= 39 is
# checked when plans/round-R.md carries claim headings AND SCORECARD.md carries
# `## Round R — post-move`. Each such heading needs exactly one manifest row
# (R, Ck, axis); a missing row prints MISMATCH R Ck no-manifest-row.
declare -A manifest_set=()
while IFS=$'\t' read -r mround mclaim maxis || [ -n "${mround:-}" ]; do
  case $mround in
    ''|'#'*|round) continue ;;
  esac
  manifest_set["$mround/$mclaim/$maxis"]=1
done < "$manifest"
for planfile in "$root"/plans/round-*.md; do
  [ -f "$planfile" ] || continue
  fname=${planfile##*/}
  rname=${fname#round-}
  rname=${rname%.md}
  case $rname in
    ''|*[!0-9]*) continue ;;
  esac
  if [ "$((10#$rname))" -lt 39 ]; then continue; fi
  if ! awk -v want="## Round $rname — post-move" 'index($0, want) == 1 { found = 1 } END { exit found ? 0 : 1 }' "$root/SCORECARD.md" 2>/dev/null; then
    continue
  fi
  while IFS=$'\t' read -r hclaim haxis; do
    [ -n "${hclaim:-}" ] || continue
    if [ -z "${manifest_set["$rname/$hclaim/$haxis"]:-}" ]; then
      echo "MISMATCH $rname $hclaim no-manifest-row"
      bad=$((bad + 1))
    fi
  done <<EOF
$(awk '
    /^[[:space:]]*(```|~~~)/ { fence = !fence; next }
    /<!--/ { htmlc = 1 }
    /-->/  { htmlc = 0 }
    !fence && !htmlc {
      line = $0
      if (line ~ /^## C[0-9]+ — [a-z]+:/) {
        sub(/^## /, "", line)
        claim = line; sub(/ .*/, "", claim)
        rest = line; sub(/^[^ ]+ — /, "", rest)
        axis = rest; sub(/:.*$/, "", axis)
        print claim "\t" axis
      }
    }' "$planfile")
EOF
done
if [ "$n" -eq 0 ]; then
  echo "CLAIMS_DECLARED: SETUP no-rows"
  exit 2
fi
if [ "$bad" -gt 0 ]; then
  echo "CLAIMS_DECLARED: MISMATCH (claims=$n mismatch=$bad)"
  exit 1
fi
echo "CLAIMS_DECLARED: CLEAN (claims=$n)"
exit 0
