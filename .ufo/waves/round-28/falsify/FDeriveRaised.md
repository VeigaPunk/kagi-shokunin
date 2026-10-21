# FDeriveRaised — round-28 falsify: derived anchor RAISED above its feed-row anchor

**Verdict: PASS** — the candidate refuses the raised-derived-anchor forgery on every
route I could construct; no acceptance counterexample found in this carrier.
Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (BASE `3553d499577084a6c98d7078906017840bbf7b28`).
Carrier C2: "a `derived:` row's anchored version must be the version named by its
`feed_source_id` registry row's located anchor in `corpus/SOURCES.md`".

## Attack (raised direction; the plan's frozen fixtures only lower)

Raise a derived row's `anchored_version` **above** the version its feed registry row
names (S033→3.13.3, S034→2.2.0, S035→2.7.1, S037→8.23.0), set `observed_version` to
the same canonical raised token, verdict `not-fired`. The default receipt pins every
row's observation, so the edited rows' receipt records are mirrored into a copy of the
default receipt and the run uses `--receipt <copy> --receipt-sha <sha>` (the frozen
`.ufo/waves/round-28/tools/c2-measure.py` construction). A generic `RECEIPT-MISMATCH`
is therefore **not** available as proof — the mirror removes it.

## Candidate code under attack

- `corpus/release-clock.py:618` — `if (is_derived and not non_canonical and feed_source is not None and not derived_anchor_bound(feed_source["anchor"], anchored)):`
- `corpus/release-clock.py:625` — `errors.add(("DERIVATION", source_id))`
- `corpus/release-clock.py:349-363` — `derived_anchor_bound()` (stable-token set equality vs the feed row's anchor cell only)
- BASE `corpus/release-clock.py:565-566` — `is_derived` only *skips* the anchor check; BASE has no `DERIVATION` category (`grep -c DERIVATION` = 0).

## Commands (sandbox clones only; no network; no lane-checkout execution)

    git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C <sandbox>/clone-candidate
    git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d499577084a6c98d7078906017840bbf7b28 | tar -x -C <sandbox>/clone-base
    python3 -I -B <sandbox>/attack/raise_attack.py          # exit 0
    python3 -I -B <sandbox>/attack/observe_raise_probe.py    # exit 0  (OBSERVE_PROBE PASS)
    python3 -I -B <sandbox>/attack/extra_probes.py           # exit 0
    python3 -I -B <sandbox>/clone-candidate/corpus/release-clock.py --selftest   # exit 0, PASS (106 cases)

Fixture run form: `python3 -I -B <clone>/corpus/release-clock.py --root <fixture> --receipt <fixture>/receipt.json --receipt-sha <sha256>`
Control (unmodified clone) `python3 -I -B corpus/release-clock.py` → exit 0,
`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` on **both** candidate and BASE.

## Result — raised groups, receipt mirrored (candidate)

| fixture | feed / raise | rows | exit | findings | summary |
|---|---|---|---|---|---|
| R1 | S033 3.13.3→**3.13.4** | S008-S011 | 1 | `DERIVATION S008,S009,S010,S011` | FAILED observed=26 fired=3 derived=11 |
| R2 | S034 2.2.0→**2.2.1** | S013,S022-S024 | 1 | `DERIVATION S013,S022,S023,S024` + `REGRESSED S012` | FAILED observed=25 fired=2 derived=11 |
| R3 | S035 2.7.1→**2.7.2** | S014-S016,S021,S025,S026 | 1 | `DERIVATION` ×6 (exact ids) | FAILED observed=24 fired=3 derived=9 |
| R4 | S037 8.23.0→**8.23.1** | S029 | 1 | `DERIVATION S029` | FAILED observed=29 fired=3 derived=14 |

No `Traceback` in stdout/stderr (stderr empty in every run). No `RECEIPT-MISMATCH` on any
edited row — the same fixture *without* the mirror does emit `RECEIPT-MISMATCH S008..S011`
etc., so the remaining finding is the derivation rule, not the generic receipt path.
No fired verdict: `fired=3` equals the control's 3 (R2: 2 — S012's own `fired` row turns
`REGRESSED` because the raise lifts the feed floor to 2.2.1).

## BASE comparison (same fixtures, same mirrored receipts)

- R1/R3/R4 on BASE → **exit 0, `RELEASE_CLOCK: CLEAN`** — BASE silently accepted the forged raised anchors (the counterexample this rule closes).
- R2 on BASE → exit 1 but only `REGRESSED S012` (base-category floor effect on a *sibling*); the four forged rows were accepted.
- No-mirror variants on BASE → exit 1 with `RECEIPT-MISMATCH` only (the generic path).

## Single-row / numeric-successor / non-canonical raises (candidate)

- P5 partial raise (only S008 → 3.13.4): `DERIVATION S008` + `REGRESSED S009,S010,S011`; the forged row is typed on its own. BASE on the same fixture yields only the three sibling `REGRESSED` findings and **accepts S008**.
- P6 numeric-successor raise (S008 → 3.13.30; numeric order says raised, string order says different token): candidate `DERIVATION S008`; BASE accepts S008.
- P7 raised but non-canonical anchor (S008 → 3.13.04): exit 1, `NON-CANONICAL S008` (C1's category) — the `not non_canonical` guard at `corpus/release-clock.py:618` skips the derivation branch. Still a typed refusal, no traceback, no release event.

## Observe path (offline stub, no network)

`--observe` with the feed body stubbed; registry feed row names `v1.2.9`, derived row claims raised `1.3.0` with a matching observation:
- feed truly at `v1.2.9` → written receipt verdict `regressed`, summary `failed=0 fired=0 regressed=1`, exit 1, findings `DERIVATION S001`, `REGRESSED S001`.
- feed advanced to `v1.3.0`, registry still `v1.2.9` → receipt verdict `not-fired`, `fired=0`, exit 1, **only** `DERIVATION S001` (no receipt mismatch, no traceback).
- control (anchor == registry anchor) → exit 0. No "fired" verdict is ever written for the raised row.

## Residual risk / notes (no defect asserted)

1. A raise on a feed that also carries a non-derived `fired` row (S034/S012) yields a mixed finding set (`DERIVATION` + base-category `REGRESSED`); the frozen `c2-measure.py` EXACT predicate (all findings non-base-category) would fail on such a fixture. The frozen fixtures only lower, so the frozen counts are unaffected. [INFERENCE]
2. `derived_anchor_bound` demands the feed cell name **exactly one** stable token; a cell naming two stable versions would type `DERIVATION` for every derived row on that feed. No cell in `corpus/SOURCES.md` S033-S037 does — I printed all five anchor cells, each holds one token. [INFERENCE]
3. The derivation branch is skipped for non-canonical tokens (line 618); such a row is typed `NON-CANONICAL` instead (P7) — different category, refusal still typed and total.

## What I did NOT check

- No network fetch of any real feed (S033-S037, python.org, curl.se); the observe probe used a stubbed body, so the registry cells' live-feed truth is unverified here.
- Not run: the full round-28 suite, the other falsify items, C1's own fixtures, lane census/selftest gates (out of scope for this seat).
- No production file modified; writes are only `<sandbox>/attack/{raise_attack.py,observe_raise_probe.py,extra_probes.py,raise-results.json,observe-raise-results.json,extra-probe-results.json}` plus this report.
- No tooling installed (python3 + git archive only, preinstalled).
- Per the scratch directive the two exported clones (108M + 105M) were deleted after the runs; the two `git archive` lines above reproduce them, and the retained fixture trees + JSON receipts are under `<sandbox>/attack/`.
