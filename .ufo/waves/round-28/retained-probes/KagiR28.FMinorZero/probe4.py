import importlib.util, pathlib, io, socket
def load(p):
    spec=importlib.util.spec_from_file_location("rc4", p)
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
class Op:
    def __init__(self, body): self.body=body
    def open(self, req, timeout=None):
        b=self.body
        class R(io.BytesIO):
            status=200
            def info(self): return type("I",(),{"headers":{}})()
            def geturl(self): return "https://www.python.org/downloads/"
        return R(b)
def res(*a, **kw): return [(socket.AF_INET, socket.SOCK_STREAM, 6, "", ("93.184.216.34", 443))]
FEEDS = {
  "canonical 3.15.1": b"<feed><entry><title>Python 3.15.1</title></entry></feed>",
  "leading-zero 3.15.01": b"<feed><entry><title>Python 3.15.01</title></entry></feed>",
  "oversize": b"<feed><entry><title>Python 3.15." + b"1"*4301 + b"</title></entry></feed>",
}
for tree in ("cand","base"):
    m=load(str(pathlib.Path(tree)/'corpus/release-clock.py'))
    src={"url":"https://www.python.org/downloads/","teaches":"t"}
    for label, body in FEEDS.items():
        vals={"id":"S040","clock":"feed","feed_url":"https://www.python.org/downloads/feed.rss",
              "anchored_version":"3.15.1","observed_version":"3.15.1"}
        r=m.observe_one(src, vals, None, opener=Op(body), resolver=res)
        print(f"{tree:5s} feed={label:22s} verdict={r.get('verdict')!r} parsed={r.get('parsed_version')!r} error={r.get('error')!r}")
