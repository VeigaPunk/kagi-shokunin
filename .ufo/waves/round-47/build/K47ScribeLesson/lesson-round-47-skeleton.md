# Draft — skeleton for `corpus/lessons/round-47.md`

Section order copied from `corpus/lessons/round-46.md` (heading, frozen-plan line, `## Claims`,
`## Gate`, `## Mistakes`, `## Errata`, `## Amendment notes`, `## Routed`, `## Frontier`,
`## Assimilation`, `## considerthese`). Every `<L1: …>` is a value this seat did not measure — no
number below is invented. The sections this seat can ground (Mistakes rows, Errata entries,
considerthese) are drafted in full in the sibling files.

```markdown
# Round 47 — <L1: one-line title naming C1 calibration and C2 freshness outcomes>

Frozen plan: `plans/round-47.md` (predeclaration `<L1: hash>`; BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`).
Counters `plans/round-47-c1.sh`, `plans/round-47-c2.sh`; pre-freeze controls `plans/round-47-controls.py`
(17 controls, `<L1: receipt line>` from `.ufo/waves/round-47/controls/controls-prefreeze.txt`). Build
wave: `.ufo/waves/round-47/build/` (12 seats, run-15 band 8–16). Final receipts:
`.ufo/waves/round-47/final/`. No predicate, counter, target or kill rule changed after the freeze.

## Claims

- **C1 calibration — the registry's self-description agrees with the bytes the lane-local census reads.**
  Frozen predicate `C1_CENSUS_CALIBRATION`, target 3. At BASE `bash corpus/sources-census.sh` FAILED with
  three findings (`SC_USEDBY_NOCITE S094`, `SC_USEDBY_NOCITE S099`, `SC_FETCH S099 missing-provenance`;
  `.ufo/waves/round-47/controls/census-start.txt`); `value=0 cleared=0 new=0 intact=1 bound=0`. The change
  appends one `source:` line each to `corpus/lessons/round-43.md` and `corpus/lessons/round-44.md`, adds
  one S099 row to `corpus/source-fetches.tsv` bound to the fleet git blob
  `75dd2612:.ufo/prompts/kagi-round-44.md`, and commits the capture
  `.ufo/waves/round-47/capture/S099.body`. At the candidate `<L1: C1_SELFTEST_KILLS-style receipt line;
  expected value=3 cleared=3 new=0 intact=1 bound=1>`. Kill rules that must be re-read, not assumed:
  value < 3, counter rc 2, or any `-` line in the `git diff BASE candidate` of the two lesson files.

- **C2 freshness — the teaching behind every fired Vault/OpenBao clock re-verified on the served docs.**
  Frozen predicate `C2_FIRED_REVERIFIED`, target 11 over F = S012 S013 S014 S015 S016 S021 S022 S023 S024
  S025 S026. At BASE `value=0 reverified=0 gate=1` and `python3 corpus/release-clock.py` read `fired=13`.
  The change adds `corpus/fired-reverify.tsv` (header `id url observed_release fetched_at capture_path
  sha256 bytes quote_count verdict`) plus the eleven captures under `.ufo/waves/round-47/capture/`; the
  release-clock gate must stay CLEAN (`<L1: RELEASE_CLOCK: … line>`). Named ceiling K2-C: hand-typed
  in-window times over byte-correct bodies score 11 — the independent live leg is what catches it.
  Clocks are re-verified, not re-armed: `corpus/release-clocks.tsv` columns 1–8 must be byte-unchanged
  (`<L1: diff line>`).

## Gate

Sources opened this round (all public GETs; `<L1: observation command, timestamp, receipt sha256>`):

| row | URL | newest stable observed | located quote (≤25 words) | used by |
|---|---|---|---|---|
| <L1: one row per S012–S016, S021–S026 capture, with fetch time and sha256> |

Registry rows touched (old → new; `<L1: state whether any row was added, deleted or re-statused>`):
- `corpus/source-fetches.tsv`: one new S099 provenance row (`<L1: quote, location>`); `<L1: any S012–S026
  column-13 changes — must be none>`.
- `corpus/SOURCES.md`: `<L1: expected none — 102 rows before and after>`.

Discernment sample (`LEARNING.md:42-46`): `<L1: one admit + one reject from this round's decisions, with
the re-opened source and the reason>`. Terminology: this round's independent seat re-fetch is the lane's
live leg, **not** "non-author" — see E47-2 below and M47-2.

## Mistakes

<L1: insert the table drafted in `build/K47ScribeLesson/mistakes.md` — M47-1 number-drift (SCORECARD
miscount, captured-by none, proposed SD10 demonstrated red→green), M47-2 attribution ("non-author" on a
lane-dispatched seat, captured-by `LEARNING.md:42-46`), M47-3 stale-premise (the 2026-10-26 considerthese
fail-open text vs `corpus/release-clock.py:789`, executed).>

## Errata

- **E47-1 (round-46 operability row, `SCORECARD.md:1695`; closure routed 1).** The row says `(8 → 11
  cases)` and cites "cases 9–11"; the committed gate asserts 12 (`f4a33d3d:corpus/claims-declared.sh:122`)
  and case 12 exists (lines 118–121). Correct reading `(8 → 12 cases)` / "cases 9–12". The line is not
  rewritten; the correction is appended to `SCORECARD.md` (text:
  `build/K47ScribeLesson/erratum-scorecard.md`).
- **E47-2 (terminology, closure routed 2).** `corpus/lessons/round-46.md:12` and `:23` call seat
  K46ReviewerLive "the non-author re-observation" / "the non-author seat". `LEARNING.md:43-46`: "A
  subagent the lane dispatched is still the lane." The term is reserved for closure and operator checks;
  round 46's report and lesson stand as committed, and the closure's own live sample is the out-of-lane
  leg for that round.

## Amendment notes (candidate side; no frozen sentence changed)

<L1: per-reviewer notes, as round 46 did — one bullet per routed reviewer/critic finding that needed a
candidate-side reading rather than a predicate change.>

## Routed (named, not claimed this round)

<L1: carry forward, from the round-46 lesson §Routed and this round's reviewer findings — at minimum the
counter amendments still open (mutation survivors, POSITIVE drop, no-op SETUP, PASS-prefix, http/date
legs), the `on-release`-on-a-REJECTED-row rule (D-7), receipt digests bound to committed captures (D-3),
pinned fired anchors (D-6), and any seat finding not landed.>
- S040/S041 ISO recheck: `<L1: state the old → new recheck cell and the cadence>`. The recheck was
  overdue at BASE per `plans/round-47.md` §Non-claim work.

## Frontier

Census before and after: `<L1: scripts/sources-census.sh validate --root … kagi` reading and rc; the
lane-local `bash corpus/sources-census.sh` before/after>`.

## Assimilation

`<L1: staged merge/kagi/ themes, or "None: …">`

## considerthese

<L1: insert `build/K47ScribeLesson/considerthese.md` §Proposed section text — newest file
`considerthese/2026-10-26.md`, proposals 1–4 with their measured state, nothing taken, reason recorded.>
```

## What this seat verified vs what the L1 must still fill

Verified here (commands + outputs committed under `build/K47ScribeLesson/`):
- the gate's case count at three revs and the case-12 block (`case-count-check.txt`, rc 0);
- the 12-case assertion is unchanged at the round-47 BASE `252ef1ca` (`case-count-check.txt`);
- `STABLE_TITLE_RE` behaviour at BASE (executed, `regex-test.txt`, rc 0);
- the absence of any lane gate that cross-checks SCORECARD counts (audited by reading
  `corpus/self-description-sweep.sh:8-31`, `corpus/claims-declared.sh:181,223`,
  `corpus/claim-ledger.sh:80-88`);
- the proposed SD10 fix demonstrated red on the real tree and green with one appended erratum line
  (`sd10-real-tree.txt` rc 1, `sd10-with-erratum.txt` rc 0);
- considerthese inventory, newest file and per-proposal state (`considerthese.md`).

Not verified here (L1's receipts): every C1/C2 claim value, the control matrix, the census readings, the
live captures and their digests, the release-clock gate verdict, the S040/S041 recheck cells, and the
frontier line. This draft deliberately leaves those as placeholders rather than plausible numbers.
