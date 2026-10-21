#!/usr/bin/env python3
"""Probe BASE (3553d49) release-clock behaviour for the six proposed selftest cases.

Read-only against the BASE tree copy; writes only temp dirs.
"""
import importlib.util
import sys
import tempfile
import traceback
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base" / "corpus" / "release-clock.py"
spec = importlib.util.spec_from_file_location("rc_base", BASE)
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

HEADER = rc.HEADER
fixture_source = rc.fixture_source
fixture_row = rc.fixture_row

default_capture = "\t".join(
    ["S001", "mined", "0" * 64, "https://example.test/doc", "https://example.test/doc",
     "200", "curl-fsSL-compressed-v1", "2026-10-21", "decoded-http-body-v1", "0" * 64,
     "1", "-", "the exact example.", "rendered-text-v1", "0" * 64, "1"]) + "\n"


def synthetic_receipt_bundle(sources, rows):
    records = {}
    by_id = {}
    for row in rows:
        if row["id"] in sources and sources[row["id"]]["recheck"] == "on-release":
            by_id.setdefault(row["id"], []).append(row)
    for source_id, matches in by_id.items():
        if len(matches) != 1 or matches[0]["malformed"]:
            continue
        values = dict(zip(HEADER, matches[0]["fields"]))
        clock = values["clock"]
        source = sources[source_id]
        records[source_id] = {
            "id": source_id,
            "clock": clock,
            "url": values["feed_url"] if clock == "feed" else source["url"],
            "http_status": 200,
            "sha256": "0" * 64,
            "parsed_version": values["observed_version"] if clock == "feed" else None,
            "located": (values["verdict"] == "quote-located")
                       if clock == "rendered-quote" else None,
            "verdict": values["verdict"],
            "observed_at": values["observed_at"] + "T00:00:00Z",
        }
    return {"records": records, "invalid_ids": set(), "invalid": False}


def run_case(name, rows_text, extra_sources=()):
    with tempfile.TemporaryDirectory(prefix="probe-") as temp:
        root = Path(temp)
        corpus = root / "corpus"
        corpus.mkdir()
        source_lines = [
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
            "|---|---|---|---|---|---|---|---|---|---|---|",
            fixture_source("S001", "Document", "docs", "Version 1.2.3",
                           "Quote: “the exact example.”", "on-release",
                           "https://example.test/doc"),
            fixture_source("S002", "Release feed", "code", "Latest release",
                           "Release Atom feed.", "90d",
                           "https://example.test/releases.atom"),
            fixture_source("S003", "Stable doc", "spec", "Page title",
                           "Stable.", "manual", "https://example.test/stable"),
        ] + list(extra_sources)
        (corpus / "SOURCES.md").write_text("\n".join(source_lines) + "\n", encoding="utf-8")
        (corpus / "release-clocks.tsv").write_text(
            "\t".join(HEADER) + "\n" + rows_text, encoding="utf-8")
        (corpus / "source-fetches.tsv").write_text(
            "# capture fixture\n" + default_capture, encoding="utf-8")
        sources = rc.parse_sources(root)
        rows = rc.parse_bindings(root)
        captures = rc.parse_captures(root)
        receipts = synthetic_receipt_bundle(sources, rows)
        result = rc.evaluate(sources, rows, captures, receipts)
        return result


def show(label, rows_text, extra_sources=()):
    print("== %s" % label)
    try:
        result = run_case(label, rows_text, extra_sources)
    except Exception as exc:  # noqa: BLE001 - probing BASE behaviour
        print("   EXCEPTION %s: %s" % (type(exc).__name__, exc))
        traceback.print_exc(limit=3)
        print()
        return
    print("   errors=%r" % (result["errors"],))
    print("   on_release=%d bound=%d unbound=%d observed=%d fired=%d derived=%d passed=%r" % (
        result["on_release"], result["bound"], result["unbound"], result["observed"],
        result["fired"], result["derived"], result["passed"]))
    print()


DERIVED_NOTE = "derived: newest stable release on the feed when the row was opened"
BIG = "1" * 4301

# C1-1: leading-zero observed token on a derived row
show("C1-1 leading-zero observed (derived row)",
     fixture_row(anchored="1.2.3", observed="1.2.03", verdict="fired",
                 note=DERIVED_NOTE) + "\n")

# C1-2: leading-zero anchored token on a derived row
show("C1-2 leading-zero anchored (derived row)",
     fixture_row(anchored="1.2.03", observed="1.2.03", verdict="not-fired",
                 note=DERIVED_NOTE) + "\n")

# C1-3: oversize component in the observed token
show("C1-3 oversize observed component",
     fixture_row(anchored="1.2.3", observed="1.2." + BIG, verdict="fired",
                 note=DERIVED_NOTE) + "\n")

# C1-3b: oversize component in the anchored token (different crash site)
show("C1-3b oversize anchored component",
     fixture_row(anchored="1.2." + BIG, observed="1.2.3", verdict="not-fired",
                 note=DERIVED_NOTE) + "\n")

# C2-1: derived anchor lowered below the feed registry anchor
feed_v123 = fixture_source("S004", "Release feed", "code",
                           "Entry titled v1.2.3, tag link /releases/tag/v1.2.3",
                           "Release Atom feed.", "90d",
                           "https://example.test/other.atom")
show("C2-1 derived anchor lowered vs feed registry anchor",
     fixture_row(feed_source_id="S004", feed_url="https://example.test/other.atom",
                 anchored="1.1.0", observed="1.1.0", verdict="not-fired",
                 note=DERIVED_NOTE) + "\n",
     extra_sources=[feed_v123])

# C2-2: derived anchor raised above the feed registry anchor
show("C2-2 derived anchor raised vs feed registry anchor",
     fixture_row(feed_source_id="S004", feed_url="https://example.test/other.atom",
                 anchored="1.2.4", observed="1.2.5", verdict="fired",
                 note=DERIVED_NOTE) + "\n",
     extra_sources=[feed_v123])

# C2-3: derived anchor equal to the feed anchor only after canonicalisation
show("C2-3 derived anchor leading-zero vs feed registry anchor",
     fixture_row(feed_source_id="S004", feed_url="https://example.test/other.atom",
                 anchored="1.2.03", observed="1.2.03", verdict="not-fired",
                 note=DERIVED_NOTE) + "\n",
     extra_sources=[feed_v123])

# Controls that must stay CLEAN before and after the fix
show("CTRL-1 derived row whose feed anchor names no version (default S002)",
     fixture_row(anchored="1.2.0", observed="1.2.0", note=DERIVED_NOTE) + "\n")

show("CTRL-2 derived row matching the feed registry anchor",
     fixture_row(feed_source_id="S004", feed_url="https://example.test/other.atom",
                 anchored="1.2.3", observed="1.2.3", verdict="not-fired",
                 note=DERIVED_NOTE) + "\n",
     extra_sources=[feed_v123])

show("CTRL-3 v-prefixed derived anchor matching the feed registry anchor",
     fixture_row(feed_source_id="S004", feed_url="https://example.test/other.atom",
                 anchored="v1.2.3", observed="1.2.3", verdict="not-fired",
                 note=DERIVED_NOTE) + "\n",
     extra_sources=[feed_v123])

print("int-str limit:", sys.get_int_max_str_digits())
