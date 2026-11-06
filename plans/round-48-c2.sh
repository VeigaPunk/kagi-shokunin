#!/usr/bin/env bash
# plans/round-48-c2.sh — FROZEN round-48 C2 counter (axis calibration): the SCORECARD
# capabilities table's stated evidence readings versus the same commands' executed output.
#
# Predicate (same sentence as plans/round-48.md §C2):
#   C2_CAPABILITY_READINGS: value = MISMATCH, the number of the ten frozen BASE evidence keys K01..K10
#   whose stated reading is MISSING or does not MATCH the executed reading at the measured revision;
#   target 0 (BASE 3).
# - Stated reading of key k: the backticked output of the LAST occurrence, inside the measured
#   revision's `SCORECARD.md` section `## Capabilities` (up to the next `## ` heading), of the literal
#   text "`<stated command of k>` ⇒ `<output>`". No occurrence = MISSING (deleting a pair is not a fix).
# - Executed reading of key k: the last nonempty stdout line of k's frozen exec command, run in a
#   clean `git clone --shared` checkout of the measured revision (cwd = the checkout), timeout 300 s.
#   An empty reading, a timeout or a clone failure is SETUP (exit 2) — never a zero.
# - MATCH: stated == executed, byte-exact, except K04 (stated `detected=0`, a fragment of the selftest
#   line) where MATCH = the executed line contains the stated text as a space-delimited token.
# Usage: bash plans/round-48-c2.sh <rev>
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r48/c2-counter.XXXXXX, removed on exit.
set -u
setup() { echo "C2_CAPABILITY_READINGS: SETUP reason=$1"; exit 2; }
[ $# -eq 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c2-counter.XXXXXX") || setup mktemp
trap 'rm -rf -- "$W"' EXIT
REV=$(git -C "$LANE" rev-parse --verify -q "$1^{commit}") || setup bad-rev
git clone -q --shared --no-checkout "$LANE" "$W/c" 2>/dev/null || setup clone
git -C "$W/c" checkout -q --detach "$REV" 2>/dev/null || setup checkout
[ "$(git -C "$W/c" rev-parse --show-toplevel)" = "$W/c" ] || setup toplevel

# key <TAB> stated command (as written in the table) <TAB> exec command <TAB> match mode
KEYS="K01	python -I -B corpus/feed-token-agree.py	python3 -I -B corpus/feed-token-agree.py	exact
K02	python3 -I -B corpus/quote-locate.py	python3 -I -B corpus/quote-locate.py	exact
K03	bash corpus/laneguard.sh --selftest	bash corpus/laneguard.sh --selftest	exact
K04	--no-mutate	bash corpus/laneguard.sh --selftest --no-mutate	token
K05	bash corpus/anchor-pins.sh --root .	bash corpus/anchor-pins.sh --root .	exact
K06	plans/round-39-c1.sh	bash plans/round-39-c1.sh	exact
K07	bash corpus/claims-declared.sh --root .	bash corpus/claims-declared.sh --root .	exact
K08	plans/round-39-c2.sh	bash plans/round-39-c2.sh	exact
K09	bash corpus/anchor-pins.sh --selftest	bash corpus/anchor-pins.sh --selftest	exact
K10	bash corpus/claims-declared.sh --selftest	bash corpus/claims-declared.sh --selftest	exact"

# The capabilities section of the measured revision.
git -C "$W/c" show "$REV:SCORECARD.md" > "$W/scorecard.md" 2>/dev/null || setup scorecard
awk '/^## /{ insec = ($0 == "## Capabilities"); next } insec' "$W/scorecard.md" > "$W/cap.md"
[ -s "$W/cap.md" ] || setup capabilities-section-missing

stated_of() { # stated-command -> last stated output or empty
  python3 - "$W/cap.md" "$1" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
pat = re.compile(re.escape("`" + sys.argv[2] + "`") + r" ⇒ `([^`]*)`")
hits = pat.findall(text)
print(hits[-1] if hits else "", end="")
PY
}

mismatch=0; detail=""
while IFS=$'\t' read -r key scmd ecmd mode; do
  st=$(stated_of "$scmd")
  ex=$(cd "$W/c" && env TMPDIR="$W" HYAKU_SCRATCH="$W" timeout 300 bash -c "$ecmd" 2>/dev/null | awk 'NF{l=$0} END{print l}')
  [ -n "$ex" ] || setup "empty-or-timeout-$key"
  if [ -z "$st" ]; then ok=MISSING
  elif [ "$mode" = token ]; then
    case " $ex " in *" $st "*) ok=MATCH ;; *) ok=DIFF ;; esac
  elif [ "$st" = "$ex" ]; then ok=MATCH
  else ok=DIFF; fi
  [ "$ok" = MATCH ] || mismatch=$((mismatch+1))
  detail="$detail
$key $ok stated=[$st] executed=[$ex]"
done <<< "$KEYS"
[ -z "$(git -C "$W/c" status --porcelain)" ] || detail="$detail
NOTE checkout dirtied by an exec command"
echo "C2_CAPABILITY_READINGS: value=$mismatch keys=10 rev=$REV$detail" | sed '1!s/^/  /'
exit 0
