# FRssHuge — round-28 C1 falsification: RSS newest oversized title

Target: pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`). Carrier: C1 (freshness) only — release-clock version-token canonicality on the RSS/Atom feed path. Method: my own harness (NOT the lane's `c1-measure.py`), exported trees only, transport stubbed exactly as the script's own selftest does (`request_body`/`utc_timestamp` module globals). No network.

## Verdict

**PASS on the frozen carrier** (newest stable title = oversized component): candidate types the row `NON-CANONICAL`, exits 1, prints no `Traceback`, writes **no fired verdict**.
**FAIL on scope-adjacent totality — real defect in the pinned candidate (F-1)**: a non-canonical token ordering *below* the newest canonical token is silently ignored, so an oversized title can still yield a written `fired` observation. (Repair rev `5e84747` "total feed validation" closes exactly this; the pinned candidate under attack does not have it.)

## Commands run (exit codes)

- `git -C <lane> archive 62a33b1… | tar -x -C /fast/scratch/hyaku/kagi-r28/FRssHuge/cand` → 0; same for `3553d49…` → base
- `python3 harness.py <cand|base> <out> <label>` → 0 (5 RSS fixtures per tree)
- `python3 -I -B corpus/release-clock.py` (cand) → **0**, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`; (base) → **0**, same line
- `python3 -I -B corpus/release-clock.py --selftest` → 0; cand `PASS (106 cases)`, base `PASS (79 cases)`
- Retained: `.ufo/waves/round-28/sandboxes/FRssHuge/receipts/{harness.py,results-cand.json,results-base.json}`. Exported trees deleted (scratch 8K).

## F-1 (MEDIUM, real) — candidate is not total over feed entries: an oversized title still yields a fired verdict

`corpus/release-clock.py:784-798` (`newest_stable`) drops non-canonical tokens from the candidate set (`:791`) and rejects the feed only when such a token orders **at or above** the newest canonical token (`:795-797`). A non-canonical token ordering **below** the newest canonical token is ignored, and the feed still names a release. Counterexample (RSS 2.0; newest *document-order* item carries the oversized title): `titles = ["Python 3.14." + "1"*4301, "Python 3.16.0"]`. Candidate observed:

    exit=1  traceback=False
    typed_lines = ['RECEIPT-MISMATCH S040']     <-- generic, NOT NON-CANONICAL
    receipt = {"parsed_version": "3.16.0", "verdict": "fired", "error": null}
    fired_written = True

A feed containing a 4301-digit token produced a **written `fired` observation**, and the only typed finding is the generic `RECEIPT-MISMATCH` — exactly the "generic receipt mismatch" the acceptance criteria forbid as proof of the new rule. BASE differed (typed `RECEIPT-MISMATCH` with `error="Exceeds the limit (4300 digits) for integer string conversion…"`), so this is candidate-side loss of the typed guarantee, not a BASE-only artifact. Same root cause, other shape: titles `["Python 3.15.0", "Python 3.14."+4301×"1"]` → candidate `parsed_version="3.15.0"`, `verdict="regressed"`, typed `['RECEIPT-MISMATCH S040','REGRESSED S040']` — the oversized token is ignored entirely, no `NON-CANONICAL` finding at all. The candidate's own selftest encodes this as intended (`corpus/release-clock.py:1383-1388`, "older oversize entry was not ignored"), which contradicts C1's "a version token used for … a feed entry must be canonical … otherwise the row or feed gets a typed finding". Repair rev `5e84747` (`newest_stable` → `if any(non_canonical_version(token) for token in tokens): raise`) closes F-1; `62a33b1` lacks it.

## F-2 (LOW, observation, not a defect) — 4-component oversized title is not a "version token" at all

`corpus/release-clock.py:779` `STABLE_TITLE_RE` requires exactly `X.Y.Z`, so title `Python 3.15.1.<4301×"1">` never becomes a token: candidate exits **0**, `parsed_version="3.15.1"`, `verdict="not-fired"`, no typed finding. BASE identical (exit 0). Consistent with the candidate's own docstring and C1's X.Y.Z scope — recorded, not counted as failure.

## Positive results on the frozen carrier (candidate)

Fixture: RSS 2.0 `<item><title>` feed, SOURCES.md narrowed to S040+S039, release-clocks.tsv narrowed to the S040 row, `request_body` stubbed to serve the fixture bytes. Every row: **no traceback, no fired verdict written**; typed category exactly `NON-CANONICAL`, outside the BASE-era set {ORPHAN, UNBOUND, INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED} ⇒ not a generic receipt mismatch.

| newest title fixture | exit | typed finding | receipt error |
|---|---|---|---|
| `Python 3.15.`+4301×`1` (newest) | 1 | `NON-CANONICAL S040` | `non-canonical version token: feed newest stable entry` |
| `Python 3.15.`+4301×`1` only | 1 | `NON-CANONICAL S040` | `… feed has no canonical stable X.Y.Z entry` |
| `Python 3.15.01` (newest) | 1 | `NON-CANONICAL S040` | `… feed newest stable entry` |
| `Python 3.15.`+4301×`1` in **major** | 1 | `NON-CANONICAL S040` | `… feed newest stable entry` |
| oversize only in `/releases/tag/v…` href | 1 | `NON-CANONICAL S040` | `… feed newest stable entry` |
| `Python 3.15.1` (control) | 0 | — `CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=0 derived=0)` | none |

Candidate path: `parse_latest_version` `:801` → `newest_stable` `:784-798` → `ValueError(NON_CANONICAL_PREFIX…)` `:797` → caught `:913-914` into `receipt["error"]` → typed by `evaluate` `:679-681`; row-side token check `:630-631`; prefix `:391`.

## BASE comparison (same fixtures, same harness)

BASE `3553d49`: `corpus/release-clock.py:380` `numeric_version` still calls `int(part)`; `:760` `max(stable, key=lambda v: tuple(int(part) …))` — the oversized component raises CPython `ValueError: Exceeds the limit (4300 digits) for integer string conversion`. Observed at BASE: newest-oversize → typed `['RECEIPT-MISMATCH S040']`, `error="Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits…"`, `parsed_version=null`, `verdict=null` — untyped CPython message, no `NON-CANONICAL` category ⇒ not a typed canonical finding. Leading-zero newest → BASE **writes a fired verdict** (`verdict="fired"`, `parsed_version="3.15.01"`) — the exact "reads as a fired release" defect C1 names; candidate: `verdict=null`, `NON-CANONICAL`. (Lane's `XC1Measure-base-c1.json` records F3/F4 MISHANDLED; `…-rerun.json` shows F4 exit 1 with the CPython `ValueError` text.) Control `Python 3.15.1`: exit 0 CLEAN at both trees.

## What I did NOT check

- C2 (derived-anchor binding) — outside this carrier; not measured.
- The lane's frozen `c1-measure.py` was not re-run by me (I used my own harness); the lane's recorded `XC1Measure-candidate-c1.json` (mishandled=0/4, typed=4/4, control CLEAN) agrees with my RSS results.
- No live fetch of `https://www.python.org/downloads/feed.rss` (no network); transport stubbed ⇒ live TLS/HTTP behaviour unverified. Unverified: plain-text `Version:` feeds, tag-href cases beyond the one above, `MAX_BODY_BYTES`/`MAX_XML_ELEMENTS` limit paths, the `rendered-quote` clock.
- Repair rev `5e84747` was diffed read-only (quoted) but not executed; no runtime claim about it.
- Lane not modified; no lane gates/selftests run in the lane checkout; no git/jj mutation.
