#!/usr/bin/env bash
# plans/round-72-controls.sh — round 72 prefreeze controls for C1 and C2. L1 KagiR72.
# Each control builds a fixture tree from BASE (a git-archive extraction of b2f3dd66) or
# from the C1 positive reference P1 (the candidate tree), runs the FROZEN counter on it and
# compares the counter's verdict line with the expected verdict written below BEFORE the
# first run. Receipts: <out>/<id>.txt (counter stdout+stderr, then `rc=N`).
# usage: plans/round-72-controls.sh --base DIR --cand DIR --out DIR
set -u
while [ $# -gt 0 ]; do case "$1" in --base) BASE=$2; shift 2;; --cand) CAND=$2; shift 2;; --out) OUT=$2; shift 2;; *) echo "usage"; exit 64;; esac; done
BASE=$(readlink -f "$BASE"); CAND=$(readlink -f "$CAND"); mkdir -p "$OUT"; OUT=$(readlink -f "$OUT")
HERE=$(cd "$(dirname "$0")" && pwd)
SR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r72; mkdir -p "$SR"
W=$(mktemp -d "$SR/controls.XXXXXX"); trap 'rm -rf -- "$W"' EXIT
fx() { rm -rf "$W/$1"; cp -a "$2" "$W/$1"; echo "$W/$1"; }
py() { python3 - "$@"; }

# expected: id | counter | expected rc | expected verdict-line regex
EXPECT=(
 "F0-base|c1|1|^C1_CLOCK_REARM: value=0 rows_passing=0 gate=0 fresh=0 census=1 "
 "P1-candidate|c1|0|^C1_CLOCK_REARM: value=10 rows_passing=10 gate=1 fresh=1 census=1 "
 "F1-anchor-bump-only|c1|1|^C1_CLOCK_REARM: value=0 rows_passing=0 gate=0 "
 "F2-no-ledger|c1|1|^C1_CLOCK_REARM: value=0 rows_passing=0 gate=1 fresh=1 census=1 "
 "F3-stale-receipt-pin|c1|1|^C1_CLOCK_REARM: value=0 rows_passing=0 gate=0 "
 "F4-forged-capture-digest|c1|1|^C1_CLOCK_REARM: value=9 rows_passing=9 gate=1 fresh=1 census=1 "
 "F5-quote-absent-capture|c1|1|^C1_CLOCK_REARM: value=9 rows_passing=9 gate=1 fresh=1 census=1 "
 "F6-fabricated-release|c1|1|^C1_CLOCK_REARM: value=4 rows_passing=4 gate=1 fresh=1 census=1 "
 "F7-inplace-anchor-edit|c1|1|^C1_CLOCK_REARM: value=4 rows_passing=4 gate=1 fresh=1 census=1 "
 "F8-weakened-shipped-gate|c1|1|^C1_CLOCK_REARM: value=0 rows_passing=[0-9]+ gate=0 "
 "F9-census-swapped|c1|2|^C1_CLOCK_REARM: SETUP \\(census=0 "
 "F10-receipt-deleted|c1|1|^C1_CLOCK_REARM: value=0 rows_passing=0 gate=0 fresh=0 "
 "G0-base|c2|1|^C2_SELF_COUNTS: value=4 pins=1 shape=1 "
 "Q1-base-plus-c2|c2|0|^C2_SELF_COUNTS: value=0 pins=1 shape=1 "
 "Q2-candidate-plus-c2|c2|0|^C2_SELF_COUNTS: value=0 pins=1 shape=1 "
 "G1-binding-dropped|c2|2|^C2_SELF_COUNTS: SETUP \\(pins=0 self-counts.tsv"
 "G2-gate-echo|c2|2|^C2_SELF_COUNTS: SETUP \\(pins=0 self-counts.py"
 "G3-line-deleted|c2|2|^C2_SELF_COUNTS: SETUP \\(shape=0 "
 "G4-wrong-number|c2|1|^C2_SELF_COUNTS: value=1 pins=1 shape=1 "
 "G5-policy-boundary-moved|c2|2|^C2_SELF_COUNTS: SETUP "
)

c2fix() { # set the four C2 numbers to the tree's live stamp/claim counts
  local t=$1 s c
  s=$(grep -cvE '^(#|$)' "$t/corpus/stamps.tsv"); c=$(grep -cE '^R[0-9]+-[0-9]+' "$t/corpus/claim-ledger.tsv")
  py "$t" "$s" "$c" <<'PY'
import re, sys
t, s, c = sys.argv[1:4]
for f, pat in (("SKILL.md", r"^(\| Re-run a claim .*?\()([0-9]+)( stamps \+ )([0-9]+)( claims\b)"),
               ("PROVINCE.md", r"^(- `corpus/claim-ledger\.sh` — .*?`verify` \()([0-9]+)( revision stamps \+ )([0-9]+)( claim rows)")):
    p = f"{t}/{f}"; L = open(p, encoding="utf-8").read().split("\n"); n = 0
    for i, l in enumerate(L):
        m = re.match(pat, l)
        if m:
            L[i] = l[:m.start(2)] + s + m.group(3) + c + l[m.end(4):]; n += 1
    assert n == 1, (f, n)
    open(p, "w", encoding="utf-8").write("\n".join(L))
PY
}

build() {
  case "$1" in
    F0-base|G0-base) echo "$BASE" ;;
    P1-candidate) echo "$CAND" ;;
    F1-anchor-bump-only) t=$(fx f1 "$BASE"); py "$t" <<'PY'
import sys
p = sys.argv[1] + "/corpus/release-clocks.tsv"; out = []
F = {"S013", "S022", "S023", "S024"}; O = {"S014", "S015", "S016", "S021", "S025", "S026"}
for l in open(p).read().rstrip("\n").split("\n"):
    c = l.split("\t")
    if c[0] in F | O:
        v = "2.2.1" if c[0] in F else "2.7.2"; c[4] = v; c[5] = v; c[7] = "not-fired"
    out.append("\t".join(c))
open(p, "w").write("\n".join(out) + "\n")
PY
      echo "$t" ;;
    F2-no-ledger) t=$(fx f2 "$CAND"); rm "$t/corpus/clock-rearm.tsv"; echo "$t" ;;
    F3-stale-receipt-pin) t=$(fx f3 "$CAND"); cp "$BASE/corpus/release-clock.py" "$t/corpus/release-clock.py"; echo "$t" ;;
    F4-forged-capture-digest) t=$(fx f4 "$CAND"); py "$t" <<'PY'
import sys
p = sys.argv[1] + "/corpus/clock-rearm.tsv"; L = open(p).read().split("\n")
for i, l in enumerate(L):
    c = l.split("\t")
    if c[0] == "S024":
        c[7] = "0" * 64; L[i] = "\t".join(c)
open(p, "w").write("\n".join(L))
PY
      echo "$t" ;;
    F5-quote-absent-capture) t=$(fx f5 "$CAND"); py "$t" <<'PY'
import hashlib, os, sys
t = sys.argv[1]; d = t + "/.ufo/waves/round-72/capture/"
open(d + "S015.page.body", "wb").write(open(d + "S014.page.body", "rb").read())
p = t + "/corpus/clock-rearm.tsv"; L = open(p).read().split("\n")
for i, l in enumerate(L):
    c = l.split("\t")
    if c[0] == "S015":
        b = open(d + "S015.page.body", "rb").read()
        c[7] = hashlib.sha256(b).hexdigest(); c[8] = str(len(b)); L[i] = "\t".join(c)
open(p, "w").write("\n".join(L))
PY
      echo "$t" ;;
    F6-fabricated-release) t=$(fx f6 "$CAND"); py "$t" <<'PY'
import hashlib, json, re, sys
t = sys.argv[1]
O = {"S014", "S015", "S016", "S021", "S025", "S026"}
p = t + "/corpus/release-clocks.tsv"; out = []
for l in open(p).read().rstrip("\n").split("\n"):
    c = l.split("\t")
    if c[0] in O:
        c[4] = c[5] = "2.7.3"
    out.append("\t".join(c))
open(p, "w").write("\n".join(out) + "\n")
s = t + "/corpus/SOURCES.md"; S = open(s).read().split("\n")
for i, l in enumerate(S):
    if l.startswith("| S175 "):
        c = l.split(" | "); c[5] = c[5].replace("v2.7.2", "v2.7.3"); S[i] = " | ".join(c)
open(s, "w").write("\n".join(S))
r = t + "/.ufo/waves/round-72/final/observe-r72.json"; d = json.load(open(r))
for o in d["observations"]:
    if o["id"] in O:
        o["parsed_version"] = "2.7.3"
open(r, "w").write(json.dumps(d, indent=1, sort_keys=True) + "\n")
h = hashlib.sha256(open(r, "rb").read()).hexdigest()
g = t + "/corpus/release-clock.py"; G = open(g).read()
G = re.sub(r'^DEFAULT_RECEIPT_SHA256 = "[0-9a-f]{64}"$', f'DEFAULT_RECEIPT_SHA256 = "{h}"', G, flags=re.M)
open(g, "w").write(G)
q = t + "/corpus/clock-rearm.tsv"; L = open(q).read().split("\n")
for i, l in enumerate(L):
    c = l.split("\t")
    if c[0] in O:
        c[3] = "2.7.3"; L[i] = "\t".join(c)
open(q, "w").write("\n".join(L))
PY
      echo "$t" ;;
    F7-inplace-anchor-edit) t=$(fx f7 "$CAND"); py "$t" <<'PY'
import sys
t = sys.argv[1]
O = {"S014", "S015", "S016", "S021", "S025", "S026"}
p = t + "/corpus/release-clocks.tsv"; out = []
for l in open(p).read().rstrip("\n").split("\n"):
    c = l.split("\t")
    if c[0] in O:
        c[2] = "S035"
    out.append("\t".join(c))
open(p, "w").write("\n".join(out) + "\n")
s = t + "/corpus/SOURCES.md"; S = open(s).read().split("\n")
for i, l in enumerate(S):
    if l.startswith("| S035 "):
        c = l.split(" | "); c[5] = c[5].replace("v2.7.1", "v2.7.2"); S[i] = " | ".join(c)
open(s, "w").write("\n".join(S))
q = t + "/corpus/clock-rearm.tsv"; L = open(q).read().split("\n")
for i, l in enumerate(L):
    c = l.split("\t")
    if c[0] in O:
        c[4] = "S035"; L[i] = "\t".join(c)
open(q, "w").write("\n".join(L))
PY
      echo "$t" ;;
    F8-weakened-shipped-gate) t=$(fx f8 "$CAND"); py "$t" <<'PY'
import sys
t = sys.argv[1]
p = t + "/corpus/release-clocks.tsv"; out = []
for l in open(p).read().rstrip("\n").split("\n"):
    c = l.split("\t")
    if c[0] == "S072":
        c[6] = "2026-11-07"
    out.append("\t".join(c))
open(p, "w").write("\n".join(out) + "\n")
g = t + "/corpus/release-clock.py"; G = open(g).read()
G = G.replace('"passed": not errors and bound == len(on_release),', '"passed": True,')
G = G.replace('"errors": sorted(errors),', '"errors": [],')
open(g, "w").write(G)
PY
      echo "$t" ;;
    F9-census-swapped) t=$(fx f9 "$CAND"); printf '#!/usr/bin/env bash\necho "SOURCES_CENSUS: CLEAN (rows=0)"\n' > "$t/corpus/sources-census.sh"; echo "$t" ;;
    F10-receipt-deleted) t=$(fx f10 "$CAND"); rm "$t/.ufo/waves/round-72/final/observe-r72.json"; echo "$t" ;;
    Q1-base-plus-c2) t=$(fx q1 "$BASE"); c2fix "$t"; echo "$t" ;;
    Q2-candidate-plus-c2) t=$(fx q2 "$CAND"); c2fix "$t"; echo "$t" ;;
    G1-binding-dropped) t=$(fx g1 "$BASE"); c2fix "$t"; grep -v '^SC-SKILL-STAMPS	' "$BASE/corpus/self-counts.tsv" > "$t/corpus/self-counts.tsv"; echo "$t" ;;
    G2-gate-echo) t=$(fx g2 "$BASE"); printf 'print("SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)")\n' > "$t/corpus/self-counts.py"; echo "$t" ;;
    G3-line-deleted) t=$(fx g3 "$BASE"); c2fix "$t"; grep -v '^| Re-run a claim ' "$t/SKILL.md" > "$t/SKILL.md.n"; mv "$t/SKILL.md.n" "$t/SKILL.md"; echo "$t" ;;
    G4-wrong-number) t=$(fx g4 "$BASE"); c2fix "$t"; py "$t" <<'PY'
import re, sys
p = sys.argv[1] + "/SKILL.md"; s = open(p).read()
s2 = re.sub(r"(\| Re-run a claim .*?\()([0-9]+)( stamps \+ )", lambda m: m.group(1) + str(int(m.group(2)) + 1) + m.group(3), s, count=1, flags=re.M)
assert s2 != s; open(p, "w").write(s2)
PY
      echo "$t" ;;
    G5-policy-boundary-moved) t=$(fx g5 "$BASE"); c2fix "$t"; py "$t" <<'PY'
import sys
p = sys.argv[1] + "/corpus/claim-ledger.tsv"; L = open(p).read().split("\n")
for i, l in enumerate(L):
    c = l.split("\t")
    if c[0] == "R29-01":
        c[1] = "python3 corpus/self-counts.py --selftest"; L[i] = "\t".join(c)
open(p, "w").write("\n".join(L))
PY
      echo "$t" ;;
  esac
}

fail=0
for e in "${EXPECT[@]}"; do
  IFS='|' read -r id ctr erc ere <<<"$e"
  t=$(build "$id")
  bash "$HERE/round-72-$ctr.sh" --tree "$t" > "$OUT/$id.txt" 2>&1; rc=$?
  echo "rc=$rc" >> "$OUT/$id.txt"
  line=$(grep -E '^C[12]_' "$OUT/$id.txt" | tail -1)
  if [ "$rc" = "$erc" ] && [[ $line =~ $ere ]]; then v=MATCH; else v=MISMATCH; fail=$((fail + 1)); fi
  printf 'CONTROL %s counter=%s expected_rc=%s observed_rc=%s %s | %s\n' "$id" "$ctr" "$erc" "$rc" "$v" "$line" | tee -a "$OUT/summary.txt"
done
echo "CONTROLS: $(( ${#EXPECT[@]} - fail ))/${#EXPECT[@]} match" | tee -a "$OUT/summary.txt"
[ $fail = 0 ]
