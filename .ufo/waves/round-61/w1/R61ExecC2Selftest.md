# R61ExecC2Selftest — seat report (kagi round 61, wave 1)

Item: C1/I2 (spot-check D2) — give `plans/round-60-c2.sh` its own fixture-driven
`--selftest` with a red witness and re-register its `SKILL.md` gate row.
Status: **complete** (see `SEAT-STATUS` at the end).

## Files changed

- `plans/round-60-c2.sh` — the seat's one lane file: header contract extended, arg
  parse made hermetic (`--selftest` dispatch before the python3/git/pin checks;
  unknown `--flag` ⇒ `SETUP` rc 2 in every mode; `--work` accepted selftest-scoped,
  `SETUP work-flag-outside-selftest` rc 2 in run mode), and a fixture-driven
  `run_selftest()` added (36 assertion cases; the run-mode evaluation after the
  dispatch — pin checks, scratch, tree materialisation, legs, verdict mapping, value
  line, exit contract — is byte-unchanged). New sha256
  `135fc46f1a39036d0129a317d82caa79ff3ccdab6ee2562d3d6892f70b87fe95`.
- `SKILL.md` — the one gate-registry row whose name cell contains
  `plans/round-60-c2.sh`: selftest cell re-registered; `none of its own` gone. Old→new
  in `.ufo/waves/round-61/build/R61ExecC2Selftest/diff.md`; nothing else in
  `SKILL.md` touched.
- Receipts (mine): `.ufo/waves/round-61/build/R61ExecC2Selftest/{selftest.txt,selftest-mutant.txt,diff.md}`.

## Behavior of `--selftest`

Fixture-driven, no `bao`, no network, no real trial (I2/QM76): it builds throwaway
fixture trees under `--work` (default `TMPDIR`, else
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecC2Selftest/selftest`) holding a
copy of the counter, a fixture `plans/round-57-c2.sh` pin naming a fixture `bao` stub,
and a fixture `corpus/openbao-approle-trial.sh` whose canned verdicts (keyed by a
`.st-mode` file, never by ambient env) drive the counter's real end-to-end path —
scratch, `env -i` legs, verdict mapping, secret scan, exit contract. 8 fixture cases /
36 assertions: absent trial (`value=0` rc 1); all five legs satisfied (`value=5` rc 0,
exact census line with the HHHHH baseline and all five shim vectors); broken shim
vector (SH1 flips T2 ⇒ `shims=4 vectors=4/5 sh1=HBHHH`, rc 1); missing second real run
(real2 ERRORs, identified as the second empty-shim non-ambient leg ⇒
`real=0 real2=0 pass=0`, rc 1); no-bao leg printing HOLDS ⇒ `none=0`, rc 1; failing
trial selftest ⇒ `selftest=0`, rc 1; secret-shaped fixture token ⇒ `secret=0`, rc 1
(the token is generated at run time as `hvs.` + random hex, so no secret-shaped
literal exists in any source or receipt); unknown flag ⇒ `SETUP unknown-flag` rc 2.
Each failed assertion prints `FINDING C2-ST-<case>-<what>`. Red witness built in: two
more copies invert the verdict mapping (`tr HB BH` in `vec`) or drop the SH1
expectation (`[sh1]=BHHHH` → `HHHHH`) and must exit non-zero printing
`FINDING C2-ST-MUT*` ids (`C2_ST_NOMUTANT=1` stops a mutated copy re-running the
witness on itself). Output: exactly one `C2_SELFTEST: PASS (cases=N)` rc 0 or
`C2_SELFTEST: FAIL (cases=N failed=M)` rc 1; `C2_SELFTEST: SETUP <reason>` rc 2.
Fixtures are removed on exit; umask 077; no hardcoded /tmp.

## Evidence (executed by this seat)

- `bash plans/round-60-c2.sh --selftest` from the lane root ⇒
  `C2_SELFTEST: PASS (cases=36)`, rc 0 (~4 s) — `build/R61ExecC2Selftest/selftest.txt`.
- Red witness (kept receipt `build/R61ExecC2Selftest/selftest-mutant.txt`): scratch
  copy with the verdict mapping inverted (sed
  `s/| cut -c1)/| cut -c1 | tr HB BH)/`, mutant sha256
  `e1f04a4f49465e84b7e846b51fa76ee986f64b5932f21c3f5da178e006530078`) ⇒
  `C2_SELFTEST: FAIL (cases=28 failed=8)` with named `FINDING C2-ST-HOLDS-RC`,
  `C2-ST-HOLDS-LINE`, `C2-ST-BADVEC-*`, `C2-ST-REAL2-AMBIENT`, `C2-ST-STFAIL-REAL`,
  `C2-ST-SECRET-REAL`, rc 1. The second mutation (SH1 expectation dropped) is asserted
  inside the PASS run itself (`C2-ST-MUTEXP-*` cases green in `selftest.txt`).
- Run-mode smoke, no trial executed: `bash plans/round-60-c2.sh
  a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2` ⇒
  `C2_APPROLE_TRIAL: value=0 … guard=0 (absent)`, rc 1 (BASE control leg unchanged).

## Fidelity notes

- The two real runs are indistinguishable inside the trial (`env -i` passes only
  HOME/PATH/TMPDIR/LANG/shim; ambient is identifiable by its placeholder `BAO_*`), so
  the "missing second real run" fixture identifies the second empty-shim non-ambient
  invocation via a counter file in the fixture tree — the same trick
  `plans/round-60-controls.sh` C2-F4 uses. Leg order is shuffled by the counter, and
  this identification is independent of shuffle order.
- The pre-freeze battery's `c2cap` invokes the counter only as
  `bash "$C2" --tree <tree>`; the parse change preserves `--tree`, revision-first-wins
  and the `--tree`-missing-arg bad-tree line byte for byte, so no existing caller
  changes reading. The round-61 I2 checker and the C1-F7 control get exactly the
  frozen contract: hermetic PASS line, and a mutated copy that exits non-zero with
  named FINDING ids (the mutant needs no `plans/round-57-c2.sh` next to it — the
  selftest dispatch precedes the pin check).

## Not run / ceilings

No real trial, no `bao` server, no network, no git/jj mutation anywhere; the counter's
full real-trial reading (two 900 s-capped real runs + shims) belongs to the parent's
post-integration gate. Secret discipline: no secret-shaped literal in any source or
receipt (the fixture token is runtime-generated; receipts name shapes and counts
only). No tools were installed or upgraded (none needed).

## Risks

- The built-in red-witness sed patterns are tied to the current byte shapes of
  `vec()` and `EXPECT`; if the counter's evaluation code is ever rewritten, the
  `C2-ST-MUT*-APPLIED` assertions fail closed (the selftest reports FAIL), which is
  the intended tripwire, but the sed expressions would need updating in the same
  change.
- `cases=36` is assertion-count (round-60 trial convention, `APPROLE_SELFTEST`
  cases=45); a mutated copy with `C2_ST_NOMUTANT=1` reports `cases=28` — disclosed in
  the mutant receipt.

SEAT-STATUS: complete
