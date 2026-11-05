# Round 44 — verifier spot-check (non-author closure)

author: hyaku closure (non-author integrator, @m_zfl)

Round: kagi 44. Claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a`; predeclaration `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae`; amendment A1 `c70bfb0b6db5c2df090034d63f9c38e935a1a786` (content revision K); candidate `0ad617a0c255a2141df8a9fa46bd6114be0bf75e`; lane final (branch `master`, `ls-remote` verified) `92c394c57bbd207978bd9ba917cf0a7dcabba8d6`. Report: `.ufo/reports/round-44/kagi.md` (fleet commit `e8ed4298881d7134868bd58601ac8bb749be429a`, author `kagi-shokunin`). This file is written by the non-author closure judge; nothing here edits a lane-authored round file. Measurements below are run against `92c394c` unless a different revision is named.

Method. Plain re-measurement over committed bytes (`git show`, `git diff`, `git cat-file`, `grep`, `sha256sum`, `wc`, `curl` for the one live source). Lane-owned counters and gates were not executed by the closure (PROTOCOL §Gate standard, Closure consequence); their readings are verified from committed receipts and marked `evidence-verified`.

## 1. Conformance (PROTOCOL §Round-robin step 1)

| check | command | observed |
|---|---|---|
| report committed by lane identity | `git -C /home/vgpnk/Projects/shokunin log --format='%an %H' -- .ufo/reports/round-44/kagi.md` | `kagi-shokunin e8ed4298881d7134868bd58601ac8bb749be429a` (commit 2026-11-05 16:41:02 -0300) |
| cited lane commits exist and are ancestors of the branch ref | `git -C kagi-shokunin merge-base --is-ancestor <h> master` for `d54109d ae9e9eb c70bfb0 0ad617a 92c394c 5f3566c 19025d9 65f66e17 542885e f2b4ec7 a918025` | all rc 0 (ancestry tested against `master`, not `@{u}`; git HEAD is detached, as expected for a jj-colocated lane) |
| cited fleet commits | `git merge-base --is-ancestor 75dd2612 HEAD` (fleet) | rc 0; report commit is an ancestor of fleet HEAD |
| lane has no uncommitted round work, is pushed | `jj-lane.sh state kagi-shokunin`; `git -C kagi-shokunin status --porcelain`; `git -C kagi-shokunin ls-remote origin refs/heads/master` | `state branch=master local=92c394c… remote=92c394c… ahead=0 behind=0 head=detached tracked=0 untracked=0`; porcelain empty; remote = `92c394c57bbd207978bd9ba917cf0a7dcabba8d6` |
| `## SHONEN` heading, one line per box | `grep -n '^## SHONEN' .ufo/reports/round-44/kagi.md`; `grep -c '^- \[' SHONEN.md` | one heading (report line 91); four `[~]` lines with pointers, one per box; lane `SHONEN.md` unchanged `d54109d..92c394c` (`git diff --quiet` rc 0) |
| report sections | `grep -n '^## ' .ufo/reports/round-44/kagi.md` | Work performed, Landed changes, Before → after measurements, Sources & frontier, Trend verdicts, SHONEN, plus the lane's own named-ceilings section — all present |
| report is real work, not a marker | read report | three named claims, evidence pointers on every work item, a landed-changes table tying each commit to its LOG entry, measured before→after per claim, SOURCES 98→99 with command |
| prompt carries the template contract | read `.ufo/prompts/kagi-round-44.md` (committed `75dd2612`) | MISSION/AXES binding (§1), 1–3 claims (§2), frontier step (§2b), L2 floor and run-15 routing (§3, §6), report contract with SHONEN (§4), commit/push scope and L0 channel (§5), hyaku addendum incl. write scope (line 448) and commit order with `landed <hash>` citation (lines 462–472). The five child-lane items are present. |
| dispatch/completion digest (watchdog, mutable) | `grep -n 'round=44' .ufo/watchdog.log` | `2026-11-05T15:35:08-03:00 launch kagi round=44 pgid=1790147 driver=hyaku-inline attempt=1` / `2026-11-05T16:41:48-03:00 complete kagi round=44; hyaku-inline attempt=1` (identical to the prompt's digest) |
| fleet leftovers | `git -C /home/vgpnk/Projects/shokunin status --porcelain` | ` M .scratch/run15-state.json`, ` M .ufo/l0-questions.md` — not lane work, not committed by this closure (the report's misroot sweep names the same two) |

Conformance is clean on the points that bar step 1 (real report, landed hashes, SHONEN heading, dispatch digest). Defects found, all status-neutral, routed in §5:

- D1 — wave composition: the prompt §3 minimum role split includes `1× scribe`; the executed wave (11 seats: executor 3, reviewer 2, critic 1, mutation-tester 1, scout 1, connector 1, sentinel 1, revenger 1) has no scribe seat, and the report's disclosed deviations name only the labrat-as-executor swap and the L1-held planner duty.
- D2 — stamp migration undercount (see §5 item 1).
- D3 — unexplained red-witness label (see §5 item 2).
- D4 — mistake classes outside the `mistakes.md` §5 vocabulary (see §5 item 3).
- D5 — unopened staged candidates recorded as "rejected candidates" in the lesson rather than under `## Leads (unopened)` (see §5 item 4).

## 2. Per-claim re-check

### C1 calibration — counter-mutation battery (target 2)

Plain measurements at `92c394c`:
- Battery absent at BASE: `git cat-file -e d54109d:plans/round-44-c1.sh` → rc 128.
- Battery present at candidate: `git show 92c394c:plans/round-44-c1.sh | wc -l` → 199; lines naming the negative fixture gates `accept-stale|accept-silent` → 8; mutant ids `y1` 13 occurrences, `y2` 13.
- Instrument pin: `git diff --quiet c70bfb0 92c394c -- plans/round-44-c1.sh plans/round-44-c2.sh plans/round-44-c3.sh plans/round-44-controls.sh plans/round-44.controls.tsv` → rc 0 (no instrument byte changed after A1; A1 is the last pre-candidate amendment).
- BASE receipts (plain read): `controls/c1-base` = 0, `controls/c1-skipfix` = 0.

Evidence-verified (committed receipts, lane counter run at the candidate; not re-executed here):
- `final/measured-at-final.txt` (revision `0ad617a0…`): `c1-real rc=0 last=2 expect=2`; `c1-skipfix rc=0 last=0 expect=0`; `c1-partial rc=0 last=1 expect=1`.
- `final/killrules-at-L.txt`: `C1 battery rc at L (kill f, expect 0): 0`; instrument pin vs A1 `0`; gate pin vs `65f66e17` `0`.

Before → after: 0 → 2 (target 2). Target met. No kill clause fired.
Ceilings the lane names and this closure accepts as stated: the always-refuse conjunct is not discriminated by any frozen receipt (B1, routed); a six-key answer-key gate sits outside the battery.
Re-measured: BASE absence, pins, BASE receipts, battery shape. Evidence-verified: the 2 / 0 / 1 readings.

### C2 operability — replay gate receipt (target 1)

Plain measurements:
- Receipt at candidate: `git show 92c394c:.ufo/waves/round-44/final/replay-at-tip.txt` → `controls-replay: CLEAN`, `revision: c70bfb0b6db5c2df090034d63f9c38e935a1a786`, `gate-sha256: fab42e1d0a6b06b3608bb6a0543fad0da37a3c4e40ad85fd9c208cfb0d9e740f`, `exit: 0`.
- Gate bytes at the cited revision: `git show c70bfb0:corpus/controls-replay.sh | sha256sum` → `fab42e1d0a6b06b3608bb6a0543fad0da37a3c4e40ad85fd9c208cfb0d9e740f` — equal to the receipt's sha.
- Receipt revision is an ancestor of the candidate: `git merge-base --is-ancestor c70bfb0 92c394c` rc 0; gate bytes unchanged `c70bfb0..92c394c` (`git diff --quiet` rc 0).
- BASE: `controls/c2-base` = 0; no committed receipt of a gate run at BASE: `git grep -l 'controls-replay: CLEAN' d54109d -- .ufo` lists only the round-43 build copies of the gate script and its diff (the literal sits in the script's own source, not in a run receipt). The gate itself is present at BASE (`git cat-file -e d54109d:corpus/controls-replay.sh` rc 0), so the BASE 0 is the absence of a receipt, not of the gate.

Evidence-verified: `final/c2-real rc=0 last=1 expect=1`; `killrules-at-L.txt` forged sha `0`, forged revision `0`, restore duty `0` dirty entries.

Before → after: 0 → 1 (target 1). Target met.
Ceilings (named by the lane, accepted as stated): a fabricated receipt naming a real green revision with the same gate bytes passes (the re-execution leg is the load-bearing fact); scheduling is refused (host state).
Re-measured: receipt fields, gate sha at K, ancestry, gate-bytes stability, BASE absence. Evidence-verified: the run and the counter's reading.

### C3 freshness — receipts-correction register (target 3)

Plain measurements:
- Register absent at BASE: `git cat-file -e d54109d:.ufo/waves/round-44/controls/receipt-corrections.md` → rc 128. Present at `92c394c` with 3 data rows (`grep -c '^| \.ufo/waves/round-4[12]'` → 3).
- Committed values at the pinned revision `5f3566c`: `round-42/controls/c1-base.txt` = `4`; `round-42/controls/c2-base.txt` = `0`; `round-42/controls/c2-worktree-at-base.txt` = `3`. All three match the register's "committed" column.
- "written by no committed runner": `git grep -c c2-worktree-at-base 5f3566c -- '*.sh'` → no match (rc 1). Matches the register's disposition.
- Superseded-by targets resolve at `92c394c`: `.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` (ok); `.ufo/waves/round-41/controls/c2-base-19025d9.txt` (ok; present at `5f3566c`).
- Re-derived column, plain: none computed by the closure (the re-derivation runs the lane's `plans/round-42-controls.sh`, a lane-owned runner).

Evidence-verified re-derivation: `build/K44ExecC3/step2-rederivation.txt` — `C1 BASE N=5`, `C2 BASE N=1`, `runner_rc=0`, `restore_cmp … identical rc=0` on all three; `build/K44ReviewC2C3/evidence/rederive-r42.stdout` repeats `C1 BASE N=5` / `C2 BASE N=1`; round-43 disclosure `.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` records `re-derives 5 (committed 4)`, `re-derives 1 (committed 0)`, `c2-worktree-at-base not written by any committed runner`. Counter fixtures: `final/killrules-at-L.txt` register-full `3`, register-wrongvals `1`. `final/c3-real rc=0 last=3 expect=3`.

Before → after: 0 → 3 (target 3). Target met.
Ceilings (named, accepted as stated): re-derivation is via the hardcoded `plans/round-42-controls.sh`; the `via` cell and the Basis line are checked as text; the Basis line's truth is not verified by the counter.
Re-measured: committed values, absence of a runner for `c2-worktree-at-base`, register presence/rows, superseded-by targets. Evidence-verified: the re-derived 5 and 1, the 3 reading, and both fixture readings.

### Harm check (all axes)

- `git -C kagi-shokunin diff --numstat d54109d 92c394c -- SCORECARD.md` → `45 0`; deletions grep empty: the SCORECARD diff is append-only. All six axis rows stay 9; the post-move block records `9 → 9` for every axis.
- `corpus/knowledge/` diff `d54109d..92c394c`: empty.
- `SHONEN.md` unchanged (rc 0). `LOG.md` `12 0`, `corpus/QUALITY.md` `10 0`, `corpus/claims-declared.tsv` `8 0` — all additions only.
- `corpus/stamps.tsv`: 7 rows changed (see D2, §5 item 1).
- Round-43 gate scripts unchanged `542885e..92c394c` (`corpus/prefreeze-control.sh`, `corpus/self-description-sweep.sh`, `corpus/surface-census.sh`: rc 0). Round-43 gate and counter unchanged `65f66e17..92c394c` (`corpus/controls-replay.sh`, `plans/round-43-c2.sh`: rc 0).
- `corpus/claims-declared.tsv` rows: round 41 = 2, round 43 = 3, round 44 = 3 (M44-9 repair present).
- `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rc 0, 99 rows (19 W04 duplicate-URL warnings, allowed).

No owned axis is harmed.

## 3. Discernment spot-check (LEARNING.md)

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S099 — admit as own-work, tier A, status `mined` (sourced basis for C3's Basis line) | admit | live: `curl -fsSL https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md` → rc 0, 97077 bytes, sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`; fleet object `git show 75dd2612:.ufo/prompts/kagi-round-44.md` identical | agree on the row's facts; reservation on tier A | Byte offset 52924 is the start of `The claim is judged on the counter, kill rule and predicate declared before data. A rule` on line 561 (§6 item 9 bullet) — located and byte-exact; 16 words, within the ≤25 rule. Reservation (recorded, not a reversal): the sentence is campaign-addendum boilerplate present in 742 committed prompts (the lane's own disclosure), and a fleet operator directive is a generous reading of tier A for the scope "freshness receipts". C3's value does not depend on it (the counter's own ceiling). |
| S099 registry row (≤25-word quote, census, append-only) | row written | `corpus/SOURCES.md` line 106; `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` → 99 (was 98 at BASE) | agree | single new row; no other row's `status`/`recheck`/`used-by` changed (`git diff` of the registry shows one added line); census `kagi ok` rc 0 |
| reject — staged `merge/kagi` themes (74 unadopted; 0 admitted) | not admitted, no row, not opened by the lane | `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/`: opened `china-gbt-17901-key-management-series.md` (source S089, samr.gov.cn GB/T 17901 series) and `trufflehog-cache-dedup-counters-r46.md` (source S220, TruffleHog `verificationcache/in_memory_metrics.go`); keyword sweep over all 81 staged files for `mutation|mutant|replay|receipt|counter|register|drift`, every hit read | agree on the decision | None of the hits is a counter-mutation battery, a replay-gate receipt or a correction register. The hits are the words "counterpart", "registered" and scanner metric counters (`trufflehog-cache-dedup-*`). The reject is a topical scope triage on unopened candidates, not an evidence-based rejection; the decision is sound and the caveat is recorded. |
| reject record form — "Rejected candidates (no row written; QM17)" in the lesson | recorded in the lesson | `corpus/SOURCES.md` `## Leads (unopened)` (line 141) and CORPUS.md §SOURCES.md rule 1 and Shape (`## Leads (unopened)`: "a lead is not evidence and never a row") | disagree with the form only | Unopened candidates belong under `## Leads (unopened)` as bullets. The frontier prompt's "rejections stay as rows" governs opened sources (CORPUS rule 1: a row is written only after opening). Routed (§5 item 4). |
| mistake fix proofs M44-2/M44-4 (sampled) | fix counts | `controls/amend-a1-redwitness.txt`: `c3-extra-row` → rc 2 (structural refusal); `c3-badvia` → 2; `c3-treedisp` → 2; `c3-nobasis` → 0; C2 unterminated fifth line → 0; `candidate-gate-missing` → rc 2; runner `--help` → rc 2 | agree on the sampled fixes; disagree with one red-witness label | The fixes are shown able to fail. The line "`C2 clean four-line receipt at BASE (expect 0: gate absent at BASE? see note): 1`" carries an expectation the file does not support: the gate is present at `d54109d` (`git cat-file -e d54109d:corpus/controls-replay.sh` rc 0), no note exists in the file, and a valid receipt over a present gate reads 1 by the counter's design. The label is wrong or unresolved; the reading is not disputed. Routed (§5 item 2). |

Discernment reading: agree on the admit and on the reject decision; disagreements are recorded as routed items, not left unlearned.

## 4. Trend verdicts (closure reading; evidence above)

- **expansion: unchanged.** `git diff --numstat d54109d 92c394c -- corpus/knowledge` empty; registry 98 → 99 with one own-work row (S099) that supports a freshness register, not a new admitted entry on uncovered ground. The LEARNING expansion observable (admitted `knowledge/` entries on uncovered ground) did not move.
- **quality: improved.** Evidence: three drifted round-42-era control receipts superseded by a register whose values were re-derived at the pinned revision (C3, 0 → 3); five fail-open or false checks repaired before any candidate measurement, each with a red witness (A1); stale stamp rows repaired (M44-10, though the record undercounts the BASE staleness — §5 item 1); QM50–QM54 added, each citing the lesson that produced it. Caveat: the gains sit in instruments, receipts and QUALITY criteria, not in an admitted `corpus/knowledge/` entry; no knowledge entry was re-verified or superseded. The grade rests on freshness of control receipts and QUALITY sharpening. A stricter reading would grade this `unchanged`; the closure does not take it, because no entry failed a re-check and no false or stale entry was left unmarked.
- **discernment: improved.** Evidence: the spot-check agrees on the admit and on the reject decision (§3); the calibration instrument discriminates both round-43 counter survivors (C1, 0 → 2) with committed negative fixtures; the wave's pre-measurement attacks were dispositioned in A1 or routed with reasons. Disagreements (§3 rows 4 and 5) are recorded here and routed.

## 5. Routed defects for the lane's next round

1. **Stamp migration undercount (D2; class: landing; route to lane round 45).** `.ufo/waves/round-44/controls/stamp-migration.txt` and lesson M44-10 say the stamp verdict was stale because of the three round-43 scripts, and attribute the four other changed rows to round 44. At `d54109d`, seven stamp rows did not match their files' bytes: `LOG.md` recorded 1783/148801 vs actual 1794/151649; `SCORECARD.md` 1595/196478 vs 1629/202119; `corpus/QUALITY.md` 218/38737 vs 227/40705; `corpus/SOURCES.md` 258/92005 vs 258/92061; plus the three scripts. Fix: an appended erratum naming the superseded text (PROTOCOL §Evidence standard, "A falsified claim in an append-only file gets a named correction entry"). Measured by: `for p in $(cut -f1 corpus/stamps.tsv); do …sha256sum… ; done` over `d54109d`, reading mismatches=7.
2. **Unexplained red-witness label (D3; class: self-description; route to lane round 45).** `.ufo/waves/round-44/controls/amend-a1-redwitness.txt`: `C2 clean four-line receipt at BASE (expect 0: gate absent at BASE? see note): 1`. The gate is present at BASE; no note exists; the reading is consistent with the counter's design. Fix: restate the expectation with its true reason, or re-run with a named expectation; append, do not rewrite.
3. **Mistake classes outside the vocabulary (D4; route to lane round 45).** CORPUS.md §Rules added from the kaika campaign: classes come from the `mistakes.md` §5 vocabulary. M44-2 (`self-description`), M44-4 (`landing/fail-open`), M44-5 (`environment leak`), M44-7 (`grammar looseness`), M44-8 (`fail-open contract`), M44-9 (`coverage of the gate itself`) are not in it. Fix: map each row to the vocabulary (for example `vacuous`, `landing`, `scope`), keeping the prose in the fix column.
4. **Unopened candidates (D5; route to lane round 45).** Move the staged `merge/kagi` inventory (scout `K44ScoutSources`) to `corpus/SOURCES.md` `## Leads (unopened)` as bullets, never rows; keep the reject decision and its flip condition in the lesson's Gate.
5. **Wave composition (D1; route to lane round 45).** The prompt's minimum split includes one scribe; the round ran without one. Disclose any role-split deviation in the report's deviation line, not only the ones the plan named.
6. **Carried, unchanged (named by the lane; accepted as ceilings):** B1 (battery always-refuse conjunct undiscriminated), plan↔manifest bijection for `claims-declared.sh` (M44-9), the round-40 report erratum (round-41/43 routed), the revenger seat's missing `SEAT-STATUS` line (counted not complete), and scheduling of `corpus/controls-replay.sh` (operator scope).
7. **For the operator, not the lane:** the four SHONEN boxes are `[~]`; the non-author evidence this spot-check gathered (SKILL.md decision tables, LOG round-3 pipeline entry, plan/gate runnability, PROVINCE scope) is recorded in this file for the promotion review. No box was written `[x]` here; promotion is operator-owned.
8. **Tier reservation on S099 (lane to justify or re-tier at next registry touch):** the row is tier A `own-work` for a campaign-addendum sentence present in 742 committed prompts; the lane's own Gate notes the boilerplate. Either justify tier A for its scope in the next round's Gate or re-tier with a `supersedes S099 —` row.

## 6. Measured vs evidence-verified (for the closure record)

- Plainly re-measured by the closure: report authorship and ancestry; lane state and remote; SCORECARD and corpus diffs; census (`kagi ok`, rc 0, 99 rows); BASE absence of plans/round-44-c1.sh, controls/receipt-corrections.md and any gate-run receipt; C1 instrument pin; C2 receipt revision and gate sha256 at K; C3 committed values at 5f3566c and the absence of any runner writing `c2-worktree-at-base`; S099 bytes (live URL and fleet object), sha256, size and offset.
- Evidence-verified (committed receipts of lane-owned counters, not executed here): C1 readings 2 / 0 / 1; C2 run `controls-replay: CLEAN` and counter reading 1, forged-receipt kill readings 0 / 0; C3 re-derived values 5 and 1, counter reading 3, fixture readings 3 / 1.
- Not re-executed by the closure: any lane gate, counter, or runner (PROTOCOL §Gate standard, Closure consequence).
