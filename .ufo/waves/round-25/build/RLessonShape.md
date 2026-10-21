# RLessonShape — round-25 lesson shape (kagi-shokunin, read-only)

Seat `KagiR25.RLessonShape-2`, leaf, read-only. Lane HEAD = BASE `4587c61a348e4528717404a68912c373f3ef4d03` (`git merge-base --is-ancestor 4587c61a… HEAD` → exit 0). Installs: none. Writes: this report and the sandbox `/fast/scratch/kagi-r25/RLessonShape-2/lane` (`git clone -q --no-hardlinks`, `checkout -q 4587c61a…`) only. Not run: `verify`/`cells` on any tree; C1–C3 counting commands (not this seat's item).

Summary: `lessons/round-25.md` does not exist yet; required sections and IDs are §2–§3. Round-24's lesson lacks a spot-check section although MANIFEST rounds[399] holds 4 non-author rows (§4.1). Three plan hazards (§5 P1, P3, P4); `plans/round-25.md` is untracked (§1).

## 1. Exact command evidence
Lane, read-only, BASE (CORPUS.md:131-148 census, lane root):
- `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` → `32`; malformed (NF≠13) → `0`; tier `A=30 C=2`; status `mined=29 queued=1 rejected=2`; duplicate ids, enum/inflation, mined-used-by-missing → empty, exit 0; `on-release` rows (awk `$11`) → `28`; highest id `S032`.
- `git ls-files plans/round-25.md .ufo/waves/round-25 | wc -l` → `0` (untracked). `git status --short` → `?? .ufo/waves/round-25/`, `?? plans/round-25.md`; a third entry `?? corpus/__pycache__/` appeared mid-read (not this seat; all python ran in the sandbox).
- `git rev-list --count 4f94b52a..4587c61a` → `14`; `git merge-base --is-ancestor 8a4ecbbd… 4f94b52a…` → exit 0 (2 commits between).
Sandbox BASE clone, `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`:
- `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=32 A=30 B=0 C=2 queued=1 mined=29 rejected=2 entries_sourced=4 legacy=21 captures=32 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0.
- `bash corpus/row-identity.sh stamps` → `count=83` exit 0; `… ledger-ids` → `count=61` exit 0.
MANIFEST.json (`?q=` reads): `rounds[399]` = closure, round 24, `commit kagi-shokunin@4587c61a…`, `trends {expansion unchanged, quality improved, discernment improved}`, `verification.source_spotchecks` = 4 rows, all `agree` (S027 admit, S029 admit, S030 reject, R24-C6 reject). `rounds[379]` = round-23 closure, `commit 8a4ecbbd…`.

## 2. Required sections of `corpus/lessons/round-25.md`
Glob of `corpus/lessons/*round-25*`: no match. Precedent = round-24 state.

| # | Section | Rule (file:line) | round-24 precedent / state |
|---|---|---|---|
| 1 | `source:` / `verified-at:` / `recheck:` header | CORPUS.md:18-20; by convention rounds 22–24 | round-24.md:1-4, present |
| 2 | `# Round 25 —` · `Frozen starting revision` · claims · no-vault/no-host boundary | plan:1-10 | round-24.md:6-15 |
| 3 | `## Plan corrections (named, append-only)`, ids `R25-Cn` | CORPUS.md:53-60 | round-24.md:17-36 |
| 4 | `## Gate`: per new row URL, access date, ≤25-word quote + location, located count, decision; reject as `REJECTED: …; flip: …` | CORPUS.md:101-102, 112-115 | round-24.md:38-52; **no per-row date column** |
| 5 | status/recheck/used-by old→new log (write `none` if none) | CORPUS.md:116-118 | round-24.md:74-93, present |
| 6 | `## Spot-check`: non-author, ≥1 admit + ≥1 reject, agree/disagree + reason | LEARNING.md:42-48 | **absent**; pending form round-21.md:74-79; decisions round-23.md:143-146 |
| 7 | `## Routed defect dispositions`: D1–D2, one typed disposition each (`fixed` needs pointer; note ≥24 chars) | closure-dispositions.py:21-27, 62-63 | round-24.md:95-129; bullets `- **D1 fixed**` miss gate regex `^- D(\d+)\b` (py:65) |
| 8 | `## Before → after`: claim · before (frozen base) · after · counting command, for C1–C3 | PROTOCOL.md:96-99; CORPUS.md:34-38 | round-23.md:56-62; round-24 prose, counts uncommanded (round-24.md:166-176) |
| 9 | One claim sourced to an `S###` row (C3) | PROTOCOL.md:138-142 | — |
| 10 | `## Source accounting`: census before→after (§1 line) | PROTOCOL.md:138-139, 156-159 | round-23.md:179-188; absent in round-24 |
| 11 | `## Mistakes`: ONE table, `M25-n`, class (vocabulary) · evidence file:line · captured-by · fix | CORPUS.md:171-176; PROTOCOL.md:139-141 | round-24 split over three places: two tables and prose (§4.2) |
| 12 | Red-before per fix, failing output committed | CORPUS.md:179-184 | mention only (round-24.md:148) |
| 13 | Trend verdicts: cite the non-author closure; never self-assign | LEARNING.md:26-35, 40-48 | MANIFEST rounds[399].trends; self-assessed SCORECARD.md:654-659 |
| 14 | Limits: what the round does not establish | QUALITY.md:22 (QA3) | round-23.md:190; round-20.md:44 |

## 3. Lane conventions and next free IDs (BASE)
- IDs: plan correction `R<N>-C<n>` → **R25-C1** (round-24.md:17); ledger row `R<N>-<nn>` → **R25-01** (claim-ledger.tsv:58-79, highest R24-16); round claim `C<n>` (plan:18-71). Keep namespaces apart.
- Mistake `M<N>-<n>` → **M25-1** (round-22.md:33; round-24.md:148). Routed defect `D<n>` restarts per closure (plan:12-15 routes D1–D2).
- Source row `S<nnn>` → **S033** (registry highest S032). Criteria: last QM20 (QUALITY.md:107), last QA10 (:71) → next **QM21 / QA11**, under `## Criteria from … (round 25)` (QUALITY.md:89, 102 precedent).
- Count rule `<number> — <command> <date>` (CORPUS.md:34-38; QA6 QUALITY.md:25). Verdict words: improved · harmed · unchanged · unprovable-but-better (LEARNING.md:28-29). The lane must not declare conformance; that verdict is the aggregator's (CORPUS.md:61-62).
- Gate-consumable closure record (non-author, not lane-written) needs H2 `## Routed defects`, `## Discernment spot-check` (table, `admit`/`reject`), `## Adjudication` (`**ADMITTED.**`/`**REJECTED…**`) (closure-dispositions.py:12-16).
- Public-fetch UA: `kagi-shokunin-round25/1.0 (documentation verification)` (task contract); round-24 Gate used `round23` (round-24.md:41).
- Lane owns `lessons/round-25.md`; aggregator writes only `round-25-aggregator-*.md` (CORPUS.md:53-57). Corrections are appended and named (round-24.md:250, 306, 313).
- Companion artifacts: LOG.md append `## Round 25 …` with `Base`, `Frozen claims`, `Lesson` (LOG.md:1229-1232; PROTOCOL.md:154); SCORECARD pre/post sections (SCORECARD.md:865-890); SOURCES rows, `## Search log` note (SOURCES.md:50-56), Leads dispositions (:69-79); SKILL.md registry rows for new gates (PROTOCOL.md:398-400; round-24.md:99-102); ledger rows R25-nn; round report `.ufo/reports/round-25/kagi.md` with `## Sources & frontier` and `SHONEN` (PROTOCOL.md:146-168).
- Commit `plans/round-25.md` before the lesson calls it frozen (round-24.md:118-120, D7).

## 4. Round-24 shape defects not to copy
1. No spot-check section. The non-author result sits only in MANIFEST rounds[399].verification.source_spotchecks; round-24.md:283-284 ("No outside spot-check … self-certified") never cites it. Correct by appended named entry in round 25.
2. Mistakes split: M24-1–7 in `## Mistakes` (:148-154); M24-8–13 under `### Mistakes — fresh falsifiers` (:234, :238-243); M24-14/15/16 as prose (:250, :306, :313). A `## Mistakes` parser finds 7 of 16.
3. Class column: 7 of 16 rows are free text (e.g. "a count standing in for a membership", :150). The nine vocabulary terms (CORPUS.md:173-176) fill 9 of 16 rows.
4. Measured-outcome counts carry no command (round-24.md:166-176), against CORPUS.md:34-38.
5. Base citation: `4f94b52a` cites `rounds[379]`, whose `commit` is `8a4ecbbd` (ancestor, two commits earlier). State the relation.

## 5. Plan hazards and counterexamples
- P1 (C1 exemption): plan:32-33 exempts "explicitly round-dated" numbers. SKILL.md:46 is current-tense and reads "…(63 stamps + 39 claims + claim ids, round 21)". A trigger on the phrase exempts the target line itself; scope the exemption by file set (LOG/lessons/SCORECARD history), as the plan's parenthetical states.
- P2 (C1 stale ≥1): SKILL.md:46 says 63/39. BASE counters give stamps 83 (claim-ledger.tsv:68, R24-05) and claims 61 (:77, R24-14). MANIFEST rounds[399].verification reports `claims=61 stamped=83`, non-author, at 4587c61a.
- P3 (C1 row, plan:83-86): class "current-tense self-description drift" is outside the vocabulary → `number-drift`. `captured-by: none` should read `QA6 (form only)`: the command sits adjacent, but the value is not live-bound.
- P4 (C3 used-by, plan:58-66): feed rows bound through `corpus/release-clocks.tsv`, but SOURCES defines used-by as knowledge entries or lessons (CORPUS.md:107-108). All 29 mined rows at BASE comply. Cite feeds from `corpus/lessons/round-25.md`.
- P5 (C3 count): on-release = 28 confirmed (plan:57-58): 25 mined, 1 queued (S005), 2 rejected (S008, S030).
- P6 (spot-check independence): round-24's S030 reject check re-read the lane receipt `.ufo/waves/round-24/recovery-normalizer-replay.json`, not the URL (MANIFEST rounds[399].verification.source_spotchecks[2].source). CORPUS.md:114-115 requires non-author verification to re-open the sample; round-25's spot-check should reopen the URL.
- P7 (directive): no `corpus/lessons/operator-*.md` exists. Whether the 2026-10-19 tooling directive is an operator teaching (LEARNING.md:50-53) is for L1 to classify; not decided here.

## 6. Not verified (UNRUN)
- C1 `self-counts.py`, C2 lone-clone `citations`, C3 `release-clock.py`: absent in the lane; not run here.
- Round-25 Gate spot-check: UNRUN (non-author duty, LEARNING.md:42-48).
- `verify`/`cells`: UNRUN on every tree (forbidden on the real tree; not needed for shape).
