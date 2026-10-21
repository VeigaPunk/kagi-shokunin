# R27 timeline reconstruction — RevengeR27Timeline-7 (BASE 3553d499)

All times 2026-10-21, `-03:00` local (wave JSON stamps are naive-UTC; lane is UTC-03:00).
Citations `path:line` are at BASE `3553d499577084a6c98d7078906017840bbf7b28` unless a commit is named.

## Findings (evidence for round-28's mined mistake, bdf90f58:plans/round-28.md:5-7,74-75)

1. **plans/round-27.md first entered git together with its candidate code and the entire build wave.**
   Commit `144babcb892f0a30154880a9f94aa59ca8ddf9c5` (author=commit 12:31:36, parent = r27 frozen BASE
   `0a47dd189356ea66ec83c3891eed54526e95b89b` committed 11:35:35) is the ONLY adder of the plan
   (`git log --diff-filter=A -- plans/round-27.md`, exit 0). It introduced 1874 paths at once:
   `plans/round-27.md`, candidate code `corpus/release-clock.py`, 1856 files under `.ufo/waves/round-27/`
   (build-spec/dispatch/record, ~60 seat reports incl. `CritC2Rollback.md`, `CritC2NonNumeric.md`),
   plus corpus/* and top-level docs (`git diff-tree --no-commit-id --name-only -r 144babcb | wc -l` → 1874).
   Wave-internal timestamps in `build-spec.json` + `build/swarm-registry.json` span
   15:06:38Z–15:15:43Z (= 12:06:38–12:15:43 local): the build wave executed **before** the plan was ever committed.
   No plan-first ordering existed; contrast round-28's claims commit `bdf90f58` ("before any work", 13:44:04).

2. **C2 scope widened mid-round, strictly after the measured revision.**
   - Frozen declaration: `plans/round-27.md:26-35` — REGRESSED only for observation below a numeric anchor;
     `:31-32` keeps non-numeric anchors on "the inequality rule as a declared limit".
   - First measurement pass pinned: `.ufo/waves/round-27/c2-before.json:3` → revision `0a47dd18` (BASE),
     `.ufo/waves/round-27/c2-after.json:3` → revision `144babcb` (first candidate), harness at that revision
     had **three** fixtures (lie/rollback/control; docstring of `144babcb:.ufo/waves/round-27/tools/c2-measure.py`).
   - Widening commit `3fb77271eeee797047c37871038b1db1247fa236` (12:59:43, only child of 144babcb before 13:09):
     appended `plans/round-27.md:48-65`; `:50-52` — "C2 scope widened before landing (CritC2Rollback,
     CritC2NonNumeric): the rule also refuses an observation below the highest numeric anchor on the same feed
     URL (and, when observing, below the row's previous observation)"; `:54-56` — non-numeric anchor S012
     `v1.21.x` now ordered against its feed's numeric floor. Same commit changed
     `.ufo/waves/round-27/tools/c2-measure.py` from 3 to 5 fixtures, "`unfire` and `nonnumeric` were added
     after CritC2Rollback/CritC2NonNumeric", and committed both passes' receipts
     (`receipts/c2-before-final.json:3` → `0a47dd18`).
   - Re-measurement at the widened revision: `.ufo/waves/round-27/final/c2-before.json:3` → `0a47dd18`,
     `final/c2-after.json:3` → `3fb77271`. So: measure @144babcb → widen → re-measure @3fb77271.
     Only bounds on the widening instant: 12:31:36 (parent commit) < widening work < 12:59:43; latest wave-file
     timestamp inside that window is 15:42:05Z (= 12:42:05 local).

3. **No round-27 START census existed.**
   - No `census-start*` file tracked anywhere under `.ufo/waves/round-27/` at BASE, while the convention existed:
     `round-24/census-start.txt`, `round-25/census-start.txt`, `round-26/census-start.json`
     (`git ls-tree -r --name-only 3553d49 -- .ufo | grep -i census`, exit 0).
   - Append-only admission `corpus/lessons/round-27.md:262-267` (added by `3553d499` 13:29:02,
     "census-start correction (append-only)"; that commit touched only this file + `corpus/stamps.tsv:69`):
     "no round-27 start census file was written … 'start had 8' and the sibling-lane explanation are withdrawn;
     the retained before/after pair is round-26 end (11 W04, exit 0) → round-27 end (11 W04, exit 0)".
   - The withdrawn false claim remains above it (append-only): `corpus/lessons/round-27.md:252-254`
     ("start had 8 — S039/S040/S041 now share URLs with another lane's registry").
   - Factual basis verified: `.ufo/waves/round-26/census-end.json` contains 11 `W04` occurrences, and
     `.ufo/waves/round-27/final/census-end.json:2` (revision `3fb77271`, exit 0) also 11 — identical, so "start had 8" was impossible.
   - Contrast: `.ufo/waves/round-28/census-start.txt:1` captured 13:38:30 (11 W04 + ok, exit=0), committed in
     `bdf90f58` 13:44:04 before any round-28 work.

## Commit timeline (verified)

| Commit | Time | Event |
|---|---|---|
| `0a47dd18` | 11:35:35 | round-26 final = round-27 frozen BASE (lessons:7) |
| `144babcb` | 12:31:36 | FIRST commit of plans/round-27.md **with** candidate code + whole build wave (1874 paths) |
| `3fb77271` | 12:59:43 | C2 scope widened (+19 plan lines), measure tool 3→5 fixtures, both measurement passes' receipts |
| `29fa79b7` | 13:09:16 | final Gate receipts at 3fb77271, `final/census-end.json`, wave outcomes |
| `3553d499` | 13:29:02 | census-start correction (lessons + stamps.tsv only) |
| `bdf90f58` | 13:44:04 | round-28 claims file + START census "before any work" |
| `b9a42c0e` | 14:06:44 | round-28 fixture clarification |

BASE `plans/round-27.md` text = `3fb77271` text (later commits untouched: `git diff 3fb77271 3553d49 --stat -- plans/round-27.md` empty, exit 0).

## Commands run (all exit 0 unless noted)

1. `git log --follow --format='%H %ad %s' --date=iso-strict -- plans/round-27.md` → 144babcb (add), 3fb77271 (modify) only.
2. `git diff-tree --no-commit-id --name-only -r 144babcb | wc -l` → 1874; per-area breakdown via `awk -F/`.
3. `git rev-parse 144babcb^` → `0a47dd189356ea66ec83c3891eed54526e95b89b`.
4. `git diff 144babcb 3fb77271 -- plans/round-27.md` → +19 lines (the widening block, lines 48-65 at BASE).
5. `git show 3fb77271 -- .ufo/waves/round-27/tools/c2-measure.py` → docstring 3→5 fixtures; `separability.py` stale-regex widened too.
6. `grep -n '"revision"' .ufo/waves/round-27/{,final/}{c2-before,c2-after}.json .ufo/waves/round-27/receipts/c2-before-final.json` → the five pins above.
7. `git show 144babcb:.ufo/waves/round-27/tools/c2-measure.py | sed -n 1,20p` → three-fixture harness at the measured revision.
8. `git ls-tree -r --name-only 3553d49 -- .ufo | grep -i census` → no round-27 census-start; r24/r25/r26 starts present.
9. `grep -o 'W04' .ufo/waves/round-26/census-end.json | wc -l` → 11; same on `round-27/final/census-end.json` → 11.
10. `git show 3553d49 -- corpus/lessons/round-27.md corpus/stamps.tsv` → correction block + restamp (19588→20037 bytes).
11. `grep -oh '2026-10-21T…' .ufo/waves/round-27 --include='*.json' --exclude-dir=sandboxes | sort` → bounds 15:06:38Z–15:42:05Z.
12. `git show bdf90f58:plans/round-28.md | grep -n -i 'census\|round-27'` → the audited claims at lines 5-7, 74-75.

## Not checked / limits

- Wall-clock execution instants of the two C2 measurement passes: the measurement JSONs carry no time fields
  (`grep '"at"\|"utc"\|"time"\|"date"'` → no match, exit 1 on c2 files); only commit-time bounds exist.
- Intra-commit ordering inside `3fb77271` (widening text vs receipts) and inside `144babcb` (plan vs candidate):
  git stores no order; I claim only co-commit, not sequence, beyond the revision pins in the JSONs.
- Authorship time of the plan draft before 12:31:36 (untracked period invisible to git; no draft copy found in wave files).
- Committer identity/signatures not verified (lane-author assumed); host script `scripts/sources-census.sh` not opened (fleet root, outside lane; argv cited from receipts only).
- No measurement, census, or gate was re-run by me; all numbers are read from retained receipts (read-only round).
- Tools installed: none (tooling directive satisfied trivially).
