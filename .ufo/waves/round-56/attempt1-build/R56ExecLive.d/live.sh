#!/usr/bin/env bash
# R56ExecLive live replay driver. Writes ONLY under /fast/scratch/hyaku/kagi-r56/R56ExecLive.
# Runs the 10 exact stated recheck commands (byte-for-byte) plus one instrumented
# body fetch per URL (receipt profile, no response headers stored; only the -w
# status/size/url/content_type line is kept).
set -u
SCR=/fast/scratch/hyaku/kagi-r56/R56ExecLive
REC=$SCR/receipts
BOD=$SCR/live-body
MIR=$SCR/mirror
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'
cp "$LANE/corpus/rendered-text-v1.py" "$MIR/corpus/rendered-text-v1.py"
cd "$MIR" || { echo "cd-failed"; exit 2; }

clock() {
  id=$1
  {
    echo "id=$id"
    echo "date_utc=$(date -u +%FT%TZ)"
    echo "command: $2"
    out=$(bash -c "$2" 2>"$REC/$id.stderr.txt"); rc=$?
    echo "stdout=<$out>"
    echo "rc_default=$rc"
    out2=$(bash -o pipefail -c "$2" 2>/dev/null); rc2=$?
    echo "rc_pipefail=$rc2"
  } > "$REC/$id.live.txt"
  eval "$3" > "$REC/$id.wline.txt" 2>"$REC/$id.fetch.err"
  echo "fetch_rc=$?" >> "$REC/$id.live.txt"
  sha256sum "$BOD/$id.body" > "$REC/$id.livebody.sha256"
  wc -c < "$BOD/$id.body" >> "$REC/$id.livebody.sha256"
}

# 1. S057 trufflehog-verification-lifecycle.md:4 (grep)
clock S057 \
"curl -fsSL 'https://trufflesecurity.com/docs/verification-caching' | grep -c 'Each cache entry expires after three hours'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S057.body' -w 'S057 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://trufflesecurity.com/docs/verification-caching'"
grep -n -e 'Each cache entry expires after three hours' "$BOD/S057.body" | cut -c1-240 > "$REC/S057.loc.txt"

# 2. S054 secret-scanning-detection-vs-validation.md:4 (grep)
clock S054 \
"curl -fsSL 'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md' | grep -c 'it can also log in to confirm if that secret is live or not'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S054.body' -w 'S054 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md'"
grep -n -e 'it can also log in to confirm if that secret is live or not' "$BOD/S054.body" | cut -c1-240 > "$REC/S054.loc.txt"

# 3. S055 betterleaks-detection-vs-validation.md:4 (grep)
clock S055 \
"curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -c 'Scans detect secrets without credential provider requests by default'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S055.body' -w 'S055 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md'"
grep -n -e 'Scans detect secrets without credential provider requests by default' "$BOD/S055.body" | cut -c1-240 > "$REC/S055.loc.txt"

# 4. S067 oidc-federation-trust-policy.md:3 (grep)
clock S067 \
"curl -fsSL --max-time 30 'https://openid.net/specs/openid-connect-core-1_0.html' | grep -c 'It MUST contain the OAuth 2.0'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S067.body' -w 'S067 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://openid.net/specs/openid-connect-core-1_0.html'"
grep -n -e 'It MUST contain the OAuth 2.0' "$BOD/S067.body" | cut -c1-240 > "$REC/S067.loc.txt"

# 5. S070 cdp-bridge-1password-oidc-workflow.md:3 (rendered-text locate, exact stated command)
clock S070 \
"curl -fsSL --max-time 30 'https://www.1password.dev/brokered-access/custom-workflow' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S070.body' -w 'S070 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://www.1password.dev/brokered-access/custom-workflow'"
{ python3 corpus/rendered-text-v1.py digest "$BOD/S070.body"
  grep -n -o 'The client authenticates using your OIDC token' "$BOD/S070.body" | head -3; } > "$REC/S070.loc.txt" 2>&1

# 6. S074 nist-key-management-guidance-status.md:3 (grep)
clock S074 \
"curl -fsSL 'https://csrc.nist.gov/pubs/sp/800/133/r3/ipd' | grep -c 'public comment period is CLOSED'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S074.body' -w 'S074 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://csrc.nist.gov/pubs/sp/800/133/r3/ipd'"
grep -n -e 'public comment period is CLOSED' "$BOD/S074.body" | cut -c1-240 > "$REC/S074.loc.txt"

# 7. S078 nist-key-management-parts-withdrawal.md:3 (pdftotext)
clock S078 \
"curl -fsSL 'https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf' | pdftotext -layout - - | grep -c 'has been withdrawn (archived)'" \
"curl -fsSL --compressed --max-time 60 -o '$BOD/S078.body' -w 'S078 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf'"
pdftotext -layout "$BOD/S078.body" - 2>/dev/null | grep -n -e 'has been withdrawn (archived)' | cut -c1-240 > "$REC/S078.loc.txt"

# 8-10. iso-11770-3-edition-status.md:3 (three grep clocks, pinned UA)
clock S101 \
"curl -fsSL -A '$UA' 'https://www.iso.org/standard/60237.html' | grep -c 'Withdrawal of International Standard'" \
"curl -fsSL --compressed --max-time 60 -A '$UA' -o '$BOD/S101.body' -w 'S101 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://www.iso.org/standard/60237.html'"
grep -n -e 'Withdrawal of International Standard' "$BOD/S101.body" | cut -c1-240 > "$REC/S101.loc.txt"

clock S113 \
"curl -fsSL -A '$UA' 'https://www.iso.org/standard/82709.html' | grep -c 'ISO/IEC 11770-3:2021/Amd'" \
"curl -fsSL --compressed --max-time 60 -A '$UA' -o '$BOD/S113.body' -w 'S113 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://www.iso.org/standard/82709.html'"
grep -n -e 'ISO/IEC 11770-3:2021/Amd' "$BOD/S113.body" | cut -c1-240 > "$REC/S113.loc.txt"

clock S114 \
"curl -fsSL -A '$UA' 'https://www.iso.org/standard/85929.html' | grep -c 'International Standard published'" \
"curl -fsSL --compressed --max-time 60 -A '$UA' -o '$BOD/S114.body' -w 'S114 %{http_code} %{size_download} %{url_effective} %{content_type}\n' 'https://www.iso.org/standard/85929.html'"
grep -n -e 'International Standard published' "$BOD/S114.body" | cut -c1-240 > "$REC/S114.loc.txt"

echo DONE
