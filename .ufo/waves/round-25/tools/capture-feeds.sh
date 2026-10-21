#!/usr/bin/env bash
# capture-feeds.sh — round-25 C3: fetch each release-feed source under the
# declared request profile (curl-fsSL-compressed-v1) and print one 16-column
# corpus/source-fetches.tsv row per feed, refusing a non-200 response or a
# quote that does not occur byte-for-byte in the decoded body (raw-literal-v1).
# Usage: capture-feeds.sh OUTDIR   (bodies are kept in OUTDIR, never in the lane)
set -euo pipefail
out=${1:?usage: capture-feeds.sh OUTDIR}
mkdir -p -- "$out"
UA='kagi-shokunin-round23/1.0 (documentation verification)'
# id <TAB> url <TAB> quote <TAB> location
FEEDS=$(cat <<'EOF'
S033	https://github.com/getsops/sops/releases.atom	<title>v3.13.3</title>	first stable entry title (tag v3.13.3)
S034	https://github.com/hashicorp/vault/releases.atom	<title>v2.2.0</title>	first stable entry title (tag v2.2.0)
S035	https://github.com/openbao/openbao/releases.atom	<title>v2.7.1</title>	first stable entry title (tag v2.7.1)
S036	https://www.python.org/downloads/feed.rss	<title>Python 3.15.0</title>	newest stable item title (above it: Python 3.16.0a1, a prerelease)
S037	https://curl.se/info	Version: 8.23.0	line 1 (Version) of the release info file
EOF
)
rc=0
while IFS=$'\t' read -r id url quote location; do
  f="$out/$id.body"
  meta=$(curl -fsSL --compressed -A "$UA" -o "$f" -w '%{http_code}\t%{url_effective}' -- "$url") || { echo "FETCH-FAIL $id $url" >&2; rc=1; continue; }
  code=${meta%%$'\t'*}; final=${meta#*$'\t'}
  [[ $code == 200 ]] || { echo "HTTP-$code $id" >&2; rc=1; continue; }
  grep -qF -- "$quote" "$f" || { echo "QUOTE-MISSING $id" >&2; rc=1; continue; }
  sha=$(sha256sum -- "$f"); sha=${sha%% *}
  bytes=$(wc -c <"$f"); bytes=${bytes//[[:space:]]/}
  ident=$(printf '%s\t%s\t%s\n' "$id" mined "$url" | sha256sum); ident=${ident%% *}
  printf '%s\tmined\t%s\t%s\t%s\t%s\tcurl-fsSL-compressed-v1\t%s\tdecoded-http-body-volatile-v1\t%s\t%s\t-\t%s\traw-literal-v1\t-\t%s\n' \
    "$id" "$ident" "$url" "$final" "$code" "$(date -u +%F)" "$sha" "$bytes" "$quote" "$location"
done <<<"$FEEDS"
exit $rc
