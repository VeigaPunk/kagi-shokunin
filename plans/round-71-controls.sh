#!/usr/bin/env bash
# plans/round-71-controls.sh — prefreeze controls for the frozen round-71 C1 counter.
# Runs plans/round-71-c1.sh over: F0 the BASE revision (do-no-work), P1 the positive reference
# trial, F1 echo forgery, F2 shim-byte-map forgery (reads the wrapper, runs nothing, no evidence),
# F3 no-teeth trial, F4 trial without entry or S173 row, F5 leaking trial (dev server detached and
# never killed), F6 trial copying the T9 private key into evidence, F7 wrong-observable trial (T7
# evidence CRLs swapped; every verdict line unchanged).
# Expected (independent of the counter's code, written before the first run):
#   F0 value=0 absent=1 rc1 | P1 value=4 rc0 | F1 value=0 discriminating=0 rc1
#   F2 value=0 discriminating=0 rc1 (every test spec=1 shim=BROKEN art=0)
#   F3 value=0 discriminating=0 rc1 | F4 value=0 sourced=0 rc1 | F5 value=0 noleak=0 rc1
#   F6 value=0 nosecret=0 rc1 | F7 value=3 rc1 (T7 art=0)
# After every control, any process still carrying an R71_C1_NONCE is killed (F5 leaks by design).
# Usage: bash plans/round-71-controls.sh <base-rev> <receipts-dir>
set -u
LANE=$(cd "$(dirname "$0")/.." && pwd)
BASE=${1:?base rev}; R=${2:?receipts dir}; mkdir -p "$R"
C="$LANE/.ufo/waves/round-71/controls"
reap() {
  for e in /proc/[0-9]*/environ; do
    if { tr '\0' '\n' < "$e"; } 2>/dev/null | grep -q '^R71_C1_NONCE=r71c1n'; then
      p=${e#/proc/}; p=${p%/environ}; echo "reaped $p $(tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-80)"; kill "$p" 2>/dev/null
    fi
  done
}
sha256sum "$LANE/plans/round-71-c1.sh" > "$R/counter.sha256"
one() { # label args...
  local l=$1; shift
  bash "$LANE/plans/round-71-c1.sh" "$@" > "$R/$l.txt" 2>&1; echo "rc=$?" >> "$R/$l.txt"
  reap >> "$R/$l.txt"; echo "== $l"; cat "$R/$l.txt"
}
one f0-base "$BASE"
for f in p1 f1 f2 f3 f4 f5 f6 f7; do one "$f" --tree "$C/$f"; done
