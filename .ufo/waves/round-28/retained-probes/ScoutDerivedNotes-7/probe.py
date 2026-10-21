#!/usr/bin/env python3
"""C2 population: mechanical binding probes using BASE release-clock.py helpers."""
import csv, importlib.util, re, sys

SB = "/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/ScoutDerivedNotes-7"
ROOT = SB + "/base"
spec = importlib.util.spec_from_file_location("rc", ROOT + "/corpus/release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

sources = rc.parse_sources(__import__("pathlib").Path(ROOT))
rows = list(csv.DictReader(open(ROOT + "/corpus/release-clocks.tsv", encoding="utf-8"), delimiter="\t"))

print("id own_anchor_names_anchored  feed_anchor_names_anchored  feed_url_matches  opened  note_date")
bad = []
for r in rows:
    note = r["note"]
    if not note.startswith("derived:"):
        continue
    fid = r["feed_source_id"]
    own = sources[r["id"]]
    feed = sources[fid]
    own_ok = rc.version_is_named(own["anchor"], r["anchored_version"])
    feed_ok = rc.version_is_named(feed["anchor"], r["anchored_version"])
    url_ok = (r["feed_url"] == feed["url"])
    ndates = re.findall(r"\d{4}-\d{2}-\d{2}", note)
    print("%s\t%s\t%s\t%s\t%s\t%s" % (r["id"], own_ok, feed_ok, url_ok,
          own["opened"], ",".join(ndates)))
    if not feed_ok or not url_ok:
        bad.append(r["id"])
print("FEED_BIND_FAIL:", bad or "none")

print("\n== negative probes: forged lower versions against feed anchors ==")
for fid, forged in (("S033", "3.13.2"), ("S034", "2.1.9"), ("S035", "2.7.0"), ("S037", "8.22.0")):
    print(fid, forged, "->", rc.version_is_named(sources[fid]["anchor"], forged))
print("equality probe S037 anchor names 8.23.1?", rc.version_is_named(sources["S037"]["anchor"], "8.23.1"))
print("S034 anchor names 2.2.0-rc1?", rc.version_is_named(sources["S034"]["anchor"], "2.2.0-rc1"))
print("S034 anchor names sdk version 0.26.0?", rc.version_is_named(sources["S034"]["anchor"], "0.26.0"))

print("\n== non-derived siblings on same feeds (must NOT be bound) ==")
for r in rows:
    if r["clock"] != "feed" or r["feed_source_id"] not in ("S033","S034","S035","S037"):
        continue
    if r["note"].startswith("derived:"):
        continue
    feed = sources[r["feed_source_id"]]
    print(r["id"], "anchored", r["anchored_version"],
          "own_names:", rc.version_is_named(sources[r["id"]]["anchor"], r["anchored_version"]),
          "feed_names:", rc.version_is_named(feed["anchor"], r["anchored_version"]))
