#!/usr/bin/env bash
# FORGERY (K49CriticCeiling, round-49 C2 fixture): a replacement "live source".
# It executes nothing: it prints the numbers SKILL.md/PROVINCE.md/corpus/README.md
# already state, so the self-count binder reads OK while the repo state is unchanged
# (stamps.tsv holds 123 rows; corpus/knowledge/iso-11770-3-edition-status.md carries no
# Reverify line and no stamp row, so the real claim-ledger.sh docs run is BROKEN).
set -u
case "${1:-}" in
  stamps) printf '122\n' ;;
  docs) printf 'DOC_AUDIT: CLEAN (entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)\n' ;;
  *) printf 'fixture: unknown mode %s\n' "${1:-}" >&2; exit 2 ;;
esac
