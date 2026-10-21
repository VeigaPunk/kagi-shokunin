# CritNoAxisHarm — round 26 C1: on-release population vs clock binding

Seat: `KagiR26.CritNoAxisHarm` (critic, leaf). Read-only. No build, test, lint, formatter or `release-clock.py` run. No installs.

## Scope and observed state

- BASE observed: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches the frozen BASE).
- Inspected: `plans/round-26.md`, `corpus/lessons/round-25.md`, `corpus/release-clock.py` (lines 28, 341–346, 377–408, 448–580, 706–735, 795–827, 1557–1604), `corpus/release-clocks.tsv`, `corpus/SOURCES.md` (BASE and live), `corpus/claim-ledger.tsv:82-83`, `corpus/sources-census.sh` (recheck rules), `corpus/lessons/round-26.md` (live), `SKILL.md` (live diff), `.ufo/waves/round-26/{observe-1.json,observe-run.json,tools/replay-current.sh,frozen/}`.
- During the review, the L1 had **uncommitted live edits** in production: `git status --short` showed ` M SKILL.md`, ` M corpus/SOURCES.md`, `corpus/lessons/round-26.md` present, and `corpus/release-clocks.tsv` unchanged (sha `53264aad…` = BASE). This report attacks that candidate as it was observed. It is not a closure.

## The attack: the correction moves the active Python teachings off the release clock, and the gate stays green

What the question anticipated was the loud case: new `on-release` rows with no binding. The candidate avoids that case by tagging the successor rows `90d`. That avoids `UNBOUND`, but the release-sensitive teaching leaves the clocked population. The clocks stay on the superseded rows, and those clocks have already fired, so they can never signal again.

### Evidence

1. **The successors are off-clock.** Live `corpus/SOURCES.md:47-48`:
   - S040 "supersedes S027", anchor "title Python 3.15.1 documentation", recheck `90d`.
   - S041 "supersedes S028", same anchor style, recheck `90d`.
   - S039 supersedes the feed row S036 with recheck `90d`. That is correct, because feed rows are `90d` by design (round-25 lesson: "no clock for the clock").
2. **This breaks the corpus convention 7 to 0.** Every earlier row that supersedes an on-release row is itself on-release and bound: S019→S007, S020→S006, S022→S012, S023→S013, S025→S014, S026→S016, S032→S007 (an awk sweep of the `supersedes S0..` cells; all are `recheck=on-release`, and all appear in `release-clocks.tsv` column 1). S040 and S041 are the first exceptions.
3. **S012 is the precedent the lesson cites, and it re-armed.** Round-25 lesson L117-127: S012's clock fired, the teaching was re-verified, and "S022 already supersedes S012's scope". S022 is bound (`release-clocks.tsv:19`, `derived:` 2.2.0, not-fired). So the Vault scope kept a live clock after its fire. The Python scope does not.
4. **The S027/S028 clocks are spent.** A fired verdict is sticky:
   - `observe_one` computes the verdict from the TSV anchor (`release-clock.py:732`): `fired` unless parsed == anchored.
   - `evaluate` accepts `fired` whenever observed ≠ anchored (`:524-526`).
   - The anchor stays `3.15.0` (frozen after-profile TSV: `S027 3.15.0 3.15.1 2026-10-21 fired`), so every future release returns the same `fired`.
5. **The 90d successors are never observed.** `evaluate` counts only `recheck == "on-release"` (`:462-465`). `run_observe` skips anything that is not on-release (`:804`). Neither `sources-census.sh` nor `release-clock.py` ties a superseding row's recheck to its predecessor's: the census checks `recheck:` only in knowledge-entry headers (`sources-census.sh:340`).
6. **The R25-04 pin cannot see the change.** `claim-ledger.tsv:83` pins `on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15`. With S040/S041 at `90d`, on_release stays 28 and R25-04 stays CLEAN.

### Counterexample (from code paths, not run)

Suppose Python 3.15.2 or 3.16.0 ships with a changed `\s` or `html.unescape` documentation sentence.

- A new `--observe` gives S027/S028 `parsed_version` 3.15.2 and verdict `fired`. That is byte-for-byte the same verdict as in today's `.ufo/waves/round-26/observe-1.json:249-266`.
- S040 and S041 are absent from the receipt.
- R25-04 stays CLEAN, and the round-26 replay stays CLEAN with `fired=3`.

The first trigger for any Python documentation teaching is then the 90d calendar, 2027-01-19. At BASE, the same event class (a stable Python release) flipped `not-fired → fired`, which is the signal that routed this round. The candidate uses up that signal and does not re-arm it. This is a freshness regression against round-25's C3 capability: "every `on-release` recheck bound to a fireable clock". The claim stays formally true while losing its meaning for the rows that are actually relied on.

### Calibration overclaims in the live text

The candidate's wording implies the clocks still monitor, when they cannot fire again:

- `SOURCES.md` round-26 search log: "the original S027/S028 on-release clocks remain bound and observable, not demoted or removed."
- `corpus/lessons/round-26.md:3`: "original S027/S028 on-release clocks remain bound and may be observed again".
- `corpus/lessons/round-26.md:33-34`: "S027/S028 retain their original on-release cadence and bindings".

Each statement is literally true. None says that the clocks are spent and that the teachings being relied on now (S040/S041) have no release clock.

### Secondary: the replay does not cover the current registry

- `frozen/inputs.sha256`: `after/corpus/SOURCES.md` = `de198f7b…`, which equals `git show HEAD:corpus/SOURCES.md | sha256sum` (BASE). The live file is `aff9ab77…`. The "after" profile has 0 S040/S041 rows and on-release=28.
- So `replay-current.sh after` CLEAN never examined the correction rows. Had they been on-release, the replay would not have shown `UNBOUND`.
- `replay-current.sh:13-16` derives `--receipt-sha` from the same file it checks, so that pin is vacuous. Integrity rests on `inputs.sha256`, which lives inside the same directory and attests to itself. The SKILL diff still calls this "byte-pinned".

### Impacted axes

- **Freshness:** harmed. There is no release-driven re-open for the Python teachings after round 26.
- **Calibration:** harmed. The wording quoted above reads as live coverage.
- **Operability:** unchanged. The gate stays green, and that is exactly why the escape is quiet.

## Rejected overclaim: "unbound on-release population is silently missed"

This is false at BASE. A registry row with `recheck=on-release` and no binding produces:

- `UNBOUND Sxxx` from `evaluate` (`:481-486`),
- `passed` false (`:579`), so `RELEASE_CLOCK: FAILED` and exit 1,
- a broken R25-04 regex, because on_release ≠ 28.

A binding without a receipt record gives `NOT OBSERVED` (`:552-554`). The one quiet spot is the observe summary line: `run_observe` skips unbound rows (`:804`), so `RELEASE_CLOCK_OBSERVE: wrote N observations (failed=0 …)` never mentions them. Only the `RELEASE_CLOCK:` line that follows does. A lesson that quotes only the observe line would overstate completeness.

## Structural constraint every cutover must respect

One TSV validates exactly one receipt. `receipt_matches` (`:377-408`) compares the TSV verdict and observed_version with each record. BASE evidence: `observe-run.json` shows the new receipt evaluated against the BASE TSV as `RECEIPT-MISMATCH S027`, `RECEIPT-MISMATCH S028`, `FAILED (… observed=26 fired=1 …)` with exit 1.

Two consequences follow:

- Any production TSV change for S027/S028, and any new on-release row, makes R25-04 red, because its default receipt is byte-pinned at `release-clock.py:28` and `:450`.
- "R25-04 unchanged and green" is compatible only with an unchanged on-release population and an unchanged TSV. That is the candidate's choice, and it is why the successors went to `90d`.

## Smallest safe corrections (the L1 or the judge picks; this is a tradeoff, not just a defect)

**Option A: re-arm, which favours freshness.**

1. Set S040 and S041 to `recheck: on-release`.
2. Add production bindings for them: `feed`, `feed_source_id` S039 (kind docs, 90d, same URL, so `BADFEED` passes), anchored `3.15.1` with no `derived:` (the anchor "Python 3.15.1 documentation" satisfies `version_is_named`, `:345`), observed `3.15.1`, `not-fired`.
3. Set the S027/S028 rows to `3.15.0 / 3.15.1 / fired`, like S012.
4. Re-observe to a new, exclusive receipt path. `observe-1.json` has no S040/S041 records, so it would give `NOT OBSERVED`.
5. Add a new ledger row with explicit `--receipt <new> --receipt-sha <literal sha>`, pinned to `on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15`.

The `derived=15` pin also catches the cheaper laundering path: a `derived:` relabel of S027/S028 skips the anchor check (`:518`) and would read `derived=17 fired=1`.

Unavoidable cost: R25-04 turns red. It needs a named, append-only expectation migration to its honest FAILED output (old and new retained, following the round-25 `expectation-migrations.json` precedent). It must never be migrated to green, and the default receipt path and SHA must not be touched. `stamps.tsv:70` (`release-clocks.tsv`) needs the existing restamp flow.

**Option B: keep the candidate's shape, but calibrate it.** This is the mandatory minimum if Option A is refused.

1. Replace the three "remain bound / observable / retain cadence" phrases with a plain statement: S027/S028 clocks are spent (anchored 3.15.0, sticky `fired`); after round 26 no Python documentation teaching has a release clock; the next re-open is the manual 90d recheck due 2027-01-19 or a manual re-open on a new stable feed item.
2. Either rebuild `frozen/after` from the live registry, or label it "BASE registry plus two binding edits; S039–S041 not evaluated".
3. Stop calling the self-derived `--receipt-sha` "byte-pinned".

**Rejected escapes**, because each produces green while harming calibration:

- a `derived:` relabel of S027/S028 (`:518` bypass);
- switching `DEFAULT_RECEIPT_SHA256` or the default path to the round-26 receipt (the R25-04 command text would stay the same while its evidence changed, which is false provenance);
- `90d` successors without the Option B disclosure.

## Commands run (all read-only)

`git rev-parse HEAD`; `git status --short`; `git diff --stat`; `git diff corpus/SOURCES.md SKILL.md`; `git show HEAD:corpus/SOURCES.md | sha256sum` → `de198f7b…`; `git show HEAD:corpus/release-clocks.tsv | sha256sum` → `53264aad…`; `sha256sum corpus/SOURCES.md corpus/release-clocks.tsv` → `aff9ab77…`, `53264aad…`; `sha256sum .ufo/waves/round-25/observe-1.json` → `b74c8ee3…` (= `DEFAULT_RECEIPT_SHA256`); `sha256sum .ufo/waves/round-26/observe-1.json` → `9a1cefec…`; awk recheck and supersedes sweeps of `SOURCES.md` (BASE: 28 on-release, 10 × 90d); `cat frozen/inputs.sha256`; grep over the frozen TSVs. Unrun: the release-clock selftest, observe or offline gate; the ledger; the census. None of these is claimed to pass.

Lane-authored advice only. This is not a non-author closure.

## Addendum — reply to the L1 re-arm plan (2026-10-21 13:42Z)

The L1 accepted the finding. Its plan: re-arm S040/S041 as on-release at 3.15.1 via S039, keep the old anchors fired, migrate the default receipt and ledger to a new 30-record receipt with an explicit old/new record, and keep the frozen 28-record replay separate with its original code. This review accepts the plan **with the conditions below**. They are unverified until the integrated candidate is checked.

1. **Changing the default is acceptable only as a named migration.** Retain R25-04's old pattern and note in the migration record. Pin the new expectation as `on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15`. Update every current-tense "default is the round-25 receipt" statement, otherwise they become stale self-description (M25-1 class): `release-clock.py:450` and the `:1562` argparse help, `SKILL.md:787`, `corpus/README.md:181-184` and `PROVINCE.md:54`. Write the new receipt to a new, exclusive path; never overwrite `round-26/observe-1.json`, which holds 28 records.
2. **Derived must stay 15.** A value of 17 would mean S027/S028 were laundered through `derived:` (`:518`).
3. **Pin knock-on effects.** A code change alters `stamps.tsv:69` (`release-clock.py`). A TSV change alters `stamps.tsv:70`. Any new selftest cases move R25-03 and the self-count rows SC-CLOCK-SELFTEST and PV-CLOCK-SELFTEST.
4. **Receipt-SHA rebuttal: partly accepted.** `inputs.sha256` is independent of the wrapper's recomputation. But it sits inside the directory it attests to, and at observation time `.ufo/waves/round-26/` was untracked. A tamperer who rewrites both the receipt and `inputs.sha256` passes `sha256sum --check`. Authority is independent only if a digest of `inputs.sha256`, or the receipt SHA itself, is pinned as a literal **outside** the frozen directory (the ledger row or the wrapper), and only once it is committed. The tamper test must include the case where `inputs.sha256` is modified together with the receipt.
5. **Frozen 28-record replay.** It must keep using the BASE registry (`de198f7b…`) and the BASE `release-clock.py` (`f1a8237c…`), and be labelled as a historical replay, not current.

