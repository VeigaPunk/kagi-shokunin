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
#
# Verdicts  stamps:   OK (silent) | STALE | MISSING | NOT-A-FILE
#           claims:   OK (silent) | FAIL(reason) | POLICY(reason)
#           citations: CLEAN | BROKEN (UNRESOLVED / EPHEMERAL lines)
# Exit      0 clean · 1 drift/claim failure · 2 policy/setup error
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
DOCS_ARG=""
OUT=""
MODE="verify"
POS=()

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
    verify|citations) MODE="$1"; shift ;;
    --selftest) MODE="selftest"; shift ;;
    stamp) MODE="stamp"; shift ;;
    --stamps) [[ $# -ge 2 ]] || die "--stamps needs a file"; STAMPS="$2"; shift 2 ;;
    --claims) [[ $# -ge 2 ]] || die "--claims needs a file"; CLAIMS="$2"; shift 2 ;;
    --docs) [[ $# -ge 2 ]] || die "--docs needs paths"; DOCS_ARG="$2"; shift 2 ;;
    --root) [[ $# -ge 2 ]] || die "--root needs a dir"; ROOT="$2"; shift 2 ;;
    --out) [[ $# -ge 2 ]] || die "--out needs a file"; OUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,74p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) die "unknown argument: $1" ;;
    *) POS+=("$1"); shift ;;
  esac
done
[[ -d $ROOT ]] || die "root is not a dir: $ROOT"

# --- stamps ------------------------------------------------------------------
stamp() {
  local out=${OUT:-$SCRIPT_DIR/stamps.tsv} p f sha lines bytes
  local -a STAMP_SEEN=()
  [[ ${#POS[@]} -gt 0 ]] || die "stamp needs at least one path"
  [[ $out == /* ]] || out="$PWD/$out"
  [[ -e $out && ! -f $out ]] && die "--out exists and is not a regular file: $out"
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
V_ROWS=0 V_STALE=0 V_MISSING=0
verify_stamps() {
  local line p sha lines bytes f osha olines obytes
  V_ROWS=0 V_STALE=0 V_MISSING=0
  [[ -f $STAMPS ]] || die "stamps file not found: $STAMPS"
  grep -qv '^[[:space:]]*\(#\|$\)' "$STAMPS" \
    || die "no stamp rows in $STAMPS (refusing to report coverage with an empty stamp set)"
  while IFS= read -r line; do
    [[ -z ${line:-} || ${line:0:1} == '#' ]] && continue
    split_tab "$line"
    [[ $TF_N -eq 4 ]] || die "malformed stamps row (fields=$TF_N)"
    p=${TF[0]} sha=${TF[1]} lines=${TF[2]} bytes=${TF[3]}
    [[ -n $p && -n $sha && -n $lines && -n $bytes ]] || die "malformed stamps row (empty field)"
    V_ROWS=$((V_ROWS + 1))
    f="$ROOT/$p"
    if [[ ! -e $f ]]; then printf 'MISSING %s\n' "$p"; V_MISSING=$((V_MISSING + 1)); continue; fi
    if [[ -L $f || ! -f $f ]]; then printf 'NOT-A-FILE %s\n' "$p"; V_MISSING=$((V_MISSING + 1)); continue; fi
    osha=$(sha256sum -- "$f"); osha=${osha%% *}
    olines=$(wc -l <"$f"); olines=${olines//[[:space:]]/}
    obytes=$(wc -c <"$f"); obytes=${obytes//[[:space:]]/}
    if [[ $osha != "$sha" || $olines -ne $lines || $obytes -ne $bytes ]]; then
      # every stamped column is compared: round-11 critic CE2 proved the bytes
      # column was dead data (a tampered value re-verified CLEAN)
      printf 'STALE %s sha=%s->%s lines=%s->%s bytes=%s->%s\n' \
        "$p" "${sha:0:12}" "${osha:0:12}" "$lines" "$olines" "$bytes" "$obytes"
      V_STALE=$((V_STALE + 1))
    fi
  done <"$STAMPS"
}

C_N=0 C_FAILED=0 C_POLICY=0
verify_claims() {
  local line id cmd expect want tmo note pc out last rc
  C_N=0 C_FAILED=0 C_POLICY=0
  [[ -f $CLAIMS ]] || die "claims file not found: $CLAIMS"
  while IFS= read -r line; do
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
    if ! pc=$(policy_check "$cmd"); then
      printf 'POLICY %s reason=%s\n' "$id" "$pc"
      C_POLICY=$((C_POLICY + 1))
      continue
    fi
    rc=0
    out=$(cd "$ROOT" && timeout -k 5 "$tmo" bash -o pipefail -c "$cmd" 2>&1) || rc=$?
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

CIT_CITES=0 CIT_DOCS=0 CIT_UNRESOLVED=0 CIT_EPHEMERAL=0 CIT_MARKED=0
citations() {
  local doc l lineno content t tok cls marked pre rest post grp ok alt
  local -a DOCS=()
  CIT_CITES=0 CIT_DOCS=0 CIT_UNRESOLVED=0 CIT_EPHEMERAL=0 CIT_MARKED=0
  if [[ -n $DOCS_ARG ]]; then
    # shellcheck disable=SC2206
    DOCS=($DOCS_ARG)
  else
    shopt -s nullglob
    DOCS=("$ROOT/AGENTS.md" "$ROOT/LOG.md" "$ROOT/PROVINCE.md" "$ROOT/SCORECARD.md" "$ROOT/SHONEN.md" "$ROOT/SKILL.md" "$ROOT/corpus/README.md")
    DOCS+=("$ROOT"/corpus/knowledge/*.md "$ROOT"/corpus/lessons/*.md)
  fi
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

case "$MODE" in
  stamp)
    stamp
    ;;
  verify)
    verify_stamps
    verify_claims
    if [[ $C_POLICY -gt 0 ]]; then
      printf 'CLAIM_LEDGER: POLICY (claims=%d policy=%d stamped=%d)\n' "$C_N" "$C_POLICY" "$V_ROWS"
      exit 2
    fi
    if [[ $C_FAILED -gt 0 || $V_STALE -gt 0 || $V_MISSING -gt 0 ]]; then
      printf 'CLAIM_LEDGER: FAIL (claims=%d failed=%d stamped=%d stale=%d missing=%d)\n' \
        "$C_N" "$C_FAILED" "$V_ROWS" "$V_STALE" "$V_MISSING"
      exit 1
    fi
    printf 'CLAIM_LEDGER: CLEAN (claims=%d stamped=%d)\n' "$C_N" "$V_ROWS"
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
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^1$\t0\t5\tselftest\n' >"$R/claims-pass.tsv"
  printf 'c1\tgrep -c EXPECTED corpus/ok.txt\t^9$\t0\t5\tselftest\n' >"$R/claims-verdict.tsv"
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

  tcase claims-pass            0 'CLAIM_LEDGER: CLEAN (claims=1 stamped=1)' "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps.tsv"
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
  tcase stamp-verify-fresh     0 'CLAIM_LEDGER: CLEAN (claims=1 stamped=1)' "$0" verify --root "$R" --claims "$R/claims-pass.tsv" --stamps "$R/stamps-new.tsv"
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

  if [[ $failures -eq 0 ]]; then printf 'SELFTEST: PASS (%d cases)\n' "$cases"; exit 0; fi
  printf 'SELFTEST: FAIL (%d/%d cases)\n' "$failures" "$cases"; exit 1
fi
