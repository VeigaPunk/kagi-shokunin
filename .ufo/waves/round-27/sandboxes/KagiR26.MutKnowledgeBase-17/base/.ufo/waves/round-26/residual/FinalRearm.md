# FinalRearm — residual attack on the round-26 explicit rearm

Seat: KagiR26.FinalRearm (critic, lane-authored advice, not non-author closure).
Candidate: `d30c9892a7377b8b5a51817d1db8b81eaddcc397`; BASE `1bf3eec48d3761580ffd375c88143232485ae814`.
Scope: S040/S041 on-release, named 3.15.1 anchors, feed S039, S027/S028 original anchors retained fired, derived 15; code/table/default; whether 3.15.2 can fire successors.
Mode: source-based falsification only. I did not run `release-clock.py` (default, `--selftest`, `--observe`), `replay-current.sh`, `final-measure.py`, or any build, lint, test, or formatter. No installs. No production, index, or jj writes. This file is my only write.

## Verdict

No blocking defect in the rearm as declared. Within the point-observation scope, the table, default, receipt, and counts agree with each other in source. A 3.15.2 feed does fire S040/S041 at the observer.

One real counterexample class remains, and the rearm makes it bite. Both the observer and the evaluator treat "fired" as *observed ≠ anchored*, not *observed > anchored*. So a stale or window-evicted feed would un-fire S027/S028 and falsely fire S040/S041, and the evaluator would accept that table. This pre-dates round 26 (it comes from round 25). It is fixable debt, not a reason to reject the rearm, but it should be named honestly rather than left implicit. There are also two low-severity wording and provenance gaps (F2, F3).

## Exercised source checks (exact commands, observed output)

All read-only probes, run from `/home/vgpnk/Projects/shokunin/kagi-shokunin`:

- Working tree vs candidate blobs: `git show d30c9892:<f> | sha256sum` vs `sha256sum < <f>`. These were equal for `corpus/release-clock.py` (`ef17654e…`), `corpus/release-clocks.tsv` (`99a9b4bc…`), `corpus/source-fetches.tsv` (`a1415da3…`), and `.ufo/waves/round-26/observe-2.json` (`13b8540c…`). Line citations below therefore apply to the candidate.
- `git diff --quiet 1bf3eec4 d30c9892 -- .ufo/waves/round-25` printed `round-25 dir unchanged`.
- Snapshot byte identity (sha256 compared with git blobs). SAME: `frozen/release-clock.py`==BASE `corpus/release-clock.py`; `frozen/before/corpus/{release-clocks.tsv,SOURCES.md,source-fetches.tsv,rendered-text-v1.py}`==BASE; `rearmed/release-clock.py`==candidate; `rearmed/after/corpus/{release-clocks.tsv,SOURCES.md,source-fetches.tsv}`==candidate; `rearmed/before/corpus/release-clocks.tsv`==BASE. DIFF, as designed: `rearmed/before/corpus/SOURCES.md` is the current 41-row registry, and `frozen/after/corpus/release-clocks.tsv` is the intermediate S027/S028-only profile without S040/S041.
- Receipt hashes: `.ufo/waves/round-25/observe-1.json` = `.ufo/waves/round-26/frozen/observe-round25.json` = `b74c8ee3…` (the BASE `DEFAULT_RECEIPT_SHA256`). Active `observe-2.json` = `rearmed/observe-2.json` = `13b8540c…`, which equals candidate `corpus/release-clock.py:28`.
- Receipt structure (python3 JSON read of `observe-2.json`): 30 records, verdicts `not-fired` 17 / `quote-located` 10 / `fired` 3. The fired ids are S012, S027, S028. S027/S028/S040/S041 all have `parsed_version` 3.15.1 and `sha256` `11c86a34…`.
- Identity drift (fields id, clock, url, http_status, error, parsed_version, located, verdict): round26 `observe-1`→`observe-2` diffs `[]`, with only S040/S041 added. Body-sha-only diffs are S005/S006/S020. Round25→`observe-2` identity diffs are `['S027','S028']`.
- `observe-2.json` was produced by a real `--observe`: `.ufo/waves/round-26/observe-rearmed-run.json` records argv `python3 -B corpus/release-clock.py --observe …/observe-2.json`, exit 0, `wrote 30 observations (failed=0 fired=3)`. It was not hand-merged.
- S039 body: `captures/S039.body` sha `11c86a34…` equals `captures/metadata.json` S039 sha, `source-fetches.tsv` S039 field 10, and the four Python receipt records. It has 10 `<item>`s with titles in order: 3.14.9, 3.15.1, 3.16.0a1, `Python install manager 26.4`, 3.15.0, 3.15.0rc3, 3.11.17, 3.10.22, 3.12.15, 3.14.8.
- Table counts (awk on TSV): BASE derived 15, candidate derived 15. Candidate fired rows are S012, S027, S028.
- Registry columns (awk on `corpus/SOURCES.md`): S027 L33 and S028 L34 are `mined / on-release`, anchors name "Python 3.15.0". S036 L42 is `90d`. S039 L46 is `docs / A / mined / 90d`. S040 L47 and S041 L48 are `docs / A / mined / on-release`, anchors contain "title Python 3.15.1 documentation".
- Grep showed no selftest case with observed < anchored (pattern `regress|downgrad|older|1\.2\.2|observed="1\.[01]`, no hits). No selftest calls `main()` without `--receipt` (`release-clock.py:1447,1465,1475,1488` all pass `--receipt`/`--observe`).

## Findings

### F1 — Downgrade or eviction un-fires predecessors and false-fires successors (observed in code; real-world trigger is inference). Severity: medium, pre-existing, fixable.

**Counterexample.** Suppose a later `--observe` gets a feed whose maximum stable item is 3.15.0. That can happen from a cached edge serving the older body, or from 3.15.x scrolling out of a 10-item window. Then:

- `observe_one` (`corpus/release-clock.py:730-734`) writes `verdict = "not-fired"` for S027/S028, because 3.15.0 == anchored 3.15.0. It writes `"fired"` for S040/S041, because 3.15.0 ≠ 3.15.1.
- `evaluate` (`corpus/release-clock.py:524-528`) accepts a table carrying exactly that: `fired` requires only `norm(observed) != norm(anchored)`, and `not-fired` requires equality. That table would be CLEAN.
- Result: the plan's invariant "S027/S028 retain original anchors and remain fired" (`plans/round-26.md:24`) is not enforced by the gate. The successors can "fire" on a regression, which contradicts the rows' own meaning ("past it, so the clock FIRED", S012 note, `corpus/release-clocks.tsv:9`).

**Why this is not hypothetical** (observed artifacts plus inference). The round25 receipt observed S027 at `2026-10-21T11:31:53Z` with `parsed_version` 3.15.0 (sha `326a2dc4…`). Yet S039 records the 3.15.1 item with pubDate `Wed, 21 Oct 2026 09:59:50 +0000` (`SOURCES.md:46`). The lesson itself leaves "cached-edge versus backdated insertion" unresolved (`corpus/lessons/round-26.md:130-136`). The feed also has only 10 items (observed count), and `parse_latest_version` takes the max only over present items (`release-clock.py:685-699`).

**Impacted axes:** freshness (false "fired" and silent un-fire), provenance (a "fired" bit that does not mean "a newer release exists").

**Pre-existing, not introduced:** the inequality logic is unchanged from BASE. The rearm is what creates a successor whose anchor sits *above* an older observable state, so a regression now flips two bits per teaching.

**Smallest safe correction** (for a later round; production is frozen):
- In `observe_one`, when both versions are numeric `X.Y.Z` and parsed < anchored, record `error: "feed max stable below anchor"` (a failed observation) instead of `fired`.
- Mirror the check in `evaluate` at line 524: for numeric anchors, require observed > anchored for `fired`. Leave the non-numeric S012 `v1.21.x` path unchanged.
- Add one selftest for the downgrade case.

For this round, the honest minimum is one Limits bullet in `corpus/lessons/round-26.md` naming this as retained debt. This is a tradeoff the judge may accept as named debt. It does not falsify C1's point observation.

### F2 — "Separately replayable" original round25 profile is never replayed (observed). Severity: low.

- **Claim:** `SCORECARD.md:1026` says "original round25 receipt/code/tables remain separately replayable"; `corpus/README.md:200-201`, `SKILL.md:793-795`, and `LOG.md:1444` say they are preserved or frozen.
- **What the replay actually covers:**
  - For the frozen root, `tools/replay-current.sh:9-15,27-28` selects `observe-1.json`, which is round26's first receipt, not `observe-round25.json`.
  - `frozen/expected.json` therefore expects BASE code + BASE tables + round26 receipt → FAILED (before), and the S027/S028 profile → CLEAN 28/fired3 (after).
  - `final-measure.py:94-97` only checks the round25 receipt's bytes and sha. It never evaluates the round25 receipt against BASE code and tables.
- **Gap:** "matching code/tables" is shown by byte identity (my SAME checks above), but the round25 CLEAN replay is never run. I infer, but did not run, that `python3 .ufo/waves/round-26/frozen/release-clock.py --root .ufo/waves/round-26/frozen/before --receipt .ufo/waves/round-26/frozen/observe-round25.json --receipt-sha b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92` would print the BASE R25-04 line (`on_release=28 … fired=1 derived=15`).
- **Impacted axis:** provenance/honesty, as an unexercised "replayable" claim.
- **Smallest correction:** either L1's final measurement runs that one command and records it, or SCORECARD:1026 says "preserved byte-identically" instead of "replayable".

### F3 — "Retain on-release cadence" for new rows (observed). Severity: low, wording.

S040/S041 are new rows; their only prior cadence was the rejected, never-landed 90d draft (`corpus/lessons/round-26.md:33-35`, `expectation-migrations.json` `registry.draft_rejected_cadence`). Yet these places say they "retain on-release cadence":
- `corpus/README.md:205`
- `SKILL.md:801`
- `LOG.md:1440`
- `PROVINCE.md:54`
- the `R21-02` note at `corpus/claim-ledger.tsv:52`

A reader of the landed history would infer an earlier on-release state that never existed. The correct phrasing is "are bound on-release". This has no gate effect.

### F4 — 3.15.2 fires the successors (observed source trace; final-measure instrument not run by me). No defect, but the fixture is narrow.

**Trace:**
- Both successors are eligible for observation: on-release (`SOURCES.md:47-48`), with exactly one TSV row each (`release-clocks.tsv:30-31`) on clock `feed` (`run_observe`, `release-clock.py:800-811`).
- A title `Python 3.15.2` matches `STABLE_TITLE_RE` (`:649`). The max over items yields 3.15.2 (`:699`). `observe_one` then gives 3.15.2 ≠ 3.15.1 → `fired` (`:730-734`).
- S027/S028 stay `fired` (3.15.2 ≠ 3.15.0). The observer's summary fired count goes 3→5 (`:822-825`).

**How the fire surfaces:** against the current table, the new receipt yields `RECEIPT-MISMATCH` for all four Python ids, because `receipt_matches` compares `parsed_version` to the table's `observed_version` (`:396`). At the gate, a successor's fire looks the same as a predecessor's observed-version drift; only per-record verdicts in the new receipt tell them apart. This is inherited design ("--observe never rewrites TSV").

**Fixture narrowness:** `final-measure.py:114-119` monkeypatches `request_body` with a one-item RSS and calls `observe_one` directly. It does not go through `run_observe` eligibility or the evaluator, and it does not use the real backport-first body. A stronger fixture would be `captures/S039.body` with the 3.15.1 title changed to 3.15.2, run through `run_observe`. Optional, not required for QM24 as worded (`corpus/QUALITY.md` QM24, "a later-release fixture must fire the successor").

### F5 — Named anchors, derived 15, on-release 30, fired 3 (observed source trace). No defect.

- **Named anchors:** `version_is_named` (`release-clock.py:341-346`) needs `3.15.1` bounded by characters other than `[A-Za-z0-9.]`. The S040/S041 anchors contain "Python 3.15.1 documentation" (space on both sides). Their notes do not start `derived:` (`release-clocks.tsv:30-31`), so `anchor_ok` relies on naming (`:517-518`). S027/S028 anchors name "Python 3.15.0" (`SOURCES.md:33-34`).
- **Derived 15:** the same 15 `derived:` rows in BASE and candidate (S008–S011, S013–S016, S021–S026, S029). Neither the new rows nor S027/S028 count as derived, because `row_derived = is_derived` (`:526,528`).
- **on_release 30:** the 28 BASE rows plus S040/S041. S039 and S036 are `90d`, as they must be, since a feed source with `on-release` is `BADFEED` (`:512`).
- **Fired 3:** S012, S027, S028 (TSV and receipt agree).

### F6 — Feed S039 binding and provenance (observed). No defect; one low note.

- **Binding:** S039 is kind `docs` (in `FEED_KINDS`, `:358`), recheck `90d`, and its URL equals `feed_url`, satisfying `:509-514`.
- **Body hash:** the capture body sha equals the receipt sha (`11c86a34…`) for all four Python records.
- **Parser on that body (inference from regex, confirmed by reading only):** these are excluded:
  - `3.16.0a1`, `3.15.0rc3` (not `X.Y.Z$`)
  - `Python install manager 26.4` (multi-word, two-part)
  
  The max is 3.15.1 even though 3.14.9 is the first item.
- **Low note:** S027/S028 still name `feed_source_id` S036 (`release-clocks.tsv:24-25`). S036's anchor says newest stable is 3.15.0 (`SOURCES.md:42`), while their observed 3.15.1 comes from the S039 fetch. Feed identity is URL-level, so the evaluator is correct, and keeping S036 preserves the original binding identity. The S027/S028 notes could name S039 as the observation source. Tradeoff only; no change required.

### F7 — Supersede convention and default cutover (observed). No defect.

- **Same pattern as before:** the predecessor stays bound on-release and keeps its verdict; the successor is a new on-release row. Precedent: S012 (fired, `release-clocks.tsv:9`) → S022, and S013/S014/S016 → S023/S025/S026 (`SOURCES.md:28-32`). This is not a second convention.
- **Clean default cutover:** `receipt_path` (`:448-452`) and `DEFAULT_RECEIPT_SHA256` (`:28`) name only round-26 `observe-2.json`. There is no fallback alias to the round-25 path.
- **No other script hard-codes the old receipt:** grep for `b74c8ee|round-25/observe-1|13b8540c` across `corpus/*.{sh,py,tsv,json}` hits only `release-clock.py` and round-26 wave artifacts.
- **Ledger:** `R25-04` (`corpus/claim-ledger.tsv:83`) matches `expectation-migrations.json` `ledger_rows.R25-04.new`, and the old row is journaled.
- **Selftest:** the 67-case claim is consistent with the source, since no selftest case exercises the default path (`:1447-1488`).

### Pending, not defects

Two artifacts promised for later are absent from the candidate tree:
- `census-end.json` (`corpus/lessons/round-26.md:39-40`)
- `final-verification.json` (`expectation-migrations.json` `verification`)

Both are deferred to L1's final measurement, which matches "no unrun check is called passing" (`lesson:83-84`). Nit: `USER_AGENT` still says `round25` (`release-clock.py:35`); this is cosmetic.

## Impacted axes summary

| Finding | Axis | Kind | Action |
|---|---|---|---|
| F1 | freshness, provenance | pre-existing tradeoff exposed by the rearm | name as debt now; numeric-monotonic fire in a later round |
| F2 | provenance/honesty | unexercised claim | run one frozen round25 replay in L1 final, or reword SCORECARD:1026 |
| F3 | provenance (wording) | fixable | "bound on-release" in README/SKILL/LOG/PROVINCE/R21-02 note |
| F4–F7 | — | no defect | optional stronger 3.15.2 fixture through `run_observe` |

C2 lone-clone INCOMPLETE/48 and the round25 receipt bytes are untouched by everything above. `.ufo/waves/round-25` is unchanged between BASE and candidate.
