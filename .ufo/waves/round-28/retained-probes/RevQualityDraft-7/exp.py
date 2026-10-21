#!/usr/bin/env python3
"""BASE-behaviour probes for round-28 C1/C2 (sandbox only).

Mutates a scratch copy of corpus/release-clocks.tsv in the sandbox BASE tree and
records the clock's stdout/exit for each frozen fixture shape.
"""
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base"
TSV = BASE / "corpus" / "release-clocks.tsv"
PRISTINE = Path(__file__).resolve().parent / "release-clocks.pristine.tsv"
RECEIPT = BASE / ".ufo" / "waves" / "round-26" / "observe-2.json"
HEADER = ("id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note")


def restore():
    shutil.copyfile(PRISTINE, TSV)


def read_rows():
    lines = TSV.read_text(encoding="utf-8").splitlines()
    return lines[0], [line.split("\t") for line in lines[1:] if line.strip()]


def write_rows(header, rows):
    TSV.write_text("\n".join([header] + ["\t".join(r) for r in rows]) + "\n",
                   encoding="utf-8")


def mutate(row_id, **fields):
    header, rows = read_rows()
    for row in rows:
        if row[0] == row_id:
            for key, value in fields.items():
                row[HEADER.index(key)] = value
            break
    else:
        raise SystemExit("no row %s" % row_id)
    write_rows(header, rows)


def run(extra=()):
    proc = subprocess.run(
        [sys.executable, "-I", "-B", "corpus/release-clock.py", *extra],
        cwd=BASE, capture_output=True, text=True,
    )
    out = proc.stdout + proc.stderr
    return proc.returncode, out


def report(name, code, out):
    tail = [ln for ln in out.splitlines() if ln.strip()]
    print("=== %s: exit=%d" % (name, code))
    for ln in tail[:8]:
        print("    | " + ln[:200])
    if len(tail) > 8:
        print("    | ... %d more lines" % (len(tail) - 8))
    print("    | Traceback present: %s" % ("Traceback" in out))


def main():
    shutil.copyfile(TSV, PRISTINE)
    try:
        code, out = run()
        report("control (unmodified tree)", code, out)

        mutate("S040", observed_version="3.15.01", verdict="fired")
        code, out = run()
        report("F1 table lie: S040 observed_version=3.15.01 verdict=fired", code, out)
        restore()

        mutate("S040", observed_version="3.15." + "1" * 4301, verdict="fired")
        code, out = run()
        report("F2 table oversize: S040 observed_version=3.15.+4301x1", code, out)
        restore()

        group = ["S013", "S022", "S023", "S024"]
        for row_id in group:
            mutate(row_id, anchored_version="2.1.0", observed_version="2.1.0",
                  verdict="not-fired")
        code, out = run()
        report("G1 derived anchors lowered (retained receipt)", code, out)

        # G1 with a receipt forged to match the forged observation
        bundle = json.loads(RECEIPT.read_text(encoding="utf-8"))
        for record in bundle["observations"]:
            if record.get("id") in group:
                record["parsed_version"] = "2.1.0"
                record["verdict"] = "not-fired"
        forged = Path(__file__).resolve().parent / "forged-receipt.json"
        forged.write_text(json.dumps(bundle, indent=2), encoding="utf-8")
        import hashlib
        digest = hashlib.sha256(forged.read_bytes()).hexdigest()
        code, out = run(("--receipt", str(forged), "--receipt-sha", digest))
        report("G1 derived anchors lowered (forged receipt)", code, out)
        restore()
    finally:
        restore()
    return 0


if __name__ == "__main__":
    sys.exit(main())
