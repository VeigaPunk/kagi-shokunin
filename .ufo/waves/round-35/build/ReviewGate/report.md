# ReviewGate — round35 adversarial review

## Findings, by severity

### P2 — calibration-axis admission is not established by the frozen counter

Recommendation, not admission: the producer-integrity repair passes C1's literal counter, but that counter alone does not demonstrate the strict calibration axis. Fleet `AXES.md:15` defines calibration as self-assessment quality, with SHONEN/SCORECARD entries matching observed repository state. `plans/round-35.md:9-18` instead measures nine gate certification decisions against independently authored producer-result expectations. No case compares a SHONEN/SCORECARD self-assessment with repository state. Existing `SCORECARD.md:706,1342` ties the gate to the lane's self-description, but an existing capability pointer is not itself a measured self-assessment discrepancy population.

L1 should retain the frozen predicate and distinguish its demonstrated gate-integrity result from an axis-admission recommendation; do not retrospectively relabel the nine cases as SCORECARD mismatches. Updating the old last-integer capability description would repair a concrete descriptive mismatch, but would still not make the frozen nine-case statistic a self-assessment mismatch statistic. No scalar increase or saturation waiver is supported by this review.

### Production implementation

No actionable defect found in the delivered candidate within the assigned producer-result cases. This is a bounded recommendation, not a universal correctness claim.

## Identities and actual execution

- BASE: `063c407494276d0c616e6c712a2e5d7aeb7e3768`.
- BASE gate SHA256: `ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a`.
- Frozen instrument SHA256: `e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17`, matching `controls/input-identity.json`.
- Reviewed candidate: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/prefreeze-control.sh`.
- Candidate SHA256: `2a0986d4e0bce5e2383ef60afe68b84036960045e7177870333b5de5424edeea`.
- Actual Linux public-path execution used BASE archive extraction, explicit PREFREEZE_REPO pointing to the lane, and exclusively owned scratch for temporary files. No clone, fixture commit, installation, or production write occurred.
- Frozen BASE replay: `MEASUREMENT_RESULT mismatches=5 invalid_false_clean=5 positive_matches=2 cases=9`, exit1.
- Frozen candidate replay: `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`, exit0.

Complete argv/cwd/exit/stdout/stderr are retained in this directory's `base-measure-process.json`, `candidate-measure-process.json`, `base-measure.json`, and `candidate-measure.json`. `candidate.diff` preserves the actual BASE-to-candidate diff. `identities.json` preserves initial identities.

## Independent adversarial cases

Driver: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ReviewGate/replay.py`.
Raw receipts: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ReviewGate/base-attacks.json` and `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ReviewGate/candidate-attacks.json`; companion `*-attacks-process.json` retain driver stdout and status. These twenty probes supplement, never amend, the nine frozen cases.

| Probe | BASE | Candidate |
|---|---|---|
| integer stdout plus stderr | CLEAN/0 | NORESULT + SETUP/2 |
| integer stdout plus whitespace-only stderr | CLEAN/0 | NORESULT + SETUP/2 |
| integer zero, rc127 | CLEAN/0 | NORESULT + SETUP/2 |
| integer one, rc1, matching expected one | CLEAN/0 | NORESULT + SETUP/2 |
| empty stdout through successful pipeline | NORESULT/2 | NORESULT/2 |
| two numeric lines | CLEAN/0 | NORESULT + SETUP/2 |
| POLICY line followed by zero | CLEAN/0 | NORESULT + SETUP/2 |
| whitespace-only stdout | NORESULT/2 | NORESULT/2 |
| zero followed by timeout | timeout/2 | timeout/2 |
| no output (`:`) | NORESULT/2 | NORESULT/2 |
| padded zero | CLEAN/0 | CLEAN/0 |
| valid zero | CLEAN/0 | CLEAN/0 |
| genuine grep-empty zero with rc1 | CLEAN/0 | CLEAN/0 |
| valid one against expected zero | MISMATCH/1 | MISMATCH/1 |
| explicit zero plus rc1 | CLEAN/0 | CLEAN/0 |
| zero without terminal newline | CLEAN/0 | CLEAN/0 |
| blank before / blank after integer (two probes) | CLEAN/0 | CLEAN/0 |
| deliberately dishonest plain integer | CLEAN/0 | CLEAN/0 (excluded ceiling) |
| hidden upstream failure, pipeline emits zero/rc0 | CLEAN/0 | CLEAN/0 (excluded ceiling) |

The exploratory driver's initial blank-before/blank-after expectations were deliberately stricter than the candidate and show `match=false` in preserved raw receipts. They are NOT frozen mismatches or claimed defects: the plan says a single nonempty integer line; candidate explicitly ignores blank lines. Do not aggregate these exploratory assumptions into C1's counter. Horizontal padding and blank-only output are distinct cases.

## Definition, callers, and invariants

Candidate lines296-320 capture stdout/stderr separately, retain process status, reject timeout, NUL, noninteger content, multiple nonempty lines, any stderr, and statuses other than rc0 or rc1-with-zero. Lines322-327 normalize unsigned decimal strings without shell integer overflow. Lines331-338 make any NORESULT final SETUP/2, otherwise preserve mismatch/1. Plain integer forgery and hidden pipeline failure remain accepted exactly as the frozen plan's exclusions state; the candidate header names this ceiling honestly.

LSP is unavailable: `read xd://lsp` returned `No such tool`. Consequently caller checks used literal search, not semantic proof. Observed affected references include `corpus/claim-ledger.tsv:93,96` (both pin the old twelve-case selftest), `SCORECARD.md:706,1342`, and historical `plans/round-34.controls.tsv:5-6` (prose-producing selftest counters). L1 must migrate active documentation/ledger expectations with installation; the candidate delivery itself does not install those sibling-owned updates. Historical frozen plans must remain historical rather than be rewritten to satisfy the new contract. No unrelated ledger, selftest, build, or host-facing gate was run.

## Residual risk and verification gaps

- This verifies the delivered candidate hash, not an eventual L1-integrated revision. L1 remains responsible for active caller/docs updates and final frozen replay on installed bytes.
- No claim that all invalid producers can be detected. Dishonest plain integer rc0 and hidden upstream pipeline failure were actually observed passing; extending the claim over them would be overreach, not a reason to change the frozen predicate.
- rc1 with zero is accepted by representation/status, not proof that grep ran; this is the declared convention, not command authentication.
- No scheduler, runtime routing, resume path, or saturation mechanism is changed here. Canonical-runtime/same-identity/resume-continuity assertions are not implicated or verified by this shell-gate diff.
- SD6 and R25-02 FAIL / R29-01 / R29-02 POLICY remain outside this review's writes and checks. No clearance is inferred.
- Candidate selftest25 was reported by ExecGate but not independently executed here; only the frozen instrument and independent public-path probes above are claimed as exercised.
- Tool installs/updates: none. Scratch is removed after durable receipts.

## Self-evaluation

Accuracy4: raw receipts and exact hashes ground results; axis-admission interpretation remains a reviewer recommendation. Completeness4: all assigned attack classes exercised; integrated callers remain L1's responsibility. Clarity4: the two stricter exploratory whitespace assumptions are explicitly separated from frozen failures. Actionability4: exact replay driver and paths supplied; no production change authorized. Conciseness4: detailed receipts remain separate from this report. Overall4.0/5. Highest-impact remaining actions are final integrated replay and an explicit axis-fit ruling; the user should agree this is bounded evidence rather than admission.

Report: .ufo/waves/round-35/build/ReviewGate/report.md
