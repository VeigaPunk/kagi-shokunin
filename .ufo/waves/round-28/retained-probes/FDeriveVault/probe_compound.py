#!/usr/bin/env python3
"""Compound probe for the G2 (Vault S034) carrier: S012's REGRESSED guard.

feed_floors() (corpus/release-clock.py:440) takes the MAX numeric anchor over
every row on a feed URL. The vault feed's only numeric anchors are the derived
rows S013/S022/S023/S024; S012's own anchor is the non-numeric series v1.21.x.
So S012 has NO anchor of its own -- its only regression guard is that shared
feed floor.

Compound fixture: the G2 group lowering (2.1.9) PLUS a stale S012 observation
(2.1.9), PLUS a forger edit of the S034 registry anchor cell to name 2.1.9
(the disclosed "editing the feed row's anchor cell together still passes"
limit, corpus/lessons/round-28.md §Limits).

Q1 at BASE: does the compound forgery read CLEAN (i.e. is S012's stale
   observation silently accepted because the floor moved with the forgery)?
Q2 at candidate: does the group lowering still raise DERIVATION (so the
   forgery is caught), and is S012 itself flagged?
Q3 at candidate with the SOURCES.md edit too: does the whole run go CLEAN,
   and is S012's REGRESSED guard still gone?
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

GROUP = ["S013", "S022", "S023", "S024"]
LOWER = "2.1.9"
FEED = "S034"
WORK = Path("/fast/scratch/kagi-r28-fdderivevault")


def load_mod(tree):
    spec = importlib.util.spec_from_file_location("rc_c", tree / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def build(tree: Path, work: Path, lower_group, stale_s012, forge_sources):
    if work.exists():
        shutil.rmtree(work)
    root = work / "root"
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(tree / "corpus" / rel, root / "corpus" / rel)
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
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if lower_group and fields[0] in GROUP:
            fields[4] = LOWER
            fields[5] = LOWER
            fields[7] = "not-fired"
            lines[index] = "\t".join(fields) + "\n"
        elif stale_s012 and fields[0] == "S012":
            fields[5] = LOWER
            fields[7] = "fired"
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


def run(tree: Path, tag, lower_group, stale_s012, forge_sources):
    mod = load_mod(tree)
    root, receipt = build(tree, WORK / tag, lower_group, stale_s012, forge_sources)
    sources = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)
    receipts = mod.load_receipt_bundle(receipt, None)
    result = mod.evaluate(sources, rows, captures, receipts)
    floors = mod.feed_floors(rows)
    vault = "https://github.com/hashicorp/vault/releases.atom"
    print("== %s ==" % tag)
    print("   floor=%s  passed=%s" % (floors.get(vault), result["passed"]))
    print("   errors=%s" % (result["errors"],))
    print("   S012 errors=%s" % ([e for e in result["errors"] if e[1] == "S012"],))


if __name__ == "__main__":
    base = Path(sys.argv[1]).resolve().parent / "base"
    cand = Path(sys.argv[1]).resolve().parent / "cand"
    run(base, "c1-base-compound-no-sources-edit", True, True, False)
    run(cand, "c2-cand-compound-no-sources-edit", True, True, False)
    run(cand, "c3-cand-compound-with-sources-edit", True, True, True)
    run(base, "c4-base-compound-with-sources-edit", True, True, True)
