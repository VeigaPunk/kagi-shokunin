#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url = sys.argv[1:6]
spec = importlib.util.spec_from_file_location(
    "release_clock_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
fetched = []
def fixture_request_body(url, opener=None, resolver=None):
    fetched.append(url)
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fixture_request_body
module.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
try:
    code = module.main(["--root", root, "--observe", out])
except BaseException as exc:
    print("HARNESS_EXC %s: %s" % (type(exc).__name__, exc))
    import traceback; traceback.print_exc()
    code = 99
print("HARNESS_FETCHED %s" % (fetched,))
raise SystemExit(code)
