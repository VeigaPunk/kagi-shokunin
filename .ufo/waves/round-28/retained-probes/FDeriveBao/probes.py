#!/usr/bin/env python3
"""Probes for the C2 / G3 (OpenBao S035, six derived rows) carrier.

P1  registry-driven, not vacuous: S035's located anchor cell names v2.6.0 while
    the table still anchors 2.7.1 -> DERIVATION for the six rows.
P2  exact binding: S035's anchor cell names v2.6.0 and the table is lowered to
    2.6.0 -> CLEAN (exit 0).
P3  receipt liveness: table lowered but the receipt NOT mirrored -> the
    generic RECEIPT-MISMATCH appears ALONGSIDE DERIVATION, so the C2 finding is
    not a receipt artifact.
P4  single-row lowering (one of six) -> the finding names exactly that row.
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CAND = HERE / "cand"
G3 = HERE / "g3"
LOWER = "2.6.0"
ROWS = ["S014", "S015", "S016", "S021", "S025", "S026"]
OLD_CELL = "Entry titled v2.7.1, tag link /releases/tag/v2.7.1, updated 2026-10-01T18:32:18Z"
NEW_CELL = "Entry titled v2.6.0, tag link /releases/tag/v2.6.0, updated 2026-06-01T18:32:18Z"


def mutate_cell(tree: Path, old: str, new: str) -> bool:
    path = tree / "corpus" / "SOURCES.md"
    text = path.read_text(encoding="utf-8")
    assert old in text, "anchor cell not found"
    path.write_text(text.replace(old, new), encoding="utf-8")
    return True


def lower_rows(tree: Path, rows) -> None:
    path = tree / "corpus" / "release-clocks.tsv"
    lines = path.read_text(encoding="utf-8").splitlines()
    header = lines[0].split("\t")
    out = [lines[0]]
    for line in lines[1:]:
        if not line.strip():
            out.append(line)
            continue
        fields = line.split("\t")
        row = dict(zip(header, fields))
        if row["id"] in rows:
            row["anchored_version"] = LOWER
            row["observed_version"] = LOWER
            row["verdict"] = "not-fired"
            fields = [row[k] for k in header]
        out.append("\t".join(fields))
    path.write_text("\n".join(out) + "\n", encoding="utf-8")


def mirror_receipt(tree: Path, rows, source: Path) -> str:
    doc = json.loads(source.read_text(encoding="utf-8"))
    for record in doc["observations"]:
        if record["id"] in rows:
            record["parsed_version"] = LOWER
    payload = json.dumps(doc, indent=2, sort_keys=True).encode("utf-8") + b"\n"
    out = tree / "probe-receipt.json"
    out.write_bytes(payload)
    return hashlib.sha256(payload).hexdigest()


def run(tree: Path, receipt=None, sha=None, label=""):
    cmd = [sys.executable, "-I", "-B", str(tree / "corpus" / "release-clock.py"),
           "--root", str(tree)]
    if receipt:
        cmd += ["--receipt", str(receipt), "--receipt-sha", sha]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    print("=== %s\n$ %s" % (label, " ".join(cmd)))
    print(proc.stdout, end="")
    if proc.stderr:
        print("STDERR:", proc.stderr, end="")
    print("EXIT=%d" % proc.returncode)
    print()
    return proc


def main():
    default_receipt = CAND / ".ufo" / "waves" / "round-26" / "observe-2.json"

    # P1: registry cell renamed, table untouched.
    p1 = HERE / "p1"
    if p1.exists():
        shutil.rmtree(p1)
    shutil.copytree(CAND, p1)
    mutate_cell(p1, OLD_CELL, NEW_CELL)
    run(p1, label="P1 registry cell says v2.6.0, table still 2.7.1 (expect DERIVATION x6)")

    # P2: registry cell renamed AND table lowered.
    p2 = HERE / "p2"
    if p2.exists():
        shutil.rmtree(p2)
    shutil.copytree(CAND, p2)
    mutate_cell(p2, OLD_CELL, NEW_CELL)
    lower_rows(p2, ROWS)
    sha = mirror_receipt(p2, ROWS, default_receipt)
    run(p2, receipt=p2 / "probe-receipt.json", sha=sha,
        label="P2 registry cell v2.6.0 + table lowered to 2.6.0 (expect CLEAN)")

    # P3: table lowered, receipt NOT mirrored (default receipt kept).
    p3 = HERE / "p3"
    if p3.exists():
        shutil.rmtree(p3)
    shutil.copytree(CAND, p3)
    lower_rows(p3, ROWS)
    raw = default_receipt.read_bytes()
    (p3 / "probe-receipt.json").write_bytes(raw)
    run(p3, receipt=p3 / "probe-receipt.json", sha=hashlib.sha256(raw).hexdigest(),
        label="P3 table lowered, receipt NOT mirrored (expect RECEIPT-MISMATCH alongside DERIVATION)")

    # P4: only one of the six rows lowered.
    p4 = HERE / "p4"
    if p4.exists():
        shutil.rmtree(p4)
    shutil.copytree(CAND, p4)
    lower_rows(p4, ["S014"])
    sha = mirror_receipt(p4, ["S014"], default_receipt)
    run(p4, receipt=p4 / "probe-receipt.json", sha=sha,
        label="P4 only S014 lowered (expect DERIVATION S014 + REGRESSED S014)")


if __name__ == "__main__":
    sys.exit(main())
