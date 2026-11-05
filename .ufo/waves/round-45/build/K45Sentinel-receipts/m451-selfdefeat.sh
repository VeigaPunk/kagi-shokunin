set -u
S=$(mktemp -d /fast/scratch/hyaku/kagi-r45/K45Sentinel/sd-XXXXXX); trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
DRIFT="$LANE/.ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py"
BASE=307fb50da825d6e6f2b5c7981c71556d35611142
T="$S/tree"; mkdir -p "$T"; git -C "$LANE" archive "$BASE" | tar -x -C "$T" || exit 2
echo "=== is corpus/stamps.tsv itself stamped? ==="
awk -F'\t' '$1=="corpus/stamps.tsv"{print "yes line "NR} END{if(NR==0)print "no row"}' "$T/corpus/stamps.tsv" >/dev/null
grep -c '^corpus/stamps\.tsv	' "$T/corpus/stamps.tsv"
echo "=== self-defeat: alter LOG.md AND update its stamp cell ==="
printf 'X' >> "$T/LOG.md"
NEWSHA=$(sha256sum "$T/LOG.md" | cut -d' ' -f1)
NEWL=$(wc -l < "$T/LOG.md" | tr -d ' '); NEWB=$(wc -c < "$T/LOG.md" | tr -d ' ')
python3 - "$T/corpus/stamps.tsv" "$NEWSHA" "$NEWL" "$NEWB" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); sha, l, b = sys.argv[2], sys.argv[3], sys.argv[4]
out=[]
for line in p.read_text(encoding="utf-8").splitlines(True):
    if line.startswith("LOG.md\t"):
        cols=line.rstrip("\n").split("\t"); cols[1]=sha; cols[2]=l; cols[3]=b
        line="\t".join(cols)+"\n"
    out.append(line)
p.write_text("".join(out), encoding="utf-8")
PY
python3 "$DRIFT" "$T"; echo "rc=$?"
