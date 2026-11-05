import json, re, sys, csv, datetime as dt, hashlib
path = sys.argv[1]
raw = open(path, 'rb').read()
print("sha256", hashlib.sha256(raw).hexdigest(), "bytes", len(raw))
print("ends_with_newline", raw.endswith(b"\n"), "crlf", b"\r\n" in raw, "tabs", b"\t" in raw)
d = json.loads(raw.decode())
print("top_keys", sorted(d.keys()), "format", d.get("format"))
obs = d["observations"]
print("n_records", len(obs))
ids = [r.get("id") for r in obs]
print("unique_ids", len(set(ids)), "dup", [i for i in set(ids) if ids.count(i)>1])
print("sorted_by_id", ids == sorted(ids))
keyset = {}
for r in obs:
    k = tuple(sorted(r.keys()))
    keyset[k] = keyset.get(k,0)+1
print("key_shapes", {len(k):v for k,v in keyset.items()}, [list(k) for k in keyset][:3] if len(keyset)>1 else "uniform")
bad_sha = [(r["id"], r.get("sha256")) for r in obs if r.get("clock")=="feed" and not (isinstance(r.get("sha256"),str) and re.fullmatch(r"[0-9a-f]{64}", r["sha256"]))]
print("bad_sha_feed", bad_sha)
sha_dupes = {}
for r in obs:
    if r.get("sha256"): sha_dupes.setdefault(r["sha256"], []).append(r["id"])
print("shared_sha", {k:v for k,v in sha_dupes.items() if len(v)>1})
ts = [(r["id"], r.get("observed_at")) for r in obs]
print("observed_at_values", sorted(set(t for _,t in ts)))
print("observed_at_all_match_Z_fmt", all(isinstance(t,str) and re.fullmatch(r"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ", t) for _,t in ts))
print("errors", [(r["id"], r["error"]) for r in obs if "error" in r])
print("http_status", sorted(set(str(r.get("http_status")) for r in obs)))
print("clock_counts", {c: sum(1 for r in obs if r.get("clock")==c) for c in set(r.get("clock") for r in obs)})
print("urls", sorted(set(r.get("url") for r in obs)))
for r in obs: print(json.dumps(r, sort_keys=True))
# bound rows
rows = [row for row in csv.DictReader(open("corpus/release-clocks.tsv", encoding="utf-8", newline=""), delimiter="\t")]
print("table_rows", len(rows), "feed_rows", sum(1 for r in rows if r["clock"]=="feed"), "quote_rows", sum(1 for r in rows if r["clock"]=="rendered-quote"))
print("ids_in_table_not_receipt", sorted(set(r["id"] for r in rows) - set(ids)))
print("ids_in_receipt_not_table", sorted(set(ids) - set(r["id"] for r in rows)))
