# CriticClaims — round 35 adversarial history/control audit

Axes: calibration (assigned); safety/adjacency, provenance integrity, and population stability are non-regression constraints. No admission, integration, or canonical judgment is made here.

## Evidence and execution boundary

Read `plans/round-35.md`, `controls/measure.py`, `controls/before.json`, `controls/input-identity.json`, `controls/populations-independent.json` (controls paths are under `.ufo/waves/round-35/`), AGENTS.md, corpus/QUALITY.md, the r32/r33/r34 non-author spotchecks, and the current producer implementation. Only read-only git show and sha256sum fact commands were executed; no gate, fixture, measurement runtime, selftest, clone, authenticated command, account/vault/handler contact, or production edit occurred. All counterexamples below marked static are deductions from displayed source, not observed executions. No tools installed. No scratch created, so no scratch cleanup remains.

Observed identities:

- Instrument working bytes and the predeclaration commit's instrument both hash to `e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17`.
- Producer working bytes at inspection and BASE's producer both hash to `ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a`.
- Predeclaration `63ba87afce53842007ec27c09e3469132d149abd` contains census-start plus before.json, input-identity.json and measure.py; freeze `83ba8d1aac70f0f04a2357471def9b19b2bdc794` contains only plans/round-35.md. Commit times place controls before freeze. Remote push state was not independently checked.

## Independently read population and exact predicate

The nine literal expected `(rc, finding)` pairs in measure.py:6–16 agree with before.json:

| id | expected | baseline observed in retained receipt |
|---|---|---|
| setup-number | 2, NORESULT | 0, OK — false CLEAN |
| failed-number | 2, NORESULT | 0, OK — false CLEAN |
| diagnostic-number | 2, NORESULT | 0, OK — false CLEAN |
| stderr-number | 2, NORESULT | 0, OK — false CLEAN |
| valid-zero | 0, OK | 0, OK — positive retained |
| grep-empty | 0, OK | 0, OK — positive retained |
| empty-output | 2, NORESULT | 2, NORESULT — refusal retained |
| wrong-count | 1, MISMATCH | 1, MISMATCH — refusal retained |
| clean-forgery | 2, NORESULT | 0, OK — false CLEAN |

Manual re-tally of retained rows: five mismatches, five invalid rc0 outcomes, two positive matches, nine cases. This corroborates the stored aggregate without re-executing it. Six cases expect rc2; one already refuses correctly, so “five false-CLEAN witnesses” does not mean only five invalid inputs.

Exact frozen target: `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`, exit0. Per-row match is precisely expected rc equality AND existence of a stdout line beginning `expected_finding + ' ' + id + ' '`. Expected labels are literal in the predeclared instrument, not imported from the producer's verdict. They are authored bounded contract expectations, not external truth or outside agreement.

## Falsifiable findings

### F1 — unchanged producer remains a blocker to claiming the repair

**Counterexample/evidence:** At inspection the canonical producer is byte-identical to BASE. Its lines258–270 ignore every producer status except timeout124, remove stderr evidence with the extraction, and parse the final digit run of the last nonblank stdout line. Consequently the five retained baseline false-CLEAN witnesses are still explained by the shipped code. Baseline before.json is observed historical execution; no fresh replay was run here.

**Impacted axes:** calibration; provenance integrity if unchanged bytes are cited as repaired.

**Smallest safe correction:** L1 must install the actual candidate and bind its changed source hash to fresh complete nine-case after output using the unchanged instrument. A report-only change, an integer score, or selftest-case growth is not the requested repair. This is a snapshot finding, not an assertion that a concurrently developed candidate is defective.

### F2 — frozen counter does not enforce complete whole-process verdict integrity

**Strongest static counterexample:** For setup-number a script can print `NORESULT setup-number fabricated` followed by `PREFREEZE: CLEAN (controls=0 mismatch=0)` and exit2. measure.py:24–25 calls that case a match despite the contradictory final summary. It also accepts duplicate/opposite findings and arbitrary stderr. A script branching on the controls filename could emit analogous expected labels/rc for all nine cases without executing any producer; all aggregate fields would then reach the literal target by source logic. This is a static adversarial construction, NOT a reported successful mutant run and NOT evidence that any candidate does this.

**Evidence:** measure.py checks `any(line.startswith(...))`, not final summary, unique finding, measured value, control count, gate stderr, or actual producer invocation. script_sha256 is recorded, not checked against input-identity.json; --base is caller-supplied. The plan's stronger kill conditions therefore require independent enforcement outside this frozen counter. The before/after report cannot treat its `match` booleans as proof of all those conditions.

**Impacted axes:** calibration and execution provenance.

**Smallest safe correction:** Do not amend or replace the frozen instrument. L1/non-author review must inspect each retained raw stdout/stderr and final summary, require the expected single case outcome and consistent final verdict, verify the exact BASE and frozen instrument hash, and inspect candidate code for actual execution rather than fixture-name lookup. Treat a contradiction or fabricated producer path as a blocker, even if the literal aggregate is green. The weakness limits the strength of the evidence; it is not by itself proof the candidate fails C1.

### F3 — syntactic producer integrity is not semantic producer honesty

**Static counterexample:** A dishonest producer can simply print `0` and exit0; a pipeline can mask an upstream error and finish with valid integer output. The new contract cannot distinguish this from the valid-zero positive control. Even rc1 plus zero is only a permitted status/output shape, not proof the command was grep or that zero is true.

**Evidence:** The frozen plan explicitly excludes dishonest valid integers and masked-upstream pipelines. The independent expectation values certify the nine fixed paths, not arbitrary shell-command truth.

**Impacted axes:** calibration if generalized; safety/adjacency if “verified” is extended to terminal authorization or private host state.

**Smallest safe correction:** Preserve the exact limitation in installed docs and report. Repair invalid result acceptance only; do not reject the valid-zero control to manufacture soundness, widen the predicate, or claim a sandbox/authentication guarantee. This is an accepted bounded tradeoff for canonical review, not a new target requirement.

## History attacks and their dispositions

- **r32 residual red / estimated BASE:** r32 spotcheck:45–67 re-derived 8→1, not frozen0, leaving non-owned SD6 untouched. Current before receipt has actual public-path outcomes and a matching BASE producer hash, addressing an estimate-only baseline. Non-owned SD6 must remain outside C1; an overall-red gate cannot be renamed overall CLEAN because this subset succeeds.
- **r33 false execution provenance:** r33 spotcheck:139–149 found claims that M7 failed and relative-work was re-tested without shipped-byte receipts. Fresh candidate receipts must identify actual bytes, argv/cwd, stdout/stderr and exit; neither a patch, source inspection nor this critic report is an execution receipt. r33's capability acceptance must not retroactively rescue its rejected coverage claim.
- **r33/r34 population coupling:** r33 spotcheck:69–82 found captures82 versus frozen111. r34 spotcheck:47–58 found rows/captures88 versus87 and sourced14 versus13 after the S088 migration coupled claims. Round35 wisely makes one nine-case causal population, no registry append and no new entry. populations-independent.json states rows88, entries35, sourced14, captures88, legacy21, consistent with r34 closure; that JSON alone contains no counting command or execution provenance. Its numbers were read, not independently re-censused by this seat. L1 should supply independently sourced before/after invariants, without converting them into new exact C1 targets or deleting valid S088 provenance.
- **r34 missing/SETUP mapped to zero:** r34 spotcheck:31 and92–97 identify this concrete failure class. Five invalid false-CLEAN witnesses plus already-refused empty output and wrong-count controls target it directly. Do not alter historical r34 awk or regrade its bounded claim.
- **Scores versus state:** Scalar9 is neither evidence of zero mismatches nor premature saturation. All-nine scores can coexist with real calibration defects; the frozen five→zero observation, not score movement, is the claimed improvement. No new capability, expansion, promotion, live-vault success or independent agreement follows from C1.

## Safety and ownership boundaries

R25-02 FAIL and R29-01/R29-02 POLICY remain routed, not cleared. Current SCORECARD lane-status explicitly retains all three. No private/ref/account/handler commands are necessary to exercise the fixed public cases. No non-owned SD6 edits, registry identity changes, rewritten historical receipts, or second oracle authority are justified by this repair. L1 holding planner is a disclosed deviation, not this seat's authority to grant a waiver.

## Handoff and self-check

Actionable blockers are F1 if unchanged producer bytes are offered as final, and F2 if contradictory/forged receipts are offered as sufficient evidence. F3 is the plan's stated limit. No final candidate or after.json was evaluated; no assertion of successful repair or canonical rejection is made.

Self-evaluation (not a lane score): accuracy4 (source-grounded; static counterexamples not executed), completeness4 (all assigned historical/control attacks covered; final candidate unavailable to this snapshot), clarity4 (findings separate blockers from limits), actionability4 (specific L1 evidence corrections; no instrument change), conciseness4 (history context adds length). Overall4.0. Highest-value improvements belong to L1: attach changed-source execution receipts and apply the whole-process consistency review. The user should agree this is an adversarial evidence report, not an admission.

Report: .ufo/waves/round-35/build/CriticClaims/report.md
