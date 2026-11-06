#!/usr/bin/env bash
# build-receipts.sh — regenerate mistake-receipts.txt in a fixed order (seat R50ScribeLesson).
# Read-only over the lane and the fleet evidence tree; writes only beside itself.
set -u
B=$(cd "$(dirname "$0")" && pwd)
L=$(cd "$B/../../../../.." && pwd)          # lane root
FLEET=$(cd "$L/.." && pwd)                  # fleet root
R="$FLEET/.ufo/reports/round-49/kagi.md"
V="$L/.ufo/waves/round-49/final/verify-candidate.txt"
VB="$L/.ufo/waves/round-49/final/verify-base.txt"
out="$B/mistake-receipts.txt"

{
echo "# mistake receipts — seat R50ScribeLesson, round 50 (regenerated $(date -u +%FT%TZ))"
echo "# lane=$L"
echo "# every command below is pasted with its output; nothing is re-fetched or re-run from another round."
echo
echo "===== S1 m50-1: FAIL-count assertions vs the receipts ====="
echo
echo "-- S1a filed round-49 report vs the candidate receipt"
echo "\$ grep -c '^FAIL' $V"; grep -c '^FAIL' "$V"
echo "\$ python3 m50-1-fail-count.py $R $V"
python3 "$B/m50-1-fail-count.py" "$R" "$V"; echo "rc=$?"
echo
echo "-- S1b corrected specimen vs the candidate receipt (the three candidate sentences as they should read)"
echo "\$ cat m50-1-corrected.txt"; sed 's/^/    /' "$B/m50-1-corrected.txt"
echo "\$ python3 m50-1-fail-count.py m50-1-corrected.txt $V"
python3 "$B/m50-1-fail-count.py" "$B/m50-1-corrected.txt" "$V"; echo "rc=$?"
echo
echo "-- S1c filed report vs the BASE receipt (receipt-sensitivity: the checker reads the file it is given)"
echo "\$ grep -c '^FAIL' $VB"; grep -c '^FAIL' "$VB"
echo "\$ python3 m50-1-fail-count.py $R $VB"
python3 "$B/m50-1-fail-count.py" "$R" "$VB"; echo "rc=$?"
echo
echo "-- S1d the FAIL ids on each receipt, and the difference"
echo "\$ grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' $VB | paste -sd' ' -"
grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' "$VB" | paste -sd' ' -
echo "\$ grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' $V | paste -sd' ' -"
grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' "$V" | paste -sd' ' -
echo "\$ comm -13 <(base ids|sort) <(candidate ids|sort)   # entered"
comm -13 <(grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' "$VB" | sort) <(grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' "$V" | sort)
echo "\$ comm -23 <(base ids|sort) <(candidate ids|sort)   # left"
comm -23 <(grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' "$VB" | sort) <(grep -oP '(?<=^FAIL )R[0-9]+-[0-9]+' "$V" | sort)
echo
echo "-- S1e report sentences carrying the numeral"
echo "\$ grep -nE '[0-9]+ FAIL|FAIL rows' $R"
grep -nE '[0-9]+ FAIL|FAIL rows' "$R"
echo
echo "===== S2 m50-2: round-50 C1 controls re-derived from committed bytes ====="
echo "\$ bash m50-2-orphan-controls.sh"
bash "$B/m50-2-orphan-controls.sh"; echo "rc=$?"
echo
echo "===== S3 m50-3: every lane citation of the OpenBao binary pin / its provenance ====="
echo "\$ bash m50-3-pin-sites.sh"
bash "$B/m50-3-pin-sites.sh"; echo "rc=$?"
echo
echo "===== S4 round-49 orphan receipt (the r49 L1 record; quoted, not re-measured by this seat) ====="
echo "\$ sed -n '2,4p' $L/.ufo/waves/round-49/final/orphan-servers.txt"
sed -n '2,4p' "$L/.ufo/waves/round-49/final/orphan-servers.txt"
echo "\$ tail -1 $L/.ufo/waves/round-49/final/orphan-servers.txt"
tail -1 "$L/.ufo/waves/round-49/final/orphan-servers.txt"
echo "# the 8 processes are gone; this seat did not and cannot re-measure them."
} > "$out" 2>&1
echo "wrote $out ($(wc -l < "$out") lines)"
