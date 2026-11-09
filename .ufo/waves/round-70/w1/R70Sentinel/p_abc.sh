#!/usr/bin/env bash
# R70Sentinel probe A/B/C — secret containment on the success path, the injected-failure
# path, and the SH1 exported-root path (whose response carries a private_key).
# Logs go to the wave dir so a sibling's scratch cleanup cannot take the evidence.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
TRIAL=$LANE/corpus/openbao-pki-trial.sh
mkdir -p "$S"/{A,B,C} "$WD/receipts"
# the counter's own NOSECRET expression (plans/round-70-c1.sh line 149)
ERE='PRIVATE KEY|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r70-[0-9a-f]{24}'

echo "############ PROBE A — success path ############"
mkdir -p "$S/A"/{home,tmp,work}
env -i HOME="$S/A/home" PATH="/home/vgpnk/.local/bin:/usr/bin:/bin" TMPDIR="$S/A/tmp" LANG=C \
  bash "$TRIAL" --work "$S/A/work" > "$S/A/out" 2> "$S/A/err"
echo "rc=$?"
echo "secret_ere_hits=$(cat "$S/A/out" "$S/A/err" | grep -cE "$ERE")"
echo "--- stdout ---"; cat "$S/A/out"
echo "--- stderr ---"; cat "$S/A/err"
echo "work dir left behind: [$(ls -A "$S/A/work" | tr '\n' ' ')]"
echo "TMPDIR leftovers: [$(ls -A "$S/A/tmp" | tr '\n' ' ')]"
echo "/tmp leftovers: [$(ls -d /tmp/kagi-pki-trial.* 2>/dev/null | tr '\n' ' ')]"

echo
echo "############ PROBE B — SH1 exported-root shim (response carries private_key) ############"
mkdir -p "$S/B"/{bin,home,tmp,work}
cat > "$S/B/bin/bao" <<'SH'
#!/bin/bash
REAL=/home/vgpnk/.local/bin/bao
P=""; if [ "${1:-}" = write ]; then for x in "${@:2}"; do case "$x" in -*) ;; *) P=$x; break;; esac; done; fi
case "$P" in */root/generate/internal) a=(); for x in "$@"; do if [ "$x" = "$P" ]; then a+=("${P%/internal}/exported"); else a+=("$x"); fi; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"
SH
chmod 755 "$S/B/bin/bao"
( for i in $(seq 1 400); do
    for f in "$S/B"/work/kagi-pki-trial.*/t1.json; do
      [ -f "$f" ] || continue
      echo "observed: $f size=$(wc -c < "$f") pem_lines=$(grep -c 'PRIVATE KEY' "$f" 2>/dev/null) key_field=$(grep -c '"private_key"' "$f" 2>/dev/null)" >> "$S/B/poll.txt"
      break
    done
    sleep 0.05
  done ) &
POLL=$!
env -i HOME="$S/B/home" PATH="$S/B/bin:/usr/bin:/bin" TMPDIR="$S/B/tmp" LANG=C \
  bash "$TRIAL" --work "$S/B/work" > "$S/B/out" 2> "$S/B/err"
echo "rc=$?"
wait $POLL 2>/dev/null
echo "poller observations (dedup):"; sort -u "$S/B/poll.txt" 2>/dev/null | sed 's/^/  /'
echo "secret_ere_hits=$(cat "$S/B/out" "$S/B/err" | grep -cE "$ERE")"
echo "--- stdout ---"; cat "$S/B/out"
echo "--- stderr ---"; cat "$S/B/err"
echo "occurrences of the literal field name in stdout: $(grep -c private_key "$S/B/out") (the KEY ITSELF is not printed)"
echo "work dir left behind (scratch removed?): [$(ls -A "$S/B/work" | tr '\n' ' ')]"

echo
echo "############ PROBE C — injected failure: PATH shim whose 'secrets enable' fails and leaks the live dev token ############"
mkdir -p "$S/C"/{bin,home,tmp,work}
cat > "$S/C/bin/bao" <<'SH'
#!/bin/bash
REAL=/home/vgpnk/.local/bin/bao
if [ "${1:-}" = secrets ] && [ "${2:-}" = enable ]; then
  printf 'Error enabling the secrets engine: permission denied\n' >&2
  printf 'token=%s\n' "$BAO_TOKEN" >&2
  printf '{"errors":["CANARY-0000-secret-leak-probe"]}\n'
  exit 1
fi
exec "$REAL" "$@"
SH
chmod 755 "$S/C/bin/bao"
env -i HOME="$S/C/home" PATH="$S/C/bin:/usr/bin:/bin" TMPDIR="$S/C/tmp" LANG=C \
  bash "$TRIAL" --work "$S/C/work" > "$S/C/out" 2> "$S/C/err"
echo "rc=$?"
echo "secret_ere_hits=$(cat "$S/C/out" "$S/C/err" | grep -cE "$ERE")"
echo "--- stdout ---"; cat "$S/C/out"
echo "--- stderr ---"; cat "$S/C/err"
echo "canary in stdout=$(grep -c CANARY-0000-secret-leak-probe "$S/C/out") stderr=$(grep -c CANARY-0000-secret-leak-probe "$S/C/err")"
echo "work dir left behind: [$(ls -A "$S/C/work" | tr '\n' ' ')]"
echo "live dev servers now: [$(pgrep -f 'bao server -dev' | tr '\n' ' ')]"
