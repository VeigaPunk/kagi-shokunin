#!/usr/bin/env bash
# fake gate A+ (attack item 3 ceiling probe): the STRONGEST possible journal-blind
# gate -- refuses deletions (DELETED) and non-literal changed expects (NOT_LITERAL,
# replicating the real gate's literal_anchored). Cannot see UNJOURNALED/OLD/COMMAND.
set -u
base=""; cand=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base-ledger) base="$2"; shift 2 ;;
    --ledger) cand="$2"; shift 2 ;;
    --journals) shift 2 ;;
    *) shift ;;
  esac
done
[ -f "$base" ] && [ -f "$cand" ] || { echo "fakeA+: setup error" >&2; exit 2; }
python3 - "$base" "$cand" <<'PY'
import sys
META = set(".[]()*+?{}|^$")
def rows(p):
    d = {}
    for l in open(p, encoding="utf-8"):
        if l.strip() and not l.startswith("#"):
            f = l.rstrip("\n").split("\t"); d[f[0]] = (f[1], f[2])
    return d
def literal_anchored(expect):
    if len(expect) < 2 or expect[0] != "^" or expect[-1] != "$":
        return False
    esc = False
    for ch in expect[1:-1]:
        if esc: esc = False
        elif ch == "\\": esc = True
        elif ch in META: return False
    return not esc
b = rows(sys.argv[1]); c = rows(sys.argv[2])
ref = []
for rid in sorted(b):
    if rid not in c:
        ref.append("EXPECT_JOURNAL: REFUSE DELETED %s" % rid)
    elif b[rid][1] != c[rid][1] and not literal_anchored(c[rid][1]):
        ref.append("EXPECT_JOURNAL: REFUSE NOT_LITERAL %s" % rid)
for r in ref:
    print(r)
if ref:
    print("EXPECT_JOURNAL: REFUSED (violations=%d)" % len(ref)); sys.exit(1)
print("EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"); sys.exit(0)
PY
