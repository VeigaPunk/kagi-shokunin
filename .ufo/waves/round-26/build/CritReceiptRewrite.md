# CritReceiptRewrite — round 26 C1, receipt overwrite/re-pin attack

Seat: KagiR26.CritReceiptRewrite (critic, leaf). Lane-authored advice, not non-author closure.
Axes judged: freshness, calibration. Impacted by the finding: freshness (false currency), calibration (historical pin silently redefined).

## Observed BASE and scope

- `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (= frozen BASE). `git status --porcelain` → only `?? .ufo/waves/round-26/` and `?? plans/round-26.md`; no tracked production change.
- Round-25 receipt bytes are unchanged across all three round-25 commits:
  `git show <c>:.ufo/waves/round-25/observe-1.json | sha256sum` → `b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92` for `82745e2c`, `9b755f5b`, `1bf3eec4`; equals `DEFAULT_RECEIPT_SHA256` at `corpus/release-clock.py:28` (the constant first appears in `9b755f5b`; absent in `82745e2c`).
- Receipt content (read-only `json.load`): 28 observations, all `observed_at` 2026-10-21 (11:31:48Z–11:31:56Z); S027/S028 `parsed_version 3.15.0`, `verdict not-fired`, feed body sha `326a2dc4…`.
- Inspected: `plans/round-26.md` (whole), `corpus/lessons/round-25.md` (whole), `corpus/release-clock.py` lines 25–28, 366–590, 706–826, 1418–1495, 1557–1608, `corpus/release-clocks.tsv` (header, S008, S027, S028), `corpus/claim-ledger.tsv:82-83`, `corpus/SOURCES.md:33,34,42`, `SKILL.md:787`, round-26 `build-spec.json` work items for XReceiptDelta/XCapturePython/XNormalizerRegression/ReviewReceiptIdentity. No round-26 seat report or sandbox draft yet mentions `DEFAULT_RECEIPT`, `observe-1`, `receipt_path`, `release-clocks.tsv` or re-pin (grep over `*.{md,py,patch,diff,txt,tsv}` in the wave: no matches).
- **Nothing executed.** `release-clock.py`, selftests and the ledger were NOT run; every behavioural claim below is `[INFERENCE]` from source reading. Python 3.15.1's existence was not fetched or verified by this seat.

## Attack — the plan's "after" state cannot go green without re-pinning the round-25 receipt

The plan promises a "newly named receipt records current clocks" and "any changed immutable registry facts receive new superseding rows", while "Historical receipt, binding TSV and default R25-04 remain historical evidence and are not rewritten to green" (`plans/round-26.md:7`). It names no gate for the new receipt. At BASE the only gate that consumes a receipt binds it to the frozen TSV, so the plan's own after-state turns red. Every route back to green rewrites or re-pins the round-25 binding.

1. **New receipt vs frozen TSV fails.** `--observe NEW.json` writes exclusively (`write_receipt`, `:769-770`, good), then evaluates NEW against the TSV (`:1588-1590,1598`). `observe_one` sets `verdict "fired"` when the parsed version ≠ anchored (`:730-733`). `receipt_matches` requires receipt `verdict` == TSV verdict and `parsed_version` == TSV `observed_version` (`:387,397`). TSV S027/S028 say `3.15.0 … not-fired` (`release-clocks.tsv:24-25`). A 3.15.1 feed therefore gives `RECEIPT-MISMATCH S027`, `RECEIPT-MISMATCH S028`, `RELEASE_CLOCK: FAILED`, exit 1 [INFERENCE]. `--receipt NEW --receipt-sha <sha>` goes through the same `evaluate` and gives the same result. The selftest's recapture case (`:1436-1460`) only covers the case with no drift (live `v1.2.3` = TSV `1.2.3`), so this path has never been exercised.
2. **Every green route rewrites history.**
   - Editing TSV S027/S028 to `3.15.1 fired` is forbidden by the plan. It also makes the default R25-04 run mismatch the pinned `b74c8ee3…` receipt (same `:397` comparison), and changes `fired=1` to `fired=3` against the R25-04 regex (`claim-ledger.tsv:83`).
   - Appending a superseding S027 TSV row does not work either: a duplicate id is `INCONSISTENT` and unbound (`:487-489`), and its receipt record becomes `RECEIPT-MISMATCH` (`:567-569`).
   - The remaining "fix" is to re-point `receipt_path` (`:448-450`), `DEFAULT_RECEIPT_SHA256` (`:28`) and the R25-04 regex and note (`claim-ledger.tsv:83`, "receipt .ufo/waves/round-25/observe-1.json") at a round-26 receipt. That is a rewrite of the round-25 receipt's authority even though no receipt byte changes.
3. **Superseding source rows break R25-04 even with zero TSV/receipt edits.** XCapturePython proposes S039 (feed), S040 (`re` doc) and S041 (`html` doc) correction rows. If S040/S041 inherit S027/S028's `recheck: on-release`, the on-release population grows from 28 to 30 (`:462-465`) → `UNBOUND S040`, `UNBOUND S041` → R25-04 (`^RELEASE_CLOCK: CLEAN \(on_release=28 bound=28 unbound=0 observed=28 …`) fails at the pinned default receipt [INFERENCE]. Binding them in the TSV instead gives `NOT OBSERVED` against `b74c8ee3…` (`:552-553`), which again forces a re-pin. S039 cannot be on-release either: a feed source that is on-release is `BADFEED` (`:512`). The round-25 feed rows S033–S037 used `recheck: 90d` for this reason (`lessons/round-25.md:106-108`).
4. **The date coupling makes `release-clock.py` exit codes useless as a drift counter.** Every TSV row has `observed_at 2026-10-21`, and `receipt_matches` requires the receipt date to equal it (`:388`). Any capture at or after 2026-10-22T00:00:00Z mismatches all 28 rows regardless of drift (`observed=0`) [INFERENCE]. The plan's counting instrument ("compares exact S027/S028 identities in old/new receipts", `plans/round-26.md:7`) must not read `release-clock.py` output as drift dispositions.

Calibration debt that already exists (to record, not to rewrite): the round-25 recheck instruction (`corpus/lessons/round-25.md:3`, "re-run `python3 corpus/release-clock.py --observe <new receipt>` whenever a feed shows a newer stable release") and `SKILL.md:787` ("`--observe NEW.json` records new evidence without overwriting a receipt or rewriting TSV") are true about writing. But they end `FAILED` exit 1 in exactly the drift case they exist for, and also after any change of day.

## Smallest safe correction (append-only plan amendment)

1. **Byte-freeze the historical authority.** The plan should list as frozen at BASE: `.ufo/waves/round-25/observe-1.json` (sha `b74c8ee3…`), `corpus/release-clocks.tsv`, `release-clock.py:28` `DEFAULT_RECEIPT_SHA256`, the `receipt_path` default (`:448-450`) and the R25-04 line (`claim-ledger.tsv:83`). Post-integration falsifier for L1:
   `git diff --exit-code 1bf3eec48d3761580ffd375c88143232485ae814 -- .ufo/waves/round-25/observe-1.json corpus/release-clocks.tsv` must exit 0. The R25-04 line and the `DEFAULT_RECEIPT_SHA256`/`receipt_path` lines must be byte-equal to BASE. R25-04 must still match its unchanged regex.
2. **Keep superseding rows out of the on-release population.** S039–S041 should carry `recheck: 90d` (the round-25 feed-row convention), with a recheck note naming the round-26 receipt. They must not be `on-release`. If L1 wants them clocked, that is a new clock surface needing its own new TSV and ledger row, and the plan must claim it. It must not grow R25-04's population.
3. **Gate the new receipt only through the receipt-delta instrument.** The new receipt is validated by XReceiptDelta's `receipt-delta.py`, pinned to the old sha `b74c8ee3…` and the new receipt's own sha. It must never be validated through `release-clock.py --receipt NEW`. The `--observe` run's expected `RECEIPT-MISMATCH S027/S028`, exit 1, is recorded as the drift signal, not as a defect to green. If the capture date is not 2026-10-21, the expected mismatch covers all 28 rows; record that too.
4. **Record the gap in round 26's lessons, not round 25's.** The missing selftest case (drift recapture against a frozen TSV) and the false-red on day change go into the round-26 lessons. Round-25 text stays as filed.

## Rejected overclaim

Any round-26 statement that "release clocks are CLEAN", or that a green R25-04 shows current Python freshness, is rejected. R25-04 green attests only that the TSV is consistent with the 2026-10-21 receipt `b74c8ee3…`. After a 3.15.1 observation, R25-04 being green is expected *precisely because* it is historical. Freshness credit must come from the delta instrument and the re-opened S027/S028 teachings.

## Commands run (exact, all read-only)

- `git rev-parse HEAD && git status --porcelain && git log --oneline -3` → BASE as above; only round-26 untracked.
- `for c in 82745e2c… 9b755f5b… 1bf3eec4…; do git show $c:.ufo/waves/round-25/observe-1.json | sha256sum; done` → `b74c8ee3…` ×3; `git diff --stat 82745e2c 9b755f5b -- observe-1.json release-clocks.tsv` → empty.
- `git show 82745e2c:corpus/release-clock.py | grep -n 'DEFAULT_RECEIPT\|round-25.*observe'` → no output.
- `sha256sum .ufo/waves/round-25/observe-1.json` → `b74c8ee3…`; `python3 -c` json read of the receipt → 28 records, the date set `['2026-10-21']`.
- `grep -nE '^S02[78]|^S036' corpus/release-clocks.tsv` → lines 24–25 (S036 is not a TSV row).
- Python one-shot over `round-26/build-spec.json` to print executor/reviewer work items (read only).

Installs: none.
