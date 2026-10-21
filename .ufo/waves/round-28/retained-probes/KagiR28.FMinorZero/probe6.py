import importlib.util, pathlib, io, socket
def load(p):
    spec=importlib.util.spec_from_file_location("rc6", p)
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
def res(*a, **kw): return [(socket.AF_INET, socket.SOCK_STREAM, 6, "", ("93.184.216.34", 443))]
FEEDS = {
 "feed minor-lead-zero 3.015.1": b"<feed><entry><title>Python 3.015.1</title></entry></feed>",
 "feed minor-lead-zero + canonical": b"<feed><entry><title>Python 3.015.1</title></entry><entry><title>Python 3.15.0</title></entry></feed>",
 "feed patch-lead-zero 3.15.01": b"<feed><entry><title>Python 3.15.01</title></entry></feed>",
}
for tree in ("cand","base"):
    m=load(str(pathlib.Path(tree)/'corpus/release-clock.py'))
    for label, body in FEEDS.items():
        try:
            v=m.parse_latest_version(body)
            print(f"{tree:5s} {label:38s} -> parsed {v!r}")
        except Exception as e:
            print(f"{tree:5s} {label:38s} -> {type(e).__name__}: {e}")
