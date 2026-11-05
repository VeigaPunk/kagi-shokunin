#!/usr/bin/env bash
# fake gate A (attack item 3): journal-blind; refuses ONLY the DELETED class
# (base-ledger ids absent from the candidate ledger). Never reads --journals.
set -u
base=""; cand=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base-ledger) base="$2"; shift 2 ;;
    --ledger) cand="$2"; shift 2 ;;
    --journals) shift 2 ;;            # deliberately ignored
    *) shift ;;
  esac
done
[ -f "$base" ] && [ -f "$cand" ] || { echo "fakeA: setup error" >&2; exit 2; }
python3 - "$base" "$cand" <<'PY'
import sys
def ids(p):
    return [l.split("\t")[0] for l in open(p, encoding="utf-8")
            if l.strip() and not l.startswith("#")]
b = ids(sys.argv[1]); c = set(ids(sys.argv[2]))
ref = [r for r in b if r not in c]
for r in sorted(ref):
    print("EXPECT_JOURNAL: REFUSE DELETED %s" % r)
if ref:
    print("EXPECT_JOURNAL: REFUSED (violations=%d)" % len(ref)); sys.exit(1)
print("EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"); sys.exit(0)
PY
