# kagi round 36 — plan (frozen claims)

Round 36, attempt 1. Lane: kagi (secrets & vault ops). Owned axes: freshness +
calibration. Two claims, distinct axes, each causally separable: C1 is measured
by `plans/round-36-c1.sh` over SCORECARD self-assessment bytes and C2 by
`plans/round-36-c2.sh` over `corpus/release-clocks.tsv` against a committed live
receipt; neither reading depends on the other claim landing.

- BASE for both claims: the predeclaration commit (instrument + executed
  controls). Nothing here is measured against the round's candidate bytes.
- Frozen at the commit that carries this file alone, before any candidate
  scoring. No target, counter, kill rule or population is rebooked after data.

## C1 — calibration: SCORECARD self-assessment mismatches 4 → 0

**Declared claim.** At the landing revision `bash plans/round-36-c1.sh` prints
one integer, the sum of two lane-owned self-assessment readings, and that
integer is **0** (BASE: **4**).

**Counter** (`plans/round-36-c1.sh`, committed in the predeclaration commit;
one unsigned integer on stdout, SETUP exit 2 on any missing reading):

1. `SD5` — `corpus/self-description-sweep.sh`: red ids named on the SCORECARD
   `lane-status:` line that are absent from the calibration row (first cell
   `calibration`) of the latest `## Round` section. BASE 3 (`R25-02`,
   `R29-01`, `R29-02` — the lane-status contract says those reds are always
   named, and the round-35 row does not name them).
2. `stale` — `corpus/self-counts.py`: declared self-count rows whose claimed
   integer differs from the live source. Round 36 arms the population with the
   SCORECARD capability-table row `SA-CAP-CENSUS-SELFTEST`
   (`SCORECARD.md:701` claims the source-census `--selftest` at 59 cases; live
   `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`, ledger `R21-03`). BASE 1.

**Population, separated before freeze.** SD5 (3) and stale (1) are lane-owned
SCORECARD bytes. The sweep's SD6 class (5 citations inside non-author verifier
spot-check files) is **not** in this reading and is preserved unchanged at 5;
this claim neither edits nor re-scores those files. Round 35's rejection turned
on mixing an instrument-integrity population with a self-assessment one; here
every counted item is a SCORECARD/SHONEN-style self-assessment cell compared
with observed repo state (`AXES.md` §calibration).

**Kill rules (frozen).**
- SD6 differs from 5 at the landing revision, or any non-owned verifier file is
  edited → C1 fails, admission withheld.
- The counter prints 0 on a tree where either population is non-empty (a
  removed instrument, a missing reading, a SETUP-shaped output read as zero) →
  C1 fails; the executed controls below are the proof it cannot.
- A wrong-number forgery (`71 cases`) or a red-id forgery planted in an earlier
  round row is not counted → C1 fails.

**Fix.** (a) The round-36 calibration row names `R25-02`, `R29-01`, `R29-02`
with their state; (b) `SCORECARD.md:701`'s present-tense capability count
becomes the live 70, with the historical 59 retained as the `R21-03` record.

**No-work control (executed before freeze).** The predeclaration tree with no
fix applied → `4` (`controls/nowork-c1.out`). A do-nothing round cannot reach 0.

**Forgery / fail-closed controls (executed before freeze).**
`controls/forge-stale-c1.out` (SCORECARD number set to 71 → stale stays 1),
`controls/forge-sd5-early-c1.out` (reds planted in the round-34 row only → SD5
stays 3), `controls/setup-c1-missing-c1.out` (instrument removed → exit 2, no
integer).

## C2 — freshness: declared release clocks re-observed, drift 15 → 0

**Declared claim.** At the landing revision `bash plans/round-36-c2.sh` prints
one integer — `clock=feed` rows in `corpus/release-clocks.tsv` whose
`observed_version` or `verdict` differs from the committed live receipt
`.ufo/waves/round-36/controls/observe-live.json` (sha256
`3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`,
observed 2026-11-04T23:42Z) — and that integer is **0** (BASE: **15**).

**Measured BASE drift** (one `--observe` run, 20 feed rows):
Vault `2.2.0 → 2.2.1` (S012, S013, S022, S023, S024), OpenBao
`2.7.1 → 2.7.2` (S014, S015, S016, S021, S025, S026), Python
`3.15.1 → 3.15.2` (S027, S028, S040, S041). Twelve of the fifteen also change
verdict `not-fired → fired`; three keep `fired` (S012, S027, S028).

**Population, separated before freeze.** Only `clock=feed` rows are counted;
`rendered-quote` rows have no version and are out of population by the table's
own schema. A row the receipt does not carry counts as drift (fail closed).

**Kill rules (frozen).**
- `python3 corpus/release-clock.py` (verify) does not print a CLEAN verdict at
  the landing revision against the repointed default receipt → operability is
  harmed → C2 fails.
- A table value *above* the receipt value is not counted (ordering instead of
  equality), or an empty receipt reads 0 → C2 fails.
- Any historical receipt is rewritten or deleted rather than superseded →
  C2 fails.

**Fix.** The fifteen rows take the receipt's `observed_version`, `observed_at`,
`verdict` and a note naming the receipt; the round-36 receipt becomes the
default observation pin (`receipt_path` + `DEFAULT_RECEIPT_SHA256`) with the
round-26 receipt retained as history; the knowledge entries that state the old
versions gain a re-verification line.

**No-work control (executed before freeze).** Predeclaration tree, no fix →
`15` (`controls/nowork-c2.out`).

**Forgery / fail-closed controls (executed before freeze).**
`controls/forge-c2-version-c2.out` (SOPS row set above its receipt value →
16, equality not ordering), `controls/forge-c2-empty-c2.out` (empty receipt →
20, every row), `controls/setup-c2-missing-c2.out` (receipt removed → exit 2).

## Sourced claim

C2 rests on `S034` (Vault releases feed) and `S035` (OpenBao releases feed),
re-opened this round with the lane's own access date and located quotes in
`corpus/lessons/round-36.md` §Gate; `S040`/`S041` (Python docs pages) cover the
Python rows. No row is appended unless an admitted entry cites it.

## Frontier step (§2b)

- `corpus/SOURCES.md` census before → after with
  `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`.
- Rows touched: `S034`, `S035`, `S040`, `S041` — `recheck`/`used-by`/observation
  cells only, old → new logged in the lesson.
- Mistake mined into `corpus/lessons/round-36.md` §Mistakes: round 35's
  calibration row omitted the reds its own lane-status contract requires, and
  `SCORECARD.md` sat outside every self-count check for fifteen rounds, so a
  stale capability count survived every "self-description" round.
- Assimilation: `considerthese/2026-10-26.md` mined; proposals 2 and 3 are
  already implemented (lane-status line, feed-token agreement) and D1 is
  discharged, so no new proposal is taken this round.

## Wave

One v1 wave, 13 seats (executor 3, scribe 2, scout 2, connector 1, reviewer 2,
critic 1, mutation-tester 1, sentinel 1; 5 attack seats = 38 %). The L1 holds
the canonical planner seat (the validator rejects `planner`). Seats deliver
files under `.ufo/waves/round-36/build/<seat>/`; the L1 is the only integration
owner and the only writer of lane production files.
