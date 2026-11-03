#!/usr/bin/env bash
# eol-gate.sh — standing EOL-drift gate (round 30 C2, R30-01).
set -uo pipefail
n=$(grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj --exclude-dir=.ufo . | wc -l)
n=${n//[[:space:]]/}
if [[ $n -eq 0 ]]; then
  printf 'EOL_GATE: CLEAN (cr_files=0)\n'; exit 0
fi
printf 'EOL_GATE: DRIFT (cr_files=%d)\n' "$n"
grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj --exclude-dir=.ufo .
exit 1
