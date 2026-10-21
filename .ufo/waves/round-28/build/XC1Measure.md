# XC1Measure — frozen C1 counting instrument (`c1-measure.py`) + BASE numbers

BASE = 3553d499577084a6c98d7078906017840bbf7b28. Tool:
`.ufo/waves/round-28/tools/c1-measure.py` (frozen command
`python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>`);
artifact `build/XC1Measure-base-c1.json` (format `kagi-round28-c1-measure-v1`);
Python 3.14.8; no installs.

## BASE result (the numbers)

```
C1_MEASURE XC1Measure-BASE: mishandled=4/4 typed=0/4 other=0/4
control_exit=0 control_clean=True   (tool exit 0)
control: RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30
fired=3 derived=15) — the plan's exact control string
```
Per fixture, with the frozen-predicate arm each verdict rides:

- **F1** table-lie (S040 `observed_version=3.15.01`, `verdict=fired`): exit 0,
  `RELEASE_CLOCK: CLEAN (… fired=4 derived=15)` → MISHANDLED, **exit-0-CLEAN
  arm**. `numeric_version` (corpus/release-clock.py:369-380) maps 3.15.01 →
  (3,15,1) (REGRESSED guard :574 silent); fired branch :582-583 accepts on
  string inequality (`norm_version` :362).
- **F2** table-oversize (`3.15.`+4301×`1`): exit 1, **stdout empty**, stderr
  `ValueError: Exceeds the limit (4300 digits)…` from numeric_version:380,
  uncaught in evaluate:502 → MISHANDLED, **Traceback arm** (only signal,
  stderr-only).
- **F3** observe-zero (local python.org-shaped feed, newest stable
  `Python 3.15.01`): `parse_latest_version` :710/:760 accepts it;
  `observe_one` :767 writes `{"parsed_version": "3.15.01", "verdict":
  "fired"}`; exit 0 CLEAN (fired=1) → MISHANDLED, **exit-0-CLEAN arm and
  written-fired-observation arm**.
- **F4** observe-oversize (4301-digit patch): fixture runs the plan's
  `--observe` command; observe arm raises at :760, caught at :822 → untagged
  receipt error (in JSON), no traceback; the evaluate stage of the same
  command crashes on the mirrored oversize table row at :380 → exit 1
  traceback → MISHANDLED, **Traceback arm**. The F4 mirror (oversize
  observed_version in the fixture table) is harness construction beyond the
  plan's literal F4 text (plans/round-28.md:38) — a reported deviation.
  Observe-only, the honest BASE verdict is OTHER (neither MISHANDLED nor a
  canonicality TYPED finding).

## Findings (defects/risks; nothing redefined)

1. **Bare tsv edits can never measure C1**: the default receipt (:28,
   `.ufo/waves/round-26/observe-2.json`, sha256 13b8540c…) pins
   observed_version/verdict via receipt_matches (:425-447); a table-only
   edit ends `RECEIPT-MISMATCH S040` (:608/:614) — generic integrity, not
   the targeted behaviour. Pinned per L1's plan correction: F1/F2 mirror
   edited rows into a receipt copy and run `--receipt/--receipt-sha`.
2. **Frozen-spec defect (declared in my work order): F3/F4 cannot run the
   shipped CLI against a local feed.** `valid_public_https_url` :176 +
   `public_addresses` :309/:327 admit only public global HTTPS:443
   (`request_body` :669-671 rejects the rest). Closest faithful harness: the
   exported release-clock.py's own `main()` in a child `python3 -I -B` with
   module-global `request_body` stubbed to the fixture feed and
   `utc_timestamp` pinned to the row's `observed_at` — the substitutions the
   script's own selftest makes. Table narrowed to S040, registry to
   S040+S039, rows verbatim (unmodified table → 29 `UNBOUND` :532).
3. **F4 arm dependency + consolidated plan correction**: the observe path
   never tracebacks at BASE (catch at :822; untagged CPython message); the
   measured MISHANDLED rides the Traceback arm raised by the F4 mirror (see
   F4 bullet); observe-only F4 = OTHER under the pinned reading. L1's
   §Plan corrections (plans/round-28.md:91) must carry together: (i) the
   receipt-mirror construction inside the C1 and C2 fixture definitions,
   (ii) the F4 table-path substitution, (iii) the shared typed-finding
   convention (the claim's own category — C1 NON-CANONICAL, C2 DERIVATION;
   everything else OTHER).
4. **TYPED is a canonicality token, not "exit 1 + names the row"**: the
   instrument counts TYPED only for a stdout finding line naming S040/feed
   whose category is outside the frozen set {ORPHAN, UNBOUND, INCONSISTENT,
   BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}; exit 2 SETUP
   (:1751) is OTHER (shared with XC2Patch: identical exclusion set at
   c2-measure.py:60, new category DERIVATION in XC2Patch.diff).
5. **Validation both ways**: against XC1Patch's patched sandbox tree
   (scratch rev 7db9a7a5; probe artifact retained as
   `build/XC1Measure-patched-probe-c1.json`) the same tool reports
   `typed=4/4` (exit 1, `NON-CANONICAL S040`, no traceback, no fired
   observations), control CLEAN exit 0; after-run F3/F4 receipts carry
   `error` starting "non-canonical version token: " with `verdict: null` —
   tokens TAGGED, not untagged errors. The "never a release event" half is
   recorded, not classifier-enforced; read `fired_observation_written`
   without inverting: BASE JSON true for F3 (the MISHANDLED signal),
   after-run JSON false for F1-F4; RevC1Fixtures' partial patch (feed
   guards removed) still scores TYPED while writing a fired receipt. The
   after-run F3/F4 error is the ROW guard ("row anchor or observation") —
   observe_one refuses before the fetch, so the feed-entry rule
   (newest_stable) is not exercised at all: the numbers cannot distinguish
   strict vs lenient feed rules (R4, L1's call). An
   untagged non-finding fix scores OTHER (typed 0/4): a vacuous transition
   fails this instrument.

## Commands run (exit codes)

- Sandbox selftest (BASE git mirror) → exit 0, mishandled=4/4 typed=0/4;
  TYPED probe (patched tree, scratch rev 7db9a7a5…) → exit 0, typed=4/4;
  both via the frozen command form under the frozen env (below).
- Lane frozen command on BASE → `build/XC1Measure-base-c1.json`: exit 0,
  mishandled=4/4 typed=0/4 other=0/4 control_exit=0; no installs.

## Pinned harness conventions (frozen into the tool)

Mirror/narrowing conventions: Findings 1-2. Fixtures run `env -i PATH HOME
LC_ALL=C PYTHONDONTWRITEBYTECODE=1 python3 -I -B …`; F3/F4 feed = Atom.

1. MISHANDLED = (exit 0 AND (last stdout line `RELEASE_CLOCK: CLEAN` OR a
   written receipt verdict `fired` for S040)) OR `Traceback` in combined
   output. TYPED = exit 1, no traceback, stdout finding line naming
   S040/feed with a non-BASE-era category. Else (incl. exit 2) OTHER.
2. Export: `git -C <lane> archive --format=tar <rev>` into a private temp
   dir; the lane checkout is never written.

## NOT checked

- Probe used XC1Patch's sandbox tree, not an integrated lane rev; L1's END
  measurement is the authoritative after-number.
- Fixture feed mimics Atom shape (entry/title), not python.org's exact
  bytes; no host/URL fetch. c2-measure.py and G1..G4 (XC2Patch) untouched.
- No fixture exercises the exit-2 SETUP path (:837/:1751); the
  `utc_timestamp` pin is untested against a changed `observed_at`.
