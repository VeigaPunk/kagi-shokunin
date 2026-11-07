#!/usr/bin/env bash
# R55SentinelScope — reproducible scope / refusal-boundary / misroot scan.
# Read-only against the lane and the fleet root. Never prints a needle, a cookie
# value, or a credential shape: only file:line and counts.
set -uo pipefail
export LC_ALL=C

L=/home/vgpnk/Projects/shokunin/kagi-shokunin
F=/home/vgpnk/Projects/shokunin
B=ebe095857a734caf5efdd7bd776feb22b4e23972
C=348aa3b8ea7298aeb2f4d69db321fe827a92ae4f
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r55/R55SentinelScope
mkdir -p -- "$S"
trap 'rm -rf -- "$S/t"' EXIT
mkdir -p -- "$S/t"

printf 'BASE=%s\nCAND=%s\n' "$(git -C "$L" rev-parse "$B")" "$(git -C "$L" rev-parse "$C")"
printf 'HEAD=%s\n' "$(git -C "$L" rev-parse HEAD)"

# --- check 1a: changed paths stay inside the lane -----------------------------
git -C "$L" diff --name-status "$B" "$C" >"$S/t/ns.txt"
printf '\n[1a] files_changed=%s\n' "$(wc -l <"$S/t/ns.txt")"
printf '[1a] absolute_or_dotdot_paths=%s (expect 0)\n' \
  "$(awk '{print $2}' "$S/t/ns.txt" | grep -cE '(^/|(^|/)\.\.(/|$))')"
printf '[1a] top_level_dirs_touched:\n'
awk '{print $2}' "$S/t/ns.txt" | cut -d/ -f1 | sort | uniq -c | sed 's/^/     /'

# --- check 1b: credential shapes in ADDED lines -------------------------------
# CRED_RE is taken verbatim from the lane census (fragments reassembled here so
# this receipt carries no needle literal).
scheme=op; CRED_RE=
eval "$(awk '/^CRED_RE[+]?=/{print}' "$L/corpus/sources-census.sh")"
printf '\n[1b] CRED_RE assembled from corpus/sources-census.sh (%s bytes)\n' "${#CRED_RE}"
# sensitivity: every needle family the census generates must be caught
sed -n '/^needle() {/,/^}/p' "$L/corpus/sources-census.sh" >"$S/t/needle.sh"
rep() { printf "%${2}s" '' | tr ' ' "$1"; }
# shellcheck disable=SC1090
. "$S/t/needle.sh"
det=0
for k in 0 1 2 3 4 5 6; do needle "$k" | grep -qE -- "$CRED_RE" && det=$((det + 1)); done
printf '[1b] needle_families_detected=%s/7\n' "$det"
printf '[1b] false_positive_on_plain_url=%s (expect 0)\n' \
  "$(printf 'https://www.iso.org/standard/82709.html\n' | grep -cE -- "$CRED_RE")"
git -C "$L" diff "$B" "$C" >"$S/t/full.diff"
printf '[1b] added_lines_scanned=%s\n' "$(awk '/^\+/&&!/^\+\+\+ /' "$S/t/full.diff" | wc -l)"
awk '/^\+/&&!/^\+\+\+ /' "$S/t/full.diff" | grep -cE -- "$CRED_RE" | sed 's/^/[1b] credential_shape_hits=/'

# --- check 1c: cookie / userinfo / private-host shapes in ADDED lines ---------
printf '\n[1c] set-cookie|jsessionid|awsalb|__cf_bm hits in added lines:\n'
awk '/^\+\+\+ /{f=$2; sub(/^b\//,"",f)} /^\+/&&!/^\+\+\+ /{if (tolower($0) ~ /set-cookie|jsessionid|awsalb|__cf_bm/) print f}' "$S/t/full.diff" \
  | sort | uniq -c | sed 's/^/     /'
printf '[1c] userinfo_embedded_urls=%s (expect 0)\n' \
  "$(awk '/^\+/&&!/^\+\+\+ /' "$S/t/full.diff" | grep -oE '://[A-Za-z0-9._%+-]+@[^ ]+' | wc -l)"
printf '[1c] private_host_shapes=%s (expect 0)\n' \
  "$(awk '/^\+/&&!/^\+\+\+ /' "$S/t/full.diff" | grep -cE 'localhost|127\.0\.0\.1|10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.|\.internal|the-janitor')"

# --- check 2: captures are the public pages they claim ------------------------
printf '\n[2] committed capture digests (sha256, size):\n'
for f in S113 S114; do
  b="$L/.ufo/waves/round-55/capture/$f.body"
  printf '     %s %s %s\n' "$f" "$(sha256sum "$b" | cut -c1-64)" "$(stat -c%s "$b")"
  printf '     %s registry  %s %s\n' "$f" \
    "$(awk -F'\t' -v id="$f" '$1==id{print $10}' "$L/corpus/source-fetches.tsv")" \
    "$(awk -F'\t' -v id="$f" '$1==id{print $11}' "$L/corpus/source-fetches.tsv")"
  printf '     %s meta      %s\n' "$f" "$(cat "$L/.ufo/waves/round-55/capture/$f.meta")"
done
printf '[2] capture titles:\n'
for f in S113 S114; do
  printf '     %s %s\n' "$f" "$(sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' "$L/.ufo/waves/round-55/capture/$f.body" | head -1 | sed 's/^ *//' | cut -c1-70)"
done
printf '[2] rejection receipts:\n'
for m in "$L"/.ufo/waves/round-55/capture/rejections/*.meta; do
  printf '     %s :: %s\n' "$(basename "$m")" "$(head -1 "$m" | cut -c1-96)"
done
printf '[2] Set-Cookie lines committed (file:line, cookie NAME only, value never printed):\n'
for f in S113 S114; do
  while IFS= read -r ln; do
    [ -n "$ln" ] || continue
    n=${ln%%:*}
    rest=${ln#*:}; rest=${rest# }; rest=${rest#Set-Cookie:}; rest=${rest#set-cookie:}; rest=${rest# }
    name=${rest%%=*}
    printf '     %s.headers:%s cookie=%s value_len=%s\n' "$f" "$n" "$name" "$(( ${#rest} - ${#name} - 1 ))"
  done < <(grep -in '^set-cookie:' "$L/.ufo/waves/round-55/capture/$f.headers")
done
printf '[2] gates consuming *.headers in the lane: census=%s claim-ledger=%s\n' \
  "$(grep -c 'headers' "$L/corpus/sources-census.sh")" \
  "$([ -f "$L/corpus/claim-ledger.sh" ] && grep -c 'headers' "$L/corpus/claim-ledger.sh" || echo absent)"

# --- check 3: fleet-root misroots --------------------------------------------
git -C "$F" status --porcelain >"$S/t/fleet.txt"
printf '\n[3] fleet_root_status_entries=%s\n' "$(wc -l <"$S/t/fleet.txt")"
printf '[3] entries_naming_kagi_round55_r55=%s (expect 0)\n' \
  "$(grep -ciE 'kagi|round-55|r55' "$S/t/fleet.txt")"
printf '[3] status entries:\n'
cut -c1-100 "$S/t/fleet.txt" | sed 's/^/     /'

# --- check 4: /tmp citations in committed files of this round ----------------
printf '\n[4] /tmp/ occurrences in diff=%s (expect 0)\n' "$(grep -c '/tmp/' "$S/t/full.diff")"
printf '[4] /tmp/ in added lines=%s (expect 0)\n' \
  "$(awk '/^\+/&&!/^\+\+\+ /' "$S/t/full.diff" | grep -c '/tmp/')"
printf '[4] scratch-path citations in added lines (informational):\n'
awk '/^\+\+\+ /{f=$2; sub(/^b\//,"",f)} /^\+/&&!/^\+\+\+ /{if ($0 ~ /\/fast\/scratch|hyaku/) printf "     %s\n", f}' "$S/t/full.diff" | sort | uniq -c | sed 's/^ *\([0-9]*\) *\(.*\)/     \1 \2/'

# --- check 5: CSRF / session-token literals in added lines -------------------
printf '\n[5] token-literal scans over added lines (expect all 0):\n'
for pat in 'form_key["'"'"']?[[:space:]]*=[[:space:]]*["'"'"'][a-zA-Z0-9]{16,}' \
           'PHPSESSID=' 'mage-cache-sessid=' 'X-Magento-Form-Key' 'csrf[_-]?token=[A-Za-z0-9]'; do
  n=$(awk '/^\+/&&!/^\+\+\+ /' "$S/t/full.diff" | grep -cE -- "$pat")
  printf '     %-52s %s\n' "$pat" "$n"
done
printf '[5] registry/script references to the round-55 .headers artifacts (expect 0):\n'
printf '     capture/S11[34].headers in tsv|sh|json|md: %s\n' \
  "$(grep -rlE 'capture/S11[34]\.headers' "$L"/corpus "$L"/plans 2>/dev/null | wc -l)"
printf '     any column|field named headers in corpus/*.tsv: %s\n' \
  "$(grep -lE '(^|\t)headers(\t|$)' "$L"/corpus/*.tsv 2>/dev/null | wc -l)"
