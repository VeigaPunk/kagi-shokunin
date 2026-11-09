#!/usr/bin/env bash
# R70Sentinel probe D — SIGTERM / SIGINT / SIGHUP delivered mid-run, with DEFAULT signal
# disposition. (A shell-launched `&` child inherits SIG_IGN for SIGINT and bash cannot
# un-ignore an inherited-ignored signal, so the signal is delivered from python instead.)
# Assertions: no `bao server` child alive; no scratch dir left.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
TRIAL=$LANE/corpus/openbao-pki-trial.sh
mkdir -p "$S/D" "$WD/receipts"

cat > "$S/D/spawn.py" <<'PY'
import os, signal, subprocess, sys, time, json
trial, work, sig, delay = sys.argv[1], sys.argv[2], sys.argv[3], float(sys.argv[4])
def pre():
    for s in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(s, signal.SIG_DFL)
env = dict(os.environ)
out = open(os.path.join(work, "out"), "wb"); err = open(os.path.join(work, "err"), "wb")
p = subprocess.Popen(["bash", trial, "--work", work], stdout=out, stderr=err, env=env, preexec_fn=pre)
time.sleep(delay)
try:
    p.send_signal(getattr(signal, "SIG" + sig))
except ProcessLookupError:
    pass
rc = p.wait(timeout=180)
out.close(); err.close()
lines = sum(1 for l in open(os.path.join(work, "out"), "rb") if l.startswith(b"TRIAL T"))
print(json.dumps({"sig": sig, "delay": delay, "rc": rc, "trial_lines": lines}))
PY

echo "===== PROBE D: signals delivered mid-run (default disposition) ====="
for sig in INT TERM HUP; do
  for d in 0.30 0.90 1.60; do
    W="$S/D/${sig}_${d}"; rm -rf "$W"; mkdir -p "$W"/{home,tmp}
    python3 "$S/D/spawn.py" "$TRIAL" "$W" "$sig" "$d"
  done
done
echo
echo "--- post-run state: dev servers and scratch dirs ---"
echo "  dev servers on the host: [$(pgrep -f 'bao server -dev' | tr '\n' ' ')]"
for sig in INT TERM HUP; do for d in 0.30 0.90 1.60; do
  W="$S/D/${sig}_${d}"
  echo "  ${sig}_${d}: scratch dirs left=$(ls -d "$W"/kagi-pki-trial.* 2>/dev/null | wc -l) trial_lines=$(grep -c '^TRIAL T' "$W/out" 2>/dev/null)"
done; done
