# FinalBookkeeping — residual review, round 26 candidate

Seat: `KagiR26.FinalBookkeeping` (residual reviewer, lane-authored advice).
Candidate: `d30c9892a7377b8b5a51817d1db8b81eaddcc397` vs frozen BASE `1bf3eec48d3761580ffd375c88143232485ae814`.
Scope: stamp89 / source41 / ledger65 / heading32 cardinalities, identity migration bookkeeping, retention of all old paths/IDs, unchanged `corpus/self-counts.tsv` doc bindings (38 rows). Read-only; no gate executed (no `claim-ledger.sh verify`, `sources-census.sh`, `release-clock.py`, `revision-audit.py`, `row-identity.sh`, `self-counts.py` runs — membership digests were recomputed by hand under `LC_ALL=C` matching each script's own documented rule).

## Findings by severity

No blocking or advisory defect found in the assigned scope. Observed facts below; items marked [INFERENCE] are interpretation, not measured.

## Verified — observed

| Check | Command | Observed |
|---|---|---|
| stamp89 | `grep -c '[^[:space:]]' corpus/stamps.tsv` | `89` — matches `R12-03` pin `^89$` (corpus/claim-ledger.tsv:28) |
| source41 | `grep -c '^S' corpus/source-fetches.tsv` | `41` — `rows=41` in `R21-02` pin (claim-ledger.tsv:52) |
| ledger65 | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | `65`; BASE also `65` — no claim row added/dropped in round 26 (R21-04 `^65$` unchanged, claim-ledger.tsv:54) |
| heading32 | `grep -c '^## Round ' SCORECARD.md` | `32` — matches `R13-01` `^32$` (claim-ledger.tsv:29); only added heading is `## Round 26 — bounded release-drift response` (SCORECARD.md:1017) |
| stamp paths | set-diff BASE→candidate path column | exactly one addition `corpus/lessons/round-26.md`, zero drops/renames |
| ledger IDs | set-diff BASE→candidate `^R` field1 | empty — all 65 IDs retained byte-identical; exactly 8 rows differ (all in migrated-expectation set: R12-03, R13-01, R21-02, R22-03, R24-05, R24-06, R24-15, R25-04) |
| R24-05 digest | `awk '{print $1}' stamps | LC_ALL=C sort | sha256sum` | `25a19776627e…0121e` = pin (claim-ledger.tsv:68) |
| R24-06 digest | `grep '^## Round ' SCORECARD.md | sha256sum` | `980bbdcaa7ef…d3ac` = pin (claim-ledger.tsv:69) |
| R24-15 digest | added-vs-`c2cab35` set = 26 paths, sha256 in file order | `8ddc68f9e8b0…00a5` = pin (claim-ledger.tsv:78); added count 26 = `R22-03` `added=26` (claim-ledger.tsv:57) |
| source rows | BASE→candidate `source-fetches.tsv` | append-only: `+S039/+S040/+S041` (rows 80–82), all 38 old rows byte-identical; field2 counts `37 mined / 1 queued / 3 rejected` = pin fields `mined=37 rejected=3` |
| SOURCES.md registry | `| A |` rows 36→39; on-release rows 35→38 line count, 30 data rows | matches `A=39`; S039–S041 present (SOURCES.md:46–48); no old `| S0` row edited (diff shows only `+` registry rows) |
| clock bindings | `release-clocks.tsv` | 30 data rows, 1 comment; BASE 28 rows retained, S027/S028 updated in place to `fired` with original `3.15.0` anchors kept (rows 24–25), `+S040/+S041` `not-fired` at named `3.15.1` anchors bound to feed `S039` (rows 30–31). `fired` count = 3 (S012, S027, S028) = `R25-04` `fired=3`; `derived:` notes = 15 = `derived=15` |
| on_release=30 | SOURCES.md `on-release` IDs vs `release-clocks.tsv` ID column | identical 30-member set (S005–S032 + S040/S041) → `bound=30 unbound=0` consistent with `R25-04` pin (claim-ledger.tsv:83) |
| receipt migration | `release-clock.py:28` `DEFAULT_RECEIPT_SHA256` = `13b8540c…a169`; `:450` default path `round-26/observe-2.json` | `sha256sum .ufo/waves/round-26/observe-2.json` = `13b8540c…a169`; receipt holds 30 observations, IDs = the 30 clocks, verdicts `{quote-located:10, not-fired:17, fired:3}` |
| historical receipt preserved | `git show BASE:.ufo/waves/round-25/observe-1.json | sha256sum` vs candidate | `b74c8ee3…9f92` identical at both revisions; old code/table/receipt copies frozen: `frozen/observe-round25.json` = `b74c8ee3…`, `frozen/release-clock.py`/`frozen/before/*` digests = BASE values per `frozen/expected.json` |
| expected-red run | `.ufo/waves/round-26/observe-run.json` | recorded `exit:1`, `RECEIPT-MISMATCH S027/S028`, `FAILED (on_release=28 … observed=26 fired=1)` — honest pre-migration failure, not rewritten green |
| overlay manifests | `frozen/expected.json`, `rearmed/expected.json` | `before` FAILED with `UNBOUND S040/S041` + mismatches; `after` CLEAN `on_release=30 bound=30 … fired=3`; `rearmed/after` input digests = candidate `SOURCES.md`/`release-clocks.tsv`/`source-fetches.tsv`/`release-clock.py` values; `frozen/before` digests = BASE values |
| no deleted/renamed paths | `git diff --name-status BASE candidate` | `M`/`A` only, zero `D`/`R` across 239 files |
| self-counts unchanged | `git show BASE:corpus/self-counts.tsv | cmp - corpus/self-counts.tsv` | byte-identical; 38 data rows (ids `SC-*`/`PV-*`/`RD-*`), zero binding changes |
| doc numbers | `git show candidate:PROVINCE.md/README.md` | `89 revision stamps + 65 claim rows` (PROVINCE.md:52, SKILL.md diff, README.md:64–65) agree with new pins; stale `88` remains only inside dated-history clauses (out of population per self-counts.tsv header rule) |
| migration journal | `.ufo/waves/round-26/expectation-migrations.json` | all 8 migrated rows recorded with exact old/new text; `default_receipt.old_receipt_unchanged=true`; `existing_status_recheck_used_by_changes=[]`; `stamp_membership` 88→89 with dropped=[] |
| stamp generation | `.ufo/waves/round-26/stamp-integration.json` | `claim-ledger.sh stamp` argv enumerates 89 paths, `STAMPED: n=89`, exit 0 |
| stamped metadata | sha256/`wc -l/-c` per changed file vs `stamps.tsv` rows | all 12 changed-file rows exact-match the **committed blobs** (verified via `git show <candidate>:<path>` where worktree is dirty — see risk §2) |
| scorecard/log honesty | `SCORECARD.md:1017–1046`, `LOG.md` diff | saturation `9→9`, `saturation9/window3`, no waiver claimed; round-25 C2 `lone-clone INCOMPLETE/48` explicitly unclosed; `wave-outcomes.json` `dead_count=23` = `terminal-error-notices.json` list length 23, `completed_reports=41` matches LOG line |

## [INFERENCE]-flagged observations (not defects)

1. **Clock-ID/source-ID overlap.** `S040`/`S041` exist both as registry sources (`source-fetches.tsv`, SOURCES.md) and as `release-clocks.tsv` clock IDs. Consistent with pre-existing convention (clocks S005–S032 already share the S-prefix space) and `release-clocks.tsv` feeds its own `feed_source_id` column (`S039`), so no ambiguity in the binding relation — noted only as an invariant to preserve.
2. **`stamps.tsv` claim-ledger byte count dropped** `28004 → 27563` with rows still `83`. Expected: the eight migrated notes are shorter than the BASE text. Consistent with every other in-place migration round.
3. **`observed=26`** in the recorded pre-migration FAILED summary is consistent with 28 bound clocks minus the two `RECEIPT-MISMATCH` bindings; [INFERENCE] on evaluator semantics — I did not execute the gate or re-derive its counting code line-by-line.
4. **Ledger `R21-04` regex `^R[0-9]+-[0-9]+`** would also match a hypothetical `R26-*` row; candidate adds none, so `^65$` remains true.

## Residual risks and verification gaps

1. **Dirty worktree vs stamped blobs (highest practical risk, outside candidate).** `git status --short` at review time shows uncommitted ` M corpus/README.md` (sha `792da0f3…`, +30 bytes) and ` M corpus/lessons/round-26.md` (sha `1cf9dd31…`, +36 lines) plus modified `tools/final-measure.py` and `tools/replay-current.sh`. The **committed candidate blobs match `stamps.tsv` exactly** (`d26518618a…`, `8122023dfd…`), so this is live post-candidate work — but if L1's final immutable suite runs `verify` against this dirty tree rather than a clean checkout of `d30c989`, `corpus/README.md` and `corpus/lessons/round-26.md` will read STALE. [INFERENCE] on suite semantics.
2. **Executed-check evidence absent by design.** I ran zero gates (per assignment: read code/data only, no full gate execution). `expectation-migrations.json:86` already reserves `final-verification.json` for L1's post-integration suite; its absence at candidate is consistent, not a gap.
3. **`replay-current.sh` manifest pins unverified against file bytes.** I read the two manifest digests (`2e4767…`, `cbb420…`) but did not hash `inputs.sha256` or run the wrapper; `frozen/` and `rearmed/` `expected.json` input digests do cross-check against live file sha256s I computed. L1's suite covers the wrapper.
4. **Receipt-record field coverage.** `observe-2.json` verdicts tally to the pin, but I did not field-level diff all 30 records against the clocks' anchors beyond verdict/ID; per-record `parsed_version`/`anchor` agreement is asserted by the `after`-CLEAN expectation only.
5. **`SOURCES.md` line-level `on-release` count grew 35→38** (three new rows each containing the token) while on-release *data rows* grew 28→30 — a naive `grep -c` reviewer could misread this; the ledger binds via `sources-census.sh`, not grep, so no bookkeeping error.

## Tools used

System `git`, `sha256sum`, `awk`, `sort`, `comm`, `diff`, `grep`, `python3` (JSON reads). No installs or updates performed.
