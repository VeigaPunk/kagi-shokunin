# K47ExecS040 — S040/S041 overdue recheck; S027/S028 successor chain

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`, predeclaration
`b020d978bac91284a431710148ebb7a7950eaab8`. Measured 2026-11-06. Non-claim curation: proposal only; the L1 applies the
cells and logs old→new.

## Proposal (old → new)

| id | cell | old | new |
|---|---|---|---|
| S040 | `recheck` | `2026-11-05` | `90d` |
| S041 | `recheck` | `2026-11-05` | `90d` |

`status` stays `mined` (both are cited by `corpus/lessons/round-26.md` line 1 `source: S039, S040, S041`, which is the
contract's `mined` definition and what keeps that lesson's citation passing `SC_ENTRY_CITE`); `opened` `2026-10-21` and
`used-by` `corpus/lessons/round-26.md` stay (rule 2: only status/recheck/used-by are mutable in place; a re-open is
recorded in the lesson, not in `opened`). Rule quoted in `proposal.md` §2.

Why `90d`: the live successor rows S095/S096 (opened 2026-11-05) both carry `90d`; `on-release` is falsified — the
S040/S041 clock rows were retired in round 46, and a scratch counterfactual setting both rows back to `on-release` makes
`python3 corpus/release-clock.py` exit 1 with `UNBOUND S040` / `UNBOUND S041` (`RELEASE_CLOCK: FAILED (… unbound=2 …)`).
Re-arming clocks is also forbidden by C2's kill rule. `90d` due = 2027-01-19.

## Live re-open (independent live leg), 2026-11-06T19:34:32Z

| row | url | http | bytes | sha256 | served title |
|---|---|---|---|---|---|
| S040 / S095 | https://docs.python.org/3/library/re.html | 200 | 257722 | `29fca9b710ae0c857165f68a8c8e62587862c979e1fe4135037a397a8cdf7cf1` | Python 3.15.2 documentation |
| S041 / S096 | https://docs.python.org/3/library/html.html | 200 | 20100 | `388321714e199e3a93849040754819d21b7ca9b36a5c17748a7218e8f300e615` | Python 3.15.2 documentation |

- S040 column-13 quote → `RENDERED_TEXT_V1_LOCATE: count=1`, rc 0; S041 → count=1, rc 0.
- S095/S096 column-13 quotes are `raw-literal-v1` (tag-bearing): rendered-text locate count=0 rc 1 *by construction*
  (normalizer removes tags); the same strings occur once as raw fixed strings, the inner rendered text locates count=1,
  and the recorded raw offsets hold (re 75897, html 13521).
- Fresh bodies differ from the committed 2026-11-05 captures only in the footer timestamp
  (`Last updated on Nov 05, 2026 (12:47 UTC).` → `Nov 06, 2026 (17:47 UTC).`), same byte counts; rows declare
  `decoded-http-body-volatile-v1`.

## Scratch gate test (git archive of BASE; three named gates, rc + last lines)

| gate | BASE copy | proposal copy |
|---|---|---|
| `bash corpus/sources-census.sh` | rc **1** · `SOURCES_CENSUS: FAILED (findings=3 rows=102)` | rc **1** · same line |
| `python3 corpus/release-clock.py` | rc **0** · `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` | rc **0** · same line |
| fleet `sources-census.sh validate --file <copy>/corpus/SOURCES.md` | rc **0** · `file<TAB>ok<TAB>…/lane-base/corpus/SOURCES.md` (19 W04) | rc **0** · `…lane-prop…` (19 W04) |

Finding sets are identical between copies (diff empty; three pre-existing C1 findings S094/S099, untouched by this item).
Supporting read: fleet `overdue` at BASE rc 1 with `S040 1d` / `S041 1d`; on the proposal rc 0 with `cadence S040
recheck=90d` / `cadence S041 recheck=90d`.

## S027/S028 successor chain

S027 (mined, `on-release`, fired feed clock 3.15.0→3.15.2, used-by round-24.md) ← S040 (mined, supersedes S027, used-by
round-26.md) ← S095 (mined, opened 2026-11-05, supersedes S040, `90d`, used-by round-40.md); S028 ← S041 ← S096 mirrors it.
Every `used-by` file exists and names the id on its `source:` line (census reports nothing for these ids); every link's
`teaches` opens `supersedes S<prev> —`; clock rows exist only for S027/S028 (fired, bound, pinned round-46 receipt) —
S040/S041 retired round 46, S095/S096 make no clock claim. Two append-only observations, no gate finding: the S027/S028
clock note still says "rearmed successor S040 carries its own named 3.15.1 anchor" (true of the registry anchor; the feed
clock is retired, as SKILL.md:48 / PROVINCE.md:75 already say), and both superseded rows' anchors name 3.15.1 while the
served title is 3.15.2 — the successor rows carry the current identity.

## Files

- `.ufo/waves/round-47/build/K47ExecS040/proposal.md` — cells, quoted rule, cadence justification, chain check, lesson draft.
- `.ufo/waves/round-47/build/K47ExecS040/receipts.txt` — every command, rc, last line, diffs, offsets.
- `.ufo/waves/round-47/build/K47ExecS040/receipts/` — raw census/clock/validate/overdue outputs, fresh bodies, locate transcript.

## Risks / blockers

- Risk: the lesson old→new log (proposal §7 draft) must be appended by the L1; without it the in-place change violates
  rule 2. No blocker: the three named gates were run in scratch only, and the proposal's census stays at the three
  pre-existing C1 findings until C1's own edits land in the same candidate.
- No lane file was written; no git mutation; no host/package change; scratch copied then removed.

SEAT-STATUS: complete
