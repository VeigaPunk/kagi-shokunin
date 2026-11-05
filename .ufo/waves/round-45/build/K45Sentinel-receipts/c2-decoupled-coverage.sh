#!/usr/bin/env bash
# K45Sentinel: is C2's LOCATED coupled to the admitted entry's own citations?
# Counter logic (plans/round-45-c2.sh):
#   entries = # knowledge files added after BASE whose FIRST 'source:' line cites an ADDED id
#   located = # quote-bodies.tsv rows whose id is in ADDED and that quote-locate does not report NOT-LOCATED
# The two sets are computed independently. Probe: build a tree where the 3 located quotes
# belong to ids the knowledge entry does NOT cite.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c2-dec-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=0d0192f63eb5e49826d75af1e5293004dc691a18
T="$S/tree"; mkdir -p "$T" && git -C "$LANE" archive "$BASE" | tar -x -C "$T" || exit 2
mkdir -p "$T/.ufo/waves/round-45/capture" "$T/corpus/knowledge"

mkrow() { # mkrow ID QUOTE URL
  local id="$1" q="$2" url="$3" body sha by ident
  body="$T/.ufo/waves/round-45/capture/$id.body"; printf '%s' "$q" > "$body"
  sha=$(sha256sum "$body" | cut -d' ' -f1); by=$(wc -c < "$body" | tr -d ' ')
  ident=$(printf '%s\tmined\t%s\n' "$id" "$url" | sha256sum | cut -d' ' -f1)
  printf '%s\tmined\t%s\t%s\t%s\t200\tcurl-fsSL-compressed-v1\t2026-11-05\tdecoded-http-body-v1\t%s\t%s\t-\t%s\traw-literal-v1\t-\tpage body\n' \
    "$id" "$ident" "$url" "$url" "$sha" "$by" "$q" >> "$T/corpus/source-fetches.tsv"
  printf '%s\t.ufo/waves/round-45/capture/%s.body\t0\t%s\n' "$id" "$id" "$q" >> "$T/corpus/quote-bodies.tsv"
  awk -v row="| $id | unrelated probe row — $url | docs | A | scope | anchor | $q | mined | 2026-11-05 | 180d | corpus/knowledge/iso-probe.md |" \
      '{print} /^\|-/ && !d {print row; d=1}' "$T/corpus/SOURCES.md" > "$T/x" && mv "$T/x" "$T/corpus/SOURCES.md"
}

# three ADDED ids that the knowledge entry will NOT cite
mkrow S200 "alpha quote body" "https://example.invalid/a"
mkrow S201 "beta quote body" "https://example.invalid/b"
mkrow S202 "gamma quote body" "https://example.invalid/c"
# a fourth ADDED id the entry DOES cite, with no located quote of its own
mkrow S203 "delta quote body" "https://example.invalid/d"

cat > "$T/corpus/knowledge/iso-probe.md" <<'EOF'
source: S203 — https://example.invalid/d — a claim the entry makes — fetched 2026-11-05
verified-at: 2026-11-05

# Probe entry

The entry asserts one thing and cites one id.
EOF

git -C "$LANE" show "$BASE:corpus/SOURCES.md" > "$S/base-SOURCES.md"
ids() { grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' "$1" | grep -oE 'S[0-9]+' | sort -u; }
ids "$S/base-SOURCES.md" > "$S/ids-base"; ids "$T/corpus/SOURCES.md" > "$S/ids-rev"
comm -13 "$S/ids-base" "$S/ids-rev" > "$S/ids-added"
added=$(wc -l < "$S/ids-added")
m_add=0; f_add=0
while IFS=$'\t' read -r rid _rest; do case $rid in ''|id) continue ;; esac; grep -qx "$rid" "$S/ids-added" && m_add=$((m_add+1)); done < "$T/corpus/quote-bodies.tsv"
while read -r kw rid _rest; do [ "$kw" = NOT-LOCATED ] || continue; grep -qx "$rid" "$S/ids-added" && f_add=$((f_add+1)); done <<<"$( cd "$T" && python3 corpus/quote-locate.py 2>&1 )"
located=$((m_add - f_add)); [ "$located" -lt 0 ] && located=0
entries=0
for f in "$T"/corpus/knowledge/*.md; do
  [ -f "$f" ] || continue
  src=$(grep -m1 '^source:' "$f" || true); [ -n "$src" ] || continue
  for id in $(grep -oE 'S[0-9]{3,}' <<<"$src" | sort -u); do grep -qx "$id" "$S/ids-added" && { entries=$((entries+1)); break; }; done
done
echo "C2 replay (decoupled): value=$located added=$added entries=$entries located=$located (rows-added=$m_add not-located-added=$f_add)"
echo "ids the entry cites: $(grep -oE 'S[0-9]{3,}' "$T/corpus/knowledge/iso-probe.md" | sort -u | tr '\n' ' ')"
echo "ids carrying the located quotes: $(comm -12 <(grep -oE 'S[0-9]{3,}' "$T/corpus/knowledge/iso-probe.md" | sort -u) <(cut -f1 "$T/corpus/quote-bodies.tsv" | sort -u) | tr '\n' ' ')(empty = none)"
