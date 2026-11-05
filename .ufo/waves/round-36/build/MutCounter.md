# MutCounter — round-36 counter mutation probe (trailer-path copy)

Full raw outputs: `.ufo/waves/round-36/build/MutCounter/report.md`, `mutations.tsv`,
`raw/*.txt`.

**Verdict: all five assigned mutants KILLED — C1 `0` and C2 `0` are load-bearing.**
One defect in the candidate as specified: **literal F3 fails the C2 operability kill rule.**

Candidate: `git archive cb8cb659e84240a8db12e4f7b4a0def5068baf7e` + F1–F4.
`SCORECARD.md` sha256 `c208d15ff75ff2633917d34e93ffde2dc2e77777192a15b901223484be9ff362`;
`corpus/release-clocks.tsv` `1a550a7a4e5e2715930305329744ba9d3dfa45c031b9ff42850901da893387de`;
`corpus/release-clock.py` `b18444f8f821c314719c91acf83bba3ad76731c7f787995b2783b1db8d2fa960`.

- Positive control: c1 `0` rc0, c2 `0` rc0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30
  unbound=0 observed=30 fired=15 derived=15)` rc0. No-work BASE reproduced: c1 `4`, c2 `15`.
- **F3 literal (15 drifting feed rows only)**: c2 `0` but `release-clock.py` **FAILED**, rc1,
  15 `RECEIPT-MISMATCH` (S005–S011, S017–S020, S029–S032). `receipt_matches()` compares
  `observed_at` for every bound row; the fix must re-date all 30 rows to 2026-11-04, which is
  what the L1 working tree does and what my candidate does. ReviewC2 reports the same.
- M1 S014 2.7.2→2.7.1 + `not-fired` (self-consistent, receipt-contradicting): c2 `0→1`,
  verify also flags `RECEIPT-MISMATCH S014`. **Killed.**
- M2 `R29-02` removed from the round-36 calibration row: c1 `0→1` (SD5 `0→1`). **Killed.**
- M3 capability cell back to 59: c1 `0→1` (`STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701
  claimed=59 live=70`). **Killed.**
- M4 receipt moved aside: c2 exit `2` `C2 SETUP: receipt missing`. **Killed (fail-closed).**
- M5 `lane-status:` deleted: sweep `SELF_DESCRIPTION: SETUP no lane-status line in
  SCORECARD.md` rc2; c1 exit `2` `C1 SETUP: sweep verdict missing`, no integer.
  **Killed (fail-closed).**
- Every mutation restored byte-exactly (sha256 == golden) and the reading returns to `0`.
- Caveat: `SD6` reads 84 on the archive extraction (fleet-path citations) vs 3 in the lane
  checkout — outside C1's population, identical on the pristine candidate, moves no verdict.
