# CritFinalC2 — round-27 residual falsification of C2 (release-clock REGRESSED rule)

Seat: KagiR26.CritFinalC2-27-t3 (critic). Lane-authored advice, not non-author closure.
Candidate `144babcb892f0a30154880a9f94aa59ca8ddf9c5` (lane HEAD, `corpus/` clean against HEAD);
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. All runs were in `/fast/scratch` clones; nothing ran
inside the lane checkout. No tools were installed or updated.

## Verdict

- The declared C2 counting command reproduces: BASE accepts 4/4 downgrade fixtures CLEAN; the
  candidate gives the exact REGRESSED set on 4/4, and both the control and the live default receipt stay CLEAN30.
- **The candidate accepts two new downgrade classes CLEAN** (counterexamples 1 and 2 below). Both
  were also CLEAN at BASE, so this is not a regression from BASE. But each one defeats the C2 property
  ("a numeric observation below the anchor becomes REGRESSED, never CLEAN") under the same threat model
  as the instrument's own `lie` fixture, where the table and receipt are rewritten consistently.
  Several of them print a summary line byte-identical to the R25-04 pin.
- **There is no false REGRESSED on the live receipt as it stands** (default exit 0, CLEAN30). But the
  byte-identical live receipt (sha `13b8540c…a169`) plus a single-row rearm whose documentation anchor
  is ahead of the feed gives 3 false REGRESSED findings on consistent sibling rows (counterexample 3).
- One fixable defect covers both CLEAN-accepted classes and both cascades: a 5-hunk scratch draft
  (correction A). It keeps the live receipt CLEAN30 and the instrument's 4/4 exact result.

## 1. Reproduction of the C2 instrument

Instrument sha256 `e33e809a…48b1` (working tree; the diff against HEAD is docstring-only). Its inputs at the lane are
`corpus/release-clock.py` `0812b6de…f1ac`, `corpus/release-clocks.tsv` `99a9b4bc…e6fd` (= stamps.tsv:78),
and `.ufo/waves/round-26/observe-2.json` `13b8540c…a169`.

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
python3 .ufo/waves/round-27/tools/c2-measure.py 0a47dd189356ea66ec83c3891eed54526e95b89b before /fast/scratch/critfinalc2/c2-before.json
  exit=0  C2_MEASURE before: downgrades_accepted_clean=4/4 regressed_exact=0/4 control_clean=True default_exit=0
python3 .ufo/waves/round-27/tools/c2-measure.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 after /fast/scratch/critfinalc2/c2-after.json
  exit=0  C2_MEASURE after: downgrades_accepted_clean=0/4 regressed_exact=4/4 control_clean=True default_exit=0
```

Per-fixture last lines after: lie `REGRESSED S040` exit1; rollback `REGRESSED S027 S028 S040 S041` exit1;
unfire `REGRESSED S027 S028` exit1; nonnumeric `REGRESSED S012` exit1; control and default
`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit0.
This agrees with the lane's `.ufo/waves/round-27/c2-after.json` (0 / 4 / True).

## 2. New fixtures (my own harness)

Harness `/fast/scratch/critfinalc2/attack.py` (sha `8cd43519…e178`). It uses the same construction
as c2-measure: a fresh `git clone --no-checkout` of the lane into `/fast/scratch`, a detached checkout of the REV, and the
clone's own table, SOURCES.md and default receipt with only the named rows edited. The receipt is pinned via
`--receipt-sha`. Each fixture runs
`python3 -I -B <clone>/corpus/release-clock.py --root <fx> --receipt <fx>/receipt.json --receipt-sha <sha>`
with env `LC_ALL=C`. It also replays the four c2-measure fixtures and the default run, and probes
`observe_one()` with a fake opener and a public resolver (no network).

```
cd /fast/scratch/critfinalc2
python3 attack.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 cand attack-cand.json            exit=0
python3 attack.py 0a47dd189356ea66ec83c3891eed54526e95b89b before attack-before.json        exit=0
python3 attack.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 A attack-A.json $PWD/draftA.py   exit=0
python3 attack.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 B attack-B.json $PWD/draftB.py   exit=0
```

Results by fixture. "same as R25-04" means the summary line still matches the ledger pin regex
`CLEAN (… observed=30 fired=3 derived=15)`.

| fixture | BASE | candidate | draft A | draft B |
|---|---|---|---|---|
| derived-sops-rewrite | CLEAN, same as R25-04 | **CLEAN, same as R25-04** | INCONSISTENT S008-S011 | same as A |
| derived-vault-rewrite | CLEAN, same as R25-04 | **CLEAN, same as R25-04** | INCONSISTENT S013,S022-S024 | same as A |
| derived-curl-rewrite | CLEAN, same as R25-04 | **CLEAN, same as R25-04** | INCONSISTENT S029 | same as A |
| nonstrict-two-part (S040 `3.15` fired) | CLEAN fired=4 | **CLEAN fired=4** | INCONSISTENT S040 | same |
| nonstrict-four-part (`3.14.0.0`) | CLEAN | **CLEAN** | INCONSISTENT | same |
| nonstrict-suffix (`3.14.0-1`) | CLEAN | **CLEAN** | INCONSISTENT | same |
| nonstrict-fullwidth (`３.14.0`) | CLEAN | **CLEAN** | INCONSISTENT | same |
| nonstrict-python-rollback (all 4 rows `3.14` fired) | CLEAN fired=5 | **CLEAN fired=5** | INCONSISTENT ×4 | same |
| nonstrict-vault-nonnumeric (S012 `1.20` fired) | CLEAN, same as R25-04 | **CLEAN, same as R25-04** | INCONSISTENT S012 | same |
| nonstrict-hidden-fired (S027/S028 `3.14` fired) | CLEAN, same as R25-04 | **CLEAN, same as R25-04** | INCONSISTENT ×2 | same |
| sibling-split (S027/S028 3.15.2, S040/S041 3.15.1, same date) | CLEAN | CLEAN | CLEAN | REGRESSED S040,S041 |
| equal-to-floor (live state) | CLEAN30 | CLEAN30 | CLEAN30 | CLEAN30 |
| regressed-matching-table (S040 3.15.0, table and receipt both `regressed`) | INCONSISTENT S040 | REGRESSED S040 | REGRESSED S040 | REGRESSED S040 |
| regressed-receipt-at-anchor (receipt `regressed`, parsed 3.15.1) | RECEIPT-MISMATCH | RECEIPT-MISMATCH + REGRESSED | same | same |
| ahead-anchor-cascade (S040 rearmed to 3.15.2, live receipt) | INCONSISTENT S040 | **REGRESSED S027,S028,S040,S041** | REGRESSED S040 | REGRESSED S040 |
| derived-typo-floor (S008 anchor 3.31.3) | INCONSISTENT S008 | REGRESSED S008-S011 | REGRESSED S008 | REGRESSED S008 |
| c2-lie / rollback / unfire / nonnumeric | CLEAN ×4 | exact ×4 | exact ×4 | exact ×4 |
| c2-control, default | CLEAN30 | CLEAN30 | CLEAN30 | CLEAN30 |

Results of the `observe_one()` probes at the candidate (BASE values in brackets):

- S040, cropped feed showing 3.15.0: `regressed` [fired]
- S027, previous observation 3.15.1, feed 3.15.0: `regressed` [not-fired]
- S012, vault feed 2.1.0: `regressed` [fired]
- S008, sops feed 3.13.2: `regressed` [fired]
- Equal versions: S040 `not-fired`, S027 `fired`

The observe floor works on the rows as they stand. But when S013 is re-anchored to 2.1.0 on the stale vault feed,
observe gives `not-fired`, and S012 (previous observation 2.1.0) gives `fired`. That is the observe-side half of
counterexample 1.

## 3. Counterexamples

### 1. Downgrade accepted CLEAN via derived anchors (candidate, SOPS / Vault / OpenBao / curl)

- **Evidence.** `anchor_ok = is_derived or version_is_named(...)` (`corpus/release-clock.py:566`).
  A `derived:` row's `anchored_version` is bound to nothing. `feed_floors()` (`:390-410`) takes the max over
  exactly those unbound anchors. Of the 20 feed rows, 16 sit on feeds whose numeric floor is
  entirely derived: SOPS S008-S011, Vault S013/S022-S024 (S012 is non-numeric), OpenBao (6 rows), and curl S029.
- **Fixture.** On the SOPS feed, regress 3.13.3 to 3.13.2 and lower the 4 derived anchors with it. The candidate
  prints `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0,
  byte-identical to the R25-04 pin.
- **The Vault variant defeats C2's own `nonnumeric` closure.** S012 (`v1.21.x`) stays "fired" at 2.1.0
  once the derived siblings S013/S022-S024 are re-derived to 2.1.0.
- **The operational path is a single step.** A stale fetch makes observe write `regressed`. An operator then
  "re-derives" the anchors ("newest stable … when the row was opened"), and re-observing gives
  not-fired / fired and CLEAN (probes above).
- **Impacted axes.** C2 freshness (claim scope) and calibration (the R25-04 pin cannot see it).
- **Classification.** A fixable defect, not a tradeoff. Every live derived anchor is already named by its
  feed source row's anchor cell: S033 `v3.13.3`, S034 `v2.2.0`, S035 `v2.7.1`, S037 `8.23.0`. Binding to the row's
  own note instead would be partial: the S009-S011 notes also name `v3.13.0`, and S029's note names `8.23.1`.

### 2. Downgrade accepted CLEAN via a non-strict observation string (candidate, any feed row)

- **Evidence.** `is_regression()` returns False when `numeric_version(observed)` is None (`:383-387`). The
  feed-row branch only requires `observed_version` to be non-empty and not `-` (`:576`). `receipt_matches`
  compares `norm_version` strings only (`:440-445`).
- **Effect.** `3.15`, `3.14.0.0`, `3.14.0-1` and fullwidth `３.14.0` are all accepted as "fired" below the anchor.
  `nonstrict-python-rollback` (every Python row at `3.14`) is CLEAN, and so is S012 at `1.20` (summary
  identical to R25-04). The real `--observe` path never emits these: `parse_latest_version` is strict.
  So the gate accepts a receipt that its own observer cannot produce. This is the `lie` fixture with one character less.
- **Impacted axes.** C2 freshness.
- **Classification.** A fixable defect. Live observations are all strict X.Y.Z, so requiring
  `numeric_version(observed_version)` costs nothing on the live data.

### 3. False REGRESSED on consistent siblings from one ahead-of-feed anchor (candidate)

- **Evidence.** `feed_floors()` treats every numeric anchor as "a release already recorded" (docstring
  `:393-397`). But a non-derived anchor is a *documentation* version (`version_is_named` against the
  row's own SOURCES anchor), not a feed observation. The lane has a precedent of docs running ahead of the feed: S029/S037
  (curl man page `8.23.1`, unreleased development label, while the feed showed `8.23.0`).
- **Fixture.** Use the byte-identical live receipt (sha `13b8540c…a169`). Rearm S040 so that its SOURCES anchor reads
  `Python 3.15.2 documentation`, with table anchor 3.15.2 and not-fired. The candidate reports `REGRESSED S027`,
  `REGRESSED S028`, `REGRESSED S040` and `REGRESSED S041`, exit 1. S027, S028 and S041 are each internally consistent
  with the actual newest stable release (3.15.1), so three findings are false and the cause is misattributed.
  At BASE only `INCONSISTENT S040` fired.
- **Same mechanism, typo case.** One derived typo (S008 anchored `3.31.3`) reports 4 REGRESSED findings instead of 1.
- **Impacted axes.** Calibration (wrong finding attribution) and maintainability of future rearms.
- **Classification.** Fail-closed, so never a false CLEAN, but a fixable defect. Correction A collapses both
  cascades to the single culprit row.

### 4. Sibling-observation split accepted CLEAN (tradeoff, not a defect)

- `sibling-split`: S027/S028 claim 3.15.2 while S040/S041 claim 3.15.1 on the same feed URL with the same
  `observed_at`. The candidate and draft A both accept it CLEAN.
- The state is impossible for one feed body. It also equals an S040 un-fire if S040 had previously read
  3.15.2 and only S040 was re-observed against a stale stream.
- Draft B (floor also takes the numeric observations on the feed) turns it into REGRESSED S040/S041 and keeps
  live CLEAN30. The cost: a later partial re-observation makes older-dated sibling observations REGRESSED.
  That is a policy choice for L1 and the judge, so it is listed here and not recommended as the minimal fix.
  The plan correction only claims the previous-observation floor "when observing", so this sits within the declared scope.

### Non-findings (held)

- **Equal-to-floor.** The live state stays CLEAN, as the comment at `:573` declares.
- **A table that says `regressed` alongside a regressed receipt.** Typed REGRESSED, exit 1 (BASE: INCONSISTENT).
- **A `regressed` receipt whose parsed version equals the anchor.** RECEIPT-MISMATCH plus REGRESSED, exit 1.
  The REGRESSED label here comes from the receipt verdict alone (`:615`), which is mislabelling but fail-closed.

## 4. Smallest safe correction (correction A, scratch draft only)

The diff is in `/fast/scratch/critfinalc2/draftA.diff` (sha `77012d1d…3d71`); the full file is `draftA.py` `bb1aacf0…4c6d`.

1. Add `feed_recorded(sources, values)`, which is true when `version_is_named(sources[feed_source_id]["anchor"], anchored_version)`.
2. `feed_floors(rows, sources)`: count only feed-recorded numeric anchors.
3. `anchor_ok = (is_derived and feed_recorded(...)) or version_is_named(own anchor, ...)`.
4. Feed-row INCONSISTENT condition: replace `not observed_version or observed_version == "-"` with
   `numeric_version(observed_version) is None`.

Measured effect (table above):

- Every candidate CLEAN downgrade becomes exit 1.
- The ahead-anchor and typo cascades collapse to the culprit row.
- The c2-measure fixtures stay exact 4/4, control and default stay CLEAN30, and S040's live 3.15.1 floor is kept
  (S039 names `Python 3.15.1 item`).

The cost, inferred and not run: the selftest feed source S002's anchor is `Latest release`, which names no version.
So the existing selftest cases "derived anchor counted", "non-numeric anchor keeps inequality", "feed floor catches
un-fire" and "feed floor lifts non-numeric anchor" (`:1048-1086`) would need S002's fixture anchor to name
1.2.0 / 1.2.3 / 1.2.4. A derived non-numeric anchor such as `1.2.x` becomes INCONSISTENT; no live row has one. New
cases would be needed for counterexamples 1-3, and the R25-03 count would change. A further maintenance rule follows:
if a feed source row's anchor cell is ever rewritten in place instead of superseded (the lane precedent is S036 → S039,
an append), the derived rows bound to it go INCONSISTENT. I consider that the desired re-verification signal, but it is a policy assumption.

## 5. Not checked

- The candidate `--selftest` and the draft selftest were not run (contract: no selftests mid-flight).
  Selftest impacts above are read from the source only.
- No live `--observe` and no network fetches. The observe behaviour comes only from synthetic bodies through `observe_one()`.
- The claim-ledger gate, `revision-audit.py` and `stamps.tsv` were not executed. Every fixture here, like C2's own,
  changes the `release-clocks.tsv` bytes stamped at stamps.tsv:78. Stamps are a byte pin and a legitimate restamp
  would carry the rewrite, so I did not treat them as a semantic defence.
- c1-measure.py and separability.py were not run (out of my item).
- Ordering of the X.Y-only / prerelease segments of PEP 440 / S043 was not audited beyond the non-strict fixtures.
- Parser attacks on `parse_latest_version` (title and href regex and entry caps) were not re-attacked here.

Scratch artifacts: `/fast/scratch/critfinalc2/{c2-before,c2-after,attack-before,attack-cand,attack-A,attack-B}.json`, plus
`attack.py`, `draftA.py`, `draftB.py` and `draftA.diff`.
