#!/usr/bin/env bash
# plans/round-53-controls.sh — pre-freeze controls for the frozen round-53 counters.
# Each control builds a fixture tree from BASE (git archive) plus the edit named on its line, runs
# the counter with --tree, and compares the printed value= (or SETUP) with the expectation written
# here before the run. Prints `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH` and a summary line.
# C1 reference fixture: .ufo/waves/round-53/controls/fixtures/ref/c1/ (overlay onto BASE).
# C2 reference edit: the four count replacements in c2_ref below (SKILL.md, PROVINCE.md, README.md).
# Usage: bash plans/round-53-controls.sh [c1|c2|all]
set -u
LANE=$(cd "$(dirname "$0")/.." && pwd)
BASE_REV=c1953d4afc19a5a336a58685c00ab5260bcfea1c
REF="$LANE/.ufo/waves/round-53/controls/fixtures/ref/c1"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r53"
mkdir -p "$SCR"
W=$(mktemp -d "$SCR/controls.XXXXXX") || exit 2
trap 'rm -rf -- "$W"' EXIT
WHICH="${1:-all}"
ok=0; bad=0
export C1_ASOF; C1_ASOF=$(date -u +%s)

mk() { local d="$W/$1"; mkdir -p "$d"; git -C "$LANE" archive "$BASE_REV" | tar -x -C "$d"; echo "$d"; }
c1_ref() { cp -a "$REF"/. "$1"/; }
c2_ref() { # dir: the C2 change only (four stated counts)
  python3 - "$1" <<'PY'
import sys
from pathlib import Path
d = Path(sys.argv[1])
def rep(path, old, new):
    p = d / path; t = p.read_text(encoding="utf-8")
    assert t.count(old) == 1, (path, old)
    p.write_text(t.replace(old, new), encoding="utf-8")
rep("SKILL.md", "`bash corpus/claim-ledger.sh verify` (124 stamps + 86 claims", "`bash corpus/claim-ledger.sh verify` (125 stamps + 86 claims")
rep("PROVINCE.md", "`verify` (124 revision stamps + 86 claim rows", "`verify` (125 revision stamps + 86 claim rows")
rep("corpus/README.md", "| 124 rows (round 49:", "| 125 rows (round 53: corrected from 124; round 49:")
rep("corpus/README.md", "one `Reverify:` line per entry: 33 row-linked / 3 by-hand / 36 pinned (round 49:", "one `Reverify:` line per entry: 34 row-linked / 3 by-hand / 37 pinned (round 53: corrected from 33/3/36; round 49:")
PY
}
py_edit() { # dir python-snippet (d = Path(dir))
  python3 - "$1" "$2" <<'PY'
import sys, re, json, hashlib
from pathlib import Path
d = Path(sys.argv[1])
exec(sys.argv[2])
PY
}
val() { sed -n 's/.*: SETUP.*/SETUP/p; s/.*: value=\([0-9]*\).*/\1/p' | head -1; }
check() { # id expect output
  local g; g=$(printf '%s\n' "$3" | val)
  if [ "$g" = "$2" ]; then ok=$((ok+1)); m=MATCH; else bad=$((bad+1)); m=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=$g $m"; echo "  $(printf '%s' "$3" | head -c 700)"
}
C1() { bash "$LANE/plans/round-53-c1.sh" --tree "$1" 2>&1; }
C2() { bash "$LANE/plans/round-53-c2.sh" --tree "$1" 2>&1; }
# clock-table / receipt helpers used by the forgers (re-digest the receipt into line 28)
REDIGEST='
g = d / "corpus/release-clock.py"; r = d / ".ufo/waves/round-53/final/observe-r53.json"
lines = g.read_text(encoding="utf-8").split("\n")
lines[27] = "DEFAULT_RECEIPT_SHA256 = \"%s\"" % hashlib.sha256(r.read_bytes()).hexdigest()
g.write_text("\n".join(lines), encoding="utf-8")
'

if [ "$WHICH" = c1 ] || [ "$WHICH" = all ]; then
  d=$(mk k1-0); check K1-0 0 "$(C1 "$d")"                                    # BASE: 90d cadence, no clocks
  d=$(mk k1-p); c1_ref "$d"; check K1-P 2 "$(C1 "$d")"                       # reference candidate
  d=$(mk k1-f1)                                                              # recheck flipped only
  py_edit "$d" 'p=d/"corpus/SOURCES.md"; t=p.read_text(); t=re.sub(r"(?m)^(\| S10[34] \|.*\| )90d( \| corpus/lessons/round-48\.md \|)$", r"\1on-release\2", t); p.write_text(t)'
  check K1-F1 0 "$(C1 "$d")"
  d=$(mk k1-f2); c1_ref "$d"                                                 # gate replaced by a CLEAN printer
  printf '%s\n' 'print("RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)")' > "$d/corpus/release-clock.py"
  check K1-F2 0 "$(C1 "$d")"
  d=$(mk k1-f3); c1_ref "$d"                                                 # default receipt reverted to round 46
  git -C "$LANE" show "$BASE_REV:corpus/release-clock.py" > "$d/corpus/release-clock.py"
  check K1-F3 0 "$(C1 "$d")"
  d=$(mk k1-f4); c1_ref "$d"                                                 # S104 pinned to an unreleased 1.3.3
  py_edit "$d" 'p=d/"corpus/release-clocks.tsv"; t=p.read_text(); t=t.replace("releases.atom\t1.3.2\t1.3.2\t","releases.atom\t1.3.3\t1.3.3\t"); p.write_text(t)'
  check K1-F4 0 "$(C1 "$d")"
  d=$(mk k1-f5); c1_ref "$d"                                                 # S111 feed row left queued
  py_edit "$d" 'p=d/"corpus/SOURCES.md"; t=p.read_text(); t=re.sub(r"(?m)^(\| S111 \|.*\| )mined( \| 2026-11-07 \|)", r"\1queued\2", t); p.write_text(t)'
  check K1-F5 1 "$(C1 "$d")"
  d=$(mk k1-f6); c1_ref "$d"                                                 # S104 half undone (row 90d, clock row gone)
  py_edit "$d" 'p=d/"corpus/SOURCES.md"; t=p.read_text(); t=re.sub(r"(?m)^(\| S104 \|.*\| )on-release( \|)", r"\g<1>90d\2", t); p.write_text(t); q=d/"corpus/release-clocks.tsv"; q.write_text("".join(l for l in q.read_text().splitlines(True) if not l.startswith("S104\t")))'
  check K1-F6 0 "$(C1 "$d")"
  d=$(mk k1-f7); c1_ref "$d"                                                 # S104 clock bound to the SOPS feed
  py_edit "$d" 'p=d/"corpus/release-clocks.tsv"; t=p.read_text(); t=t.replace("S104\tfeed\tS111\thttps://github.com/FiloSottile/age/releases.atom","S104\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom"); p.write_text(t)'
  check K1-F7 0 "$(C1 "$d")"
  d=$(mk k1-f8); c1_ref "$d"                                                 # S104 observation relabelled 2026-11-06 (table + receipt + digest)
  py_edit "$d" 'r=d/".ufo/waves/round-53/final/observe-r53.json"; j=json.loads(r.read_text()); [o.__setitem__("observed_at","2026-11-06T23:00:00Z") for o in j["observations"] if o["id"]=="S104"]; r.write_text(json.dumps(j, indent=2)+"\n"); p=d/"corpus/release-clocks.tsv"; t=p.read_text().split("\n"); t=[("\t".join(l.split("\t")[:6]+["2026-11-06"]+l.split("\t")[7:]) if l.startswith("S104\t") else l) for l in t]; p.write_text("\n".join(t))'"$REDIGEST"
  check K1-F8 1 "$(C1 "$d")"
  d=$(mk k1-f9); c1_ref "$d"                                                 # S104 registry URL swapped
  py_edit "$d" 'p=d/"corpus/SOURCES.md"; t=p.read_text(); t=t.replace("age release v1.3.2, GitHub release page — https://github.com/FiloSottile/age/releases/tag/v1.3.2","age release v1.3.2, GitHub release page — https://github.com/FiloSottile/age/releases/tag/v1.3.3"); p.write_text(t)'
  check K1-F9 1 "$(C1 "$d")"
  d=$(mk k1-c2); c2_ref "$d"; check K1-C2ONLY 0 "$(C1 "$d")"                # C2 change alone moves nothing in C1
fi

if [ "$WHICH" = c2 ] || [ "$WHICH" = all ]; then
  d=$(mk k2-0); check K2-0 5 "$(C2 "$d")"                                    # BASE: five stale counts
  d=$(mk k2-p); c2_ref "$d"; check K2-P 0 "$(C2 "$d")"                       # reference C2 change
  d=$(mk k2-f1); c2_ref "$d"                                                 # only SKILL.md corrected
  for f in PROVINCE.md corpus/README.md; do git -C "$LANE" show "$BASE_REV:$f" > "$d/$f"; done
  check K2-F1 4 "$(C2 "$d")"
  d=$(mk k2-f2); c2_ref "$d"                                                 # ledger R12-03 command forged to agree
  py_edit "$d" 'p=d/"corpus/claim-ledger.tsv"; t=p.read_text(); t=t.replace("R12-03\tgrep -c '"'"'[^[:space:]]'"'"' corpus/stamps.tsv\t","R12-03\techo 125\t"); p.write_text(t)'
  check K2-F2 SETUP "$(C2 "$d")"
  d=$(mk k2-f3); printf '# emptied\n' > "$d/corpus/self-counts.tsv"           # measured table emptied
  check K2-F3 5 "$(C2 "$d")"
  d=$(mk k2-f4); sed -i '/^corpus\/adjacency\.tsv\t/d' "$d/corpus/stamps.tsv"  # stamp population pruned to 124
  check K2-F4 SETUP "$(C2 "$d")"
  d=$(mk k2-f5)                                                              # the five numbers blanked (locator miss)
  py_edit "$d" '
for f,o,n in [("SKILL.md","(124 stamps + 86","(NNN stamps + 86"),("PROVINCE.md","(124 revision stamps","(NNN revision stamps"),("corpus/README.md","| 124 rows (round 49:","| NNN rows (round 49:"),("corpus/README.md","33 row-linked / 3 by-hand / 36 pinned","NN row-linked / 3 by-hand / NN pinned")]:
    p=d/f; t=p.read_text(); assert t.count(o)==1,(f,o); p.write_text(t.replace(o,n))'
  check K2-F5 7 "$(C2 "$d")"   # run 1 expected 5 and read 7: SKILL.md:46 and README.md:67 each carry a second binding (SC-SKILL-CLAIMS, RD-DOCS-BYHAND) whose locator also needs the blanked number
  d=$(mk k2-c1); c1_ref "$d"; check K2-C1ONLY 5 "$(C2 "$d")"                 # C1 change alone moves nothing in C2
  d=$(mk k12); c1_ref "$d"; c2_ref "$d"                                      # both changes together
  check K12-C1 2 "$(C1 "$d")"; check K12-C2 0 "$(C2 "$d")"
fi
echo "CONTROLS: match=$ok mismatch=$bad"
[ "$bad" -eq 0 ]
