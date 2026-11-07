#!/usr/bin/env bash
# R56ExecLive offline replay driver (recovery rerun). Writes ONLY under /fast/scratch/hyaku/kagi-r56/R56ExecLive.
set -u
SCR=/fast/scratch/hyaku/kagi-r56/R56ExecLive
REC=$SCR/receipts
MIR=$SCR/mirror
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C45=$LANE/.ufo/waves/round-45/controls/capture-r45/S101.raw
C55=$LANE/.ufo/waves/round-55/capture
C56=$LANE/.ufo/waves/round-56/capture
cd "$MIR" || { echo "cd-failed"; exit 2; }

offgrep() {
  id=$1; cap=$2; pat=$3
  {
    echo "id=$id"
    echo "date_utc=$(date -u +%FT%TZ)"
    echo "capture=$cap"
    out=$(grep -c -e "$pat" "$cap"); rc=$?
    echo "count=$out"
    echo "rc=$rc"
    echo "-- first located lines --"
    grep -n -e "$pat" "$cap" 2>/dev/null | cut -c1-240 | head -3
  } > "$REC/$id.offline.txt"
}

offgrep S057 "$C56/S057.body" 'Each cache entry expires after three hours'
offgrep S054 "$C56/S054.body" 'it can also log in to confirm if that secret is live or not'
offgrep S055 "$C56/S055.body" 'Scans detect secrets without credential provider requests by default'
offgrep S067 "$C56/S067.body" 'It MUST contain the OAuth 2.0'
offgrep S074 "$C56/S074.body" 'public comment period is CLOSED'
offgrep S101 "$C45" 'Withdrawal of International Standard'
offgrep S113 "$C55/S113.body" 'ISO/IEC 11770-3:2021/Amd'
offgrep S114 "$C55/S114.body" 'International Standard published'

{
  echo "id=S078"
  echo "date_utc=$(date -u +%FT%TZ)"
  echo "capture=$C56/S078.body"
  out=$(pdftotext -layout "$C56/S078.body" - 2>/dev/null | grep -c -e 'has been withdrawn (archived)')
  rc=$?
  echo "count=$out"
  echo "rc=$rc"
  echo "-- located lines --"
  pdftotext -layout "$C56/S078.body" - 2>/dev/null | grep -n -e 'has been withdrawn (archived)' | cut -c1-240 | head -3
} > "$REC/S078.offline.txt"

{
  echo "id=S070"
  echo "date_utc=$(date -u +%FT%TZ)"
  echo "capture=$C56/S070.body"
  python3 corpus/rendered-text-v1.py locate "$C56/S070.body" 'The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator'
  echo "rc=$?"
  python3 corpus/rendered-text-v1.py digest "$C56/S070.body"
} > "$REC/S070.offline.txt" 2>&1

{
  for f in "$C45" "$C55/S113.body" "$C55/S114.body" "$C56/S054.body" "$C56/S055.body" "$C56/S057.body" "$C56/S067.body" "$C56/S070.body" "$C56/S074.body" "$C56/S078.body"; do
    printf '%s first12=' "$f"
    head -c 12 "$f" | od -An -c | tr -s ' '
    printf '%s statusline=%s setcookie_lines=%s\n' "$f" \
      "$(head -c 4096 "$f" | grep -c '^HTTP/[0-9]' 2>/dev/null)" \
      "$(LC_ALL=C grep -c -i '^set-cookie:' "$f" 2>/dev/null)"
  done
} > "$REC/capture-headercheck.txt" 2>&1

GM=$SCR/gmirror
rm -rf "$GM"
mkdir -p "$GM"
cp -r "$LANE/corpus" "$GM/corpus"
mkdir -p "$GM/.ufo/waves/round-45/controls/capture-r45" "$GM/.ufo/waves/round-55/capture" "$GM/.ufo/waves/round-56/capture"
cp "$C45" "$GM/.ufo/waves/round-45/controls/capture-r45/"
cp "$C55/S113.body" "$C55/S114.body" "$GM/.ufo/waves/round-55/capture/"
cp "$C56/S054.body" "$C56/S055.body" "$C56/S057.body" "$C56/S067.body" "$C56/S070.body" "$C56/S074.body" "$C56/S078.body" "$GM/.ufo/waves/round-56/capture/"
cd "$GM" || { echo "cd-gmirror-failed"; exit 2; }
{
  echo "date_utc=$(date -u +%FT%TZ)"
  echo "command: python3 -I -B corpus/recheck-replay.py   (cwd=$GM)"
  python3 -I -B corpus/recheck-replay.py
  echo "gate_rc=$?"
} > "$REC/gate-run.txt" 2>&1
{
  echo "date_utc=$(date -u +%FT%TZ)"
  echo "command: python3 -I -B corpus/recheck-replay.py --selftest"
  python3 -I -B corpus/recheck-replay.py --selftest
  echo "selftest_rc=$?"
} > "$REC/gate-selftest.txt" 2>&1
echo DONE
