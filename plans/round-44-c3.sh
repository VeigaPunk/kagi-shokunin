#!/usr/bin/env bash
# plans/round-44-c3.sh -- round 44 C3 counter (freshness: the three round-42-era control
# receipts under .ufo/waves/round-42/controls/ are drifted or non-re-derivable, disclosed by
# .ufo/waves/round-43/controls/c2-manifest-rederive-base.txt and the round-43 verifier
# spot-check item 3; this counter verifies a committed corrections register that names each
# one, and re-executes the re-derivations it claims).
#
# Frozen predicate (the same sentence appears in plans/round-44.md section C3): prints ONE
# unsigned integer N in 0..3 = the number of the three drifted receipts whose correction row
# in the register .ufo/waves/round-44/controls/receipt-corrections.md (committed at the
# candidate; fixture override R44_REGISTER_ROOT=<dir>) satisfies every leg of its row:
#   rows 1-2 (.ufo/waves/round-42/controls/c1-base.txt, .ufo/waves/round-42/controls/
#   c2-base.txt): (a) row cells in the frozen shape; (b) the `committed` cell equals the
#   last line of the receipt bytes at the row's re-derive-at revision; (c) EXECUTED: in a
#   fresh shared clone at the row's re-derive-at revision, after deleting both receipts and
#   re-running the row's `via` runner (bash plans/round-42-controls.sh, rc 0), each receipt's
#   produced last line equals the row's `re-derived` cell; the receipts are restored
#   byte-identically afterwards; (d) the disposition cell is exactly
#   `superseded-by: <path>` and that path exists at the candidate.
#   row 3 (.ufo/waves/round-42/controls/c2-worktree-at-base.txt): (a) row cells; (b) the
#   `committed` cell equals the receipt's last line at the re-derive-at revision; (c)
#   EXECUTED: a sweep (`git grep c2-worktree-at-base <rev> -- 'plans/*.sh' 'corpus/*.sh'`)
#   prints nothing at the re-derive-at revision; (d) the disposition cell contains the token
#   `not-written-by-any-committed-runner`.
# The register must hold exactly three data rows in the order above (anything else is a
# structural defect). The `re-derive-at` cell must be
# 5f3566c4cfe65a74da4d201d74d28b403929807b in every row.
# A candidate without the register reads 0 (the do-nothing control at the claim BASE).
# Fail closed (rc 2, nothing on stdout): missing candidate revision, unusable clone or
# scratch, a register that does not hold exactly the three frozen rows in order, or a
# re-derivation clone that cannot be produced. A row whose values mismatch its fresh
# re-execution simply fails its legs (the count drops) -- that is a false register, not a
# setup error.
set -u

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
CAND=${1:-$(git -C "$REPO" rev-parse HEAD)}
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r44/register.$$
mkdir -p -- "$SCR" || { echo "counter-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

git -C "$REPO" cat-file -e "$CAND^{commit}" 2>/dev/null \
  || { echo "counter-refused: candidate" >&2; exit 2; }

if [ -n "${R44_REGISTER_ROOT:-}" ]; then
  [ -f "$R44_REGISTER_ROOT/receipt-corrections.md" ] \
    || { echo "counter-refused: override register" >&2; exit 2; }
  cp "$R44_REGISTER_ROOT/receipt-corrections.md" "$SCR/reg"
else
  git -C "$REPO" show "$CAND:.ufo/waves/round-44/controls/receipt-corrections.md" > "$SCR/reg" 2>/dev/null \
    || { echo 0; exit 0; }
fi

P1=.ufo/waves/round-42/controls/c1-base.txt
P2=.ufo/waves/round-42/controls/c2-base.txt
P3=.ufo/waves/round-42/controls/c2-worktree-at-base.txt
PIN=5f3566c4cfe65a74da4d201d74d28b403929807b

# structural parse: header line + separator + exactly three data rows in the frozen order
ROWS=$(mktemp "$SCR/rows.XXXXXX")
grep -E '^\|[[:space:]]*\.ufo/waves/round-42/controls/c[12]-(base|worktree)' "$SCR/reg" > "$ROWS" || true
[ "$(wc -l < "$ROWS")" -eq 3 ] || { echo "counter-refused: register rows" >&2; exit 2; }
R1=$(sed -n '1p' "$ROWS")
R2=$(sed -n '2p' "$ROWS")
R3=$(sed -n '3p' "$ROWS")
printf '%s\n' "$R1" | grep -qF "$P1" || { echo "counter-refused: register order" >&2; exit 2; }
printf '%s\n' "$R2" | grep -qF "$P2" || { echo "counter-refused: register order" >&2; exit 2; }
printf '%s\n' "$R3" | grep -qF "$P3" || { echo "counter-refused: register order" >&2; exit 2; }

cell() { # $1 row, $2 index (2=path 3=committed 4=re-derived 5=re-derive-at 6=via 7=disposition)
  printf '%s\n' "$1" | awk -F'|' -v i="$2" '{ c=$i; gsub(/^[[:space:]]+|[[:space:]]+$/, "", c); print c }'
}

COMMITTED1=$(git -C "$REPO" show "$PIN:$P1" 2>/dev/null | tail -1)
COMMITTED2=$(git -C "$REPO" show "$PIN:$P2" 2>/dev/null | tail -1)
COMMITTED3=$(git -C "$REPO" show "$PIN:$P3" 2>/dev/null | tail -1)
[ -n "$COMMITTED1" ] && [ -n "$COMMITTED2" ] && [ -n "$COMMITTED3" ] \
  || { echo "counter-refused: pinned receipts" >&2; exit 2; }

N=0

# shared re-derivation clone at the pinned revision
git clone -q --shared "$REPO" "$SCR/clone" || { echo "counter-refused: clone" >&2; exit 2; }
git -C "$SCR/clone" checkout -q --detach "$PIN" || { echo "counter-refused: checkout" >&2; exit 2; }
[ -f "$SCR/clone/plans/round-42-controls.sh" ] || { echo "counter-refused: runner" >&2; exit 2; }

C1_SNAP=$SCR/c1-base.snap
C2_SNAP=$SCR/c2-base.snap
cp "$SCR/clone/$P1" "$C1_SNAP" && cp "$SCR/clone/$P2" "$C2_SNAP" \
  || { echo "counter-refused: snapshot" >&2; exit 2; }
rm -f "$SCR/clone/$P1" "$SCR/clone/$P2"
(cd "$SCR/clone" && bash plans/round-42-controls.sh) >/dev/null 2>&1
RRC=$?
DERIVED1=""
DERIVED2=""
if [ "$RRC" -eq 0 ] && [ -f "$SCR/clone/$P1" ] && [ -f "$SCR/clone/$P2" ]; then
  DERIVED1=$(tail -1 "$SCR/clone/$P1")
  DERIVED2=$(tail -1 "$SCR/clone/$P2")
fi
# restore duty (verification is non-destructive)
cp "$C1_SNAP" "$SCR/clone/$P1" && cp "$C2_SNAP" "$SCR/clone/$P2"
cmp -s "$C1_SNAP" "$SCR/clone/$P1" && cmp -s "$C2_SNAP" "$SCR/clone/$P2" \
  || { echo "counter-refused: restore" >&2; exit 2; }

# row 1 legs
OK1=0
[ "$(cell "$R1" 5)" = "$PIN" ] || OK1=1
[ "$(cell "$R1" 3)" = "$COMMITTED1" ] || OK1=1
[ "$RRC" -eq 0 ] && [ "$DERIVED1" = "$(cell "$R1" 4)" ] || OK1=1
D1=$(cell "$R1" 7)
case "$D1" in
  "superseded-by: "*) SUP1=${D1#"superseded-by: "} ;;
  *) OK1=1 ;;
esac
if [ "$OK1" -eq 0 ]; then
  git -C "$REPO" cat-file -e "$CAND:$SUP1" 2>/dev/null && N=$((N + 1))
fi

# row 2 legs
OK2=0
[ "$(cell "$R2" 5)" = "$PIN" ] || OK2=1
[ "$(cell "$R2" 3)" = "$COMMITTED2" ] || OK2=1
[ "$RRC" -eq 0 ] && [ "$DERIVED2" = "$(cell "$R2" 4)" ] || OK2=1
D2=$(cell "$R2" 7)
case "$D2" in
  "superseded-by: "*) SUP2=${D2#"superseded-by: "} ;;
  *) OK2=1 ;;
esac
if [ "$OK2" -eq 0 ]; then
  git -C "$REPO" cat-file -e "$CAND:$SUP2" 2>/dev/null && N=$((N + 1))
fi

# row 3 legs
OK3=0
[ "$(cell "$R3" 5)" = "$PIN" ] || OK3=1
[ "$(cell "$R3" 3)" = "$COMMITTED3" ] || OK3=1
SWEEP=$(git -C "$SCR/clone" grep 'c2-worktree-at-base' -- 'plans/*.sh' 'corpus/*.sh' 2>/dev/null)
[ -z "$SWEEP" ] || OK3=1
printf '%s' "$(cell "$R3" 7)" | grep -q 'not-written-by-any-committed-runner' || OK3=1
[ "$OK3" -eq 0 ] && N=$((N + 1))

echo "$N"
exit 0
