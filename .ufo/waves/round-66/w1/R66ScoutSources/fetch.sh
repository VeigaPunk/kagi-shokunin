#!/usr/bin/env bash
# R66ScoutSources — frontier re-open receipt generator (read-only wrt the lane repo)
set -u
S="${1:?scratch dir}"
OUT="$S/receipt"
mkdir -p "$OUT"
UA_BROWSER='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
LOG="$OUT/fetch.log"
: > "$LOG"

fetch() { # name url ua outfile
  local name="$1" url="$2" ua="$3" out="$4"
  local code size final
  read -r code size final < <(curl -sS -L --compressed -A "$ua" \
      -o "$out" -w '%{http_code} %{size_download} %{url_effective}' "$url" 2>>"$LOG")
  local sha bytes
  sha=$(sha256sum "$out" | cut -d' ' -f1)
  bytes=$(stat -c%s "$out")
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$name" "2026-11-08" "$code" "$bytes" "$sha" "$url" "$final" "$(date -Iseconds)" \
    >> "$OUT/manifest.tsv"
  printf '== %s status=%s bytes=%s sha=%s final=%s\n' "$name" "$code" "$bytes" "$sha" "$final" >> "$LOG"
  sleep 21   # NCBI per-user rate limit: 3 requests/second, one per 21 s to stay clear
}

{
printf 'name\taccess_date\thttp_status\tbytes\tsha256\turl\tfinal_url\tfetched_at\n'
} > "$OUT/manifest.tsv"

# 1. S148 carrier — NCBI BioC XML deposit (the C1 carrier)
fetch S148_bioc 'https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode' "$UA_BROWSER" "$OUT/S148_bioc.body"
# 2. S155 carrier — PMC2757457 through the eutils EFetch carrier (S135's URL)
fetch S155_eutils 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml' "$UA_BROWSER" "$OUT/S155_eutils.body"
# 3. equivalent-mutant lead, reject A — the publisher record (unopened citation chain)
fetch LEAD_dlacm 'https://dl.acm.org/doi/10.1145/3650212.3680310' "$UA_BROWSER" "$OUT/LEAD_dlacm.body"
# 4. equivalent-mutant survey page, reject B — SpringerLink chapter under the lane's declared browser UA
fetch LEAD_springer 'https://link.springer.com/chapter/10.1007/978-3-031-92474-3_4' "$UA_BROWSER" "$OUT/LEAD_springer.body"
# 5. equivalent-mutant peer-reviewed candidate (admit candidate) — arXiv abstract page
fetch CAND_arxiv2404 'https://arxiv.org/abs/2404.09241' "$UA_BROWSER" "$OUT/CAND_arxiv2404.body"

cat "$OUT/manifest.tsv"
