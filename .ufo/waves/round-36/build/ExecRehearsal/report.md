# ExecRehearsal — round-36 candidate rehearsal (attempt 2)

Seat: ExecRehearsal (leaf). Lane repo untouched; every run below was executed on
scratch extractions of the frozen instrument commit
`cb8cb659e84240a8db12e4f7b4a0def5068baf7e` (receipt sha256 verified equal to the
frozen `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`).
Scratch root `/fast/scratch/hyaku/kagi-r36/ExecRehearsal/` was removed before
this report was finalized; all raw outputs were copied to `receipts/` first.

## Verdict

- **C1 calibration: PASSES.** `bash plans/round-36-c1.sh` prints `0` (rc 0) on
  the F1–F4 tree; BASE prints `4` (rc 0). 4 → 0 measured.
- **C2 freshness counter: PASSES.** `bash plans/round-36-c2.sh` prints `0`
  (rc 0); BASE prints `15` (rc 0). 15 → 0 measured.
- **C2 kill rule FAILS on the candidate as specified.** `python3
  corpus/release-clock.py` (verify) prints `RELEASE_CLOCK: FAILED (on_release=30
  bound=30 unbound=0 observed=15 fired=15 derived=10)`, rc 1 — not CLEAN. The
  frozen kill rule "verify does not print a CLEAN verdict at the landing
  revision → C2 fails" therefore fires for the candidate exactly as specified.
- **Minimal measured completion exists** (probe variant, report-only): also
  taking the receipt's `observed_at` (2026-11-04) on the 15 *non-drifting* rows
  — values and verdicts already agree — yields `RELEASE_CLOCK: CLEAN
  (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`, rc 0,
  with C2 still 0. Recommend the L1 widen F3's `observed_at` refresh to all 30
  rows (or re-scope the kill rule) before landing.
- **Frozen-plan inconsistency found (report-only, not fixable by the
  candidate):** the plan states SD6 is "preserved unchanged at 5", but SD6 = 3
  at BASE measured two independent ways — `git archive` extraction and a full
  `git clone` checked out at cb8cb65 — with byte-identical sweep output
  (`receipts/base-sweep.txt` and `receipts/base-sweep-with-git.txt`, same
  sha256 `371af979…`). The three SD6 residuals are the round-30/32/33
  verifier-spotcheck citation lines. The C1 counter itself is unaffected (it
  reads only SD5 + stale), but the letter of the C1 kill rule ("SD6 differs
  from 5 at the landing revision → C1 fails") would fire even on a perfect fix.

## BASE receipts (cb8cb65, no fix)

| command | output | rc |
|---|---|---|
| `bash plans/round-36-c1.sh` | `4` | 0 |
| `bash plans/round-36-c2.sh` | `15` | 0 |
| `python3 corpus/release-clock.py` | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | 0 |
| `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)` | 1 |
| `python3 corpus/self-counts.py` | not retained raw (background job died mid-run after the sweep); stale=1 at BASE is evidenced by C1=4 = SD5 3 + stale 1 | — |

BASE verify is CLEAN against the round-26 rearmed receipt (the tsv was last
written against that receipt), which is why the drift only appears once F4
re-points the default receipt — and why F3 must make the *whole table* agree
with the new receipt, not only the 15 version-drifting rows.

## Candidate receipts (F1–F4 applied exactly as specified)

| command | output | rc | receipt |
|---|---|---|---|
| `bash plans/round-36-c1.sh` | `0` | 0 | `receipts/cand-c1.txt` |
| `bash plans/round-36-c2.sh` | `0` | 0 | `receipts/cand-c2.txt` |
| `python3 corpus/release-clock.py` | 15 × `RECEIPT-MISMATCH` (S005 S006 S007 S008 S009 S010 S011 S017 S018 S019 S020 S029 S030 S031 S032), then `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=15 fired=15 derived=10)` | 1 | `receipts/cand-verify.txt` |
| `bash corpus/self-description-sweep.sh --selftest` | `SELFTEST: PASS (10 cases)` | 0 | `receipts/cand-sweep-selftest.txt` |
| `python3 corpus/self-counts.py --selftest` | `SELF_COUNTS_SELFTEST: PASS (48 cases)` | 0 | `receipts/cand-selfcounts-selftest.txt` |
| `python3 corpus/release-clock.py --selftest` | `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` | 0 | `receipts/cand-clock-selftest.txt` |
| `bash corpus/self-description-sweep.sh` (full, SD evidence) | `SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)` | 1 | `receipts/cand-sweep.txt` |
| `python3 corpus/self-counts.py` (full) | `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` | 2 | `receipts/cand-selfcounts.txt` |

- No evaluate class fired on any of the 15 fixed rows: no REGRESSED, DERIVATION,
  INCONSISTENT, NOT OBSERVED, BADFEED or NON-CANONICAL line appears in any
  candidate run. The only findings are the 15 RECEIPT-MISMATCH rows named
  above, all caused by `observed_at` 2026-10-21 vs the receipt's 2026-11-04
  (`receipt_matches` requires `receipt_date(receipt.observed_at) ==
  values["observed_at"]` for every row, rendered-quote rows included).
- The self-counts POLICY=2 rows are `PV-FEEDTOKEN-SHAPES`/`PV-FEEDTOKEN-SELFTEST`
  (`ledger:R29-01`/`R29-02` "command not allowlisted") — the declared
  operator-owned reds, pre-existing and untouched by the candidate; the C1
  counter extracts only `stale=`, so they do not affect C1. stale 1 → 0.
- SD5 3 → 0; SD6 unchanged at 3 (see verdict section). SD1–SD4, SD7–SD9 all 0.

## Probe variant (work2 — candidate + observed_at refresh on the 15 non-drifting rows; report-only, not in candidate.patch)

| command | output | rc | receipt |
|---|---|---|---|
| `python3 corpus/release-clock.py` | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` | 0 | `receipts/probe-verify.txt` |
| `bash plans/round-36-c2.sh` | `0` | 0 | `receipts/probe-c2.txt` |

## Assignment questions answered

- **Does F3 need a note change to stay `derived:`-consistent?** Yes. 10 of the
  15 drifting rows (S013–S016, S021–S026) carry notes whose first token is
  `derived:`; the receipt-naming clause must be *appended after* the existing
  note text (`; re-observed 2026-11-04 per receipt
  .ufo/waves/round-36/controls/observe-live.json (observed X.Y.Z, fired)`),
  never before it. With the prefix preserved, no DERIVATION finding fires: the
  derived-anchor binding is checked against `anchored_version` (untouched) and
  the SOURCES.md feed-row anchor cell, not the note tail. The 5 non-derived
  rows (S012, S027, S028, S040, S041) get the same appended clause without a
  prefix.
- **What do `fired=` and `derived=` become?** On the candidate as specified:
  verify prints `fired=15 derived=10` (the 5 non-drifting derived rows
  S008–S011, S029 are invalidated by RECEIPT-MISMATCH, and `derived` counts
  only valid rows). With the probe completion: `fired=15 derived=15`,
  `observed=30`, CLEAN. `on_release=30 bound=30 unbound=0` in both.

## Deliverables

- `candidate.patch` — unified diff over the three changed files (sha256
  `094340023ed5621fb815d14e9ca6dbdc5b1e4d79db7238b208d1ddae69f92dfe`, 114
  lines). Note: F1 and F2 both edit `SCORECARD.md`, so "the four files" of the
  shared context are three distinct paths: `SCORECARD.md` (F1+F2),
  `corpus/release-clocks.tsv` (F3), `corpus/release-clock.py` (F4). The patch
  dry-run applies cleanly (`patch -p1 --dry-run` rc 0) against a fresh
  `git archive` extraction of cb8cb65.
- `receipts/` — all raw outputs listed above, plus
  `receipts/observe-live.json` (sha256 `3f611eec…`, equal to the frozen hash).
- `report.md` — this report (duplicate of `../ExecRehearsal.md`).

## Limitations and honesty notes

- BASE `self-counts` full raw output is missing: the BASE capture job was
  killed after its sweep step (its own rc 1). stale=1 at BASE is evidenced
  indirectly by C1=4 with SD5=3; the candidate's stale=0 is directly retained.
- The Round 36 pre/post-move table prose in `candidate.patch` is a rehearsal
  instantiation written by this seat; the instrument-relevant contracts are
  what were verified (latest `## Round` section's calibration row names
  `R25-02`/`R29-01`/`R29-02` with state → SD5 0; capability row's first
  `--selftest N cases` capture = 70 → stale 0). Final wording is the L1's.
- The probe variant's date refresh is a measurement of the minimal completion,
  not a claim that the L1 must adopt it verbatim; the alternative is amending
  the frozen kill rule, which only the L1/plan process can do.
- No tools were installed or upgraded (nothing needed); no pacman transaction.
- Dead ends: the first two `git clone` attempts exited 1 with no output (the
  session shell was busy; retried successfully as a single command with output
  to a log — `receipts/clone.log`); one BASE capture job died mid-script as
  noted above.
