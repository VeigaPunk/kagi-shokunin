# CritChronology — same-day receipts vs feed publication dates (round 26, C1 freshness)

Seat: `KagiR26.CritChronology` (critic, leaf). Axes judged: freshness, calibration.
Observed BASE: `git rev-parse HEAD` in `kagi-shokunin` → `1bf3eec48d3761580ffd375c88143232485ae814`
(committed 2026-10-21T10:16:34-03:00 = 13:16:34Z), equal to the frozen BASE.
Mode: read-only. No network fetch, no build/test/lint, no production edit, no installs.
Lane-authored advice, not non-author closure.

## Verdict

One concrete overclaim must be refused: **"Python 3.15.1 was released since the round-25
review of S027/S028"** (or any synonym: "after review", "new release since round 25",
"the S027/S028 clocks fired because a release occurred since"). It is **unproven**, and
the only dated publication evidence on record points the other way. The opposite claim,
"round 25 missed or mis-measured an already-published 3.15.1", is also unproven. Round 26 may
state only what was observed and when. The precedent already exists for S012
(`corpus/lessons/round-25.md:227-228`).

## Evidence: same-day timeline, all 2026-10-21, converted to UTC

| UTC time | event | what it saw | anchor |
|---|---|---|---|
| ~05:52 | docs build that S027's capture pins | Python 3.15.0 docs (digest match, [INFERENCE] by ClockS027) | `.ufo/waves/round-25/build/ClockS027.md:48` |
| 07:27 | docs.python.org rebuild (footer only) | — | `ClockS027.md:48`, `ClockS028.md:31` |
| **09:59:50** | **feed `pubDate` of the Python 3.15.1 item** | — | `MANIFEST.json:10801` (CloseKagi25 routed D1, independent refetch) |
| ≤10:42:21 / ≤10:43:06 | ClockS028 / ClockS027 re-verify (report mtimes) | RSS digest `326a2dc4…`, newest stable **3.15.0**; release API `is_published=true` max **3.15.0** `is_latest`; `/3/` title "3.15.0 Documentation"; PEP 790 says "3.15.1: Tuesday, 2026-12-01" | `ClockS027.md:7,16,31,53-56`; file mtimes 07:42:21/07:43:06 -0300 |
| **11:31:53** | L1 `release-clock.py --observe` receipt | S027/S028 `parsed_version 3.15.0`, sha `326a2dc4…` | `.ufo/waves/round-25/observe-1.json` (`observed_at`) |
| 11:49:25 | frozen candidate `82745e2c` | — | `git log -1 82745e2c` |
| [11:49:25, 12:11:44] | FFeedS036 falsify fetch (after the candidate, before the report mtime) | sha `326a2dc4…`, 3389 bytes, parsed **3.15.0** | `.ufo/waves/round-25/falsify/FFeedS036.md:22` |
| 13:07:39 / 13:16:34 | measured commit `9b755f5b` / BASE `1bf3eec` | — | `git log` |
| ≤13:33:09 | CloseKagi25 refetch sees **3.15.1** as newest | "pubDate Wed21Oct2026 09:59:50+0000 (before retained11:31:53Z observation)… Cached-edge versus backdated insertion is unresolvable" | `MANIFEST.json:10801`, blame commit `ff47be96` author-time 1792589589 = 13:33:09Z |

Every retained round-25 Python observation was made after the 3.15.1 `pubDate`. There are
four of them: two Clock seats, the L1 receipt and FFeedS036. They used two python.org
endpoints, the RSS feed and the `is_published` release API, and all four saw 3.15.0. So
the `pubDate` cannot be read as "released after the review". Reading it as "visible
before the review" would contradict four observations. The data are consistent with
cache lag. They are also consistent with python.org dating the item when it was
created rather than when it became visible. This is [INFERENCE]: an API query filtered
on `is_published=true` returning max 3.15.0 after 09:59:50 suggests the object was
not yet published. I did not verify the CMS semantics. PEP 790's scheduled date of
2026-12-01 makes an unscheduled same-day 3.15.1 plausible but does not date it.

## Why the instruments cannot settle "since" either

- `corpus/release-clocks.tsv` `observed_at` is date-only (`S027…2026-10-21`, lines 24-25).
  A round-26 receipt written today also says `2026-10-21`, so the old and new rows tie on
  date and cannot be ordered.
- `corpus/release-clock.py:366-375` (`receipt_date`) truncates the receipt timestamp to
  a date when it binds the TSV. `parse_latest_version` (lines 652-699) keeps only the
  max stable `X.Y.Z` and discards every item's `pubDate`/`updated`, so no retained receipt
  holds a publication time.
- `corpus/source-fetches.tsv:79` (S036) and `SOURCES.md:42` keep only a date, "feed
  fetched 2026-10-21". The 3.15.0 item's `pubDate` (09 Oct) is quoted only because it
  sits in the anchor prose.

Under the plan's counting instrument (`plans/round-26.md:5`), a "since" claim
therefore rests on prose, not on instrument output.

## Impacted axes

- **Calibration:** a "since review" sentence asserts an ordering that the only dated
  datum contradicts, the same false-provenance class that the S012 note already refused.
- **Freshness:** the honest gain is that a new receipt now observes 3.15.1, and the
  S027/S028 teachings are re-opened against docs served at a named time. Inflating that
  into "detected a release that occurred after review" overstates the clock: it detects
  visibility, not publication.
- Historical integrity: the round-25 rows `release-clocks.tsv:24-25`,
  `observe-1.json`, `lessons/round-25.md:130` ("Python S027/S028 at 3.15.0") and the
  header `verified-at: 2026-10-21` are true as observations at their stated times. They
  must not be rewritten to "fired" or "stale at review time".

## Smallest safe correction (wording rule for the round-26 receipt, lesson and SCORECARD)

1. Forbid these phrasings: "released since round 25", "since review", "new release
   after S027/S028 verification", "round 25 missed 3.15.1", and "round 25 mis-measured".
2. Allowed form, with full UTC seconds: "Receipt `<new path>` at `<T>Z` parses
   Python 3.15.1 as newest stable on S036. The item's feed `pubDate` 2026-10-21T09:59:50Z
   precedes every retained round-25 Python observation (ClockS027/S028 ≤10:43Z, observe-1
   11:31:53Z, FFeedS036 ≤12:11:44Z), all of which parsed 3.15.0. Publication versus
   visibility order is unresolved (cache or backdated item). The clock detects
   that 3.15.1 became visible to this lane in the window (≤12:11:44Z, ≤13:33:09Z], not
   publication after review." This mirrors `lessons/round-25.md:227-228`.
3. When citing chronology, compare full ISO timestamps from the new receipt's
   `observed_at` and copy the item's `pubDate` verbatim from the fetched body as a
   located quote. Never order by the TSV's date-only `observed_at`. A same-date tie must
   be stated as a tie.
4. Label the S027/S028 re-verification by the docs actually served. Quote the served
   page title ("… Python 3.15.x documentation") and footer "Last updated … UTC". Do not
   infer the docs version from the feed. `/3/` is rebuilt intraday (05:52 and 07:27 on
   2026-10-21) independently of release items.
5. Any superseding S036 row says "newest stable observed at `<T>Z` is 3.15.1". Keep
   the old row's present-tense "Newest stable CPython is 3.15.0" as dated history
   (append-only, per routed D1 at `MANIFEST.json:10801`).

No production edit is proposed here. A code change, such as retaining `pubDate` per item
or a timestamp-granular `observed_at`, would add new capability beyond the C1 claim. It
is out of scope; the wording rule above is sufficient.

## Bounded scope and what was not done

Inspected: `plans/round-26.md` (all), `corpus/lessons/round-25.md` (all),
`corpus/release-clocks.tsv:1-32`, `corpus/release-clock.py:334-388,640-700`,
`corpus/source-fetches.tsv` S027/S028/S036 rows, `corpus/SOURCES.md:33-34,42`,
`.ufo/waves/round-25/observe-1.json` (S027/S028), `build/ClockS027.md`, `build/ClockS028.md`
(grep), `falsify/FFeedS036.md` (grep), the fleet `MANIFEST.json:10795,10801` and its blame,
plus `git log` times for 82745e2c, 9b755f5b and 1bf3eec.

Not done:
- I did not fetch the live feed. The 3.15.1 `pubDate` is CloseKagi25's observation as
  recorded in MANIFEST, not mine.
- I verified no python.org CMS semantics.
- The round-26 build reports seen at write time are ClockS011/S014/S016/S025/S030
  evidence and the ClockS008/S009 sandboxes. None of them contained Python chronology
  text, so no peer seat's wording was attacked directly.
- I ran no checks, and I call nothing passing.

Installs: none.
