#!/usr/bin/env bash
# build-trees.sh SRC DEST — clean + defect trees for R67MutGate probes.
set -euo pipefail
SRC=${1:?src}; DEST=${2:?dest}
export LC_ALL=C
mkdir -p "$DEST"
rsync -a --exclude .git "$SRC/" "$DEST/clean/"
args=("$DEST/clean" "$SRC/.ufo/waves/round-67/w1/R67ExecQuoteFix/s115-recut-line.tsv")
python3 - "${args[@]}" <<'PY'
import sys
tree, recut = sys.argv[1], sys.argv[2]
new = open(recut).read().strip("\n").split("\t")
assert len(new) == 16, len(new)
p = f"{tree}/corpus/source-fetches.tsv"
lines = open(p).read().split("\n")
n = 0
for i, l in enumerate(lines):
    f = l.split("\t")
    if len(f) > 15 and f[0] == "S115":
        lines[i] = "\t".join(new); n += 1
assert n == 1, n
open(p, "w").write("\n".join(lines))
PY
mk() { rsync -a "$DEST/clean/" "$DEST/$1/"; }

cat >"$DEST/patch.py" <<'PY'
import os, shutil, sys
tree, defect = sys.argv[1], sys.argv[2]
p = f"{tree}/corpus/source-fetches.tsv"
lines = open(p).read().split("\n")
def edit(fn):
    for i, l in enumerate(lines):
        f = l.split("\t")
        if len(f) > 15 and f[0] == "S113":
            fn(f); lines[i] = "\t".join(f); return
    raise SystemExit("S113 row absent")
def loc(v):
    edit(lambda f: f.__setitem__(15, v))
if defect == "repoint":
    loc(".ufo/waves/round-55/capture/S114.body")
elif defect == "quote":
    def q(f):
        f[12] = "zzq not-a-locating-quote qzz"
        f[13] = "raw-literal-v1"
        f[14] = "-"
    edit(q)
elif defect == "traversal":
    loc("../outside.body")
elif defect == "counts":
    loc("S113 section 4, page 9 of the standard")
elif defect == "absolute":
    loc("/etc/hostname")
elif defect == "escape":
    loc("../outside.body")
elif defect not in ("samesize", "truncate", "delete"):
    raise SystemExit("unknown defect " + defect)
open(p, "w").write("\n".join(lines))
if defect == "samesize":
    b = bytearray(open(f"{tree}/.ufo/waves/round-55/capture/S113.body", "rb").read())
    b[100] ^= 0x01
    open(f"{tree}/.ufo/waves/round-55/capture/S113.body", "wb").write(bytes(b))
elif defect == "truncate":
    b = open(f"{tree}/.ufo/waves/round-55/capture/S113.body", "rb").read()
    open(f"{tree}/.ufo/waves/round-55/capture/S113.body", "wb").write(b[:-1])
elif defect == "delete":
    os.unlink(f"{tree}/.ufo/waves/round-55/capture/S113.body")
elif defect == "escape":
    shutil.copyfile(f"{tree}/.ufo/waves/round-55/capture/S113.body",
                    os.path.join(os.path.dirname(os.path.abspath(tree)), "outside.body"))
PY

for d in repoint samesize quote absolute traversal counts truncate delete escape; do
  mk "$d"
  python3 "$DEST/patch.py" "$DEST/$d" "$d"
done
printf 'trees: %s\n' "$(cd "$DEST" && ls -d */ | tr '\n' ' ')"
