# R64ExecC1Counter — C1_HELDOUT counter receipt

Seat: R64ExecC1Counter (executor). File owned: `plans/round-64-c1.sh`
(885 lines, sha256 `e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484`).
Lane repo: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`).
Report: `.ufo/waves/round-64/w1/R64ExecC1Counter.md`.

## 1. Frozen facts this counter seals

| item | value | source / command |
|---|---|---|
| held-out table | `plans/round-64-heldout.tsv`, 20 data rows | plan §C1 + Amendment A1 |
| seal | `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2` | `sha256sum plans/round-64-heldout.tsv`, 2026-11-08 (matches the plan) |
| population | 8 = H1..H5 (F2,F6,F8,F10,B4) + Q1..Q3 (P6,B5,P7) | plan §C1 predicate sentence (A1) |
| target | heldout = 0 (BASE 8) | plan §C1 |
| output line | `C1_HELDOUT: heldout=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)` | plan §C1 |
| exit | 0 iff guard=1 and A=0; 1 otherwise; 2 SETUP | plan §C1 |
| selftest floor | N ≥ 109 (plan floor 91; raised — see §6.1) | this counter, header |
| slim tree | the checker's seven inputs + `plans/round-63-c1.sh` when present | measured; §6.2 |

The counter opens with `sha256sum` on the table and refuses (`SETUP` rc 2, a
`c1-heldout:` line only) on any mismatch, before any tree work. A verdict run
never honours a table override; only the diagnostic modes do (§6.3).

## 2. Acceptance commands and outputs

### 2.1 Selftest — PASS, 23 cases

```
$ bash plans/round-64-c1.sh --selftest
C1_HELDOUT_SELFTEST: PASS (cases=23)
rc=0
```
Receipt: `.ufo/waves/round-64/build/R64ExecC1Counter/selftest.txt` (≈440 s wall in
the paired run — 1187 s total for selftest + BASE verdict, of which the BASE
verdict measured 744 s — BASE revision `09cbee83…`, slim archive). Witness lines
in the same receipt:

```
c1-heldout: witness seal rc=2 line=c1-heldout: SETUP held-out table seal mismatch: expected b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2, found de0bae5836d252c20cac5718faaee9d6c7fc3252a83ae1051673ab68360aa5dd — refusing
c1-heldout: witness W0 rc=1 line=C1_HELDOUT: heldout=5 population=8 guard=0 (real=1 selftest=0 resid=0 stub=1 vehicle=1)
c1-heldout: witness W1 rc=1 line=C1_HELDOUT: heldout=3 population=8 guard=0 (real=0 selftest=0 resid=0 stub=1 vehicle=1)
c1-heldout: witness W2 rc=1 tamper=1 line=C1_HELDOUT: heldout=5 population=8 guard=0 (real=1 selftest=0 resid=0 stub=1 vehicle=0)
```

The 23 cases: seal-sha256, seal-refusal, tsv-shape, tsv-row-count, hq-parse,
fixture-apply-exactly-once (all eight H/Q anchors apply exactly once),
tree-has-checker, guard-composition (all-1 plus each of the five legs forced 0),
value-parse, stub-refused (both printer shapes), stub-leg-negative-vector,
count-witness-zero (constant value=0 ⇒ heldout=5), count-witness-one (constant
value=1 ⇒ heldout=3), selftest-floor (109 passes, 108 does not), bits-parse,
resid-absent-reads-zero, vehicle-fires, vehicle-round63-identity,
vehicle-negative-vector (a vehicle that answers the held-out forgeries reads
heldout=0), verdict-wiring-w0, verdict-wiring-w1, vehicle-leg-zero,
verdict-line-shape.

The verdict-wiring cases run the whole verdict path as a child process on
printer-witness trees and compare the **full verdict line** and the exit code
(W0/W1/W2 above). They kill forced-0, skip and forced-1 mutants of the verdict
wiring. Measured by the mutation seat on the frozen bytes (ledger
`.ufo/waves/round-64/build/R64MutC1/mutants.md` §6/§6b, one mutant per assignment
rule, every mutated copy's sha256 recorded there):

| mutant | reading |
|---|---|
| S1 force heldout=0 | KILLED (verdict-wiring-w0/w1) |
| S2 force guard=1 | KILLED (verdict-wiring-w0/w1) |
| S3 skip resid leg | KILLED (verdict-wiring-w0/w1) |
| S4 skip vehicle leg | KILLED (vehicle-leg-zero) |
| S5 skip the seal refusal | KILLED (seal-refusal) |
| S6 force exit 0 | KILLED (verdict-wiring-w0/w1) |
| S7 force stub=1 | **SURVIVED** — named ceiling: every witness expects stub=1, so a constant is indistinguishable; killing it needs a `leg_stub` override plus a witness whose stub shapes are accepted (STUB=0) |
| S8 force real=1 | KILLED (verdict-wiring-w1) |
| S9 force selftest=1 | KILLED (verdict-wiring-w0/w1, vehicle-leg-zero) |

The surviving class is exactly the named ceiling in the header: a forced-1 on a
leg every witness expects to read 1 (round-63 M63-6 class).

### 2.2 BASE reading — `heldout=8 population=8 guard=0`, rc 1 (K1)

```
$ bash plans/round-64-c1.sh 09cbee831d57be7c4edfbe77bf238f46bf729047
c1-heldout: measured=revision 09cbee831d57be7c4edfbe77bf238f46bf729047 (slim archive: 7 checker inputs plus any optional file present)
c1-heldout: seal=sha256 b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2 (frozen)
c1-heldout: selftest rc=0 pass=1 cases=102 (guard floor 109)
c1-heldout: H accepted=5/5 (each counted when value=0) Q rejected=3/3 (each counted when value>=1)
c1-heldout: per-fixture F2=value0 F6=value0 F8=value0 F10=value0 B4=value0 P6=value1 B5=value1 P7=value1
c1-heldout: unmodified value=0 bits=i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1
c1-heldout: resid leg=1 (C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1 chal=1))
c1-heldout: stub e1_rc=2 e1_ok=1 e2_rc=2 e2_ok=1
c1-heldout: vehicle heldout=5 r63=1 (must be heldout>=1)
c1-heldout: timing measure=396s real=33s resid=312s stub=0s vehicle=2s total=744s (resid budget 1500s)
C1_HELDOUT: heldout=8 population=8 guard=0 (real=1 selftest=0 resid=1 stub=1 vehicle=1)
rc=1
```
Receipt: `.ufo/waves/round-64/build/R64ExecC1Counter/base-verdict.txt`.
Base checker: `plans/round-61-c1-check.py` at BASE = sha256
`eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`
(2031 lines, `--selftest` `PASS (cases=102)`).

Reading: K1 holds — a tree byte-identical to BASE reads `heldout=8 population=8`
(all five H forgeries accepted, all three Q benign rewrites rejected). Guard=0
because only the selftest floor fails (102 < 109); the other four legs read 1.

### 2.3 Seal refusal (mutated table copy)

```
$ python3 - <<'PY'  # mutate the F2 replacement in a scratch copy of the table
$ sha256sum $S/mut/plans/round-64-heldout.tsv
da002285e6bfd7aaefde3fde66e5880fb289d7de2ed653abff84893d67d3e500
$ bash $S/mut/plans/round-64-c1.sh --selftest
c1-heldout: SETUP held-out table seal mismatch: expected b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2, found da002285e6bfd7aaefde3fde66e5880fb289d7de2ed653abff84893d67d3e500 — refusing
rc=2
```
No `C1_HELDOUT:` line. (The lane's sealed file was never modified; the fake lane
holds a copy of the counter and a copy of the table.)

## 3. The A4 vehicle leg — evidence

The counter builds the vehicle from the plan's §C1(e) description
(`make_vehicle_tree`): a literal `NEGATORS = frozenset(())` dead line, a
15-string lookup built from `plans/round-63-residual.tsv` (10) +
`plans/round-62-bypass.tsv` (5), and a constant
`C1_CHECK_SELFTEST: PASS (cases=91)`.

Measured (independent probe before it was folded into the counter,
`/fast/scratch/hyaku/kagi-r64/R64ExecC1Counter/probe/probe_round63.py`):

- On the round-63 committed tables: `F1..F10 → value=1`, `P1..P6 → value=0`,
  `B3..B7 → value=1`, unmodified `value=0`; the round-63 counter on the vehicle
  tree reads `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=0
  (real=1 selftest=1 prior=1 para=1 stub=1 chal=0)` — `accepted=0 rejected=0`
  holds (it is the real vehicle), refused only by the round-63 `chal` leg.
- On the round-64 held-out set: `F2,F6,F8,F10,B4 → value=0` (all five forgery
  fixtures accepted) and `P6,B5,P7 → value=0` (benign accepted) ⇒ **heldout=5**;
  the vehicle cannot answer the held-out fixtures, so guard leg (e) reads 1.
- The answering variant (table + the five H replacements) reads `heldout=0` —
  the negative vector: the leg is able to fail (selftest case
  `vehicle-negative-vector`; the W2 witness drives the whole verdict line to
  `vehicle=0`).

## 4. Defects found while building (reported, not laundered)

1. **The dispatch's resid invocation cannot work on a slim tree.** `bash
   <tree>/plans/round-63-c1.sh --tree <tree>`: the round-63 counter derives
   `LANE` from its own `BASH_SOURCE`, so inside a slim copy it reads its fixture
   tables from `<tree>/plans/*.tsv` and prints `c1-residual: SETUP forgery
   fixture table not readable: <tree>/plans/round-63-residual.tsv` rc 2 — the
   (c) guard leg could never fire. Reproduced by R64ScribeEntry
   (`/fast/scratch/hyaku/kagi-r64/R64ScribeEntry/kagi-r64/R64ExecC1Counter/run-20261108T023040Z-3336648/resid.out`).
   Fix: invoke the committed instrument from the lane
   (`bash <lane>/plans/round-63-c1.sh --tree <tree>`); the tree copy is a
   fallback only when the lane lacks one.
2. **The dispatch's BASE expectation for the resid leg is stale.** It says a
   BASE tree does not carry `plans/round-63-c1.sh`; it does (`git show
   09cbee83:plans/round-63-c1.sh` succeeds), and at this BASE the round-63
   counter reads `accepted=0 rejected=0 population=10/6 guard=1` (round 63's
   hardening landed before this BASE). The leg therefore reads 1 at BASE, which
   is the plan's guard (c) "no regression" reading, not a kill. The leg is not
   vacuous: it can read 0 (selftest case `resid-absent-reads-zero`, and a
   regression on a committed fixture would read rejected≥1).
3. **A sibling's mutation harness wrote the live lane file through a symlink
   farm** (R64MutC1, disclosed): `VEHICLE=1` replaced the `leg_vehicle` call at
   02:36 (sha `b07bc518…`). Disclosed by the author, killed, restored from the
   seat's own snapshot; the frozen bytes are the ones tested.
4. **`cases=91` in the provenance echo** was an ordering bug: the vehicle leg's
   gate overwrote `ST_*` before the echo printed them. Fixed by saving
   `MEASURED_ST_*` right after the measured tree's gate.
5. **`stub2_e2` vs `stub_e2`** — the composition used `stub_e2` while the echo
   printed an unset look-alike (stale 0). Fixed (one variable, initialised).
6. **`vehicle-leg-zero` failed once for a sibling** (R64ScribeEntry, 02:47) on
   the same sha I measured PASS on: their run straddled the 02:45 edit that
   fixed the fake-lane tamper (pre-fix, the tamper was a no-op, so the vehicle
   answered the tables and read 1). The case now echoes its child line and
   tamper flag, so a failure is self-diagnosing. Re-measured PASS by this seat
   on both the immediate-fix bytes (sha `ca6dec9b`, cases=22) and the frozen
   bytes (sha `e03a4d69`, cases=23).

## 5. Budget / operability (for the L1's candidate run)

Measured on the BASE tree under the fleet's load (≈1300 live peers):
`measure=396 s`, `real=33 s`, `resid=312 s`, `stub=0 s`, `vehicle=2 s`,
`total=744 s` (12 m 24 s). One measured-checker run ≈ 27–50 s; the round-63
counter runs 24 fixtures through it.

- The resid leg's budget is `C1_RESID_TIMEOUT` (default 1500 s). A timeout
  reads `resid=0` with the reason printed — never a silent pass.
- A candidate whose checker is much slower can exceed the budget; the L1 can
  raise it (`C1_RESID_TIMEOUT=2400 bash plans/round-64-c1.sh <rev>` under
  `timeout 3600`). The leg's timing is printed in the verdict provenance.
- The counter never writes inside the measured tree; scratch is
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecC1Counter/<tag>`, and
  the copy target refuses to sit at/inside the measured tree (QM74).

## 6. Design notes / named tensions

1. **Selftest floor 109 vs the plan's frozen 91.** The dispatch says "N ≥ 109
   (raise the floor with the hardening; record it in the header)"; the plan
   freezes 91. This counter uses 109 and prints the floor in the verdict
   provenance. If the frozen checker ends below 109, the leg reads 0 and the L1
   should rule on the dispatch-vs-plan floor rather than the counter being
   silently lenient. The hardening checker measured `cases=110`.
2. **Slim tree contents.** The checker reads seven files; the fleet report the
   I6 derivation reads is resolved from the fleet root, not the tree. The slim
   tree is materialised from a revision with `git archive <rev> -- <paths>`
   (no 263 MB copy) or from `--tree DIR` with `tar` over the same list. The
   measured BASE slim tree reproduces the full tree's `value=0` and the
   round-63 counter's full-tree verdict (`accepted=0 rejected=0 guard=1`).
3. **Diagnostic table override.** `C1_HELDOUT_TSV_OVERRIDE` is honoured only in
   `--selftest` / `--no-challenge` (never in a verdict run) and exists so the
   selftest can exercise the seal refusal; the override path is not part of any
   verdict.
4. **Named ceiling.** Forced-1 on the `stub` leg survives (its 0 path needs a
   filesystem failure); forced-1 on any leg a witness expects to be 1 survives
   by construction (same class as round-63 M63-6). Eight fixtures are eight
   fixtures, not a grammar proof (plan §C1).

## 7. Host / tooling

- No tools installed or upgraded; `pacman` untouched (host-wide pause).
- Scratch under `/fast/scratch/hyaku/kagi-r64/R64ExecC1Counter/` (deleted
  before yield); no citable evidence under `/tmp`.
- Read the sealed table (permitted for this seat).
