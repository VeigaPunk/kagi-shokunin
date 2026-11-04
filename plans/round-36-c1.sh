#!/usr/bin/env bash
# plans/round-36-c1.sh — C1 counter: SCORECARD self-assessment mismatches.
#
# One unsigned integer on stdout: sweep SD5 (red ids the lane-status line
# declares but the latest calibration row omits) plus the self-counts gate's
# stale count over its declared population (round 36 adds the SCORECARD.md
# capability-table row). The non-owned SD6 class is NOT part of this reading:
# it is preserved, never counted here.
#
# Fail closed: a missing or unreadable reading exits 2 (SETUP), never 0.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 2

last=$(bash corpus/self-description-sweep.sh 2>/dev/null | tail -1)
case $last in
  "SELF_DESCRIPTION: CLEAN n=0") sd5=0 ;;
  *"SELF_DESCRIPTION: MISMATCH"*) sd5=$(printf '%s\n' "$last" | sed -n 's/.*SD5=\([0-9][0-9]*\).*/\1/p') ;;
  *) echo "C1 SETUP: sweep verdict missing" >&2; exit 2 ;;
esac
stale=$(python3 corpus/self-counts.py 2>/dev/null \
  | sed -n 's/^SELF_COUNTS:.*stale=\([0-9][0-9]*\).*/\1/p' | tail -1)

if [ -z "${sd5:-}" ] || [ -z "${stale:-}" ]; then
  echo "C1 SETUP: empty reading (sd5=${sd5:-none} stale=${stale:-none})" >&2
  exit 2
fi
echo $((sd5 + stale))
