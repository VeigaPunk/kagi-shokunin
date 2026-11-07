# R62ExecC2Counter — seat report (kagi round 62, w1)

Seat: R62ExecC2Counter (executor, C2 lane). Claim worked: **C2_HARDENED** (operability:
the C2 counter's guard and self-invocation can fail — killed 0 → 3). BASE
`60b5b7b60b76629633110a5b4adac883193c8b2a`. Frozen plan `plans/round-62.md` §C2 read
before work, together with `corpus/lessons/round-61-verifier-spotcheck.md` §7 and
`corpus/lessons/round-61.md`. No frozen predicate, target, POP, kill rule or item
condition was amended.

## Files changed (exactly the assigned scope)

| file | change |
|---|---|
| `plans/round-61-c2.sh` (sha256 `20614697f3720aa446501b3c3246748c762a025b99065a19556476d9ff3f4f29`, 25970 B) | hardened: marker-delimited `decide` and shim aggregation units; `--selftest` now executes the aggregation (11 → 21 cases); guard requires per-leg observables; scratch re-pointed to `kagi-r62/R62ExecC2Counter` |
| `plans/round-62-c2.sh` (sha256 `59553ef46b8e4052cb6bf0b863e90ad973347bd5c14d623b12e8384f46404c57`, 14818 B) | new round-62 counter: modes `[revision]` / `--tree DIR` / `--selftest`; legs M-A, M-B, G; guard legs (a)/(b)/(c); one-line verdict; exit 0 iff guard=1 and killed=3, 1 otherwise, 2 SETUP |
| `.ufo/waves/round-62/build/R62ExecC2Counter/` | 8 receipts (below) |
| `.ufo/waves/round-62/w1/R62ExecC2Counter.md` | this report |

No other lane file was written; no git/jj mutation anywhere; nothing written outside the
lane paths above and the seat scratch `/fast/scratch/hyaku/kagi-r62/R62ExecC2Counter/`
(deleted before yield; the counters' own scratch is self-cleaning).

## Hardening of `plans/round-61-c2.sh` (behavior)

- `decide()` (six leg values pass shims none selftest ops t2w → echoes `0|5`) and
  `shim_count()` (five shim OUT files → echoes `0..5`) are delimited by the markers
  `# BEGIN-DECIDE` / `# END-DECIDE` and `# BEGIN-SHIMS` / `# END-SHIMS`, each occurring
  exactly once (measured). The function header/footer lines sit OUTSIDE the markers, so a
  strictly-between constant replacement yields a valid constant function — exactly the
  M-A/M-B falsifier shape. The main path calls both (`shims_ok=$(shim_count …)` with the
  per-shim rc=1 gate kept on the main path; `value=$(decide …)`), and the stub-control and
  secret-scan gates still force `value=0` afterwards.
- `--selftest` keeps all 11 prior cases and adds ten aggregation cases: positive vector
  `decide 5 5 1 1 1 1 = 5`, one negative vector per leg (`decide 4 5 1 1 1 1 = 0`,
  `5 4 …`, `5 5 0 …`, `5 5 1 0 …`, `5 5 1 1 0 …`, `5 5 1 1 1 0`), `shim_count` over five
  correct fixtures = 5, over a wrong-vector fixture set = 4, over a right-vector/missing-
  summary fixture = 4. Measured: `C2_SELFTEST: PASS (cases=21)` rc 0. A constant
  replacement of either block fails named cases (leg receipts below), closing the C2-5
  finding.
- The guard is no longer "legs ran + sha256 recorded" (the C2-4 near-constant): it
  additionally requires every leg's expected observable in its captured stream — the
  trial's `SEAL_SELFTEST: PASS (cases=N)` line grepped on the selftest leg stdout, the
  real runs' TRIAL/summary content (`real_ok`), the no-bao SETUP line without HOLDS
  (`none_ok`), the trial selftest PASS with N ≥ 8 (`selftest_ok`), the ops argv shapes
  (`ops_ok`), the T2 progress markers (`t2_ok`) and the five exact shim flips
  (`shims_ok=5`) — so a valid-sha256 stub trial that prints nothing reads `guard=0`
  (measured, leg-g receipt). "Evaluated and failed" is distinguishable from "could not
  evaluate".

## `plans/round-62-c2.sh` (behavior)

- Legs: M-A applies `  echo 5` strictly between the DECIDE markers of the measured
  tree's `plans/round-61-c2.sh`; M-B applies `  shims_ok=5` strictly between the SHIMS
  markers. The needle (`grep -cF`) must match exactly once for each marker or the leg is
  absent (fails closed, K2). Mutant copies live in mirrored scratch trees carrying the
  measured tree's `plans/round-57-c2.sh`, so the mutant's nested control cases resolve
  their own REPO exactly as the real counter would. A fired leg requires the mutant's
  `--selftest` to exit non-zero printing a named `FINDING R61-C2-ST-<case>` line.
- G materialises a scratch tree whose `corpus/openbao-seal-trial.sh` is a valid-sha256
  stub that prints nothing and requires the unmutated counter to read `guard=0` rc 1 on
  it.
- Guard: (a) unmutated `--selftest` exits 0 printing `C2_SELFTEST: PASS (cases=N)` with
  N ≥ 17; (b) the measured counter on the real trial reads `value=5 … shims=5
  vectors=ok/5` (rc 0); (c) a constant-verdict counter is refused by the counter's own
  stub control — implemented as the M-A/M-B stub replacements themselves: a selftest that
  prints PASS without executing the aggregation keeps printing PASS under both constant
  replacements, the legs cannot fire, `refused=0`, guard=0. Guard = (a)∧(b)∧(c).
- SETUP (exit 2, line `C2_HARDENED: SETUP <reason>`): no git/awk/sha256sum, bad revision,
  unreadable `--tree`, missing `plans/round-61-c2.sh`, missing or unpinned `bao` (same
  resolution the measured counter uses; pin read from the measured tree's
  `plans/round-57-c2.sh`), `bao` in /usr/bin or /bin, unusable scratch. The heavy
  real-trial leg runs last. Nothing is written inside the measured tree; umask 077;
  randomized run names; TMPDIR in scratch; no hardcoded /tmp.
- Output: exactly one line
  `C2_HARDENED: killed=K population=3 guard=G (ma=F mb=F g=F selftest=F real=F)`.
- Own `--selftest`: fixture-driven, no bao, no network, 16 cases over the real code paths
  (`apply_mut` ok/between/missing/dup, `selftest_n` extraction + N ≥ 17 gate + multi-line
  refusal, `verdict_field` value/shims/vectors/guard and guard=0 and missing-line
  refusal, named-FINDING detection, `guard_calc` conjuncts, `exit_code` mapping,
  `verdict_line` exact format). Prints `C2R62_SELFTEST: PASS (cases=16)`.

## Measured verdicts (exact retained evidence)

Receipts — `.ufo/waves/round-62/build/R62ExecC2Counter/`:

| receipt | command (line 1 of file) | measured result |
|---|---|---|
| `base-run.txt` | `bash plans/round-62-c2.sh 60b5b7b60b76629633110a5b4adac883193c8b2a` | `C2_HARDENED: killed=0 population=3 guard=0 (ma=0 mb=0 g=0 selftest=0 real=1)` rc **1** (wall 101 s) |
| `candidate-run.txt` | `bash plans/round-62-c2.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin` | `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` rc **0** (wall 105 s) |
| `real-trial.txt` | `bash plans/round-61-c2.sh --tree <lane>` (hardened counter, full battery) | `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB trial=a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535 cases=63)` rc 0 (wall 99 s) |
| `selftest.txt` | both `--selftest` invocations | `C2_SELFTEST: PASS (cases=21)` rc 0; `C2R62_SELFTEST: PASS (cases=16)` rc 0 |
| `leg-ma.txt` | DECIDE block → `  echo 5`, mutated counter `--selftest` | `C2_SELFTEST: FAIL (cases=21 failed=6)` with named `FINDING R61-C2-ST-decide-{pass,shims,none,selftest,ops,t2w}` rc 1 |
| `leg-mb.txt` | SHIMS block → `  shims_ok=5`, mutated counter `--selftest` | `C2_SELFTEST: FAIL (cases=21 failed=3)` with named `FINDING R61-C2-ST-shims-{ok,bad,summary}` rc 1 |
| `leg-g.txt` | stub trial tree (sha256 `2817f7ae…b264`), unmutated counter `--tree` | `C2_SEAL_TRIAL: value=0 … guard=0 …` rc 1 (BASE counter read guard=1 here) |
| `sha256sums.txt` | `sha256sum` + `wc -c` over both files | values above |

Acceptance cross-check: both files exist; BASE prints `killed=0 population=3` guard=0
rc 1; candidate prints `killed=3 population=3 guard=1` rc 0; the real trial reads
`value=5 … shims=5 vectors=ok/5`; the stub-trial tree reads `guard=0`; every receipt
carries its command and output; a K3-style secret-shape scan over all receipts reads no
hits (receipt census lines carry pure-hex file digests only — no share, token, OTP or
nonce values anywhere).

## Notes for the L1 and sibling seats

- Coordination: `R62ScribeRecords` received the exact selftest invocations, PASS lines,
  verdict spellings and sha256s for both SKILL.md registry rows (D2 work item);
  `R62MutC2` received the marker/signature/aggregation/guard shapes and both sha256s.
- My counter's own selftest caught one real bug before any receipt was taken:
  `selftest_n` originally extracted digits with `grep -oE '[0-9]+'`, which matched the
  `2` in the `C2_SELFTEST` prefix; fixed to extract through `cases=`. Available as a
  lesson candidate (instrument parse class, captured by the instrument's own red witness).
- Observation (not mine to fix): the working tree carries an L1-authored modification to
  the frozen `plans/round-62.md` (a §C1 B6 fixture defect note; the note itself states the
  predicate, target, POP and fixtures are unchanged). HEAD is `8e5463c7…`; the §C2
  predicate my counter implements is identical in both versions.
- Real-trial discipline: throwaway inmem servers bound to 127.0.0.1 under
  `setpriv --pdeathsig KILL`, free ports, scratch-only work dirs — all inside the
  committed trial `corpus/openbao-seal-trial.sh`; the counters only invoke it.
- Tooling authorization (operator 2026-10-19): nothing installed or upgraded — the
  pinned `~/.local/bin/bao` (sha256 `9c5f3628…b788`, matches the round-57 pin) and stock
  coreutils were sufficient. No pacman transaction, no host mutation, no sysctls.

## Risks / ceilings (unchanged from the plan, plus one seat-local)

- Two mutation classes and one stub shape only — a complete mutation set is the plan's
  named ceiling; the counter still trusts the trial's printed observables (fabrication
  class, round-61 K2 ceiling, unchanged).
- Seat-local: guard leg (c) is implemented as "the stub replacements must be able to
  refuse the counter" (refused = ma ∧ mb) rather than as a separate third mutant copy;
  the constant-verdict counter is refused exactly when the stub mutations fire. If the
  L1 wants a literal third mutant (selftest verdict block → constant PASS) as its own
  leg, that is a plan-faithful extension, not a re-write.
- `killed` counts G via the measured counter's own `guard=` reading, so the G leg
  depends on the measured counter printing its census line — a counter that prints
  nothing at all cannot fire G (it also fails legs (a)/(b), so it cannot reach
  killed=3 guard=1).

## Bounds

Scratch `/fast/scratch/hyaku/kagi-r62/R62ExecC2Counter/` deleted before yield. No builds,
linters or repo test suites were run — the executed commands above are the seat's own
instrument runs, which are the deliverable receipts, not integration gates.

SEAT-STATUS: complete
