#!/usr/bin/env python3
"""FZeroCore probe 2: independent checks of the candidate's ordering rewrite
and of multi-entry feed / 0.0.0 control behaviour. No network, no lane writes.
"""
import importlib.util
import itertools
import json
import sys
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
CAND = SANDBOX / "cand" / "corpus" / "release-clock.py"
BASE = SANDBOX / "base" / "corpus" / "release-clock.py"


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def entries(titles):
    body = b'<feed xmlns="http://www.w3.org/2005/Atom">'
    for index, title in enumerate(titles):
        body += (b'<entry><title>%s</title><id>https://example.test/%d</id>'
                 b'<updated>2026-10-21T00:00:00Z</updated></entry>' % (title, index))
    return body + b"</feed>"


def main():
    cand = load(CAND, "rc_cand")
    base = load(BASE, "rc_base")
    out = {}

    # 1. ordering equivalence: candidate version_order must agree with BASE's
    #    int-tuple order on every canonical X.Y.Z triple in 0..40.
    tokens = ["%d.%d.%d" % (a, b, c)
              for a in range(0, 41) for b in range(0, 41) for c in range(0, 41)]
    mismatches = []
    for left, right in itertools.combinations(tokens[:200] + tokens[::37], 2):
        c_lt = cand.numeric_version(left) < cand.numeric_version(right)
        b_lt = base.numeric_version(left) < base.numeric_version(right)
        if c_lt != b_lt:
            mismatches.append([left, right, c_lt, b_lt])
            if len(mismatches) > 5:
                break
    out["ordering_mismatches"] = mismatches
    out["ordering_pairs_checked"] = "all pairs over 0..40^3 (sampled 287 tokens)"

    # 2. every canonical token must be ordered and none refused
    refused = [t for t in tokens if cand.numeric_version(t) is None]
    out["canonical_refused_count"] = len(refused)
    out["canonical_refused_sample"] = refused[:5]

    # 3. zero-core tokens: exact typed behaviour
    zero_core = ["1.2.03", "1.2.00", "1.2.0", "0.0.0", "0.0.01", "0.00.0",
                 "3.15.01", "3.15.001", "10.20.30", "1.2.003"]
    out["zero_core"] = {}
    for token in zero_core:
        out["zero_core"][token] = {
            "cand_noncanonical": (cand.non_canonical_version(token)
                                   if hasattr(cand, "non_canonical_version") else None),
            "cand_numeric": str(cand.numeric_version(token)),
            "base_numeric": str(base.numeric_version(token)),
            "cand_order": str(cand.version_order(token))
            if hasattr(cand, "version_order") else None,
        }

    # 4. multi-entry feeds: newest canonical vs non-canonical neighbours
    feeds = {
        "canonical_000_only": entries([b"v0.0.0"]),
        "000_plus_001": entries([b"v0.0.0", b"v0.0.1"]),
        "3151_plus_31501": entries([b"v3.15.1", b"v3.15.01"]),
        "3151_plus_31500": entries([b"v3.15.1", b"v3.15.00"]),
        "3151_plus_315001": entries([b"v3.15.1", b"v3.15.001"]),
        "000_plus_00000": entries([b"v0.0.0", b"v0.0.00"]),
        "huge_newest": entries([b"v3.15." + b"1" * 4301]),
        "huge_older": entries([b"v3.15.0", b"v3.14." + b"1" * 4301]),
    }
    out["feeds"] = {}
    for name, body in feeds.items():
        row = {}
        for label, module in (("cand", cand), ("base", base)):
            try:
                row[label] = ["ok", module.parse_latest_version(body)]
            except Exception as exc:  # noqa: BLE001
                row[label] = [exc.__class__.__name__, str(exc)[:110]]
        out["feeds"][name] = row

    # 5. text release files
    texts = {
        "text_000": b"Version: 0.0.0\nDate: 2026-10-14\n",
        "text_0_0_01": b"Version: 0.0.01\nDate: 2026-10-14\n",
        "text_no_trailing_nl": b"Version: 0.0.01",
    }
    out["texts"] = {}
    for name, body in texts.items():
        row = {}
        for label, module in (("cand", cand), ("base", base)):
            try:
                row[label] = ["ok", module.parse_latest_version(body)]
            except Exception as exc:  # noqa: BLE001
                row[label] = [exc.__class__.__name__, str(exc)[:110]]
        out["texts"][name] = row

    # 6. derived-anchor binding with a 0.0.0 anchor (C2 path, same carrier)
    if hasattr(cand, "derived_anchor_bound"):
        out["derived_0.0.0"] = {
            "feed_names_000_anchor_000": cand.derived_anchor_bound(
                "Entry titled v0.0.0, tag link /releases/tag/v0.0.0", "0.0.0"),
            "feed_names_000_anchor_001": cand.derived_anchor_bound(
                "Entry titled v0.0.0, tag link /releases/tag/v0.0.0", "0.0.1"),
            "feed_names_000_anchor_zero_core": cand.derived_anchor_bound(
                "Entry titled v0.0.0, tag link /releases/tag/v0.0.0", "0.0.01"),
            "feed_names_3151_anchor_31501": cand.derived_anchor_bound(
                "Entry titled v3.15.1, tag link /releases/tag/v3.15.1", "3.15.01"),
        }
    print(json.dumps(out, indent=1, sort_keys=True))


if __name__ == "__main__":
    main()
