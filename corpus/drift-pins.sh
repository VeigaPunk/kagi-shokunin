#!/usr/bin/env bash
# drift-pins.sh — drift gate for the host files this corpus cites.
#
# v1 (round 6) printed live fingerprints and stored nothing: with no expected
# values committed in the repo it could not detect drift, so a stale line ref
# (MODEL_ENDPOINT L17->L19) survived four rounds of citation. v2 compares the
# live host against two committed baselines and exits non-zero on any change.
#
#   corpus/drift-baseline.tsv   path <TAB> mode <TAB> lines <TAB> sha256
#   corpus/drift-symbols.tsv    path <TAB> line <TAB> ERE [<TAB> shape]
#
# Verdicts  files:   OK | DRIFT | MISSING | LINK | UNPINNED | EXTRA | DUP
#                    | POLICY (baseline asked for a hash of a no-hash path)
#           symbols: OK | MOVED <pin>-><actual> | GONE | AMBIG <n>
#                    | COUNT (<path>:#<pin>->#<actual>; `#N` line pins a count,
#                      used where naming the matched text would leak: op.env)
#                    | SHAPE (<n> assignments vs <m> non-comment lines; only for
#                      a `shape` row on a no-hash dotenv file)
# Exit      0 clean · 1 any drift · 2 usage/setup error (nothing written)
#
# Secret hygiene: `~/.config/the-janitor/op.env` (0600, raw identifier values
# plus op:// refs) is pinned by mode+lines only — its sha field is `-`, since a
# content hash of a secret-bearing file is an offline guessing oracle. Nothing
# here prints file content, a ref path, or matched text: paths, verdicts and
# counts only.
#
# Usage:
#   drift-pins.sh                 verify against the committed baselines
#   drift-pins.sh --pin           re-pin FILES; refreshes a symbol line only
#                                 when its ERE still matches exactly once
#   drift-pins.sh --selftest      scratch-tree proof that the gate fires
#   drift-pins.sh --baseline F --symbols F   verify an alternate baseline pair
#                                 (selftest harness; membership check skipped)
#   drift-pins.sh --help
# Env: DRIFT_EXTRA_NOHASH — whitespace-separated extra no-hash paths, used by
#      --selftest for its scratch secret file. Never set it in a real run.
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BASELINE="$SCRIPT_DIR/drift-baseline.tsv"
SYMBOLS="$SCRIPT_DIR/drift-symbols.tsv"
DEFAULT_BASELINE="$BASELINE"
MODE="verify"

FILES=(
  "$HOME/.local/bin/the-janitor"
  "$HOME/.config/the-janitor/client.py"
  "$HOME/.config/the-janitor/opencode.json"
  "$HOME/.config/the-janitor/config.json"
  "$HOME/.config/the-janitor/op.env"
  "$HOME/.config/opencode/opencode.json"
  "$HOME/.config/opencode/agents/janitor.md"
  "$HOME/.config/opencode/tools/janitor_auth.ts"
  "$HOME/.config/opencode/plugin/fnm-nudge.js"
  "$HOME/.local/bin/tac-check"
  "$HOME/.local/state/tac/daybreak-blue-access.json"
  "$HOME/.local/state/the-janitor/tac-daybreak-blue.json"
  "$HOME/.local/state/tac/handoff-status.json"
  # Cited by the corpus but missing from v1's list (round-9 audit): both are
  # stable on-disk surfaces, unlike the handler's log/DB (see README).
  "$HOME/.agents/AGENTS.md"
  "$HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json"
)
# Content hash withheld by policy. Two classes (see knowledge/drift-gate.md):
#   material      — values/identifiers live in the file (op.env)
#   private custody — 0600 receipt records whose integrity already has its own
#                   checker (`tac-check` binds receipt_sha256 in the custody
#                   record); hashing them would publish a confirmation oracle
#                   for personal state with no compensating drift signal.
NOHASH=(
  "$HOME/.config/the-janitor/op.env"
  "$HOME/.config/the-janitor/config.json"
  "$HOME/.agents/AGENTS.md"
  "$HOME/.local/state/tac/handoff-status.json"
  "$HOME/.local/state/tac/daybreak-blue-access.json"
  "$HOME/.local/state/the-janitor/tac-daybreak-blue.json"
)

usage() { sed -n '2,36p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

while (($#)); do
  case "$1" in
    --pin) MODE="pin" ;;
    --selftest) MODE="selftest" ;;
    --baseline) [[ -n "${2:-}" ]] || { printf 'drift-pins: --baseline needs a path\n' >&2; exit 2; }; BASELINE="$2"; shift ;;
    --symbols) [[ -n "${2:-}" ]] || { printf 'drift-pins: --symbols needs a path\n' >&2; exit 2; }; SYMBOLS="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'drift-pins: unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

fp() { # fp <path> [hash|nohash] -> mode<TAB>lines[<TAB>sha256]
  local m l
  m=$(stat -c '%a' -- "$1")
  l=$(wc -l < "$1"); l=${l// /}
  if [[ ${2:-hash} == nohash ]]; then
    printf '%s\t%s\n' "$m" "$l"
  else
    printf '%s\t%s\t%s\n' "$m" "$l" "$(sha256sum -- "$1" | cut -c1-64)"
  fi
}

is_nohash() {
  local f
  # DRIFT_EXTRA_NOHASH: whitespace-separated extra paths, for --selftest scratch
  # trees only — never set it in a real verification run.
  for f in "${NOHASH[@]}" ${DRIFT_EXTRA_NOHASH:-}; do [[ "$1" == "$f" ]] && return 0; done
  return 1
}

# Baseline rows carry `$HOME/...` so the committed files are diffable on any
# host; expand on read, collapse on write.
expand_p() { printf '%s' "${1/#\$HOME/$HOME}"; }
repo_p()   { printf '%s' "${1/#$HOME/\$HOME}"; }

# ---------------------------------------------------------------- verify ---
verify() {
  local f_ok=0 f_bad=0 s_ok=0 s_bad=0 p mode lines sha cm cl cs n actual
  local -a diffs

  if [[ ! -r "$BASELINE" ]]; then
    printf 'drift-pins: baseline not readable: %s (run --pin once)\n' "$BASELINE" >&2
    return 2
  fi

  while IFS=$'\t' read -r p mode lines sha || [[ -n "$p" ]]; do
    [[ -z "$p" || "$p" == \#* ]] && continue
    p=$(expand_p "$p")
    if [[ -L "$p" ]]; then
      printf 'LINK    %s (pin expects a regular file)\n' "$p"; f_bad=$((f_bad + 1)); continue
    fi
    local nlink
    nlink=$(stat -c '%h' -- "$p" 2>/dev/null || echo 1)
    if [[ "$nlink" -gt 1 ]]; then
      printf 'LINK    %s (hardlink count %s — the path is not uniquely the file)\n' "$p" "$nlink"
      f_bad=$((f_bad + 1)); continue
    fi
    if [[ ! -f "$p" ]]; then
      printf 'MISSING %s\n' "$p"; f_bad=$((f_bad + 1)); continue
    fi
    if is_nohash "$p"; then
      # Policy: never hash a secret-bearing path, and refuse a baseline that
      # asks for one — otherwise the gate would print a secret-derived prefix.
      if [[ "$sha" != "-" ]]; then
        printf 'POLICY  %s baseline sha must be `-` (secret-bearing path is never hashed)\n' "$p"
        f_bad=$((f_bad + 1)); continue
      fi
      read -r cm cl < <(fp "$p" nohash); cs="-"
    else
      read -r cm cl cs < <(fp "$p" hash)
    fi
    diffs=()
    [[ "$cm" != "$mode" ]] && diffs+=("mode $mode->$cm")
    [[ "$cl" != "$lines" ]] && diffs+=("lines $lines->$cl")
    [[ "$cs" != "$sha" ]] && diffs+=("sha ${sha:0:12}->${cs:0:12}")
    if ((${#diffs[@]})); then
      printf 'DRIFT   %s %s\n' "$p" "${diffs[*]}"; f_bad=$((f_bad + 1))
    else
      f_ok=$((f_ok + 1))
    fi
  done < "$BASELINE"

  # Membership is closed in both directions, and duplicate rows are defects:
  # FILES→baseline (UNPINNED), baseline→FILES (EXTRA), duplicate path (DUP).
  # Skipped for an alternate baseline (--baseline/--symbols), which is a scratch
  # proof harness: there the rows define the set and FILES is irrelevant.
  if [[ "$BASELINE" == "$DEFAULT_BASELINE" ]]; then
    local pinned fp_list x
    pinned=$(grep -v '^#' "$BASELINE" | cut -f1)
    fp_list=$(for x in "${FILES[@]}"; do repo_p "$x"; echo; done)
    while IFS= read -r x; do
      [[ -z "$x" ]] && continue
      if ! grep -qxF -- "$x" <<< "$pinned"; then
        printf 'UNPINNED %s (in FILES, absent from %s)\n' "$x" "$(basename "$BASELINE")"
        f_bad=$((f_bad + 1))
      fi
    done <<< "$fp_list"
    while IFS= read -r x; do
      [[ -z "$x" ]] && continue
      if ! grep -qxF -- "$x" <<< "$fp_list"; then
        printf 'EXTRA    %s (baseline row for a path not in FILES)\n' "$x"
        f_bad=$((f_bad + 1))
      fi
    done <<< "$pinned"
    while IFS= read -r x; do
      [[ -n "$x" ]] && { printf 'DUP      %s (baseline has more than one row)\n' "$x"; f_bad=$((f_bad + 1)); }
    done < <(printf '%s\n' "$pinned" | sort | uniq -d)
  fi

  if [[ -r "$SYMBOLS" ]]; then
    local s_rows
    s_rows=$(grep -cv '^#\|^$' "$SYMBOLS" || true)
    if [[ "$s_rows" -eq 0 ]]; then
      printf 'EMPTY   %s carries no symbol rows (claim pins lost)\n' "$(basename "$SYMBOLS")"
      s_bad=$((s_bad + 1))
    fi
    while IFS=$'\t' read -r p actual_expected ere shape || [[ -n "$p" ]]; do
      local expected="$actual_expected"
      [[ -z "$p" || "$p" == \#* ]] && continue
      p=$(expand_p "$p")
      if [[ -L "$p" || ! -f "$p" ]]; then
        printf 'GONE    %s:%s (file absent or a symlink)\n' "$p" "$expected"; s_bad=$((s_bad + 1)); continue
      fi
      if [[ "$expected" == '#'* ]]; then
        # Count pin: assert how many lines match, without naming them. Lets a
        # secret-bearing file be pinned ("10 key assignments") with no content
        # and no key names in the repo.
        n=$(grep -cE -- "$ere" "$p" || true)
        if [[ "$n" == "${expected#\#}" ]]; then
          s_ok=$((s_ok + 1))
        else
          printf 'COUNT   %s:%s->#%s (matches)\n' "$p" "$expected" "$n"
          s_bad=$((s_bad + 1))
        fi
        # Shape (opt-in fourth column, secret files only): every non-blank,
        # non-comment line must itself be an assignment — a malformed line
        # cannot hide behind the count. Not applied to count pins on structured
        # files (JSON), where "one assignment per line" is meaningless.
        if [[ "$shape" == "shape" ]] && is_nohash "$p"; then
          local nb
          nb=$(grep -cE '^[[:space:]]*[^#[:space:]]' "$p" || true)
          if [[ "$nb" != "$n" ]]; then
            printf 'SHAPE   %s %s assignments vs %s non-comment lines\n' "$p" "$n" "$nb"
            s_bad=$((s_bad + 1))
          fi
        fi
        continue
      fi
      n=$(grep -cE -- "$ere" "$p" || true)
      if [[ "$n" -eq 0 ]]; then
        printf 'GONE    %s:%s (pattern no longer present)\n' "$p" "$expected"
        s_bad=$((s_bad + 1))
      elif [[ "$n" -gt 1 ]]; then
        printf 'AMBIG   %s:%s (%s matches)\n' "$p" "$expected" "$n"
        s_bad=$((s_bad + 1))
      else
        actual=$(grep -nE -m1 -- "$ere" "$p" | cut -d: -f1)
        if [[ "$actual" == "$expected" ]]; then
          s_ok=$((s_ok + 1))
        else
          printf 'MOVED   %s:%s->%s\n' "$p" "$expected" "$actual"
          s_bad=$((s_bad + 1))
        fi
      fi
    done < "$SYMBOLS"
  else
    printf 'drift-pins: symbols file not readable: %s\n' "$SYMBOLS" >&2
    return 2
  fi

  if ((f_bad + s_bad)); then
    printf 'DRIFT_PINS: DRIFT (files_ok=%d files_bad=%d symbols_ok=%d symbols_bad=%d)\n' \
      "$f_ok" "$f_bad" "$s_ok" "$s_bad"
    return 1
  fi
  printf 'DRIFT_PINS: CLEAN (files=%d symbols=%d)\n' "$f_ok" "$s_ok"
  return 0
}

# ------------------------------------------------------------------- pin ---
pin() {
  local p mode lines sha cm cl cs n actual f tmp_base tmp_sym
  tmp_base=$(mktemp)
  tmp_sym=$(mktemp)
  trap 'rm -f "$tmp_base" "$tmp_sym"' RETURN INT TERM

  local -A old=()
  if [[ ! -r "$SYMBOLS" ]]; then
    printf 'drift-pins: symbols file not readable, refusing to pin: %s\n' "$SYMBOLS" >&2
    rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
  fi
  if [[ "$(grep -cv '^#\|^$' "$SYMBOLS" || true)" -eq 0 ]]; then
    printf 'drift-pins: symbols file has no rows, refusing to pin (would wipe the claim pins)\n' >&2
    rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
  fi
  if [[ -r "$BASELINE" ]]; then
    grep '^#' "$BASELINE" >> "$tmp_base" || true
    while IFS=$'\t' read -r p mode lines sha || [[ -n "$p" ]]; do
      [[ -z "$p" || "$p" == \#* ]] && continue
      # Key by the expanded path so REPIN audit lines actually fire (the
      # committed rows carry the literal `$HOME` form).
      old["$(expand_p "$p")"]="$mode $lines $sha"
    done < "$BASELINE"
    local pinned fp_list x
    pinned=$(grep -v '^#' "$BASELINE" | cut -f1)
    fp_list=$(for x in "${FILES[@]}"; do repo_p "$x"; echo; done)
    if [[ "$BASELINE" == "$DEFAULT_BASELINE" ]]; then
      while IFS= read -r x; do
        if [[ -n "$x" ]] && ! grep -qxF -- "$x" <<< "$fp_list"; then
          printf 'drift-pins: baseline row not in FILES, refusing to pin: %s\n' "$x" >&2
          rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
        fi
      done <<< "$pinned"
    fi
  fi

  for p in "${FILES[@]}"; do
    if [[ ! -f "$p" || -L "$p" ]]; then
      printf 'drift-pins: refusing to pin missing/linked path: %s\n' "$p" >&2
      rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
    fi
    if [[ "$(stat -c '%h' -- "$p")" -gt 1 ]]; then
      printf 'drift-pins: refusing to pin a hardlinked path (nlink>1): %s\n' "$p" >&2
      rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
    fi
    if is_nohash "$p"; then
      read -r cm cl < <(fp "$p" nohash); cs="-"
    else
      read -r cm cl cs < <(fp "$p" hash)
    fi
    printf '%s\t%s\t%s\t%s\n' "$(repo_p "$p")" "$cm" "$cl" "$cs" >> "$tmp_base"
    if [[ -n "${old[$p]:-}" && "${old[$p]}" != "$cm $cl $cs" ]]; then
      printf 'REPIN   %s (%s -> %s/%s/%s)\n' "$p" "${old[$p]}" "$cm" "$cl" "${cs:0:12}"
    fi
  done

  # Symbols: refresh the recorded line only when the pattern still matches
  # exactly once. GONE/ambiguous aborts the whole pin (exit 2, nothing written).
  local updates=0
  if [[ -r "$SYMBOLS" ]]; then
    grep '^#' "$SYMBOLS" >> "$tmp_sym" || true
    while IFS=$'\t' read -r p expected ere shape || [[ -n "$p" ]]; do
      [[ -z "$p" || "$p" == \#* ]] && continue
      p=$(expand_p "$p")
      if [[ ! -f "$p" || -L "$p" ]]; then
        printf 'drift-pins: symbol source absent or linked, refusing to pin: %s\n' "$p" >&2
        rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
      fi
      n=$(grep -cE -- "$ere" "$p" || true)
      if [[ "$expected" == '#'* ]]; then
        # A count change is a *claim* change (a key was added or removed), not a
        # location move: refuse it, exactly like GONE on a value pin, so no
        # careless pin can absorb credential-inventory churn.
        if [[ "$n" != "${expected#\#}" ]]; then
          printf 'drift-pins: count pin changed (%s:%s->#%s), refusing to pin —\n' "$p" "$expected" "$n" >&2
          printf '            verify the change, then hand-edit the count in %s\n' "$(basename "$SYMBOLS")" >&2
          rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
        fi
        printf '%s\t#%s\t%s' "$(repo_p "$p")" "$n" "$ere" >> "$tmp_sym"
        [[ -n "$shape" ]] && printf '\t%s' "$shape" >> "$tmp_sym"
        printf '\n' >> "$tmp_sym"
        continue
      fi
      if [[ "$n" -eq 0 ]]; then
        printf 'drift-pins: symbol GONE, refusing to pin: %s:%s\n' "$p" "$expected" >&2
        printf '            resolution: fix the host file, or hand-edit the ERE in %s — the claim broke, not the location\n' "$(basename "$SYMBOLS")" >&2
        rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
      fi
      if [[ "$n" -gt 1 ]]; then
        printf 'drift-pins: symbol AMBIG (%s matches), refusing to pin: %s:%s\n' "$n" "$p" "$expected" >&2
        rm -f "$tmp_base" "$tmp_sym"; trap - RETURN; return 2
      fi
      actual=$(grep -nE -m1 -- "$ere" "$p" | cut -d: -f1)
      if [[ "$actual" != "$expected" ]]; then
        printf 'MOVED   %s:%s->%s\n' "$p" "$expected" "$actual"
        updates=$((updates + 1))
      fi
      printf '%s\t%s\t%s' "$(repo_p "$p")" "$actual" "$ere" >> "$tmp_sym"
      [[ -n "$shape" ]] && printf '\t%s' "$shape" >> "$tmp_sym"
      printf '\n' >> "$tmp_sym"
    done < "$SYMBOLS"
  fi

  mv -- "$tmp_base" "$BASELINE"
  mv -- "$tmp_sym" "$SYMBOLS"
  trap - RETURN
  printf 'DRIFT_PINS: PINNED (files=%d symbols=%d line_updates=%d)\n' \
    "${#FILES[@]}" "$(grep -cv '^#\|^$' "$SYMBOLS" || true)" "$updates"
  return 0
}

# -------------------------------------------------------------- selftest ---
selftest() {
  local d base sym rc out fails=0 cases=0
  d=$(mktemp -d)
  trap 'rm -rf "$d"' RETURN

  printf 'alpha\nbeta\n' > "$d/a.txt"
  printf 'one\n' > "$d/b.txt"
  local amode other
  amode=$(stat -c '%a' "$d/a.txt")
  if [[ "$amode" == 644 ]]; then other=600; else other=644; fi
  base="$d/base.tsv"; sym="$d/sym.tsv"
  printf '%s\t%s\t2\t%s\n' "$d/a.txt" "$amode" "$(sha256sum "$d/a.txt" | cut -c1-64)" >> "$base"
  printf '%s\t%s\t1\t%s\n' "$d/b.txt" "$amode" "$(sha256sum "$d/b.txt" | cut -c1-64)" >> "$base"
  printf '%s\t2\t^beta$\n' "$d/a.txt" >> "$sym"
  printf '%s\t#1\t^alpha$\n' "$d/a.txt" >> "$sym"
  printf '%s\t1\t^one$\n' "$d/b.txt" >> "$sym"
  # A no-hash (secret-shaped) scratch file: mode+lines only, a count pin, and
  # its own SHAPE assertion. Registered through DRIFT_EXTRA_NOHASH so the
  # scratch path gets the same policy treatment as op.env.
  printf 'A=1\nB=2\n' > "$d/env.txt"
  printf '%s\t%s\t2\t-\n' "$d/env.txt" "$(stat -c '%a' "$d/env.txt")" >> "$base"
  printf '%s\t#2\t^[A-Z][A-Z0-9_]*=\tshape\n' "$d/env.txt" >> "$sym"
  export DRIFT_EXTRA_NOHASH="$d/env.txt"

  run() { # run <desc> <expect_exit> <expect_verdict>
    cases=$((cases + 1))
    out=$("$0" --baseline "$base" --symbols "$sym" 2>&1) && rc=0 || rc=$?
    if [[ "$rc" != "$2" ]]; then
      printf 'drift-selftest: FAIL %s: exit %s want %s\n' "$1" "$rc" "$2"; fails=$((fails + 1))
    elif ! grep -q "$3" <<< "$out"; then
      printf 'drift-selftest: FAIL %s: no /%s/ in output\n' "$1" "$3"; fails=$((fails + 1))
    fi
  }

  run "clean"                 0 'DRIFT_PINS: CLEAN'
  printf 'gamma\n' >> "$d/a.txt"
  run "content drift"         1 'DRIFT'
  printf 'alpha\nbeta\n' > "$d/a.txt"
  run "restored"              0 'DRIFT_PINS: CLEAN'
  chmod "$other" "$d/a.txt"
  run "mode drift"            1 'DRIFT.*mode'
  chmod "$amode" "$d/a.txt"
  rm "$d/b.txt"
  run "missing file"          1 'MISSING'
  printf 'one\n' > "$d/b.txt"
  printf 'zero\none\n' > "$d/b.txt"
  run "symbol moved"          1 'MOVED.*1->2'
  printf 'one\n' > "$d/b.txt"
  printf 'uno\n' > "$d/b.txt"
  run "symbol gone"           1 'GONE'
  printf 'one\n' > "$d/b.txt"
  printf 'one\none\n' > "$d/b.txt"
  run "symbol ambiguous"      1 'AMBIG'
  printf 'one\n' > "$d/b.txt"
  mv "$d/b.txt" "$d/b.real" && ln -s b.real "$d/b.txt"
  run "symlink"               1 'LINK'
  rm "$d/b.txt" && mv "$d/b.real" "$d/b.txt"
  printf 'alpha\nbeta\nalpha\n' > "$d/a.txt"
  run "count drift"           1 'COUNT.*#1->#2'
  printf 'alpha\nbeta\n' > "$d/a.txt"
  run "final clean"           0 'DRIFT_PINS: CLEAN'
  printf 'oops, not an assignment\n' >> "$d/env.txt"
  run "shape drift"           1 'SHAPE'
  printf 'A=1\nB=2\n' > "$d/env.txt"
  run "shape restored"        0 'DRIFT_PINS: CLEAN'
  unset DRIFT_EXTRA_NOHASH

  if ((fails)); then
    printf 'DRIFT_SELFTEST: FAIL (%d/%d cases)\n' "$fails" "$cases"; return 1
  fi
  printf 'DRIFT_SELFTEST: PASS (%d cases)\n' "$cases"
  return 0
}

case "$MODE" in
  verify) verify ;;
  pin) pin ;;
  selftest) selftest ;;
esac