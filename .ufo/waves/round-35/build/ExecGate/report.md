# ExecGate — round 35 candidate

## Deliverable and axes

Candidate: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/prefreeze-control.sh`.
BASE: `063c407494276d0c616e6c712a2e5d7aeb7e3768`, obtained with explicit `git -C <lane> show BASE:corpus/prefreeze-control.sh`.
Axes: producer-result integrity, positive-control retention, baseline interface/isolation/timeout retention. No production or frozen-control files edited.

The candidate accepts exactly one non-whitespace stdout line containing only optional whitespace and an unsigned integer, with empty stderr and rc0, or rc1 only for measured zero. Other statuses, diagnostic/SETUP/POLICY prose, multiple nonempty lines, empty output and stderr produce NORESULT and final SETUP exit2. Timeout keeps its existing named timeout result. Raw stdout capture detects NUL rather than silently discarding it. Decimal-string normalization prevents shell arithmetic overflow and retains leading-zero meaning. Header comments describe the new contract and its limits.

All twelve original cases remain. Thirteen public-invocation cases cover five frozen false-cleans, multiple lines, rc1/nonzero, POLICY, signed numbers, NUL, padded zero, large integers and wraparound rejection. Extraction, cleanup traps, BASE/LANE environment, timeout command and CLI remain in place. The second fixture commit now also asserts the fixture top-level before mutation.

## Exercised checks

Only the two assigned checks ran, concurrently; each process used cwd `/fast/scratch/hyaku/kagi-r35/ExecGate` and TMPDIR at that exact seat scratch path.

1. `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/prefreeze-control.sh --selftest`
   - rc0; final stdout `PREFREEZE_SELFTEST: PASS (25 cases)`; empty stderr.
2. `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py --script /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/prefreeze-control.sh --base 063c407494276d0c616e6c712a2e5d7aeb7e3768 --out /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/measurement.json --work /fast/scratch/hyaku/kagi-r35/ExecGate/measure`
   - rc0; stdout `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`; empty stderr.

Exact argv/cwd/exit/raw output and hashes: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/receipts.json`.
Full nine-case public outputs: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/measurement.json`.
Separate raw captures and exits: `selftest.stdout`, `selftest.stderr`, `selftest.rc`, `measurement.stdout`, `measurement.stderr`, `measurement.rc`, all under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/`.

Candidate SHA256: `2a0986d4e0bce5e2383ef60afe68b84036960045e7177870333b5de5424edeea`.
Frozen measure SHA256 before/after: `e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17` (unchanged).

## Scope, risks and handoff

L1 KagiR35 and MutGate-3 received the final candidate path/hash. L1 owns installation and post-integration gates. No clone, installation, external contact, secret access, routing edit, lane/fleet git mutation or unrelated check occurred. Selftest git commits occurred only in its guarded disposable fixture. No LSP interface is exposed in this seat; supported symbol lookup was unavailable, not reported absent from a cold response. Non-owned SD6 and R25-02 FAIL / R29-01 / R29-02 POLICY were untouched and not rerun.

The gate cannot detect a dishonest producer emitting a valid plain integer with rc0, including masked pipeline failures; no universal soundness or outside judgment is claimed. Frozen measurement covers nine named cases, not arbitrary producer behavior. Historical receipts remain historical.

Report-path instructions conflict: the strict exclusive-directory bound permits `ExecGate/report.md`, whereas the later report locator names sibling `ExecGate.md`. This report uses the exclusive directory and does not write the sibling path.

Self-evaluation (advisory, not judgment): accuracy 4 (bounded named-case evidence, no universal proof); completeness 4 (implementation/checks complete, installation intentionally L1-owned); clarity 4 (raw evidence separate from summary); actionability 4 (final candidate/hash provided, integration remains L1-owned); conciseness 4 (exact command detail retained for reproducibility). Overall 4.0. Improvement: L1 should bind installed bytes to this candidate hash and execute its owned post-integration gate. Would the user agree? The explicit receipts and scope limits make this assessment inspectable.

Report: .ufo/waves/round-35/build/ExecGate/report.md
