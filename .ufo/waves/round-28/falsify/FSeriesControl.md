# FSeriesControl — falsify round-28 candidate 62a33b1 (carrier: S012 non-derived `v1.21.x`)

**Verdict: PASS** (carrier-specific). S012 stays valid under the candidate; both new rules are
typed exactly (`NON-CANONICAL`, `DERIVATION`), never a traceback, and never write a `fired`
verdict from a non-canonical token. One low-severity calibration fragility is reported (it does
not touch S012). No lane file was modified except this report.

## Target / method
- Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`
  (code ≠ BASE `3553d499`, exported for comparison).
- Isolated exports (read-only `git archive`; no clone into the lane, no lane git mutation):
  `git archive 62a33b1 | tar -x -C /fast/scratch/hyaku/kagi-r28/FSeriesControl`, BASE into
  `.../base`. Every run is in that scratch dir (probe trees = copies of `corpus/` + retained
  receipt). **No network**: evaluation uses the retained receipt; the observe path uses a static
  opener + fake resolver.
- Carrier facts: `corpus/release-clocks.tsv:9` → S012 `feed / S034 / vault releases.atom /
  anchored v1.21.x / observed 2.2.0 / verdict fired`, note does **not** start with `derived:`;
  `corpus/SOURCES.md:18` (S012 cell names “newest pinned version v1.21.x”); `corpus/SOURCES.md:40`
  (S034 cell names exactly `v2.2.0`).
- Tooling: no installs (none needed); `/usr/bin/python3` 3.14.8.

## Commands and exit codes (isolated exports)
1. `python3 -I -B corpus/release-clock.py --root <cand>` → **exit 0**, `RELEASE_CLOCK: CLEAN
   (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`; BASE same → exit 0, same
   counts. `--selftest`: candidate **exit 0** `PASS (106 cases)`, BASE **exit 0** `PASS (79)`.
2. Per-row evaluation of the control tree (module import, no writes): **S012 errors: NONE**,
   all errors `[]`, `fired=3` — identical at candidate and BASE.
3. Bad inputs on the S012 carrier (table edited **and mirrored into a receipt copy** per the
   round-28 plan correction, so no generic receipt mismatch can stand in for the rule):
   | edit on S012 | candidate 62a33b1 | BASE 3553d49 |
   |---|---|---|
   | `observed_version=2.2.00` (leading zero) | exit 1, `NON-CANONICAL S012`, `fired=2`, no traceback | exit 0 `CLEAN`, `fired=3` — leading-zero token accepted as a fired release |
   | `observed_version=2.2.` + 4301×`1` | exit 1, `NON-CANONICAL S012`, no traceback | exit 1, **untyped `ValueError` traceback** (`base/corpus/release-clock.py:380` `int(part)`) |
   | `anchored_version=v2.02.0` | exit 1, `NON-CANONICAL S012` | exit 1, `INCONSISTENT S012` |
   | receipt carries `non-canonical version token: …` (what `--observe` writes) | exit 1, **`NON-CANONICAL S012`** | exit 1, **`RECEIPT-MISMATCH S012`** (generic) |
   The exact category is thus proven, not inferred from a receipt mismatch.
4. Observe path (offline, static opener, S012-shaped row `anchored=v1.21.x observed=2.2.0`):
   candidate feed `v2.2.0` → `verdict='fired' parsed_version='2.2.0' error=None` (carrier still
   fires; BASE identical); candidate feed title `v2.2.00` → `verdict=None parsed_version=None
   error='non-canonical version token: feed has no canonical stable X.Y.Z entry'`; candidate row
   anchor `v2.02.0` → `verdict=None parsed_version=None error='non-canonical version token: row
   anchor or observation; no verdict written'`. BASE on feed `v2.2.00` → **`verdict='fired'
   parsed_version='2.2.00'`** (a fired verdict written from a non-canonical token).
5. C2 blast radius around S012’s feed S034 (table untouched except where stated):
   - G1 vault derived group lowered (S013,S022,S023,S024 → `2.1.0`/`2.1.0`/`not-fired`, receipt
     mirrored): exit 1, `DERIVATION S013/S022/S023/S024` **exactly**, **S012 errors NONE**, S012
     still fired (`fired=3`).
   - J1/J2 S034 anchor cell edited to name two versions / the `sdk/v0.26.0` module tag: exit 1,
     same four `DERIVATION`, **S012 errors NONE**.
   - J3 S034 cell without the `v` prefix: exit 0 CLEAN, derived rows still bind.
   - K1 derived row S013 raised to `2.3.0` (receipt mirrored): S012 turns `REGRESSED` **identically
     at BASE and candidate** → pre-existing shared-feed floor coupling
     (`corpus/release-clock.py:440` `feed_floors`), not introduced by C2.

## Candidate code cited
`corpus/release-clock.py:395` `non_canonical_version` (series text `v1.21.x` is never a token →
never flagged); `:388` `VERSION_COMPONENT_MAX_DIGITS = 18`; `:418` `numeric_version`; `:349`
`derived_anchor_bound` + `:345` `STABLE_TOKEN_RE`; `:617`/`:625`/`:631` evaluate branch
(`DERIVATION`, `NON-CANONICAL`); `:679-680` receipt-error branch → `NON-CANONICAL`; `:784`
`newest_stable`; `:870-872` observe guard (“no verdict written”). BASE: `base/corpus/
release-clock.py:369` `numeric_version`, `:715` `parse_latest_version`, `:767` `observe_one`.

## Findings by severity
- **PASS (no defect) — carrier.** Nothing in the candidate makes S012 invalid: control `fired=3`
  with `S012 errors: NONE` (candidate = BASE); every bad-input variant on the S012 row yields
  exactly one typed error (`NON-CANONICAL S012`), exit 1, no `Traceback`, and S012 leaves the
  fired count (`fired=2`) instead of being counted as a fired release; the observe path writes
  no verdict and no `parsed_version` for a non-canonical token.
- **LOW — calibration fragility (registry prose can invalidate derived rows; S012 unaffected).**
  `derived_anchor_bound` (`corpus/release-clock.py:349`) reads the S034 anchor cell as the *set*
  of stable X.Y.Z tokens it names, so one added version or module tag there makes every derived
  row of that feed unsatisfiable with no table edit (J1/J2 → `DERIVATION S013,S022,S023,S024`;
  BASE: exit 0 CLEAN). The lane’s own S034 row already carries `sdk/v0.26.0` in the teaches cell
  (`corpus/SOURCES.md:40`), so moving that prose into the anchor cell would break four clock
  rows. Deliberate (selftest case “derived anchor needs one version in cell”); S012 stays valid
  in every variant, so it does not falsify the carrier.
- **INFO — spec-wording deviation.** The plan says “components beyond CPython’s int-string
  conversion limit”; the candidate caps at 18 digits (`corpus/release-clock.py:388`), so a
  legitimate 19-digit component is refused as `NON-CANONICAL` (selftest case “nineteen-digit
  component refused”). Lane-chosen, documented bound; no real release affected.

## Residual risk / verification gaps
- The real vault feed was **not** re-fetched (no network): S012’s `2.2.0` and the “newest stable”
  claim come from `corpus/SOURCES.md:40` + the retained receipt → live-feed freshness unproven.
- I did not run the frozen `c1-measure.py`/`c2-measure.py` tools or the F1–F4/G1–G4 ids (other seats); I drove `corpus/release-clock.py` directly with mirrored receipts.
- The derived-series-anchor branch (`version_is_named` path, `:358`) has no live instance — all 15
  `derived:` rows carry strict X.Y.Z; only the selftest fixture anchor exercises it.
- **Not checked:** claim-ledger pins, SKILL.md/PROVINCE.md text, round-28 census, and every
  row/feed other than S012 and S034’s group. No production edit; scratch exports and probe
  receipts (`probe*.txt`) live only under `/fast/scratch/hyaku/kagi-r28/FSeriesControl/`.
