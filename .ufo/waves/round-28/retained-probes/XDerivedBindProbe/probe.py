#!/usr/bin/env python3
"""XDerivedBindProbe — empirical BASE probe for round-28 C2.

Loads BASE corpus the way release-clock.py does (importing its functions) and
reports, for each `derived:` row: id, feed_source_id, anchored_version, the
feed row's anchor text, version_is_named(feed_anchor, anchored), and exact
token membership. Then the naive-rule counterexamples among non-derived feed
rows. Read-only over the tree given as argv[1].
"""
import importlib.util
import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]).resolve()
spec = importlib.util.spec_from_file_location(
    "release_clock_base", ROOT / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

sources = rc.parse_sources(ROOT)
rows = rc.parse_bindings(ROOT)

feed_rows = []
for row in rows:
    if row["malformed"]:
        continue
    values = dict(zip(rc.HEADER, row["fields"]))
    if values["clock"] != "feed":
        continue
    is_derived = values["note"].startswith("derived:")
    feed_src = sources.get(values["feed_source_id"])
    feed_anchor = feed_src["anchor"] if feed_src else None
    anchored = values["anchored_version"]

    named = rc.version_is_named(feed_anchor, anchored) if feed_anchor else False
    # exact-token: canonical (v-stripped) anchored value present verbatim as a
    # token in the anchor, versus the same for the anchored value verbatim.
    anchor_tokens = set()
    for m in rc.VERSION_RE.finditer(feed_anchor or ""):
        anchor_tokens.add(m.group(0))
        anchor_tokens.add(rc.norm_version(m.group(0)))
    exact_norm = rc.norm_version(anchored) in anchor_tokens
    exact_verbatim = anchored in anchor_tokens
    # Would the row also satisfy BASE's own-anchor rule (what evaluate()
    # applies to NON-derived rows at BASE)?
    own_named = rc.version_is_named(sources[row["id"]]["anchor"], anchored)
    # Naive all-rows variants:
    floor = rc.feed_floors(rows).get(values["feed_url"], "")
    r1 = named
    r2 = (rc.norm_version(anchored) == rc.norm_version(floor))
    feed_rows.append({
        "id": row["id"], "tsv_line": row["line"], "derived": is_derived,
        "feed_source_id": values["feed_source_id"], "anchored": anchored,
        "observed": values["observed_version"], "verdict": values["verdict"],
        "feed_anchor": feed_anchor, "named": named,
        "exact_norm": exact_norm, "exact_verbatim": exact_verbatim,
        "own_named": own_named, "floor": floor, "naive_R1": r1, "naive_R2": r2,
        "own_tsv_line_sources": sources[row["id"]]["line"],
        "feed_src_line": feed_src["line"] if feed_src else None,
        "feed_src_status": (sources[values["feed_source_id"]]["recheck"]
                            if feed_src else None),
    })

derived = [r for r in feed_rows if r["derived"]]
nonderived = [r for r in feed_rows if not r["derived"]]

print("=== derived rows: %d ===" % len(derived))
for r in derived:
    print("%s line=%d feed=%s(feed-line=%s) anchored=%r named=%s exact_norm=%s exact_verbatim=%s own_named=%s verdict=%s"
          % (r["id"], r["tsv_line"], r["feed_source_id"], r["feed_src_line"],
             r["anchored"], r["named"], r["exact_norm"],
             r["exact_verbatim"], r["own_named"], r["verdict"]))

print()
print("=== non-derived feed rows: %d ===" % len(nonderived))
for r in nonderived:
    print("%s line=%d feed=%s(feed-line=%s) anchored=%r named=%s exact_norm=%s own_named=%s floor=%r naive_R1(feed-anchor)=%s naive_R2(floor-eq)=%s verdict=%s"
          % (r["id"], r["tsv_line"], r["feed_source_id"], r["feed_src_line"],
             r["anchored"], r["named"], r["exact_norm"], r["own_named"],
             r["floor"], r["naive_R1"], r["naive_R2"], r["verdict"]))

print()
print("=== feed-row anchor version inventories (VERSION_RE on feed anchor) ===")
for fid in sorted({r["feed_source_id"] for r in feed_rows}):
    toks = [m.group(0) for m in rc.VERSION_RE.finditer(sources[fid]["anchor"])]
    print("%s line=%d recheck=%s tokens=%r"
          % (fid, sources[fid]["line"], sources[fid]["recheck"], toks))

print()
print("=== groupings (feed_source_id -> derived ids) ===")
groups = {}
for r in derived:
    groups.setdefault(r["feed_source_id"], []).append(r["id"])
for fid in sorted(groups):
    print("%s -> %s" % (fid, ",".join(groups[fid])))

print()
print("=== counterexamples: non-derived rows breaking naive rules ===")
print("R1 (every feed row must match feed_source_id row anchor):",
      [r["id"] for r in nonderived if not r["naive_R1"]] or "none")
print("R2 (every feed row's anchor must equal feed-URL floor):",
      [r["id"] for r in nonderived if not r["naive_R2"]] or "none")
print("R1 over ALL feed rows (incl. derived):",
      [r["id"] for r in feed_rows if not r["naive_R1"]] or "none")
print("R2 over ALL feed rows (incl. derived):",
      [r["id"] for r in feed_rows if not r["naive_R2"]] or "none")
