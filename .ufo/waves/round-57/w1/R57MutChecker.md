# R57MutChecker — which conjunctions does the frozen round-57 C1 battery actually kill?

Seat: R57MutChecker (mutation tester, attack share). Lane kagi-shokunin, one live tree,
scratch `/fast/scratch/hyaku/kagi-r57/R57MutChecker/` (deleted before yield). No lane writes
outside this report and `R57MutChecker.d/`. Answering model as labelled by the harness:
`amr/deepseek-v4.1-flash`.

**Result.** Ten single-defect mutants of the frozen checker were each run against the frozen
11-control battery. **Killed: M1, M3, M4, M6, M10. Survived: M2, M5, M7, M8, M9.** Every
survivor was shown behaviourally live on a tree shape the battery never builds; the survivors
are coverage findings, not contract changes. In flight, the lane re-froze (epoch B) and then
carried an uncommitted census amendment (A3) that kills M8 alone; M2/M5/M7/M9 survive even A3.

## 1. Inputs, exact bytes

| item | revision / SHA256 |
|---|---|
| claim BASE (audited trees) | `1cda9e7ae4767b4133e283bfbc08266d4c86362d` |
| epoch-A freeze (read at seat start) | `7aa1f4726e1f6bcdc8411d1a8b21828d49785173` |
| epoch-B re-freeze (landed during the probe) | `03cbf656943b33bf93607f607bbbeb55d500b0f9` |
| landing commit observed at 11:35 | `d857f344c13a314971b29adc0380705fc2ffc401` |
| frozen C1 checker | `19d75337ce37259b08eaa8b960eedddac68bec70ed4eab3f55f9d621e142f72c` |
| frozen C1 counter `plans/round-57-c1.sh` (epochs A and B, identical) | `3104b06f5bfaef77745bd0e5726d4e3ac86c471ff61eef2cc298ad21fee90601` |
| epoch-A controls | `6796ae7040b4956d28b9c71772c24c9ba0d4298e21e86f9f13dbff38e693ce41` |
| epoch-A C2 counter | `3de6b4dec570594b7ff47971156b9eb9f932a50a2261ba568b51314e906439a9` |
| epoch-B controls | `09f334cbf727667a0212729942386d78441dbc5ea7f0c553d316bbb7c613e618` |
| epoch-B C2 counter | `140a8f2b204af9a0e45e1b596d1c09c4b12f84a70bd42abd18e888d82bbaea28` |
| A3 uncommitted C1 counter snapshot (11:31) | `6fcbdec75af1e7ddb9ba6110b4d77a50295994bcc2f9141fbc6ab36eb653ce14` |
| A3 uncommitted controls snapshot (11:35) | `ee96476a79025e9ecc1a37fa49ca92bb65a9e9f279314291276e55446ee0cbe0` |

The C1 checker bytes are identical in epochs A, B and the landing; only the C2 counter/controls
and the plan changed between A and B (epoch-B commit message: C2 adopts the TRIAL convention,
battery re-run). The A3 counter was uncommitted work-in-progress in the lane worktree at
11:31–11:35; it was snapshotted by hash and probed separately, never treated as frozen.

Tools (no installs; pacman paused, nothing installed): bash 5.3.20(1), Python 3.14.8,
git 2.56.0, `sha256sum` 0.8.0, Linux 7.2.11-arch1-1. No network, no secrets.

## 2. Method

1. Snapshotted the five frozen instruments from `git show HEAD:plans/...` (epoch A, then
   epoch B) into scratch; verified every hash against the values read at 11:04 (epoch A) and
   against the recorded snapshots (`frozen.sha256.expected` / `frozenB.sha256` in this
   receipt; `sha256sum -c` rc=0).
2. Generated `M0` (byte-identical copy) and ten one-edit mutants of
   `plans/round-57-c1-check.py`. Each edit anchor occurred exactly once; `mutant-diffs.txt`
   holds the full diff for each mutant (one hunk each; M0 diff empty).
3. For each mutant `M`, `mut/M/plans/round-57-c1.sh` is a byte copy of the frozen counter
   (its `REPO=$(dirname)/..` resolves to `mut/M`, so `CHECK` is the mutant) and
   `bin/controls-M.sh` is the frozen controls with exactly two path changes + one `mk_base`
   indirection (`controls-M0.diff`): `REPO` pinned to the instrument snapshot, `mk_base`
   takes trees from the real lane, `C1` pointed at the mutant runner. The C1/C2 expectations
   are untouched.
4. Ran the battery per mutant. `mk_base` extracts BASE `1cda9e7` fresh for every control, so
   each of the 11 controls is a real end-to-end counter run: 8 C1 controls (BASE, F1–F7) and
   3 C2 controls (BASE/STUB/MOCK). `K1-REF`/`K2-REF` print `PENDING` and are not counted.
5. Wrote the per-mutant predictions (values and kill verdict) to `EXPECTATIONS.md`
   SHA256 `27206a54d23c1fc194ef64a77307e87d16dbcdd00cd24a1ee9940e06d80312a4` **before**
   running any mutant battery; the epoch-B addendum `EXPECTATIONS-epochB.md`
   SHA256 `93506cc578c71b20c5855040d94e79c37d9da845b0b78414f479ad90e6e1a1d9` before the
   epoch-B runs. All 110 predicted cells agreed with the readings (10/10 verdicts correct);
   the one known miss is a supplementary liveness prediction, corrected in §5.

Mutants (all scratch-only; hashes from `mutant-manifest.tsv`):

| id | one-line defect (exact edit) | mutant SHA256 |
|---|---|---|
| M1 | `value = bad if guard else "FAIL"` → `value = 0 if guard else "FAIL"` | `1ef04bc3096de60c8a1bff513d2ed13d660ed34541929ad0ca071a5811eee278` |
| M2 | checker floor `population >= 8` → `>= 0` | `fde72c5445c5756eaa8b1becaea27f1183c5929df052972554595a118703e74d` |
| M3 | receipt-path authority `match_auth.get(L)` → `stated` | `3b28db3fb7884bbc6b9e9ea24159f062ca76867fabe2844a14d3b97163e16175` |
| M4 | epochs authority `epochs_auth` → `stated` | `2e148d9e75aa0e5ad61db04c9f471d02928e19c00247fdd12948cfd2795f12aa` |
| M5 | `clocks_auth = manifest_rows(root)` → `= 10` | `688a52b4348f7c890459397fdc2901303493fd3b83048afc5c97a143daab167a` |
| M6 | nearest-epoch pairing removed, `auth=None` | `21d9274fc3dce2b34a26fc06418b2e2c34461f90ee53e7f1a8a61dfc3cb4a34e` |
| M7 | missing-surface branch prints `value=0 population=16 ... guard=1`, rc 0 | `6c0787e141eb3f079399dc909557141405bd698e6b713594cb629d7e9d7e0728` |
| M8 | `N/N MATCH` pop statements not emitted (span still excluded) | `041aae18d1c4b41e4e62cbae324c6a387e1b766db1f64401c0ee503220d39629` |
| M9 | `selftest_cases()` returns constant 20 | `b86c792a3aee06bc788b94949b557bc9e44058676fc52fca2a8ed53d4048aec1` |
| M10 | `value = 0` unconditionally | `e0923a33319af1b2395ec39e4b94ea9d0f46446d9dbea00abecf03b4cbb44aad` |

M0 = `19d75337...` (identical to frozen). Supplementary probes built later:
`M8b` (whole pop block deleted), `S2s` (shell floor 8→0 alone), `M2S2` (both floors),
plus A3 runs of M2/M5/M7/M8/M9.

## 3. The 10×11 matrix (epoch-B frozen battery, measured)

Legend: cell = `C1_CURRENT: value=` / `C2_AUDIT_TRIAL: value=` reading; `!` = MISMATCH against
the battery's own frozen expectation. Frozen expectation row: `3 2 2 2 0 FAIL 6 3 | 0 0 0`.

| mutant | K1-BASE | K1-F1 | K1-F2 | K1-F3 | K1-F4 | K1-F5 | K1-F6 | K1-F7 | K2-BASE | K2-STUB | K2-MOCK | verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 0! | 0! | 0! | 0! | 0 | FAIL | 0! | 0! | 0 | 0 | 0 | KILLED |
| M2 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 0 | SURVIVED |
| M3 | 3 | 2 | 2 | 2 | 0 | FAIL | 4! | 3 | 0 | 0 | 0 | KILLED |
| M4 | 1! | 0! | 1! | 1! | 0 | FAIL | 4! | 1! | 0 | 0 | 0 | KILLED |
| M5 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 0 | SURVIVED |
| M6 | 8! | 7! | 7! | 7! | 5! | FAIL | 10! | 8! | 0 | 0 | 0 | KILLED |
| M7 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 0 | SURVIVED |
| M8 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 0 | SURVIVED |
| M9 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 0 | SURVIVED |
| M10 | 0! | 0! | 0! | 0! | 0 | FAIL | 0! | 0! | 0 | 0 | 0 | KILLED |

Observed populations (C1 controls; `-` for C2): M1–M7, M9, M10 = `16 16 16 16 16 1 16 16`;
M8 = `14 14 14 14 14 1 14 14`. M0 = the frozen row, 11/11 MATCH, populations `16 ... 1 ... 16`.

Epoch A gives the identical C1 table (the frozen C1 checker/counter did not change between
epochs); the only difference is K2-MOCK: expected/read `5` in epoch A (shape-keyed mock
accepted) versus `0` in epoch B (epoch-B C2 rejects the mock). Full logs:
`logs/battery-*.log` (A), `logs/batteryB-*.log` (B).

## 4. Killed / surviving

| mutant | killed by (controls whose reading changed) | reading vs expected | verdict |
|---|---|---|---|
| M1 (value ignores mismatches) | BASE, F1, F2, F3, F6, F7 | 0 vs 3 / 2 / 2 / 2 / 6 / 3 | KILLED |
| M3 (receipt authority ignored) | F6 only | 4 vs 6 | KILLED |
| M4 (epoch authority = stated) | BASE, F1, F2, F3, F6, F7 | 1/0/1/1/4/1 vs 3/2/2/2/6/3 | KILLED |
| M6 (nearest-epoch pairing removed) | BASE, F1, F2, F3, F4, F6, F7 | 8/7/7/7/5/10/8 vs 3/2/2/2/0/6/3 | KILLED |
| M10 (value always 0) | BASE, F1, F2, F3, F6, F7 | 0 vs 3/2/2/2/6/3 | KILLED |
| M2 (checker floor 8→0) | — | 11/11 MATCH | **SURVIVED** |
| M5 (clocks authority hardcoded 10) | — | 11/11 MATCH | **SURVIVED** |
| M7 (missing surface reads clean) | — | 11/11 MATCH | **SURVIVED** |
| M8 (`N/N MATCH` not pop) | — | 11/11 MATCH (population silently 16→14) | **SURVIVED** |
| M9 (selftest case authority = 20) | — | 11/11 MATCH | **SURVIVED** |

Every battery rc: 0 iff all 11 controls matched. Epoch B: M0/M2/M5/M7/M8/M9 rc=0;
M1/M3/M4/M6/M10 rc=1. Exact commands and rcs: `commands.txt`.

## 5. Survivor liveness (not inert copies)

The battery never builds these tree shapes, so the survivors were probed directly with the
pristine checker and the mutant on the same tree (`probes/probe-summary.txt`):

| probe tree | pristine checker | mutant | conclusion |
|---|---|---|---|
| F5-shaped tree (sections removed), population 1 | `value=FAIL population=1 ... guard=0` rc=1 | M2: `value=0 population=1 ... guard=1` rc=0 | M2 live; the shell re-derives FAIL from `P<8` |
| BASE with one `recheck-captures.tsv` data row removed | `value=7 population=16` rc=1 | M5: `value=3 population=16` rc=1 | M5 live (4 statements bound to the manifest: 2 pop + 2 clocks) |
| BASE with `LOG.md` deleted | `value=FAIL population=0` rc=1 | M7: `value=0 population=16 ... guard=1` rc=0 | M7 live (fail-open branch) |
| BASE with `10/10 MATCH` → `9/10 MATCH` | `value=4 population=16` rc=1 | M8: `value=3 population=14` rc=1 | M8 live; the fraction is uncounted, not mis-valued |
| BASE with `recheck-replay.py` replaced by a `PASS (19 cases)` stub | `value=5 population=16` rc=1 | M9: `value=3 population=16` rc=1 | M9 live (constant hides an authority change) |

Corrected prediction: for the M5 probe I predeclared pristine `6` vs mutant `3`; the measured
pristine value is `7` because four statements are bound to the manifest authority, not three.
The mutant side matched. The battery-side predictions had no misses.

Independent liveness signal: M9 never invokes the 20-case selftest eight times per battery, and
its epoch-B battery wall time is `29.6 s` against `56.5–62.5 s` for the other mutants (same
host, same 11 controls) — consistent with the skipped subprocess, though no control measures it.

## 6. What the frozen 11-control battery does not bind

Each finding names the mutant that survives because of it.

1. **The guard floor is duplicated and single mutants cannot kill either copy (M2).** The
   checker's `population >= 8` and the shell's `[ "$P" -ge 8 ]` enforce the same floor. M2's
   raw line at K1-F5 is `value=0 population=1 ... guard=1`; the frozen shell still prints
   `FAIL`. Probe `S2s` (shell floor alone, 8→0) also reads 11/11 MATCH; the double mutant
   `M2S2` is killed by exactly `K1-F5` (`got=0` vs `FAIL`). So the floor conjunct is only
   observable when both copies break together, a shape the battery's one-mutant convention
   never builds.
2. **M1 and M10 are indistinguishable on this battery.** Both read
   `0! 0! 0! 0! 0 FAIL 0! 0!`; the only difference is the un-guarded branch at K1-F5
   (M1 inner `value=FAIL`, M10 inner `value=0`), and the shell overwrites both with `FAIL`.
   No control asserts the checker's value when `guard=0`.
3. **No control perturbs `corpus/recheck-captures.tsv` (M5).** All 11 controls leave the
   clocks/pop authority at 10 rows. The hard-coded `10` is invisible; the manifest-removal
   probe changes the reading from 7 to 3.
4. **No control deletes a surface file (M7).** `K1-F5` deletes sections, not files: the
   checker's missing-file branch (`population=0`, `value=FAIL`) never runs. The fail-open
   branch is live (deleted `LOG.md` → `value=0`) but unexercised.
5. **The population size is printed but never asserted (M8).** Dropping the two `N/N MATCH`
   statements moves `population` 16→14 and is visible in every C1 line, yet all controls
   compare only `value`; the floor still passes at 14. The minimal defect survives. The
   *whole-block* deletion `M8b` reads `4! 3! 3! 3! 1! FAIL 7! 4!` and is KILLED, but only
   because `10 MATCH` then falls through into `MATCH_RE` and becomes UNBOUND — the kill is a
   regex-overlap accident, not a control that checks the population.
6. **No control perturbs the selftest case authority (M9).** A constant 20 passes every
   control; a `PASS (19 cases)` stub moves the pristine reading 3→5.
7. **The gate/census conjunct is never exercised by the counted 11 (all mutants).** Every
   counted control runs a BASE tree, and BASE carries no `corpus/current-claims.py`, so every
   reading prints `gate=0`; `K1-REF`/`K2-REF` are `PENDING` and uncounted in both epochs. The
   shell's gate-agreement logic cannot be killed by the battery as frozen. (Under the A3
   amendment the gate is pinned and challenged by the new `K1-F9`; still pending until frozen.)
8. **M3 depends on a single control.** Only `K1-F6` binds the receipt authority (F6 edits the
   epoch-F receipt 23→19). The two receipt-path statements fall silent; only the
   nearest-epoch statement at `LOG:3` still compares, giving `4` vs `6`. A battery without F6
   would not see M3 at all.
9. Boundary (not probed): no control edits the class regexes (`CASES_RE`, `MATCH_RE`,
   `EPOCHS_RE`, `CLOCKS_RE`) or the surface section boundaries; a narrowing there would
   silently shrink POP. `[INFERENCE]` from reading the controls — no mutant was built for it.

## 7. Lane drift observed during the probe (calibration context)

- 11:04–11:20: lane worktree matched epoch-A freeze `7aa1f47`; snapshot hashes verified.
- 11:16–11:19: siblings edited `plans/round-57-c2.sh`, `plans/round-57-controls.sh`,
  `plans/round-57.md`; epoch B committed as `03cbf65`. The C1 checker/counter were unchanged
  (`19d75337`/`3104b06f`). One early battery run against the drifting worktree (before I pinned
  the instruments) read `CONTROLS: match=10 mismatch=1` with `K2-MOCK got=0 expect=5`; the
  log `logs/worktree-drift-battery-M0-1119.summary.txt` shows the worktree C2 was already at
  `140a8f2b`. This is the epoch-B semantics, not a defect in the frozen battery.
- 11:31–11:35: an **uncommitted** A3 amendment appeared in the worktree
  (`plans/round-57-c1.sh` `6fcbdec7`, `plans/round-57-controls.sh` `ee96476a`; the counter
  comment names reviewer K1-F8). It replaces the floor with an exact
  frozen census (`P=16 cases=3 match=7 epochs=2 clocks=2 pop=2`), pins the gate bytes
  (`GATE_SHA256_PIN=e36472b3...`), adds a forged-tree challenge, and adds controls K1-F8
  (statements deleted) and K1-F9 (printer gate) — 13 counted controls.
  Measured on the exact snapshots: A3 baseline `13/13 MATCH`; **A3+M8 is killed** (7 C1
  mismatches, every populated control reads `FAIL` because the census fails on
  `population=14 pop=0`); **A3+M2, A3+M5, A3+M7, A3+M9 all read `13/13 MATCH`**. So the census
  closes M8; it does not close the missing-file branch (M7), the duplicated floor (M2), or the
  unperturbed authorities (M5, M9). A3 was not frozen at the time of writing and is reported
  as a forward observation, not as the assigned battery.

## 8. Exact commands and rcs

Full transcript: `commands.txt`. Condensed:

```
$ python3 -I -B .../bin/gen_mutants.py                     rc=0  (29 artifacts)
$ sha256sum -c .../out/frozen.sha256.expected              rc=0  (epoch A)
$ bash .../bin/run_battery.sh M0                           rc=0  11 MATCH   (epoch A)
$ bash .../bin/run_battery.sh M1|M3|M4|M6|M10              rc=1  (6,1,6,7,6 mismatches)
$ bash .../bin/run_battery.sh M2|M5|M7|M8|M9               rc=0  11 MATCH each
$ bash .../bin/run_battery.sh M8b                          rc=1  7 mismatches
$ bash .../bin/run_battery.sh S2s | M2S2                   rc=0 / rc=1 (M2S2: K1-F5 only)
$ bash .../bin/run_batteryB.sh M0                          rc=0  11 MATCH   (epoch B)
$ bash .../bin/run_batteryB.sh M1..M10 (+M8b,S2s,M2S2)     same verdicts, 11-control rows
$ bash .../bin/liveness_probes.sh                          rc=0  (10 checker runs; probe rcs in §5)
$ bash .../bin/controlsA3-A3|A3M7|A3M8.sh                  rc=0 / 0 / 1 (13-control A3 probe)
$ python3 -I -B .../bin/build_matrix.py                    rc=0
$ python3 -I -B .../bin/build_matrix_b.py                  rc=0
```

`K1-REF` and `K2-REF` printed `PENDING` and were not counted in every run — unrun is not
passed; they are outside the 11.

## 9. Restoration and lane-write evidence

- **No production bytes were written.** All writes are under
  `/fast/scratch/hyaku/kagi-r57/R57MutChecker/` and this receipt. The lane's C1 checker is
  still `19d75337ce37259b08eaa8b960eedddac68bec70ed4eab3f55f9d621e142f72c` (re-hashed at
  11:32); the worktree changes to `plans/round-57-*.sh`/`.md` are other seats' (git status,
  read-only, not mine).
- Mutants never entered the lane: the receipt's `mutants/` tree is the scratch copy; M0 is
  byte-identical to the frozen checker, and each mutant differs from it only by the one hunk
  recorded in `mutant-diffs.txt`.
- The scratch tree is deleted before yield. Receipt: `R57MutChecker.d/` (170 files,
  `RECEIPT.sha256` manifest).
- No git/jj mutation was performed; only read-only commands (`rev-parse`, `show`, `archive`,
  `log`, `status`, `diff`).

Unrun / not claimed: the REF-dependent controls; A3 is uncommitted and may change again; the
class-regex mutant in §6.9 is inference, not measurement. No judgement of the contract, no
integration, no second runtime.
