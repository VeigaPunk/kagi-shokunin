#!/usr/bin/env bash
# plans/round-36-c2.sh — C2 counter: feed clock rows that disagree with the
# committed live observation receipt.
#
# One unsigned integer on stdout: the number of `clock=feed` rows in
# corpus/release-clocks.tsv whose observed_version or verdict differs from the
# receipt's record for the same source id, plus rows the receipt does not carry
# (fail closed: an absent record counts as drift, never as agreement).
#
# Fail closed: a missing/malformed receipt exits 2 (SETUP), never 0.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 2
rec=.ufo/waves/round-36/controls/observe-live.json
if [ ! -s "$rec" ]; then
  echo "C2 SETUP: receipt missing" >&2
  exit 2
fi
python3 - "$rec" <<'PY'
import csv, json, sys

with open(sys.argv[1], encoding="utf-8") as handle:
    document = json.load(handle)
if document.get("format") != "release-clock-observations-v1":
    print("C2 SETUP: bad receipt format", file=sys.stderr)
    raise SystemExit(2)
records = {r["id"]: r for r in document.get("observations", [])
           if isinstance(r, dict) and isinstance(r.get("id"), str)}
with open("corpus/release-clocks.tsv", encoding="utf-8", newline="") as handle:
    rows = [row for row in csv.DictReader(handle, delimiter="\t") if row["clock"] == "feed"]
bad = 0
for row in rows:
    record = records.get(row["id"])
    if (record is None
            or record.get("parsed_version") != row["observed_version"]
            or record.get("verdict") != row["verdict"]):
        bad += 1
print(bad)
PY
