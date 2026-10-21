#!/usr/bin/env python3
"""C1 false-positive probe: classify every upstream version token on the five feeds
against the round-28 canonicality axes (leading zero, >3 components, non-ASCII
digits, >9-digit components). Token extraction mirrors BASE VERSION_RE."""
import json
import re
import sys
import unicodedata
from pathlib import Path

RAW = Path(__file__).resolve().parent / "raw"

# BASE corpus/release-clock.py:30-33 (anchor/observation token grammar)
VERSION_RE = re.compile(
    r"(?<![A-Za-z0-9.])v?([0-9]+\.[0-9]+(?:\.[0-9]+)*(?:[-+][0-9A-Za-z.-]+)?)(?![A-Za-z0-9.])",
    re.IGNORECASE,
)
# BASE corpus/release-clock.py:710-712 (feed stable-acceptance grammars)
STABLE_TITLE_RE = re.compile(r"^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)$")
STABLE_TAG_HREF_RE = re.compile(r"/releases/tag/v?([0-9]+\.[0-9]+\.[0-9]+)$")
TEXT_VERSION_RE = re.compile(r"^Version:[ \t]*v?([0-9]+\.[0-9]+\.[0-9]+)[ \t]*$", re.MULTILINE)
NONASCII_DIGIT = re.compile(r"[^0-9\s]", re.ASCII)  # placeholder, real scan below


def norm_version(value):  # BASE :362-363
    return value[1:] if value[:1].lower() == "v" else value


def core_of(token):
    """Drop SemVer-style [-+]suffix; keep the numeric core the clock int()s."""
    return re.split(r"[-+]", token, maxsplit=1)[0]


def classify(core):
    """Return the set of canonicality violations of a numeric core."""
    bad = set()
    parts = core.split(".")
    if len(parts) > 3:
        bad.add("WIDE(>3comp)")
    for p in parts:
        if not p.isascii() or not p.isdigit():
            bad.add("NONNUM(%s)" % p)
            continue
        if len(p) > 1 and p[0] == "0":
            bad.add("LEADZERO(%s)" % p)
        if len(p) > 9:
            bad.add("LONG(>9dig:%d)" % len(p))
        if len(p) > 4300:
            bad.add("INTLIMIT(>4300dig)")
    return bad


def nonascii_digits(s):
    return [c for c in s if unicodedata.category(c) == "Nd" and c not in "0123456789"]


def slurp_pages(path):
    pages = json.loads(path.read_text())
    return [r for page in pages for r in (page if isinstance(page, list) else [page])]


instances = []  # every (feed, stream, name, token, badset) with any violation
accepted_stable = []  # tokens the CURRENT feed grammar accepts as stable
stats = {}

def look(feed, stream, name, extra=""):
    tokens = [m.group(1) for m in VERSION_RE.finditer(name)]
    stats.setdefault((feed, stream), [0, 0])
    stats[(feed, stream)][0] += 1
    if tokens:
        stats[(feed, stream)][1] += 1
    for tok in tokens:
        bad = classify(core_of(tok))
        nad = nonascii_digits(tok)
        if nad:
            bad = bad | {"NONASCIIDIGIT(%s)" % "".join(nad)}
        if bad:
            instances.append((feed, stream, name, extra, tok, sorted(bad)))

def look_feed_stable(feed, title, href):
    """Would the CURRENT clock accept it as stable, and would the NEW rule refuse it?"""
    m = STABLE_TITLE_RE.match(title.strip()) if title else None
    tok = m.group(1) if m else None
    if tok is None and href:
        m2 = STABLE_TAG_HREF_RE.search(href.strip())
        tok = m2.group(1) if m2 else None
    if tok is not None:
        accepted_stable.append((feed, title, tok, sorted(classify(tok))))

for repo in ("sops", "vault", "openbao"):
    tags = slurp_pages(RAW / f"{repo}-tags.json")
    rels = slurp_pages(RAW / f"{repo}-releases.json")
    (Path(__file__).resolve().parent / f"{repo}-tags.txt").write_text(
        "".join(f"{t.get('name','')}\n" for t in tags))
    (Path(__file__).resolve().parent / f"{repo}-releases.txt").write_text(
        "".join(f"{r.get('tag_name','')}\t{'draft' if r.get('draft') else 'release'}\t"
                f"{'prerelease' if r.get('prerelease') else 'stable'}\t{r.get('published_at','')}\n"
                for r in rels))
    for t in tags:
        look(f"github.com/{repo}", "tags", t.get("name", "") )
    for r in rels:
        look(f"github.com/{repo}", "release.tag_name", r.get("tag_name", ""))
        look(f"github.com/{repo}", "release.title", r.get("name") or "", extra=r.get("tag_name", ""))
        look_feed_stable(f"github.com/{repo}", "", r.get("tag_name", ""))

# python.org RSS
rss = (RAW / "python-feed.rss").read_text()
for m in re.finditer(r"<title>([^<]*)</title>", rss):
    title = m.group(1)
    look("python.org/downloads/feed.rss", "item.title", title)
    look_feed_stable("python.org/downloads/feed.rss", title, "")

# curl.se/info text
info = (RAW / "curl-info.txt").read_text()
for m in TEXT_VERSION_RE.finditer(info):
    tok = m.group(1)
    look("curl.se/info", "Version: line", m.group(0).strip())
    accepted_stable.append(("curl.se/info", m.group(0).strip(), tok, sorted(classify(tok))))
gt = re.search(r"^git tag:\s*(\S+)", info, re.M)
if gt:
    look("curl.se/info", "git tag: line", gt.group(1))

out = Path(__file__).resolve().parent / "census.json"
out.write_text(json.dumps({
    "stats": {"%s | %s" % k: {"names": v[0], "with_tokens": v[1]} for k, v in sorted(stats.items())},
    "violating_instances": [
        {"feed": f, "stream": s, "name": n, "extra": e, "token": t, "violations": v}
        for f, s, n, e, t, v in instances],
    "accepted_stable": [{"feed": f, "title": ti, "token": t, "violations": v}
                        for f, ti, t, v in accepted_stable],
    "totals": {"names_scanned": sum(v[0] for v in stats.values()),
               "violating_instances": len(instances),
               "accepted_stable_entries": len(accepted_stable),
               "accepted_stable_violating": sum(1 for a in accepted_stable if a[3])},
}, indent=1))
print("names_scanned=%d violating_instances=%d accepted_stable=%d accepted_violating=%d"
      % (sum(v[0] for v in stats.values()), len(instances),
         len(accepted_stable), sum(1 for a in accepted_stable if a[3])))
byclass = {}
for _, _, _, _, _, bad in instances:
    for b in bad:
        key = re.sub(r"\(.*", "", b)
        byclass[key] = byclass.get(key, 0) + 1
print("violation_classes:", json.dumps(byclass, sort_keys=True))
