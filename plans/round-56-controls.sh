#!/usr/bin/env bash
# plans/round-56-controls.sh -- pre-freeze controls for the round-56 counter.
# Each control builds a tree in scratch, runs the frozen counter on it and compares
#   the reading with the expectation written in the table below BEFORE the run.
#   usage: bash plans/round-56-controls.sh REFTREE
#   REFTREE is the reference overlay (the working tree that carries the planned
#   landing); BASE and the forgeries are built from BASE and from REFTREE.
# Output: one line per control `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH`
#   and a last line `CONTROLS: match=M mismatch=K`; exit 0 iff K = 0.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=832ba6a53d6a76706b5c80bce2278683dea33d42
REF=${1:?reference tree}
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/controls.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
C1="$REPO/plans/round-56-c1.sh"
mk_base() { mkdir -p "$SCR/$1" && git -C "$REPO" archive "$BASE" | tar -x -C "$SCR/$1"; }
mk_ref() { mkdir -p "$SCR/$1" && (cd "$REF" && git ls-files -co --exclude-standard -z | tar --null -T - -cf -) | tar -x -C "$SCR/$1"; }
py() { python3 -I -B -c "$1" "${@:2}"; }
# edit helper: py-sub DIR RELPATH OLD NEW [COUNT]  (literal replace, must change the file)
sub() { py 'import sys
p=sys.argv[1]+"/"+sys.argv[2]; s=open(p,encoding="utf-8").read(); n=int(sys.argv[5]) if len(sys.argv)>5 else -1
t=s.replace(sys.argv[3],sys.argv[4],n)
assert t!=s, "inert edit "+sys.argv[2]
open(p,"w",encoding="utf-8").write(t)' "$@"; }
pick() { sed -n 's/^\(C1_REPLAY: value=\)\([^ ]*\) .*/\2/p' | head -1; }
M=0; K=0
report() { # id expect line
  local got; got=$(printf '%s\n' "$3" | pick)
  if [ "$got" = "$2" ]; then M=$((M+1)); r=MATCH; else K=$((K+1)); r=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=${got:-none} $r :: $(printf '%s\n' "$3" | head -1)"
}
check() { report "$1" "$2" "$(bash "$C1" --tree "$SCR/$3" 2>&1)"; }
check_rev() { report "$1" "$2" "$(bash "$C1" "$3" 2>&1)"; }
ENTRY=corpus/knowledge/betterleaks-detection-vs-validation.md

# ---------------- C1 ----------------
check_rev K1-BASE 0 "$BASE"
mk_ref ref; check K1-REF 10 ref
# F1 delete one clock's stated line (restated expectation on a second recheck line is removed)
mk_ref f1; py 'import sys
p=sys.argv[1]+"/corpus/knowledge/trufflehog-verification-lifecycle.md"; s=open(p,encoding="utf-8").read()
i=s.find("recheck:"); j=s.find("\n",i); open(p,"w",encoding="utf-8").write(s[:i]+"recheck: 180d — on-change — reopen the docs page"+s[j:])' "$SCR/f1"
check K1-F1-clock-removed FAIL f1
# F2 restate one clock's N (stale expectation passes the gate only if capture changes; counter must not)
mk_ref f2; sub "$SCR/f2" "$ENTRY" "by default\` -> 1" "by default\` -> 2" || true
sub "$SCR/f2" corpus/knowledge/betterleaks-detection-vs-validation.md 'default`' 'default`' >/dev/null 2>&1 || true
# simpler: rewrite the stated N via regex on the recheck line
py 'import sys,re
p=sys.argv[1]+"/corpus/knowledge/betterleaks-detection-vs-validation.md"; s=open(p,encoding="utf-8").read()
t=re.sub(r"(curl -fsSL .https://raw\.githubusercontent\.com/betterleaks[^\`]*\` -> )1", r"\g<1>2", s)
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/f2"
check K1-F2-restated-N FAIL f2
# F3 forged capture: append a byte to one body without updating the manifest
mk_ref f3; printf 'x' >> "$SCR/f3/.ufo/waves/round-56/capture/S054.body"
check K1-F3-body-tampered 0 f3
# F4 manifest row dropped
mk_ref f4; py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"; s=open(p,encoding="utf-8").read()
t="\n".join(l for l in s.splitlines() if not l.startswith("S054\t"))+"\n"
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/f4"
check K1-F4-row-dropped 0 f4
# F5 printer gate: a python3 printer that reads nothing, replays nothing, prints
# the ten MATCH lines + CLEAN + a 0-case selftest PASS. Under the pinned-digest
# counter this must read FAIL (digest mismatch -> gate_ok=0 -> every r5 fails).
mk_ref f5; cat > "$SCR/f5/corpus/recheck-replay.py" <<'PY'
import sys
if "--selftest" in sys.argv:
    print("RECHECK_REPLAY_SELFTEST: PASS (0 cases)")
else:
    clocks=[("corpus/knowledge/betterleaks-detection-vs-validation.md","S055","grep",1),("corpus/knowledge/cdp-bridge-1password-oidc-workflow.md","S070","locate",1),("corpus/knowledge/iso-11770-3-edition-status.md","S101","grep",2),("corpus/knowledge/iso-11770-3-edition-status.md","S113","grep",3),("corpus/knowledge/iso-11770-3-edition-status.md","S114","grep",2),("corpus/knowledge/nist-key-management-guidance-status.md","S074","grep",1),("corpus/knowledge/nist-key-management-parts-withdrawal.md","S078","pdf",1),("corpus/knowledge/oidc-federation-trust-policy.md","S067","grep",1),("corpus/knowledge/secret-scanning-detection-vs-validation.md","S054","grep",1),("corpus/knowledge/trufflehog-verification-lifecycle.md","S057","grep",1)]
    for e,i,f,n in clocks: print("MATCH %s:3 id=%s form=%s stated=%d replayed=%d"%(e,i,f,n,n))
    print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
PY
check K1-F5-printer-gate 0 f5
# F5b gate edited in place (one conjunct dropped) — digest mismatch fails every r5
mk_ref f5b; py 'import sys
p=sys.argv[1]+"/corpus/recheck-replay.py"; s=open(p,encoding="utf-8").read()
t=s.replace("re.search(rb\"(?im)^set-cookie:\", data)","False")
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/f5b"
check K1-F5b-gate-edited 0 f5b
# F5c gate path symlinked to an off-tree copy of the real gate
mk_ref f5c; cp "$SCR/f5c/corpus/recheck-replay.py" "$SCR/realgate.py"; rm "$SCR/f5c/corpus/recheck-replay.py"; ln -s "$(python3 -c "import os;print(os.path.relpath('$SCR/realgate.py','$SCR/f5c/corpus'))")" "$SCR/f5c/corpus/recheck-replay.py"
check K1-F5c-gate-symlink 0 f5c
# F11 restated N with trailing letter (`-> 1x`) must not satisfy PRESENT
mk_ref f11; py 'import sys,re
p=sys.argv[1]+"/corpus/knowledge/betterleaks-detection-vs-validation.md"; s=open(p,encoding="utf-8").read()
t=re.sub(r"(->\s*)1(?!\d)", r"\g<1>1x", s, count=1)
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/f11"
check K1-F11-restated-Nx FAIL f11
# F12 one added uncaptured clock -> gate DRIFT -> every r5 fails (population guard)
mk_ref f12; py 'import sys
p=sys.argv[1]+"/corpus/knowledge/prefreeze-controls.md"; s=open(p,encoding="utf-8").read()
s=s.replace("replay the frozen BASE controls after any gate change","`curl -fsSL https://example.invalid/x | grep -c needle` -> 1; replay the frozen BASE controls after any gate change")
open(p,"w",encoding="utf-8").write(s)' "$SCR/f12"
check K1-F12-extra-clock 0 f12
# F6 symlinked capture body
mk_ref f6; mv "$SCR/f6/.ufo/waves/round-56/capture/S055.body" "$SCR/f6/s055.body"; ln -s ../../../s055.body "$SCR/f6/.ufo/waves/round-56/capture/S055.body"
check K1-F6-symlink-body 0 f6
# F7 header bytes in a body
mk_ref f7; printf 'HTTP/2 200\r\nset-cookie: x=1\r\n\r\n' | cat - "$SCR/f7/.ufo/waves/round-56/capture/S057.body" > "$SCR/f7/tmp" && mv "$SCR/f7/tmp" "$SCR/f7/.ufo/waves/round-56/capture/S057.body"
# manifest digest no longer matches, so also fix the manifest row to keep only the header check live? counter checks digest first -> still FAIL; make it reach r3-headers by fixing bytes+sha
py 'import sys,hashlib
root=sys.argv[1]; p=root+"/.ufo/waves/round-56/capture/S057.body"; d=open(p,"rb").read()
mp=root+"/corpus/recheck-captures.tsv"; s=open(mp).read().splitlines()
out=[]
for l in s:
    c=l.split("\t")
    if c and c[0]=="S057":
        c[5]=str(len(d)); c[6]=hashlib.sha256(d).hexdigest(); l="\t".join(c)
    out.append(l)
open(mp,"w").write("\n".join(out)+"\n")' "$SCR/f7"
check K1-F7-header-bytes 0 f7
# F8 unsupported form added to an entry must not score (extra clock with a pipe the gate can't parse -> gate DRIFT, counter still CLEAN? must read FAIL via r5 or present)
mk_ref f8; py 'import sys
p=sys.argv[1]+"/corpus/knowledge/prefreeze-controls.md"; s=open(p,encoding="utf-8").read()
s=s.replace("recheck: on-change — bash corpus/prefreeze-control.sh --selftest; replay the frozen BASE controls after any gate change",
 "recheck: 90d — `curl -fsSL https://example.invalid/x | sed -n 1p | grep -c needle` -> 1; replay")
open(p,"w",encoding="utf-8").write(s)' "$SCR/f8"
check K1-F8-unsupported-clock 0 f8
# F9 gate file replaced by the pinned bytes plus one byte — digest mismatch
# (the pin makes a selftest-only break unreachable: any byte change fails the
# digest before selftest is consulted).
mk_ref f9; printf ' ' >> "$SCR/f9/corpus/recheck-replay.py"
check K1-F9-gate-byte-drift 0 f9
# F10 entry symlink
mk_ref f10; mv "$SCR/f10/$ENTRY" "$SCR/f10/e.md"; ln -s ../../e.md "$SCR/f10/$ENTRY"
check K1-F10-entry-symlink FAIL f10

echo "CONTROLS: match=$M mismatch=$K"
[ "$K" = 0 ]
