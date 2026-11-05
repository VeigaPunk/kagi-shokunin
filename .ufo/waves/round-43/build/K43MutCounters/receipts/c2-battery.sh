#!/usr/bin/env bash
# K43MutCounters C2 mutation battery. Sandbox-only.
set -u
S=/fast/scratch/hyaku/kagi-r43/K43MutCounters
WORK=$S/work
G=$S/gates
mkdir -p -- "$G"
export HYAKU_SCRATCH=$S/scr
cd "$WORK" || exit 2
[ "$(git rev-parse --show-toplevel)" = "$WORK" ] || { echo "FATAL: toplevel mismatch" >&2; exit 2; }
echo "corpus/controls-replay.sh at dd6ccb9: $([ -f corpus/controls-replay.sh ] && echo PRESENT || echo ABSENT)"
echo "CAND (HEAD of sandbox clone) = $(git rev-parse HEAD)"

# ---------------- gates ----------------
# c2gate.sh: correct gate per frozen §C2 interface: snapshot -> delete -> run clone's two
# runners (each must exit 0) -> every manifest file exists + byte-matches snapshot -> restore.
cat > "$G/c2gate.sh" <<'EOF'
#!/usr/bin/env bash
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] && [ -d "$2" ] || { echo "gate: setup" >&2; exit 2; }
CLONE=$2
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c2gate.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
M41=$CLONE/.ufo/waves/round-41/controls
M42=$CLONE/.ufo/waves/round-42/controls
[ -d "$M41" ] && [ -d "$M42" ] || { echo "gate: setup" >&2; exit 2; }
cp -a "$M41" "$SCR/snap-r41" && cp -a "$M42" "$SCR/snap-r42" || { echo "gate: setup" >&2; exit 2; }
rm -rf -- "$M41" "$M42"
(cd "$CLONE" && bash plans/round-42-controls.sh) > "$SCR/r42.log" 2>&1; R42=$?
(cd "$CLONE" && bash plans/round-41-controls.sh) > "$SCR/r41.log" 2>&1; R41=$?
MANIFEST=".ufo/waves/round-42/controls/c1-control-refuse-all.txt
.ufo/waves/round-42/controls/c1-control-accept-all.txt
.ufo/waves/round-42/controls/c2-derivation-D.txt
.ufo/waves/round-41/controls/c1-control-refuse-all.txt
.ufo/waves/round-41/controls/c1-control-accept-all.txt
.ufo/waves/round-41/controls/c1-control-no-gate.txt
.ufo/waves/round-41/controls/c2-control-decoy.txt
.ufo/waves/round-41/controls/c2-base-19025d9.txt"
BAD=0
while IFS= read -r rel; do
  p41=$SCR/snap-r41/${rel#.ufo/waves/round-41/controls/}
  p42=$SCR/snap-r42/${rel#.ufo/waves/round-42/controls/}
  case "$rel" in
    .ufo/waves/round-41/*) snap=$p41 ;;
    .ufo/waves/round-42/*) snap=$p42 ;;
  esac
  if [ ! -f "$CLONE/$rel" ] || ! cmp -s "$CLONE/$rel" "$snap"; then BAD=1; fi
done <<LIST
$MANIFEST
LIST
rm -rf -- "$M41" "$M42"
cp -a "$SCR/snap-r41" "$M41" && cp -a "$SCR/snap-r42" "$M42" || { echo "gate: restore failed" >&2; exit 2; }
[ "$R42" = "0" ] && [ "$R41" = "0" ] && [ "$BAD" = "0" ] || { echo "gate: refused" >&2; exit 1; }
exit 0
EOF
# accept-stale.sh: replay-verifies only round-42 c1 blanket receipts -> clean 0, stale 0, silent 1.
cat > "$G/accept-stale.sh" <<'EOF'
#!/usr/bin/env bash
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] && [ -d "$2" ] || { echo "gate: setup" >&2; exit 2; }
CLONE=$2
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c2accstale.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
M42=$CLONE/.ufo/waves/round-42/controls
[ -d "$M42" ] || { echo "gate: setup" >&2; exit 2; }
cp -a "$M42" "$SCR/snap" || exit 2
rm -rf -- "$M42"
(cd "$CLONE" && bash plans/round-42-controls.sh) > "$SCR/r42.log" 2>&1; R42=$?
BAD=0
for rel in c1-control-refuse-all.txt c1-control-accept-all.txt; do
  [ -f "$M42/$rel" ] && cmp -s "$M42/$rel" "$SCR/snap/$rel" || BAD=1
done
rm -rf -- "$M42"; cp -a "$SCR/snap" "$M42" || { echo "gate: restore failed" >&2; exit 2; }
[ "$R42" = "0" ] && [ "$BAD" = "0" ] || exit 1
exit 0
EOF
# accept-silent.sh: commit-compare only (no replay) -> clean 0, stale 1, silent 0.
cat > "$G/accept-silent.sh" <<'EOF'
#!/usr/bin/env bash
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] && [ -d "$2" ] || { echo "gate: setup" >&2; exit 2; }
CLONE=$2
MANIFEST=".ufo/waves/round-42/controls/c1-control-refuse-all.txt
.ufo/waves/round-42/controls/c1-control-accept-all.txt
.ufo/waves/round-42/controls/c2-derivation-D.txt
.ufo/waves/round-41/controls/c1-control-refuse-all.txt
.ufo/waves/round-41/controls/c1-control-accept-all.txt
.ufo/waves/round-41/controls/c1-control-no-gate.txt
.ufo/waves/round-41/controls/c2-control-decoy.txt
.ufo/waves/round-41/controls/c2-base-19025d9.txt"
while IFS= read -r rel; do
  git -C "$CLONE" show "HEAD:$rel" 2>/dev/null | cmp -s - "$CLONE/$rel" || exit 1
done <<LIST
$MANIFEST
LIST
exit 0
EOF
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/always0.sh"
printf '#!/usr/bin/env bash\nexit 1\n' > "$G/always1.sh"

# ---------------- mutants ----------------
python3 - "$WORK" <<'PY' || exit 2
import os, sys
top = sys.argv[1]
src = open(os.path.join(top, "plans/round-43-c2.sh"), encoding="utf-8").read()

N1_BLOCK = '''# N1: stale fixture -- a manifest receipt's committed bytes altered; the gate must refuse.
cp -a "$SCR/clone" "$SCR/stale" || { echo "counter-refused: stale fixture" >&2; exit 2; }
F=$SCR/stale/.ufo/waves/round-42/controls/c2-derivation-D.txt
[ -f "$F" ] && [ "$(cat "$F" 2>/dev/null)" = "1" ] || { echo "counter-refused: stale precondition" >&2; exit 2; }
printf '2\\n' > "$F"
bash "$GATE" --clone "$SCR/stale" >/dev/null 2>&1
N1=$?

'''
N2_BLOCK = '''# N2: silent fixture -- the round-42 controls runner writes nothing; the gate must refuse.
cp -a "$SCR/clone" "$SCR/silent" || { echo "counter-refused: silent fixture" >&2; exit 2; }
printf '#!/usr/bin/env bash\\nexit 0\\n' > "$SCR/silent/plans/round-42-controls.sh"
bash "$GATE" --clone "$SCR/silent" >/dev/null 2>&1
N2=$?

'''
COND = 'if [ "$P1" = "0" ] && [ "$N1" = "1" ] && [ "$N2" = "1" ]; then'

def write(name, text):
    open(os.path.join(top, "plans", name), "w", encoding="utf-8").write(text)

assert N1_BLOCK in src, "N1 block not found"
write("mut-y1-non1.sh", src.replace(N1_BLOCK, "", 1).replace(COND, 'if [ "$P1" = "0" ] && [ "$N2" = "1" ]; then', 1))
assert N2_BLOCK in src, "N2 block not found"
write("mut-y2-non2.sh", src.replace(N2_BLOCK, "", 1).replace(COND, 'if [ "$P1" = "0" ] && [ "$N1" = "1" ]; then', 1))
assert COND in src, "final condition not found"
write("mut-y3-p01.sh", src.replace(COND, 'if { [ "$P1" = "0" ] || [ "$P1" = "1" ]; } && [ "$N1" = "1" ] && [ "$N2" = "1" ]; then', 1))
print("c2 surgery ok")
PY

# ---------------- battery ----------------
row() { # $1 variant  $2 gate-file
  local out rc
  out=$(env CONTROLS_REPLAY_GATE="$G/$2" bash "plans/$1" 2> "$S/scr/err-$1-$2.txt"); rc=$?
  printf '%-18s %-14s out=[%s] rc=%d\n' "$1" "$2" "$out" "$rc"
}
echo "=== C2 battery (variant x gate -> counter stdout, rc) ==="
for v in round-43-c2.sh mut-y1-non1.sh mut-y2-non2.sh mut-y3-p01.sh; do
  row "$v" c2gate.sh
  row "$v" always0.sh
  row "$v" always1.sh
done
echo "--- discriminating extra probes (not part of the frozen battery) ---"
row round-43-c2.sh   accept-stale.sh
row mut-y1-non1.sh   accept-stale.sh
row round-43-c2.sh   accept-silent.sh
row mut-y2-non2.sh   accept-silent.sh
echo "=== C2 battery done ==="
