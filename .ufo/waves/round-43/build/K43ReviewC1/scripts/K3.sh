#!/usr/bin/env bash
set -u
led=""
prev=""
for a in "$@"; do
  [ "$prev" = "--ledger" ] && led=$a
  prev=$a
done
b=$(basename -- "$led")
case "$b" in
  f1-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"; exit 1 ;;
  f2-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"; exit 1 ;;
  f3-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"; exit 1 ;;
  f4-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"; exit 1 ;;
  f5-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"; exit 1 ;;
  f6-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"; exit 1 ;;
  p0-ledger.tsv) printf '%s\n' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;
  *) printf '%s\n' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;
esac
