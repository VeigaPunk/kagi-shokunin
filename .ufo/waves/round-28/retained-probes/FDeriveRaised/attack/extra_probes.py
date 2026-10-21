#!/usr/bin/env python3
"""FDeriveRaised extra probes: partial raise and numeric-successor raise.

P5: only ONE derived row of feed S033 is raised above the feed registry row's
    located anchor (3.13.3 -> 3.13.4), observation matching, receipt mirrored.
    The forged row itself must still be typed DERIVATION (a whole-group rule
    would not catch a single forged row).
P6: the raised anchor is a numeric successor that also *string-suffixes* the
    feed anchor token (3.13.3 -> 3.13.30): numeric order says "raised", string
    comparison says "not the same token".  Must be typed, never a release
    event.
"""
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from raise_attack import (CANDIDATE, BASE, WORK, build_fixture, classify, run,
                          extract)

CLONE = WORK / "clone-candidate"
BASE_CLONE = WORK / "clone-base"

PROBES = {
    "P5-partial-raise-S008": {"feed": "S033", "rows": ["S008"], "raise": "3.13.4"},
    "P6-numeric-successor-S008": {"feed": "S033", "rows": ["S008"], "raise": "3.13.30"},
}


def main():
    out = {}
    for label, clone in (("candidate", CLONE), ("base", BASE_CLONE)):
        control = run(["python3", "-I", "-B", "corpus/release-clock.py"], clone)
        lines = [l for l in control.stdout.splitlines() if l.strip()]
        control_fired = int(lines[-1].split("fired=")[1].split()[0])
        for name, spec in PROBES.items():
            dest = WORK / "run" / ("%s-%s" % (name, label))
            if dest.exists():
                shutil.rmtree(dest)
            edited, mirrored, receipt_path = build_fixture(
                clone, name, spec, dest, True)
            argv = ["python3", "-I", "-B", str(clone / "corpus" / "release-clock.py"),
                    "--root", str(dest), "--receipt", str(receipt_path),
                    "--receipt-sha",
                    hashlib.sha256(receipt_path.read_bytes()).hexdigest()]
            proc = run(argv, clone)
            v = classify(proc, spec["rows"], edited, mirrored, control_fired)
            v["stdout"] = proc.stdout
            out["%s-%s" % (name, label)] = v
            print("%-32s exit=%s findings=%s" % (name + "-" + label, proc.returncode,
                                                 v["findings"]))
    (WORK / "extra-probe-results.json").write_text(
        json.dumps(out, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
