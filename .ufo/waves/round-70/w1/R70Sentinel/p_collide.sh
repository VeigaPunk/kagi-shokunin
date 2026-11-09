#!/usr/bin/env bash
# R70Sentinel probe E — natural port collision between concurrent trial runs.
# The trial picks its port with a CONNECT probe: a refused connect is read as "free".
# Two concurrent trials therefore race for the same port, and the loser's own dev server
# cannot bind — the loser then talks to the WINNER's server.
# This measures how often that happens with the trial's own random port choice (no forcing).
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
TRIAL=$LANE/corpus/openbao-pki-trial.sh
R=$WD/receipts
mkdir -p "$S/coll" "$R"

echo "===== PROBE E: $1 concurrent trial runs, natural port choice ====="
N=${2:-6}
mkdir -p "$S/coll"/{home,tmp}
for i in $(seq 1 $N); do
  ( HOME="$S/coll/home" TMPDIR="$S/coll/tmp" LANG=C \
    bash "$TRIAL" --work "$S/coll/w$i" > "$S/coll/o$i" 2> "$S/coll/e$i" ) &
done
wait
ok=0; setup=0; other=0
for i in $(seq 1 $N); do
  last=$(grep '^OPENBAO_PKI_TRIAL: ' "$S/coll/o$i" 2>/dev/null | tail -1)
  n=$(grep -c '^TRIAL T' "$S/coll/o$i" 2>/dev/null)
  echo "  run $i: lines=$n  $last"
  case "$last" in
    *"HOLDS holds=5"*) ok=$((ok+1));;
    *"SETUP"*) setup=$((setup+1));;
    *) other=$((other+1));;
  esac
done
echo "  => full HOLDS(5)=$ok  SETUP=$setup  other=$other  (of $N)"
echo "  dev servers left: [$(pgrep -f 'bao server -dev' | tr '\n' ' ')]"
echo "  scratch dirs left: $(ls -d "$S/coll"/w*/kagi-pki-trial.* 2>/dev/null | wc -l)"
