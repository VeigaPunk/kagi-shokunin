# R64ExecC1Counter — w1 report

Seat: executor (C1 counter). Files: `plans/round-64-c1.sh` (owned; 885 lines,
sha256 `e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484`) and
`.ufo/waves/round-64/build/R64ExecC1Counter/` (receipts). No commit, no push, no
other file touched. Read the sealed held-out table (permitted for this seat).

SEAT-STATUS: complete

## 1. What landed

`plans/round-64-c1.sh` — the `C1_HELDOUT` counter over the sealed held-out table.
Modes: `[revision]` (default BASE `09cbee83…`), `--tree DIR`, `--selftest
[revision|--tree DIR]`, `--no-challenge …`, `-h/--help`. It seals
`plans/round-64-heldout.tsv` at `sha256 b0f51e2a…` before any work (SETUP rc 2 on
mismatch, `c1-heldout:` line only). It measures on a slim copy of the tree (the
checker's seven inputs + `plans/round-63-c1.sh` when present), each fixture on a
fresh copy with the anchor asserted exactly once.

Verdict line (frozen shape):
`C1_HELDOUT: heldout=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)`,
exit 0 iff guard=1 and A=0; 1 otherwise; 2 SETUP.

Measure legs: H = F2,F6,F8,F10,B4 counted when the copy prints
`C1_ROUTED: value=0`; Q = P6,B5,P7 counted when it prints `value>=1`.
Guard legs on the same tree: real (unmodified `value=0` with i1..i7 all 1),
selftest (`PASS (cases=N)`, N ≥ 109 — see §5.1), resid (round-63 counter prints
`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1`), stub (two printer
shapes refused, no verdict line, non-zero exit), vehicle (the A4 lookup-table
vehicle reads `heldout>=1` and still reads `accepted=0 rejected=0` on the
round-63 tables).

## 2. Acceptance evidence (exact retained readings)

- `bash plans/round-64-c1.sh 09cbee831d57be7c4edfbe77bf238f46bf729047` ⇒
  `C1_HELDOUT: heldout=8 population=8 guard=0 (real=1 selftest=0 resid=1 stub=1 vehicle=1)` rc 1 —
  K1 holds (per-fixture F2=value0 F6=value0 F8=value0 F10=value0 B4=value0
  P6=value1 B5=value1 P7=value1; unmodified value=0 with all seven item bits 1;
  timing measure=396 s real=33 s resid=312 s stub=0 s vehicle=2 s total=744 s).
  Receipt `.ufo/waves/round-64/build/R64ExecC1Counter/base-verdict.txt`.
- `bash plans/round-64-c1.sh --selftest` ⇒ `C1_HELDOUT_SELFTEST: PASS (cases=23)` rc 0.
  Receipt `.ufo/waves/round-64/build/R64ExecC1Counter/selftest.txt`.
- Seal refusal: a scratch copy with one edited byte
  (`sha256 da002285e6bf…`) ⇒ `c1-heldout: SETUP held-out table seal mismatch:
  expected b0f51e2a…, found da002285… — refusing` rc 2, no `C1_HELDOUT:` line.
  Recorded in `counter.md` §2.3.
- Vehicle leg shown able to fail: the A4 vehicle built from the plan's
  description reads `accepted=0 rejected=0` on the round-63 tables and
  **heldout=5** on the held-out set (guard leg e reads 1); a variant carrying the
  five H replacements reads **heldout=0**, and the W2 witness drives a whole
  verdict line to `vehicle=0`. All three are selftest cases on the frozen bytes.
- BASE checker: sha256 `eb08094c…` (2031 lines), `--selftest` `PASS (cases=102)`.

## 3. Selftest design (fixture-driven; no lane instrument needed beyond the tree)

23 cases, including: TSV shape/seal/H-Q parsing; all eight anchors apply exactly
once; guard composition (each leg forced to 0 ⇒ guard 0); both stub shapes
refused plus a negative vector (the good tree is *not* refused); counting
witnesses (constant value=0 ⇒ heldout=5, constant value=1 ⇒ heldout=3); the
109-case floor; item-bit parsing; the resid 0-path; the vehicle positive,
identity and negative vectors; the seal-refusal vector; three **verdict-wiring**
witnesses that run the whole verdict path and compare the full line and exit code
(W0 `heldout=5 … guard=0` rc 1; W1 `heldout=3 … real=0` rc 1; W2 `vehicle=0`
rc 1).

The verdict-wiring and seal-resistance cases were added on the mutation seat's
measured survivors (S5 was the seal skip; S1/S2/S3/S4/S6 were already killed).
On the frozen bytes the seat re-derived nine counter mutants: S1–S6 and S8/S9
killed (S8 force real=1 by W1; S9 force selftest=1 by W0/W1/W2); S7 (force
stub=1) survives — the named ceiling, since every witness expects stub=1.
Ledger `.ufo/waves/round-64/build/R64MutC1/mutants.md` §6/§6b.

## 4. Findings for the L1 (defects, not edits)

1. **Dispatch defect — resid invocation.** The dispatch's literal
   `bash <tree>/plans/round-63-c1.sh --tree <tree>` cannot work on a slim tree:
   that counter derives LANE from its own path and reads its fixtures from
   `<tree>/plans/*.tsv` ⇒ `SETUP forgery fixture table not readable`. Measured,
   with a sibling's independent receipt. The counter now invokes the lane's copy
   (`bash <lane>/plans/round-63-c1.sh --tree <tree>`), falling back to the
   tree's copy only when the lane lacks one.
2. **Dispatch defect — BASE resid expectation.** The dispatch says a BASE tree
   does not carry `plans/round-63-c1.sh`; it does, and at this BASE the round-63
   counter reads `accepted=0 rejected=0 population=10/6 guard=1` (round 63's
   hardening landed before this BASE). So `resid=1` at BASE. That is the plan's
   guard (c) "no regression" reading, not a kill; the leg can still read 0
   (selftest 0-path, and any regression on a committed fixture reads
   rejected≥1). Do not read `resid=1` at BASE as the leg being vacuous.
3. **Dispatch vs plan — selftest floor.** Dispatch: N ≥ 109. Plan §C1(b): N ≥ 91.
   The counter uses 109 (hardening checker measured `cases=110`) and prints the
   floor in the provenance. If the frozen checker ends below 109 the leg reads 0;
   the L1 should rule on the floor, not read it as a checker failure.
4. **Budget.** BASE verdict = 744 s (measure 396, resid 312). The resid leg's
   budget is `C1_RESID_TIMEOUT` (default 1500 s; a timeout reads resid=0 with the
   reason printed). For a slow candidate: `C1_RESID_TIMEOUT=2400 bash
   plans/round-64-c1.sh <rev>` under `timeout 3600`. The per-leg timings are in
   the verdict provenance.
5. **Live-file contention (disclosed).** R64MutC1's harness wrote the live file
   through a symlink farm (`VEHICLE=1`) at 02:36; disclosed, killed, restored
   from this seat's snapshot. No mutant reading was taken on those bytes as
   final; the frozen sha was re-tested after the restore.
6. **Provenance bugs fixed during the build** (`cases=91` from the vehicle gate
   overwriting `ST_*`; `stub2_e2` printed instead of `stub_e2`) — both could
   have been misread as candidate readings; they are gone on the frozen bytes.

## 5. State of the claim

`C1_HELDOUT` at BASE: `heldout=8 population=8 guard=0`, rc 1. The counter is
ready for the candidate; the candidate reading is the L1's to take. What the
candidate must satisfy: the five H copies read `value>=1`, the three Q copies
read `value=0` (heldout 0), the checker's selftest prints ≥109 cases, the
round-63 counter still reads `accepted=0 rejected=0 guard=1`, both stub shapes are
refused, and the A4 vehicle still reads `heldout>=1`.

## 6. Files

- `plans/round-64-c1.sh` (sha `e03a4d69…`, 885 lines) — the counter.
- `.ufo/waves/round-64/build/R64ExecC1Counter/counter.md` — full receipt (every
  command, output, hash, timing, defect).
- `.ufo/waves/round-64/build/R64ExecC1Counter/selftest.txt` — selftest receipt.
- `.ufo/waves/round-64/build/R64ExecC1Counter/base-verdict.txt` — BASE verdict.

No tool installed or upgraded; pacman untouched. Scratch
`/fast/scratch/hyaku/kagi-r64/R64ExecC1Counter/` deleted before this yield.
