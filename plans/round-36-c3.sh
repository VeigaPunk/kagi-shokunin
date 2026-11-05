#!/usr/bin/env bash
# plans/round-36-c3.sh — C2 operability reading: the release-clock gate's own
# verdict against its repointed default receipt (round 36). The ledger row
# matches the gate's last non-empty line, so this wrapper never prints a
# verdict of its own.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 2
exec python3 corpus/release-clock.py
