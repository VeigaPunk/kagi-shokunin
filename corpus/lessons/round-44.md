# Round 44 — instrument hardening: a counter-mutation battery (C1 calibration), a committed replay-run receipt (C2 operability), a receipt-corrections register (C3 freshness)

Frozen plan: `plans/round-44.md`, predeclaration `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae` (counters `plans/round-44-c{1,2,3}.sh`, controls runner `plans/round-44-controls.sh`, prefreeze controls `plans/round-44.controls.tsv`, BASE receipts under `.ufo/waves/round-44/controls/`).
Amendment A1 `c70bfb0b6db5c2df090034d63f9c38e935a1a786` (the wave's pre-measurement fixes; the instrument pin is re-anchored to this commit, see the plan's A1 section). Content revision K = `c70bfb0b6db5c2df090034d63f9c38e935a1a786`. Claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a`. Candidate: this round's landing commit (recorded in the report and the SCORECARD post-move section).

## Claims

- **C1 calibration — battery counter `plans/round-44-c1.sh`, target 2.** The round-43 C2 counter survives two counter mutations (M43-7: N1 leg dropped, N2 leg dropped; `.ufo/waves/round-43/build/K43MutCounters/mutants.md` rows y1, y2). The battery builds both mutants from frozen recipes, pairs each with a negative fixture gate (accept-stale for y1, accept-silent for y2), and counts a mutant only when the real counter reads 0, the mutant reads 1 and the always-refuse blanket reads 0, under a positive control P0. The no-work reading at the claim BASE is 0 (no battery file).
- **C2 operability — committed receipt of the replay gate's own run, `plans/round-44-c2.sh`, target 1.** Round-43 routed item 3: `corpus/controls-replay.sh` is run by nothing. The receipt `.ufo/waves/round-44/final/replay-at-tip.txt` names K and the gate sha256 (`fab42e1d…740f`) and records `controls-replay: CLEAN`, `exit: 0`. The counter re-executes the gate in a fresh clone of the candidate. The gate's own restore duty held on the producing run (0 dirty entries in `.ufo/waves/round-41/controls` and `round-42/controls`). Scheduling is refused (host state; named operability ceiling since round 14).
- **C3 freshness — corrections register `.ufo/waves/round-44/controls/receipt-corrections.md`, `plans/round-44-c3.sh`, target 3.** The three drifted round-42-era receipts (`c1-base.txt` committed 4 / re-derives 5; `c2-base.txt` committed 0 / re-derives 1; `c2-worktree-at-base.txt` written by no committed runner) are superseded by dated corrections, never rewritten. The counter re-executes the re-derivation at the pinned revision `5f3566c`.

## Gate

- **S099 — opened this round (admit as the sourced basis for C3's register Basis line).** Source: fleet repo `.ufo/prompts/kagi-round-44.md` at fleet commit `75dd2612`, pinned raw URL `https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md`. Access date **2026-11-05**. Re-open by the L1 and by scout seat `K44ScoutSources`: HTTP 200 on the pinned URL; sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`; 97077 bytes; the file is unchanged between `75dd2612` and fleet HEAD (`git diff --quiet`, rc 0). Located quote (16 tokens, byte offset 52924, line 561, §6 item 9): *"The claim is judged on the counter, kill rule and predicate declared before data. A rule"* — the registry row's `teaches` cell is grounded by that quote. Body saved at `.ufo/waves/round-44/capture/S099.body`.
  - Calibration note from the scout (kept): the sentence occurs in 742 committed `.ufo/prompts/*` files fleet-wide — campaign boilerplate. The row cites this lane's own committed round-44 prompt at 75dd2612, not the template (`templates/round-prompt.md` does not contain the sentence).
- **Registry change:** S099 appended (new row, tier A `own-work`, status `mined`, `used-by` corpus/lessons/round-44.md). No other row changed. Census: see the report's Sources & frontier section.
- **Rejected candidates (no row written; QM17):** the staged `merge/kagi/` themes GB/T 17901, ISO 11770, Sakura Cloud custody, ja/zh scanning vocabularies, SP 800-131A tables, TruffleHog and Betterleaks deltas, cloud-KMS and Aliyun custody, Claude Code secret-scan guards and IPA JP guideline were **not opened and not admitted**: none is the ground of any of the three claims (scout inventory `.ufo/waves/round-44/build/K44ScoutSources.md`, 74 of 74 unadopted files match no claim). Decision basis: PROVINCE scope for the round's claims; flip condition: a claim that needs one of them.
- **Discernment sample (LEARNING.md):** the round's admit is S099 (re-opened and byte-checked by the L1 and the scout; agrees). The reject half is the not-opened staged themes above — a disagreement would be a lesson, not a silent admit. The non-author closure spot-checks this sample; the round-43 closure noted its reject half as vacuous, and this round supplies a recorded one.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M44-1 | reference-drift: the register's row-2 `superseded-by` path was written from memory (`round-42/controls/c2-base-19025d9.txt`); the receipt lives under `round-41/controls/` | `plans/round-44.md` §Pre-freeze M44-1; `c3-pos` read 2 instead of 3 before the path was fixed | the counter's disposition-existence leg (caught pre-freeze, before any candidate) | path verified by `git cat-file -e`; QM50 |
| M44-2 | self-description: the C3 declared ceiling said "the legs run the named `via` file", and the counter never read the `via` cell (`bash plans/round-44-c3.sh` with bogus `via` read 3, pre-A1) | `.ufo/waves/round-44/build/K44ReviewC2C3.md` F1; `K44CriticClaims.md` D2; `controls/amend-a1-redwitness.txt` (`c3-badvia`: 2 after A1) | none (no rule said a ceiling naming a check needs a red witness) | A1-3: the `via` leg reads the cell; the ceiling is now true; QM51 |
| M44-3 | vacuous: the disposition leg `cat-file -e` accepts a directory, and awk `-F'|'` truncates a pipe-bearing cell, so `superseded-by: .ufo` satisfied the leg (read 3, pre-A1) | `K44ReviewC2C3.md` F2; red witness `c3-treedisp` 2 after A1 | none | A1-4: blob-type check and exact 8-field shape; QM50 |
| M44-4 | landing/fail-open: the controls runner accepted `base --help` as the revision, overwrote the eight committed receipts with refusal bytes and exited 0 (a live injection probe) | `K44SentinelScope.md` F1 (MEDIUM); `controls/amend-a1-redwitness.txt` runner line (rc 2 now, receipts byte-untouched) | none (no receipt-writing rule validated its revision) | A1-2: full-commit validation before any write; QM52 |
| M44-5 | environment leak: an exported `CONTROLS_REPLAY_GATE` reached the battery's P0 leg and read 0 on a valid candidate (measured: ambient accept-stale → 0) | `K44ReviewC1.md` F1 | none | A1-1: cleared at entry in the battery and the runner; QM52 |
| M44-6 | vacuous count: the C3 register leg counted only rows matching the frozen prefix; an extra row `c2-derivation-D` passed invisibly, and a row's identity was a substring match (`…c1-base.txt.old` counted) | `K44CriticClaims.md` D1; `K44ReviewC2C3.md` F4 | none | A1-4/A1-5: exact row count and exact path field; QM53 |
| M44-7 | grammar looseness: the C2 receipt grammar counted newlines, so an unterminated fifth line parsed as a valid receipt (read 1) | `K44ReviewC2C3.md` F3 | none | A1-7: `sed -n '5,$p'` must be empty; QM53 |
| M44-8 | fail-open contract: the C2 header promised rc 2 on unreadable gate bytes, but the code hashed an empty stream (`e3b0c442…`) and reached 0 by a later leg | `K44CriticClaims.md` D5 | the header contract (a comment is not a check) | A1-8: `cat-file -e` gate check, rc 2; QM51 |
| M44-9 | coverage of the gate itself: `claims-declared.sh` read CLEAN (`claims=7`) while plans for rounds 41 and 43 carried claims absent from the manifest; the gate cannot see an omission (QM41 ceiling) | `corpus/claims-declared.tsv` before this round's repair; `CLAIMS_DECLARED: CLEAN (claims=12)` after | QM41 named the ceiling but not the omission | five manifest rows added (41 C1, 41 C2, 43 C1, 43 C2, 43 C3); the gate still cannot see an omission — routed to round 45 (plan↔manifest bijection); QM54 |

Fix proofs (each shown able to fail before it counted): M44-1 (`c3-pos` 2 → 3 after the path fix); M44-2 (`c3-badvia` 3 → 2); M44-3 (`c3-treedisp` 3 → 2); M44-4 (`base --help` rc 0 → rc 2 with receipts untouched); M44-5 (ambient gate override reads 0 → cleared at entry); M44-6 (`c3-extra-row` 3 → rc 2 structural refusal); M44-7 (`c2` unterminated fifth line 1 → 0); M44-8 (`gate-absent` 0 → rc 2); M44-9 (count 7 → 12 with the omission rows present).

## Frontier

- **Calibration ground:** the round-43 C2 counter's two mutation survivors are now discriminated by a committed battery. The blanket conjunct is not discriminated by any frozen receipt (routed B1 below).
- **Operability ground:** the freshness gate has a committed run receipt at its candidate revision. Scheduling it remains operator scope (host state), named, not claimed.
- **Freshness ground:** the three drifted round-42-era receipts are superseded by a register whose values are re-executed at the pinned revision, not restated.
- Fleet prior art, recorded not claimed: kake r91 (`.ufo/waves/round-91/c91_defects.py:216-255`, a replay counter over a `--shared` clone at a revision) for C2; tameshi r14 (`tools/evidence-disposition.py`, `.ufo/evidence/round-14/dispositions.json`, a standing disposition register) for C3. Both are adjacent to the instruments here, not duplicated.

## Routed (named, not claimed this round)

1. **B1 (mutation-tester):** dropping the battery's always-refuse conjunct `[ "$Y1_AL" = "0" ]` changes no frozen receipt. A gate-ignoring y1 counter (`OVER=` in place of the override read) is credited without the conjunct. Needs a receipt that exercises the blanket leg (a fixture counter plus a runner slot); round 45.
2. **Plan↔manifest bijection for `claims-declared.sh` (M44-9):** the gate cannot see an omitted round; a `plans/round-N.md` with `## C` headings and no manifest rows must fail. Round 45.
3. **Scheduling of `corpus/controls-replay.sh` and of the round-44 battery:** host state; operator scope. Refused this round.
4. **Six-key answer-key ceiling of the round-43 C1 instrument** (round-43 routed 7; the 6-key gate still reaches the target 6): a shape-level control is a predicate amendment; no slot.
5. **Common-mode coupling C1↔C2 (critic D11):** one drifted manifest receipt byte kills C1's P0 and C2's leg (c) together; C3 is insulated. The L1 bookkeeping names a simultaneous C1+C2 kill once.
6. **Round-40 report erratum** (round-41/43 routed item): still owed; the L1 write scope covers the round-44 report only.
7. **Smoke-matrix dead pointers (critic D10):** `.ufo/waves/round-44/controls/smoke-matrix.txt` names fixture revisions whose clones were deleted; the readings stand as receipt-only evidence, corroborated by the committed BASE receipts and the A1 red-witness receipt.
8. **Revenger seat without a SEAT-STATUS line** (`K44RevengerDrift.md`): counted as not complete (QM47); its findings were used only as cited evidence (commit-level drift reconstruction, `timeline.md`), not as a settled verdict.
9. **Considerthese `2026-10-26.md`, proposals 1 and 3:** not taken. Proposal 1 is operator policy under HOLD; proposal 3 needs its own predicate and there is no separable slot (three claims frozen).
10. **Open L0 lines** (`.ufo/l0-questions.md`: r32 SD6, r38 R38-03 policy, r39 wave, r40 admission, r42 DELETED retirement form): routed around, never assumed answered.
11. **`expect-journal.sh` `*.json` discovery on a wave directory** (round-43 routed 1): a frozen-interface change; no slot.

## Assimilation

None this round. The staged `merge/kagi/` package holds 74 unadopted knowledge files, and none matches the three claims (scout inventory). The round's sourced action is S099, a fleet-authored prompt (not a staged package theme). `Assimilation: none` (no penalty).

## considerthese

The latest file is `considerthese/2026-10-26.md`; proposals 1 and 3 remain unimplemented (see Routed 9). The directory is operator-authored input and was not edited.

## Adjacency

Connector sweep `.ufo/waves/round-44/build/K44ConnOverlap.md`: 46 hit-classes over 20 sibling lanes — overlap 4, adjacent 37, none 5. The overlaps are the fleet prior art named under Frontier (kake r91 for C2; tameshi r14 for C3). No sibling implements a battery of counter-mutation negative fixtures or a receipt-corrections register with executed re-derivation at a pinned revision; the connector's proposed static recipe-validation move is recorded for a later round (Routed 1 lineage), not claimed here.
