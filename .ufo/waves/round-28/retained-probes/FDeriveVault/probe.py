#!/usr/bin/env python3
"""Per-row status probe for the G2 fixture: which rows are observed/fired/derived
and which carry which error category, in BASE and in the candidate.

Also probes the feed-floor coupling: feed_floors() derives the vault feed's
numeric floor from the *anchor* column of every row on that feed URL, so
lowering the derived group's anchor also moves the floor that guards the
non-derived row S012.
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import g2  # noqa: E402


def load(tree: Path):
    spec = importlib.util.spec_from_file_location("rc_%s" % tree.name,
                                                  tree / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def status(mod, root: Path, receipt: Path):
    sources = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)
    receipts = mod.load_receipt_bundle(receipt, None)
    result = mod.evaluate(sources, rows, captures, receipts)
    floors = mod.feed_floors(rows)
    return result, floors, rows


def main():
    for label in ("cand", "base"):
        tree = Path(sys.argv[1]).resolve().parent / label
        work = Path("/fast/scratch/kagi-r28-fdderivevault/probe-" + label)
        if work.exists():
            shutil.rmtree(work)
        work.mkdir(parents=True)
        root, receipt, edited, mirrored, kept = g2.build(tree, work)
        mod = load(tree)
        result, floors, rows = status(mod, root, receipt)
        print("== %s ==" % label)
        print("  errors:", result["errors"])
        print("  counts:", {k: result[k] for k in
                           ("on_release", "bound", "unbound", "observed", "fired", "derived")})
        vault = "https://github.com/hashicorp/vault/releases.atom"
        print("  vault feed floor:", floors.get(vault))
        # per-row derived classification
        for row in rows:
            vals = dict(zip(mod.HEADER, row["fields"]))
            if vals["feed_url"] != vault:
                continue
            print("   ", vals["id"], "anchor=%s observed=%s verdict=%s derived=%s"
                  % (vals["anchored_version"], vals["observed_version"],
                     vals["verdict"], vals["note"].startswith("derived:")))
        print("  S012 in errors:", [e for e in result["errors"] if e[1] == "S012"])
        # what does evaluate think of S012 in isolation?
        print()


if __name__ == "__main__":
    raise SystemExit(main())
