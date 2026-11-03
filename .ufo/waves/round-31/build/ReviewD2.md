# ReviewD2 — round-31 BUILD, D1/D2 hygiene attack (leaf seat, read-only)

Seat: ReviewD2 (reviewer). Lane: `kagi-shokunin`. Lane HEAD at measurement: `2d46e5759c02307edb3570c389de650040f98956`
(round-31 plan correction 1). Frozen BASE `655e620651808ac04bb59bfa35b81227f62a031b` is an ancestor. Round-30 tip
`d00e37e57828b6c057dbedf1fb7c3630dfd09f25` is an ancestor. Worktree is DIRTY (round-30 D1 files plus round-31 live wave files).
No lane file was written; no lane git/jj mutation; no `op`/vault contact; no network use; no installs.

Judged on: calibration, coverage. Milestone: round-31 BUILD, D1/D2 hygiene (frozen plan, Frontier step).

## Verdict

D1 is attackable and the defects are concrete: the 11-path routed list is correct as status entries but is 14 files, the
commit must be path-restricted away from 23 round-31 untracked paths, and two untracked registry drafts are stale against
landed bytes. D2 is a pointer defect, not a value defect: the round-30 after-state (`stale=0`) reproduces at `d00e37e`,
but the file the report cites holds the before-state. Receipt at the round-31 tip is produced (`selfcounts-at-r31-tip.txt`:
`stale=0 policy=2 setup=0`, exit 2). Three cited round-30 paths do not exist at `d00e37e`.

## F1 — MUST-FIX — D1 commit scope: take exactly the 14 round-30 files; exclude round-31 wave files

`git status --porcelain=v1 -uall` shows 11 status entries under `.ufo/waves/round-30/` (the `final/c3/registry/` directory
collapses to one entry). Expanded at file level: **14 files** (2 modified + 12 untracked).

Round-30 set (to be committed under the round-31 entry, by explicit pathspec):

| # | state | path | round-30 authorship evidence |
|---|---|---|---|
| 1 | M | `.ufo/waves/round-30/SentHygiene-report.md` | append-only +48 lines, "Post-commit verification" section, SentHygiene |
| 2 | M | `.ufo/waves/round-30/build/SentHygiene.md` | append-only +48 lines, same section |
| 3 | ?? | `.ufo/waves/round-30/SDraftEntries-report.md` | SDraftEntries seat report |
| 4 | ?? | `.ufo/waves/round-30/SRegistryRows-report.md` | SRegistryRows seat report |
| 5 | ?? | `.ufo/waves/round-30/build-results.json` | round-30 build results, 15 seats (XD1Rows, XD2Cells, XEol…) |
| 6 | ?? | `.ufo/waves/round-30/build/SDraftEntries.md` | SDraftEntries seat file |
| 7 | ?? | `.ufo/waves/round-30/build/SRegistryRows.md` | SRegistryRows seat file |
| 8 | ?? | `.ufo/waves/round-30/final/c3/entries/SDraftEntries-fetch-receipts.txt` | SDraftEntries fetch rows S053–S060 |
| 9 | ?? | `.ufo/waves/round-30/final/c3/entries/SDraftEntries-fleet-gate.txt` | SDraftEntries fleet gate run |
| 10 | ?? | `.ufo/waves/round-30/final/c3/entries/SDraftEntries-lane-gate.txt` | SDraftEntries lane gate run |
| 11 | ?? | `.ufo/waves/round-30/final/c3/registry/append-block.md` | cites XAssimCol; S053–S060; **stale, see F4** |
| 12 | ?? | `.ufo/waves/round-30/final/c3/registry/capture-rows.tsv` | S053–S060 capture rows; **stale, see F4** |
| 13 | ?? | `.ufo/waves/round-30/final/c3/registry/index-drafts.md` | cites round-30 seats and README/PROVINCE index rows |
| 14 | ?? | `.ufo/waves/round-30/final/c3/registry/used-by.tsv` | used-by map for S053–S060; matches landed entries (F6) |

Round-31 paths currently untracked (NOT round-30 evidence; must not enter the round-30 hygiene content; they belong to the
round-31 wave and are committed, if at all, under its own entry with path-restricted staging). Snapshot at 23 paths:
`.ufo/waves/round-31/base/` ×7 (`base-cells`, `base-census`, `base-counts`, `base-fleet`, `base-headings`, `base-routed`,
`base-rows`); `build-dispatch.json`, `build-spec.json`, `build.ready`, `build.ready.dispatched`; `build/` ×8
(`AttackCells-reshape.sed`, `assimilation/{collisions,reg-ids,staged-ids}`, `cells-red-base.txt`,
`cells-red-inlane-rows.txt`, `cells-red-probe.txt`, `swarm-registry.json`); `src-open/` ×4 (`group-a*`, `group-b*`).
The set is still growing while the wave lands, so re-list at commit time.

Mechanism for the L1: `git add -A`, `git add .ufo/`, or `git add .ufo/waves/round-31` would sweep the round-31 set in with
the round-30 set. Stage the 14 round-30 paths by explicit pathspec, and assert `git diff --cached --name-only` = those 14
before committing. (The `.gitattributes` rule `.ufo/** -text -eol` is in force at HEAD, so staging does not renormalize
these bytes. I verified it; see Checks.)

## F2 — MUST-FIX — D2 receipt-pointer defect: the round-30 C1 after-state cites the before-state file

Verbatim sentence the round-31 report must supersede (fleet report `.ufo/reports/round-30/kagi.md`, line 11, the C1 bullet):

> Evidence: `corpus/lessons/round-30.md` §C1; `.ufo/waves/round-30/final/receipts/selfcounts-at-tip.txt`.

What the cited file holds at `d00e37e` (`git show d00e37e:.ufo/waves/round-30/final/receipts/selfcounts-at-tip.txt`), the
before-state:

    SELF_COUNTS: POLICY (claims=62 stale=8 unlocated=0 ambiguous=0 policy=2 setup=1)

Which after-state is correct and reproducible:

- Live run, archive export of `d00e37e` in scratch (no lane mutation):
  `SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, exit 2. **The round-30 after-state
  VALUE is correct.** The defect is only the cited file.
- Lane at HEAD `2d46e57`, worktree dirty, in-lane run:
  `SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, exit 2. Receipt:
  `.ufo/waves/round-31/build/selfcounts-at-r31-tip.txt`.
- The lesson `corpus/lessons/round-30.md` line 66 quotes the same after-state verbatim
  (`SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, exit 2). That half of the citation is valid.

Also cites `.ufo/waves/round-30/final/receipts/selfcounts-at-tip.txt` as the before-state surface:
`corpus/lessons/round-30-verifier-spotcheck.md` lines 33 and 137 (the verifier already named it). Those are correct
descriptions of the defect and need no change.

Required in the round-31 report: name the line-11 sentence above and supersede it by name, citing the round-31 receipt and the
lesson line 66. Do not rewrite `final/receipts/selfcounts-at-tip.txt` (filed bytes; the round-30 tree is committed).
The final round-31 receipt must be re-run at the final tip (the plan predicate is at the measured revision, not `2d46e57`).

## F3 — MUST-FIX — pointer sweep: three round-30-cited paths do not exist at `d00e37e`

Every `.ufo/waves/round-30/…` path the round-30 fleet report (`.ufo/reports/round-30/kagi.md`) cites, tested with
`git cat-file -e d00e37e:<path>`:

| cited (report line) | at `d00e37e` | note |
|---|---|---|
| `.ufo/waves/round-30/` (line 11 context, dir) | EXISTS | — |
| `build/CAttackPredicates.md`, `build/RAttackC1.md`, `build/RAttackC3.md`, `build/LProbeGitattr.md`, `build/XD2Cells.md`, `build/XAssimCol.md` (line 19, brace-expanded) | EXISTS ×6 | — |
| `build/ConnOverlap.md` (line 24) | EXISTS | — |
| `build/MAttackEol.md` (line 26) | EXISTS | — |
| `build/ScoutHost.md` (line 25) | EXISTS | — |
| `build/SentHygiene.md` (line 20) | EXISTS (tracked, M in worktree) | — |
| `build-spec.json` (line 99) | EXISTS | — |
| `build-dispatch.json` (line 99, short form) | EXISTS | — |
| `census-start.txt` (line 22) | EXISTS | — |
| `final/c2/` (dir) | EXISTS (tree) | — |
| `final/c3/src-open/` (dir) | EXISTS (tree) | — |
| `final/receipts/selfcounts-at-tip.txt` (line 11) | EXISTS, **before-state content** | F2 |
| `final/receipts/verify-at-tip.txt` (line 49 context) | EXISTS | — |
| **`.ufo/waves/round-30/SDraftEntries-report.md`** (line 21, item 3 "Pointer") | **MISSING** | untracked; resolves when F1 lands |
| **`.ufo/waves/round-30/final/c3/registry/used-by.tsv`** (line 63) | **MISSING** | untracked; resolves when F1 lands |
| **`build-results.json`** (line 99, short form) | **MISSING** | untracked; resolves when F1 lands |

Required in the round-31 report: name all three missing paths alongside the F2 pointer defect, and state that they resolve on
the D1 landing, using the same wording as the R11-08 precedent (cited but not durable until the commit lands). The round-31
report must not present them as "present at `d00e37e`".

## F4 — MUST-FIX — two untracked registry drafts are stale against landed bytes; committing them unlabeled creates two conflicting capture sets

Both drafts sit in `.ufo/waves/round-30/final/c3/registry/` and are in the F1 set. Measured against HEAD:

- `append-block.md`, 8 rows: **7 of 8 exact** in HEAD `corpus/SOURCES.md`. The mismatch is S056. The draft says
  `… star count and last-push date as recorded by the code host`, with `stargazers_count` 2322 and `pushed_at` 2026-10-22T21:28:27Z
  inline. The landed S056 row (changed in `2017a68`, F2 correction) says `… the repository's own fork status as recorded by the code host; star and push counts are point observations and move`,
  with the counts moved into a labelled campaign capture. The draft predates the correction.
- `capture-rows.tsv`, 8 rows: **0 of 8 exact** against landed `corpus/source-fetches.tsv` rows S053–S060. Field diff (16 columns):
  - col 9 (decode profile) differs on 8 of 8: draft `decoded-http-body-v1`, landed `decoded-http-body-volatile-v1`
    (the landed profile was introduced in `064d4b6`);
  - col 16 (locator text) differs on 8 of 8 (e.g. draft `§Validation`, landed `README Validation section`);
  - col 10 (S056 sha) differs on S056 (draft `7387064618752b5081aa…`, landed `b7e19953ecde88d0…`).
- The round-30 report line 27 states `SRegistryRows (append block vs landed: zero diff)`, and `SRegistryRows-report.md` §0 says the
  block was "already landed byte-identically". Both were true for the append block at `064d4b6`, before `2017a68`. They are **not
  reproducible at HEAD**: 1 of 8 append rows and 8 of 8 capture rows differ. The `capture-rows` claim was never reproducible against HEAD.

Required (choose one, state which in the round-31 report): (a) before the F1 commit, the L1 labels both files as superseded
pre-correction drafts (header line naming the superseding commit `2017a68` and the landed files), without editing their
filed-bytes history; or (b) leave both untracked and cite only the landed rows. Do not commit them as unlabeled evidence, and
do not paste them into `corpus/SOURCES.md` or `corpus/source-fetches.tsv` (the landed rows are authoritative).

## F5 — NOTE — per-entry drafts are pre-correction counterexamples, not landed bytes

`.ufo/waves/round-30/final/c3/entries/` holds the three per-entry drafts as pre-correction counterexamples; `SDraftEntries-report.md` labels them
"counterexamples against the landed entries". Measured: `secret-scanning-detection-vs-validation.md` 133 differing lines against
landed, `betterleaks-detection-vs-validation.md` 148, `trufflehog-verification-lifecycle.md` 138. The drafts are the M30-8
pre-correction record. They are valid round-30 evidence (F6) and may be committed, labelled as pre-correction drafts superseded
by `2017a68`. The round-31 commit message should not describe them as landed.

## F6 — NOTE — authorship of all 14 files: round-30 evidence confirmed by content, not only by name

Name-based grep (`SDraftEntries|SRegistryRows|SentHygiene|round-30|round 30`): 13 of 14 files reference a round-30 seat or round-30
identifier; `round-31` matched 0 times in all 14. `registry/append-block.md` cites `XAssimCol`; `registry/capture-rows.tsv` and
`registry/used-by.tsv` carry no seat name, but their ids (S053–S060) and their dates (2026-11-03) exist only in round 30.
`used-by.tsv` was checked against the landed entries (loose grep on `[S05x]` / `S05x`): S053, S054 → `secret-scanning-detection-vs-validation.md`;
S055, S056 → `betterleaks-detection-vs-validation.md`; S057–S060 → `trufflehog-verification-lifecycle.md`. That is 8 of 8 match.
So `used-by.tsv` is landed-consistent round-30 evidence even though it is not seat-named.

## F7 — NOTE — the two modified round-30 files are append-only and safe to commit

`git diff --stat`: `SentHygiene-report.md` +48, `build/SentHygiene.md` +48, 0 deletions in either. The appended section
("Post-commit verification") was written after `064d4b6` by SentHygiene. The H7 CRLF-resurrection hazard it describes:
`corpus/SOURCES.md`, `SKILL.md`, `corpus/claim-ledger.tsv` are `i/lf w/lf attr/text eol=lf` at HEAD (checked with
`git ls-files --eol`), so the hazard does not bite the kagi index. Commit these with F1.

## F8 — NOTE — scope count: "11 paths" is status entries; the commit is 14 files

The plan and the round-30 verifier say "11 paths" (status entries, with the registry directory collapsed). The file-level set is
14. Any commit checklist that counts status lines will under-count by 3 files (`append-block.md`, `capture-rows.tsv`, `used-by.tsv` and `index-drafts.md` under the collapsed directory).
Record both counts in the round-31 report: 11 status entries, 14 files.

## F9 — NOTE — D2 counts, field-by-field (calibration check)

Round-30 receipt (before-state, `d00e37e`): `stale=8 policy=2 setup=1`, exit 2. Round-31 receipt (`2d46e57`, in-lane, dirty worktree):
`stale=0 policy=2 setup=0`, exit 2. Live `d00e37e` archive run: `stale=0 policy=2 setup=0`, exit 2. Consistent across all three measurements.
The stale→clean change at the stamp row is `SC-SKILL-STAMPS SKILL.md:46 claimed=99 live=99` at HEAD (was `claimed=91 live=94` in the before-state receipt).
The setup=1 row was `KN-CHECKLIST-FALSIFY-FLOOR ledger:R15-05 exit=2 expected=0` in the before-state; it reads OK at HEAD and at `d00e37e` live.
The two POLICY rows are the operator-routed R29 bindings (`PV-FEEDTOKEN-SHAPES`→R29-02, `PV-FEEDTOKEN-SELFTEST`→R29-01, "command not allowlisted").
Those rows remain red and named; no gate was relaxed (the counter's exit 2 is correct output).

## Checks run (read-only; each reported once)

- `git status --porcelain=v1 -uall`, `git rev-parse HEAD`, `git log`, ancestry for BASE/plan/r30 tip.
- `git cat-file -e d00e37e:<path>` over every cited round-30 pointer (the table in F3).
- `python3 corpus/self-counts.py` in the lane (in-lane run, cwd lane, default root): rc 2, `SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, 16.5 s, stderr empty. Output written to `.ufo/waves/round-31/build/selfcounts-at-r31-tip.txt` with a 5-line header (revision, date, layout, dirty worktree, command).
- Live `d00e37e` run: `git archive d00e37e | tar -x` into scratch, then `python3 corpus/self-counts.py` in the export: rc 2, the same summary line as above with `stale=0 … setup=0`.
- Registry/capture/entry drafts vs HEAD: exact-line match of the 8 append rows against `corpus/SOURCES.md`; field diff (16-column) of the 8 capture rows against `corpus/source-fetches.tsv`; `diff` line counts for the three entries; used-by vs entry `[S05x]` citations.
- EOL and attributes at HEAD: `git ls-files --eol` (3 repaired files `i/lf w/lf`), `git check-attr` on `.ufo/waves/round-30/…` (text/eol unset), `.gitattributes` content.
- Round-30 modified pair: `git diff --stat` and a read of the appended section.

## Verification gaps

- No content secret/boundary scan was run on the 14 round-30 files or the 23 round-31 files. That is SentHygiene's class set (round-30 bytes) and is not repeated here; this seat checked authorship and inventory only.
- Round-31 untracked set (23 paths) is moving; the F1 list is a snapshot. Re-list at the commit point.
- The receipt is at `2d46e57`. The round-31 final tip will move; the final predicate receipt must be re-run there.
- The live `d00e37e` check used an archive export, not a clone with fleet layout. Self-counts does not need fleet layout, so the result is not a layout artifact, but it was not run in a lane clone with `.git` history.

## Residue and tooling

- Scratch: `/fast/scratch/hyaku/kagi-r31/ReviewD2/` (self-counts output, live `d00e37e` archive). Removed before yield (see the scratch note at the end).
- Receipt written: `.ufo/waves/round-31/build/selfcounts-at-r31-tip.txt`.
- Report written: `.ufo/waves/round-31/build/ReviewD2.md` (full findings); `.ufo/waves/round-31/ReviewD2-report.md` (findings index pointing here).
- Tool installs: none. Pacman untouched. `op` not invoked (no `op --version` either; no vault/account read).
- No lane file written; no lane git/jj mutation; no `agent://all`; no fleet-root write; no refused-work (feed-token derivation, token totality, release-clock tokenizers) touched.

Scratch note: `/fast/scratch/hyaku/kagi-r31/ReviewD2/` was removed after the receipt and report were written.
