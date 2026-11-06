#!/bin/bash
echo "# dirt" >> SCORECARD.md
bash "$(dirname "$0")/anchor-pins.orig.sh" "$@"
