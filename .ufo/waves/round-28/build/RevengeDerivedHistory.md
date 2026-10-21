# RevengeDerivedHistory: did the C2 rule ever fire? (BASE 3553d499577084a6c98d7078906017840bbf7b28)

All `path:line` citations are at BASE `3553d499577084a6c98d7078906017840bbf7b28`. Scope: the `derived:` rows of `corpus/release-clocks.tsv` and feed rows S033–S037 of `corpus/SOURCES.md`, rounds 25–27, plus round-28 HEAD `b9a42c0` for completeness. The lane checkout was not written. BASE was extracted read-only with `git archive` into my sandbox. The replays re-implement the frozen C2 text (`plans/round-28.md` §C2): a `derived:` row's `anchored_version` must equal the version named by its `feed_source_id` row's located anchor (the anchor column). They are not the lane gate.

## Verdict
- **No. C2 would never have fired.** In all 24 revisions that carry the clock file, 0 of 15 derived anchors differ from their feed-row anchor. This includes the 13 master revisions 82745e2..b9a42c0 and 11 side revisions kept under `refs/jj/keep/*`.
- Coverage: 50 commits in all refs change `release-clocks.tsv` or `SOURCES.md`. 15 of them carry the clock file; the other 35 lack it, so C2 is vacuous there. The 15 carry 4 distinct (clock, registry) blob pairs, all replayed, 0 mismatches. The 9 other master commits that carry the file change neither file.
- No `derived:` anchor and no S033–S037 anchor was ever edited after creation in 82745e2. Round-25..27 data changes: S038 (registry, 9b755f5), S027/S028 verdict flip to fired at 3.15.1 and S039–S041 (d30c989), S042/S043 (registry, 144babc). None touches a derived row.
- Consequence: C2 is a latent guard with zero historical positives. The replay passes (no finding) on every real revision. Its first live trigger is a feed re-verification (recheck `90d`, `corpus/SOURCES.md:39-43`) that moves a located newest tag; the record contains no such event.
- Confidence: high for the data facts (direct blob reads; three replays agree). Medium for the future rule, since only the frozen text exists.

## 1. Derived rows and their feed rows (BASE)
| feed row | derived rows (`corpus/release-clocks.tsv` line) | anchored = observed | located in feed row (`corpus/SOURCES.md`) |
|---|---|---|---|
| S033 SOPS | S008 :5, S009 :6, S010 :7, S011 :8 | 3.13.3 | 3.13.3 (:39) |
| S034 Vault | S013 :10, S022 :19, S023 :20, S024 :21 | 2.2.0 | 2.2.0 (:40) |
| S035 OpenBao | S014 :11, S015 :12, S016 :13, S021 :18, S025 :22, S026 :23 | 2.7.1 | 2.7.1 (:41) |
| S037 curl | S029 :26 | 8.23.0 | 8.23.0 (:43) |

- All 15 rows were introduced in 82745e2 with verdict not-fired. In the 13 master revisions their full row tuples never change. Across all 24 replayed revisions, each feed has a single anchored value.
- Feed rows S033–S037 (:39–43) have one raw text each in every revision where they exist. On master, S033 is absent at 82745e2^ (`git show 82745e2^:corpus/SOURCES.md | grep -c S033` gave 0).
- The derived notes' dates (opened 2026-10-19..21) postdate every feed entry they copy: S033 updated 2026-07-23, S034 2026-10-15, S035 2026-10-01, S037 release 2026-10-14 (:39-43). So the copied values were current when written.

## 2. Per-revision table (master line)
Blobs are the first 7 characters of the `release-clocks.tsv` / `SOURCES.md` blobs. C2 = derived mismatches / derived rows. "widened" = non-derived feed rows a rule applied to all feed rows would flag.

| rev | round / subject | tsv / reg blob | rows | derived | C2 | fired | widened |
|---|---|---|---|---|---|---|---|
| 82745e2 | r25 candidate: creates clocks, S033–S037 | 35288f1 / 3d6dc6a | 28 | 15 | 0/15 | 1 | S012 |
| 9b755f5 | r25 falsifiers repaired (adds S038) | 35288f1 / 48c355b | 28 | 15 | 0/15 | 1 | S012 |
| 1bf3eec | r25 immutable measurements | 35288f1 / 48c355b | 28 | 15 | 0/15 | 1 | S012 |
| d30c989 | r26 rearm: S027/S028 fired at 3.15.1; S040/S041 added | 883b23e / 394465a | 30 | 15 | 0/15 | 3 | S012 |
| 65318c0 | wip, inside r26 | 883b23e / 394465a | 30 | 15 | 0/15 | 3 | S012 |
| d109c75 | r26 falsification repairs | 883b23e / 394465a | 30 | 15 | 0/15 | 3 | S012 |
| 0a47dd1 | r26 retain immutable results | 883b23e / 394465a | 30 | 15 | 0/15 | 3 | S012 |
| 144babc | r27 knowledge numbers bound (adds S042/S043) | 883b23e / cc91208 | 30 | 15 | 0/15 | 3 | S012 |
| 3fb7727 | r27 residual falsifier fixes | 883b23e / cc91208 | 30 | 15 | 0/15 | 3 | S012 |
| 29fa79b | r27 final Gate receipts | 883b23e / cc91208 | 30 | 15 | 0/15 | 3 | S012 |
| 3553d49 | r27 census-start correction (BASE) | 883b23e / cc91208 | 30 | 15 | 0/15 | 3 | S012 |
| bdf90f5 | r28 frozen claims + START census | 883b23e / cc91208 | 30 | 15 | 0/15 | 3 | S012 |
| b9a42c0 | r28 plan fixture clarification (HEAD) | 883b23e / cc91208 | 30 | 15 | 0/15 | 3 | S012 |

- Side revisions kept under `refs/jj/keep/*`, same four data pairs, all 0/15: 35288f1/3d6dc6a: e21071e, 5f2fa5a, 7b6b4a5. 35288f1/48c355b: 39e78ce, ae8f9b2. 883b23e/394465a: 7a427e9, f6ee1d0, ff1be12. 883b23e/cc91208: 184e770, 6e2e787, f891699. a66477d (parent 4587c61, not a descendant of 82745e2) has no clock file.
- 46 committed copies of `release-clocks.tsv` across all refs, including round-26 `.ufo/waves/round-26/frozen/{before,after}` and round-27 sandboxes: 3 blobs (883b23e x30, 35288f1 x12, fec3ff1 x4 = round-26 `frozen/after`). 0 mismatches, 15 derived rows in each.

## 3. Counterexamples and near-misses (none is a historical firing)
1. **Widening false positive.** `corpus/release-clocks.tsv:9` S012 is a fired row anchored `v1.21.x`; its feed S034 locates `2.2.0` (`corpus/SOURCES.md:40`). A rule applied to all feed rows flags it at all 13 master revisions. C2 must stay scoped to `derived:` rows.
2. **Whole-row parse pitfall.** Whole-row version tokens are {0.26.0, 2.2.0} for S034 (`sdk/v0.26.0` and `v2.2.0-rc1` in :40) and {8.23.0, 8.23.1} for S037 (its teaches cell says "S029's anchor names 8.23.1", :43). A whole-row parser returns AMBIG for both feeds and flags S013, S022, S023, S024 and S029 at every revision. Read the anchor column only.
3. **The own-row bypass is load-bearing for all 15.** A derived row's own registry anchor (`corpus/SOURCES.md:14-17, 19-22, 27-32, 35`) names its anchored version in 0/15 cases. The five non-derived feed rows (S012, S027, S028, S040, S041) name theirs in 5/5. `anchor_ok = is_derived or version_is_named(...)` (`corpus/release-clock.py:565-566`; helper at :341-346) is the only reason the 15 pass that check. Sharpest case: S029's own anchor says `8.23.1` (`corpus/SOURCES.md:35`) while the clock anchors `8.23.0`. C2 checks S037, not S029, so this stays unchecked.
4. **Observed binding comes with the anchor.** For not-fired rows the BASE requires observed == anchored (`corpus/release-clock.py:585-586`). Binding the anchor to the feed row therefore also binds the observed value offline.
5. **Snapshot, not live (freshness).** Feed rows recheck every `90d` (`corpus/SOURCES.md:39-43`). The derived clock rows are `on-release` (`corpus/SOURCES.md:14`, `:19`), and BADFEED forbids on-release feed rows (`corpus/release-clock.py:560`). C2 certifies agreement with a snapshot up to 90 days old. `feed_floors` (`corpus/release-clock.py:390-410`) counts derived anchors too, so a coordinated lowering also lowers the floor. That offline-CLEAN forgery is what the plan's G-fixtures target. The live observer compares the anchor with the fetched feed (`corpus/release-clock.py:794-801`) and would record `fired` for it, so the gap is offline-only.

## 4. Commands run and exit codes
- `git rev-parse --verify 3553d499577084a6c98d7078906017840bbf7b28^{commit}` → 0. `git archive <same> | tar -x -C sandboxes/RevengeDerivedHistory/base` → 0. A first attempt used a mistyped 39-character SHA (cat-file 128, tar 2); that was my typo, not a repository fault.
- `git rev-list --count 82745e2^..b9a42c0` → 13. `git rev-list --merges` over the same range → empty. `git merge-base --is-ancestor 3553d49 b9a42c0` → 0. `git merge-base --is-ancestor 82745e2 a66477d` → 1.
- `git cat-file -e 82745e2^:corpus/release-clocks.tsv` → 128 (absent, expected).
- `git hash-object` on the three working files equals `rev-parse 3553d49:` and `rev-parse HEAD:` (tsv 883b23e, reg cc912081, py e5fbbd25) → 0.
- `git log --all -- corpus/release-clocks.tsv` → 0. `git for-each-ref` → 0. `git reflog -n 8` → 0.
- `git grep -n 'derived:' 3553d499577084a6c98d7078906017840bbf7b28 -- corpus/release-clocks.tsv` → 0 (15 hits). `git grep -n -E '^\| S03[3-7] \|'` → 0 (5). `git grep -n -o -E '^\| S0(08|09|10|11|13|14|15|16|21|22|23|24|25|26|29) \|'` → 0 (15).
- Python replays, read-only `git` subprocess only: (a) 13 master revisions, 69 git calls (1 expected 128); (b) 50 commits changing either file across `--all`, 242 calls (35 expected 128 absent probes); (c) 46 committed copies, 238 calls (2 expected 128 sibling-registry probes). C2 mismatches: 0 in every run.
- `read` on BASE: `corpus/release-clock.py:336-350,390-412,560-592,780-806`; `corpus/SOURCES.md:35,39-45`.
- No installs or updates. No lane writes, no `git status`, no jj, no gates or selftests, no network.

## 5. Not checked
- Live feeds and `--observe` receipts (no network, outside the item). Round-25..27 receipts under `.ufo/waves` were not replayed.
- Other lanes and worktrees (`.tower/*`) and other repositories. Unreferenced objects (only 8 reflog entries; no `fsck`).
- The rule itself: only the frozen text was replayed. No C2 code was written or run.
- Whether `corpus/release-clock.py:565-566` was identical in earlier rounds. Only the BASE code was read; the data replay does not depend on it.
- Lesson prose and the "docs-date anchor (v3.13.0) would read fired" remark in the S009–S011 notes. The replay shows only that no revision stores a derived anchor other than the values in section 1.
- The intended semantics of the round-27 mutant sandboxes; only their data was replayed.

Lane-authored advice, not non-author closure.
