#!/usr/bin/env bash
# sources-census.sh — registry gate for `corpus/SOURCES.md` (round 21, C3 capability)
#
# WHAT IT MEASURES. `corpus/SOURCES.md` (fleet contract v1, kaika 2026-10-19,
# `fleet-ledger/.ufo/waves/kaika/SOURCES-CONTRACT-v1.md`) is where the lane's
# knowledge comes from; `corpus/knowledge/*.md` is what was admitted from it.
# The contract ships its census as seven shell one-liners that a reviewer runs
# by hand. This gate runs them — the awk programs are embedded VERBATIM from the
# contract's §Census, executed from the lane root exactly as the contract says —
# and adds the cross-file checks the one-liners cannot make: that a `mined` row
# is actually cited by the file it names, and that a sourced entry cites only
# registered, mined rows that name it back. Read-only: no network, no `op`, no
# write anywhere (the selftest writes only under its own `mktemp -d`).
#
#   bash corpus/sources-census.sh                    # verify the lane tree
#   bash corpus/sources-census.sh verify --root DIR  # verify DIR (fixtures)
#   bash corpus/sources-census.sh --selftest         # prove every finding id
#   bash corpus/sources-census.sh -h                 # this header
#
# Root is the repo dir of this script (`corpus/..`) unless `--root` names one.
#
# FINDINGS (one `FINDING <ID> <detail>` line each, stdout, before the verdict):
#   contract v1 census (verbatim awk):
#     SC_ZERO            no registry rows
#     SC_MALFORMED       a row whose 11-column shape is broken (NF!=13); and
#                        (this gate) any `|` line in `## Registry` — up to the
#                        next `## ` heading — that is not the header row (first
#                        cell `id`), not the `|---|` separator, and not a row
#                        whose id cell matches the contract pattern at column 1
#                        (a leading space, `S17`, `s017` are all malformed, not
#                        silently uncounted)
#     SC_DUP             an id used by more than one row
#     SC_ENUM            tier/status/kind outside the contract enums
#     SC_INFLATION       tier A on a `community` row
#     SC_USEDBY_MISSING  a mined row's used-by path does not exist; and (this
#                        gate) a used-by path that is not exactly
#                        `corpus/(knowledge|lessons)/<name>.md` — absolute and
#                        `../` paths fail even when they exist
#   cross-file (this gate):
#     SC_USEDBY_NOCITE   a mined row's used-by file does not carry the row id on
#                        its `source:` line (or the path is not a regular file)
#     SC_MINED_UNUSED    a mined row with used-by `—`, `-` or empty
#     SC_REJECT_SHAPE    a rejected row whose teaches does not start with
#                        `REJECTED:` or lacks `flip:`
#     SC_SECTIONS        a missing `## Registry`, `## Paths`, `## Search log` or
#                        `## Leads (unopened)` heading (exact line)
#     SC_ENTRY_HEADER    a sourced entry missing `verified-at:` or `recheck:`, or
#                        carrying more than one column-1 `source:` line
#     SC_ENTRY_CITE      a sourced entry whose `source:` line carries no S id, or
#                        an S id that is not a well-formed registry row, not
#                        `mined`, or whose used-by does not list that entry; or
#                        whose cited ids include no tier A or B row (contract:
#                        tier C is a lead, never sole support)
#     SC_CREDENTIAL      credential-shaped text in SOURCES.md or a sourced entry;
#                        prints `file:line` only, never the matched bytes
#
# ENTRIES. An entry is SOURCED when a line starts with `source:` (lower case,
# column 1); exactly one such line is allowed. Its source field is that
# `source:` line plus any directly following lines that start with whitespace
# (wrapped continuation). Entries with no column-1 `source:` line are LEGACY
# (the pre-registry `Source:`/`Source basis:` prose): counted as `legacy=N`.
# STATED BOUND: legacy entries are outside every check of this gate — header,
# cite, tier and the credential scan included — until they gain a column-1
# `source:` line; the lane's own transcript/claim gates own them. Used-by paths
# are matched as the exact repo-relative path `corpus/knowledge/<name>.md`.
#
# CREDENTIAL needles (assembled from fragments below so this file never carries
# a literal the fleet pre-commit sweep matches): the 1Password secret-reference
# scheme, PEM private-key armour, GitHub classic PAT, AWS access-key id, Slack
# token prefixes, age secret keys, and Vault/OpenBao service/batch/recovery
# tokens.
#
# VERDICT (last line, always):
#   SOURCES_CENSUS: CLEAN (rows=N A=a B=b C=c queued=q mined=m rejected=r entries_sourced=e legacy=l)  exit 0
#   SOURCES_CENSUS: FAILED (findings=K rows=N)                                                          exit 1
#   SOURCES_CENSUS: SETUP (<reason>)   SOURCES.md or knowledge/ absent/unreadable, bad args           exit 2
#   --selftest: SOURCES_CENSUS_SELFTEST: PASS (N cases) exit 0 | FAIL (N cases, K failed) exit 1
# Nothing is skipped: every check runs on every verify, so there is no
# `skipped=` count to carry (QUALITY.md QM3).
#
# The selftest builds a fixture tree under `mktemp -d` (removed by an EXIT trap),
# runs `verify --root` on one or more mutations per finding id (plus SETUP, a
# clean case and two scope cases), and asserts the exit code, the finding id,
# the findings count and — for the clean cases — the whole verdict line.
# Expectations are literals in the case table, not recomputed from the gate's
# own logic.
set -uo pipefail
export LC_ALL=C

setup() { printf 'SOURCES_CENSUS: SETUP (%s)\n' "$1"; exit 2; }

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || setup "cannot resolve script directory"
SELF="$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")"
ROOT="$SCRIPT_DIR/.."
MODE="verify"

while [[ $# -gt 0 ]]; do
  case "$1" in
    verify) MODE="verify"; shift ;;
    --selftest) MODE="selftest"; shift ;;
    --root) [[ $# -ge 2 ]] || setup "--root needs a directory"; ROOT="$2"; shift 2 ;;
    -h|--help) sed -n '2,/^set -uo pipefail$/p' "$SELF" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) setup "unknown argument: $1" ;;
  esac
done

# --- credential ERE (fragments; see header) ----------------------------------
scheme='op'
CRED_RE="${scheme}://[A-Za-z0-9_-]"
CRED_RE+='|''BEG''IN [A-Z ]*PRI''VATE KEY'
CRED_RE+='|''gh''p_[A-Za-z0-9]{20,}'
CRED_RE+='|''AK''IA[0-9A-Z]{16}'
CRED_RE+='|''xo''x[baprs]-'
CRED_RE+='|''AGE-SEC''RET-KEY-'
CRED_RE+='|''hv''[sbr]\.[A-Za-z0-9_-]{24,}'

FINDINGS=0
finding() { printf 'FINDING %s %s\n' "$1" "$2"; FINDINGS=$((FINDINGS + 1)); }

# First `source:` line plus whitespace-led continuation lines.
src_field() { awk 'f && /^[[:space:]]/ {print; next} f {exit} /^source:/ {f=1; print}' "$1"; }

trim() { local s=$1; s=${s#"${s%%[![:space:]]*}"}; s=${s%"${s##*[![:space:]]}"}; printf '%s' "$s"; }

cred_scan() { # file relpath
  local n
  while IFS= read -r n; do finding SC_CREDENTIAL "$2:$n"; done < <(grep -nE -- "$CRED_RE" "$1" | cut -d: -f1)
}

verify() {
  [[ -d $ROOT ]] || setup "root is not a directory"
  ROOT=$(cd -- "$ROOT" && pwd) || setup "root is not accessible"
  local src="$ROOT/corpus/SOURCES.md" kdir="$ROOT/corpus/knowledge"
  [[ -f $src && -r $src ]] || setup "corpus/SOURCES.md absent or unreadable"
  [[ -d $kdir && -r $kdir && -x $kdir ]] || setup "corpus/knowledge absent or unreadable"

  local rows rc nmal out line w k a b c q m r
  # ---- contract v1 §Census, verbatim, run from the lane root ----
  # rows (spacing-tolerant)
  rows=$(cd -- "$ROOT" || exit 2; grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md); rc=$?
  [[ $rc -le 1 && $rows =~ ^[0-9]+$ ]] || setup "row count failed"
  [[ $rows -gt 0 ]] || finding SC_ZERO "rows=0"
  # malformed rows — 11 columns means NF=13; must print 0
  nmal=$(cd -- "$ROOT" || exit 2; awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF!=13 {n++} END{print n+0}' corpus/SOURCES.md) || setup "malformed count failed"
  out=$(awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF!=13 {i=$2; gsub(/[[:space:]]/,"",i); print "line=" NR " id=" i " nf=" NF}' "$src") || setup "malformed listing failed"
  local listed=0
  while IFS= read -r line; do [[ -n $line ]] || continue; finding SC_MALFORMED "$line"; listed=$((listed + 1)); done <<<"$out"
  [[ $listed -eq $nmal ]] || setup "malformed listing ($listed) disagrees with contract count ($nmal)"
  # tier histogram
  out=$(cd -- "$ROOT" || exit 2; awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {t=$5; gsub(/[[:space:]]/,"",t); n[t]++} END{for(k in n) printf "%s=%d ", k, n[k]; print ""}' corpus/SOURCES.md) || setup "tier histogram failed"
  a=0 b=0 c=0
  for w in $out; do k=${w%%=*}; case $k in A) a=${w#*=} ;; B) b=${w#*=} ;; C) c=${w#*=} ;; esac; done
  # status histogram
  out=$(cd -- "$ROOT" || exit 2; awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {s=$9; gsub(/[[:space:]]/,"",s); n[s]++} END{for(k in n) printf "%s=%d ", k, n[k]; print ""}' corpus/SOURCES.md) || setup "status histogram failed"
  q=0 m=0 r=0
  for w in $out; do k=${w%%=*}; case $k in queued) q=${w#*=} ;; mined) m=${w#*=} ;; rejected) r=${w#*=} ;; esac; done
  # duplicate ids — must print nothing
  out=$(cd -- "$ROOT" || exit 2; awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {i=$2; gsub(/[[:space:]]/,"",i); print i}' corpus/SOURCES.md | sort | uniq -d) || setup "duplicate scan failed"
  while IFS= read -r line; do [[ -n $line ]] && finding SC_DUP "id=$line"; done <<<"$out"
  # enum violations and tier inflation — must print nothing
  out=$(cd -- "$ROOT" || exit 2; awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {i=$2;k=$4;t=$5;s=$9; gsub(/[[:space:]]/,"",i); gsub(/[[:space:]]/,"",k); gsub(/[[:space:]]/,"",t); gsub(/[[:space:]]/,"",s); if (t !~ /^[ABC]$/) print "tier", i, t; if (s !~ /^(queued|mined|rejected)$/) print "status", i, s; if (k !~ /^(spec|docs|paper|code|tool|dataset|talk|book|community|own-work)$/) print "kind", i, k; if (t=="A" && k=="community") print "tier-inflation", i}' corpus/SOURCES.md) || setup "enum scan failed"
  local kind id val
  while read -r kind id val; do
    case $kind in
      tier|status|kind) finding SC_ENUM "$kind id=$id value=$val" ;;
      tier-inflation) finding SC_INFLATION "id=$id" ;;
    esac
  done <<<"$out"
  # mined rows whose used-by paths do not exist — must print nothing
  out=$(cd -- "$ROOT" || exit 2; awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {s=$9; gsub(/[[:space:]]/,"",s); if (s=="mined") {n=split($12, a, /[,;]/); for (j=1;j<=n;j++) {p=a[j]; gsub(/^[[:space:]]+|[[:space:]]+$/,"",p); if (p!="" && p!="—") print p}}}' corpus/SOURCES.md | while read -r p; do [ -e "$p" ] || echo "missing: $p"; done) || setup "used-by existence scan failed"
  while IFS= read -r line; do [[ -n $line ]] && finding SC_USEDBY_MISSING "path=${line#missing: }"; done <<<"$out"

  # ---- cross-file checks ----
  local h
  for h in '## Registry' '## Paths' '## Search log' '## Leads (unopened)'; do
    awk -v h="$h" '{sub(/\r$/,""); sub(/[[:space:]]+$/,"")} $0==h {f=1} END{exit !f}' "$src" || finding SC_SECTIONS "missing=$h"
  done
  # every `|` line inside `## Registry` must be the header, the separator, or a
  # row the contract awk above actually sees (id cell shape at column 1)
  out=$(awk '{sub(/\r$/,"")} /^## /{x=$0; sub(/[[:space:]]+$/,"",x); f=(x=="## Registry"); next} f && /^[[:space:]]*\|/ && $0 !~ /^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && $0 !~ /^\|[[:space:]]*id[[:space:]]*\|/ && $0 !~ /^\|([[:space:]]*:?-+:?[[:space:]]*\|)+[[:space:]]*$/ {print NR}' "$src") || setup "registry row-shape scan failed"
  while IFS= read -r line; do [[ -n $line ]] && finding SC_MALFORMED "line=$line: row id not in contract shape"; done <<<"$out"

  declare -A ST=() UB=() TI=()
  local t u s p parts field tier
  local usedby_re='^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\.md$'
  while IFS=$'\x1f' read -r id s tier t u; do
    [[ -n $id ]] || continue
    ST[$id]=$s; UB[$id]=$u; TI[$id]=$tier
    if [[ $s == rejected ]]; then
      [[ $t == REJECTED:* && $t == *flip:* ]] || finding SC_REJECT_SHAPE "id=$id"
    elif [[ $s == mined ]]; then
      if [[ -z $u || $u == '—' || $u == '-' ]]; then finding SC_MINED_UNUSED "id=$id"; continue; fi
      IFS=',;' read -ra parts <<<"$u"
      for p in "${parts[@]}"; do
        p=$(trim "$p")
        [[ -n $p && $p != '—' ]] || continue
        if [[ ! $p =~ $usedby_re ]]; then finding SC_USEDBY_MISSING "$id: $p not a repo corpus path"; continue; fi
        [[ -e $ROOT/$p ]] || continue # nonexistent in-shape path: contract SC_USEDBY_MISSING above
        if [[ ! -f $ROOT/$p ]]; then finding SC_USEDBY_NOCITE "id=$id path=$p not-a-regular-file"; continue; fi
        field=$(src_field "$ROOT/$p")
        [[ $field =~ (^|[^A-Za-z0-9_])$id([^0-9]|$) ]] || finding SC_USEDBY_NOCITE "id=$id path=$p"
      done
    fi
  done < <(awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {i=$2; s=$9; r=$5; gsub(/[[:space:]]/,"",i); gsub(/[[:space:]]/,"",s); gsub(/[[:space:]]/,"",r); t=$8; u=$12; sub(/^[[:space:]]+/,"",t); sub(/[[:space:]]+$/,"",t); sub(/^[[:space:]]+/,"",u); sub(/[[:space:]]+$/,"",u); printf "%s\037%s\037%s\037%s\037%s\n", i, s, r, t, u}' "$src")

  cred_scan "$src" "corpus/SOURCES.md"

  local f rel sourced=0 legacy=0 ids listed_here nsrc supported
  shopt -s nullglob
  for f in "$kdir"/*.md; do
    rel="corpus/knowledge/${f##*/}"
    if ! grep -q '^source:' "$f"; then legacy=$((legacy + 1)); continue; fi
    sourced=$((sourced + 1))
    grep -q '^verified-at:' "$f" || finding SC_ENTRY_HEADER "entry=$rel missing=verified-at"
    grep -q '^recheck:' "$f" || finding SC_ENTRY_HEADER "entry=$rel missing=recheck"
    nsrc=$(grep -c '^source:' "$f")
    [[ $nsrc -le 1 ]] || finding SC_ENTRY_HEADER "$rel: multiple source: lines"
    field=$(src_field "$f")
    ids=$(grep -oE '\bS[0-9]{3,}\b' <<<"$field" | sort -u)
    [[ -n $ids ]] || finding SC_ENTRY_CITE "entry=$rel no-registry-id"
    supported=0
    for id in $ids; do
      case ${TI[$id]-} in A|B) supported=1 ;; esac
      if [[ ! -v ST[$id] ]]; then finding SC_ENTRY_CITE "entry=$rel id=$id not-a-registry-row"; continue; fi
      if [[ ${ST[$id]} != mined ]]; then finding SC_ENTRY_CITE "entry=$rel id=$id status=${ST[$id]}"; continue; fi
      listed_here=0
      IFS=',;' read -ra parts <<<"${UB[$id]}"
      for p in "${parts[@]}"; do [[ $(trim "$p") == "$rel" ]] && listed_here=1; done
      [[ $listed_here -eq 1 ]] || finding SC_ENTRY_CITE "entry=$rel id=$id used-by-omits-entry"
    done
    [[ -z $ids || $supported -eq 1 ]] || finding SC_ENTRY_CITE "$rel: no tier A/B support (tier C is a lead only)"
    cred_scan "$f" "$rel"
  done
  shopt -u nullglob

  if [[ $FINDINGS -eq 0 ]]; then
    printf 'SOURCES_CENSUS: CLEAN (rows=%d A=%d B=%d C=%d queued=%d mined=%d rejected=%d entries_sourced=%d legacy=%d)\n' \
      "$rows" "$a" "$b" "$c" "$q" "$m" "$r" "$sourced" "$legacy"
    exit 0
  fi
  printf 'SOURCES_CENSUS: FAILED (findings=%d rows=%d)\n' "$FINDINGS" "$rows"
  exit 1
}

# --- selftest ------------------------------------------------------------------
ST_DIR=""
cleanup() { [[ -n $ST_DIR && -d $ST_DIR ]] && rm -rf -- "$ST_DIR"; }

base_fixture() { # dir
  local d=$1
  mkdir -p "$d/corpus/knowledge" "$d/corpus/lessons" || return 1
  cat >"$d/corpus/SOURCES.md" <<'EOF'
# SOURCES — where selftest learns

## Registry

| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |
|---|---|---|---|---|---|---|---|---|---|---|
| S001 | Spec one — https://example.invalid/one | spec | A | topic one | §1, rev 1 | teaches one | mined | 2026-10-19 | 90d | corpus/knowledge/e1.md |
| S002 | Paper two — https://example.invalid/two | paper | B | topic two | §2, 2026-01-01 | teaches two | mined | 2026-10-19 | 180d | corpus/knowledge/e1.md |
| S003 | Forum three — https://example.invalid/three | community | C | topic three | thread 3, 2026-02-02 | lead three | queued | 2026-10-19 | 90d | — |
| S004 | Product four — https://example.invalid/four | docs | B | topic four | page, 2026-03-03 | REJECTED: product page; flip: a primary doc | rejected | 2026-10-19 | on-release | — |

## Paths

- topic — S001 → S002: spec before paper.

## Search log

- one bounded search, identified 4, included 2.

## Leads (unopened)

- a lead.
EOF
  cat >"$d/corpus/knowledge/e1.md" <<'EOF'
# entry one
source: S001 (https://example.invalid/one, §1, rev 1); S002 (https://example.invalid/two, §2, 2026-01-01)
verified-at: 2026-10-19 (opened both)
recheck: 90d — re-open S001 and S002
Reverify: R21-02

Body.
EOF
  printf '# legacy\n\nSource basis: host inspection.\n' >"$d/corpus/knowledge/legacy.md"
}

rep() { printf "%${2}s" '' | tr ' ' "$1"; }
needle() { # k → a credential-shaped string built at runtime
  case $1 in
    0) printf '%s%s%s' 'o' 'p:' '//aa/bb/cc' ;;
    1) printf '%s%s%s' '-----BEG' 'IN RSA PRI' 'VATE KEY-----' ;;
    2) printf '%s%s' 'gh' "p_$(rep a 24)" ;;
    3) printf '%s%s' 'AK' "IA$(rep A 16)" ;;
    4) printf '%s%s' 'xo' 'xb-123' ;;
    5) printf '%s%s' 'AGE-SEC' 'RET-KEY-1QQQ' ;;
    6) printf '%s%s' 'hv' "s.$(rep a 24)" ;;
  esac
}

SRC_F() { printf '%s/corpus/SOURCES.md' "$1"; }
E1_F() { printf '%s/corpus/knowledge/e1.md' "$1"; }
ROW5='| S005 | Doc five — https://example.invalid/five | docs | B | topic five | §5, 2026-04-04 | teaches five | mined | 2026-10-19 | 90d | USEDBY |'
ROW5C='| S005 | Forum five — https://example.invalid/five | community | C | topic five | thread 5, 2026-04-04 | lead five | mined | 2026-10-19 | 90d | corpus/knowledge/e2.md |'

# mutations: each takes the fixture dir; may set ARGS / NEEDLE
m_clean() { :; }
m_continuation() { sed -i 's/^\(source: S001 ([^)]*);\) \(S002 .*\)$/\1\n  \2/' "$(E1_F "$1")"; }
m_zero() { sed -i '/^| S0/d' "$(SRC_F "$1")"; rm -f -- "$(E1_F "$1")"; }
m_malformed() { sed -i '/^| S003 /s/| — |$/| — | extra |/' "$(SRC_F "$1")"; }
m_row_lead_space() { sed -i 's/^| S003 / | S003 /' "$(SRC_F "$1")"; }
m_row_two_digit() { sed -i 's/^| S003 /| S03 /' "$(SRC_F "$1")"; }
m_row_lower() { sed -i 's/^| S003 /| s003 /' "$(SRC_F "$1")"; }
m_dup() { sed -i '/^| S003 /p' "$(SRC_F "$1")"; }
m_enum_tier() { sed -i '/^| S003 /s/| community | C |/| community | D |/' "$(SRC_F "$1")"; }
m_enum_status() { sed -i '/^| S003 /s/| queued |/| pending |/' "$(SRC_F "$1")"; }
m_enum_kind() { sed -i '/^| S003 /s/| community |/| blog |/' "$(SRC_F "$1")"; }
m_inflation() { sed -i '/^| S003 /s/| C |/| A |/' "$(SRC_F "$1")"; }
m_usedby_missing() { sed -i '/^| S002 /s#| corpus/knowledge/e1.md |$#| corpus/knowledge/e1.md, corpus/knowledge/ghost.md |#' "$(SRC_F "$1")"; }
m_usedby_abs() { sed -i "/^| S002 /s#| corpus/knowledge/e1.md |\$#| corpus/knowledge/e1.md, $1/corpus/knowledge/e1.md |#" "$(SRC_F "$1")"; }
m_usedby_dotdot() { sed -i '/^| S002 /s#| corpus/knowledge/e1.md |$#| corpus/knowledge/e1.md, ../base/corpus/knowledge/e1.md |#' "$(SRC_F "$1")"; }
m_usedby_nocite() {
  printf '# lesson\n\nno source line.\n' >"$1/corpus/lessons/l1.md"
  sed -i '/^| S002 /s#| corpus/knowledge/e1.md |$#| corpus/knowledge/e1.md, corpus/lessons/l1.md |#' "$(SRC_F "$1")"
}
m_unused_dash() { sed -i "/^| S004 /a ${ROW5/USEDBY/—}" "$(SRC_F "$1")"; }
m_unused_empty() { sed -i "/^| S004 /a ${ROW5/USEDBY/}" "$(SRC_F "$1")"; }
m_reject_prefix() { sed -i '/^| S004 /s/REJECTED: //' "$(SRC_F "$1")"; }
m_reject_flip() { sed -i '/^| S004 /s/; flip: a primary doc//' "$(SRC_F "$1")"; }
m_sec_registry() { sed -i '/^## Registry$/d' "$(SRC_F "$1")"; }
m_sec_paths() { sed -i '/^## Paths$/d' "$(SRC_F "$1")"; }
m_sec_search() { sed -i '/^## Search log$/d' "$(SRC_F "$1")"; }
m_sec_leads() { sed -i '/^## Leads (unopened)$/d' "$(SRC_F "$1")"; }
m_hdr_verified() { sed -i '/^verified-at:/d' "$(E1_F "$1")"; }
m_hdr_recheck() { sed -i '/^recheck:/d' "$(E1_F "$1")"; }
m_hdr_two_source() { printf 'source: S099 (https://example.invalid/x, §9, 2026-05-05)\n' >>"$(E1_F "$1")"; }
m_cite_unknown() { sed -i '/^source:/s#$#; S009 (https://example.invalid/nine, §9, 2026-05-05)#' "$(E1_F "$1")"; }
m_cite_queued() { sed -i '/^source:/s#$#; S003 (https://example.invalid/three, thread 3, 2026-02-02)#' "$(E1_F "$1")"; }
m_cite_usedby() {
  printf '# lesson\nsource: S001 (https://example.invalid/one, §1, rev 1)\n' >"$1/corpus/lessons/l1.md"
  sed -i '/^| S001 /s#| corpus/knowledge/e1.md |$#| corpus/lessons/l1.md |#' "$(SRC_F "$1")"
}
m_cite_noid() { sed -i 's#^source:.*$#source: https://example.invalid/one (§1, rev 1)#' "$(E1_F "$1")"; }
m_cite_tier_c() {
  sed -i "/^| S004 /a $ROW5C" "$(SRC_F "$1")"
  printf '# entry two\nsource: S005 (https://example.invalid/five, thread 5, 2026-04-04)\nverified-at: 2026-10-19\nrecheck: 90d\n' >"$1/corpus/knowledge/e2.md"
}
m_cred_src() { NEEDLE=$(needle "$2"); printf -- '- note %s\n' "$NEEDLE" >>"$(SRC_F "$1")"; }
m_cred_entry() { NEEDLE=$(needle 2); printf 'body %s\n' "$NEEDLE" >>"$(E1_F "$1")"; }
m_cred_legacy() { NEEDLE=$(needle 3); printf 'body %s\n' "$NEEDLE" >>"$1/corpus/knowledge/legacy.md"; }
m_setup_nosrc() { rm -f -- "$(SRC_F "$1")"; }
m_setup_srcdir() { rm -f -- "$(SRC_F "$1")"; mkdir -- "$(SRC_F "$1")"; }
m_setup_noknow() { rm -rf -- "$1/corpus/knowledge"; }
m_setup_badarg() { ARGS=(verify --root "$1" --bogus); }
m_setup_noroot() { ARGS=(verify --root "$1/absent"); }
m_setup_rootnoarg() { ARGS=(verify --root); }

selftest() {
  ST_DIR=$(mktemp -d) || setup "mktemp failed"
  trap cleanup EXIT
  base_fixture "$ST_DIR/base" || setup "fixture build failed"
  local CLEAN_LINE='SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1)'
  # name | mutation | arg | exit | expected id (CLEAN / SETUP / finding id) | findings
  local -a CASES=(
    "clean|m_clean||0|CLEAN|0"
    "continuation-line|m_continuation||0|CLEAN|0"
    "legacy-not-scanned|m_cred_legacy||0|CLEAN|0"
    "zero|m_zero||1|SC_ZERO|1"
    "malformed|m_malformed||1|SC_MALFORMED|1"
    "row-leading-space|m_row_lead_space||1|SC_MALFORMED|1"
    "row-two-digit-id|m_row_two_digit||1|SC_MALFORMED|1"
    "row-lowercase-id|m_row_lower||1|SC_MALFORMED|1"
    "dup|m_dup||1|SC_DUP|1"
    "enum-tier|m_enum_tier||1|SC_ENUM|1"
    "enum-status|m_enum_status||1|SC_ENUM|1"
    "enum-kind|m_enum_kind||1|SC_ENUM|1"
    "inflation|m_inflation||1|SC_INFLATION|1"
    "usedby-missing|m_usedby_missing||1|SC_USEDBY_MISSING|1"
    "usedby-absolute|m_usedby_abs||1|SC_USEDBY_MISSING|1"
    "usedby-dotdot|m_usedby_dotdot||1|SC_USEDBY_MISSING|1"
    "usedby-nocite|m_usedby_nocite||1|SC_USEDBY_NOCITE|1"
    "mined-unused-dash|m_unused_dash||1|SC_MINED_UNUSED|1"
    "mined-unused-empty|m_unused_empty||1|SC_MINED_UNUSED|1"
    "reject-prefix|m_reject_prefix||1|SC_REJECT_SHAPE|1"
    "reject-flip|m_reject_flip||1|SC_REJECT_SHAPE|1"
    "sections-registry|m_sec_registry||1|SC_SECTIONS|1"
    "sections-paths|m_sec_paths||1|SC_SECTIONS|1"
    "sections-search|m_sec_search||1|SC_SECTIONS|1"
    "sections-leads|m_sec_leads||1|SC_SECTIONS|1"
    "entry-verified-at|m_hdr_verified||1|SC_ENTRY_HEADER|1"
    "entry-recheck|m_hdr_recheck||1|SC_ENTRY_HEADER|1"
    "entry-two-source|m_hdr_two_source||1|SC_ENTRY_HEADER|1"
    "cite-unknown|m_cite_unknown||1|SC_ENTRY_CITE|1"
    "cite-not-mined|m_cite_queued||1|SC_ENTRY_CITE|1"
    "cite-usedby-omits|m_cite_usedby||1|SC_ENTRY_CITE|1"
    "cite-no-id|m_cite_noid||1|SC_ENTRY_CITE|3"
    "cite-tier-c-sole|m_cite_tier_c||1|SC_ENTRY_CITE|1"
    "cred-scheme|m_cred_src|0|1|SC_CREDENTIAL|1"
    "cred-pem|m_cred_src|1|1|SC_CREDENTIAL|1"
    "cred-gh|m_cred_src|2|1|SC_CREDENTIAL|1"
    "cred-aws|m_cred_src|3|1|SC_CREDENTIAL|1"
    "cred-slack|m_cred_src|4|1|SC_CREDENTIAL|1"
    "cred-age|m_cred_src|5|1|SC_CREDENTIAL|1"
    "cred-vault|m_cred_src|6|1|SC_CREDENTIAL|1"
    "cred-entry|m_cred_entry||1|SC_CREDENTIAL|1"
    "setup-no-sources|m_setup_nosrc||2|SETUP|-"
    "setup-sources-dir|m_setup_srcdir||2|SETUP|-"
    "setup-no-knowledge|m_setup_noknow||2|SETUP|-"
    "setup-bad-arg|m_setup_badarg||2|SETUP|-"
    "setup-root-absent|m_setup_noroot||2|SETUP|-"
    "setup-root-noarg|m_setup_rootnoarg||2|SETUP|-"
  )
  local spec name fn arg xe xid xn d out rc last ok cases=0 failed=0
  for spec in "${CASES[@]}"; do
    IFS='|' read -r name fn arg xe xid xn <<<"$spec"
    cases=$((cases + 1)); ok=1
    d="$ST_DIR/case-$name"
    cp -R -- "$ST_DIR/base" "$d" || setup "fixture copy failed"
    ARGS=(verify --root "$d"); NEEDLE=""
    "$fn" "$d" "$arg"
    # a mutation that leaves the fixture byte-identical proves nothing (QM9)
    case $fn in m_clean|m_setup_badarg|m_setup_rootnoarg|m_setup_noroot) ;;
      *) if diff -rq -- "$ST_DIR/base" "$d" >/dev/null 2>&1; then ok=0; printf 'case %s: mutation inert\n' "$name"; fi ;;
    esac
    out=$(bash "$SELF" "${ARGS[@]}" 2>&1); rc=$?
    last=${out##*$'\n'}
    [[ $rc == "$xe" ]] || ok=0
    case $xid in
      CLEAN) [[ $last == "$CLEAN_LINE" ]] || ok=0 ;;
      SETUP) [[ $last == 'SOURCES_CENSUS: SETUP ('*')' ]] || ok=0 ;;
      *)
        grep -q "^FINDING $xid " <<<"$out" || ok=0
        [[ $last == "SOURCES_CENSUS: FAILED (findings=$xn rows="*')' ]] || ok=0 ;;
    esac
    if [[ -n $NEEDLE ]] && grep -qF -- "$NEEDLE" <<<"$out"; then ok=0; fi
    if [[ $ok -eq 1 ]]; then
      printf 'case %s: ok (exit %s, %s)\n' "$name" "$rc" "$xid"
    else
      failed=$((failed + 1))
      printf 'case %s: FAIL (exit %s want %s; want %s findings=%s; last=%s)\n' "$name" "$rc" "$xe" "$xid" "$xn" "$last"
    fi
  done
  if [[ $failed -eq 0 ]]; then printf 'SOURCES_CENSUS_SELFTEST: PASS (%d cases)\n' "$cases"; exit 0; fi
  printf 'SOURCES_CENSUS_SELFTEST: FAIL (%d cases, %d failed)\n' "$cases" "$failed"; exit 1
}

case $MODE in
  verify) verify ;;
  selftest) selftest ;;
esac
