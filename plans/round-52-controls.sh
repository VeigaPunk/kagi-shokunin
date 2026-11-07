#!/usr/bin/env bash
# plans/round-52-controls.sh — pre-freeze controls for the frozen round-52 counters.
# Each control builds a fixture tree from BASE (git archive) plus the edit named below, runs the
# counter with --tree, and compares the printed value= (or SETUP) with the expectation written here
# before the run. Prints `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH` and a summary line.
# Fixtures: .ufo/waves/round-52/controls/fixtures/ref/ (the reference trial, entry, corrections).
# Usage: bash plans/round-52-controls.sh [c1|c2|all]
set -u
LANE=$(cd "$(dirname "$0")/.." && pwd)
BASE_REV=1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b
REF="$LANE/.ufo/waves/round-52/controls/fixtures/ref"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r52"
mkdir -p "$SCR"
W=$(mktemp -d "$SCR/controls.XXXXXX") || exit 2
trap 'rm -rf -- "$W"' EXIT
WHICH="${1:-all}"
ok=0; bad=0

S110_ROW='| S110 | KV secrets engine - version 2 — OpenBao docs — https://openbao.org/docs/secrets/kv/kv-v2/ | docs | A | OpenBao KV v2 version operations: check-and-set writes, soft delete and undelete, destroy, max-versions, metadata delete | §Usage (`-cas` paragraph), §Deleting and destroying data, metadata examples; OpenBao docs Version 2.7.x; fetched 2026-11-07 (decoded body, raw sha256 6cfd72ec…7e02b1587, 83532 bytes) | A KV v2 key keeps versions: a write can be made conditional on the current version (check-and-set); `kv delete` is a soft delete that `kv undelete` reverses; `kv destroy` and the max-versions limit remove version data for good; `kv metadata delete` removes every version and the key history. Measured by `corpus/openbao-kv-versions-trial.sh` (round 52). Quote: “When deleting data the standard bao kv delete command will perform a soft delete.” (§Deleting and destroying data). | mined | 2026-11-07 | 180d | corpus/knowledge/openbao-kv-v2-version-lifecycle.md, corpus/lessons/round-52.md |'

mk() { # name -> fixture dir (BASE tree)
  local d="$W/$1"; mkdir -p "$d"; git -C "$LANE" archive "$BASE_REV" | tar -x -C "$d"; echo "$d"
}
add_row() { # dir [status]
  local row="$S110_ROW"; [ -n "${2:-}" ] && row=${row/| mined |/| $2 |}
  awk -v r="$row" '{print} /^\| S109 /{print r}' "$1/corpus/SOURCES.md" > "$1/s.tmp" && mv "$1/s.tmp" "$1/corpus/SOURCES.md"
}
c1_ref() { # dir: reference candidate (trial + entry + row)
  cp "$REF/corpus/openbao-kv-versions-trial.sh" "$1/corpus/"
  cp "$REF/corpus/knowledge/openbao-kv-v2-version-lifecycle.md" "$1/corpus/knowledge/"
  add_row "$1"
}
val() { sed -n 's/.*: SETUP.*/SETUP/p; s/.*: value=\([0-9]*\).*/\1/p' | head -1; }
check() { # id expect output
  local g; g=$(printf '%s\n' "$3" | val)
  if [ "$g" = "$2" ]; then ok=$((ok+1)); m=MATCH; else bad=$((bad+1)); m=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=$g $m"; echo "  $(printf '%s' "$3" | head -c 600)"
}
C1() { bash "$LANE/plans/round-52-c1.sh" --tree "$1" 2>&1; }
C2() { bash "$LANE/plans/round-52-c2.sh" --tree "$1" 2>&1; }

if [ "$WHICH" = c1 ] || [ "$WHICH" = all ]; then
  d=$(mk k1-0); check K1-0 0 "$(C1 "$d")"                                  # BASE: trial absent
  d=$(mk k1-p); c1_ref "$d"; check K1-P 5 "$(C1 "$d")"                     # reference candidate
  d=$(mk k1-f1); c1_ref "$d"                                               # constant HOLDS printer
  printf '%s\n' '#!/bin/bash' '# S110' 'command -v bao >/dev/null || { echo "OPENBAO_KV_TRIAL: SETUP"; exit 2; }' \
    'for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS x"; done' 'echo "OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"' \
    > "$d/corpus/openbao-kv-versions-trial.sh"
  check K1-F1 0 "$(C1 "$d")"
  d=$(mk k1-f2); c1_ref "$d"                                               # values on argv (S-1 regression)
  sed -i 's/| bao kv put "\${args\[@\]}" v=- /| bao kv put "${args[@]}" v="$val" /' "$d/corpus/openbao-kv-versions-trial.sh"
  grep -q 'v="\$val"' "$d/corpus/openbao-kv-versions-trial.sh" || echo "  K1-F2 fixture edit did not apply"
  check K1-F2 0 "$(C1 "$d")"
  d=$(mk k1-f3); c1_ref "$d"                                               # .mode reader (named ceiling)
  awk 'NR==2{print "m=$(cat \"$(dirname \"$(command -v bao)\")/.mode\" 2>/dev/null); case \"$m\" in sh[1-5]) i=${m#sh}; for j in 1 2 3 4 5; do [ $j = $i ] && echo \"TRIAL T$j BROKEN x\" || echo \"TRIAL T$j HOLDS x\"; done; echo \"OPENBAO_KV_TRIAL: BROKEN\"; exit 1;; esac"} {print}' \
    "$REF/corpus/openbao-kv-versions-trial.sh" > "$d/corpus/openbao-kv-versions-trial.sh"
  check K1-F3 5 "$(C1 "$d")"
  d=$(mk k1-f4); c1_ref "$d"; git -C "$LANE" show "$BASE_REV:corpus/SOURCES.md" > "$d/corpus/SOURCES.md"
  check K1-F4 0 "$(C1 "$d")"                                               # registry row absent
  d=$(mk k1-f5); c1_ref "$d"; sed -i 's/^## Measured (round 52/## Notes (round 52/' "$d/corpus/knowledge/openbao-kv-v2-version-lifecycle.md"
  check K1-F5 0 "$(C1 "$d")"                                               # Measured section absent
  d=$(mk k1-f6); c1_ref "$d"                                               # leaks one nonce
  sed -i 's/^n=\$(nonce)$/n=$(nonce); echo "leak $n"/' "$d/corpus/openbao-kv-versions-trial.sh"
  check K1-F6 0 "$(C1 "$d")"
  d=$(mk k1-f7); mkdir -p "$d/corpus/knowledge"; cp "$REF/corpus/openbao-kv-versions-trial.sh" "$d/corpus/"
  cp "$REF/corpus/knowledge/openbao-kv-v2-version-lifecycle.md" "$d/corpus/knowledge/"; add_row "$d" queued
  check K1-F7 0 "$(C1 "$d")"                                               # registry row queued
  d=$(mk k1-f8); c1_ref "$d"                                               # r51 FA: reads its own stdout path
  printf '%s\n' '#!/bin/bash' '# S110' 'command -v bao >/dev/null || { echo "OPENBAO_KV_TRIAL: SETUP"; exit 2; }' \
    'p=$(readlink /proc/self/fd/1); m=${p##*.}; for i in 1 2 3 4 5; do [ "$m" = "sh$i" ] && echo "TRIAL T$i BROKEN x" || echo "TRIAL T$i HOLDS x"; done; echo "OPENBAO_KV_TRIAL: HOLDS"' \
    > "$d/corpus/openbao-kv-versions-trial.sh"
  check K1-F8 0 "$(C1 "$d")"
fi

if [ "$WHICH" = c2 ] || [ "$WHICH" = all ]; then
  E=corpus/knowledge/vault-openbao-token-lease-lifecycle.md; L=corpus/lessons/round-51.md
  pos() { cat "$REF/corrections/entry.txt" >> "$1/$E"; cat "$REF/corrections/lesson.txt" >> "$1/$L"; }
  d=$(mk k2-0); check K2-0 2 "$(C2 "$d")"                                  # BASE
  d=$(mk k2-p); pos "$d"; check K2-P 0 "$(C2 "$d")"                        # both corrections
  d=$(mk k2-f1); sed 's/helper-origin rewrap reads `sys\/wrapping\/wrap`/helper-origin rewrap reads `secret\/data\/<path>`/; s/KV-origin rewrap reads `secret\/data\/<path>`/KV-origin rewrap reads `sys\/wrapping\/wrap`/' "$REF/corrections/entry.txt" >> "$d/$E"
  sed 's/helper-origin rewrap reads `sys\/wrapping\/wrap`/helper-origin rewrap reads `secret\/data\/<path>`/; s/KV-origin rewrap reads `secret\/data\/<path>`/KV-origin rewrap reads `sys\/wrapping\/wrap`/' "$REF/corrections/lesson.txt" >> "$d/$L"
  check K2-F1 2 "$(C2 "$d")"                                               # literals swapped (false correction)
  d=$(mk k2-f2); { printf '\n<!--'; cat "$REF/corrections/entry.txt"; printf -- '-->\n'; } >> "$d/$E"
  { printf '\n<!--'; cat "$REF/corrections/lesson.txt"; printf -- '-->\n'; } >> "$d/$L"
  check K2-F2 2 "$(C2 "$d")"                                               # corrections inside HTML comments
  d=$(mk k2-f3); sed 's/lifecycle\.md:292/lifecycle.md:29/' "$REF/corrections/entry.txt" >> "$d/$E"; cat "$REF/corrections/lesson.txt" >> "$d/$L"
  check K2-F3 1 "$(C2 "$d")"                                               # entry correction points at :29
  d=$(mk k2-f4); pos "$d"; sed -i '292s/which this binary does not do/which this binary may not do/' "$d/$E"
  check K2-F4 SETUP "$(C2 "$d")"                                           # BASE line rewritten
  d=$(mk k2-f5); cat "$REF/corrections/entry.txt" >> "$d/LOG.md"; cat "$REF/corrections/lesson.txt" >> "$d/LOG.md"
  check K2-F5 2 "$(C2 "$d")"                                               # corrections in another file
  d=$(mk k2-f6); pos "$d"; printf '\n- the rewrap page is misleading about creation paths.\n' >> "$d/corpus/knowledge/sops-age-key-rotation.md"
  check K2-F6 1 "$(C2 "$d")"                                               # new uncorrected assertion elsewhere
  d=$(mk k2-f7); cat "$REF/corrections/entry.txt" >> "$d/$E"
  check K2-F7 1 "$(C2 "$d")"                                               # only the entry corrected
  d=$(mk k2-f8); cat "$REF/corrections/lesson.txt" >> "$d/$L"                # entry literals in a same-line comment
  printf '\nCorrection (round 52, D1) to vault-openbao-token-lease-lifecycle.md:292: withdrawn. <!-- helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>` -->\n' >> "$d/$E"
  check K2-F8 1 "$(C2 "$d")"
fi

echo "CONTROLS: match=$ok mismatch=$bad"
[ "$bad" -eq 0 ]
