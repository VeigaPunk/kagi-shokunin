#!/usr/bin/env python3
"""Child runner: run a tree's corpus/release-clock.py main() with only the
network transport stubbed, so the local fixture feed body is served verbatim.

Usage: run-observe.py TREE ROOT OUT.json FEED_FILE FEED_URL OBSERVED_AT

The only substitution is module.request_body (the script's own selftest makes
the same substitution) and module.utc_timestamp (pinned to the row's observed
date). No code inside the tree is edited.
"""
import importlib.util
import os
import sys
from pathlib import Path

tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
# Optional control: lower CPython's decimal int/string conversion limit inside
# the child (the -I flag ignores PYTHON* env vars, so it is set here).
_limit = os.environ.get("PROBE_INT_MAX_STR_DIGITS")
if _limit:
    sys.set_int_max_str_digits(int(_limit))
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()


def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "probe harness: unexpected URL fetch"


module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
