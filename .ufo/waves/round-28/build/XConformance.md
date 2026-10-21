# XConformance — `round-conformance.py` (round-28 mistake-fix tool)

Seat `KagiR28.XConformance-7` · lane `kagi-shokunin` · BASE `3553d4995770…` · 2026-10-21

## Findings first (ground truth the tool fixes)
- Round-27 conformance defects confirmed in git history: the round-27 plan's FIRST commit
  `144babcb892f` ("round-27: … (candidate)", ct 1792596696) touched 1874 paths, 1873 of them
  outside the allowed set — incl. `corpus/release-clock.py`, `SKILL.md`, `LOG.md`,
  `PROVINCE.md`, `SCORECARD.md`, `corpus/lessons/round-27.md`, and all of
  `.ufo/waves/round-27/**` (its `tools/`, `build/`, `sandboxes/`). `git log --`
  `.ufo/waves/round-27/census-start.txt` is empty: no START census was ever committed.
- BASE path:line anchors (plans/round-27.md in worktree == BASE: `git diff --stat
  3553d499..HEAD` adds only `.ufo/waves/round-28/census-start.txt` and `plans/round-28.md`):
  `plans/round-27.md:20-21` — its counting command is prose ("Counting command: overlay the
  after binding table…"), no machine-checkable command block; `plans/round-27.md:48` —
  corrections heading with suffix text.
- `plans/round-28.md` does not exist at BASE; it was added by `bdf90f58e43f` ("frozen claims
  file and START census (before any work)", ct 1792601044) touching exactly 2 paths:
  `plans/round-28.md` + `.ufo/waves/round-28/census-start.txt`. Counting commands live at
  `plans/round-28.md:29` and `:59` (at bdf90f58 and tip); corrections heading at
  `plans/round-28.md:91`; the tool mandate itself is `plans/round-28.md:74-77`. Tip
  `b9a42c0e9476` ("plan fixture clarification") modified only plans/round-28.md, +10/−0,
  appended after line 91 (`git diff bdf90f58..HEAD -- plans/round-28.md`, exit 0) — frozen
  text and both counting commands untouched.
- Defect found in my own first draft during testing: `git()` returns a 3-tuple; the census
  existence check unpacked 2 (ValueError at line 166, exit 1). Fixed before any result was
  recorded; all outputs below are from the fixed file.

## Deliverable
`.ufo/waves/round-28/tools/round-conformance.py` — NEW file, stdlib-only, no lane code
executed, read-only git only (`rev-parse`, `log`, `rev-list -n1 --parents`, `diff-tree -z`,
`show`, `cat-file -e`, `merge-base --is-ancestor`). Usage:
`python3 -I -B .ufo/waves/round-28/tools/round-conformance.py <lane> <round>` (`round-28`
prefix accepted). Exit 0 = PASS, 1 = FAIL (any FAIL/ERROR, incl. usage errors). One typed
line per check: `C1 PLAN-FIRST-COMMIT-SCOPE`, `C2 CENSUS-START-ORDER`,
`C3 FROZEN-COUNTING-COMMANDS`, plus detail lines (`C1 OUTSIDE-PATH`, `C3 FIRST-DIFF` /
`AT-FIRST` / `AT-TIP`, `NOTE`) and final `VERDICT`.
- C1: the oldest commit touching `plans/round-<N>.md` must touch nothing outside `plans/`
  and exactly `.ufo/waves/round-<N>/census-start.txt`; a merge commit as first touch is a
  typed ERROR (unsupported), root commits handled via `diff-tree --root`.
- C2: census-start.txt must exist at HEAD and its first commit be no later than the plan's
  first commit — decided by commit-graph ancestry (`merge-base --is-ancestor`; same commit
  counts), NOT by commit timestamps (clock-skew-proof); `%ct` printed as evidence only.
  Committed-then-deleted at HEAD is also FAIL-MISSING.
- C3: frozen part = all lines before the first line starting `## Plan corrections` (prefix
  match covers both plans' heading suffixes). Counting-command lines = content lines of ```
  fences plus lines indented ≥4 spaces inside the frozen part (fence delimiters excluded);
  compared byte-identically between the plan's first commit and HEAD (worktree ignored).
  Zero detected lines ⇒ vacuous OK with an explicit NOTE (round-27 shape).

## Exact outputs (canonical runs, cwd = lane root)
Round 27 — FAIL (exit 1); full 1873-line OUTSIDE-PATH list: artifact://19558:
```
ROUND-CONFORM lane=. round=27 head=b9a42c0e9476
C1 PLAN-FIRST-COMMIT-SCOPE FAIL-SCOPE first=144babcb892f ct=1792596696 subject='round-27: knowledge numbers bound; numeric release regression refused (candidate)' touched=1874 outside=1873
  C1 OUTSIDE-PATH .ufo/waves/round-27/build-assignments.json   […1872 more, incl. corpus/release-clock.py, SKILL.md, LOG.md, PROVINCE.md, SCORECARD.md, corpus/lessons/round-27.md]
C2 CENSUS-START-ORDER FAIL-MISSING census=never-committed plan_first=144babcb892f(1792596696)
C3 FROZEN-COUNTING-COMMANDS OK lines=0 first=144babcb892f tip=HEAD (vacuous: none detected)
  C3 NOTE no fenced/indented counting-command lines in the frozen part; check is vacuous for this plan
VERDICT FAIL
EXIT=1
```
Round 28 — PASS (exit 0), lane tip `b9a42c0e9476`:
```
ROUND-CONFORM lane=. round=28 head=b9a42c0e9476
C1 PLAN-FIRST-COMMIT-SCOPE OK first=bdf90f58e43f ct=1792601044 subject='round-28: frozen claims file and START census (before any work)' touched=2
C2 CENSUS-START-ORDER OK same-commit-as-plan first=bdf90f58e43f ct=1792601044
C3 FROZEN-COUNTING-COMMANDS OK lines=2 first=bdf90f58e43f tip=HEAD
VERDICT PASS
EXIT=0
```
Absolute `<lane>` from foreign cwd (/tmp): same 6 lines with
`lane=/home/vgpnk/Projects/shokunin/kagi-shokunin`, VERDICT PASS, EXIT=0.

## Negative controls (can it fail?) — synthetic repo
`.ufo/waves/round-28/sandboxes/XConformance/negrepo` (5 commits, retained). r98 = plan+census
one commit, then append-only correction; r99 = same-shape plan, frozen command mutated at tip
(`--mode=one`→`--mode=two`); r97 = census committed after the plan.
```
--- r98: C1 OK touched=2 / C2 OK same-commit-as-plan first=53b0a74851aa / C3 OK lines=1 / VERDICT PASS / EXIT=0
--- r99: C1 OK touched=2 / C2 OK same-commit-as-plan first=8e85c64ad42d /
  C3 FROZEN-COUNTING-COMMANDS FAIL-CHANGED first=8e85c64ad42d tip=HEAD
  C3 FIRST-DIFF index=0
  C3 AT-FIRST '    echo frozen-99 --rev=<rev> --mode=one'
  C3 AT-TIP   '    echo frozen-99 --rev=<rev> --mode=two'
  VERDICT FAIL / EXIT=1
--- r97: C1 OK touched=1 /
  C2 CENSUS-START-ORDER FAIL-ORDER census_first=db1787587563(1792603021) plan_first=d97d7ec94229(1792603012) census-committed-after-plan
  VERDICT FAIL / EXIT=1
```

## Command log (all exit 0 unless noted)
1. `git log --format='%H %ct %s' -- plans/round-{27,28}.md` and `-- …/census-start.txt` ×2 — history census (above).
2. `git show --name-status` on 144babcb / bdf90f58 / b9a42c0e — path sets (above).
3. `git diff bdf90f58..HEAD -- plans/round-28.md`; `git diff --stat 3553d499..HEAD` — append-only proof.
4. Canonical runs r27 (first run hit the unpack bug, exit 1 via traceback; rerun after fix = FAIL exit 1) and r28 (same: bug run, then PASS exit 0).
5. Usage/edge: no args → `ERROR ARGS usage: …` EXIT=1; `round 99` → `ERROR PLAN-NEVER-COMMITTED plans/round-99.md` EXIT=1; `round-28` prefix → identical PASS.
6. Negative controls (above), exits 0/1/1.

## Not checked / declared limits
- Merge commit as a plan's first touch: typed ERROR by design, never exercised on a real merge.
- C3 vacuousness on round-27: its commands are prose, so C3 cannot fail there; C3's fail path is proven only on the synthetic r99. If a future plan writes counting commands as prose again, C3 is vacuous — visible via the NOTE line.
- No CRLF plan files, no renamed plans (`--follow` not used), no `## Plan corrections` line inside a fenced block (would truncate the frozen slice early), no deep non-linear histories (multiple roots / plan added on a side branch then merged) were tested.
- Census receipt CONTENT (timestamp/40-hex pin) is out of scope here; a sibling ScoutMistakeSweep draft covers receipt shape. `plans/round-28.md` fixture-set bullet lines (non-indented) are intentionally not C3-compared — assignment scopes C3 to counting-command lines.
- Lane tip verified at `b9a42c0e9476` during runs; if L1 lands further commits before integration, re-run the two canonical commands.

## Tooling installs
None — stdlib-only Python; no pacman/uv/npm/cargo activity (pause respected).
