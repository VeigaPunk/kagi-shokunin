#!/usr/bin/env python3
"""Vault feed floor: unmodified candidate tree vs the G2-lowered fixture.

feed_floors() takes the MAX numeric anchor over every row on the feed URL.
The vault feed's only numeric anchors are the derived rows S013/S022/S023/S024
(S012's own anchor v1.21.x is non-numeric), so the G2 lowering also moves the
floor from 2.2.0 down to 2.1.9 -- and that floor is S012's ONLY regression
guard.

Prints the floor in the unmodified tree and in the G2 fixture, and shows
whether a stale S012 observation (2.1.9) is caught at each floor.
"""
import importlib.util
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import g2  # noqa: E402

WORK = Path("/fast/scratch/kagi-r28-fdderivevault/floors")


def load_mod(tree):
    spec = importlib.util.spec_from_file_location("rc_f", tree / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def floor_of(tree, work):
    mod = load_mod(tree)
    root, receipt, _, _, _ = g2.build(tree, work)
    rows = mod.parse_bindings(root)
    floors = mod.feed_floors(rows)
    return floors.get("https://github.com/hashicorp/vault/releases.atom")


def stale_s012_caught(tree, work):
    """S012 observation staled to 2.1.9 with the group UNTOUCHED (floor 2.2.0)."""
    mod = load_mod(tree)
    root = work / "root"
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(tree / "corpus" / rel, root / "corpus" / rel)
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] == "S012":
            fields[5] = "2.1.9"
            fields[7] = "fired"
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")
    import json
    records = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json")
                         .read_text(encoding="utf-8"))
    for record in records["observations"]:
        if record.get("id") == "S012":
            record["parsed_version"] = "2.1.9"
            record["verdict"] = "fired"
    receipt = root / "receipt.json"
    receipt.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    sources = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)
    receipts = mod.load_receipt_bundle(receipt, None)
    result = mod.evaluate(sources, rows, captures, receipts)
    floors = mod.feed_floors(rows)
    return (floors.get("https://github.com/hashicorp/vault/releases.atom"),
            [e for e in result["errors"] if e[1] == "S012"])


if __name__ == "__main__":
    for label in ("cand", "base"):
        tree = Path(sys.argv[1]).resolve().parent / label
        w = WORK / label
        if w.exists():
            shutil.rmtree(w)
        w.mkdir(parents=True)
        print("== %s ==" % label)
        print("   vault floor, UNMODIFIED tree = %s" % floor_of(tree, w / "unmod"))
        print("   vault floor, G2-LOWERED tree = %s" % floor_of(tree, w / "g2"))
        print("   stale S012 (2.1.9), group untouched -> floor=%s S012 errors=%s"
              % stale_s012_caught(tree, w / "stale"))
