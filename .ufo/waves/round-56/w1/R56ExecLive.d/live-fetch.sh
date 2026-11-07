#!/usr/bin/env bash
# R56ExecLive-2 live re-fetch driver. Public GETs only. Bodies in scratch only; no -D/-i (no response headers stored).
set -u
SCR=/fast/scratch/hyaku/kagi-r56/R56ExecLive-2
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=832ba6a53d6a76706b5c80bce2278683dea33d42
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'
cd "$SCR" || exit 9
for t in curl grep pdftotext python3 sha256sum git; do command -v "$t" >/dev/null || { echo "MISSING $t"; exit 9; }; done
git -C "$LANE" show "$BASE:corpus/rendered-text-v1.py" > corpus/rendered-text-v1.py || exit 9
: > summary.tsv
mkdir -p live iso-probe

# clock ID URL MAXT UA FORM PATTERN STATED_N CAPTURE_RELPATH EXPECT_SHA EXPECT_BYTES
clock() {
  local id="$1" url="$2" maxt="$3" ua="$4" form="$5" pat="$6" stated="$7" cap="$8" esha="$9" ebytes="${10}"
  local d="live/$id"; mkdir -p "$d"
  local ca=(curl -fsSL)
  [ -n "$maxt" ] && ca+=(--max-time "$maxt")
  [ -n "$ua" ] && ca+=(-A "$ua")
  # (A) exact stated command shape, piped through its filter
  case "$form" in
    grep)   "${ca[@]}" "$url" | grep -c -e "$pat" > "$d/pipe.out" 2> "$d/pipe.err" ;;
    pdf)    "${ca[@]}" "$url" | pdftotext -layout - - | grep -c -e "$pat" > "$d/pipe.out" 2> "$d/pipe.err" ;;
    locate) "${ca[@]}" "$url" | python3 corpus/rendered-text-v1.py locate /dev/stdin "$pat" > "$d/pipe.out" 2> "$d/pipe.err" ;;
  esac
  local prc=$?
  local pcount; pcount=$(tr -cd '0-9\n' < "$d/pipe.out" | grep -o '[0-9]\+' | tail -n 1)
  # (B) status/digest fetch of the same URL (body to scratch only)
  local src=1
  "${ca[@]}" -o "$d/body" -w '%{http_code} %{size_download} %{url_effective}\n' "$url" > "$d/status.txt" 2> "$d/fetch.err" || src=$?
  local lsha=""; [ -s "$d/body" ] && lsha=$(sha256sum "$d/body" | cut -d' ' -f1)
  # (C) filter on the live body (cross-check of the pipe count)
  local bcount
  case "$form" in
    grep)   bcount=$(grep -c -e "$pat" "$d/body" 2>/dev/null) ;;
    pdf)    bcount=$(pdftotext -layout "$d/body" - 2>/dev/null | grep -c -e "$pat") ;;
    locate) bcount=$(python3 corpus/rendered-text-v1.py locate "$d/body" "$pat" 2>/dev/null | grep -o 'count=[0-9]*' | cut -d= -f2) ;;
  esac
  # (D) committed capture replay + digest check
  local cpath="$LANE/$cap" csha="—" cbytes="—" crep="—"
  if [ -f "$cpath" ]; then
    csha=$(sha256sum "$cpath" | cut -d' ' -f1); cbytes=$(wc -c < "$cpath" | tr -d ' ')
    case "$form" in
      grep)   crep=$(grep -c -e "$pat" "$cpath" 2>/dev/null) ;;
      pdf)    crep=$(pdftotext -layout "$cpath" - 2>/dev/null | grep -c -e "$pat") ;;
      locate) crep=$(python3 corpus/rendered-text-v1.py locate "$cpath" "$pat" 2>/dev/null | grep -o 'count=[0-9]*' | cut -d= -f2) ;;
    esac
  fi
  local shaok=no; [ "$csha" = "$esha" ] && [ "$cbytes" = "$ebytes" ] && shaok=yes
  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$id" "${pcount:-}" "$prc" "$(cat "$d/status.txt" 2>/dev/null | tr '\n' ' ')" "src_rc=$src" "$lsha" "${bcount:-}" "$crep" "$shaok" "$stated" "$cap" >> summary.tsv
}

clock C1  'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' 60 '' grep 'Scans detect secrets without credential provider requests by default' 1 '.ufo/waves/round-56/capture/S055.body' f61c3993fd48dfb973652b9676697f4d37404fad9f30748c2003127eb81a73b1 13252 &
clock C2  'https://www.1password.dev/brokered-access/custom-workflow' 30 '' locate 'The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator' 1 '.ufo/waves/round-56/capture/S070.body' 5c226c06413854281f229aa0831f3fa7b9e63cdd3d2a4bf761f2226652a1c0dd 268454 &
clock C3  'https://www.iso.org/standard/60237.html' 60 "$UA" grep 'Withdrawal of International Standard' 2 '.ufo/waves/round-45/controls/capture-r45/S101.raw' 2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80 85615 &
clock C4  'https://www.iso.org/standard/82709.html' 60 "$UA" grep 'ISO/IEC 11770-3:2021/Amd' 3 '.ufo/waves/round-55/capture/S113.body' d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357 90604 &
clock C5  'https://www.iso.org/standard/85929.html' 60 "$UA" grep 'International Standard published' 2 '.ufo/waves/round-55/capture/S114.body' 8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf 85138 &
clock C6  'https://csrc.nist.gov/pubs/sp/800/133/r3/ipd' 60 '' grep 'public comment period is CLOSED' 1 '.ufo/waves/round-56/capture/S074.body' df32e64b9cce734698974dde083feeeaa7d34eef2e6c6391c7694ea7f29c3688 45351 &
clock C7  'https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf' 120 '' pdf 'has been withdrawn (archived)' 1 '.ufo/waves/round-56/capture/S078.body' 68266cb10868a1fee83fb8bcebbee9573fc738cee9141ee94d03649bad8538d5 622785 &
clock C8  'https://openid.net/specs/openid-connect-core-1_0.html' 30 '' grep 'It MUST contain the OAuth 2.0' 1 '.ufo/waves/round-56/capture/S067.body' 4d016752a645e8a3c259baa4173b5a90cb6c82898ce868fc8444adde262a5aed 437508 &
clock C9  'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md' 60 '' grep 'it can also log in to confirm if that secret is live or not' 1 '.ufo/waves/round-56/capture/S054.body' 7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7 38524 &
clock C10 'https://trufflesecurity.com/docs/verification-caching' 60 '' grep 'Each cache entry expires after three hours' 1 '.ufo/waves/round-56/capture/S057.body' 221d80fae1227db73c5f65ff71080d72e6e91666856a1dd8e1e2d402dfe9604b 110710 &
wait

# ISO default-UA probes (evidence for the S113-row 403 claim); no -f so the status is captured, no UA sent
probe() {
  local id="$1" url="$2"
  curl -sS --max-time 60 -o "iso-probe/$id.body" -w '%{http_code} %{size_download}\n' "$url" > "iso-probe/$id.status" 2> "iso-probe/$id.err"
  echo "rc=$?" >> "iso-probe/$id.status"
}
probe S113-default-ua 'https://www.iso.org/standard/82709.html' &
probe S101-default-ua 'https://www.iso.org/standard/60237.html' &
probe S114-default-ua 'https://www.iso.org/standard/85929.html' &
wait
echo DONE
