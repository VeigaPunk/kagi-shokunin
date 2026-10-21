# CritC2NonNumeric — round 27 C2 scope critic (non-numeric/derived anchors, rendered-quote clocks)

Seat: `KagiR26.CritC2NonNumeric-17`, critic, read-only, nothing executed.
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b` (HEAD observed equal). "wt" means
the uncommitted working-tree draft of L1 as read on 2026-10-21; BASE lines come
from `git show BASE:<path>`. Lane-authored advice only; not a judgment or closure.

Axes judged: **freshness** (primary), **calibration** (claim text vs code).

## Verdict

The draft overstates monotonicity. `is_regression` (wt `corpus/release-clock.py:382-386`)
checks one row against its own anchor only, so it is not a monotonic guarantee.
Two consequences survive the after-revision:

1. **Non-numeric S012 is a constant `fired` clock.** It accepts an older Vault
   observation CLEAN, and the output line is byte-identical to the pinned
   R25-04 expectation.
2. **The equal-to-anchor un-fire, the only un-fire path BASE ever had, is
   untouched.** QM25, the code comment and the selftest comment still claim it
   is refused.

A fixable defect, not an unavoidable tradeoff. The table already holds a higher
numeric floor for the same feed URL, and the rule ignores it.

## Concrete counterexample A: S012, older Vault feed accepted CLEAN with fired=3 unchanged

Live row, BASE `corpus/release-clocks.tsv:9`:
`S012 feed S034 https://github.com/hashicorp/vault/releases.atom v1.21.x 2.2.0 2026-10-21 fired …`

Overlay: change only S012 to `observed_version=1.20.0`, `verdict=fired`, and set
its receipt record to `parsed_version=1.20.0, verdict=fired`. Leave S013 and
S022–S024 unchanged. They sit on the same feed URL with numeric anchor and
observation `2.2.0` (BASE `release-clocks.tsv:10,19-21`).

Walking the after code (wt `release-clock.py`):
- `numeric_version("v1.21.x")` → `None` (wt 366-379; `NUMERIC_VERSION_RE` fullmatch fails).
  So `is_regression` → False (wt 386) and the REGRESSED branch (wt 542-547) is skipped.
- `anchor_ok`: not `derived:`, and `version_is_named(anchor, "v1.21.x")` matches
  "newest pinned version v1.21.x" (BASE `corpus/SOURCES.md:18`; matcher wt 341-346). OK.
- `verdict == "fired"` and `"1.20.0" != "1.21.x"` → `row_fired = True` (wt 553-555).
- `receipt_matches`: parsed equals observed, verdict equal (wt 401-421). The
  receipt-level REGRESSED check (wt 587-589) needs `verdict == "regressed"`, and
  `observe_one` never writes that for a non-numeric anchor (wt 762-767).
- Result [INFERENCE, read, not run]:
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`,
  exactly the R25-04 regex (BASE `corpus/claim-ledger.tsv:83`).

Under SemVer §11.2 (S042, wt `corpus/SOURCES.md:49`), 1.20.0 is below every
member of `1.21.x`, and below 2.2.0, which four sibling rows on the same URL
already anchor. This is exactly the plan's own Before defect
(`plans/round-27.md:26-28`: "a stale or cropped feed whose newest stable release
is OLDER than a … anchor reads 'fired' … and is accepted CLEAN"). It stays live
on the one non-numeric production row.

A stronger fact: S012 can never read `not-fired`. Every parser path returns
digits-only `X.Y.Z` (BASE `release-clock.py:649-651`: `STABLE_TITLE_RE`,
`STABLE_TAG_HREF_RE`, `TEXT_VERSION_RE`), and `not-fired` requires
`norm(observed) == "1.21.x"` (wt 556). So S012's verdict is `fired` for any feed
content at all, 0.0.1 included. Its observation carries no information. "Keeps
the inequality rule" (`plans/round-27.md:31-32`, wt `corpus/lessons/round-27.md:75-77`)
understates this: the clock is a constant.

## Concrete counterexample B: equal-to-anchor un-fire (S027/S028), and a false "red-before"

At BASE the only way a row reads `not-fired` is `norm(observed) == norm(anchored)`
(BASE `release-clock.py:527`). A below-anchor `not-fired` row was already
`INCONSISTENT` (BASE 529-531, exit 1). So the only un-fire BASE could accept is
"the observation returned to exactly the anchor". The draft's strict `<`
(wt 386) leaves that path unchanged.

Overlay: S027 and S028 (BASE `release-clocks.tsv:24-25`, anchor 3.15.0, fired at
3.15.1) are set to `observed 3.15.0, not-fired`, with matching receipts. S040 and
S041 (BASE `release-clocks.tsv:30-31`, anchor 3.15.1) stay at `3.15.1 not-fired`.
After code: `is_regression("3.15.0","3.15.0")` is False, and the equality branch is
valid (wt 556-557). Result [INFERENCE, not run]: CLEAN with fired=1 (only S012 remains).
That is a silent un-fire of two fired clocks, while the same python.org feed URL
carries a 3.15.1 anchor in the same table. Only the literal R25-04 `fired=3`
pin differs, and pins are migrated per round (R25-04 itself migrated 28/fired1
→ 30/fired3, BASE `claim-ledger.tsv:83`). So the pin is a count, not a
monotonic rule.

This split is reachable live because `--observe` fetches each row independently,
with no per-URL coherence (BASE `release-clock.py:818-819`, wt 851-852): S027 and
S028 (feed S036) and S040 and S041 (feed S039) are four separate GETs of
`https://www.python.org/downloads/feed.rss`. Inference: a CDN or mirror serving a
stale body to a subset of those GETs produces exactly this bundle. The
whole-feed rollback fixture of M27-1 (wt `corpus/lessons/round-27.md:85`,
`.ufo/waves/round-27/c2-before.json` "rollback", rows S027/S028/S040/S041) is
caught after the change only because S040/S041 go REGRESSED. S027 and S028
themselves are still accepted as valid `not-fired` rows.

Claims this falsifies (duplicate authorities that disagree with each other):
- wt `corpus/QUALITY.md:132` QM25: "…never a fired release **and never an un-fire of an earlier anchor**."
- wt `corpus/release-clock.py:543-545` comment: "…never a release event and never an un-fire of an earlier anchor."
- wt `corpus/release-clock.py:1027-1029` comment: "red-before: both lies were accepted CLEAN at round-26 BASE."
  This is false for the second fixture. "downgrade un-fire refused" (wt 1032-1034:
  anchor 1.2.3, observed 1.1.9, `not-fired`) is `INCONSISTENT` / exit 1 at BASE
  (BASE 527-531). After the change it only relabels INCONSISTENT as REGRESSED, so it is
  not a red-before witness. This is false provenance on a selftest case.
- `plans/round-27.md:28` lists "(or un-fires an already fired predecessor)" as a
  defect that the After (`:29-31`) appears to cure.
- In contrast, wt `corpus/lessons/round-27.md:92-94` Limits ("does not detect a feed
  that silently drops the newest release while still showing an equal or newer
  version") concedes the gap, so lesson and QM25 contradict each other.

## Selftest control that locks the lie in

wt `release-clock.py:1037-1040` "non-numeric anchor keeps inequality" expects
`anchored 1.2.x, observed 1.0.0, fired` to be **CLEAN, fired=1**. Under §11.2,
1.0.0 is ordered below every `1.2.z`, so this is not an "unorderable" control. It
pins a downgrade-reads-fired lie as the expected output, and its note
`"derived: series anchor, not orderable"` is an overclaim. Any later fix has to
flip a passing expectation. An honest control for the inequality-only limit would
be an observation above the series, `observed 1.3.0, fired`, which is a true fire
under either rule.

## Derived anchors and rendered-quote clocks: checked, no defect in the draft's own scope

- **Derived numeric anchors** (S008–S011, S013–S016, S021–S026, S029; BASE
  `release-clocks.tsv:5-8,10-13,18-23,26`) are strict X.Y.Z, so the draft's REGRESSED
  rule applies to them. By their own notes they are "newest stable … when the row
  was opened", meaning prior observations of the same feed. They are therefore
  the soundest floor values in the table (used in the fix below).
- **Rendered-quote clocks** (S005–S007, S017–S020, S030–S032) carry `anchored=-` and
  `observed=-` and never reach `is_regression` (wt 561-572). The plan makes no
  monotonicity claim for them, and none is needed for C2. Their analog of an
  un-fire, `quote-missing` flipping back to `quote-located` on a stale cached page,
  is unguarded. That is outside the C2 claim, and I note it as an undeclared limit,
  not a defect.

## Smallest safe correction

**Required either way (calibration, text only):** remove "and never an un-fire of
an earlier anchor" from QM25 (wt `QUALITY.md:132`) and from the comment at wt
`release-clock.py:545`. Correct the red-before comment at wt 1027-1029: only
"downgrade fired lie refused" is red at BASE; "downgrade un-fire refused" was
INCONSISTENT. Replace the control at wt 1037-1040 with an above-series
observation. Declare in the plan, QM25 and the lesson: "REGRESSED is measured
against the row's own numeric anchor; an observation equal to the anchor un-fires
a fired row CLEAN; non-numeric S012 reads fired on any content."

**Recommended code fix (freshness, closes both counterexamples):** set a per-feed-URL
floor equal to the maximum strict-X.Y.Z anchor over all bound feed rows sharing
that `feed_url`. Key on the URL, not on `feed_source_id`: S036 and S039 are
distinct source ids for the same python.org URL. Then refuse any observation
below the floor, with one rule in place of the own-anchor test:

```python
    feed_floor = {}
    for source_id in on_release:
        matches = by_id.get(source_id, [])
        if len(matches) != 1 or matches[0]["malformed"]:
            continue
        values = dict(zip(HEADER, matches[0]["fields"]))
        core = numeric_version(values["anchored_version"])
        if values["clock"] == "feed" and core is not None:
            feed_floor[values["feed_url"]] = max(feed_floor.get(values["feed_url"], core), core)
    ...
            floor = feed_floor.get(feed_url)
            seen = numeric_version(observed_version)
            if floor is not None and seen is not None and seen < floor:
                errors.add(("REGRESSED", source_id))
                row_valid = False
```

Effect on the counterexamples [INFERENCE, not run]: S012 at 1.20.0 is below the
S034 URL floor of 2.2.0, so REGRESSED. S027/S028 at 3.15.0 are below the python.org
URL floor of 3.15.1, so REGRESSED.

Why this adds no new false positive: if every row on a URL reports one coherent
observation O, and the floor A > O, then the row owning A is already REGRESSED
under the draft rule and the run already exits 1. The floor changes exit status
only when rows sharing a URL disagree about O, which is exactly the split or
edited bundle.

Live default receipt: per-URL floors versus observations in BASE
`release-clocks.tsv` are Vault 2.2.0/2.2.0, python.org 3.15.1/3.15.1 (all four),
SOPS 3.13.3, OpenBao 2.7.1 and curl 8.23.0. CLEAN30 fired=3 should therefore hold
[INFERENCE, not run].

Cost: one selftest case needs a second `on-release` fixture source sharing S002's
URL (the fixture registry at wt 945-956 has only S001 as on-release), which grows
the selftest count by one beyond the draft's 73 (wt `SKILL.md:48`,
`PROVINCE.md:54`). `observe_one` may stay anchor-only; `evaluate` is the gate.

If L1 declines the code fix, the text-only correction above is mandatory. Without
it, QM25 and the code comment certify an un-fire refusal that the code does not
perform.

## Impacted axes

- freshness: S012 and the equal-to-anchor un-fire both leave a stale feed accepted CLEAN.
- calibration: QM25, the code comment and the selftest provenance comment state
  more than the code does; the lesson Limits contradicts QM25.

## Not checked (unrun is not a pass)

- Nothing executed: no selftest, no overlay, and no `c2-measure.py` run. Every
  CLEAN/REGRESSED outcome above is inferred from reading the code.
- Did not read `c2-measure.py`, the round-26 `observe-2.json` receipt, or the
  `CritC2Rollback` / `MutDowngradeBase` / `XC2Measure` outputs, so overlap with
  those seats is not ruled out.
- Did not verify live feeds, CDN behaviour, or whether python.org or GitHub ever
  serve split bodies; split-fetch reachability is inference.
- Did not audit prerelease, two-component or `+build` parsing beyond the three
  BASE regexes cited, and did not check S043 (cited in the lesson, not read).
- Did not check stamps, self-counts or ledger bookkeeping for the selftest count change.

Tooling: none installed or updated.
