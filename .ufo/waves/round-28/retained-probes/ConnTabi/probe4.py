import importlib.util, sys, re
from pathlib import Path
spec = importlib.util.spec_from_file_location("rc", sys.argv[1])
rc = importlib.util.module_from_spec(spec); spec.loader.exec_module(rc)
root = Path(sys.argv[2])
sources = rc.parse_sources(root)
rows = rc.parse_bindings(root)
print("rows", len(rows), "sources", len(sources))
bad = 0
for row in rows:
    if row["malformed"]:
        print("MALFORMED", row); bad += 1; continue
    v = dict(zip(rc.HEADER, row["fields"]))
    if not v["note"].startswith("derived:"):
        continue
    feed = sources[v["feed_source_id"]]
    toks = [rc.norm_version(m.group(1)) for m in rc.VERSION_RE.finditer(feed["anchor"])]
    uniq = sorted(set(toks))
    ok = rc.norm_version(v["anchored_version"]) in uniq
    exact = uniq == [rc.norm_version(v["anchored_version"])]
    print("%s feed=%s anchored=%s anchor_tokens=%s in_set=%s set_equals=%s" % (
        v["id"], v["feed_source_id"], v["anchored_version"], uniq, ok, exact))
    if not (ok and exact): bad += 1
print("derived rows failing literal set-equality:", bad)
