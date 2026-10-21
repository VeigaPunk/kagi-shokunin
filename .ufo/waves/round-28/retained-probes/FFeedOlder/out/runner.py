#!/usr/bin/env python3
"""Child runner: the tree's own release-clock.py main() with the network
transport stubbed to serve the local fixture feed; no socket is opened."""
import importlib.util
import sys
from pathlib import Path

tree, root, out, feed_file, feed_url, observed_at, mode, receipt, receipt_sha = sys.argv[1:10]
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()


def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"


module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
if mode == "observe":
    argv = ["--root", root, "--observe", out]
else:
    argv = ["--root", root, "--receipt", receipt, "--receipt-sha", receipt_sha]
raise SystemExit(module.main(argv))
