#!/usr/bin/env bash
# plans/round-44-c1.sh -- round 44 C1 battery counter (calibration: the round-43 C2 counter
# survives two counter-mutation shapes -- K43MutCounters y1 (N1 stale-refusal leg dropped) and
# y2 (N2 silent-refusal leg dropped), routed defect M43-7 -- and this committed battery
# discriminates both from the real counter with negative fixture gates).
#
# Frozen predicate (the same sentence appears in plans/round-44.md section C1 and in the
# receipt labels): prints ONE unsigned integer N in 0..2 = the number of the two counter
# mutants y1 and y2 the battery discriminates from the real round-43 C2 counter
# (the candidate's own plans/round-43-c2.sh bytes), counted only if the positive control P0
# holds: the real counter reads 1 with the candidate's own corpus/controls-replay.sh gate.
# Mutant m is discriminated iff, with its paired negative fixture gate (y1: accept-stale;
# y2: accept-silent), the real counter reads 0, the mutant reads 1, and with the
# always-refuse blanket gate the mutant reads 0. The candidate must carry this battery's own
# bytes at plans/round-44-c1.sh (byte-identical to this file); a candidate without the
# battery file reads 0.
#
# Mutant recipes (frozen; applied to a byte-copy of the candidate's plans/round-43-c2.sh):
#   y1: delete the block from the line starting `# N1: stale fixture` through the line `N1=$?`
#       inclusive; in the final condition replace
#       `[ "$P1" = "0" ] && [ "$N1" = "1" ] && [ "$N2" = "1" ]`
#       with `[ "$P1" = "0" ] && [ "$N2" = "1" ]`.  Post-condition: no `"$N1"` remains.
#   y2: delete the block from the line starting `# N2: silent fixture` through the line `N2=$?`
#       inclusive; in the final condition replace the same string with
#       `[ "$P1" = "0" ] && [ "$N1" = "1" ]`.  Post-condition: no `"$N2"` remains.
#   A recipe marker that is absent, or present more than once, in the candidate's counter
#   bytes fails the battery closed.
#
# Negative fixture gates (embedded templates; frozen interface `--clone <dir>`):
#   accept-stale  refuses ONLY the silent shape (plans/round-42-controls.sh is the exit-0
#                 stub); accepts clean and stale (the stale refusal is inverted -- the
#                 gate-side mutation that exposes a counter without its N1 leg).
#   accept-silent refuses ONLY the stale shape (.ufo/waves/round-42/controls/
#                 c2-derivation-D.txt reads 2); accepts clean and silent (the silent
#                 refusal inverted -- exposes a counter without its N2 leg).
#   always-refuse exit 1 unconditionally (blanket).
#
# Control variants (harness-only; the claim's counting command passes no environment):
#   R44_SKIP_FIXTURES=1  both negative fixture gates are replaced by the candidate's own
#                        gate -- the M43-7 state; the battery must read 0.
#   R44_ONLY_FIXTURE=stale   the accept-silent gate is replaced by the candidate's own gate;
#                            the battery reads at most 1.
#   R44_ONLY_FIXTURE=silent  the accept-stale gate is replaced by the candidate's own gate;
#                            the battery reads at most 1.
#
# Do-nothing control: at the claim BASE d54109d943abc900e71613a02e5a7a2e46453c3a this battery
# file does not exist, so the existence leg fails and the counter reads 0.
# Fail closed (rc 2, nothing on stdout): missing candidate revision, unusable clone or
# scratch, missing round-43 counter bytes, self-byte mismatch against the candidate, or a
# mutant recipe that does not apply exactly once.
# Scratch root: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r44/battery.<pid>, removed on exit.
set -u

SELF=$(readlink -f "$0")
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
CAND=${1:-$(git -C "$REPO" rev-parse HEAD)}
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r44/battery.$$
mkdir -p -- "$SCR" || { echo "battery-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

git -C "$REPO" cat-file -e "$CAND^{commit}" 2>/dev/null \
  || { echo "battery-refused: candidate" >&2; exit 2; }

# existence leg: the candidate must carry this battery's bytes at this path
if ! git -C "$REPO" cat-file -e "$CAND:plans/round-44-c1.sh" 2>/dev/null; then
  echo 0
  exit 0
fi
git -C "$REPO" show "$CAND:plans/round-44-c1.sh" > "$SCR/self-at-cand" 2>/dev/null \
  || { echo "battery-refused: self bytes" >&2; exit 2; }
cmp -s "$SELF" "$SCR/self-at-cand" \
  || { echo "battery-refused: self mismatch" >&2; exit 2; }

git clone -q --shared "$REPO" "$SCR/clone" \
  || { echo "battery-refused: clone" >&2; exit 2; }
git -C "$SCR/clone" checkout -q --detach "$CAND" \
  || { echo "battery-refused: checkout" >&2; exit 2; }

SRC=$SCR/clone/plans/round-43-c2.sh
[ -f "$SRC" ] || { echo "battery-refused: counter bytes" >&2; exit 2; }
if [ ! -f "$SCR/clone/corpus/controls-replay.sh" ]; then
  echo 0
  exit 0
fi

# mutants from the frozen recipes
python3 - "$SRC" "$SCR" <<'PYEOF' || { echo "battery-refused: recipes" >&2; exit 2; }
import sys
src, scr = sys.argv[1], sys.argv[2]
s = open(src).read()
OLD = '[ "$P1" = "0" ] && [ "$N1" = "1" ] && [ "$N2" = "1" ]'
assert s.count(OLD) == 1, "final-condition marker"
assert s.count("# N1: stale fixture") == 1, "N1 marker"
assert s.count("# N2: silent fixture") == 1, "N2 marker"

def cut(text, start, end):
    i = text.index(start)
    j = text.index(end, i) + len(end)
    return text[:i] + text[j:]

y1 = cut(s, "# N1: stale fixture", "N1=$?\n").replace(OLD, '[ "$P1" = "0" ] && [ "$N2" = "1" ]')
assert '"$N1"' not in y1, "y1 post-condition"
y2 = cut(s, "# N2: silent fixture", "N2=$?\n").replace(OLD, '[ "$P1" = "0" ] && [ "$N1" = "1" ]')
assert '"$N2"' not in y2, "y2 post-condition"
open(scr + "/mut-y1", "w").write(y1)
open(scr + "/mut-y2", "w").write(y2)
PYEOF

cp "$SRC" "$SCR/clone/plans/r44b-real"
cp "$SCR/mut-y1" "$SCR/clone/plans/r44b-mut-y1"
cp "$SCR/mut-y2" "$SCR/clone/plans/r44b-mut-y2"

# negative fixture gates
cat > "$SCR/g-as" <<'EOF'
#!/usr/bin/env bash
# round-44 negative fixture gate (accept-stale): refuses ONLY the silent shape.
set -u
[ "$#" -eq 2 ] && [ "$1" = "--clone" ] && [ -n "$2" ] || { echo "usage: --clone <dir>" >&2; exit 2; }
D=$2
if [ -f "$D/plans/round-42-controls.sh" ] \
   && [ "$(wc -l < "$D/plans/round-42-controls.sh")" -le 2 ] \
   && grep -q '^exit 0' "$D/plans/round-42-controls.sh"; then
  exit 1
fi
exit 0
EOF
cat > "$SCR/g-asi" <<'EOF'
#!/usr/bin/env bash
# round-44 negative fixture gate (accept-silent): refuses ONLY the stale shape.
set -u
[ "$#" -eq 2 ] && [ "$1" = "--clone" ] && [ -n "$2" ] || { echo "usage: --clone <dir>" >&2; exit 2; }
D=$2
F=$D/.ufo/waves/round-42/controls/c2-derivation-D.txt
if [ -f "$F" ] && [ "$(cat "$F")" = "2" ]; then
  exit 1
fi
exit 0
EOF
cat > "$SCR/g-always" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF

OG=$SCR/clone/corpus/controls-replay.sh
AS=$SCR/g-as
ASI=$SCR/g-asi
if [ "${R44_SKIP_FIXTURES:-0}" = "1" ]; then
  AS=$OG
  ASI=$OG
fi
case "${R44_ONLY_FIXTURE:-}" in
  stale) ASI=$OG ;;
  silent) AS=$OG ;;
  "") ;;
  *) echo "battery-refused: only-fixture" >&2; exit 2 ;;
esac

run_counter() { # $1 = counter copy inside the clone, $2 = override gate ("" = default)
  local out rc
  if [ -n "$2" ]; then
    out=$(CONTROLS_REPLAY_GATE=$2 bash "$1" "$CAND" 2>/dev/null)
    rc=$?
  else
    out=$(bash "$1" "$CAND" 2>/dev/null)
    rc=$?
  fi
  if [ "$rc" -ne 0 ] || [ -z "$out" ] || [ "$(printf '%s\n' "$out" | wc -l)" -ne 1 ] \
     || printf '%s' "$out" | grep -q '[^0-9]'; then
    printf 'INVALID\n'
  else
    printf '%s\n' "$out"
  fi
}

N=0
P0=$(run_counter "$SCR/clone/plans/r44b-real" "")
if [ "$P0" != "1" ]; then
  echo 0
  exit 0
fi

R_AS=$(run_counter "$SCR/clone/plans/r44b-real" "$AS")
Y1_AS=$(run_counter "$SCR/clone/plans/r44b-mut-y1" "$AS")
Y1_AL=$(run_counter "$SCR/clone/plans/r44b-mut-y1" "$SCR/g-always")
if [ "$R_AS" = "0" ] && [ "$Y1_AS" = "1" ] && [ "$Y1_AL" = "0" ]; then
  N=$((N + 1))
fi

R_ASI=$(run_counter "$SCR/clone/plans/r44b-real" "$ASI")
Y2_ASI=$(run_counter "$SCR/clone/plans/r44b-mut-y2" "$ASI")
Y2_AL=$(run_counter "$SCR/clone/plans/r44b-mut-y2" "$SCR/g-always")
if [ "$R_ASI" = "0" ] && [ "$Y2_ASI" = "1" ] && [ "$Y2_AL" = "0" ]; then
  N=$((N + 1))
fi

echo "$N"
exit 0
