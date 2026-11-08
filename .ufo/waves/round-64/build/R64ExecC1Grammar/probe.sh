#!/usr/bin/env bash
# Round-64 C1 grammar seat: final-bytes probe driver (scratch only).
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
FLEET=/home/vgpnk/Projects/shokunin
BASE=/fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar
SLIM=$BASE/slim
CHK=$LANE/plans/round-61-c1-check.py

echo "## checker"
sha256sum "$CHK"; wc -l "$CHK"

echo "## selftest"
python3 -I -B "$CHK" --selftest; echo "rc=$?"

probe() { # $1=name $2=rel $3=anchor $4=replacement
  local name="$1" rel="$2" anchor="$3" repl="$4" dir="$BASE/probe-$1" line
  rm -rf "$dir"; cp -r "$SLIM" "$dir"
  python3 - "$dir/$rel" "$anchor" "$repl" <<'PY'
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
t = open(path, encoding="utf-8").read()
assert t.count(old) == 1, f"anchor count {t.count(old)} in {path}"
open(path, "w", encoding="utf-8").write(t.replace(old, new, 1))
PY
  line=$(python3 -I -B "$CHK" --root "$dir" --repo "$LANE" --fleet "$FLEET" --no-challenge | tail -1)
  echo "$name | $line"
}

echo "## base (unmodified slim copy)"
python3 -I -B "$CHK" --root "$SLIM" --repo "$LANE" --fleet "$FLEET" --no-challenge | tail -1

echo "## forgery classes (expect value=1)"
probe denial-after-pair corpus/lessons/round-60.md \
  "so the literal reading is 3/16 = 18.75 %" \
  "so the literal reading is 3/16 = 18.75 %, which is not the case"
probe duplicate-pair-unbound corpus/lessons/round-60.md \
  "gives 4/16 = 25 %; the round states" \
  "gives 4/16 = 25 %; seen elsewhere, 4/16 = 25 % again; the round states"
probe negated-subject corpus/lessons/round-60.md \
  "counting the sentinel as an attack seat" \
  "counting a different seat than the sentinel as an attack seat"
probe quoted-claim-denied corpus/lessons/round-60.md \
  "The round introduced no new record defect that it did not itself route" \
  "The round introduced no new record defect that it did not itself route, the record denies it"
probe duplicated-mechanism LOG.md \
  "it was rewritten in place at" \
  "it was rewritten in place at, and again rewritten in place at"

echo "## benign classes (expect value=0)"
probe parenthetical corpus/lessons/round-60.md \
  "so the literal reading is 3/16 = 18.75 %" \
  "so the literal reading (16 results counted, three present roles, one sentinel present, as the role mix records) is 3/16 = 18.75 %"
probe emdash-aside corpus/lessons/round-60.md \
  "so the literal reading is 3/16 = 18.75 %" \
  "so the literal reading — not the other way round here please now indeed — is 3/16 = 18.75 %"
probe idiom-not-less-than corpus/lessons/round-60.md \
  "introduced three new record defects" \
  "introduced not less than three new record defects"
probe blocker-window-bounded corpus/lessons/round-60.md \
  "so the literal reading is 3/16 = 18.75 %" \
  "so in other work the audit board said the literal reading is 3/16 = 18.75 %"
