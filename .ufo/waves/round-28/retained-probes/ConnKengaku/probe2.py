import importlib.util, pathlib, json

BASE = pathlib.Path(__file__).resolve().parent / "base"
spec = importlib.util.spec_from_file_location("rc", BASE / "corpus/release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

src = {"id": "S001", "url": "https://example.test/feed", "kind": "docs",
       "anchor": "Version: 3.15.1", "teaches": "t", "recheck": "on-release", "line": 1}
def vals(anchor="3.15.1", observed="3.15.1", verdict="not-fired"):
    return {"id": "S001", "clock": "feed", "feed_source_id": "S002",
            "feed_url": "https://example.test/feed", "anchored_version": anchor,
            "observed_version": observed, "observed_at": "2026-10-21",
            "verdict": verdict, "note": "derived: probe"}

def run(label, body):
    m.request_body = lambda url, opener=None, resolver=None: (200, body, None)
    r = m.observe_one(src, vals(), None)
    print(label, "receipt_verdict=", r.get("verdict"), "parsed=", r.get("parsed_version"),
          "error=", (r.get("error") or "")[:50])
    bundle = {"records": {"S001": r}, "invalid_ids": set(), "invalid": False}
    rows = [{"id": "S001", "fields": ["S001", "feed", "S002", "https://example.test/feed",
             "3.15.1", "3.15.1", "2026-10-21", "not-fired", "derived: probe"],
             "line": 2, "malformed": False}]
    sources = {"S001": src, "S002": {"id": "S002", "url": "https://example.test/feed",
               "kind": "docs", "anchor": "Version: 3.15.1", "teaches": "t",
               "recheck": "90d", "line": 3}}
    res = m.evaluate(sources, rows, None, bundle)
    print(label, "evaluate_errors=", res["errors"], "observed=", res["observed"],
          "fired=", res["fired"])

run("F3_leading_zero",
    b'<?xml version="1.0"?><rss><channel><item><title>Python 3.15.01</title></item></channel></rss>')
run("F4_oversize",
    ('<?xml version="1.0"?><rss><channel><item><title>Python 3.15.' + "1"*4301 +
     '</title></item></channel></rss>').encode())
