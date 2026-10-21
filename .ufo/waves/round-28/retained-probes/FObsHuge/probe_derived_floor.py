#!/usr/bin/env python3
"""FObsHuge probe 3: adjacent carriers of the SAME table observation carrier.

(a) a derived row whose ANCHOR carries the 4301-digit token -> which typed
    category wins (NON-CANONICAL vs DERIVATION)?
(b) a second row on the SAME feed_url whose ANCHOR carries the 4301-digit
    token -> does it poison the feed floor and produce a false REGRESSED on a
    legitimate sibling row? (feed_floors must skip a non-canonical anchor.)
(c) a rendered-quote row whose observed_version carries the token -> typed?
All runs use a receipt mirrored to the fixture token so a receipt mismatch can
never explain the finding.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

src = Path(sys.argv[1]).resolve()
work = Path(sys.argv[2]).resolve()
OVERSIZE = "3.15." + "1" * 4301
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")
BASE_ERA = {"ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
            "RECEIPT-MISMATCH", "NOT OBSERVED"}


def table_with(edits):
    """edits: row_id -> {field_index: value}"""
    lines = (src / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            for index, value in edits[fields[0]].items():
                fields[index] = str(value)
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def run(name, table_text, receipt_edits):
    root = work / name
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(src / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    receipt = json.loads((src / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record.get("id") in receipt_edits:
            for key, value in receipt_edits[record["id"]].items():
                record[key] = value
    path = root / "receipt.json"
    path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    sha = hashlib.sha256(path.read_bytes()).hexdigest()
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(work),
           "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    proc = subprocess.run(
        ["python3", "-I", "-B", str(src / "corpus" / "release-clock.py"),
         "--root", str(root), "--receipt", str(path), "--receipt-sha", sha],
        cwd=str(src), env=env, text=True, capture_output=True, timeout=120)
    findings = [ln.strip() for ln in proc.stdout.splitlines()
                if ln.strip() and not ln.startswith("RELEASE_CLOCK")]
    print("### %s" % name)
    print("exit=%d findings=%s" % (proc.returncode, json.dumps(findings)))
    print("summary=%s" % json.dumps([ln for ln in proc.stdout.splitlines()
                                     if ln.startswith("RELEASE_CLOCK")]))
    print("traceback=%s stderr=%s" % ("Traceback" in proc.stdout + proc.stderr,
                                      json.dumps(proc.stderr.splitlines()[-2:])))
    print("non_base_era=%s" % json.dumps([f.split()[0] for f in findings
                                          if f.split()[0] not in BASE_ERA]))
    print()
    return findings


if __name__ == "__main__":
    work.mkdir(parents=True, exist_ok=True)
    # (a) derived row anchor oversize. S033-S037 are feed rows; find a derived row.
    rows = (src / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines()
    derived = [ln.split("\t")[0] for ln in rows if "\tderived:" in ln]
    print("derived rows:", derived)
    target = derived[0]
    run("a-derived-anchor-oversize",
        table_with({target: {4: OVERSIZE, 5: OVERSIZE}}),
        {target: {"parsed_version": OVERSIZE, "verdict": "fired"}})
    # (b) sibling row on the same feed_url with an oversize anchor.
    feed_url = None
    for ln in rows:
        fields = ln.split("\t")
        if fields and fields[0] == "S040":
            feed_url = fields[3]
    siblings = [ln.split("\t")[0] for ln in rows
                if ln.split("\t") and len(ln.split("\t")) > 3 and ln.split("\t")[3] == feed_url]
    print("siblings on", feed_url, ":", siblings)
    sibling = [s for s in siblings if s != "S040"][0]
    run("b-sibling-oversize-anchor",
        table_with({sibling: {4: OVERSIZE, 5: OVERSIZE},
                    "S040": {5: OVERSIZE, 7: "fired"}}),
        {sibling: {"parsed_version": OVERSIZE, "verdict": "fired"},
         "S040": {"parsed_version": OVERSIZE, "verdict": "fired"}})
    # (c) rendered-quote row with an oversize observed_version
    quote_rows = [ln.split("\t")[0] for ln in rows
                  if len(ln.split("\t")) > 1 and ln.split("\t")[1] == "rendered-quote"]
    print("rendered-quote rows:", quote_rows[:4])
    q = quote_rows[0]
    run("c-quote-row-oversize-observed",
        table_with({q: {5: OVERSIZE}}), {q: {"parsed_version": OVERSIZE}})
