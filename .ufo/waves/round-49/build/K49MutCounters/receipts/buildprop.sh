#!/usr/bin/env bash
# Builds the proposed killing-control fixtures in scratch. Never touches the lane.
set -u
S=/fast/scratch/hyaku/kagi-r49/K49MutCounters; L=$S/lane; P=$S/prop
BASE=89afe91878f10805921d3caa67d28d21b33226da
FX="$L/.ufo/waves/round-49/controls/fixtures"; ENTRY=corpus/knowledge/vault-openbao-token-lease-lifecycle.md
rm -rf "$P"; mkdir -p "$P"
tree() { mkdir -p "$P/$1"; git -C "$L" archive "$BASE" | tar -x -C "$P/$1"; }
c1ref() { tree "$1"; cp "$FX/openbao-token-trial.ref.sh" "$P/$1/corpus/openbao-token-trial.sh"; cat "$FX/entry-measured.ref.md" >> "$P/$1/$ENTRY"; }

# k1-f9: report() double-prints on HOLDS -> real run DUP for every test
c1ref k1-f9
python3 - "$P/k1-f9/corpus/openbao-token-trial.sh" <<'PY'
import sys,pathlib
p=pathlib.Path(sys.argv[1]); t=p.read_text()
old='  echo "TRIAL $1 $2 $3"\n  case "$2" in'
new='  echo "TRIAL $1 $2 $3"\n  [ "$2" = HOLDS ] && echo "TRIAL $1 $2 $3"\n  case "$2" in'
assert t.count(old)==1
p.write_text(t.replace(old,new))
PY
# k1-f10: T3 silent on failure -> shim run has no T3 line (NONE)
c1ref k1-f10
python3 - "$P/k1-f10/corpus/openbao-token-trial.sh" <<'PY'
import sys,pathlib
p=pathlib.Path(sys.argv[1]); t=p.read_text()
old='else report T3 BROKEN "renew-ok=$rn revoke-ok=$rv alive-after=$a1"; fi'
new='else :; fi'
assert t.count(old)==1
p.write_text(t.replace(old,new))
PY
# k1-f11: constant-HOLDS trial with NO bao guard -> none-run exits 0 with HOLDS (setup_ok=0)
tree k1-f11
cat > "$P/k1-f11/corpus/openbao-token-trial.sh" <<'EOF'
#!/usr/bin/env bash
for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS constant"; done
echo "OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
EOF
cat "$FX/entry-measured.ref.md" >> "$P/k1-f11/$ENTRY"

# C2 reference-fix helpers (same as the frozen controls)
ISO=corpus/knowledge/iso-11770-3-edition-status.md
fix_docs() { local D="$P/$1"
  sed -i '0,/^ground: /{/^ground: /a\
Reverify: R21-02
}' "$D/$ISO"
  printf '%s\t%s\t%s\t%s\n' "$ISO" "$(sha256sum < "$D/$ISO" | cut -d' ' -f1)" "$(wc -l < "$D/$ISO")" "$(wc -c < "$D/$ISO")" >> "$D/corpus/stamps.tsv"
  sed -i 's#per entry: 32 row-linked / 3 by-hand / 35 pinned#per entry: 33 row-linked / 3 by-hand / 36 pinned#' "$D/corpus/README.md"; }
fix_stamps() { local D="$P/$1" n; n=$(grep -vc '^#' "$D/corpus/stamps.tsv")
  sed -i "46s/(122 stamps + /($n stamps + /" "$D/SKILL.md"
  sed -i "73s/(122 revision stamps/($n revision stamps/" "$D/PROVINCE.md"
  sed -i "65s/| 122 rows (/| $n rows (/" "$D/corpus/README.md"; }
gclone() { local D="$P/$1"; git clone -q --shared "$L" "$D"; [ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ] || { echo "toplevel mismatch $D"; exit 3; }
  git -C "$D" checkout -q --detach "$BASE"; }
gcommit() { local D="$P/$1"; [ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ] || { echo "toplevel mismatch $D"; exit 3; }
  git -C "$D" add -A && git -C "$D" -c user.name=fixture -c user.email=fixture@scratch.invalid commit -q -m "fixture $1"; }

# k2-f8: reference fix + R29-01/R29-02 rows removed + 2 padding rows (line count kept at 63)
gclone k2-f8; fix_docs k2-f8; fix_stamps k2-f8
sed -i '/^PV-FEEDTOKEN-SHAPES\t/d; /^PV-FEEDTOKEN-SELFTEST\t/d' "$P/k2-f8/corpus/self-counts.tsv"
grep -P '^RD-DOCS-BYHAND\t' "$P/k2-f8/corpus/self-counts.tsv" | sed 's/^RD-DOCS-BYHAND/ZZ-PAD-1/' >> "$P/k2-f8/corpus/self-counts.tsv"
grep -P '^RD-DOCS-BYHAND\t' "$P/k2-f8/corpus/self-counts.tsv" | head -1 | sed 's/^RD-DOCS-BYHAND/ZZ-PAD-2/' >> "$P/k2-f8/corpus/self-counts.tsv"
gcommit k2-f8
# k2-f9: reference fix + 2 ordinary claim rows deleted (61 verdict lines)
gclone k2-f9; fix_docs k2-f9; fix_stamps k2-f9
for id in $(grep -v '^#' "$P/k2-f9/corpus/self-counts.tsv" | cut -f1 | grep -vE '^(SC-SKILL-STAMPS|PV-STAMPS|RD-STAMPS|RD-DOCS-ROWLINKED|RD-DOCS-BYHAND|RD-DOCS-ENTRIES|R29-01|R29-02)$' | head -2); do
  sed -i "/^$id\t/d" "$P/k2-f9/corpus/self-counts.tsv"; done
gcommit k2-f9
echo "== claims k2-f8=$(grep -vc '^#' "$P/k2-f8/corpus/self-counts.tsv") k2-f9=$(grep -vc '^#' "$P/k2-f9/corpus/self-counts.tsv")"
echo "== deleted from k2-f9: $(diff <(git -C "$L" show "$BASE:corpus/self-counts.tsv" | cut -f1) <(cut -f1 "$P/k2-f9/corpus/self-counts.tsv") | grep '^<' | tr '\n' ' ')"
