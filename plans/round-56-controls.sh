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
# F5 printer gate: replace recheck-replay.py by a CLEAN printer
mk_ref f5; printf '#!/usr/bin/env bash\ncase "${1:-}" in --selftest) echo "RECHECK_REPLAY_SELFTEST: PASS (13 cases)";; *) echo "RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)";; MATCH* ) ;; esac\nexit 0\n' > "$SCR/f5/corpus/recheck-replay.py"
check K1-F5-printer-gate FAIL f5
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
# F9 selftest broken (gate exits 0 run but selftest fails)
mk_ref f9; py 'import sys
p=sys.argv[1]+"/corpus/recheck-replay.py"; s=open(p,encoding="utf-8").read()
t=s.replace("RECHECK_REPLAY_SELFTEST: PASS","RECHECK_REPLAY_SELFTEST: FAILX")
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/f9"
check K1-F9-selftest-broken FAIL f9
# F10 entry symlink
mk_ref f10; mv "$SCR/f10/$ENTRY" "$SCR/f10/e.md"; ln -s ../../e.md "$SCR/f10/$ENTRY"
check K1-F10-entry-symlink FAIL f10

echo "CONTROLS: match=$M mismatch=$K"
[ "$K" = 0 ]
