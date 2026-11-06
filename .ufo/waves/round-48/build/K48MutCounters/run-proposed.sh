#!/bin/bash
# run-proposed.sh <pristine|M01-c1|M11-c1|M05-c1|N01-c2|N05-c2> <P1|P2|P3|P4>
set -u
S=/fast/scratch/hyaku/kagi-r48/K48MutCounters
CTL=$1; P=$2; BASE=76da518fcc3029e738648bd6fd4ba5571df01c1c
L=$S/clone
W=$(mktemp -d "$S/prop.XXXXXX"); trap 'rm -rf -- "$W"' EXIT
C1F="$L/plans/round-48-c1.sh"; C2F="$L/plans/round-48-c2.sh"
case "$CTL" in
  pristine) ;;
  *-c1) C1F="$L/mut/$CTL.sh";;
  *-c2) C2F="$L/mut/$CTL.sh";;
  *) echo "bad ctl $CTL"; exit 9;;
esac
val() { printf '%s' "$1" | sed -n 's/^C[12]_[A-Z_]*: value=\([0-9]*\).*/\1/p;t;s/^C[12]_[A-Z_]*: SETUP.*/SETUP/p'; }
case "$P" in
P1|P2|P5)
  case "$P" in P1) src="$S/proposed/fx-none-silent-trial.sh";; P2) src="$S/proposed/fx-dup-trial.sh";;
              P5) src="$S/proposed/fx-diagonal-trial.sh";; esac
  t="$W/t"; mkdir -p "$t"; git -C "$L" archive "$BASE" | tar -x -C "$t"
  cp "$src" "$t/corpus/sops-age-trial.sh"
  cat "$L/.ufo/waves/round-48/controls/fixtures/ref-entry-measured.md" >> "$t/corpus/knowledge/sops-age-key-rotation.md"
  out=$(bash "$C1F" --tree "$t"); rc=$?
  printf 'PROPOSED %s ctl=%-8s rc=%s VAL=%s | %s\n' "$P" "$CTL" "$rc" "$(val "$out")" "$(printf '%s' "$out" | tail -1)" ;;
P3|P4)
  D="$W/c2"; git clone -q --shared "$L" "$D" && git -C "$D" checkout -q --detach "$BASE" || exit 2
  [ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ] || { echo "PROPOSED $P ctl=$CTL SETUP toplevel"; exit 2; }
  mkdir -p "$D/plans"; cp "$C2F" "$D/plans/r48-c2-under-test.sh"
  if [ "$P" = P3 ]; then python3 "$S/proposed/c2-fixture2.py" substr "$D/SCORECARD.md" "$L/.ufo/waves/round-48/controls/fixtures/c2-fixture.py"
  else printf '#!/usr/bin/env python3\n' > "$D/corpus/quote-locate.py"; fi
  git -C "$D" add -A >/dev/null 2>&1
  git -C "$D" -c user.name=fixture -c user.email=fixture@scratch.invalid commit -q -m p >/dev/null 2>&1
  H=$(git -C "$D" rev-parse HEAD)
  out=$(bash "$D/plans/r48-c2-under-test.sh" "$H"); rc=$?
  printf 'PROPOSED %s ctl=%-8s rc=%s VAL=%s | %s\n' "$P" "$CTL" "$rc" "$(val "$out")" "$(printf '%s' "$out" | head -1)" ;;
esac
