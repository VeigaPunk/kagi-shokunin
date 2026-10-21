#!/usr/bin/env python3
"""FZeroCore probe 4: exhaustive ordering equivalence (candidate version_order vs
BASE int-tuple order) over 0..40^3 canonical tokens, plus 0.0.0 semantics
(fired / regressed / floor) and zero-core feed-entry positions.
"""
import importlib.util
import json
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
CAND = SANDBOX / "cand" / "corpus" / "release-clock.py"
BASE = SANDBOX / "base" / "corpus" / "release-clock.py"


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    cand = load(CAND, "rc_cand")
    base = load(BASE, "rc_base")
    out = {}

    tokens = ["%d.%d.%d" % (a, b, c)
              for a in range(0, 41) for b in range(0, 41) for c in range(0, 41)]
    cand_order = sorted(tokens, key=cand.version_order)
    base_order = sorted(tokens, key=base.numeric_version)
    out["tokens"] = len(tokens)
    out["sort_identical"] = cand_order == base_order
    if cand_order != base_order:
        diffs = [(a, b) for a, b in zip(cand_order, base_order) if a != b][:10]
        out["sort_diff_sample"] = diffs

    # 0.0.0 semantics
    out["zero_semantics"] = {
        "cand_numeric_000": str(cand.numeric_version("0.0.0")),
        "base_numeric_000": str(base.numeric_version("0.0.0")),
        "cand_order_000": str(cand.version_order("0.0.0")),
        "cand_is_regression_000_to_001": cand.is_regression("0.0.0", "0.0.1"),
        "cand_is_regression_001_to_000": cand.is_regression("0.0.1", "0.0.0"),
        "base_is_regression_000_to_001": base.is_regression("0.0.0", "0.0.1"),
        "base_is_regression_001_to_000": base.is_regression("0.0.1", "0.0.0"),
        "cand_is_regression_3.15.9_to_3.15.10": cand.is_regression("3.15.9", "3.15.10"),
        "cand_is_regression_3.15.10_to_3.15.9": cand.is_regression("3.15.10", "3.15.9"),
        "cand_is_regression_2.9_to_2.10": cand.is_regression("2.9", "2.10"),
    }

    # zero-core feed entry at every position relative to the newest canonical
    def entries(titles):
        doc = b'<feed xmlns="http://www.w3.org/2005/Atom">'
        for index, title in enumerate(titles):
            doc += (b'<entry><title>%s</title><id>https://example.test/%d</id>'
                    b'<updated>2026-10-21T00:00:00Z</updated></entry>' % (title, index))
        return doc + b"</feed>"

    feeds = {
        "newer_canonical_plus_older_zero_core": entries([b"v3.15.2", b"v3.15.01"]),
        "newer_canonical_plus_zero_core_000": entries([b"v3.15.2", b"v3.15.00"]),
        "newer_canonical_plus_000_zero_core": entries([b"v3.15.2", b"v0.0.01"]),
        "newer_canonical_plus_zero_core_tie": entries([b"v3.15.2", b"v3.15.2.0"]),
        "only_zero_core": entries([b"v3.15.01"]),
        "only_zero_core_000": entries([b"v0.0.01"]),
        "canonical_plus_zero_core_newer": entries([b"v3.15.01", b"v3.15.2"]),
    }
    out["zero_core_feed_positions"] = {}
    for name, body in feeds.items():
        row = {}
        for label, module in (("cand", cand), ("base", base)):
            try:
                row[label] = ["ok", module.parse_latest_version(body)]
            except Exception as exc:  # noqa: BLE001
                row[label] = [exc.__class__.__name__, str(exc)[:100]]
        out["zero_core_feed_positions"][name] = row
    print(json.dumps(out, indent=1, sort_keys=True))


if __name__ == "__main__":
    main()
