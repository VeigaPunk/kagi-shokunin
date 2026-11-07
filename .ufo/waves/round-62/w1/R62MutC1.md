# R62MutC1 — mutation battery over the hardened C1 grammar and counter

Seat: `R62MutC1`, role mutation-tester (attack seat), wave `kagi-r62-w1`, kagi round
62 attempt 1. Read-only over the lane: no lane file was written, no git/jj command
was run. Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`.

Full receipt: `.ufo/waves/round-62/build/R62MutC1/mutants.md`, with
`grammar-selftest.txt`, `grammar-behavior.txt`, `fixture-battery.txt`,
`w6-i6-isolation.txt` and `counter-battery.txt` in the same directory.

## Instruments measured

| instrument | sha256 | baseline |
|---|---|---|
| `plans/round-61-c1-check.py` (hardened grammar) | `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0` | `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0 |
| `plans/round-62-c1.sh` (C1 counter, 8 checks) | `efe676ebb0d016664705f17c181ecc3331963a4b09fb2f80403f8773170cf62f` | `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 |

The counter was revised three times during the wave (`19ea1131…` → `d190e6e2…` →
`5c71947d…` → `efe676eb…`); the battery was re-run on each revision and the census
below is on the final bytes. The checker was measured on its final bytes
(`f2afd9b8…`, the executor's FINAL hash).

## Census

```
MUTANTS: killed=11 survives=3 population=14
```

- Grammar (9): GM1 I3 negator removed, GM2 I4 negator removed, GM3 I5 negator
  removed, GM4 negator window 0, GM5 I6 superseded-stamp clause dropped, GM6 I7
  pairing dropped, GM7 `_is_negator` inverted, GM8 I6 denial clause dropped, GM9
  verdict mapping inverted. Killed 8 (all but GM5), each by a named selftest case
  (`b3-negated-withdrawn-unresolved`, `b4-no-three-unresolved`,
  `b5-not-rewritten-unresolved`, `b7-swapped-pairing-unresolved`,
  `b6-tail-denial-unresolved`, plus the window/negator-set/K5 cases and the 17
  aggregate cases for GM9).
- Counter (5): CM1 count `value>0` as accepted, CM2a stub composition forced 1,
  CM2b stub leg always 1, CM3 paraphrase leg skips, CM4 challenge composition forced
  1 (Amendment A3). Killed 3 (CM1 by the K1 census and the candidate reading, CM3 by
  guard leg d, CM4 by guard leg e on a needle-carrying PASS stub); survived 2 (CM2a,
  CM2b).

## Findings for the L1

1. **GM5 survives — I6 clause (c) has no isolating selftest case (coverage defect).**
   Dropping `bool(superseded)` from both `item6` branches leaves `--selftest` at
   `PASS (cases=75)`. The case named `b6-wholeline-no-superseded-stamp-unresolved`
   fails for the launch-line reason (its replacement line has no launch line), not
   for the superseded-stamp reason. Behaviourally live: on a tree that keeps the
   launch line and four derived committer stamps but removes the quoted superseded
   stamp and the driver-complete stamp (`W6`), the pristine checker reads
   `i6 FAIL … superseded-stamp=none` (value=1) and the mutant reads `i6 HOLD …
   superseded-stamp=none` (value=0). Amendment A1 asks for the whole-line variant as
   an I6 case; the shipped case does not isolate the clause. Fix: add the `W6`-shaped
   case (assert FAIL) and rename the existing case as the launch-line case.
2. **CM2a survives — the verdict-mode stub composition is never exercised.** The
   selftest calls `stub_leg` directly and asserts both shapes are refused; it never
   evaluates `stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1`. Forcing
   `stub=1` is unobservable on every tree. Fix: share the composition via a helper
   and add a `stub_c1=0` (or `stub_c2=0`) case.
3. **CM2b survives — `stub_leg` has no negative vector.** The selftest asserts only
   that both stub shapes are refused, so deleting the `grep -q '^C1_BYPASS:'` and
   `[[ "$SL_RC" -ne 0 ]]` discriminators (forcing `SL_OK=1`) still passes
   `stub-refused`. Fix: run `stub_leg` on the existing reject-stub tree and assert
   `SL_OK=0`.
4. **Three pre-fix counter defects were exposed by the controls and are fixed in the
   final bytes** (details in `mutants.md` §Instrument defects): the `selftest_gate`
   case-count parse (`cases=1`, guard leg b unsatisfiable), the `measure_battery`
   rejected-tail status leak (the counter aborted `SETUP measure leg failed` on the
   hardened tree, making the candidate reading unreachable), and check 7's missing
   `mkdir`. Each was reported to `R62ExecC1Counter` with a minimal repro; the executor
   fixed each and added the corresponding selftest check.
5. **Plan fixture B6 was vacuous under the frozen I6** (the tail-only substitution
   left the quoted superseded stamp and the driver-complete time on the line). It was
   reported by the two C1 executors before any candidate reading; the L1's Amendment
   A1 added I6 clause (d), and B6 now flips (`i6=0`, `value=1`). The frozen predicate,
   target, POP, fixtures and kill rules were not amended; my battery confirms the flip
   on the final checker.

## Positive controls on the final bytes

- Hardened checker over the frozen fixtures: `REAL value=0`; `B3..B7 value=1` with
  i3/i4/i5/i6/i7 respectively 0; `P3..P5 value=0`; `W6 value=1` with i6=0.
- Counter: `--selftest` `PASS (8/8)` rc 0; BASE tree `accepted=5 population=5
  guard=0` rc 1; hardened tree `accepted=0 population=5 guard=1` rc 0; hostile
  paraphrase table `paraphrase leg=0 guard=0` rc 1; needle-carrying PASS stub
  `chal=0 guard=0` rc 1.

## Scratch and restoration

All clones, fixture trees and mutant copies were under
`/fast/scratch/hyaku/kagi-r62/R62MutC1/` and are deleted before this seat yielded.
No citable evidence was written under `/tmp`. No secret value, cookie, token or
vault/item/field name appears in any receipt. The lane instrument hashes at the end
of the seat are the executors' final bytes (`f2afd9b8…`, `efe676eb…`); this seat
wrote none of them.

SEAT-STATUS: complete
