#!/usr/bin/env bash
# plans/round-54-controls.sh — pre-freeze controls for the frozen round-54 C1 counter.
# Each control builds a fixture tree from BASE (git archive) plus the committed S112 capture,
# applies the edit named on its line, runs plans/round-54-c1.sh with --tree, and compares the
# printed value= (or SETUP) with the expectation written here before the run. Prints
# `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH` and a summary `CONTROLS: match=N mismatch=M`.
# C1 reference fixture: .ufo/waves/round-54/controls/fixtures/ref/c1/ (overlay onto BASE).
# Usage: bash plans/round-54-controls.sh
set -u
LANE=$(cd "$(dirname "$0")/.." && pwd)
BASE_REV=1a0f43a9220bb0e995462c2aef745ac0124c3317
REF="$LANE/.ufo/waves/round-54/controls/fixtures/ref/c1"
CAP="$LANE/.ufo/waves/round-54/capture/S112.body"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r54"
mkdir -p "$SCR" || exit 2
W=$(mktemp -d "$SCR/controls.XXXXXX") || exit 2
trap 'rm -rf -- "$W"' EXIT
export TMPDIR="$W"
ok=0; bad=0
export C1_ASOF; C1_ASOF=$(date -u +%s)
[ -f "$CAP" ] && [ -d "$REF" ] || { echo "CONTROLS: SETUP (capture or reference overlay missing)"; exit 2; }

mk() { local d="$W/$1"; mkdir -p "$d"; git -C "$LANE" archive "$BASE_REV" | tar -x -C "$d";
       mkdir -p "$d/.ufo/waves/round-54/capture"; cp "$CAP" "$d/.ufo/waves/round-54/capture/"; echo "$d"; }
ref() { local d; d=$(mk "$1"); cp -a "$REF"/. "$d"/; echo "$d"; }
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
  local g m; g=$(printf '%s\n' "$3" | val)
  if [ "$g" = "$2" ]; then ok=$((ok+1)); m=MATCH; else bad=$((bad+1)); m=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=$g $m"; echo "  $(printf '%s' "$3" | head -c 700)"
}
C1() { bash "$LANE/plans/round-54-c1.sh" --tree "$1" 2>&1; }
# receipt helpers used by the forgers: re-digest observe-r54.json into the gate's digest line
REDIGEST='
g = d / "corpus/release-clock.py"; r = d / ".ufo/waves/round-54/final/observe-r54.json"
t = g.read_text(encoding="utf-8")
t = re.sub(r"(?m)^DEFAULT_RECEIPT_SHA256 = \"[0-9a-f]{64}\"$", "DEFAULT_RECEIPT_SHA256 = \"%s\"" % hashlib.sha256(r.read_bytes()).hexdigest(), t)
g.write_text(t, encoding="utf-8")
'
S072REC='
r = d / ".ufo/waves/round-54/final/observe-r54.json"
doc = json.loads(r.read_text(encoding="utf-8"))
rec = [o for o in doc["observations"] if o["id"] == "S072"][0]
'
SAVEREC='
r.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8")
'
SETCLOCK='
def setclock(col, value):
    p = d / "corpus/release-clocks.tsv"
    out = []
    for l in p.read_text(encoding="utf-8").split("\n"):
        f = l.split("\t")
        if f[0] == "S072":
            f[col] = value
        out.append("\t".join(f))
    p.write_text("\n".join(out), encoding="utf-8")
'
OPR=.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt

# K1-0: BASE (do-nothing control) -> 0
d=$(mk k0); check K1-0 0 "$(C1 "$d")"
# K1-P: reference overlay (the planned candidate) -> 2
d=$(ref kp); check K1-P 2 "$(C1 "$d")"
# K1-F1: S072 recheck flipped to on-release, nothing else (no clock, no receipt, no measure) -> 0
d=$(mk kf1); py_edit "$d" '
p = d / "corpus/SOURCES.md"; t = p.read_text(encoding="utf-8")
old = "| mined | 2026-11-03 | 180d | corpus/lessons/round-32.md |"
assert t.count(old) == 1
p.write_text(t.replace(old, "| mined | 2026-11-03 | on-release | corpus/lessons/round-32.md |"), encoding="utf-8")'
check K1-F1 0 "$(C1 "$d")"
# K1-F2: gate replaced by a printer that prints CLEAN / selftest PASS for any argument -> 1 (measured only)
d=$(ref kf2); cat > "$d/corpus/release-clock.py" <<'PY'
import sys
print("RELEASE_CLOCK_SELFTEST: PASS (121 cases)" if "--selftest" in sys.argv else
      "RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)")
PY
check K1-F2 1 "$(C1 "$d")"
# K1-F3: BASE gate (no declared title prefix) with only its receipt lines moved to round 54 -> 1
d=$(ref kf3); git -C "$LANE" show "$BASE_REV:corpus/release-clock.py" > "$d/corpus/release-clock.py"
py_edit "$d" '
g = d / "corpus/release-clock.py"; t = g.read_text(encoding="utf-8")
t = t.replace("\"round-53\" / \"final\" / \"observe-r53.json\"", "\"round-54\" / \"final\" / \"observe-r54.json\"")
g.write_text(t, encoding="utf-8")'"$REDIGEST"
check K1-F3 1 "$(C1 "$d")"
# K1-F4: clock re-anchored on 2.42.0 as not-fired (table and receipt agree, digest rewritten) -> 1
d=$(ref kf4); py_edit "$d" "$SETCLOCK"'
setclock(4, "2.42.0"); setclock(7, "not-fired")'"$S072REC"'
rec["verdict"] = "not-fired"'"$SAVEREC$REDIGEST"
check K1-F4 1 "$(C1 "$d")"
# K1-F5: op receipt names op_version=2.41.1 (the installed CLI) -> 1
d=$(ref kf5); py_edit "$d" "
p = d / '$OPR'; t = p.read_text(encoding='utf-8')
assert t.count('op_version=2.42.0') == 1
p.write_text(t.replace('op_version=2.42.0', 'op_version=2.41.1'), encoding='utf-8')"
check K1-F5 1 "$(C1 "$d")"
# K1-F6: one byte case reads FAIL while the summary line is left CLEAN -> 1
d=$(ref kf6); py_edit "$d" "
p = d / '$OPR'; t = p.read_text(encoding='utf-8')
p.write_text(t.replace('id=trailing-lf status=PASS', 'id=trailing-lf status=FAIL'), encoding='utf-8')"
check K1-F6 1 "$(C1 "$d")"
# K1-F7: entry left at BASE (no section 11.2) -> 1
d=$(ref kf7); git -C "$LANE" show "$BASE_REV:corpus/knowledge/op-ref-consumption.md" > "$d/corpus/knowledge/op-ref-consumption.md"
check K1-F7 1 "$(C1 "$d")"
# K1-F8: S112 registry row moved to another URL (clock and receipt unchanged) -> 1
d=$(ref kf8); py_edit "$d" '
p = d / "corpus/SOURCES.md"; t = p.read_text(encoding="utf-8")
old = "— https://releases.1password.com/developers/cli/index.xml |"
assert t.count(old) == 1
p.write_text(t.replace(old, "— https://releases.1password.com/developers/cli/feed.xml |"), encoding="utf-8")'
check K1-F8 1 "$(C1 "$d")"
# K1-F9: S072 observation relabelled 2026-11-06T23:59:59Z in table and receipt, digest rewritten -> 1
d=$(ref kf9); py_edit "$d" "$SETCLOCK"'
setclock(6, "2026-11-06")'"$S072REC"'
rec["observed_at"] = "2026-11-06T23:59:59Z"'"$SAVEREC$REDIGEST"
check K1-F9 1 "$(C1 "$d")"
# K1-F10: probe replaced by a CLEAN printer and the receipt's probe digest rewritten to match -> 0
d=$(ref kf10); printf '#!/usr/bin/env bash\necho "OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)"\n' > "$d/corpus/op-ref-probe.sh"
py_edit "$d" "
p = d / '$OPR'; t = p.read_text(encoding='utf-8')
new = hashlib.sha256((d / 'corpus/op-ref-probe.sh').read_bytes()).hexdigest()
t = re.sub(r'(?m)^probe_sha256=[0-9a-f]{64}\$', 'probe_sha256=' + new, t)
p.write_text(t, encoding='utf-8')"
check K1-F10 0 "$(C1 "$d")"
# K1-F11: signature line removed from the op receipt -> 1
d=$(ref kf11); py_edit "$d" "
p = d / '$OPR'; t = p.read_text(encoding='utf-8')
p.write_text(re.sub(r'(?m)^gpg_validsig=.*\n', '', t), encoding='utf-8')"
check K1-F11 1 "$(C1 "$d")"
# K1-F12: default receipt replaced by a symlink to an identical copy outside the pinned path -> 1
d=$(ref kf12); mkdir -p "$d/elsewhere"; mv "$d/.ufo/waves/round-54/final/observe-r54.json" "$d/elsewhere/observe-r54.json"
ln -s ../../../../elsewhere/observe-r54.json "$d/.ufo/waves/round-54/final/observe-r54.json"
check K1-F12 1 "$(C1 "$d")"
# K1-F13: committed capture tampered (one byte appended; receipt still names the original digest) -> 1
d=$(ref kf13); printf ' ' >> "$d/.ufo/waves/round-54/capture/S112.body"
check K1-F13 1 "$(C1 "$d")"
# K1-F14: S072 receipt record no longer linked to the committed body (other sha256, digest rewritten) -> 1
d=$(ref kf14); py_edit "$d" "$S072REC"'
rec["sha256"] = "0" * 64'"$SAVEREC$REDIGEST"
check K1-F14 1 "$(C1 "$d")"

echo "CONTROLS: match=$ok mismatch=$bad"
[ "$bad" -eq 0 ]
