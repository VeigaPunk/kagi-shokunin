# FAtomZero — round-28 falsification: Atom feed whose newest stable title carries a leading zero

Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (BASE `3553d499577084a6c98d7078906017840bbf7b28`).
Carrier: `--observe` over a python.org-shaped **Atom** feed whose newest stable item is titled
`Python 3.15.01`. Isolation: exported candidate + BASE trees under
`.ufo/waves/round-28/sandboxes/KagiR28.FAtomZero/`, `request_body` stubbed to the local feed (transport
replaced, as `corpus/release-clock.py`'s own selftest does) — **no network**, no lane writes, no
production bytes edited. Verdict is a recommendation, not closure.

## Verdict

**PASS for the assigned carrier** (Atom newest leading-zero title → typed finding, no traceback,
no fired verdict written), plus **one MEDIUM boundary defect** (a non-canonical Atom entry that
orders *below* the newest canonical entry is silently dropped), reproduced independently below.

## F1 — MEDIUM (corroborates `FFeedOlder.md`): sub-newest non-canonical Atom entry is silently ignored

- Candidate path:line — `corpus/release-clock.py:784-798` (`newest_stable()`; ignore rule at
  `:795-797`) and `corpus/release-clock.py:848` (`parse_latest_version()` → `newest_stable(stable)`).
- Counterexample (my harness, candidate tree): feed `["Python 3.15.01","Python 3.16.0"]`, table row
  S040 `observed_version=3.16.0`, `verdict=fired` →
  `python3 harness.py cand runs/cand-V4b '["Python 3.15.01","Python 3.16.0"]' '' '{"5":"3.16.0","7":"fired"}'`
  → release-clock **exit 0**, stdout `RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=1 derived=0)`,
  receipt S040 `verdict="fired"`, `parsed_version="3.16.0"`, **no `NON-CANONICAL` line at all**.
- Defect vs the frozen claim (`plans/round-28.md` C1): "a version token used for an anchor, a table
  observation **or a feed entry** must be canonical … otherwise the row or feed gets a typed finding
  (exit 1), **never a release event** and never a traceback". This feed carries `Python 3.15.01`;
  the candidate raises no typed finding **and writes a fired release verdict**. The narrowing is
  deliberate in code (`corpus/release-clock.py:786-789`), so it is a candidate/plan divergence, but
  no frozen fixture covers it and the frozen predicate would score it MISHANDLED. Same class with the
  table left verbatim (`runs/cand-V4`): exit 1, only the generic `RECEIPT-MISMATCH S040`, yet the
  receipt again carries `verdict="fired"`, `parsed_version="3.16.0"`.

## F2 — LOW (frozen C1 text inaccuracy, not my carrier): the oversize ValueError traceback is table-only

- `plans/round-28.md` C1 asserts an over-limit component "raises an untyped ValueError traceback"; measured
  at BASE that holds only for the table path (`corpus/release-clock.py:369` `numeric_version()` → `int(part)`;
  `F2-table-oversize` → `traceback_in_output=True`), while the observe path catches it in `observe_one()`
  (`F4-observe-oversize` → exit 1, `traceback_in_output=False`, `RECEIPT-MISMATCH S040`, BASE F4 classified
  `OTHER`). Frozen before/after numbers (`MISHANDLED k/4 → 0/4`) are unaffected. Reported, not redefined.

## Evidence — assigned carrier, candidate vs BASE

Candidate (`python3 harness.py cand runs/cand-F3 '["Python 3.15.01","Python 3.15.0"]'`, harness exit 0,
inner release-clock **exit 1**): stdout `NON-CANONICAL S040` then
`RELEASE_CLOCK: FAILED (on_release=1 bound=1 unbound=0 observed=0 fired=0 derived=0)`; receipt S040
`verdict=null`, `parsed_version=null`, `error="non-canonical version token: feed newest stable entry"`;
stderr `HARNESS_FETCH_CALLS=['https://www.python.org/downloads/feed.rss']` (stub; no socket);
`traceback_in_output=false`; `RELEASE_CLOCK_OBSERVE: … failed=1 fired=0`.

BASE (`python3 harness.py base runs/base-F3 '["Python 3.15.01","Python 3.15.0"]'`, inner **exit 1**):
stdout `RECEIPT-MISMATCH S040` only — a **BASE-era** category, i.e. the "generic receipt mismatch"
that must not be accepted as proof of the new rule — while the receipt S040 carries `verdict="fired"`,
`parsed_version="3.15.01"` (`RELEASE_CLOCK_OBSERVE: … fired=1`): BASE **wrote a release event** for
the padded token (BASE anchor `base/corpus/release-clock.py:760`
`max(stable, key=lambda v: tuple(int(part) …))`). ⇒ the discriminating evidence is the *category*
`NON-CANONICAL` **plus** `verdict=null`, not the exit code: BASE also exits 1 here.

Candidate implementation: `corpus/release-clock.py:391` (`NON_CANONICAL_PREFIX`), `:395`
(`non_canonical_version()`), `:784-798` (`newest_stable()`, raises `:793`/`:797`), `:848`, `:870-872`
(`observe_one()` pre-check), `:626-631` (row-level `NON-CANONICAL`), `:679-681` (receipt error
prefix → `NON-CANONICAL`).

Same-carrier variants, all **exit 1 / `NON-CANONICAL S040` / no traceback / no fired verdict**:
`V2` feed `["Python 3.15.01"]` only → `…feed has no canonical stable X.Y.Z entry`; `V3` padded token
carried only by `<link href="…/releases/tag/v3.15.01">` → `…feed newest stable entry`; `V7`
`["Python 3.15.1","Python 3.15.01"]` (padded duplicate of the canonical newest) → `…feed newest stable entry`.

Frozen instrument (unmodified, output into my sandbox):
- `TMPDIR=$SB/tmp python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0 cand $SB/runs/c1-cand.json` → exit 0,
  `C1_MEASURE cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` (F3 → `NON-CANONICAL S040`, exit 1, `fired_observation_written=false`).
- same with `3553d499577084a6c98d7078906017840bbf7b28` → exit 0,
  `C1_MEASURE base: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True` (F3 → MISHANDLED, `fired_observation_written=true`).
- Own runs on the candidate export: `python3 -I -B cand/corpus/release-clock.py` → exit 0,
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`;
  `python3 -I -B cand/corpus/release-clock.py --selftest` → exit 0, `RELEASE_CLOCK_SELFTEST: PASS (106 cases)`.

## Not checked / residual risk

- No network: the real python.org feed was never fetched, so I did **not** verify whether a live
  title ever carries a padded component (F1 mitigates only the tool's own grammar).
- Not attacked: C2 (derived anchors), F1/F2 table paths beyond the frozen summary, the receipt-token
  carrier, ledger/lesson/separability bookkeeping, the selftest cases one by one; a padded token inside
  a longer title (`"Python 3.15.01 (security release)"`), which `corpus/release-clock.py:781`
  `STABLE_TITLE_RE` does not recognise as a version at all.
- F1's severity depends on reading the plan sentence as "any feed entry"; a reviewer reading it as "the
  token naming the feed's newest release" would score the candidate conformant — the L1 owns that reading,
  and the candidate docstring (`corpus/release-clock.py:786-789`) states the narrower rule.
- Tooling: no installs/upgrades (none needed); Python 3.14.8, stdlib only. `git archive`/`log`/`status`
  read-only; no commits, pushes, jj or index writes. Retained: `sandboxes/KagiR28.FAtomZero/{harness.py,runs/*}` (~1 MB).
