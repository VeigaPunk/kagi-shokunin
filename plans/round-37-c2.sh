#!/usr/bin/env bash
# plans/round-37-c2.sh — C2 counter (round 37): release-feed registry anchor
# currency against the committed round-37 observation receipt.
#
# One unsigned integer on stdout: the number of release-feed surfaces
# (hashicorp/vault releases.atom, openbao/openbao releases.atom,
# python.org downloads feed.rss) for which corpus/SOURCES.md holds NO registry
# row whose source cell carries the feed URL AND whose anchor cell names the
# receipt's parsed_version for that feed (as "v<version>", "Python <version>"
# or a boundary-delimited bare version).
#   - a superseded anchor (e.g. v2.2.0 for a vault surface observed at 2.2.1)
#     does not hold;
#   - a current version under the WRONG feed URL does not hold;
#   - a current version outside SOURCES.md (knowledge/, lessons/) does not hold.
# Fail closed (R34-2): a missing or sha-mismatched receipt exits 2 (SETUP),
# never 0; a surface absent from the receipt, or with disagreeing parsed
# versions across its records, exits 2.
# Receipt: .ufo/waves/round-37/controls/observe-r37.json (written by
# `python3 corpus/release-clock.py --observe` on this host on 2026-11-05; sha256
# pinned below; not rewritten, not superseding any historical receipt).
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 2
rec=.ufo/waves/round-37/controls/observe-r37.json
want=cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203
sha=$(sha256sum "$rec" 2>/dev/null | awk '{print $1}')
[ -n "$sha" ] && [ "$sha" = "$want" ] || {
  echo "C2 SETUP: receipt missing or sha mismatch" >&2; exit 2; }
python3 - "$rec" <<'PY'
import json, re, sys
try:
    doc = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    print("C2 SETUP: receipt unreadable", file=sys.stderr); raise SystemExit(2)
if doc.get("format") != "release-clock-observations-v1":
    print("C2 SETUP: bad receipt format", file=sys.stderr); raise SystemExit(2)
recs = [r for r in (doc.get("observations") or []) if isinstance(r, dict)]
surfaces = [
    "https://github.com/hashicorp/vault/releases.atom",
    "https://github.com/openbao/openbao/releases.atom",
    "https://www.python.org/downloads/feed.rss",
]
rows = []  # (source cell, anchor cell) of every registry row; SOURCES columns: 1=id 2=source 6=anchor
for line in open("corpus/SOURCES.md", encoding="utf-8"):
    if re.match(r"^\|\s*S[0-9]{3,}\s*\|", line):
        cells = [c.strip() for c in line.split("|")]
        if len(cells) >= 13:
            rows.append((cells[2], cells[6]))
stale = 0
for url in surfaces:
    vers = sorted({r.get("parsed_version") for r in recs
                   if r.get("url") == url and r.get("parsed_version")})
    if len(vers) != 1:
        print(f"C2 SETUP: surface {url} carries {len(vers)} receipt versions",
              file=sys.stderr)
        raise SystemExit(2)
    v = vers[0]
    pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?" + re.escape(v) + r"(?![0-9])")
    if not any((url in src) and pat.search(anc) for src, anc in rows):
        stale += 1
print(stale)
PY
