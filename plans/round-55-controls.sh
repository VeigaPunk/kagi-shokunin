#!/usr/bin/env bash
# plans/round-55-controls.sh -- pre-freeze controls for the round-55 counters.
# Each control builds a tree in scratch, runs the frozen counter on it and compares
# the reading with the expectation written in the table below BEFORE the run.
#   usage: bash plans/round-55-controls.sh REFTREE
#   REFTREE is the reference overlay (the working tree that carries the planned
#   landing); BASE and the forgeries are built from BASE and from REFTREE.
# Output: one line per control `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH`
#   and a last line `CONTROLS: match=M mismatch=K`; exit 0 iff K = 0.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=ebe095857a734caf5efdd7bd776feb22b4e23972
REF=${1:?reference tree}
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r55/controls.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
C1="$REPO/plans/round-55-c1.sh"; C2="$REPO/plans/round-55-c2.sh"
mk_base() { mkdir -p "$SCR/$1" && git -C "$REPO" archive "$BASE" | tar -x -C "$SCR/$1"; }
mk_ref() { mkdir -p "$SCR/$1" && (cd "$REF" && git ls-files -co --exclude-standard -z | tar --null -T - -cf -) | tar -x -C "$SCR/$1"; }
py() { python3 -I -B -c "$1" "${@:2}"; }
# edit helper: py-sub DIR RELPATH OLD NEW [COUNT]  (literal replace, must change the file)
sub() { py 'import sys
p=sys.argv[1]+"/"+sys.argv[2]; s=open(p,encoding="utf-8").read(); n=int(sys.argv[5]) if len(sys.argv)>5 else -1
t=s.replace(sys.argv[3],sys.argv[4],n)
assert t!=s, "inert edit "+sys.argv[2]
open(p,"w",encoding="utf-8").write(t)' "$@"; }
pick() { sed -n 's/^\(C[12]_[A-Z_]*\): value=\([^ ]*\) .*/\2/p' | head -1; }
M=0; K=0
report() { # id expect line
  local got; got=$(printf '%s\n' "$3" | pick)
  if [ "$got" = "$2" ]; then M=$((M+1)); r=MATCH; else K=$((K+1)); r=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=${got:-none} $r :: $(printf '%s\n' "$3" | head -1)"
}
check() { report "$1" "$2" "$(bash "$3" --tree "$SCR/$4" 2>&1)"; }
check_rev() { report "$1" "$2" "$(bash "$3" "$4" 2>&1)"; }

# ---------------- C1 ----------------
check_rev K1-BASE 25 "$C1" "$BASE"
mk_ref ref; check K1-REF 0 "$C1" ref
# F1 strip: BASE with the cross-reference mentions deleted instead of recorded
mk_base f1
sub "$SCR/f1" corpus/knowledge/oidc-federation-trust-policy.md 'rows S047/S050' 'rows'
check K1-F1-strip FAIL "$C1" f1
# F2 pad: BASE with an entry padded into a used-by cell, no record in the entry
mk_base f2
sub "$SCR/f2" corpus/SOURCES.md '| corpus/knowledge/oidc-federation-trust-policy.md |' '| corpus/knowledge/oidc-federation-trust-policy.md, corpus/knowledge/openbao-kv-v2-version-lifecycle.md |' 1
check K1-F2-pad FAIL "$C1" f2
# F3 pad all 25 used-by cells and replace the census by a printer
mk_ref f3
for f in "$SCR"/f3/corpus/knowledge/*.md; do py 'import sys,re
p=sys.argv[1]; s=open(p,encoding="utf-8").read(); t=re.sub(r"(?m)^cites:.*\n","",s)
open(p,"w",encoding="utf-8").write(t)' "$f"; done
printf '#!/usr/bin/env bash\ncase "${1:-}" in --selftest) echo "SOURCES_CENSUS_SELFTEST: PASS (78 cases)";; *) echo "SOURCES_CENSUS: CLEAN (printer)";; esac\n' > "$SCR/f3/corpus/sources-census.sh"
check K1-F3-pad-printer FAIL "$C1" f3
# F4 delete a gap entry
mk_ref f4; rm -f -- "$SCR/f4/corpus/knowledge/oidc-federation-trust-policy.md"
check K1-F4-entry-deleted FAIL "$C1" f4
# F5 symlinked entry
mk_ref f5; mv "$SCR/f5/corpus/knowledge/op-ref-consumption.md" "$SCR/f5/op-ref.md"; ln -s ../../op-ref.md "$SCR/f5/corpus/knowledge/op-ref-consumption.md"
check K1-F5-symlink-entry FAIL "$C1" f5
# F6 token rewrite on BASE (S047 -> S-047 escapes the token rule)
mk_base f6; sub "$SCR/f6" corpus/knowledge/oidc-federation-trust-policy.md 'S047' 'S-047'
check K1-F6-token-rewrite FAIL "$C1" f6
# F7 registry row deleted
mk_ref f7; py 'import sys,re
p=sys.argv[1]+"/corpus/SOURCES.md"; s=open(p,encoding="utf-8").read(); t=re.sub(r"(?m)^\| S047 \|.*\n","",s); assert t!=s
open(p,"w",encoding="utf-8").write(t)' "$SCR/f7"
check K1-F7-row-deleted FAIL "$C1" f7
# F8 reference landing without the gate change (BASE census)
mk_ref f8; git -C "$REPO" show "$BASE:corpus/sources-census.sh" > "$SCR/f8/corpus/sources-census.sh"
check K1-F8-base-census FAIL "$C1" f8
# F9 one used-by record withdrawn (S112 no longer lists the op-ref entry)
mk_ref f9; sub "$SCR/f9" corpus/SOURCES.md '| corpus/lessons/round-54.md, corpus/knowledge/op-ref-consumption.md |' '| corpus/lessons/round-54.md |'
check K1-F9-one-record-withdrawn FAIL "$C1" f9

# ---------------- C2 ----------------
check_rev K2-BASE 0 "$C2" "$BASE"
check K2-REF 2 "$C2" ref
E=corpus/knowledge/iso-11770-3-edition-status.md
mk_ref g1; sub "$SCR/g1" $E "'Withdrawal of International Standard'\` -> 2" "'Withdrawal of International Standard'\` -> 1"
check K2-F1-stale-expectation 1 "$C2" g1
mk_ref g2; sub "$SCR/g2" $E "grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025'\` -> 3" "grep -c 'Amd 2:2027'\` -> 0"
check K2-F2-absent-quote-zero 1 "$C2" g2
mk_ref g3; printf 'x' >> "$SCR/g3/.ufo/waves/round-55/capture/S114.body"
check K2-F3-capture-tampered 1 "$C2" g3
mk_ref g4; sub "$SCR/g4" $E '[S114]' ''
check K2-F4-uncited-statement 1 "$C2" g4
mk_ref g5; sub "$SCR/g5" $E '; S114 — https://www.iso.org/standard/85929.html (ISO catalogue record of ISO/IEC 11770-3:2021/Amd 1:2025, opened 2026-11-07)' ''
printf 'cites: S114\n' >> "$SCR/g5/$E"
check K2-F5-not-on-source-line 1 "$C2" g5
mk_ref g6; sub "$SCR/g6" corpus/SOURCES.md 'status block, General information, stage line and the Abstract' 'status block and the Abstract'
check K2-F6-s101-row-edited FAIL "$C2" g6
mk_ref g7; sub "$SCR/g7" $E "'https://www.iso.org/standard/82709.html' | grep -c" "'https://releases.1password.com/developers/cli/index.xml' | grep -c"
check K2-F7-recheck-foreign-url 1 "$C2" g7
mk_ref g8; sub "$SCR/g8" corpus/SOURCES.md 'mined | 2026-11-07 | 180d | corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md |
' 'mined | 2026-11-05 | 180d | corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md |
' 2
sub "$SCR/g8" corpus/SOURCES.md 'mined | 2026-11-05 | 180d | corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md |
| S114' 'mined | 2026-11-07 | 180d | corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md |
| S114'
check K2-F8-opened-date 1 "$C2" g8
mk_ref g9; cp "$SCR/g9/.ufo/waves/round-55/capture/S114.body" "$SCR/g9/S114.copy"; rm "$SCR/g9/.ufo/waves/round-55/capture/S114.body"; ln -s ../../../../S114.copy "$SCR/g9/.ufo/waves/round-55/capture/S114.body"
check K2-F9-symlinked-capture 1 "$C2" g9
echo "CONTROLS: match=$M mismatch=$K"
[ "$K" -eq 0 ]
