# probe-only: end-to-end --observe with every fetch stubbed (python feed = local copy, others = HTTP 503)
import importlib.util, io, contextlib, shutil, sys, tempfile
from pathlib import Path
tree = Path(sys.argv[1]).resolve(); title = sys.argv[2]
tmp = Path(tempfile.mkdtemp(prefix="critsep-obs-")); shutil.copytree(tree / "corpus", tmp / "corpus")
spec = importlib.util.spec_from_file_location("rc", tmp / "corpus" / "release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
body = ("<rss><channel><item><title>Python 3.14.9</title></item><item><title>%s</title></item>"
        "<item><title>Python 3.15.1</title></item></channel></rss>" % title).encode()
m.request_body = lambda url, opener=None, resolver=None: (200, body, None) if "python.org/downloads" in url else (503, b"", "HTTP 503")
out = io.StringIO(); code = None
with contextlib.redirect_stdout(out):
    try: code = m.main(["--root", str(tmp), "--observe", str(tmp / "obs.json")])
    except Exception as e: print("TRACEBACK", type(e).__name__)
lines = out.getvalue().splitlines()
print("exit=%s" % code, [l[:70] for l in lines if "S040" in l or "TRACEBACK" in l or l.startswith("RELEASE_CLOCK")])
shutil.rmtree(tmp)
