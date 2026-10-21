import importlib.util, pathlib, io
def load(p):
    spec=importlib.util.spec_from_file_location("rc3", p)
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
class Op:
    def open(self, req, timeout=None):
        class R(io.BytesIO):
            status=200
            def info(self): return type("I",(),{"headers":{}})()
            def geturl(self): return "https://www.python.org/downloads/"
        return R(b"<feed><entry><title>Python 3.15.1</title></entry></feed>")
def res(*a, **kw): return ["93.184.216.34"]
for tree in ("cand","base"):
    m=load(str(pathlib.Path(tree)/'corpus/release-clock.py'))
    src={"url":"https://www.python.org/downloads/","teaches":"t"}
    for obs in ("3.015.1","3.15.01"):
        vals={"id":"S040","clock":"feed","feed_url":"https://www.python.org/downloads/feed.rss",
              "anchored_version":obs,"observed_version":obs}
        r=m.observe_one(src, vals, None, opener=Op(), resolver=res)
        print(tree, obs, "verdict=",r.get("verdict"), "parsed=",r.get("parsed_version"),
              "error=",repr(r.get("error")))
