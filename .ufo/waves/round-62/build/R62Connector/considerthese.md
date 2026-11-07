# considerthese Mining — kagi round 62 (R62Connector)

- **Date**: 2026-11-07
- **Seat**: R62Connector (connector)
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Source Directory**: `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/` (read-only; operator reflections)
- **Files Swept**:
  - `2026-10-19.md`
  - `2026-10-20.md`
  - `2026-10-21.md`
  - `2026-10-22.md`
  - `2026-10-23.md`
  - `2026-10-24.md`
  - `2026-10-25.md`
  - `2026-10-26.md`

---

## 1. Inventory of Proposals Across the considerthese Archive

| File Date | Proposal # | Description | Status in Lane / Fleet |
|---|---|---|---|
| `2026-10-19.md` | 1 | Commit-time close-out gate (`corpus/close-gate.sh`) | Implemented in round 21/24 as QM5/QM12 and `claim-ledger.sh --host-safe`. |
| `2026-10-19.md` | 2 | Hash-pin every probe a verdict cites | Partially implemented; sources carry fetch hashes and pins. |
| `2026-10-19.md` | 3 | Pin op CLI version with the byte contract | Historical; op substrate absent on current host. |
| `2026-10-19.md` | 4 | Make the-janitor's absence an explicit verdict | Implemented in round 18 as `substrate-deferral.md` and R18-01. |
| `2026-10-19.md` | 5 | Seed Capabilities table and declare saturation | Implemented in round 21. |
| `2026-10-19.md` | 6 | Widen dotenv byte contract (CRLF, BOM, NUL) | Landed in round 21. |
| **`2026-10-20.md`** | 1 | Host-safe `verify` mode automating QM12 | Landed in round 24 (`claim-ledger.sh verify --allow-host-rows`). |
| **`2026-10-20.md`** | **2** | **A standing fail-open suite for every gate (adversarial inputs run alongside `--selftest`)** | **STILL UNIMPLEMENTED** as a standing gate standard. **SELECTED**. |
| `2026-10-20.md` | 3 | Qualifier check before admission (QA9, made checkable) | Landed as QA9 / QA10 in round 21/22. |
| `2026-10-20.md` | 4 | Track outside agreement as calibration number | Landed in verifier spot-checks; recorded in SCORECARD. |
| `2026-10-20.md` | 5 | Check quotes, not page hashes, for source freshness | Landed in round 24 (`corpus/rendered-text-v1.py`). |
| `2026-10-20.md` | 6 | Make history edits append-only by gate | Landed as QM14 and `revision-audit.py`. |
| `2026-10-21.md` | 1 | Enforce host boundary with OS sandbox (`bwrap`) | Refused for trusted repo inputs; carried debt. |
| `2026-10-21.md` | 2 | Round-sequencing gate (`round-gate.sh`) | Landed partly as `round-conformance.py` in round 28. |
| `2026-10-21.md` | 3 | Finish row identity for count-only selftest rows | Addressed in round 24/25. |
| `2026-10-21.md` | 4 | Seat quorum and provider fallback | Addressed by UFO wave policy. |
| `2026-10-21.md` | 5 | Point next round at domain depth | Landed in rounds 30, 31, 33, 48–61. |
| `2026-10-21.md` | 6 | One-page operator digest per round | Open; handled via round reports. |
| `2026-10-22.md` | 1 | Put op release clock on dotenv contract | Carried over; op substrate absent. |
| `2026-10-22.md` | 2 | Standing malformed-feed fixture library for release-clock | Landed as `corpus/feed-token-agree.py` in round 29. |
| `2026-10-22.md` | 3 | Make conformance check non-vacuous on argv | Landed in round 28/29. |
| `2026-10-22.md` | 4 | Enforce seat paths and seat quorum mechanically | Landed in wave harness. |
| `2026-10-22.md` | 5 | Spend next round on GitHub Actions OIDC | Landed in round 31. |
| `2026-10-22.md` | 6 | Resolve or retire lone-clone INCOMPLETE | Landed in round 25 (R11-08/R11-09). |
| `2026-10-23.md` | 1 | Give open round an age and closing obligation | Addressed in fleet driver. |
| `2026-10-23.md` | 2 | Let clocks run when no round is running | Rejected as autonomous cron; on-demand only. |
| `2026-10-24.md` | 1 | Create `considerthese/BACKLOG.md` | Proposal for tracking; not a claim. |
| `2026-10-25.md` | 1 | Differential tokenizer test on feed path | Landed as `feed-token-agree.py` in round 29. |
| `2026-10-25.md` | 2 | "Quoted gate output must have a receipt" check | Addressed as routed defect D5 in round 62 (not a claim). |
| `2026-10-25.md` | 3 | Round-shape validation before dispatch | Handled by validator. |
| `2026-10-25.md` | 4 | Record refusals and quota deaths in wave record | Documented in wave JSON. |
| `2026-10-25.md` | 5 | Pre-flight sensitivity check on claims | Addressed in planning. |
| `2026-10-26.md` | 1 | Repair-only release path under a HOLD | Stale; lane is open and unblocked. |
| `2026-10-26.md` | 2 | Machine-readable lane status | Already implemented (`SCORECARD.md:14`). |
| `2026-10-26.md` | 3 | Mark known-defective instrument output | Underlying defect fixed in round 45. |
| `2026-10-26.md` | 4 | Create `considerthese/BACKLOG.md` | Unchanged tracking proposal. |

---

## 2. Selected Proposal

- **Source File**: `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/2026-10-20.md`
- **Proposal Date**: 2026-10-20
- **Proposal Text**:
  > **2. A standing fail-open suite for every gate.**
  > For each gate, keep a set of adversarial inputs that *should* be rejected (malformed ids, duplicate headers, path escapes, tier inflation, Unicode look-alikes, trailing whitespace) and require all of them to fail. Run it alongside `--selftest`. The census bugs from round 21 were found only because a reviewer thought to try them.

---

## 3. What It Points At

The proposal points directly at a chronic structural failure mode across software testing and verification gates:
1. **Nominal vs. Load-Bearing Self-Tests**:
   A gate or counter author writes a `--selftest` mode that runs on happy-path synthetic data and exits 0. The suite demonstrates that the code *can* produce a 0 exit code under ideal inputs, but proves nothing about whether it actually discriminates bad data.
2. **Reviewer-Discovered Gaps vs. Standing Invariants**:
   Adversarial inputs (such as negation tokens, swapped pairings, printer stubs, or constant-verdict mocks) are typically discovered post-landing by human reviewers, critics, or mutation-testers in ad-hoc waves. Because these adversarial inputs are rarely codified into the gate's permanent, automated self-test battery, regressions re-enter silently whenever the code is touched.
3. **The Unreached Aggregation Anti-Pattern**:
   In counter scripts, a `--selftest` often verifies small isolated helper functions while completely bypassing the main aggregation logic (the code that decides whether `value=0` or `value=5`), allowing constant-return mutants to survive undetected.

---

## 4. Why It Is Still Unimplemented Across the Lane

In `considerthese/2026-10-21.md` §Status of yesterday's suggestions, the reflection noted:
> *Standing fail-open suite per gate (#2): partly. Falsify waves with mutation testers now run every round and selftests keep growing (a 151-case paired fixture regression in round 24), but the adversarial cases still come from fresh seats each round rather than a standing per-gate suite; M24-8 shows the cost.*

Subsequent reflections through `2026-10-26.md` kept carrying this proposal over as an open suggestion. While individual rounds added ad-hoc fixtures when caught by reviewers, the lane never established a formal quality criterion or architectural standard requiring every gate and counter to carry permanent, standing fail-open adversarial suites that must fail when the gate is mutated.

---

## 5. Direct Fit with Round 62 Claims

Round 62's two declared claims in `plans/round-62.md` directly embody and instantiate Proposal 2:

### 5.1 Fit with Claim C1 (Calibration)
- **The Defect**:
  In round 61, the C1 checker (`plans/round-61-c1-check.py`) tested items I3..I7 for token presence only. The reviewer discovered 5 bypass trees (B3..B7) that kept every required token while asserting the exact opposite (negating statements with `not withdrawn`, `no three`, `not rewritten in place`, or swapping fraction/percentage numbers `3/16 = 25 %`). The baseline checker graded all five bypass trees as `value=0` (accepted 5/5).
- **The Round 62 Realization**:
  The hardened checker incorporates a 5-token preceding window check for negators and paired fraction/percentage validation, driving accepted bypasses from $5 \rightarrow 0$.
- **Standing Fail-Open Enforcement (Kill Rule K5)**:
  `plans/round-62.md` explicitly mandates that the checker's permanent `--selftest` must include the 5 bypass cases (the adversarial inputs that must fail closed) alongside 3 paraphrase cases (benign variants that must pass), and proves that inverting a verdict mapping or dropping an item's polarity test causes `--selftest` to fail.

### 5.2 Fit with Claim C2 (Operability)
- **The Defect**:
  The baseline C2 counter (`plans/round-61-c2.sh`) had two glaring holes:
  1. Its `--selftest` never executed the aggregation blocks (`decide` and `shims`), so replacing either with a constant `value=5` or `shims_ok=5` still passed `--selftest` cleanly;
  2. Its `guard` logic did not check whether the trial actually produced expected observables, so a printer-stub trial that printed nothing still read `guard=1`.
- **The Round 62 Realization**:
  The hardened counter makes its self-invocation mode execute both `decide` and `shims` over both positive and negative vectors.
- **Standing Fail-Open Enforcement**:
  - Mutant M-A (replacing `# BEGIN-DECIDE` .. `# END-DECIDE` with `  echo 5`) and Mutant M-B (replacing `# BEGIN-SHIMS` .. `# END-SHIMS` with `  shims_ok=5`) MUST cause `--selftest` to exit non-zero printing a named `FINDING`.
  - Guard challenge G proves that a valid-sha256 stub trial without observables reads `guard=0`.
  - Leg (c) proves that a constant-verdict stub counter is rejected by the counter's own stub control.

---

## 6. Grounding: Quality Criteria and Lesson Draft

Proposal 2 directly grounds the normative work assigned to seat `R62ScribeRecords` in `plans/round-62.md` §Wave plan:

1. **Grounds QUALITY Criteria `QM81` and `QM82` (`corpus/QUALITY.md`)**:
   - **`QM81` (Standing Adversarial Fail-Open Suites for Verification Checkers)**:
     *A verification checker or structural validator must incorporate a standing battery of adversarial fail-open cases (bypass fixtures, negation injections, swapped pairings, and malformed structures) in its permanent `--selftest`; a checker whose `--selftest` only evaluates valid positive inputs or whose assertions pass when an item's discrimination check is removed carries a nominal suite, not a gate.*
   - **`QM82` (Executable Aggregation and Mutant Refusal in Counter Self-Tests)**:
     *A measurement counter or scoring gate's `--selftest` must directly execute its aggregation and decision logic over both positive and negative vectors; a counter whose `--selftest` evaluates only helper functions, leaves its decision unit unreached, or passes when its aggregation is replaced by a constant verdict violates operability and must be refused by stub controls.*

2. **Grounds `corpus/lessons/round-62.md`**:
   - In §Mistakes: Resolves M61-8 (the C2 counter having no independent oracle and an unexercised aggregation in selftest) and the five reviewer bypasses (QM79 bypass class).
   - In §Bounds: Formulates the principle that while structural window checks narrow bypass classes, standing adversarial suites in `--selftest` are required to maintain that protection against future regression.

---

## 7. Decision

**ADMITTED**.
Proposal 2 from `considerthese/2026-10-20.md` is selected as the sole unimplemented proposal from the `considerthese/` archive that fits Round 62's claims. It grounds the round's falsification architecture, kill rules, and the drafting of QUALITY criteria QM81 and QM82.

Receipt written to `.ufo/waves/round-62/build/R62Connector/considerthese.md`.
