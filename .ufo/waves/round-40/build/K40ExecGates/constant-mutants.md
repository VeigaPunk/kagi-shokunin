# Receipt: M39-6 red witnesses re-derived (constant-CLEAN mutants of both gates)
# seat K40ExecGates, 2026-11-05

## Method

1. Copied both gates from the candidate tree (HEAD cb3f642…) into my scratch
   `/fast/scratch/hyaku/kagi-r40/K40ExecGates/const-mut/` — byte-identical
   copies (7512 and 8306 bytes, matching the lane files).
2. Verified the mutation target is unique in each copy:
   `grep -cF 'if [ "$bad" -gt 0 ]; then'` → 1 in anchor-pins.sh (line 164),
   1 in claims-declared.sh (line 187).
3. Applied exactly the M39-6 patch to each copy: that line replaced by
   `if false; then` (no other byte changed).
4. Ran the patched copy's own `--selftest`. Because each gate's selftest mode
   does `exec bash "$0" --run-selftest "$(readlink -f "$0")"`, GATE_SRC is the
   patched copy itself: every one of the 8 cases exercises the mutant as the
   gate under test, and case 8 additionally builds its own `if false; then`
   mutant of GATE_SRC (a no-op sed on the already-patched copy) and requires
   `real_rc == 1 && mut_rc == 0`.

## Observed — patched anchor-pins.sh --selftest

- exit code: 1
- stdout: `ANCHOR_PINS_SELFTEST: FAIL (passed=2/8)`
- stderr (verbatim):

    SELFTEST-FAIL drift-rewrite rc=0 out=DRIFT A39
    ANCHOR_PINS: CLEAN (pins=3)
    SELFTEST-FAIL dup-row rc=0 out=DRIFT A39 dup
    ANCHOR_PINS: CLEAN (pins=3)
    SELFTEST-FAIL tab-indent rc=0 out=DRIFT A35 shape
    ANCHOR_PINS: CLEAN (pins=3)
    SELFTEST-FAIL extra-cell rc=0 out=DRIFT A39 schema
    ANCHOR_PINS: CLEAN (pins=3)
    SELFTEST-FAIL row-missing rc=0 out=DRIFT A35 row-missing
    ANCHOR_PINS: CLEAN (pins=3)
    SELFTEST-FAIL constant-mutant real=0 mutant=0

## Observed — patched claims-declared.sh --selftest

- exit code: 1
- stdout: `CLAIMS_DECLARED_SELFTEST: FAIL (passed=1/8)`
- stderr (verbatim; `out=` marks the first line of each case's captured gate
  output, the following lines are the rest of that capture):

    SELFTEST-FAIL dup-row rc=0 out=MISMATCH 90 C1 dup-row
    CLAIMS_DECLARED: CLEAN (claims=3)
    SELFTEST-FAIL fence-heading rc=0 out=MISMATCH 90 C1 plan-heading-not-freshness
    CLAIMS_DECLARED: CLEAN (claims=2)
    SELFTEST-FAIL cross-section rc=0 out=MISMATCH 90 C1 section-missing
    MISMATCH 90 C2 section-missing
    CLAIMS_DECLARED: CLEAN (claims=2)
    SELFTEST-FAIL padded-cell rc=0 out=MISMATCH 90 C1 axis-cell-not-freshness
    CLAIMS_DECLARED: CLEAN (claims=2)
    SELFTEST-FAIL missing-tag rc=0 out=MISMATCH 90 C1 tagged-rows-0
    CLAIMS_DECLARED: CLEAN (claims=2)
    SELFTEST-FAIL duplicate-tag rc=0 out=MISMATCH 90 C1 tagged-rows-2
    MISMATCH 90 C2 tagged-rows-0
    CLAIMS_DECLARED: CLEAN (claims=2)
    SELFTEST-FAIL constant-mutant real=0 mutant=0

## Reading

Divergence IS caught, through two independent mechanisms, both observed:

- Case 8 of each selftest: the probe requires the real gate to exit 1 on a
  drift fixture while the constant mutant exits 0. With the gate itself
  neutered, `SELFTEST-FAIL constant-mutant real=0 mutant=0` prints and the
  case fails.
- The verdict line collapses from `*_SELFTEST: PASS (8 cases)` (exit 0) to
  `*_SELFTEST: FAIL (passed=N/8)` (exit 1): every drift case that demands
  rc=1 + a DRIFT/MISMATCH token now sees rc=0 CLEAN. The per-case diagnosis
  text (DRIFT/MISMATCH lines) still prints because those echoes sit before
  the neutered verdict branch — the classic false-clean shape: diagnosis
  without verdict. Since the round-40 C3 counter only counts a gate whose
  selftest's last line is `*_SELFTEST: PASS (8 cases)` with exit 0, a
  constant-CLEAN gate also fails C3's own criterion — defense in depth for
  the M39-6 class at both the gate level and the counter level.

Both selftests on the unpatched candidate gates pass 8/8 (selftests.txt), so
the FAIL verdicts above are caused by the mutation alone.
