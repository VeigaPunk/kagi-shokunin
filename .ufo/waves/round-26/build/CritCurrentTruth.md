# CritCurrentTruth — round 26 C1 (freshness): can a new receipt plus re-opened docs count as freshness while R25-04's default stays historical?

Seat: KagiR26.CritCurrentTruth (critic, leaf). Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814`; worktree untracked only `.ufo/waves/round-26/` and `plans/round-26.md` (`git status --short`).
Mode: read-only. I executed no gate, selftest, fetch or `--observe`. The predicted gate outputs below are derived by reading the code and are marked [INFERENCE]. The Python facts come from read-only greps over peer captures (ClockS027/ClockS028 artifacts, fetched 2026-10-21T13:36Z); I did not fetch them myself.
Installs: none.

## Verdict (bounded)

**Yes, but only as dated point evidence of detected drift.** It does not mean "the clocks are current".

- A new named receipt, plus the two re-opened Python pages, plus per-identity dispositions, honestly counts as freshness for C1.
- R25-04 may stay a historical check of the round-25 receipt.
- The repository currently routes the present-tense question "did this on-release recheck fire?" to that historical default. After round 26 lands, that default will still count S027/S028 as not fired, while the round-26 receipt will say they fired. That mismatch is the attack below.
- Two plan moves would turn "R25-04 stays historical" into a false or broken claim. Both are covered below, with falsifiers.

## The attack: the repo's "current" answer is the historical receipt

### Counterexample

After integration, a reader follows `SKILL.md:48`: "Judge whether a source's `on-release` recheck fired | `python3 corpus/release-clock.py` …". With no TSV edit (the plan forbids one), that command loads the SHA-pinned round-25 receipt. It prints the R25-04 line unchanged [INFERENCE from code]:

`RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)` with exit 0.

This counts S027 and S028 as `not-fired`. The current python.org feed lists Python 3.15.1 as the newest stable release, so both clocks have fired. The repository's routed present-tense judgment is therefore false for exactly the two rows that C1 is about.

### Evidence

- **Default receipt is pinned to round 25.** `corpus/release-clock.py:28` pins `DEFAULT_RECEIPT_SHA256 = "b74c8ee3…f92"`. `receipt_path` (`:448-450`) defaults to `.ufo/waves/round-25/observe-1.json`. `sha256sum` of that file is `b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92`, which matches.
- **Default receipt says 3.15.0, not fired.** In `observe-1.json:249-266`, S027 and S028 both record `parsed_version "3.15.0"`, `verdict "not-fired"`, `observed_at "2026-10-21T11:31:53Z"`, and the same feed `sha256 326a2dc4…`.
- **TSV rows match the old receipt.** `corpus/release-clocks.tsv:24-25` gives S027/S028 as `3.15.0 3.15.0 2026-10-21 not-fired`. R25-04 (`corpus/claim-ledger.tsv:83`) pins `fired=1` with exit 0.
- **The feed has moved.** The peer feed capture (`build/ClockS028-evidence/feed.rss` and `build/ClockS027-artifacts/feed.body`) has sha256 `11c86a34…a66b` in both files. Its newest stable item is `<title>Python 3.15.1</title>`, pubDate `Wed, 21 Oct 2026 13:08:09 +0000`. Above it sits `Python 3.16.0a1`, a prerelease, then `Python 3.15.0`.
  - The round-25 receipt (11:31:53Z) predates the 3.15.1 release (13:08:09Z). Round 25's "S027/S028 at 3.15.0" (`corpus/lessons/round-25.md:130`) was true when written. Nothing historical needs a rewrite.
- **The docs moved too, and the quotes still locate.**
  - `build/ClockS027-artifacts/re3.body`, `re315.body`, `build/ClockS028-evidence/html.body` and `html3150.body` all carry "Python 3.15.1 documentation".
  - The headers show `last-modified: Wed, 21 Oct 2026 13:04:29/30 GMT`.
  - The `/3.15/` route also serves 3.15.1, so no 3.15.0-labelled page remains at either route.
  - The declared quotes appear once each: "Matches Unicode whitespace characters" in `re3.body` and `re315.body`; "Convert all named and numeric character references" in `html-3.15.0.norm.txt` and `html-3.15.1.norm.txt`.
  - Result: both teachings hold, and both anchors are stale. `corpus/SOURCES.md:33` says "Python 3.15.0 documentation as served"; `:34` says "Python 3.15.0 documentation".
- **Other present-tense consumers of the default.**
  - `SKILL.md:787`: "offline values must agree with the byte-pinned retained observation receipt".
  - `PROVINCE.md:54` and `corpus/README.md:181-184`: "observation receipt `.ufo/waves/round-25/observe-1.json`".
- **Changed registry fact.** `corpus/SOURCES.md:42` (S036) teaches in the present tense "Newest stable CPython is 3.15.0". That is now false. It is a changed fact that needs a superseding row; the existing row must not be edited.

### Impacted axes

- **freshness:** the routed current judgment is stale for S027/S028.
- **calibration:** a green CLEAN with `fired=1` will be quoted as current.

## Falsifiers the plan must survive

### F1. The gate cannot certify the new receipt against the unchanged TSV, and its mismatch set depends on the capture date

`receipt_matches` (`release-clock.py:378-399`) requires all of these to hold:

- the receipt `verdict` equals the TSV verdict;
- the receipt `parsed_version` equals the TSV `observed_version`;
- the receipt **date** equals the TSV `observed_at` (`receipt_date`, `:366-375`, which keeps the day only).

A new receipt will record S027/S028 as `parsed_version 3.15.1` and `verdict fired` (`observe_one`, `:727-734`). Running `--receipt NEW --receipt-sha X`, or `--observe NEW`, which evaluates its own output (`:1588-1597`), therefore gives [INFERENCE]:

```
RECEIPT-MISMATCH S027
RECEIPT-MISMATCH S028
RELEASE_CLOCK: FAILED (on_release=28 bound=28 unbound=0 observed=26 fired=1 derived=15)
```

with exit 1. This assumes no other feed moved and all quotes locate. Peer feeds S011, S013 and S014 still top at v3.13.3, v2.2.0 and v2.7.1.

That `observed=26` exists only because round 26 happens on the same calendar day (2026-10-21) as round 25. If the receipt is captured on 2026-10-22 or later, the date check fails for **every** row: all 28 rows give RECEIPT-MISMATCH and `observed=0`. Two consequences follow:

- The gate's mismatch set measures capture date as much as drift.
- `claim-ledger.sh` matches only the exit code and the **last** output line (`corpus/claim-ledger.sh:612-621`). A ledger row pinning `RELEASE_CLOCK: FAILED (…observed=26…)` with exit 1 would pass for **any** two mismatching IDs, so it does not identify S027/S028.

The same `--observe` run also prints `RELEASE_CLOCK_OBSERVE: … failed=0 fired=3` (`:821-826`) above a summary line that says `fired=1`. Two "fired" numbers come out of one run. Quoting either alone is an overclaim.

### F2. On-release superseding doc rows break R25-04

The proposed S040/S041 "re/html doc corrections" (XCapturePython's assignment in `build-spec.json`) would naturally carry `recheck: on-release`, like S027/S028 (`SOURCES.md:33-34`). `evaluate` (`:462-486`, `:548-554`) puts every on-release source in the population:

- with no TSV row, they give `UNBOUND S040/S041`;
- with an appended TSV row, they give `NOT OBSERVED` against the pinned round-25 receipt.

Either way R25-04's default becomes FAILED with exit 1 [INFERENCE]. The new rows also cannot retire S027/S028: their status and recheck stay `on-release` (no existing-row edits), so the stale `not-fired` rows stay in the population regardless. Such rows therefore add nothing to clock truth and contradict "default R25-04 remain[s] historical" (`plans/round-26.md:7`).

There is a precedent. Round 25 handled fired S012 this way (`corpus/lessons/round-25.md:118-127`): the teaching held and the anchor was stale, so the stale anchor was recorded in the lesson and no new superseding row was added for the rule.

## Smallest safe correction

1. **What counts as freshness.** Count all four of the following, with exact paths and bytes. Do not count "clocks current", "R25-04 CLEAN", or `fired=1` as the present state.
   - (a) One new exclusive receipt (e.g. `.ufo/waves/round-26/observe-1.json`), its sha256, and its full capture timestamp.
   - (b) The XReceiptDelta per-identity delta: S027 and S028 each `3.15.0/not-fired → 3.15.1/fired`, feed sha `326a2dc4… → <new>`. Say explicitly that both IDs share **one** feed body, so this is one observation fanned out to two bindings, not two independent observations.
   - (c) Two doc re-openings (`re.html`, `html.html`) with digest, length and `last-modified`, each locating its declared quote under the "Python 3.15.1 documentation" label.
   - (d) Per-row dispositions: S027/S028 "teaching holds on 3.15.1, anchor stale". S036's "Newest stable CPython is 3.15.0" gets a new 90d feed-correction row (S039), which is not on-release and so leaves R25-04 untouched.
2. **Do not add on-release S040/S041.** Record the stale 3.15.0 anchors in the round-26 lesson, as with S012. If doc rows are added anyway, they must not be `on-release`, and the lesson must state that the S027/S028 clocks remain fired and un-re-anchored.
3. **Proposed wording** for the routing line and notes (a docs edit for L1 to integrate; I made no live edit):
   - `SKILL.md:48`, append after the existing `--selftest` clause: "the default offline check reports the round-25 receipt (observed 2026-10-21T11:31:53Z), not current release state; judge a fire now with `--observe NEW.json` (round 26: S027/S028 fired, Python 3.15.1, receipt `<path>` sha `<sha>`)".
     - Constraint: `self-counts.tsv:22` (`SC-CLOCK-SELFTEST`) matches `^\| Judge whether a source's \`on-release\` recheck fired .*?\`--selftest\` ([0-9]+) cases\b`. Keep the prefix, and add no earlier "`--selftest` N cases" text.
   - R25-04 note: "historical: the round-25 receipt; not a current-fire claim".
   - Use the same dating in `SKILL.md:787`, `PROVINCE.md:54` and `corpus/README.md:181-184`.
4. **Counting instrument.** The falsifier must be identity-exact: XReceiptDelta or an equivalent per-ID comparison of the two receipts, failing if the changed set is not exactly {S027, S028} unless each extra ID has a disposition. Do not use a ledger row on `RELEASE_CLOCK: FAILED`, because it matches only the last line and is date-dependent (F1). If the `--observe` capture's exit 1 is recorded, describe it as the designed TSV/receipt divergence signal, not as a capture failure and not as CLEAN.

### Rejected overclaims

- "S027/S028 re-verified against current Python, R25-04 CLEAN": the CLEAN refers to the round-25 receipt only.
- "fired=1 current".
- "the new receipt passes release-clock.py".
- "superseding rows refresh the clock".

## Inspected scope

- `plans/round-26.md` (whole).
- `corpus/lessons/round-25.md` (whole).
- `corpus/release-clock.py:1-30`, `:360-600`, `:690-830`, `:1557-1608`.
- `corpus/release-clocks.tsv` (whole).
- `corpus/claim-ledger.tsv:54,77,80-83`.
- `corpus/claim-ledger.sh:596-625`.
- `corpus/SOURCES.md` header and the S027/S028/S036 rows, plus its supersede rows.
- `corpus/self-counts.tsv` clock rows.
- `SKILL.md:48,787`, `PROVINCE.md:54`, `corpus/README.md:178-186`.
- `.ufo/waves/round-25/observe-1.json` (sha and S027/S028 records).
- Round-26 peer artifacts (read-only greps): ClockS027/S028 feed and doc bodies and headers; ClockS011/S013/S014 feed tops; the XReceiptDelta/XCapturePython assignment text in `build-spec.json`.

Not run: every gate, selftest, `--observe` and fetch. The predicted outputs above are code-read only.
