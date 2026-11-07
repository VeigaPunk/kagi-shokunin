#!/usr/bin/env bash
# R56Critic receipt: reproduces every row of R56Critic.md against byte-pinned judges.
#
#   epoch A = committed predeclaration 42070de7 (counter 096251c9..., gate b7782f35...)
#   epoch B = a SNAPSHOT of the lane working tree taken by this script (the judge moved
#             several times during the wave; the snapshot's sha256 is printed first and is
#             the only bytes the B rows refer to)
#
# Run: bash .ufo/waves/round-56/w1/R56Critic.d/run-attacks.sh
# Writes only under $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r56/R56Critic-epC.
# Never mutates the lane; the one live clone is created here and carries git + BASE.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
REV=42070de7770e1558adcf6aa7a7bc59309a9654d7
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r56/R56Critic-epC
D=$LANE/.ufo/waves/round-56/w1/R56Critic.d
CLONE=$S/clone
rm -rf "$S"; mkdir -p "$S/snap"

# --- snapshot the epoch-B judge atomically (copy once, hash what we copied) ----
cp "$LANE/plans/round-56-c1.sh" "$S/snap/counter.sh" || exit 2
cp "$LANE/corpus/recheck-replay.py" "$S/snap/gate.py" || exit 2
A_SHA=096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a
printf 'epoch A counter pin  %s\n' "$A_SHA"
printf 'epoch B counter      %s\n' "$(sha256sum "$S/snap/counter.sh" | cut -d' ' -f1)"
printf 'epoch B gate         %s\n' "$(sha256sum "$S/snap/gate.py" | cut -d' ' -f1)"
printf 'epoch B gate pin     %s\n' "$(grep -m1 '^GATE_SHA256_PIN=' "$S/snap/counter.sh" | cut -d= -f2)"
if grep -q '^GATE_SHA256_PIN=' "$S/snap/counter.sh"; then
  [ "$(grep -m1 '^GATE_SHA256_PIN=' "$S/snap/counter.sh" | cut -d= -f2)" = \
    "$(sha256sum "$S/snap/gate.py" | cut -d' ' -f1)" ] \
    && echo "pin consistent with the snapshotted gate" \
    || echo "PIN INCONSISTENT with the snapshotted gate"
fi
bash -n "$S/snap/counter.sh" || echo "EPOCH-B COUNTER DOES NOT PARSE"
# --- one live clone at the frozen revision (git + BASE object) ---
git clone --quiet "$LANE" "$CLONE" || exit 2
( cd "$CLONE" && [ "$(git rev-parse --show-toplevel)" = "$CLONE" ] \
  && git checkout --quiet "$REV" ) || exit 2
cp "$CLONE/plans/round-56-c1.sh" "$S/snap/counterA.sh"
[ "$(sha256sum "$S/snap/counterA.sh" | cut -d' ' -f1)" = "$A_SHA" ] \
  && echo "epoch A counter verified at $REV" || { echo "EPOCH A COUNTER MISMATCH"; exit 2; }

run() {  # $1 = A|B  $2 = label  $3 = tree  $4 = 1 when the gate itself is the attack
  if [ "$1" = B ] && [ "${4:-0}" = 0 ]; then cp "$S/snap/gate.py" "$3/corpus/recheck-replay.py"; fi
  cp "$S/snap/counter$1.sh" "$CLONE/plans/round-56-c1.sh"
  printf '%s %-13s ' "$1" "$2"
  bash "$CLONE/plans/round-56-c1.sh" --tree "$3" | cut -c1-150
}

minimal() {  # $1 = dest, built from the epoch-A archive (its gate is the epoch-A gate)
  mkdir -p "$1"
  git -C "$CLONE" archive "$REV" corpus/knowledge corpus/SOURCES.md \
    corpus/recheck-captures.tsv corpus/recheck-replay.py corpus/rendered-text-v1.py \
    .ufo/waves/round-56/capture .ufo/waves/round-55/capture \
    .ufo/waves/round-45/controls/capture-r45 | tar -x -C "$1" || return 1
}

repoint() {  # $1 tree  $2 id (ALL = every row)  $3 body_path  $4 bytes  $5 sha256
  T=$1 ID=$2 BP=$3 B=$4 H=$5 python3 - <<'PY'
import os
t = os.environ["T"] + "/corpus/recheck-captures.tsv"
rows, hdr = [], False
for line in open(t).read().splitlines():
    if not line.strip() or line.startswith("#"):
        rows.append(line); continue
    c = line.split("\t")
    if not hdr:
        rows.append(line); hdr = True; continue
    if os.environ["ID"] in ("ALL", c[0]):
        c[2], c[5], c[6] = os.environ["BP"], os.environ["B"], os.environ["H"]
        rows.append("\t".join(c)); continue
    rows.append(line)
open(t, "w").write("\n".join(rows) + "\n")
PY
}

each() { for e in A B; do run "$e" "$1" "$2" "${3:-0}"; done; }

echo "=== controls ==="
minimal "$S/min"; each positive "$S/min"
printf 'A %-13s ' BASE; cp "$S/snap/counterA.sh" "$CLONE/plans/round-56-c1.sh"
bash "$CLONE/plans/round-56-c1.sh" 832ba6a53d6a76706b5c80bce2278683dea33d42 | cut -c1-120

echo "=== A1 gate -> constant printer ==="
cp -a "$S/min" "$S/a1"; cp "$D/fake-gate.py" "$S/a1/corpus/recheck-replay.py"; each printer "$S/a1" 1

echo "=== A2 gate -> symlink to .ufo/printer.py ==="
cp -a "$S/min" "$S/a1b"
mv "$S/a1b/corpus/recheck-replay.py" "$S/a1b/.ufo/printer.py"
ln -s ../.ufo/printer.py "$S/a1b/corpus/recheck-replay.py"; each symlink-gate "$S/a1b" 1

echo "=== A3 one 691-byte text body for nine clocks ==="
cp -a "$S/min" "$S/a2"
python3 - "$S/a2" <<'PY'
import pathlib, sys
S = pathlib.Path(sys.argv[1])
pats = [("Scans detect secrets without credential provider requests by default", 1),
        ("Withdrawal of International Standard", 2), ("ISO/IEC 11770-3:2021/Amd", 3),
        ("International Standard published", 2), ("public comment period is CLOSED", 1),
        ("It MUST contain the OAuth 2.0", 1),
        ("it can also log in to confirm if that secret is live or not", 1),
        ("Each cache entry expires after three hours", 1),
        ("The client authenticates using your OIDC token, workload ID, and the integration key "
         "configured by your administrator", 1)]
lines = ["scratch forge (A3): synthesized body satisfying every stated count", ""]
for pat, n in pats:
    lines += ["filler"] + [pat] * n
body = ("\n".join(lines) + "\n").encode()
p = S / ".ufo/waves/round-56/forge.txt"; p.parent.mkdir(parents=True, exist_ok=True)
p.write_bytes(body)
print("forge", len(body))
PY
F="$S/a2/.ufo/waves/round-56/forge.txt"
for id in S101 S113 S114 S054 S055 S057 S067 S070 S074; do
  repoint "$S/a2" "$id" .ufo/waves/round-56/forge.txt "$(stat -c%s "$F")" "$(sha256sum "$F" | cut -d' ' -f1)"
done
each text-forge "$S/a2"

echo "=== A4 one 1287-byte PDF for all ten clocks ==="
cp -a "$S/min" "$S/a2b"; python3 "$D/forge-a2b.py" "$S/a2b"; each pdf-forge "$S/a2b"

echo "=== A5 symlinked body ==="
cp -a "$S/min" "$S/a3"; mkdir -p "$S/a3/.ufo/waves/round-56/linkdir"
printf 'Scans detect secrets without credential provider requests by default\n' \
  > "$S/a3/.ufo/waves/round-56/linkdir/S055.body"
ln -s S055.body "$S/a3/.ufo/waves/round-56/linkdir/link-to.body"
B="$S/a3/.ufo/waves/round-56/linkdir/S055.body"
repoint "$S/a3" S055 .ufo/waves/round-56/linkdir/link-to.body "$(stat -c%s "$B")" "$(sha256sum "$B" | cut -d' ' -f1)"
each symlink-body "$S/a3"

echo "=== A6 drop the manifest ==="
cp -a "$S/min" "$S/a4"; rm "$S/a4/corpus/recheck-captures.tsv"; each no-manifest "$S/a4"

echo "=== A7 inline body_path ==="
cp -a "$S/min" "$S/a4b"
python3 - "$S/a4b" <<'PY'
import base64, hashlib, pathlib, sys
S = pathlib.Path(sys.argv[1]); body = b"Scans detect secrets without credential provider requests by default\n"
t = S / "corpus/recheck-captures.tsv"; rows, hdr = [], False
for line in t.read_text().splitlines():
    if not line.strip() or line.startswith("#"): rows.append(line); continue
    c = line.split("\t")
    if not hdr: rows.append(line); hdr = True; continue
    if c[0] == "S055":
        c[2] = "data:text/plain;base64," + base64.b64encode(body).decode()
        c[5] = str(len(body)); c[6] = hashlib.sha256(body).hexdigest()
        rows.append("\t".join(c)); continue
    rows.append(line)
t.write_text("\n".join(rows) + "\n")
PY
each inline "$S/a4b"

echo "=== A8 edit stated N with the body ==="
cp -a "$S/min" "$S/a5"
python3 - "$S/a5" <<'PY'
import hashlib, pathlib, sys
S = pathlib.Path(sys.argv[1])
e = S / "corpus/knowledge/iso-11770-3-edition-status.md"; t = e.read_text()
old = "' | grep -c 'ISO/IEC 11770-3:2021/Amd'` -> 3"
assert t.count(old) == 1
e.write_text(t.replace(old, "' | grep -c 'ISO/IEC 11770-3:2021/Amd'` -> 1"))
body = b"pad\nISO/IEC 11770-3:2021/Amd\n"
p = S / ".ufo/waves/round-56/edit.body"; p.write_bytes(body)
mt = S / "corpus/recheck-captures.tsv"; rows, hdr = [], False
for line in mt.read_text().splitlines():
    if not line.strip() or line.startswith("#"): rows.append(line); continue
    c = line.split("\t")
    if not hdr: rows.append(line); hdr = True; continue
    if c[0] == "S113":
        c[2] = ".ufo/waves/round-56/edit.body"; c[5] = str(len(body)); c[6] = hashlib.sha256(body).hexdigest()
        rows.append("\t".join(c)); continue
    rows.append(line)
mt.write_text("\n".join(rows) + "\n")
PY
each restated-N "$S/a5"

echo "=== A9 drift one real body, manifest honest ==="
cp -a "$S/min" "$S/a6"
python3 - "$S/a6" <<'PY'
import hashlib, pathlib, sys
S = pathlib.Path(sys.argv[1]); p = S / ".ufo/waves/round-55/capture/S113.body"
lines = p.read_bytes().split(b"\n"); pat = b"ISO/IEC 11770-3:2021/Amd"
hits = [i for i, l in enumerate(lines) if pat in l]; assert len(hits) == 3
del lines[hits[0]]; new = b"\n".join(lines); p.write_bytes(new)
mt = S / "corpus/recheck-captures.tsv"; rows, hdr = [], False
for line in mt.read_text().splitlines():
    if not line.strip() or line.startswith("#"): rows.append(line); continue
    c = line.split("\t")
    if not hdr: rows.append(line); hdr = True; continue
    if c[0] == "S113":
        c[5] = str(len(new)); c[6] = hashlib.sha256(new).hexdigest()
        rows.append("\t".join(c)); continue
    rows.append(line)
mt.write_text("\n".join(rows) + "\n")
PY
each drifted "$S/a6"

echo "=== A10 drifted + printer gate (epoch A isolates r4) ==="
cp -a "$S/a6" "$S/a7"; cp "$D/fake-gate.py" "$S/a7/corpus/recheck-replay.py"
run A drifted+printer "$S/a7" 1

echo "=== A11 tamper a body, leave the manifest stale ==="
cp -a "$S/min" "$S/a8"
python3 - "$S/a8" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1]) / ".ufo/waves/round-55/capture/S113.body"
p.write_bytes(p.read_bytes().replace(b"International Standard published",
                                     b"International Standard withdrawn", 1))
PY
each tampered "$S/a8"

echo "=== A12 correct clocks, tree lacks rendered-text-v1.py ==="
cp -a "$S/min" "$S/nonorm"; rm "$S/nonorm/corpus/rendered-text-v1.py"
each no-normaliser "$S/nonorm"
