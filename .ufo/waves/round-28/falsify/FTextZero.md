# FTextZero — round-28 falsify: curl text-carrier leading-zero version token

Target: kagi-shokunin @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (BASE `3553d499577084a6c98d7078906017840bbf7b28`).
Carrier: row **S029** (clock `feed`, `feed_source_id=S037`, `https://curl.se/info`) — the plain-text `Version: X.Y.Z` path.
Verdict: **PASS** on the declared curl Version line (exact typed category `NON-CANONICAL`, exit 1, no traceback, no fired verdict written), with **two residual risks** below (no FAIL, no new scope).

## Method (no network, no lane execution)
- Read-only exports: `git -C <lane> archive 62a33b1 | tar -x -C /fast/scratch/hyaku/kagi-r28/FTextZero/cand` and same for `3553d49` → `…/base` (exit 0). Nothing executed in the lane checkout; lane `HEAD` still `62a33b1`; only this report + my sandbox were written.
- Body fixture = the **byte-exact upstream capture already committed in-tree**: `.ufo/waves/round-26/build/ClockS029-evidence/info.body` (352 B, sha256 `cfa106be99126075e28cd6dbc675aa1cebf7f81b02e0a39e31efd946e765e1e8` = `corpus/source-fetches.tsv:80`, quote `Version: 8.23.0` at line 1). Only the version token is mutated; everything else is unchanged.
- Harness (in my sandbox `sandboxes/KagiR28.FTextZero/`): `probe.py` (feed-body variants), `probe2.py` (table row + mirrored receipt), `probe3.py` (secondary line forms), `probe4.py` (byte-exact body). Each builds a minimal corpus fixture (registry rows S029+S037 and clock row S029 copied verbatim from the tree under test), serves the body offline, runs the real CLI `main(["--root",…,"--observe",…])` / `["--receipt",…,"--receipt-sha",…]`, and prints exit code, stdout categories and the written receipt record.
- **All path:line citations below are against the pinned candidate export (`git archive 62a33b1`), not the lane working tree**: the lane's `corpus/release-clock.py` was being edited concurrently by another seat while I ran (mtime 14:56, `STABLE_TOKEN_RE`, `newest_stable`, `load_receipt_bundle` hunks) — not my edit; I never wrote in the lane checkout. My verdict is about the pinned candidate `62a33b1` as instructed.

## Finding 1 — PASS (primary): leading-zero curl `Version:` line is a typed finding, never a fired release
Command: `python3 -I -B probe4.py …/cand CAND` / `…/base BASE` (harness exit 0; inner CLI exit 1).
Counterexample body = the real 352 B capture with line 1 → `Version: 8.23.01` (body sha256 `bb2d7e6b1befb770…`).

| | BASE `3553d49` | CAND `62a33b1` |
|---|---|---|
| stdout category | `RECEIPT-MISMATCH S029` (generic) | `NON-CANONICAL S029` (exact typed category) |
| receipt S029 | `verdict='fired'`, `parsed_version='8.23.01'` → **a fired release written for a leading-zero token** | `verdict=None`, `parsed_version=None`, `error='non-canonical version token: text release version'` |
| summary | `RELEASE_CLOCK: FAILED (… fired=0 …)` exit 1 | `RELEASE_CLOCK: FAILED (on_release=1 bound=1 unbound=0 observed=0 fired=0 derived=0)` exit 1 |
| traceback | none | none |

Exact candidate path:line — `corpus/release-clock.py:815-816` (`if non_canonical_version(match.group(1)): raise ValueError(NON_CANONICAL_PREFIX + "text release version")`) inside `parse_latest_version` (:801), the refusal is typed into `("NON-CANONICAL", source_id)` at `corpus/release-clock.py:680` (receipt-error branch; :391 prefix, :395 `non_canonical_version`, :870-872 row-anchor pre-check, :631 row-level branch). BASE counterpart: `corpus/release-clock.py:729` `return match.group(1)` — the raw leading-zero token is returned and becomes a fired receipt.
Control: unmodified capture → CAND exit 0 `RELEASE_CLOCK: CLEAN (… fired=0 derived=1)`, `parsed_version='8.23.0'`; BASE identical.
Leading-zero in the major/minor/zero component (`08.23.0`, `8.023.0`, `8.23.00`), `v8.23.01`, trailing blanks and a later line all give the same typed `NON-CANONICAL S029` exit 1 in CAND and `verdict='fired'` in BASE.

## Finding 2 — PASS: the same rule on the curl *table* row (no generic mismatch as proof)
Command: `python3 -I -B probe2.py …/cand CAND` / `…/base BASE`.
- CAND: S029 `observed_version=8.23.01`, `verdict=fired` (receipt mirrored, `--receipt`+`--receipt-sha`) → `NON-CANONICAL S029`, exit 1, `fired=0`.
- BASE: same fixture → `RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=1 derived=1)`, exit 0 — the leading zero **reads as a fired release** (the C1 defect on the curl row).
- CAND with a leading-zero *anchor* (`anchored_version=8.23.01`, observed `8.23.01` and `8.23.0`) → `NON-CANONICAL S029`, exit 1, no second category (`DERIVATION` is correctly suppressed for non-canonical anchors, `corpus/release-clock.py:617-619`).

## Finding 3 — residual risk (medium-low): a non-canonical token **outside** the first `Version:` line is silently ignored → CLEAN exit 0
Evidence: `corpus/release-clock.py:813-817` (text path: `TEXT_VERSION_RE.search` → only the **first** `Version:` line is read) vs `:784-798` `newest_stable` (atom path inspects **every** stable token and refuses on any non-canonical one). The two carriers are asymmetric.
Counterexample (CAND, real body): line 3 → `Download: https://curl.se/download/curl-8.23.01.tar.gz` → exit **0**, `RELEASE_CLOCK: CLEAN (… fired=0 …)`, receipt `parsed_version='8.23.0'`, **no typed finding at all**. Same for `Changelog: https://curl.se/ch/8.23.01.html` and for a second `Version: 8.23.01` line after a canonical one. BASE behaves identically → pre-existing, not a candidate regression; but C1's wording ("a version token … in a feed entry must be canonical; otherwise the row or feed gets a typed finding") is not met for the text carrier outside line 1.
Note: the frozen C1 fixtures (`.ufo/waves/round-28/tools/c1-measure.py:10-23`, F1–F4) cover only the python.org RSS carrier and the table — the plain-text curl carrier is **not in the frozen set**, so this gap is invisible to the frozen count.

## Finding 4 — residual risk (low): the typed category depends on the exact line form
A leading-zero token on a line form the corpus does not declare falls back to the pre-existing generic refusal `text release file has no Version: X.Y.Z line` → typed as **generic `RECEIPT-MISMATCH`** (exit 1, no fire, no traceback) in CAND *and* BASE: `Version: 8.23.01 (x86_64-pc-linux-gnu)`, CRLF body `Version: 8.23.01\r\n`, `version: 8.23.01` (lowercase), ` Version: 8.23.01` (indent), `Version: 8.23.01.1` (4 components). Per this wave's contract these generic mismatches are **not** accepted as evidence of the new rule (they are the old refusal path, `corpus/release-clock.py:818`); only the corpus-declared line form yields `NON-CANONICAL`.

## Commands run (exit codes)
- `git -C <lane> archive 62a33b1 | tar -x -C …/cand` ; same for `3553d49` → `…/base` — 0
- `python3 -I -B probe4.py …/cand CAND` — 0 (inner CLI 0/1 per variant; results in `results-*.json`)
- `python3 -I -B probe4.py …/base BASE` — 0; `probe.py` (13 variants × 2 trees) — 0; `probe2.py` ×2 — 0; `probe3.py` ×2 — 0
- `python3 -I -B corpus/release-clock.py --selftest` (in the exported candidate tree) — 0, `RELEASE_CLOCK_SELFTEST: PASS (106 cases)`
- `python3 -I -B corpus/release-clock.py` (default verify, pinned receipt, no network) — 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` — matches the plan's control line.

## What I did NOT check
- No live network fetch of `curl.se/info`; upstream line endings today are unconfirmed (the committed capture is LF). I did not chase the real-world divergence between the corpus's `Version:` line model and upstream's actual first line.
- Did not run the frozen counting command `c1-measure.py` (its fixtures do not cover this carrier) and did not audit the frozen fixture definitions.
- Did not test the atom/RSS carrier, the oversize (>4300-digit) carrier, C2's derived-anchor binding, ledger/stamp bookkeeping, or the "selftest count grows only by new cases" claim against BASE's count.
- Did not execute any gate or script inside the lane checkout; did not modify production files.
