#!/usr/bin/env bash
# R56ExecControls.d/controls.sh -- prefreeze executable controls for the PROPOSED
# round-56 C1 counter (plans/round-56-c1.sh, lane kagi, BASE
# 832ba6a53d6a76706b5c80bce2278683dea33d42, freeze NOT yet occurred).
#
# usage: controls.sh --tree DIR [--only ERE] [--receipt PATH]
#   --tree DIR   reference landing tree (the overlay the counter will measure;
#                normally the lane working tree at /home/vgpnk/Projects/shokunin/kagi-shokunin)
#   --only ERE   run only controls whose id matches the ERE (default all)
#   --receipt P  receipt file (default: this script's dir / controls-run.txt)
#
# For every control the expectation below was fixed BEFORE the run it is scored in,
# derived only from the frozen predicate in plans/round-56.md section C1 and the
# PROPOSED counter/gate source -- never from a prior run's results. Run-1 shakeout
# (disclosed): two sub() calls carried unescaped backticks so two mutations never
# applied, and seventeen expectations ignored that r5's gate-CLEAN conjunct is
# global (any measured-gate DRIFT/SETUP zeroes replayed for every clock); the
# expectations were re-derived from source and fixed before the scored run. The
# counter was never modified by this seat. NOTE: the lane's counter/gate are under
# live repair by the L1 during this wave (predeclaration 42070de, then working-tree
# repairs); each run therefore pins the counter by sha256 and aborts (rc 3) if it
# changes mid-run, and the receipt records the exact counter/gate/manifest hashes
# each run scored against. The script hashes itself into the receipt so a post-run
# edit is detectable.
#
# FROZEN ANCHOR (scored below): epoch-F predeclaration commit 9cbe9d5f803de2518d4c11c6bc6b9a585e5120ad
#   (supersedes dd31b786; history: 42070de A, 5d9a157 B, 711e6393 C, d362318 D, dd31b786 E;
#   F = manifest fetched calendar-validated (shape AND datetime.date.fromisoformat) in gate+counter,
#   vacuous-control fix on their side, GATE_SHA256_PIN bump)
#   -- counter plans/round-56-c1.sh sha256 f4c1de312e4a566dfde6c0699fb66a94c2e71e459eb97afbddb5c4073ffd2382,
#   gate corpus/recheck-replay.py sha256 b6959d6c7afb9380c043cbd40530e6a70ee8da2bf79f1ea9d0669706f50bb5a3
#   (= GATE_SHA256_PIN; gate also pins normaliser 14f6ca6a…, selftest "PASS (20 cases)",
#   header refusal (?im) any-case, N boundary (?![0-9A-Za-z_.]), gate-digest token appended last
#   for present-but-unpinned gate bytes).
#
# Each control copies the reference snapshot once into an isolated scratch tree,
# applies exactly one mutation, runs the public counter
#   HYAKU_SCRATCH=<run> bash plans/round-56-c1.sh --tree <copy>
# (or the revision form for C01) and compares rc + full C1_REPLAY line against the
# expectation. No lane file is written; no git/jj mutation is performed anywhere
# (archive/cat-file/rev-parse reads only); scratch dies with the run.
#
# Output: one line per control
#   CONTROL <id> rc=<rc> MATCH|MISMATCH expect=<ere> got=<line>
# and a last line `CONTROLS: total=N match=M mismatch=K`; exit 0 iff K = 0.
set -u
here=$(cd "$(dirname "$0")" && pwd -P)
REPO=$(cd "$here/../../../../.." && pwd -P)   # .ufo/waves/round-56/build/<seat>.d -> lane root
C1="$REPO/plans/round-56-c1.sh"
BASE=832ba6a53d6a76706b5c80bce2278683dea33d42
TREE=""; ONLY="."; RECEIPT="$here/controls-run.txt"
while [ $# -gt 0 ]; do
  case $1 in
    --tree) TREE=${2:?}; shift 2 ;;
    --only) ONLY=${2:?}; shift 2 ;;
    --receipt) RECEIPT=${2:?}; shift 2 ;;
    *) echo "usage: controls.sh --tree DIR [--only ERE] [--receipt PATH]" >&2; exit 2 ;;
  esac
done
[ -f "$C1" ] || { echo "SETUP counter missing: $C1" >&2; exit 2; }
[ -n "$TREE" ] && [ -d "$TREE" ] || { echo "SETUP --tree DIR required" >&2; exit 2; }
TREE=$(cd "$TREE" && pwd -P)
[ -f "$TREE/corpus/recheck-captures.tsv" ] || { echo "SETUP tree lacks corpus/recheck-captures.tsv: $TREE" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "SETUP no-python3" >&2; exit 2; }

SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/R56ExecControls/run.$$
mkdir -p -- "$SCR/out" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
REFCOPY=$SCR/ref
mkdir -p -- "$REFCOPY"

# one snapshot of the reference overlay; every control copies from this snapshot so a
# mid-run lane edit cannot make controls inconsistent
if [ "$(git -C "$TREE" rev-parse --show-toplevel 2>/dev/null)" = "$TREE" ]; then
  (cd "$TREE" && git ls-files -co --exclude-standard -z | tar --null -T - -cf -) | tar -x -C "$REFCOPY" || exit 2
else
  cp -a "$TREE"/. "$REFCOPY"/ || exit 2
fi

py() { python3 -I -B -c "$1" "${@:2}"; }
C1SHA=$(sha256sum "$C1" | cut -d' ' -f1)
guard_counter() { # the counter is executed live from the lane; abort if it changes mid-run
  local h
  h=$(sha256sum "$C1" | cut -d' ' -f1)
  if [ "$h" != "$C1SHA" ]; then
    echo "COUNTER-CHANGED-MIDRUN $C1SHA -> $h" | tee -a "$RECEIPT" >&2
    exit 3
  fi
}
sub() { # FILE OLD NEW  (literal first replace; must change the file)
  py 'import sys
p,old,new=sys.argv[1],sys.argv[2],sys.argv[3]
s=open(p,encoding="utf-8").read(); t=s.replace(old,new,1)
assert t!=s, "sub-no-change:"+p
open(p,"w",encoding="utf-8").write(t)' "$@"
}
mrow() { # TREE ID COL NEWVAL  (0-based column of the manifest row)
  py 'import sys
tree,sid,col,val=sys.argv[1],sys.argv[2],int(sys.argv[3]),sys.argv[4]
p=tree+"/corpus/recheck-captures.tsv"
ls=open(p,encoding="utf-8").read().splitlines()
hit=0
for i,l in enumerate(ls):
    c=l.split("\t")
    if c and c[0]==sid:
        c[col]=val; ls[i]="\t".join(c); hit+=1
assert hit==1, "row %s hit=%d"%(sid,hit)
open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n")' "$@"
}
fixdigest() { # TREE ID -- recompute bytes+sha256 of the row from its body file
  py 'import sys,hashlib
tree,sid=sys.argv[1],sys.argv[2]
p=tree+"/corpus/recheck-captures.tsv"
ls=open(p,encoding="utf-8").read().splitlines(); hdr=None; done=0
for i,l in enumerate(ls):
    c=l.split("\t")
    if hdr is None: hdr=c; continue
    if c and c[0]==sid:
        d=open(tree+"/"+c[2],"rb").read()
        c[5]=str(len(d)); c[6]=hashlib.sha256(d).hexdigest()
        ls[i]="\t".join(c); done=1
assert done==1
open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n")' "$@"
}
BODY=.ufo/waves/round-56/capture

mk() { mkdir -p -- "$SCR/c/$1" && cp -a --reflink=auto "$REFCOPY"/. "$SCR/c/$1"/ ; }

run_tree() { # ID DIR -> sets GOTRC GOTLINE OUT
  guard_counter || return 3
  OUT=$SCR/out/$1.txt
  HYAKU_SCRATCH=$SCR bash "$C1" --tree "$2" > "$OUT" 2>&1
  GOTRC=$?
  GOTLINE=$(grep '^C1_REPLAY:' "$OUT" | tail -n 1)
}
run_rev() { # ID REV
  guard_counter || return 3
  OUT=$SCR/out/$1.txt
  HYAKU_SCRATCH=$SCR bash "$C1" "$2" > "$OUT" 2>&1
  GOTRC=$?
  GOTLINE=$(grep '^C1_REPLAY:' "$OUT" | tail -n 1)
}

M=0; K=0
report() { # ID EXPECT_RC EXPECT_ERE
  local id=$1 erc=$2 ere=$3 ok=0
  if [ "$GOTRC" = "$erc" ] && [ -n "$GOTLINE" ] && printf '%s\n' "$GOTLINE" | grep -E -q -- "$ere"; then ok=1; fi
  if [ "$ok" = 1 ]; then M=$((M+1)); st=MATCH; else K=$((K+1)); st=MISMATCH; fi
  printf 'CONTROL %s rc=%s %s\n  expect=%s\n  got=%s\n' "$id" "$GOTRC" "$st" "$ere" "$GOTLINE" >> "$RECEIPT"
  printf 'CONTROL %s rc=%s %s expect=%s got=%s\n' "$id" "$GOTRC" "$st" "$ere" "$GOTLINE"
  if [ "$st" = MISMATCH ]; then
    { echo "  --- counter output for $id ---"; sed 's/^/  | /' "$OUT"; } >> "$RECEIPT"
  fi
}

: > "$RECEIPT" || exit 2
{
  echo "# R56ExecControls prefreeze controls receipt"
  echo "started: $(date -Is)"
  echo "reference-tree: $TREE"
  echo "counter: $C1"
  echo "counter-sha256: $(sha256sum "$C1" | cut -d' ' -f1)"
  echo "gate-sha256: $(sha256sum "$REFCOPY/corpus/recheck-replay.py" | cut -d' ' -f1)"
  echo "manifest-sha256: $(sha256sum "$REFCOPY/corpus/recheck-captures.tsv" | cut -d' ' -f1)"
  echo "controls-sha256(self): $(sha256sum "$0" | cut -d' ' -f1)"
  echo "BASE: $BASE"
} >> "$RECEIPT"

## C01 -- BASE/no-work: the landing is absent at BASE; no clock can replay; guard
##   holds (all 10 clocks PRESENT at BASE, no gate to selftest) so value = replayed = 0.
run_rev C01-BASE-no-work "$BASE"
report C01-BASE-no-work 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad='

## C02 -- positive reference: unmutated landing scores the target.
mk C02-REF-positive; run_tree C02-REF-positive "$SCR/c/C02-REF-positive"
report C02-REF-positive 0 '^C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 \(bad=none\)$'

# ---- r1 family: the entry must still state the BASE clock ----

## C03 -- clock deleted (recheck line kept, backticked clock gone): PRESENT fails,
##   guard drops. The gate's own population shrinks to 9 MATCHing clocks, but the
##   counter's gate verdict demands the exact CLEAN(clocks=10 match=10) shape, so
##   the gate field reads 0 and replayed collapses to 0.
mk C03-R1-clock-deleted
py 'import sys,re
p=sys.argv[1]+"/corpus/knowledge/betterleaks-detection-vs-validation.md"
s=open(p,encoding="utf-8").read()
t=re.sub(r"(?m)^recheck:.*$","recheck: 180d — clock withdrawn this round, see the live page",s,count=1)
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/c/C03-R1-clock-deleted"
run_tree C03-R1-clock-deleted "$SCR/c/C03-R1-clock-deleted"
report C03-R1-clock-deleted 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C04 -- stated N restated 1->2 without touching the capture: PRESENT fails (BASE N
##   pinned), and the gate itself reports MISMATCH against its stated 2.
mk C04-R1-N-restated
sub "$SCR/c/C04-R1-N-restated/corpus/knowledge/betterleaks-detection-vs-validation.md" \
  "provider requests by default'\` -> 1" "provider requests by default'\` -> 2"
run_tree C04-R1-N-restated "$SCR/c/C04-R1-N-restated"
report C04-R1-N-restated 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C41 -- N-boundary underscore encoding (R56ReviewCounter G2 regression witness):
##   stated N restated to `-> 1_0`. Epoch C's `(?![0-9A-Za-z])` boundary READ this
##   as a stated 1 (underscore passed the boundary) and scored; epoch D's
##   `(?![0-9A-Za-z_.])` must fail PRESENT -> absent -> FAIL. The gate's own
##   CLOCK_RE still parses stated=1 and MATCHes the capture, so the gate stays
##   CLEAN(clocks=10 match=10) and the nine present clocks replay.
mk C41-R1-N-boundary-underscore
sub "$SCR/c/C41-R1-N-boundary-underscore/corpus/knowledge/betterleaks-detection-vs-validation.md" \
  "provider requests by default'\` -> 1 (ran 2026-10-23)" "provider requests by default'\` -> 1_0 (ran 2026-10-23)"
run_tree C41-R1-N-boundary-underscore "$SCR/c/C41-R1-N-boundary-underscore"
report C41-R1-N-boundary-underscore 0 '^C1_REPLAY: value=FAIL present=9 replayed=9 gate=1 guard=0 \(bad=absent:'

## C05 -- command text retexted inside the backticks (-fsSL -> -fsSLX): PRESENT fails;
##   the gate cannot parse the mutated clock -> UNSUPPORTED -> DRIFT.
mk C05-R1-command-retexted
sub "$SCR/c/C05-R1-command-retexted/corpus/knowledge/betterleaks-detection-vs-validation.md" \
  "curl -fsSL 'https://raw.githubusercontent.com/betterleaks" "curl -fsSLX 'https://raw.githubusercontent.com/betterleaks"
run_tree C05-R1-command-retexted "$SCR/c/C05-R1-command-retexted"
report C05-R1-command-retexted 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C06 -- clock restated as a second column-1 recheck line (byte-identical clock):
##   PRESENT demands exactly one recheck line; the gate population grows to 11
##   MATCHing clocks, and the exact CLEAN(clocks=10 match=10) shape check makes the
##   gate field read 0, so replayed collapses to 0.
mk C06-R1-second-clock-line
printf '%s\n' "recheck: 180d — \`curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -c 'Scans detect secrets without credential provider requests by default'\` -> 1 (restated duplicate)" >> "$SCR/c/C06-R1-second-clock-line/corpus/knowledge/betterleaks-detection-vs-validation.md"
run_tree C06-R1-second-clock-line "$SCR/c/C06-R1-second-clock-line"
report C06-R1-second-clock-line 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C07 -- recheck line indented off column 1: PRESENT fails; the gate never sees the
##   clock (column-1 rule) and reports CLEAN over 9 clocks, but the exact
##   CLEAN(clocks=10 match=10) shape check makes the gate field read 0.
mk C07-R1-recheck-indented
py 'import sys,re
p=sys.argv[1]+"/corpus/knowledge/betterleaks-detection-vs-validation.md"
s=open(p,encoding="utf-8").read()
t=re.sub(r"(?m)^recheck:"," recheck:",s,count=1)
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/c/C07-R1-recheck-indented"
run_tree C07-R1-recheck-indented "$SCR/c/C07-R1-recheck-indented"
report C07-R1-recheck-indented 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

# ---- r2 family: manifest/registry binding ----

## C08 -- manifest absent: counter reads r2 as unsatisfied for every clock (value 0,
##   guard holds); the gate SETUPs, so gate=0.
mk C08-R2-manifest-absent; rm "$SCR/c/C08-R2-manifest-absent/corpus/recheck-captures.tsv"
run_tree C08-R2-manifest-absent "$SCR/c/C08-R2-manifest-absent"
report C08-R2-manifest-absent 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-manifest:'

## C09 -- one manifest row dropped: that clock loses its capture (r2-rows0); the gate
##   reports NO-CAPTURE -> DRIFT.
mk C09-R2-row-missing
py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"
ls=[l for l in open(p,encoding="utf-8").read().splitlines() if not l.startswith("S054\t")]
assert len(ls)>0; open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n")' "$SCR/c/C09-R2-row-missing"
run_tree C09-R2-row-missing "$SCR/c/C09-R2-row-missing"
report C09-R2-row-missing 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C10 -- byte-identical duplicate manifest row: epoch C's manifest bijection on
##   body_path+sha256 fail-closes the whole manifest (the duplicate row reuses both),
##   so the reading is r2-manifest-malformed for every clock; gate SETUPs on the
##   duplicate URL as before.
mk C10-R2-row-duplicate
py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"
ls=open(p,encoding="utf-8").read().splitlines()
row=[l for l in ls if l.startswith("S054\t")]; assert len(row)==1
open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n"+row[0]+"\n")' "$SCR/c/C10-R2-row-duplicate"
run_tree C10-R2-row-duplicate "$SCR/c/C10-R2-row-duplicate"
report C10-R2-row-duplicate 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-manifest-malformed:'

## C11 -- URL swap: the S054/S055 rows exchange urls. Both URLs stay unique, so the
##   manifest parses; both clocks fail r2-registry (the id's registry row no longer
##   carries the clock's URL); the other 8 clocks replay. Gate: BAD-CAPTURE x2.
mk C11-R2-url-swap
mrow "$SCR/c/C11-R2-url-swap" S054 1 "https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md"
mrow "$SCR/c/C11-R2-url-swap" S055 1 "https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md"
run_tree C11-R2-url-swap "$SCR/c/C11-R2-url-swap"
report C11-R2-url-swap 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-registry:'

## C12 -- manifest id dangles (S054 -> S999): r2-registry for that clock; gate
##   BAD-CAPTURE not-a-registry-row.
mk C12-R2-manifest-id-dangle
mrow "$SCR/c/C12-R2-manifest-id-dangle" S054 0 S999
run_tree C12-R2-manifest-id-dangle "$SCR/c/C12-R2-manifest-id-dangle"
report C12-R2-manifest-id-dangle 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C13 -- registry row status minted (mined -> minted, cell 8 of 11): the counter's
##   11-cell mined check fails for that clock; the gate does not check status, so the
##   gate stays CLEAN (binding asymmetry the counter must carry alone).
mk C13-R2-registry-status-minted
py 'import sys
p=sys.argv[1]+"/corpus/SOURCES.md"
ls=open(p,encoding="utf-8").read().splitlines(); done=0
for i,l in enumerate(ls):
    cells=[x.strip() for x in l.strip().strip("|").split("|")]
    if cells and cells[0]=="S054":
        assert cells.count("mined")==1 and len(cells)==11
        cells[cells.index("mined")]="minted"
        ls[i]="| "+" | ".join(cells)+" |"; done=1
assert done==1
open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n")' "$SCR/c/C13-R2-registry-status-minted"
run_tree C13-R2-registry-status-minted "$SCR/c/C13-R2-registry-status-minted"
report C13-R2-registry-status-minted 0 '^C1_REPLAY: value=9 present=10 replayed=9 gate=1 guard=1 \(bad=r2-registry:'

## C36 -- duplicate manifest id over a fresh non-clock URL REUSING S054's body_path
##   and sha256: the 096251c9-era counter tolerated it (value=10, tolerance
##   witness); epoch C fail-closes the whole manifest on a shared body_path or
##   sha256, so the reading must now be value=0 via r2-manifest-malformed (regression
##   witness for the row-uniqueness binding).
mk C36-R2-duplicate-id-other-url
py 'import sys,hashlib
tree=sys.argv[1]
b=open(tree+"/.ufo/waves/round-56/capture/S054.body","rb").read()
row="\t".join(["S054","https://example.invalid/round-56-controls-c36",
  ".ufo/waves/round-56/capture/S054.body","2026-11-07","200",str(len(b)),
  hashlib.sha256(b).hexdigest()])
p=tree+"/corpus/recheck-captures.tsv"
s=open(p,encoding="utf-8").read()
assert "example.invalid" not in s
open(p,"w",encoding="utf-8").write(s+row+"\n")' "$SCR/c/C36-R2-duplicate-id-other-url"
run_tree C36-R2-duplicate-id-other-url "$SCR/c/C36-R2-duplicate-id-other-url"
report C36-R2-duplicate-id-other-url 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-manifest-malformed:'

## C42 -- calendar-invalid fetched date (R56MutCounter-2 m31 regression witness,
##   independent of their F28: different row, impossible-not-just-malformed date):
##   S055 row's fetched set to `2026-02-30` -- matches the epoch-E shape regex but
##   datetime.date.fromisoformat refuses it. Epoch F must fail-close the whole
##   manifest: r2-manifest-malformed for every clock; gate SETUPs likewise.
mk C42-R2-fetched-calendar-invalid
mrow "$SCR/c/C42-R2-fetched-calendar-invalid" S055 3 "2026-02-30"
run_tree C42-R2-fetched-calendar-invalid "$SCR/c/C42-R2-fetched-calendar-invalid"
report C42-R2-fetched-calendar-invalid 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-manifest-malformed:'

# ---- r3 family: body confinement and digest ----

## C14 -- body tampered, manifest stale: r3-digest; gate BAD-CAPTURE sha256.
mk C14-R3-body-tampered
printf 'x' >> "$SCR/c/C14-R3-body-tampered/$BODY/S054.body"
run_tree C14-R3-body-tampered "$SCR/c/C14-R3-body-tampered"
report C14-R3-body-tampered 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C15 -- NAMED CEILING witness: body tampered AND manifest restated to match
##   (self-consistent hand-written capture). The appended byte does not move the
##   filter count, so the frozen predicate scores it 10 by design; this control pins
##   that the ceiling is real, not an accident.
mk C15-R3-ceiling-handwritten-capture
printf 'x' >> "$SCR/c/C15-R3-ceiling-handwritten-capture/$BODY/S054.body"
fixdigest "$SCR/c/C15-R3-ceiling-handwritten-capture" S054
run_tree C15-R3-ceiling-handwritten-capture "$SCR/c/C15-R3-ceiling-handwritten-capture"
report C15-R3-ceiling-handwritten-capture 0 '^C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 \(bad=none\)$'

## C16 -- capture body replaced by a symlink to a file outside the capture dir:
##   r3 confinement (no symlinked component); gate BAD-CAPTURE symlink.
mk C16-R3-body-symlink
mv "$SCR/c/C16-R3-body-symlink/$BODY/S055.body" "$SCR/c/C16-R3-body-symlink/s055.outside"
ln -s ../../../../s055.outside "$SCR/c/C16-R3-body-symlink/$BODY/S055.body"
run_tree C16-R3-body-symlink "$SCR/c/C16-R3-body-symlink"
report C16-R3-body-symlink 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r3-file:'

## C17 -- header bytes smuggled into a body WITH the manifest restated, so only the
##   QM72 rule is exercised (digest first would mask it): r3-headers; gate
##   BAD-CAPTURE header-bytes.
mk C17-R3-header-bytes-digest-fixed
{ printf 'HTTP/2 200\r\nset-cookie: k=v\r\n\r\n'; cat "$SCR/c/C17-R3-header-bytes-digest-fixed/$BODY/S057.body"; } > "$SCR/c/C17-R3-header-bytes-digest-fixed/h.body"
mv "$SCR/c/C17-R3-header-bytes-digest-fixed/h.body" "$SCR/c/C17-R3-header-bytes-digest-fixed/$BODY/S057.body"
fixdigest "$SCR/c/C17-R3-header-bytes-digest-fixed" S057
run_tree C17-R3-header-bytes-digest-fixed "$SCR/c/C17-R3-header-bytes-digest-fixed"
report C17-R3-header-bytes-digest-fixed 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C40 -- canonical-case header smuggling (R56MutCounter F9 / ReviewCounter G1
##   regression witness): S057.body prepended with `HTTP/2 200` and CAPITALISED
##   `Set-Cookie:` with the manifest restated, so only the case rule is exercised.
##   Epoch C's `(?m)`-only regex PASSED this (the hole); epoch D's `(?im)` must
##   refuse it: r3-headers on the trufflehog clock, gate BAD-CAPTURE -> DRIFT.
mk C40-R3-header-case-canonical
{ printf 'HTTP/2 200\r\nSet-Cookie: k=v\r\n\r\n'; cat "$SCR/c/C40-R3-header-case-canonical/$BODY/S057.body"; } > "$SCR/c/C40-R3-header-case-canonical/h.body"
mv "$SCR/c/C40-R3-header-case-canonical/h.body" "$SCR/c/C40-R3-header-case-canonical/$BODY/S057.body"
fixdigest "$SCR/c/C40-R3-header-case-canonical" S057
run_tree C40-R3-header-case-canonical "$SCR/c/C40-R3-header-case-canonical"
report C40-R3-header-case-canonical 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C18 -- body file deleted, manifest row intact: r3-file (body-missing); gate
##   BAD-CAPTURE body-missing.
mk C18-R3-body-absent; rm "$SCR/c/C18-R3-body-absent/$BODY/S070.body"
run_tree C18-R3-body-absent "$SCR/c/C18-R3-body-absent"
report C18-R3-body-absent 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C34 -- bytes column lowered by one, body untouched: r3-digest via the bytes check;
##   gate BAD-CAPTURE bytes.
mk C34-R3-bytes-col-tampered
mrow "$SCR/c/C34-R3-bytes-col-tampered" S074 5 45350
run_tree C34-R3-bytes-col-tampered "$SCR/c/C34-R3-bytes-col-tampered"
report C34-R3-bytes-col-tampered 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C35 -- sha256 columns of two rows exchanged: two clocks fail r3-digest; gate
##   BAD-CAPTURE sha256 x2.
mk C35-R3-sha-col-swap
py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"
ls=open(p,encoding="utf-8").read().splitlines()
ia=ib=None
for i,l in enumerate(ls):
    if l.startswith("S067\t"): ia=i
    if l.startswith("S070\t"): ib=i
assert ia is not None and ib is not None
ca=ls[ia].split("\t"); cb=ls[ib].split("\t")
ca[6],cb[6]=cb[6],ca[6]
ls[ia]="\t".join(ca); ls[ib]="\t".join(cb)
open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n")' "$SCR/c/C35-R3-sha-col-swap"
run_tree C35-R3-sha-col-swap "$SCR/c/C35-R3-sha-col-swap"
report C35-R3-sha-col-swap 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

# ---- r4 family: the counter's own replay ----

## C19 -- filter drained: the stated pattern removed from the S067 body with the
##   manifest restated, so r3 passes and only the replay can object: r4-replay0 AND
##   gate MISMATCH. Guard holds (P=10, selftest ok) so value reads 9.
mk C19-R4-body-filter-drained
sub "$SCR/c/C19-R4-body-filter-drained/$BODY/S067.body" \
  "It MUST contain the OAuth 2.0" "It MUST contain the OAumh 2.0"
fixdigest "$SCR/c/C19-R4-body-filter-drained" S067
run_tree C19-R4-body-filter-drained "$SCR/c/C19-R4-body-filter-drained"
report C19-R4-body-filter-drained 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

## C20 -- changed normaliser: the measured tree's rendered-text-v1.py is replaced by
##   a lying stub (count=7). The counter judges the locate clock with BASE's
##   normaliser (r4 passes) but the frozen epoch-C gate pins the normaliser bytes
##   AND its selftest exercises the tree's own copy, so the gate refuses and the
##   selftest conjunct fails: guard drops, value=FAIL, every clock fails r5.
mk C20-R4-normaliser-lying-stub
printf 'import sys\nsys.stdout.write("RENDERED_TEXT_V1_LOCATE: count=7\\n")\n' > "$SCR/c/C20-R4-normaliser-lying-stub/corpus/rendered-text-v1.py"
run_tree C20-R4-normaliser-lying-stub "$SCR/c/C20-R4-normaliser-lying-stub"
report C20-R4-normaliser-lying-stub 0 '^C1_REPLAY: value=FAIL present=10 replayed=0 gate=0 guard=0 \(bad=r5-gate:'

## C21 -- unsupported filter form restated as a second clock line: PRESENT fails
##   (two recheck lines) and the gate hits UNSUPPORTED -> DRIFT.
mk C21-R4-unsupported-second-clock
printf '%s\n' "recheck: 180d — \`curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | sed -n 1p | grep -c 'Scans detect'\` -> 1 (unsupported form)" >> "$SCR/c/C21-R4-unsupported-second-clock/corpus/knowledge/betterleaks-detection-vs-validation.md"
run_tree C21-R4-unsupported-second-clock "$SCR/c/C21-R4-unsupported-second-clock"
report C21-R4-unsupported-second-clock 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C38 -- malformed capture body: S078.body truncated to 10 bytes with the manifest
##   restated, so only the pdftotext stage can object: the replay is unusable
##   (r4-replayNone or r4-replay0) and the gate reports TOOL or MISMATCH -> DRIFT.
mk C38-FC-malformed-capture-body-pdf
py 'import sys
p=sys.argv[1]+"/.ufo/waves/round-56/capture/S078.body"
d=open(p,"rb").read()[:10]
open(p,"wb").write(d)' "$SCR/c/C38-FC-malformed-capture-body-pdf"
fixdigest "$SCR/c/C38-FC-malformed-capture-body-pdf" S078
run_tree C38-FC-malformed-capture-body-pdf "$SCR/c/C38-FC-malformed-capture-body-pdf"
report C38-FC-malformed-capture-body-pdf 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

# ---- r5/guard family: the measured gate's own verdict ----

## C22 -- printer gate (python, prints CLEAN + PASS lines): the digest pin fires
##   first (printer bytes != GATE_SHA256_PIN), and since epoch C a present-but-
##   unpinned gate also forces SELF_OK=0, so guard drops and the reading is FAIL.
mk C22-R5-gate-printer-clean-only
cat > "$SCR/c/C22-R5-gate-printer-clean-only/corpus/recheck-replay.py" <<'PRINTER'
import sys
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (14 cases)"); sys.exit(0)
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
PRINTER
run_tree C22-R5-gate-printer-clean-only "$SCR/c/C22-R5-gate-printer-clean-only"
report C22-R5-gate-printer-clean-only 0 '^C1_REPLAY: value=FAIL present=10 replayed=0 gate=0 guard=0 \(bad=r5-gate:'

## C23 -- full gate forgery: a python printer that also fabricates the ten MATCH
##   lines from public knowledge (POP x manifest ids) and ends CLEAN. Against the
##   096251c9 draft this scored value=10 (gate stdout trusted, no identity
##   binding); since the pinned-digest repair it must read like any other gate
##   edit, and epoch C additionally drops guard (present-but-unpinned -> SELF_OK=0):
##   value=FAIL, gate=0, guard=0. Regression witness for the forgery hole.
mk C23-R5-gate-printer-forged-match
cat > "$SCR/c/C23-R5-gate-printer-forged-match/corpus/recheck-replay.py" <<'PRINTER'
import sys
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (14 cases)"); sys.exit(0)
ROWS = [
 ("corpus/knowledge/betterleaks-detection-vs-validation.md", 4, "S055", "grep", 1),
 ("corpus/knowledge/cdp-bridge-1password-oidc-workflow.md", 3, "S070", "locate", 1),
 ("corpus/knowledge/iso-11770-3-edition-status.md", 3, "S101", "grep", 2),
 ("corpus/knowledge/iso-11770-3-edition-status.md", 3, "S113", "grep", 3),
 ("corpus/knowledge/iso-11770-3-edition-status.md", 3, "S114", "grep", 2),
 ("corpus/knowledge/nist-key-management-guidance-status.md", 3, "S074", "grep", 1),
 ("corpus/knowledge/nist-key-management-parts-withdrawal.md", 3, "S078", "pdf", 1),
 ("corpus/knowledge/oidc-federation-trust-policy.md", 3, "S067", "grep", 1),
 ("corpus/knowledge/secret-scanning-detection-vs-validation.md", 4, "S054", "grep", 1),
 ("corpus/knowledge/trufflehog-verification-lifecycle.md", 4, "S057", "grep", 1),
]
for rel, ln, sid, form, n in ROWS:
    print("MATCH %s:%d id=%s form=%s stated=%d replayed=%d" % (rel, ln, sid, form, n, n))
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
PRINTER
run_tree C23-R5-gate-printer-forged-match "$SCR/c/C23-R5-gate-printer-forged-match"
report C23-R5-gate-printer-forged-match 0 '^C1_REPLAY: value=FAIL present=10 replayed=0 gate=0 guard=0 \(bad=r5-gate:'

## C24 -- selftest line edited (PASS -> FAILX inside the pinned gate's bytes): any
##   byte edit breaks the digest pin, and epoch C forces SELF_OK=0 for a present-
##   but-unpinned gate, so guard drops: value=FAIL, gate=0, guard=0. The selftest
##   verdict itself is reachable only for a digest-matching gate (environment guard).
mk C24-R5-selftest-broken
sub "$SCR/c/C24-R5-selftest-broken/corpus/recheck-replay.py" \
  "RECHECK_REPLAY_SELFTEST: PASS" "RECHECK_REPLAY_SELFTEST: FAILX"
run_tree C24-R5-selftest-broken "$SCR/c/C24-R5-selftest-broken"
report C24-R5-selftest-broken 0 '^C1_REPLAY: value=FAIL present=10 replayed=0 gate=0 guard=0 \(bad=r5-gate:'

## C25 -- gate absent: counter reads the empty producer as not-CLEAN (r5 fails for
##   every clock); no selftest to fail, so guard holds and value reads 0 -- the same
##   reading as BASE, not FAIL.
mk C25-R5-gate-absent; rm "$SCR/c/C25-R5-gate-absent/corpus/recheck-replay.py"
run_tree C25-R5-gate-absent "$SCR/c/C25-R5-gate-absent"
report C25-R5-gate-absent 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r5-gate:'

# ---- fail-closed family ----

## C26 -- SETUP: --tree at a nonexistent directory must exit 2 before any scratch use.
run_tree C26-FC-setup-bad-tree "$SCR/no-such-dir"
report C26-FC-setup-bad-tree 2 '^C1_REPLAY: SETUP tree$'

## C27 -- the whole round-56 capture directory deleted: the seven new-URL clocks lose
##   their bodies (r3-file), the three reused captures still replay; gate DRIFT.
mk C27-FC-capture-dir-deleted; rm -rf "$SCR/c/C27-FC-capture-dir-deleted/$BODY"
run_tree C27-FC-capture-dir-deleted "$SCR/c/C27-FC-capture-dir-deleted"
report C27-FC-capture-dir-deleted 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r3-file:'

## C28 -- malformed manifest header (sha256 column renamed): the manifest reads as
##   unusable for the counter and the gate SETUPs; value 0, guard holds.
mk C28-FC-manifest-header-malformed
py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"
s=open(p,encoding="utf-8").read()
t=s.replace("\tsha256\n","\tsha\n",1)
assert t!=s, "header-rename-no-change"
open(p,"w",encoding="utf-8").write(t)' "$SCR/c/C28-FC-manifest-header-malformed"
run_tree C28-FC-manifest-header-malformed "$SCR/c/C28-FC-manifest-header-malformed"
report C28-FC-manifest-header-malformed 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-manifest:'

## C29 -- malformed manifest row (S101 row shortened to 6 columns): the counter's
##   parser SKIPS the wrong-width row silently (the gate SETUPs on it), so the
##   iso:60237 clock reads r2-rows0 while every other clock dies on the gate's DRIFT;
##   value fields match C28, the bad tokens do not.
mk C29-FC-manifest-row-malformed
py 'import sys
p=sys.argv[1]+"/corpus/recheck-captures.tsv"
ls=open(p,encoding="utf-8").read().splitlines()
for i,l in enumerate(ls):
    if l.startswith("S101\t"):
        c=l.split("\t")[:-1]; assert len(c)==6
        ls[i]="\t".join(c)
open(p,"w",encoding="utf-8").write("\n".join(ls)+"\n")' "$SCR/c/C29-FC-manifest-row-malformed"
run_tree C29-FC-manifest-row-malformed "$SCR/c/C29-FC-manifest-row-malformed"
report C29-FC-manifest-row-malformed 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-manifest-malformed:'

## C30 -- knowledge entry deleted (the ISO entry carries 3 clocks): P=7 -> guard 0 ->
##   FAIL; the gate reports CLEAN over its 7-clock population, so the exact
##   CLEAN(clocks=10 match=10) shape check makes the gate field read 0, and the
##   five PRESENT clocks processed before the ISO entry fail r5 first: the bad list
##   opens with r5-gate, not absent.
mk C30-FC-entry-absent; rm "$SCR/c/C30-FC-entry-absent/corpus/knowledge/iso-11770-3-edition-status.md"
run_tree C30-FC-entry-absent "$SCR/c/C30-FC-entry-absent"
report C30-FC-entry-absent 0 '^C1_REPLAY: value=FAIL present=7 replayed=0 gate=0 guard=0 \(bad=r5-gate:'

## C31 -- registry absent: every clock fails r2-registry (value 0, guard holds); the
##   gate refuses the tree outright (not-a-lane-tree SETUP) so gate=0.
mk C31-FC-registry-absent; rm "$SCR/c/C31-FC-registry-absent/corpus/SOURCES.md"
run_tree C31-FC-registry-absent "$SCR/c/C31-FC-registry-absent"
report C31-FC-registry-absent 0 '^C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 \(bad=r2-registry:'

## C32 -- restatement done "properly": stated N 1->2 AND the capture re-forged to
##   carry two matches AND the manifest restated, so the gate MATCHes its own 9-clock
##   population -- but the exact CLEAN(clocks=10 match=10) shape check makes the gate
##   field read 0, and PRESENT pins the BASE N, so guard drops: FAIL, replayed=0.
mk C32-FC-restated-with-fresh-capture
sub "$SCR/c/C32-FC-restated-with-fresh-capture/corpus/knowledge/betterleaks-detection-vs-validation.md" \
  "provider requests by default'\` -> 1" "provider requests by default'\` -> 2"
printf 'Scans detect secrets without credential provider requests by default\n' >> "$SCR/c/C32-FC-restated-with-fresh-capture/$BODY/S054.body"
fixdigest "$SCR/c/C32-FC-restated-with-fresh-capture" S054
run_tree C32-FC-restated-with-fresh-capture "$SCR/c/C32-FC-restated-with-fresh-capture"
report C32-FC-restated-with-fresh-capture 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C33 -- knowledge entry replaced by a symlink: PRESENT refuses symlinked reads ->
##   FAIL; the repaired gate reports the symlinked entry as an UNSUPPORTED clock
##   row, so the gate cannot go CLEAN either (blind spot closed; the 096251c9-era
##   gate stayed CLEAN here). replayed therefore reads 0, not 9.
mk C33-FC-entry-symlink
mv "$SCR/c/C33-FC-entry-symlink/corpus/knowledge/betterleaks-detection-vs-validation.md" "$SCR/c/C33-FC-entry-symlink/e.md"
ln -s ../../e.md "$SCR/c/C33-FC-entry-symlink/corpus/knowledge/betterleaks-detection-vs-validation.md"
run_tree C33-FC-entry-symlink "$SCR/c/C33-FC-entry-symlink"
report C33-FC-entry-symlink 0 '^C1_REPLAY: value=FAIL present=9 replayed=0 gate=0 guard=0 \(bad=absent:'

## C37 -- knowledge directory deleted entirely: every clock absent -> FAIL present=0;
##   the gate SETUPs (not-a-lane-tree).
mk C37-FC-knowledge-dir-absent; rm -rf "$SCR/c/C37-FC-knowledge-dir-absent/corpus/knowledge"
run_tree C37-FC-knowledge-dir-absent "$SCR/c/C37-FC-knowledge-dir-absent"
report C37-FC-knowledge-dir-absent 0 '^C1_REPLAY: value=FAIL present=0 replayed=0 gate=0 guard=0 \(bad=absent:'

## C39 -- SETUP: no python3 on PATH must exit 2 with SETUP no-python3 before any
##   scratch or repo access (env -i, absolute bash; no inherited PATH).
OUT=$SCR/out/C39-FC-setup-no-tools.txt
env -i PATH=/nonexistent HYAKU_SCRATCH=$SCR /bin/bash "$C1" --tree "$REFCOPY" > "$OUT" 2>&1
GOTRC=$?
GOTLINE=$(grep '^C1_REPLAY:' "$OUT" | tail -n 1)
report C39-FC-setup-no-tools 2 '^C1_REPLAY: SETUP no-python3$'

echo "CONTROLS: total=$((M+K)) match=$M mismatch=$K" | tee -a "$RECEIPT"
{
  echo "finished: $(date -Is)"
  echo "controls-sha256(self,post-run): $(sha256sum "$0" | cut -d' ' -f1)"
} >> "$RECEIPT"
[ "$K" = 0 ]
