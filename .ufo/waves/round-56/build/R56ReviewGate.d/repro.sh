#!/usr/bin/env bash
# R56ReviewGate repro: minimal public-path false greens in corpus/recheck-replay.py
# and plans/round-56-c1.sh (round-56 predeclaration 42070de).
#
# usage: bash repro.sh <REF_TREE> <SCRATCH_DIR>
#   REF_TREE     a clean checkout of the reviewed revision (git archive 42070de | tar -x)
#   SCRATCH_DIR  empty writable dir; trees are built under it and NOT removed
#
# Every mutation below is a public path: a knowledge entry, the manifest, a capture
# body, or the gate file itself. No network, no secrets. The fake cookie value is
# literally "demo-not-a-real-value".
set -u
REF=${1:?reference tree}
SCR=${2:?scratch dir}
LANE=${LANE:-/home/vgpnk/Projects/shokunin/kagi-shokunin}
C1="$LANE/plans/round-56-c1.sh"
GATE=corpus/recheck-replay.py
MAN=corpus/recheck-captures.tsv
export TMPDIR=$SCR
mkdir -p "$SCR"
mk() { rm -rf "$SCR/$1"; cp -a "$REF" "$SCR/$1"; }

gate() { ( cd "$SCR/$1" && TMPDIR=$SCR python3 -I -B "$GATE" --root "$SCR/$1" 2>&1 ); echo "gate_rc=$?"; }
cnt()  { HYAKU_SCRATCH=$SCR/hy bash "$C1" --tree "$SCR/$1" 2>&1 | sed -n '1p'; }

# ---- A1/A2: a clock can be deleted and the gate still says CLEAN --------------
mk a1
python3 -I -B - "$SCR/a1" <<'PY'
import sys
p=sys.argv[1]+"/corpus/knowledge/trufflehog-verification-lifecycle.md"; s=open(p).read()
t=s.replace("` -> 1 (ran 2026-10-23)","` (no count recorded) (ran 2026-10-23)",1)
assert t!=s; open(p,"w").write(t)
PY
mk a2
python3 -I -B - "$SCR/a2" <<'PY'
import sys
p=sys.argv[1]+"/corpus/knowledge/trufflehog-verification-lifecycle.md"; s=open(p).read()
t="\n".join(l for l in s.splitlines() if not l.startswith("recheck:"))+"\n"
assert t!=s; open(p,"w").write(t)
PY

# ---- A7/A8: http_status and fetched columns are inert -------------------------
mk a7
python3 -I -B - "$SCR/a7" <<'PY'
import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; s=open(p).read()
t=s.replace("\t200\t","\t404\t",1); assert t!=s; open(p,"w").write(t)
PY
mk a8
python3 -I -B - "$SCR/a8" <<'PY'
import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; s=open(p).read()
t=s.replace("\t2026-11-07\t200\t","\tnot-a-date\t200\t",1); assert t!=s; open(p,"w").write(t)
PY

# ---- F1: curl -v shaped body (status line + set-cookie, not at offset 0) ------
mk sv
python3 -I -B - "$SCR/sv" <<'PY'
import sys,hashlib
root=sys.argv[1]; p=root+"/.ufo/waves/round-56/capture/S054.body"
orig=open(p,"rb").read()
trace=(b"* Connected to raw.githubusercontent.com\n* using HTTP/1.1\n"
       b"> GET /trufflesecurity/trufflehog/main/README.md HTTP/1.1\n"
       b"< HTTP/1.1 200 OK\n< set-cookie: session=demo-not-a-real-value\n"
       b"< content-type: text/plain\n\n")
d=trace+orig; open(p,"wb").write(d)
mp=root+"/corpus/recheck-captures.tsv"; out=[]
for l in open(mp).read().splitlines():
    c=l.split("\t")
    if c and c[0]=="S054": c[5]=str(len(d)); c[6]=hashlib.sha256(d).hexdigest(); l="\t".join(c)
    out.append(l)
open(mp,"w").write("\n".join(out)+"\n")
PY

# ---- F2: gate that fails (rc 3) but ends with a CLEAN-prefixed line -----------
mk st
python3 -I -B - "$SCR/st" <<'PY'
import sys
root=sys.argv[1]
lines=[
 "MATCH corpus/knowledge/betterleaks-detection-vs-validation.md:4 id=S055 form=grep stated=1 replayed=1",
 "MATCH corpus/knowledge/cdp-bridge-1password-oidc-workflow.md:3 id=S070 form=locate stated=1 replayed=1",
 "MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S101 form=grep stated=2 replayed=2",
 "MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S113 form=grep stated=3 replayed=3",
 "MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S114 form=grep stated=2 replayed=2",
 "MATCH corpus/knowledge/nist-key-management-guidance-status.md:3 id=S074 form=grep stated=1 replayed=1",
 "MATCH corpus/knowledge/nist-key-management-parts-withdrawal.md:3 id=S078 form=pdf stated=1 replayed=1",
 "MATCH corpus/knowledge/oidc-federation-trust-policy.md:3 id=S067 form=grep stated=1 replayed=1",
 "MATCH corpus/knowledge/secret-scanning-detection-vs-validation.md:4 id=S054 form=grep stated=1 replayed=1",
 "MATCH corpus/knowledge/trufflehog-verification-lifecycle.md:4 id=S057 form=grep stated=1 replayed=1",
 "RECHECK_REPLAY: CLEANUP failed, population truncated",
]
open(root+"/corpus/recheck-replay.py","w").write(
 '#!/usr/bin/env python3\nimport sys\nif "--selftest" in sys.argv:\n'
 '    print("RECHECK_REPLAY_SELFTEST: PASS (13 cases)"); sys.exit(0)\n'
 'print("\\n".join(%r)); sys.exit(3)\n' % lines)
PY

# ---- F5: locate producer prints a count then exits 2 -------------------------
mk src2
python3 -I -B - "$SCR/src2" <<'PY'
import sys
open(sys.argv[1]+"/corpus/rendered-text-v1.py","w").write(
 '#!/usr/bin/env python3\nimport sys\n'
 'print("RENDERED_TEXT_V1_LOCATE: count=1")\nsys.exit(2)\n')
PY

for t in a1 a2 a7 a8 sv st src2; do
  echo "===== $t ====="
  gate "$t" | tail -2
  cnt  "$t"
done
