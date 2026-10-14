#!/usr/bin/env bash
# claim-ledger.sh — calibration gate: revisions, claims, citations.
#
# Round 10 left calibration at 7 for three measured reasons: the scorecard
# cells were self-scored with prose evidence; the round report's 62 claims were
# adjudicated by hand (9 STALE, 4 UNCHECKABLE) because no claim carried a
# command; and two committed citations (`local://round-10/critic.md`,
# `local://round-10/connector.md`) name session-scoped scratch that no fresh
# session can resolve — the same class the protocol lane logged for kumitate
# (`.ufo/reports/round-10/protocol.md` D-19, OPEN).
#
# This gate makes the three classes mechanically checkable:
#
#   revision — `corpus/stamps.tsv`: path <TAB> sha256 <TAB> lines <TAB> bytes,
#              one row per artifact this round cites. `verify` recomputes and
#              reports STALE / MISSING, so a reviewer can state which revision
#              was read and prove the shipped revision is the stamped one.
#              Regenerating is a reviewed commit, not an automatic re-pin.
#              `stamp PATH…` regenerates the WHOLE row set from the paths given
#              (it replaces the file, it does not merge), so a run that names
#              fewer paths than the file holds is refused unless `--prune` is
#              passed — round 12 lost 18 rows to an in-flight `stamp` of 10
#              paths before this guard existed.
#   claim    — `corpus/claim-ledger.tsv`: id <TAB> command <TAB> expect
#              <TAB> exit <TAB> timeout <TAB> note. `verify` runs each command
#              under a timeout and passes it only when BOTH hold: the exit code
#              equals the expected one AND the expected ERE matches the LAST
#              non-empty output line. The final-line rule is what stops a
#              command that prints a verdict-shaped string *and then fails* from
#              passing; a verdict is a summary line by construction.
#   citation — committed Markdown docs must cite durable evidence. Every
#              whitespace token on every line is normalized (backticks, quotes,
#              parens, `./`, line refs `:N`/`:N-M`/`:N,:M`, `#anchor`,
#              `?query`, `=value`, `'s`) and classified by shape:
#              `corpus/…` and the root docs (resolve under
#              the repo), `knowledge/…`/`lessons/…` (the two corpus
#              shorthands), `<lane>-shokunin/…` (sibling lane repo),
#              `ufo/…`/`.ufo/…` (main-repo .ufo tree); a `{a,b}` brace set
#              must have every alternative resolve. Session-scoped URIs
#              (local://, artifact://, agent://, proc://) are EPHEMERAL and
#              fail, and a path that does not resolve fails as UNRESOLVED —
#              unless the citing LINE labels it with a marker (scratch |
#              ephemeral | relocat | formerly | no longer | removed | renamed |
#              historical). A labelled stale token is counted, not failed: the
#              rule is "a dead citation must be labelled dead where it is
#              cited", not "no dead citations ever".
#   idref    — every claim-id token (`R<digits>-<digits>`) in the same doc set
#              must be a row id in `corpus/claim-ledger.tsv`. The ledger was
#              only ever iterated FORWARD (rows → commands), so a doc citing an
#              id that never existed passed every gate, and rows cited nowhere
#              went unnoticed (five at round 12). Uncited rows are ORPHANs:
#              counted, informational, listed with `--orphans`.
#   entry    — `docs` audits the knowledge surface: every
#              `corpus/knowledge/*.md` entry must declare how its host-fact
#              base is re-verified, on ONE line, in one of two strict forms:
#                `Reverify: R11-04, R11-05`  (claim rows, re-run by `verify`)
#                `Reverify: by-hand: <class> — <reason ≥24 chars>`
#              and must be a row in `corpus/stamps.tsv` (a revision pin). The
#              four by-hand classes (control-plane-scratch | opencode-internal |
#              interactive-only | vault-refusal) are the explicit, countable
#              unverifiable set, not a bin: the mode fails when fewer than half
#              the entries carry a row, so the escape cannot swallow the rule.
#              The declaration is a POINTER, not relevance — a row can be
#              irrelevant to the entry beside it (round-13 critic's executed
#              counterexample, still open; see §Bounds).
#   cell     — `cells` audits `SCORECARD.md`'s own score card: every table row
#              inside a `## Round <N> — pre-move|post-move` section whose first
#              cell is one of the six axis names must carry a POINTER — a
#              resolving row id, or a path listed in `corpus/stamps.tsv` (the
#              stamp is the revision-pinned artifact that records the number).
#              This is round 11's recorded next step ("each score cell names the
#              claim ids it rests on"); 20 of 48 cells had no resolving pointer
#              when it landed. ZERO checked cells is a setup error (exit 2),
#              never a clean run.
#
# Verdicts  stamps:   OK (silent) | STALE | MISSING | NOT-A-FILE
#           claims:   OK (silent) | FAIL(reason) | POLICY(reason)
#           citations: CLEAN | BROKEN (UNRESOLVED / EPHEMERAL lines)
#           idref:    OK (silent) | MISSING-ID doc:line id | ORPHAN (--orphans)
#           cells:    OK (silent) | MISSING-ID file:line id | UNCITED file:line axis
#           entry:    OK (silent) | UNDECLARED | MISSING-ID | UNPINNED | RATIO
# Exit      0 clean · 1 drift/claim/id/cell/entry failure · 2 policy/setup error
#
# Secret hygiene: the gate prints paths, hashes of repo files, claim ids,
# exit codes and counts. It NEVER echoes a claim's output (a claim could read
# a private file; only the verdict line is matched, never printed).
#
# Command safety: a committed runnable-command file is an execution surface, so
# claims are refused (POLICY, exit 2, never run) unless they are a single simple
# command: first token in a five-entry allowlist (bash|grep|sha256sum|wc|test),
# no shell metacharacters (; & | < > $ backtick), no backslash, no empty quote
# pair, no `bash -c`, and no denied verb — the deny words are matched on a
# QUOTE-STRIPPED copy of the text, so `g''it` / `g\it` / `o"p"` cannot walk past
# a name-based guard (round-11 executor A03/A04 + sentinel F2). `--selftest`
# proves each refusal path on scratch data; selftest never runs `verify` against
# the real files.
#
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT=$({ cd -- "$SCRIPT_DIR/.." && pwd; })
STAMPS="$SCRIPT_DIR/stamps.tsv"
CLAIMS="$SCRIPT_DIR/claim-ledger.tsv"
SCORECARD=""
DOCS_ARG=""
OUT=""
MODE="verify"
POS=()
PRUNE=0
ORPHANS=0

die() { printf 'claim-ledger: %s\n' "$1" >&2; exit 2; }

# Split one line on TAB, preserving EMPTY fields: `IFS=$'\t' read` treats tab as
# IFS-whitespace and collapses runs, so a row with an empty column silently
# shifts (round-11 executor A15: an empty command column was reported CLEAN).
# Fills the global TF array; TF_N = field count.
TF=(); TF_N=0
split_tab() {
  local rest="$1" f
  TF=(); TF_N=0
  while :; do
    if [[ $rest == *$'\t'* ]]; then f=${rest%%$'\t'*}; rest=${rest#*$'\t'}; else f=$rest; rest=""; fi
    TF+=("$f"); TF_N=$((TF_N + 1))
    [[ -n $rest ]] || break
  done
}
# --- substrate presence ------------------------------------------------------
# Round 18: the host substrate this lane censes (the-janitor handler at
# $HOME/.local/bin/the-janitor) may be absent entirely — a host-state fact, not
# a claim failure. A claims row whose NOTE field contains the literal tag
# `[substrate]` declares that dependence; when the substrate is absent such a
# row is DEFERred (counted, never run) rather than FAILed, and the verify/cells
# summary carries `deferred=N`/`row_deferred=N`. Deferral is not forgiveness:
# untagged rows still fail, and a tagged row runs normally while the substrate
# is present. KAGI_SUBSTRATE=present|absent overrides detection for the
# selftest, which must prove both paths on any host.
substrate_present() {
  case "${KAGI_SUBSTRATE:-}" in
    present) return 0 ;;
    absent)  return 1 ;;
  esac
  [[ -x "$HOME/.local/bin/the-janitor" ]]
}


# stamp's temp file is cleaned by an EXIT trap: a `local` tmp would be out of
# scope (and unbound, under set -u) by the time the trap runs — found by the
# first real `stamp` invocation, not by the selftest, which is why the selftest
# now owns stamp cases (round-11 cases 23-25).
STAMP_TMP=""
cleanup_tmp() { [[ -n ${STAMP_TMP:-} ]] && rm -f -- "$STAMP_TMP"; return 0; }
trap cleanup_tmp EXIT

# --- policy ------------------------------------------------------------------
# First token must be one of these; the allowlist is deliberately tiny — a
# claim is a verdict-producing command, not a pipeline.
ALLOWED_RE='^(bash|grep|sha256sum|wc|test)$'
# No shell metacharacters at all: one simple command, no composition.
META_RE='[;&|<>$`]'
# Verbs that touch the handler, the vault, the repo, or the network. Word
# boundaries are alnum/underscore/dash-aware so `corpus/op-cli-surface.md`
# (dashes) is not a false hit, while `grep -q op file` is refused.
DENY_WORD_RE='(^|[^A-Za-z0-9_-])(op|the-janitor|git|rm|mv|cp|chmod|chown|curl|wget|sudo|ssh|scp|systemctl|tmux|kill|pkill|dd|truncate|shred|ln|rsync|tar)([^A-Za-z0-9_-]|$)'

# Prints the refusal class on stdout; 0 = allowed, 1 = refused.
policy_check() {
  local c=$1 w
  w=${c%%[[:space:]]*}
  [[ $w =~ $ALLOWED_RE ]] || { printf 'first-token:%s' "$w"; return 1; }
  [[ $c =~ $META_RE ]] && { printf 'metachar'; return 1; }
  # `bash -c <inline>` is the whole execution surface in one argument; no row
  # needs it (round-11 sentinel F1: policy-clean rows mutated state)
  [[ $c == 'bash -c' || $c == 'bash -c '* ]] && { printf 'inline-shell'; return 1; }
  # word-splitting a denied name defeats a name-based guard; both forms are
  # refused because no legitimate claim row needs a backslash or an empty
  # quote pair (round-11 executor A03/A04: `g''it` / `g\it` executed a stand-in)
  [[ $c == *'\\'* ]] && { printf 'backslash'; return 1; }
  [[ $c == *"''"* || $c == *'""'* ]] && { printf 'empty-quotes'; return 1; }
  # deny words are matched on a QUOTE-STRIPPED copy: `o"p"`, `g''it` and `g\it`
  # all reached a denied name while the literal text did not (round-11 sentinel
  # F2 / executor A03-A04). Legitimate rows use quotes only around EREs.
  local dn=${c//\'/}; dn=${dn//\"/}
  [[ $dn =~ $DENY_WORD_RE ]] && { printf 'denied-verb:%s' "${BASH_REMATCH[2]}"; return 1; }
  return 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    verify|citations|cells|docs) MODE="$1"; shift ;;
    --selftest) MODE="selftest"; shift ;;
    stamp) MODE="stamp"; shift ;;
    --stamps) [[ $# -ge 2 ]] || die "--stamps needs a file"; STAMPS="$2"; shift 2 ;;
    --claims) [[ $# -ge 2 ]] || die "--claims needs a file"; CLAIMS="$2"; shift 2 ;;
    --scorecard) [[ $# -ge 2 ]] || die "--scorecard needs a file"; SCORECARD="$2"; shift 2 ;;
    --docs) [[ $# -ge 2 ]] || die "--docs needs paths"; DOCS_ARG="$2"; shift 2 ;;
    --root) [[ $# -ge 2 ]] || die "--root needs a dir"; ROOT="$2"; shift 2 ;;
    --out) [[ $# -ge 2 ]] || die "--out needs a file"; OUT="$2"; shift 2 ;;
    --prune) PRUNE=1; shift ;;
    --orphans) ORPHANS=1; shift ;;
    # the range tracks the header's end marker, so extending the contract above
    # cannot silently truncate its own help (round 13; the old fixed `2,74p`
    # range had already drifted into the assignments below the header)
    -h|--help) sed -n '2,/^set -euo pipefail$/p' "${BASH_SOURCE[0]}" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) die "unknown argument: $1" ;;
    *) POS+=("$1"); shift ;;
  esac
done
[[ -d $ROOT ]] || die "root is not a dir: $ROOT"
# A claim row may invoke this gate's `--selftest` (scratch-only and bounded —
# R11-09 does exactly that), but a nested AUDIT recurses: `verify` runs every
# row, and rows can run gates. `verify` is therefore refused when it is already
# inside a ledger run (exit 2, deterministic, no hang). The consequence is a
# stated bound: the ledger cannot pin its own `verify` summary. `cells` is NOT
# refused — it re-runs only the rows its scorecard cites and skips the rows that
# re-invoke this gate (see cells_evidence), so one nesting level stays bounded.
if [[ ${CLAIM_LEDGER_DEPTH:-0} -gt 0 && $MODE == verify ]]; then
  die "refusing a nested self-audit (CLAIM_LEDGER_DEPTH=${CLAIM_LEDGER_DEPTH}; a claim row cannot run $MODE from inside a ledger run)"
fi
# resolved after --root so a scratch --root gets a scratch scorecard by default
[[ -n $SCORECARD ]] || SCORECARD="$ROOT/SCORECARD.md"

# --- stamps ------------------------------------------------------------------
stamp() {
  local out=${OUT:-$SCRIPT_DIR/stamps.tsv} p f sha lines bytes existing=0
  local -a STAMP_SEEN=()
  [[ ${#POS[@]} -gt 0 ]] || die "stamp needs at least one path"
  [[ $out == /* ]] || out="$PWD/$out"
  [[ -e $out && ! -f $out ]] && die "--out exists and is not a regular file: $out"
  # a symlinked --out would be REPLACED by `mv` (the link, not its target),
  # leaving two diverged copies (round-12 critic F4)
  [[ -L $out ]] && die "--out is a symlink, refusing to replace it: $out"
  if [[ -f $out ]]; then
    existing=$(grep -c '[^[:space:]]' "$out"); existing=${existing//[[:space:]]/}
  fi
  # `stamp` replaces the row set; every path already pinned must be named again.
  # A per-path check (round-12 mutation lane: an equal-count path swap and a
  # missing-final-newline off-by-one both slipped past the earlier row-count
  # rule) — the file's *membership* is the invariant, not its length.
  local q
  for q in "${POS[@]}"; do
    [[ $q == "$out" || $q == "${out#"$ROOT/"}" ]] && die "refusing to stamp the output file itself: $q"
  done
  if [[ $PRUNE -eq 0 && -f $out ]]; then
    local old
    # `read` drops a final row that has no trailing newline; `|| [[ -n $old ]]`
    # keeps it (round-12 critic F1: a 4-path stamp over a 5-row file whose last
    # row was unterminated silently dropped that artifact). Comment lines are not
    # paths and are skipped.
    while IFS= read -r old || [[ -n ${old:-} ]]; do
      [[ -n ${old:-} ]] || continue
      [[ ${old:0:1} == '#' ]] && continue
      old=${old%%$'\t'*}
      [[ " ${POS[*]} " == *" $old "* ]] ||
        die "refusing to shrink $out: '$old' is pinned and would be dropped (existing $existing rows, new ${#POS[@]}; pass --prune to accept)"
    done <"$out"
  fi
  STAMP_TMP=$(mktemp) || die "mktemp failed"
  for p in "${POS[@]}"; do
    [[ $p == /* ]] && die "absolute path refused: $p"
    [[ $p == *[[:space:]]* ]] && die "whitespace in path refused: $p"
    [[ $p == *$'\t'* ]] && die "tab in path refused: $p"
    [[ $p == "$out" ]] && die "refusing to stamp the output file itself: $p"
    [[ $p == "${out#"$ROOT/"}" || $p == "$out" ]] && die "refusing to stamp the output file itself: $p"
    [[ $p == *..* ]] && die "refusing a path with '..' (--root containment): $p"
    [[ " ${STAMP_SEEN[*]-} " == *" $p "* ]] && die "duplicate path in one stamp invocation: $p"
    STAMP_SEEN+=("$p")
    f="$ROOT/$p"
    [[ -e $f ]] || die "not found: $p"
    [[ ! -L $f && -f $f ]] || die "not a regular file: $p"
    # the final component is checked for symlink above; the DIRECTORY path could
    # still traverse one, so the canonical path must stay under the canonical root
    [[ $(readlink -f -- "$f") == "$(readlink -f -- "$ROOT")"/* ]] \
      || die "path escapes --root through a symlinked directory: $p"
    sha=$(sha256sum -- "$f"); sha=${sha%% *}
    lines=$(wc -l <"$f"); lines=${lines//[[:space:]]/}
    bytes=$(wc -c <"$f"); bytes=${bytes//[[:space:]]/}
    printf '%s\t%s\t%s\t%s\n' "$p" "$sha" "$lines" "$bytes" >>"$STAMP_TMP"
  done
  sort -o "$STAMP_TMP" "$STAMP_TMP"
  mv -- "$STAMP_TMP" "$out"
  STAMP_TMP=""
  printf 'STAMPED: n=%d out=%s\n' "${#POS[@]}" "$out"
}

# Counters are globals: the detail lines go to stdout and the caller must not
# have to parse them out of a command substitution (round-11 selftest case 1
# caught exactly that: `read` consumed a FAIL line as if it were the summary).
# Rows are loaded ONCE into parallel arrays: the first read is what fixes the
# schema errors (blank row, wrong field count), and both consumers need random
# access — `verify` iterates, the cell audit looks a single path up by exact
# first-field equality. A substring match on the raw line is NOT a lookup: the
# score columns of a scorecard cell contain bare digits, and `grep -F "7<TAB>"`
# happily matched the end of a sha256 hex string, which made every cell look
# credentialled to a stamped artifact (round-13 probe, before it shipped).
SPATH=(); SSHA=(); SLINES=(); SBYTES=(); S_N=0
load_stamps() {
  local line
  SPATH=(); SSHA=(); SLINES=(); SBYTES=(); S_N=0
  [[ -f $STAMPS ]] || die "stamps file not found: $STAMPS"
  grep -qv '^[[:space:]]*\(#\|$\)' "$STAMPS" \
    || die "no stamp rows in $STAMPS (refusing to report coverage with an empty stamp set)"
  while IFS= read -r line || [[ -n ${line:-} ]]; do
    [[ ${line:0:1} == '#' ]] && continue
    # a blank line is NOT a comment: it would silently reduce coverage while a
    # `grep -c` count row still sees a row (round-12 mutation lane finding)
    [[ -n ${line:-} ]] || die "malformed stamps row (blank line)"
    split_tab "$line"
    [[ $TF_N -eq 4 ]] || die "malformed stamps row (fields=$TF_N)"
    [[ -n ${TF[0]} && -n ${TF[1]} && -n ${TF[2]} && -n ${TF[3]} ]] || die "malformed stamps row (empty field)"
    # READ-side containment, symmetric with what `stamp` refuses to WRITE: a row
    # naming an absolute path or one containing `..` would make `verify` hash a
    # file outside `--root` (a hash oracle) and let a scorecard cell point at one.
    # `stamp` has refused both since round 11; the reader did not, and the round-13
    # sentinel demonstrated the asymmetry end to end (both in `verify` and `cells`).
    [[ ${TF[0]} != /* ]] || die "stamps row names an absolute path: ${TF[0]}"
    [[ ${TF[0]} != *..* ]] || die "stamps row names a path with '..': ${TF[0]}"
    SPATH+=("${TF[0]}"); SSHA+=("${TF[1]}"); SLINES+=("${TF[2]}"); SBYTES+=("${TF[3]}")
    S_N=$((S_N + 1))
  done <"$STAMPS"
}

# Index of a pinned path, or 1 when it is not pinned. Exact first-field match.
stamp_index() {
  local i
  for ((i = 0; i < S_N; i++)); do [[ ${SPATH[i]} == "$1" ]] && { printf '%s' "$i"; return 0; }; done
  return 1
}

# Compare one pinned path against its row. 0 fresh · 1 stale · 2 absent or not a
# regular file · 3 not pinned. Details land in CMP_* for the caller to print, so
# the two consumers can label the same fact differently.
CMP_OSHA="" CMP_NSHA="" CMP_OL=0 CMP_NL=0 CMP_OB=0 CMP_NB=0
stamp_cmp() {
  local i f osha olines obytes
  CMP_OSHA=""; CMP_NSHA=""; CMP_OL=0; CMP_NL=0; CMP_OB=0; CMP_NB=0
  i=$(stamp_index "$1") || return 3
  CMP_OSHA=${SSHA[i]}; CMP_OL=${SLINES[i]}; CMP_OB=${SBYTES[i]}
  f="$ROOT/$1"
  [[ -e $f && ! -L $f && -f $f ]] || return 2
  osha=$(sha256sum -- "$f"); CMP_NSHA=${osha%% *}
  olines=$(wc -l <"$f"); CMP_NL=${olines//[[:space:]]/}
  obytes=$(wc -c <"$f"); CMP_NB=${obytes//[[:space:]]/}
  [[ $CMP_NSHA == "$CMP_OSHA" && $CMP_NL -eq $CMP_OL && $CMP_NB -eq $CMP_OB ]] || return 1
  return 0
}

# Counters are globals: the detail lines go to stdout and the caller must not
# have to parse them out of a command substitution (round-11 selftest case 1
# caught exactly that: `read` consumed a FAIL line as if it were the summary).
V_ROWS=0 V_STALE=0 V_MISSING=0
verify_stamps() {
  local i rc f
  V_ROWS=0 V_STALE=0 V_MISSING=0
  load_stamps
  V_ROWS=$S_N
  for ((i = 0; i < S_N; i++)); do
    rc=0; stamp_cmp "${SPATH[i]}" || rc=$?
    case $rc in
      0) ;;
      1)
        # every stamped column is compared: round-11 critic CE2 proved the bytes
        # column was dead data (a tampered value re-verified CLEAN)
        printf 'STALE %s sha=%s->%s lines=%s->%s bytes=%s->%s\n' \
          "${SPATH[i]}" "${CMP_OSHA:0:12}" "${CMP_NSHA:0:12}" "$CMP_OL" "$CMP_NL" "$CMP_OB" "$CMP_NB"
        V_STALE=$((V_STALE + 1))
        ;;
      2)
        f="$ROOT/${SPATH[i]}"
        if [[ -e $f ]]; then printf 'NOT-A-FILE %s\n' "${SPATH[i]}"; else printf 'MISSING %s\n' "${SPATH[i]}"; fi
        V_MISSING=$((V_MISSING + 1))
        ;;
    esac
  done
}

C_N=0 C_FAILED=0 C_POLICY=0 C_DEFER=0
# the nesting depth this run was started with: every claim command this gate
# spawns sees depth+1, which is what lets a nested audit detect itself
CLAIM_LEDGER_DEPTH_IN=${CLAIM_LEDGER_DEPTH:-0}
verify_claims() {
  local line id cmd expect want tmo note pc out last rc
  C_N=0 C_FAILED=0 C_POLICY=0 C_DEFER=0
  [[ -f $CLAIMS ]] || die "claims file not found: $CLAIMS"
  while IFS= read -r line || [[ -n ${line:-} ]]; do
    [[ -z ${line:-} || ${line:0:1} == '#' ]] && continue
    split_tab "$line"
    [[ $TF_N -ge 5 && $TF_N -le 6 ]] || die "malformed claims row (fields=$TF_N)"
    id=${TF[0]} cmd=${TF[1]} expect=${TF[2]} want=${TF[3]} tmo=${TF[4]} note=${TF[5]:-}
    [[ -n $id && -n $cmd && -n $expect && -n $want && -n $tmo ]] || die "malformed claims row (empty field)"
    [[ $want =~ ^[0-9]+$ ]] || die "claims row $id: exit must be numeric, got '$want'"
    [[ $tmo =~ ^[1-9][0-9]*$ ]] || die "claims row $id: timeout must be a positive integer, got '$tmo'"
    # a bare anchor matches an empty last line: `expect=^` would pass a claim
    # whose command printed nothing (round-11 planner, observed)
    [[ $expect =~ [^\^\$] ]] || die "claims row $id: expect must assert a literal, not just anchors"
    C_N=$((C_N + 1))
    if [[ $note == *'[substrate]'* ]] && ! substrate_present; then
      printf 'DEFER %s reason=substrate-absent\n' "$id"
      C_DEFER=$((C_DEFER + 1)); continue
    fi
    if ! pc=$(policy_check "$cmd"); then
      printf 'POLICY %s reason=%s\n' "$id" "$pc"
      C_POLICY=$((C_POLICY + 1))
      continue
    fi
    rc=0
    out=$(cd "$ROOT" && CLAIM_LEDGER_DEPTH=$((CLAIM_LEDGER_DEPTH_IN + 1)) \
      timeout -k 5 "$tmo" bash -o pipefail -c "$cmd" 2>&1) || rc=$?
    if [[ $rc -eq 124 || $rc -eq 137 ]]; then
      printf 'FAIL %s reason=timeout exit=%s tmo=%s\n' "$id" "$rc" "$tmo"
      C_FAILED=$((C_FAILED + 1)); continue
    fi
    if [[ $rc -ne $want ]]; then
      printf 'FAIL %s reason=exit-mismatch exit=%s want=%s\n' "$id" "$rc" "$want"
      C_FAILED=$((C_FAILED + 1)); continue
    fi
    last=$(printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | tail -n 1 || true)
    if [[ -z $last ]]; then
      printf 'FAIL %s reason=no-output exit=%s\n' "$id" "$rc"
      C_FAILED=$((C_FAILED + 1)); continue
    fi
    if [[ ! $last =~ $expect ]]; then
      printf 'FAIL %s reason=verdict-not-final exit=%s\n' "$id" "$rc"
      C_FAILED=$((C_FAILED + 1)); continue
    fi
  done <"$CLAIMS"
}

# --- citations ---------------------------------------------------------------
# Checked classes (shape-based; anything else is a reference, not a path — see
# the header §Bounds). A citation that cannot resolve must be labelled dead on
# its own line (marker: scratch | ephemeral | relocat | formerly | no longer |
# removed | renamed | historical), otherwise it is a defect.
#   corpus/…            → $ROOT/…
#   knowledge/… lessons/… → $ROOT/corpus/…   (the two corpus shorthands)
#   <lane>-shokunin/…   → $ROOT/../…         (sibling lane repo)
#   ufo/… .ufo/…        → $ROOT/../.ufo/…   (main-repo .ufo tree)
#   root docs exact     → $ROOT/…
EPHEM_RE='(local|artifact|agent|proc)://[^)`,;[:space:]]*'
MARK_RE='scratch|ephemeral|relocat|formerly|no longer|removed|renamed|historical'

cite_class() {
  case "$1" in
    corpus/*) printf 'local' ;;
    knowledge/*|lessons/*) printf 'shorthand' ;;
    ufo/*|.ufo/*) printf 'ufo' ;;
    *-shokunin/*) printf 'sibling' ;;
    SKILL.md|SCORECARD.md|PROVINCE.md|SHONEN.md|LOG.md|AGENTS.md) printf 'rootdoc' ;;
    *) return 1 ;;
  esac
}

cite_target() { # prints the resolved absolute path, or nothing
  local t=$1 r
  case "$t" in
    corpus/*|SKILL.md|SCORECARD.md|PROVINCE.md|SHONEN.md|LOG.md|AGENTS.md)
      [[ -e $ROOT/$t ]] && printf '%s' "$ROOT/$t" ;;
    knowledge/*|lessons/*)
      [[ -e $ROOT/corpus/$t ]] && printf '%s' "$ROOT/corpus/$t" ;;
    .ufo/*)
      r=${t#.ufo/}; [[ -e $ROOT/../.ufo/$r ]] && printf '%s' "$ROOT/../.ufo/$r" ;;
    ufo/*)
      r=${t#ufo/}; [[ -e $ROOT/../.ufo/$r ]] && printf '%s' "$ROOT/../.ufo/$r" ;;
    *-shokunin/*)
      [[ -e $ROOT/../$t ]] && printf '%s' "$ROOT/../$t" ;;
  esac
}

# Normalize a whitespace token into a citation candidate: strip backticks,
# quotes and parens, `./`, and line refs (`:N`, `:N-M`, `:N,:M`), repeating
# until stable — a whole-line scan sees `` `path`:12 `` and `(path:12)`.
NTOK=""
norm_tok() {
  local t=$1 prev=""
  while [[ $t != "$prev" ]]; do
    prev=$t
    t=${t#\`};  t=${t%\`}
    t=${t#\"};  t=${t%\"}
    t=${t#\'};  t=${t%\'}
    t=${t#(};   t=${t%)}
    t=${t#./}
    if [[ $t =~ ^(.*)[,:][0-9]+([-,][0-9]+)*$ ]]; then t=${BASH_REMATCH[1]}; fi
    t=${t%%#*}                      # anchor fragments (`path.md#section`)
    t=${t%%\?*}                     # query strings (`path.md?plain=1`)
    t=${t%%=*}                      # value suffixes (`path`=4)
    t=${t%\'s}; t=${t%’s}            # possessive suffixes (`path`'s)
    # punctuation is stripped INSIDE the loop: `` `path`: `` needs the colon
    # gone before the backtick can be seen as trailing (round-11 reviewer addendum)
    t=${t%[.,;:]}
    t=${t%[,:]}
  done
  NTOK=$t
}

# The checked doc set: explicit `--docs`, else every live doc that carries
# evidence pointers. ONE definition for two consumers (citations, idref): a
# second copy is exactly how two scans over "the docs" silently diverge.
DOCS_LIST=()
default_docs() {
  DOCS_LIST=()
  if [[ -n $DOCS_ARG ]]; then
    # shellcheck disable=SC2206
    DOCS_LIST=($DOCS_ARG)
  else
    shopt -s nullglob
    DOCS_LIST=("$ROOT/AGENTS.md" "$ROOT/LOG.md" "$ROOT/PROVINCE.md" "$ROOT/SCORECARD.md" "$ROOT/SHONEN.md" "$ROOT/SKILL.md" "$ROOT/corpus/README.md")
    DOCS_LIST+=("$ROOT"/corpus/knowledge/*.md "$ROOT"/corpus/lessons/*.md)
  fi
}

CIT_CITES=0 CIT_DOCS=0 CIT_UNRESOLVED=0 CIT_EPHEMERAL=0 CIT_MARKED=0
citations() {
  local doc l lineno content t tok cls marked pre rest post grp ok alt
  local -a DOCS=()
  CIT_CITES=0 CIT_DOCS=0 CIT_UNRESOLVED=0 CIT_EPHEMERAL=0 CIT_MARKED=0
  default_docs
  DOCS=("${DOCS_LIST[@]}")
  for doc in "${DOCS[@]}"; do
    [[ -f $doc ]] || die "doc not found: $doc"
    CIT_DOCS=$((CIT_DOCS + 1))
    # session-scoped URIs, anywhere on the line (backticked or not)
    while IFS= read -r l; do
      lineno=${l%%:*}; content=${l#*:}
      if [[ ${content,,} =~ $MARK_RE ]]; then marked=1; else marked=0; fi
      while IFS= read -r t; do
        [[ -n $t ]] || continue
        CIT_CITES=$((CIT_CITES + 1))
        if [[ $marked -eq 1 ]]; then
          printf 'LABELED %s:%s %s (session URI, labelled on its line)\n' "${doc#"$ROOT/"}" "$lineno" "$t"
          CIT_MARKED=$((CIT_MARKED + 1))
        else
          printf 'EPHEMERAL %s:%s %s\n' "${doc#"$ROOT/"}" "$lineno" "$t"
          CIT_EPHEMERAL=$((CIT_EPHEMERAL + 1))
        fi
      done < <(printf '%s' "$content" | grep -oE "$EPHEM_RE" || true)
    done < <(grep -nE 'local://|artifact://|agent://|proc://' "$doc" || true)
    # checked-class path citations anywhere on the line, not only inside code
    # spans (round-11 scout-citations: span-only left 153 class-shaped tokens
    # invisible, dominated by command arguments and root-doc names in prose)
    while IFS= read -r l; do
      lineno=${l%%:*}; content=${l#*:}
      if [[ ${content,,} =~ $MARK_RE ]]; then marked=1; else marked=0; fi
      while IFS= read -r t; do
        norm_tok "$t"; tok=$NTOK
        [[ $tok == *'*'* || $tok == *'<'* || $tok == *'…'* || $tok == *'...'* ]] && continue
        cls=$(cite_class "$tok") || continue
        CIT_CITES=$((CIT_CITES + 1))
        if [[ $tok == *'{'* && $tok == *'}'* ]]; then
          # a brace set names several files (e.g. lessons/round-{4,5}.md);
          # every alternative must resolve
          pre=${tok%%\{*}; rest=${tok#*\{}; post=${rest#*\}}; grp=${rest%%\}*}
          ok=1
          for alt in ${grp//,/ }; do
            alt=${alt//[[:space:]]/}   # `{4, 5}` — trim, else a space breaks the path
            [[ -n $(cite_target "${pre}${alt}${post}") ]] || ok=0
          done
          [[ $ok -eq 1 ]] && continue
        elif [[ -n $(cite_target "$tok") ]]; then
          continue
        fi
        # NOTE: the span is split on whitespace first (the `while IFS= read -r t`
        # above), so every token in a span is checked, not only the first —
        # round-11 critic CE3 proved `bash corpus/nope.md` and a two-token span
        # were invisible before this.

        if [[ $marked -eq 1 ]]; then
          printf 'LABELED %s:%s %s (unresolved, labelled on its line)\n' "${doc#"$ROOT/"}" "$lineno" "$tok"
          CIT_MARKED=$((CIT_MARKED + 1))
        else
          printf 'UNRESOLVED %s:%s %s (%s)\n' "${doc#"$ROOT/"}" "$lineno" "$tok" "$cls"
          CIT_UNRESOLVED=$((CIT_UNRESOLVED + 1))
        fi
      # spaces inside a brace set are not token separators: `{4, 5}` is one path
      done < <(printf '%s' "$content" |
        sed -E ':a; s/\{([^}]*)[[:space:]]+([^}]*)\}/{\1\2}/g; ta' |
        tr ' ' '\n' | tr '\t' '\n' || true)
    done < <(grep -nE '.' "$doc" || true)
  done
}

# --- id references -----------------------------------------------------------
# `R<digits>-<digits>` is this corpus's claim-id vocabulary. A cited id must be
# a ROW (a comment line naming an id does not create one) and the id universe
# must be non-empty — an empty ledger would turn every citation into a
# MISSING-ID and the whole gate into a false failure, so it is a setup error.
LID=(); LID_N=0
load_ids() {
  local line
  LID=(); LID_N=0
  [[ -f $CLAIMS ]] || die "claims file not found: $CLAIMS"
  while IFS= read -r line || [[ -n ${line:-} ]]; do
    [[ -z ${line:-} || ${line:0:1} == '#' ]] && continue
    split_tab "$line"
    [[ -n ${TF[0]:-} ]] || continue
    LID+=("${TF[0]}"); LID_N=$((LID_N + 1))
  done <"$CLAIMS"
  [[ $LID_N -gt 0 ]] || die "no claim rows in $CLAIMS (refusing to resolve ids against an empty ledger)"
}

is_row() {
  local k
  for k in "${LID[@]}"; do [[ $k == "$1" ]] && return 0; done
  return 1
}

# An id is a WHOLE WORD in the id vocabulary. Extracting bare `R[0-9]+-[0-9]+`
# substrings let `R12-03a`, `xR12-01` and any other suffixed/prefixed form pass
# as their prefix (round-13 mutation lane M5, demonstrated by substituting an
# id-shaped word whose prefix row existed), so the word is what gets resolved.
# Bound, stated: the vocabulary is upper-case `R`; a lower-case `r13-99` is not
# an id token and is not scanned for.
IDWORD_RE='[A-Za-z0-9_-]*R[0-9]+-[0-9]+[A-Za-z0-9_-]*'
line_ids() { printf '%s' "$1" | grep -oE "$IDWORD_RE" || true; }

# A document may quote a fabricated id to explain the check itself; the citation
# scan's rule ("a dead pointer must be labelled dead where it is cited") applies
# here too, with the same line-granular bound, plus `fabricated|illustrative|
# example` because that is how a doc says "this token is an example". A labelled
# id is COUNTED (`labeled_ids`), never silently tolerated: this gate's own
# contract document and lesson cite the fabricated ids that were used as
# before-evidence, and the first run of the audit failed on them.
ID_MARK_RE="$MARK_RE|fabricated|illustrative|example"

IDX_TOKENS=0 IDX_MISSING=0 IDX_CITED=0 IDX_ORPHANS=0 IDX_LABELED=0
idref_audit() {
  local doc l lineno content id marked
  local -a DOCS=() CITED=()
  IDX_TOKENS=0 IDX_MISSING=0 IDX_CITED=0 IDX_ORPHANS=0 IDX_LABELED=0
  load_ids
  default_docs
  DOCS=("${DOCS_LIST[@]}")
  for doc in "${DOCS[@]}"; do
    [[ -f $doc ]] || die "doc not found: $doc"
    while IFS= read -r l; do
      lineno=${l%%:*}; content=${l#*:}
      if [[ ${content,,} =~ $ID_MARK_RE ]]; then marked=1; else marked=0; fi
      while IFS= read -r id; do
        [[ -n $id ]] || continue
        IDX_TOKENS=$((IDX_TOKENS + 1))
        if is_row "$id"; then
          [[ " ${CITED[*]-} " == *" $id "* ]] || CITED+=("$id")
        elif [[ $marked -eq 1 ]]; then
          printf 'LABELED-ID %s:%s %s (labelled on its line)\n' "${doc#"$ROOT/"}" "$lineno" "$id"
          IDX_LABELED=$((IDX_LABELED + 1))
        else
          printf 'MISSING-ID %s:%s %s\n' "${doc#"$ROOT/"}" "$lineno" "$id"
          IDX_MISSING=$((IDX_MISSING + 1))
        fi
      done < <(line_ids "$content")
    done < <(grep -nE 'R[0-9]+-[0-9]+' "$doc" || true)
  done
  IDX_CITED=${#CITED[@]}
  for id in "${LID[@]}"; do
    if [[ " ${CITED[*]-} " != *" $id "* ]]; then
      IDX_ORPHANS=$((IDX_ORPHANS + 1))
      [[ $ORPHANS -eq 1 ]] && printf 'ORPHAN %s (row cited by no document in the checked set)\n' "$id"
    fi
  done
  return 0
}

# --- scorecard cells ---------------------------------------------------------
# A cell is POINTED when it names an artifact a reader can re-check: a resolving
# claim row (a re-runnable command) or a path in `stamps.tsv` (the hash-pinned
# revision that recorded the number). `row_pointed` and `stamp_pointed` are
# independent counts, so the summary shows how many scores rest on a live
# command rather than on a frozen document — the distinction round 11 asked for.
# Checked cells are ROUND tables only: the `Retired` table and any other section
# are prose, and the six axis names are the vocabulary of a score card.
AXES_RE='^(depth|coverage|operability|freshness|calibration|adjacency)$'
SEC_RE='^## Round [0-9]+ — (pre|post)-move'
CL_CELLS=0 CL_ROWS=0 CL_STAMPS=0 CL_UNCITED=0
CL_STALE=0 CL_ROWS_RUN=0
CEL_IDS=(); CEL_PATHS=()
SEC_SEEN=()

# Every recognised round section must carry all six axes, once each. A section
# that has lost or mis-spelled a row (a bolded `**Depth**`, a split, a deleted
# row) would silently shrink the checked set, and the global non-zero count can
# never see one section losing rows while another keeps it positive (round-13
# planner T2-1/T2-2). This is what makes a formatting miss loud instead of green.
section_check() { # SECTION-HEADING
  local ax missing="" n=${#SEC_SEEN[@]}
  for ax in depth coverage operability freshness calibration adjacency; do
    [[ " ${SEC_SEEN[*]-} " == *" $ax "* ]] || missing="$missing $ax"
  done
  [[ -z $missing && $n -eq 6 ]] ||
    die "scorecard section '$1' does not carry all six axes exactly once (found=$n missing=${missing# })"
  return 0
}

cells() {
  local l lineno content rest f1 tok d in_docs=0 in_set=0 has_row has_stamp sec_head=""
  local -a F=()
  CL_CELLS=0 CL_ROWS=0 CL_STAMPS=0 CL_UNCITED=0
  CEL_IDS=(); CEL_PATHS=(); SEC_SEEN=()
  [[ -f $SCORECARD ]] || die "scorecard not found: $SCORECARD"
  load_stamps
  # the scorecard's own ids are resolved by the id audit, so the scorecard must
  # be inside the doc set it scanned: otherwise a bogus id in a cell could pass
  for d in "${DOCS_LIST[@]}"; do [[ $d == "$SCORECARD" ]] && in_docs=1; done
  [[ $in_docs -eq 1 ]] ||
    die "scorecard is not in the checked doc set: $SCORECARD (its ids must be resolved against $CLAIMS; pass --docs including it)"
  while IFS= read -r l; do
    lineno=${l%%:*}; content=${l#*:}
    if [[ $content == '## '* ]]; then
      # section gate: only Round <N> pre/post-move tables are score cards. The
      # `Retired` table and every other section are prose, not scores. A ROUND
      # heading that does not match the expected shape is a setup error, not a
      # section to skip: a typo (`## Round 13 pre-move`, a colon, an en-dash)
      # would silently drop six cells while the global count stayed positive.
      [[ $in_set -eq 1 ]] && section_check "$sec_head"
      SEC_SEEN=()
      if [[ $content == '## Round '* && ! $content =~ $SEC_RE ]]; then
        die "unrecognised round heading in $SCORECARD: '$content' (expected '## Round <N> — pre-move|post-move')"
      fi
      if [[ $content =~ $SEC_RE ]]; then in_set=1; sec_head=$content; else in_set=0; sec_head=""; fi
      continue
    fi
    [[ $in_set -eq 1 && $content == '|'* ]] || continue
    rest=${content#|}; rest=${rest%|}
    IFS='|' read -r -a F <<<"$rest"
    f1=${F[0]:-}
    f1=${f1//[[:space:]]/}; f1=${f1//\*/}
    [[ $f1 =~ $AXES_RE ]] || continue
    CL_CELLS=$((CL_CELLS + 1))
    SEC_SEEN+=("$f1")
    has_row=0; has_stamp=0
    while IFS= read -r tok; do
      [[ -n $tok ]] || continue
      if is_row "$tok"; then
        has_row=1
        [[ " ${CEL_IDS[*]-} " == *" $tok "* ]] || CEL_IDS+=("$tok")
      fi
    done < <(line_ids "$content")
    while IFS= read -r tok; do
      [[ -n $tok ]] || continue
      norm_tok "$tok"; tok=$NTOK
      # ellipsis/placeholder tokens are shapes, not artifacts (same skip as the
      # citation scan, which treats them as references rather than paths)
      [[ $tok == *'…'* || $tok == *'...'* || $tok == *'*'* ]] && continue
      if stamp_index "$tok" >/dev/null; then
        has_stamp=1
        [[ " ${CEL_PATHS[*]-} " == *" $tok "* ]] || CEL_PATHS+=("$tok")
      fi
    done < <(printf '%s' "$content" | tr ' ' '\n' | tr '\t' '\n' || true)
    [[ $has_row -eq 1 ]] && CL_ROWS=$((CL_ROWS + 1))
    [[ $has_stamp -eq 1 ]] && CL_STAMPS=$((CL_STAMPS + 1))
    if [[ $has_row -eq 0 && $has_stamp -eq 0 ]]; then
      printf 'UNCITED %s:%s %s (no resolving row id and no pinned artifact)\n' \
        "${SCORECARD#"$ROOT/"}" "$lineno" "$f1"
      CL_UNCITED=$((CL_UNCITED + 1))
    fi
  done < <(grep -nE '.' "$SCORECARD" || true)
  [[ $in_set -eq 1 ]] && section_check "$sec_head"
  [[ $CL_CELLS -gt 0 ]] ||
    die "no scored cells found in $SCORECARD (refusing to report coverage over a scorecard with no round tables)"
  # Non-vacuity: if NO cell cites a claim row, the strongest tooth (a re-run of
  # the cited measurements) has nothing to bite and a green run would mean only
  # "some pointers resolve" — the tautology this audit exists to avoid.
  [[ $CL_ROWS -gt 0 ]] ||
    die "no cell in $SCORECARD cites a claim row (nothing to re-run; the audit would be vacuous)"
  return 0
}

# The teeth: a pointer is only evidence if the thing it points at still holds.
# (a) re-run the cited claim rows through the ordinary claims machinery — the
# same exit-equality + last-line rule, so a cell cannot rest on a row that fails
# today; (b) re-compare the cited pinned artifacts against their rows, so a cell
# cannot rest on a revision that has since moved. Membership alone was the
# round-13 critic's executed counterexample: a poisoned stamps row (deadbeef/0/0)
# and a cell citing an unrelated row both passed a membership-only audit.
CL_STALE=0 CL_ROWS_RUN=0 CL_SELF_SKIP=0
cells_evidence() {
  local line p rc saved
  CL_STALE=0 CL_ROWS_RUN=0 CL_SELF_SKIP=0
  if [[ ${#CEL_IDS[@]} -gt 0 ]]; then
    STAMP_TMP=$(mktemp) || die "mktemp failed"
    while IFS= read -r line || [[ -n ${line:-} ]]; do
      [[ -z ${line:-} || ${line:0:1} == '#' ]] && continue
      split_tab "$line"
      [[ " ${CEL_IDS[*]} " == *" ${TF[0]:-} "* ]] || continue
      # a row that re-invokes this gate is NOT re-run here: `cells` is reachable
      # from a claim row, so re-running it from inside `cells` is how a bounded
      # audit would become an unbounded one. Reported, never silent. The test is
      # the SCRIPT (`claim-ledger.sh`), not the stem: a row that merely greps
      # `corpus/claim-ledger.tsv` is a reader, not a re-invocation.
      if [[ ${TF[1]:-} == *claim-ledger.sh* ]]; then
        printf 'SKIP-SELF %s (row invokes this gate; not re-run from inside the cell audit)\n' "${TF[0]}"
        CL_SELF_SKIP=$((CL_SELF_SKIP + 1))
        continue
      fi
      printf '%s\n' "$line" >>"$STAMP_TMP"
    done <"$CLAIMS"
    saved=$CLAIMS
    CLAIMS=$STAMP_TMP
    verify_claims
    CLAIMS=$saved
    rm -f -- "$STAMP_TMP"; STAMP_TMP=""
    CL_ROWS_RUN=$C_N
  fi
  for p in "${CEL_PATHS[@]}"; do
    rc=0; stamp_cmp "$p" || rc=$?
    case $rc in
      0) ;;
      1)
        printf 'STALE-POINTER %s sha=%s->%s lines=%s->%s bytes=%s->%s\n' \
          "$p" "${CMP_OSHA:0:12}" "${CMP_NSHA:0:12}" "$CMP_OL" "$CMP_NL" "$CMP_OB" "$CMP_NB"
        CL_STALE=$((CL_STALE + 1))
        ;;
      2) printf 'MISSING-POINTER %s\n' "$p"; CL_STALE=$((CL_STALE + 1)) ;;
    esac
  done
  return 0
}

# --- knowledge entries -------------------------------------------------------
# A knowledge entry is the lane's primary product: prose whose host-fact base
# must be re-runnable. Before round 14 nothing linked the two: 16 of 17 entries
# named no claim row, 10 of 17 were not revision-pinned, and no command could
# tell a reader whether that had changed. `docs` makes the link a declaration
# and the gap countable.
#
# Two forms, parsed strictly (a third form is a setup error, not a third class):
#   `Reverify: R11-04, R11-05`                      ids, comma+space separated
#   `Reverify: by-hand: <class> — <reason ≥24>`     the explicit unverifiable set
# Exit 2 = shape (no entries, ≥2 declarations, malformed value, unknown class,
# short reason); exit 1 = defect (UNDECLARED, MISSING-ID, UNPINNED, RATIO).
BYHAND_CLASSES='control-plane-scratch|opencode-internal|interactive-only|vault-refusal'
DA_N=0 DA_ROWS=0 DA_BYHAND=0 DA_UNDECLARED=0 DA_MISSING=0 DA_UNPINNED=0
DA_DUPLICATE=0
DA_FLOOR=0
doc_audit() {
  local dir=${1:-corpus/knowledge} rel f line val ids_re class reason id
  local nrows byhand n key near
  local -a FILES=() DECLS=() REASONS=()
  DA_N=0 DA_ROWS=0 DA_BYHAND=0 DA_UNDECLARED=0 DA_MISSING=0 DA_UNPINNED=0
  DA_DUPLICATE=0 DA_FLOOR=0
  [[ $dir == /* ]] && die "entries dir must be relative to --root, got an absolute path: $dir"
  [[ $dir == *..* ]] && die "entries dir contains '..': $dir"
  [[ -d $ROOT/$dir ]] || die "entries dir not found: $ROOT/$dir"
  ids_re='^R[0-9]+-[0-9]+(, ?R[0-9]+-[0-9]+)*$'
  # a directory with no entries would report CLEAN over an empty surface — the
  # vacuity class this gate has refused since round 11
  shopt -s nullglob
  FILES=("$ROOT/$dir"/*.md)
  # `*.md` does not match a dotfile, so a hidden entry would be invisible rather
  # than wrong (round-14 mutation lane): refuse it loudly instead. Checked
  # BEFORE the empty-surface refusal, so a dir of only hidden entries reports
  # the hidden file rather than "no entries".
  local -a HIDDEN=("$ROOT/$dir"/.[!.]*.md)
  [[ ${#HIDDEN[@]} -eq 0 ]] ||
    die "hidden entry under $dir: ${HIDDEN[0]#"$ROOT/"} (dotfiles are not audited by the *.md glob; remove it or rename it)"
  [[ ${#FILES[@]} -gt 0 ]] || die "no knowledge entries under $dir (refusing a clean run over an empty surface)"
  load_ids
  load_stamps
  for f in "${FILES[@]}"; do
    rel=${f#"$ROOT/"}
    DA_N=$((DA_N + 1))
    DECLS=()
    # `grep -n` so a second declaration can be named with its line
    while IFS= read -r line; do [[ -n $line ]] && DECLS+=("$line"); done \
      < <(grep -nE '^Reverify: ' "$f" || true)
    n=${#DECLS[@]}
    # a malformed spelling (`Reverify:`, `Reverify :`, a detached colon) would
    # otherwise be invisible and read as UNDECLARED; every line that STARTS with
    # `Reverify` must be a declaration (round-14 planner finding)
    near=$(grep -cE '^Reverify' "$f" || true)
    [[ $near -eq $n ]] ||
      die "entry $rel: $((near - n)) line(s) start with 'Reverify' but are not 'Reverify: ' declarations"
    nrows=0; byhand="-"
    if [[ $n -eq 0 ]]; then
      printf 'UNDECLARED %s (no Reverify line)\n' "$rel"
      DA_UNDECLARED=$((DA_UNDECLARED + 1))
    elif [[ $n -gt 1 ]]; then
      die "entry $rel carries $n Reverify lines (exactly one required)"
    else
      val=${DECLS[0]#*:}; val=${val#Reverify: }
      if [[ $val =~ $ids_re ]]; then
        # `tr` splits the id list; the strict form already refused anything else
        for id in $(printf '%s' "$val" | tr ',' ' '); do
          [[ -n $id ]] || continue
          # `row_linked` counts entries naming at least one RESOLVING row: a
          # fabricated id must not raise the ratio while the run is BROKEN
          if is_row "$id"; then
            nrows=$((nrows + 1))
          else
            printf 'MISSING-ID %s %s (declared id is not a claim row)\n' "$rel" "$id"
            DA_MISSING=$((DA_MISSING + 1))
          fi
        done
      elif [[ $val == 'by-hand: '* ]]; then
        reason=${val#'by-hand: '}
        [[ $reason == *' — '* ]] ||
          die "entry $rel: by-hand declaration needs the ' — ' separator: $val"
        class=${reason%% — *}
        reason=${reason#* — }
        [[ $class =~ ^($BYHAND_CLASSES)$ ]] ||
          die "entry $rel: unknown by-hand class '$class' (allowed: ${BYHAND_CLASSES//|/, })"
        # trim surrounding whitespace: padding must not reach the 24-char floor
        # (round-14 mutation lane: an empty reason padded to 24 spaces)
        reason=${reason#"${reason%%[![:space:]]*}"}
        reason=${reason%"${reason##*[![:space:]]}"}
        [[ ${#reason} -ge 24 ]] ||
          die "entry $rel: by-hand reason is ${#reason} chars (the stated floor is 24): $reason"
        byhand=$class
        DA_BYHAND=$((DA_BYHAND + 1))
        # N identical reasons mean the class was not reasoned per entry — the
        # cheapest rubber stamp (round-14 critic's executed fixture). Compared
        # case-folded and whitespace-collapsed.
        key=$(printf '%s' "$reason" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' ' ')
        if [[ " ${REASONS[*]-} " == *" $key "* ]]; then
          printf 'DUPLICATE-REASON %s (identical by-hand reason already used)\n' "$rel"
          DA_DUPLICATE=$((DA_DUPLICATE + 1))
        else
          REASONS+=("$key")
        fi
      else
        die "entry $rel: Reverify value matches neither form: $val"
      fi
    fi
    # a revision pin, for every entry: a by-hand measurement recorded at an
    # unknown revision is the round-9 failure (a claim nothing can re-check)
    if ! stamp_index "$rel" >/dev/null; then
      printf 'UNPINNED %s (knowledge entry is not a row in the stamps file)\n' "$rel"
      DA_UNPINNED=$((DA_UNPINNED + 1))
    fi
    DA_ROWS=$((DA_ROWS + (nrows > 0 ? 1 : 0)))
    printf 'ENTRY %s row_linked=%d by_hand=%s\n' "$rel" "$nrows" "$byhand"
  done
  DA_FLOOR=$(((DA_N + 1) / 2))
  printf 'DOC_AUDIT_RATIO: row_linked=%d/%d floor=%d by_hand=%d duplicate_reasons=%d\n' \
    "$DA_ROWS" "$DA_N" "$DA_FLOOR" "$DA_BYHAND" "$DA_DUPLICATE"
  return 0
}

case "$MODE" in
  stamp)
    stamp
    ;;
  verify)
    verify_stamps
    verify_claims
    idref_audit
    if [[ $C_POLICY -gt 0 ]]; then
      printf 'CLAIM_LEDGER: POLICY (claims=%d policy=%d stamped=%d)\n' "$C_N" "$C_POLICY" "$V_ROWS"
      exit 2
    fi
    if [[ $C_FAILED -gt 0 || $V_STALE -gt 0 || $V_MISSING -gt 0 || $IDX_MISSING -gt 0 ]]; then
      printf 'CLAIM_LEDGER: FAIL (claims=%d failed=%d deferred=%d stamped=%d stale=%d missing=%d unresolved_ids=%d labeled_ids=%d)\n' \
        "$C_N" "$C_FAILED" "$C_DEFER" "$V_ROWS" "$V_STALE" "$V_MISSING" "$IDX_MISSING" "$IDX_LABELED"
      exit 1
    fi
    printf 'CLAIM_LEDGER: CLEAN (claims=%d deferred=%d stamped=%d ids=%d cited=%d labeled_ids=%d orphans=%d)\n' \
      "$C_N" "$C_DEFER" "$V_ROWS" "$LID_N" "$IDX_CITED" "$IDX_LABELED" "$IDX_ORPHANS"
    ;;
  docs)
    doc_audit "${POS[0]:-corpus/knowledge}"
    if [[ $DA_UNDECLARED -gt 0 || $DA_MISSING -gt 0 || $DA_UNPINNED -gt 0 || $DA_DUPLICATE -gt 0 || $((DA_ROWS * 2)) -lt $DA_N ]]; then
      printf 'DOC_AUDIT: BROKEN (entries=%d row_linked=%d by_hand=%d undeclared=%d missing_ids=%d unpinned=%d duplicate_reasons=%d floor=%d)\n' \
        "$DA_N" "$DA_ROWS" "$DA_BYHAND" "$DA_UNDECLARED" "$DA_MISSING" "$DA_UNPINNED" "$DA_DUPLICATE" "$DA_FLOOR"
      exit 1
    fi
    printf 'DOC_AUDIT: CLEAN (entries=%d row_linked=%d by_hand=%d undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)\n' \
      "$DA_N" "$DA_ROWS" "$DA_BYHAND"
    ;;
  cells)
    # the id audit runs first: it is what resolves the ids a cell cites, and its
    # doc set must therefore contain the scorecard (cells refuses otherwise)
    idref_audit
    cells
    cells_evidence
    if [[ $C_POLICY -gt 0 ]]; then
      printf 'CELL_AUDIT: POLICY (cells=%d row_pointed=%d stamp_pointed=%d policy=%d)\n' \
        "$CL_CELLS" "$CL_ROWS" "$CL_STAMPS" "$C_POLICY"
      exit 2
    fi
    if [[ $CL_UNCITED -gt 0 || $IDX_MISSING -gt 0 || $C_FAILED -gt 0 || $CL_STALE -gt 0 ]]; then
      printf 'CELL_AUDIT: BROKEN (cells=%d row_pointed=%d stamp_pointed=%d uncited=%d missing_ids=%d rows_run=%d row_deferred=%d row_failures=%d stale_pointers=%d self_skipped=%d orphans=%d)\n' \
        "$CL_CELLS" "$CL_ROWS" "$CL_STAMPS" "$CL_UNCITED" "$IDX_MISSING" "$CL_ROWS_RUN" "$C_DEFER" "$C_FAILED" "$CL_STALE" "$CL_SELF_SKIP" "$IDX_ORPHANS"
      exit 1
    fi
    printf 'CELL_AUDIT: CLEAN (cells=%d row_pointed=%d stamp_pointed=%d uncited=0 missing_ids=0 rows_run=%d row_deferred=%d row_failures=0 stale_pointers=0 self_skipped=%d orphans=%d)\n' \
      "$CL_CELLS" "$CL_ROWS" "$CL_STAMPS" "$CL_ROWS_RUN" "$C_DEFER" "$CL_SELF_SKIP" "$IDX_ORPHANS"
    ;;
  citations)
    citations
    if [[ $CIT_UNRESOLVED -gt 0 || $CIT_EPHEMERAL -gt 0 ]]; then
      printf 'CITATION_GATE: BROKEN (cites=%d docs=%d unresolved=%d ephemeral=%d labeled=%d)\n' \
        "$CIT_CITES" "$CIT_DOCS" "$CIT_UNRESOLVED" "$CIT_EPHEMERAL" "$CIT_MARKED"
      exit 1
    fi
    printf 'CITATION_GATE: CLEAN (cites=%d docs=%d unresolved=0 ephemeral=0 labeled=%d)\n' \
      "$CIT_CITES" "$CIT_DOCS" "$CIT_MARKED"
    ;;
  selftest)
    SELFTEST=1
    ;;
esac

# --- selftest ----------------------------------------------------------------
if [[ ${SELFTEST:-0} -eq 1 ]]; then
  S=$(mktemp -d); trap 'rm -rf -- "$S"' EXIT
  # The selftest's cases invoke this script's `verify` against a SCRATCH root and
  # scratch claims — the one nested audit that cannot recurse into the real
  # ledger — so the nesting marker is cleared here. A *claim row* cannot do this:
  # the refusal is what makes the bound explicit, and R11-09 (this very selftest,
  # run as a claim row) is the regression test for the interaction.
  unset CLAIM_LEDGER_DEPTH
  CLAIM_LEDGER_DEPTH_IN=0
  R="$S/inner"
  mkdir -p "$R/corpus/docs" "$R/corpus/knowledge" "$R/corpus/lessons" "$S/kagi-selftest" "$S/.ufo/reports"
  printf 'EXPECTED\n' >"$R/corpus/ok.txt"
  printf '#!/usr/bin/env bash\nsleep 30\n' >"$R/corpus/sleep.sh"
  printf '#!/usr/bin/env bash\nprintf "CLAIM_OK\\ntrailer\\n"\n' >"$R/corpus/echo-two.sh"
  SHA_OK=$(sha256sum -- "$R/corpus/ok.txt"); SHA_OK=${SHA_OK%% *}
  printf 'corpus/ok.txt\t%s\t1\t9\n' "$SHA_OK" >"$R/stamps.tsv"
  printf '# only a comment\n' >"$R/stamps-empty.tsv"
  printf 'corpus/ok.txt\t%s\t99\t9\n' "$SHA_OK" >"$R/stamps-stale.tsv"
  printf 'corpus/ok.txt\t%s\t1\t999\n' "$SHA_OK" >"$R/stamps-bytes.tsv"
  printf 'corpus/ok.txt\t%s\t1\t9\ncorpus/absent.txt\tdeadbeefdeadbeef\t1\t1\n' "$SHA_OK" >"$R/stamps-missing.tsv"
  # the id audit scans the DEFAULT doc set (root docs + knowledge + lessons), so
  # those files must exist in the scratch root; the old fixtures never needed
  # them because verify touched no documents
  for f in AGENTS.md LOG.md PROVINCE.md SCORECARD.md SHONEN.md SKILL.md; do
    printf 'EXPECTED\n' >"$R/$f"
  done
  printf 'EXPECTED\n' >"$R/corpus/README.md"
  printf 'R1-01\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\tselftest\n' >"$R/claims-r.tsv"
  printf 'R2-01\tgrep -c EXPECTED corpus/absent.txt\t^1$\t1\t5\tselftest\n' >"$R/claims-r2.tsv"
  # a scorecard fixture is only checkable when it carries all six axes, so the
  # fixtures are generated: six FILE "depth-pointer" "coverage-pointer" …
  six() {
    local f=$1; shift
    local -a P=("$@")
    local i=0 ax
    { printf '## Round 1 — pre-move\n\n| Axis | Score | Evidence |\n|---|---|---|\n'
      for ax in depth coverage operability freshness calibration adjacency; do
        printf '| %s | 7 | %s |\n' "$ax" "${P[i]}"
        i=$((i + 1))
      done
    } >"$f"
  }
  # fenced block AND prose, both carrying an unknown id (the id scan is
  # line-oriented over every byte: no cell/fence filtering, planner T1-1)
  printf 'doc prose cites `R9-99` here\n\n```\nfence cites R9-98 too\n```\n' >"$R/corpus/docs/id-missing.md"
  printf 'doc cites row `R1-01` here\n' >"$R/corpus/docs/id-known.md"
  six "$R/sc-ok.md" '`corpus/ok.txt`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  six "$R/sc-uncited.md" '`R1-01`' 'self-scored, nothing to re-run' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  six "$R/sc-missing-id.md" '`R1-01`' '`R9-99`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  six "$R/sc-row-fails.md" '`R2-01`' '`R2-01`' '`R2-01`' '`R2-01`' '`R2-01`' '`R2-01`'
  six "$R/sc-stale-pointer.md" '`R1-01` and `corpus/ok.txt`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  six "$R/sc-numeric.md" '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  six "$R/sc-vacuous.md" '`corpus/ok.txt`' '`corpus/ok.txt`' '`corpus/ok.txt`' '`corpus/ok.txt`' '`corpus/ok.txt`' '`corpus/ok.txt`'
  six "$R/sc-retired.md" '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  printf '\n## Retired\n\n| Axis | Why |\n|---|---|\n| depth | saturated |\n' >>"$R/sc-retired.md"
  printf '# scorecard with no round tables at all\n' >"$R/sc-empty.md"
  # bolded and padded first cells are accepted; a five-axis section is not
  printf '## Round 1 — pre-move\n\n| Axis | Score | Evidence |\n|---|---|---|\n| **depth** | 7 | `R1-01` |\n|  coverage  | 6 | `R1-01` |\n| operability | 5 | `R1-01` |\n| freshness | 4 | `R1-01` |\n| calibration | 3 | `R1-01` |\n| adjacency | 2 | `R1-01` |\n' >"$R/sc-bold.md"
  printf '## Round 1 — pre-move\n\n| Axis | Score | Evidence |\n|---|---|---|\n| depth | 7 | `R1-01` |\n| coverage | 6 | `R1-01` |\n| operability | 5 | `R1-01` |\n| freshness | 4 | `R1-01` |\n| calibration | 3 | `R1-01` |\n' >"$R/sc-five.md"
  ln -sfn "$R/corpus/ok.txt" "$R/corpus/link.txt"
  printf 'corpus/link.txt\t%s\t1\t9\n' "$SHA_OK" >"$R/stamps-linkrow.tsv"
  # the score column itself carries digits that a stamps field also ends with
  # (`9<TAB>` occurred inside the lines column), which is how an unanchored
  # lookup made all 48 real cells look pinned to an artifact (round-13 probe)
  printf 'corpus/ok.txt\t%s\t9\t9\n' "$SHA_OK" >"$R/stamps-numeric.tsv"
  printf '## Round 1 — pre-move\n\n| Axis | Score | Evidence |\n|---|---|---|\n| depth | 9 | `R1-01` |\n| coverage | 9 | `R1-01` |\n| operability | 9 | `R1-01` |\n| freshness | 9 | `R1-01` |\n| calibration | 9 | `R1-01` |\n| adjacency | 9 | `R1-01` |\n' >"$R/sc-numeric.md"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\tselftest\n' >"$R/claims-pass.tsv"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^9$\t0\t5\tselftest\n' >"$R/claims-verdict.tsv"
  # an id named only in a ledger COMMENT is not a row (mutation lane M8), and an
  # id-shaped word with a prefix/suffix is not the id it starts with (M5)
  printf '# R5-05 is named only in this comment\nR1-01\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\tselftest\n' >"$R/claims-comment.tsv"
  printf 'R3-01\tbash corpus/claim-ledger.sh --selftest\t^SELFTEST: PASS\t0\t300\tselftest\nR1-01\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\tselftest\n' >"$R/claims-r3.tsv"
  printf 'doc cites R5-05, which exists only in a ledger comment\n' >"$R/corpus/docs/id-comment.md"
  printf 'doc cites R1-01a here\n' >"$R/corpus/docs/id-suffixed.md"
  printf 'doc cites xR1-01 here\n' >"$R/corpus/docs/id-prefixed.md"
  printf 'doc cites the range R1-01..99 here\n' >"$R/corpus/docs/id-range.md"
  printf 'this illustrative line quotes a fabricated id R7-07 on purpose\n' >"$R/corpus/docs/id-labeled.md"
  six "$R/sc-selfrow.md" '`R3-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`' '`R1-01`'
  # sentinel round 13: a stamps row that escapes the root (read side), and a round
  # heading that does not match the expected shape (silently dropped six cells)
  printf '../outside.txt\tdeadbeefdeadbeef\t1\t1\n' >"$R/stamps-dotdot.tsv"
  printf '/etc/hostname\tdeadbeefdeadbeef\t1\t1\n' >"$R/stamps-abs.tsv"
  printf '## Round 1 pre-move\n\n| Axis | Score | Evidence |\n|---|---|---|\n| depth | 7 | `R1-01` |\n' >"$R/sc-bad-heading.md"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^1$\t3\t5\tselftest\n' >"$R/claims-exit.tsv"
  printf 'c1\tbash corpus/sleep.sh\tDONE\t0\t1\tselftest\n' >"$R/claims-timeout.tsv"
  printf 'c1\tbash corpus/ok.txt; true\tEXPECTED\t0\t5\tselftest\n' >"$R/claims-meta.tsv"
  printf 'c1\top account list\tx\t0\t5\tselftest\n' >"$R/claims-op.tsv"
  printf 'c1\tgrep -q op corpus/ok.txt\tEXPECTED\t0\t5\tselftest\n' >"$R/claims-denied.tsv"
  printf 'c1\tgrep -q EXPECTED corpus/ok.txt\n' >"$R/claims-malformed.tsv"
  printf 'c1\tbash corpus/echo-two.sh\tCLAIM_OK\t0\t5\tselftest\n' >"$R/claims-two.tsv"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^\t0\t5\tselftest\n' >"$R/claims-anchor.tsv"
  printf 'c1\t\tEXPECTED\t0\t5\tselftest\n' >"$R/claims-emptycmd.tsv"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\tselftest\textra\tfused\n' >"$R/claims-fused.tsv"
  printf 'c1\tbash -c "o""p --version"\tX\t0\t5\tselftest\n' >"$R/claims-split.tsv"
  printf 'c1\ttest -e corpus/absent.txt\t.*\t1\t5\tselftest\n' >"$R/claims-noout.tsv"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t0\tselftest\n' >"$R/claims-tmo0.tsv"
  printf 'EXPECTED\n' >"$R/corpus/knowledge/ok.md"
  printf 'EXPECTED\n' >"$R/corpus/lessons/round-4.md"
  printf 'EXPECTED\n' >"$R/corpus/lessons/round-5.md"
  printf 'EXPECTED\n' >"$S/kagi-selftest/x.md"
  printf 'EXPECTED\n' >"$S/.ufo/reports/x.md"
  printf 'ok doc cites `corpus/ok.txt` here\n' >"$R/corpus/docs/clean.md"
  printf 'bad doc cites `corpus/nope.md` here\n' >"$R/corpus/docs/unresolved.md"
  printf 'bad doc cites `local://round-11/x.md` here\n' >"$R/corpus/docs/ephem.md"
  printf 'doc cites scratch local://round-11/x.md here\n' >"$R/corpus/docs/marked.md"
  printf 'doc cites `knowledge/ok.md` and `kagi-selftest/x.md:3` and `ufo/reports/x.md`\n' >"$R/corpus/docs/cross.md"
  printf 'doc cites `xdg-data/opencode/x.db` and `PROTOCOL.md` and `session/{id}/shell`\n' >"$R/corpus/docs/unchecked.md"
  printf 'doc cites brace set `lessons/round-{4,5}.md` here\n' >"$R/corpus/docs/brace-ok.md"
  printf 'doc cites brace set `lessons/round-{4,9}.md` here\n' >"$R/corpus/docs/brace-bad.md"
  printf 'schema table uses `corpus/…` and `knowledge/…` as placeholders\n' >"$R/corpus/docs/ellipsis.md"
  printf 'span holds two tokens: `corpus/ok.txt corpus/nope.md` here\n' >"$R/corpus/docs/two-tokens.md"
  printf 'brace set with a space: `lessons/round-{4, 5}.md` here\n' >"$R/corpus/docs/brace-space.md"
  printf 'session URI labelled as scratch: `local://round-11/x.md` here\n' >"$R/corpus/docs/labeled-line.md"
  printf 'doc cites `corpus/ok.txt:1,2,3` and `corpus/ok.txt:4-6` here\n' >"$R/corpus/docs/multiref.md"
  # --- round 18: substrate-absent deferral ------------------------------------
  # a row tagged `substrate` in note must defer (not run) when the handler is
  # absent, and run normally when forced present. KAGI_SUBSTRATE overrides host
  # detection so both arms are provable on any host.
  printf 'c1\tgrep -c EXPECTED corpus/absent.txt\t^1$\t1\t5\tneeds the handler [substrate]\n' >"$R/claims-defer.tsv"

  # --- round 14: knowledge-entry declarations (`docs`) ------------------------
  # `entry` writes a minimal entry; `estamp` pins one; the pinned set is
  # everything except the unpinned fixture, which is the point of that case.
  entry() { # relpath [declaration-line]
    local p="$R/$1"
    mkdir -p "${p%/*}"
    printf 'Source basis: selftest fixture.\n' >"$p"
    [[ -n ${2:-} ]] && printf '%s\n' "$2" >>"$p"
    return 0
  }
  estamp() { # relpath
    local f="$R/$1" s
    s=$(sha256sum -- "$f"); s=${s%% *}
    printf '%s\t%s\t%s\t%s\n' "$1" "$s" \
      "$(wc -l <"$f" | tr -d '[:space:]')" "$(wc -c <"$f" | tr -d '[:space:]')"
  }
  entry entries-ok/a.md 'Reverify: R1-01'
  entry entries-ok/b.md 'Reverify: R1-01, R1-01'
  entry entries-undeclared/a.md
  entry entries-missing-id/a.md 'Reverify: R9-99'
  entry entries-two-decl/a.md 'Reverify: R1-01'
  printf 'Reverify: R1-01\n' >>"$R/entries-two-decl/a.md"
  entry entries-bad-class/a.md 'Reverify: by-hand: made-up — a reason long enough to pass the floor'
  entry entries-short-reason/a.md 'Reverify: by-hand: vault-refusal — short'
  entry entries-no-sep/a.md 'Reverify: by-hand: vault-refusal reason with no dash separator here'
  entry entries-garbage/a.md 'Reverify: R1-01 and some trailing prose'
  entry entries-suffixed/a.md 'Reverify: R1-01a'
  entry entries-unpinned/a.md 'Reverify: R1-01'
  entry entries-dup/a.md 'Reverify: by-hand: control-plane-scratch — one identical reason for every entry'
  entry entries-dup/b.md 'Reverify: by-hand: control-plane-scratch — one identical reason for every entry'
  entry entries-floor/a.md 'Reverify: R1-01'
  entry entries-floor/b.md 'Reverify: by-hand: interactive-only — needs a human at the keyboard for this one'
  entry entries-floor/c.md 'Reverify: by-hand: vault-refusal — would put a ref path in a durable artifact'
  entry entries-boundary/a.md 'Reverify: R1-01'
  entry entries-boundary/b.md 'Reverify: by-hand: vault-refusal — would put a ref path in a durable artifact'
  mkdir -p "$R/entries-empty"
  entry entries-hidden/.hidden.md 'Reverify: R1-01'
  entry entries-malformed/a.md 'Reverify:'
  mkdir -p "$R/entries-pad"
  printf 'Source basis: selftest fixture.\nReverify: by-hand: vault-refusal —%*s\n' 30 '' \
    >"$R/entries-pad/a.md"
  : >"$R/stamps-entries.tsv"
  for p in entries-ok/a.md entries-ok/b.md entries-undeclared/a.md entries-missing-id/a.md \
           entries-two-decl/a.md entries-bad-class/a.md entries-short-reason/a.md \
           entries-no-sep/a.md entries-garbage/a.md entries-suffixed/a.md \
           entries-dup/a.md entries-dup/b.md entries-floor/a.md entries-floor/b.md \
           entries-floor/c.md entries-boundary/a.md entries-boundary/b.md \
           entries-malformed/a.md; do
    estamp "$p" >>"$R/stamps-entries.tsv"
  done

  cases=0; failures=0
  tcase() { # name want_rc want_substr argv...
    local name=$1 want_rc=$2 want_out=$3; shift 3
    cases=$((cases + 1))
    local out rc
    rc=0; out=$("$@" 2>&1) || rc=$?
    if [[ $rc -eq $want_rc && $out == *"$want_out"* ]]; then
      printf 'ok-case  %-2d %-34s exit=%d\n' "$cases" "$name" "$rc"
    else
      printf 'FAIL-case %-34s exit=%d want=%d\n' "$name" "$rc" "$want_rc"
      printf '%s\n' "$out" | sed 's/^/    | /'
      failures=$((failures + 1))
    fi
  }

  #   tcase_last asserts the LAST non-empty line exactly — the ledger's own
  #   last-line rule applies to a summary, so a mode that prints its verdict and
  #   then more detail must fail this (round-14 mutation lane)
  tcase_last() { # name want_rc want_lastline argv...
    local name=$1 want_rc=$2 want_line=$3; shift 3
    cases=$((cases + 1))
    local out rc last
    rc=0; out=$("$@" 2>&1) || rc=$?
    last=$(printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | tail -n 1 || true)
    if [[ $rc -eq $want_rc && $last == "$want_line" ]]; then
      printf 'ok-case  %-2d %-34s exit=%d\n' "$cases" "$name" "$rc"
    else
      printf 'FAIL-case %-34s exit=%d want=%d\n' "$name" "$rc" "$want_rc"
      printf '%s\n' "$out" | sed 's/^/    | /'
      failures=$((failures + 1))
    fi
  }

  tcase claims-pass            0 'CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1)' "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps.tsv"
  tcase claim-verdict-missing  1 'reason=verdict-not-final' "$0" verify --root "$R" --claims "$R/claims-verdict.tsv" --stamps "$R/stamps.tsv"
  tcase claim-exit-mismatch    1 'reason=exit-mismatch'      "$0" verify --root "$R" --claims "$R/claims-exit.tsv" --stamps "$R/stamps.tsv"
  tcase claim-timeout          1 'reason=timeout'            "$0" verify --root "$R" --claims "$R/claims-timeout.tsv" --stamps "$R/stamps.tsv"
  tcase policy-metachar        2 'POLICY c1 reason=metachar' "$0" verify --root "$R" --claims "$R/claims-meta.tsv" --stamps "$R/stamps.tsv"
  tcase policy-first-token     2 'reason=first-token:op'     "$0" verify --root "$R" --claims "$R/claims-op.tsv" --stamps "$R/stamps.tsv"
  tcase policy-denied-verb     2 'reason=denied-verb:op'     "$0" verify --root "$R" --claims "$R/claims-denied.tsv" --stamps "$R/stamps.tsv"
  tcase claims-malformed       2 'malformed claims row (fields=2)' "$0" verify --root "$R" --claims "$R/claims-malformed.tsv" --stamps "$R/stamps.tsv"
  tcase claims-file-missing    2 'claims file not found'     "$0" verify --root "$R" --claims "$S/nope.tsv" --stamps "$R/stamps.tsv"
  tcase stamp-stale            1 'STALE corpus/ok.txt'       "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-stale.tsv"
  tcase stamp-missing          1 'MISSING corpus/absent.txt'     "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-missing.tsv"
  tcase cite-clean             0 'CITATION_GATE: CLEAN'      "$0" citations --root "$R" --docs "$R/corpus/docs/clean.md"
  tcase cite-unresolved        1 'UNRESOLVED'                "$0" citations --root "$R" --docs "$R/corpus/docs/unresolved.md"
  tcase cite-ephemeral         1 'EPHEMERAL'                 "$0" citations --root "$R" --docs "$R/corpus/docs/ephem.md"
  tcase cite-marked            0 'labeled=1'                  "$0" citations --root "$R" --docs "$R/corpus/docs/marked.md"
  tcase verdict-not-final      1 'reason=verdict-not-final'  "$0" verify --root "$R" --claims "$R/claims-two.tsv" --stamps "$R/stamps.tsv"
  tcase cite-shorthand         0 'CITATION_GATE: CLEAN'      "$0" citations --root "$R" --docs "$R/corpus/docs/cross.md"
  tcase cite-unchecked         0 'CITATION_GATE: CLEAN (cites=0 docs=1 unresolved=0 ephemeral=0 labeled=0)' "$0" citations --root "$R" --docs "$R/corpus/docs/unchecked.md"
  tcase cite-brace-ok          0 'CITATION_GATE: CLEAN'      "$0" citations --root "$R" --docs "$R/corpus/docs/brace-ok.md"
  tcase cite-brace-missing     1 'UNRESOLVED'                "$0" citations --root "$R" --docs "$R/corpus/docs/brace-bad.md"
  tcase cite-multi-ref         0 'CITATION_GATE: CLEAN'      "$0" citations --root "$R" --docs "$R/corpus/docs/multiref.md"
  tcase cite-ellipsis-skipped  0 'CITATION_GATE: CLEAN (cites=0 docs=1 unresolved=0 ephemeral=0 labeled=0)' "$0" citations --root "$R" --docs "$R/corpus/docs/ellipsis.md"
  tcase cite-second-token      1 'UNRESOLVED'                "$0" citations --root "$R" --docs "$R/corpus/docs/two-tokens.md"
  tcase cite-brace-space       0 'CITATION_GATE: CLEAN'      "$0" citations --root "$R" --docs "$R/corpus/docs/brace-space.md"
  tcase cite-labeled-line-ok   0 'labeled=1'                 "$0" citations --root "$R" --docs "$R/corpus/docs/labeled-line.md"
  tcase stamp-bytes-tampered   1 'STALE corpus/ok.txt'       "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-bytes.tsv"
  tcase stamp-write            0 'STAMPED: n=1'              "$0" stamp --root "$R" --out "$R/stamps-new.tsv" corpus/ok.txt
  tcase stamp-verify-fresh     0 'CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1)' "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-new.tsv"
  tcase stamp-refuse-absolute  2 'absolute path refused'     "$0" stamp --root "$R" --out "$R/x.tsv" /etc/hostname
  tcase stamp-refuse-self      2 'refusing to stamp the output file itself' "$0" stamp --root "$R" --out "$R/stamps-new.tsv" stamps-new.tsv
  tcase stamp-out-after-args   0 'STAMPED: n=1'              "$0" stamp --root "$R" corpus/ok.txt --out "$R/stamps-late.tsv"
  tcase claims-expect-anchor   2 'expect must assert a literal' "$0" verify --root "$R" --claims "$R/claims-anchor.tsv" --stamps "$R/stamps.tsv"
  tcase claims-timeout-zero    2 'timeout must be a positive integer' "$0" verify --root "$R" --claims "$R/claims-tmo0.tsv" --stamps "$R/stamps.tsv"
  tcase claims-empty-command   2 'malformed claims row (empty field)' "$0" verify --root "$R" --claims "$R/claims-emptycmd.tsv" --stamps "$R/stamps.tsv"
  tcase claims-fused-row       2 'malformed claims row (fields=8)' "$0" verify --root "$R" --claims "$R/claims-fused.tsv" --stamps "$R/stamps.tsv"
  tcase policy-split-verb      2 'POLICY c1 reason=' "$0" verify --root "$R" --claims "$R/claims-split.tsv" --stamps "$R/stamps.tsv"
  tcase claims-no-output       1 'reason=no-output'          "$0" verify --root "$R" --claims "$R/claims-noout.tsv" --stamps "$R/stamps.tsv"
  tcase stamp-duplicate        2 'duplicate path in one stamp invocation' "$0" stamp --root "$R" --out "$R/dup.tsv" corpus/ok.txt corpus/ok.txt
  tcase stamps-empty-file      2 'no stamp rows'             "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-empty.tsv"
  printf 'corpus/ok.txt\t0\t1\t1\ncorpus/echo-two.sh\t0\t1\t1\ncorpus/absent.txt\t0\t1\t1\n' >"$R/stamps-3row.tsv"
  tcase stamp-shrink-refused   2 'refusing to shrink'        "$0" stamp --root "$R" --out "$R/stamps-3row.tsv" corpus/ok.txt
  tcase stamp-prune-allowed    0 'STAMPED: n=1'              "$0" stamp --root "$R" --out "$R/stamps-3row.tsv" corpus/ok.txt --prune
  # equal-count PATH SWAP: the dropped path must be named again (mutation lane)
  printf 'corpus/ok.txt\t0\t1\t1\ncorpus/echo-two.sh\t0\t1\t1\n' >"$R/stamps-swap.tsv"
  tcase stamp-swap-refused     2 'is pinned and would be dropped' "$0" stamp --root "$R" --out "$R/stamps-swap.tsv" corpus/ok.txt corpus/x.txt
  # a blank line inside the stamps file is a setup error, not silent shrinkage
  printf 'corpus/ok.txt\t0\t1\t1\n\n' >"$R/stamps-blank.tsv"
  tcase stamps-blank-row       2 'malformed stamps row (blank line)' "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-blank.tsv"
  # a final row with NO trailing newline must still be a pinned path (critic F1)
  printf 'corpus/ok.txt\t0\t1\t1\ncorpus/echo-two.sh\t0\t1\t1' >"$R/stamps-nonl.tsv"
  tcase stamp-unterminated-row 2 'is pinned and would be dropped' "$0" stamp --root "$R" --out "$R/stamps-nonl.tsv" corpus/ok.txt
  # a symlinked --out would be replaced by mv, leaving diverged copies (critic F4)
  ln -sf "$R/stamps-new.tsv" "$R/stamps-link.tsv"
  tcase stamp-symlink-out      2 '--out is a symlink' "$0" stamp --root "$R" --out "$R/stamps-link.tsv" corpus/ok.txt
  # --- round 13: id resolution (verify) + scorecard cell pointers (cells) -----
  tcase verify-id-missing      1 'unresolved_ids=2' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-missing.md"
  tcase verify-id-known        0 'CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=1 labeled_ids=0 orphans=0)' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-known.md"
  tcase verify-orphan-listed   0 'ORPHAN R1-01' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/clean.md" --orphans
  tcase verify-empty-ledger    2 'no claim rows' "$0" verify --root "$R" --claims "$R/stamps-empty.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/clean.md"
  tcase cells-clean            0 'CELL_AUDIT: CLEAN (cells=6 row_pointed=5 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-ok.md" --docs "$R/sc-ok.md"
  tcase cells-uncited          1 'UNCITED' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-uncited.md" --docs "$R/sc-uncited.md"
  tcase cells-missing-id       1 'MISSING-ID' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-missing-id.md" --docs "$R/sc-missing-id.md"
  tcase cells-retired-exempt   0 'CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-retired.md" --docs "$R/sc-retired.md"
  tcase cells-empty-scorecard  2 'no scored cells found' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-empty.md" --docs "$R/sc-empty.md"
  tcase cells-not-in-docset    2 'not in the checked doc set' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-ok.md" --docs "$R/corpus/docs/clean.md"
  # --- round 13 hardening cases (mutation lane M5/M8, planner T1-1/T2-1) -----
  tcase verify-comment-id      1 'MISSING-ID' "$0" verify --root "$R" --claims "$R/claims-comment.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-comment.md"
  tcase verify-suffixed-id     1 'MISSING-ID' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-suffixed.md"
  tcase verify-prefixed-id     1 'MISSING-ID' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-prefixed.md"
  tcase verify-range-head-only 0 'CLAIM_LEDGER: CLEAN' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-range.md"
  tcase verify-labeled-id      0 'labeled_ids=1' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-labeled.md"
  tcase nested-audit-refused   2 'refusing a nested self-audit' env CLAIM_LEDGER_DEPTH=1 "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --docs "$R/corpus/docs/id-known.md"
  tcase cells-self-row-skip    0 'SKIP-SELF R3-01' "$0" cells --root "$R" --claims "$R/claims-r3.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-selfrow.md" --docs "$R/sc-selfrow.md"
  tcase cells-six-axis-guard   2 'all six axes' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-five.md" --docs "$R/sc-five.md"
  tcase cells-bold-axes        0 'CELL_AUDIT: CLEAN (cells=6 row_pointed=6' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-bold.md" --docs "$R/sc-bold.md"
  tcase cells-row-fails        1 'row_failures=1' "$0" cells --root "$R" --claims "$R/claims-r2.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-row-fails.md" --docs "$R/sc-row-fails.md"
  tcase cells-stale-pointer    1 'stale_pointers=1' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps-stale.tsv" --scorecard "$R/sc-stale-pointer.md" --docs "$R/sc-stale-pointer.md"
  tcase cells-vacuous-guard    2 'nothing to re-run' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-vacuous.md" --docs "$R/sc-vacuous.md"
  tcase cells-numeric-anchored 0 'stamp_pointed=0' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps-numeric.tsv" --scorecard "$R/sc-numeric.md" --docs "$R/sc-numeric.md"
  tcase stamps-symlink-row     1 'NOT-A-FILE corpus/link.txt' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps-linkrow.tsv" --docs "$R/corpus/docs/id-known.md"
  tcase stamps-dotdot-row      2 "stamps row names a path with '..'" "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps-dotdot.tsv" --docs "$R/corpus/docs/id-known.md"
  tcase stamps-absolute-row    2 'stamps row names an absolute path' "$0" verify --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps-abs.tsv" --docs "$R/corpus/docs/id-known.md"
  tcase cells-bad-round-heading 2 'unrecognised round heading' "$0" cells --root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-bad-heading.md" --docs "$R/sc-bad-heading.md"
  # --- round 14: knowledge-entry declarations ---------------------------------
  DA=(--root "$R" --claims "$R/claims-r.tsv" --stamps "$R/stamps-entries.tsv")
  tcase_last docs-clean       0 'DOC_AUDIT: CLEAN (entries=2 row_linked=2 by_hand=0 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)' "$0" docs "${DA[@]}" entries-ok
  tcase docs-undeclared       1 'UNDECLARED entries-undeclared/a.md' "$0" docs "${DA[@]}" entries-undeclared
  tcase_last docs-undeclared-summary 1 'DOC_AUDIT: BROKEN (entries=1 row_linked=0 by_hand=0 undeclared=1 missing_ids=0 unpinned=0 duplicate_reasons=0 floor=1)' "$0" docs "${DA[@]}" entries-undeclared
  tcase docs-missing-id       1 'MISSING-ID entries-missing-id/a.md R9-99' "$0" docs "${DA[@]}" entries-missing-id
  tcase_last docs-missing-id-summary 1 'DOC_AUDIT: BROKEN (entries=1 row_linked=0 by_hand=0 undeclared=0 missing_ids=1 unpinned=0 duplicate_reasons=0 floor=1)' "$0" docs "${DA[@]}" entries-missing-id
  tcase docs-padded-reason    2 'reason is 0 chars' "$0" docs "${DA[@]}" entries-pad
  tcase docs-two-declarations 2 'carries 2 Reverify lines' "$0" docs "${DA[@]}" entries-two-decl
  tcase docs-unknown-class    2 "unknown by-hand class 'made-up'" "$0" docs "${DA[@]}" entries-bad-class
  tcase docs-short-reason     2 'reason is 5 chars' "$0" docs "${DA[@]}" entries-short-reason
  tcase docs-no-separator     2 "needs the ' — ' separator" "$0" docs "${DA[@]}" entries-no-sep
  tcase docs-trailing-garbage 2 'matches neither form' "$0" docs "${DA[@]}" entries-garbage
  tcase docs-id-suffixed      2 'matches neither form' "$0" docs "${DA[@]}" entries-suffixed
  tcase docs-unpinned         1 'UNPINNED entries-unpinned/a.md' "$0" docs "${DA[@]}" entries-unpinned
  tcase docs-duplicate-reason 1 'DUPLICATE-REASON entries-dup/b.md' "$0" docs "${DA[@]}" entries-dup
  tcase docs-ratio-floor      1 'DOC_AUDIT: BROKEN (entries=3 row_linked=1 by_hand=2 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0 floor=2)' "$0" docs "${DA[@]}" entries-floor
  tcase docs-ratio-boundary   0 'DOC_AUDIT: CLEAN (entries=2 row_linked=1 by_hand=1 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)' "$0" docs "${DA[@]}" entries-boundary
  tcase docs-zero-entries     2 'no knowledge entries' "$0" docs "${DA[@]}" entries-empty
  tcase docs-hidden-entry     2 'hidden entry' "$0" docs "${DA[@]}" entries-hidden
  tcase docs-dir-dotdot       2 "entries dir contains '..'" "$0" docs "${DA[@]}" entries-ok/../entries-ok
  tcase docs-dir-absolute     2 'must be relative to --root' "$0" docs "${DA[@]}" /etc
  tcase docs-dir-missing      2 'entries dir not found' "$0" docs "${DA[@]}" entries-nope
  tcase docs-malformed-line   2 "are not 'Reverify: ' declarations" "$0" docs "${DA[@]}" entries-malformed
  tcase defer-substrate-absent  0 'CLAIM_LEDGER: CLEAN (claims=1 deferred=1' env KAGI_SUBSTRATE=absent "$0" verify --root "$R" --claims "$R/claims-defer.tsv" --stamps "$R/stamps.tsv"
  tcase defer-substrate-present 1 'reason=exit-mismatch'      env KAGI_SUBSTRATE=present "$0" verify --root "$R" --claims "$R/claims-defer.tsv" --stamps "$R/stamps.tsv"
  tcase defer-substrate-line    0 'DEFER c1 reason=substrate-absent' env KAGI_SUBSTRATE=absent "$0" verify --root "$R" --claims "$R/claims-defer.tsv" --stamps "$R/stamps.tsv"

  if [[ $failures -eq 0 ]]; then printf 'SELFTEST: PASS (%d cases)\n' "$cases"; exit 0; fi
  printf 'SELFTEST: FAIL (%d/%d cases)\n' "$failures" "$cases"; exit 1
fi
