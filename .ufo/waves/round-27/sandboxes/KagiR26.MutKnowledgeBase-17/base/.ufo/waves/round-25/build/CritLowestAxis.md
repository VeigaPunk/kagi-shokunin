# CritLowestAxis — round-25 critic (C1–C3 vs AXES, MISSION, SCORECARD)

Seat KagiR25.CritLowestAxis-2 · BASE 4587c61a348e4528717404a68912c373f3ef4d03 · lane tree not modified · sandbox `/fast/scratch/kagi-r25/CritLowestAxis/lane` (clone at BASE; `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/CritLowestAxis/home`) · subagents: none · installs: none.

**Disclosure.** The sandbox `verify` below also ran non-host row R21-01 (`op-ref-probe.sh --dotenv-bytes`; its ledger note says it runs the `op` binary under env -i with a scratch HOME). That is outside my no-op contract. Disclosed, not credited, not repeated.

## Reproduced before-values (sandbox, BASE)
- `bash corpus/claim-ledger.sh citations` (lone clone) → `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`, exit 1. Classes: ufo 31, sibling 57. Each of the 88 tokens exists in the real lane working tree or the fleet root (0 absent), so plan:51 "all layout" holds.
- `bash corpus/claim-ledger.sh verify` (lone clone) → `FAIL R11-08 reason=exit-mismatch exit=1 want=0`; `CLAIM_LEDGER: FAIL (claims=61 failed=1 … stamped=83 … host_skipped=12)`, exit 1. Matches plan:52; its after-state exit is unstated.
- SOURCES.md: 28 rows `on-release` (S005–S032), 4 `90d` (S001–S004), matching plan:57. `rows:` counts (claim-ledger.tsv 61, stamps.tsv 83) equal verify's values, so C1's `rows:` route is feasible.
- SKILL.md:46 is stale (63/39 vs 83/61). SKILL.md:47 `--selftest 70 cases` is current (`sources-census.sh --selftest` → PASS 70, exit 0).
- Nudge: capabilities entered in rounds 22 and 23 (SCORECARD.md:851-852); window N=3 (:693). It does not fire in round 25.

## Counterexamples and risks (HIGH = flips a gate verdict or admission; MEDIUM = mis-measures an axis; LOW = bookkeeping)

1. **C2 verify verdict unspecified — HIGH** (calibration, operability). Plan:46-49 fixes the row line (LAYOUT-SKIP, `layout_skipped=N`, "never credited") but not verify's exit or top-line verdict. The convention is CLEAN-with-skips: FAIL fires only on C_FAILED/stale/missing (claim-ledger.sh:1126-1132), and round 24 recorded the real-tree run as `exit 0 CLEAN (claims61, stamped83, host_skipped12)` (SCORECARD.md:900-901). The natural C2 build prints lone-clone `CLAIM_LEDGER: CLEAN (… layout_skipped=1)` with exit 0, while `citations` on the same check exits 1. Falsifier (after-state): lone-clone verify exits 0 with CLEAN. Fix: layout_skipped>0 ⇒ INCOMPLETE, exit 1.

2. **C2 lane-owned `.ufo/` misses reclassified — HIGH** (freshness, calibration). Probe at BASE (`corpus/docs/critic-probe.md`): `UNRESOLVED corpus/docs/critic-probe.md:1 .ufo/waves/round-25/build/NoSuchCritic.md (ufo)` and `…:3 corpus/NoSuchCritic.md (local)`. Plan:41-44 sends unresolved `ufo` tokens to FLEET-ABSENT yet says "lane-local misses stay UNRESOLVED". The code treats `.ufo/` as lane-owned (claim-ledger.sh:38-39), resolves it lane-first (:627-632), and classes `.ufo/*` and `ufo/*` alike (:613). A lone clone cannot tell a lane typo from a fleet-only reference, so the rule cannot satisfy both halves. The plan's control (:53-55) does not name a class; the existing case (:1631) plants `$S/.ufo/reports` (:1336), so it never exercises the lone layout. Falsifier: the probe in a lone clone must stay UNRESOLVED; under plan:41-44 it becomes FLEET-ABSENT. Fix: a lane-owned `.ufo/` class.

3. **C2 `[fleet]` tag can hide real failures — MEDIUM** (operability). The skip is keyed to "layout absent" (plan:45-47), not to the cause, and "any other row the wave proves layout-bound" is an unmechanized judgment. Falsifier: tag R11-10 (claim-ledger.tsv:24, `grep -cv '^#' corpus/state-shape.tsv` → `^22$`) `[fleet]`, corrupt one row in a lone clone; it must print FAIL R11-10, where the plan rule prints LAYOUT-SKIP. Fix: skip only when the failure names a fleet path.

4. **C2 layout marker and fail direction unstated — HIGH** (freshness). Plan:39-40: "marker fixed by the implementation". If a real fleet checkout lacks the marker, R11-08 is skipped silently and the real tree goes green. Falsifier: fleet-shaped scratch root with the marker removed ⇒ verify must not be CLEAN. Fix: name the marker in the plan; default to fleet when ambiguous.

5. **C2 "unresolved 88 → 0" is a relabel — MEDIUM** (calibration). Plan:51-52 reports `unresolved=0 fleet_absent=88`. The 88 are unchecked, not resolved; with #1, the lone-clone freshness signal moves from flagged to absent. Report `checked=1283 unchecked=88`. Falsifier: the after-state lone clone must print unchecked=88, not unresolved=0.

6. **C3 has no fail-closed control — HIGH** (freshness). C1 has a mutation control (plan:36-37) and C2 has controls (:53-55). C3's counting (:67-71) measures only the live tree, and CLEAN carries `fired=K` (:64-65) with no rule that K>0 or a failed re-verification changes the exit. Falsifier: in a scratch copy, alter one rendered-quote row's quote or one feed row's version ⇒ `release-clock.py` must exit non-zero.

7. **C3 S008 has no valid clock — HIGH** (freshness, counting). SOURCES.md:14 is a `code` row for raw.githubusercontent.com/getsops/sops/main/README.rst; its anchor reads "upstream `main` snapshot … no commit/version displayed"; recheck `on-release`. `feed` needs "the version the row's anchor names" (plan:60-61): none exists. `rendered-quote` needs the quote in rendered text, but round 24 located it only as a raw literal (corpus/lessons/round-24.md:85). A release feed misses main-only commits (`.ufo/waves/round-22/build/Source08.md:56`: a 45-day unreleased gap). Series anchors ("Version 2.7.x", SOURCES.md:27, 31, 32) name no single release. So `bound=28 unbound=0` (plan:69) needs a third clock or a false binding. Falsifier: binding S008 to either clock yields no version to compare, or a quote that does not locate.

8. **C3 freshness does not decay — MEDIUM** (freshness). `observed=N` (plan:64-66) has no receipt-age limit and no re-observation rule, so 2026-10-21 receipts stay CLEAN indefinitely. Falsifier: backdate one receipt to 2026-01-01 in scratch ⇒ must not be CLEAN.

9. **C3 new rows break a pinned count — LOW** (operability). R21-02 (claim-ledger.tsv:52) is anchored `^SOURCES_CENSUS: CLEAN \(rows=32 … captures=32 …\)$`, so each S033+ row turns verify red. Plan:77 does not name the re-pin, and an unexplained re-pin is the SKILL.md:45 anti-pattern "re-pinning to silence red". Falsifier: add one SOURCES row in scratch ⇒ FAIL R21-02.

10. **C1 population overclaim; present-tense forecast escapes — MEDIUM** (calibration, freshness). Plan:20-21 says current-tense numbers "are bound", but the checker covers only rows in a hand-written TSV and nothing enumerates unlisted numbers. Plan:32-33 exempts round-dated text by rule, so present-tense forecasts escape: SCORECARD.md:693 (under ## Saturation, "Declared round 21") still says "the earliest round it can fire is round 25". With capabilities at 22–23 it is round 27 (:776-778). Falsifier: C1 reports CLEAN with that line present. Fix: claim listed rows only, or scan forecast phrasing.

11. **Claim typing — MEDIUM** (distinct axes, capability window). MISSION requires each claim to be an axis-move on a distinct axis; AXES lets a claim be a capability instead, and capability entries reset the stagnation window. The plan gives no type. AXES.md:14 defines freshness as "skill claims re-verified against live surfaces; stale items flagged or fixed", which is C1's stated job. Calibration (AXES.md:15) concerns SHONEN/SCORECARD entries; C1 binds SKILL.md. So C1 and C3 may be one freshness claim (AXES counts same-axis claims once), leaving calibration 9→9 unmeasured. Booking self-counts.py or release-clock.py as a capability would reset the window (:693, :776-778) and falsify plan:6-7's "last capability round 23". Falsifier: the round report must carry a claim-type table.

12. **Premise: "all six at 9" is self-scored and has never moved down — HIGH** (calibration). Round-24 pre-move (SCORECARD.md:871-873): operability 9 with R11-08 red and 35 host executions; freshness 9 with 16 of 26 rows historical-only; calibration 9 with 15/15 identity swaps surviving. A scan of every SCORECARD axis cell (96 arrow-form, 90 single-value) finds 0 decreases (Python, exit 0). So saturation and the tied-lowest rule carry no measurement, and at round 27 (if no capability enters rounds 24–26) the nudge could waive the lowest-axis duty on axes the lane's own evidence calls defective. Fix: measure the lowest axis, allow downward moves, or mark saturation unmeasured.

13. **"Moot at a uniform 9" — LOW** (rule wording). SCORECARD.md:858. AXES has no moot exemption: ties satisfy the obligation, and only the nudge waives it (AXES §The stagnation nudge). Plan:3-10 has the right reading. Retire "moot"; state the round-27 earliest nudge.

14. **Bookkeeping — LOW.** (a) C3's title "fired today" (plan:56-57) versus `fired=K`, which may be 0: say "observed". (b) AXES §Working the axes requires per-claim before→after in SCORECARD.md and evidence in LOG.md; plan:75-78 names neither. (c) AXES §The learning path: pick the axis from the furthest-behind trend; the plan names none.

## No axis harmed, per claim (AXES §Working the axes)
- C1: calibration risk from the overclaimed population (#10); no operability harm found.
- C2: lone-clone calibration and freshness harm (#1, #2, #5). That is a trade; AXES requires it reported, not admitted.
- C3: freshness that cannot fail (#6) or decays (#8); operability via #9.

## UNRUN / not verified
- All after-states (C1–C3 are unimplemented). Falsifiers #1–#4, #6, #8 must run after implementation.
- No release feed fetched; no `--observe` run; the layout marker is undefined in the plan.
- MANIFEST CloseKagi24 and LEARNING.md not read. The no-nudge conclusion holds under any reading of round 24.
- Installs: none.
