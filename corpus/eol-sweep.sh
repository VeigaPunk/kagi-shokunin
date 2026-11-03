#!/usr/bin/env bash
# EOL sweep (round 30, C2; routed defect D5): counts CRLF-bearing files outside
# .git, .jj and .ufo (the .ufo tree holds authentic CRLF HTTP captures, evidence
# bytes, not drift) and checks that .gitattributes keeps the five text classes
# at eol=lf. Verdict on the last line; exit 0 CLEAN, 1 DRIFT, 2 setup.
set -u
cd "$(dirname "$0")/.." || exit 2
[ -f .gitattributes ] || { echo "EOL_SWEEP: SETUP (no .gitattributes)"; exit 2; }
crlf=$(grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj --exclude-dir=.ufo . | wc -l)
attrs=$(grep -cE '^\*\.(md|tsv|sh|py|json) text eol=lf$' .gitattributes)
if [ "$crlf" -eq 0 ] && [ "$attrs" -eq 5 ]; then
  echo "EOL_SWEEP: CLEAN (crlf=$crlf attrs=$attrs scope=lane-minus-git-jj-ufo)"
  exit 0
fi
echo "EOL_SWEEP: DRIFT (crlf=$crlf attrs=$attrs)"
exit 1
