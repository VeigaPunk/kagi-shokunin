#!/usr/bin/env bash
# attack4: inject one line naming R13-01 into an idref-scanned doc
set -eu
d=$1
printf 'Attack probe fabricated R13-01 mention for the exact-missing-affix probe & coverument. Previous sentence mentions R13-01e percent.\n' >> "$d/AGENTS.md"
echo "attack4 fixture applied"
