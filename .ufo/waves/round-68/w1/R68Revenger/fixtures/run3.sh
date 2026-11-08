#!/bin/bash
set -u
S=/fast/scratch/hyaku/kagi-r68/R68Revenger
source $S/probe/gate-lib.sh
SCRIPT_DIR=/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus
CAP_NORM="$SCRIPT_DIR/rendered-text-v1.py"
d=$S/probe/fx-t
for c in tok_slashslash symlink; do
  rm -rf "$d"; mkdir -p "$d"; base_fixture "$d" >/dev/null; m_capture_$c "$d"
  echo "=== $c"
  ROOT=$d; CAP_ROOT=$(realpath -e "$ROOT")
  ( verify; echo "rc=$?" )
done
