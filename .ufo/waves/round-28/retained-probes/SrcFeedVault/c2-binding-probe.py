"""Offline probe: would C2's "derived anchor == version named by feed row anchor" hold at BASE?

Imports BASE release-clock.py pure helpers only (main is guarded).
"""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("rc_base", HERE / "release-clock.BASE.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

HEADER = ["id", "source", "kind", "tier", "scope", "anchor", "teaches", "status",
          "opened", "recheck", "used-by"]


def source_rows(path):
    rows = {}
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.startswith("| S"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 11:
            print("MALFORMED", lineno, len(cells))
            continue
        rows[cells[0]] = dict(zip(HEADER, cells))
    return rows


sources = source_rows(HERE / "SOURCES.BASE.md")
print("sources:", len(sources))

clock_header = (HERE / "release-clocks.BASE.tsv").read_text(encoding="utf-8").splitlines()[0].split("\t")
derived = []
for line in (HERE / "release-clocks.BASE.tsv").read_text(encoding="utf-8").splitlines()[1:]:
    if not line.strip():
        continue
    vals = dict(zip(clock_header, line.split("\t")))
    if vals["note"].startswith("derived:"):
        derived.append(vals)

print("derived rows:", len(derived))
bad = 0
for v in derived:
    feed = sources.get(v["feed_source_id"])
    anchor_cell = feed["anchor"] if feed else "<missing feed row>"
    ok = feed is not None and rc.version_is_named(anchor_cell, v["anchored_version"])
    if not ok:
        bad += 1
    print(("OK  " if ok else "FAIL"), v["id"], "feed", v["feed_source_id"],
          "anchored", v["anchored_version"], "| cell:", anchor_cell[:90])
print("SUMMARY fail=%d/%d" % (bad, len(derived)))

# Locator-hole demonstrations on the Vault feed anchor cell (BASE SOURCES.md:40)
cell = sources["S034"]["anchor"]
print("\nS034 anchor cell:", cell)
for probe in ["2.2.0", "2.2.0-rc1", "0.26.0", "2.2.0-rc1\n"]:
    p = probe.strip()
    print("version_is_named(S034.anchor, %r) = %s" % (p, rc.version_is_named(cell, p)))

# Trap: a feed cell that names the prerelease also "names" its stable core.
trap = "Entry titled v2.2.0-rc1, tag link /releases/tag/v2.2.0-rc1"
print("trap cell:", trap)
for probe in ["2.2.0", "2.2.0-rc1"]:
    print("version_is_named(trap, %r) = %s" % (probe, rc.version_is_named(trap, probe)))

# Trap 2: a feed cell naming an sdk/ module tag.
trap2 = "Entry titled sdk/v0.26.0, tag link /releases/tag/sdk/v0.26.0"
print("trap2 cell:", trap2)
for probe in ["0.26.0"]:
    print("version_is_named(trap2, %r) = %s" % (probe, rc.version_is_named(trap2, probe)))

# C1 helper surface: numeric_version on oversize / leading zero
for probe in ["3.15.01", "3.15.1", "3.15." + "1" * 4301]:
    try:
        print("numeric_version(%r...) =" % probe[:20], rc.numeric_version(probe))
    except Exception as exc:  # noqa: BLE001 - probing for untyped failure
        print("numeric_version(%r...) raised %s: %s" % (probe[:20], type(exc).__name__, exc))
sys.exit(0)
