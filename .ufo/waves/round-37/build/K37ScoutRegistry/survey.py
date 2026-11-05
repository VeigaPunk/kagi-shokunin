#!/usr/bin/env python3
"""K37ScoutRegistry: survey release-feed registry rows in corpus/SOURCES.md.

Read-only. Operates on an extraction of the lane at candidate 9efcea7.
Column indices verified against the frozen counter plans/round-37-c2.sh:
  line.split('|') -> ['', id, source, kind, tier, scope, anchor, teaches, ...]
  cells[2] = source, cells[6] = anchor  (counter: rows.append((cells[2], cells[6])))
"""
import json
import re
import sys

ROOT = sys.argv[1]
RECEIPT = sys.argv[2]

FEED_PAT = re.compile(r"releases\.atom|/releases|feed\.rss|releases/")
ROW_PAT = re.compile(r"^\|\s*S[0-9]{3,}\s*\|")
URL_PAT = re.compile(r"https?://[^\s|]+")

CLAIM_POPULATION = {
    "https://github.com/hashicorp/vault/releases.atom",
    "https://github.com/openbao/openbao/releases.atom",
    "https://www.python.org/downloads/feed.rss",
}

doc = json.load(open(RECEIPT, encoding="utf-8"))
recs = [r for r in (doc.get("observations") or []) if isinstance(r, dict)]

# receipt version per url (set of distinct parsed_version)
recver = {}
for r in recs:
    v = r.get("parsed_version")
    if r.get("url") and v:
        recver.setdefault(r["url"], set()).add(v)

rows = []
for lineno, line in enumerate(open(f"{ROOT}/corpus/SOURCES.md", encoding="utf-8"), 1):
    if not ROW_PAT.match(line):
        continue
    cells = [c.strip() for c in line.split("|")]
    if len(cells) < 13:
        continue
    rows.append({"lineno": lineno, "id": cells[1], "source": cells[2],
                 "kind": cells[3], "tier": cells[4], "scope": cells[5],
                 "anchor": cells[6], "teaches": cells[7], "used_by": cells[11]})

feed_rows = []
for r in rows:
    urls = URL_PAT.findall(r["source"])
    r["urls"] = urls
    if any(FEED_PAT.search(u) for u in urls):
        feed_rows.append(r)

def current(r, url):
    """True if the row's anchor names a receipt version for that url."""
    vers = recver.get(url, set())
    for v in vers:
        pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?" + re.escape(v) + r"(?![0-9])")
        if pat.search(r["anchor"]):
            return v
    return None

def superseded(r, url):
    """A version-named anchor that is NOT any receipt version for this url."""
    found = re.findall(r"(?:v|Python\s)(\d+\.\d+\.\d+)", r["anchor"])
    vers = recver.get(url, set())
    stale = [f for f in found if f not in vers]
    return stale, found

print("=== ALL REGISTRY ROWS WITH A FEED-STYLE URL IN THE SOURCE CELL ===")
print(f"(source-cell pattern: {FEED_PAT.pattern})")
print()
for r in feed_rows:
    print(f"{r['id']}  line {r['lineno']}  tier {r['tier']}")
    print(f"   source : {r['source']}")
    print(f"   urls   : {r['urls']}")
    print(f"   anchor : {r['anchor']}")
    for u in r["urls"]:
        if not FEED_PAT.search(u):
            continue
        cur = current(r, u)
        st, found = superseded(r, u)
        pop = "IN-CLAIM" if u in CLAIM_POPULATION else "OUT-OF-CLAIM"
        print(f"   -> url {u}  [{pop}]")
        print(f"      receipt versions for url : {sorted(recver.get(u, set())) or 'NONE (no receipt record)'}")
        print(f"      anchor names receipt ver : {cur or 'NO'}")
        print(f"      anchor versions seen     : {found or 'none'}")
        print(f"      anchor superseded versions: {st or 'none'}")
    print()

n_feed = len(feed_rows)
n_current = 0
n_superseded = 0
for r in feed_rows:
    for u in r["urls"]:
        if not FEED_PAT.search(u):
            continue
        if current(r, u):
            n_current += 1
        st, _ = superseded(r, u)
        if st:
            n_superseded += 1

print("=== COUNTS ===")
print(f"rows with feed-style URL in source cell : {n_feed}")
print(f"row-url pairs whose anchor names the receipt version : {n_current}")
print(f"row-url pairs whose anchor names a superseded version : {n_superseded}")
print()
print("=== OUT-OF-CLAIM FEED ROWS ===")
for r in feed_rows:
    for u in r["urls"]:
        if FEED_PAT.search(u) and u not in CLAIM_POPULATION:
            print(f"{r['id']}  url {u}")
            print(f"   anchor : {r['anchor']}")
            print(f"   teaches: {r['teaches']}")
            print(f"   receipt versions for url: {sorted(recver.get(u, set())) or 'NONE'}")
            print(f"   anchor names receipt ver: {current(r, u) or 'NO'}")
            print()
