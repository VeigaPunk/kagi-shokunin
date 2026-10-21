# CritC2Rollback — round-27 C2 critic (rollback, yank, cropping, backport-first, prerelease anchors)

Seat: `KagiR26.CritC2Rollback-17` (critic, leaf, read-only). BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`
(confirmed `git rev-parse HEAD`). Nothing was executed: no selftest, no `c2-measure.py`, no gate, no network.
Every behavioural claim below comes from reading the code statically. Wherever I say a check would return X,
that is my reading of the code, not an observed run. BASE code was read through `git show HEAD:<path>`, and
copies are in `.ufo/waves/round-27/sandboxes/CritC2Rollback/`. The in-flight L1 draft is the uncommitted
working-tree `corpus/release-clock.py`, cited as **WT**.

## Verdict

C2's REGRESSED rule is sound for the case it orders: an observation below a numeric anchor. It correctly
turns stale-feed, cropped-feed and rolled-back-feed readings into a refusal instead of a release event. Most
of the false alarms (legitimate yank, feed cropping, a dev-label anchor) are **acceptable as findings**.

The plan and the draft still **overclaim on "un-fire"**. A fired predecessor whose feed rolls back to
*exactly its anchor* is still un-fired. The evaluator accepts that row as valid, and `--observe` types it
`not-fired`, not `regressed`. The draft selftest named "downgrade un-fire refused" does not test an
un-fire at all, and its "red-before: accepted CLEAN" provenance is false for that case. Both problems are
fixable without new sources. Neither is a tradeoff the judge must reject.

## The concrete attack: return-to-anchor un-fire

**Counterexample.** Use the real Python rows. S027 and S028 are anchored at 3.15.0, observed 3.15.1, and
`fired` (BASE `corpus/release-clocks.tsv:24-25`). Suppose the vendor withdraws the 3.15.1 item, so the
newest stable item in the feed is 3.15.0 again.

- **WT `observe_one` (`corpus/release-clock.py:762-767`):** it computes `is_regression("3.15.0", "3.15.0")`,
  which is False. The versions are equal, so the receipt verdict is `not-fired`, and the summary prints
  `regressed=0`. The prior fired observation 3.15.1 is available in `values["observed_version"]`, because
  `run_observe` builds `values` from the table row (BASE `:809`). The rule never consults it.
- **WT `evaluate` (`:542`, then the BASE branch `:527-528`):** a row "anchor 3.15.0, observed 3.15.0,
  not-fired" is valid. Its anchor is named at BASE `corpus/SOURCES.md:33` ("Python 3.15.0
  documentation"), so the row counts as observed with fired+0. This state cannot be refused without
  history, because it is byte-identical to S027's legitimate round-25 state.
- **Instrument masking.** `c2-measure.py`'s `rollback` fixture
  (`.ufo/waves/round-27/tools/c2-measure.py:9-11,27-28`) bundles four changes: the S027/S028 un-fire *and*
  the S040/S041 below-anchor lies. After the fix the run fails only because S040 and S041 are REGRESSED. I
  infer that `regressed_findings` will be `[S040, S041]` and S027/S028 will still be counted as observed
  and valid. `accepted_clean` is whole-run (`:76`), so the fixture reports a refusal without showing that
  the un-fire itself survives. A fixture that changes only S027 and S028 to 3.15.0/not-fired, with a
  matching receipt, would end CLEAN with fired dropping from 3 to 1. I did not run this; it is a static
  reading.

**Overclaimed text.**

| Location | What it claims | Why it overclaims |
|---|---|---|
| `plans/round-27.md:26-29` | The Before case lists "(or un-fires an already fired predecessor)" among the cases the After fixes. | The After only orders against the anchor. |
| WT `corpus/release-clock.py:544-545` | "never an un-fire of an earlier anchor" | The un-fire in M27-1 is S027 *at* its earlier anchor, and this branch does not cover it. |
| `corpus/lessons/round-27.md:85` (M27-1) | Credits the rollback fixture's exit 1 as the fix for "S027/S028 silently un-fired". | The exit 1 comes from S040/S041. |
| `corpus/QM25` (WT `corpus/QUALITY.md:132`) | "never an un-fire of an earlier anchor" | Grammatically this is scoped to "an observation older than its numeric anchor", so it is narrowly true. A reader of M27-1 will take it broadly. |

**Why the real live feed partly hides this.** The captured S039 body is a 10-item recency window
(`.ufo/waves/round-26/captures/S039.body`: 3.14.9, **3.15.1**, 3.16.0a1, install manager 26.4, **3.15.0**,
3.15.0rc3, 3.11.17, 3.10.22, 3.12.15, 3.14.8, newest first by pubDate). Cropping drops the oldest items
first, so it cannot leave 3.15.0 visible while removing 3.15.1. [INFERENCE: this relies on the window
staying ordered by recency, which I saw in one capture.] Only a vendor withdrawal of the successor release
produces the return-to-anchor state. In that case S040/S041, anchored at 3.15.1, go REGRESSED in the same
run, so a real whole-run observation is not CLEAN today.

The hole is exposed for any fired row that has no higher-anchored successor on the same feed. S012 is one:
anchor `v1.21.x`, observed 2.2.0, fired (BASE `release-clocks.tsv:9`). If Vault withdrew 2.2.0, the newest
stable would be 2.1.x. Inequality with the non-numeric anchor says `fired` at 2.1.x, which is a lower
version recorded as a release. After a table/receipt refresh this is accepted CLEAN.

## Second defect: false red-before provenance in the draft selftest

WT `:1028-1034` says "red-before: both lies were accepted CLEAN at round-26 BASE". The second case is
`fixture_row(anchored="1.2.3", observed="1.1.9", verdict="not-fired")`. At BASE, a `not-fired` verdict
whose observation differs from the anchor falls to the `else` branch and is **INCONSISTENT**, exit 1
(BASE `:527-531`). BASE's own "wrong verdict" case already pins that branch (BASE `:966`; `fixture_row`
defaults at `:840-843`). So this case was refused before the fix, and only its error tag changes. It is
also not an un-fire, which would be fired→not-fired at the anchor. Only "downgrade fired lie refused"
(WT `:1030`) is genuinely red at BASE. The BASE `c2-before.json` `lie` result agrees: S040 fired at 3.15.0
was CLEAN, exit 0.

## When REGRESSED is a false alarm, and whether that is acceptable

| Scenario | Vendor state | WT result | False alarm? | Acceptable as a finding? |
|---|---|---|---|---|
| Feed cropping: a security batch (3.10–3.14 plus prereleases plus install manager) pushes 3.15.x out of the 10-item S039 window | No regression | S027, S028, S040 and S041 all REGRESSED (3.14.x is below 3.15.0) | Yes, about the vendor; no, about the observation | **Yes.** At BASE this read `fired` at 3.14.x, a fake release event. A refusal is the honest result. The draft's wording ("stale/cropped/rolled-back feed") correctly does not blame the vendor. Lesson Gate `round-27.md:27` already rejects "the feed is complete". |
| Backport-first ordering (first item 3.14.9) | No regression | Not affected. `parse_latest_version` takes the maximum over all entries (BASE `:654-699`), not the first entry. | No | Not applicable. This is already covered by M26-2 (BASE `lessons/round-26.md:91`). |
| Legitimate yank of the anchored release (for example, SOPS v3.13.3 tag deleted, derived anchor S008–S011) | Real withdrawal | REGRESSED, exit 1 | Not a false alarm. The anchor names a version that no longer exists. | **Yes**, but there is a liveness gap. No table state can record "anchor withdrawn". The only path is a QM24-style successor or re-anchor row. The default gate is unaffected, because it reads the pinned retained receipt (`DEFAULT_RECEIPT_SHA256`, BASE `:28`). This gap should be named, not fixed. |
| Prerelease or dev-label anchor bound non-derived (S029's anchor text "curl 8.23.1", BASE `SOURCES.md:35`; curlver `8.23.1-DEV`, BASE `lessons/round-25.md:103-104`) | Not yet released | `version_is_named` accepts 8.23.1 because `-` is outside its lookahead class (BASE `:341-346`). Then (8,23,1) > 8.23.0 gives REGRESSED. | Partly. Under SemVer §11.3, 8.23.0 < 8.23.1-DEV, so the ordering is right, but the cause is "not released yet", not regression. | **Yes.** The lane already escapes this with a `derived:` 8.23.0 binding (BASE `release-clocks.tsv:26`). Comparing cores strictly is sound for prerelease anchors: if the core is lower, the version is lower whatever the suffix. That is an optional future widening, not required. |
| Return-to-anchor un-fire (the attack above) | Successor withdrawn | Accepted as `not-fired` | No, the opposite: a **missed** regression | **No.** This is silent acceptance, and it is the defect above. |

Minor issue: WT `:542` puts `if is_regression(...)` *before* the INCONSISTENT checks, using `elif`. A
non-derived row with an unnamed or bogus anchor, a bad date, or a bad verdict that is also below its anchor
reports only REGRESSED. The binding defect is then hidden behind a "re-verify the feed" finding. Exit 1 is
preserved, so this is diagnostic precision, not a pass.

## Smallest safe correction

1. **Use the recorded observation as an observe-time floor.** This touches one line of code and adds one
   selftest case. In WT `observe_one` (`:762`):

   ```python
   if (is_regression(values["anchored_version"], parsed_version)
           or is_regression(values.get("observed_version", ""), parsed_version)):
       receipt["verdict"] = "regressed"
   ```

   - `.get` is required because the direct `observe_one` selftest calls pass no `observed_version` (BASE
     `:1314-1318`). `numeric_version("")` already returns None.
   - Rows that are not fired have observed equal to anchored, so they are unchanged. The existing recapture
     selftest uses a table row with `observed=1.2.3` (BASE `:1423`), so it is unchanged.
   - This catches S027/S028 going from 3.15.1 back to 3.15.0. It also covers S012, where the anchor is
     non-numeric but the recorded 2.2.0 is numeric, so the declared-limit population shrinks.
   - New case: `observe_one` with anchored 3.15.0, `observed_version` 3.15.1 and a feed body containing
     only v3.15.0 must be `regressed`. My static reading is that WT returns `not-fired`.
   - The evaluator does not change. A hand-edited table plus a hand-built receipt under explicit
     `--receipt-sha` stays self-attested, which is the existing posture.
2. **If (1) is not taken, narrow the text instead** (the overclaim rejected):
   - Plan line 27: the parenthetical becomes a limit.
   - WT comment `:544-545`: change to "never an un-fire *by an observation older than the anchor*".
   - M27-1: credit the rollback refusal to S040/S041 REGRESSED and state that the S027/S028 return-to-anchor
     un-fire is undetected, because no monotonic history exists. This matches the round-26 FinalRearm text,
     BASE `lessons/round-26.md:230-237`.
   - Lessons Limits (`round-27.md:92-94`): add the return-to-anchor case.
3. **Either way, fix the selftest provenance.** Rename WT `:1032` to say what it tests (a below-anchor
   not-fired row, previously INCONSISTENT and now REGRESSED). Limit "red-before" to the fired-lie case.
4. **Optional diagnostic precision.** Evaluate REGRESSED in addition to the INCONSISTENT checks rather than
   as an `elif`.

Axes:
- **Freshness:** improved by (1), and no axis is harmed. The live default CLEAN30 is untouched because
  `evaluate` is unchanged. [INFERENCE: not run.]
- **Calibration:** improved by (2) and (3), which remove false provenance and an un-fire claim the code
  does not deliver.

## What I did NOT check

- I ran nothing: no selftest, no `c2-measure.py` before or after, no gate. The `regressed_findings`
  expectations above are static readings. Unrun checks are not passes.
- I did not fetch any live feed. The 10-item window is seen in one round-26 capture of python.org. I did
  not verify GitHub `releases.atom` window size or ordering; no S033–S035 body is retained in the lane.
- I found no real-world precedent for python.org, Vault, OpenBao or SOPS withdrawing a release.
  Withdrawal scenarios are hypothetical [INFERENCE].
- I read only the WT draft lines in the diff hunks. The draft may change after this review.
- I made no C1 review and no SemVer §11.3 or §11.4 source verification beyond the S042/S043 rows as
  registered.
- No tools were installed or updated.
