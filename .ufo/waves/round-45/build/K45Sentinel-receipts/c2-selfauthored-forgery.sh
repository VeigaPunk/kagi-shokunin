#!/usr/bin/env bash
# K45Sentinel adversarial demo v2 (scratch only): the cheapest C2 LOCATED forgery --
# three ids whose "capture" bodies the seat WROTE ITSELF (quote pasted in), no live fetch.
# Everything happens in a scratch copy of the lane tree. The lane is untouched.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c2-forgery-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=0d0192f63eb5e49826d75af1e5293004dc691a18
T="$S/tree"
mkdir -p "$T" && git -C "$LANE" archive "$BASE" | tar -x -C "$T" || exit 2
mkdir -p "$T/.ufo/waves/round-45/capture" "$T/corpus/knowledge"

reg_insert() { # reg_insert ROW
  # insert a registry row inside the Registry table (after the header separator line)
  awk -v row="$1" '{print} /^\|-/ && !done {print row; done=1}' "$T/corpus/SOURCES.md" > "$T/corpus/SOURCES.md.new"
  mv "$T/corpus/SOURCES.md.new" "$T/corpus/SOURCES.md"
}

mk() { # mk ID QUOTE URL
  local id="$1" quote="$2" url="$3" body sha bytes ident
  body="$T/.ufo/waves/round-45/capture/$id.body"
  printf '%s' "$quote" > "$body"
  sha=$(sha256sum "$body" | cut -d' ' -f1)
  bytes=$(wc -c < "$body" | tr -d ' ')
  ident=$(printf '%s\tmined\t%s\n' "$id" "$url" | sha256sum | cut -d' ' -f1)
  printf '%s\tmined\t%s\t%s\t%s\t200\tcurl-fsSL-compressed-v1\t2026-11-05\tdecoded-http-body-v1\t%s\t%s\t-\t%s\traw-literal-v1\t-\tpage body\n' \
    "$id" "$ident" "$url" "$url" "$sha" "$bytes" "$quote" >> "$T/corpus/source-fetches.tsv"
  printf '%s\t.ufo/waves/round-45/capture/%s.body\t0\t%s\n' "$id" "$id" "$quote" >> "$T/corpus/quote-bodies.tsv"
  reg_insert "| $id | self-written capture — $url | docs | A | a scope the seat chose | the anchor the seat chose | $quote | mined | 2026-11-05 | 180d | corpus/knowledge/iso-11770-3-forgery.md |"
}

mk S100 "Withdrawal date 2021-10-22" "https://webstore.iec.ch/en/publication/62160"
mk S101 "Publication date 2021-10-22" "https://webstore.iec.ch/en/publication/71650"
mk S102 "Edition 4.0" "https://webstore.iec.ch/en/publication/107179"

cat > "$T/corpus/knowledge/iso-11770-3-forgery.md" <<'EOF'
source: S100 — https://webstore.iec.ch/en/publication/62160 — the withdrawal date field — fetched 2026-11-05
source: S101 — https://webstore.iec.ch/en/publication/71650 — the publication date field — fetched 2026-11-05
source: S102 — https://webstore.iec.ch/en/publication/107179 — the edition field — fetched 2026-11-05
verified-at: 2026-11-05

# Forgery probe

The 2015 edition was withdrawn: Withdrawal date 2021-10-22 [S100]
EOF

echo "=== quote-locate.py (bodies written by the seat; no fetch performed) ==="
( cd "$T" && python3 corpus/quote-locate.py --root "$T" ); echo "rc=$?"
echo "=== fleet census validate ==="
/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file "$T/corpus/SOURCES.md" > "$S/census.out" 2>&1; crc=$?
grep -E 'E[0-9]{2}' "$S/census.out" | cut -c1-160; echo "census rc=$crc (E-codes above, if any)"
echo "=== counter arithmetic, replayed on the scratch tree (ADDED/LOCATED as plans/round-45-c2.sh computes) ==="
git -C "$LANE" show "$BASE:corpus/SOURCES.md" > "$S/base-SOURCES.md"
ids() { grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' "$1" | grep -oE 'S[0-9]+' | sort -u; }
ids "$S/base-SOURCES.md" > "$S/ids-base"; ids "$T/corpus/SOURCES.md" > "$S/ids-rev"
comm -13 "$S/ids-base" "$S/ids-rev" > "$S/ids-added"
added=$(wc -l < "$S/ids-added")
m_add=0; f_add=0
while IFS=$'\t' read -r rid _rest; do case $rid in ''|id) continue ;; esac; grep -qx "$rid" "$S/ids-added" && m_add=$((m_add+1)); done < "$T/corpus/quote-bodies.tsv"
while read -r kw rid _rest; do [ "$kw" = NOT-LOCATED ] || continue; grep -qx "$rid" "$S/ids-added" && f_add=$((f_add+1)); done <<<"$( cd "$T" && python3 corpus/quote-locate.py 2>&1 )"
located=$((m_add - f_add)); [ "$located" -lt 0 ] && located=0
echo "C2_LOCATED (replayed): value=$located added=$added entries=1 census=$crc located=$located (rows-added=$m_add not-located-added=$f_add)"
