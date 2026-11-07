# Round 61 — mutation report (seat R61MutCounters)

Mutation-tests the round's instruments: the C1 checker (`plans/round-61-c1-check.py`), the C2
counter (`plans/round-61-c2.sh`), the seal trial (`corpus/openbao-seal-trial.sh`) and the
pre-freeze control battery (`plans/round-61-controls.sh`). No lane file was edited: every
mutant is a byte copy under scratch, placed at its real relative path inside a repo skeleton
(so `$0`/`__file__`-relative resolution still works) or inside a full tree copy for the
battery, and the same bounded detector ran on the pristine and the mutated bytes over the same
fixtures.

**Verdicts.**
- *killed* — a detector separates the two readings and the pristine reading is the contract-red
  one (the instrument's own `--selftest` goes PASS -> FAIL; a defect fixture reads
  `value<target`/`BROKEN`/`mismatch>0` on pristine and `value=target`/`HOLDS`/`mismatch=0` on
  the mutant; or an item token moves from 0 to 1).
- *survived* — no detector separates the readings (behaviourally identical, or the mutant only
  moves a reading no detector asserts).
- *inconclusive* — the pristine baseline is not the contract reading the detector needs
  (fixture defect, or the instrument was red at baseline). A baseline failure is never counted
  as a kill.

**Detectors.**
- `selftest` — the instrument's own `--selftest` (fixture-driven; no network).
- `token-*` / `item-count` — the C1 checker run on a fixture tree, printing only the token the
  mutant is supposed to move (`i1=..`, `guard=..`, the item-token count).
- `forge-*` — a copy of the synthetic fixed tree with exactly one item's substance broken while
  leaving satisfied-looking text (the plan's C1-F1..F7 class), read on the diagnostic leg
  (`--no-challenge --repo <lane>`).
- `defect-*` — a real run of the trial under a PATH whose `bao`/`curl` wrappers inject the
  defect the dropped check exists to catch; the detector prints only the designated
  `TRIAL T<n> ...` line.
- `fixture-*` — a tree whose trial carries one defect, read by the counter.
- `absent-instruments` — the battery run on a copy with the checker and trial removed, so its
  controls SKIP (a SKIP is contractually a mismatch).

**Instrument bytes probed (sha256).**

| instrument | sha256 probed | note |
|---|---|---|
| `plans/round-61-c1-check.py` | `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812` | final bytes (67905 B); the earlier 66108 B bytes carried the two I2 defects below |
| `plans/round-61-c2.sh` | `c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6` | final bytes; earlier probes on `c9f34d06…` (16920 B, no vacuity controls) and `def7b737…` |
| `corpus/openbao-seal-trial.sh` | `a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535` | final bytes (46845 B, 1123 lines) |
| `plans/round-61-controls.sh` | `4239f674107cbf6ad73dbafd2b60ea15a4bb7234cb3b0b71df194580d8ee683b` (probed) → `20fd5c6f…` (current) | the two mutated lines are unchanged in the current bytes |
| `bao` v2.7.2 | `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` | the round-57 pin |

**Fixtures.** All under `/fast/scratch/hyaku/kagi-r61/R61MutCounters/` (deleted after the
report): `trees/base` (BASE `c940f51` via `git archive`), `trees/fixed` (a synthetic tree built
by `bin/mkfixed.py` that satisfies the seven frozen item conditions with numbers derived from
the BASE tree and the lane's git history — a labelled fixture, not lane evidence),
`trees/forges/*` (one substance break each), `fixtures/c2/*` (counter fixtures),
`fixtures/defect/*` (defect-injecting `bao`/`curl` wrappers) and `trees/ctl` (a full lane copy
with the checker and trial removed, for the battery).

## Mutant index

| id | file | verdict |
|---|---|---|
| C1-M1-drop-i1-byte-check | `round-61-c1-check.py` | killed |
| C1-M2-invert-i1-verdict | `round-61-c1-check.py` | killed |
| C1-M3-skip-i6 | `round-61-c1-check.py` | killed |
| C1-M4-guard-always-1 | `round-61-c1-check.py` | killed |
| C1-M5-challenge-noop | `round-61-c1-check.py` | killed |
| C1-M6-accept-timestamp-out-of-range | `round-61-c1-check.py` | killed |
| C1-M7-accept-wrong-denominator | `round-61-c1-check.py` | killed |
| C1-M8-drop-i5-numstat | `round-61-c1-check.py` | killed |
| C1-M9-drop-i3-withdrawn | `round-61-c1-check.py` | killed |
| C2-M1-one-real-run | `round-61-c2.sh` | inconclusive (fixture defect on final bytes; see §C2) |
| C2-M2-drop-shim-vector | `round-61-c2.sh` | killed (on `c9f34d06…`; final-byte re-run cut by the budget) |
| C2-M3-accept-stub-bao | `round-61-c2.sh` | killed (final bytes) |
| C2-M4-ignore-secret-scan | `round-61-c2.sh` | killed (final bytes) |
| C2-M5-accept-selftest-cases-5 | `round-61-c2.sh` | killed (final bytes) |
| C2-M6-guard-always-1 | `round-61-c2.sh` | survived (equivalent) |
| T-M1-drop-duplicate-share-check | `openbao-seal-trial.sh` | killed |
| T-M2-drop-non-persistence-check | `openbao-seal-trial.sh` | killed |
| T-M3-drop-503-check | `openbao-seal-trial.sh` | killed |
| T-M4-accept-wrong-otp | `openbao-seal-trial.sh` | killed |
| T-M5-drop-inmem-rekey-leg | `openbao-seal-trial.sh` | killed |
| CTL-M1-skip-counts-as-match | `round-61-controls.sh` | killed |
| CTL-M2-hide-mismatch | `round-61-controls.sh` | killed |

## C1 — `plans/round-61-c1-check.py` (final bytes `d525ee28…`)

Detector trees: `trees/fixed` reads `value=0 population=7 i1..i7=1` on the final checker (the
all-resolved fixture); each forge reads `value=1` with exactly its designated item 0. The lane
tree reads `value=0 … guard=1` rc 0.

| id | mutation (unified diff in `raw/mutants/<id>/mutant.diff`) | detector fixture → token | pristine | mutant | verdict |
|---|---|---|---|---|---|
| C1-M1 | `item1`: drop `and int(m.group(2)) == b_bytes` (accept a wrong byte length) | forge `f1b-i1-bytes` (states `output=3825`) → `i1=` | `i1=0` | `i1=1` | killed |
| C1-M2 | `item1`: `return (HOLD if ok else FAIL)` → `(FAIL if ok else HOLD)` (invert a verdict) | `trees/fixed` → `i1=` | `i1=1` | `i1=0` | killed |
| C1-M3 | `ITEMS` drops `("i6", item6)`; `population = sum(...)` → `population = POP` (skip an item, still claim 7) | `trees/fixed` → item-token count | `7` | `6` | killed |
| C1-M4 | `guard = 1 if (population == POP and chal_ok is True and stub_fails is True) else 0` → `guard = 1` | BASE tree, challenge on → `guard=` | `guard=0` | `guard=1` | killed |
| C1-M5 | challenge delta no-op: `changed, err = mutate_i5_deletions(copy)` → `("noop", None)` and `expect = count + 1` → `expect = count` | BASE tree, challenge on → `guard=` | `guard=0` | `guard=1` | killed |
| C1-M6 | `item6`: `qualifying = {t for t in stamps if t in derived}` → `qualifying = stamps` (accept a timestamp not in range) | forge `f6-i6-timestamp` (invented `2026-11-07T23:59:59-03:00`) → `i6=` | `i6=0` | `i6=1` | killed |
| C1-M7 | `item7`: `frac_a = re.compile(rf"(?<![0-9]){a}/{n}(?![0-9])")` → `{a}/[0-9]+` (accept a wrong denominator) | forge `f7b-i7-denominator` (states `3/17`) → `i7=` | `i7=0` | `i7=1` | killed |
| C1-M8 | `item5`: `ok = (structural and m is not None and int(m.group(1)) == ins and int(m.group(2)) == dels)` → `ok = (structural and m is not None)` (accept wrong numstat) | forge `f5-i5-deletions` (states `deletions=2`) → `i5=` | `i5=0` | `i5=1` | killed |
| C1-M9 | `item3`: drop `and WITHDRAWN_RE.search(section) is not None` (an A7 that withdraws nothing) | forge `f3-i3-withdrawn` (says `retained`) → `i3=` | `i3=0` | `i3=1` | killed |

The checker's own `--selftest` on the final bytes: `C1_CHECK_SELFTEST: PASS (52 cases)` rc 0.

## C2 — `plans/round-61-c2.sh` (final bytes `c7d9e272…`)

The counter gained vacuity controls during the wave (ops witness over the `bao` argv log, a
T2-marker witness, and a stub-control leg). A text-only fixture trial is now zeroed by design
(`ops=0`), so the fixtures below are the real trial (or a copy of it) unless noted.

| id | mutation | detector fixture | pristine reading | mutant reading | verdict |
|---|---|---|---|---|---|
| C2-M1 | `real_ok` accepts one good run of the two (`for m in real real2; do … && real_ok=1; done`) | `fixtures/c2/second-broken` (2nd real invocation flips SH1) | `value=0 … real=0 real2=0 ops=1 t2w=1` | `value=0` (both runs BROKEN) | **inconclusive** — the fixture's marker file is consumed by the no-bao leg before the first real leg, so both real legs flip; the fixture needs a `command -v bao` guard (one line). Not a survivor. |
| C2-M2 | shim loop: drop `[ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ]` | `fixtures/c2/sh3-wrong-test` (SH3 flips T2, vector HBHHH) | `value=0 … shims=4 vectors=4/5` | `value=5 … shims=5 vectors=ok/5` | killed (on `c9f34d06…`; the final-byte re-run was cut by the budget) |
| C2-M3 | drop `[ "$(sha256sum < "$BAO_BIN" …)" = "$PIN_BAO" ] \|\| setup bao-pin-mismatch` | `fixtures/c2/stub-bao` + `R61_BAO=<wrapper script with a different sha256, same behaviour>` | `SETUP bao-pin-mismatch` rc 2 | `value=5 … guard=1` rc 0 | killed (final bytes) |
| C2-M4 | `[ "$nosecret" = 1 ] && [ "$value" = 5 ] \|\| value=0` → `[ "$value" = 5 ] \|\| value=0` | `fixtures/c2/secret` (trial text carries a fabricated `hvs.` shape) | `value=0 … secret=0` | `value=5` | killed (final bytes) |
| C2-M5 | `[ "$sn" -ge 8 ] && selftest_ok=1` → `[ "$sn" -ge 1 ]` | `fixtures/c2/selftest-5` (`SEAL_SELFTEST: PASS (cases=5)`) | `value=0 … selftest=0 cases=5` | `value=5 … selftest=1` | killed (final bytes) |
| C2-M6 | `[ "$legs_ran" = 1 ] && printf '%s' "$TRIAL_SHA" \| grep -qE '^[0-9a-f]{64}$' && guard=1` → `guard=1` | `--selftest` (no detector separates) | PASS 11 | PASS 11 | **survived (equivalent)** — `legs_ran` is always 1 and `TRIAL_SHA` is always 64 hex, so the guard cannot fail; see finding F1 |

The counter's own `--selftest` on the final bytes: `C2_SELFTEST: PASS (cases=11)` rc 0, and it
passes on **all five** scoring mutants (M1-M5) — it tests the helper functions (`vec`,
`verdict`, `EXPECT`, `scan_hits`), not the scoring conjuncts.

## Seal trial — `corpus/openbao-seal-trial.sh` (final bytes `a3bc8825…`)

Pristine baseline on the final bytes: `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0
bao=v2.7.2` rc 0, `SEAL_SELFTEST: PASS (cases=63)`. Each defect fixture makes the pristine
trial read `BROKEN` on exactly its designated test; the mutant reads `HOLDS`.

| id | mutation | defect fixture (what the healthy server is made to do) | pristine `TRIAL T<n>` | mutant | verdict |
|---|---|---|---|---|---|
| T-M1 | T2: `[ "$sx" = "true" ] && [ "$r2" = "1" ] && dup=1` → `dup=1` | `dup-counted`: a repeated share increments progress (`same-share-again=progress=2/3`) | `T2 BROKEN` | `T2 HOLDS` | killed |
| T-M2 | T1: `[ "$m" = "0" ] && nopersist=1` → `nopersist=1` | `persist`: the init payload (with the five shares) is written under the raft storage path | `T1 BROKEN … nopersist=0` | `T1 HOLDS … nopersist=1` | killed |
| T-M3 | T3: `[ "$code" = "503" ] && auth503=1` → `auth503=1` | `sealed-200`: an authenticated `/v1/sys/mounts` request returns 200 while sealed | `T3 BROKEN … auth503=0` | `T3 HOLDS … auth503=1` | killed |
| T-M4 | T4: wrong-OTP branch always taken (`if true; then wrong=1; elif false; then`) | `otp-any`: `-decode` with a wrong `-otp` yields the same token | `T4 BROKEN … wrong=0` | `T4 HOLDS … wrong=1` | killed |
| T-M5 | T5: `rekey_refused "$D/rk-inmem.err" && mem405=1` → `mem405=1` | `inmem-rekey-ok`: rekey succeeds on the inmem server | `T5 BROKEN … mem405=0` | `T5 HOLDS … mem405=1` | killed |

All five mutants **survive the trial's own 63-case `--selftest`** (PASS on every mutant): the
selftest exercises the stub harness, the shim matrix, the verdict/rc/summary helpers and one
injected `unseal-fault`, but no case injects a server that counts a duplicate share, persists
the shares, answers 200 while sealed, accepts a wrong OTP, or succeeds at rekey. The defect
fixtures above are the only detectors that kill them.

## Control battery — `plans/round-61-controls.sh`

Run on `trees/ctl` (a full lane copy with `plans/round-61-c1-check.py` and
`corpus/openbao-seal-trial.sh` removed, so the instrument-dependent controls SKIP): pristine
`CONTROLS: match=3 mismatch=15` rc 1.

| id | mutation | pristine | mutant | verdict |
|---|---|---|---|---|
| CTL-M1 | `report_skip() { K=$((K + 1)) … }` → `M=$((M + 1))` (a SKIP counted as a match) | `match=3 mismatch=15` | `match=18 mismatch=0` | killed |
| CTL-M2 | summary `printf 'CONTROLS: match=%d mismatch=%d\n' "$M" "$K"` → `mismatch=0` (hide mismatches) | `match=3 mismatch=15` | `match=3 mismatch=0` | killed |

## Findings

**F1 — the C2 guard cannot fail (survived mutant C2-M6).** `guard=1` iff `legs_ran = 1` (every
mode always runs, so this is always true) and `TRIAL_SHA` matches `^[0-9a-f]{64}$` (always true
for any file). The guard therefore certifies nothing; the mutant that replaces the whole
expression with `guard=1` is behaviourally identical. Line:
`[ "$legs_ran" = 1 ] && printf '%s' "$TRIAL_SHA" | grep -qE '^[0-9a-f]{64}$' && guard=1`.
A guard that can fail would need a leg that can be missing (e.g. a leg whose rc is unset) or a
trial-sha comparison against a recorded pin.

**F2 — the C2 `--selftest` does not cover the scoring conjuncts.** All five scoring mutants
(M1-M5) pass the 11-case selftest. The selftest tests `vec`, `verdict`, `EXPECT`, `tlines`,
`holds5`, `scan_hits` and the bad-tree/absent paths; no case exercises `real_ok`, the shim-loop
vector comparison, the bao pin, the `nosecret` conjunct or the `N >= 8` threshold. The fixture
detectors are the only kills for those five.

**F3 — the trial's `--selftest` does not cover the T-body assertions.** All five trial mutants
pass the 63-case selftest. The harness supports faults (`init-fault`, `unseal-fault`,
`genroot-fault`, `decode-fault`) but only `unseal-fault` is used (one ERROR case); there is no
case for a duplicate-counting server, persisted shares, a 200-while-sealed answer, an
OTP-ignoring decode, or a rekey that succeeds. Named missing cases: T1-nopersist, T2-dup,
T3-503, T4-wrong-otp, T5-inmem-405.

**F4 — two measured C1-checker I2 defects (fixed by the owner during the wave).** On the
66108-byte bytes: (a) `C2_PASS_RE` expected `C2_SELFTEST: PASS (N cases)` while the frozen line
and the landed script print `(cases=N)`, so I2 leg A could never pass; (b) `_scan_registry_table`
split on `|` without honouring `\|`, so SKILL.md row 855 (whose entry-command cell contains
`[revision \| --tree DIR]`) shifted the selftest column onto the verdict-map cell and I2 leg B
could never pass. Both reproduced with exact evidence and reported to R61ExecCounterC1; the
final bytes (`d525ee28…`) read `i2=1` and `--selftest PASS (52 cases)`.

**F5 — the trial's T4 HTTP endpoint was wrong (measured, fixed).** `POST /v1/sys/generate-root`
without a token returns 403 `permission denied`; `/v1/sys/generate-root/attempt` and
`/update` return 405 `unsupported operation` on this build even with `X-Vault-Token`. The
working shape is the CLI: `bao operator generate-root -nonce=<nonce> -format=json <share>` (or
the share on stdin `-`) for submissions, and `-decode=<enc> -otp=<otp>` for the decode, whose
output is JSON `{"token": "s.…"}` (26 chars). Reported to R61ExecTrial; the final bytes use it
and T4 HOLDS.

**F6 — the counter's ops witness and an HTTP unseal were incompatible (measured, resolved).**
With the trial unsealing over `curl`, `bash plans/round-61-c2.sh --tree <lane>` read `ops=0`
and value=0 even where T1/T2/T3/T5 held. The final trial uses `bao operator unseal -format=json
"$SHARE"`, so the ops log carries `operator unseal` and the witness passes.

**F7 — fixture-level caveat for C2-M1.** The `second-broken` fixture's marker is consumed by
the counter's no-bao leg before the first real leg, so both real runs flip and the mutant reads
0 too. The fixture needs a `command -v bao` guard before the marker. Recorded as inconclusive,
not as a survivor; the mutation itself (accept one of two runs) is not exercised by a valid
detector on the final bytes.

MUTANTS: total=22 killed=20 survived=1 inconclusive=1

SEAT-STATUS: complete
