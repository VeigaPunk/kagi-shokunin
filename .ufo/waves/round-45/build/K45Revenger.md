# K45Revenger — routed-item state at the candidate and the M45-1 timeline (round 45, attempt 1)

Seat: revenger (wave `kagi-r45-build`, 11 seats). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`. Read-only seat: `git log/show/cat-file/diff/rev-parse/ls-tree/archive` only; plus
`grep`, `sed`, `python3` reads. No lane file edited; no `git add/commit/stash/checkout/switch/reset/pull/push`;
no mutating `jj`; no `pacman`; no network fetch by this seat; no secret read, no `op://` reference written.

Revisions measured: BASE claim tip `0d0192f63eb5e49826d75af1e5293004dc691a18`; round-45 predeclaration
`307fb50da825d6e6f2b5c7981c71556d35611142`; amendment A1 `c74ca51b9e867ac2d18e92664662f2115705c099`;
candidate `072bb0b` (landed after this seat's dispatch — the assignment said "no candidate exists yet";
the candidate landed while this seat measured, so the present state below is at `072bb0b` and the BASE
readings are reported separately).

Scratch: `/fast/scratch/hyaku/kagi-r45/K45Revenger` (one `git archive` extraction, removed with
`rm -rf -- "$S"`). `/tmp` held only four 12 967-byte `corpus/stamps.tsv` extracts, deleted afterwards.
Tools installed: **none** — no tool install or upgrade was needed, so no pacman transaction was run.

## Full findings

**`.ufo/waves/round-45/build/K45Revenger/routed-state.md`** — the complete table, timeline and command
receipts. Summary of the nine routed items:

| routed item | state |
|---|---|
| D1 wave composition (scribe seat) | CLOSED for the seat (scribe ×1 in the 11-seat registry); OPEN for the deviation-disclosure half (no round-45 report exists yet) |
| D2 stamp migration undercount (M45-1) | CLOSED — erratum E45-1 at `corpus/lessons/round-45.md:40` + red witness `build/K45ExecStampRW/receipts.txt` (drift 0 clean / drift 1 on two altered copies) |
| D3 red-witness label | CLOSED — E45-2 at `corpus/lessons/round-45.md:41`; the round-44 line is not rewritten |
| D4 mistake classes outside the vocabulary | **OPEN** — the round-45 lesson maps the round-44 classes to the §5 *proposals* L1–L5 (`corpus/lessons/round-45.md:36`) instead of to the class vocabulary, and its own new rows use out-of-vocabulary classes (`fail-open` at `:33`, `self-description / fixture leak` at `:34`) |
| D5 unopened candidates | CLOSED — `corpus/SOURCES.md:144,152` (bullets, no rows); registry 99 → 102 with only S100–S102 |
| B1 battery always-refuse conjunct | OPEN (carried, named, not claimed) — `plans/round-44-c1.sh:186–187` untouched; no round-45 receipt exercises the blanket leg |
| round-40 report erratum | OPEN (owed; fleet-root file, outside the lane's write scope) |
| revenger SEAT-STATUS line | OPEN for round 44 (`K44RevengerDrift.md` has 0); **recurring in round 45** — 8 of the 9 round-45 seat reports carry no `SEAT-STATUS` line; this seat's report carries one |
| `corpus/controls-replay.sh` scheduling | OPEN (operator scope, refused) — no crontab, no timer, only invoker is `plans/round-43-c2.sh:55` |

**M45-1 timeline (the substantive addition this round).** The drifted stamp set grew in two steps, both
in round 43: `542885e` (three gate scripts) and **`65f66e1`** ("round-43: C1-C3 integration"), which
changed `LOG.md`, `SCORECARD.md`, `corpus/QUALITY.md` and `corpus/SOURCES.md` while touching
`corpus/stamps.tsv` **zero** times (`git show --stat 65f66e1 | grep -c stamps.tsv` → 0). So the four
document rows were stale **before round 44 began**, and the round-44 migration record's "motivating
change" column (`.ufo/waves/round-44/controls/stamp-migration.txt:11–14`, "round-44 … appended")
misattributes them to round 44. The re-pin that closed all seven rows is **`92c394c`** (round-44 landing,
M44-10); `0d0192f`, `307fb50` and `c74ca51` all read drift 0; the round-45 candidate `072bb0b` re-pinned
the six rows this round changed and also reads drift 0. Measured per-file at BASE `0d0192f`: `LOG.md`
last changed `92c394c` / stamp row `92c394c`; `SCORECARD.md` `92c394c` / `92c394c`;
`corpus/QUALITY.md` `0ad617a` / `92c394c`; `corpus/SOURCES.md` `0ad617a` / `92c394c` — all in step; at the
candidate all four are `072bb0b` / `072bb0b`.

**Path correction.** The assignment lists `corpus/LOG.md`; that file does not exist
(`git ls-tree HEAD -- corpus/LOG.md` → empty). The lane's log is root-level `LOG.md` and that is the
stamped path (`corpus/stamps.tsv:113`).

**Live-worktree observation.** At 18:05 the working tree read `STAMP_DRIFT: rows=123 drift=1 / DRIFT
corpus/SOURCES.md` — an uncommitted `corpus/SOURCES.md` edit against a stale stamp row, i.e. the M45-1
class reproduced mid-round and closed by the candidate's re-pin. Worth the L1's attention for the next
round: any pre-landing edit to a stamped file reproduces the drift.

**Surviving defects named by this seat** (all evidence-backed, all in the routed set or in the plan):
1. **D4 not discharged, and the substitute breaks the same rule** — `corpus/lessons/round-45.md:33,34`
   class strings `fail-open` / `self-description / fixture leak` are outside CORPUS.md:171–178's
   vocabulary; the mapping at `:36` targets the §5 lesson proposals, not the vocabulary.
2. **E45-1 names the count but not the cause** — `corpus/lessons/round-45.md:40` records seven stale rows
   at `d54109d` but not that the four document rows went stale at `65f66e1`; a reader would still
   attribute them to round 44.
3. **Round-44's migration record's attribution is wrong** — `.ufo/waves/round-44/controls/stamp-migration.txt:11–14`.
4. **QM47 recurrence** — 8 of 9 round-45 seat reports have no `SEAT-STATUS` line (only `K45ScribeEntry.md`
   does); the round-44 revenger report still has none.
5. **No sentinel output** — no `K45Sentinel*` file exists under `.ufo/waves/round-45/build/`, though the
   seat is in the registry and in `build-spec.json` (11 items).
6. **S099 tier reservation (closure §5 item 8) unaddressed** — the row is still tier A `own-work`
   (`corpus/SOURCES.md:106`); the round-45 lesson mentions S099 only as the renumber boundary
   (`corpus/lessons/round-45.md:20,22`); no `supersedes S099 —` row and no tier justification exists.
7. **New id-space collision created by the landed renumber** (independently measured by this seat).
   A1-8 promised "the registry's next free id is taken after the append is composed, so no
   staged-reserved id is reused" (`plans/round-45.md:124`). The landed rows took **S100, S101, S102** —
   and the staged package already holds S100/S101/S102 for *different documents* (staged S100 =
   betterleaks `main` tree, S101 = betterleaks `v1.x` tree, S102 = GB/T 17901.1-2020 采标情况). Re-running
   the §6 grep pair at the candidate: registry ids 102, staged ids 172, **collisions 51** — the three
   new collisions are exactly S100, S101, S102 (`comm -13` of the HEAD collisions and the now-collision
   set = `S100 S101 S102`). The lesson's Gate still says "48 staged ids collide with lane ids
   (S052–S099)" (`corpus/lessons/round-45.md:22`), i.e. the landed count is under-stated by the round's
   own three rows, and the true next id outside **both** the registry (S001–S099) and the staged package
   (S052–S223) is **S224**. A future round admitting staged S100/S101/S102 must renumber again; the
   collision guard itself works (it caught this) but the lesson's count was frozen at the pre-append
   48. The scout named the same fact (`build/K45ScoutSources/report.md` §6b-i); it is not carried into
   the lesson's Gate, so the round's own record understates the collision set by three.

**Independently verified this round (not re-derived, read at the named revisions):** the C1 bijection
gate is present at the candidate (`corpus/claims-declared.sh` +46 lines at `072bb0b`), the C2 knowledge
entry landed (`corpus/knowledge/iso-11770-3-edition-status.md`, 65 lines) with three located quotes
(S100/S101/S102 → `corpus/quote-bodies.tsv`, `corpus/source-fetches.tsv`), and the A1 locator-rc gate
(`plans/round-45-c2.sh`: `value` now also requires `locate_rc -eq 0`) is in place. The peer seats'
independent reference gate reads C1 `value=2` and C2 `value=3` at the candidate
(`build/K45MutBattery.receipts/ref.txt`, `build/K45ExecBijection/receipts.txt`). This seat ran **no**
counter, gate or claim-ledger verify, and asserts none of those numbers as its own measurement.

**Collision / quarantine check (carried forward for the L1, not re-run here):** 48 staged ids collide
with lane ids S052–S099 (`build/K45ScoutSources/collisions`, 48 lines); the cited staged ids S159/S170/S171
are above the lane's S099 ceiling and were renumbered to S100/S101/S102; the quarantine slice
(S053, S071, S081, S090, S091, S093, S108, S113) is not cited by the admitted entry and was not appended
(`corpus/lessons/round-45.md` §Gate). The first free id outside both the registry (S001–S099) and the
staged package (S052–S223) is **S224** — the plan's "S100 onward" wording overlaps the staged range
(critic D-2 raised this); the landed renumber avoided it by taking S100–S102, which are inside the staged
range but are exactly the ids the renumber map records as taken. Worth one explicit line in the report.

Report: .ufo/waves/round-45/build/K45Revenger.md
