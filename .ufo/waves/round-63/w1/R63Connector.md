# R63Connector — Scoped Findings & UFO-FSD Connector Proposal

- **Seat**: `R63Connector` (connector, UFO-FSD role)
- **Round**: 63, Attempt 1, Wave `kagi-r63-w1`
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Claim BASE**: `0c07aab8df64b673a54a5113aebd7f34b622adbc`
- **Frozen Plan**: `plans/round-63.md` (`12c9e4284d6de52ba61fcc656165cd24e8b74480`, with Amendments A1/A2)
- **Receipt**: `.ufo/waves/round-63/build/R63Connector/sweep.md`

---

## 1. Evidence

Across the fleet root `/home/vgpnk/Projects/shokunin/`, all 20 sibling `*-shokunin` lanes were systematically swept (read-only) across their corpus, gates, plans, and knowledge paths for the round's declared grounds:

1. **Negation / Polarity Grammar**:
   - `chousa-shokunin` (`tools/inference-ground.py`, `corpus/evidence/round76/correction-count-v2.py`): Checks research citation inference bullets against source spans using Latin stem windows (7 words before / 3 words after) and CJK 6-character clause windows. Sourced in Tan et al. 2025 (S094) and grounded in QUALITY 69/136.
   - `kotoba-shokunin` (`verifiers/verify_skill_checklist.py:510, 1570-1588`): Single-line `no_placeholder` heuristic ignoring `TODO`/`FIXME` when preceded by `no`, `not`, `never`, `avoid`, `without` on the same line.
   - `kasegi-shokunin` (`instruments/claim-package-check.py`): Manifest artifact polarity (`"positive"` vs `"negative"`) for bug bounty packages.
   - `audio-shokunin`, `kake-shokunin`, `kaidoku-shokunin`: Audio DSP waveform polarity, accessibility test case coverage polarity, and binary RE exit polarity.
   - **Verdict**: Strictly **adjacent**. All sibling implementations operate on citations, frontmatter checklists, bug manifests, or DSP signals. Kagi uniquely applies a windowed polarity grammar to verify historical lane record corrections.

2. **Pseudo-Negation or Idiom List**:
   - Sweep of all 20 sibling lanes produced **0 hits** for `pseudo[-_ ]negat` and **0 hits** for negation idiom exception lists. Occurrences of phrases like `not merely` or `no fewer than` in sibling lanes appear solely in informal code comments (`audio-shokunin/measure_audio.py:5678`) or passive historical text captures (`kotodama-shokunin/S604.txt:4869`).
   - **Verdict**: Kagi uniquely holds the pseudo-negation concept and idiom list (`not only`, `not merely`, `not just`, `no fewer than`, `no less than` grounded by Harkema et al. 2009 ConText).

3. **Mutation-Kill Contract**:
   - `tameshi-shokunin` (`tools/mutate-and-run.sh:84-89`): Owns the fleet-wide mutation testing method and repeat-control baseline validation.
   - `kumitate-shokunin`, `kasegi-shokunin`, `kotoba-shokunin`, `mori-shokunin`, `mado-shokunin`: Implement domain-specific mutation-kill contracts over their respective harness, parser, or gauge gates.
   - **Verdict**: Strictly **adjacent**. Tameshi owns the general method; each lane governs its own gates. Kagi's C2 mutation-kill contract governs OpenBao seal trial counter and C1 checker refusal.

4. **Stub-Refusal Counter**:
   - Sibling lanes (`kumitate-shokunin/scripts/ready-handoff.mjs`, `chousa-shokunin/corpus/lessons/round-80.md`, `kasegi-shokunin/SKILL.md:1243`, `mori-shokunin/w1-results-r58.json:256`) refuse constant-verdict or printer stubs in their own gates.
   - **Verdict**: Strictly **adjacent**. Kagi's C1 leg (e) and C2 legs L3/L4 govern OpenBao trial stubs and checker printer stubs.

5. **Sentence-Scope Window**:
   - Sibling lanes (`kumitate-shokunin/corpus/lessons/round-37-verifier-spotcheck.md:315-317`, `kama-shokunin/corpus/lessons/round-87.md:41`) use sentence splitting for prose checks or citation selection.
   - **Verdict**: Strictly **adjacent**. Kagi's 24-token window truncated by `.` or `;` is uniquely designed for scoping negators and denial predicates over record assertions.

6. **Superseded-Stamp Derivation**:
   - All 20 sibling lanes feature standard `## Stale-lane` report sections, but 0 sibling lanes derive a superseded timestamp from a previous round's report §Stale-lane line.
   - **Verdict**: Kagi uniquely derives `.ufo/reports/round-60/kagi.md` §Stale-lane (`launch 15:09:28 -03`) in item I6 to enforce exact quotation of superseded timestamps.

7. **Carried Breadth Debt (`ADJACENCY_SCOPE: DEFECT`)**:
   - Executing `bash corpus/scope-gate.sh` yields:
     `ADJACENCY_SCOPE: DEFECT (census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=3 breadth_ok=0 breadth_missing=0 breadth_invalid=0 breadth_drift=5 breadth_exceeds=0 breadth_unverified=1)`.
   - **Movement**: **Not moved**. This debt is caused by substrate absence on the host (drift across opencode, local/bin, and agents child counts, plus missing chrome profile). It remains correctly reported, carried, and unabsorbed.

8. **In-Wave Dispatch vs. Plan Contradiction**:
   - `w1-spec.json` (committed `4fe6c0d`) specifies C2 `population=6` and target `killed=6`.
   - `plans/round-63.md` Amendment A2 (committed `81bd56c`, 35 seconds later) specifies C2 `population=5` and target `killed=5` because leg L5 (MutC2 S3) was proven vacuous at BASE (printing `SETUP needle-ma` with exit 2 on pristine BASE bytes). Under kill rule K1 ("a leg that already fires at BASE is vacuous and voids the claim"), counting L5 violates K1.

---

## 2. Affected Axes

| Axis | Status | Impact & Evidence |
|---|---|---|
| **Adjacency** | **Defended (9 → 9)** | Complete sibling scan confirms zero overlap with secrets/vault ops or kagi's record auditing grammar. Carried breadth debt (`breadth_drift=5 breadth_unverified=1`) is reported without absorbing external substrate maintenance. |
| **Calibration** | **Improved (9 → 9)** | C1 closes residual polarity classes on both sides: 10 forgeries accepted → 0, 6 benign rewrites rejected → 0. Negation grammar is explicitly anchored to closed house lexicons. |
| **Operability** | **Improved (9 → 9)** | C2 refuses surviving mutants over the non-vacuous population ($POP=5$, killed 0 → 5) under Amendment A2, eliminating vacuous leg L5. |
| **Freshness** | **Preserved (9 → 9)** | Admitted sources (ConText Harkema et al. 2009 for pseudo-negation/idioms; mutation testing literature) opened live on 2026-11-07 with located quotes. |
| **Depth** | **Preserved (9 → 9)** | Preserves exact token-window bounds, denial predicates, and OpenBao seal trial observable assertions. |
| **Coverage** | **Preserved (9 → 9)** | Source registry and knowledge entries expand with validated coverage. |

---

## 3. Proposed Move

**Compatible Synthesis: Closed-Lexicon Boundary Defense & A2 Population Reconciliation**

1. **Reconcile the Population Contract ($POP = 5$)**:
   - Ensure all downstream instruments (`plans/round-63-c2.sh`, `plans/round-63-controls.sh`) and final receipts (`.ufo/waves/round-63/final/c2-refusal.txt`) consistently measure and assert $POP = 5$ with target `killed = 5`, reflecting Amendment A2.
   - Scribe records and the round report must document the 35-second ordering gap between `w1-spec.json` (`4fe6c0d`) and Amendment A2 (`81bd56c`), explicitly stating that leg L5 was retired prior to candidate measurement to prevent a vacuity violation under kill rule K1.

2. **Bound the Negation Grammar as a Closed House Lexicon**:
   - Synthesizing the lessons from `chousa-shokunin` (QUALITY 69: "A polarity precision result is a bounded regression set, not a general rate"; QUALITY 136), explicitly declare in the round-63 knowledge entry and lesson that kagi's `NEGATORS`, `DENIAL_PREDICATES`, and `IDIOMS` are closed house lexicons governing historical record corrections in lane plans and lessons.
   - Do not claim or infer that this structural grammar constitutes a general NLP semantic parser. Any negation or denial structure outside these closed sets is a new routed defect, not a grammar expansion.

---

## 4. Risks & Second-Order Effects

1. **Risk of Spec / Prompt Discrepancy**:
   - Attack seats (`R63Reviewer`, `R63Critic`, `R63MutC2`) reading the initial prompt (`population=6`) might report a mismatch against the counter's candidate line (`population=5`).
   - *Mitigation*: The frozen plan's Amendment A2 is committed prior to candidate measurement. Leg `dc` and controls must verify post-A2 5-leg population consistency.
2. **Risk of Idiom Drift**:
   - If an executor adds arbitrary English idioms beyond the five declared in §C1 (`not only`, `not merely`, `not just`, `no fewer than`, `no less than`), unreviewed false passes could enter the C1 checker.
   - *Mitigation*: The 5 idioms are frozen in §C1; selftest case isolation guarantees only the declared set is active.

---

## 5. Verification

1. **Adjacency & Breadth Debt**:
   - `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh` exits 1 printing `ADJACENCY_SCOPE: DEFECT (… breadth_drift=5 breadth_unverified=1)` — correctly verifies that breadth debt is carried and unchanged.
2. **C1 Residual Polarity**:
   - `bash plans/round-63-c1.sh` prints `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 …` with exit 0.
3. **C2 Refusal under Amendment A2**:
   - `bash plans/round-63-c2.sh` prints `C2_REFUSAL: killed=5 population=5 guard=1 …` with exit 0.
4. **Pre-Freeze Controls**:
   - `bash plans/round-63-controls.sh` prints `CONTROLS: match=N mismatch=0` with 0 skips.

Receipt committed at `.ufo/waves/round-63/build/R63Connector/sweep.md`.

SEAT-STATUS: complete
