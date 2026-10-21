#!/usr/bin/env bash
# surface-census.sh — coverage gate for the surfaces this corpus claims to govern.
#
# v0 (rounds 1–9): `PROVINCE.md` §Surfaces was prose. Nothing detected a surface
# disappearing, changing kind/mode, or — the live leak vector proved in round 6 —
# an *undeclared* file appearing in `~/.config/the-janitor/`, which the handler
# would then load (discovery is not disabled). The two `xdg-data` runtime
# artifacts were named but unfalsifiable: "mutates legitimately; not pinned".
#
# v1 compares the live host against two committed data files and exits non-zero
# on any change, and can exercise the handler's write-side verbs on scratch
# overrides with a verdict per verb.
#
#   corpus/surface-census.tsv  path <TAB> class <TAB> kind <TAB> mode <TAB> note
#     class: asset   (must exist; absence or mutation is drift)
#            runtime (may legitimately be absent: ABSENT is informational)
#     kind:  file | dir | exec   (exec = regular file carrying u+x)
#     mode:  3 octal digits, or `-` for "do not check"
#     directive lines: `# scan` <TAB> <dir>  — every child of <dir> must be a
#            declared path, otherwise UNLISTED.
#
#   corpus/state-shape.tsv     path <TAB> kind <TAB> assertion <TAB> value <TAB> note
#     kind:  sqlite | log | json | lock | marker (presence+mode only;
#            session-id is a conversation marker, not a flock file)
#     assertion: magic | mode | size_min | lines_min | tables_min
#              | tables_required | rows_min (<table>:<floor>)
#              | keys (top-level JSON key names, presence only)
#     Floors are monotone lower bounds: they tolerate legitimate growth and
#     fire only on reset/truncation/schema loss. No assertion reads or prints
#     file content — see §Secret hygiene.
#
# Verdicts  surfaces: OK | DIVERGED | GONE | ABSENT | LINK | UNLISTED
#                    | CROSSCHECK   (a malformed row is a setup error: `die`,
#                    exit 2 — it is not a verdict)
#           shapes:   OK | SHAPE | ABSENT | SKIP (sqlite unreadable)
#           verbs:    PASS | FAIL | SKIP
# Exit      0 clean · 1 any drift or failed probe · 2 usage/setup error
#           (0 is also returned when the only non-OK lines are ABSENT/SKIP)
#
# Secret hygiene: this gate prints paths, kinds, modes, counts and verdicts.
# It never prints file content, an `op://` ref path, a vault item name, an
# account identifier, a transcript cell, or a hash of a 0600 private file
# (hashes of those stay withheld per the round-9 sentinel ruling in
# `knowledge/drift-gate.md` §Bounds; the census checks mode/kind only).
# `--verbs` runs the handler with scratch overrides and fabricates its own
# probe values; it never reads the real env file's values.
#
# Usage:
#   surface-census.sh                     verify surfaces + runtime shapes
#   surface-census.sh --verbs             exercise the local write-side verbs
#                                         (cdp-bridge ensure, refs, usage guards,
#                                         status) — scratch overrides only, no
#                                         `op` subprocess, no real file written
#   surface-census.sh --verbs --deep      add the probes with a real-world
#                                         effect: `op run` over a plain env, a
#                                         ref run that may block on the
#                                         1Password desktop prompt, and the
#                                         tac-register no-replace re-run on the
#                                         real custody record
#   surface-census.sh --selftest          scratch-tree proof that both fire
#   surface-census.sh --census F --shapes F --baseline F --root D
#                                         alternate inputs (selftest harness)
#   surface-census.sh --verb-root D       scratch root for --verbs
#   surface-census.sh --help
# Env: CENSUS_BREAK=<probe>   force one probe to FAIL (selftest only; never set
#                             it in a real run)
#      SQLITE3_BIN=<path>     sqlite3 binary (selftest 10 proves the fail-closed
#                             path with a name that cannot resolve)
#      THE_JANITOR_BIN=<path> handler binary; every probe invocation uses it
#
# There is deliberately no `--pin`: editing a declaration is a scope decision
# that must be a reviewed commit, unlike a mechanical hash re-pin.
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CENSUS="$SCRIPT_DIR/surface-census.tsv"
SHAPES="$SCRIPT_DIR/state-shape.tsv"
BASELINE="$SCRIPT_DIR/drift-baseline.tsv"
ROOT="${HOME}"
VERB_ROOT=""
MODE="verify"
DEEP=""
JANITOR="${THE_JANITOR_BIN:-the-janitor}"
SQLITE3="${SQLITE3_BIN:-sqlite3}"

die() { printf 'surface-census: %s\n' "$1" >&2; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    verify|--verify) MODE="verify"; shift ;;
    --verbs) MODE="verbs"; shift ;;
    --deep) DEEP=1; shift ;;
    --selftest) MODE="selftest"; shift ;;
    --census) [[ $# -ge 2 ]] || die "--census needs a file"; CENSUS="$2"; shift 2 ;;
    --shapes) [[ $# -ge 2 ]] || die "--shapes needs a file"; SHAPES="$2"; shift 2 ;;
    --baseline) [[ $# -ge 2 ]] || die "--baseline needs a file"; BASELINE="$2"; shift 2 ;;
    --root) [[ $# -ge 2 ]] || die "--root needs a dir"; ROOT="$2"; shift 2 ;;
    --verb-root) [[ $# -ge 2 ]] || die "--verb-root needs a dir"; VERB_ROOT="$2"; shift 2 ;;
    -h|--help) sed -n '2,60p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

STATE_SUFFIX=".local/state/the-janitor"
# The redaction probes must feed a value whose first five bytes are the
# 1Password ref scheme. The prefix is assembled at runtime so that no committed
# line of this repo carries a ref-shaped literal — corpus rule from round 1
# ("no op:// ref path in an artifact"), which a fabricated literal would still
# blur for the next reader.
RS='op:'"//"
declare -a CLEANUP_DIRS=()
MAGIC_EXPECT=""

cleanup() {
  local d
  for d in "${CLEANUP_DIRS[@]:-}"; do [[ -n "$d" ]] && rm -rf "$d"; done
  [[ -n "$MAGIC_EXPECT" ]] && rm -f "$MAGIC_EXPECT"
  return 0
}
trap cleanup EXIT

# Expand the two documented prefixes. Nothing else is templated: a row that
# hardcodes another lane's path is a scope error, not a portability feature.
resolve() {
  local p="$1"
  p="${p/\$HOME/$ROOT}"
  p="${p/\$STATE/$ROOT/$STATE_SUFFIX}"
  printf '%s' "$p"
}

stat_kind() { # prints: regular|directory|symlink|missing|other
  local p="$1"
  if [[ -L "$p" ]]; then printf 'symlink'; return; fi
  if [[ ! -e "$p" ]]; then printf 'missing'; return; fi
  case "$(stat -c %F "$p" 2>/dev/null)" in
    "regular file"|"regular empty file") printf 'regular' ;;
    directory) printf 'directory' ;;
    *) printf 'other' ;;
  esac
}

stat_mode() { stat -c %a "$1" 2>/dev/null || printf '?'; }

# --- verify mode -----------------------------------------------------------

declare -a ROW_PATH=() ROW_CLASS=() ROW_KIND=() ROW_MODE=() ROW_LABEL=()
declare -a SCAN_DIR=()
FAILED=0
N_OK=0; N_ABSENT=0; N_DIVERGED=0; N_GONE=0; N_LINK=0; N_UNLISTED=0
N_CROSSCHECK=0; N_SHAPE=0; N_SKIP=0; N_UNVERIFIED=0

load_census() {
  local line f1 f2 f3 f4 f5 lineno=0
  [[ -r "$CENSUS" ]] || die "census file not readable: $CENSUS"
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    [[ -z "$line" ]] && continue
    if [[ "$line" == '#'* ]]; then
      IFS=$'\t' read -r f1 f2 _ <<<"$line"
      [[ "$f1" == "# scan" ]] && SCAN_DIR+=("$(resolve "$f2")")
      continue
    fi
    IFS=$'\t' read -r f1 f2 f3 f4 f5 extra <<<"$line"
    # A fused row (a missing newline between two rows) parses as a long note and
    # silently drops the second row — found in round 10 by the L2 wave. Refuse
    # the file instead of evaluating a subset of it.
    [[ -n "${extra:-}" ]] && die "row $lineno: too many fields ($(( 5 + 1 )) minimum) — fused rows?" 
    [[ -z "${f1:-}" ]] && continue
    case "${f2:-}" in asset|runtime) ;; *) die "row $lineno: bad class '${f2:-}'" ;; esac
    case "${f3:-}" in file|dir|exec) ;; *) die "row $lineno: bad kind '${f3:-}'" ;; esac
    if [[ "${f4:-}" != '-' ]] && [[ ! "${f4:-}" =~ ^[0-7]{3}$ ]]; then
      die "row $lineno: bad mode '${f4:-}' (3 octal digits, as `stat -c %a` prints)"
    fi
    ROW_PATH+=("$f1"); ROW_CLASS+=("$f2"); ROW_KIND+=("$f3"); ROW_MODE+=("${f4:--}")
    ROW_LABEL+=("${f5:-}")
  done <"$CENSUS"
}

mode_from_baseline() { # $1 = $HOME-relative path -> mode or empty
  local want="$1"
  [[ -r "$BASELINE" ]] || return 0
  awk -F'\t' -v p="$want" '$1==p {print $2; exit}' "$BASELINE"
}

verify_surfaces() {
  local i p cls kind mode live lmode want_mode base abs
  for i in "${!ROW_PATH[@]}"; do
    p="${ROW_PATH[$i]}"; cls="${ROW_CLASS[$i]}"; kind="${ROW_KIND[$i]}"; mode="${ROW_MODE[$i]}"
    abs="$(resolve "$p")"
    live="$(stat_kind "$abs")"
    if [[ "$live" == "missing" ]]; then
      if [[ "$cls" == "runtime" ]]; then
        printf 'SURFACE ABSENT   %s (%s)\n' "$p" "$kind"
        N_ABSENT=$((N_ABSENT + 1))
      else
        printf 'SURFACE GONE     %s (%s expected)\n' "$p" "$kind"
        N_GONE=$((N_GONE + 1)); FAILED=1
      fi
      continue
    fi
    if [[ "$live" == "symlink" ]]; then
      printf 'SURFACE LINK     %s (declared %s)\n' "$p" "$kind"
      N_LINK=$((N_LINK + 1)); FAILED=1
      continue
    fi
    case "$kind" in
      dir) if [[ "$live" != "directory" ]]; then
             printf 'SURFACE DIVERGED %s (declared dir, live %s)\n' "$p" "$live"
             N_DIVERGED=$((N_DIVERGED + 1)); FAILED=1; continue
           fi ;;
      file|exec) if [[ "$live" != "regular" ]]; then
             printf 'SURFACE DIVERGED %s (declared %s, live %s)\n' "$p" "$kind" "$live"
             N_DIVERGED=$((N_DIVERGED + 1)); FAILED=1; continue
           fi
           if [[ "$kind" == "exec" && ! -x "$abs" ]]; then
             printf 'SURFACE DIVERGED %s (declared exec, no execute bit)\n' "$p"
             N_DIVERGED=$((N_DIVERGED + 1)); FAILED=1; continue
           fi ;;
    esac
    lmode="$(stat_mode "$abs")"
    if [[ "$mode" != "-" ]] && [[ "$lmode" != "$mode" ]]; then
      printf 'SURFACE DIVERGED %s (mode %s, declared %s)\n' "$p" "$lmode" "$mode"
      N_DIVERGED=$((N_DIVERGED + 1)); FAILED=1; continue
    fi
    # Cross-check against the drift baseline: one fact, one owner. Where both
    # files describe the same path's mode, they must agree.
    if [[ "$mode" != "-" ]]; then
      want_mode="$(mode_from_baseline "$p")"
      [[ -z "$want_mode" ]] && want_mode="$(mode_from_baseline "${abs/$ROOT/\$HOME}")"
      if [[ -n "$want_mode" && "$want_mode" != "$mode" ]]; then
        printf 'SURFACE CROSSCHECK %s (census mode %s vs drift-baseline %s)\n' "$p" "$mode" "$want_mode"
        N_CROSSCHECK=$((N_CROSSCHECK + 1)); FAILED=1; continue
      fi
    fi
    printf 'SURFACE OK       %s (%s %s)\n' "$p" "$kind" "$lmode"
    N_OK=$((N_OK + 1))
  done
}

verify_unlisted() {
  local dir child i declared base
  [[ ${#SCAN_DIR[@]} -eq 0 ]] && return 0
  for dir in "${SCAN_DIR[@]}"; do
    if [[ ! -d "$dir" ]]; then
      printf 'SURFACE GONE     %s (scan dir)\n' "$dir"
      N_GONE=$((N_GONE + 1)); FAILED=1
      continue
    fi
    while IFS= read -r -d '' child; do
      declared=0
      for i in "${!ROW_PATH[@]}"; do
        if [[ "$(resolve "${ROW_PATH[$i]}")" == "$child" ]]; then declared=1; break; fi
      done
      if [[ "$declared" -eq 0 ]]; then
        base="${child/$ROOT/\$HOME}"
        base="${base/$ROOT\/$STATE_SUFFIX/\$STATE}"
        printf 'SURFACE UNLISTED %s (%s %s)\n' "$base" "$(stat_kind "$child")" "$(stat_mode "$child")"
        N_UNLISTED=$((N_UNLISTED + 1)); FAILED=1
      fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 | sort -z)
  done
}

# --- runtime shape pins ----------------------------------------------------

sqlite_probe() { # $1 = live path -> sets S_TABLES, S_NAMES, S_ROWS, S_ERR, S_RERR
  local live="$1" need_tables="$2" sql out rc snap
  local path="$live" t
  S_ERR=""; S_RERR=""; S_TABLES=""; S_NAMES=""; S_ROWS=""
  if ! command -v "$SQLITE3" >/dev/null 2>&1; then S_ERR="sqlite3 unavailable: $SQLITE3"; return 0; fi
  # Never open the live artifact: a read-only SQLite open can still touch
  # `-shm`, which would make this gate a mutator of a surface it verifies.
  # A WAL-mode database is only current together with its `-wal`, so the
  # snapshot carries the siblings when they are non-empty.
  snap="$(mktemp -d "${TMPDIR:-/tmp}/surface-census.XXXXXX")" || { S_ERR="no scratch dir"; return 0; }
  CLEANUP_DIRS+=("$snap")
  cp -p "$live" "$snap/db" 2>/dev/null || { S_ERR="snapshot copy failed"; return 0; }
  [[ -s "$live-wal" ]] && cp -p "$live-wal" "$snap/db-wal" 2>/dev/null
  [[ -s "$live-shm" ]] && cp -p "$live-shm" "$snap/db-shm" 2>/dev/null
  path="$snap/db"
  # Call A — metadata only. It must never fail because a *data* table is
  # missing: a dropped table has to read as SHAPE (missing tables), not as an
  # unreadable database that skips every assertion.
  sql="select 'tables|'||(select count(*) from sqlite_master where type='table');"
  sql+=" select 'name|'||name from sqlite_master where type='table';"
  set +e
  out="$("$SQLITE3" "file:$path?mode=ro" "$sql" 2>&1)"; rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then S_ERR="$(printf '%s' "$out" | head -n1)"; S_ERR="${S_ERR#Error: }"; return 0; fi
  local line
  while IFS= read -r line; do
    case "$line" in
      tables\|*) S_TABLES="${line#tables|}" ;;
      name\|*) S_NAMES+="${line#name|}"$'\n' ;;
    esac
  done <<<"$out"
  # Call B — row counts, only for tables that actually exist.
  sql=""
  for t in $need_tables; do
    if names_has "$S_NAMES" "$t"; then sql+=" select 'rows|$t|'||count(*) from \"$t\";"; fi
  done
  [[ -z "$sql" ]] && return 0
  set +e
  out="$("$SQLITE3" "file:$path?mode=ro" "$sql" 2>&1)"; rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then S_RERR="$(printf '%s' "$out" | head -n1)"; S_RERR="${S_RERR#Error: }"; return 0; fi
  while IFS= read -r line; do
    case "$line" in rows\|*) S_ROWS+="${line#rows|}"$'\n' ;; esac
  done <<<"$out"
}

names_has() { printf '%s' "$1" | grep -Fxq "$2"; }
rows_get() { printf '%s' "$1" | awk -F'|' -v t="$2" '$1==t {print $2; exit}'; }

verify_shapes() {
  local line f1 f2 f3 f4 f5 lineno=0 p kind assertion value abs live lmode
  declare -A need_rows=()
  declare -A sqlite_done=() ; declare -A S_TABLES_A=() ; declare -A S_NAMES_A=()
  declare -A S_ROWS_A=() ; declare -A S_ERR_A=() ; declare -A S_RERR_A=()

  [[ -r "$SHAPES" ]] || die "shape file not readable: $SHAPES"
  # Pass 1: collect the tables whose row floors are pinned, so each sqlite file
  # is opened exactly once.
  while IFS=$'\t' read -r f1 f2 f3 f4 _ extra || [[ -n "$f1" ]]; do
    lineno=$((lineno + 1))
    [[ -n "${extra:-}" ]] && printf 'surface-census: note — pass 1 saw a >5-field row at line %s\n' "$lineno" >&2
    [[ -z "${f1:-}" || "$f1" == '#'* ]] && continue
    if [[ "${f3:-}" == "rows_min" ]]; then
      need_rows["$f1"]+="${f4%%:*} "
    fi
  done <"$SHAPES"

  lineno=0
  while IFS=$'\t' read -r f1 f2 f3 f4 f5 extra || [[ -n "$f1" ]]; do
    lineno=$((lineno + 1))
    [[ -z "${f1:-}" ]] && continue
    [[ "$f1" == '#'* ]] && continue
    [[ -n "${extra:-}" ]] && die "shape row $lineno: too many fields (fused rows?)" 
    case "${f2:-}" in sqlite|log|json|lock|marker) ;; *) die "shape row $lineno: bad kind '${f2:-}'" ;; esac
    case "${f3:-}" in magic|mode|size_min|lines_min|tables_min|tables_required|rows_min|keys) ;;
      *) die "shape row $lineno: bad assertion '${f3:-}'" ;; esac
    p="$f1"; kind="$f2"; assertion="$f3"; value="$f4"
    abs="$(resolve "$p")"
    live="$(stat_kind "$abs")"
    if [[ "$live" == "missing" ]]; then
      printf 'SHAPE ABSENT   %s %s (runtime)\n' "$p" "$assertion"
      N_ABSENT=$((N_ABSENT + 1)); continue
    fi
    if [[ "$live" != "regular" ]]; then
      printf 'SHAPE SHAPE    %s %s (live %s)\n' "$p" "$assertion" "$live"
      N_SHAPE=$((N_SHAPE + 1)); FAILED=1; continue
    fi
    case "$assertion" in
      mode)
        lmode="$(stat_mode "$abs")"
        if [[ "$lmode" == "$value" ]]; then printf 'SHAPE OK       %s mode %s\n' "$p" "$lmode"
        else printf 'SHAPE SHAPE    %s mode %s want %s\n' "$p" "$lmode" "$value"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi ;;
      size_min)
        local sz; sz="$(stat -c %s "$abs")"
        if [[ "$sz" -ge "$value" ]]; then printf 'SHAPE OK       %s size %s >= %s\n' "$p" "$sz" "$value"
        else printf 'SHAPE SHAPE    %s size %s < floor %s\n' "$p" "$sz" "$value"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi ;;
      lines_min)
        local ln; ln="$(wc -l <"$abs")"
        if [[ "$ln" -ge "$value" ]]; then printf 'SHAPE OK       %s lines %s >= %s\n' "$p" "$ln" "$value"
        else printf 'SHAPE SHAPE    %s lines %s < floor %s\n' "$p" "$ln" "$value"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi ;;
      magic)
        # Exact, NUL-inclusive: a text file carrying the 15-char prefix but no
        # terminator must fail, which is why the expected value is written to
        # a scratch file rather than string-compared.
        [[ -n "$MAGIC_EXPECT" ]] || MAGIC_EXPECT="$(mktemp)"
        printf '%s\0' "$value" >"$MAGIC_EXPECT"
        if head -c "$(( ${#value} + 1 ))" "$abs" | cmp -s - "$MAGIC_EXPECT"; then
          printf 'SHAPE OK       %s magic (16-byte header)\n' "$p"
        else
          printf 'SHAPE SHAPE    %s magic mismatch (not a %s header)\n' "$p" "${#value}-byte+ NUL"
          N_SHAPE=$((N_SHAPE + 1)); FAILED=1
        fi ;;
      keys)
        local keys; keys="$(python3 -c 'import json,sys; print(" ".join(json.load(open(sys.argv[1])).keys()))' "$abs" 2>/dev/null || printf '__parse_error__')"
        if [[ "$keys" == "__parse_error__" ]]; then
          printf 'SHAPE SHAPE    %s json parse failed\n' "$p"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1
        else
          local want missing="" k
          IFS=',' read -r -a want <<<"$value"
          for k in "${want[@]}"; do names_has "$(printf '%s\n' $keys)" "$k" || missing+="$k "; done
          if [[ -z "$missing" ]]; then printf 'SHAPE OK       %s keys present (%s)\n' "$p" "${#want[@]}"
          else printf 'SHAPE SHAPE    %s missing keys: %s\n' "$p" "${missing% }"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi
        fi ;;
      tables_min|tables_required|rows_min)
        if [[ -z "${sqlite_done[$p]:-}" ]]; then
          sqlite_probe "$abs" "${need_rows[$p]:-}"
          S_TABLES_A["$p"]="$S_TABLES"; S_NAMES_A["$p"]="$S_NAMES"
          S_ROWS_A["$p"]="$S_ROWS"; S_ERR_A["$p"]="$S_ERR"; S_RERR_A["$p"]="$S_RERR"
          sqlite_done["$p"]=1
        fi
        # A locked database is transient and exit-neutral (the handler may be
        # writing); anything else means the assertion could not be evaluated at
        # all — that is UNVERIFIED and fails closed, because a CLEAN summary
        # over an unread shape class is the false-clean this gate exists to
        # prevent.
        if [[ -n "${S_ERR_A[$p]:-}" ]]; then
          if [[ "${S_ERR_A[$p]}" =~ (locked|busy) ]]; then
            printf 'SHAPE SKIP     %s %s (%s)\n' "$p" "$assertion" "${S_ERR_A[$p]}"
            N_SKIP=$((N_SKIP + 1))
          else
            printf 'SHAPE UNVERIFIED %s %s (%s)\n' "$p" "$assertion" "${S_ERR_A[$p]}"
            N_UNVERIFIED=$((N_UNVERIFIED + 1)); FAILED=1
          fi
          continue
        fi
        if [[ "$assertion" == "rows_min" && -n "${S_RERR_A[$p]:-}" ]]; then
          if [[ "${S_RERR_A[$p]}" =~ (locked|busy) ]]; then
            printf 'SHAPE SKIP     %s rows_min (%s)\n' "$p" "${S_RERR_A[$p]}"
            N_SKIP=$((N_SKIP + 1))
          else
            printf 'SHAPE UNVERIFIED %s rows_min (%s)\n' "$p" "${S_RERR_A[$p]}"
            N_UNVERIFIED=$((N_UNVERIFIED + 1)); FAILED=1
          fi
          continue
        fi
        case "$assertion" in
          tables_min)
            local n; n="${S_TABLES_A[$p]}"
            if [[ "$n" -ge "$value" ]]; then printf 'SHAPE OK       %s tables %s >= %s\n' "$p" "$n" "$value"
            else printf 'SHAPE SHAPE    %s tables %s < floor %s\n' "$p" "$n" "$value"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi ;;
          tables_required)
            local miss="" t; IFS=',' read -r -a t <<<"$value"
            for k in "${t[@]}"; do names_has "${S_NAMES_A[$p]}" "$k" || miss+="$k "; done
            if [[ -z "$miss" ]]; then printf 'SHAPE OK       %s required tables present (%s)\n' "$p" "${#t[@]}"
            else printf 'SHAPE SHAPE    %s missing tables: %s\n' "$p" "${miss% }"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi ;;
          rows_min)
            local tbl="${value%%:*}" floor="${value##*:}" got
            got="$(rows_get "${S_ROWS_A[$p]}" "$tbl")"
            if [[ -z "$got" ]]; then
              printf 'SHAPE SHAPE    %s rows %s: table absent\n' "$p" "$tbl"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1
            elif [[ "$got" -ge "$floor" ]]; then printf 'SHAPE OK       %s rows %s %s >= %s\n' "$p" "$tbl" "$got" "$floor"
            else printf 'SHAPE SHAPE    %s rows %s %s < floor %s (floor anchors the recorded census; re-anchor after a deliberate reset)\n' "$p" "$tbl" "$got" "$floor"; N_SHAPE=$((N_SHAPE + 1)); FAILED=1; fi ;;
        esac ;;
    esac
  done <"$SHAPES"
}

# --- verb probes -----------------------------------------------------------

PROBE=""; PROBE_FAILS=0; PROBE_PASSES=0; PROBE_SKIPS=0

check() { # name expected actual
  local name="$1" expected="$2" actual="$3"
  if [[ -n "${CENSUS_BREAK:-}" && "$CENSUS_BREAK" == "$PROBE" ]]; then
    actual="<injected-mismatch>"
  fi
  if [[ "$expected" == "$actual" ]]; then printf '  check %-28s ok\n' "$name"
  else printf '  check %-28s FAIL (want=%s got=%s)\n' "$name" "$expected" "$actual"; PROBE_FAILS=$((PROBE_FAILS + 1)); fi
}

probe_open() { PROBE="$1"; printf 'PROBE %s\n' "$PROBE"; }
probe_close() {
  local verdict="$1" detail="${2:-}"
  case "$verdict" in
    PASS) PROBE_PASSES=$((PROBE_PASSES + 1)); printf 'PROBE %s: PASS  %s\n' "$PROBE" "$detail" ;;
    SKIP) PROBE_SKIPS=$((PROBE_SKIPS + 1)); printf 'PROBE %s: SKIP  %s\n' "$PROBE" "$detail" ;;
    FAIL) PROBE_FAILS=$((PROBE_FAILS + 1)); printf 'PROBE %s: FAIL  %s\n' "$PROBE" "$detail" ;;
  esac
}

verbs() {
  local S rc out
  [[ -n "$VERB_ROOT" ]] || VERB_ROOT="$(mktemp -d)"
  mkdir -p "$VERB_ROOT"
  command -v "$JANITOR" >/dev/null 2>&1 || die "handler not on PATH: $JANITOR"
  case "$VERB_ROOT" in
    /*) ;;
    *) die "scratch root must be absolute: $VERB_ROOT" ;;
  esac

  # 1 — cdp-bridge ensure, scratch profile: the real profile is never touched.
  local before=$PROBE_FAILS
  probe_open cdp-ensure-scratch
  S="$VERB_ROOT/cdp"; rm -rf "$S"; mkdir -p "$S"
  # Guard: every probe path must live under the scratch root. An override
  # regression that silently pointed at the real profile would otherwise write
  # into a surface this repo only monitors.
  [[ "$S" == "$VERB_ROOT/"* ]] || die "probe path escaped the scratch root: $S"
  set +e
  out="$(MUSKETEER_CHROME_PROFILE="$S/profile" "$JANITOR" cdp-bridge ensure 2>&1)"; rc=$?
  set -e
  local NMH="$S/profile/NativeMessagingHosts/com.1password.1password.json"
  check exit 0 "$rc"
  check file-written yes "$([[ -f "$NMH" ]] && echo yes || echo no)"
  check mode 600 "$(stat_mode "$NMH")"
  local parsed
  parsed="$(python3 - "$NMH" <<'PY' 2>/dev/null || printf 'PARSE_ERROR'
import json,sys
d=json.load(open(sys.argv[1]))
print("%s|%s|%s" % (d.get("path"), len(d.get("allowed_origins") or []), ",".join(sorted(d.get("allowed_origins") or []))))
PY
)"
  local expect_path="${ONEPASSWORD_BROWSER_SUPPORT:-/opt/1Password/1Password-BrowserSupport}"
  check json-path "$expect_path" "${parsed%%|*}"
  check origins 2 "$(printf '%s' "$parsed" | awk -F'|' '{print $2}')"
  check nmh-entries 1 "$(find "$S/profile/NativeMessagingHosts" -mindepth 1 -maxdepth 1 | wc -l)"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "scratch profile only"

  # 2 — same verb, missing BrowserSupport: must refuse and write nothing.
  before=$PROBE_FAILS
  probe_open cdp-ensure-missing-support
  S="$VERB_ROOT/cdp2"; rm -rf "$S"; mkdir -p "$S"
  set +e
  out="$(MUSKETEER_CHROME_PROFILE="$S/profile" ONEPASSWORD_BROWSER_SUPPORT="$S/nonexistent" "$JANITOR" cdp-bridge ensure 2>&1)"; rc=$?
  set -e
  check exit 2 "$rc"
  check message yes "$([[ "$out" == *"BrowserSupport missing"* ]] && echo yes || echo no)"
  check no-file absent "$([[ -e "$S/profile/NativeMessagingHosts/com.1password.1password.json" ]] && echo written || echo absent)"
  check nmh-dir-created yes "$([[ -d "$S/profile/NativeMessagingHosts" ]] && echo yes || echo no)"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "refusal path"

  # 3 — refs redaction on a fabricated env file (never the real op.env).
  before=$PROBE_FAILS
  probe_open refs-redaction
  S="$VERB_ROOT/refs"; rm -rf "$S"; mkdir -p "$S"
  printf '%s\n' "FAKE_REF=${RS}FakeVault/FakeItem/FakeField" 'FAKE_PLAIN=fake-plain-value-0001' >"$S/op.env"
  chmod 600 "$S/op.env"
  set +e
  out="$(THE_JANITOR_ENV="$S/op.env" "$JANITOR" refs 2>&1)"; rc=$?
  set -e
  check exit 0 "$rc"
  check ref-verbatim yes "$([[ "$out" == *"FAKE_REF=${RS}FakeVault/FakeItem/FakeField"* ]] && echo yes || echo no)"
  check plain-redacted yes "$([[ "$out" == *'FAKE_PLAIN=<redacted-non-op-value>'* ]] && echo yes || echo no)"
  check plain-absent yes "$([[ "$out" != *"fake-plain-value-0001"* ]] && echo yes || echo no)"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "fabricated env file"

  # 4 — refs shape table: which line shapes the awk in cmd_refs (L228-235)
  #     matches at all. An unmatched key is silently absent from the inventory,
  #     which is a different hazard from a leaked value.
  before=$PROBE_FAILS
  probe_open refs-shape-table
  S="$VERB_ROOT/refs2"; rm -rf "$S"; mkdir -p "$S"
  {
    printf '%s\n' 'UPPER_PLAIN=shh-000'
    printf '%s\n' 'UPPER_EMPTY='
    printf '%s\n' 'UPPER_EQ=a=b'
    printf '%s\n' 'export EXPORTED=shh-002'
    printf '%s\n' 'LOWER_case=shh-003'
    printf '%s\n' '  LEADING_SPACE=shh-004'
    printf '%s\n' 'UPPER_REF='"${RS}FakeVault/FakeItem/F2"
  } >"$S/op.env"
  chmod 600 "$S/op.env"
  set +e
  out="$(THE_JANITOR_ENV="$S/op.env" "$JANITOR" refs 2>&1)"; rc=$?
  set -e
  check exit 0 "$rc"
  check line-count 4 "$(printf '%s\n' "$out" | sed -n '2,$p' | grep -c .)"
  check listed-upper-plain yes "$([[ "$out" == *'UPPER_PLAIN=<redacted-non-op-value>'* ]] && echo yes || echo no)"
  check listed-empty yes "$([[ "$out" == *'UPPER_EMPTY=<redacted-non-op-value>'* ]] && echo yes || echo no)"
  check listed-ref yes "$([[ "$out" == *"UPPER_REF=${RS}FakeVault/FakeItem/F2"* ]] && echo yes || echo no)"
  check omitted-export yes "$([[ "$out" != *EXPORTED* ]] && echo yes || echo no)"
  check omitted-lower yes "$([[ "$out" != *LOWER_case* ]] && echo yes || echo no)"
  check omitted-leading yes "$([[ "$out" != *LEADING_SPACE* ]] && echo yes || echo no)"
  check no-plain-leak yes "$([[ "$out" != *shh-0* ]] && echo yes || echo no)"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "3 shapes listed, 3 omitted"

  # 4b — the redaction guard is a prefix match, not a validator: a value whose
  #      first five bytes are literally `op://` is echoed whole, plaintext tail
  #      included (round-10 executor finding F1; cmd_refs awk L234). PASS here
  #      means the defect is still present — a fix flips this row to FAIL on
  #      purpose, forcing the decision table and this probe to be updated in
  #      the same commit. Anything else in that value shape is a leak.
  before=$PROBE_FAILS
  probe_open refs-redaction-prefix-only
  S="$VERB_ROOT/refs3"; rm -rf "$S"; mkdir -p "$S"
  printf '%s\n' "LEAK_KEY=${RS}FakeVault/FakeItem/field fakeplaintext-0009" >"$S/op.env"
  chmod 600 "$S/op.env"
  set +e
  out="$(THE_JANITOR_ENV="$S/op.env" "$JANITOR" refs 2>&1)"; rc=$?
  set -e
  check exit 0 "$rc"
  check tail-echoed yes "$([[ "$out" == *"fakeplaintext-0009"* ]] && echo yes || echo no)"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "unredacted tail rides out"

  # 5 — run with a plain-values env file: pass-through, no vault dependency.
  #     Behind --deep: it execs `op`, and the default probe set deliberately
  #     execs no `op` binary at all (see the usage guards below).
  before=$PROBE_FAILS
  probe_open run-plain-env
  if [[ -z "${DEEP:-}" ]]; then
    probe_close SKIP "requires --deep (execs op)"
  else
    S="$VERB_ROOT/run"; rm -rf "$S"; mkdir -p "$S"
    printf '%s\n' 'FAKE_PLAIN=fake-plain-value-0002' >"$S/op.env"; chmod 600 "$S/op.env"
    set +e
    out="$(THE_JANITOR_ENV="$S/op.env" timeout 20 "$JANITOR" run -- sh -c 'printf %s "$FAKE_PLAIN"' 2>&1)"; rc=$?
    set -e
    check exit 0 "$rc"
    check value-passed "fake-plain-value-0002" "$out"
    probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "no vault access needed"
  fi

  # 6 — run with a ref while signed out: must not succeed, and may block on the
  #     1Password desktop prompt instead of failing fast (round-10 executor
  #     finding F2: exit 1 after 6.4 s with a "isn't a vault in this account"
  #     error, or exit 124 silent at the bound — non-deterministic). Operator
  #     present only: --deep.
  before=$PROBE_FAILS
  probe_open run-ref-signed-out
  if [[ -z "${DEEP:-}" ]]; then
    probe_close SKIP "requires --deep (may block on the desktop prompt)"
  else
    S="$VERB_ROOT/runref"; rm -rf "$S"; mkdir -p "$S"
    printf '%s\n' 'FAKE_REF=op://FakeVault/FakeItem/F3' >"$S/op.env"; chmod 600 "$S/op.env"
    local t0 t1 wall
    t0=$(date +%s)
    set +e
    out="$(THE_JANITOR_ENV="$S/op.env" timeout 25 "$JANITOR" run -- sh -c 'printf %s "${FAKE_REF:-unset}"' 2>&1)"; rc=$?
    set -e
    t1=$(date +%s); wall=$((t1 - t0))
    check not-succeeded "$([[ $rc -ne 0 ]] && echo yes || echo no)" yes
    printf '  info exit=%s wall=%ss mode=%s\n' "$rc" "$wall" "$([[ $rc -eq 124 ]] && echo blocked-on-prompt || echo fast-fail)"
    probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "exit $rc after ${wall}s"
  fi

  # 7 — tac-register re-run must not replace an existing record. Reads the real
  #     custody record and runs the real binary, so it is --deep only; it
  #     refuses to create a record if none exists.
  before=$PROBE_FAILS
  probe_open tac-register-no-replace
  local REC="$HOME/.local/state/the-janitor/tac-daybreak-blue.json"
  if [[ -z "${DEEP:-}" ]]; then
    probe_close SKIP "requires --deep (reads the real custody record)"
  elif [[ ! -f "$REC" ]]; then
    probe_close SKIP "no custody record present; refusing to create one"
  else
    local h0 h1 m0 m1
    h0="$(sha256sum "$REC" | cut -d' ' -f1)"; m0="$(stat -c %Y:%s "$REC")"
    set +e
    out="$(timeout 20 "$JANITOR" tac-register 2>&1)"; rc=$?
    set -e
    h1="$(sha256sum "$REC" | cut -d' ' -f1)"; m1="$(stat -c %Y:%s "$REC")"
    check exit 0 "$rc"
    # Compare digests without printing them: a sha256 of a 0600 file published
    # in a log is the offline oracle the round-9 ruling withholds.
    if [[ "$h0" == "$h1" ]]; then printf '  check %-28s ok\n' sha-unchanged
    else printf '  check %-28s FAIL (custody record digest changed)\n' sha-unchanged; PROBE_FAILS=$((PROBE_FAILS + 1)); fi
    check mtime-size-unchanged "$m0" "$m1"
    check not-replaced yes "$([[ "$out" != *LOCAL_EVIDENCE_CHECK:\ FAILED* ]] && echo yes || echo no)"
    probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "existing record intact"
  fi

  # 8 — argument/guard paths of `run` and `refs`: the documented exit-2 refusals,
  #     reached before any `op` subprocess is executed and before any file is
  #     written. This is the default set's coverage of `run` — the op-executing
  #     behaviour of the same verb sits behind --deep.
  before=$PROBE_FAILS
  probe_open usage-guards
  S="$VERB_ROOT/guards"; rm -rf "$S"; mkdir -p "$S"
  printf '%s\n' 'FAKE_PLAIN=fake-plain-value-0003' >"$S/present.env"; chmod 600 "$S/present.env"
  set +e
  out="$(THE_JANITOR_ENV="$S/present.env" "$JANITOR" run 2>&1)"; rc=$?
  set -e
  check run-no-command-exit 2 "$rc"
  check run-no-command-msg yes "$([[ "$out" == *"missing command"* ]] && echo yes || echo no)"
  set +e
  out="$(THE_JANITOR_ENV="$S/absent.env" "$JANITOR" run -- true 2>&1)"; rc=$?
  set -e
  check run-missing-env-exit 2 "$rc"
  check run-missing-env-msg yes "$([[ "$out" == *"missing $S/absent.env"* ]] && echo yes || echo no)"
  set +e
  out="$(THE_JANITOR_ENV="$S/absent.env" "$JANITOR" refs 2>&1)"; rc=$?
  set -e
  check refs-missing-env-exit 2 "$rc"
  check no-file-created yes "$([[ ! -e "$S/absent.env" ]] && echo yes || echo no)"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "3 refusals, no op exec"

  # 9 — status contract: five static lines, one live-dependent state line.
  before=$PROBE_FAILS
  probe_open status-contract
  S="$VERB_ROOT/status"; rm -rf "$S"; mkdir -p "$S"
  set +e
  out="$(THE_JANITOR_STATE_DIR="$S/state" "$JANITOR" status 2>&1)"; rc=$?
  set -e
  local missing="" k
  for k in session model endpoint "fallback disabled" config_overlay state; do
    printf '%s\n' "$out" | grep -q "^$k" || missing+="$k "
  done
  check exit 0 "$rc"
  check static-lines "$([[ -z "$missing" ]] && echo yes || echo no)" yes
  local state_val tmux_rc
  state_val="$(printf '%s\n' "$out" | awk '/^state /{print $2}')"
  set +e; tmux has-session -t janitor 2>/dev/null; tmux_rc=$?; set -e
  check state-live "$([[ $tmux_rc -eq 0 ]] && echo running || echo stopped)" "$state_val"
  probe_close "$([[ $PROBE_FAILS -eq $before ]] && echo PASS || echo FAIL)" "static contract + state=$state_val"
}

# --- selftest --------------------------------------------------------------

selftest() {
  local cases=0 failures=0 R
  R="$(mktemp -d)"
  SELFTEST_R="$R"
  trap 'rm -rf "$SELFTEST_R"' EXIT

  build_tree() { # clean scratch host tree
    rm -rf "$R/host"; mkdir -p "$R/host/.config/the-janitor" "$R/host/.local/bin" \
      "$R/host/.local/state/tac" "$R/host/.local/state/the-janitor/xdg-data/opencode/log" \
      "$R/host/.config/opencode"
    chmod 700 "$R/host/.local/state/the-janitor" "$R/host/.local/state/the-janitor/xdg-data" \
      "$R/host/.local/state/the-janitor/xdg-data/opencode" "$R/host/.local/state/the-janitor/xdg-data/opencode/log"
    printf 'x\n' >"$R/host/.config/the-janitor/op.env"; chmod 600 "$R/host/.config/the-janitor/op.env"
    printf 'x\n' >"$R/host/.local/bin/the-janitor"; chmod 755 "$R/host/.local/bin/the-janitor"
    printf 'x\n' >"$R/host/.local/state/tac/daybreak-blue-access.json"; chmod 600 "$R/host/.local/state/tac/daybreak-blue-access.json"
    : >"$R/host/.local/state/the-janitor/client.lock"; chmod 600 "$R/host/.local/state/the-janitor/client.lock"
    sqlite3 "$R/host/.local/state/the-janitor/xdg-data/opencode/opencode.db" \
      'create table session(id int); create table message(id int); create table part(id int);
       insert into session values(1); insert into message values(1); insert into part values(1);' >/dev/null
    chmod 600 "$R/host/.local/state/the-janitor/xdg-data/opencode/opencode.db"
    printf 'ERROR line\n' >"$R/host/.local/state/the-janitor/xdg-data/opencode/log/opencode.log"
    chmod 600 "$R/host/.local/state/the-janitor/xdg-data/opencode/log/opencode.log"
    printf '{"schema_version":1,"custodian":"the-janitor"}\n' >"$R/host/.local/state/the-janitor/tac-daybreak-blue.json"
    chmod 600 "$R/host/.local/state/the-janitor/tac-daybreak-blue.json"
  }
  write_data() {
    cat >"$R/census.tsv" <<'EOF'
# scan	$HOME/.config/the-janitor
# scan	$STATE
# scan	$STATE/xdg-data/opencode
$HOME/.config/the-janitor/op.env	asset	file	600	env-ref file
$HOME/.local/bin/the-janitor	asset	exec	755	CLI
$HOME/.local/state/tac/daybreak-blue-access.json	asset	file	600	receipt
$STATE/client.lock	runtime	file	600	flock file
$STATE/tac-daybreak-blue.json	runtime	file	600	custody
$STATE/xdg-data	runtime	dir	700	XDG_DATA_HOME
$STATE/xdg-data/opencode	runtime	dir	700	opencode root
$STATE/xdg-data/opencode/opencode.db	runtime	file	600	transcripts
$STATE/xdg-data/opencode/log	runtime	dir	700	log dir
$STATE/xdg-data/opencode/log/opencode.log	runtime	file	600	handler log
EOF
    cat >"$R/shapes.tsv" <<'EOF'
$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db	sqlite	magic	SQLite format 3	-
$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db	sqlite	mode	600	-
$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db	sqlite	tables_min	3	-
$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db	sqlite	tables_required	session,message,part	-
$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db	sqlite	rows_min	part:1	-
$HOME/.local/state/the-janitor/xdg-data/opencode/log/opencode.log	log	mode	600	-
$HOME/.local/state/the-janitor/xdg-data/opencode/log/opencode.log	log	size_min	1	-
$HOME/.local/state/the-janitor/tac-daybreak-blue.json	json	keys	schema_version,custodian	-
EOF
    printf '$HOME/.config/the-janitor/op.env\t600\t1\t-\n' >"$R/baseline.tsv"
  }
  run_case() { # name expected-exit expected-token
    local name="$1" want_exit="$2" token="$3" out rc
    set +e
    out="$(census_verify)"; rc=$?
    set -e
    cases=$((cases + 1))
    if [[ "$rc" != "$want_exit" ]] || { [[ -n "$token" ]] && [[ "$out" != *"$token"* ]]; }; then
      failures=$((failures + 1))
      printf 'bad-case %02d %-34s want exit=%s token=%s got exit=%s\n' "$cases" "$name" "$want_exit" "${token:--}" "$rc"
      printf '%s\n' "$out" | sed 's/^/    | /'
    else
      printf 'ok-case  %02d %-34s exit=%s %s\n' "$cases" "$name" "$rc" "$token"
    fi
  }
  census_verify() {
    bash "${BASH_SOURCE[0]}" verify --root "$R/host" --census "$R/census.tsv" \
      --shapes "$R/shapes.tsv" --baseline "$R/baseline.tsv" 2>&1 || return $?
  }

  printf 'SELFTEST surfaces+shapes\n'
  build_tree; write_data; run_case clean 0 'SURFACE OK'
  build_tree; write_data; chmod 644 "$R/host/.config/the-janitor/op.env"; run_case mode-drift 1 'SURFACE DIVERGED'
  build_tree; write_data; rm "$R/host/.local/bin/the-janitor"; run_case asset-gone 1 'SURFACE GONE'
  build_tree; write_data; rm "$R/host/.local/state/the-janitor/xdg-data/opencode/log/opencode.log"; run_case runtime-absent 0 'SHAPE ABSENT'
  build_tree; write_data; printf 'x\n' >"$R/host/.local/state/the-janitor/session-id"; run_case undeclared-file 1 'SURFACE UNLISTED'
  build_tree; write_data; printf '$HOME/.config/the-janitor/op.env\t644\t1\t-\n' >"$R/baseline.tsv"; run_case crosscheck-disagree 1 'SURFACE CROSSCHECK'
  build_tree; write_data; ln -sf /etc/hostname "$R/host/.local/bin/the-janitor"; run_case symlink-swap 1 'SURFACE LINK'
  build_tree; write_data; printf 'NOTSQLITE-0000000\n' >"$R/host/.local/state/the-janitor/xdg-data/opencode/opencode.db"; run_case sqlite-magic 1 'SHAPE SHAPE'
  build_tree; write_data; printf 'SQLite format 3X' >"$R/host/.local/state/the-janitor/xdg-data/opencode/opencode.db"; run_case sqlite-magic-prefix-only 1 'SHAPE SHAPE'
  # Fail closed when the shape class cannot be evaluated at all: a CLEAN
  # summary over an unread database is the false-clean class (critic CE3).
  build_tree; write_data; cases=$((cases + 1))
  set +e
  out="$(SQLITE3_BIN="$R/no-such-sqlite3" census_verify)"; rc=$?
  set -e
  if [[ $rc -eq 1 && "$out" == *'SHAPE UNVERIFIED'* && "$out" == *'unverified=3'* ]]; then
    printf 'ok-case  %02d %-34s exit=1 UNVERIFIED, unverified=3\n' "$cases" "sqlite-unavailable"
  else
    failures=$((failures + 1))
    printf 'bad-case %02d %-34s exit=%s\n' "$cases" "sqlite-unavailable" "$rc"
    printf '%s\n' "$out" | sed 's/^/    | /'
  fi
  build_tree; write_data; sqlite3 "$R/host/.local/state/the-janitor/xdg-data/opencode/opencode.db" 'drop table part;' >/dev/null; run_case required-table-gone 1 'missing tables'
  build_tree; write_data; sqlite3 "$R/host/.local/state/the-janitor/xdg-data/opencode/opencode.db" 'delete from part;' >/dev/null; run_case row-floor 1 'rows part 0'
  build_tree; write_data; sed -i '1s/.*/$HOME\/x\tasset\tblob\t600\tnope/' "$R/census.tsv"; run_case malformed-row 2 'bad kind'
  # A fused row (missing newline between two rows) parses as a long note and
  # silently drops the second row — the round-10 L2 wave found exactly that in
  # the shipped state-shape.tsv. Refuse the file instead of evaluating a subset.
  build_tree; write_data; python3 -c "
import sys
p=sys.argv[1]
lines=open(p).read().splitlines()
lines[3]=lines[3]+lines[4]
del lines[4]
open(p,'w').write('\n'.join(lines)+'\n')
" "$R/shapes.tsv"
  cases=$((cases + 1))
  set +e
  out="$(census_verify)"; rc=$?
  set -e
  if [[ $rc -eq 2 && "$out" == *'too many fields'* ]]; then
    printf 'ok-case  %02d %-34s exit=2 fused-row refused\n' "$cases" "fused-shape-row"
  else
    failures=$((failures + 1))
    printf 'bad-case %02d %-34s exit=%s\n' "$cases" "fused-shape-row" "$rc"
    printf '%s\n' "$out" | sed 's/^/    | /'
  fi

  printf 'SELFTEST verbs\n'
  cases=$((cases + 1))
  if ! command -v "$JANITOR" >/dev/null 2>&1; then
    # the two verb cases execute the REAL handler (the probes' whole point is
    # the handler's own behavior, not scratch fixtures); when the substrate is
    # absent the case is recorded as skipped, not failed — a host-state fact
    printf 'skip-case %02d %-34s substrate-absent (handler not on PATH)\n' "$cases" "verbs-sandboxed"
    cases=$((cases + 1))
    printf 'skip-case %02d %-34s substrate-absent (handler not on PATH)\n' "$cases" "verbs-break-injection"
  else
  set +e
  out="$(bash "${BASH_SOURCE[0]}" --verbs --verb-root "$R/verbs" 2>&1)"; rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    failures=$((failures + 1)); printf 'bad-case %02d %-34s exit=%s\n' "$cases" "verbs-sandboxed" "$rc"
    printf '%s\n' "$out" | sed 's/^/    | /'
  else
    printf 'ok-case  %02d %-34s exit=0\n' "$cases" "verbs-sandboxed"
  fi
  cases=$((cases + 1))
  set +e
  out="$(CENSUS_BREAK=cdp-ensure-scratch bash "${BASH_SOURCE[0]}" --verbs --verb-root "$R/verbs2" 2>&1)"; rc=$?
  set -e
  if [[ $rc -eq 1 && "$out" == *"PROBE cdp-ensure-scratch: FAIL"* ]]; then
    printf 'ok-case  %02d %-34s exit=1 injected-failure-detected\n' "$cases" "verbs-break-injection"
  else
    failures=$((failures + 1))
    printf 'bad-case %02d %-34s exit=%s\n' "$cases" "verbs-break-injection" "$rc"
  fi
  fi

  if [[ $failures -eq 0 ]]; then printf 'SELFTEST: PASS (%s cases)\n' "$cases"; exit 0; fi
  printf 'SELFTEST: FAIL (%s/%s cases)\n' "$failures" "$cases"; exit 1
}

# --- dispatch --------------------------------------------------------------

case "$MODE" in
  verify)
    load_census
    verify_surfaces
    verify_unlisted
    verify_shapes
    if [[ $FAILED -eq 0 ]]; then
      printf 'SURFACE_CENSUS: CLEAN (assets=%s runtime=%s scanned=%s ok=%s absent=%s skipped=%s)\n' \
        "$(printf '%s\n' "${ROW_CLASS[@]}" | grep -c '^asset$')" \
        "$(printf '%s\n' "${ROW_CLASS[@]}" | grep -c '^runtime$')" \
        "${#SCAN_DIR[@]}" "$N_OK" "$N_ABSENT" "$N_SKIP"
      exit 0
    fi
    printf 'SURFACE_CENSUS: DRIFT (diverged=%s gone=%s link=%s unlisted=%s crosscheck=%s shape=%s unverified=%s ok=%s absent=%s skipped=%s)\n' \
      "$N_DIVERGED" "$N_GONE" "$N_LINK" "$N_UNLISTED" "$N_CROSSCHECK" "$N_SHAPE" "$N_UNVERIFIED" "$N_OK" "$N_ABSENT" "$N_SKIP"
    exit 1
    ;;
  verbs)
    verbs
    if [[ $PROBE_FAILS -eq 0 && $PROBE_PASSES -gt 0 ]]; then
      printf 'SURFACE_CENSUS_VERBS: CLEAN (pass=%s skip=%s)\n' "$PROBE_PASSES" "$PROBE_SKIPS"; exit 0
    fi
    if [[ $PROBE_FAILS -eq 0 ]]; then
      # fail closed: a summary that passes zero probes is not evidence. The
      # shapes path already states this doctrine (a required read that cannot
      # happen is `UNVERIFIED`, not `SKIP`); round-11 critic CE1 proved the
      # verbs path could print `CLEAN (pass=0 skip=10)` with exit 0, which a
      # claim row could then accept.
      printf 'SURFACE_CENSUS_VERBS: DEGRADED (pass=0 skip=%s)\n' "$PROBE_SKIPS"
      exit 1
    fi
    printf 'SURFACE_CENSUS_VERBS: FAILURES (fail=%s pass=%s skip=%s)\n' "$PROBE_FAILS" "$PROBE_PASSES" "$PROBE_SKIPS"
    exit 1
    ;;
  selftest) selftest ;;
esac