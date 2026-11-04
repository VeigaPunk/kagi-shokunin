#!/usr/bin/env bash
# scope-gate.sh — ownership partition gate for the surfaces this corpus touches.
#
# v0 (rounds 1–15): "cross-domain awareness — evidence belonging to another
# domain reported, not absorbed" lived in three prose places: the overlap table
# in `corpus/README.md`, two refusals in `PROVINCE.md`, and one `mode = -` census
# row. Nothing fired when a census row drifted into another lane's tree, when a
# shared surface lost its named owner, or when a basis citation decayed into a
# pointer at unrelated text (`corpus/README.md:76` cited
# `kake-shokunin/SKILL.md:104-107` for the musketeer lease; the claim is at
# `:161`, and `:104-107` is webzites/probe material).
#
# v1 partitions the census: every declared surface is either OWNED by this
# domain (an `# own` prefix) or SHARED (covered by a row in
# `corpus/adjacency.tsv` that names the lane that owns it, its status, the claim
# this domain makes on it, and a resolving citation for that lane's claim).
#
# v2 measures the four leaf directories deliberately excluded from full
# enumeration. Count-only breadth pins expose how much of each shared directory
# the census actually declares without committing private child-name manifests.
#
#   corpus/adjacency.tsv
#     # own <prefix> | # owner <lane> | # status <v> | # claim <v>
#     # no-enumerate <dir>
#     # breadth <dir> <TAB> children=<N> <TAB> declared=<M>
#     path <TAB> owner <TAB> status <TAB> claim <TAB> basis <TAB> token <TAB> note
#
# Rules
#   R1  schema + directive vocabulary                BAD-ROW
#   R2  partition: owned (prefix) or shared          (classification, not a
#       guard: its failure modes are R3 and R4)
#   R3  every shared census row is covered           FOREIGN
#   R4  every group row covers ≥1 census row         ORPHAN
#   R5  owner/status/claim inside the closed sets    UNKNOWN-OWNER | BAD-VALUE
#       (the literal sets below AND the directives)   OWNER-MISMATCH
#   R6  basis resolves + token matches its line(s)   NOT-A-FILE | STALE-BASIS
#       basis stays inside its root, token hygiene    BASIS-ESCAPE | BAD-ROW
#   R7  claim ↔ mode is biconditional                OVERCLAIM
#   R8  every `# scan` dir is inside an `# own`      FOREIGN-SCAN
#   R9  resolution containment, both directions      ESCAPE | INBOUND | UNVERIFIED
#   R10 `# no-enumerate` names a census row or an
#       ancestor, is not `$HOME`, and is not a scan    ENUM-CLASH
#   R11 an `# own` prefix must be a declared census
#       surface (dir prefixes must be `# scan` dirs)   OWN-UNLISTED
#   R12 breadth schema + exact leaf membership        BAD-ROW | BREADTH-*
#   R13 live child/declared counts equal their pins   BREADTH-*-DRIFT
# Verdicts  CLEAN | DEFECT on the summary line; one `SCOPE <token> …` line per
# defect above it. A missing/empty input file is a setup error (`die`, exit 2).
# Exit      0 clean · 1 any defect · 2 usage/setup error (a missing input prints
#           `ADJACENCY_SCOPE: SETUP (…)` before exiting — never a bare death)
#
# `unresolved` (ownership awaiting an integrator ruling) and `contested` are
# DECLARED classes: counted and printed in the summary, exit-neutral — the same
# call the census makes for `skipped=N`. A runtime row that is legitimately
# absent abstains from R9 (`ADJACENCY_ABSTAIN: rows=N`, exit-neutral); a path
# that exists but cannot be resolved is `UNVERIFIED` and fails closed.
#
# Secret hygiene: this gate prints paths, verdicts and counts. It never prints
# file content, an `op://` ref path, a vault item name, an account identifier or
# a transcript cell, and it never reads a private file's bytes — `basis` lines
# are matched with `sed -n` against the cited line only.
#
# Usage:
#   scope-gate.sh                          verify partition + breadth (default)
#   scope-gate.sh --map                    print the partition, then verify
#   scope-gate.sh --breadth                print each breadth measurement
#   scope-gate.sh --selftest               scratch-tree proof that every rule fires
#   scope-gate.sh --falsify                mutate shipped data in scratch
#   scope-gate.sh --data F --census F --root D --basis-root D --lane-root D
#                                          alternate inputs (selftest harness)
#   scope-gate.sh --help
# Env: REALPATH_BIN=<path>  realpath resolver (default `readlink -f`); the
#                           selftest proves the fail-closed path with a binary
#                           that cannot resolve
# There is deliberately no `--pin`: scope and breadth pins are reviewed data.
set -euo pipefail

# Bootstrap failures must not be readable as "drift found": exit 1 means a
# defect here, so a broken environment (no `dirname`, an unreadable script dir)
# prints SETUP and exits 2 (round-16 executor D4/F4 — the same class is present
# in corpus/surface-census.sh:75 and is reported, not silently shared).
if ! SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"; then
  printf 'scope-gate: SETUP (cannot resolve the script directory — is dirname on PATH?)\n' >&2
  exit 2
fi
SELF="$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")"
DATA="${ADJ_DATA:-$SCRIPT_DIR/adjacency.tsv}"
CENSUS="${ADJ_CENSUS:-$SCRIPT_DIR/surface-census.tsv}"
ROOT="${ADJ_HOME:-${HOME}}"
BASIS_ROOT="${ADJ_BASIS_ROOT:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
LANE_ROOT="${ADJ_LANE_ROOT:-$(cd -- "$SCRIPT_DIR/../.." && pwd)}"
REALPATH_BIN="${REALPATH_BIN:-readlink}"
MODE="verify"
FALSIFY_R=""
# The closed sets are literal here, and the `# owner|# status|# claim` directives
# must agree with them: a directive that *creates* its own vocabulary would let
# an edit widen the contract without a code review (mutation M19).
OWNERS_OK="integrator kagi kake kotoba"
STATUSES_OK="contested shared-read unresolved writer"
CLAIMS_OK="declared presence-only"

die() { printf 'scope-gate: %s\n' "$1" >&2; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    verify|--verify) MODE="verify"; shift ;;
    --map) MODE="map"; shift ;;
    --breadth) MODE="breadth"; shift ;;
    --selftest) MODE="selftest"; shift ;;
    --falsify) MODE="falsify"; shift ;;
    --data) [[ $# -ge 2 ]] || die "--data needs a file"; DATA="$2"; shift 2 ;;
    --census) [[ $# -ge 2 ]] || die "--census needs a file"; CENSUS="$2"; shift 2 ;;
    --root) [[ $# -ge 2 ]] || die "--root needs a dir"; ROOT="$2"; shift 2 ;;
    --basis-root) [[ $# -ge 2 ]] || die "--basis-root needs a dir"; BASIS_ROOT="$2"; shift 2 ;;
    --lane-root) [[ $# -ge 2 ]] || die "--lane-root needs a dir"; LANE_ROOT="$2"; shift 2 ;;
    -h|--help) sed -n '2,68p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

expand() { # $HOME is the only templated prefix (as in surface-census.sh)
  local p="$1"
  printf '%s' "${p/\$HOME/$ROOT}"
}

under() { # p under-or-equal prefix
  local p="$1" pre="$2"
  [[ -n "$pre" ]] || return 1
  [[ "$p" == "$pre" || "$p" == "$pre"/* ]]
}

resolve_real() { # realpath through REALPATH_BIN; empty output + rc!=0 on failure
  local p="$1" out
  out="$("$REALPATH_BIN" -f -- "$p" 2>/dev/null)" || return 1
  [[ -n "$out" ]] || return 1
  printf '%s' "$out"
}

resolve_anchor() { # an `# own` prefix: the final component is literal, the
  # parent is resolved — so a prefix that was itself displaced by a symlink no
  # longer contains its rows (the anchor-identity half of R9)
  local p="$1" d b
  d="$(dirname -- "$p")"; b="$(basename -- "$p")"
  local rd; rd="$(resolve_real "$d")" || return 1
  printf '%s/%s' "$rd" "$b"
}

is_dup() { # array-name value
  local -n _a="$1"; shift
  local v="$1" x
  for x in "${_a[@]:-}"; do [[ "$x" == "$v" ]] && return 0; done
  return 1
}

token_hits() { # file first-line last-line-or-empty ere  → 0 if any cited line matches
  local f="$1" a="$2" b="$3" ere="$4" line range
  [[ -f "$f" ]] || return 1
  if [[ -n "$b" ]]; then range="${a},${b}p"; else range="${a},\$p"; fi
  while IFS= read -r line; do
    if [[ "$line" =~ $ere ]]; then return 0; fi
  done < <(sed -n "$range" -- "$f")
  return 1
}

# --- the gate --------------------------------------------------------------

gate() {
  local -a own=() owners=() statuses=() claims=() noenum=() scans=()
  local -a c_path=() c_class=() c_kind=() c_mode=()
  local -a g_path=() g_owner=() g_status=() g_claim=() g_basis=() g_token=()
  local -a b_dir=() b_children=() b_declared=() breadth_required_dirs=()
  local -i census=0 owned=0 shared=0 groups=0 unresolved=0 contested=0
  local -i escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 abstained=0 asset_absent=0 unverified=0
  local -i basis_escape=0 own_unlisted=0 defects=0
  local -i breadth_pins=0 breadth_required=0 breadth_checked=0 breadth_ok=0
  local -i breadth_missing=0 breadth_invalid=0 breadth_drift=0 breadth_exceeds=0 breadth_unverified=0
  local -i breadth_children_total=0 breadth_declared_total=0
  local f1 f2 f3 f4 f5 f6 f7 nf line i j k pre cur best best_i rp rpre
  local bd live_children live_declared row_bad child list_file breadth_set breadth_verdict breadth_line
  local -a covered=() prefix_of=() group_of=()
  local basis_file basis_a basis_b basis_root basis_root_for_row rb rroot

  if [[ ! -f "$DATA" ]]; then
    printf 'ADJACENCY_SCOPE: SETUP (data file not found: %s)\n' "$DATA"; exit 2
  fi
  if [[ ! -f "$CENSUS" ]]; then
    printf 'ADJACENCY_SCOPE: SETUP (census file not found: %s)\n' "$CENSUS"; exit 2
  fi

  # ---- parse the partition data ------------------------------------------
  while IFS=$'\t' read -r f1 f2 f3 f4 f5 f6 f7 || [[ -n "${f1:-}" ]]; do
    [[ -z "${f1:-}" ]] && continue
    if [[ "$f1" == '#'* ]]; then
      # A directive is exact-arity tab-separated data; prose comments occupy
      # the first field only. Extra fields are never ignored.
      if [[ -z "${f2:-}" ]]; then continue; fi
      if [[ "$f1" != '# breadth' && -n "${f3:-}${f4:-}${f5:-}${f6:-}${f7:-}" ]]; then
        printf 'SCOPE BAD-ROW %s (directive wants exactly 2 fields)\n' "$f1"
        defects=$((defects+1)); continue
      fi
      case "$f1" in
        '# own')        if is_dup own "$f2"; then printf 'SCOPE BAD-ROW duplicate # own: %s\n' "$f2"; defects=$((defects+1)); else own+=("$f2"); fi ;;
        '# owner')      if is_dup owners "$f2"; then printf 'SCOPE BAD-ROW duplicate # owner: %s\n' "$f2"; defects=$((defects+1)); else owners+=("$f2"); fi ;;
        '# status')     if is_dup statuses "$f2"; then printf 'SCOPE BAD-ROW duplicate # status: %s\n' "$f2"; defects=$((defects+1)); else statuses+=("$f2"); fi ;;
        '# claim')      if is_dup claims "$f2"; then printf 'SCOPE BAD-ROW duplicate # claim: %s\n' "$f2"; defects=$((defects+1)); else claims+=("$f2"); fi ;;
        '# no-enumerate') if is_dup noenum "$f2"; then printf 'SCOPE BAD-ROW duplicate # no-enumerate: %s\n' "$f2"; defects=$((defects+1)); else noenum+=("$f2"); fi ;;
        '# breadth')
          if [[ ! "$f3" =~ ^children=(0|[1-9][0-9]*)$ || ! "$f4" =~ ^declared=(0|[1-9][0-9]*)$ || -n "${f5:-}${f6:-}${f7:-}" ]]; then
            printf 'SCOPE BAD-ROW %s (breadth wants dir, children=<N>, declared=<M>)\n' "${f2:-<missing>}"
            breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); continue
          fi
          local bch="${f3#children=}" bde="${f4#declared=}"
          if [[ ${#bch} -gt 10 || ${#bde} -gt 10 ]] || (( 10#$bch > 2147483647 || 10#$bde > 2147483647 )); then
            printf 'SCOPE BREADTH-INVALID %s count outside 0..2147483647\n' "$f2"
            breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); continue
          fi
          if is_dup b_dir "$f2"; then
            printf 'SCOPE BAD-ROW duplicate # breadth: %s\n' "$f2"
            breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); continue
          fi
          b_dir+=("$f2"); b_children+=("$((10#$bch))"); b_declared+=("$((10#$bde))") ;;
        *) printf 'SCOPE BAD-ROW unknown directive: %s\n' "$f1"; defects=$((defects+1)) ;;
      esac
      continue
    fi
    if [[ -z "${f7:-}" ]]; then
      printf 'SCOPE BAD-ROW %s (want 7 columns: path owner status claim basis token note)\n' "$f1"
      defects=$((defects+1)); continue
    fi
    if [[ "$f7" == *$'\t'* ]]; then
      printf 'SCOPE BAD-ROW %s (more than 7 columns — note may not contain a tab; a fused line lands here)\n' "$f1"
      defects=$((defects+1)); continue
    fi
    if is_dup g_path "$f1"; then printf 'SCOPE BAD-ROW duplicate group path: %s\n' "$f1"; defects=$((defects+1)); continue; fi
    g_path+=("$f1"); g_owner+=("$f2"); g_status+=("$f3"); g_claim+=("$f4"); g_basis+=("$f5"); g_token+=("$f6")
  done <"$DATA"

  # ---- parse the census ---------------------------------------------------
  while IFS=$'\t' read -r f1 f2 f3 f4 f5 || [[ -n "${f1:-}" ]]; do
    [[ -z "${f1:-}" ]] && continue
    if [[ "$f1" == '# scan' ]]; then
      if [[ -z "${f2:-}" || -n "${f3:-}${f4:-}${f5:-}" ]]; then
        printf 'SCOPE BAD-ROW census # scan wants exactly 2 fields\n'; defects=$((defects+1))
      elif is_dup scans "$f2"; then
        printf 'SCOPE BAD-ROW duplicate census # scan: %s\n' "$f2"; defects=$((defects+1))
      else
        scans+=("$f2")
      fi
      continue
    fi
    [[ "$f1" == '#'* ]] && continue
    if [[ -z "${f5:-}" ]]; then
      printf 'SCOPE BAD-ROW census row (want 5 columns path class kind mode note): %s\n' "$f1"; defects=$((defects+1)); continue
    fi
    if [[ "$f5" == *$'\t'* ]]; then
      printf 'SCOPE BAD-ROW census row %s (more than 5 columns)\n' "$f1"; defects=$((defects+1)); continue
    fi
    if is_dup c_path "$f1"; then
      printf 'SCOPE BAD-ROW duplicate census row: %s\n' "$f1"; defects=$((defects+1)); continue
    fi
    c_path+=("$f1"); c_class+=("$f2"); c_kind+=("$f3"); c_mode+=("$f4")
  done <"$CENSUS"

  census=${#c_path[@]}
  groups=${#g_path[@]}

  # ---- R5: closed sets ----------------------------------------------------
  for ((i = 0; i < groups; i++)); do
    if ! is_dup owners "${g_owner[$i]}" || [[ " $OWNERS_OK " != *" ${g_owner[$i]} "* ]]; then
      printf 'SCOPE UNKNOWN-OWNER %s owner=%s\n' "${g_path[$i]}" "${g_owner[$i]}"; defects=$((defects+1))
    fi
    if ! is_dup statuses "${g_status[$i]}" || [[ " $STATUSES_OK " != *" ${g_status[$i]} "* ]]; then
      printf 'SCOPE BAD-VALUE %s status=%s\n' "${g_path[$i]}" "${g_status[$i]}"; defects=$((defects+1))
    fi
    if ! is_dup claims "${g_claim[$i]}" || [[ " $CLAIMS_OK " != *" ${g_claim[$i]} "* ]]; then
      printf 'SCOPE BAD-VALUE %s claim=%s\n' "${g_path[$i]}" "${g_claim[$i]}"; defects=$((defects+1))
    fi
    # the citation for a lane-owned surface must be that lane's (M20: an
    # owner/basis mismatch lets a row borrow another lane's evidence)
    if [[ "${g_basis[$i]}" == lane:* && "${g_status[$i]}" != "unresolved" ]]; then
      local blane="${g_basis[$i]#lane:}"; blane="${blane%%/*}"
      if [[ "$blane" != "${g_owner[$i]}" ]]; then
        printf 'SCOPE OWNER-MISMATCH %s owner=%s but basis cites lane:%s\n' "${g_path[$i]}" "${g_owner[$i]}" "$blane"
        defects=$((defects+1))
      fi
    fi
  done

  # ---- R2/R3/R4: partition + coverage ------------------------------------
  for ((i = 0; i < groups; i++)); do covered+=("0"); done
  for ((i = 0; i < census; i++)); do prefix_of+=(""); group_of+=("-1"); done

  for ((i = 0; i < census; i++)); do
    pre=""
    for ((j = 0; j < ${#own[@]}; j++)); do
      if under "$(expand "${c_path[$i]}")" "$(expand "${own[$j]}")"; then pre="${own[$j]}"; break; fi
    done
    if [[ -n "$pre" ]]; then
      owned=$((owned+1)); prefix_of[$i]="$pre"
      continue
    fi
    shared=$((shared+1))
    best=""; best_i=-1
    for ((j = 0; j < groups; j++)); do
      if under "$(expand "${c_path[$i]}")" "$(expand "${g_path[$j]}")"; then
        cur="${g_path[$j]}"
        if [[ -z "$best" || ${#cur} -gt ${#best} ]]; then best="$cur"; best_i=$j; fi
      fi
    done
    if [[ "$best_i" -lt 0 ]]; then
      printf 'SCOPE FOREIGN %s (no covering group in %s)\n' "${c_path[$i]}" "$(basename -- "$DATA")"
      foreign=$((foreign+1)); defects=$((defects+1)); continue
    fi
    group_of[$i]="$best_i"; covered[$best_i]=$(( ${covered[$best_i]:-0} + 1 ))
  done

  for ((i = 0; i < groups; i++)); do
    if [[ "${covered[$i]:-0}" -eq 0 ]]; then
      printf 'SCOPE ORPHAN %s (covers no census row)\n' "${g_path[$i]}"
      orphans=$((orphans+1)); defects=$((defects+1))
    fi
  done

  # ---- R6: basis resolves, and the cited line(s) carry the group's token ---
  for ((i = 0; i < groups; i++)); do
    basis_file=""; basis_a=1; basis_b=""
    cur="${g_basis[$i]}"
    # a token is echoed verbatim in defect output, so it must be a short plain
    # ERE: no scheme literal, nothing ref-shaped, nothing long (sentinel S3)
    if [[ ! "${g_token[$i]}" =~ ^[^[:space:]]{1,60}$ || "${g_token[$i]}" == *"://"* ]]; then
      printf 'SCOPE BAD-ROW %s token must be a short plain ERE without a URL scheme: %s\n' "${g_path[$i]}" "${g_token[$i]}"
      defects=$((defects+1)); continue
    fi
    if [[ "$cur" == /* || "$cur" == *".."* ]]; then
      printf 'SCOPE BASIS-ESCAPE %s basis must be a root-relative path with no .. : %s\n' "${g_path[$i]}" "$cur"
      basis_escape=$((basis_escape+1)); defects=$((defects+1)); continue
    fi
    if [[ "$cur" == lane:* ]]; then
      local rest="${cur#lane:}"
      local lname="${rest%%/*}"
      local lpath="${rest#*/}"
      basis_root="$LANE_ROOT/${lname}-shokunin"
      basis_file="$basis_root/$lpath"
    else
      basis_root="$BASIS_ROOT"
      basis_file="$BASIS_ROOT/$cur"
    fi
    basis_root_for_row="$basis_root"
    if [[ "$basis_file" == *:* ]]; then
      local tail="${basis_file##*:}"
      if [[ "$tail" =~ ^[0-9]+(-[0-9]+)?$ ]]; then
        basis_file="${basis_file%:*}"
        basis_a="${tail%%-*}"
        basis_b="${tail##*-}"
      fi
    fi
    rb="$(resolve_real "$basis_file")" || rb="$basis_file"
    rroot="$(resolve_anchor "$basis_root_for_row")" || rroot="$basis_root_for_row"
    if ! under "$rb" "$rroot"; then
      printf 'SCOPE BASIS-ESCAPE %s basis=%s escapes its root (%s -> %s)\n' "${g_path[$i]}" "${g_basis[$i]}" "$basis_root_for_row" "$rroot"
      basis_escape=$((basis_escape+1)); defects=$((defects+1)); continue
    fi
    if [[ ! -f "$basis_file" ]]; then
      printf 'SCOPE NOT-A-FILE %s basis=%s (resolved %s)\n' "${g_path[$i]}" "${g_basis[$i]}" "$basis_file"
      stale_basis=$((stale_basis+1)); defects=$((defects+1)); continue
    fi
    if ! token_hits "$basis_file" "$basis_a" "$basis_b" "${g_token[$i]}"; then
      printf 'SCOPE STALE-BASIS %s basis=%s lines=%s-%s token=%s\n' \
        "${g_path[$i]}" "${g_basis[$i]}" "$basis_a" "$basis_b" "${g_token[$i]}"
      stale_basis=$((stale_basis+1)); defects=$((defects+1))
    fi
  done

  # ---- R7: claim ↔ mode is biconditional ---------------------------------
  for ((i = 0; i < groups; i++)); do
    local want="-"
    [[ "${g_claim[$i]}" == "declared" ]] && want="exact"
    for ((j = 0; j < census; j++)); do
      [[ "${group_of[$j]}" == "$i" ]] || continue
      local got="exact"; [[ "${c_mode[$j]}" == "-" ]] && got="-"
      if [[ "$got" != "$want" ]]; then
        printf 'SCOPE OVERCLAIM %s claim=%s but census mode=%s\n' \
          "${c_path[$j]}" "${g_claim[$i]}" "${c_mode[$j]}"
        defects=$((defects+1))
      fi
    done
  done

  # ---- R8: scan directives stay inside owned prefixes ---------------------
  while IFS=$'\t' read -r f1 f2 || [[ -n "${f1:-}" ]]; do
    [[ "${f1:-}" == '# scan' && -n "${f2:-}" ]] || continue
    pre=""
    for ((j = 0; j < ${#own[@]}; j++)); do
      if under "$(expand "$f2")" "$(expand "${own[$j]}")"; then pre="${own[$j]}"; break; fi
    done
    if [[ -z "$pre" ]]; then
      printf 'SCOPE FOREIGN-SCAN %s (not inside any # own prefix)\n' "$f2"
      defects=$((defects+1))
    fi
  done <"$CENSUS"

  # ---- R9: resolution containment, both directions ------------------------
  for ((i = 0; i < census; i++)); do
    cur="$(expand "${c_path[$i]}")"
    if [[ ! -e "$cur" && ! -L "$cur" ]]; then
      # a missing row is not this gate's claim: `asset` absence is the census's
      # GONE verdict and is named loudly (never silently abstained — planner
      # R9-edge), while a `runtime` row may legitimately be absent
      if [[ "${c_class[$i]}" == "asset" ]]; then asset_absent=$((asset_absent+1));
      else abstained=$((abstained+1)); fi
      continue
    fi
    if [[ -L "$cur" && ! -e "$cur" ]]; then
      printf 'SCOPE UNVERIFIED %s (symlink whose target does not exist)\n' "${c_path[$i]}"
      unverified=$((unverified+1)); defects=$((defects+1)); continue
    fi
    if ! rp="$(resolve_real "$cur")"; then
      printf 'SCOPE UNVERIFIED %s (realpath did not resolve)\n' "${c_path[$i]}"
      unverified=$((unverified+1)); defects=$((defects+1)); continue
    fi
    if [[ "${group_of[$i]}" -lt 0 ]]; then
      # owned: the resolved path must stay inside the owned set (any prefix) —
      # prefix containment, not anchor identity: a census-row anchor swapped for
      # another in-domain path is the census's LINK/kind claim, not this gate's
      local inside=0
      for ((j = 0; j < ${#own[@]}; j++)); do
        rpre="$(resolve_anchor "$(expand "${own[$j]}")")" || continue
        if under "$rp" "$rpre"; then inside=1; break; fi
      done
      if [[ "$inside" -eq 0 ]]; then
        printf 'SCOPE ESCAPE %s resolves to %s, outside every owned prefix\n' "${c_path[$i]}" "$rp"
        escapes=$((escapes+1)); defects=$((defects+1))
      fi
    else
      for ((j = 0; j < ${#own[@]}; j++)); do
        rpre="$(resolve_anchor "$(expand "${own[$j]}")")" || continue
        if under "$rp" "$rpre"; then
          printf 'SCOPE INBOUND %s resolves into owned prefix %s\n' "${c_path[$i]}" "${own[$j]}"
          inbound=$((inbound+1)); defects=$((defects+1)); break
        fi
      done
    fi
  done

  # ---- R11: an owned prefix must be a declared surface --------------------
  # Ownership without a declared surface is the creep class the sentinel proved:
  # `# own $HOME/.local/bin` claimed 105 foreign children with a byte-identical
  # CLEAN summary. An `# own` prefix must therefore be an exact census row, and
  # a directory prefix must be one of the `# scan` dirs — so the claim can only
  # be as wide as a surface this repo already declares and enumerates.
  for ((i = 0; i < ${#own[@]}; i++)); do
    cur="$(expand "${own[$i]}")"; local row_kind="" is_scan_dir=0
    for ((j = 0; j < census; j++)); do
      [[ "$(expand "${c_path[$j]}")" == "$cur" ]] && { row_kind="${c_class[$j]}/${c_kind[$j]}"; break; }
    done
    while IFS=$'\t' read -r f1 f2 || [[ -n "${f1:-}" ]]; do
      [[ "${f1:-}" == '# scan' && -n "${f2:-}" ]] || continue
      [[ "$(expand "$f2")" == "$cur" ]] && is_scan_dir=1
    done <"$CENSUS"
    if [[ -z "$row_kind" ]]; then
      printf 'SCOPE OWN-UNLISTED %s is an # own prefix with no census row\n' "${own[$i]}"
      own_unlisted=$((own_unlisted+1)); defects=$((defects+1))
    elif [[ "$row_kind" == "asset/dir" || "$row_kind" == "runtime/dir" ]] && [[ "$is_scan_dir" -eq 0 ]]; then
      printf 'SCOPE OWN-UNLISTED %s is an owned directory that is not a # scan dir\n' "${own[$i]}"
      own_unlisted=$((own_unlisted+1)); defects=$((defects+1))
    fi
  done

  # ---- R10: no-enumerate directives are meaningful ------------------------
  for ((i = 0; i < ${#noenum[@]}; i++)); do
    cur="$(expand "${noenum[$i]}")"; local is_scan=0 is_row=0 is_owned=0
    for ((j = 0; j < ${#scans[@]}; j++)); do
      [[ "$(expand "${scans[$j]}")" == "$cur" ]] && is_scan=1
    done
    for ((j = 0; j < census; j++)); do
      if under "$(expand "${c_path[$j]}")" "$cur"; then is_row=1; break; fi
    done
    # A directory declared "deliberately not scanned" must not also be claimed
    # outright: `# own` over it would cover every foreign child the census never
    # enumerates.
    for ((j = 0; j < ${#own[@]}; j++)); do
      if under "$cur" "$(expand "${own[$j]}")"; then is_owned=1; break; fi
    done
    if [[ "$cur" == "$ROOT" ]]; then
      printf 'SCOPE ENUM-CLASH %s is the whole HOME root\n' "${noenum[$i]}"
      defects=$((defects+1))
    elif [[ "$is_scan" -eq 1 ]]; then
      printf 'SCOPE ENUM-CLASH %s is a # scan directory\n' "${noenum[$i]}"
      defects=$((defects+1))
    elif [[ "$is_owned" -eq 1 ]]; then
      printf 'SCOPE ENUM-CLASH %s is inside an # own prefix\n' "${noenum[$i]}"
      defects=$((defects+1))
    elif [[ "$is_row" -eq 0 ]]; then
      printf 'SCOPE ENUM-CLASH %s names no census row and no ancestor\n' "${noenum[$i]}"
      defects=$((defects+1))
    fi
  done

  # ---- R12/R13: breadth of the deliberately unenumerated leaf dirs --------
  # Aggregate ancestors churn for unrelated reasons. Required membership is
  # derived, not self-declared: a # no-enumerate dir is a leaf when it has no
  # strict descendant # no-enumerate or # scan dir. Deleting all breadth pins
  # therefore fails closed, while .config/.local aggregate churn stays exempt.
  for ((i = 0; i < ${#noenum[@]}; i++)); do
    local leaf=1
    for ((j = 0; j < ${#noenum[@]}; j++)); do
      [[ "$i" == "$j" ]] && continue
      [[ "${noenum[$j]}" == "${noenum[$i]}"/* ]] && { leaf=0; break; }
    done
    if [[ "$leaf" -eq 1 ]]; then
      for ((j = 0; j < ${#scans[@]}; j++)); do
        [[ "${scans[$j]}" == "${noenum[$i]}"/* ]] && { leaf=0; break; }
      done
    fi
    [[ "$leaf" -eq 1 ]] && breadth_required_dirs+=("${noenum[$i]}")
  done
  breadth_required=${#breadth_required_dirs[@]}
  breadth_pins=${#b_dir[@]}

  for ((i = 0; i < breadth_required; i++)); do
    if ! is_dup b_dir "${breadth_required_dirs[$i]}"; then
      printf 'SCOPE BREADTH-MISSING %s has no # breadth pin\n' "${breadth_required_dirs[$i]}"
      breadth_missing=$((breadth_missing+1)); defects=$((defects+1))
    fi
  done

  for ((i = 0; i < breadth_pins; i++)); do
    bd="${b_dir[$i]}"; row_bad=0
    if ! is_dup noenum "$bd"; then
      printf 'SCOPE BREADTH-NOENUM %s is not a # no-enumerate dir\n' "$bd"
      breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); row_bad=1
    elif is_dup scans "$bd"; then
      printf 'SCOPE BREADTH-SCAN %s is already a # scan dir\n' "$bd"
      breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); row_bad=1
    elif ! is_dup breadth_required_dirs "$bd"; then
      printf 'SCOPE BREADTH-SCOPE %s is an aggregate ancestor, not a required leaf\n' "$bd"
      breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); row_bad=1
    fi
    if (( ${b_declared[$i]} > ${b_children[$i]} )); then
      printf 'SCOPE BREADTH-INVALID %s declared=%s exceeds children=%s\n' \
        "$bd" "${b_declared[$i]}" "${b_children[$i]}"
      breadth_invalid=$((breadth_invalid+1)); defects=$((defects+1)); row_bad=1
    fi
    [[ "$row_bad" -eq 1 ]] && continue

    cur="$(expand "$bd")"
    if [[ -L "$cur" ]]; then
      printf 'SCOPE BREADTH-UNVERIFIED %s root is a symlink\n' "$bd"
      breadth_unverified=$((breadth_unverified+1)); defects=$((defects+1)); continue
    elif [[ ! -e "$cur" ]]; then
      printf 'SCOPE BREADTH-HOST-MISSING %s\n' "$bd"
      breadth_unverified=$((breadth_unverified+1)); defects=$((defects+1)); continue
    elif [[ ! -d "$cur" ]]; then
      printf 'SCOPE BREADTH-NOT-DIR %s\n' "$bd"
      breadth_unverified=$((breadth_unverified+1)); defects=$((defects+1)); continue
    fi
    rb="$(resolve_real "$cur")" || rb=""
    rroot="$(resolve_real "$ROOT")" || rroot=""
    if [[ -z "$rb" || -z "$rroot" ]] || ! under "$rb" "$rroot"; then
      printf 'SCOPE BREADTH-UNVERIFIED %s cannot be resolved inside HOME\n' "$bd"
      breadth_unverified=$((breadth_unverified+1)); defects=$((defects+1)); continue
    fi

    if ! list_file="$(mktemp)"; then
      printf 'ADJACENCY_SCOPE: SETUP (cannot create breadth scratch file)\n'; exit 2
    fi
    chmod 600 "$list_file"
    if ! find -P "$cur" -mindepth 1 -maxdepth 1 -print0 >"$list_file" 2>/dev/null; then
      rm -f "$list_file"
      printf 'SCOPE BREADTH-UNVERIFIED %s directory enumeration failed\n' "$bd"
      breadth_unverified=$((breadth_unverified+1)); defects=$((defects+1)); continue
    fi
    live_children=0; live_declared=0
    while IFS= read -r -d '' child; do
      live_children=$((live_children+1))
      for ((j = 0; j < census; j++)); do
        cur="$(expand "${c_path[$j]}")"
        if [[ "$cur" == "$child" || "$cur" == "$child"/* ]]; then
          live_declared=$((live_declared+1)); break
        fi
      done
    done <"$list_file"
    rm -f "$list_file"
    breadth_checked=$((breadth_checked+1))
    breadth_children_total=$((breadth_children_total+live_children))
    breadth_declared_total=$((breadth_declared_total+live_declared))
    row_bad=0
    if [[ "$live_children" != "${b_children[$i]}" ]]; then
      printf 'SCOPE BREADTH-CHILDREN-DRIFT %s pinned=%s live=%s\n' \
        "$bd" "${b_children[$i]}" "$live_children"
      breadth_drift=$((breadth_drift+1)); defects=$((defects+1)); row_bad=1
    fi
    if (( live_declared > ${b_declared[$i]} )); then
      printf 'SCOPE BREADTH-EXCEEDS %s pinned=%s live=%s\n' \
        "$bd" "${b_declared[$i]}" "$live_declared"
      breadth_exceeds=$((breadth_exceeds+1)); defects=$((defects+1)); row_bad=1
    elif (( live_declared < ${b_declared[$i]} )); then
      printf 'SCOPE BREADTH-DECLARED-DRIFT %s pinned=%s live=%s\n' \
        "$bd" "${b_declared[$i]}" "$live_declared"
      breadth_drift=$((breadth_drift+1)); defects=$((defects+1)); row_bad=1
    fi
    [[ "$row_bad" -eq 0 ]] && breadth_ok=$((breadth_ok+1))
    if [[ "$MODE" == "breadth" ]]; then
      printf 'ADJACENCY_BREADTH: dir=%s children=%s declared=%s undeclared=%s\n' \
        "$bd" "$live_children" "$live_declared" "$((live_children-live_declared))"
    fi
  done

  breadth_set="$(printf '%s\n' "${breadth_required_dirs[@]}" | LC_ALL=C sort | paste -sd, -)"
  breadth_verdict="CLEAN"
  if (( breadth_missing + breadth_invalid + breadth_drift + breadth_exceeds + breadth_unverified > 0 )); then
    breadth_verdict="DEFECT"
  fi
  printf -v breadth_line \
    'BREADTH_AUDIT: %s (required=%s pins=%s checked=%s ok=%s children=%s declared=%s undeclared=%s missing=%s invalid=%s drift=%s exceeds=%s unverified=%s)' \
    "$breadth_verdict" "$breadth_required" "$breadth_pins" "$breadth_checked" "$breadth_ok" \
    "$breadth_children_total" "$breadth_declared_total" "$((breadth_children_total-breadth_declared_total))" \
    "$breadth_missing" "$breadth_invalid" "$breadth_drift" "$breadth_exceeds" "$breadth_unverified"
  [[ "$MODE" != "breadth" ]] && printf '%s\n' "$breadth_line"

  # ---- map view -----------------------------------------------------------
  if [[ "$MODE" == "map" ]]; then
    for ((i = 0; i < census; i++)); do
      if [[ "${group_of[$i]}" -lt 0 ]]; then
        printf 'SCOPE_MAP: %s\towned\t%s\n' "${c_path[$i]}" "${prefix_of[$i]}"
      else
        printf 'SCOPE_MAP: %s\tshared\t%s\t%s\n' "${c_path[$i]}" \
          "${g_path[${group_of[$i]}]}" "${g_owner[${group_of[$i]}]}"
      fi
    done
  fi

  for ((i = 0; i < groups; i++)); do
    [[ "${g_status[$i]}" == "unresolved" ]] && unresolved=$((unresolved+1))
    [[ "${g_status[$i]}" == "contested" ]] && contested=$((contested+1))
  done

  [[ "$abstained" -gt 0 ]] && printf 'ADJACENCY_ABSTAIN: rows=%s\n' "$abstained"
  [[ "$asset_absent" -gt 0 ]] && printf 'ADJACENCY_ASSET_ABSENT: rows=%s (asset rows: surface-census.sh owns the GONE verdict)\n' "$asset_absent"

  local -a fields=(
    "census=$census" "owned=$owned" "shared=$shared" "groups=$groups"
    "owners=${#owners[@]}" "unresolved=$unresolved" "contested=$contested"
    "escapes=$escapes" "inbound=$inbound" "foreign=$foreign"
    "orphans=$orphans" "stale_basis=$stale_basis" "basis_escape=$basis_escape" "own_unlisted=$own_unlisted"
    "breadth_required=$breadth_required" "breadth_pins=$breadth_pins"
    "breadth_checked=$breadth_checked" "breadth_ok=$breadth_ok"
    "breadth_missing=$breadth_missing" "breadth_invalid=$breadth_invalid"
    "breadth_drift=$breadth_drift" "breadth_exceeds=$breadth_exceeds"
    "breadth_unverified=$breadth_unverified"
  )
  local joined="" f; local -i scope_rc=0
  for f in "${fields[@]}"; do
    if [[ -z "$joined" ]]; then joined="$f"; else joined="$joined $f"; fi
  done
  if [[ "$defects" -eq 0 ]]; then
    printf 'ADJACENCY_SCOPE: CLEAN (%s)\n' "$joined"
  else
    printf 'ADJACENCY_SCOPE: DEFECT (%s)\n' "$joined"
    scope_rc=1
  fi
  if [[ "$MODE" == "breadth" ]]; then
    printf 'ADJACENCY_BREADTH_SET: dirs=%s\n' "$breadth_set"
    printf '%s\n' "$breadth_line"
  fi
  return "$scope_rc"
}

# --- falsify ---------------------------------------------------------------
# Mutation set runs against the SHIPPED data + census. Every fixture is a
# mktemp copy; no host bytes or repo files are changed.

falsify() {
  FALSIFY_R="$(mktemp -d)"
  trap 'rm -rf "${FALSIFY_R:-}"' EXIT
  local R="$FALSIFY_R"
  local -i caught=0; local -i failed=0; local -i total=18
  local out rc name

  mutate_case() { # name data census want_exit token
    local n="$1" d="$2" c="$3" we="$4" tok="$5"
    set +e
    out="$("$SELF" --data "$d" --census "$c" --root "$ROOT" --basis-root "$BASIS_ROOT" \
      --lane-root "$LANE_ROOT" 2>&1)"; rc=$?
    set -e
    if [[ "$rc" == "$we" && "$out" == *"$tok"* ]]; then
      caught=$((caught+1)); printf 'FALSIFY OK   %s (exit %s, %s)\n' "$n" "$rc" "$tok"
    else
      failed=$((failed+1))
      printf 'FALSIFY FAIL %s (exit %s want %s, token %s)\n' "$n" "$rc" "$we" "$tok"
      printf '%s\n' "$out" | sed 's/^/    /'
    fi
  }

  append_row() { # file text — normalize the missing trailing newline first
    local f="$1" t="$2"
    if [[ -n "$(tail -c 1 -- "$f")" ]]; then printf '\n' >>"$f"; fi
    printf '%b\n' "$t" >>"$f"
  }

  # 1. the documented defect this gate exists for: a basis citation that
  #    resolves but points at unrelated text (`corpus/README.md:76` cited
  #    kake SKILL.md:104-107 for the musketeer lease; :104-107 is webzites)
  sed 's|lane:kake/SKILL.md:161|lane:kake/SKILL.md:104-107|' "$DATA" >"$R/stale-basis.tsv"
  mutate_case stale-basis "$R/stale-basis.tsv" "$CENSUS" 1 'SCOPE STALE-BASIS'

  # 2. a census row in another lane's tree that no group covers
  cp -- "$CENSUS" "$R/foreign.tsv"
  append_row "$R/foreign.tsv" '$HOME/.local/share/other-lane/cfg.json\tasset\tfile\t644\tuncovered' 
  mutate_case foreign-row "$DATA" "$R/foreign.tsv" 1 'SCOPE FOREIGN'

  # 3. the contested profile drifted to a claim it may not make
  sed 's|\tkake\tcontested\tpresence-only\t|\tkake\tcontested\tdeclared\t|' "$DATA" >"$R/overclaim.tsv"
  mutate_case overclaim-presence-only "$R/overclaim.tsv" "$CENSUS" 1 'SCOPE OVERCLAIM'

  # 4. enumerating another lane's directory
  cp -- "$CENSUS" "$R/foreign-scan.tsv"
  append_row "$R/foreign-scan.tsv" '# scan\t$HOME/.config/opencode' 
  mutate_case foreign-scan "$DATA" "$R/foreign-scan.tsv" 1 'SCOPE FOREIGN-SCAN'

  # 5. prefix creep over a directory the data itself declares unscanned: with
  #    R10's own-vs-no-enumerate rule this is caught (reviewer D2 — before that
  #    rule `# own $HOME/.local/bin` was CLEAN while its 105 children are not
  #    enumerated by anything)
  sed 's|^# own\t\$HOME/.local/bin/the-janitor|# own\t$HOME/.local/bin|' "$DATA" >"$R/prefix-creep.tsv"
  mutate_case prefix-creep-over-no-enumerate "$R/prefix-creep.tsv" "$CENSUS" 1 'SCOPE ENUM-CLASH'

  # 5b. the same creep one level up: `# own $HOME/.local/state` would claim 13
  #     live children that are not this domain's (exec-data Q1: state has 15
  #     children of which 2 are ours) — caught because the data declares the
  #     ancestry `# no-enumerate`
  cp -- "$DATA" "$R/state-creep.tsv"
  append_row "$R/state-creep.tsv" '# own\t$HOME/.local/state'
  mutate_case prefix-creep-over-declared-ancestry "$R/state-creep.tsv" "$CENSUS" 1 'SCOPE ENUM-CLASH'

  # 6. an `# own` prefix over a tree no surface declares — the class the
  #    sentinel proved was silently CLEAN before R11 (`# own $HOME/.local/bin`
  #    claimed 105 foreign children with a byte-identical CLEAN summary). Now
  #    ownership requires a declared, enumerated surface, so this fires.
  cp -- "$DATA" "$R/ungated-tree.tsv"
  append_row "$R/ungated-tree.tsv" '# own\t$HOME/projects'
  mutate_case own-prefix-over-ungated-tree "$R/ungated-tree.tsv" "$CENSUS" 1 'SCOPE OWN-UNLISTED'
  sed 's|lane:kake/SKILL.md:161|lane:kake/k.md:1|' "$DATA" >"$R/basis-escape-resolved.tsv"

  # 7. the basis-traversal family: a citation that escapes its root turns the
  #    verdict into a boolean oracle over private bytes (sentinel S1 — `../` at
  #    enough depth reaches $CONFIG_DIR/op.env from the repo root)
  sed 's|lane:kake/SKILL.md:161|lane:kake/../../priv/secret.env:1|' "$DATA" >"$R/basis-escape.tsv"
  mutate_case basis-traversal "$R/basis-escape.tsv" "$CENSUS" 1 'SCOPE BASIS-ESCAPE'

  # 7b. containment on the RESOLVED path: a clean-looking `lane:` citation whose
  #     lane root resolves outside the lane tree (symlinked checkout)
  mkdir -p "$R/outside-lane"; printf 'musketeer\n' >"$R/outside-lane/k.md"
  rm -rf "$R/lanes2"; mkdir -p "$R/lanes2"
  ln -s "$R/outside-lane" "$R/lanes2/kake-shokunin"
  ln -s "$LANE_ROOT/kotoba-shokunin" "$R/lanes2/kotoba-shokunin"
  set +e
  out="$("$SELF" --data "$R/basis-escape-resolved.tsv" --census "$CENSUS" --root "$ROOT" \
    --basis-root "$BASIS_ROOT" --lane-root "$R/lanes2" 2>&1)"; rc=$?
  set -e

  if [[ "$rc" == 1 && "$out" == *'SCOPE BASIS-ESCAPE'* ]]; then
    caught=$((caught+1)); printf 'FALSIFY OK   basis-escape-on-resolved-lane-root (exit 1, SCOPE BASIS-ESCAPE)\n'
  else
    failed=$((failed+1)); printf 'FALSIFY FAIL basis-escape-on-resolved-lane-root (exit %s)\n%s\n' "$rc" "$out"
  fi

  # 10–18. Breadth mutations: membership, both count directions, schema,
  # aggregate-scope refusal, and a newly declared direct child.
  sed '/^# breadth\t\$HOME\/.agents\t/d' "$DATA" >"$R/breadth-missing.tsv"
  mutate_case breadth-missing "$R/breadth-missing.tsv" "$CENSUS" 1 'SCOPE BREADTH-MISSING'

  sed 's|# breadth\t$HOME/.local/bin\tchildren=105\tdeclared=2|# breadth\t$HOME/.local/bin\tchildren=104\tdeclared=2|' \
    "$DATA" >"$R/breadth-children.tsv"
  mutate_case breadth-children-drift "$R/breadth-children.tsv" "$CENSUS" 1 'SCOPE BREADTH-CHILDREN-DRIFT'

  sed 's|# breadth\t$HOME/.config/opencode\tchildren=20\tdeclared=4|# breadth\t$HOME/.config/opencode\tchildren=20\tdeclared=3|' \
    "$DATA" >"$R/breadth-exceeds.tsv"
  mutate_case breadth-exceeds "$R/breadth-exceeds.tsv" "$CENSUS" 1 'SCOPE BREADTH-EXCEEDS'

  sed 's|# breadth\t$HOME/.config/opencode\tchildren=20\tdeclared=4|# breadth\t$HOME/.config/opencode\tchildren=20\tdeclared=5|' \
    "$DATA" >"$R/breadth-declared.tsv"
  mutate_case breadth-declared-drift "$R/breadth-declared.tsv" "$CENSUS" 1 'SCOPE BREADTH-DECLARED-DRIFT'

  cp -- "$DATA" "$R/breadth-aggregate.tsv"
  append_row "$R/breadth-aggregate.tsv" '# breadth\t$HOME/.config\tchildren=94\tdeclared=2'
  mutate_case breadth-aggregate "$R/breadth-aggregate.tsv" "$CENSUS" 1 'SCOPE BREADTH-SCOPE'

  cp -- "$DATA" "$R/breadth-noenum.tsv"
  append_row "$R/breadth-noenum.tsv" '# breadth\t$HOME/other\tchildren=0\tdeclared=0'
  mutate_case breadth-noenum "$R/breadth-noenum.tsv" "$CENSUS" 1 'SCOPE BREADTH-NOENUM'

  sed '0,/^# breadth\t/{s/$/\textra/}' "$DATA" >"$R/breadth-extra.tsv"
  mutate_case breadth-extra-field "$R/breadth-extra.tsv" "$CENSUS" 1 'SCOPE BAD-ROW'

  cp -- "$DATA" "$R/noenum-home.tsv"
  append_row "$R/noenum-home.tsv" '# no-enumerate\t$HOME'
  mutate_case noenum-whole-home "$R/noenum-home.tsv" "$CENSUS" 1 'is the whole HOME root'

  cp -- "$CENSUS" "$R/breadth-exceeds-census.tsv"
  append_row "$R/breadth-exceeds-census.tsv" '$HOME/.config/opencode/command/breadth-probe.md\tasset\tfile\t644\tdeclared child mutation'
  mutate_case breadth-new-declared-child "$DATA" "$R/breadth-exceeds-census.tsv" 1 'SCOPE BREADTH-EXCEEDS'

  if [[ "$caught" == "$total" && "$failed" == 0 ]]; then
    printf 'SCOPE_FALSIFY: PASS (caught=%s/%s failed=0)\n' "$caught" "$total"
    return 0
  fi
  printf 'SCOPE_FALSIFY: FAIL (caught=%s/%s failed=%s)\n' "$caught" "$total" "$failed"
  return 1
}

# --- selftest --------------------------------------------------------------

selftest() {
  local -i cases=0 failures=0
  local R; R="$(mktemp -d)"
  trap 'rm -rf "$R"' EXIT

  build_tree() { # rebuilt from scratch for every case (never sed-mutated)
    rm -rf "$R/host"
    mkdir -p "$R/host/.config/the-janitor" "$R/host/.config/opencode" \
      "$R/host/.agents" "$R/host/.local/bin" \
      "$R/host/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts"
    chmod 700 "$R/host/.config/the-janitor"
    printf 'x\n' >"$R/host/.config/the-janitor/op.env"; chmod 600 "$R/host/.config/the-janitor/op.env"
    printf 'x\n' >"$R/host/.local/bin/the-janitor"; chmod 755 "$R/host/.local/bin/the-janitor"
    printf 'x\n' >"$R/host/.config/opencode/opencode.json"; chmod 644 "$R/host/.config/opencode/opencode.json"
    printf 'x\n' >"$R/host/.agents/AGENTS.md"; chmod 600 "$R/host/.agents/AGENTS.md"
    chmod 700 "$R/host/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts"
    printf 'x\n' >"$R/host/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json"
    chmod 600 "$R/host/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json"
  }

  build_census() {
    cat >"$R/census.tsv" <<'EOF'
# scan	$HOME/.config/the-janitor
$HOME/.config/the-janitor	asset	dir	700	cfg
$HOME/.config/the-janitor/op.env	asset	file	600	env refs
$HOME/.local/bin/the-janitor	asset	exec	755	CLI
$HOME/.config/opencode/opencode.json	asset	file	644	shared
$HOME/.agents/AGENTS.md	asset	file	600	shared
$HOME/.local/share/the-musketeer/chrome-profile	asset	dir	-	shared profile
$HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts	asset	dir	700	shared nmh
EOF
  }
  build_data() {
    cat >"$R/adjacency.tsv" <<'EOF'
# own	$HOME/.config/the-janitor
# own	$HOME/.local/bin/the-janitor
# owner	integrator
# owner	kake
# owner	kotoba
# status	contested
# status	shared-read
# status	unresolved
# status	writer
# claim	declared
# claim	presence-only
# no-enumerate	$HOME/.config/opencode
# no-enumerate	$HOME/.agents
# no-enumerate	$HOME/.local/share/the-musketeer/chrome-profile
# breadth	$HOME/.config/opencode	children=1	declared=1
# breadth	$HOME/.agents	children=1	declared=1
# breadth	$HOME/.local/share/the-musketeer/chrome-profile	children=1	declared=1
$HOME/.config/opencode	integrator	unresolved	declared	basis.md:3	beta	shared config
$HOME/.agents/AGENTS.md	kotoba	shared-read	declared	basis.md	beta	shared rule file
$HOME/.local/share/the-musketeer/chrome-profile	kake	contested	presence-only	basis.md	beta	contested profile
$HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts	kake	writer	declared	basis.md	beta	NMH subtree
EOF
  }
  build_basis() { printf 'alpha\nsecond\nbeta claim\nfourth\n' >"$R/basis.md"; }
  build_all() { rm -rf "$R/host"; build_tree; build_census; build_data; build_basis; }
  run_gate() {
    set +e
    out="$("$SELF" --data "$R/adjacency.tsv" --census "$R/census.tsv" --root "$R/host" \
      --basis-root "$R" --lane-root "$R/lanes")"
    rc=$?
    set -e
  }
  run_case() {
    local name="$1" want_exit="$2" token="$3" out rc
    run_gate
    cases=$((cases + 1))
    if [[ "$rc" != "$want_exit" ]] || { [[ -n "$token" ]] && [[ "$out" != *"$token"* ]]; }; then
      failures=$((failures + 1))
      printf 'SELFTEST FAIL %s (exit=%s want=%s token=%s)\n' "$name" "$rc" "$want_exit" "$token"
      printf '%s\n' "$out" | sed 's/^/    /'
    fi
  }

  build_all
  run_case clean 0 'ADJACENCY_SCOPE: CLEAN'
  run_case clean-counts 0 'census=7 owned=3 shared=4 groups=4'
  run_case clean-unresolved 0 'unresolved=1 contested=1'
  run_case clean-breadth 0 'BREADTH_AUDIT: CLEAN (required=3 pins=3 checked=3 ok=3 children=3 declared=3 undeclared=0'

  build_all
  set +e
  out="$("$SELF" --breadth --data "$R/adjacency.tsv" --census "$R/census.tsv" --root "$R/host" \
    --basis-root "$R" --lane-root "$R/lanes")"; rc=$?
  set -e
  cases=$((cases+1))
  if [[ "$rc" != 0 || "$out" != *'ADJACENCY_BREADTH_SET: dirs=$HOME/.agents,$HOME/.config/opencode,$HOME/.local/share/the-musketeer/chrome-profile'* || "$out" != *'BREADTH_AUDIT: CLEAN'* ]]; then
    failures=$((failures+1)); printf 'SELFTEST FAIL breadth-mode\n%s\n' "$out"
  fi

  build_all; sed -i '/^# breadth/d' "$R/adjacency.tsv"
  run_case breadth-missing 1 'SCOPE BREADTH-MISSING'

  build_all; sed -i $'s/children=1\\tdeclared=1/declared=1\\tchildren=1/' "$R/adjacency.tsv"
  run_case breadth-fixed-order 1 'SCOPE BAD-ROW'

  build_all; printf '# breadth\t$HOME/.agents\tchildren=1\tdeclared=1\n' >>"$R/adjacency.tsv"
  run_case breadth-duplicate 1 'SCOPE BAD-ROW duplicate # breadth'

  build_all
  printf '# no-enumerate\t$HOME/.config\n# breadth\t$HOME/.config\tchildren=2\tdeclared=2\n' >>"$R/adjacency.tsv"
  run_case breadth-aggregate-refused 1 'SCOPE BREADTH-SCOPE'

  build_all; printf '# breadth\t$HOME/other\tchildren=0\tdeclared=0\n' >>"$R/adjacency.tsv"
  run_case breadth-noenum 1 'SCOPE BREADTH-NOENUM'

  build_all
  printf '# no-enumerate\t$HOME/.config/the-janitor\n# breadth\t$HOME/.config/the-janitor\tchildren=1\tdeclared=1\n' >>"$R/adjacency.tsv"
  run_case breadth-scan-refused 1 'SCOPE BREADTH-SCAN'

  build_all; sed -i 's|# breadth\t$HOME/.agents\tchildren=1\tdeclared=1|# breadth\t$HOME/.agents\tchildren=0\tdeclared=1|' "$R/adjacency.tsv"
  run_case breadth-invalid-arithmetic 1 'SCOPE BREADTH-INVALID'

  build_all; sed -i 's|# breadth\t$HOME/.agents\tchildren=1\tdeclared=1|# breadth\t$HOME/.agents\tchildren=2\tdeclared=1|' "$R/adjacency.tsv"
  run_case breadth-children-drift 1 'SCOPE BREADTH-CHILDREN-DRIFT'

  build_all; sed -i 's|# breadth\t$HOME/.agents\tchildren=1\tdeclared=1|# breadth\t$HOME/.agents\tchildren=1\tdeclared=0|' "$R/adjacency.tsv"
  run_case breadth-exceeds 1 'SCOPE BREADTH-EXCEEDS'

  build_all; printf 'x\n' >"$R/host/.agents/extra"
  sed -i 's|# breadth\t$HOME/.agents\tchildren=1\tdeclared=1|# breadth\t$HOME/.agents\tchildren=2\tdeclared=2|' "$R/adjacency.tsv"
  run_case breadth-declared-drift 1 'SCOPE BREADTH-DECLARED-DRIFT'

  build_all; rm -rf "$R/host/.agents"
  run_case breadth-host-missing 1 'SCOPE BREADTH-HOST-MISSING'

  build_all; rm -rf "$R/host/.agents"; ln -s "$R/host/.config/opencode" "$R/host/.agents"
  run_case breadth-root-symlink 1 'SCOPE BREADTH-UNVERIFIED'

  build_all; rm -rf "$R/host/.agents"; printf 'x\n' >"$R/host/.agents"
  run_case breadth-not-dir 1 'SCOPE BREADTH-NOT-DIR'

  build_all
  printf 'x\n' >"$R/host/.agents/"$'line\nbreak'
  printf 'x\n' >"$R/host/.agents/"$'tab\tname'
  sed -i 's|# breadth\t$HOME/.agents\tchildren=1\tdeclared=1|# breadth\t$HOME/.agents\tchildren=3\tdeclared=1|' "$R/adjacency.tsv"
  run_case breadth-hostile-names 0 'BREADTH_AUDIT: CLEAN'

  build_all; printf '# no-enumerate\t$HOME/.agents\textra\n' >>"$R/adjacency.tsv"
  run_case directive-extra-field 1 'directive wants exactly 2 fields'

  build_all; printf '# no-enumerate\t$HOME\n' >>"$R/adjacency.tsv"
  run_case noenum-whole-home-refused 1 'is the whole HOME root'

  build_all; printf '$HOME/.local/share/other-lane/cfg.json\tasset\tfile\t644\tuncovered\n' >>"$R/census.tsv"
  run_case foreign 1 'SCOPE FOREIGN $HOME/.local/share/other-lane/cfg.json'

  build_all; printf '$HOME/.local/share/other-lane\tkake\tcontested\tdeclared\tbasis.md\tbeta\torphan\n' >>"$R/adjacency.tsv"
  run_case orphan 1 'SCOPE ORPHAN $HOME/.local/share/other-lane'

  build_all; sed -i 's/\tintegrator\tunresolved/\tboguslane\tunresolved/' "$R/adjacency.tsv"
  run_case unknown-owner 1 'SCOPE UNKNOWN-OWNER'

  build_all; sed -i 's/\tkotoba\tshared-read/\tkotoba\tbogus-status/' "$R/adjacency.tsv"
  run_case bad-status 1 'SCOPE BAD-VALUE'

  build_all; sed -i 's/\tdeclared\tbasis.md\tbeta\tNMH subtree/\tpresence-only\tbasis.md\tbeta\tNMH subtree/' "$R/adjacency.tsv"
  run_case overclaim-declared-mode 1 'SCOPE OVERCLAIM'

  build_all; sed -i 's/\tcontested\tpresence-only\tbasis\.md\tbeta\tcontested profile/\tcontested\tdeclared\tbasis.md\tbeta\tcontested profile/' "$R/adjacency.tsv"
  run_case overclaim-mode-dash 1 'SCOPE OVERCLAIM'

  build_all; sed -i 's|^# scan\t\$HOME/.config/the-janitor|# scan\t$HOME/.config/opencode|' "$R/census.tsv"
  run_case foreign-scan 1 'SCOPE FOREIGN-SCAN'

  build_all; printf 'x\n' >"$R/elsewhere.env"
  rm -f "$R/host/.config/the-janitor/op.env"
  ln -s "$R/elsewhere.env" "$R/host/.config/the-janitor/op.env"
  run_case escape 1 'SCOPE ESCAPE'

  build_all; rm -f "$R/host/.agents/AGENTS.md"
  ln -s "$R/host/.config/the-janitor/op.env" "$R/host/.agents/AGENTS.md"
  run_case inbound 1 'SCOPE INBOUND'

  build_all; printf '$HOME/.agents/AGENTS.md\tkotoba\tshared-read\tdeclared\tbasis.md\tbeta\n' >>"$R/adjacency.tsv"
  run_case bad-row-six-fields 1 'SCOPE BAD-ROW'

  build_all; printf '# ownerz\tkake\n' >>"$R/adjacency.tsv"
  run_case bad-row-unknown-directive 1 'SCOPE BAD-ROW unknown directive'

  build_all; printf '# owner\tkake\n' >>"$R/adjacency.tsv"
  run_case bad-row-duplicate-directive 1 'SCOPE BAD-ROW duplicate # owner'

  build_all; printf '$HOME/.agents/AGENTS.md\tkotoba\tshared-read\tdeclared\tmissing.md\tbeta\tdup path\n' >>"$R/adjacency.tsv"
  run_case bad-row-duplicate-group 1 'SCOPE BAD-ROW duplicate group path'

  build_all; sed -i 's/basis\.md:3/nofile.md:3/' "$R/adjacency.tsv"
  run_case not-a-file 1 'SCOPE NOT-A-FILE'

  build_all; sed -i 's/basis\.md:3/basis.md:1/' "$R/adjacency.tsv"
  run_case stale-basis 1 'SCOPE STALE-BASIS'

  build_all; sed -i 's|^# no-enumerate\t\$HOME/.agents|# no-enumerate\t$HOME/elsewhere|' "$R/adjacency.tsv"
  run_case enum-clash-unrelated 1 'SCOPE ENUM-CLASH'

  build_all; sed -i 's|^# no-enumerate\t\$HOME/.config/opencode|# no-enumerate\t$HOME/.config/the-janitor|' "$R/adjacency.tsv"
  run_case enum-clash-scan-dir 1 'SCOPE ENUM-CLASH'

  build_all; printf '# no-enumerate\t$HOME/.local/bin/the-janitor\n' >>"$R/adjacency.tsv"
  run_case enum-clash-own-covered 1 'is inside an # own prefix'

  build_all; printf 'x\n' >"$R/outside.env"
  rm -f "$R/host/.local/bin/the-janitor"
  ln -s "$R/outside.env" "$R/host/.local/bin/the-janitor"
  run_case escape-exact-file 1 'SCOPE ESCAPE'

  build_all; printf '# owner\tnewlane\n' >>"$R/adjacency.tsv"
  sed -i $'s/\tintegrator\tunresolved/\tnewlane\tunresolved/' "$R/adjacency.tsv"
  run_case self-declared-owner-refused 1 'SCOPE UNKNOWN-OWNER'

  build_all; sed -i $'s/\tintegrator\tunresolved/\tboguslane\tunresolved/' "$R/adjacency.tsv"
  run_case undeclared-owner-refused 1 'SCOPE UNKNOWN-OWNER'

  build_all; printf '# status\tbogus-status\n' >>"$R/adjacency.tsv"
  sed -i $'s/\tkotoba\tshared-read/\tkotoba\tbogus-status/' "$R/adjacency.tsv"
  run_case bad-value-status 1 'SCOPE BAD-VALUE'

  build_all; mkdir -p "$R/lanes/kake-shokunin"; printf 'beta\n' >"$R/lanes/kake-shokunin/k.md"
  sed -i $'s|\\tkotoba\\tshared-read\\tdeclared\\tbasis.md|\\tkotoba\\tshared-read\\tdeclared\\tlane:kake/k.md:1|' "$R/adjacency.tsv"
  run_case owner-basis-mismatch 1 'SCOPE OWNER-MISMATCH'

  build_all; sed -i 's|	kake\tcontested\tpresence-only\tbasis\.md\tbeta\tcontested profile|\tkake\tcontested\tpresence-only\tbasis.md\tbeta\tcontested profile\textra|' "$R/adjacency.tsv"
  run_case row-overflow-column 1 'SCOPE BAD-ROW'

  build_all; printf '$HOME/.agents/AGENTS.md\tasset\tfile\t600\tduplicate census row\n' >>"$R/census.tsv"
  run_case duplicate-census-row 1 'SCOPE BAD-ROW duplicate census row'

  build_all; sed -i 's|basis\.md:3|\.\./outside.md:1|' "$R/adjacency.tsv"
  run_case basis-parent-escape 1 'SCOPE BASIS-ESCAPE'

  build_all; sed -i 's|basis\.md:3|/etc/hostname:1|' "$R/adjacency.tsv"
  run_case basis-absolute 1 'SCOPE BASIS-ESCAPE'

  build_all; sed -i 's|\tbeta\t|\tbad://token\t|' "$R/adjacency.tsv"
  run_case token-scheme-refused 1 'SCOPE BAD-ROW'

  build_all; printf '# own\t$HOME/.local/share/other-tree\n' >>"$R/adjacency.tsv"
  run_case own-prefix-unlisted 1 'SCOPE OWN-UNLISTED'

  build_all; printf '# own\t$HOME/.agents\n' >>"$R/adjacency.tsv"
  run_case own-dir-not-scan 1 'SCOPE OWN-UNLISTED'

  build_all; rm -f "$R/host/.config/opencode/opencode.json"
  run_case asset-absent-breadth-drift 1 'ADJACENCY_ASSET_ABSENT: rows=1'

  build_all; printf '$HOME/.config/the-janitor/session-id\truntime\tfile\t600\tmarker\n' >>"$R/census.tsv"
  rm -f "$R/host/.config/the-janitor/session-id"
  run_case runtime-absent-abstains 0 'ADJACENCY_ABSTAIN: rows=1'

  build_all; rm -f "$R/host/.config/opencode/opencode.json"
  ln -s "$R/vanished.json" "$R/host/.config/opencode/opencode.json"
  run_case unverified-dangling-symlink 1 'SCOPE UNVERIFIED'

  build_all
  set +e
  out="$(REALPATH_BIN=/bin/false "$SELF" --data "$R/adjacency.tsv" --census "$R/census.tsv" \
    --root "$R/host" --basis-root "$R" --lane-root "$R/lanes")"
  rc=$?
  set -e
  cases=$((cases + 1))
  if [[ "$rc" != 1 || "$out" != *'SCOPE UNVERIFIED'* || "$out" != *'ADJACENCY_SCOPE: DEFECT'* ]]; then
    failures=$((failures + 1)); printf 'SELFTEST FAIL realpath-fail-closed\n%s\n' "$out"
  fi

  build_all
  set +e
  out="$(cd / && "$SELF" --map --data "$R/adjacency.tsv" --census "$R/census.tsv" \
    --root "$R/host" --basis-root "$R" --lane-root "$R/lanes")"
  rc=$?
  set -e
  cases=$((cases + 1))
  if [[ "$rc" != 0 || "$out" != *'SCOPE_MAP: $HOME/.agents/AGENTS.md	shared'* || "$out" != *'SCOPE_MAP: $HOME/.local/bin/the-janitor	owned'* ]]; then
    failures=$((failures + 1)); printf 'SELFTEST FAIL map-view\n%s\n' "$out"
  fi

  build_all; : >"$R/adjacency.tsv"
  run_case empty-data 1 'ADJACENCY_SCOPE: DEFECT'

  build_all; mkdir -p "$R/lanes/kake-shokunin"; printf 'no such token\n' >"$R/lanes/kake-shokunin/k.md"
  sed -i 's/basis\.md:3/lane:kake\/k.md:1/' "$R/adjacency.tsv"
  run_case lane-basis-stale 1 'SCOPE STALE-BASIS'

  build_all; mkdir -p "$R/lanes/kake-shokunin"; printf 'beta lease line\n' >"$R/lanes/kake-shokunin/k.md"
  sed -i 's/basis\.md:3/lane:kake\/k.md:1/' "$R/adjacency.tsv"
  run_case lane-basis-ok 0 'ADJACENCY_SCOPE: CLEAN'

  cases=$((cases + 1))
  set +e
  out="$(env PATH=/nonexistent "$BASH" "$SELF" 2>&1)"
  rc=$?
  set -e
  if [[ "$rc" != 2 || "$out" != *'SETUP'* ]]; then
    failures=$((failures + 1)); printf 'SELFTEST FAIL bootstrap-setup-exit-2 (exit %s)\n%s\n' "$rc" "$out"
  fi

  cases=$((cases + 1))
  set +e
  out="$("$SELF" --data "$R/nope.tsv" --census "$R/census.tsv" --root "$R/host" 2>&1)"
  rc=$?
  set -e
  if [[ "$rc" != 2 || "$out" != *'ADJACENCY_SCOPE: SETUP'* ]]; then
    failures=$((failures + 1)); printf 'SELFTEST FAIL missing-data-setup-line (exit %s)\n%s\n' "$rc" "$out"
  fi

  if [[ "$failures" -eq 0 ]]; then printf 'SCOPE_SELFTEST: PASS (%s cases)\n' "$cases"; exit 0; fi
  printf 'SCOPE_SELFTEST: FAIL (%s/%s cases)\n' "$failures" "$cases"; exit 1
}

case "$MODE" in
  selftest) selftest ;;
  falsify) falsify ;;
  map) gate ;;
  *) gate ;;
esac