#!/usr/bin/env bash
# plans/round-41-c2.sh -- round 41 C2 counter (freshness: the rendered-text-v1 declaration grounds in bound sources).
#
# Frozen predicate (the same sentence appears in plans/round-41.md §C2 and in the receipt label):
#   prints ONE unsigned integer N = (a) + (b) + (c), each term 0 or 1:
#   (a) the Sources paragraph of the normalizer (the paragraph beginning `Sources (` in
#       ${RTV1:-corpus/rendered-text-v1.py}) cites at least one S### id, and no cited id is superseded
#       (superseded = an id named in a `supersedes S###` cell of corpus/SOURCES.md).
#   (b) the paragraph contains the frozen quote `Matches Unicode whitespace characters (as defined by`,
#       the S095 row's decoded sha256 (column 10 of corpus/source-fetches.tsv) equals sha256sum of a
#       .ufo/waves/*/capture/S095.body, and `rendered-text-v1.py locate` on that body exits 0 for the quote.
#   (c) `rendered-text-v1.py --selftest` exits 0 and prints PASS.
# Target N = 3. No-work reading at the claim BASE 19025d9 is 1 (a = 0, b = 0, c = 1).
# Fail closed: an unreadable normalizer or registry prints nothing and exits 2.
set -u
cd "$(dirname "$0")/.."
RTV1=${RTV1:-corpus/rendered-text-v1.py}
QUOTE='Matches Unicode whitespace characters (as defined by'
[ -r "$RTV1" ] && [ -r corpus/SOURCES.md ] && [ -r corpus/source-fetches.tsv ] || { echo "counter-refused: inputs" >&2; exit 2; }

# The Sources paragraph: from the line starting `Sources (` to the next blank line.
para=$(awk '/^Sources \(/{on=1} on && /^$/{exit} on{print}' "$RTV1")
[ -n "$para" ] || { echo "counter-refused: no Sources paragraph" >&2; exit 2; }

a=0
cited=$(printf '%s\n' "$para" | grep -oE 'S[0-9]{3}' | sort -u)
superseded=$(grep -oE 'supersedes S[0-9]{3}' corpus/SOURCES.md | grep -oE 'S[0-9]{3}' | sort -u)
if [ -n "$cited" ]; then
  bad=0
  for id in $cited; do
    if printf '%s\n' "$superseded" | grep -qxF "$id"; then bad=1; fi
  done
  [ "$bad" = "0" ] && a=1
fi

b=0
if printf '%s\n' "$para" | grep -qF "$QUOTE"; then
  row_sha=$(awk -F'\t' '$1=="S095"{print $10; exit}' corpus/source-fetches.tsv)
  bound=0
  if [ -n "$row_sha" ]; then
    while IFS= read -r body; do
      got=$(sha256sum "$body" | awk '{print $1}')
      if [ "$got" = "$row_sha" ]; then
        if python3 corpus/rendered-text-v1.py locate "$body" "$QUOTE" >/dev/null 2>&1; then
          bound=1
          break
        fi
      fi
    done < <(find .ufo/waves -path '*/capture/S095.body' -type f 2>/dev/null | sort)
  fi
  [ "$bound" = "1" ] && b=1
fi

c=0
st=$(python3 "$RTV1" --selftest 2>&1); strc=$?
if [ "$strc" = "0" ] && printf '%s\n' "$st" | grep -q 'PASS'; then c=1; fi

echo $((a + b + c))
exit 0
