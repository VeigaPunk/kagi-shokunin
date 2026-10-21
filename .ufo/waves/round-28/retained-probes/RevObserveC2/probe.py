#!/usr/bin/env python3
"""Probe C2's derived-anchor binding semantics at BASE (read-only on BASE tree).

Answers: what version does a feed registry row's LOCATED ANCHOR name, and which
comparison variant keeps a legitimately FIRED derived row valid?
"""
import importlib.util
import re
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base"
spec = importlib.util.spec_from_file_location("rc", BASE / "corpus/release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

root = BASE
sources = rc.parse_sources(root)
rows = rc.parse_bindings(root)

STRICT = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
LEADING_ZERO = re.compile(r"(^|\.)0[0-9]")

print("== feed registry rows: located anchor cell and its version tokens ==")
for sid in sorted(sources):
    src = sources[sid]
    if src["kind"].lower() not in rc.FEED_KINDS:
        continue
    anchor_cell = src["anchor"]
    toks = STRICT.findall(anchor_cell)
    distinct = sorted(set(toks))
    lz = [t for t in distinct if LEADING_ZERO.search(t)]
    print("%s kind=%s recheck=%s versions=%s distinct=%s leading_zero=%s" % (
        sid, src["kind"], src["recheck"], toks, distinct, lz))
    print("    anchor cell: %s" % anchor_cell[:150])

print()
print("== every clock row: derived? binding under 4 comparison variants ==")
header = rc.HEADER
print("%-6s %-7s %-6s %-10s %-10s %-9s | %-7s %-7s %-7s %-7s" % (
    "id", "derived", "feed", "anchored", "observed", "verdict",
    "raw", "norm", "numeric", "obs-vs"))
for row in rows:
    if row["malformed"]:
        continue
    v = dict(zip(header, row["fields"]))
    if v["clock"] != "feed":
        continue
    derived = v["note"].startswith("derived:")
    feed = sources.get(v["feed_source_id"])
    if feed is None:
        continue
    toks = sorted(set(STRICT.findall(feed["anchor"])))
    a = rc.norm_version(v["anchored_version"])
    raw = "n/a"
    norm = "n/a"
    num = "n/a"
    obs = "n/a"
    if len(toks) == 1:
        fv = toks[0]
        raw = "OK" if fv == v["anchored_version"] else "MISMATCH"
        norm = "OK" if rc.norm_version(fv) == a else "MISMATCH"
        fn = rc.numeric_version(fv)
        an = rc.numeric_version(a)
        num = "OK" if (fn is not None and an is not None and fn == an) else "MISMATCH"
        obs = "OK" if rc.norm_version(v["observed_version"]) == rc.norm_version(fv) else "MISMATCH"
    else:
        raw = norm = num = obs = "AMBIG(%d)" % len(toks)
    print("%-6s %-7s %-6s %-10s %-10s %-9s | %-7s %-7s %-7s %-7s" % (
        row["id"], "yes" if derived else "no", v["feed_source_id"],
        v["anchored_version"], v["observed_version"], v["verdict"],
        raw, norm, num, obs))

print()
print("== non-derived feed rows under the same binding (scope test) ==")
for row in rows:
    if row["malformed"]:
        continue
    v = dict(zip(header, row["fields"]))
    if v["clock"] != "feed" or v["note"].startswith("derived:"):
        continue
    feed = sources.get(v["feed_source_id"])
    toks = sorted(set(STRICT.findall(feed["anchor"]))) if feed else []
    print("%-6s feed=%-6s anchored=%-10s feed_anchor_versions=%s norm_eq=%s" % (
        row["id"], v["feed_source_id"], v["anchored_version"], toks,
        (rc.norm_version(toks[0]) == rc.norm_version(v["anchored_version"]))
        if len(toks) == 1 else "?"))
