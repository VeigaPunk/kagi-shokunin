Author: R72ExecHarm (executor)

Axes (godspeed): freshness, calibration. Harm check = candidate vs BASE across all
lane gates in the assignment list, run on git-archive extractions of
b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9 (BASE) and
a947a42c52dc5b64cc9be1eef98207712fca7c42 (candidate) in scratch
/fast/scratch/hyaku/kagi-r72/R72ExecHarm/{base,cand}. No claim is admitted
if an axis (or any gate) is harmed. `claim-ledger.sh verify` was not run
(per assignment). Receipts in this seat dir: harm.tsv, sweep_base.txt,
sweep_cand.txt.

Results (TSV: .ufo/waves/round-72/w1/R72ExecHarm/harm.tsv)

1. release-clock --selftest: PASS (121) rc 0 on both — no change.
2. sources-census: CLEAN both. BASE rows=164 A=146 mined=142 captures=164;
   candidate rows=166 A=148 mined=144 captures=166 — the +2/+2/+2 is exactly
   the claimed S174/S175 move; verdict unchanged. Not a harm.
3. sources-census --selftest: PASS (98) rc 0 both — no change.
4. self-counts: BASE POLICY stale=4 rc 2 → candidate stale=0 rc 2
   (SC-SKILL-STAMPS, SC-SKILL-CLAIMS, PV-STAMPS, PV-CLAIMS now OK 181/181,
   102/102; POLICY pair retained). The stale 4→0 is the claimed C2 move;
   exit 2 POLICY shape is preserved, not harmed.
5. self-description-sweep: MISMATCH n=28 (SD5=4 SD6=23 SD8=1) rc 1 on BOTH,
   byte-identical output (diff IDENTICAL). Pre-existing mismatch, untouched
   by the candidate. The script was slow (claim-ledger citations subrun;
   timed out at 120s/240s, completed with timeout 280 in ~250s both trees).
   No harm; no improvement either.
6. claims-declared: MISMATCH (claims=67 mismatch=2) rc 1 on both — the
   carried round-69 pair, outside C2's population per the frozen plan. No
   change, no harm.
7. recheck-replay: CLEAN (10/10) rc 0 both — no change.
8. feed-token-agree: AGREE (12/0) rc 0 both; --selftest PASS (4) rc 0 both.
9. claim-ledger docs (DOC_AUDIT): CLEAN (51/48) rc 0 both — no change.
10. Diagnostic (not in the battery list): release-clock default offline
    CLEAN both, fired 14 → 4. The -10 is the claimed C1 re-arm (the ten
    F-set rows); remaining fired are S012/S027/S028/S072, all outside F
    per the plan. Consistent with the claim, not a harm.

Candidate surface check: corpus diff is exactly the claimed files
(clock-rearm.tsv, round-72 lesson, release-clock.py receipt-pin only,
release-clocks.tsv, source-fetches.tsv, SOURCES.md) + SKILL.md:46 /
PROVINCE.md:73 number lines + wave/capture/receipt trees. claim-ledger.tsv
unchanged. release-clock.py diff is DEFAULT_RECEIPT_SHA256 + receipt_path
only. No other gate source modified.

Per-check verdict table: .ufo/waves/round-72/w1/R72ExecHarm/harm.tsv

FINDING H1 falsifies-number offline release-clock fired 14->4 matches claimed C1 re-arm; remaining 4 fired are outside F
FINDING H2 falsifies-number census rows 164->166 (+2 C1 S174/S175) verdict CLEAN unchanged; self-counts stale 4->0 is claimed C2, POLICY shape preserved
FINDING H3 neutral self-description-sweep MISMATCH n=28 identical BASE and candidate; claims-declared MISMATCH(2) identical; DOC_AUDIT CLEAN identical — no harm, no unclaimed move
SEAT-STATUS: complete harm battery run on both trees; no axis harmed
