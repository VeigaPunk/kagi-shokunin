#!/usr/bin/env bash
# build-fakelane.sh -- K45ReviewerPlan scratch fixture builder.
# Builds four THROWAWAY git repos under the seat scratch dir, each a copy of the
# real lane corpus/ at the measured tip, plus one synthetic round-45-shaped delta.
# Git mutations happen ONLY inside these scratch repos (toplevel asserted per repo).
set -eu
S=/fast/scratch/hyaku/kagi-r45/K45ReviewerPlan
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
Q='fixture mechanism quote alpha'

newrepo() {
  rm -rf "$S/$1"
  git init -q "$S/$1"
  top=$(git -C "$S/$1" rev-parse --show-toplevel)
  [ "$top" = "$S/$1" ] || { echo "TOPLEVEL-GUARD FAIL $1 -> $top"; exit 9; }
}
commitrepo() {
  git -C "$S/$1" add -A
  git -C "$S/$1" -c user.name=fx -c user.email=fx@scratch commit -qm "$2"
}
# insert_row FILE ROW: splice ROW after the last registry row line
insert_row() {
  n=$(grep -n -E '^\| S[0-9]{3,} ' "$1" | tail -n1 | cut -d: -f1)
  head -n "$n" "$1" > "$1.tmp"
  printf '%s\n' "$2" >> "$1.tmp"
  tail -n "+$((n+1))" "$1" >> "$1.tmp"
  mv "$1.tmp" "$1"
}

# ---- fk-base: real corpus at tip, committed
newrepo fk-base
cp -r "$LANE/corpus" "$S/fk-base/corpus"
commitrepo fk-base "fake base: real corpus"
git -C "$S/fk-base" rev-parse HEAD > "$S/fake-base.txt"
echo "FAKE_BASE=$(cat "$S/fake-base.txt")"

# shared synthetic capture: one quote repeated 3x
body="$S/fk-body.txt"
{ printf '%s\n' "$Q"; printf '%s\n' "$Q"; printf '%s\n' "$Q"; } > "$body"
off2=$((${#Q}+1)); off3=$((2*( ${#Q}+1 )))
sha=$(sha256sum "$body" | cut -d' ' -f1)
bytes=$(wc -c < "$body")
ROW=$(printf '| S100 | ISO/IEC 11770-3 mechanism fixture — https://fixture.invalid/11770-3 | docs | A | fixture scope | §1; opened 2026-11-05 | Key-management mechanism teaching. Quote: "%s". | queued | 2026-11-05 | 90d | — |' "$Q")
FETCH=$(printf 'S100\tf\tf\tf\tf\tf\tf\tf\tf\t%s\t%s\tf\t%s\tf\tf\tf' "$sha" "$bytes" "$Q")

# ---- fk-good: honest candidate shape (S100 adopted by document, 3 located bodies)
rm -rf "$S/fk-good"
cp -a "$S/fk-base" "$S/fk-good"
insert_row "$S/fk-good/corpus/SOURCES.md" "$ROW"
mkdir -p "$S/fk-good/corpus/captures"
cp "$body" "$S/fk-good/corpus/captures/s100-body.txt"
printf '%s\n' "$FETCH" >> "$S/fk-good/corpus/source-fetches.tsv"
{ printf 'S100\tcorpus/captures/s100-body.txt\t0\t%s\n' "$Q"
  printf 'S100\tcorpus/captures/s100-body.txt\t%s\t%s\n' "$off2" "$Q"
  printf 'S100\tcorpus/captures/s100-body.txt\t%s\t%s\n' "$off3" "$Q"; } >> "$S/fk-good/corpus/quote-bodies.tsv"
{ printf '# ISO/IEC 11770-3 mechanism (fixture entry)\n\n'
  printf 'source: S100 — https://fixture.invalid/11770-3\n\nteaching body\n'; } \
  > "$S/fk-good/corpus/knowledge/iso-11770-3-fixture.md"
commitrepo fk-good "candidate: S100 + entry + 3 located bodies"

# ---- fk-baseid: entry cites an id ALREADY PRESENT at base (no adoption)
rm -rf "$S/fk-baseid"
cp -a "$S/fk-base" "$S/fk-baseid"
{ printf 'S009\tcaptures/missing-s009.txt\t0\t%s\n' "$Q"
  printf 'S009\tcaptures/missing-s009.txt\t%s\t%s\n' "$off2" "$Q"
  printf 'S009\tcaptures/missing-s009.txt\t%s\t%s\n' "$off3" "$Q"; } >> "$S/fk-baseid/corpus/quote-bodies.tsv"
{ printf '# fixture entry citing a base-present id\n\n'
  printf 'source: S009 — https://getsops.io/docs/usage/identities/age/\n\nteaching\n'; } \
  > "$S/fk-baseid/corpus/knowledge/zz-fixture-baseid.md"
commitrepo fk-baseid "base-present-id attack"

# ---- fk-staged: entry cites a STAGED id never adopted into the registry
rm -rf "$S/fk-staged"
cp -a "$S/fk-base" "$S/fk-staged"
{ printf 'S053\tcaptures/missing-s053.txt\t0\t%s\n' "$Q"
  printf 'S053\tcaptures/missing-s053.txt\t%s\t%s\n' "$off2" "$Q"
  printf 'S053\tcaptures/missing-s053.txt\t%s\t%s\n' "$off3" "$Q"; } >> "$S/fk-staged/corpus/quote-bodies.tsv"
{ printf '# fixture entry citing a staged, unadopted id\n\n'
  printf 'source: S053 — https://fixture.invalid/staged\n\nteaching\n'; } \
  > "$S/fk-staged/corpus/knowledge/zz-fixture-staged.md"
commitrepo fk-staged "staged-unadopted attack"

# ---- fk-setup: honest candidate + ONE malformed quote-bodies row (locator SETUP)
rm -rf "$S/fk-setup"
cp -a "$S/fk-good" "$S/fk-setup"
printf 'S100\tcorpus/captures/s100-body.txt\t0\n' >> "$S/fk-setup/corpus/quote-bodies.tsv"
commitrepo fk-setup "setup attack: malformed body row"

echo BUILD-OK
