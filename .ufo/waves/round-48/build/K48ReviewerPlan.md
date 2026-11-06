# K48ReviewerPlan — attack on the frozen round-48 plan and counters (52991e5)

Scope: same-sentence check, controls re-run, fail-open paths. No counter, control, predicate, target or kill rule was edited; findings are routed to the L1. Scratch: `/fast/scratch/hyaku/kagi-r48/K48ReviewerPlan/` (fixture clone `c2repo`, fixture trees `c1f/`). Copies of receipts and fixtures: `build/K48ReviewerPlan/` (see `fixtures/REPRO.md`).

Lane HEAD = `52991e5` (A1). `plans/` has no uncommitted change; the frozen counters are the committed ones.

## 1. Same-sentence check (plan vs counter header comments)

Method: extract the predicate sentence (`C1_SOPS_AGE_TRIAL: value = … target 5.` and `C2_CAPABILITY_READINGS: value = … target 0 (BASE 3).`) from `plans/round-48.md` and from each counter header, stripping the leading `#` comment markers and collapsing whitespace.

| Predicate | Plan vs header | Result |
|---|---|---|
| C1 `C1_SOPS_AGE_TRIAL` | identical after comment strip | IDENTICAL |
| C2 `C2_CAPABILITY_READINGS` | identical after comment strip | IDENTICAL |

Raw text differs only where the counters wrap the sentence across lines with `#` (the wrap point is the only difference). Reading drift, not sentence drift:

- The C2 header MATCH clause says "K04 (stated `detected=0`, a **fragment** of the selftest line) … contains the stated text as a **space-delimited token**". The plan says "a **token** of the laneguard selftest line". The code implements the token rule. Wording only.
- The C2 header and the plan both say "empty/timeout/clone failure = SETUP". The code does not implement the timeout clause (K48RP-01). This is code-versus-sentence drift.

## 2. Controls re-run

Command: `HYAKU_SCRATCH=<seat>/hs bash plans/round-48-controls.sh 76da518fcc3029e738648bd6fd4ba5571df01c1c > <seat>/controls-rerun.txt; echo rc=$?` (real HOME, not overridden).

Receipt: `build/K48ReviewerPlan/receipts/controls-rerun.txt`. Last lines:
```
CONTROLS: ALL-MATCH (match=16 mismatch=0)
rc=0
```
Comparison: `diff` of the 16 `CONTROL` lines against `.ufo/waves/round-48/controls/controls-prefreeze.txt` → identical (17 lines including the summary).

## 3. Findings (numbered K48RP-01…)

"Changes measured value at a plausible candidate?" means: a candidate that keeps the frozen kill rules and does not touch `corpus/*.sh`.

### K48RP-01 — C2 timeout clause is not implemented (sentence/code drift) — medium
- Predicate: "empty/timeout/clone failure = SETUP" (plan §C2 Executed reading; counter header).
- Code: `ex=$(… timeout 300 bash -c "$ecmd" 2>/dev/null | awk 'NF{l=$0} END{print l}')`. `timeout` kills only the command; the reading printed before the kill is accepted. The exit status is never checked.
- Repro (small): `timeout 2 bash -c 'echo "ANCHOR_PINS: CLEAN (pins=4)"; sleep 6' 2>/dev/null | awk 'NF{l=$0} END{print l}'` → `ANCHOR_PINS: CLEAN (pins=4)` (reading accepted, no SETUP).
- Full fixture: commit `cd289a5` (`fixtures/c2-anchor-hang.sh`: K05 prints its reading, then `sleep 320`). Observed: the counter did not return within 600 s (outer kill, rc 124, no `C2_CAPABILITY_READINGS:` line). The predicate requires SETUP at 300 s. [INFERENCE] The overrun is the orphaned `sleep` keeping the pipe open; not isolated.
- Changes measured value at a plausible candidate: no (gates finish in about 5 s). It changes the failure mode for a hanging gate: the reading is accepted or the run stalls, but it is never SETUP. Route to the L1; the counter is not edited here.

### K48RP-02 — two `## Capabilities` headings are merged; LAST occurrence across both — high (integrity)
- Predicate: "the measured revision's `## Capabilities` section" (singular). Code: `awk '/^## /{ insec = ($0 == "## Capabilities"); next } insec'` concatenates every such heading.
- Repro: commit `6abc31c` (appends `## Capabilities` + reference readings at EOF; BASE table left stale). Observed `C2_CAPABILITY_READINGS: value=0 keys=10`. Commit `dcf8586` (same, built via python): `value=0 keys=10`. BASE: `value=3`.
- A candidate that appends a second heading moves 3 → 0 without touching the first table. Changes measured value at a gaming candidate: yes; an honest single-table candidate is unaffected. Recommend the L1 treat a count of `## Capabilities` headings other than 1 as SETUP (not edited here).

### K48RP-03 — K04 token rule accepts any space-delimited fragment of the selftest line — low
- Repro: `FK1` (K04 stated `` `--no-mutate` ⇒ `mutants=3` ``, commit `e92db7a`): K04 MATCH, value 0. `FK3` (stated `` `LANE_GUARD_SELFTEST:` ``, commit `6f7247e`): K04 MATCH, value 0. `FK2` (stated `detected=1`, commit `a8ea843`): K04 DIFF, value 1 — the rule works for a wrong count.
- Changes measured value at a plausible candidate: no, because a non-gaming candidate cannot change the laneguard line without editing `corpus/*.sh` (C2 kill rule). Route for calibration hygiene.

### K48RP-04 — exec-command exit status ignored — low to medium
- Repro: `FR` (commit `3d2351e`, `corpus/claims-declared.sh` ends `exit 1` after printing `CLAIMS_DECLARED: CLEAN (claims=21)`). Observed K07 MATCH while the gate exits 1; collateral K08 DIFF (`executed=[0]`) and K10 DIFF (`CLAIMS_DECLARED_SELFTEST: FAIL (passed=9/12)`); value 2.
- The predicate defines the executed reading only as the last nonempty stdout line, so this is spec-consistent. A failing gate can still pass calibration. Changes measured value at a plausible candidate: no, since gate edits are killed by the C2 rule.

### K48RP-05 — checkout dirtied by an exec command: NOTE only — low
- Repro: `FD` (commit `febde6f`, `corpus/anchor-pins.sh` appends to `SCORECARD.md` before printing). Observed: `value=0`, K05 MATCH, plus `NOTE checkout dirtied by an exec command`; rc 0. The value is unaffected; only the note appears.

### K48RP-06 — C1 has no deadline on trial runs (operability) — medium
- Code: `run()` in `plans/round-48-c1.sh` calls `env -i … bash "$TRIAL"` with no `timeout`; the C2 counter has one, C1 does not.
- Repro: `fixtures/c1-hang-trial.sh` (`sleep 400` then the reference trial). `timeout 60 bash plans/round-48-c1.sh --tree <tree>` → rc 124 (still running at 60 s; no SETUP, no value).
- Changes measured value at a plausible candidate: no value is produced at all; a hanging candidate trial stalls the wave instead of failing closed. Route to the L1.

### K48RP-07 — C1 entry check is text presence, not measurement — low (calibration of the claim)
- Code: `entry_line` requires a line starting `- T<n> ` and containing `sops 3.13.3` inside `## Measured (round 48`. It is not bound to any run.
- Repro: control K1-P (`controls/fixtures/ref-entry-measured.md`) contains placeholder text ("T1 updatekeys-add: reference fixture line, sops 3.13.3.") and the counter reads `value=5`. The 5 therefore certifies the trial's discrimination, not the entry's content. A candidate still needs a discriminating trial (K1-F1, K1-F3, K1-F6 confirm this), so the value is not raised by text alone. Changes measured value at a plausible candidate: no. The lesson must not describe the entry text as measured content.

### K48RP-08 — same-sentence drift items — low
- See §1: C2 header "fragment" vs plan "token"; C2 header claims timeout = SETUP (K48RP-01). Predicate sentences themselves are identical.

## 4. Verified holds (fail-closed paths checked with fixtures)

| Path | Fixture / command | Observed | Required | Holds |
|---|---|---|---|---|
| C1 duplicate `TRIAL T1 HOLDS` in real run | `fixtures/c1-dup-trial.sh`, `--tree` | `value=4 … T1:real=DUP,shim=BROKEN,ok=0` | T1 must not discriminate; value 4 | yes |
| C1 real run without final `SOPS_AGE_TRIAL:` line | `fixtures/c1-nofinal-trial.sh` | `C1_SOPS_AGE_TRIAL: SETUP reason=real-run-no-final-line(rc=0)`, rc 2 | SETUP exit 2 | yes |
| C1 silent producer (exit 0, no output) | control K1-F4 | `SETUP` | SETUP | yes |
| C2 empty producer (K09 silent on `--selftest`, commit `37bb8b5`) | `fixtures/c2-anchor-silent-selftest.sh` | `C2_CAPABILITY_READINGS: SETUP reason=empty-or-timeout-K09`, rc 2 | SETUP | yes |
| C2 clone failure (PATH `git` refuses `clone`) | shim `git clone` → exit 128 | `SETUP reason=clone`, rc 2 | SETUP | yes |
| C2 stated reading with trailing space in K02 (commit `d9d6973`) | python-inserted line `…located=8 rows=8 ` | `K02 DIFF`, `value=1` | DIFF (byte-exact) | yes (fail-closed) |
| C2 dirty-tree NOTE | FD | `NOTE checkout dirtied…`, value unchanged | value unaffected | yes |
| C2 K04 with a wrong count | FK2 | `K04 DIFF`, `value=1` | DIFF | yes |

## 5. Discarded runs (recorded for honesty)

- First `FX_TIMEOUT` (commit `6f54e2d`): the appended `sleep 400` sat after `anchor-pins.sh`'s final `exit 0`, so it never ran (value 3 in 5 s). Replaced by `cd289a5`.
- First `mkline`-built fixtures (`FSP`, `FK*`, `FR`, `FD`): `unicode_escape` mangled the `⇒` glyph, and FK inserted outside the section. Those values were invalid; all were rebuilt with `fixtures/payload/ins.py` and the rebuilt values are reported above.

## 6. Tooling

None installed or upgraded. Verified existing binaries only (`sops`, `age-keygen` run through the counters; sha256 pins checked by the counters).

## 7. Residual risk and verification gaps

- The timeout-after-output overrun (K48RP-01) is observed once (600 s outer kill) and attributed by inference.
- Shim detection by a trial remains the named ceiling; not attacked here.
- `K2-F2` assumes `## Capabilities` is not the last heading; the control's observed value 3 confirms it is not.
- No check of the kill rules' git-diff conditions (L1 territory).
