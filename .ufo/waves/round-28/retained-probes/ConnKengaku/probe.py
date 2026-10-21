import importlib.util, sys, pathlib, tempfile, shutil

BASE = pathlib.Path(__file__).resolve().parent / "base"
spec = importlib.util.spec_from_file_location("rc", BASE / "corpus/release-clock.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

print("python", sys.version.split()[0], "int_max_str_digits", sys.get_int_max_str_digits())
for c in ["3.15.1", "3.15.01", "v3.15.01"]:
    print("norm_equal_zero", c, m.norm_version(c) == m.norm_version("3.15.1"),
          "numeric", m.numeric_version(c))
big = "3.15." + "1" * 4301
try:
    m.numeric_version(big)
    print("numeric_oversize OK")
except Exception as e:
    print("numeric_oversize EXC", type(e).__name__, str(e)[:60])
print("is_regression_3.15.1_vs_3.15.01", m.is_regression("3.15.1", "3.15.01"))
print("version_is_named_one_component", m.version_is_named("v1 (30 Sep 2025)", "1"))

body = b'<?xml version="1.0"?><rss><channel><item><title>Python 3.15.01</title></item></channel></rss>'
try:
    print("parse_latest_zero", m.parse_latest_version(body))
except Exception as e:
    print("parse_latest_zero EXC", type(e).__name__, str(e)[:60])
body2 = ('<?xml version="1.0"?><rss><channel><item><title>Python ' + big + '</title></item></channel></rss>').encode()
try:
    print("parse_latest_oversize", m.parse_latest_version(body2)[:20])
except Exception as e:
    print("parse_latest_oversize EXC", type(e).__name__, str(e)[:60])

# 4-digit registry id visibility
tmp = pathlib.Path(tempfile.mkdtemp(prefix="connkengaku-"))
try:
    (tmp / "corpus").mkdir()
    src = (BASE / "corpus/SOURCES.md").read_text()
    row = "| S1000 | probe | docs | A | probe | v9.9.9 | probe | mined | 2026-10-21 | 90d | — |"
    (tmp / "corpus/SOURCES.md").write_text(src + "\n" + row + "\n")
    parsed = m.parse_sources(tmp)
    print("s1000_visible", "S1000" in parsed, "rows_parsed", len(parsed))
finally:
    shutil.rmtree(tmp)

# C2 baseline satisfiability + column-swap blind spot
sources = m.parse_sources(BASE)
rows = m.parse_bindings(BASE)
derived = []
for row in rows:
    v = dict(zip(m.HEADER, row["fields"]))
    if v["note"].startswith("derived:"):
        derived.append(v)
print("derived_rows", len(derived))
miss_anchor = []
teaches_also_names = []
for v in derived:
    feed = sources.get(v["feed_source_id"])
    anchored = v["anchored_version"]
    if not m.version_is_named(feed["anchor"], anchored):
        miss_anchor.append(v["id"])
    if m.version_is_named(feed["teaches"], anchored):
        teaches_also_names.append(v["id"])
print("derived_anchor_not_named_by_feed_anchor", miss_anchor)
print("derived_also_named_by_feed_teaches", teaches_also_names)

# full table: anchor vs teaches name check for every feed row used
used = sorted({v["feed_source_id"] for v in derived})
for sid in used:
    s = sources[sid]
    print("feed_row", sid, "line", s["line"], "anchor_names_any_derived",
          [v["anchored_version"] for v in derived if v["feed_source_id"] == sid
           and m.version_is_named(s["anchor"], v["anchored_version"])],
          "teaches_names",
          [v["anchored_version"] for v in derived if v["feed_source_id"] == sid
           and m.version_is_named(s["teaches"], v["anchored_version"])])
print("sources_header_pinned_in_parse_sources", any(
    "| id | source |" in line for line in (BASE / "corpus/SOURCES.md").read_text().splitlines()[:10]))
