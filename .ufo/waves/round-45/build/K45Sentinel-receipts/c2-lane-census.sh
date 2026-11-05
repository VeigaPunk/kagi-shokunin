set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c2-census-XXXXXX"); trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=0d0192f63eb5e49826d75af1e5293004dc691a18
T="$S/tree"; mkdir -p "$T"; git -C "$LANE" archive "$BASE" | tar -x -C "$T" || exit 2
mkdir -p "$T/.ufo/waves/round-45/capture" "$T/corpus/knowledge"
Q="Withdrawal date 2021-10-22"; URL="https://webstore.iec.ch/en/publication/62160"
B="$T/.ufo/waves/round-45/capture/S100.body"; printf '%s' "$Q" > "$B"
SHA=$(sha256sum "$B"|cut -d' ' -f1); BY=$(wc -c < "$B"|tr -d ' ')
ID=$(printf 'S100\tmined\t%s\n' "$URL"|sha256sum|cut -d' ' -f1)
printf 'S100\tmined\t%s\t%s\t%s\t200\tcurl-fsSL-compressed-v1\t2026-11-05\tdecoded-http-body-v1\t%s\t%s\t-\t%s\traw-literal-v1\t-\tpage body\n' "$ID" "$URL" "$URL" "$SHA" "$BY" "$Q" >> "$T/corpus/source-fetches.tsv"
printf 'S100\t.ufo/waves/round-45/capture/S100.body\t0\t%s\n' "$Q" >> "$T/corpus/quote-bodies.tsv"
awk -v row="| S100 | self-written capture — $URL | docs | A | a scope the seat chose | the anchor the seat chose | $Q | mined | 2026-11-05 | 180d | corpus/knowledge/iso-11770-3-forgery.md |" '{print} /^\|-/ && !d {print row; d=1}' "$T/corpus/SOURCES.md" > "$T/x"; mv "$T/x" "$T/corpus/SOURCES.md"
printf 'source: S100 — %s — the withdrawal date field — fetched 2026-11-05\nverified-at: 2026-11-05\n\n# probe\n\nWithdrawn: %s [S100]\n' "$URL" "$Q" > "$T/corpus/knowledge/iso-11770-3-forgery.md"
echo "=== LANE corpus/sources-census.sh verify on the forged tree ==="
bash "$LANE/corpus/sources-census.sh" verify --root "$T" 2>&1 | cut -c1-200
echo "rc=${PIPESTATUS[0]}"
