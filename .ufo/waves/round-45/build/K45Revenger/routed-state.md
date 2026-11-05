# K45Revenger — routed-item state at the round-45 candidate, and the M45-1 timeline

Seat: revenger (wave `kagi-r45-build`, attempt 1). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`. Read-only: `git log/show/cat-file/diff/rev-parse/ls-tree/archive` only, plus `grep`,
`sed`, `python3` reads. No lane file edited; no mutating git/jj; no `pacman`; no network fetch by this
seat. Scratch: `/fast/scratch/hyaku/kagi-r45/K45Revenger` (one `git archive` extraction, removed with
`rm -rf -- "$S"`); `/tmp` held only the four `corpus/stamps.tsv` extracts (each 12 967 B) and they were
deleted. Revisions referenced: BASE claim tip `0d0192f63eb5e49826d75af1e5293004dc691a18`; round-45
predeclaration `307fb50da825d6e6f2b5c7981c71556d35611142`; amendment A1 `c74ca51b9e867ac2d18e92664662f2115705c099`;
candidate `072bb0b` (landed after this seat's dispatch; measured here).

## (a) Routed items of `corpus/lessons/round-44-verifier-spotcheck.md` §5 — present state

| # | routed item | OPEN / CLOSED | evidence pointer |
|---|---|---|---|
| 1 | **D1 wave composition** (scribe seat) | **CLOSED** (seat) / **OPEN** (disclosure) | `plans/round-45.md:95` names `scribe ×1`; `.ufo/waves/round-45/build/swarm-registry.json:92` `"K45ScribeEntry"` role `scribe`; role census of the 11 members = connector 1, executor 3, reviewer 1, critic 1, mutation-tester 1, scout 1, **scribe 1**, sentinel 1, revenger 1; attack seats 3/11 = 27 %. **OPEN half:** no round-45 report exists (`/home/vgpnk/Projects/shokunin/.ufo/reports/round-45/kagi.md` absent) so the "deviations named in the report's deviation line" half of the closure item is not yet discharged. Also **no `K45Sentinel*` report in `.ufo/waves/round-45/build/`** (sentinel seat has no output as of this measurement). |
| 2 | **D2 stamp migration undercount** → M45-1 | **CLOSED** (erratum + red witness) | erratum **E45-1** landed: `corpus/lessons/round-45.md:40`. Red witness: `.ufo/waves/round-45/build/K45ExecStampRW/receipts.txt` — base archive `drift=0` rc 0 (line 3–5); one byte appended to root `LOG.md` `drift=1` rc 1 `DRIFT LOG.md` (lines 9–11); one sha256 cell flipped `drift=1` rc 1 (lines 16–18). Not a rewrite: `corpus/lessons/round-44.md:36` (M44-10) untouched, `.ufo/waves/round-44/controls/stamp-migration.txt` untouched. **Residual:** the erratum counts the drift as seven rows but does not name the commit that caused the four document rows to go stale — see the timeline below, which pins it to `65f66e1`. |
| 3 | **D3 red-witness label** | **CLOSED** | correction **E45-2** landed: `corpus/lessons/round-45.md:41`; superseded line `.ufo/waves/round-44/controls/amend-a1-redwitness.txt:16` not rewritten (file's last change is still `c70bfb0`); the true reason is named (`git cat-file -e d54109d:corpus/controls-replay.sh` rc 0 → gate present → a valid receipt reads 1 by design). |
| 4 | **D4 mistake classes outside the vocabulary** | **OPEN** (partly discharged; the fix itself breaks the rule) | CORPUS.md:171–178 requires classes from the `mistakes.md` §5 vocabulary (`vacuous`, `survivor`, `stale-premise`, `reference-drift`, `number-drift`, `scope`, `attribution`, `landing`, `provider`); the list is at `/home/vgpnk/Projects/shokunin/.ufo/waves/kaika-w1/mistakes.md` §5. The round-45 lesson carries the mapping in prose at `corpus/lessons/round-45.md:36` ("Vocabulary:" paragraph) — but it maps the round-44 classes onto the **§5 lesson proposals L1–L5**, not onto the class vocabulary the closure asked for ("map each row to the vocabulary (for example `vacuous`, `landing`, `scope`)"), and the round-45 table's **own new rows** use out-of-vocabulary class names: `corpus/lessons/round-45.md:33` M45-2 class `fail-open`, `:34` M45-3 class `self-description / fixture leak`. The scribe's draft had in-vocabulary classes (`.ufo/waves/round-45/build/K45ScribeEntry/lesson-draft.md:39,41,44` → `vacuous`, `scope`, `scope`); the landed lesson dropped them. Round-44's table is not rewritten (correct, append-only). |
| 5 | **D5 unopened candidates → `## Leads (unopened)` bullets** | **CLOSED** | at the candidate: `corpus/SOURCES.md:144` `## Leads (unopened)`, the moved inventory at `corpus/SOURCES.md:152` (one bullet, staged themes listed, no rows written); registry grew 99 → 102 with **only** S100/S101/S102 (`corpus/SOURCES.md:107–109`), i.e. no rows for the staged inventory; `corpus/lessons/round-45.md` §Leads (unopened) points at the move; the round-44 record stays untouched at `corpus/lessons/round-44.md:17`. |
| 6 | **B1 battery always-refuse conjunct** | **OPEN** (carried, named, not claimed) | the conjunct is still `plans/round-44-c1.sh:186–187` (`Y1_AL=…`; `[ "$Y1_AL" = "0" ]`), file unchanged since `c70bfb0`; no round-45 receipt exercises that blanket leg — `grep -rn 'Y1_AL\|always-refuse' .ufo/waves/round-45/` matches only the dispatch prompt text, no receipt. Named as carried: `plans/round-45.md:86`, `corpus/lessons/round-45.md` §Routed 1 ("not taken … Round-46 candidate"). The reviewer's `C1_GATE_OVERRIDE` runs (`build/K45ReviewerPlan-receipts/g-always1.sh`, `g-always0.sh`) probe the round-45 C1 counter, a different instrument. |
| 7 | **round-40 report erratum** | **OPEN** (owed, outside the lane's write scope) | `/home/vgpnk/Projects/shokunin/.ufo/reports/round-40/kagi.md` contains no `erratum` string (`grep -c -i erratum` → 0); its last commits are `70fe8641` (filed) and `14f47cbd` (the in-place amendment the closure objected to). The related **SCORECARD** erratum does exist (`SCORECARD.md:1564`, commit `209147c`) — that is a different item (spot-check §7 item 3 vs item 7). Named as carried: `corpus/lessons/round-45.md` §Routed 2. |
| 8 | **revenger SEAT-STATUS line** | **OPEN** (round-44 artifact) / **CLOSED for this seat** | round-44's revenger report has no status line: `grep -c 'SEAT-STATUS' .ufo/waves/round-44/build/K44RevengerDrift.md` → **0**; the round-44 report counts it not complete (`/home/vgpnk/Projects/shokunin/.ufo/reports/round-44/kagi.md:32`). **Round-45 recurrence:** of the 9 seat reports now in `.ufo/waves/round-45/build/`, **8 have no `SEAT-STATUS` line** (only `K45ScribeEntry.md` has one) — the same QM47 defect, one wave later. This seat's report carries `SEAT-STATUS:` (see `.ufo/waves/round-45/build/K45Revenger.md`). |
| 9 | **scheduling of `corpus/controls-replay.sh`** | **OPEN** (operator scope, refused) | no scheduler exists: `crontab` → "command not found"; `systemctl list-timers` lists only base-system timers (snapper/shadow/plocate/man-db/tmpfiles/paccache/fstrim/archlinux-keyring) — none for this gate; the only invoker in the tree is `plans/round-43-c2.sh:55` (`GATE=$SCR/clone/corpus/controls-replay.sh`). Named as carried/refused: `plans/round-45.md:86–87`, `corpus/lessons/round-45.md` §Routed 4. |

Also routed in §5 but outside this seat's list, recorded for completeness: **item 7** (four `SHONEN.md`
boxes still `[~]`, operator-owned — `SHONEN.md:5,9,13,17`) and **item 8** (S099 tier reservation: the row
is still tier A `own-work` at `corpus/SOURCES.md:106`; the round-45 lesson re-pins the renumber boundary
at `corpus/lessons/round-45.md:20,22` but says nothing about S099's tier — unresolved, and no
`supersedes S099 —` row exists).

**Additional finding of this seat (collision/quarantine leg), measured at the candidate.** Re-running the
§6 grep pair against the landed registry (`grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}'` over
`corpus/SOURCES.md` and the staged `SOURCES.append.md`, then `comm -12`): registry 102 ids, staged 172
ids, **collisions 51** — the three extra are the round's own new rows **S100, S101, S102**, which the
staged package already assigns to different documents (staged S100 = betterleaks `main` tree, S101 =
betterleaks `v1.x` tree, S102 = GB/T 17901.1-2020 采标情况). `comm -13` of the HEAD collision set and
the candidate collision set = `S100 S101 S102`. A1-8 promised "no staged-reserved id is reused"
(`plans/round-45.md:124`); the lesson's Gate still reports the pre-append count "48 staged ids collide
with lane ids (S052–S099)" (`corpus/lessons/round-45.md:22`), so the landed record understates its own
collision set by three. The true next id outside both the registry (S001–S099) and the staged package
(S052–S223) is **S224**. The guard is alive (it caught this); the recorded count is stale.

## (b) M45-1 timeline — stamp drift and the re-pin

Measured by recomputing sha256 + line + byte counts for every row of `corpus/stamps.tsv` at each
revision, against the blob of that revision (`git cat-file -p <rev>:<path>`). 123 rows throughout.

```
6d6b486  round-42 close ........ drift 0   (baseline: every stamp row matches its file)
542885e  round-43 candidate .... drift 3   prefreeze-control.sh, self-description-sweep.sh, surface-census.sh
65f66e1  round-43 integration .. drift 7   + LOG.md, SCORECARD.md, corpus/QUALITY.md, corpus/SOURCES.md
c70bfb0  round-44 A1 ........... drift 7   (SCORECARD.md bytes changed again; still stale)
0ad617a  round-44 candidate ..... drift 7   (QUALITY.md, SOURCES.md bytes changed again; still stale)
92c394c  round-44 landing ...... drift 0   RE-PIN: stamps.tsv rewritten, 7 rows corrected (M44-10)
0d0192f  BASE claim tip ........ drift 0   (closure's own measurement reproduced)
307fb50  round-45 predecl. ..... drift 0
c74ca51  round-45 A1 ............ drift 0
072bb0b  round-45 candidate ..... drift 0   re-pinned again (stamps.tsv 12 lines changed)
```

**When the stamps went out of step, and which commit re-pinned them.** The drifted set grew in two
steps, both in **round 43**: `542885e` (three gate scripts) and **`65f66e1`** ("round-43: C1-C3
integration", which changed `LOG.md` +11, `SCORECARD.md` +34, `corpus/QUALITY.md` +9,
`corpus/SOURCES.md` 1 line and **did not touch `corpus/stamps.tsv` at all** — `git show --stat 65f66e1`
contains 0 `stamps.tsv` rows). Measured at `65f66e1`: `LOG.md` stamp `8823cd79/1783/148801` vs actual
`81f7a512/1794/151649`; `SCORECARD.md` `7d606e26/1595/196478` vs `05f3d564/1629/202119`;
`corpus/QUALITY.md` `9e4ffdc5/218/38737` vs `bee36fcf/227/40705`; `corpus/SOURCES.md`
`17981a0e/258/92005` vs `7e234fba/258/92061` — i.e. the four document rows were already stale **at
round 43's integration**, and the round-44 migration record's "motivating change" column
(`.ufo/waves/round-44/controls/stamp-migration.txt:11–14`, "round-44 … appended") misattributes them to
round 44. The re-pin that closed all seven rows is **`92c394c`** (round-44 landing, M44-10); the round-45
candidate `072bb0b` re-pinned the six rows this round changed.

**Per-file, commit that last changed the file vs. the commit that wrote its stamp row**
(`git log --format='%h %ad %s' --date=short -- <path>`; stamp row from `git log -- corpus/stamps.tsv`):

| file | last change to the file | stamp row written by | state at BASE `0d0192f` | state at candidate `072bb0b` |
|---|---|---|---|---|
| `LOG.md` (lane root; **`corpus/LOG.md` does not exist** — `git ls-tree HEAD -- corpus/LOG.md` is empty) | `92c394c` | `92c394c` | in step | last change `072bb0b`, stamp row `072bb0b` — in step |
| `SCORECARD.md` | `92c394c` | `92c394c` | in step | `072bb0b` / `072bb0b` — in step |
| `corpus/QUALITY.md` | `0ad617a` | `92c394c` | in step (re-pinned after the candidate) | `072bb0b` / `072bb0b` — in step |
| `corpus/SOURCES.md` | `0ad617a` | `92c394c` | in step (re-pinned after the candidate) | `072bb0b` / `072bb0b` — in step |

Live-worktree observation (same defect class as M45-1, mid-round and repaired at landing): at 18:05 the
working tree read `STAMP_DRIFT: rows=123 drift=1 / DRIFT corpus/SOURCES.md` (rc 1) because `corpus/SOURCES.md`
carried an uncommitted edit (the D5 lead bullet) while its stamp row still pointed at the committed
bytes; the candidate's re-pin closed it (`drift=0` at `072bb0b`).

## (c) No stamp churn from this seat's commands

- `sha256sum corpus/stamps.tsv` = `f2423b311d5b8564c060e0beb66feb69ff577bd5957865d36df0c5d284583177`;
  `git show HEAD:corpus/stamps.tsv | sha256sum` — identical; `git diff --quiet HEAD -- corpus/stamps.tsv`
  → rc **0**.
- `git status --porcelain` at measurement time: only `.ufo/waves/round-45/build/K45ScoutSources.md`,
  `…/K45ScoutSources/receipts.txt`, `…/K45ScoutSources/report.md` (modified by that seat) and
  `?? .ufo/waves/round-45/final/` — none is mine and none is a stamp artifact.
- The only stamp-named file under `.ufo/waves/round-45/build/` is `K45ExecStampRW/stamp-drift.py`
  (a peer seat's read-only checker) plus its receipts. No `stamps.tsv` copy or registry was written by
  this seat anywhere.
- This seat wrote exactly two files, both in scope:
  `.ufo/waves/round-45/build/K45Revenger/routed-state.md` and `.ufo/waves/round-45/build/K45Revenger.md`.

## Commands run (each with exit code and last line)

| command | rc | last line / note |
|---|---|---|
| `git -C <lane> rev-parse HEAD` | 0 | `307fb50da825d6e6f2b5c7981c71556d35611142` (later `072bb0b`) |
| `git -C <lane> log --format='%h %ad %s' --date=short -- corpus/stamps.tsv \| head -20` | 0 | 20 rows, `072bb0b` … `ffa4add` |
| `git -C <lane> log --format='%h %ad %s' --date=short -1 -- <path>` ×4 | 0 | per-file table above |
| `git -C <lane> show --stat --format='' 65f66e1 \| grep -c stamps.tsv` | 1 (0 matches) | `65f66e1` touched no stamp row |
| `git -C <lane> cat-file -e d54109d:corpus/controls-replay.sh` | 0 | gate present at BASE |
| `git -C <lane> cat-file -e <rev>:corpus/lessons/round-45.md` | 1 at `307fb50` | lesson absent at predeclaration |
| `git -C <lane> ls-tree HEAD -- corpus/LOG.md` | 0 (empty) | `corpus/LOG.md` does not exist |
| `git -C <lane> diff --quiet HEAD -- corpus/stamps.tsv` | 0 | no churn (part c) |
| `git -C <lane> status --porcelain` | 0 | peer-seat files only |
| python3 sha256/line/byte recompute over `corpus/stamps.tsv` at 10 revisions | 0 | drift table above |
| `python3 .ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py <lane>` | 1 | `DRIFT corpus/SOURCES.md` (live worktree, pre-candidate) |
| `grep -c 'SEAT-STATUS' .ufo/waves/round-44/build/K44RevengerDrift.md` | 1 (0 matches) | round-44 revenger has no status line |
| `grep -c 'SEAT-STATUS' .ufo/waves/round-45/build/*.md` | 1 (1 of 9 files matched) | 8 of 9 round-45 reports lack it |
| `grep -c -i erratum /home/vgpnk/Projects/shokunin/.ufo/reports/round-40/kagi.md` | 1 (0 matches) | report erratum still owed |
| `systemctl list-timers --no-pager` / `crontab -l` | 0 / 127 | no scheduler for `corpus/controls-replay.sh` |

No claim-ledger verify, no self-counts, no lane gate or counter was executed by this seat.

Confidence: high for every OPEN/CLOSED row above (each is a direct path:line or command output at a
named revision); the two judgement calls are marked in the text — (i) D1's "disclosure" half is judged
OPEN only because no round-45 report file exists to carry a deviation line, and (ii) D4's OPEN rests on
the class strings as written at `corpus/lessons/round-45.md:33–34` compared against CORPUS.md:171–178.
