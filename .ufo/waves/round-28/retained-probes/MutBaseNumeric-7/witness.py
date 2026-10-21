#!/usr/bin/env python3
"""Offline counterexamples; exits report execution, not invariant validity."""
import importlib.util
import json
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("release_clock_probe", Path("corpus/release-clock.py"))
clock = importlib.util.module_from_spec(spec)
spec.loader.exec_module(clock)


def numeric(value):
    result = clock.numeric_version(value)
    if result is not None and any(isinstance(part, int) and part.bit_length() > 100 for part in result):
        return {"accepted": True, "component_digits": [len(str(part)) for part in result]}
    return result


def observe(body, anchor="3.15.1"):
    clock.request_body = lambda *args, **kwargs: (200, body, None)
    clock.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
    receipt = clock.observe_one(
        {"id": "S040", "url": "https://example.test/doc"},
        {"id": "S040", "clock": "feed", "feed_url": "https://example.test/feed",
         "anchored_version": anchor, "observed_version": anchor},
        None,
    )
    return {key: receipt.get(key) for key in ("parsed_version", "verdict", "error")}


def feed_probe(body, anchor="3.15.1"):
    try:
        parsed = clock.parse_latest_version(body)
    except Exception as exc:
        parsed = {"exception": type(exc).__name__, "message": str(exc)}
    return {"parser": parsed, "observation": observe(body, anchor)}


unicode_version = "\u0663.\u0661\u0665.\u0661"
probes = {
    "M01": lambda: numeric(unicode_version),
    "M02": lambda: numeric("1.3"),
    "M03": lambda: numeric("1.2.3.4"),
    "M04": lambda: numeric("1.2.3-rc1"),
    "M05": lambda: clock.is_regression("1.2.3", "1.10.0"),
    "M06": lambda: clock.is_regression("1.2.3", "1.2.2"),
    "M07": lambda: clock.is_regression("1.2.3", "0.9.9"),
    "M08": lambda: clock.is_regression("1.2.3", "1.2.3"),
    "M09": lambda: clock.is_regression("1.2.3", "1.2.2"),
    "M10": lambda: numeric("1.2." + "1" * 4301),
    "M11": lambda: feed_probe(("<rss><channel><item><title>Python " + unicode_version + "</title></item></channel></rss>").encode()),
    "M12": lambda: feed_probe(("<feed><entry><link href=\"https://example.test/releases/tag/v" + unicode_version + "\"/></entry></feed>").encode()),
    "M13": lambda: feed_probe(("Version: " + unicode_version + "\n").encode()),
    "M14": lambda: feed_probe(b"<rss><channel><item><title>Python 3.16.0a1</title></item><item><title>Python 3.15.0</title></item></channel></rss>"),
    "M15": lambda: feed_probe(b'<feed><entry><link href="https://example.test/releases/tag/v3.0.0-beta1"/></entry></feed>', "2.9.0"),
    "M16": lambda: feed_probe(b"Version: 8.23.0-rc1\n", "8.22.0"),
    "C1-leading-zero": lambda: {"numeric": numeric("3.15.01"), "feed": feed_probe(b"<rss><channel><item><title>Python 3.15.01</title></item></channel></rss>")},
}
mid = sys.argv[1]
try:
    result = {"value": probes[mid]()}
except Exception as exc:
    result = {"exception": type(exc).__name__, "message": str(exc)}
print(json.dumps({"id": mid, "int_max_str_digits": sys.get_int_max_str_digits(), "result": result}, sort_keys=True, ensure_ascii=True))
