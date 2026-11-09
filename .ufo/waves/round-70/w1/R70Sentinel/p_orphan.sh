#!/usr/bin/env bash
# R70Sentinel probe H — SIGKILL: does the dev server survive as an orphan, and what exactly
# is left on disk? Re-verified with a unique env marker so the orphan is attributable.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
R=$WD/receipts
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
TRIAL=$LANE/corpus/openbao-pki-trial.sh
V="orphan_$$_x"
W=$S/H/kill; rm -rf "$W"; mkdir -p "$W"/{home,tmp,work}

echo "===== H: SIGKILL mid-run, marker-attributed ====="
env R70_SENTINEL_MARK="$V" HOME="$W/home" TMPDIR="$W/tmp" LANG=C \
  bash "$TRIAL" --work "$W/work" > "$W/out" 2> "$W/err" &
TP=$!
# wait for the dev server to be up and attributable to our marker
sp=""
for i in $(seq 1 100); do
  for p in $(pgrep -f 'bao server -dev' 2>/dev/null); do
    if tr '\0' '\n' < "/proc/$p/environ" 2>/dev/null | grep -qx "R70_SENTINEL_MARK=$V"; then sp=$p; fi
  done
  [ -n "$sp" ] && break
  sleep 0.05
done
echo "  our dev server pid=$sp (found after ~${i}50ms)"
echo "  killing the trial bash (pid $TP) with SIGKILL"
kill -9 "$TP" 2>/dev/null; wait "$TP" 2>/dev/null
sleep 2
echo "  after SIGKILL + 2s:"
echo "    our marker-carrying dev server still alive? $(kill -0 "$sp" 2>/dev/null && echo YES-ORPHAN || echo no)"
echo "    all bao server -dev now: [$(pgrep -f 'bao server -dev' | tr '\n' ' ')]"
echo "    scratch dirs left: $(ls -d "$W"/work/kagi-pki-trial.* 2>/dev/null | wc -l)"
for d in "$W"/work/kagi-pki-trial.*; do
  [ -d "$d" ] || continue
  echo "    PEM-private-key files in the surviving scratch: $(grep -rlE 'PRIVATE KEY' "$d" 2>/dev/null | wc -l)"
  echo "    dev-token-shaped files in the surviving scratch: $(grep -rlE 'r70-[0-9a-f]{24}' "$d" 2>/dev/null | wc -l)"
  echo "    home/.vault-token present: $( [ -e "$d/home/.vault-token" ] && echo yes || echo no )"
  echo "    home/.vault-token holds the dev token shape: $(grep -cE 'r70-[0-9a-f]{24}' "$d/home/.vault-token" 2>/dev/null)"
done
echo "  -> cleanup for this probe:"
for p in $(pgrep -f 'bao server -dev' 2>/dev/null); do kill -9 "$p" 2>/dev/null; done
rm -rf "$W"
echo "  dev servers after cleanup: [$(pgrep -f 'bao server -dev' | tr '\n' ' ')]"
