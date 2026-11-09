#!/usr/bin/env bash
# R70Sentinel — re-verification of the three claims whose original receipts were lost to a
# sibling's scratch cleanup. Outputs go straight into this seat's receipts dir.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
R=$WD/receipts
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
TRIAL=$LANE/corpus/openbao-pki-trial.sh
mkdir -p "$S/RV"

echo "===== RV1: the dev root token IS in the live dev server's argv (masked) ====="
W=$S/RV/argv; rm -rf "$W"; mkdir -p "$W"/{home,tmp,work}
HOME="$W/home" TMPDIR="$W/tmp" LANG=C bash "$TRIAL" --work "$W/work" > "$W/out" 2> "$W/err" &
TP=$!
for i in $(seq 1 200); do
  for p in $(pgrep -f 'bao server -dev' 2>/dev/null); do
    a=$(tr '\0' ' ' < "/proc/$p/cmdline" 2>/dev/null)
    case "$a" in
      *"bao server -dev"*)
        echo "  argv of pid $p (token MASKED):"
        printf '%s\n' "$a" | sed -E 's/-dev-root-token-id=[^ ]+/-dev-root-token-id=<DEV-TOKEN-MASKED>/' | sed 's/^/    /'
        echo "  the argv carries a 28-char token field: $(printf '%s' "$a" | grep -oE '\-dev-root-token-id=.{28}' | wc -l)"
        echo "  /proc/<pid>/cmdline mode: $(stat -c %A "/proc/$p/cmdline")   /proc mount: $(grep ' /proc ' /proc/mounts | awk '{print $4}')"
        break 2;;
    esac
  done
  sleep 0.05
done
wait "$TP" 2>/dev/null
echo "  (the trial's own claim, for comparison):"
grep -n 'lives only in scratch and is never printed' "$TRIAL" | sed 's/^/    /'

echo
echo "===== RV2: the trial's scratch really holds PEM private keys and the dev token (live capture) ====="
W2=$S/RV/scratch; rm -rf "$W2"; mkdir -p "$W2"/{home,tmp,work,copy}
( for i in $(seq 1 600); do
    for d in "$W2"/work/kagi-pki-trial.*; do
      [ -d "$d" ] || continue
      { echo "  files in the trial scratch:"; ls -1 "$d" | sed 's/^/    /'
        echo "  files holding a PEM private key:"
        grep -rlE 'PRIVATE KEY' "$d" 2>/dev/null | sed "s|$W2|$S|g" | sed 's/^/    /'
        echo "  files holding the dev-token shape:"
        grep -rlE 'r70-[0-9a-f]{24}' "$d" 2>/dev/null | sed "s|$W2|$S|g" | sed 's/^/    /'
        echo "  (the dev token itself is masked below)"
        grep -rhoE 'Root Token: r70-[0-9a-f]{24}' "$d" 2>/dev/null | sed -E 's/r70-[0-9a-f]{24}/<DEV-TOKEN-MASKED>/' | sort -u | sed 's/^/    /'
      } > "$R/probe-RV2-scratch-secrets.log" 2>/dev/null
      break
    done
    sleep 0.03
  done ) &
POLL=$!
HOME="$W2/home" TMPDIR="$W2/tmp" LANG=C bash "$TRIAL" --work "$W2/work" > "$W2/out" 2> "$W2/err"
echo "  trial rc=$?"
wait $POLL 2>/dev/null
cat "$R/probe-RV2-scratch-secrets.log"

echo
echo "===== RV3: N concurrent trial runs, natural port choice ====="
for N in 6 12; do
  W3=$S/RV/c$N; rm -rf "$W3"; mkdir -p "$W3"/{home,tmp}
  for i in $(seq 1 $N); do mkdir -p "$W3/w$i"; done
  for i in $(seq 1 $N); do
    ( HOME="$W3/home" TMPDIR="$W3/tmp" LANG=C bash "$TRIAL" --work "$W3/w$i" > "$W3/o$i" 2> "$W3/e$i" ) &
  done
  wait
  ok=0; setup=0; other=0
  for i in $(seq 1 $N); do
    last=$(grep '^OPENBAO_PKI_TRIAL: ' "$W3/o$i" 2>/dev/null | tail -1)
    case "$last" in *"HOLDS holds=5"*) ok=$((ok+1));; *"SETUP"*) setup=$((setup+1));; *) other=$((other+1));; esac
  done
  echo "  $N concurrent runs: HOLDS(5)=$ok SETUP=$setup other=$other ; dev servers left=[$(pgrep -f 'bao server -dev' | tr '\n' ' ')] scratch dirs left=$(find "$W3" -maxdepth 2 -name 'kagi-pki-trial.*' 2>/dev/null | wc -l)"
done
