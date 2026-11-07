# R52ExecHarm — harm baseline (claim ledger verify at BASE 1d984ad)

Scratch clone: /fast/scratch/hyaku/kagi-r52/R52ExecHarm/base @ 1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b (toplevel `/fast/scratch/hyaku/kagi-r52/R52ExecHarm/base` asserted after `git clone -q --shared` before checkout --detach 1d984ad).

## Full verify
Command (run in scratch clone): `bash corpus/claim-ledger.sh verify`
- rc=2, elapsed 708 s, output 103 lines, last line `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=124)` (`claims=86` = 104 rows - 13 HOST-SKIP - 3 FAIL - 2 DEFER? see note: 104 total rows, 13 host-skipped, 3 FAIL, 3 POLICY; host/deferred counts as printed).
- Receipt: `R52ExecHarm-verify-base.txt` (103 lines, full output).
- Note: ran concurrently with other seats; timing inflated. Isolated single-row timings below are the clean baseline.

## Summary table (FAIL / POLICY at BASE)

| Row | Verdict in verify | Isolated direct run (same command verify runs) | Isolated timing | Root-cause finding |
|---|---|---|---|---|
| R11-08 | FAIL timeout exit=124 tmo=300 | `bash corpus/claim-ledger.sh citations` rc=1, last line `CITATION_GATE: BROKEN (cites=3667 docs=129 unresolved=4 ephemeral=0 labeled=34)`, plus `CITATION_LAYOUT: lone-clone fleet_absent=165` | 167.94 s | In a LONE layout (scratch clone, no fleet root beside) citations end BROKEN not INCOMPLETE: 4 UNRESOLVED lane-owned tokens: `corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)`, `round-32-verifier-spotcheck.md:54` same, `round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)`, `round-51-verifier-spotcheck.md:72 corpus/plans/.ufo (local)`. Fleet_absent=165 (not counted failed). In-fleet layout may differ — this is a lone-clone artifact, flagged not as a lane defect without fleet evidence. Full isolated output: `R52ExecHarm-r11-08-full.txt` (205 lines). Under verify it timed out at 300 s due to concurrent load (fleet verify runs 700+ s; 300 s per-row timeouts are contention-sensitive). |
| R36-01 | FAIL timeout exit=124 tmo=300 | `bash plans/round-36-c1.sh` rc=0, output `0` (last line matches `^0$`) | 183.33 s isolated (sweep alone 143.27 s rc=1 MISMATCH n=5 SD6=4 SD8=1 SD5=0 + self-counts ~20 s) | Counter logic: sd5=0 (SELF_DESCRIPTION shows SD5=0) + stale=0 → 0, target met. Non-owned SD6=4 + SD8=1 are preserved/not counted by design. Receipt `R52ExecHarm-r36-01.txt` (`0`). Verify timeout was 300 s; isolated 183 s — again contention-sensitive per-row timeout. |
| R25-02 | FAIL exit-mismatch exit=2 want=0 | `python3 corpus/self-counts.py` rc=2, last line `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` | ~17-20 s | POLICY because R29-01/R29-02 commands are `python ...` (first token `python` not in allowlist `bash\|grep\|sha256sum\|wc\|test\|python3`), so self-counts refuses them as "command not allowlisted" (PV-FEEDTOKEN-SHAPES, PV-FEEDTOKEN-SELFTEST). Expect was `SELF_COUNTS: CLEAN (claims=60 stale=0)` — stale=0 but claims=63≠60 and policy=2. Root cause is the R29 `python` token (see below), not self-counts logic. |
| R29-01 | POLICY first-token:python | `python -I -B corpus/feed-token-agree.py --selftest` rc=0 `FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)` | <60 s | Row uses `python`, allowlist has only `python3`; refused before execution. Comment cites a round-29 Windows host with no working python3 — on this Linux host `python` works, but policy allowlist is static. POLICY is committed state, not execution failure. |
| R29-02 | POLICY first-token:python | `python -I -B corpus/feed-token-agree.py` rc=0 `FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)` | <60 s | Same as R29-01. |
| R38-03 | POLICY python-script | `python3 -I -B corpus/quote-locate.py` rc=0 `QUOTE_LOCATE: CLEAN located=8 rows=8` (expect was located=5 rows=5 — drift: 8 rows now) | ~<120 s | `corpus/quote-locate.py` not in `PYTHON_SCRIPT_RE` allowlist (feature-claims, revision-audit, closure-dispositions, rendered-text-v1, self-counts, release-clock). Refused statically. Also live output drifted 5→8 rows since the row was written. |

FAIL count: 3 (R11-08, R25-02, R36-01), POLICY count: 3 (R29-01, R29-02, R38-03), HOST-SKIP: 13 (R11-01..R18-01 group).
MISSING-ID lines in verify output: 57; LABELED-ID: 26. These are `idref` findings (cited ids without ledger rows, e.g. R32-*, R33-*, R34-*, R35-*, R36-1..5, R46-01 in LOG.md/SCORECARD.md/lessons) — counted as findings/labeled-or-missing, but final `CLAIM_LEDGER: POLICY` verdict driven by policy=3 rows.
Stamps: stamped=124, no STALE/MISSING stamps printed in verify output.

## Timeouts under contention
- Verify used tmo=300 for R11-08/R36-01; isolated runtimes 168 s / 183 s leave <45% headroom. A 300 s per-row timeout is marginal under host contention (7+ parallel OpenBao trials per seat spec). Recommend report note only (cannot edit ledger): per-row timeouts for these two rows are harm-sensitive to host load.
- Full verify wall time 708 s (concurrent) vs sum of isolated ceilings.

## Caveats
- Lone layout: scratch clone has no fleet-root sibling; 165 FLEET-ABSENT citations make R11-08 verdict layout-dependent. Harm baseline is recorded as-measured in a lone clone; fleet-layout rerun may differ on R11-08.
- verify was NOT run with --allow-host-rows or --orphans (defaults); host rows skipped as designed.
- No ledger/plan/fixture edited (frozen). No bao server started. No tool installed (no installs needed).

## Receipts in this dir
- `R52ExecHarm-verify-base.txt` — full verify output (103 lines)
- `R52ExecHarm-r11-08-full.txt` — isolated citations full output (205 lines)
- `R52ExecHarm-r36-01.txt` — isolated round-36 counter output (`0`)
- `R52ExecHarm-r11-08-partial.txt` — superseded partial (36 lines, timeout 650 run killed mid-stream); retained for provenance, the full file replaces it.
