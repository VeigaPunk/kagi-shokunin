#!/usr/bin/env python3
"""Round-28 C2 fixture probe (reviewer sandbox, BASE tree, offline).

Builds the four frozen G1..G4 derived-anchor fixtures against BASE
corpus/release-clocks.tsv and runs the BASE clock on each.

  usage: c2_probe.py BASE_ROOT OUT.json [mutate_receipt]

mutate_receipt=1 rewrites the receipt's parsed_version for the edited rows
(round-27 c2-measure.py precedent); mutate_receipt=0 leaves the BASE receipt
untouched (literal reading of "release-clocks.tsv edits only").
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

GROUPS = {
    "G1-SOPS":    (["S008", "S009", "S010", "S011"], "S033"),
    "G2-Vault":   (["S013", "S022", "S023", "S024"], "S034"),
    "G3-OpenBao": (["S014", "S015", "S016", "S021", "S025", "S026"], "S035"),
    "G4-curl":    (["S029"], "S037"),
}
# lower canonical versions: (primary, alternative) per group
LOWER = {
    "G1-SOPS":    ("3.13.2", "3.0.0"),
    "G2-Vault":   ("2.1.0", "2.0.0"),
    "G3-OpenBao": ("2.7.0", "2.0.0"),
    "G4-curl":    ("8.22.0", "8.0.0"),
}


def build_fixture(base, root, edits, lower, mutate_receipt):
    rows, feed_id = edits
    (root / "corpus").mkdir(parents=True, exist_ok=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(base / "corpus" / rel, root / "corpus" / rel)
    lines = (base / "corpus/release-clocks.tsv").read_text().splitlines(keepends=True)
    changed = []
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in rows:
            fields[4] = lower          # anchored_version
            fields[5] = lower          # observed_version
            fields[7] = "not-fired"    # verdict
            lines[index] = "\t".join(fields) + "\n"
            changed.append(fields[0])
    (root / "corpus/release-clocks.tsv").write_text("".join(lines))
    receipt = json.loads((base / ".ufo/waves/round-26/observe-2.json").read_text())
    if mutate_receipt:
        for record in receipt["observations"]:
            if record["id"] in rows:
                record["parsed_version"] = lower
                record["verdict"] = "not-fired"
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
    return changed, receipt_path, sha


def run(base, root, receipt_path, sha):
    argv = ["python3", "-I", "-B", str(base / "corpus/release-clock.py"),
            "--root", str(root), "--receipt", str(receipt_path), "--receipt-sha", sha]
    proc = subprocess.run(argv, text=True, capture_output=True, timeout=120)
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    last = lines[-1] if lines else ""
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr[-2000:], "last_line": last, "findings": findings,
            "accepted_clean": proc.returncode == 0 and last.startswith("RELEASE_CLOCK: CLEAN")}


def main():
    base = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    mutate = sys.argv[3] != "0" if len(sys.argv) > 3 else True
    work = base.parent / "probe-work"
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    results = {}
    for name, (rows, feed_id) in GROUPS.items():
        for tag, lower in (("lower", LOWER[name][0]), ("lower-alt", LOWER[name][1])):
            root = work / ("%s-%s" % (name, tag))
            changed, receipt_path, sha = build_fixture(base, root, (rows, feed_id), lower, mutate)
            res = run(base, root, receipt_path, sha)
            res["changed_rows"] = changed
            res["lower"] = lower
            res["feed_source_id"] = feed_id
            results["%s/%s" % (name, tag)] = res
    # control: unmodified table + BASE receipt
    ctl_root = work / "control"
    ctl_root.mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py", "release-clocks.tsv"):
        shutil.copy2(base / "corpus" / rel, ctl_root / "corpus" / rel) if False else None
    (ctl_root / "corpus").mkdir(parents=True, exist_ok=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py", "release-clocks.tsv"):
        shutil.copy2(base / "corpus" / rel, ctl_root / "corpus" / rel)
    receipt = json.loads((base / ".ufo/waves/round-26/observe-2.json").read_text())
    rp = ctl_root / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    results["control"] = run(base, ctl_root, rp, sha)
    # default command (no --root/--receipt) inside the BASE tree
    dp = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py"], cwd=base,
                        text=True, capture_output=True, timeout=120)
    results["default"] = {"exit": dp.returncode, "stdout": dp.stdout, "stderr": dp.stderr[-2000:]}
    summary = {
        "mutate_receipt": mutate,
        "accepted_clean": sum(1 for k, v in results.items()
                              if k != "control" and k != "default" and v.get("accepted_clean")),
        "groups": len(GROUPS),
        "results": results,
    }
    out.write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
