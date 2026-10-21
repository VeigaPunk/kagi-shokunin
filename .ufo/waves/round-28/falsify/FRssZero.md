# FRssZero — round-28 falsify: RSS newest leading-zero title (C1, freshness)

Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (BASE
`3553d499577084a6c98d7078906017840bbf7b28`). Carrier: `--observe` over a python.org-shaped
feed whose **newest stable item title carries a leading zero**. No network was used.

**Verdict: PASS for the frozen F3 carrier** — a newest-title leading zero yields a typed
`NON-CANONICAL` finding (exit 1, no `Traceback`, no fired verdict written), and BASE really
did fire a release there. **One scoped defect (F2, medium):** the shipped rule is
*position-dependent* — a leading-zero title that is **not** the newest entry is silently
accepted (`CLEAN`, exit 0) or still fires a release event. The frozen plan's §C1 text
("a version token used for an anchor, a table observation or a feed entry must be canonical
… otherwise the row or feed gets a typed finding (exit 1), **never a release event**") is
broader than what ships. Not a frozen-fixture failure — a claim-scope gap for L1.

## F1 — PASS: newest stable RSS title with a leading zero → typed NON-CANONICAL

Path: `corpus/release-clock.py:395` `non_canonical_version` → `:779` `STABLE_TITLE_RE`
(`^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)$`) → `:784-798` `newest_stable` (`:793`
no-canonical-entry, `:795-797` newest-entry raise) → `:880` `parse_latest_version` →
`:913-914` `except (OSError, ValueError)` records `receipt["error"]` (no verdict) →
`:679-681` `evaluate()` maps the `NON_CANONICAL_PREFIX` error to `("NON-CANONICAL", row)`.

- Frozen command, untouched: `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand <D>/c1-cand.json`
  → exit 0, `C1_MEASURE cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True`;
  F3 record: `verdict=null, parsed_version=null, error="non-canonical version token: feed newest stable entry"`,
  stdout `NON-CANONICAL S040` + `RELEASE_CLOCK: FAILED …`, exit 1, no `Traceback`, no fired record.
- BASE, same command → exit 0, `mishandled=3/4 typed=0/4 other=1/4`; F3 wrote
  `verdict="fired", parsed_version="3.15.01"` (BASE defect line `corpus/release-clock.py:760`
  `max(stable, key=lambda v: tuple(int(part) …))`).
- My own harness (own fixture staging + own runner, RSS 2.0 `<item><title>` shape instead of
  the frozen tool's Atom): newest-leading-zero → TYPED, exit 1, `NON-CANONICAL S040`, receipt
  `verdict=null`, typed error, no traceback, no fired verdict. Same TYPED for: only-leading-zero
  item (`feed has no canonical stable X.Y.Z entry`), CDATA title, `v3.15.01`, `03.15.1`,
  `3.015.1`, 4301-digit patch. BASE wrote `verdict="fired"` with `parsed_version` `3.15.01` /
  `03.15.1` / `3.015.1` for each → the fix is real, not cosmetic.

## F2 — DEFECT (medium): a leading-zero title below the newest canonical entry is ignored

`corpus/release-clock.py:791-797`: only tokens with `version_order(token) >= version_order(newest)`
are refused; a non-canonical token ordering **below** the newest canonical one is dropped
silently (docstring `:785-789`; `corpus/lessons/round-28.md:61-64` states the narrowing
deliberately). The table path is total (`:617`, `:627-631`); only the feed path is
position-dependent. Counterexamples (candidate; S040 row + S039 registry row verbatim, only the
local feed copy changed):

- **D — silent CLEAN.** RSS items `Python 3.15.1`, `Python 3.9.01` → exit **0**,
  `RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=0 derived=0)`,
  receipt `verdict="not-fired" parsed_version="3.15.1"`, **no typed finding at all** for a feed
  carrying the leading-zero title `Python 3.9.01`. BASE identical → pre-existing, not closed.
- **C — release event still fired.** RSS items `Python 3.15.01`, `Python 3.16.0` → receipt written
  with **`verdict="fired", parsed_version="3.16.0"`** (`RELEASE_CLOCK_OBSERVE: wrote 1 observations
  (failed=0 fired=1 regressed=0)`), exit 1, and the only finding is `RECEIPT-MISMATCH S040` — a
  BASE-era category, i.e. **no** `NON-CANONICAL`. By the frozen predicate ("a written fired
  observation" ⇒ MISHANDLED) this feed produces a release event.

Same carrier as the frozen F3 fixture, one position away. L1 decision: narrow the round-28 claim
text to "the newest stable entry" (the lesson already does), or extend the rule to every
feed-entry token.

## Commands run (exit codes)

1. `git -C <lane> archive 62a33b1… | tar -x -C <D>/cand` (and `3553d49…` → `<D>/base`) — exit 0.
2. `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand <D>/c1-cand.json` — exit 0.
3. `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d49… base <D>/c1-base.json` — exit 0.
4. `python3 -I -B <D>/harness/rssh.py <D>/cand cand` (and `<D>/base base`) — exit 0, 11 RSS/Atom fixtures each.
5. `python3 -I -B corpus/release-clock.py --selftest` (in the exported candidate copy) — exit 0,
   `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` (matches ledger pin R25-03). No tool installed/updated.

## Evidence (kept with this report; `<D>` = `.ufo/waves/round-28/sandboxes/FRssZero/`)

`<D>/c1-cand.json`, `<D>/c1-base.json` (frozen instrument), `<D>/rssh-cand.json`,
`<D>/rssh-base.json` + `<D>/harness/rssh.py` (my harness), `<D>/receipts/*.observe-out.json`
(six written S040 records). Exported trees deleted after the runs; re-export via command 1.

## What I did NOT check

- C2 / calibration, the DERIVATION path, and the internals of F1/F2/F4 (only the frozen
  instrument's per-fixture verdicts were read for those).
- The real HTTPS transport (`valid_public_https_url`, `public_addresses`): `request_body` was
  replaced by a local stub in a child process (the substitution the script's own selftest uses);
  no live python.org feed was fetched.
- Lane gates/selftests were **not** run in the lane checkout (the selftest above ran in the
  exported sandbox copy). No git/jj mutation, no production edit, no SHONEN mark.
