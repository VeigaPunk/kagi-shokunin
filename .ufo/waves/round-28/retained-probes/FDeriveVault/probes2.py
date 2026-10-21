#!/usr/bin/env python3
"""Boundary probes for the G2 (Vault / feed S034) carrier, candidate tree only.

P1 partial lowering: lower only S013 and S022 (leave S023, S024 at 2.2.0).
   Expected: the two lowered rows get DERIVATION; the untouched rows keep the
   vault feed floor at 2.2.0, so the lowered rows may ALSO be REGRESSED
   (observed 2.1.9 < floor 2.2.0). Probe: which categories, which row ids?
P2 forger-edits-both: also rewrite the S034 registry anchor cell to name 2.1.9.
   Expected (per QM28's stated limitation): the lowering is accepted CLEAN.
   This is the residual bypass to report, not a frozen-fixture result.
P3 no-write check: confirm a verify-mode run writes no file under the root.
"""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

GROUP = ["S013", "S022", "S023", "S024"]
LOWER = "2.1.9"
FEED = "S034"
TREE = Path(sys.argv[1]).resolve()
WORK = Path("/fast/scratch/kagi-r28-fdderivevault")


def build(work: Path, lower_rows, forge_sources: bool):
    if work.exists():
        shutil.rmtree(work)
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(TREE / "corpus" / rel, root / "corpus" / rel)
    if forge_sources:
        text = (root / "corpus" / "SOURCES.md").read_text(encoding="utf-8")
        out = []
        for line in text.splitlines(keepends=True):
            s = line.strip()
            if s.startswith("|"):
                cells = s[1:].split("|")
                if cells and not cells[-1].strip():
                    cells.pop()
                cells = [c.strip() for c in cells]
                if cells and cells[0] == FEED:
                    cells[5] = ("Entry titled v%s, tag link /releases/tag/v%s, "
                                "updated 2026-10-15T18:50:14Z; feed fetched 2026-10-21"
                                % (LOWER, LOWER))
                    line = "|" + "|".join(cells) + "|\n"
            out.append(line)
        (root / "corpus" / "SOURCES.md").write_text("".join(out), encoding="utf-8")

    lines = (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in lower_rows:
            fields[4] = LOWER
            fields[5] = LOWER
            fields[7] = "not-fired"
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")

    records = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    for record in records["observations"]:
        if record.get("id") in lower_rows:
            record["parsed_version"] = LOWER
            record["verdict"] = "not-fired"
    receipt = root / "receipt.json"
    receipt.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    return root, receipt


def run(root, receipt, tag):
    argv = ["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(receipt),
            "--receipt-sha", hashlib.sha256(receipt.read_bytes()).hexdigest()]
    before = sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())
    proc = subprocess.run(argv, cwd=TREE, text=True, capture_output=True)
    after = sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())
    print("== %s ==" % tag)
    print("   exit=%d traceback=%s" % (proc.returncode,
          "Traceback" in proc.stdout or "Traceback" in proc.stderr))
    for line in proc.stdout.splitlines():
        print("   |", line)
    if proc.stderr.strip():
        print("   stderr:", proc.stderr.strip()[:400])
    print("   files_created=%s" % sorted(set(after) - set(before)))
    return proc


def main():
    root, receipt = build(WORK / "p1", ["S013", "S022"], False)
    run(root, receipt, "P1 partial lowering (S013,S022 only)")
    root, receipt = build(WORK / "p2", GROUP, True)
    run(root, receipt, "P2 forger edits SOURCES.md S034 anchor cell too")
    root, receipt = build(WORK / "p3", GROUP, False)
    run(root, receipt, "P3 full G2 (control for this probe set)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
