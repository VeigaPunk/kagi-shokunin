# R64Reviewer — attack report (round 64, kagi)

Seat: reviewer (attack). Read-only on lane source; every attack tree and counter
copy lived under `/fast/scratch/hyaku/kagi-r64/R64Reviewer/` (removed before
yield). Full record, every command and line: `.ufo/waves/round-64/build/R64Reviewer/findings.md`
with `receipts/` and `attacks/`.

**Disclosure:** this seat did **not** read `plans/round-64-heldout.tsv`. The seal
was copied byte-for-byte into one scratch tree only so the counter's sha256 check
would run; its contents were never opened. No held-out reading is claimed.

## Pins

- Lane HEAD `eb647d23132cf7ffc3b3cd08f2083b8e39e5391e` (working tree dirty and live
  during the seat).
- Checker BASE (HEAD) `eb08094c…` (2031 lines); hardened working-tree bytes
  `c433dcb2…` (2127 lines), `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=110)`.
- C1 counter moved `552775a2…` → `b940c890…` → `7e5bcfa1…` → `2d5cba28…` →
  `83d1ee8b…` while this seat ran; the forged pass was re-measured on `83d1ee8b`
  (last bytes seen; the unbound variable is at `:559`/`:620` on all four).
- C2 counter `061f0ad5…`; controls battery `4db83dd2…` (moved from `7c247aea…`).
- BASE no-work control re-derived on the unmodified slim tree: `heldout=8`
  (`H accepted=5/5`, `Q rejected=3/3`) — the population is real at BASE.

## C1 — 21 new forgery instances, 19 still accepted

`accepted` = `C1_ROUTED: value=0`. BASE = HEAD checker; hardened = `c433dcb2`.

| id | class | BASE | hardened |
|---|---|---|---|
| F01 | denial predicate in a later sentence (I3) | accepted | **accepted** |
| F02 | negator in a previous sentence (I3) | accepted | **accepted** |
| F03 | subject swap with a third subject (I7) | accepted | **accepted** |
| F04 | unbound duplicate pair (I7) | accepted | rejected `i7=0` — fix fires |
| F05 | duplicated mechanism + contrastive hedge (I5) | accepted | **accepted** |
| F06 | `no such`-style denial the list misses (I3) | accepted | **accepted** |
| F07 | fabricated stamp that is a derived committer time (I6) | rejected | rejected — closed |
| F08 | fraction + percentage from a different denominator (I7) | accepted | **accepted** |
| F09 | appositive hides a negation (I3) | accepted | **accepted** |
| F10 | token form the lists do not carry `cannot` (I3) | accepted | **accepted** |
| F11 | I4 denial verb outside the closed set | accepted | **accepted** |
| F12 | I5 post-token denial outside the closed set | accepted | **accepted** |
| F13 | I6 post-token denial outside the closed set | accepted | **accepted** |
| F14 | denial predicate in a later sentence (I7) | accepted | **accepted** |
| F15 | quote mask deletes a scare-quoted negator (I3) | accepted | **accepted** |
| F16 | negation after the subject, pair still binds (I7) | accepted | **accepted** |
| F17 | fabricated non-derived stamp riding the `>=3` floor (I6) | accepted | **accepted** |
| F18 | negator beyond the 24-token window (I3, ceiling) | accepted | **accepted** |
| F19 | `no such` denial missed: `does not exist` (I3) | accepted | **accepted** |
| F20 | same-sentence denial beyond the 24-token post window (I3) | accepted | **accepted** |
| F21 | negator denial the I6 list misses (I6) | accepted | **accepted** |

The two fixes the round claims are visible where they apply (F04, F07); the
negated-subject guard fires only when the blocker precedes the subject (F16 is the
one-sided case). The plan's "eight fixtures are eight fixtures" ceiling stands —
this is class openness beyond it, not a falsification of `heldout=0`.

## C1 — 13 new benign rewrites

B01 appositive, B02 passive, B03 numeric, B04 hyphenated, B05 contrastive,
B06 parenthetical aside, B07 em-dash aside, B08 quoted-but-asserted — **all eight
accepted** by `c433dcb2` (the classes the seat was asked for). B13 (`not less than`
idiom) is accepted by the hardening, rejected at BASE — the round's fix works.

**B11 is the one regression**: `no reading other than the literal reading gives
3/16 = 18.75 %` reads `value=0` at BASE and `value=1 i7=0` on `c433dcb2`
(`_subject_blocked` sees `no` five tokens before the subject). B09/B10/B12 are
rejected at BASE too — pre-existing precision, not round-64 regressions.

## Counter attacks (measured)

- **C1 forged pass.** The counter names each fixture copy after its id
  (`meas.H-F2.tree` / `meas.Q-P6.tree`) and passes that path to the checker. A
  path-keyed printer stub plus a three-line stub `plans/round-63-c1.sh` reads
  `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1
  vehicle=1)` rc 0 — measured on `83d1ee8b` with only the one-line unbound-variable
  defect fixed. On the unedited bytes the verdict path dies first:
  `round-64-c1.sh: line 620: stub2_e2: unbound variable`, rc 1, no verdict line.
- **C2 forged pass.** A tree whose seven instruments are stubs reads
  `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1
  real=1 terminates=1 bound=1)` rc 0 in 5 s — no counter work.
- **C2-BOUND cannot fail on a crash.** A counter that exits 1 immediately under
  `C2_RECURSION_BOUND=0` reads `CONTROL C2-BOUND … observed=no-verdict-line;rc=1
  verdict=match`; "no verdict line and any rc≠0" is mapped to nontermination.
- **`--selftest` printers.** `C1_HELDOUT_SELFTEST: PASS (cases=22)` and
  `C2R64_SELFTEST: PASS (cases=21)`, rc 0, from copies that execute no case; the
  C1 copy also prints PASS with no held-out table readable (the dispatch precedes
  the seal check). Nothing in the wave runs either counter's selftest.
- **Empty control list.** A battery with the eight `ctrl_*` calls replaced by `:`
  reads `CONTROLS: match=0 mismatch=0`, `SKIPS: 0`, `SEAT-STATUS: complete`, rc 0.
- **`C1-F9`/`C2-F7` cannot test the counter**: `mk_stub_counter` prepends a
  dispatch to a copy of the counter and checks the battery's own constant line
  (round-63 F-4, unchanged).

## Findings (severity, fix)

- **R64-C1-01 CRITICAL (operability)** — `stub2_e2` unbound at the verdict path
  (`:562` sets `stub_e2`; `:623` reads `stub2_e2`); the C1 counter cannot print
  `C1_HELDOUT:` on any tree. Fix: `stub2_e2=$SL_OK`, re-run before any claim.
- **R64-C1-02 HIGH (guard d)** — fixture id in the copy path lets a printer stub
  reach `heldout=0 guard=1`. Fix: opaque equal-length copy names plus a per-run
  nonce; never pass the fixture id in a path or argv; pin the checker sha256.
- **R64-C1-03 HIGH (guard c)** — the resid leg (and the vehicle identity leg) run
  the measured tree's own `round-63-c1.sh`; a 3-line stub reads `resid=1`. Fix: run
  the counter from bytes pinned at BASE (sha256 in the counter; mismatch ⇒ SETUP).
- **R64-C1-04 MEDIUM (conformance)** — `SELFTEST_FLOOR=109`, the frozen predicate
  says `N >= 91`; the instrument refuses what the plan allows. Fix: set 91 or land
  a disclosed amendment before the candidate reading.
- **R64-C1-05 LOW (reporting)** — the provenance `cases=` line reports the A4
  vehicle's gate (91) because `leg_vehicle` overwrites `ST_N`. Fix: keep the
  measured gate in its own variables.
- **R64-C1-06 MEDIUM** — a `--selftest` printer is unrefused and skips the seal.
  Fix: self-challenge case or a `C1-SELFTEST-MUT` control; seal check before the
  mode dispatch.
- **R64-G-01..G-04 MEDIUM (grammar)** — I3 sentence scope (F01,F02,F06,F09,F10,
  F15,F18,F19,F20), I7 one-sided binding and non-derived pairs (F03,F08,F14,F16),
  I5 mechanism-only-once by token count (F05), I6 `>=3` floor plus closed denial
  list (F13,F17,F21). Fixes per class in `findings.md` §4 (whole-section denial
  scan, own-clause polarity both sides, mechanism predicates, set inclusion for
  stamps).
- **R64-G-05 LOW (ceiling)** — I4/I5 denial verbs outside the closed sets (F11,
  F12): named floor, no fix required this round.
- **R64-G-06 MEDIUM (regression)** — B11 benign comparative rejected only by the
  hardening. Fix: do not block a subject whose negator governs `other than` /
  `except` / `but`.
- **R64-G-07 LOW (pre-existing)** — B09/B10/B12 rejected at BASE too; the benign
  claim should not be read as covering abbreviations inside em-dash asides, a pair
  stated before its subject, or nested parentheses.
- **R64-C2-01 HIGH (forged pass)** — every leg/guard reads tree-supplied scripts.
  Fix: pin the seven instrument shas at BASE; SETUP on mismatch.
- **R64-C2-02 HIGH (guard b)** — a bound=0 crash reads `match`. Fix: require
  `rc=124` (or 137); any other non-zero rc is a mismatch, and assert the run
  consumed the timeout budget.
- **R64-C2-03 MEDIUM** — bound=0 runs the full battery with no timeout, so guard
  (b) measures the tree's battery, not the counter. Fix: give the bound=0
  delegation a hard timeout and read SETUP if it returns.
- **R64-C2-04 MEDIUM** — guard (a)/(c)/(d) execute the tree's scripts. Fix: same
  sha pinning as R64-C2-01.
- **R64-C2-05 MEDIUM** — C2 `--selftest` printer unrefused. Fix: self-challenge.
- **R64-B-01 MEDIUM (guard d witness)** — empty control list reads a clean
  battery. Fix: minimum population plus the six named ids, else SETUP.
- **R64-B-02 HIGH (cannot fail)** — `C1-F9`/`C2-F7` are satisfied by the battery's
  own stub machinery; round-63 F-4 unchanged. Fix: run the measured counter on a
  mutated tree and require a non-target reading.
- **R64-B-03 MEDIUM** — PRIOR delegation re-emits six `skip` rows with
  `match=0`; the C2 guard's "still match with 0 skips" has no witness here. Fix:
  require the PRIOR stub-control matches and fail on a PRIOR skip.

## Verdicts (this seat)

- **C1**: the number is not falsified on an honest tree (BASE no-work `heldout=8`
  re-derived; no seal read). The guard is falsified: `guard=1` is forgeable with a
  one-line typo fix and a tree that supplies its own instruments.
- **C2**: the termination claim is not falsified on the honest candidate; the
  composition is — seven stubs reach `killed=5 guard=1 terminates=1`, and the bound
  leg admits a crash.
- **Grammar**: open beyond the declared ceiling — 19 new forgeries accepted, one
  benign class newly rejected.

## Verification gaps

- The lane was live (checker `2d48e481→c433dcb2`, C1 counter
  `552775a2→b940c890→7e5bcfa1→2d5cba28→83d1ee8b`); the L1 must re-check `stub2_e2`
  in the committed bytes (`:559` sets `stub_e2`; `:620` reads `stub2_e2`).
- Not read: the sealed held-out table. Not run: the real bao trial, the round-63
  counter's full end-to-end, any lane gate. No lane file written; no git/jj
  mutation; no tooling installed.

SEAT-STATUS: complete
