# R63Reviewer — attack report (round 63, kagi)

Seat: reviewer (attack). Read-only on lane source; every attack tree is a copy
under `/fast/scratch/hyaku/kagi-r63/R63Reviewer/` (removed before yield). Full
record with every command and line: `.ufo/waves/round-63/build/R63Reviewer/findings.md`.

## Pins

- BASE tree `0c07aab8df64b673a54a5113aebd7f34b622adbc` (10883 files).
- BASE checker `plans/round-61-c1-check.py` sha256 `f2afd9b8…` (81640 B),
  `--selftest` ⇒ `PASS (cases=75)`.
- Candidate checker measured: sha256 `eb08094c…` (20:09 snapshot),
  `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=102)` (guard leg b needs 91).
- Harness control: the frozen F1..F10 / P1..P6 rebuild and measure exactly as the
  plan's census (BASE accepted 10 / rejected 6; candidate accepted 0 / rejected 0,
  each forgery rejected by its designated item).

## C1 — 19 new forgery trees (17 still accepted)

| id | attack | BASE | candidate | verdict |
|---|---|---|---|---|
| X1 | hedge `ostensibly` | accepted | **accepted** | open F-9 |
| X2 | hedge `purportedly` | accepted | **accepted** | open F-9 |
| X3 | denial verb `contradicts` | accepted | **accepted** | open F-9 |
| X4 | denial verb `rejects` | accepted | **accepted** | open F-9 |
| X5 | negation in previous sentence + attribution | accepted | **accepted** | open F-8 |
| X6 | token in quotation, denial outside (`does not support`) | accepted | **accepted** | open F-8 |
| X7 | token in quotation, denial outside (`disputes`) | accepted | **accepted** | open F-8 |
| X8 | I7 subject swap with third subject | accepted | **accepted** | open F-7 |
| X9 | I7 extra pair from another denominator (`3/15 = 20 %`) | accepted | **accepted** | open F-7 |
| X10 | fabricated stamp that is a derived committer time (replace) | accepted | **rejected** `i6=0` | closed |
| X11 | fabricated derived-time stamp (add) | accepted | **rejected** `i6=0` | closed |
| X12 | token form `cannot` | accepted | **accepted** | open F-9 |
| X13 | prefix negation `un-withdrawn` | accepted | **accepted** | open F-9 |
| X14 | contrastive-exception abuse `not, but …, withdrawn` | accepted | **accepted** | open F-6 |
| X15 | quote-mask abuse `is "not" withdrawn` | **rejected** | **accepted** | open F-5 (regression) |
| X16 | negator 30 tokens back (24-token cap) | accepted | **accepted** | open F-9 |
| X17 | I4 post-token denial `contradicts` | accepted | **accepted** | open F-9 |
| X18 | I5 post-token denial `contradicts` | accepted | **accepted** | open F-9 |
| X19 | I6 post-token denial `disputes` | accepted | **accepted** | open F-10 |

Accepted line on every open tree:
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`.
**The hardened grammar narrows the class; it does not close it.** X15 is the
sharpest: the round-63 quote mask turns a tree the round-62 checker *rejected*
into an accepted forgery.

## C1 — 8 new benign rewrites (all accepted)

Y1 appositive, Y2 passive with agent, Y3 numeric `3 (three)`, Y4 hyphenated
anchor `A3-item-2`, Y5 contrastive `withdrawn, not merely restated`, Y6
quoted-but-asserted, Y7 I6 benign parenthetical, Y8 I7 appositive. Every one
reads `value=0` on the candidate; no false positive in this set.

## Counter attacks

- **A — stub that prints the target line plus leg fields.** As a tree's C1
  counter, a stub printing `accepted=10 rejected=6 population=10/6 guard=1`
  reads `C1-F8 mismatch`, `C1-NOWORK match`, `C1-REAL match` (`CONTROLS:
  match=3 mismatch=1`). The two behavioural controls accept a constant; only the
  constant `C1-F8` catches it, and `C1-F8` mismatches for *any* counter because
  its stub dispatch intercepts every run. **F-4.** As a checker, all three stub
  shapes are refused (no PASS line / no value / constant-printer defence) —
  closed.
- **B — counter whose `--selftest` prints PASS without a case.** A copy of
  `plans/round-63-c1.sh` with an early `--selftest` printer reads
  `C1_RESIDUAL_SELFTEST: PASS (7/7 checks)` rc 0 with no TSV readable and no case
  executed; nothing refuses it. **F-3.**
- **C — battery with an empty control list.** `CONTROLS: match=0 mismatch=0`,
  `SKIPS: 0`, `SEAT-STATUS: complete`, rc 0 (measured on battery `e90d5cfc`). Any
  guard that reads only `mismatch=0`/`skips=0` is vacuous. **F-2.**
- **D — transient: the 20:04 C1 counter referenced an unbound `$stub`** under
  `set -u`, so it could not print `C1_RESIDUAL:` at all; fixed in the current
  bytes (`leg_stub` → `stub_calc` sets `STUB`). **F-1** (verify final bytes).
- **E — tampered fleet report.** With `--fleet` pointing at a scratch copy whose
  §Stale-lane line reads `launch 16:59:59`, F9 reads `value=0` and the unmodified
  tree reads `value=1 i6=0`. The I6 conjunct is only as trustworthy as the fleet
  report's unpinned bytes; the counter's `real` leg catches the tamper, so this
  is a residual risk, not a claim bypass.
- **F — PRIOR delegation.** A tree whose `plans/round-62-controls.sh` is a
  two-line stub reads `PRIOR-K1-BASE-C1 verdict=match` and
  `PRIOR-K1-BASE-C2 verdict=skip`: the PRIOR rows are the tree's own battery
  output. **F-12.**

## Findings (severity, fix)

- **F-1 HIGH (fixed in-round)** — unbound `$stub` in the C1 verdict guard; fix:
  `stub_calc`/`leg_stub` set `STUB` (present at `:527-531`); keep the
  verdict-mode guard composition in the counter's selftest.
- **F-2 HIGH** — empty control list reads a clean battery; fix: require
  `match >= 6` and the six named control ids with non-skip verdicts, else
  `SETUP controls-empty`.
- **F-3 MEDIUM** — `--selftest` printer unrefused; fix: self-challenge in the
  counter's selftest (mutate `stub_calc`/`leg_selftest`, require `FAIL`) or a
  `C1-SELFTEST-MUT` battery control.
- **F-4 MEDIUM** — `C1-F8`/`C2-F6` are constant controls (the stub dispatch
  intercepts every run), so the C2 predicate's L3/L4 are satisfied by
  construction; fix: run the measured counter on a mutated tree and require a
  non-target reading.
- **F-5 MEDIUM (regression)** — the quote mask deletes a scare-quoted negator
  (X15 accepted, rejected at BASE); fix: mask only attributed/superseded spans,
  or treat a quoted negator immediately before the token as a negator.
- **F-6 MEDIUM** — the contrastive exception exempts any `but` between negator
  and token (X14); fix: require `not X but <token>` with no intervening clause.
- **F-7 MEDIUM** — I7 binds by string proximity: a third subject containing the
  subject string (X8) and an extra non-derived pair (X9) both pass; fix: nearest
  subject, one pair per clause, reject a pair whose percentage is not its own.
- **F-8 MEDIUM** — attribution/quotation classes (X5/X6/X7) stay open; fix:
  denial scan through the whole sentence after the closing quote; treat
  "as the draft had it"/"the draft's wording" as attribution.
- **F-9 LOW–MEDIUM (plan ceiling)** — hedges, denial verbs outside the set,
  `cannot`, `un-`, >24-token negators, I4/I5 denial verbs (X1–X4, X12, X13,
  X16–X18); fix next round: widen the sets, add prefix negation, sentence-scope
  the window.
- **F-10 LOW** — I6 accepts a post-token denial verb (`disputes`, X19); fix: run
  `_denied_after` on the I6 line or extend `I6_DENY_PHRASES`.
- **F-11 LOW (plan conformance)** — the C1 counter's guard has six legs and its
  verdict line carries `chal=`; the frozen §C1 guard is five legs (a)–(e) and the
  frozen line has five fields. Fix: drop the challenge from the guard composition
  (keep it as a diagnostic) or land it as a disclosed amendment before the
  candidate reading.
- **F-12 LOW** — the PRIOR rows re-emit the measured tree's own
  `round-62-controls.sh` output; a stub battery reads match. Fix: pin the round-62
  battery's sha256 or run it from the lane.

## Verification gaps

- The candidate checker was still being written during the measurement
  (`53acc21d` → `cc92d8a9` → `eb08094c`); the table is measured on `eb08094c`.
  Re-run the X trees if the grammar code changes.
- `plans/round-63-c2.sh` did not exist at measurement time, so F-2's effect on
  `C2_REFUSAL` guard leg d is a source-level inference plus the measured
  empty-battery line, not a measured `C2_REFUSAL` line.
- Not run: the real `bao` trial, the round-62 battery's 14 controls, any lane
  gate. No lane file written; no git/jj mutation anywhere.
- Tooling: none installed, upgraded or removed.

SEAT-STATUS: complete
