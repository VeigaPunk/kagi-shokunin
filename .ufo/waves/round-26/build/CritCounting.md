# CritCounting — S027/S028 before/after population exactness (round 26, C1 freshness)

Seat: `KagiR26.CritCounting` (critic, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE).
Production writes: none. Installs: none. Repo code executed: none (no release-clock.py, census, ledger, normalizer, tests). Probes were read-only data reads: `sha256sum`, `grep`, `diff`, `awk`, and an inline `python3` JSON comparison of the two receipts.
Peer message: one short key note was delivered to `KagiR26.XReceiptDelta`. At 13:42Z its wake turn failed with a provider capacity error (`turn_rate_limit_exceeded`, retry budget exhausted, no answer produced). The note is therefore **unacknowledged**. L1 must check the comparison key in correction 4 directly in any XReceiptDelta output, not assume the seat applied it.

Working tree at inspection (L1 integration in progress, adapted to): `M SKILL.md`, `M corpus/SOURCES.md` (+S039–S041), `M corpus/source-fetches.tsv` (+3 rows), untracked `corpus/lessons/round-26.md`, `.ufo/waves/round-26/`, `corpus/__pycache__/`. Production `corpus/release-clocks.tsv`, `corpus/release-clock.py`, and `.ufo/waves/round-25/observe-1.json` are byte-equal to the frozen `before` copies (`cmp`).

## Primary attack — "exactly S027/S028 changed" is exact by a same-day coincidence, and the after CLEAN is by construction

### Claim attacked

- `corpus/lessons/round-26.md:53-58`: the new receipt against the old profile returns exactly `RECEIPT-MISMATCH S027/S028`.
- `round-26.md:60-72` and `SKILL.md` (new §Round-26): the paired `after` changes "ONLY S027/S028" and returns `CLEAN28/observed28/fired3`. This pair is the round's "counting/replay command".
- `.ufo/waves/round-26/frozen/expected.json`: `"only_changed_binding_ids": ["S027","S028"]`.

### Counterexample

1. **The before-population is date-coupled.** `corpus/release-clock.py:388` rejects a receipt whenever `receipt_date(observed_at) != values["observed_at"]`, and `receipt_date` (L366-375) reduces the timestamp to its UTC date. All 28 rows in both the BASE and the `after` TSV carry `observed_at=2026-10-21`. The round-25 receipt is stamped `2026-10-21T11:31:53Z` and the round-26 receipt `2026-10-21T13:36:36Z`, so they share a date.
   - The measured red set `{S027,S028}` (`.ufo/waves/round-26/observe-run.json`) is therefore exact **only because the second observation happened on the same UTC day**.
   - [INFERENCE from the source, not executed] The same receipt stamped `2026-10-22` would fail every one of the 28 rows against either profile. Then "which rows drifted" can no longer be read off the gate.
   - The recheck instruction in `round-26.md:3`, and `round-25.md:3` ("re-run `--observe <new receipt>`"), implicitly relies on the gate to isolate drift. After today it cannot.
2. **The after CLEAN is construction-consistency, not a measurement.**
   - `diff frozen/before/corpus/release-clocks.tsv frozen/after/corpus/release-clocks.tsv` shows only lines 24-25 changed. S027 and S028 moved from `3.15.0 … not-fired` to `3.15.1 … fired` (anchor `3.15.0` kept), with a note appended.
   - The after profile was hand-written to equal the new receipt. Its CLEAN proves only that the author transcribed the receipt correctly. Likewise, `only_changed_binding_ids` is a diff of two author-authored TSVs, not an observation.
   - The only independent count in the pair is the red-before set, and that is the date-coupled count from item 1.
3. **The independent, date-free count was not recorded.** I compared the two byte-pinned receipts directly:

   | comparison key | changed ids |
   |---|---|
   | all fields | 28 (`observed_at` differs on every row) |
   | all fields except `observed_at` | 5: S005, S006, S020 (digest-only; `located` stays `true`) and S027, S028 |
   | `id, clock, url, http_status, error, parsed_version, located, verdict` | **2: S027, S028** |

   - Identity sets: 28 = 28, identical. Per-field: `parsed_version` 2, `verdict` 2, `sha256` 5, `observed_at` 28; `clock`, `url`, `http_status` and `located` 0.
   - S027 and S028 share one feed body in each receipt: `326a2dc4…` in round 25 and `11c86a34…` in round 26. The round-26 body is byte-equal to `captures/S039.body` and to `build/ClockS027-artifacts/feed.body` / `ClockS028-evidence/feed.rss`. So this is **1 feed event → 2 bindings**, not two independent drifts.
   - Fired counts: the observer reports `fired=3` and the old-profile evaluator `fired=1`. S012's fire comes from round 25, so neither number is a drift count. (`round-26.md:55-58` already discloses the different denominators.)

### Impacted axes

- **Calibration.** "Only S027/S028 changed" is presented as a measured population. It is measured only through a same-day artifact, plus an after profile that is tautological.
- **Freshness.** The next re-observation on any later day cannot isolate drift with the documented gate.
- Neither of these is a regression of the round-25 receipt. That receipt, the TSV and R25-04 all remain historical and untouched.

### Smallest safe correction (text/evidence only; no production code or history rewrite)

1. Record the receipt-pair count in `corpus/lessons/round-26.md` as the C1 counting instrument:
   - **Inputs:** old receipt `b74c8ee3…f92` and new receipt `9a1cefec…b1e` (both already pinned in `frozen/expected.json`).
   - **Key:** `(id, clock, url, http_status, error, parsed_version, located, verdict)`. Exclude `observed_at` and `sha256`.
   - **Result:** 28 = 28 identities; semantic changes = {S027, S028}; digest-only changes = {S005, S006, S020}, counted separately and not as drift; timestamp-only changes = 23; feed events = 1.
   - **Dispositions:** 2 teachings re-opened and located (S040 → `0724d815…`, S041 → `8a541381…`); 0 teachings changed.
2. Add one limit sentence: the `before` red set is exact because both receipts share the date `2026-10-21` (`release-clock.py:388`); a later-day receipt mismatches every row. The `after` CLEAN is consistency of an author-written profile, not an independent measurement.
3. Change the recheck guidance (`round-26.md:3`): compare a future receipt against `9a1cefec…` using the key above, instead of reading the gate's mismatch set.
4. If XReceiptDelta's tool lands, its change key must exclude `observed_at` and `sha256`. Otherwise it reports 28 or 5 changes, not 2. The note sent to that seat is unacknowledged (its turn failed on capacity), so L1 must check this key itself.

## Rejected overclaims / bounded residuals (source-row score)

- **Sources 38 → 41 are re-verification points, not acquired sources.** `round-26.md:33-37` discloses "38 → 41, all three new rows tier A/mined, no new governed coverage ground". That is acceptable only if every downstream count says so.
  - Census pin R21-02 (`claim-ledger.tsv:52`, `rows=38 A=36 mined=34 captures=38`) must migrate to 41/39/37/41. That migration should be labelled "3 dated point observations (1 feed body, 2 doc bodies), 0 changed teachings". It must not read like round 25's "6 new tierA".
  - S040's capture quote is a strict substring of S027's: `For Unicode (str) patterns: Matches …` versus `Matches …`. It locates once in `captures/S040.body`, and the `For Unicode (str) patterns:` qualifier is adjacent. S040 and S041 reuse S027's and S028's exact URLs.
  - [INFERENCE] The fleet census W04 "duplicate url across scopes" rule (`census-start.json` already lists 8 such warnings) will add warnings for S039/S040/S041. `census-end` should show this and not be read as new coverage.
- **Precedent asymmetry, disclosed as debt rather than fixed here.**
  - In round 25, fired S012 with an unchanged teaching got **no** superseding row (`round-25.md:124-127`). In round 26, fired S027/S028 with unchanged teachings get S040/S041.
  - S022, which superseded S012, stayed `on-release` with a live clock. S040 and S041, now the current authorities for the rendered-text-v1 teachings, are `90d` (`SOURCES.md` S040/S041 recheck cell).
  - The superseded S027/S028 are now fired with their anchors retained, so their verdict cannot transition again. After this round, no live Python teaching row has an edge-capable release clock. Drift is visible only through the receipt-pair parsed_version delta above.
  - This trade keeps `on_release=28` and R25-04 historical. It is acceptable as a stated choice, not as "the population is unchanged". One debt sentence in `round-26.md` §Limits suffices.

## Inspected scope

- `plans/round-26.md` (full).
- `corpus/lessons/round-25.md` (full) and `corpus/lessons/round-26.md` (full, working tree).
- `corpus/release-clock.py`: L58-157, L362-610 and L1557-1608.
- `corpus/release-clocks.tsv` (full).
- `corpus/SOURCES.md` rows S027/S028/S036/S039–S041 and the `git diff`.
- `corpus/source-fetches.tsv`: S027, S028, S036, S039–S041.
- `corpus/sources-census.sh`: duplicate-provenance rule L238-286.
- `corpus/claim-ledger.tsv`: R21-02 and R25-04.
- `.ufo/waves/round-25/observe-1.json` (all 28 records).
- `.ufo/waves/round-26/{observe-1.json, observe-run.json, census-start.json, captures/metadata.json, frozen/expected.json, frozen/inputs.sha256, tools/replay-current.sh}`.
- `build/ConnectPython.md`, `build/ClockS028.md` (grep), and the bodies in `build/ClockS027-artifacts/` and `build/ClockS028-evidence/`.

## Commands run (observed)

- `git rev-parse HEAD` printed `1bf3eec4…814`.
- `git status --short` and `git diff --stat` showed 3 modified files (+34 lines).
- `sha256sum round-25/observe-1.json round-26/observe-1.json` printed `b74c8ee3…f92` and `9a1cefec…b1e`.
- An inline `python3` JSON comparison of the two receipts produced the per-key counts in the table above.
- `diff frozen/before/corpus/release-clocks.tsv frozen/after/corpus/release-clocks.tsv` showed only lines 24-25 changed.
- `cmp` of the production files against the frozen `before` copies: equal for release-clocks.tsv, source-fetches.tsv, rendered-text-v1.py, release-clock.py and the round-25 receipt; differs for SOURCES.md, because of L1's +S039–S041.
- `grep -o '<title>…|<pubDate>…'` over the feed bodies found the items 3.14.9 (13:08:09Z), 3.15.1 (09:59:50Z), 3.16.0a1, install manager 26.4, 3.15.0, 3.15.0rc3 and 3.11.17. All three copies have sha `11c86a34…`.
- The `<title>` lines of the doc bodies read `re.html` 3.15.1 (`0724d815`), `html.html` 3.15.1 (`8a541381`), and `release/3.15.0` html 3.15.0 (`ed0ca0ad`, 19540 B).
- A word diff of `html-3.15.0.norm.txt` against `html-3.15.1.norm.txt` found only version labels (×3) and a date/time footer.
- `grep -o 'Matches Unicode whitespace characters' captures/S040.body | wc -l` returned 1.

## Not run (L1-only, after integration)

`replay-current.sh before|after`, `release-clock.py` (offline, `--selftest` or `--observe`), `sources-census.sh`, `claim-ledger.sh`, `self-counts.py`. No pass is claimed for any of them. The `after` CLEAN28/fired3 is quoted from `expected.json` and was not observed by this seat.
