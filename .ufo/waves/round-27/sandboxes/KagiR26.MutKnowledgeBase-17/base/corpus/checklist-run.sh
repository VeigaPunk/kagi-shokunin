#!/usr/bin/env bash
# checklist-run.sh — the credential-hygiene checklist, executable (round 15).
#
# `SKILL.md` §Credential-hygiene checklist holds 16 items. Until round 15 they
# were prose: no command mapped an item to a verdict, so "run the checklist"
# was reading, and the judgement/per-item split was an assertion. This gate
# binds every item to exactly one row of
#
#   corpus/checklist.tsv
#   id <TAB> class <TAB> lead <TAB> check <TAB> expect_exit <TAB> expect_last
#      <TAB> reason <TAB> note
#
#   class runnable  check = shell command run with cwd = repo root and a
#                   timeout; expect_exit = integer or `A|B|C`; expect_last = ERE
#                   matched against the last non-blank stdout line of the check.
#                   reason must be `-`.
#   class by-hand   check/expect_exit/expect_last must be `-`; reason is
#                   `<class>: <text>` with the class from a closed set and text
#                   >= 24 chars, unique across rows. A by-hand row is a
#                   declaration, never a silent omission.
#   lead            an ERE matched against the text of the item the row
#                   declares. The mapping is a bijection over the 16 items: one
#                   row per item, one item per row. Positional guessing is not
#                   allowed, and a row whose lead matches nothing, or an item no
#                   row matches, is a defect.
#
# Verdicts  OK:  `CHECKLIST_RUN: CLEAN (items=N runnable=K by_hand=M failed=0)`
#                `CHECKLIST_RATIO: runnable=K/N floor=F by_hand=M delegated=D direct=K-D`
#                (`delegated` = rows whose check is `bash corpus/<gate>.sh`, i.e.
#                 the item already had a gate; `direct` = assertions this file
#                 introduces — the two are not the same claim)
#           defects (exit 1): ITEM-FAIL <id> (exit a want b) · ITEM-LASTLINE
#                <id> (want … got …) · UNDECLARED · EXTRA · UNMATCHED-ITEM ·
#                UNMATCHED-LEAD · DUPLICATE-LEAD · DUPLICATE-REASON ·
#                RATIO (runnable=K floor=F)
#           shape/policy (exit 2): POLICY · SETUP (nothing executed)
#           `--only ID` prints `CHECKLIST_ROW: CLEAN|BROKEN (id=…)` instead of a
#           checklist verdict: one row is not the checklist
# Exit      0 clean · 1 item or declaration defect · 2 usage/setup/shape
#
# Secret hygiene: a row may not touch a denied surface (a POLICY check refuses
# any `check` naming op.env, `op run|read|inject`, a handler start/stop/run or
# the ledger gate), no row resolves a reference, and the ref-path scan prints
# counts only — printing the matched line of that scan would be the very leak
# the item forbids. That deny list governs a row's OWN check string: a row that
# delegates to another gate inherits that gate's policy instead, which is
# stated on the row (row E5 delegates to op-ref-probe.sh, the one row whose
# delegate execs `op run` over generated plain fixtures and refuses any ref
# token before exec).
#
# Usage:
#   checklist-run.sh                 verify every row against this host
#   checklist-run.sh --ratio         audit the declaration and print only the
#                                    CHECKLIST_RATIO line; executes no row
#   checklist-run.sh --list          print the declaration table, run nothing
#   checklist-run.sh --only ID       run (or report) one row
#   checklist-run.sh --selftest      scratch-tree proof that the gate fires
#   checklist-run.sh --tsv F --skill F   alternate declaration/checklist (the
#                                    selftest harness; real runs use the repo pair)
#   checklist-run.sh --help
# Env: CHECKLIST_TIMEOUT (seconds per row, default 240)
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SELF="$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")"   # absolute: the selftest re-invokes itself from any cwd
ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
TSV="$SCRIPT_DIR/checklist.tsv"
SKILL="$ROOT/SKILL.md"
MODE="verify"
RATIO_ONLY=0
ONLY=""
ROW_TIMEOUT=${CHECKLIST_TIMEOUT:-240}
FLOOR_DEN=2   # floor = ceil(items / FLOOR_DEN)
BYHAND_CLASSES='authoring-duty|runtime-behavior|cross-lane|manual-change|operator-scope'
DENY_CHECK='op\.env|op run|op read|op inject|the-janitor start|the-janitor stop|the-janitor run|claim-ledger\.sh'

usage() { awk 'NR > 1 && /^set -euo/ { exit } NR > 1 { sub(/^# ?/, ""); print }' "${BASH_SOURCE[0]}"; }

while (($#)); do
  case "$1" in
    --list) MODE="list" ;;
    --ratio) MODE="verify"; RATIO_ONLY=1 ;;
    --selftest) MODE="selftest" ;;
    --only) [[ -n "${2:-}" ]] || { printf 'checklist-run: --only needs an id\n' >&2; exit 2; }; ONLY="$2"; shift ;;
    --tsv) [[ -n "${2:-}" ]] || { printf 'checklist-run: --tsv needs a path\n' >&2; exit 2; }; TSV="$2"; shift ;;
    --skill) [[ -n "${2:-}" ]] || { printf 'checklist-run: --skill needs a path\n' >&2; exit 2; }; SKILL="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'checklist-run: unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

BAD=0
defect() { printf '%s\n' "$*"; BAD=1; }

# ---------------------------------------------------------------- items ---
# Items live in one section of SKILL.md, one `- [ ] ` bullet each; continuation
# lines are indented. extract_items <skill> <dir> -> count on stdout, item n in
# <dir>/n (raw, possibly multi-line).
extract_items() {
  local f=$1 d=$2 line in=0 n=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if ((in == 0)); then
      [[ "$line" == '## Credential-hygiene checklist' ]] && in=1
      continue
    fi
    [[ "$line" == '## '* ]] && break
    if [[ "$line" == '- [ ] '* ]]; then
      n=$((n + 1))
      printf '%s\n' "${line#- \[ \] }" >"$d/$n"
    elif ((n > 0)) && [[ "$line" == [[:space:]]* ]] && [[ -n "${line//[[:space:]]/}" ]]; then
      printf '%s\n' "$line" >>"$d/$n"
    fi
  done <"$f"
  printf '%s' "$n"
}

# ---------------------------------------------------------------- rows ---
# Parallel arrays, index 1..N. load_rows -> 0 ok, 2 shape/policy (rows skipped).
load_rows() {
  local line n=0 id class lead check exexit exlast reason note rt ns
  local -a f
  ROWS_N=0
  if [[ ! -r "$TSV" ]]; then
    printf 'SETUP checklist.tsv not readable: %s\n' "$TSV"
    return 2
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    IFS=$'\t' read -r -a f <<<"$line"
    if [[ ${#f[@]} -ne 8 ]]; then
      printf 'POLICY row %s: %d columns, want 8 (id class lead check expect_exit expect_last reason note)\n' \
        "${f[0]:-<blank>}" "${#f[@]}"
      BAD=1
      continue
    fi
    id=${f[0]} class=${f[1]} lead=${f[2]} check=${f[3]} exexit=${f[4]} exlast=${f[5]} reason=${f[6]} note=${f[7]}
    n=$((n + 1))
    if [[ ! "$id" =~ ^[A-Z][0-9]+$ ]]; then
      printf 'POLICY row %d: id %q is not <letter><digits>\n' "$n" "$id"; BAD=1
    fi
    case "$class" in
      runnable)
        [[ -n "$check" && "$check" != '-' ]] || { printf 'POLICY row %s: runnable row needs a check\n' "$id"; BAD=1; }
        [[ "$exexit" =~ ^[0-9]+(\|[0-9]+)*$ ]] || { printf 'POLICY row %s: expect_exit %q is not N or A|B|…\n' "$id" "$exexit"; BAD=1; }
        [[ -n "$exlast" && "$exlast" != '-' ]] || { printf 'POLICY row %s: runnable row needs expect_last\n' "$id"; BAD=1; }
        [[ "$reason" == '-' ]] || { printf 'POLICY row %s: runnable row must carry reason `-` (the by-hand class is for by-hand rows)\n' "$id"; BAD=1; }
        [[ -n "$note" && "$note" != '-' ]] || { printf 'POLICY row %s: runnable row needs a note saying what it verifies\n' "$id"; BAD=1; }
        if [[ "$check" =~ $DENY_CHECK ]]; then
          printf 'POLICY row %s: check touches a denied surface (/%s/)\n' "$id" "$DENY_CHECK"; BAD=1
        fi
        ;;
      by-hand)
        [[ "$check" == '-' && "$exexit" == '-' && "$exlast" == '-' ]] || {
          printf 'POLICY row %s: by-hand row must carry `-` for check/expect_exit/expect_last\n' "$id"; BAD=1; }
        [[ "$reason" =~ ^($BYHAND_CLASSES):\ .{24,}$ ]] || {
          printf 'POLICY row %s: reason %q is not `<class>: <>=24 chars>` with class in (%s)\n' "$id" "$reason" "$BYHAND_CLASSES"; BAD=1; }
        rt=${reason#*: }
        ns=$(printf '%s' "$rt" | tr -d '[:space:]' | wc -c); ns=${ns// /}
        ((ns >= 20)) || {
          printf 'POLICY row %s: reason carries only %s non-space chars — padding is not a reason\n' "$id" "$ns"; BAD=1; }
        [[ -n "$note" && "$note" != '-' ]] || { printf 'POLICY row %s: by-hand row needs a note saying why not mechanisable\n' "$id"; BAD=1; }
        ;;
      *) printf 'POLICY row %s: class %q is not runnable|by-hand\n' "$id" "$class"; BAD=1 ;;
    esac
    R_ID[$n]=$id; R_CLASS[$n]=$class; R_LEAD[$n]=$lead; R_CHECK[$n]=$check
    R_EXEXIT[$n]=$exexit; R_EXLAST[$n]=$exlast; R_REASON[$n]=$reason; R_NOTE[$n]=$note
  done <"$TSV"
  ROWS_N=$n
  ((BAD == 0)) || return 2
  return 0
}

floor_of() { printf '%s' "$(((($1 + FLOOR_DEN - 1)) / FLOOR_DEN))"; }

# -------------------------------------------------------------- verify ---
verify() {
  local items_n i k m d line lead hits j class last out rc want fl failed=0 dup_reasons dup_ids bh_reasons dl
  declare -a R_ID=() R_CLASS=() R_LEAD=() R_CHECK=() R_EXEXIT=() R_EXLAST=() R_REASON=() R_NOTE=()
  ROWS_N=0
  ITEM_DIR=$(mktemp -d)
  trap 'rm -rf "$ITEM_DIR"' RETURN

  [[ -r "$SKILL" ]] || { printf 'SETUP checklist source not readable: %s\n' "$SKILL"; return 2; }
  items_n=$(extract_items "$SKILL" "$ITEM_DIR")
  if [[ "$items_n" -eq 0 ]]; then
    printf 'SETUP no `## Credential-hygiene checklist` section with `- [ ] ` items in %s\n' "$SKILL"
    return 2
  fi

  load_rows || return 2

  # ids unique
  dup_ids=$(for ((i = 1; i <= ROWS_N; i++)); do printf '%s\n' "${R_ID[$i]}"; done | sort | uniq -d) || true
  if [[ -n "$dup_ids" ]]; then
    printf 'POLICY duplicate row id: %s\n' "$(tr '\n' ' ' <<<"$dup_ids")"
    return 2
  fi

  k=0 m=0
  for ((i = 1; i <= ROWS_N; i++)); do
    [[ "${R_CLASS[$i]}" == runnable ]] && k=$((k + 1)) || m=$((m + 1))
  done

  # declaration completeness: one row per item, one item per row
  ((ROWS_N < items_n)) && defect "UNDECLARED (items=$items_n rows=$ROWS_N)"
  ((ROWS_N > items_n)) && defect "EXTRA (items=$items_n rows=$ROWS_N)"

  # lead bijection
  for ((i = 1; i <= ROWS_N; i++)); do
    lead=${R_LEAD[$i]}
    hits=0
    for ((j = 1; j <= items_n; j++)); do
      line=$(tr '\n' ' ' <"$ITEM_DIR/$j" | tr -s ' ')
      if [[ " $line" =~ $lead ]]; then hits=$((hits + 1)); fi
    done
    ((hits == 0)) && defect "UNMATCHED-LEAD ${R_ID[$i]} (/$lead/ matches no item)"
    ((hits > 1)) && defect "DUPLICATE-LEAD ${R_ID[$i]} (/$lead/ matches $hits items)"
  done
  for ((j = 1; j <= items_n; j++)); do
    line=$(tr '\n' ' ' <"$ITEM_DIR/$j" | tr -s ' ')
    hits=0
    for ((i = 1; i <= ROWS_N; i++)); do
      [[ " $line" =~ ${R_LEAD[$i]} ]] && hits=$((hits + 1))
    done
    ((hits == 0)) && defect "UNMATCHED-ITEM $j (no row declares it)"
    ((hits > 1)) && defect "DUPLICATE-ITEM $j ($hits rows declare it)"
  done

  # by-hand reasons unique
  bh_reasons=$(for ((i = 1; i <= ROWS_N; i++)); do
    if [[ "${R_CLASS[$i]}" == by-hand ]]; then printf '%s\n' "${R_REASON[$i]}"; fi
  done) || true
  dup_reasons=$(printf '%s\n' "$bh_reasons" | grep -v '^$' | sort | uniq -d) || true
  if [[ -n "$dup_reasons" ]]; then
    defect "DUPLICATE-REASON ($(tr '\n' '|' <<<"$dup_reasons"))"
  fi

  local fl
  fl=$(floor_of "$items_n")
  dl=0
  for ((i = 1; i <= ROWS_N; i++)); do
    [[ "${R_CLASS[$i]}" == runnable ]] || continue
    [[ "${R_CHECK[$i]}" =~ ^bash[[:space:]]+corpus/ ]] && dl=$((dl + 1))
  done
  ((k * FLOOR_DEN >= items_n)) || defect "RATIO (runnable=$k floor=$fl items=$items_n)"

  # run the runnable rows (skipped by --ratio, which audits the declaration only)
  local failed=0
  if ((RATIO_ONLY)); then
    printf 'CHECKLIST_RATIO: runnable=%s/%s floor=%s by_hand=%s delegated=%s direct=%s\n' \
      "$k" "$items_n" "$fl" "$m" "$dl" "$((k - dl))"
    if ((BAD)); then return 1; fi
    return 0
  fi
  for ((i = 1; i <= ROWS_N; i++)); do
    [[ "${R_CLASS[$i]}" == runnable ]] || continue
    if [[ -n "$ONLY" && "$ONLY" != "${R_ID[$i]}" ]]; then continue; fi
    want=${R_EXEXIT[$i]}
    rc=0
    out=$(cd "$ROOT" && timeout "$ROW_TIMEOUT" bash -c "${R_CHECK[$i]}" 2>&1) || rc=$?
    last=$(printf '%s\n' "$out" | awk 'NF { l = $0 } END { print l }')
    if [[ "$want" == *'|'* ]]; then
      [[ "|$want|" == *"|$rc|"* ]] || {
        printf 'ITEM-FAIL %s (exit %s want %s)%s\n' "${R_ID[$i]}" "$rc" "$want" "$([[ $rc == 124 ]] && printf ' TIMEOUT' || true)"
        printf '%s\n' "$out" | tail -n 6 | sed 's/^/    | /'
        failed=$((failed + 1)); BAD=1; continue
      }
    elif [[ "$rc" != "$want" ]]; then
      printf 'ITEM-FAIL %s (exit %s want %s)%s\n' "${R_ID[$i]}" "$rc" "$want" "$([[ $rc == 124 ]] && printf ' TIMEOUT' || true)"
      printf '%s\n' "$out" | tail -n 6 | sed 's/^/    | /'
      failed=$((failed + 1)); BAD=1; continue
    fi
    if ! grep -qE -- "${R_EXLAST[$i]}" <<<"$last"; then
      printf 'ITEM-LASTLINE %s (want /%s/ got %q)\n' "${R_ID[$i]}" "${R_EXLAST[$i]}" "$last"
      printf '%s\n' "$out" | tail -n 6 | sed 's/^/    | /'
      failed=$((failed + 1)); BAD=1; continue
    fi
  done

  printf 'CHECKLIST_RATIO: runnable=%s/%s floor=%s by_hand=%s delegated=%s direct=%s\n' \
    "$k" "$items_n" "$fl" "$m" "$dl" "$((k - dl))"
  if ((BAD)); then
    if [[ -n "$ONLY" ]]; then
      printf 'CHECKLIST_ROW: BROKEN (id=%s failed=%s — this is a single row, not the checklist)\n' "$ONLY" "$failed"
    else
      printf 'CHECKLIST_RUN: BROKEN (items=%s runnable=%s by_hand=%s failed=%s)\n' "$items_n" "$k" "$m" "$failed"
    fi
    return 1
  fi
  if [[ -n "$ONLY" ]]; then
    printf 'CHECKLIST_ROW: CLEAN (id=%s — this is a single row, not the checklist)\n' "$ONLY"
  else
    printf 'CHECKLIST_RUN: CLEAN (items=%s runnable=%s by_hand=%s failed=0)\n' "$items_n" "$k" "$m"
  fi
  return 0
}

# ---------------------------------------------------------------- list ---
list_rows() {
  local i
  declare -a R_ID=() R_CLASS=() R_LEAD=() R_CHECK=() R_EXEXIT=() R_EXLAST=() R_REASON=() R_NOTE=()
  ROWS_N=0
  load_rows || return 2
  for ((i = 1; i <= ROWS_N; i++)); do
    if [[ "${R_CLASS[$i]}" == runnable ]]; then
      printf 'ROW %s runnable lead=/%s/ exit=%s last=/%s/ :: %s\n' \
        "${R_ID[$i]}" "${R_LEAD[$i]}" "${R_EXEXIT[$i]}" "${R_EXLAST[$i]}" "${R_CHECK[$i]}"
    else
      printf 'ROW %s by-hand  lead=/%s/ %s\n' "${R_ID[$i]}" "${R_LEAD[$i]}" "${R_REASON[$i]}"
    fi
  done
  local k=0 m=0
  for ((i = 1; i <= ROWS_N; i++)); do
    [[ "${R_CLASS[$i]}" == runnable ]] && k=$((k + 1)) || m=$((m + 1))
  done
  printf 'CHECKLIST_LIST: rows=%s runnable=%s by_hand=%s\n' "$ROWS_N" "$k" "$m"
}

only_row() {
  local i
  declare -a R_ID=() R_CLASS=() R_LEAD=() R_CHECK=() R_EXEXIT=() R_EXLAST=() R_REASON=() R_NOTE=()
  ROWS_N=0
  load_rows || return 2
  for ((i = 1; i <= ROWS_N; i++)); do
    [[ "${R_ID[$i]}" == "$ONLY" ]] || continue
    if [[ "${R_CLASS[$i]}" == by-hand ]]; then
      printf 'BY-HAND %s (%s)\n' "${R_ID[$i]}" "${R_REASON[$i]}"
      return 0
    fi
    verify
    return $?
  done
  printf 'SETUP --only %s: no such row id\n' "$ONLY"
  return 2
}

# ------------------------------------------------------------ selftest ---
selftest() {
  local d sk tv out rc fails=0 cases=0
  d=$(mktemp -d)
  trap 'rm -rf "$d"' RETURN
  sk="$d/SKILL.md"
  tv="$d/checklist.tsv"

  items6() { # a 6-item checklist section: alpha..zeta
    {
      printf '## Credential-hygiene checklist\n\nEvidence production:\n'
      local t
      for t in 'alpha item text' 'beta item text' 'gamma item text' \
        'delta item text' 'epsilon item text' 'zeta item text'; do
        printf -- '- [ ] %s\n' "$t"
      done
      printf '\n## Next section\n'
    } >"$sk"
  }
  row() { printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$@" >>"$tv"; }
  c1_default() { row C1 runnable alpha 'printf "A1: OK\n"' 0 '^A1: OK$' - 'alpha delegates to itself'; }
  rest_rows() { # rest_rows [C5-reason] [C6-reason] — C2..C6, 3 runnable + 2 by-hand
    row C2 runnable beta 'printf "A2: OK\n"' 0 '^A2: OK$' - 'beta delegates to itself'
    row C3 runnable gamma 'printf "A3: OK\n"; exit 1' '0|1' '^A3: OK$' - 'gamma prints then exits 1; A|B accepts it'
    row C4 runnable delta 'printf "A4: OK\n"' 0 '^A4: OK$' - 'delta delegates to itself'
    row C5 by-hand epsilon - - - "${1:-authoring-duty: epsilon is a writing decision with no command shape}" 'epsilon needs an author'
    row C6 by-hand zeta - - - "${2:-cross-lane: zeta is owned elsewhere and only reported, never adjudicated}" 'zeta is foreign scope'
  }
  # fixture <variant>: rebuild the item section and the row file from scratch, so
  # no case depends on a sed pattern surviving an earlier one.
  fixture() {
    items6
    rm -f "$tv"
    case "$1" in
      clean)      c1_default; rest_rows ;;
      slow)       row C1 runnable alpha 'sleep 5' 0 '^A1: OK$' - 'alpha sleeps past the row timeout'; rest_rows ;;
      exit-bad)   row C1 runnable alpha 'exit 3' 0 '^A1: OK$' - 'alpha exits 3 where 0 is declared'; rest_rows ;;
      last-bad)   row C1 runnable alpha 'printf "A1: OK\n"' 0 '^A1: NOPE$' - 'alpha prints OK where NOPE is declared'; rest_rows ;;
      reason-bad) row C1 runnable alpha 'printf "A1: OK\n"' 0 '^A1: OK$' 'authoring-duty: a reason on a runnable row is a shape error' 'alpha carries a reason'; rest_rows ;;
      dup-lead)   row C1 runnable delta 'printf "A1: OK\n"' 0 '^A1: OK$' - 'alpha row declares the delta item'; rest_rows ;;
      broad-lead) row C1 runnable 'item text' 'printf "A1: OK\n"' 0 '^A1: OK$' - 'alpha row declares every item'; rest_rows ;;
      denied)     row C1 runnable alpha 'cat op.env' 0 '^A1: OK$' - 'alpha reads a denied surface'; rest_rows ;;
      denied-ledger) row C1 runnable alpha 'bash corpus/claim-ledger.sh verify' 0 '^A1: OK$' - 'alpha re-invokes the ledger gate'; rest_rows ;;
      denied-run) row C1 runnable alpha 'the-janitor run -- printenv' 0 '^A1: OK$' - 'alpha execs the handler run verb'; rest_rows ;;
      empty-output) row C1 runnable alpha 'true' 0 '^A1: OK$' - 'alpha prints nothing at all'; rest_rows ;;
      pad-reason) c1_default; rest_rows "authoring-duty: $(printf '%*s' 40 '')" ;;
      tri-exit)   row C1 runnable alpha 'printf "A1: OK\n"; exit 4' '3|4|5' '^A1: OK$' - 'alpha declares a three-way exit set'; rest_rows ;;
      class-bad)  c1_default; rest_rows; row X1 manual alpha_twin 'true' 0 '^X$' - 'class outside the set' ;;
      short)      c1_default; rest_rows; printf 'X1\trunnable\talpha\n' >>"$tv" ;;
      dup-id)     c1_default; rest_rows; row C5 runnable epsilon 'printf "A5: OK\n"' 0 '^A5: OK$' - 'a second row with id C5' ;;
      short-reason) c1_default; rest_rows 'authoring-duty: too short' ;;
      dup-reason) c1_default; rest_rows 'authoring-duty: epsilon is a writing decision with no command shape' \
        'authoring-duty: epsilon is a writing decision with no command shape' ;;
      bh-check)   c1_default; rest_rows
                  row C5 by-hand epsilon 'true' - - 'authoring-duty: epsilon is a writing decision with no command shape' 'epsilon needs an author' ;;
      floor-breach)
        c1_default
        row C2 runnable beta 'printf "A2: OK\n"' 0 '^A2: OK$' - 'beta delegates to itself'
        row C3 by-hand gamma - - - 'authoring-duty: gamma is also a writing decision with no command shape' 'gamma needs an author'
        row C4 by-hand delta - - - 'runtime-behavior: delta needs a live handler cycle and is operator scope' 'delta needs the handler'
        row C5 by-hand epsilon - - - 'authoring-duty: epsilon is a writing decision with no command shape' 'epsilon needs an author'
        row C6 by-hand zeta - - - 'cross-lane: zeta is owned elsewhere and only reported, never adjudicated' 'zeta is foreign scope' ;;
      extra)      c1_default; rest_rows; row X7 runnable nosuchitem 'printf "A7: OK\n"' 0 '^A7: OK$' - 'a row for an item that does not exist' ;;
      undeclared)
        c1_default
        row C2 runnable beta 'printf "A2: OK\n"' 0 '^A2: OK$' - 'beta delegates to itself'
        row C3 runnable gamma 'printf "A3: OK\n"; exit 1' '0|1' '^A3: OK$' - 'gamma prints then exits 1; A|B accepts it'
        row C4 runnable delta 'printf "A4: OK\n"' 0 '^A4: OK$' - 'delta delegates to itself'
        row C5 by-hand epsilon - - - 'authoring-duty: epsilon is a writing decision with no command shape' 'epsilon needs an author' ;;
      *) c1_default; rest_rows ;;
    esac
  }

  run() { # run <desc> <want_exit> <want_regex> [args...]
    local desc=$1 wex=$2 wre=$3
    shift 3
    cases=$((cases + 1))
    rc=0
    out=$(CHECKLIST_TIMEOUT="${CT:-240}" "$SELF" --tsv "$tv" --skill "$sk" "$@" 2>&1) || rc=$?
    if [[ "$rc" != "$wex" ]]; then
      printf 'checklist-selftest: FAIL %s: exit %s want %s\n' "$desc" "$rc" "$wex"
      fails=$((fails + 1))
    elif ! grep -qE -- "$wre" <<<"$out"; then
      printf 'checklist-selftest: FAIL %s: no /%s/ in output\n' "$desc" "$wre"
      fails=$((fails + 1))
    fi
  }

  fixture clean
  run "clean"                0 'CHECKLIST_RUN: CLEAN .items=6 runnable=4 by_hand=2 failed=0.'
  run "ratio line"           0 'CHECKLIST_RATIO: runnable=4/6 floor=3 by_hand=2 delegated=0 direct=4'
  run "list"                 0 'CHECKLIST_LIST: rows=6 runnable=4 by_hand=2' --list
  run "only runnable"        0 'CHECKLIST_ROW: CLEAN .id=C1' --only C1
  run "only by-hand"         0 'BY-HAND C5 .authoring-duty: epsilon' --only C5
  run "only unknown"         2 'SETUP --only NOPE' --only NOPE

  fixture exit-bad
  run "exit mismatch"        1 'ITEM-FAIL C1 .exit 3 want 0.'
  fixture last-bad
  run "lastline mismatch"    1 'ITEM-LASTLINE C1 .want /\^A1: NOPE\$/'
  fixture slow
  CT=1 run "row timeout"     1 'ITEM-FAIL C1 .*TIMEOUT'
  fixture class-bad
  run "unknown class"        2 'POLICY row X1: class manual is not runnable\|by-hand'
  fixture short
  run "short row"            2 'POLICY row X1: 3 columns, want 8'
  fixture dup-id
  run "duplicate id"         2 'POLICY duplicate row id: C5'
  fixture reason-bad
  run "runnable with reason" 2 'POLICY row C1: runnable row must carry reason'
  fixture bh-check
  run "by-hand with check"   2 'POLICY row C5: by-hand row must carry'
  fixture short-reason
  run "short reason"         2 'POLICY row C5: reason .* is not'
  fixture dup-reason
  run "duplicate reason"     1 'DUPLICATE-REASON .authoring-duty: epsilon'
  fixture floor-breach
  run "floor breach"         1 'RATIO .runnable=2 floor=3 items=6.'
  fixture extra
  run "extra row"            1 'EXTRA .items=6 rows=7.'
  fixture undeclared
  run "undeclared item"      1 'UNDECLARED .items=6 rows=5.'
  fixture dup-lead
  run "duplicate item"       1 'DUPLICATE-ITEM 4 .2 rows declare it.'
  fixture broad-lead
  run "duplicate lead"       1 'DUPLICATE-LEAD C1 '
  fixture denied
  run "denied surface"       2 'POLICY row C1: check touches a denied surface'
  fixture denied-ledger
  run "denied claim-ledger"  2 'POLICY row C1: check touches a denied surface'
  fixture denied-run
  run "denied handler run"   2 'POLICY row C1: check touches a denied surface'
  fixture empty-output
  run "empty row output"     1 'ITEM-LASTLINE C1 .*got '
  fixture tri-exit
  run "three-way exit"       0 'CHECKLIST_RUN: CLEAN .items=6 runnable=4 by_hand=2 failed=0.'
  fixture pad-reason
  run "padded reason"        2 'POLICY row C5: reason carries only'
  fixture clean
  run "ratio mode"           0 '^CHECKLIST_RATIO: runnable=4/6 floor=3 by_hand=2 delegated=0 direct=4$' --ratio
  fixture floor-breach
  run "ratio mode defect"    1 'RATIO .runnable=2 floor=3 items=6.' --ratio
  fixture clean
  run "ratio mode quiet"     0 'CHECKLIST_RATIO' --ratio
  # --ratio executes no row: this fixture's row would fail if it were run
  fixture slow
  run "ratio mode runs no row" 0 '^CHECKLIST_RATIO: runnable=4/6 floor=3 by_hand=2 delegated=0 direct=4$' --ratio

  run "missing tsv"          2 'SETUP checklist.tsv not readable' --tsv "$d/nope.tsv"
  printf '# no checklist here\n## Other\n' >"$d/other.md"
  run "missing section"      2 'SETUP no .## Credential-hygiene checklist. section' --skill "$d/other.md"

  fixture clean
  run "final clean"          0 'CHECKLIST_RUN: CLEAN .items=6 runnable=4 by_hand=2 failed=0.'

  if ((fails)); then
    printf 'CHECKLIST_SELFTEST: FAIL (%d/%d cases)\n' "$fails" "$cases"
    return 1
  fi
  printf 'CHECKLIST_SELFTEST: PASS (%d cases)\n' "$cases"
  return 0
}

case "$MODE" in
  verify)
    if [[ -n "$ONLY" ]]; then only_row; else verify; fi
    ;;
  list) list_rows ;;
  selftest) selftest ;;
esac