#!/usr/bin/env bash
# R70Sentinel probe G — the last hygiene items.
#  G1: SIGKILL cannot be trapped: does the trial's scratch (leaf private keys, the dev root
#      token in server.log, a .vault-token file) survive on disk?
#  G2: does the counter remove its whole scratch tree on exit (including the trial's)?
#  G3: the trial's own header claims about the token ("lives only in scratch and is never
#      printed") vs the token's presence in the process argv.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
R=$WD/receipts
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
TRIAL=$LANE/corpus/openbao-pki-trial.sh
mkdir -p "$S/G"

echo "===== G1: SIGKILL mid-run — does the scratch survive with secrets on disk? ====="
W=$S/G/kill; rm -rf "$W"; mkdir -p "$W"/{home,tmp,work}
HOME="$W/home" TMPDIR="$W/tmp" LANG=C bash "$TRIAL" --work "$W/work" > "$W/out" 2> "$W/err" &
TP=$!
sleep 2.0
echo "  killing the trial with SIGKILL (pid $TP) — no trap can run"
kill -9 "$TP" 2>/dev/null; wait "$TP" 2>/dev/null
sleep 1
echo "  scratch dirs left under --work: $(ls -d "$W"/work/kagi-pki-trial.* 2>/dev/null | wc -l)"
for d in "$W"/work/kagi-pki-trial.*; do
  [ -d "$d" ] || continue
  echo "  surviving scratch $d:"
  ls -A "$d" | sed 's/^/    file: /'
  echo "    files holding a PEM private key: $(grep -rlE 'PRIVATE KEY' "$d" 2>/dev/null | wc -l)"
  echo "    files holding the dev root token shape: $(grep -rlE 'r70-[0-9a-f]{24}' "$d" 2>/dev/null | wc -l)"
  echo "    a .vault-token file present: $( [ -e "$d/home/.vault-token" ] && echo yes || echo no )"
done
echo "  dev servers left: [$(pgrep -f 'bao server -dev' | tr '\n' ' ')]"
echo "  -> a SIGKILLed trial leaves its leaf private keys, its dev root token (server.log)"
echo "     and a .vault-token file on disk, and leaves the dev server running."
# clean up
for p in $(pgrep -f 'bao server -dev' 2>/dev/null); do kill -9 "$p" 2>/dev/null; done
rm -rf "$W"

echo
echo "===== G2: does the counter remove its whole scratch tree (including the trial's) on exit? ====="
HYAKU_SCRATCH="$S" bash "$LANE/plans/round-70-c1.sh" --tree "$LANE/.ufo/waves/round-70/controls/p1" > /dev/null 2>&1
echo "  counter scratch trees left under $S/kagi-r70: $(ls -d "$S"/kagi-r70/c1-counter.* 2>/dev/null | wc -l)"
grep -n 'trap .rm -rf' "$LANE/plans/round-70-c1.sh" | sed 's/^/    /'

echo
echo "===== G3: the trial's own token claim vs the token's real locations ====="
grep -n 'dev root token is random' "$LANE/corpus/openbao-pki-trial.sh" | sed 's/^/  /'
echo "  the token is passed on the command line:"
grep -n 'dev-root-token-id' "$LANE/corpus/openbao-pki-trial.sh" | sed 's/^/    /'
echo "  and is therefore in the process argv, readable by any local user via /proc/<pid>/cmdline:"
grep ' /proc ' /proc/mounts | sed 's/^/    mount: /'
stat -c '    /proc/self/cmdline mode: %A' /proc/self/cmdline
echo "  the lane's own controls runner captured exactly that argv into a committed receipt:"
grep -n 'cmdline' "$LANE/plans/round-70-controls.sh" | sed 's/^/    /'
sed 's/^/    /' "$LANE/.ufo/waves/round-70/controls/receipts/README.txt"
