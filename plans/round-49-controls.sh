#!/usr/bin/env bash
# plans/round-49-controls.sh — FROZEN round-49 pre-freeze controls for plans/round-49-c1.sh and
# plans/round-49-c2.sh. Each control builds a fixture from BASE (frozen in round-49-c2.sh), runs the
# frozen counter on it, and compares the observed value (or SETUP) with the expected value written
# here before the first run. Prints one `CONTROL <id> expected=<e> observed=<o> MATCH|MISMATCH` line
# per control and a final `CONTROLS: ALL-MATCH|MISMATCH (match=N mismatch=M)`.
# Fixture git commits (C2 controls) are made only in scratch clones, with `git -C "$D"` and a
# verified toplevel; nothing is committed in the lane.
set -u
L=$(cd "$(dirname "$0")/.." && pwd)
BASE=89afe91878f10805921d3caa67d28d21b33226da
FX="$L/.ufo/waves/round-49/controls/fixtures"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r49"
mkdir -p "$SCR"; W=$(mktemp -d "$SCR/controls.XXXXXX"); trap 'rm -rf -- "$W"' EXIT
ENTRY=corpus/knowledge/vault-openbao-token-lease-lifecycle.md

tree() { mkdir -p "$W/$1"; git -C "$L" archive "$BASE" | tar -x -C "$W/$1"; }
c1ref() { tree "$1"; cp "$FX/openbao-token-trial.ref.sh" "$W/$1/corpus/openbao-token-trial.sh"; cat "$FX/entry-measured.ref.md" >> "$W/$1/$ENTRY"; }

# ---------- C1 fixtures ----------
tree k1-0
c1ref k1-p
tree k1-f1; cat > "$W/k1-f1/corpus/openbao-token-trial.sh" <<'EOF'
#!/usr/bin/env bash
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_TRIAL: SETUP no bao"; exit 2; }
for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS constant"; done
echo "OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
EOF
cat "$FX/entry-measured.ref.md" >> "$W/k1-f1/$ENTRY"
c1ref k1-f2; sed -i "0,/^BASE=/s|^BASE=|PATH=$HOME/.local/bin:\$PATH\nBASE=|" "$W/k1-f2/corpus/openbao-token-trial.sh"
tree k1-f3; cp "$FX/openbao-token-trial.ref.sh" "$W/k1-f3/corpus/openbao-token-trial.sh"
c1ref k1-f4; sed -i 's/if \[ "\$a0" = 1 \] && \[ "\$a1" = 0 \]; then report T1 HOLDS/if [ "$a0" = 1 ]; then report T1 HOLDS/' "$W/k1-f4/corpus/openbao-token-trial.sh"
c1ref k1-f5; sed -i '/^## Measured (round 49/,$ s/OpenBao 2\.7\.2/OpenBao 2.7.1/g' "$W/k1-f5/$ENTRY"
c1ref k1-f6; mkdir -p "$W/badbin"; cp "$HOME/.local/bin/bao" "$W/badbin/bao"; printf '\0' >> "$W/badbin/bao"
c1ref k1-f7; sed -i 's|^report() {|leak() { :; }\nreport() {|; s|^# T1 — |bao token create -field=token -policy=default -ttl=60s 2>/dev/null \| sed "s/^/token: /"\n# T1 — |' "$W/k1-f7/corpus/openbao-token-trial.sh"
tree k1-f8; printf '#!/usr/bin/env bash\nexit 0\n' > "$W/k1-f8/corpus/openbao-token-trial.sh"; cat "$FX/entry-measured.ref.md" >> "$W/k1-f8/$ENTRY"

# ---------- C2 fixtures (git clones in scratch) ----------
gclone() { local D="$W/$1"; git clone -q --shared "$L" "$D"; [ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ] || { echo "toplevel mismatch $D"; exit 3; }
  git -C "$D" checkout -q --detach "$BASE"; }
gcommit() { local D="$W/$1"; [ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ] || { echo "toplevel mismatch $D"; exit 3; }
  git -C "$D" add -A && git -C "$D" -c user.name=fixture -c user.email=fixture@scratch.invalid commit -q -m "fixture $1"; }
ISO=corpus/knowledge/iso-11770-3-edition-status.md
fix_docs() { local D="$W/$1"
  sed -i '0,/^ground: /{/^ground: /a\
Reverify: R21-02
}' "$D/$ISO"
  printf '%s\t%s\t%s\t%s\n' "$ISO" "$(sha256sum < "$D/$ISO" | cut -d' ' -f1)" "$(wc -l < "$D/$ISO")" "$(wc -c < "$D/$ISO")" >> "$D/corpus/stamps.tsv"
  sed -i 's#per entry: 32 row-linked / 3 by-hand / 35 pinned#per entry: 33 row-linked / 3 by-hand / 36 pinned#' "$D/corpus/README.md"; }
fix_stamps() { local D="$W/$1" n; n=$(grep -vc '^#' "$D/corpus/stamps.tsv")
  sed -i "46s/(122 stamps + /($n stamps + /" "$D/SKILL.md"
  sed -i "73s/(122 revision stamps/($n revision stamps/" "$D/PROVINCE.md"
  sed -i "65s/| 122 rows (/| $n rows (/" "$D/corpus/README.md"; }
gclone k2-0
gclone k2-p; fix_docs k2-p; fix_stamps k2-p; gcommit k2-p
gclone k2-f1; git -C "$W/k2-f1" rm -q "$ISO"; sed -i 's#^\(.*\)$#\1#' "$W/k2-f1/corpus/README.md"; fix_stamps k2-f1; gcommit k2-f1
gclone k2-f2; sed -i '/^corpus\/adjacency\.tsv\t/d' "$W/k2-f2/corpus/stamps.tsv"; fix_docs k2-f2; fix_stamps k2-f2; gcommit k2-f2
gclone k2-f3; fix_docs k2-f3; fix_stamps k2-f3; printf '\n# fixture\n' >> "$W/k2-f3/corpus/self-counts.py"; gcommit k2-f3
gclone k2-f4; fix_stamps k2-f4; gcommit k2-f4
gclone k2-f5; fix_docs k2-f5; gcommit k2-f5
gclone k2-f6; fix_docs k2-f6; fix_stamps k2-f6; sed -i "46s/([0-9]* stamps + /(999 stamps + /" "$W/k2-f6/SKILL.md"; gcommit k2-f6
gclone k2-f7; fix_docs k2-f7; fix_stamps k2-f7; sed -i 's/^\(SC-SKILL-STAMPS\t\)/\1/; /^RD-DOCS-ENTRIES\t/d' "$W/k2-f7/corpus/self-counts.tsv"; gcommit k2-f7

# ---------- run (parallel), compare ----------
C1="$L/plans/round-49-c1.sh"; C2="$L/plans/round-49-c2.sh"
declare -A EXP=(
  [k1-0]=0 [k1-p]=5 [k1-f1]=0 [k1-f2]=0 [k1-f3]=0 [k1-f4]=4 [k1-f5]=0 [k1-f6]=SETUP [k1-f7]=0 [k1-f8]=SETUP
  [k2-0]=6 [k2-p]=0 [k2-f1]=SETUP [k2-f2]=SETUP [k2-f3]=SETUP [k2-f4]=3 [k2-f5]=3 [k2-f6]=1 [k2-f7]=SETUP
)
declare -A WHY=(
  [k1-0]="do-nothing (BASE tree)" [k1-p]="reference trial + entry section" [k1-f1]="constant-HOLDS trial"
  [k1-f2]="reference forcing the real bao onto PATH (shims bypassed)" [k1-f3]="reference trial, no entry section"
  [k1-f4]="reference with T1's after-lapse check removed" [k1-f5]="entry names OpenBao 2.7.1"
  [k1-f6]="unpinned bao binary" [k1-f7]="trial prints a token" [k1-f8]="silent producer (exit 0, no lines)"
  [k2-0]="do-nothing (BASE)" [k2-p]="reference: iso entry Reverify + stamp, README docs 33/3/36, stamp counts"
  [k2-f1]="iso entry deleted instead of declared" [k2-f2]="a BASE stamps row deleted" [k2-f3]="self-counts.py changed"
  [k2-f4]="stamp counts only" [k2-f5]="docs only" [k2-f6]="SKILL stamp count written as 999" [k2-f7]="a frozen key row removed from self-counts.tsv"
)
for k in k1-0 k1-p k1-f1 k1-f2 k1-f3 k1-f4 k1-f5 k1-f6 k1-f7 k1-f8; do
  if [ "$k" = k1-f6 ]; then R49_BAO="$W/badbin/bao" bash "$C1" --tree "$W/$k" > "$W/$k.res" 2>&1 &
  else bash "$C1" --tree "$W/$k" > "$W/$k.res" 2>&1 & fi
done
for k in k2-0 k2-p k2-f1 k2-f2 k2-f3 k2-f4 k2-f5 k2-f6 k2-f7; do bash "$C2" --tree "$W/$k" > "$W/$k.res" 2>&1 & done
wait
m=0; x=0
for k in k1-0 k1-p k1-f1 k1-f2 k1-f3 k1-f4 k1-f5 k1-f6 k1-f7 k1-f8 k2-0 k2-p k2-f1 k2-f2 k2-f3 k2-f4 k2-f5 k2-f6 k2-f7; do
  line=$(grep -E '^C[12]_' "$W/$k.res" | head -1)
  if printf '%s' "$line" | grep -q ' SETUP '; then o=SETUP; else o=$(printf '%s' "$line" | sed -n 's/.* value=\([0-9]*\).*/\1/p'); fi
  [ -n "$o" ] || o=NONE
  if [ "$o" = "${EXP[$k]}" ]; then r=MATCH; m=$((m+1)); else r=MISMATCH; x=$((x+1)); fi
  echo "CONTROL $k expected=${EXP[$k]} observed=$o $r — ${WHY[$k]} :: $line"
done
[ $x -eq 0 ] && s=ALL-MATCH || s=MISMATCH
echo "CONTROLS: $s (match=$m mismatch=$x)"
