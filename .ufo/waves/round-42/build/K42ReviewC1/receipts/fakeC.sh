#!/usr/bin/env bash
# fake gate C (attack item 3): accepts P0 and refuses F1..F5 by hardcoded
# per-id matching (an answer key keyed to the five frozen forgeries; it reads
# the journals but implements no journal-gate semantics beyond the key).
set -u
base=""; cand=""; jdir=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base-ledger) base="$2"; shift 2 ;;
    --ledger) cand="$2"; shift 2 ;;
    --journals) jdir="$2"; shift 2 ;;
    *) shift ;;
  esac
done
[ -f "$base" ] && [ -f "$cand" ] && [ -d "$jdir" ] || { echo "fakeC: setup error" >&2; exit 2; }
python3 - "$base" "$cand" "$jdir" <<'PY'
import json, os, sys
def rows(p):
    d = {}
    for l in open(p, encoding="utf-8"):
        if l.strip() and not l.startswith("#"):
            f = l.rstrip("\n").split("\t"); d[f[0]] = (f[1], f[2])
    return d
b = rows(sys.argv[1]); c = rows(sys.argv[2])
ents = {}
for dp, dn, fn in os.walk(sys.argv[3]):
    for f in sorted(fn):
        if f.endswith(".json"):
            doc = json.load(open(os.path.join(dp, f), encoding="utf-8"))
            for m in doc.get("migrations", []):
                ents.setdefault(m["id"], []).append(m)
ref = set()
def add(cls, rid): ref.add("EXPECT_JOURNAL: REFUSE %s %s" % (cls, rid))
for rid in sorted(b):
    if rid not in c:
        add("DELETED", rid)                                   # F5
changed = lambda rid: rid in b and rid in c and b[rid] != c[rid]
if changed("R13-01"):                                         # F1 / F3
    e = ents.get("R13-01")
    if not e:
        add("UNJOURNALED", "R13-01")
    elif any(m["new_expect"] == "^[0-9]+$" for m in e):
        add("NOT_LITERAL", "R13-01")
if changed("R21-02"):                                         # F2
    for m in ents.get("R21-02", []):
        if m["old_expect"] == m["new_expect"]:
            add("OLD_MISMATCH", "R21-02")
if changed("R24-06"):                                         # F4
    if not any(m["command"] == c["R24-06"][0] for m in ents.get("R24-06", [])):
        add("COMMAND_MISMATCH", "R24-06")
for r in sorted(ref):
    print(r)
if ref:
    print("EXPECT_JOURNAL: REFUSED (violations=%d)" % len(ref)); sys.exit(1)
print("EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"); sys.exit(0)
PY
