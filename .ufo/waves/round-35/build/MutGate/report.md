# MutGate — round 35 producer-result integrity

Axes: producer-result integrity; positive-control retention; BASE isolation.

## Observed BASE proof

Executed `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/probe.py --base-proof`.

- BASE: `063c407494276d0c616e6c712a2e5d7aeb7e3768`.
- Frozen instrument SHA256: `e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17`.
- BASE gate SHA256: `ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a`.
- Actual exit: 1. Raw stdout: `MEASUREMENT_RESULT mismatches=5 invalid_false_clean=5 positive_matches=2 cases=9`.
- This BASE failure is not a killed mutant. Both positive controls matched; five invalid producers incorrectly returned CLEAN.
- Whole-process argv/rc/stdout/stderr: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/base-proof.json`.
- Complete public case receipts: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/base-proof-cases.json`.
- Combined evidence: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/base-results.json`.

## Harness

`/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/probe.py` accepts a candidate and exact one-occurrence mutation specifications. Each mutation gets pristine, mutated and exactly restored runs of the same detector. Only a passing pristine/restored pair plus an explicit failing mutated measurement or named selftest CASE FAIL is classified killed. Empty output, timeouts and invalid detector processes are inconclusive. Scratch bytes are restored in `finally`; durable receipts precede scratch removal.

No production writes, installs, commits, pushes, handler contact, host-private reads, routing changes or sibling writes. SD6, R25-02 FAIL and R29-01/R29-02 POLICY are outside these probes and unchanged by this seat. Executed checks were limited to the authorized frozen detector and candidate selftest.

## Five candidate mutants: all killed

Candidate: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecGate/prefreeze-control.sh`.
Candidate SHA256: `2a0986d4e0bce5e2383ef60afe68b84036960045e7177870333b5de5424edeea`.

Executed the harness with `--candidate` naming that absolute path and `--specs /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/mutations.json`.

| Mutant | Detector | Actual detector rc / finding | Verdict |
|---|---|---|---|
| Remove rc guard | Frozen measure, failed-number | rc1; mismatches=1 invalid_false_clean=1 positive_matches=2 cases=9. Producer wrongly gives rc0 `OK failed-number expect=0 measured=0` and CLEAN. | killed |
| Remove stderr guard | Frozen measure, stderr-number | rc1; mismatches=1 invalid_false_clean=1 positive_matches=2 cases=9. Producer wrongly gives rc0 `OK stderr-number expect=0 measured=0` and CLEAN. | killed |
| Relax numeric-only to last-integer | Frozen measure, diagnostic-number / clean-forgery | rc1; mismatches=2 invalid_false_clean=2 positive_matches=2 cases=9. Both invalid producers wrongly give rc0 OK and CLEAN. | killed |
| Blanket refuse producers | Frozen measure, valid-zero / grep-empty | rc1; mismatches=3 invalid_false_clean=0 positive_matches=0 cases=9. Both positives and wrong-count give rc2 NORESULT, final SETUP noresult. | killed |
| Ignore BASE isolation | Candidate selftest, base-isolation | rc1; `CASE base-isolation             FAIL rc=0 last=PREFREEZE: CLEAN (controls=1 mismatch=0)`; relative-work also fails rc1 MISMATCH; final `PREFREEZE_SELFTEST: FAIL (25 cases)`. | killed |

All four frozen-measure probes independently passed on pristine and restored bytes: rc0, `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`. BASE-isolation pristine and restored selftests both returned rc0, `PREFREEZE_SELFTEST: PASS (25 cases)`. No baseline failure or absence of output was booked as a kill.

### Mutated SHA256 identities

| Mutant | SHA256 |
|---|---|
| remove-rc-guard | `827af709620680dc46db236f799ebfa4d2049d1cca8466dff3bf83d0b7505196` |
| remove-stderr-guard | `c426bd935f2f263d6f7e1d712c10127b255ee6c6e2ccc9b96e4514637ead57c8` |
| last-integer-grammar | `d8618f70a102985328c908a2e7e97d823a80edf17cb1d3ea5678dc4dc76e4635` |
| blanket-refuse-producers | `c83a47a353560db169b9e9563c6487bc5c21612c11521ed9a0ba747b9f2a69b1` |
| ignore-base-isolation | `1c47e8a33bf9300fc5ff27071a3d629248bc75aac574ca942d90d494dd761165` |

### Restoration and durable evidence

All five scratch scripts were restored to exact original bytes in `finally`; before and restored SHA256 equal the candidate SHA256 above, with `exact_restoration=true` for every probe. The harness removed `/fast/scratch/hyaku/kagi-r35/MutGate/` after writing receipts. No clone was created.

- Combined pristine/mutated/restored receipts and restoration identities: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/results.json`.
- Raw per-process argv/rc/stdout/stderr: absolute files in that same directory named `<mutant>-pristine.json`, `<mutant>-mutated.json`, `<mutant>-restored.json`.
- Complete nine-case frozen observations: corresponding `*-cases.json` files in that directory.
- Raw receipt digests: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/receipt-sha256.json`.
- Exact substitutions: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/MutGate/mutations.json`.

The frozen measure itself is not claimed to detect BASE isolation; that mutant was killed by the candidate selftest. No production integration or universal producer honesty is asserted. This report stays inside the explicitly permitted seat directory rather than the conflicting sibling-level output hint.

Self-evaluation: accuracy 4/5 (bounded paths, no broader honesty proof); completeness 5/5 (five requested probes, each three-phase); clarity 4/5 (full outputs require linked receipts); actionability 5/5 (candidate, substitutions and observations retained); conciseness 4/5 (hash inventory retained for custody). Overall 4.4/5. Review improvement: use the raw named findings rather than only this aggregate table.

Report: .ufo/waves/round-35/build/MutGate/report.md
