#!/usr/bin/env python3
"""XC2Patch G-fixture driver: frozen C2 shape (release-clocks.tsv edits only),
with the receipt rewritten to match the forged observations -- the step the
frozen plan omits but the measuring tool must do (receipt binding).

For each derived group: lower every derived anchor on the feed to one lower
canonical version, set observed equal (verdict stays not-fired), rebuild the
receipt from the retained round-26 receipt with matching parsed_version, then
run BASE and PATCHED clocks against the same work tree + receipt.
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

S = Path(__file__).resolve().parent
BASE = S / "base"
LANE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")

GROUPS = {
    "G1-SOPS": (["S008", "S009", "S010", "S011"], "3.13.2"),
    "G2-Vault": (["S013", "S022", "S023", "S024"], "2.1.9"),
    "G3-OpenBao": (["S014", "S015", "S016", "S021", "S025", "S026"], "2.7.0"),
    "G4-curl": (["S029"], "8.22.1"),
}


def build_work(name, rows, lowered):
    work = S / ("gwork-" + name)
    if work.exists():
        shutil.rmtree(work)
    shutil.copytree(BASE, work)
    tsv = work / "corpus" / "release-clocks.tsv"
    lines = tsv.read_text(encoding="utf-8").splitlines()
    out = []
    for line in lines:
        fields = line.split("\t")
        if len(fields) == 9 and fields[0] in rows:
            assert fields[7] == "not-fired", fields
            fields[4] = lowered
            fields[5] = lowered
            out.append("\t".join(fields))
        else:
            out.append(line)
    tsv.write_text("\n".join(out) + "\n", encoding="utf-8")
    receipt_src = work / ".ufo" / "waves" / "round-26" / "observe-2.json"
    doc = json.loads(receipt_src.read_text(encoding="utf-8"))
    hits = 0
    for record in doc["observations"]:
        if record.get("id") in rows:
            record["parsed_version"] = lowered
            hits += 1
    assert hits == len(rows), (name, hits)
    receipt = work / "receipt.json"
    receipt.write_text(json.dumps(doc, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                       encoding="utf-8")
    return work, receipt


def run(clock, work, receipt):
    sha = hashlib.sha256(receipt.read_bytes()).hexdigest()
    proc = subprocess.run(
        [sys.executable, "-I", "-B", str(clock), "--root", str(work),
         "--receipt", str(receipt), "--receipt-sha", sha],
        capture_output=True, text=True)
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


def main():
    patched = S / "work" / "corpus" / "release-clock.py"
    base_clock = BASE / "corpus" / "release-clock.py"
    for name, (rows, lowered) in GROUPS.items():
        work, receipt = build_work(name, rows, lowered)
        base_rc, base_out, _ = run(base_clock, work, receipt)
        patch_rc, patch_out, _ = run(patched, work, receipt)
        print("== %s lower=%s rows=%s" % (name, lowered, ",".join(rows)))
        print("BASE    exit=%d" % base_rc)
        print(base_out)
        print("PATCHED exit=%d" % patch_rc)
        print(patch_out)


if __name__ == "__main__":
    main()
