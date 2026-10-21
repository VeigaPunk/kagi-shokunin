# RevInequality: why round 25 fired on observed ≠ anchor, and whether regression was weighed

Lane `kagi-shokunin` · Base `0a47dd189356ea66ec83c3891eed54526e95b89b` · Axes: calibration, freshness · Seat `KagiR26.RevInequality-17` (leaf; lane-authored advice, not non-author closure).

Conventions. `path:line` is BASE unless tagged **WT** (working tree: uncommitted round-27 edits that changed while I read them). **UNRUN** means traced from source, not executed. Every BASE line was checked with `git show 0a47dd18:<path>` or against the BASE extract in my sandbox (§10).

## 1. Answer

1. **Round 25 meant "fired" as an identity change, not a release.** QM23, listed among round-25 landings (`LOG.md:1380–1381`), defines an on-release clock as naming "one observable release identity … and is observed"; a fired clock "is re-verified in the lesson" (`corpus/QUALITY.md:120`). The planner's spec encoded it as `fired iff observed_version != anchored_version for feed` (`.ufo/waves/round-25/build-spec.json:25`). The code does exactly that: fired iff `observed != anchored` (`corpus/release-clock.py:524–525`); the observer writes `not-fired` iff equal, otherwise `fired` (`:728–734`).
2. **The seats were told, and wrote, forward motion.** All 28 per-row clock prompts ask for "verdict fired (feed moved past the anchored version)" (`build-spec.json:105, 110, … 240`; 28 hits). Seat prose says "after the anchor", "newer", "max > recorded observed_version" (§4). Prompts and checker disagree on direction. No artifact reconciles them.
3. **Regression was not considered and rejected as a verdict condition.** Apart from one case, no round-25 artifact considers "observed below anchor" as a verdict. A1 (`.ufo/waves/round-25/build/ClockS021.md:34`) notes that a backport taking "latest" fires the rule and keeps it as a fire ("false positive; re-verification absorbs it"); it is never analysed or refused. Directional comparators were proposed, but only in the forward sense. Negative evidence: every feed fixture in the BASE selftest has observed ≥ anchor (`corpus/release-clock.py:952, 966, 988, 1016–1020, 1326–1328, 1431`), and the five falsifier reports that address direction all ask about a newer or greater release (`.ufo/waves/round-25/falsify/FClockS009.md:54`, `FClockS021.md:51`, `FClockS022.md:28`, `FClockS026.md:22`, `FClockS029.md:26`). The limit is first named in round 26 (`corpus/lessons/round-26.md:230–233`; `.ufo/waves/round-26/residual/FinalRearm.md:12, 32–48`).
4. **Latent, not live.** No current BASE row has observed below a numeric anchor: `corpus/release-clocks.tsv` has 30 rows, 19 with a numeric anchor and observed version, and 0 below. The one real observed-below-named-anchor case in round 25 (S029) was resolved by re-anchoring, not by the comparator (§4, A7).

Axis read. **Calibration:** the label overclaims. `fired` is an identity-change predicate, but the surrounding record, the round-26 successor claims, and the SCORECARD "freshness" wording read it as "a newer release exists". **Freshness:** the clock detects that the feed differs from the anchor. It cannot tell a newer release from a lower observation, so its freshness claim holds only if feeds never go backwards. Nothing enforces that.

## 2. Evidence chain at BASE

| # | Stage | Where | What it fixes |
|---|---|---|---|
| 1 | Criterion | `corpus/QUALITY.md:120` (QM23) | identity: "one observable release identity … is observed" |
| 2 | Planner spec | `.ufo/waves/round-25/build-spec.json:25` | `fired iff observed_version != anchored_version for feed` |
| 3 | Seat prompts | `build-spec.json:105–240` (28×) | "fired (feed moved past the anchored version)" |
| 4 | Checker | `corpus/release-clock.py:524–527`, `:728–734` | `!=` / `==` only; no ordering in the verdict |
| 5 | Parser | `corpus/release-clock.py:654–699` (`max` at `:699`) | numeric max over entries; the ordering exists in the same file |
| 6 | Selftests | `corpus/release-clock.py:952, 966, 988, 1016–1020, 1326–1328, 1431` | observed ≥ anchor only; zero downgrade fixtures |
| 7 | Seat rationale | `ClockS015.md:17–18`, `ClockS016.md:39, 43`, `ClockS021.md:8`, `ClockS022.md:9` | "literal" / "exact comparator"; no reason given for `!=` over an ordering |
| 8 | Critic | `.ufo/waves/round-25/build/CritC3.md:5` | asks what "fired" means and whether it is a freshness event; never raises direction |
| 9 | Falsifiers | `.ufo/waves/round-25/falsify/FClockS009.md:54` and four others (§1.3) | newer/greater only |
| 10 | Round log | `LOG.md:1383` | "fired (Vault 2.2.0 past its v1.21.x anchor)": directional wording in the round-25 record |

The lesson records anchor-derivation alternatives explicitly ("Alternatives the seats raised are recorded, not silently chosen", `corpus/lessons/round-25.md:74–79`). It records no comparator alternative.

## 3. Divergences

- **D1 · prompt vs checker direction.** `ClockS029.md:8`: "The feed has not moved past 8.23.1, so the literal verdict is **not-fired**." Anchor 8.23.1 is ahead of the feed (8.23.0). The same row, `S029 feed … 8.23.1 8.23.0 … not-fired`, is listed as the "Rule-literal alternative" (`ClockS029.md:17`). Under BASE that row is refused as `INCONSISTENT` (probe C3, §5). The seat's verdict is directional; the coded rule is not.
- **D2 · identity vs event.** Under QM23's identity model a downgrade is a legitimate re-verification trigger, so BASE's C1 result is consistent with QM23. Under the event model that round 26 adopted, it is a false event. The successors are described as: "A future stable release can therefore fire the successors, not merely leave old fired bits permanently set" (`corpus/README.md:205–207`; see also `corpus/lessons/round-26.md:92`, M26-3, and `corpus/QUALITY.md:126`, QM24, "a later-release fixture must fire the successor"). QM24 tests only the forward direction, which `!=` passes. S040/S041 (`corpus/release-clocks.tsv:30–31`) therefore depend on event semantics the comparator does not implement.
- **D3 · derived anchors.** R25-C8 derives the anchor as the newest stable release at open (`corpus/lessons/round-25.md:71–79`). Combined with `!=`, that means "a release newer than the open-date newest" **only if the feed never regresses**. The lesson admits "past feed states were not retained" (`round-25.md:225–227`). No artifact states the monotone assumption. I grepped the round-25 wave, round-25/26 lessons, plans, QUALITY, knowledge, LOG and SCORECARD for monoton / non-decreas / never decrease / only increase / moves forward: no clock hit. The one "not monotonic" (`ClockS022.md:45`) concerns a different claim. The equivalence is my inference.
- **D4 · cropping.** `ClockS014.md:37` rejected the Atom window because "a burst of submodule tags can push the main tag out of the window". A lower max fires under BASE. The final design binds six OpenBao rows to that same 10-entry Atom feed (S035, `corpus/SOURCES.md:41`; `corpus/release-clocks.tsv:11–13, 18, 22–23`; anchors 2.7.1, derived). `ClockS025.md:58` reasons only that a *newer* tag would sort to the top of the window. `.ufo/waves/round-25/falsify/FClockS023.md:39` treats window rotation as loss of attestation, not as a lower observed max. **UNRUN** (not observed live).

## 4. Was regression weighed? Nearest considerations, and the layer each was decided at

| | Consideration | Where | Layer | Outcome |
|---|---|---|---|---|
| A1 | Backport takes "latest" and fires the rule | `build/ClockS021.md:34` | verdict (Location-tag observer design; not in BASE) | "false positive; re-verification absorbs it": kept as fire |
| A2 | REST `releases/latest` rejected: "`latest` is date-sorted, so a backport can become latest" | `corpus/lessons/round-25.md:96–98`, `:69–70` | source selection | rejected for quota and date order; the proposed flip (semver-sorted listing) would still feed `!=` |
| A3 | Atom window cropping ("burst of submodule tags") | `build/ClockS014.md:37` | source selection | Atom rejected there; Atom adopted for OpenBao later (D4) |
| A4 | `max > recorded observed_version` | `build/ClockS025.md:36` vs `build/ClockS015.md:29` | comparator | declined "to share this rule": a uniformity reason, not a regression reason |
| A5 | "release published after `opened`" | `build/RSourcesContract.md:51` | comparator | not adopted; the derived-at-open anchor (R25-C8) is the nearest adopted form |
| A6 | S023 proposed "fired iff a stable tag newer than the anchored one appears" | `build/ClockS023.md:45` | comparator | not adopted; no reason recorded |
| A7 | S029 named 8.23.1 (`corpus/SOURCES.md:35`) vs observed 8.23.0 | `corpus/release-clocks.tsv:26`; `build/ClockS029.md:16–17` | anchor | re-anchored to derived 8.23.0; a planner decision |
| A8 | Backport `v1.9.99` updated later than `v2.2.0` | `falsify/FFeedParser.md:35, 64` | selection | max-semver wins; the comparator is not tested |
| A9 | Date comparator ("latest GA leaves the line, or dated after the row opened") | `build/ClockS013.md:27` | comparator | proposed; not adopted; no reason recorded |
| A10 | Stale edge copies (58–62 h; cache HIT age ≈ 9.9 h) | `build/ClockS011.md:46`; `build/ClockS017.md:50`; `build/ClockS018.md:28` | rendered-quote freshness | noted; no feed-comparator analysis |

Pattern: every consideration that touched a lower version was decided at the selection or anchor layer, except A1, which reached the verdict and was kept as a fire. Five directional or date-based comparators were proposed (A4–A6, A9, plus the S010 publish-date guard at `ClockS010.md:42`, which is recorded as holding and is not in `release-clock.py`). Only A4 has a recorded reason, and that reason is uniformity.

## 5. Counterexamples

**Executed** (in-process probe; no network; no gate, selftest, or `--observe`). `evaluate()` ran on synthetic rows, with receipts shaped as `observe_one` emits them and passing `receipt_matches`. `observe_one()` ran with `request_body` stubbed to a fixed Atom body. Output: `.ufo/waves/round-27/sandboxes/RevInequality/probe-base-direction.json`. Caveat: the probe bypasses `main()`, `load_receipt_bundle` (`:411`), and the receipt sha pin (`:28`, `:1595–1597`).

| case | anchored | observed | verdict | BASE result |
|---|---|---|---|---|
| C1 downgrade recorded fired | 1.2.3 | 1.2.2 | fired | **CLEAN**, fired=1 (`:524–525`) |
| C2 stale feed falsely fires a successor | 3.15.1 | 3.15.0 | fired | **CLEAN**, fired=1 |
| C3 downgrade recorded not-fired | 1.2.3 | 1.2.2 | not-fired | `INCONSISTENT` (`:529–531`): refused by equality, not by direction |
| C4 return to anchor | 3.15.0 | 3.15.0 | not-fired | **CLEAN**, fired=0: no history input exists |
| C5 control, newer | 1.2.3 | 1.2.4 | fired | CLEAN, fired=1 |
| C6 control, equal | 1.2.3 | 1.2.3 | not-fired | CLEAN, fired=0 |

Observer (`observe_one`, `:728–734`): O1 feed max 1.2.2 vs anchor 1.2.3 → `parsed 1.2.2, verdict fired`. O2 feed max 3.15.0 vs anchor 3.15.1 → `parsed 3.15.0, verdict fired`. O3 control 1.2.3 vs 1.2.3 → `not-fired`.

**Source-traced, UNRUN:**
- CE-W (window): with the 10-entry Atom feed, if the anchored release drops out of the window, `parse_latest_version` (`:699`) returns a lower max and `observe_one` writes `fired`, as O2 does. Six OpenBao rows are exposed now (D4).
- CE-R (stale mirror): an older cached body produces the same result.

C1 and C2 violate event semantics (D2), not QM23 identity semantics. Any report that reads BASE's `fired=K` as "newer releases seen" inherits that error.

## 6. Implications for round-27 C2 (advice; not verified)

- The plan's C2 text (`plans/round-27.md:26–35`, WT; absent at BASE) describes an anchor-only REGRESSED rule. By source, an anchor-only check refuses C1, C2 and C3, and cannot see C4, because equality is not an ordering. FinalRearm's own smallest correction (`.ufo/waves/round-26/residual/FinalRearm.md:46–48`) is anchor-only, so it leaves the predecessor un-fire that its own F1 names (`:34–37`).
- **WT** (uncommitted, still changing when I read it): `is_regression` (`corpus/release-clock.py` WT `:383–387`), a per-feed-URL `floors` check (WT `:567–568`, `:793–794`), and a selftest "return to the anchor after a recorded newer observation was not regressed" (WT `:1455–1456`). That is the history input C4 needs. It is not in the plan text. **UNRUN.**
- S027/S028 and S040/S041 share one feed URL (`corpus/release-clocks.tsv:24–25, 30–31`), so a per-URL floor is shared state. Test it with a successor fixture as well as a predecessor fixture.
- The WT round-27 lesson's M27-1 ("QM23 asks for an observable identity, not an ordered one", WT `corpus/lessons/round-27.md:85`) matches D2. The calibration fix is to say which model `fired` means, or to add the history floor for event semantics.

## 7. Confidence

- **High:** BASE code paths and line numbers; spec and prompt wording; no downgrade fixture in the BASE selftest; probe results C1–C6 and O1–O3.
- **Medium-high:** no round-25 artifact weighs observed-below-anchor. This is search-based (§8 lists the patterns). A miss in wording I did not search is possible. No session transcript is tracked at BASE, so private deliberation cannot be ruled out.
- **Inference, marked:** that QM23 is the reason for `!=` (no written rationale exists; the spec and QM23 are the only written forms); that derived-at-open anchors plus `!=` equal "newer than open" only under monotone feeds (D3).

## 8. Did not check

- No network, no live feed, no lane gate, no default `release-clock.py` run, no `--selftest`, no `--observe`, no `c3-measure.py`, no census, no ledger row. The only execution was the in-process probe in §5.
- The WT candidate was read, not executed, and it was still changing.
- The probe bypasses `main()`, `load_receipt_bundle`, and the sha pin.
- Round-25 L1 planning transcripts: none tracked at BASE. A `git ls-tree` over `.ufo` for jsonl / transcript / session found only round-23 and round-24 files. Commit bodies of `82745e2`, `9b755f5`, and `1bf3eec` are empty.
- Dispatch, refusal, and task-result files: keyword counts only. The one "downgrade" token in `falsify-spec.json` concerns citation layout, not versions.
- Patterns searched across BASE round-25 wave, lessons, plans, QUALITY, knowledge, LOG, SCORECARD: regress, downgrad, rollback, roll back, older/newer/greater/lower/below/behind/earlier, numeric(ally), monoton, non-decreas, never decrease, only increase, moves forward, fired iff, moved past, literal, comparator, max-semver, stale, backport, yank, revert, withdraw, cropp, evict, CDN. Synonyms and other languages were not searched.
- External primary sources (SemVer §11, PEP 440) were not re-opened. This item does not ask for them.
- Window eviction, stale mirrors, and backport-as-latest are source-traced only.

## 9. Tooling and installs

None installed. The probe used the Python standard library with `sys.dont_write_bytecode = True`, so no `__pycache__` was written. Git was read-only (`git archive`, `git show`, `git grep`, `git log`, `git ls-tree`). The index and jj state were not touched; `git archive` wrote only into my sandbox.

## 10. Artifacts (within contract)

- `.ufo/waves/round-27/sandboxes/RevInequality/base/`: read-only BASE extract (240 files). Re-verify any line cite by diffing against `git show 0a47dd18:<path>`.
- `.ufo/waves/round-27/sandboxes/RevInequality/probe-base-direction.json`: probe output (6 gate cases, 3 observer cases).
- This report.
