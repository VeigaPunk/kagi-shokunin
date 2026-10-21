#!/usr/bin/env python3
"""End-to-end: the REAL --observe path when a derived row's feed advances.

Uses the real corpus/release-clock.py with request_body stubbed (no network),
so the receipt verdict, the table verdict and evaluate() all run as in
production. Proves what a legitimately fired DERIVED row looks like, and
whether a C2 rule that binds the anchor (not the observation) keeps it valid.
"""
import importlib.util
import json
import re
import shutil
import sys
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work3"

SOPS_ATOM = """<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <title>v3.14.0</title>
    <link href="https://github.com/getsops/sops/releases/tag/v3.14.0"/>
    <updated>2026-10-25T00:00:00Z</updated>
  </entry>
  <entry>
    <title>v3.13.3</title>
    <link href="https://github.com/getsops/sops/releases/tag/v3.13.3"/>
    <updated>2026-07-23T05:29:11Z</updated>
  </entry>
</feed>
"""


def load(root, name="rc"):
    spec = importlib.util.spec_from_file_location(name, root / "corpus/release-clock.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def build(name, patch=None):
    root = WORK / name
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE, root)
    if patch:
        path = root / "corpus/release-clock.py"
        code = path.read_text(encoding="utf-8")
        anchor_line = '            is_derived = values["note"].startswith("derived:")\n'
        assert anchor_line in code
        code = code.replace(anchor_line, patch, 1)
        path.write_text(code, encoding="utf-8")
    return root


HELPER = '''
def _ver_tokens(text):
    out = set()
    for m in re.finditer(r"(?<![0-9A-Za-z.])v?([0-9]+\\.[0-9]+\\.[0-9]+)(?![0-9A-Za-z.])",
                         text or ""):
        t = m.group(1)
        if not re.search(r"(^|\\.)0[0-9]", t):
            out.add(t)
    return out
'''

PATCH_ANCHOR = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

PATCH_OBS = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["observed_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''


def observe_with_advanced_feed(root, label):
    """Run the real run_observe with the SOPS feed stubbed at v3.14.0."""
    rc = load(root, "rc_" + label)
    sources = rc.parse_sources(root)
    rows = rc.parse_bindings(root)
    captures = rc.parse_captures(root)
    real_request = rc.request_body
    real_utc = rc.utc_timestamp

    def stub(url, opener=None, resolver=None):
        if "getsops" in url:
            return 200, SOPS_ATOM.encode("utf-8"), None
        return real_request(url, opener=opener, resolver=resolver)

    rc.request_body = stub
    rc.utc_timestamp = lambda: "2026-10-21T13:43:21Z"
    out = root / ("observe-%s.json" % label)
    if out.exists():
        out.unlink()
    try:
        failures = rc.run_observe(root, sources, rows, out, captures)
    finally:
        rc.request_body = real_request
        rc.utc_timestamp = real_utc
    bundle = rc.load_receipt_bundle(out)
    print("  %-8s observe failures=%d" % (label, failures))
    for rid in ("S008", "S009", "S010", "S011", "S012"):
        rec = bundle["records"].get(rid, {})
        print("     %s receipt parsed=%s verdict=%s" % (rid, rec.get("parsed_version"),
                                                        rec.get("verdict")))
    # what the table must now say for the receipt to match (re-verification)
    return bundle


def table_edit(root, edits):
    path = root / "corpus/release-clocks.tsv"
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields[0] in edits:
            anchored, observed, verdict, observed_at = edits[fields[0]]
            fields[4], fields[5], fields[7], fields[6] = anchored, observed, verdict, observed_at
            line = "\t".join(fields) + "\n"
        out.append(line)
    path.write_text("".join(out), encoding="utf-8")


def evaluate(root, label, receipt_name):
    rc = load(root, "ev_" + label)
    sources = rc.parse_sources(root)
    rows = rc.parse_bindings(root)
    captures = rc.parse_captures(root)
    bundle = rc.load_receipt_bundle(root / receipt_name)
    result = rc.evaluate(sources, rows, captures, bundle)
    rc.print_result(result)
    return result


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    for label, patch in (("ANCHOR", PATCH_ANCHOR), ("OBS", PATCH_OBS)):
        root = build("v" + label)
        path = root / "corpus/release-clock.py"
        code = path.read_text(encoding="utf-8")
        code = code.replace("def evaluate(sources, rows, captures=None, receipt_bundle=None):\n",
                            HELPER.lstrip("\n") + "\n\ndef evaluate(sources, rows, captures=None, receipt_bundle=None):\n", 1)
        code = code.replace('            is_derived = values["note"].startswith("derived:")\n', patch, 1)
        path.write_text(code, encoding="utf-8")
        print("== %s: feed advanced to v3.14.0, derived rows fire ==" % label)
        bundle = observe_with_advanced_feed(root, label)
        # re-verification: the table records the new observation, verdict fired,
        # anchored version UNCHANGED (3.13.3), observed_at the new date
        table_edit(root, {
            "S008": ("3.13.3", "3.14.0", "fired", "2026-10-21"),
            "S009": ("3.13.3", "3.14.0", "fired", "2026-10-21"),
            "S010": ("3.13.3", "3.14.0", "fired", "2026-10-21"),
            "S011": ("3.13.3", "3.14.0", "fired", "2026-10-21"),
        })
        result = evaluate(root, label, "observe-%s.json" % label)
        print("     passed=%s errors=%s" % (result["passed"], result["errors"]))
        print()


if __name__ == "__main__":
    main()
