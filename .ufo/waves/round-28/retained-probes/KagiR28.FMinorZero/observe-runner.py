import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("release_clock_fixture", Path(tree)/"corpus"/"release-clock.py")
module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url: return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
