# R53ExecCounters — frozen counters + kill rules + controls

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (master)
BASE c1953d4afc19a5a336a58685c00ab5260bcfea1c ; CANDIDATE 36d0a86a7539890eb079d893c9a58e37e84d953d ; predeclaration 39460f8676954f135d15fa99b43cd882360b3eee
All commands run in /fast/scratch/hyaku/kagi-r53/R53ExecCounters; receipts copied to .ufo/waves/round-53/build/R53ExecCounters/

## C1 counter
- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-53-c1.sh c1953d4afc19a5a336a58685c00ab5260bcfea1c`
  exit: 0
  last line: `C1_CURRENCY_CLOCKS: value=0 watched=0 gate=1 guard=1 (ok=; bad=S103:recheck=90d S104:recheck=90d; gate-line=RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15))`
  Verdict: BASE expected 0 — MATCH.
- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-53-c1.sh 36d0a86a7539890eb079d893c9a58e37e84d953d`
  exit: 0
  last line: `C1_CURRENCY_CLOCKS: value=2 watched=2 gate=1 guard=1 (ok=S103 S104; bad=; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))`
  Verdict: target 2 — MATCH (S103+S104 WATCHED on live release clocks, 31/31 on_release bound).

## C2 counter
- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-53-c2.sh c1953d4afc19a5a336a58685c00ab5260bcfea1c`
  exit: 0
  last line: `C2_SELF_COUNTS: value=5 (bad=STALE:SC-SKILL-STAMPS STALE:PV-STAMPS STALE:RD-STAMPS STALE:RD-DOCS-ROWLINKED STALE:RD-DOCS-ENTRIES; summary=SELF_COUNTS: POLICY (claims=63 stale=5 unlocated=0 ambiguous=0 policy=2 setup=0))`
  Verdict: BASE expected 5 — MATCH (the frozen five STALE bindings).
- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-53-c2.sh 36d0a86a7539890eb079d893c9a58e37e84d953d`
  exit: 0
  last line: `C2_SELF_COUNTS: value=0 (bad=; summary=SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0))`
  Verdict: target 0 — MATCH (claims=63, stale=0, no unlocated/ambiguous).

## Kill rules (all PASS)
K1 — predeclaration freeze: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff --stat 39460f8676954f135d15fa99b43cd882360b3eee 36d0a86a7539890eb079d893c9a58e37e84d953d -- plans/round-53.md plans/round-53-c1.sh plans/round-53-c2.sh plans/round-53-controls.sh .ufo/waves/round-53/controls`
  exit: 0, empty output — frozen plan/counters/controls untouched. PASS.
K2 — C1 gate bytes vs fixture ref: `git show 36d0a86...:<path>` cmp -s against `.ufo/waves/round-53/controls/fixtures/ref/c1/<path>`:
  corpus/release-clocks.tsv cmp exit 0; corpus/release-clock.py cmp exit 0; .ufo/waves/round-53/final/observe-r53.json cmp exit 0. PASS.
K3 — C2 checker/ledger untouched: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff --stat c1953d4afc19a5a336a58685c00ab5260bcfea1c 36d0a86a7539890eb079d893c9a58e37e84d953d -- corpus/self-counts.py corpus/self-counts.tsv corpus/claim-ledger.sh`
  exit: 0, empty output. PASS.

## Controls re-run
- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-53-controls.sh all`
  The script's summary line was emitted and is fully present in the receipt: `CONTROLS: match=22 mismatch=0` (22/22 MATCH lines, 0 MISMATCH lines, 45 lines total, incl. K12-C1 expect=2 MATCH and K12-C2 expect=0 MATCH). The foreground shell wrapper nevertheless hit its 900s timeout after the summary was written (exit from wrapper: timeout, output file complete), so the wrapper's own exit code is NOT recorded — the receipt's final line is the controls summary itself.
  Verdict: matches expected `CONTROLS: match=22 mismatch=0`. PASS.

## Files
build/R53ExecCounters.md (this report); build/R53ExecCounters/{c1-base.txt, c1-cand.txt, c2-base.txt, c2-cand.txt, controls-all.txt}

No installs/updates; no tokens/secrets touched; no host or lane mutations.
