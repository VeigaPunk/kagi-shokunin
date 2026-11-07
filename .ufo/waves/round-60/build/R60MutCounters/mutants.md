# Round 60 — mutation report (seat R60MutCounters)

Mutation-tests the round's instruments: the C1 checker (`plans/round-60-c1-check.py`), the
C2 counter (`plans/round-60-c2.sh`) and the AppRole trial
(`corpus/openbao-approle-trial.sh`). No lane file was edited; every mutant is a byte copy
under scratch and the same bounded detector ran on the pristine and mutated bytes over the
same fixture tree.

**Verdicts.** *killed* = the instrument's own detector fires on the mutant (its
`--selftest`, its GUARD, or the shipped pre-freeze control fixture it is supposed to be
caught by); *survived* = the mutant reads green where the pristine instrument reads red,
or is behaviourally identical to the pristine bytes.

**Instrument bytes probed (sha256).**

| instrument | sha256 |
|---|---|
| `plans/round-60-c1-check.py` | `52d4fd5c6660e6a9235ae6cbf7e4e504c245b06cc6aa871fa83df721489fa658` (§A5+§A6 amended) |
| `plans/round-60-c1.sh` | `c11da5c60db536c97ef3e22c0f2d6ab0704e56b1508ce6e93a65847d0e39d599` |
| `plans/round-60-c2.sh` | `a6fc9825972a20e87a35cef89032365b3611bb909606bd7738e54d1a653501f2` |
| `corpus/openbao-approle-trial.sh` | `49ea928f28f42c7cce91459fe577a6d80023db3844229047718f483bfed0e54f` |
| `bao` v2.7.2 | `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (matches the round-57 pin) |

**Drift during the wave.** The checker moved `9eb98716` → `268b27cb` → `52d4fd5c` and the
trial `bd2d6647` → `a228e312` → `49ea928f` while the seats worked (§A5/§A6 landed between
readings). All rows below are on the final bytes; the one finding taken on the earlier
bytes (C1-X1) is marked as such. The C2 counter was byte-stable throughout.

**Fixtures.** C1 trees are synthetic copies of the claim BASE with the seven repairs
applied, then one substance break each (`brk-i1h`, `brk-i1a`, `brk-i1i`, `brk-i2` …
`brk-i7`, `nosel`), plus the all-resolved tree `fixed`. I7 is satisfied in these trees by a
fast fixture stand-in for the transit trial (labelled, not lane evidence) so a checker run
is seconds, not a bao run. C2 fixtures are wrapper trials under scratch that delegate to
the real trial; the *clean reading* column is the pristine counter on the same fixture.

## Mutant index (id, file, verdict)

| id | file | verdict |
|---|---|---|
| C1-M1-item-always-1 | `plans/round-60-c1-check.py` | killed |
| C1-M2-any-nonempty-file | `plans/round-60-c1-check.py` | killed |
| C1-M3-population-skips-i6 | `plans/round-60-c1-check.py` | killed |
| C1-M4a-guard-no-challenge | `plans/round-60-c1-check.py` | killed |
| C1-M4b-stub-leg-not-run | `plans/round-60-c1-check.py` | survived (equivalent) |
| C1-M5s-failopen-selftest-count | `plans/round-60-c1-check.py` | survived |
| C1-M6-i6-rev-not-compared | `plans/round-60-c1-check.py` | killed |
| C2-M1-any-shim-vector | `plans/round-60-c2.sh` | killed |
| C2-M2-single-run-as-two | `plans/round-60-c2.sh` | survived |
| C2-M3-missing-selftest | `plans/round-60-c2.sh` | killed |
| C2-M4-summary-error1 | `plans/round-60-c2.sh` | survived |
| C2-M5-score-no-bao | `plans/round-60-c2.sh` | survived |
| C2-M6-accept-secret-shape | `plans/round-60-c2.sh` | survived |
| T-M1-shim-flips-two | `corpus/openbao-approle-trial.sh` | killed |
| T-M2-broken-maps-0 | `corpus/openbao-approle-trial.sh` | killed |
| T-M3-selftest-no-assertions | `corpus/openbao-approle-trial.sh` | survived |

## C1 — `plans/round-60-c1-check.py`

| id | edit | clean reading | mutated reading | verdict |
|---|---|---|---|---|
| C1-M1-item-always-1 | item1: `ok = (names_json and shape is not None and int(shape.group(1)) == r_count …)` → `ok = True` | `brk-i1h`: diag `value=1 i1=0`; full `value=FAIL guard=0` (the challenge flips the already-wrong last shape line, so the copy still reads 1 where 2 is expected) | diag `value=0 i1=1`; full `value=FAIL guard=0` | **killed** — `--selftest` FAIL 43/46, failed `evaluate-guard-good-tree,i1-later-restatement-in-block,challenge-plus1-fires-with-unresolved` |
| C1-M2-any-nonempty-file | item2: `return (HOLD if hit else FAIL)` → `return (HOLD if lesson else FAIL)` (any non-empty lesson resolves) | `brk-i2`: full `value=1 guard=1` rc 1 | full `value=0 guard=1` rc 0 (`i2=1`) | **killed** — `--selftest` FAIL 43/46, failed `i2-false-substance-32,i2-misplaced-correction-fails,i2-later-wrong-restatement` |
| C1-M3-population-skips-i6 | `ITEMS` drops `("i6", item6)`; `population = sum(…)` → `population = POP` | `brk-i6`: full `value=1 guard=1` rc 1 (`i6=0`) | full `value=0 guard=1` rc 0; line carries `population=7` with no `i6` token | **killed** — `--selftest` aborts: `KeyError: 'i6'` at `res_bad["i6"]`, rc 1, no PASS line (loud, but it crashes rather than naming a case) |
| C1-M4a-guard-no-challenge | `chal_ok, stub_fails, challenge_detail = run_guard(root, count)` → `True, True, "skipped (MUTANT)"` | `base-tree`: full `value=FAIL guard=0` rc 1 | full `value=7 guard=1` rc 1 — claims a validated guard it never ran | **killed** — `--selftest` FAIL 43/46, failed `evaluate-guard-good-tree,evaluate-all-unresolved-guard-fails-closed,challenge-plus1-fires-with-unresolved` |
| C1-M4b-stub-leg-not-run | `stub_fails = not (isinstance(sv, int) and sv == expect)` → `stub_fails = True` | `fixed`: full `value=0 guard=1` rc 0 | identical: `value=0 guard=1` rc 0 | **survived** — equivalent mutant; `--selftest` PASS 46. The stub leg is vacuous: the stub prints `value=0` and `expect=count+1 ≥ 1`, so `stub_fails` is always True and the leg cannot discriminate |
| C1-M5s-failopen-selftest-count | `derive_selftest_cases`: receipt missing → fall back to the first `<n> cases` on the round-59 lesson line naming `C1_CHECK_SELFTEST` | `nosel`: full `value=1 guard=1` rc 1 (`i2=0`, "receipt missing") | full `value=0 guard=1` rc 0 (`i2=1`) | **survived** — `--selftest` PASS 46; no case covers a missing selftest receipt |
| C1-M6-i6-rev-not-compared | item6: `ok = "c1-landed.txt" in ln and want in ln` → `ok = "c1-landed.txt" in ln` | `brk-i6`: full `value=1 guard=1` rc 1 (`i6=0`) | full `value=0 guard=1` rc 0 (`i6=1` on a wrong 40-hex) | **killed** — `--selftest` FAIL 45/46, failed `i6-wrong-hash-stated` |

Not constructible: *"a `git show` fallback that reads the working tree instead of the
revision"*. No item derives from a named revision — `grep -nE 'git (show|diff|cat-file|archive)'`
matches only the docstring and a fixture string, and `--repo` is accepted but unused. The
closest class (a self-referential, fail-open derivation) is C1-M5s above.

## C2 — `plans/round-60-c2.sh`

The counter has no self-test; its detector is the shipped pre-freeze control fixture that
covers the same conjunct (the battery's `C2-F*`), run against the mutant.

| id | edit | clean reading | mutated reading | verdict |
|---|---|---|---|---|
| C2-M1-any-shim-vector | `[ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ]` → `[ -n "$(vec "${OUT[sh$n]}")" ]` | `f6-sh1-flips-two`: `value=0 shims=4 vectors=4/5 sh1=BBHHH` | `value=5 shims=5 vectors=ok/5 sh1=BBHHH` | **killed** — shipped `C2-F6` expects `<5`, observes 5 → battery mismatch |
| C2-M2-single-run-as-two (two hunks, one behaviour) | (a) `real_ok` requires both runs → requires either run; (b) the summary loop `grep … \|\| real_ok=0` → `grep … && sum_ok=1`, `[ "$sum_ok" = 1 ] \|\| real_ok=0` | `f4-single-run`: `value=0 real=0` | `value=5 real=1` — one successful real run counts as two | **survived** — the battery-exact `C2-F4` fixture reads `0` on the mutant (same as clean), because its wrapper refuses the `none` and `ambient` legs too, so the `real2` conjunct is never isolated |
| C2-M3-missing-selftest | drop `&& [ "$selftest_ok" = 1 ]` from the value conjunct | `f3-no-selftest`: `value=0 selftest=0` | `value=5 selftest=0` | **killed** — shipped `C2-F3` expects `<5`, observes 5 → battery mismatch |
| C2-M4-summary-error1 | both summary greps `'^OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0'` → `'^OPENBAO_APPROLE_TRIAL: HOLDS'` | `error1-summary`: `value=0 real=0 real2=0 ambient=0` | `value=5` with the summary reading `… HOLDS holds=5 broken=0 error=1` | **survived** — no shipped control covers an `error=1` summary |
| C2-M5-score-no-bao | `none_ok=0; [ RC[none]=2 ] && … && none_ok=1` → `none_ok=1` | `fake-no-bao`: `value=0 none=0` (a shape-keyed trial that prints HOLDS with no bao) | `value=5 none=1` | **survived** — `C2-F2` tests the trial's no-bao leg, not the counter's `none` conjunct |
| C2-M6-accept-secret-shape | final `[ "$nosecret" = 1 ] && [ "$value" = 5 ] \|\| value=0` → `[ "$value" = 5 ] \|\| value=0` | `secret-shape`: `value=0 secret=0` (a deliberately fake `hvs.NOTAREALTOKEN…` line in the captured output) | `value=5 secret=0` | **survived** — no shipped control exercises the secret scan |

## Trial — `corpus/openbao-approle-trial.sh`

The trial's detector is its own `--selftest` (fixture-driven, no bao).

| id | edit | clean reading | mutated reading | verdict |
|---|---|---|---|---|
| T-M1-shim-flips-two | `SH1) … ctok … return 0; return 1` → also `[ "$2" = 2 ] && [ "$3" = ref2 ] && return 0` | `--selftest` PASS (45 cases) rc 0 | FAIL (45 cases, failed=1), `FINDING F-SHIM-MATRIX`, rc 1 | **killed** |
| T-M2-broken-maps-0 | `rc_for`: `elif [ "$2" -gt 0 ]; then echo 1` removed → BROKEN maps to 0 | PASS (45) rc 0 | FAIL (45, failed=1), `FINDING F-RCFOR-BROKEN`, rc 1 | **killed** |
| T-M3-selftest-no-assertions | `run_selftest` body replaced by `echo "APPROLE_SELFTEST: PASS (cases=42)"; return 0` | PASS (45) rc 0 | PASS (42) rc 0; the clean counter on a tree carrying this trial reads `value=5` rc 0 (`raw/c2-on-gutted-selftest-trial.txt` + `.provenance.md`) | **survived** — nothing asserts the selftest's own assertions; the counter only requires `PASS (cases=N)` with N ≥ 8 |

MUTANTS: total=16 killed=9 survived=7

## Survivors — routed defects with proposed kills

- **S1 (C1-M4b, equivalent).** The GUARD's printer-stub clause has no teeth: the stub
  prints `value=0` and the expected value is `count+1 ≥ 1`, so `stub_fails` is always True;
  a checker that never runs the stub leg is behaviourally identical. *Proposed kill:* make
  the stub print the expected value (or run it with `--expect` injected) and require it to
  fail; otherwise the clause is decoration. This is a calibration observation on the frozen
  GUARD, not a fix I may apply.
- **S2 (C1-M5s).** `derive_selftest_cases` may fall back to the lesson's own stated count
  when the receipt is missing, so a tree with no receipt still resolves I2 — a fail-open
  derivation of exactly the class the checker's docstring forbids. *Proposed kill:* keep the
  `LookupError` fail-closed and add a selftest case `i2-selftest-receipt-missing` (and a
  battery control C1-F9: remove the receipt → diagnostic 1).
- **S3 (C2-M2).** The "two independent real runs" conjunct is not isolated by `C2-F4`: the
  battery wrapper counts the `none` and `ambient` legs as runs, so the control can refuse the
  wrong invocations and still read `<5`. A trial that fails one of its two real runs scores 5
  under the mutant. *Proposed kill:* `C2-F4` must count only the two real runs (exclude the
  no-bao leg by `command -v bao` and the ambient leg by `BAO_ADDR`) and must assert both the
  per-run vector and the per-run summary.
- **S4 (C2-M4).** A summary line reading `HOLDS holds=5 broken=0 error=1` is accepted once
  the `error=` field is not compared. *Proposed kill:* add C2-F9 — a trial whose summary
  carries `error=1` must read 0.
- **S5 (C2-M5).** A trial that prints HOLDS with no `bao` on PATH is scored 5 when the
  counter's `none` conjunct is dropped; `C2-F2` only exercises the trial, not the counter.
  *Proposed kill:* add C2-F10 — the counter must read 0 on that trial.
- **S6 (C2-M6).** A secret-shaped string in the captured output is accepted when the scan
  result is not enforced. *Proposed kill:* add C2-F11 — a trial that prints an `hvs.`-shaped
  line must read 0.
- **S7 (T-M3).** A trial whose `--selftest` asserts nothing still prints PASS and the counter
  scores 5. *Proposed kill:* the counter should run the trial's `--selftest` on a copy
  carrying one defined mutation (the C1 checker's I7 leg-C pattern) and require a non-zero
  exit with a named finding; the trial cannot detect its own gutting.

## Instrument defect found without a mutation (routed; fixed by §A5 1)

- **C1-X1.** On the pre-§A5 checker (`9eb98716`), I1 evaluated the *first* `results=<R>
  dead=<D>` line of the last correction block, so a later wrong restatement inside the same
  block was ignored: an all-resolved tree plus an in-block `results=15 dead=1` line read
  `value=0 i1=1` where the plan's C1-F1 requires 1. This is the same class the reviewer
  reported; §A5 item 1 (last statement wins) fixes it, and the current bytes read
  `value=1 i1=0` on both `brk-i1a` (append at EOF) and `brk-i1i` (in-block) — verified.

## Calibration notes

- **Scratch race (discarded matrix).** A peer deleted
  `${HYAKU_SCRATCH}/kagi-r60/R60ExecCounterC2` at ~15:45–15:47 while my first C2 matrix was
  in flight; legs lost their scratch mid-run (symptom: empty vectors, 2–9 s runs, `pass=0`).
  That matrix was discarded and every C2 row above was re-run under an isolated
  `HYAKU_SCRATCH` (`…/R60MutCounters/hs`), where the counter's per-run scratch cannot be
  reached by a sibling's cleanup.
- **C2-M2 build.** The first build changed only the `real_ok` block; the untouched per-run
  summary loop reset `real_ok=0`, so the mutant was neutralised by a second check. The
  recorded mutant carries both hunks (one behaviour); the reading above is from that build.
- **Crash-as-kill.** C1-M3 is killed by an uncaught `KeyError` in the selftest rather than a
  named case; it fails loudly (rc 1, no PASS line) but the selftest would be more operable if
  the scorecard-absent case guarded `res_bad.get("i6")`.
