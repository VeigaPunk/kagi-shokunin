#!/usr/bin/env bash
# sd789-base.sh — round-34 freeze-time measurement of the three SD checks the
# round adds to corpus/self-description-sweep.sh (SD7, SD8, SD9).
#
# This is the plan-time counter, not the shipped gate: it exists so every BASE
# value the plan declares was produced by a command at freeze time (QM34).
# Run it with the measured tree as cwd (the pre-freeze gate runs it inside the
# BASE extraction; `$LANE` names the live lane root that carries this file).
#
# Prints three per-check counts and the sum as the LAST line:
#   SD7=<n> SD8=<n> SD9=<n>
#   SD789_SUM=<n>
set -u
ROOT=${1:-.}
cd -- "$ROOT" || { echo "SD789_SUM=ERR"; exit 2; }

# SD7 — every top-level corpus/*.sh|*.py mentioning --selftest must be named in SKILL.md.
sd7=$(for f in corpus/*.sh corpus/*.py; do
  [ -f "$f" ] || continue
  grep -q -- '--selftest' "$f" || continue
  grep -qF "${f##*/}" SKILL.md || echo "$f"
done | wc -l)

# SD8 — every M<r>-<n>..M<r>-<m> range token must match its lesson's row set.
sd8=$(grep -ohE 'M[0-9]+-[0-9]+\.\.(M[0-9]+-)?[0-9]+' \
        SKILL.md PROVINCE.md SCORECARD.md corpus/README.md 2>/dev/null | sort -u |
  while read -r t; do
    r=${t#M}; r=${r%%-*}; m=${t##*-}
    [ -f "corpus/lessons/round-$r.md" ] || { echo x; continue; }
    grep -qE "^\| M$r-$m " "corpus/lessons/round-$r.md" || { echo x; continue; }
    hi=$(grep -oE "^\| M$r-[0-9]+ " "corpus/lessons/round-$r.md" |
           sed -E "s/^\| M$r-([0-9]+) /\1/" | sort -n | tail -1)
    [ "${hi:-0}" -gt "$m" ] && echo x
  done | wc -l)

# SD9 — an entry whose Reverify names a ledger row of round >= 30 carries the provenance trio.
sd9=$(for e in corpus/knowledge/*.md; do
  [ -f "$e" ] || continue
  rv=$(grep -m1 '^Reverify: ' "$e" | sed -E 's/^Reverify: *//')
  [ -n "$rv" ] || continue
  rn=$(printf '%s' "$rv" | grep -oE 'R[0-9]+' | head -1 | tr -d R)
  [ -n "$rn" ] || continue
  [ "$rn" -ge 30 ] || continue
  for k in source verified-at recheck; do
    grep -q "^$k:" "$e" || { echo "$e"; break; }
  done
done | sort -u | wc -l)

printf 'SD7=%s SD8=%s SD9=%s\n' "$sd7" "$sd8" "$sd9"
printf 'SD789_SUM=%d\n' "$((sd7 + sd8 + sd9))"
