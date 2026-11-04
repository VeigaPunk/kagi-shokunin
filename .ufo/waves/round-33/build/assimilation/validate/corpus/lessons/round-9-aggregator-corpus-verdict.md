# Round 9 aggregator corpus verdict — kagi

Measured against landed `kagi-shokunin` HEAD `4391b3b` (main HEAD `62fdfbe`), not its moving dirty worktree. The worktree had 21 entries; all decisive worktree-only text is provisional.

## Verdict

Rule 10 is discharged with **not conformant — rules 4 and 8 literal text**. Rule 4 remains open because the landed SCORECARD depth cell preserves uncommanded/stale counts. Rule 8 is graded against CORPUS.md's literal ban: landed corpus contains 54 literal `op://` occurrences, all observed as schematic placeholders, prose, mechanism descriptions, or sweep patterns; no resolvable real-vault path and no secret value were observed. Therefore **FAIL-literal / PASS-intent**, not clean. This records the conflict with the inherited round-6 interpretation and routes it to the integrator/operator for clarification.

## Box 3

Round 8's `[x]` provisional cold-run was re-tested. Landed drift and surface gates firm: drift `CLEAN (files=15 symbols=19)`, selftest `PASS (13 cases)`, surface census CLEAN, selftest PASS (16), verbs CLEAN. But landed `claim-ledger.sh verify` fails R11-08, citations fail with 40 unresolved, transcript scan exits 1 with 2 hits, and `op-ref-probe.sh` is absent from the landed tree (untracked in the worktree). Result: **break / still provisional**, not firm.

## Drift/redaction

The gate partially conforms to §Gate standard: committed 15-file/19-symbol inputs, 13-case selftest, declared 0/1 semantics, and read-only scope are present. Registry completeness and a distinct committed real-input snapshot are incomplete/partial. The L0 prefix-match defect remains open at the-janitor L228–235: the awk test echoes values beginning `op://` wholesale. HEAD `surface-census.sh --verbs` reproduces `refs-redaction-prefix-only: PASS unredacted tail rides out`. The read-only probes emitted no secret value; credential tripwire count was zero; only counts, names, and redaction-path status are reported.

## Movement

D-63 remains open: four `[x]` SHONEN marks remain, and `KagiR9Reviewer` does not resolve to a committed verifier report. D-65 remains open: SCORECARD L16 retains the four falsified depth counts without inline counting commands. Compared with the stale §11.1 row (`not conformant — 4 only`, 6 majors/10 defects), the landed review confirms non-conformance and adds the literal rule-8 failure plus gate failures; worktree repairs are provisional.
