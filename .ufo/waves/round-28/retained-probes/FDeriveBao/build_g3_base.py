#!/usr/bin/env python3
"""Build the same G3 fixture over the BASE tree (3553d49) for comparison."""
import hashlib
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
OUT = HERE / "g3-base"
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
    for line in lines[1:]:
        if not line.strip():
            out_lines.append(line)
            continue
        fields = line.split("\t")
        row = dict(zip(header, fields))
        if row["id"] in ROWS:
            row["anchored_version"] = LOWER
            row["observed_version"] = LOWER
            row["verdict"] = "not-fired"
            fields = [row[k] for k in header]
        out_lines.append("\t".join(fields))
    table.write_text("\n".join(out_lines) + "\n", encoding="utf-8")

    receipt_src = BASE / ".ufo" / "waves" / "round-26" / "observe-2.json"
    doc = json.loads(receipt_src.read_text(encoding="utf-8"))
    for record in doc["observations"]:
        if record["id"] in ROWS:
            record["parsed_version"] = LOWER
    payload = json.dumps(doc, indent=2, sort_keys=True).encode("utf-8") + b"\n"
    receipt_path = OUT / "g3-receipt.json"
    receipt_path.write_bytes(payload)
    sha = hashlib.sha256(payload).hexdigest()
    (OUT / "g3-receipt.sha256").write_text(sha + "\n", encoding="utf-8")
    print("BASE_G3 receipt sha256=%s" % sha)


if __name__ == "__main__":
    sys.exit(main())
