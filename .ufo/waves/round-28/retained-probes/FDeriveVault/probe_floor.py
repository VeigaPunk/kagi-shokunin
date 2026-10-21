#!/usr/bin/env python3
"""Floor-coupling probe for the G2 (Vault S034) carrier.

feed_floors() (corpus/release-clock.py:440) takes the MAX numeric anchor over
every feed row on a feed URL. The vault feed's only numeric anchors are the
derived rows S013/S022/S023/S024 (S012's anchor v1.21.x is non-numeric), so
the G2 lowering also MOVES THE FLOOR from 2.2.0 down to 2.1.9.

Q: with the G2 lowering in place, does S012 (the non-derived row on the same
feed, which has NO anchor of its own to protect it) still get the REGRESSED
guard that BASE gives it?

Fixture: G2 lowering (S013/S022/S023/S024 -> 2.1.9) PLUS S012's observation
staled to 2.1.9 (a cropped/stale feed reading). BASE (group not lowered) must
call S012 REGRESSED (floor 2.2.0). Candidate (group lowered) has floor 2.1.9,
so S012's stale 2.1.9 observation is no longer below the floor.

Both runs also lower the group, so the candidate still raises DERIVATION for
the four rows; this probe asks only about S012's own classification.
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

GROUP = ["S013", "S022", "S023", "S024"]
LOWER = "2.1.9"
WORK = Path("/fast/scratch/kagi-r28-fdderivevault")


def load_mod(tree):
    spec = importlib.util.spec_from_file_location("rc_fc", tree / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def build(tree: Path, work: Path, lower_group: bool, stale_s012: bool):
    if work.exists():
        shutil.rmtree(work)
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(tree / "corpus" / rel, root / "corpus" / rel)
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if lower_group and fields[0] in GROUP:
            fields[4] = LOWER
            fields[5] = LOWER
            fields[7] = "not-fired"
            lines[index] = "\t".join(fields) + "\n"
        elif stale_s012 and fields[0] == "S012":
            fields[5] = LOWER          # observed_version staled to 2.1.9
            fields[7] = "fired"       # 2.1.9 != anchor v1.21.x -> "fired"
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")
    records = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    for record in records["observations"]:
        if lower_group and record.get("id") in GROUP:
            record["parsed_version"] = LOWER
            record["verdict"] = "not-fired"
        elif stale_s012 and record.get("id") == "S012":
            record["parsed_version"] = LOWER
            record["verdict"] = "fired"
    receipt = root / "receipt.json"
    receipt.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    return root, receipt


def run(tree: Path, tag, lower_group, stale_s012):
    mod = load_mod(tree)
    root, receipt = build(tree, WORK / tag, lower_group, stale_s012)
    sources = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)
    receipts = mod.load_receipt_bundle(receipt, None)
    result = mod.evaluate(sources, rows, captures, receipts)
    floors = mod.feed_floors(rows)
    vault = "https://github.com/hashicorp/vault/releases.atom"
    s012 = [e for e in result["errors"] if e[1] == "S012"]
    print("== %s ==" % tag)
    print("   vault floor=%s  S012 errors=%s" % (floors.get(vault), s012))
    print("   all errors=%s" % (result["errors"],))
    print("   counts=%s" % {k: result[k] for k in ("observed", "fired", "derived")})


if __name__ == "__main__":
    base = Path(sys.argv[1]).resolve().parent / "base"
    cand = Path(sys.argv[1]).resolve().parent / "cand"
    # A: stale S012 alone (group untouched) -> BASE reference for the guard
    run(base, "A-base-staleS012-only", False, True)
    run(cand, "A-cand-staleS012-only", False, True)
    # B: stale S012 + G2 lowering -> does the lowering move the floor under S012?
    run(base, "B-base-staleS012-plus-G2", True, True)
    run(cand, "B-cand-staleS012-plus-G2", True, True)
