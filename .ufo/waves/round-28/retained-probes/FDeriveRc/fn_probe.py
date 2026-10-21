"""Function-level probes of the candidate's derived-anchor binding rule.

Usage: fn_probe.py <tree-root>
Imports corpus/release-clock.py from the given tree and prints the decision of
version_is_named (the round-27 reading) and derived_anchor_bound (round-28 C2)
for a set of feed-row anchor cells.
"""
import importlib.util
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
spec = importlib.util.spec_from_file_location("release_clock", root / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

CELLS = {
    "stable only (as committed)": "Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z; feed fetched 2026-10-21",
    "prerelease only": "Entry titled v2.2.0-rc1, tag link /releases/tag/v2.2.0-rc1, updated 2026-10-15T18:50:14Z; feed fetched 2026-10-21",
    "stable + same-feed rc": "Entry titled v2.2.0 (the same feed also lists v2.2.0-rc1), tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z",
    "rc + sdk module tag": "Entry titled v2.2.0-rc1, tag link /releases/tag/v2.2.0-rc1, sdk/v0.26.0, updated 2026-10-15T18:50:14Z",
    "two stable versions": "Entries titled v2.2.0 and v2.3.0, updated 2026-10-15T18:50:14Z",
    "longer component": "Entry titled v2.2.0.1, updated 2026-10-15T18:50:14Z",
}

print("%-30s %-22s %-22s %s" % ("cell", "version_is_named", "derived_anchor_bound", "note"))
for label, cell in CELLS.items():
    old = rc.version_is_named(cell, "2.2.0")
    new = rc.derived_anchor_bound(cell, "2.2.0")
    print("%-30s %-22r %-22r %s" % (label, old, new, "rc-cell" if "-rc1" in cell else ""))
print()
print("derived_anchor_bound(cell='Entry titled v2.2.0-rc1', anchored='2.2.0-rc1') = %r" %
      rc.derived_anchor_bound("Entry titled v2.2.0-rc1", "2.2.0-rc1"))
print("STABLE_TOKEN_RE.findall('v2.2.0-rc1') = %r" % (rc.STABLE_TOKEN_RE.findall("v2.2.0-rc1"),))
print("STABLE_TOKEN_RE.findall('v2.2.0') = %r" % (rc.STABLE_TOKEN_RE.findall("v2.2.0"),))
