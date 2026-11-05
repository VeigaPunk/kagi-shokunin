import csv, json, re, sys, io, os
root = sys.argv[1]
os.chdir(root)
# F4: default receipt pin and path
src = open("corpus/release-clock.py", encoding="utf-8").read()
old_sha = '"13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169"'
new_sha = '"3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727"'
assert src.count(old_sha) == 1, src.count(old_sha)
src = src.replace(old_sha, new_sha)
old_path = 'return root / ".ufo" / "waves" / "round-26" / "observe-2.json"'
new_path = 'return root / ".ufo" / "waves" / "round-36" / "controls" / "observe-live.json"'
assert src.count(old_path) == 1
src = src.replace(old_path, new_path)
old_help = "(default is the round-26 rearmed receipt)"
assert src.count(old_help) == 1
src = src.replace(old_help, "(default is the round-36 rearmed receipt)")
open("corpus/release-clock.py", "w", encoding="utf-8", newline="").write(src)

# F3: 15 drifting clock=feed rows take the receipt values
doc = json.load(open(".ufo/waves/round-36/controls/observe-live.json", encoding="utf-8"))
rec = {r["id"]: r for r in doc["observations"]}
text = open("corpus/release-clocks.tsv", encoding="utf-8", newline="").read()
lines = text.split("\n")
header = lines[0].split("\t")
ci = {k: header.index(k) for k in header}
changed = []
for i, line in enumerate(lines[1:], start=1):
    if not line:
        continue
    f = line.split("\t")
    if f[ci["clock"]] != "feed":
        continue
    r = rec.get(f[0])
    if r is None:
        continue
    drift = (r["parsed_version"] != f[ci["observed_version"]]) or (r["verdict"] != f[ci["verdict"]])
    if not drift:
        continue
    f[ci["observed_version"]] = r["parsed_version"]
    f[ci["observed_at"]] = r["observed_at"][:10]
    f[ci["verdict"]] = r["verdict"]
    note = f[ci["note"]]
    if "observe-live.json" not in note:
        note = note + "; re-observed by the round-36 receipt observe-live.json (2026-11-04)"
    f[ci["note"]] = note
    lines[i] = "\t".join(f)
    changed.append(f[0])
open("corpus/release-clocks.tsv", "w", encoding="utf-8", newline="").write("\n".join(lines))
print("F3 changed rows:", len(changed), changed)
