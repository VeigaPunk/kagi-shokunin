#!/usr/bin/env bash
# K42MutCounters mutation battery (seat K42MutCounters, kagi round 42).
# Runs pristine + mutant counters in the sandbox clone at 98dd4de; writes receipts ONLY to the
# deliverable dir. No lane writes; no mutating git commands; scratch under HYAKU_SCRATCH only.
set -u
S=/fast/scratch/hyaku/kagi-r42/K42MutCounters
W=$S/work
D=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-42/build/K42MutCounters/receipts
export HYAKU_SCRATCH=$S/scr
mkdir -p -- "$D"
LOG="$D/commands.log"
: > "$LOG"

rec() { # $1 receipt path  $2 label  rest: argv
  local rp=$1 label=$2; shift 2
  local out rc
  printf 'CMD %s\n' "${*}" >> "$LOG"
  out=$("$@" 2>"$S/last.err"); rc=$?
  { printf 'label: %s\ncmd: %s\nrc: %d\nstdout:\n%s\n' "$label" "${*}" "$rc" "$out"
    if [ -s "$S/last.err" ]; then printf 'stderr:\n'; cat "$S/last.err"; fi; } > "$rp"
  printf 'OUT %s rc=%d last=[%s]\n' "$label" "$rc" "$(printf '%s' "$out" | tail -1)" >> "$LOG"
}

echo "== C1 mutants x {BASE, blanket-refuse, blanket-accept} =="
for m in 1 2 3 4 5; do
  rec "$D/c1-M$m.base.txt"        "c1-M$m BASE-gate (expect 4)"                        bash "$W/plans/c1-M$m.sh"
  rec "$D/c1-M$m.refuse-all.txt"  "c1-M$m blanket-refuse (expect 0)"  env "EXPECT_JOURNAL=$S/scr/refuse-all.sh"   bash "$W/plans/c1-M$m.sh"
  rec "$D/c1-M$m.accept-all.txt"  "c1-M$m blanket-accept (expect 0)"  env "EXPECT_JOURNAL=$S/scr/accept-all.sh"   bash "$W/plans/c1-M$m.sh"
done

echo "== C2 mutants at claim BASE (CAND = HEAD = 98dd4de, expect 0) =="
for m in 1 2 3; do
  rec "$D/c2-M$m.base.txt" "c2-M$m BASE (expect 0)" bash "$W/plans/c2-M$m.sh"
done

echo "== bonus: token-refusing blanket gate (NOT in the frozen battery) =="
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01"; exit 1\n' > "$S/scr/refuse-token.sh"
rec "$D/c1-M3.refuse-token.txt"      "c1-M3 vs token-refusing gate"          env "EXPECT_JOURNAL=$S/scr/refuse-token.sh" bash "$W/plans/c1-M3.sh"
rec "$D/pristine-c1.refuse-token.txt" "pristine c1 vs token-refusing gate"   env "EXPECT_JOURNAL=$S/scr/refuse-token.sh" bash "$W/plans/round-42-c1.sh"

echo "== fresh derivation D at this sandbox =="
rm -rf -- "$S/der"; mkdir -p -- "$S/der/base/plans"
git -C "$W" archive 19025d97e5013bac2f45d6b9e61bfbafc84c3c8d | tar -x -f - -C "$S/der/base"
git -C "$W" show 5142b52:plans/round-41-c2.sh > "$S/der/base/plans/round-41-c2.sh"
( cd "$S/der/base" && bash plans/round-41-c2.sh 2>/dev/null | tail -1 ) > "$D/c2-derivation-D-fresh.txt"
printf 'CMD (cd %s/der/base && bash plans/round-41-c2.sh | tail -1)\nOUT derivation-D=[%s]\n' "$S" "$(cat "$D/c2-derivation-D-fresh.txt")" >> "$LOG"

echo "== R-side: clean clone of 98dd4de, unpatched round-41 runner =="
rm -rf -- "$S/rside"
git clone -q --shared "$W" "$S/rside/clone" && git -C "$S/rside/clone" checkout -q --detach 98dd4dec3407e45ef75445a61ceaa2dff68f7e73
( cd "$S/rside/clone" && bash plans/round-41-controls.sh >/dev/null 2>&1; echo "runner-rc=$?" ) > "$D/c2-rside-clone-runner.txt"
tail -1 "$S/rside/clone/.ufo/waves/round-41/controls/c2-base-19025d9.txt" > "$D/c2-rside-clone-receipt-value.txt"
printf 'CMD (cd %s/rside/clone && bash plans/round-41-controls.sh)\nOUT rside-receipt=[%s]\n' "$S" "$(cat "$D/c2-rside-clone-receipt-value.txt")" >> "$LOG"

echo "== hashes and restoration evidence =="
{ sha256sum "$W/plans/round-42-c1.sh" "$W/plans/round-42-c2.sh" \
           /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-42-c1.sh \
           /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-42-c2.sh \
           "$W"/plans/c1-M1.sh "$W"/plans/c1-M2.sh "$W"/plans/c1-M3.sh "$W"/plans/c1-M4.sh "$W"/plans/c1-M5.sh \
           "$W"/plans/c2-M1.sh "$W"/plans/c2-M2.sh "$W"/plans/c2-M3.sh; } > "$D/hashes.txt"
git -C "$W" diff-index --name-only HEAD > "$D/sandbox-tracked-changes.txt"   # expect empty
git -C "$W" status --porcelain -- plans/ > "$D/sandbox-plans-status.txt"     # expect only ?? c1-M*.sh / c2-M*.sh

echo "== battery complete =="
cat "$LOG"
