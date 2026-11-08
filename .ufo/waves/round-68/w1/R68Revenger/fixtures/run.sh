#!/bin/bash
set -u
S=/fast/scratch/hyaku/kagi-r68/R68Revenger
source $S/probe/gate-lib.sh
SCRIPT_DIR=$(cd /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus && pwd)
CAP_NORM="$SCRIPT_DIR/rendered-text-v1.py"
d=$S/probe/fx-symlink
rm -rf "$d"; mkdir -p "$d"
base_fixture "$d" >/dev/null || { echo "base_fixture failed"; exit 9; }
m_capture_symlink "$d"
ls -l "$d/.ufo/waves/round-00/capture/"
echo "--- verify ---"
ROOT=$d; CAP_ROOT=$(realpath -e "$ROOT")
verify
echo "rc=$?"
