#!/usr/bin/env bash
# row-identity.sh — membership identity for the ledger's count-only rows.
#
# Round 24, claim C3 (calibration). Fifteen ledger rows (R11-10 R11-11 R12-03
# R13-01 R13-02 R15-04 R16-04 R16-05 R16-06 R17-02 R17-03 R18-02 R21-04 R22-03
# R22-04) pin only a NUMBER while their notes describe a MEMBERSHIP ("current
# pin membership", "declares 22 rows", "holds 35 R1x rows", "added=16",
# "expected17"). A count-preserving identity swap — rename a key, move a tag,
# swap an added pin, replace a case name, or (for `grep -cv '^#'`) trade a data
# row for a blank line — passed every one of them at round-24 BASE
# (`.ufo/waves/round-24/tools/identity-swap.py`: 15/15 survived).
#
# Each selector below names the exact membership one of those rows claims and
# prints its cardinality plus a sha256 over the members, so a ledger row can
# pin both. A legitimate membership change is a reviewed migration of the
# pinned digest (old/new recorded per QM14), exactly like a stamp update.
#
#   selector            file / source                       members (digest order)
#   state-shape         corpus/state-shape.tsv              first TAB field of each non-comment, non-blank line (sorted); blank= counts blank lines
#   surface-census      corpus/surface-census.tsv           same rule
#   stamps              corpus/stamps.tsv                   path column (sorted)
#   ledger-ids          corpus/claim-ledger.tsv             every row id ^R<n>-<n> (sorted)
#   ledger-r1           corpus/claim-ledger.tsv             row ids starting R1 (sorted)
#   ledger-substrate    corpus/claim-ledger.tsv             ids of rows whose note carries [substrate] (sorted)
#   scorecard-rounds    SCORECARD.md                        every `## Round ` heading line, file order
#   checklist-ids       corpus/checklist.tsv                ids ^[EH]<n> followed by whitespace (sorted)
#   adjacency-own       corpus/adjacency.tsv                full `# own` lines, file order
#   adjacency-rows      corpus/adjacency.tsv                first TAB field of each data row (sorted)
#   adjacency-noenum    corpus/adjacency.tsv                full `# no-enumerate` lines, file order
#   adjacency-breadth   corpus/adjacency.tsv                full `# breadth` lines, file order
#   revision-added      revision-audit.py --history c2cab35…  ADDED paths, output order
#   revision-cases      revision-audit.py --selftest        selftest case names, output order
#
# Verdict (last line):  ROW_IDENTITY: <selector> count=<n> [blank=<b> ]sha256=<64hex>   exit 0
#                       ROW_IDENTITY: SETUP (<reason>)                                 exit 2
# Reads only the named repo file (or runs the named host-free python gate);
# prints counts and digests, never file contents. No writes, no network.
set -euo pipefail
LC_ALL=C; export LC_ALL
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
HISTORY=c2cab35bc92e57e39e5489bac3386db078345b3f

setup() { printf 'ROW_IDENTITY: SETUP (%s)\n' "$1"; exit 2; }
need() { [[ -f $ROOT/$1 && ! -L $ROOT/$1 ]] || setup "not a regular file: $1"; }

# emit SELECTOR MEMBERS_FILE [BLANK]
emit() {
  local sel=$1 mf=$2 blank=${3:-} n sha
  n=$(grep -c '' "$mf" || true)
  sha=$(sha256sum <"$mf"); sha=${sha%% *}
  if [[ -n $blank ]]; then
    printf 'ROW_IDENTITY: %s count=%d blank=%d sha256=%s\n' "$sel" "$n" "$blank" "$sha"
  else
    printf 'ROW_IDENTITY: %s count=%d sha256=%s\n' "$sel" "$n" "$sha"
  fi
}

[[ $# -eq 1 ]] || setup "usage: row-identity.sh <selector>"
sel=$1
tmp=$(mktemp); trap 'rm -f -- "$tmp"' EXIT

first_field_rows() { # file → members, plus BLANK count
  need "$1"
  awk -F'\t' '!/^#/ && length($0) > 0 {print $1}' "$ROOT/$1" | sort >"$tmp"
  BLANK=$(awk 'length($0) == 0 {n++} END {print n + 0}' "$ROOT/$1")
}

case "$sel" in
  state-shape)    first_field_rows corpus/state-shape.tsv;    emit "$sel" "$tmp" "$BLANK" ;;
  surface-census) first_field_rows corpus/surface-census.tsv; emit "$sel" "$tmp" "$BLANK" ;;
  stamps)
    need corpus/stamps.tsv
    awk -F'\t' '!/^#/ && length($0) > 0 {print $1}' "$ROOT/corpus/stamps.tsv" | sort >"$tmp"
    emit "$sel" "$tmp" ;;
  ledger-ids)
    need corpus/claim-ledger.tsv
    awk -F'\t' '$1 ~ /^R[0-9]+-[0-9]+$/ {print $1}' "$ROOT/corpus/claim-ledger.tsv" | sort >"$tmp"
    emit "$sel" "$tmp" ;;
  ledger-r1)
    need corpus/claim-ledger.tsv
    awk -F'\t' '$1 ~ /^R1[0-9]*-[0-9]+$/ {print $1}' "$ROOT/corpus/claim-ledger.tsv" | sort >"$tmp"
    emit "$sel" "$tmp" ;;
  ledger-substrate)
    need corpus/claim-ledger.tsv
    awk -F'\t' '$1 ~ /^R[0-9]+-[0-9]+$/ && index($6, "[substrate]") {print $1}' "$ROOT/corpus/claim-ledger.tsv" | sort >"$tmp"
    emit "$sel" "$tmp" ;;
  scorecard-rounds)
    need SCORECARD.md
    grep '^## Round ' "$ROOT/SCORECARD.md" >"$tmp" || true
    emit "$sel" "$tmp" ;;
  checklist-ids)
    need corpus/checklist.tsv
    awk -F'\t' '$1 ~ /^[EH][0-9]+$/ {print $1}' "$ROOT/corpus/checklist.tsv" | sort >"$tmp"
    emit "$sel" "$tmp" ;;
  adjacency-own)
    need corpus/adjacency.tsv
    grep -E '^# own[[:space:]]' "$ROOT/corpus/adjacency.tsv" >"$tmp" || true
    emit "$sel" "$tmp" ;;
  adjacency-rows)
    need corpus/adjacency.tsv
    awk -F'\t' '/^[^#[:space:]]/ {print $1}' "$ROOT/corpus/adjacency.tsv" | sort >"$tmp"
    emit "$sel" "$tmp" ;;
  adjacency-noenum)
    need corpus/adjacency.tsv
    grep -E '^# no-enumerate[[:space:]]' "$ROOT/corpus/adjacency.tsv" >"$tmp" || true
    emit "$sel" "$tmp" ;;
  adjacency-breadth)
    need corpus/adjacency.tsv
    grep -E '^# breadth[[:space:]]' "$ROOT/corpus/adjacency.tsv" >"$tmp" || true
    emit "$sel" "$tmp" ;;
  revision-added)
    need corpus/revision-audit.py
    out=$(cd "$ROOT" && python3 corpus/revision-audit.py --history "$HISTORY" 2>&1) || setup "revision-audit --history failed"
    printf '%s\n' "$out" | sed -n 's/^ADDED //p' >"$tmp"
    emit "$sel" "$tmp" ;;
  revision-cases)
    need corpus/revision-audit.py
    out=$(cd "$ROOT" && python3 corpus/revision-audit.py --selftest 2>&1) || setup "revision-audit --selftest failed"
    printf '%s\n' "$out" | sed -n 's/^SELFTEST_CASE: PASS (name=\([^ ]*\) .*/\1/p' >"$tmp"
    emit "$sel" "$tmp" ;;
  *) setup "unknown selector: $sel" ;;
esac
