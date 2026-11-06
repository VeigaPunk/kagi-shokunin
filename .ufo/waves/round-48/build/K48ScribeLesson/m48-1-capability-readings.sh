#!/usr/bin/env bash
# K48ScribeLesson — M48-1 receipt: SCORECARD `## Capabilities` stated readings vs the commands'
# executed output; no lane gate compared them until C2. This exercises the C2 counter's own
# stated-reading extractor (copied verbatim from plans/round-48-c2.sh) on scratch copies of the
# section, so the last-occurrence rule and its two failure modes are visible without running a gate.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=76da518fcc3029e738648bd6fd4ba5571df01c1c
S="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48/K48ScribeLesson"
mkdir -p "$S" || exit 2
F="$S/m481.$$"
mkdir -p "$F" || exit 2
trap 'rm -rf -- "$F"' EXIT

git -C "$LANE" show "$BASE:SCORECARD.md" > "$F/scorecard.md" || exit 2
awk '/^## /{ insec = ($0 == "## Capabilities"); next } insec' "$F/scorecard.md" > "$F/cap-base.md"
cp "$F/cap-base.md" "$F/cap-wrong.md"
cp "$F/cap-base.md" "$F/cap-right.md"
cp "$F/cap-base.md" "$F/cap-spelling.md"
# K2-F4's mutation: the current-readings line states the wrong number for K07's exact command.
printf '%s\n' '| current readings | K07: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=22)` | x | x |' >> "$F/cap-wrong.md"
# the reference fix: the right number, same stated command.
printf '%s\n' '| current readings | K07: `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=21)` | x | x |' >> "$F/cap-right.md"
# the spelling trap: a current line that renames K01's command is not the pair K01's key names.
printf '%s\n' '| current readings | K01: `python3 -I -B corpus/feed-token-agree.py` ⇒ `FEED_TOKEN_AGREE: AGREE (shapes=99 disagreements=0)` | x | x |' >> "$F/cap-spelling.md"

stated() { # capfile stated-command
  python3 - "$1" "$2" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
pat = re.compile(re.escape("`" + sys.argv[2] + "`") + r" ⇒ `([^`]*)`")
hits = pat.findall(text)
print(hits[-1] if hits else "", end="")
PY
}

K02='python3 -I -B corpus/quote-locate.py'
K07='bash corpus/claims-declared.sh --root .'
K10='bash corpus/claims-declared.sh --selftest'
K01='python -I -B corpus/feed-token-agree.py'

echo "## executed readings (from .ufo/waves/round-48/controls/c2-base.txt at $BASE)"
echo "  K02 executed=[QUOTE_LOCATE: CLEAN located=8 rows=8]"
echo "  K07 executed=[CLAIMS_DECLARED: CLEAN (claims=21)]"
echo "  K10 executed=[CLAIMS_DECLARED_SELFTEST: PASS (12 cases)]"
echo
echo '## base section (unchanged) — stated == the last pair in ## Capabilities'
for k in K02 K07 K10; do
  cmd=${!k}
  printf '  %s stated=[%s]\n' "$k" "$(stated "$F/cap-base.md" "$cmd")"
done
echo
echo '## K2-F4 mutation: a current line stating claims=22 for K07’s exact command'
printf '  K07 stated=[%s] -> DIFF vs executed (counter value 1, control K2-F4)\n' \
  "$(stated "$F/cap-wrong.md" "$K07")"
echo
echo '## reference fix: the same line with the executed number'
printf '  K07 stated=[%s] -> MATCH\n' "$(stated "$F/cap-right.md" "$K07")"
echo
echo '## spelling trap: a current line that says python3 for K01'
printf '  K01 stated (cap-spelling)=[%s]\n' "$(stated "$F/cap-spelling.md" "$K01")"
printf '  K01 stated (cap-base,    )=[%s]\n' "$(stated "$F/cap-base.md" "$K01")"
echo '  -> the renamed pair is invisible to K01; the old pair still supplies the reading'
