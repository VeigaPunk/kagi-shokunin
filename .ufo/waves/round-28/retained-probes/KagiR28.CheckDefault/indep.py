#!/usr/bin/env python3
"""Independent recount of the default release-clock counters (no lane code imported).

Usage: indep.py <tree-root>
Prints the six counters the tool prints, computed from
corpus/SOURCES.md, corpus/release-clocks.tsv and the default receipt.
"""
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()

# --- registry: SOURCES.md -------------------------------------------------
registry = {}
for line in (root / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines():
    if not line.startswith("| S"):
        continue
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) < 11:
        continue
    registry[cells[0]] = {
        "anchor": cells[5],
        "teaches": cells[6],
        "status": cells[7],
        "recheck": cells[9],
    }
on_release = sorted(k for k, v in registry.items() if v["recheck"] == "on-release")

# --- rows: release-clocks.tsv --------------------------------------------
rows = []
lines = (root / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines()
header = lines[0].split("\t")
for line in lines[1:]:
    if not line.strip():
        continue
    cells = line.split("\t")
    rows.append(dict(zip(header, cells)))

bound = [r for r in rows if r["feed_source_id"] != "-"
         and r["feed_source_id"] in registry]
unbound = [r for r in rows if r["feed_source_id"] != "-"
           and r["feed_source_id"] not in registry]
derived = [r for r in rows if r["note"].startswith("derived:")]
fired = [r for r in rows if r["verdict"] == "fired"]

# --- receipt --------------------------------------------------------------
receipt = json.loads(
    (root / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text(encoding="utf-8"))
obs = {o["id"]: o for o in receipt["observations"]}
observed = [r for r in rows if r["id"] in obs]
missing_obs = [r["id"] for r in rows if r["id"] not in obs]
extra_obs = [k for k in obs if k not in {r["id"] for r in rows}]

print("rows=%d on_release=%d bound=%d unbound=%d observed=%d fired=%d derived=%d"
      % (len(rows), len(on_release), len(bound), len(unbound),
         len(observed), len(fired), len(derived)))
print("fired_ids=%s" % ",".join(sorted(r["id"] for r in fired)))
print("derived_ids=%s" % ",".join(sorted(r["id"] for r in derived)))
print("unbound_ids=%s missing_obs=%s extra_obs=%s"
      % (",".join(r["id"] for r in unbound), ",".join(missing_obs), ",".join(extra_obs)))
print("on_release_ids=%s" % ",".join(on_release))

# --- C2 binding: derived row's anchored version vs its feed row's located anchor
print("--- C2 binding (derived row anchored_version vs feed registry located anchor) ---")
bad = 0
for r in sorted(derived, key=lambda x: x["id"]):
    feed = registry.get(r["feed_source_id"])
    anchor_cell = feed["anchor"] if feed else ""
    # "located anchor" = the first canonical X.Y.Z token named in the anchor cell
    toks = re.findall(r"(?<![0-9.])v?(\d+\.\d+\.\d+)(?![0-9.+-])", anchor_cell)
    ok = toks and toks[0] == r["anchored_version"]
    if not ok:
        bad += 1
    print("%s feed=%s anchored=%s registry_anchor_tokens=%s %s"
          % (r["id"], r["feed_source_id"], r["anchored_version"], toks,
             "OK" if ok else "MISMATCH"))
print("c2_binding_mismatches=%d" % bad)
