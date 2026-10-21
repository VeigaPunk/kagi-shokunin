#!/usr/bin/env python3
"""Feed version tokens to every parse site of BASE corpus/release-clock.py.

Runs the BASE module from ../base/corpus/release-clock.py read-only; prints a
markdown table (tokens x sites) and a few targeted scenario probes.
"""
import importlib.util
import json
import re
import sys
import xml.sax.saxutils as sax

BASE = __file__.rsplit("/", 1)[0] + "/base/corpus/release-clock.py"
spec = importlib.util.spec_from_file_location("release_clock", BASE)
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

TOKENS = [
    ("3.15.01", "zero-padded component"),
    ("03.15.1", "leading-zero major"),
    ("3.15.0", "canonical lower"),
    ("3.15.00", "zero-padded minor"),
    ("0.0.0", "all-zero"),
    ("3.15.1" + "1" * 4300, "4301-digit component (over CPython int-str limit)"),
    ("3.15.1" + "1" * 4301, "4302-digit component"),
    ("3.15.１", "fullwidth final digit U+FF11"),
    ("3.15.1_0", "underscore-suffixed"),
    (" 3.15.1", "leading space"),
    ("3.15.1\n", "trailing newline"),
    ("v3.15.1", "lowercase v prefix"),
    ("V3.15.1", "uppercase V prefix"),
]

FEED_URL = "https://feed.example/atom.xml"


def brief(value, limit=26):
    s = repr(value)
    if len(s) > limit:
        s = s[:limit - 3] + "..."
    return s


def cell(fn, tok):
    try:
        out = fn(tok)
    except Exception as exc:  # noqa: BLE001 - probe records the exception
        return "EXC %s: %s" % (exc.__class__.__name__, exc)
    if out is None:
        return "reject"
    return "accept " + brief(out)


def version_re(tok):
    m = rc.VERSION_RE.search(tok)
    return m.group(1) if m else None


def title_re(tok):
    m = rc.STABLE_TITLE_RE.match(tok)
    return m.group(1) if m else None


def href_re_raw(tok):
    m = rc.STABLE_TAG_HREF_RE.search(tok)
    return m.group(1) if m else None


def href_re_insitu(tok):
    m = rc.STABLE_TAG_HREF_RE.search(("/releases/tag/" + tok).strip())
    return m.group(1) if m else None


def text_re_raw(tok):
    m = rc.TEXT_VERSION_RE.search(tok)
    return m.group(1) if m else None


def text_re_insitu(tok):
    m = rc.TEXT_VERSION_RE.search("Version: " + tok + "\n")
    return m.group(1) if m else None


def numeric(tok):
    v = rc.numeric_version(tok)
    return None if v is None else tuple(v)


def numeric_raw_re(tok):
    m = rc.NUMERIC_VERSION_RE.fullmatch(tok)
    return m.group(0) if m else None


def regression(tok):
    return rc.is_regression("3.15.1", tok)


def feed_floors_one(tok):
    fields = ("S901", "feed", "S902", FEED_URL, tok, "-", "2026-01-01", "not-fired", "-")
    floors = rc.feed_floors([{"malformed": False, "fields": list(fields)}])
    return floors.get(FEED_URL, "<no-floor>") if FEED_URL in floors else "<no-floor>"


def vin_anchor_fixed(tok):
    return rc.version_is_named("3.15.1", tok)


def vin_version_fixed(tok):
    return rc.version_is_named(tok, "3.15.1")


def atom_body(titles):
    entries = "".join(
        "<entry><title>%s</title><updated>2026-01-01T00:00:00Z</updated></entry>" % sax.escape(t)
        for t in titles
    )
    return ("<feed xmlns=\"http://www.w3.org/2005/Atom\">%s</feed>" % entries).encode("utf-8")


def latest_single(tok):
    return rc.parse_latest_version(atom_body([tok]))


def latest_text(tok):
    return rc.parse_latest_version(("Version: " + tok + "\n").encode("utf-8"))


def latest_max(tok):
    return rc.parse_latest_version(atom_body([tok, "3.15.1"]))


SITES = [
    ("VERSION_RE.search:1", version_re),
    ("NUMERIC_VERSION_RE.fullmatch:366", numeric_raw_re),
    ("numeric_version:369", numeric),
    ("is_regression(3.15.1,tok):383", regression),
    ("feed_floors(anchor=tok):390", feed_floors_one),
    ("version_is_named(a=3.15.1,v=tok):341", vin_anchor_fixed),
    ("version_is_named(a=tok,v=3.15.1):341", vin_version_fixed),
    ("STABLE_TITLE_RE.match:710", title_re),
    ("STABLE_TAG_HREF_RE.search raw:711", href_re_raw),
    ("STABLE_TAG_HREF_RE /releases/tag/:711", href_re_insitu),
    ("TEXT_VERSION_RE.search raw:712", text_re_raw),
    ("TEXT_VERSION_RE Version:-line:712", text_re_insitu),
    ("parse_latest_version xml title:715", latest_single),
    ("parse_latest_version text:715", latest_text),
    ("newest-stable max(tok,3.15.1):760", latest_max),
]


def main():
    limit = sys.get_int_max_str_digits()
    print("int_max_str_digits=%d" % limit)
    header = ["token (note)"] + [name for name, _ in SITES]
    print("| " + " | ".join(header) + " |")
    print("|" + "---|" * len(header))
    for tok, note in TOKENS:
        label = brief(tok, 20) + " (" + note + ")"
        row = [label] + [cell(fn, tok) for _, fn in SITES]
        print("| " + " | ".join(row) + " |")

    # targeted scenario probes
    print("\nscenarios:")
    scen = {}
    # C1 fired-lie mechanism: zero-padded observed on canonical anchor
    scen["vin(3.15.1, 3.15.01)"] = rc.version_is_named("3.15.1", "3.15.01")
    scen["numeric(3.15.01)==numeric(3.15.1)"] = (
        rc.numeric_version("3.15.01") == rc.numeric_version("3.15.1"))
    scen["norm(3.15.01)==norm(3.15.1)"] = (
        rc.norm_version("3.15.01") == rc.norm_version("3.15.1"))
    # floor merge of zero-equal anchors on one feed
    fields = ("S901", "feed", "S902", FEED_URL, "%s", "-", "2026-01-01", "not-fired", "-")
    rows = [{"malformed": False, "fields": list((fields[0:4] + (t,) + fields[5:]))}
            for t in ("3.15.1", "3.15.01")]
    scen["floor_merge(3.15.1,3.15.01)"] = rc.feed_floors(rows).get(FEED_URL)
    # junk-suffix anchor names plain version
    scen["vin(3.15.1_0, 3.15.1)"] = rc.version_is_named("3.15.1_0", "3.15.1")
    # equal max keys keep first entry verbatim
    scen["max(3.15.01 first)"] = rc.parse_latest_version(atom_body(["3.15.01", "3.15.1"]))
    scen["max(3.15.1,3.15.10)"] = rc.parse_latest_version(atom_body(["3.15.1", "3.15.10"]))
    # text file without Version line / no-stable feed errors
    try:
        rc.parse_latest_version(b"Version: 3.15.01")
    except ValueError as exc:
        scen["text_no_trailing_nl"] = "ValueError: %s" % exc
    scen["text_no_nl_recheck"] = rc.TEXT_VERSION_RE.search("Version: 3.15.01") is not None
    for key in sorted(scen):
        print("%s = %r" % (key, scen[key]))

    with open(__file__.rsplit("/", 1)[0] + "/probe-results.json", "w") as fh:
        json.dump({"int_max_str_digits": limit, "scenarios": scen}, fh, indent=1, default=str)
    return 0


if __name__ == "__main__":
    sys.exit(main())
