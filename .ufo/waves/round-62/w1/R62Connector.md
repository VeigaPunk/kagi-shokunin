# R62Connector — Sibling-Overlap Sweep, Considerthese Mining, and Non-Obvious Move

- **Seat**: R62Connector (connector) · kagi round 62 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
- **Claim BASE**: `60b5b7b60b76629633110a5b4adac883193c8b2a` (round-61 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-62.md` (`8e5463c7937dccdd97fd5a812b8091f83b708aa7`)
- **Declared Claims / Target Axes**:
  - **C1 — Calibration (accepted 5 → 0)**: The C1 checker's negation / swapped-pairing bypass class is closed (`C1_BYPASS: accepted = the number of the five committed bypass fixtures B3..B7 on which the measured tree's checker prints value=0 when GUARD = 1, else FAIL`; target 0, BASE 5, POP = 5).
  - **C2 — Operability (killed 0 → 3)**: The C2 counter's guard and self-invocation can fail (`C2_HARDENED: killed = the number of the three falsifier legs that fire over POP = 3 — M-A, M-B, G — when GUARD = 1, else FAIL`; target 3, BASE 0, POP = 3).
- **Answering Model**: `google-antigravity/gemini-3.8-flash`
- **Committed Receipts**:
  - `.ufo/waves/round-62/build/R62Connector/sweep.md` (sibling-overlap sweep across all 21 lanes)
  - `.ufo/waves/round-62/build/R62Connector/considerthese.md` (unimplemented proposal mining and grounding)
- **Scratch**: Cleaned before yield (leaf subagent scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62Connector/`)

---

## 1. Scope & Declared Claims

Round 62 executes against two tightly coupled verification and calibration claims declared in `plans/round-62.md`:

1. **Claim C1 — Calibration (Target: 0, BASE: 5)**:
   - Evaluates the C1 checker (`plans/round-61-c1-check.py`) over five frozen bypass fixtures (B3..B7) and three paraphrase fixtures (P3..P5) for items I3..I7:
     - B3: `**A3 item 2 is not withdrawn**` (forgery) vs P3: `**A3 item 2 is hereby withdrawn**` (benign);
     - B4: `the round introduced no three new record defects it did not route` vs P4: `this round did introduce three new record defects it did not route`;
     - B5: `it was not rewritten in place at` vs P5: `it was rewritten in place, at`;
     - B6: `the paragraph's times are correct.` (forgery omitting superseded stamp quote);
     - B7: `so the literal reading is 3/16 = 25 %, and counting the sentinel as an attack seat gives 4/16 = 18.75 %` (swapped numbers).
   - Hardened grammar introduces:
     - A 5-token preceding window check before the asserting token, truncated at `.`, `;`, or `:`, rejecting negator tokens (`not`, `no`, `never`, `neither`, `nor`, `without`, `none`, `n't`), with the idiom `not only` exempt;
     - A paired expression check for derived fractions and percentages (`3/16 = 18.75 %` and `4/16 = 25 %`);
     - P3..P5 must still read `value=0` (no false positives on benign rephrasings).
   - At BASE: B3..B7 all read `value=0` (accepted = 5). On candidate: accepted = 0.

2. **Claim C2 — Operability (Target: 3, BASE: 0)**:
   - Evaluates the C2 counter (`plans/round-61-c2.sh`) across three falsifier legs over $POP = 3$:
     - **M-A**: Replacing `# BEGIN-DECIDE` .. `# END-DECIDE` with `  echo 5` causes `--selftest` to exit non-zero printing a named `FINDING`;
     - **M-B**: Replacing `# BEGIN-SHIMS` .. `# END-SHIMS` with `  shims_ok=5` causes `--selftest` to exit non-zero printing a named `FINDING`;
     - **G**: A tree whose trial file is a valid-sha256 stub printing no expected observables reads `guard=0` on the unmutated counter.
   - At BASE: M-A survives (exit 0), M-B survives (exit 0), and stub trial reads `guard=1` (killed = 0). On candidate: killed = 3.

---

## 2. Sibling Overlap Sweep Across All 21 Fleet Lanes

A read-only sweep was conducted across all 21 `*-shokunin` repositories under `/home/vgpnk/Projects/shokunin/` across their governance and knowledge directories (`PROVINCE.md`, `SKILL.md`, `corpus/knowledge/`, `corpus/lessons/`, and `plans/`) for the terms: `mutation`, `negation`, `polarity`, `selftest`, `guard`, `bypass`.

### Sweep Table

| Sibling Lane | Paths Evaluated | Relevant Hits Found | Status & Domain Classification | Duplicate vs. Adjacent |
|---|---|---|---|---|
| `audio-shokunin` | `PROVINCE.md`, `corpus/knowledge/`, `corpus/lessons/` | `PROVINCE.md:14` (engine source mutation refuse); `knowledge/2026-10-12-threshold-calibration.md:5,33` (rule polarity, duration comparator polarity); `lessons/round-101.md:10,30` (side-effect guard, positive-control oracle mutation) | Audio DSP & acoustics: waveform synthesis, sample polarity, RMS floor guards. Zero vault relevance. | **Adjacent** |
| `chousa-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/`, `corpus/lessons/` | `SKILL.md:80,86-93,124,136` (gate selftest suites, `inference-ground` lexical polarity tool, `cjk-polarity-check.py`); `knowledge/claim-verification-r2.md:93,119` (literal contradiction `marker`); `knowledge/gate-baseline-r8.md:132` (selftest mutation resistance); `knowledge/denylist-r22.md:1` (path-start bypass) | Research methodology & citation verification: citation contradiction markers, quote verification, lexical polarity flips. Zero secrets custody. | **Adjacent** |
| `game-dev-2d-shokunin` | `PROVINCE.md`, `corpus/lessons/` | `PROVINCE.md:10` (engine source mutation refuse); `lessons/r101-seq-replay-transcript-pin.md:27,59` (transcript mutation); `lessons/r103-export-divergence.md:120` (gate evasion mutations); `lessons/r21-signal-exit.md:10` (signal exit guard) | 2D game development (Godot): input replay, button focus, headless node lifecycle. Zero vault custody. | **Adjacent** |
| `game-dev-3d-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:33` (source mutation refuse); `SKILL.md:46,48,189` (mutation matrix in r101-mutation-tester, runtime actor mutation); `knowledge/unreal-mcp/executability/actors-scene.md:10,153` (actor mutation hazard) | 3D game development (Unreal Engine MCP): live editor actor mutation, static descriptors. Zero secrets ops. | **Adjacent** |
| `kaidoku-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:148` (RISC-V ELF bypass); `SKILL.md:134,315,623,740-767` (supersession guard table, input guards); `knowledge/2026-10-13-r5-01-riscv-bypass.md` (e_machine patch bypass); `knowledge/2026-10-19-arc3-r6-viair-dispatch-shape.md:22` (inverted calldatasize guard); `knowledge/2026-10-19-arc3-r12-go-evidence-id-domain.md:25` (mutation of path fields) | Binary reverse engineering: Ghidra architecture bypass, packed ELF reader seams, calldatasize guards. Zero secrets custody. | **Adjacent** |
| `kake-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:188,513,575` (selftest tallies); `SKILL.md:212-224` (c93–c98 conditional request evaluation gates, selftests); `knowledge/accessibility-review-cards.json:316-322` (WCAG 2.4.1 Bypass Blocks); `knowledge/instrument-receipts.md:21,90` (selftest mode in receipt binding) | Webzites publishing & HTTP semantics: conditional request evaluation, sitemap audits, WCAG bypass blocks. Zero vault custody. | **Adjacent** |
| `kama-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/`, `corpus/lessons/` | `PROVINCE.md:17,310,321` (census waiver boundary shims, interpretation pins mutant); `SKILL.md:309-323` (pre-report gate selftest, survivor probe); `knowledge/error-is-not-a-verdict.md:5-43` (error vs mutation kill); `knowledge/instrument-run-agreement.md:41-48` (corpus guard); `knowledge/late-acceptance-rule.md:74-82` (L1 mutation battery, selftest arms) | Model serving runtime & endpoints: memory-fd sealing, model probe mutation matrices, error vs mutation kill credit. Refuses secrets. | **Adjacent** |
| `kasegi-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `SKILL.md:167,551,981-983,1065,1068` (positive polarity in manifests, limb mutation testing `limb-mutation-check.py`); `knowledge/capture-intake-gate.md:3,57-67` (push-protection bypass); `knowledge/claim-anatomy-sample.md:39,78` (submit guard polarity inversion); `knowledge/claim-gates.md:23-24,136-138` (artifact polarity); `knowledge/claim-package-gate.md:5,12` (polarity in manifest) | Bug bounty platform packages: push-protection bypass tokens, artifact polarity in manifests, limb mutation testing. Zero vault custody. | **Adjacent** |
| `kengaku-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:20,138,284,304,340,483` (hermetic grader selftest, attribution calibration selftest, own-gate mutation tests); `SKILL.md:155,166,510,571,596-605` (grader mutation tests, `grader_perturb.py`); `knowledge/grader-perturbation-audit.md:13,51` (perturbation polarity, negative controls); `knowledge/instrument-registry-derivation.md:14,28` (selftest unbacked checks) | Model evaluation & benchmark calibration: grader perturbation, response format invariance, eval grading. Zero vault custody. | **Adjacent** |
| `kotoba-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:14,27` (checklist verifiers, mutation battery); `SKILL.md:14,289,471,522` (negation in `trigger.no_placeholder`, compound clause guard G9, `check_mutation_battery.py`); `knowledge/checklist-execution-round15.md:140,298` (negation window `no/not/never/avoid/without`); `knowledge/compound-clause-citation-round63.md:31,66` (G9 clause guard); `knowledge/erratum-absorption-round62.md:7,39` (guard-disabled flip arms); `knowledge/g7-span-pinning-round64.md:9,98` (evasion cell, equivalent mutants) | Agent & skill frontmatter grammar: checklist negation windows (`no_placeholder`), compound-clause citation guards (G9), mutation battery over skill verifiers. Zero secrets ops. | **Adjacent** |
| `kotodama-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `SKILL.md:37,56,109,308-311,426-430,670-675` (packet gates selftests, rank projection mutation); `knowledge/civilizations/carthage.md:8,109,210` (anachronism guards); `knowledge/culture-material/sumptuary-law-rank-display.md:67` (price-per-ell mutation-proof schedule); `knowledge/linguistics/conlang-methodology.md:19,79,153` (syntax skeleton negation, scaffold sentences) | Fictional world-building & conlang linguistics: syntax negation, heraldic seal iconography, register law gates. Zero software crypto. | **Adjacent** |
| `kumitate-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:39` (selftest portability); `SKILL.md:183,209,505,579,607-620` (path/rerun guards, `counter-receipt.mjs --selftest`, `gate-mutants.mjs` 43 mutants, `ready-handoff.mjs` selftest); `knowledge/agent-isolation-substrates.md:5,35,92` (seat isolation guards); `knowledge/counter-receipt-discrimination.md:10,76` (counter transcript selftest); `knowledge/dispatcher-admission-surface.md:45,58` (admission guards); `knowledge/fail-closed-clock-validation.md:70,123` (NaN window guards, selftest arms) | Swarm orchestration & UFO harness: task admission, membrane lease sealing, counter receipt reconciliation, `gate-mutants.mjs` battery. Zero vault custody. | **Adjacent** |
| `lore-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/`, `corpus/lessons/` | `SKILL.md:69,80,93` (no-selftest debt, schema drift mutation); `knowledge/2026-10-12-lore-decision-table.md:34,89,164` (relation/place guards); `knowledge/r99-gate-blind-spot-table.md:1,15,30,276` (11 mutation classes, reduction detection); `knowledge/r100-crossing-arc-synthesis.md:37` (negation in clerk records) | Fictional lore & narrative canon: event dependency freeze gates, mutation blind-spot tables, timeline place guards. Zero vault custody. | **Adjacent** |
| `mado-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:20,24-33,143,180,199-201` (plan safety gate, verify selftest, globals selftest, WinDWM selftest); `SKILL.md:116,225,295,419,788-798` (mado-verify selftest, regression mutation mode, read-verb whitelist); `knowledge/arc-synthesis.md:10,62,120,160` (gate evolution 28->268, 10/10 kills); `knowledge/bar-footprint-composition-r80.md:55,77,97,146` (applyExclusive guard, area guard, selftest green); `knowledge/bar-footprint-identity-causes-r85.md:40,115` (cause selftest, 51-mutant clause) | Window management (Hyprland / WinDWM): geometry reserve guards, layer-shell footprint joins, regression mutation mode. Zero vault custody. | **Adjacent** |
| `mori-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:529,551,554,574,648-675` (selftest transport scaling, claim sweeps, counter-mutation closures); `SKILL.md:159,164-182` (mori-census selftest, silence cases, round regressions selftests); `knowledge/audit-r11.md:4,76,123,171` (selftest determinism, quota abort); `knowledge/branch-reachability-r90.md:39` (pipeline negation `!`); `knowledge/calibration-arming-r91.md:13,21` (mutant killed if red run carries declared label); `knowledge/counter-mutation-adequacy-r83.md:5,26,40` (counter selftest mutation adequacy); `knowledge/drift-pin-r10.md:11,52,217` (selftest precedence) | Resource monitoring & fleet liveness: cgroup pressure, counter mutation adequacy, shell pipeline negation, drift pins. Zero vault custody. | **Adjacent** |
| `revenger-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `SKILL.md:149,211,345,380,423-426,434-437,443-448,457,466` (message tree check selftest, `gate_probe2.sh` selftest, `receipt_probe2.sh` selftest, `probe_negctl2` gate, `census_reprobe` unadmitted gate); `knowledge/claude-red-re-bridge.md:13,21` (mitigation bypass refused); `knowledge/round-62-commonjs-require-name-evidence.md:65,331` (no guard credit claimed) | Binary reverse engineering of shipped artifacts: negative control probe (`probe_negctl2`), unadmitted census reprobe, REA bridge. Zero vault custody. | **Adjacent** |
| `souji-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `SKILL.md:21,101,111,119,135,159,192,211-231` (maintenance guard, cert evidence selftest, post-guard FIFO swap, `souji-verify.sh --selftest`, `r12-maintenance-guard.sh`); `knowledge/duplicate-verdict-byte-equality.md:74` (identity guard); `knowledge/filter-filemode-witness.md:2,62,172,219,286` (writer selftest, witness counter selftest); `knowledge/git-auto-maintenance-prunes-worktrees.md:3,16` (maintenance guard); `knowledge/jj-colocation-receipts.md:94,119` (hook/filter bypass) | Fleet repo & worktree hygiene: Git auto-maintenance prune guards, quarantine staging, filter filemode witness. Zero vault custody. | **Adjacent** |
| `tabi-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:167,203` (M5 mutation survived selftest, tameshi adjacency); `SKILL.md:216,372,867,991,1010,1104,1123,1552,1594,1606,1614,1659,1800` (mutation deltas, dynamic capture, guard-skip abort, BiDi gate selftest, model role bypass refused); `knowledge/bidi-gate-selftest-round-34.md:3,8,19` (BiDi gate selftest, 20 mutants); `knowledge/bidi-runtime-gate-v2-round-33.md:3,25,94,190` (forgery battery, sandbox guard); `knowledge/chromium-156-release-pin-recheck.md:88,106` (detached-document guard) | Browser automation & web interaction: WebDriver BiDi gate selftest mutants, chromium form detached-document guards, replay guard skip. Zero vault custody. | **Adjacent** |
| `tameshi-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:4,8,29,36,51,75,102,109,174-179` (reusable mutation method owner, recorded mutation legs, `mutate-and-run.sh`); `SKILL.md:3,9,29,70,90,122,136,159` (hermetic suites, nominal vs load-bearing mutation bar, scope-gate `--falsify`, `policy_check` bypasses); `knowledge/arm-class-matrix.md:4,64,89,122,291` (fail-closed arms, B1 scan guard inversion, kagi selftest pulse); `knowledge/fixture-shrinking-pilot.md:8,11,58,90` (staged-id guard pristine vs mutant); `knowledge/fleet-kill-rate-ledger.md:28,48,72,95,141,194` (fleet kill rates, mado 10/10, kagi 8/10, runner selftest); `knowledge/fleet-suite-census.md:5,18,56,103,134` (fleet gate census, mutation controls) | Fleet verification craft & mutation-testing method owner (`mutate-and-run.sh`, `fleet-kill-rate-ledger.md`). Applies to fleet gates as read-only primary surfaces. Each lane owns its own gates. | **Adjacent** |
| `tsukuroi-shokunin` | `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/` | `PROVINCE.md:52,96,130,176,233,284,328,375` (tameshi adjacency, mount-table guard, census selftest tallies); `SKILL.md:250,258,268,295,435,474,552-570` (census selftest, own-gate mutation kill-rate 23->13 killed); `knowledge/aur-risk-plane-ver-s7.md:89,154,163` (selftest 41/41, mutation resistance); `knowledge/boot-writers-r19.md:21,26,114` (limine snapper watcher guards); `knowledge/calibration-synthesis.md:5,57,170,306,408` (own-gate mutation 13/23->23/23); `knowledge/closeout-r11.md:5,87,123,198` (own-source mutation sweeps) | OS package & boot repair: update safety, systemd unit and limine boot guards, own-gate mutation sweeps. Zero vault custody. | **Adjacent** |

---

## 3. Analysis of Round 62's Four Target Grounds

1. **A Gate Whose Self-Invocation Mode Executes Its Aggregation**:
   - *Round 62 Context*: In C2, the counter's `--selftest` executes `decide()` and `shims()` over both positive and negative vectors, killing M-A (`decide` replaced by `echo 5`) and M-B (`shims` replaced by `shims_ok=5`).
   - *Sibling Context*: `mori-shokunin` (`counter-mutation-adequacy-r83.md` and `PROVINCE.md:673`) diagnosed the exact same flaw and extracted pure helpers (`stability`, `subject_ok`, `met_verdict`) so `--selftest` exercises the aggregation. `revenger-shokunin` (`SKILL.md:466`) rejected a census reprobe gate because its selftest never called `main`. `kumitate-shokunin` (`SKILL.md:607`) verifies exit, verdict, line count, and source digest.
   - *Verdict*: **Adjacent**. Sibling precedents prove this is a critical structural pattern across verification gates, but applied to resource gauges, RE tools, or dispatch queues. Kagi retains exclusive ownership of OpenBao seal custody evaluation.

2. **A Structural Record Check with a Polarity/Negation Test**:
   - *Round 62 Context*: In C1, the checker hardens items I3..I7 with a 5-token preceding window for negators (`not`, `no`, `never`, `neither`, `nor`, `without`, `none`, `n't`), truncated at `.`, `;`, `:`, plus paired numbers (`3/16 = 18.75 %` and `4/16 = 25 %`), driving bypass fixtures B3..B7 from accepted $5 \rightarrow 0$.
   - *Sibling Context*: `kotoba-shokunin` (`SKILL.md:289` and `checklist-execution-round15.md:140`) implements an ordered preceding window check for negator tokens (`no`, `not`, `never`, `avoid`, `without`) in `trigger.no_placeholder`. `chousa-shokunin` (`claim-verification-r2.md:93,119`) enforces contradiction markers and `INF_POLARITY_FLIP`. `kasegi-shokunin` (`claim-anatomy-sample.md:79`) checks manifest artifact polarity.
   - *Verdict*: **Adjacent**. Kotoba's checklist trigger parser is the closest fleet analogue, but evaluates frontmatter descriptions. Kagi owns record defect calibration in plans, lessons, and git commits.

3. **A Mutation-Kill Census**:
   - *Round 62 Context*: In C2, a formal kill census over $POP = 3$ falsifier legs (M-A, M-B, G) drives killed $0 \rightarrow 3$.
   - *Sibling Context*: `tameshi-shokunin` owns the generic mutation-testing methodology (`mutate-and-run.sh`, `fleet-kill-rate-ledger.md`). `kumitate-shokunin` (`gate-mutants.mjs`), `kasegi-shokunin` (`limb-mutation-check.py`), `kotoba-shokunin` (`check_mutation_battery.py`), and `mori-shokunin` (`calibration-arming-r91.md`) maintain lane-specific mutation suites.
   - *Verdict*: **Adjacent**. Tameshi owns the generic method fleet-wide; kagi owns its own gate-specific mutation census.

4. **A Guard Challenge Leg**:
   - *Round 62 Context*: In C2 leg G, a valid-sha256 stub trial without expected observables must read `guard=0`. In C1 leg (c), a printer-stub checker is refused by the counter's measure leg with non-zero exit.
   - *Sibling Context*: `tameshi-shokunin` (`guard-kill-closure.md`), `kotoba-shokunin` (`erratum-absorption-round62.md`), `kama-shokunin` (`census-waiver-boundary.py`), `revenger-shokunin` (`gate_probe2.sh`), and `mori-shokunin` (`tools/mori-control-receipt.py`) employ guard challenge legs to prevent vacuous passes.
   - *Verdict*: **Adjacent**. Kagi's guard challenges specifically target OpenBao trial argv shapes and observable emission.

---

## 4. considerthese Mining & Grounding

All 8 files in `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/` (`2026-10-19.md` through `2026-10-26.md`) were read and inventoried.

### Selected Proposal
- **Source**: `considerthese/2026-10-20.md` (2026-10-20)
- **Item**: **Proposal 2: A standing fail-open suite for every gate**
- **Text**:
  > *For each gate, keep a set of adversarial inputs that should be rejected (malformed ids, duplicate headers, path escapes, tier inflation, Unicode look-alikes, trailing whitespace) and require all of them to fail. Run it alongside `--selftest`. The census bugs from round 21 were found only because a reviewer thought to try them.*

### Analysis & Fit
1. **Unimplemented Status**:
   In `considerthese/2026-10-21.md`, the reflection noted: *"Standing fail-open suite per gate (#2): partly. Falsify waves with mutation testers now run every round... but the adversarial cases still come from fresh seats each round rather than a standing per-gate suite"*. It was carried over unformalized through `2026-10-26.md`.
2. **Direct Fit with Round 62 Claims**:
   - **Claim C1 (calibration)**: Checker bypass fixtures B3..B7 (negations and swapped pairings) are the standing adversarial fail-open suite. Kill rule K5 requires the checker's permanent `--selftest` to contain all five bypass cases and three paraphrase cases, failing when a polarity check is mutated or removed.
   - **Claim C2 (operability)**: Counter falsifier legs M-A, M-B, and G enforce that `--selftest` directly executes `decide` and `shims` over both positive and negative vectors, failing on constant-verdict replacements and refusing printer-stub trials.
3. **Grounding**:
   - **QUALITY Criteria `QM81` and `QM82` (`corpus/QUALITY.md`)**:
     - `QM81`: A verification checker's `--selftest` must carry standing adversarial fail-open inputs (bypasses, negations, malformed structures) and fail when its discriminating logic is removed; positive-only selftests are nominal.
     - `QM82`: A counter's `--selftest` must directly execute its aggregation logic with both positive and negative vectors; a counter whose `--selftest` bypasses its aggregation or passes under constant replacement fails to witness its own operability.
   - **Lesson Draft (`corpus/lessons/round-62.md`)**:
     Grounds §Mistakes (resolving M61-8: unexercised counter aggregation and stub trials) and §Bounds (structural windowed negation detection vs. semantic truth).
4. **Decision**:
   **ADMITTED**. Grounds the round's falsification architecture, kill rules, and QM81/QM82 drafts.

---

## 5. Non-Obvious Move (UFO-FSD Connector Synthesis)

### 5.1 Evidence
1. **C2 Predicate Contract**:
   `plans/round-62.md:141,144` specifies that mutants M-A (`decide` replaced by `echo 5`) and M-B (`shims` replaced by `shims_ok=5`) must cause `--selftest` to "exit non-zero printing a named `FINDING`".
2. **C1 Predicate Contract**:
   Kill rule K5 specifies that the checker's `--selftest` must contain one case per fixture class (five bypass cases and three paraphrase cases) and fail on a mutated copy.
3. **Cross-Lane Evidence on Unhandled Crashes vs. Attributed Findings**:
   - `mori-shokunin` (`counter-mutation-adequacy-r83.md` §K2 and `calibration-arming-r91.md` §2) found that a counter's `--selftest` that fails on a mutant by crashing (traceback, syntax error, or unhandled exit code) does not provide adequate kill evidence: the red run must produce an attributed, stable `FINDING` or `FAIL` token.
   - `tameshi-shokunin` (`fleet-kill-rate-ledger.md` and `arm-class-matrix.md`) proved that exit codes alone can be satisfied by setup errors (exit 127, exit 2), whereas coupling exit code $\neq 0$ with an exact `FINDING` token guarantees semantic detection.

### 5.2 Affected Axes
- **Operability (C2)**: **Improved & Hardened**. Ensures that M-A and M-B mutants are killed semantically by `--selftest` producing an attributed `FINDING` line, satisfying the frozen predicate.
- **Calibration (C1)**: **Improved & Protected**. Ensures that bypass fixture rejections in `--selftest` are cleanly attributed to the negator/pairing grammar rules rather than unhandled string errors.
- **Adjacency**: **Preserved**. Reuses the attributed finding-id convention from mori/tameshi without absorbing external tooling.

### 5.3 Proposed Move
In `plans/round-61-c2.sh` (hardened by `R62ExecC2Counter`):
1. In `--selftest`, structure the test harness to run `decide` and `shims` through both positive and negative vectors. When a negative vector fails (as happens when M-A replaces `decide` with `echo 5` or M-B replaces `shims` with `shims_ok=5`), the test harness MUST output a stable finding line:
   ```bash
   echo "FINDING C2-ST-DECIDE: decide returned $got, expected 0 on negative vector"
   ```
   or
   ```bash
   echo "FINDING C2-ST-SHIMS: shims returned $got, expected < 5 on broken vector"
   ```
   and set `failed=$((failed + 1))`, terminating with `exit 1` and printing `C2_SELFTEST: FAIL (cases=N failed=K)`.
2. In `plans/round-62-c2.sh` (the claim C2 driver), when evaluating M-A and M-B on the candidate tree:
   The driver executes `bash plans/round-61-c2.sh --selftest` on the mutated copy in scratch, capturing both stdout and exit code. It asserts BOTH:
   - `rc != 0`
   - `grep -q "FINDING" <<< "$out"`
   Only when both hold does `ma_killed=1` or `mb_killed=1`.
3. In `plans/round-61-c1-check.py` (hardened by `R62ExecC1Grammar`):
   In `--selftest`, ensure the 5 bypass cases and 3 paraphrase cases are tested against their expected outcomes (`value=1` for bypasses, `value=0` for paraphrases), outputting `FAIL <case>` when a mutant inverts the behavior.

### 5.4 Risks & Mitigations
- *Risk*: A mutant introducing a syntax error that crashes bash before any `FINDING` can be printed.
- *Mitigation*: M-A and M-B are frozen syntax-valid replacement blocks (`  echo 5` and `  shims_ok=5`). The code around `# BEGIN-DECIDE` and `# BEGIN-SHIMS` must be valid bash functions/blocks so that the replacement executes cleanly.

### 5.5 Verification
- Re-run M-A in scratch: `--selftest` exits 1, stdout carries `FINDING`, `ma=1`.
- Re-run M-B in scratch: `--selftest` exits 1, stdout carries `FINDING`, `mb=1`.
- Unmutated counter: `--selftest` exits 0, stdout carries `C2_SELFTEST: PASS (cases=N)` with $N \ge 17$.

---

## 6. Verification & Artifact Integrity Summary

1. `sweep.md` written to `.ufo/waves/round-62/build/R62Connector/sweep.md` (18,567 bytes; 21 lanes swept; hits detailed; 0 duplicates, all adjacent).
2. `considerthese.md` written to `.ufo/waves/round-62/build/R62Connector/considerthese.md` (11,628 bytes; 8 files swept; Proposal 2 from 2026-10-20 selected, analyzed, and admitted for QM81/QM82).
3. No file outside the seat's assigned write scope (`.ufo/waves/round-62/build/R62Connector/` and `.ufo/waves/round-62/w1/R62Connector.md`) was created, edited, or deleted.
4. Scratch directory cleaned up.

SEAT-STATUS: complete
