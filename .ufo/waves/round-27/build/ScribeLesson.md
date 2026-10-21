# ScribeLesson — round-27 lesson skeleton and C2 Mistakes row (KagiR26.ScribeLesson-17)

Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (HEAD equals BASE).
Working tree is dirty (`git status`: `corpus/release-clock.py`, `corpus/self-counts.tsv`,
`corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/*`, untracked
`corpus/lessons/round-27.md`, `.ufo/waves/round-27/`). Every BASE citation below
is `git show 0a47dd18…:<path>`. Working-tree citations are labelled "working tree".

Scope: the lesson skeleton (provenance trio, Gate, one Mistakes row for the
inherited inequality-firing defect, limits). C1 is not assessed here except
where it touches the lesson.

Writes: this report only. `corpus/lessons/round-27.md` is read-only to me, so the
skeleton is given inline below for L1 to integrate. Nothing was installed or
updated. No selftest, gate, `c2-measure.py`, `c1-measure.py`, network fetch or
vault/host read was run. Only `read`, `git show`, `grep`, `awk`, `tr`, `sha256sum`
and `ls`.

## 1. Findings that change the draft

| # | Finding | Evidence |
|---|---|---|
| F1 | The Mistakes row's "fix shown able to fail" has no after-run. No `c2-after.json` exists. The selftest cases exist only in the working tree and are unrun by me. Until L1 runs `c2-measure.py` at the after revision, the row must say UNRUN, not "shown". | `ls .ufo/waves/round-27/` lists only `c2-before.json`; `git diff BASE -- corpus/release-clock.py` adds the cases |
| F2 | The draft cites `.ufo/waves/round-27/c1-before.json` (for M27-2). That file is absent. The M27-2 citation is broken. | `ls .ufo/waves/round-27/c1-before.json` → No such file |
| F3 | The draft cites QM25 and QM26 as if committed. At BASE, `corpus/QUALITY.md` has 0 matches for QM25/QM26 and ends at QM24 (line 126). They exist only in the working tree (lines 132-133). | `git show BASE:corpus/QUALITY.md \| grep -c 'QM25\|QM26'` → 0 |
| F4 | The draft cites S042 as "§11.2". The fetched body has no rendered "11.2". The located sentence sits under the Precedence section, unnumbered in the HTML. The "11.2" comes only from `corpus/source-fetches.tsv` column 16 (working tree line 85). The number is therefore unverified by the captured body. | `.ufo/waves/round-27/captures/S042.body`, tag-stripped: the sentence is at line 289 of the stripped text, with no "11.2" in the body |
| F5 | The fix does not refuse one class of predecessor un-fire. The evaluator checks each row only against its own anchor. S027/S028 (anchor 3.15.0) and S040/S041 (anchor 3.15.1) read the same Python feed under different source IDs, and nothing compares rows that share a feed. A predecessor observed at its own anchor is not "below" it, so the rule passes it. See counterexample C-A. | BASE `corpus/release-clocks.tsv` lines 24, 25, 30, 31; `corpus/release-clock.py:481-531` (per-row loop, no cross-row check) |
| F6 | The rollback fixture's REGRESSED findings must be exactly S040 and S041. S027/S028 are not refused by the after rule at 3.15.0, because they equal their own anchor. The lesson must not say "predecessor un-fire refused". | `.ufo/waves/round-27/tools/c2-measure.py` FIXTURES `rollback`; `corpus/release-clock.py:524-528` at BASE |

Confirmed (read-only):
- Round-26 limit: `corpus/lessons/round-26.md:230-237` (BASE) names "the evaluator defines fired as observed-version unequal to anchor, not strictly newer. A stale/cropped feed could regress and un-fire an older anchor; no monotonic-history guarantee is made." This is the inherited defect the Mistakes row cites.
- BASE inequality code: `corpus/release-clock.py:524` (`norm_version(observed) != norm_version(anchored)` → fired), `:527` (equal → not-fired); `observe_one` `:730-734` the same rule on the live feed.
- BASE parser: `parse_latest_version` returns the max stable X.Y.Z (`:699`), so the observation is the newest stable, which is the value that can regress.
- "captured-by none" holds at BASE: `git show BASE:corpus/release-clock.py | grep -n -i 'downgrade\|older\|regress'` returns nothing. No selftest at BASE exercises a downgrade.
- `c2-before.json` (working-tree artifact, not re-run by me) records at revision BASE: `lie` exit0 `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 …)`; `rollback` exit0 `CLEAN (… fired=3 …)`; `control` exit0 CLEAN; `changed_rows` lie `[S040]`, rollback `[S027,S028,S040,S041]`. `downgrades_accepted_clean: 2`. Its scratch dir `/fast/scratch/kagi-r27-c2-9fmmkqxt` no longer exists, so the record cannot be reproduced from the directory.
- Gate quotes, byte-for-byte after tag strip: S042 "Major, minor, and patch versions are always compared numerically." (9 words, present). S043 "Comparison and ordering of release segments considers the numeric value of each component of the release segment in turn." (19 words, present). S043 "Last updated on Oct 12, 2026" (present). S043 also states "the shorter segment is padded out with additional zeros as necessary", which supports the draft's "zero-padding not implemented" note.
- Digests: `captures/S042.body` sha256 `f9d4b8b1…9fb9409e` and `S043.body` `4e53ed83…f3eb5442` match `captures/metadata.json` and `corpus/source-fetches.tsv` column 10 (working tree). Normalized digests (col 15) also match. Column 3 is `row_identity_sha256` per the file header (lines 6-9), not a body digest.
- Registry count: BASE `corpus/SOURCES.md` has 41 `| S### |` rows; S042/S043 are added in the working tree (lines 49-50). "41 → 43" is right for the working tree only.
- Working-tree selftest additions: five `run_case` entries plus one live downgrade feed observation (a `cases += 1`), so "six new cases" matches the diff. Not executed.

## 2. Counterexamples (inference from code reading; none executed)

C-A (cross-row predecessor un-fire passes). Two receipts for the same Python feed URL: S027's receipt parses 3.15.0 (verdict not-fired, equal to its anchor 3.15.0); S040's receipt parses 3.15.1 (not-fired, equal to its anchor). Each row validates against its own receipt. The rule finds no `REGRESSED`, and the evaluator reports CLEAN. Here S027/S028 read as un-fired and CLEAN is printed. The after rule does not catch it, because no per-row observation is below its own anchor. Needs a feed-level consistency check: all bound rows sharing a feed URL must agree on the observed version. [INFERENCE from `release-clock.py:481-531`; not run.]

C-B (non-numeric anchor keeps the inequality). S012 anchor `v1.21.x` (BASE `release-clocks.tsv:9`). An observation `1.20.9` (feed served older) gives `norm_version` ≠ anchor → fired, counted, CLEAN. This is the declared limit in plans/round-27.md, not a bug in the fix, but the lesson must name it as an accepted counterexample. [INFERENCE.]

C-C (single-row rollback to a predecessor anchor with no successor). If the successor rows S040/S041 were absent, a whole-feed rollback to 3.15.0 would un-fire S027/S028 with no REGRESSED. This is the reason C-A matters and why round-26's successor rearm (QM24) carries the refusal. [INFERENCE from BASE `release-clocks.tsv` rows 24-31.]

C-D (prerelease observations, low reach). `is_regression` needs strict X.Y.Z, so `3.15.0rc1` against anchor 3.15.1 falls back to inequality and fires. `parse_latest_version` (BASE `:685-699`) only admits exact `vX.Y.Z` titles, so the reach is limited to a text-file or plain-text path. [INFERENCE; not checked.]

## 3. Skeleton for `corpus/lessons/round-27.md` (for L1; not written by me)

```
source: S042, S043
verified-at: 2026-10-21 — SemVer 2.0.0 and PyPA version-specifiers pages fetched with curl-fsSL-compressed-v1; quotes located under rendered-text-v1; no vault/account/handler/CDP contact
recheck: 180d — re-open both specifications after any change to corpus/release-clock.py; re-run the C2 measure (round-27 tools) at the after revision

# Round 27 — knowledge-entry numbers bound; release clocks refuse numeric regression

Frozen BASE: 0a47dd189356ea66ec83c3891eed54526e95b89b. Claims: plans/round-27.md (C1 calibration, C2 freshness).

## Gate — sources opened and decided
[table: S042 ADMIT (quote "Major, minor, and patch versions are always compared numerically." sha f9d4b8b1…, located once, the §11.2 number is NOT rendered in the body — cite the Precedence section); S043 ADMIT (quote "Comparison and ordering of release segments considers the numeric value of each component of the release segment in turn.", sha 4e53ed83…, located once, page "Last updated on Oct 12, 2026"); REJECT completeness/monotonic-feed inference; REJECT lexical/date ordering]

## C2 — regression is a finding
[state the working-tree rule only AFTER L1 runs it; until then, describe as proposed]
Declared limits: non-numeric anchors (S012 v1.21.x) keep inequality (C-B); no feed-level consistency check across rows sharing a feed (C-A, unless fixed); prerelease (C-D).

## Mistakes
| id | class | evidence | captured-by | fix / counterexample |
|---|---|---|---|---|
| M27-1 | survivor: inequality accepted as release | round-26.md:230-237 (FinalRearm names it); BASE release-clock.py:524,527,730-734; no BASE selftest for downgrade (grep empty); c2-before.json lie exit0 fired=4, rollback exit0 fired=3 | none — QM23 asks for an observable identity, not an ordered one | numeric REGRESSED rule + selftest cases; after-run c2-measure: UNRUN until executed (expected changed-rows REGRESSED: S040 for lie; S040,S041 for rollback); QM25 is working-tree only at BASE |
| M27-2 | number-drift (knowledge entries outside the binder) | c1-before.json is ABSENT — cite the actual measurement record or mark UNRUN | QM21 | KN-* bindings and corrections; QM26 working-tree only |

## Limits
- C2 orders numbers only; C-A cross-row feed disagreement, C-B non-numeric anchors, C-D prerelease, and feed completeness are not covered.
- A REGRESSED finding needs human re-verification of the feed; it does not establish vendor rollback.
- C1 binds a reviewed population, not every digit.
```

## 4. Limits and what I did NOT check

- No gate, selftest, measure tool, or build was run. Every "pass" above is absent. `c2-before.json` is cited as recorded, not reproduced.
- Working-tree code was read through `git diff`, not executed. Its selftest cases are unverified.
- No live network fetch. I used the captured bodies in `.ufo/waves/round-27/captures/` and their recorded digests.
- The §11.2 numbering was not checked against the SemVer source's section numbers. Only the body text and the source-fetches column were read.
- C1 was not assessed: no `self-counts.tsv` bindings, no knowledge-entry numbers, no `knowledge-migrations.json`. The `c1-before.json` absence (F2) was observed by `ls` only.
- Fleet MANIFEST and the round-26 outside closure were not verified; I relied on the lesson's own citations of them.
- Ledger pins in `corpus/claim-ledger.tsv` were not read.
- The outside admit/reject spot-check is pending and is not claimed.
- C-A, C-B, C-C, C-D are code-reading inferences, not executed counterexamples. Each needs a fixture run by L1 to become evidence.

Tooling: none installed or updated. Channel and version: n/a.

Report: `.ufo/waves/round-27/build/ScribeLesson.md`.
