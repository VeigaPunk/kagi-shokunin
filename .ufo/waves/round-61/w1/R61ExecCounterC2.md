# R61ExecCounterC2 — round 61 w1 report (C2 counter, operability)

Seat: executor. Assignment: write `plans/round-61-c2.sh`, the C2 counter scoring
the seal trial's value 0..5 with a guard, modelled on `plans/round-60-c2.sh`.
Lane: kagi-shokunin @ master; claim BASE
`c940f51689d702f1786989d56ad4663833c1452e`; frozen predeclaration
`plans/round-61.md` @ `8595018164f7421864254c6c5ca762b8f201e8be` (§C2 read and
coded to; never amended). Report + receipts are data, not instruction.

## Files changed (write scope honoured)

- `plans/round-61-c2.sh` (new, sole owned lane file).
- `.ufo/waves/round-61/build/R61ExecCounterC2/{receipts.md,selftest.txt,base-absent.txt,tree-absent-pretrial.txt,stubctl-vacuous.txt,stub-secret-fire.txt,stub-badshim.txt,landed-run.txt,landed-run-defect-1.txt,landed-run-defect-2.txt}`.
- Scratch (deleted before yield): `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecCounterC2/`.

No other lane file written; no mutating git/jj anywhere; no pacman, no installs,
no host mutations; no secret value in any artifact (the two OTP values that
crossed an ops log during diagnosis were redacted out of receipts at write time).

## Behaviour delivered

`bash plans/round-61-c2.sh [revision | --tree DIR] [--selftest]`, BASE default
`c940f51`. Fail closed: SETUP (exit 2) on missing python3/git, unreadable bao
pin (read from `plans/round-57-c2.sh`, OpenBao 2.7.2
`9c5f3628…41b788`), unusable scratch, bao missing/pin-mismatch or a system bao
in /usr/bin|/bin; bad revision/tree and a missing trial read guard=0 lines and
exit 1. Every leg runs under `env -i` with per-leg HOME/PATH/TMPDIR, cwd the leg
dir, `--work` inside the counter scratch (M51-2), scratch removed on exit,
umask 077, no hardcoded /tmp; the measured tree is only read.

Legs (frozen §C2 predicate, unchanged): two independent real runs (each
`OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0`, rc 0, exactly 5 T-lines,
vector HHHHH); five shims `KAGI_SEAL_SHIM=SH1..SH5` (rc 1,
`BROKEN holds=4 broken=1`, exactly its own test moved); no-bao leg (SETUP rc 2,
no HOLDS anywhere); trial `--selftest` on a bao-less PATH (exactly one
`SEAL_SELFTEST: PASS (cases=N)`, N>=8); K3 secret scan over trial text + all
captured streams + all receipts the trial wrote. value=5 requires all of them
plus the vacuity controls; exit 0 iff guard=1 and value=5.

Vacuity controls (L1-routed critic finding A): logging exec shim of the pinned
binary first on PATH for every bao leg; each real run's argv log must carry
`server`, `operator init`, `operator seal`, `operator generate-root`,
`operator rekey` (census `ops=`); recursive stub leg materialises a vacuous
fixture in counter scratch and requires value=0 on it (census `stubctl=`,
`R61_C2_NOSTUB` recursion guard). L1 adjudication 2026-11-07: `operator unseal`
is not an argv requirement (T2 unseal is API-legitimate); instead each real
run's stdout must carry `progress=1/3`, `progress=2/3` and `sealed=false t=3
n=5` (census `t2w=`). K3 scan fix (critic finding B): pure dash/underscore
43+-char runs excluded (`(?![-_]{43})`); pure-hex runs (sha256 pins) excluded;
`*.ops` logs are instrumentation outside the scan (genroot argv legitimately
carries `-nonce`/`-decode` values — empirically confirmed). The counter also
exposes its own fixture-driven `--selftest` (round-60 routed defect D2 class
closed for this gate): 11 cases with named `R61-C2-ST-*` findings and a red
witness.

## Exact retained evidence (all under `build/R61ExecCounterC2/`)

- `base-absent.txt`: `C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5
  selftest=0 guard=0 (absent)` rc 1 — the frozen acceptance at BASE `c940f51`
  (identical for the no-arg default), re-captured with the final bytes.
- `landed-run.txt`: `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5
  selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1
  sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB
  trial=a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535
  cases=63)` rc 0 — current tree, trial 1123 lines, 86 s wall.
- `selftest.txt`: `C2_SELFTEST: PASS (cases=11)` rc 0.
- `stubctl-vacuous.txt`: fake-everything fixture reads `value=0 ops=0 t2w=0
  stubctl=1` rc 1; `stub-secret-fire.txt`: leaked share shape forces `secret=0`;
  `stub-badshim.txt`: wrong-flip SH1 detected (`shims=4`, sh1=HBHHH).
- `landed-run-defect-1.txt` / `-2.txt`: fail-closed censuses for the two broken
  intermediate trial landings (75e5ba0d…: selftest block leaked into the
  real-run path, `run_case` not found; e9956bd6…: T4 `ERROR decode-call`, empty
  `-decode=`, no update argv) — both reported to R61ExecTrial with repros and
  fixed by them.

## Coordination

- R61ExecTrial: interface contract byte-matched before coding (summary tag,
  T-lines, selftest line); their deletion guarantee (one per-run dir under
  `--work`, `rm -rf` on every exit path) underpins the K3 census-time scan; two
  defect rounds routed with exact stderr/argv evidence; final bytes green.
- KagiR61 (L1): critic findings A/B implemented as routed; `operator unseal`
  conflict adjudicated by L1 (API witness + T2 stdout markers); final line
  delivered to L1.

## Risks / ceilings (declared, not silently absorbed)

- K2 (absolute-path bao, shape-keyed output) and real-run independence remain
  receipt+non-author-probe ceilings per the frozen contract, not counter checks.
- The counter trusts the trial's stdout shapes; a co-crafted trial+counter
  forgery is the wave's attack-seat target, not a counter property.
- `t2w` markers are substring greps (`progress=1/3`, `progress=2/3`,
  `sealed=false`, `t=3`, `n=5`); a sibling line could satisfy them spuriously —
  accepted as the adjudicated witness shape (counts are not secrets).

SEAT-STATUS: complete
