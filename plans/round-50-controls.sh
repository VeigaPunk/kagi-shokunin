#!/usr/bin/env bash
# plans/round-50-controls.sh — round-50 pre-freeze controls. Every expected value below was written
# in this file before the first run. Fixtures: .ufo/waves/round-50/controls/fixtures/.
# Receipt: stdout (committed as .ufo/waves/round-50/controls/controls-prefreeze.txt).
# Expected forms: a number = the counter's `value=`; SETUP = the counter printed `: SETUP` (exit 2).
set -u
BASE=565c43a874b59cd216f4a55c8742db48fa854f16
LANE=$(cd "$(dirname "$0")/.." && pwd)
FX="$LANE/.ufo/waves/round-50/controls/fixtures"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r50/controls"
mkdir -p "$SCR"; S=$(mktemp -d "$SCR/run.XXXXXX"); trap 'rm -rf -- "$S"' EXIT
C1="$LANE/plans/round-50-c1.sh"; C2="$LANE/plans/round-50-c2.sh"
echo "CONTROLS round-50 lane=$LANE base=$BASE started=$(date -u +%FT%TZ)"
sha256sum "$C1" "$C2" "$0" "$FX"/* | sed "s#$LANE/##"

# ---------- C1 fixture trees (plain trees: archive of BASE + one trial file) ----------
c1tree() { # name trialfile|- -> tree path
  local t="$S/c1-$1"; mkdir -p "$t"; git -C "$LANE" archive "$BASE" | tar -x -C "$t"
  [ "$2" = - ] || cp "$2" "$t/corpus/openbao-token-trial.sh"; echo "$t"; }
# ---------- C2 fixture repos (clone --shared of BASE + one fixture commit) ----------
c2repo() { # name -> repo path (HEAD = BASE)
  local d="$S/c2-$1"
  git clone -q --shared --no-checkout "$LANE" "$d"
  [ "$(git -C "$d" rev-parse --show-toplevel)" = "$d" ] || { echo "toplevel mismatch $d"; exit 2; }
  git -C "$d" checkout -q --detach "$BASE"; echo "$d"; }
c2commit() { # repo
  [ "$(git -C "$1" rev-parse --show-toplevel)" = "$1" ] || { echo "toplevel mismatch $1"; exit 2; }
  git -C "$1" add -A && git -C "$1" -c user.name=fixture -c user.email=fixture@invalid commit -qm fixture; }
mig() { # repo mode -> apply python3 fixtures/migrate.py <mode>
  python3 "$FX/migrate.py" "$1" "$2"; }

declare -A EXP
EXP[K1-0]=0; EXP[K1-P]=3; EXP[K1-F1]=0; EXP[K1-F2]=0; EXP[K1-F3]=SETUP; EXP[K1-F4]=SETUP
EXP[K2-0]=10; EXP[K2-P]=0; EXP[K2-F1]=SETUP; EXP[K2-F2]=SETUP; EXP[K2-F3]=SETUP; EXP[K2-F4]=SETUP
EXP[K2-F5]=5; EXP[K2-F6]=SETUP; EXP[K2-F7]=SETUP

run() { # key cmd... -> one line
  local k=$1; shift; local out got
  out=$("$@" 2>&1 | grep -E '^C[12]_[A-Z_]+: ' | head -1)
  case "$out" in *": SETUP"*) got=SETUP;; *) got=$(printf '%s' "$out" | grep -oP 'value=\K[0-9]+' | head -1);; esac
  [ -n "$got" ] || got=NONE
  if [ "$got" = "${EXP[$k]}" ]; then m=MATCH; else m=MISMATCH; fi
  echo "$k expected=${EXP[$k]} got=$got $m :: $out" >> "$S/lines"
}

# C1 (description, then the run)
# K1-0 do-nothing: BASE trial (EXIT-trap cleanup only)
run K1-0 bash "$C1" --tree "$(c1tree 0 -)" &
# K1-P reference: setpriv --pdeathsig KILL on the server
run K1-P bash "$C1" --tree "$(c1tree P "$FX/openbao-token-trial.ref.sh")" &
# K1-F1 process group only (setsid, the round-49 routed wording), no parent-death signal
run K1-F1 bash "$C1" --tree "$(c1tree F1 "$FX/openbao-token-trial.f1-setsid.sh")" &
# K1-F2 server detached with setsid nohup and the nonce stripped (descendant capture must see it)
run K1-F2 bash "$C1" --tree "$(c1tree F2 "$FX/openbao-token-trial.f2-detached-nononce.sh")" &
# K1-F3 constant-HOLDS printer, no server (OBSERVED fails; POSITIVE fails)
run K1-F3 bash "$C1" --tree "$(c1tree F3 "$FX/openbao-token-trial.f3-constant.sh")" &
# K1-F4 pdeathsig server, constant HOLDS, no tests (POSITIVE fails)
run K1-F4 bash "$C1" --tree "$(c1tree F4 "$FX/openbao-token-trial.f4-server-no-tests.sh")" &
wait

# C2 runs serially: run 1 (receipt controls-prefreeze-run1.txt) ran the nine C2 controls in parallel and
# K2-P read SETUP G6-no-digit-R24-15; run 2 (serial, controls-prefreeze-run2.txt) read the same: the cause was
# not load but the unrestamped ledger (revision audit DRIFT stale=1). Run 3 adds the restamp to fixtures/migrate.py.
# C2
d=$(c2repo 0); run K2-0 bash "$C2" --tree "$d"
d=$(c2repo P); mig "$d" ref && c2commit "$d"; run K2-P bash "$C2" --tree "$d"
d=$(c2repo F1); mig "$d" wildcard && c2commit "$d"; run K2-F1 bash "$C2" --tree "$d"
d=$(c2repo F2); mig "$d" repoint && c2commit "$d"; run K2-F2 bash "$C2" --tree "$d"
d=$(c2repo F3); mig "$d" nojournal && c2commit "$d"; run K2-F3 bash "$C2" --tree "$d"
d=$(c2repo F4); mig "$d" boundary && c2commit "$d"; run K2-F4 bash "$C2" --tree "$d"
d=$(c2repo F5); mig "$d" half && c2commit "$d"; run K2-F5 bash "$C2" --tree "$d"
d=$(c2repo F6); mig "$d" digitclass && c2commit "$d"; run K2-F6 bash "$C2" --tree "$d"
d=$(c2repo F7); mig "$d" producer && c2commit "$d"; run K2-F7 bash "$C2" --tree "$d"
sort "$S/lines"
n=$(grep -c ' MATCH ' "$S/lines"); x=$(grep -c ' MISMATCH ' "$S/lines")
if [ "$x" -eq 0 ] && [ "$n" -eq ${#EXP[@]} ]; then v=ALL-MATCH; else v=MISMATCH; fi
echo "CONTROLS: $v (match=$n mismatch=$x expected=${#EXP[@]}) finished=$(date -u +%FT%TZ)"
