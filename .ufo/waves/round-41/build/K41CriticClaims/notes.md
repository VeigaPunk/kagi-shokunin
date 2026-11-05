# K41CriticClaims — working notes

Seat: critic, round-41 kagi attempt-1 wave. Leaf: no delegation, no ask, no agent://all.
Judged on: calibration, freshness.

## What I did, in order
1. Read the frozen plan (plans/round-41.md), both counters, and the controls script in full first.
2. Built the sandbox clone at 5142b52 and asserted `rev-parse --show-toplevel` == sandbox before
   every write; every git call named `-C` or absolute paths; lane HEAD confirmed 5142b52.
3. Reproduced both no-work readings in the sandbox (C1 0, C2 1) and captured the BASE selftest
   (PASS, cases=22 — exactly at the C2 kill floor).
4. P0 audit in plain python over `git show` bytes (never ran the gate): ledger diff base→P0 is
   exactly six expect-cell changes, journal has exactly those six migrations, R1/R2/R3 all clean,
   journal byte-identical at 6f1588c and 5142b52.
5. Harvested every changed expect from all twelve committed journal files (five different schema
   generations — round-23/24/25 use `expect{old,new}`, row triples and `expectation_changes`;
   round-34/35/37/38/40 use the modern forms). Two entries fail the frozen R3 rule if replayed as
   future expects: round-24 R13-03 and round-25 R11-08 (named in critic.md §c).
6. Built the degenerate C2 paragraph from BASE bytes and measured N=3 with the frozen counter
   itself, plus a per-term breakdown. Note: term (b)'s locate is hard-coded to the lane's
   rendered-text-v1.py, not $RTV1.
7. Separability: enumerated both counters' read sets (intersection ∅) and empirically ran the C1
   counter with the three C2 files moved away (outputs byte-identical, 4/4 runs).
8. Kill-rule analysis: two ambiguities, each settled by a quotable sentence; one measurement gap
   (selftest count not measured by the counter; BASE sits exactly at 22).

## Findings routed (not fixed in the lane — leaf)
- controls script `C2 BASE N=` control measures the working tree, not 19025d9 → L1: build it from
  `git archive 19025d9` into scratch or rename the receipt line.
- landing verification must measure the selftest case count explicitly (counter only checks PASS).
- landing-time C1 migration check must run with `--base-ledger` from 6cc8850, else the six-migration
  kill clause is vacuous → record the interpretation in the round report.

## Pitfalls hit
- First sandbox setup embedded the required `trap 'rm -rf -- "$S"' EXIT`; the bash wrapper treats
  calls as supervised processes and the trap fired at process end, deleting the just-cloned tree.
  Recreated without the trap; manual `rm -rf` done before yield. Others in this wave should do the
  same if their runner supervises processes.
- `grep -E '\t'` is a stray-backslash warning (GNU grep), not a tab — cost one failed fixture grep;
  switched to awk -F'\t' / python splits.
- Journal schemas differ by round; a naive `new_expect` walk crashes on round-24 dict entries and
  list-typed entries in later files. Recursive string harvest was the robust approach.

## Not done / why
- `corpus/claim-ledger.sh verify` never executed (frozen once-per-seat budget; the F1–F4 acceptance
  premise is static from the gate's own header contract, and its empirical measurement belongs to
  the reviewer seat's BEFORE evidence).
- No mutation of the gate or counters; falsification only, per assignment.
