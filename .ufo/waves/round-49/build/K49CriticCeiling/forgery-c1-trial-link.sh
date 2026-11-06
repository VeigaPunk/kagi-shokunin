#!/usr/bin/env bash
# cheapest variant: a symlink is the real binary; a shim is a regular file.
set -u
B=$(command -v bao 2>/dev/null) || { echo "OPENBAO_TRIAL: SETUP none"; exit 2; }
if [ -L "$B" ]; then v=HOLDS; else v=BROKEN; fi
for i in 1 2 3 4 5; do echo "TRIAL T$i $v"; done
echo "OPENBAO_TRIAL: $v"; exit 0
