#!/usr/bin/env python3
"""Independent G2 (Vault feed S034) reproduction for round-28 falsification.

Builds the G2 fixture by hand from the candidate tree (NOT via the frozen
tool's fixture builder) so the fixture is independently authored:

  feed S034 rows S013, S022, S023, S024 are the author-declared `derived:`
  rows on the Vault feed. Lower every one of them to the same lower canonical
  version 2.1.9 (anchored_version AND observed_version), verdict not-fired,
  and mirror exactly those rows into a copy of the default receipt
  (parsed_version + verdict), so the run cannot end on a generic
  RECEIPT-MISMATCH.

  S012 is the non-derived row on the SAME feed S034 (anchor v1.21.x, observed
  2.2.0, verdict fired). It is left untouched in the table and in the receipt:
  it must survive with no DERIVATION finding and still counted fired.

Usage: g2.py <tree-root> <label>
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


def build(tree: Path, work: Path):
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(tree / "corpus" / rel, root / "corpus" / rel)

    table = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8")
    lines = table.splitlines(keepends=True)
    edited, kept012 = [], None
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in GROUP:
            assert fields[2] == FEED, (fields[0], fields[2])
            assert fields[8].startswith("derived:"), fields[0]
            fields[4] = LOWER
            fields[5] = LOWER
            fields[7] = "not-fired"
            lines[index] = "\t".join(fields) + "\n"
            edited.append(fields[0])
        elif fields[0] == "S012":
            kept012 = list(fields)
    assert sorted(edited) == sorted(GROUP), edited
    assert kept012 is not None and kept012[2] == FEED, kept012
    (root / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")

    default = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    records = json.loads(json.dumps(default))
    mirrored = []
    for record in records["observations"]:
        if record.get("id") in GROUP:
            record["parsed_version"] = LOWER
            record["verdict"] = "not-fired"
            mirrored.append(record["id"])
    assert sorted(mirrored) == sorted(GROUP), mirrored
    receipt = root / "receipt.json"
    receipt.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    return root, receipt, edited, mirrored, kept012


def main():
    tree = Path(sys.argv[1]).resolve()
    label = sys.argv[2]
    work = Path("/fast/scratch") if Path("/fast/scratch").is_dir() else Path("/tmp")
    work = work / "kagi-r28-fdderivevault" / label
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    root, receipt, edited, mirrored, kept012 = build(tree, work)
    argv = ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(receipt),
            "--receipt-sha", hashlib.sha256(receipt.read_bytes()).hexdigest()]
    proc = subprocess.run(argv, cwd=tree, text=True, capture_output=True)
    print("### %s argv: %s" % (label, " ".join(argv)))
    print("### exit=%d" % proc.returncode)
    print("--- stdout ---")
    print(proc.stdout, end="")
    if proc.stderr:
        print("--- stderr ---")
        print(proc.stderr, end="")
    print("### traceback_in_stdout=%s traceback_in_stderr=%s"
          % ("Traceback" in proc.stdout, "Traceback" in proc.stderr))
    findings = [ln for ln in proc.stdout.splitlines()
                if ln.strip() and not ln.startswith("RELEASE_CLOCK:")]
    ids = []
    for ln in findings:
        import re
        ids += re.findall(r"(?<![A-Za-z0-9])S[0-9]{3}(?![0-9])", ln)
    print("### findings=%r" % (findings,))
    print("### named_ids=%s expected=%s exact_set=%s"
          % (sorted(set(ids)), sorted(GROUP), sorted(set(ids)) == sorted(GROUP)))
    print("### s012_in_findings=%s" % ("S012" in ids))
    print("### categories=%s" % sorted({ln.split("S0")[0].strip() for ln in findings}))
    print("### edited=%s mirrored=%s" % (edited, mirrored))
    print("### s012_row_kept=%r" % (kept012,))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
