# ConnOverlap — sibling overlap scan for kagi round 44 (C1 counter-discrimination battery, C2 replay-run receipts, C3 receipt-drift correction register)

Seat: `K44ConnOverlap` (connector, leaf, read-only over siblings). Lane: `kagi-shokunin`.  
BASE: `d54109d943abc900e71613a02e5a7a2e46453c3a`. Predeclaration: `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae`.  
Plan: `plans/round-44.md` read in full; its frozen vocabulary, predicates, targets, kill rules, and controls govern this scan.  
Axes touched by scanned claims: C1 → **calibration**; C2 → **operability**; C3 → **freshness**.

---

## 1. Scope and method

### Sibling lanes scanned (20 total, kagi-shokunin excluded)
All 20 active sibling worktrees under `/home/vgpnk/Projects/shokunin/` were scanned at their observed tips:
- `audio-shokunin` (tip `f9da7ee9`)
- `chousa-shokunin` (tip `378fda82`)
- `game-dev-2d-shokunin` (tip `1e033ef0`)
- `game-dev-3d-shokunin` (tip `39ca397`)
- `kaidoku-shokunin` (tip `2a54af078`)
- `kake-shokunin` (tip `9177e658`)
- `kama-shokunin` (tip `9b4c7af1`)
- `kasegi-shokunin` (tip `d16d212`)
- `kengaku-shokunin` (tip `28e9f8bf`)
- `kotoba-shokunin` (tip `e073723`)
- `kotodama-shokunin` (tip `d41eb594`)
- `kumitate-shokunin` (tip `0bff4bab`)
- `lore-shokunin` (tip `0f044aa`)
- `mado-shokunin` (tip `24ba2a9d`)
- `mori-shokunin` (tip `973b2af1`)
- `revenger-shokunin` (tip `ff76743`)
- `souji-shokunin` (tip `893b8ef4`)
- `tabi-shokunin` (tip `58d84eda`)
- `tameshi-shokunin` (tip `f256302b`)
- `tsukuroi-shokunin` (tip `64f45b79`)

### Sweep method
Queries were executed read-only across tracked files and git object trees (`git grep -n -E`, `git ls-files`, `git cat-file`, `git show`). No file in any sibling lane, no lane production file in `kagi-shokunin`, and no fleet root file was modified. All transient commands ran in isolated scratch space or memory.

### Three claim surfaces swept
1. **Counter-discrimination batteries:** Negative fixture gates that kill known counter mutants (kagi round-43 `K43MutCounters` lineage; mado `quality/check-counter-discrimination.py`; kotoba `plans/round-86.md`; kake `c96_reval.py` `anti_table`; sibling mutant batteries or discrimination instruments).
2. **Replay-run receipts:** A committed receipt of a replay/verification gate's own run at a tip (kake round-91 `controls/replay-tip.txt` and `c91_defects.py` lineage; sibling replay receipts or runners).
3. **Receipt-drift correction registers:** A committed record naming committed-vs-re-derived value drift of historical receipts with supersession dispositions (sibling correction registers, erratum registers, drift registers).

---

## 2. Headline findings across the three claim surfaces

### Surface 1: Counter-discrimination batteries (C1 calibration)
- **Verdict: NO DIRECT OVERLAP (0); RICH ADJACENT PRIOR ART (12).**
- **Analysis:**
  - Kagi's round-44 C1 instrument (`plans/round-44-c1.sh`) represents a distinct, unprecedented instrument shape in the fleet: it is a **meta-counter battery** that applies frozen text/AST mutant recipes (`y1`, `y2`) directly to candidate counter code (`plans/round-43-c2.sh`), evaluating each counter mutant against embedded negative fixture gates (`accept-stale`, `accept-silent`, `always-refuse`) and positive control $P_0$.
  - In sibling lanes:
    - `mado-shokunin` (`quality/check-counter-discrimination.py:1-60`) tests admission counters against a 25-item control manifest (3 accept, 22 reject) to score the instrument's discrimination. This tests the counter against corrupted *inputs*, but does not mutate the counter script itself.
    - `kake-shokunin` (`.ufo/waves/round-96/c96_reval.py:13-22, 51-58`) verifies `anti_table` (preventing candidate sources from hardcoding input digests or forgery stems) and executes a 14-mutant battery against 6 negative fixture forgeries. However, the mutants are mutations of the *domain candidate script*, not mutations of the counter itself.
    - `kotoba-shokunin` (`plans/round-86.md:65-90`) tests admission counters against $K_0$ (base), $K_1$ (echo forgery), $K_2$ (hardcoded answer key), and $S$ (selftest), proving counter sensitivity against hand-crafted negative stand-in modules.
    - `souji-shokunin` (`census/round-44/c2-counter.py:1-34, 53-56`) embeds negative fixture stubs (`STUB_CLEAN`, `STUB_FINDINGS`) directly into its counter to verify that an external audit script rejects both stubs.
  - Sibling prior art pioneered the concepts of negative fixture gates, answer-key rejection, and `anti_table` source analysis, but kagi's round-44 C1 is the fleet's first committed instrument that generates and discriminates mutants of the counter instrument itself.

### Surface 2: Replay-run receipts (C2 operability)
- **Verdict: DIRECT OVERLAP (2); ADJACENT PRIOR ART (10).**
- **Analysis:**
  - Kagi's round-44 C2 claim (`plans/round-44-c2.sh`) requires a committed receipt `.ufo/waves/round-44/final/replay-at-tip.txt` of the freshness gate's own execution (`corpus/controls-replay.sh`), parsing 4 exact lines (`controls-replay: CLEAN`, `revision: <R>`, `gate-sha256: <S>`, `exit: 0`), verifying ancestry, and executing a clean-clone replay.
  - In sibling lanes, **direct structural overlap** exists in `kake-shokunin`:
    - In round 91, kake seat `ExecReplayC` generated and committed `.ufo/waves/round-91/controls/replay-tip.txt` (`revision=f4fff130a52ae6de49af5de7d568d2ee320ebfb0 exit=0 controls ok 9/9`), recording the clean replay of `.ufo/waves/round-90/controls/run_controls.sh` on a scratch clone checked out at the tip.
    - In the same round, kake counter `.ufo/waves/round-91/c91_defects.py:216-255` (`def item_c`) executed this exact replay procedure: cloning `--shared`, detaching at `--revision`, running `run_controls.sh`, and asserting `controls ok K/K` with $rc = 0$.
  - However, kake's round-91 replay was a round-specific wave defect counter, not a permanent gate in `corpus/`, and did not bind the gate's SHA256 (`gate-sha256`).
  - `tameshi-shokunin` (`tools/receipt-revision-gate.py:1-60`) provides the static contract for receipt revision binding (`ROLE=positive|verdict|control`, `rev=` resolution, ancestry checks, and digest mismatch checks).
  - Kagi's round-44 C2 synthesizes kake's execution replay with tameshi's hash-and-ancestry binding into a standing committed gate and counter.

### Surface 3: Receipt-drift correction registers (C3 freshness)
- **Verdict: DIRECT OVERLAP (2); ADJACENT PRIOR ART (10).**
- **Analysis:**
  - Kagi's round-44 C3 claim (`plans/round-44-c3.sh`) validates `.ufo/waves/round-44/controls/receipt-corrections.md` containing 3 rows for drifted round-42 control receipts (`c1-base.txt`, `c2-base.txt`, `c2-worktree-at-base.txt`), providing committed values, re-derived values, re-derive-at revision (`5f3566c`), and explicit supersession dispositions (`superseded-by: <path>` and `not-written-by-any-committed-runner`), verified by live scratch clone re-execution.
  - In sibling lanes, **direct conceptual overlap** exists in `tameshi-shokunin`:
    - In round 14, tameshi faced the exact defect where a historical receipt (`.ufo/evidence/round-13/verification.json` check `producer_before`) drifted/crashed due to a path layout bug.
    - Instead of rewriting history, tameshi established the schema-based disposition register `tools/evidence-disposition.py:1-50` and `.ufo/evidence/round-14/dispositions.json`: each row is marked `state: effective` or `state: superseded` with `reason`, `raw_receipt`, `raw_check`, and `superseded_by: ["producer_before_oracle", "producer_after_oracle"]`.
    - Tameshi's rule: "Every original expectation stays effective or explicitly superseded; the retained setup crash cannot gain mechanism credit from exit agreement alone... never rewrite the deferred-at-write text."
  - Further adjacent prior art exists in `kake-shokunin` round 20/21 (`.ufo/waves/round-21/frozen/before/corpus/lessons/round-20.md:328-360` "Inbound-pointer correction register"), which established the principle that frozen evidence remains a historical snapshot and line drift must be superseded in an append-only register.
  - Kagi's round-44 C3 advances this lineage by incorporating an **executed re-derivation leg** into the counter itself, re-running the runner at the pinned revision to verify the re-derived numbers before admitting the row.

---

## 3. Hit tables

### Classification criteria
- **overlap**: Directly implements or carries the same instrument shape or artifact role as the round-44 claim.
- **adjacent**: Same problem family, related mechanism, or sibling lesson/audit of the concept, but operating on a different unit (e.g. domain script vs counter) or running in a different mode (e.g. static check vs live execution).
- **none**: Lexical collision, unrelated usage, or false positive.

### Table A: Counter-discrimination batteries (Surface 1)

| # | lane | round | path:line | what-it-does | classification |
|---|---|---|---|---|---|
| 1 | mado | r36 | `quality/check-counter-discrimination.py:1-60` | Dedicated standing gate testing admission counters against 25 control fixtures (3 accept, 22 reject) to score instrument discrimination. | **adjacent** |
| 2 | kotoba | r86 | `plans/round-86.md:65-90` | Tests admission counter against K0 (base), K1 (echo forgery), K2 (answer key: 215 literals in `K2-hardcode-module.py:704`), and S (selftest). | **adjacent** |
| 3 | kotoba | r86 | `.ufo/waves/round-86/receipts/c1-K2-hardcode.txt:1-10` | Receipt recording rejection of K2 answer-key forgery (`G1 FAIL: 215 hardcoded literals`). | **adjacent** |
| 4 | kake | r96 | `.ufo/waves/round-96/c96_reval.py:13-22, 51-58` | Counter checks `anti_table` (no digest/stem in source), positive control, 6 negative fixtures (forgeries), and 14 candidate mutants. | **adjacent** |
| 5 | kake | r95 | `.ufo/waves/round-95/c95_conditional.py:799-825` | Counter scores candidate against 6 negative fixture forgeries and a 14-mutant battery loaded from `mutants-reval.json`. | **adjacent** |
| 6 | kake | r90 | `.ufo/waves/round-90/c90_gate.py:23-32` | Requires `anti_table ok` and 57 negative fixtures refused 57/57. | **adjacent** |
| 7 | souji | r44 | `census/round-44/c2-counter.py:1-34, 53-56` | Embeds negative fixture stubs `STUB_CLEAN` and `STUB_FINDINGS` and asserts the hidden audit rejects both. | **adjacent** |
| 8 | souji | r44 | `census/round-44/waves/w1/S44mutationtester51/report.md:1-40` | Wave attack seat running mutated detectors against frozen counter to evaluate discrimination. | **adjacent** |
| 9 | souji | r37 | `tests/fixtures/r37-drift-discrimination.py:1-40` | Tests drift tool against a 6-case synthetic fleet fixture to verify field-exact discrimination. | **adjacent** |
| 10 | tsukuroi | r31 | `.ufo/waves/round-31/measure/controls/build-c1-controls.py:1-40` | Builds K1 (sourceless forged answer key) and K2–K4 junk fixtures in sandbox clone for counter testing. | **adjacent** |
| 11 | kumitate | r51 | `.ufo/waves/round-51/w2/RevD51Rerun.md:95` | Whole-counter discrimination falsification running mutated counter variants in scratch clone. | **adjacent** |
| 12 | tameshi | r75 | `.ufo/evidence/round-75/c1-landed-battery.txt:11-15` | Landed mutant battery over `tools/wave-reconcile.py` (testing domain tool, not counter). | **adjacent** |
| 13 | chousa | r51 | `.ufo/waves/round-51/w2/R51W2MutC2Counter.md:1-25` | Wave attack seat creating manual mutations on `c2-count.py` to evaluate kill rates. | **adjacent** |
| 14 | audio | r87 | `corpus/live/r87-critic/arm-replay.py:157, 296` | Wave critic script running mutation battery over audio law claims. | **adjacent** |
| 15 | audio | r89 | `corpus/live/r89-simplifier/proofs/differential.py:49` | `class FakeClock`: audio timing mock (lexical collision with `fakeC`). | **none** |
| 16 | game-dev-3d | r84 | `reports/round-84/r84-author.md:77` | `scratch_fakechild/`: test directory name (lexical collision). | **none** |
| 17 | tsukuroi | r24 | `.ufo/waves/round-24/w1/ExecMirrorTimestamps/host-extra-pkglist.txt:1875` | `fakechroot`: pacman package listing in mirror audit (lexical collision). | **none** |

### Table B: Replay-run receipts (Surface 2)

| # | lane | round | path:line | what-it-does | classification |
|---|---|---|---|---|---|
| 1 | kake | r91 | `.ufo/waves/round-91/controls/replay-tip.txt:1-16` | Committed receipt of tip replay: `revision=f4fff130… exit=0 controls ok 9/9` for `run_controls.sh` in scratch clone. | **overlap** |
| 2 | kake | r91 | `.ufo/waves/round-91/c91_defects.py:216-255` | Counter `item_c` clones `--shared` at `--revision`, detaches, replays `run_controls.sh`, and asserts rc 0 and `controls ok K/K`. | **overlap** |
| 3 | kake | r92 | `.ufo/waves/round-92/c92_defects.py:65` | Counter re-scores frozen round-91 counter (`FROZEN91 = ".ufo/waves/round-91/c91_defects.py"`). | **adjacent** |
| 4 | tameshi | r56 | `tools/receipt-revision-gate.py:1-60` | Standing static gate validating `rev=` tokens in receipts against git objects (positive, verdict, and control roles). | **adjacent** |
| 5 | tameshi | r56 | `corpus/knowledge/receipt-revision-binding.md:1-40` | Formal specification and rules for binding receipts to git revisions and detecting content drift. | **adjacent** |
| 6 | tameshi | r12 | `.ufo/evidence/round-12/replayed-controls/command.txt:1-5` | Committed receipt recording execution command of replayed controls. | **adjacent** |
| 7 | kumitate | r86 | `.ufo/waves/round-86/controls/replay.txt:1-25` | Committed control receipt recording `rev=23235099… cmd=node … exit=1` for negative control replay. | **adjacent** |
| 8 | kumitate | r51 | `.ufo/waves/round-51/receipts/attest-run-2-replayed.txt:1-5` | Committed receipt of replayed attestation run. | **adjacent** |
| 9 | souji | r30 | `census/round-30/waves/w2/deliver-controls-replay.txt:1-10` | Seat report recording replay of `controls.sh` and `controls-amended.sh` in scratch. | **adjacent** |
| 10 | souji | r59 | `census/round-59/wave/w1/S59Reviewer/probe-controls-replay.json:1-15` | Recorded results of replaying frozen controls twice to verify determinism. | **adjacent** |
| 11 | kaidoku | r38 | `.ufo/waves/round-38/w2/R38W2C2Controls.md:1-30` | Wave 2 seat replaying seven frozen controls from first-freeze in scratch clone. | **adjacent** |
| 12 | audio | r62 | `corpus/live/r62-verifier/replay.sh:1-20` | Script replaying audio verification measurements. | **adjacent** |
| 13 | kasegi | r44 | `.ufo/waves/round-44/controls/c2-frozen-counter-replay.txt:1-12` | Compares base vs worktree stdout of frozen counter command. | **adjacent** |
| 14 | kama | r48 | `.ufo/waves/round-48/w1/out/V2Receipts/compare.md:162` | `python3 $S/replay-at-tip.py --compare` in wave artifact (transient script name, not committed receipt). | **none** |

### Table C: Receipt-drift correction registers (Surface 3)

| # | lane | round | path:line | what-it-does | classification |
|---|---|---|---|---|---|
| 1 | tameshi | r14 | `tools/evidence-disposition.py:1-50` | Standing expectation disposition gate validating schema-based disposition documents accounting for historical check drift. | **overlap** |
| 2 | tameshi | r14 | `.ufo/evidence/round-14/dispositions.json:1-60` | Committed JSON register naming drifted check (`producer_before`), failure reason, and `superseded_by: ["producer_before_oracle", …]`. | **overlap** |
| 3 | tameshi | r14 | `.ufo/evidence/round-14/correction-sweep.txt:1-60` | Text register detailing stale expectations and empirical corrections by addition. | **adjacent** |
| 4 | tameshi | r14 | `SCORECARD.md:446` | Declares quality improvement from correcting stale expectation by addition and supersession. | **adjacent** |
| 5 | kake | r20 | `.ufo/waves/round-21/frozen/before/corpus/lessons/round-20.md:328-360` | `Inbound-pointer correction register`: table superseding unqualified line pointers at commit `02b6dd0` without rewriting frozen files. | **adjacent** |
| 6 | kake | r91 | `.ufo/waves/round-91/w1/ScribeKnowledge/controls-drift.txt:1-75` | Detailed inventory recording working-tree vs committed blob drift across controls and runners. | **adjacent** |
| 7 | kasegi | r13 | `corpus/knowledge/triage-thresholds.md:424-448` | `Round-13 correction ledger (SUPERSEDES register)`: table mapping claims, source basis, and superseded targets. | **adjacent** |
| 8 | mori | r14 | `.ufo/waves/round-14/build/HistoricalCorrections.md:1-25` | Comprehensive checklist and table tracking routed defects, historical attribution, and superseding status. | **adjacent** |
| 9 | game-dev-3d | r103 | `reports/round-103/b2/corrections.md:524, 587` | Formally notes that historical failure is preserved in place and superseded by re-measurement. | **adjacent** |
| 10 | kaidoku | r3 | `.ufo/gates/citation-drift/pointer-table.json:574-588` | Table recording pre-errata observation lines superseded by round-3 errata. | **adjacent** |
| 11 | chousa | r48 | `.ufo/waves/round-48/w1-dispatch.json:234-282` | Tasks directing seats to analyze R39/R40 active-receipt drift. | **adjacent** |
| 12 | lore | r102 | `.ufo/waves/round-102/receipt.json:177, 401` | Receipt recording 25/25 surfaces dispositioned and stale pointers superseded. | **adjacent** |
| 13 | kumitate | r33 | `.ufo/reports/round-33/kumitate.md:55` | Report noting `axis-correction.json` names superseded bytes in work commit. | **adjacent** |
| 14 | audio | r68 | `reports/round-68/r68-critic.md:144` | Audit section reviewing ledger rows and prior-receipt drift. | **adjacent** |
| 15 | tsukuroi | r37 | `.ufo/waves/round-37/w1/Build11Scratch43/receipt-drift-binding.txt:1-5` | Receipt recording drift binding in scratch build (transient artifact). | **none** |

---

## 4. Verdict tally summary

| Category | Overlap (exact shape) | Adjacent (related unit/mode) | None (lexical/false positive) | Total hits |
|---|---|---|---|---|
| **1. Counter-discrimination batteries** | **0** | **14** | **3** | **17** |
| **2. Replay-run receipts** | **2** | **11** | **1** | **14** |
| **3. Receipt-drift correction registers** | **2** | **12** | **1** | **15** |
| **Total** | **4** | **37** | **5** | **46** |

### Analysis of category clusters
- **Direct Overlap (4 hits):**
  - **Surface 2:** `kake-shokunin` round 91 (`controls/replay-tip.txt` and `c91_defects.py:216-255`). Directly implements the scratch clone tip replay runner and committed replay receipt.
  - **Surface 3:** `tameshi-shokunin` round 14 (`tools/evidence-disposition.py:1-50` and `.ufo/evidence/round-14/dispositions.json`). Directly implements the machine-checkable supersession register formalizing drifted receipts with failure reasons and replacement paths.
- **Adjacent Prior Art (37 hits):**
  - Covers mado (`check-counter-discrimination.py`), kake (`c96_reval.py`, `c89_key.py`, r20 correction register), kotoba (r86 K-series controls), souji (r44 `c2-counter.py` stubs, r37 drift discrimination), tameshi (`receipt-revision-gate.py`), kasegi (r13 supersedes ledger), and mori (`HistoricalCorrections.md`).
- **None (5 hits):**
  - Lexical collisions on `fakeC` (audio `FakeClock`, game-dev `fakechild`, tsukuroi `fakechroot`) and transient script names.

---

## 5. Fleet prior art citations for later kagi rounds

A later kagi round should formally cite the following fleet prior art in its lesson (`corpus/lessons/`):

1. **For C1 (Counter-discrimination battery):**
   - Cite **`mado-shokunin`** round 36 (`quality/check-counter-discrimination.py:1-60`) and **`kotoba-shokunin`** round 86 (`plans/round-86.md:65-90`) as the fleet's foundational 1D counter discrimination gates (scoring counters against accept/reject control manifests and answer-key forgeries).
   - Cite **`kake-shokunin`** round 96 (`.ufo/waves/round-96/c96_reval.py:13-22, 51-58`) for the `anti_table` discipline (asserting that candidates do not hardcode digests or forgery stems) and frozen negative fixture sets.
   - Contrast these with kagi's round-44 C1, which established the fleet's first committed **closed 2D counter-mutation battery** applying programmatic mutant recipes directly to counter code.

2. **For C2 (Replay-run receipts):**
   - Cite **`kake-shokunin`** round 91 (`.ufo/waves/round-91/controls/replay-tip.txt:1-16` and `.ufo/waves/round-91/c91_defects.py:216-255`) as the origin of the scratch-clone replay execution pattern and committed tip replay receipt.
   - Cite **`tameshi-shokunin`** round 56 (`tools/receipt-revision-gate.py:1-60` and `corpus/knowledge/receipt-revision-binding.md:1-40`) for the static git-object revision-binding contract and ancestry verification rules.
   - Note that kagi round 44 C2 synthesizes both into the first standing counter binding gate SHA256, 40-hex ancestor commit, 4-line receipt parsing, and live clean-clone replay.

3. **For C3 (Receipt-drift correction registers):**
   - Cite **`tameshi-shokunin`** round 14 (`tools/evidence-disposition.py:1-50` and `.ufo/evidence/round-14/dispositions.json:1-60`) as the fleet's primary prior art for formalizing receipt check drift via machine-verifiable supersession dispositions (`superseded_by`, `reason`, `raw_receipt`) while retaining historical files intact.
   - Cite **`kake-shokunin`** round 20 (`.ufo/waves/round-21/frozen/before/corpus/lessons/round-20.md:328-360`) for the append-only inbound-pointer correction register principle.
   - Note that kagi round 44 C3 advances this lineage by requiring an **executed re-derivation leg** directly in the counter, re-running runners in a fresh clone at the pinned revision to verify re-derived figures before admitting supersession.

---

## 6. Proposed move (connector synthesis)

### One non-obvious move: Formalize counter-mutation recipe markers as static AST invariants (advancing Calibration & Operability)

#### Evidence from round cache & sibling scan
1. In kagi round 44 C1 (`plans/round-44-c1.sh:26-27`), the kill rule specifies fail-closed behaviour:
   ```bash
   # A recipe marker that is absent, or present more than once, in the candidate's counter
   # bytes fails the battery closed (exit 2).
   ```
2. In kake round 96 (`c96_reval.py:15-16`), the counter enforces `anti_table` as a static check over candidate source before running dynamic cases:
   ```python
   # anti_table ok (no hand-case input digest, no generated-case input digest,
   # and no forgery stem in the candidate source)
   ```
3. In mado round 36 (`quality/check-counter-discrimination.py:20-25`), the gate verifies that each reject control differs in exactly one isolated structural component.
4. In kagi round 43/44, counter mutants $y_1$ and $y_2$ rely on regex string replacement (`# N1: stale fixture` through `N1=$?`, and `# N2: silent fixture` through `N2=$?`). If an executor in a future round refactors variable names or comment headers in `plans/round-43-c2.sh`, the recipe markers could silently fail to match (leading to an exit 2 fail-closed outcome) or fail to isolate the intended mutation.

#### Affected axes
- **Calibration (improved):** Strengthens the C1 battery by guaranteeing that counter mutation recipes operate on verified, unambiguous syntax boundaries, preventing recipe drift from invalidating the battery.
- **Operability (improved):** Prevents benign formatting/comment refactors from triggering false exit 2 failures, providing deterministic static feedback before subprocess execution.
- **Freshness & other axes (unharmed):** Does not alter the frozen predicates of round 44 or modify historical receipts; purely sharpens future instrument design.

#### Proposed move
For round 45 / future kagi rounds building on C1:
- Synthesize kake's static `anti_table` pattern with kagi's C1 mutant recipes by establishing a static **counter-recipe validation pre-check**:
  Before attempting string substitution, the battery verifies that:
  1. Each mutation target block has exactly one occurrence and conforms to a strict structural grammar (e.g. `^# <MUTANT_ID>: <NAME>` through `^<VAR>=\$\?`).
  2. The candidate counter contains no hardcoded bypass nonces or blanket tokens.
  3. The post-mutation byte-copy is syntax-validated (`bash -n`) before execution.
- Record this architectural boundary in the round-44 lesson (§Limits / Future Work) as the logical evolutionary step connecting kake's static `anti_table` with kagi's dynamic counter mutation.

#### Risks and bounds
- This is a recommendation for the round lesson and future round planning; it does not mutate the frozen round-44 instruments or predicates.
- Operates strictly within lane bounds; no changes to fleet infrastructure.

#### Verification
- Verified by checking `plans/round-44-c1.sh:18-27` against `kake-shokunin/.ufo/waves/round-96/c96_reval.py:13-22`.
- Confirmed that `bash -n plans/round-44-c1.sh` exits 0.

---

## 7. Deliverable verification and environment cleanup

- **Deliverables written:**
  - Primary path: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-44/build/K44ConnOverlap/ConnOverlap.md`
  - Report trailer path: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-44/build/K44ConnOverlap.md`
- **Tooling authorization:** No new packages or tools installed; standard python3, bash, and git used. No pacman transactions executed (guard observed).
- **Working tree discipline:** Zero edits to `kagi-shokunin` tracked files, sibling repositories, or fleet-root files.
- **Scratch cleanup:** Sandbox clone created at `/fast/scratch/hyaku/kagi-r44/K44ConnOverlap` was fully removed prior to completion.

---

SEAT-STATUS: complete

Report: .ufo/waves/round-44/build/K44ConnOverlap.md
