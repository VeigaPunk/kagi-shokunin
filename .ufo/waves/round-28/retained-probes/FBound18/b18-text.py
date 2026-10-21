#!/usr/bin/env python3
"""FBound18 probe 3: the plain-text release feed path (curl 'Version: X.Y.Z')."""
import json, shutil, subprocess, sys, tempfile
from pathlib import Path
tree = Path(sys.argv[1]).resolve()
token = sys.argv[2]
temp = Path(tempfile.mkdtemp(prefix="fb18t-"))
root = temp / "fx"; (root / "corpus").mkdir(parents=True)
for rel in ["SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py", "release-clocks.tsv"]:
    shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
runner = temp / "runner.py"
runner.write_text('''import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("rc", Path(tree)/"corpus"/"release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
data = Path(feed_file).read_bytes()
m.request_body = lambda url, opener=None, resolver=None: (200, data, None) if url == feed_url else (None, None, "no")
m.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(m.main(["--root", root, "--observe", out]))
''')
# narrow the table to S040 and point its feed at a local text file
lines = (tree/"corpus"/"release-clocks.tsv").read_text().splitlines()
feed_url = None; observed_at = None
out_lines = []
for l in lines:
    f = l.split("\t")
    if f and f[0] == "S040":
        feed_url = f[3]; observed_at = f[6]
    if f and f[0] != "id" and f[0] != "S040":
        continue
    out_lines.append(l)
(root/"corpus"/"release-clocks.tsv").write_text("\n".join(out_lines) + "\n")
feed = root/"feed.txt"; feed.write_text("Version: %s\n" % token)
out = root/"observe-out.json"
p = subprocess.run(["python3","-I","-B",str(runner),str(tree),str(root),str(out),str(feed),feed_url,observed_at],text=True,capture_output=True,timeout=120)
print("token", token, "exit", p.returncode)
print(p.stdout.strip()[:400])
if out.exists():
    for r in json.loads(out.read_text()).get("observations", []):
        print("  receipt:", {k:r.get(k) for k in ("id","verdict","error","parsed_version")})
shutil.rmtree(temp, ignore_errors=True)
