#!/usr/bin/env python3
"""Re-point probe for the G2 (Vault S034) carrier, candidate tree.

QM28 (corpus/QUALITY.md:135) discloses: "a forger who edits both, or re-points
the row to another feed, still passes until the feed row's scope is bound too."

R1 re-point S013 to feed S033 (SOPS) keeping its forged anchor 2.1.9.
   Expect: DERIVATION still fires (S033's anchor cell names 3.13.3, not 2.1.9).
R2 re-point S013 to feed S033 AND change its anchor to 3.13.3 (fully self-
   consistent re-point). Expect: no DERIVATION for S013 -> the disclosed
   limitation is real and reachable with a table-only edit.
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

WORK = Path("/fast/scratch/kagi-r28-fdderivevault")
TREE = Path(sys.argv[1]).resolve()


def load_mod():
    spec = importlib.util.spec_from_file_location("rc_rp", TREE / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def build(work: Path, edits):
    if work.exists():
        shutil.rmtree(work)
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(TREE / "corpus" / rel, root / "corpus" / rel)
    lines = (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in edits:
            for col, val in edits[fields[0]].items():
                fields[col] = val
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")
    records = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    for record in records["observations"]:
        if record.get("id") in edits:
            if "anchor" in edits[record["id"]]:
                record["parsed_version"] = edits[record["id"]]["anchor"]
            if "verdict" in edits[record["id"]]:
                record["verdict"] = edits[record["id"]]["verdict"]
    receipt = root / "receipt.json"
    receipt.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    return root, receipt


def run(tag, edits):
    mod = load_mod()
    root, receipt = build(WORK / tag, edits)
    sources = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)
    receipts = mod.load_receipt_bundle(receipt, None)
    result = mod.evaluate(sources, rows, captures, receipts)
    print("== %s ==" % tag)
    print("   errors=%s" % (result["errors"],))
    print("   counts=%s" % {k: result[k] for k in ("observed", "fired", "derived")})


if __name__ == "__main__":
    # R1: re-point S013 to the SOPS feed, keep the forged 2.1.9 anchor
    run("r1-repoint-keep-forged", {
        "S013": {2: "S033", 3: "https://github.com/getsops/sops/releases.atom",
                 4: "2.1.9", 5: "2.1.9", 7: "not-fired"}})
    # R2: re-point S013 to SOPS and make the anchor match SOPS' anchor cell
    run("r2-repoint-self-consistent", {
        "S013": {2: "S033", 3: "https://github.com/getsops/sops/releases.atom",
                 4: "3.13.3", 5: "3.13.3", 7: "not-fired"}})
