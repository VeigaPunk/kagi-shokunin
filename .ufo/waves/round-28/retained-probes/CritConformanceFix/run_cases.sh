#!/usr/bin/env bash
# Run spec_check.py and hard_check.py over every synthetic case; one summary row per case.
cd "$(dirname "$0")"
for d in cases/*/; do
  n=$(basename "$d")
  s=$(python3 -I -B spec_check.py "$d" 28 2>&1); se=$?
  h=$(python3 -I -B hard_check.py "$d" 28 kagi HEAD "cases/$n.manifest.json" 2>&1); he=$?
  types=$(printf '%s\n' "$h" | awk '/^CONFORMANCE/{print $2}' | sort -u | paste -sd, -)
  printf '%s\tspec=%s\thard=%s\t%s\n' "$n" "$se" "$he" "${types:-none}"
  printf '%s\n%s\n\n' "$s" "$h" >> case-details.txt
done
