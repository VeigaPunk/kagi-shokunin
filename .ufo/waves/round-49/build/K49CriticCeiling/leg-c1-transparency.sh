#!/usr/bin/env bash
# leg-c1-transparency.sh — candidate-side leg for round-49 C1 (seat K49CriticCeiling).
#
# The frozen counter decides DISCRIMINATE(T) from five behaviour shims (SH1..SH5): each shim
# is a small shell wrapper on PATH. A trial that never runs the mechanics can still pass by
# reading the identity of the `bao` on PATH (sha256, symlink-ness, path). This leg tells the
# two apart without changing the counter:
#
#   (a) STATIC: the trial source must not resolve the identity of the binary it runs
#       (hash, readlink/realpath, stat/file/xxd/od/head -c on it, `type -P`).
#   (b) DYNAMIC: run the trial with a TRANSPARENT logging wrapper on PATH. The wrapper has
#       exactly the real binary's behaviour (it execs it); it only records argv[1] argv[2]
#       (never a token-bearing argument) and passes everything through. A trial whose
#       verdicts come from server behaviour prints five HOLDS and its log shows the
#       dev-server and token/lease mechanics. A trial that decides from the bytes/type of
#       `bao` prints BROKEN here (the wrapper's bytes differ from the pinned binary), and a
#       constant-HOLDS trial leaves the log empty.
#
# PASS = (a) clean AND (b) five HOLDS and every required marker in the log.
# Exit 0 PASS, 1 FAIL, 2 setup. Nothing secret is printed: the log is never echoed.
#
# Usage: bash leg-c1-transparency.sh <trial.sh> [scratchdir]
set -u
TRIAL=${1:?usage: leg-c1-transparency.sh TRIAL [SCRATCH]}
REAL=${R49_BAO:-$HOME/.local/bin/bao}
PIN=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
[ -f "$TRIAL" ] || { echo "LEG_C1: SETUP trial-not-found=$TRIAL"; exit 2; }
[ -x "$REAL" ] || { echo "LEG_C1: SETUP bao-missing"; exit 2; }
[ "$(sha256sum < "$REAL" | cut -d' ' -f1)" = "$PIN" ] || { echo "LEG_C1: SETUP bao-pin-mismatch"; exit 2; }
if [ $# -ge 2 ]; then W=$2; mkdir -p "$W" || { echo "LEG_C1: SETUP scratch"; exit 2; }
else W=$(mktemp -d "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r49/leg-c1.XXXXXX") || { echo "LEG_C1: SETUP scratch"; exit 2; }; fi
mkdir -p "$W/home" "$W/tmp" "$W/wrap" || { echo "LEG_C1: SETUP scratch"; exit 2; }
LOG="$W/argv.log"; : > "$LOG"

# (a) static identity resolution
id_hits=$(grep -nE 'sha256sum|sha1sum|md5sum|b2sum|cksum|readlink|realpath|\[ -L |\bstat\b|\bfile \b|xxd|od -|head -c|type -P' "$TRIAL" || true)
id_hits=$(printf '%s\n' "$id_hits" | grep -c . || true)

# transparent wrapper: same behaviour, argv[1] argv[2] recorded, every argument passed through
{ printf '#!/bin/bash\nprintf "%%s %%s\\n" "${1:-}" "${2:-}" >> %q\nexec %q "$@"\n' "$LOG" "$REAL"; } > "$W/wrap/bao"
chmod 755 "$W/wrap/bao"
env -i HOME="$W/home" PATH="$W/wrap:/usr/bin:/bin" TMPDIR="$W/tmp" LANG=C \
  timeout 600 bash "$TRIAL" --work "$W/tmp" > "$W/out" 2> "$W/err"
rc=$?

missing=""; holds=0
for i in 1 2 3 4 5; do
  n=$(grep -cE "^TRIAL T$i HOLDS( |\$)" "$W/out")
  [ "$n" -eq 1 ] || missing="$missing T$i($n)"
  holds=$((holds + n))
done
final=$(grep -c '^OPENBAO_TRIAL: ' "$W/out")
markers=""
for m in '^server ' '^token create' '^token lookup' '^token renew' '^token revoke' '^login ' '^lease lookup' '^secrets enable' '^write -format=json'; do
  c=$(grep -cE "$m" "$LOG")
  [ "$c" -gt 0 ] || markers="$markers [${m#^}]=$c"
done
calls=$(grep -c . "$LOG" || true)

verdict=FAIL; why=""
[ "$id_hits" -eq 0 ] || why="$why identity-reads=$id_hits"
[ -z "$missing" ] || why="$why holds-missing:$missing"
[ "$holds" -eq 5 ] || why="$why holds=$holds"
[ "$final" -ge 1 ] || why="$why no-final-line"
[ -z "$markers" ] || why="$why mechanics-not-executed:$markers"
if [ -z "$why" ]; then verdict=PASS; fi
echo "LEG_C1: $verdict trial=$(basename "$TRIAL") rc=$rc identity_reads=$id_hits holds=$holds calls=$calls$why"
[ "$verdict" = PASS ] || [ -n "$why" ]
[ "$verdict" = PASS ] && exit 0 || exit 1
