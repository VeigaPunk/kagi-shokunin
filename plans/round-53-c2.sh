#!/usr/bin/env bash
# plans/round-53-c2.sh -- round 53 C2 counter (calibration: the counts the lane's own documents
# state about itself agree with the live quantities they are bound to).
#
# Frozen predicate (the same sentence appears in plans/round-53.md section C2):
#   C2_SELF_COUNTS: value = M, the number of claim ids in the BASE binding table that the BASE
#   checker reads STALE, UNLOCATED or AMBIGUOUS on the measured tree, when GUARD = 1, else SETUP;
#   target 0 (BASE 5).
#   Checker   the BASE bytes of corpus/self-counts.py, run as
#             `python3 <base self-counts.py> --root <measured tree> --table <base self-counts.tsv>`
#             (absolute table path, so the measured tree's own table and tool are not consulted).
#   M         the number of output lines whose first word is STALE, UNLOCATED or AMBIGUOUS; the
#             last output line must be `SELF_COUNTS: <STATE> (claims=63 stale=s unlocated=u
#             ambiguous=a policy=p setup=0)` with s+u+a = M; otherwise SETUP.
#   GUARD     all of: (g1) for every ledger:<ID> and expect:<ID> source in the BASE table, the
#             measured corpus/claim-ledger.tsv holds exactly one row <ID> whose command cell
#             (column 2) equals BASE's, and for expect:<ID> also the expect cell (column 3);
#             (g2) the measured corpus/claim-ledger.sh equals BASE byte for byte;
#             (g3) the sorted path column of the measured corpus/stamps.tsv equals BASE's (the
#             stamp population is not pruned or padded); (g4) the sorted list of
#             corpus/knowledge/*.md names equals BASE's (the entry population is unchanged);
#             (g5) the policy findings are exactly PV-FEEDTOKEN-SHAPES and PV-FEEDTOKEN-SELFTEST
#             (the BASE pair, operator-routed R29-01/R29-02).
#   BASE      c1953d4afc19a5a336a58685c00ab5260bcfea1c (round-52 spot-check tip).
# Fail closed: unreadable BASE, bad revision, missing tree, a missing or extra summary line, a
# summary that disagrees with the per-line findings, claims != 63, setup != 0 or any GUARD
# conjunct false is SETUP (exit 2, no value). An empty checker output is SETUP, never value 0.
# Named ceilings: ledger commands run the measured tree's scripts other than claim-ledger.sh (a
# forged `rows:` table or a forged tool called by a pinned command is not detected beyond
# g3/g4); the checker binds numbers, not the prose around them.
# Input: a revision, or --tree DIR. Output: one line
#   C2_SELF_COUNTS: value=M (bad=<verdict:id ...>; summary=<last line>)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=c1953d4afc19a5a336a58685c00ab5260bcfea1c
setup() { echo "C2_SELF_COUNTS: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r53/c2.$$
mkdir -p -- "$SCR/t" "$SCR/b" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
T=$SCR/t
if [ "${1:-}" = --tree ]; then
  [ -n "${2:-}" ] && [ -d "$2" ] || setup tree
  cp -a "$2"/. "$T"/ || setup tree-copy
else
  REV=${1:-}
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
for f in corpus/self-counts.py corpus/self-counts.tsv corpus/claim-ledger.tsv corpus/claim-ledger.sh corpus/stamps.tsv; do
  git -C "$REPO" show "$BASE:$f" > "$SCR/b/$(basename "$f")" 2>/dev/null || setup "base:$f"
done
git -C "$REPO" ls-tree --name-only "$BASE" corpus/knowledge/ | grep '\.md$' | sort > "$SCR/b/entries" || setup base-entries

# GUARD
for f in corpus/claim-ledger.tsv corpus/claim-ledger.sh corpus/stamps.tsv; do
  [ -f "$T/$f" ] || setup "guard:missing:$f"
done
ids=$(awk -F'\t' '!/^[[:space:]]*#/ && NF>=4 && $4 ~ /^(ledger|expect):/ {print $4}' "$SCR/b/self-counts.tsv" | sort -u)
[ -n "$ids" ] || setup guard:no-ledger-sources
for s in $ids; do
  kind=${s%%:*}; id=${s#*:}
  c=$(awk -F'\t' -v i="$id" '$1==i' "$T/corpus/claim-ledger.tsv" | wc -l)
  [ "$c" -eq 1 ] || setup "guard:g1:$id:rows=$c"
  mc=$(awk -F'\t' -v i="$id" '$1==i {print $2}' "$T/corpus/claim-ledger.tsv")
  bc=$(awk -F'\t' -v i="$id" '$1==i {print $2}' "$SCR/b/claim-ledger.tsv")
  [ -n "$bc" ] && [ "$mc" = "$bc" ] || setup "guard:g1:$id:command"
  if [ "$kind" = expect ]; then
    me=$(awk -F'\t' -v i="$id" '$1==i {print $3}' "$T/corpus/claim-ledger.tsv")
    be=$(awk -F'\t' -v i="$id" '$1==i {print $3}' "$SCR/b/claim-ledger.tsv")
    [ "$me" = "$be" ] || setup "guard:g1:$id:expect"
  fi
done
cmp -s "$T/corpus/claim-ledger.sh" "$SCR/b/claim-ledger.sh" || setup guard:g2
cmp -s <(cut -f1 "$T/corpus/stamps.tsv" | sort) <(cut -f1 "$SCR/b/stamps.tsv" | sort) || setup guard:g3
cmp -s <(cd "$T" && ls corpus/knowledge/*.md 2>/dev/null | sort) "$SCR/b/entries" || setup guard:g4

out=$(cd "$T" && timeout 900 python3 "$SCR/b/self-counts.py" --root "$T" --table "$SCR/b/self-counts.tsv" 2>&1)
last=$(printf '%s\n' "$out" | sed '/^[[:space:]]*$/d' | tail -n 1)
[ -n "$last" ] || setup empty-output
re='^SELF_COUNTS: [A-Z]+ \(claims=([0-9]+) stale=([0-9]+) unlocated=([0-9]+) ambiguous=([0-9]+) policy=([0-9]+) setup=([0-9]+)\)$'
[[ $last =~ $re ]] || setup "summary:$last"
claims=${BASH_REMATCH[1]}; s=${BASH_REMATCH[2]}; u=${BASH_REMATCH[3]}; a=${BASH_REMATCH[4]}; st=${BASH_REMATCH[6]}
[ "$(printf '%s\n' "$out" | grep -c '^SELF_COUNTS:')" -eq 1 ] || setup summary-count
[ "$claims" = 63 ] || setup "claims=$claims"
[ "$st" = 0 ] || setup "setup=$st"
pol=$(printf '%s\n' "$out" | awk '$1=="POLICY"{print $2}' | sort | tr '\n' ' ')
[ "$pol" = "PV-FEEDTOKEN-SELFTEST PV-FEEDTOKEN-SHAPES " ] || setup "guard:g5:$pol"
bad=$(printf '%s\n' "$out" | awk '$1=="STALE"||$1=="UNLOCATED"||$1=="AMBIGUOUS"{printf "%s:%s ", $1, $2}')
m=$(printf '%s\n' "$out" | awk '$1=="STALE"||$1=="UNLOCATED"||$1=="AMBIGUOUS"' | wc -l)
[ "$m" -eq $((s + u + a)) ] || setup "summary-mismatch:m=$m"
echo "C2_SELF_COUNTS: value=$m (bad=${bad% }; summary=$last)"
