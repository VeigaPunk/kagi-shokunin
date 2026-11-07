#!/usr/bin/env bash
# R56LabratCeiling -- bounded ceiling probe. Scratch only; lane read via git archive (no mutation).
set -u
SCR=/fast/scratch/hyaku/kagi-r56/R56LabratCeiling
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
PRE=42070de7770e1558adcf6aa7a7bc59309a9654d7
PHRASE='it can also log in to confirm if that secret is live or not'

echo "### phase1: trees from git archive of predeclaration $PRE"
rm -rf "$SCR/base" "$SCR/p0" "$SCR/p1" "$SCR/p2" "$SCR/p3"
mkdir -p "$SCR/base"
git -C "$LANE" archive "$PRE" | tar -x -C "$SCR/base" || { echo ARCHIVE-FAIL; exit 2; }
for d in p0 p1 p2 p3; do cp -a "$SCR/base" "$SCR/$d"; done
sha256sum "$SCR/base/.ufo/waves/round-56/capture/S054.body"

echo "### P0 baseline (untouched tree)"
bash "$LANE/plans/round-56-c1.sh" --tree "$SCR/p0"; echo "P0-counter-rc=$?"
python3 -I -B "$SCR/p0/corpus/recheck-replay.py" --root "$SCR/p0" > "$SCR/p0.gate" 2>&1; echo "P0-gate-rc=$?"
tail -n 2 "$SCR/p0.gate"

echo "### P1 probe A: synthetic S054 body, phrase once, manifest bytes+sha256 updated, fetched/http_status set to garbage, fetch-receipt.json deleted"
python3 - <<'PY'
import hashlib, pathlib
root = pathlib.Path('/fast/scratch/hyaku/kagi-r56/R56LabratCeiling/p1')
body = root/'.ufo/waves/round-56/capture/S054.body'
text = (
 "Synthetic capture body for the round-56 ceiling probe (seat R56LabratCeiling).\n"
 "This file was written by hand in scratch; no fetch produced it.\n"
 "it can also log in to confirm if that secret is live or not\n"
 "Trailing filler line so the body has several lines.\n"
)
body.write_bytes(text.encode())
data = body.read_bytes()
man = root/'corpus/recheck-captures.tsv'
out = []
for line in man.read_text().splitlines():
    if line.startswith('S054\t'):
        c = line.split('\t')
        c[3] = '1999-01-01'; c[4] = '999'
        c[5] = str(len(data)); c[6] = hashlib.sha256(data).hexdigest()
        line = '\t'.join(c)
    out.append(line)
man.write_text('\n'.join(out) + '\n')
print('P1 body bytes=%d sha256=%s' % (len(data), hashlib.sha256(data).hexdigest()))
PY
rm -f "$SCR/p1/.ufo/waves/round-56/capture/fetch-receipt.json"; echo "P1 receipt rm rc=$?"
grep -c -e "$PHRASE" "$SCR/p1/.ufo/waves/round-56/capture/S054.body"
bash "$LANE/plans/round-56-c1.sh" --tree "$SCR/p1"; echo "P1-counter-rc=$?"
python3 -I -B "$SCR/p1/corpus/recheck-replay.py" --root "$SCR/p1" > "$SCR/p1.gate" 2>&1; echo "P1-gate-rc=$?"
grep -n 'secret-scanning' "$SCR/p1.gate"; tail -n 1 "$SCR/p1.gate"

echo "### P2 probe B: S054 body with phrase ZERO times, manifest bytes+sha256 FORGED to match"
python3 - <<'PY'
import hashlib, pathlib
base = pathlib.Path('/fast/scratch/hyaku/kagi-r56/R56LabratCeiling')
text = b"synthetic body with no needle phrase at all\nsecond line of filler\n"
for d, forge in (('p2', True), ('p3', False)):
    root = base/d
    (root/'.ufo/waves/round-56/capture/S054.body').write_bytes(text)
    if forge:
        man = root/'corpus/recheck-captures.tsv'
        out = []
        for line in man.read_text().splitlines():
            if line.startswith('S054\t'):
                c = line.split('\t')
                c[5] = str(len(text)); c[6] = hashlib.sha256(text).hexdigest()
                line = '\t'.join(c)
            out.append(line)
        man.write_text('\n'.join(out) + '\n')
print('P2/P3 body bytes=%d sha256=%s' % (len(text), hashlib.sha256(text).hexdigest()))
PY
bash "$LANE/plans/round-56-c1.sh" --tree "$SCR/p2"; echo "P2-counter-rc=$?"
python3 -I -B "$SCR/p2/corpus/recheck-replay.py" --root "$SCR/p2" > "$SCR/p2.gate" 2>&1; echo "P2-gate-rc=$?"
grep -n 'S054' "$SCR/p2.gate"; tail -n 1 "$SCR/p2.gate"

echo "### P3 probe B-unforged: same zero-phrase body, ORIGINAL manifest row (no forgery)"
bash "$LANE/plans/round-56-c1.sh" --tree "$SCR/p3"; echo "P3-counter-rc=$?"
python3 -I -B "$SCR/p3/corpus/recheck-replay.py" --root "$SCR/p3" > "$SCR/p3.gate" 2>&1; echo "P3-gate-rc=$?"
grep -n 'S054' "$SCR/p3.gate"; tail -n 1 "$SCR/p3.gate"

echo "### field consultation grep on the two instruments (lane, read-only)"
grep -n -e 'fetched' -e 'http_status' "$LANE/plans/round-56-c1.sh" "$LANE/corpus/recheck-replay.py"
echo "grep-rc=$? (1 = no non-header consultation)"
grep -c 'fetch-receipt' "$LANE/plans/round-56-c1.sh" "$LANE/corpus/recheck-replay.py"
echo "done"
