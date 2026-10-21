#!/usr/bin/env python3
"""Offline contrast observations, separate from the frozen round-28 fixtures."""
import json
import runpy
import sys

clock = runpy.run_path(sys.argv[1], run_name="mutbase_derived_witness")
feed_url = "https://example.test/releases.atom"


def evaluate_specs(specs):
    sources = {
        "S002": {"id": "S002", "url": feed_url, "kind": "code",
                 "anchor": "Latest release 1.2.3", "recheck": "90d"},
    }
    rows = []
    records = {}
    for index, spec in enumerate(specs):
        source_id = "S001" if index == 0 else "S004"
        sources[source_id] = {
            "id": source_id, "url": "https://example.test/" + source_id,
            "kind": "docs", "anchor": spec.get("source_anchor", "Version 1.2.3"),
            "recheck": "on-release",
        }
        anchored = spec.get("anchored", "1.2.3")
        observed = spec.get("observed", anchored)
        verdict = spec.get("verdict", "not-fired")
        row_text = clock["fixture_row"](
            source_id, anchored=anchored, observed=observed, verdict=verdict,
            note=spec.get("note", "test"),
        )
        rows.append({"id": source_id, "fields": row_text.split("\t"),
                     "line": index + 2, "malformed": False})
        records[source_id] = {
            "id": source_id, "clock": "feed", "url": feed_url,
            "http_status": 200, "sha256": "0" * 64,
            "parsed_version": observed, "located": None, "verdict": verdict,
            "observed_at": "2026-10-21T00:00:00Z",
        }
    result = clock["evaluate"](
        sources, rows, receipt_bundle={
            "records": records, "invalid_ids": set(), "invalid": False,
        },
    )
    return {key: result[key] for key in ("passed", "observed", "fired", "derived", "errors")}


specifications = {
    "canonical_derived": [{"note": "derived: newest stable release"}],
    "derived_mismatch": [{"anchored": "1.2.0", "note": "derived: forged lower anchor"}],
    "no_colon": [{"anchored": "1.2.0", "note": "derived accidentally without colon"}],
    "infix_marker": [{"anchored": "1.2.0", "note": "audit derived: newest stable release"}],
    "plain_row": [{}],
    "two_derived": [{"note": "derived: first"}, {"note": "derived: second"}],
    "left_subtoken": [{"source_anchor": "Version 11.2.3"}],
    "right_subtoken": [{"source_anchor": "Version 1.2.30"}],
}
results = {name: evaluate_specs(specs) for name, specs in specifications.items()}
results["named_boundaries"] = {
    "left": clock["version_is_named"]("Version 11.2.3", "1.2.3"),
    "right": clock["version_is_named"]("Version 1.2.30", "1.2.3"),
}
print(json.dumps(results, sort_keys=True))
