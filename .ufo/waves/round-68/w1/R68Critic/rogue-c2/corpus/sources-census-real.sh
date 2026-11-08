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
#                        its `source:` line or its `cites:` line (round 55)
#                        (or the path is not a regular file)
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
#     SC_BODY_CITE       (round 55) a knowledge entry (`corpus/knowledge/*.md`
#                        only; lessons are not scanned) — sourced or legacy — whose text
#                        names a registry id that is on neither its `source:`
#                        line nor its `cites:` line; or a `cites:` id that is not
#                        a registry row, or whose row's used-by does not list
#                        the entry; or more than one column-1 `cites:` line.
#                        `cites:` (lower case, column 1, at most one, wrapped
#                        continuation like `source:`) records the registry ids an
#                        entry names outside its support line: cross-references,
#                        later-section sources, and every id a legacy entry
#                        names. It does not make an entry sourced. Ids are
#                        matched as `S` + 3 or more digits not preceded by a
#                        letter, digit or `_` and not followed by a digit.
#     SC_CREDENTIAL      credential-shaped text in SOURCES.md or a sourced entry;
#                        prints `file:line` only, never the matched bytes
#     SC_FETCH           fetch provenance (round 23, routed D7): every registry
#                        row needs an in-row `Fetch sha256:` or at least one
#                        `corpus/source-fetches.tsv` row. A provenance row must
#                        match its registry id, status, exact registered URL and
#                        the sha256 of its registry identity (id, status, URL);
#                        it declares request profile, final URL,
#                        HTTP status, representation, digest, decoded-byte count,
#                        quote normalization, normalized digest and location.
#                        A moving-ref URL needs a 40-hex revision. Captures are
#                        point attestations: no cross-capture equality is
#                        enforced, only one provenance row per id.
#                        Round 24 (routed D5): in-row `Fetch sha256:` digests
#                        are exempt from the capture requirement ONLY for the
#                        historical set S001-S016; any later row with an in-row
#                        pin is SC_INROW `inrow-pin-not-historical` and still
#                        needs a capture row. Every in-row pin needs exactly one
#                        corpus/inrow-pins.tsv row (id, in-row digest, capture
#                        date, verdict, note) whose verdict the census RECOMPUTES
#                        from that id's capture: reproduces-raw (capture sha256 =
#                        pin), reproduces-normalized (normalized sha256 = pin) or
#                        non-reproducing. A missing, duplicate, stale-dated or
#                        disagreeing classification is SC_INROW.
#                        request profile curl-fsSL-compressed-v1 is the command
#                        in the round-23 lesson; decoded-http-body-v1 means
#                        Content-Encoding removed by curl. The quote/page
#                        normalization rendered-text-v1 is declared ONCE, in
#                        corpus/rendered-text-v1.py (round 24, routed D6); this
#                        file does not restate it. A provenance digest
#                        is a point attestation, not a drift pin.
#     SC_INROW           historical in-row pin classification (round 24, above)
#     SC_CAPTURE         (round 67) a fetch row whose location is capture-path-
#                        shaped does not read through to its declared body:
#                          capture-outside-root  absolute location, or a
#                                                repo-relative one whose
#                                                canonical path (symlinks
#                                                followed) leaves the root
#                          capture-missing       no regular file at that path
#                          capture-digest-mismatch  raw sha256 != col 10
#                          capture-bytes-mismatch   size != col 11
#                          quote-not-located     col 13 does not locate under
#                                                col 14 normalization on a row
#                                                whose bytes otherwise bind
#                        printed as `FINDING SC_CAPTURE id=<S-id> <reason>`.
#                        One finding per defect class: a body truncated by one
#                        byte fails both the byte and the digest check, so it
#                        prints both reasons.
#
# ENTRIES. An entry is SOURCED when a line starts with `source:` (lower case,
# column 1); exactly one such line is allowed. Its source field is that
# `source:` line plus any directly following lines that start with whitespace
# (wrapped continuation). Entries with no column-1 `source:` line are LEGACY
# (the pre-registry `Source:`/`Source basis:` prose): counted as `legacy=N`.
# STATED BOUND: legacy entries are outside the header, cite, tier and
# credential checks of this gate until they gain a column-1 `source:` line (the
# lane's own transcript/claim gates own them); since round 55 SC_BODY_CITE does
# reach them (every registry id a legacy entry names must be on its `cites:`
# line). Lessons are reached only through used-by (SC_USEDBY_NOCITE). Used-by paths
# are matched as the exact repo-relative path `corpus/knowledge/<name>.md`.
#
# CREDENTIAL needles (assembled from fragments below so this file never carries
# a literal the fleet pre-commit sweep matches): the 1Password secret-reference
# scheme, PEM private-key armour, GitHub classic PAT, AWS access-key id, Slack
# token prefixes, age secret keys, and Vault/OpenBao service/batch/recovery
# tokens.
#
# CAPTURE READ-THROUGH (round 67, C1; QUALITY.md QM92-QM94). A location is
# CAPTURE-PATH-SHAPED when column 16 contains `/` and is either repo-relative
# (`^[A-Za-z0-9._][A-Za-z0-9._/-]*$`) or absolute (`^/` plus that shape; always
# a violation). Every capture-shaped row is READ: the path must canonicalize
# (realpath, symlinks followed) inside the lane root and name a regular file
# whose raw sha256 equals col 10 and whose byte count equals col 11; a row
# bound by those checks must locate its col-13 quote under the col-14
# normalization (rendered-text-v1 via `python3 corpus/rendered-text-v1.py
# locate FILE QUOTE`; raw-literal-v1 by literal substring; count >= 1). Prose
# locations (anything else, including words that match the path shape without
# a `/`) are counted and never read. Immediately before every verdict the gate
# prints
#   SOURCES_CAPTURES: CLEAN (path_rows=N bound=N located=N prose=N)
# or, when any SC_CAPTURE finding exists,
#   SOURCES_CAPTURES: FAILED (defects=N path_rows=N bound=N located=N prose=N)
# and the verdict is FAILED (exit 1). `bound` counts capture-shaped rows that
# exist inside the root with matching digest and byte count; `located` counts
# bound rows whose quote locates. Rows whose col-16 value is not 16-column
# well-formed are outside the summary (the SC_FETCH shape check owns them).
# CEILING: the binding is to the bytes the row names, not to the origin URL.
# A body rewritten together with its row — file bytes replaced and col 10,
# col 11 and col 13 updated coherently — still passes. There is no network and
# no second witness here: the gate catches a row that drifts from its declared
# body, not a body that drifted from the page it once held.
#
# VERDICT (last line, always):
#   SOURCES_CENSUS: CLEAN (rows=N A=a B=b C=c queued=q mined=m rejected=r entries_sourced=e legacy=l captures=k inrow=i inrow_only=o inrow_nonreproducing=n)  exit 0
#   SOURCES_CENSUS: FAILED (findings=K rows=N)                                                          exit 1
#   SOURCES_CENSUS: SETUP (<reason>)   SOURCES.md or knowledge/ absent/unreadable, bad args           exit 2
#   --selftest: SOURCES_CENSUS_SELFTEST: PASS (N cases) exit 0 | FAIL (N cases, K failed) exit 1
# Nothing is skipped: every check runs on every verify, so there is no
# `skipped=` count to carry (QUALITY.md QM3).
#
# The selftest builds a fixture tree under `mktemp -d` (removed by an EXIT trap),
# runs `verify --root` on one or more mutations per finding id (plus SETUP, a
# clean case and two scope cases), and asserts the exit code, the finding id and
# reason, the findings count, the capture summary line and its stage relations,
# and — for the clean cases — the whole verdict line. Round 67 adds one case per
# SC_CAPTURE reason (digest, bytes, missing, outside-root via absolute, outside-
# root via `..`, outside-root via symlink, quote-not-located), a bound control,
# a prose-skip control and a declared-bytes control.
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
# Round 55: first `cites:` line plus whitespace-led continuation lines.
cites_field() { awk 'f && /^[[:space:]]/ {print; next} f {exit} /^cites:/ {f=1; print}' "$1"; }
# Round 55: every registry-id-shaped token in a file, one per line, unique.
body_ids() { grep -oE '(^|[^A-Za-z0-9_])S[0-9]{3,}' "$1" | grep -oE 'S[0-9]+$' | sort -u; }

trim() { local s=$1; s=${s#"${s%%[![:space:]]*}"}; s=${s%"${s##*[![:space:]]}"}; printf '%s' "$s"; }

cred_scan() { # file relpath
  local n
  while IFS= read -r n; do finding SC_CREDENTIAL "$2:$n"; done < <(grep -nE -- "$CRED_RE" "$1" | cut -d: -f1)
}

# --- capture read-through (round 67, C1; header "CAPTURE READ-THROUGH") -----
# Counters are per verify() call; CAP_ROOT and CAP_NORM are set there.
CAP_PATH=0 CAP_BOUND=0 CAP_LOCATED=0 CAP_PROSE=0 CAP_DEFECTS=0
CAP_ROOT=""
CAP_NORM=""

cap_is_shaped() { # loc → 0 when the location is capture-path-shaped
  local loc=$1
  [[ $loc == */* ]] || return 1
  [[ $loc =~ ^[A-Za-z0-9._][A-Za-z0-9._/-]*$ ]] && return 0
  [[ $loc =~ ^/[A-Za-z0-9._][A-Za-z0-9._/-]*$ ]]
}

cap_locate() { # file quote norm → 0 when the quote locates at least once
  local file=$1 quote=$2 norm=$3 out rc n
  case $norm in
    rendered-text-v1)
      [[ -n $CAP_NORM && -f $CAP_NORM ]] || setup "rendered-text-v1.py absent"
      out=$(python3 "$CAP_NORM" locate "$file" "$quote" 2>/dev/null); rc=$?
      [[ $rc -eq 1 ]] && return 1
      [[ $rc -eq 0 ]] || setup "rendered-text-v1 locate failed (rc=$rc)"
      [[ $out == 'RENDERED_TEXT_V1_LOCATE: count='* ]] || setup "rendered-text-v1 output unexpected"
      n=${out##*count=}
      [[ $n =~ ^[0-9]+$ ]] || setup "rendered-text-v1 count unparsable"
      [[ $n -ge 1 ]]
      ;;
    raw-literal-v1) grep -qF -e "$quote" -- "$file" ;;
    *) return 1 ;; # undeclared normalization already fails SC_FETCH; fail closed here
  esac
}

cap_row() { # id sha bytes quote norm loc
  local id=$1 sha=$2 bytes=$3 quote=$4 norm=$5 loc=$6
  local rp size got bad=0 q
  if ! cap_is_shaped "$loc"; then CAP_PROSE=$((CAP_PROSE + 1)); return 0; fi
  CAP_PATH=$((CAP_PATH + 1))
  # absolute locations never satisfy "repo-relative", whatever they name
  if [[ $loc == /* ]]; then
    finding SC_CAPTURE "id=$id capture-outside-root"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); return 0
  fi
  # canonicalize (symlinks followed; missing components allowed so that a `..`
  # escape is classified before its target's existence matters)
  rp=$(realpath -m -- "$CAP_ROOT/$loc" 2>/dev/null) || rp=""
  if [[ -z $rp || ( $rp != "$CAP_ROOT" && $rp != "$CAP_ROOT"/* ) ]]; then
    finding SC_CAPTURE "id=$id capture-outside-root"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); return 0
  fi
  if [[ ! -e $CAP_ROOT/$loc || ! -f $CAP_ROOT/$loc ]]; then
    finding SC_CAPTURE "id=$id capture-missing"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); return 0
  fi
  size=$(stat -Lc %s -- "$CAP_ROOT/$loc" 2>/dev/null) || size=""
  got=$(sha256sum -- "$CAP_ROOT/$loc" 2>/dev/null); got=${got%% *}
  if [[ -z $size || $size != "$bytes" ]]; then
    finding SC_CAPTURE "id=$id capture-bytes-mismatch"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); bad=1
  fi
  if [[ $got != "$sha" ]]; then
    finding SC_CAPTURE "id=$id capture-digest-mismatch"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); bad=1
  fi
  [[ $bad -eq 0 ]] || return 0
  CAP_BOUND=$((CAP_BOUND + 1))
  q=$quote; q=${q//[[:space:]]/}
  if [[ -z $q ]] || ! cap_locate "$CAP_ROOT/$loc" "$quote" "$norm"; then
    finding SC_CAPTURE "id=$id quote-not-located"; CAP_DEFECTS=$((CAP_DEFECTS + 1)); return 0
  fi
  CAP_LOCATED=$((CAP_LOCATED + 1))
}

verify() {
  [[ -d $ROOT ]] || setup "root is not a directory"
  ROOT=$(cd -- "$ROOT" && pwd) || setup "root is not accessible"
  local src="$ROOT/corpus/SOURCES.md" kdir="$ROOT/corpus/knowledge"
  [[ -f $src && -r $src ]] || setup "corpus/SOURCES.md absent or unreadable"
  [[ -d $kdir && -r $kdir && -x $kdir ]] || setup "corpus/knowledge absent or unreadable"
  command -v realpath >/dev/null 2>&1 || setup "realpath absent"
  CAP_ROOT=$(realpath -e -- "$ROOT") || setup "root does not canonicalize"
  # round 67 (R67Sentinel V-2): the normalizer is the gate's own sibling, never
  # a copy shipped inside the tree being audited - a tree that carries a
  # truthy normalizer must not be able to move the quote verdict.
  CAP_NORM="$SCRIPT_DIR/rendered-text-v1.py"
  [[ -f $CAP_NORM ]] || setup "rendered-text-v1.py absent beside the gate"

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
        field="$(src_field "$ROOT/$p")"$'\n'"$(cites_field "$ROOT/$p")"
        [[ $field =~ (^|[^A-Za-z0-9_])$id([^0-9]|$) ]] || finding SC_USEDBY_NOCITE "id=$id path=$p"
      done
    fi
  done < <(awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {i=$2; s=$9; r=$5; gsub(/[[:space:]]/,"",i); gsub(/[[:space:]]/,"",s); gsub(/[[:space:]]/,"",r); t=$8; u=$12; sub(/^[[:space:]]+/,"",t); sub(/[[:space:]]+$/,"",t); sub(/^[[:space:]]+/,"",u); sub(/[[:space:]]+$/,"",u); printf "%s\037%s\037%s\037%s\037%s\n", i, s, r, t, u}' "$src")

  # ---- fetch provenance (round 23, routed D7) -------------------------------
  local fetchf="$ROOT/corpus/source-fetches.tsv"
  local fid fstatus frow furl ffinal fhttp fprof ffet frep fsha fbytes frev fquote fnorm fnsha floc seen_key words
  declare -A FURL=() FINROW=() FSEEN=() FRAW=() FNORM=() FFET=()
  while IFS=$'\x1f' read -r fid furl sdigest; do
    [[ -n $fid ]] || continue
    FURL[$fid]=$furl; FINROW[$fid]=$sdigest
  done < <(awk -F'|' '
    /^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {
      i=$2; gsub(/[[:space:]]/,"",i)
      src=$3; url=""
      if (match(src, /https?:\/\/[^ |]+/)) url=substr(src,RSTART,RLENGTH)
      d=""
      if (match($0, /Fetch sha256: `[0-9a-f]+`/)) d=substr($0,RSTART+15,RLENGTH-16)
      printf "%s\037%s\037%s\n", i, url, d
    }' "$src")
  if [[ -f $fetchf ]]; then
    out=$(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF!=16 {print "line=" NR " nf=" NF}' "$fetchf")
    while IFS= read -r line; do [[ -n $line ]] && finding SC_FETCH "$line"; done <<<"$out"
    while IFS=$'\t' read -r fid fstatus frow furl ffinal fhttp fprof ffet frep fsha fbytes frev fquote fnorm fnsha floc; do
      [[ -n ${fid:-} ]] || continue
      FSEEN[$fid]=$(( ${FSEEN[$fid]:-0} + 1 ))
      FRAW[$fid]=$fsha; FNORM[$fid]=$fnsha; FFET[$fid]=$ffet
      # round 67: read the bytes and the quote this row declares (SC_CAPTURE)
      cap_row "$fid" "$fsha" "$fbytes" "$fquote" "$fnorm" "$floc"
      [[ -v FURL[$fid] ]] || { finding SC_FETCH "id=$fid not-a-registry-row"; continue; }
      [[ ${ST[$fid]:-} == "$fstatus" ]] || finding SC_FETCH "id=$fid status=$fstatus registry=${ST[$fid]:-absent}"
      [[ ${FURL[$fid]} == "$furl" ]] || finding SC_FETCH "id=$fid url-mismatch"
      line=$(printf '%s\t%s\t%s\n' "$fid" "${ST[$fid]:-}" "${FURL[$fid]}" | sha256sum)
      [[ $frow == "${line%% *}" ]] || finding SC_FETCH "id=$fid row-identity-digest-mismatch"
      [[ $ffinal =~ ^https?://[^[:space:]]+$ ]] || finding SC_FETCH "id=$fid final-url"
      [[ $fhttp =~ ^[0-9]{3}$ ]] || finding SC_FETCH "id=$fid http-status"
      [[ $fprof == curl-fsSL-compressed-v1 ]] || finding SC_FETCH "id=$fid request-profile"
      [[ $ffet =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || finding SC_FETCH "id=$fid fetched"
      [[ $frep == decoded-http-body-v1 || $frep == decoded-http-body-volatile-v1 ]] || finding SC_FETCH "id=$fid representation"
      [[ $fsha =~ ^[0-9a-f]{64}$ ]] || finding SC_FETCH "id=$fid digest"
      [[ $fbytes =~ ^[1-9][0-9]*$ ]] || finding SC_FETCH "id=$fid bytes"
      if [[ $frev != - ]]; then
        [[ $frev =~ ^[0-9a-f]{40}$ ]] || finding SC_FETCH "id=$fid revision"
      fi
      if [[ $furl == *raw.githubusercontent.com* || $furl == */main/* || $furl == */main ]]; then
        [[ $frev =~ ^[0-9a-f]{40}$ ]] || finding SC_FETCH "id=$fid moving-ref-revision"
      fi
      words=$(printf '%s' "$fquote" | wc -w); words=${words//[[:space:]]/}
      [[ -n $fquote && $words -le 25 ]] || finding SC_FETCH "id=$fid quote"
      [[ $fnorm == rendered-text-v1 || $fnorm == raw-literal-v1 ]] || finding SC_FETCH "id=$fid normalization"
      if [[ $fnorm == rendered-text-v1 ]]; then
        [[ $fnsha =~ ^[0-9a-f]{64}$ ]] || finding SC_FETCH "id=$fid normalized-digest"
      elif [[ $fnsha != - ]]; then
        finding SC_FETCH "id=$fid normalized-digest-not-applicable"
      fi
      [[ ${#floc} -ge 8 ]] || finding SC_FETCH "id=$fid location"
      [[ ${FSEEN[$fid]} -le 1 ]] || finding SC_FETCH "id=$fid duplicate-provenance"
    done < <(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF==16' "$fetchf")
  fi
  # ---- historical in-row pins (round 24, routed D5) -------------------------
  # The in-row-only exemption belongs to the historical set S001-S016 alone: a
  # later row cannot certify itself with a bare `Fetch sha256:` digest. Every
  # in-row pin needs exactly one corpus/inrow-pins.tsv classification against
  # that id's capture row; the verdict is CHECKED against the capture digests,
  # never taken on the author's word.
  local HIST_RE='^S0(0[1-9]|1[0-6])$' inrowf="$ROOT/corpus/inrow-pins.tsv"
  local iid isha ifet iverdict inote n_inrow=0 n_inrow_only=0 n_nonrep=0 n_capt=0 want_v
  declare -A IPSEEN=()
  if [[ -f $inrowf ]]; then
    out=$(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF!=5 {print "line=" NR " nf=" NF}' "$inrowf")
    while IFS= read -r line; do [[ -n $line ]] && finding SC_INROW "$line"; done <<<"$out"
    while IFS=$'\t' read -r iid isha ifet iverdict inote; do
      [[ -n ${iid:-} ]] || continue
      IPSEEN[$iid]=$(( ${IPSEEN[$iid]:-0} + 1 ))
      [[ ${IPSEEN[$iid]} -le 1 ]] || { finding SC_INROW "id=$iid duplicate-classification"; continue; }
      [[ -n ${FINROW[$iid]:-} ]] || { finding SC_INROW "id=$iid not-an-inrow-row"; continue; }
      [[ $isha == "${FINROW[$iid]}" ]] || { finding SC_INROW "id=$iid inrow-digest-mismatch"; continue; }
      [[ ${FSEEN[$iid]:-0} -ge 1 ]] || { finding SC_INROW "id=$iid capture-missing"; continue; }
      [[ $ifet == "${FFET[$iid]}" ]] || { finding SC_INROW "id=$iid capture-date"; continue; }
      if [[ ${FRAW[$iid]} == "$isha" ]]; then want_v=reproduces-raw
      elif [[ ${FNORM[$iid]} == "$isha" ]]; then want_v=reproduces-normalized
      else want_v=non-reproducing; fi
      [[ $iverdict == "$want_v" ]] || { finding SC_INROW "id=$iid verdict=$iverdict capture-says=$want_v"; continue; }
      [[ $iverdict == non-reproducing ]] && n_nonrep=$((n_nonrep + 1))
    done < <(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF==5' "$inrowf")
  fi
  for fid in "${!ST[@]}"; do
    [[ ${FSEEN[$fid]:-0} -ge 1 ]] && n_capt=$((n_capt + 1))
    if [[ -n ${FINROW[$fid]:-} ]]; then
      n_inrow=$((n_inrow + 1))
      [[ ${FINROW[$fid]} =~ ^[0-9a-f]{64}$ ]] || finding SC_FETCH "id=$fid inrow-digest-malformed"
      [[ ${IPSEEN[$fid]:-0} -ge 1 ]] || finding SC_INROW "id=$fid classification-missing"
      if [[ $fid =~ $HIST_RE ]]; then
        [[ ${FSEEN[$fid]:-0} -ge 1 ]] || n_inrow_only=$((n_inrow_only + 1))
        continue
      fi
      finding SC_INROW "id=$fid inrow-pin-not-historical"
    fi
    [[ ${FSEEN[$fid]:-0} -ge 1 ]] || finding SC_FETCH "id=$fid missing-provenance"
  done

  cred_scan "$src" "corpus/SOURCES.md"

  local f rel sourced=0 legacy=0 ids listed_here nsrc supported cfield bid
  shopt -s nullglob
  for f in "$kdir"/*.md; do
    rel="corpus/knowledge/${f##*/}"
    # round 55: every registry id the entry names is recorded on its source: or
    # cites: line, and every cites: id is a registry row whose used-by lists it
    [[ $(grep -c '^cites:' "$f") -le 1 ]] || finding SC_BODY_CITE "entry=$rel multiple-cites-lines"
    field=$(src_field "$f"); cfield=$(cites_field "$f")
    for bid in $(body_ids "$f"); do
      [[ -v ST[$bid] ]] || continue
      [[ $field =~ (^|[^A-Za-z0-9_])$bid([^0-9]|$) || $cfield =~ (^|[^A-Za-z0-9_])$bid([^0-9]|$) ]] || finding SC_BODY_CITE "entry=$rel id=$bid unrecorded"
    done
    for bid in $(grep -oE '(^|[^A-Za-z0-9_])S[0-9]{3,}' <<<"$cfield" | grep -oE 'S[0-9]+$' | sort -u); do
      if [[ ! -v ST[$bid] ]]; then finding SC_BODY_CITE "entry=$rel id=$bid cites-not-a-registry-row"; continue; fi
      listed_here=0
      IFS=',;' read -ra parts <<<"${UB[$bid]}"
      for p in "${parts[@]}"; do [[ $(trim "$p") == "$rel" ]] && listed_here=1; done
      [[ $listed_here -eq 1 ]] || finding SC_BODY_CITE "entry=$rel id=$bid cites-used-by-omits-entry"
    done
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

  # round 67: the capture summary sits immediately before the verdict
  if [[ $CAP_DEFECTS -eq 0 ]]; then
    printf 'SOURCES_CAPTURES: CLEAN (path_rows=%d bound=%d located=%d prose=%d)\n' \
      "$CAP_PATH" "$CAP_BOUND" "$CAP_LOCATED" "$CAP_PROSE"
  else
    printf 'SOURCES_CAPTURES: FAILED (defects=%d path_rows=%d bound=%d located=%d prose=%d)\n' \
      "$CAP_DEFECTS" "$CAP_PATH" "$CAP_BOUND" "$CAP_LOCATED" "$CAP_PROSE"
  fi
  if [[ $FINDINGS -eq 0 ]]; then
    printf 'SOURCES_CENSUS: CLEAN (rows=%d A=%d B=%d C=%d queued=%d mined=%d rejected=%d entries_sourced=%d legacy=%d captures=%d inrow=%d inrow_only=%d inrow_nonreproducing=%d)\n' \
      "$rows" "$a" "$b" "$c" "$q" "$m" "$r" "$sourced" "$legacy" "$n_capt" "$n_inrow" "$n_inrow_only" "$n_nonrep"
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
  cat >"$d/corpus/knowledge/legacy.md" <<'EOF'
# legacy

Source basis: host inspection.
EOF
  local h1 h2 h3 h4
  h1=$(printf 'S001\tmined\thttps://example.invalid/one\n' | sha256sum); h1=${h1%% *}
  h2=$(printf 'S002\tmined\thttps://example.invalid/two\n' | sha256sum); h2=${h2%% *}
  h3=$(printf 'S003\tqueued\thttps://example.invalid/three\n' | sha256sum); h3=${h3%% *}
  h4=$(printf 'S004\trejected\thttps://example.invalid/four\n' | sha256sum); h4=${h4%% *}
  {
    printf 'S001\tmined\t%s\thttps://example.invalid/one\thttps://example.invalid/one\t200\tcurl-fsSL-compressed-v1\t2026-10-19\tdecoded-http-body-v1\t%s\t100\t-\tteaches one\trendered-text-v1\t%s\t§1, rev 1\n' "$h1" "$(rep a 64)" "$(rep 1 64)"
    printf 'S002\tmined\t%s\thttps://example.invalid/two\thttps://example.invalid/two\t200\tcurl-fsSL-compressed-v1\t2026-10-19\tdecoded-http-body-v1\t%s\t200\t-\tteaches two\trendered-text-v1\t%s\t§2, 2026-01-01\n' "$h2" "$(rep b 64)" "$(rep 2 64)"
    printf 'S003\tqueued\t%s\thttps://example.invalid/three\thttps://example.invalid/three\t200\tcurl-fsSL-compressed-v1\t2026-10-19\tdecoded-http-body-v1\t%s\t300\t-\tlead three\traw-literal-v1\t-\tthread 3\n' "$h3" "$(rep c 64)"
    printf 'S004\trejected\t%s\thttps://example.invalid/four\thttps://example.invalid/four\t200\tcurl-fsSL-compressed-v1\t2026-10-19\tdecoded-http-body-v1\t%s\t400\t-\tproduct four\traw-literal-v1\t-\tpage four\n' "$h4" "$(rep d 64)"
  } >"$d/corpus/source-fetches.tsv"
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
FETCH_F() { printf '%s/corpus/source-fetches.tsv' "$1"; }
fetch_edit() { # dir id field value
  local f tmp
  f=$(FETCH_F "$1"); tmp="$f.tmp"
  awk -F'\t' -v OFS='\t' -v id="$2" -v field="$3" -v value="$4" '
    /^#/ || length($0)==0 {print; next}
    $1==id { $field=value; print; next }
    {print}' "$f" >"$tmp" && mv -- "$tmp" "$f"
}
m_fetch_missing() {
  local f; f=$(FETCH_F "$1")
  awk -F'\t' 'BEGIN{OFS="\t"} $1!="S002"' "$f" >"$f.t" && mv -- "$f.t" "$f"
}
m_fetch_url() { fetch_edit "$1" S002 4 https://example.invalid/wrong; }
m_fetch_status() { fetch_edit "$1" S002 2 queued; }
m_fetch_rowdigest() { fetch_edit "$1" S002 3 deadbeef; }
m_fetch_digest() { fetch_edit "$1" S002 10 deadbeef; }
m_fetch_quote_long() { fetch_edit "$1" S002 13 "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty twentyone twentytwo twentythree twentyfour twentyfive twentysix"; }
m_fetch_norm() { fetch_edit "$1" S002 14 bad-norm-v1; fetch_edit "$1" S002 15 -; }
m_fetch_normsha() { fetch_edit "$1" S002 15 -; }
m_fetch_location() { fetch_edit "$1" S002 16 ""; }
m_fetch_unknown() {
  printf 'S099\tmined\t%s\thttps://example.invalid/nine\thttps://example.invalid/nine\t200\tcurl-fsSL-compressed-v1\t2026-10-19\tdecoded-http-body-v1\t%s\t10\t-\tunknown row\traw-literal-v1\t-\t§9\n' \
    "$(rep e 64)" "$(rep f 64)" >>"$(FETCH_F "$1")"
}
m_fetch_duplicate() {
  local f; f=$(FETCH_F "$1")
  grep '^S002	' "$f" >"$f.t" && cat "$f.t" >>"$f" && rm -f -- "$f.t"
}
m_fetch_disagree() {
  local f sha
  f=$(FETCH_F "$1")
  sha=$(rep 9 64)
  awk -F'\t' -v OFS='\t' -v sha="$sha" '$1=="S002" {$10=sha; print; exit}' "$f" >>"$f"
}
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
# round 55: body citations and the `cites:` line (SC_BODY_CITE, NOCITE via cites:)
LEGACY_F() { printf '%s/corpus/knowledge/legacy.md' "$1"; }
m_body_unrecorded() { printf '\nThe forum lead S003 says so.\n' >>"$(E1_F "$1")"; }
m_body_legacy() { printf '\nSee row S002.\n' >>"$(LEGACY_F "$1")"; }
m_body_cites_ok() {
  printf '\nThe forum lead S003 says so.\ncites: S003\n' >>"$(E1_F "$1")"
  sed -i '/^| S003 /s#| — |$#| corpus/knowledge/e1.md |#' "$(SRC_F "$1")"
}
m_body_cites_omits() { printf '\nThe forum lead S003 says so.\ncites: S003\n' >>"$(E1_F "$1")"; }
m_body_cites_unknown() { printf '\ncites: S099\n' >>"$(E1_F "$1")"; }
m_body_cites_two() {
  m_body_cites_ok "$1"
  printf 'cites: S003\n' >>"$(E1_F "$1")"
}
m_body_usedby_via_cites() {
  printf '\nSee row S002.\ncites: S002\n' >>"$(LEGACY_F "$1")"
  sed -i '/^| S002 /s#| corpus/knowledge/e1.md |$#| corpus/knowledge/e1.md, corpus/knowledge/legacy.md |#' "$(SRC_F "$1")"
}
m_body_digit_suffix() { printf '\nSection S0031 and xS003 are not ids.\n' >>"$(E1_F "$1")"; }
m_cred_src() { NEEDLE=$(needle "$2"); printf -- '- note %s\n' "$NEEDLE" >>"$(SRC_F "$1")"; }
m_cred_entry() { NEEDLE=$(needle 2); printf 'body %s\n' "$NEEDLE" >>"$(E1_F "$1")"; }
m_cred_legacy() { NEEDLE=$(needle 3); printf 'body %s\n' "$NEEDLE" >>"$1/corpus/knowledge/legacy.md"; }
m_setup_nosrc() { rm -f -- "$(SRC_F "$1")"; }
m_setup_srcdir() { rm -f -- "$(SRC_F "$1")"; mkdir -- "$(SRC_F "$1")"; }
m_setup_noknow() { rm -rf -- "$1/corpus/knowledge"; }
m_setup_badarg() { ARGS=(verify --root "$1" --bogus); }
m_setup_noroot() { ARGS=(verify --root "$1/absent"); }
m_setup_rootnoarg() { ARGS=(verify --root); }
# --- round 24: historical in-row pins (SC_INROW) ---------------------------------
# S001's capture row carries raw sha256 = 64x`a` and normalized sha256 = 64x`1`.
INROW_F() { printf '%s/corpus/inrow-pins.tsv' "$1"; }
pin_s001() { sed -i "/^| S001 /s/| teaches one |/| teaches one. Fetch sha256: \`$2\` |/" "$(SRC_F "$1")"; }
inrow_row() { printf 'S001\t%s\t%s\t%s\tselftest\n' "$2" "$3" "$4" >>"$(INROW_F "$1")"; }
m_inrow_unclassified() { pin_s001 "$1" "$(rep a 64)"; }
m_inrow_raw_ok() { pin_s001 "$1" "$(rep a 64)"; inrow_row "$1" "$(rep a 64)" 2026-10-19 reproduces-raw; }
m_inrow_norm_ok() { pin_s001 "$1" "$(rep 1 64)"; inrow_row "$1" "$(rep 1 64)" 2026-10-19 reproduces-normalized; }
m_inrow_nonrep_ok() { pin_s001 "$1" "$(rep 7 64)"; inrow_row "$1" "$(rep 7 64)" 2026-10-19 non-reproducing; }
m_inrow_verdict_lie() { pin_s001 "$1" "$(rep a 64)"; inrow_row "$1" "$(rep a 64)" 2026-10-19 non-reproducing; }
m_inrow_digest() { pin_s001 "$1" "$(rep a 64)"; inrow_row "$1" "$(rep 7 64)" 2026-10-19 reproduces-raw; }
m_inrow_date() { pin_s001 "$1" "$(rep a 64)"; inrow_row "$1" "$(rep a 64)" 2026-10-20 reproduces-raw; }
m_inrow_dup() { m_inrow_raw_ok "$1"; inrow_row "$1" "$(rep a 64)" 2026-10-19 reproduces-raw; }
m_inrow_capture_missing() {
  local f; f=$(FETCH_F "$1")
  m_inrow_raw_ok "$1"
  awk -F'\t' 'BEGIN{OFS="\t"} $1!="S001"' "$f" >"$f.t" && mv -- "$f.t" "$f"
}
m_inrow_not_historical() {
  sed -i "/^| S004 /a | S017 | Doc seventeen — https://example.invalid/seventeen | docs | B | topic seventeen | §17, 2026-04-04 | teaches seventeen. Fetch sha256: \`$(rep a 64)\` | queued | 2026-10-19 | 90d | — |" "$(SRC_F "$1")"
  printf 'S017\t%s\t2026-10-19\tnon-reproducing\tselftest\n' "$(rep a 64)" >>"$(INROW_F "$1")"
}
m_inrow_orphan() { inrow_row "$1" "$(rep a 64)" 2026-10-19 reproduces-raw; }
# --- round 67: capture read-through (SC_CAPTURE, SOURCES_CAPTURES) -----------
# The base fixture's four locations are prose. These mutations repoint S001's
# provenance row at a real capture file; each then breaks one predicate. The
# capture body is fixed here so the declared quote, size and digest are facts
# of the fixture, not of the gate's own logic.
CAP_QUOTE='Audit devices must be enabled by a root user.'
cap_fixture() { # dir [location]
  local d=$1 loc=${2:-captures/c1.body} body sha n normsha
  mkdir -p "$d/captures" || return 1
  printf 'The quick capture body.\nAudit devices must be enabled by a root user.\nEnd.\n' >"$d/captures/c1.body"
  body="$d/captures/c1.body"
  sha=$(sha256sum -- "$body"); sha=${sha%% *}
  n=$(stat -c %s -- "$body")
  normsha=$(python3 "$SCRIPT_DIR/rendered-text-v1.py" digest "$body" | sed -n 's/.*normalized_sha256=\([0-9a-f]\{64\}\).*/\1/p')
  [[ -n $normsha ]] || return 1
  fetch_edit "$d" S001 10 "$sha"
  fetch_edit "$d" S001 11 "$n"
  fetch_edit "$d" S001 13 "$CAP_QUOTE"
  fetch_edit "$d" S001 14 rendered-text-v1
  fetch_edit "$d" S001 15 "$normsha"
  fetch_edit "$d" S001 16 "$loc"
}
m_capture_ok() { cap_fixture "$1"; }
m_capture_repoint() {
  # same-size sibling body, different bytes: digest-only, and the quote is
  # garbage too — an unbound row must NOT also report quote-not-located
  cap_fixture "$1"
  cp -- "$1/captures/c1.body" "$1/captures/other.body"
  sed -i 's/Audit/audit/' "$1/captures/other.body"
  fetch_edit "$1" S001 13 'this sentence locates in no body at all'
  fetch_edit "$1" S001 16 captures/other.body
}
m_capture_missing() { cap_fixture "$1" captures/absent.body; }
m_capture_truncate() { cap_fixture "$1"; truncate -s -1 -- "$1/captures/c1.body"; }
m_capture_absolute() { cap_fixture "$1" "$1/captures/c1.body"; }
m_capture_dotdot() {
  cap_fixture "$1"
  printf 'outside body\n' >"$1/../c1-outside.body"
  fetch_edit "$1" S001 16 ../c1-outside.body
}
m_capture_quote() { cap_fixture "$1"; fetch_edit "$1" S001 13 'this sentence locates in no body at all'; }
m_capture_prose() { cap_fixture "$1" 'page title/H1'; }
m_capture_bytes_declared() { cap_fixture "$1"; fetch_edit "$1" S001 11 999999; }
m_capture_symlink() {
  cap_fixture "$1"
  printf 'outside body\n' >"$1/../c1-link-target.body"
  ln -s ../../c1-link-target.body "$1/captures/link.body"
  fetch_edit "$1" S001 16 captures/link.body
}
m_capture_symlink_intree() {
  # an in-tree symlink resolves to an in-tree regular file: size and digest
  # measure the resolved object (stat -L), so the row binds
  cap_fixture "$1"
  ln -s c1.body "$1/captures/alias.body"
  fetch_edit "$1" S001 16 captures/alias.body
}

selftest() {
  ST_DIR=$(mktemp -d) || setup "mktemp failed"
  trap cleanup EXIT
  base_fixture "$ST_DIR/base" || setup "fixture build failed"
  local CLEAN_LINE='SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=0 inrow_only=0 inrow_nonreproducing=0)'
  local CLEAN_INROW='SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)'
  local CLEAN_NONREP='SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=1)'
  # name | mutation | arg | exit | expected id (CLEAN / SETUP / finding id) | findings
  local -a CASES=(
    "clean|m_clean||0|CLEAN|0"
    "continuation-line|m_continuation||0|CLEAN|0"
    "legacy-not-scanned|m_cred_legacy||0|CLEAN|0"
    "zero|m_zero||1|SC_ZERO|5"
    "malformed|m_malformed||1|SC_MALFORMED|2"
    "row-leading-space|m_row_lead_space||1|SC_MALFORMED|2"
    "row-two-digit-id|m_row_two_digit||1|SC_MALFORMED|2"
    "row-lowercase-id|m_row_lower||1|SC_MALFORMED|2"
    "dup|m_dup||1|SC_DUP|1"
    "enum-tier|m_enum_tier||1|SC_ENUM|1"
    "enum-status|m_enum_status||1|SC_ENUM|3"
    "enum-kind|m_enum_kind||1|SC_ENUM|1"
    "inflation|m_inflation||1|SC_INFLATION|1"
    "usedby-missing|m_usedby_missing||1|SC_USEDBY_MISSING|1"
    "usedby-absolute|m_usedby_abs||1|SC_USEDBY_MISSING|1"
    "usedby-dotdot|m_usedby_dotdot||1|SC_USEDBY_MISSING|1"
    "usedby-nocite|m_usedby_nocite||1|SC_USEDBY_NOCITE|1"
    "mined-unused-dash|m_unused_dash||1|SC_MINED_UNUSED|2"
    "mined-unused-empty|m_unused_empty||1|SC_MINED_UNUSED|2"
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
    "cite-no-id|m_cite_noid||1|SC_ENTRY_CITE|5"
    "cite-tier-c-sole|m_cite_tier_c||1|SC_ENTRY_CITE|2"
    "body-cite-unrecorded|m_body_unrecorded||1|SC_BODY_CITE|1"
    "body-cite-legacy|m_body_legacy||1|SC_BODY_CITE|1"
    "body-cites-control|m_body_cites_ok||0|CLEAN|0"
    "body-cites-usedby-omits|m_body_cites_omits||1|SC_BODY_CITE|1"
    "body-cites-not-a-row|m_body_cites_unknown||1|SC_BODY_CITE|1"
    "body-cites-two-lines|m_body_cites_two||1|SC_BODY_CITE|1"
    "usedby-via-cites-control|m_body_usedby_via_cites||0|CLEAN|0"
    "body-digit-suffix-control|m_body_digit_suffix||0|CLEAN|0"
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
    "fetch-missing|m_fetch_missing||1|SC_FETCH|1"
    "fetch-url|m_fetch_url||1|SC_FETCH|1"
    "fetch-status|m_fetch_status||1|SC_FETCH|1"
    "fetch-rowdigest|m_fetch_rowdigest||1|SC_FETCH|1"
    "fetch-digest|m_fetch_digest||1|SC_FETCH|1"
    "fetch-quote-long|m_fetch_quote_long||1|SC_FETCH|1"
    "fetch-norm|m_fetch_norm||1|SC_FETCH|1"
    "fetch-normsha|m_fetch_normsha||1|SC_FETCH|1"
    "fetch-location|m_fetch_location||1|SC_FETCH|1"
    "fetch-unknown|m_fetch_unknown||1|SC_FETCH|1"
    "fetch-duplicate|m_fetch_duplicate||1|SC_FETCH|1"
    "fetch-disagree|m_fetch_disagree||1|SC_FETCH|1"
    "inrow-unclassified|m_inrow_unclassified||1|SC_INROW|1"
    "inrow-raw-control|m_inrow_raw_ok||0|CLEAN_INROW|0"
    "inrow-normalized-control|m_inrow_norm_ok||0|CLEAN_INROW|0"
    "inrow-nonreproducing-counted|m_inrow_nonrep_ok||0|CLEAN_NONREP|0"
    "inrow-verdict-lie|m_inrow_verdict_lie||1|SC_INROW|1"
    "inrow-digest-mismatch|m_inrow_digest||1|SC_INROW|1"
    "inrow-capture-date|m_inrow_date||1|SC_INROW|1"
    "inrow-duplicate|m_inrow_dup||1|SC_INROW|1"
    "inrow-capture-missing|m_inrow_capture_missing||1|SC_INROW|1"
    "inrow-not-historical|m_inrow_not_historical||1|SC_INROW|3"
    "inrow-orphan-classification|m_inrow_orphan||1|SC_INROW|1"
    "capture-bound-ok|m_capture_ok||0|CLEAN|0|SOURCES_CAPTURES: CLEAN (path_rows=1 bound=1 located=1 prose=3)"
    "capture-repoint|m_capture_repoint||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-digest-mismatch"
    "capture-missing|m_capture_missing||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-missing"
    "capture-truncate-by-1|m_capture_truncate||1|SC_CAPTURE|2|SOURCES_CAPTURES: FAILED (defects=2 path_rows=1 bound=0 located=0 prose=3)|capture-bytes-mismatch,capture-digest-mismatch"
    "capture-absolute-location|m_capture_absolute||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-outside-root"
    "capture-dotdot-location|m_capture_dotdot||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-outside-root"
    "capture-quote-garbage|m_capture_quote||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=1 located=0 prose=3)|quote-not-located"
    "capture-prose-skip|m_capture_prose||0|CLEAN|0|SOURCES_CAPTURES: CLEAN (path_rows=0 bound=0 located=0 prose=4)"
    "capture-bytes-declared|m_capture_bytes_declared||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-bytes-mismatch"
    "capture-symlink-escape|m_capture_symlink||1|SC_CAPTURE|1|SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)|capture-outside-root"
    "capture-symlink-intree-control|m_capture_symlink_intree||0|CLEAN|0|SOURCES_CAPTURES: CLEAN (path_rows=1 bound=1 located=1 prose=3)"
  )
  local spec name fn arg xe xid xn xcap xreason d out rc last ok cases=0 failed=0
  for spec in "${CASES[@]}"; do
    IFS='|' read -r name fn arg xe xid xn xcap xreason <<<"$spec"
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
      CLEAN_INROW) [[ $last == "$CLEAN_INROW" ]] || ok=0 ;;
      CLEAN_NONREP) [[ $last == "$CLEAN_NONREP" ]] || ok=0 ;;
      SETUP) [[ $last == 'SOURCES_CENSUS: SETUP ('*')' ]] || ok=0 ;;
      *)
        grep -q "^FINDING $xid " <<<"$out" || ok=0
        [[ $last == "SOURCES_CENSUS: FAILED (findings=$xn rows="*')' ]] || ok=0 ;;
    esac
    if [[ -n $xreason ]]; then
      local -a RREASONS=()
      local rr
      IFS=',' read -ra RREASONS <<<"$xreason"
      for rr in "${RREASONS[@]}"; do
        grep -qE "^FINDING $xid id=[^ ]+ $rr\$" <<<"$out" || ok=0
      done
    fi
    # round 67: the capture summary is the line before the verdict, its counts
    # agree with the fixture and with the SC_CAPTURE findings, and stage
    # relations hold (located ≦ bound ≦ path_rows)
    if [[ $rc -ne 2 ]]; then
      local -a OUTL=()
      mapfile -t OUTL <<<"$out"
      local cap_sum cap_n cap_def=0 cap_path cap_bound cap_located cap_prose data_rows
      cap_sum=${OUTL[${#OUTL[@]}-2]}
      cap_n=$(grep -c '^FINDING SC_CAPTURE ' <<<"$out")
      if [[ $cap_sum =~ ^SOURCES_CAPTURES:\ CLEAN\ \(path_rows=([0-9]+)\ bound=([0-9]+)\ located=([0-9]+)\ prose=([0-9]+)\)$ ]]; then
        cap_path=${BASH_REMATCH[1]}; cap_bound=${BASH_REMATCH[2]}; cap_located=${BASH_REMATCH[3]}; cap_prose=${BASH_REMATCH[4]}
      elif [[ $cap_sum =~ ^SOURCES_CAPTURES:\ FAILED\ \(defects=([0-9]+)\ path_rows=([0-9]+)\ bound=([0-9]+)\ located=([0-9]+)\ prose=([0-9]+)\)$ ]]; then
        cap_def=${BASH_REMATCH[1]}; cap_path=${BASH_REMATCH[2]}; cap_bound=${BASH_REMATCH[3]}; cap_located=${BASH_REMATCH[4]}; cap_prose=${BASH_REMATCH[5]}
      else
        ok=0; cap_path=0; cap_prose=0; cap_bound=0; cap_located=0
      fi
      if [[ -f $(FETCH_F "$d") ]]; then
        data_rows=$(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF==16 {n++} END{print n+0}' "$(FETCH_F "$d")")
      else
        data_rows=0
      fi
      [[ $((cap_path + cap_prose)) -eq $data_rows ]] || ok=0
      [[ $cap_located -le $cap_bound && $cap_bound -le $cap_path ]] || ok=0
      [[ $cap_def -eq $cap_n ]] || ok=0
    fi
    if [[ -n $xcap ]] && ! grep -qF -- "$xcap" <<<"$out"; then ok=0; fi
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
