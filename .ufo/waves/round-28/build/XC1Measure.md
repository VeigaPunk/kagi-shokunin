# XC1Measure — frozen C1 counting instrument (`c1-measure.py`)

BASE = 3553d499577084a6c98d7078906017840bbf7b28. Frozen command
`python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label>
<out.json>`; Python 3.14.8; no installs.

**Tool versions**: L1 integrated the tool post-deployment (sha fa1706f5…,
citing CritFrozenCommands): F3/F4 fixture rows stay verbatim
(feed-copy-only edits) and any-exit written fired observation counts as
MISHANDLED. The pre-integration version (sandbox sha c78029c5…) produced
the first artifacts; its 4/4-vs-3/4 difference is the construction change
below. All numbers here are the integrated tool's, reproduced
independently by RevC1Fixtures and XC1Patch.

## Final transition (integrated tool, lane artifacts)

```
BASE 3553d49   → mishandled=3/4 typed=0/4 other=1/4 control CLEAN30 exit 0
candidate 62a33b1 → typed=4/4 mishandled=0/4 other=0/4 control CLEAN30 exit 0
```
Artifacts: `XC1Measure-base-c1-rerun.json` (BASE, integrated tool),
`XC1Measure-candidate-c1.json` (lane-native rev — cite in END),
`XC1Measure-patched-probe-c1-integrated.json` (scratch rev 7db9a7a5);
`XC1Measure-base-c1.json` + `XC1Measure-patched-probe-c1.json` are
pre-integration-tool, historical.

Per fixture at BASE with the integrated tool (arm each verdict rides):

- **F1**: exit 0, `CLEAN (… fired=4)` → MISHANDLED, **exit-0-CLEAN arm**.
  `numeric_version` (:369-380) maps 3.15.01 → (3,15,1) (REGRESSED guard
  :574 silent); fired branch :582-583 accepts on string inequality (:362).
- **F2**: exit 1, stdout empty, stderr `ValueError: Exceeds the limit
  (4300 digits)…` from numeric_version:380, uncaught in evaluate:502 →
  MISHANDLED, **Traceback arm** (only signal; stderr-only).
- **F3**: observe writes `{"parsed_version": "3.15.01", "verdict":
  "fired"}` (parse :710/:760 accepts the title) while the verbatim row says
  not-fired/3.15.1 → exit 1 RECEIPT-MISMATCH → MISHANDLED,
  **written-fired-observation arm** (any exit; the recorded release event).
- **F4**: observe arm raises at :760, caught at :822 → untagged receipt
  error (`parsed_version: null`), no traceback; verbatim row → evaluate
  exits 1 RECEIPT-MISMATCH → **OTHER** (the predicate has no name for this
  transition: untagged oversize feed token → typed feed finding).

## Findings (defects/risks; nothing redefined)

1. **Bare tsv edits can never measure C1**: the default receipt (:28,
   `.ufo/waves/round-26/observe-2.json`, sha256 13b8540c…) pins
   observed_version/verdict via receipt_matches (:425-447); a table-only
   edit ends `RECEIPT-MISMATCH S040` (:608/:614). Pinned per L1's plan
   correction: F1/F2 mirror edited rows into a receipt copy and run
   `--receipt/--receipt-sha`.
2. **Frozen-spec defect (declared in my work order): F3/F4 cannot run the
   shipped CLI against a local feed.** `valid_public_https_url` :176 +
   `public_addresses` :309/:327 admit only public global HTTPS:443
   (`request_body` :669-671 rejects the rest). Harness: the exported
   release-clock.py's own `main()` in a child `python3 -I -B` with
   module-global `request_body` stubbed to the fixture feed and
   `utc_timestamp` pinned to the row's `observed_at` (the selftest's own
   substitutions); table narrowed to S040, registry to S040+S039, rows
   verbatim (unmodified table → 29 `UNBOUND` :532).
3. **Consolidated plan correction for L1** (§Plan corrections,
   plans/round-28.md:91), three items together: (i) the receipt-mirror
   construction inside the C1 and C2 fixture definitions, (ii) the F4
   question — the observe path never tracebacks at BASE (catch at :822),
   so with verbatim rows F4-at-BASE is OTHER and the predicate has no name
   for its OTHER→TYPED transition ("MISHANDLED k/4" is k=3), (iii) the
   shared typed-finding convention (claim's own category — C1
   NON-CANONICAL, C2 DERIVATION; everything else OTHER).
4. **TYPED is a canonicality token, not "exit 1 + names the row"**: the
   instrument counts TYPED only for a stdout finding line naming S040/feed
   whose category is outside the frozen set {ORPHAN, UNBOUND, INCONSISTENT,
   BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}; exit 2 SETUP
   (:1751) is OTHER (shared with XC2Patch: identical exclusion set at
   c2-measure.py:60, new category DERIVATION in XC2Patch.diff).
5. **Validation both ways**: BASE numbers reproduced independently by
   RevC1Fixtures and XC1Patch; candidate 62a33b1 → TYPED 4/4 reproduced by
   RevC1Fixtures and me. After-run F3/F4 receipts carry `error` starting
   "non-canonical version token: feed newest stable entry" with `verdict:
   null` — the FEED guard fires (rows verbatim), tokens TAGGED. The "never
   a release event" half is recorded, not classifier-enforced: read
   `fired_observation_written` — BASE true for F3/false for F4, after-run
   false for F1-F4; RevC1Fixtures' partial patch (feed guards removed)
   still scores TYPED while writing a fired receipt. R4: 62a33b1 still
   carries the lenient newest_stable (below-newest entries silently
   dropped; XC1LaneStrict.diff undecided) — no frozen fixture exercises it
   (F3/F4 tokens sit at/above the newest canonical entry).

## Commands run (exit codes)

- Frozen command, integrated tool: BASE → exit 0, 3/4 mishandled
  (`XC1Measure-base-c1-rerun.json`); candidate 62a33b1 → exit 0, 4/4 typed
  (`XC1Measure-candidate-c1.json`); scratch-rev probe → exit 0, 4/4 typed.
- Pre-integration tool: BASE 4/4 mishandled (`XC1Measure-base-c1.json`);
  patched probe 4/4 typed (`XC1Measure-patched-probe-c1.json`).
- Installs/updates: none.

## Pinned harness conventions (frozen into the tool)

Mirror (F1/F2) and narrowing (F3/F4: table S040, registry S040+S039, rows
verbatim) are in Findings 1-2; fixtures run `env -i PATH HOME LC_ALL=C
PYTHONDONTWRITEBYTECODE=1 python3 -I -B …`; F3/F4 feed = Atom
(`Python 3.15.01` / `Python 3.15.<4301 digits>` + older `Python 3.15.0`);
MISHANDLED = (exit 0 AND last stdout line `RELEASE_CLOCK: CLEAN`) OR
written receipt verdict `fired` for S040 OR `Traceback` in combined
output; TYPED = exit 1, no traceback, stdout finding line naming
S040/feed with a non-BASE-era category; else OTHER; export via
`git -C <lane> archive --format=tar <rev>` into a private temp dir — the
lane checkout is never written.

## NOT checked

- Candidate measured at the lane-committed 62a33b1 (reproducible); L1's
  END measurement remains authoritative.
- Fixture feed mimics Atom shape (entry/title), not python.org's exact
  bytes; no host/URL fetch. c2-measure.py and G1..G4 (XC2Patch) untouched.
- Untested: exit-2 SETUP path (:837/:1751); `utc_timestamp` pin vs a
  changed `observed_at`; the below-newest feed case (R4) — no frozen
  fixture carries it.
