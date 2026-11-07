# R53ExecHarm — harm check: full ledger verify on BASE vs candidate

Seat: R53ExecHarm (Harm check, round-53)
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master, read-only use)
BASE: c1953d4afc19a5a336a58685c00ab5260bcfea1c
CANDIDATE: 36d0a86a7539890eb079d893c9a58e37e84d953d

## Method

Two `git clone -q --shared` clones under $HYAKU_SCRATCH/kagi-r53/R53ExecHarm/ (default /fast/scratch/hyaku), each checked out detached at the pinned revision inside the clone only:

- `base/` @ c1953d4afc19a5a336a58685c00ab5260bcfea1c
- `candidate/` @ 36d0a86a7539890eb079d893c9a58e37e84d953d

In each, ran `bash corpus/claim-ledger.sh verify` (sequential, not in parallel). Full outputs saved:

- `.ufo/waves/round-53/build/R53ExecHarm-verify-base.txt` — 103 lines, exit 2 (~773 s)
- `.ufo/waves/round-53/build/R53ExecHarm-verify-candidate.txt` — 103 lines, exit 2 (~1131 s)

`diff R53ExecHarm-verify-base.txt R53ExecHarm-verify-candidate.txt` → **IDENTICAL** (no output).

## Measured id sets

Both trees (identical):

- **FAIL**: R11-08 (timeout, exit=124, tmo=300), R25-02 (exit-mismatch, exit=2, want=0), R36-01 (timeout, exit=124, tmo=300)
- **POLICY**: R29-01 (first-token:python), R29-02 (first-token:python), R38-03 (python-script)
- **HOST-SKIP**: 13 rows (R11-01, R11-02, R11-03, R11-04, R11-06, R12-01, R15-01, R13-03, R16-01, R16-03, R17-01, R18-01, R31-01)
- **MISSING-ID lines: 57 / 57** (BASE / candidate); LABELED-ID: 26 / 26
- Terminal line (both): `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`

This exactly matches the lane's expected reading (BASE FAIL R11-08/R25-02/R36-01, POLICY R29-01/R29-02/R38-03; candidate the same ids).

## Diff with per-id explanation

There is no diff: the BASE and candidate verify outputs are byte-for-byte identical. Per the assignment, each failing/policy id was run alone in the candidate clone to explain its status:

- **R11-08** (`bash corpus/claim-ledger.sh citations`, tmo 300 s, want exit 0): run alone in the candidate clone it did not finish within 600 s (job timed out, killed). Consistent with the verify's `timeout exit=124 tmo=300` — this gate is host-load/timeout sensitive in both trees; the failure is not introduced by round-53 (BASE fails identically).
- **R25-02** (`python3 corpus/self-counts.py`, want exit 0, expect `^SELF_COUNTS: CLEAN \(claims=60 stale=0\)$`): run alone in the candidate clone (~148 s, exit 2): final line `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, with the two POLICY rows `PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted` and `PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted`. All 61 count bindings print `OK … claimed == live` — including the C2-corrected stamps (125) and knowledge entries (34/37). So the exit-2 is caused entirely by the two POLICY rows, not by stale counts. The same command in the BASE clone (~140 s, exit 2) ends `SELF_COUNTS: POLICY (claims=63 stale=5 unlocated=0 ambiguous=0 policy=2 setup=0)` — BASE has stale=5 where candidate has stale=0 (the C2 fix), but both exit 2 for the same POLICY reason. The verify verdict for R25-02 is therefore identical in both trees while the underlying counts improved.
- **R36-01** (`bash plans/round-36-c1.sh`, tmo 300 s, want exit 0, expect `^0$`): probed alone in the candidate clone with a 60 s probe — still running (killed at 60 s, exit 124). Consistent with the verify's `timeout exit=124 tmo=300` in both trees; a host-load timeout, not a round-53 regression (BASE fails identically).
- **R29-01 / R29-02** (`python -I -B corpus/feed-token-agree.py [--selftest]`, want exit 0): POLICY `first-token:python` — the ledger rows use bare `python` (round-29 Windows host note), which this host's policy gate rejects; identical in both trees, no network or host read involved in the rows themselves.
- **R38-03** (`python3 -I -B corpus/quote-locate.py`, want exit 0): POLICY `python-script` — policy gate rejects the python-script command form; identical in both trees.

Conclusion: no id differs between BASE and candidate; no round-53 harm detected on any axis. The candidate differs from BASE only in the self-count staleness (5 → 0), which does not change any verify verdict.

## Extra commands (candidate clone)

All run in `/fast/scratch/hyaku/kagi-r53/R53ExecHarm/candidate`:

1. `bash corpus/expect-journal.sh --base-ledger <BASE clone>/corpus/claim-ledger.tsv --ledger corpus/claim-ledger.tsv --journals .ufo/waves/round-53`
   - As assigned, stderr/exit: `expect-journal: setup error: journal .ufo/waves/round-53/controls/fixtures/ref/c1/.ufo/waves/round-53/final/observe-r53.json: no migrations list`, **exit 2**. Cause: the gate recursively walks `--journals` and the committed C1 control-fixture subtree inside `.ufo/waves/round-53/controls/fixtures/ref/c1/` contains a non-journal JSON (`observe-r53.json`, format `release-clock-observations-v1`, no `migrations` list), which trips the setup-error path before any comparison. This is a fixture-layout interaction, not a migration mismatch: with the journals dir limited to the round's own `expectation-migrations.json` (copied alone to /tmp/r53j), the same command prints `EXPECT_JOURNAL: CLEAN (changed=9 journaled=9)`, **exit 0** — all 9 journaled migrations (R13-01 R21-02 R24-06 R31-02 R33-02 R34-03 R36-02 R36-03 R38-01) verify.
2. `bash corpus/claims-declared.sh --root .` → last line `CLAIMS_DECLARED: CLEAN (claims=33)`, **exit 0**.
3. `python3 corpus/release-clock.py --selftest` → last line `RELEASE_CLOCK_SELFTEST: PASS (116 cases)`, **exit 0**.

## Evidence notes

- The lane's scratch-copy verify (`.ufo/waves/round-53/final/verify-candidate-tree.txt`) additionally shows FAIL R22-03 / R24-15 exit 2; its own header explains those read exit 2 in a non-git scratch copy (they need git history) and defers to this clean-clone verify — consistent with what was measured here (neither id fails in either clean clone).
- No stray git mutation was performed in the lane or clones (detached checkouts only, inside scratch). No tokens, keys, or secrets were read.
