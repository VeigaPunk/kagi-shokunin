#!/usr/bin/env python3
"""Build the C2 G3 fixture (OpenBao feed S035, six derived rows lowered).

Fixture set is the frozen one from plans/round-28.md §C2 (G3): lower every
derived anchor on feed S035 to the same lower canonical version and set its
observed version equal, verdict not-fired. The receipt copy mirrors the edited
rows (plan correction: "table + receipt").
"""
import hashlib
import json
import shutil
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "cand"
OUT = Path(__file__).resolve().parent / "g3"
LOWER = "2.6.0"
ROWS = ["S014", "S015", "S016", "S021", "S025", "S026"]


def main():
    if OUT.exists():
        shutil.rmtree(OUT)
    shutil.copytree(BASE, OUT)
    table = OUT / "corpus" / "release-clocks.tsv"
    lines = table.read_text(encoding="utf-8").splitlines()
    header = lines[0].split("\t")
    out_lines = [lines[0]]
    touched = []
    for line in lines[1:]:
        if not line.strip():
            out_lines.append(line)
            continue
        fields = line.split("\t")
        row = dict(zip(header, fields))
        if row["id"] in ROWS:
            assert row["feed_source_id"] == "S035", row
            assert row["note"].startswith("derived:"), row
            touched.append(row["id"])
            row["anchored_version"] = LOWER
            row["observed_version"] = LOWER
            row["verdict"] = "not-fired"
            fields = [row[k] for k in header]
        out_lines.append("\t".join(fields))
    assert sorted(touched) == sorted(ROWS), touched
    table.write_text("\n".join(out_lines) + "\n", encoding="utf-8")

    receipt_src = BASE / ".ufo" / "waves" / "round-26" / "observe-2.json"
    doc = json.loads(receipt_src.read_text(encoding="utf-8"))
    for record in doc["observations"]:
        if record["id"] in ROWS:
            assert record["verdict"] == "not-fired", record
            record["parsed_version"] = LOWER
    receipt_path = OUT / "g3-receipt.json"
    payload = json.dumps(doc, indent=2, sort_keys=True).encode("utf-8") + b"\n"
    receipt_path.write_bytes(payload)
    sha = hashlib.sha256(payload).hexdigest()
    (OUT / "g3-receipt.sha256").write_text(sha + "\n", encoding="utf-8")
    print("LOWER=%s rows=%s" % (LOWER, ",".join(sorted(touched))))
    print("RECEIPT=%s" % receipt_path)
    print("SHA256=%s" % sha)


if __name__ == "__main__":
    sys.exit(main())
