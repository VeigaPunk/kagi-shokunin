# R61ExecCounterC2 — build receipts (round 61, C2 counter)

Seat: executor, C2 counter. Instrument: `plans/round-61-c2.sh` (sole owned lane
file; everything below is its evidence trail). Claim BASE
`c940f51689d702f1786989d56ad4663833c1452e`; frozen predicate `plans/round-61.md`
§C2 (commit `8595018164f7421864254c6c5ca762b8f201e8be`).

Environment: OpenBao 2.7.2 at `/home/vgpnk/.local/bin/bao`, sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`, byte-equal to
`PIN_BAO` read from `plans/round-57-c2.sh` (verified by the counter itself and by
manual `sha256sum` before any run). No pacman transactions, no installs, no host
mutations; all fixtures under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecCounterC2/`.

## Receipt index (`build/R61ExecCounterC2/`)

| receipt | line | evidence |
|---|---|---|
| `selftest.txt` | `C2_SELFTEST: PASS (cases=11)` rc 0 | the counter's own fixture-driven self-invocation mode (round-60 routed defect D2 class closed for this gate): base const, `--tree` arg-parse both failure shapes, absent reading, vec/tlines/summary parsing, NONE/DUP detection, frozen shim-vector table, secret-scan fires on `hvs.` token + 45-char fabricated share literal, secret-scan clean on redacted shapes + 64-hex pin + 60-char pure dash and pure underscore separator runs, and the red witness (a flipped T1 fixture is detected against the frozen table). |
| `base-absent.txt` | `C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (absent)` rc 1 | the frozen acceptance at BASE: `bash plans/round-61-c2.sh c940f51`. Identical bytes for the no-arg default (`c940f51` baked as BASE) — run and shown in-session. |
| `tree-absent-pretrial.txt` | same absent line rc 1 | current working tree before the trial landed (the "record the absent leg and re-run when it appears" leg). |
| `stubctl-vacuous.txt` | `value=0 … none=1 ops=0 stubctl=1 secret=1 …` rc 1 | vacuity control (L1-routed critic finding A): a fixture trial that fakes T1..T5 HOLDS, both summary shapes, all five shim vectors and `SEAL_SELFTEST: PASS (cases=8)` without exec-ing bao reads `ops=0` (empty argv logs) and cannot score; the counter's built-in stub leg reproduced the same reading recursively (`stubctl=1`). |
| `stub-secret-fire.txt` | `value=0 … secret=0 …` rc 1 | kill rule K3 fires: a trial line carrying a 45-char fabricated share-shaped literal forces `secret=0` and value=0. |
| `stub-badshim.txt` | `value=0 … shims=4 vectors=4/5 … sh1=HBHHH` rc 1 | kill rule K4: a fixture whose SH1 flips the wrong test is detected by the vector read. |
| `landed-run-defect-1.txt` | `value=0 … all-NONE … trial=75e5ba0d…` rc 1 | first landing of `corpus/openbao-seal-trial.sh` (1008 lines, 17:00) was a broken mid-write snapshot: a plain `--work` run died rc 1 with zero stdout and stderr `line 837: run_case: command not found` / `line 838: CASE_RC: unbound variable` (`run_case` defined at line 810 inside the indented selftest block, executed outside its definition context in the real-run path). Reported to R61ExecTrial with the repro; fail-closed reading preserved here. |
| `landed-run-defect-2.txt` | `value=0 … real=0 ops=0 t2w absent … trial=e9956bd6…` rc 1 | second landing (1069 lines, 17:06) fixed the selftest leak: T1/T2/T3/T5 HOLDS, selftest 63 cases, none/stubctl/secret all pass, but T4 reads `ERROR decode-call` — the argv ops log shows `operator generate-root -decode=` with an EMPTY decode value and no generate-root update invocation in argv at all (the update chain produced no encoded token; OTP values in the raw log were redacted out of this receipt per QM72). Also routed to L1: `operator unseal` never appears in argv because the trial drives T2's unseal over the HTTP API — adjudicated 2026-11-07: API witness accepted, CLI ops list is server / operator init / operator seal / operator generate-root / operator rekey, and each real run's stdout must carry the T2 progress markers `progress=1/3`, `progress=2/3`, `sealed=false t=3 n=5` (census flag `t2w=`) instead; marker contract routed to R61ExecTrial (the trial did not print them yet). |
| `landed-run.txt` | `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB trial=a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535 cases=63)` rc 0 | final landing of `corpus/openbao-seal-trial.sh` (1123 lines): both real runs HOLDS 5/5 with the T2 progress markers, all five shim vectors exact, none leg SETUP rc 2, trial selftest 63 cases, all five CLI ops witnessed in both real argv logs, vacuous fixture refused, no secret-shaped material, exit 0. Both defect snapshots above are superseded fail-closed readings on earlier trial bytes. |

## Counter behaviour delivered

- Legs (frozen predicate, unchanged): two independent real runs (each must read
  `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0`, rc 0, exactly 5 T-lines,
  vector HHHHH), five shim legs (`KAGI_SEAL_SHIM=SH1..SH5`, each rc 1 with
  `BROKEN holds=4 broken=1` and exactly its own test flipped: BHHHH / HBHHH /
  HHBHH / HHHBH / HHHHB), the no-bao leg (SETUP rc 2, no HOLDS line anywhere),
  the trial's `--selftest` on a bao-less PATH (exactly one
  `SEAL_SELFTEST: PASS (cases=N)`, N >= 8), and the K3 secret scan over the
  trial text plus every captured stream and receipt the trial wrote.
- Vacuity controls (L1-routed critic finding A): every bao-carrying leg runs the
  pinned binary through a logging exec shim first on PATH (argv appended to a
  per-leg `*.ops` log); each real run's log must carry `server`,
  `operator init`, `operator seal`, `operator generate-root`,
  `operator rekey` or value=0 (census `ops=`). L1 adjudication 2026-11-07:
  `operator unseal` is not required in argv — the trial drives T2's unseal over
  the HTTP API of the real pinned server — so each real run's stdout must
  instead carry the T2 progress markers `progress=1/3` (>=1, the duplicate-share
  observation may repeat it), `progress=2/3` (>=1) and the final `sealed=false`
  with `t=3` and `n=5` (census `t2w=`). A recursive stub leg materialises
  a vacuous fixture inside the counter's own scratch and requires value=0 on it
  (census `stubctl=`; guard `R61_C2_NOSTUB=1` prevents unbounded recursion).
- K3 scan fix (L1-routed critic finding B): the 43+-char base64url share shape
  now excludes pure dash/underscore runs (`(?![-_]{43})`) so comment separators
  cannot false-positive; pure-hex 43+-char runs (sha256 pins) remain excluded;
  redacted receipt shapes pass; captured logs stay scanned. The counter's
  `*.ops` logs are instrumentation outside the scan: the generate-root protocol
  legitimately carries `-nonce`/`-decode` argv values.
- Guard: 1 iff every frozen leg ran (captured rc per mode) and the trial file's
  sha256 is recorded (census `trial=<hex>`). Exit 0 iff guard=1 and value=5;
  1 otherwise; 2 SETUP. Every leg runs under `env -i` with per-leg HOME/PATH/
  TMPDIR and `--work` inside the counter scratch; scratch removed on exit;
  nothing is ever written inside the measured tree.

## Coordination

- R61ExecTrial confirmed byte-stable output shapes (`OPENBAO_SEAL_TRIAL` summary,
  `TRIAL T<n> …` lines, `SEAL_SELFTEST: PASS (cases=N)`) and the trial-side
  deletion guarantee (one per-run dir under `--work`, `rm -rf` on every exit
  path, values never printed), which my K3 scan depends on at census time.
- Pending: final `landed-run.txt` value=5 reading on the corrected trial.
