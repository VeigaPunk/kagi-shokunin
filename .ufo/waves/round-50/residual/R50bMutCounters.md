# R50bMutCounters — mutation test of the frozen round-50 counters

Seat: R50bMutCounters (UFO-FSD mutation tester, round 50 attempt 2, axis: operability / calibration).
Lane /home/vgpnk/Projects/shokunin/kagi-shokunin, BASE 565c43a874b59cd216f4a55c8742db48fa854f16,
predeclaration 7d3b2c01b375d5459abd7da79bb4063b7d728fc7.
Scratch: /fast/scratch/hyaku/kagi-r50/R50bMutCounters (removed at exit).

## Instruments under test (frozen; only COPIES were mutated)

| file | sha256 (frozen) |
|---|---|
| plans/round-50-c1.sh | `fe6dc81212dac9f1d9ab52b6f34068009ad14a8d27c1f0d52eb0e33c22a5aaf6` |
| plans/round-50-c2.sh | `449979bfe11a4506ce8a715f87942333df2aa78b402a9acc9969fe8b57cbb023` |

Both copies in scratch hash-identical to the frozen values before mutation (verified:
`sha256sum $S/lane/plans/p-c1.sh $S/lane/plans/p-c2.sh`).

## Harness

`S=/fast/scratch/hyaku/kagi-r50/R50bMutCounters` (removed at exit; every command below is the one
actually run, with `$S` expanded).

- Pristine and mutant copies live in `$S/lane/plans/` where `$S/lane` is
  `git clone -q --shared --no-checkout <lane>` checked out at BASE
  (`git -C $S/lane rev-parse --show-toplevel` = `$S/lane`, HEAD = BASE asserted).
  Copy placement is required by the instruments themselves: C1 resolves
  `$HERE/round-49-c1.sh` and C2 resolves `LANE=$(dirname $0)/..` for `git show BASE:...`.
- Fixture trees/repos are byte-for-byte what plans/round-50-controls.sh builds:
  C1 `git -C <lane> archive BASE | tar -x -C $t` + one fixture trial file;
  C2 `git clone -q --shared --no-checkout <lane>` + `checkout --detach BASE` + the frozen
  `.ufo/waves/round-50/controls/fixtures/migrate.py <mode>` + fixture commit
  (toplevel asserted before each commit).
- Detector: the same bounded predicate the controls use — the instrument's own
  `C1_ORPHAN_SAFE: ` / `C2_LEDGER_DRIFT: ` line, `value=` read out (or `SETUP`).
- Pristine baselines: the committed pre-freeze receipt
  `.ufo/waves/round-50/controls/controls-prefreeze.txt` (ALL-MATCH, 15/15) plus local
  pristine-copy runs (p-c1 on c1-0, p-c2 on c2-0) in this wave.

## Mutants (each exactly one changed line; old→new recorded verbatim)

C1 (`plans/round-50-c1.sh`, copy `p-c1.sh`):

| id | line | old | new | drops |
|---|---|---|---|---|
| M1 | 134 | `[ "$alive" -eq 0 ]` | `[ "$alive" -ge 0 ]` | survivors check (always "0 survivors") |
| M2 | 150 | `if [ $positive -ne 1 ] \|\| [ $setupk -ne 0 ]; then` | `if [ $setupk -ne 0 ]; then` | POSITIVE requirement |
| M3 | 127 | `[ -n "$c" ] \|\| { echo "$k:observed=0,reached=1"; return 2; }` | `[ -n "$c" ] \|\| :` | OBSERVED requirement |
| M4 | 128 | `sleep 5` | `sleep 0` | the 5 s post-kill wait |

C2 (`plans/round-50-c2.sh`, copy `p-c2.sh`):

| id | line | old → new | drops |
|---|---|---|---|
| M5 | 110 | `[[ $pert =~ $new ]] && setup "G6-not-discriminating-$id"` → `[[ $pert =~ $new ]] && :` | G6 digit+1 refusal |
| M6 | 91 | `[ -f "$C/$JOURNAL" ] \|\| setup "G5-journal-missing"` → `... \|\| continue` | G5 journal requirement |
| M6b | 101 | `ok = len(hits) == 1 and hits[0].get("old_expect") == old and hits[0].get("new_expect") == new \` → `ok = len(hits) == 1 and True and True \` | G5 old/new equality (supplementary) |
| M7 | 82 | `... ] \|\| setup "G2-columns-$id"` → `... ] \|\| :` | G2 command-column freeze |
| M8 | 124 | `^(FAIL\|POLICY\|LAYOUT-INCOMPLETE)` → `^(FAIL\|LAYOUT-INCOMPLETE)` (both greps on the counting line) | POLICY arm of the value |

Line numbers are in the mutated copy; every mutant changes exactly one line and keeps the
line count (`bash -n` clean on the one mutant with a backslash-continued Python heredoc line).

### Supplementary probe — is the POLICY arm load-bearing at all? (M8)

No frozen control ever makes `claim-ledger.sh verify` print a `POLICY` line (K2-0 = 10 FAIL,
K2-F5 = 5 FAIL + 5 OK, K2-P = 0 FAIL). So M8 SURVIVED the control set. To distinguish "equivalent
mutant" from "control-set gap" I built one extra fixture in **my scratch only** (not a control, not
a frozen file, nothing written to the lane): a BASE clone with `corpus/sources-census.sh` replaced
by a same-content symlink (`corpus/sources-census.dup.sh`) and committed. The four frozen ids whose
command is `bash corpus/sources-census.sh` (R21-02, R31-02, R33-02, R34-03) are then refused by
`claim-ledger.sh`'s `policy_check`/`script-symlink` arm — with the command column byte-identical to
BASE (G2 holds) and the producer content byte-identical (G1 holds, `sha256sum` follows the symlink).

| run | expected from M8 drop of POLICY | got |
|---|---|---|
| pristine `p-c2.sh` on `c2-POL2` | — | `value=10` (4 POLICY + 6 FAIL) |
| `m8-failonly.sh` on `c2-POL2` | 6 | **6** |

Raw:
```
p-c2_cPOL2 counter=p-c2.sh tree=c2-POL2 expected=MEASURE got=10 rc=0 :: C2_LEDGER_DRIFT: value=10 ids=10 changed=0 verify_rc=2 R13-01=FAIL R21-02=POLICY R22-03=FAIL R24-05=FAIL R24-06=FAIL R24-15=FAIL R31-02=POLICY R33-02=POLICY R34-03=POLICY R38-01=FAIL
m8_cPOL2  counter=m8-failonly.sh tree=c2-POL2 expected=MEASURE got=6 rc=0 :: C2_LEDGER_DRIFT: value=6 ids=10 changed=0 verify_rc=2 R13-01=FAIL R21-02=OK R22-03=FAIL R24-05=FAIL R24-06=FAIL R24-15=FAIL R31-02=OK R33-02=OK R34-03=OK R38-01=FAIL
```
Verdict on M8 therefore stays **SURVIVED against the frozen control set** (no control kills it),
with the added fact that the mutated arm *is* reachable and load-bearing: the gap is in the
control set, not in the counter's semantics.

(An earlier POL variant that *also* ran `migrate.py ref` before the symlink commit was discarded:
it trips `G6-no-digit-R24-15` even with the pristine counter — `p-c2.sh` on `c2-POL` = `SETUP
reason=G6-no-digit-R24-15`, rc=2 — because the extra commit changes `row-identity.sh
revision-added`'s output shape; that is an artifact of my fixture, not a lane finding.)

## Results

Detector = the instrument's own summary line (`value=`, else `SETUP`). A control kills a mutant
when the mutant's detector reading differs from the control's pre-freeze expectation (i.e. the
mutant's run prints MISMATCH where the pristine instrument prints MATCH).

| mutant | control (frozen expectations from controls-prefreeze.txt) | expected | mutant got | verdict |
|---|---|---|---|---|
| M1 drop survivors check | K1-0 (BASE trial, EXIT-trap only) | 0 | **3** | **KILLED** |
| M2 drop POSITIVE | K1-F4 (pdeathsig server, constant HOLDS, no tests) | SETUP | **3** | **KILLED** |
| M3 drop OBSERVED | K1-F3 (constant-HOLDS printer, no server) | SETUP | SETUP | SURVIVED |
| M4 5 s wait → 0 | K1-P (reference fixture) | 3 | 3 | SURVIVED |
| M4 5 s wait → 0 | K1-0 (BASE trial) | 0 | 0 | SURVIVED |
| M5 drop G6 digit+1 refusal | K2-F1 (wildcard expect) | SETUP | **0** | **KILLED** |
| M6 drop G5 journal | K2-F3 (nojournal) | SETUP | **0** | **KILLED** |
| M6b drop G5 old/new equality | K2-P (reference migration) | 0 | 0 | SURVIVED |
| M7 drop G2 command-column freeze | K2-F2 (repoint R13-01's command) | SETUP | **1** | **KILLED** |
| M8 count only FAIL (drop POLICY) | K2-0 (BASE) | 10 | 10 | SURVIVED |
| M8 count only FAIL (drop POLICY) | K2-F5 (half) | 5 | 5 | SURVIVED |

Raw lines (the first probe wave, 15 runs; `results.txt` holds all 19 including the re-runs):

```
m1_t0  counter=m1-suvivors.sh tree=c1-0 expected=0 got=3 MISMATCH rc=0 :: C1_ORPHAN_SAFE: value=3 positive=1 reaped=3 K1:observed=1,captured=1,survivors=1 K2:observed=1,captured=1,survivors=1 K3:observed=1,captured=1,survivors=1
m2_tF4 counter=m2-positive.sh tree=c1-F4 expected=SETUP got=3 MISMATCH rc=0 :: C1_ORPHAN_SAFE: value=3 positive=0 reaped=0 K1:observed=1,captured=1,survivors=0 K2:observed=1,captured=1,survivors=0 K3:observed=1,captured=1,survivors=0
m3_tF3 counter=m3-observed.sh tree=c1-F3 expected=SETUP got=SETUP MATCH rc=2 :: C1_ORPHAN_SAFE: SETUP positive=0 observed_all=0 safe=2 reaped=0 K1:observed=0,reached=0 K2:observed=1,captured=0,survivors=0 K3:observed=1,captured=0,survivors=0 pos=[C1_OPENBAO_TRIAL: value=0 discriminating=0 pins=1 setup_ok=0]
m4_tP  counter=m4-wait.sh tree=c1-P expected=3 got=3 MATCH rc=0 :: C1_ORPHAN_SAFE: value=3 positive=1 reaped=0 K1:observed=1,captured=1,survivors=0 K2:observed=1,captured=1,survivors=0 K3:observed=1,captured=1,survivors=0
m4_t0  counter=m4-wait.sh tree=c1-0 expected=0 got=0 MATCH rc=0 :: C1_ORPHAN_SAFE: value=0 positive=1 reaped=3 K1:observed=1,captured=1,survivors=1 K2:observed=1,captured=1,survivors=1 K3:observed=1,captured=1,survivors=1
m5_cF1 counter=m5-g6.sh tree=c2-F1 expected=SETUP got=0 MISMATCH rc=0 :: C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK R21-02=OK R22-03=OK R24-05=OK R24-06=OK R24-15=OK R31-02=OK R33-02=OK R34-03=OK R38-01=OK
m6_cF3 counter=m6-g5.sh tree=c2-F3 expected=SETUP got=0 MISMATCH rc=0 :: C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK R21-02=OK R22-03=OK R24-05=OK R24-06=OK R24-15=OK R31-02=OK R33-02=OK R34-03=OK R38-01=OK
m6b_cP counter=m6b-g5content.sh tree=c2-P expected=0 got=0 MATCH rc=0 :: C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK ... R38-01=OK
m7_cF2 counter=m7-g2.sh tree=c2-F2 expected=SETUP got=1 MISMATCH rc=0 :: C2_LEDGER_DRIFT: value=1 ids=10 changed=10 verify_rc=2 R13-01=POLICY R21-02=OK R22-03=OK R24-05=OK R24-06=OK R24-15=OK R31-02=OK R33-02=OK R34-03=OK R38-01=OK
m8_c0  counter=m8-failonly.sh tree=c2-0 expected=10 got=10 MATCH rc=0 :: C2_LEDGER_DRIFT: value=10 ids=10 changed=0 verify_rc=1 R13-01=FAIL ... R38-01=FAIL
m8_cF5 counter=m8-failonly.sh tree=c2-F5 expected=5 got=5 MATCH rc=0 :: C2_LEDGER_DRIFT: value=5 ids=10 changed=5 verify_rc=1 R13-01=OK R21-02=OK R22-03=FAIL R24-05=FAIL R24-06=FAIL R24-15=FAIL R31-02=OK R33-02=OK R34-03=OK R38-01=FAIL
```

## Findings

### B1 — blocker: none. No control reading of either frozen counter is made wrong by a surviving mutant in a way that changes a verdict at BASE or at the landed candidates.

Detail per surviving mutant (all are coverage findings, not contract changes):

### F1 — M3 (drop OBSERVED) SURVIVED · severity note · falsifies nothing, names a ceiling
Command: `bash $S/lane/plans/m3-observed.sh --tree $S/trees/c1-F3` → rc=2,
last line `C1_ORPHAN_SAFE: SETUP positive=0 observed_all=0 safe=2 reaped=0 K1:observed=0,reached=0 K2:observed=1,captured=0,survivors=0 K3:observed=1,captured=0,survivors=0 …`
Control K1-F3 expects SETUP; the mutant also prints SETUP (MATCH) → SURVIVED. Why: the K1 reach
condition (`[ -n "$c" ] && reached=1`) is itself an OBSERVED test, so a trial that starts no server
can never reach K1 and the run is SETUP through `setupk` anyway. What the check still buys is
honesty of the detail line: in the mutant, K2/K3 print `observed=1,captured=0` (self-contradictory)
and `safe=2`, i.e. the per-kill-point detail would lie while the verdict stays SETUP. Uncovered
shape: a trial observed at K1 whose server vanishes before K2/K3 (then the mutant scores those kill
points as safe and the verdict flips to value>0). No pre-freeze fixture has that shape.

### F2 — M4 (5 s wait → 0) SURVIVED · severity note · names a ceiling
Commands: `bash $S/lane/plans/m4-wait.sh --tree $S/trees/c1-P` → rc=0, last line
`C1_ORPHAN_SAFE: value=3 positive=1 reaped=0 K1:observed=1,captured=1,survivors=0 …` (control
expects 3) and `--tree $S/trees/c1-0` → rc=0, `value=0 … survivors=1` (control expects 0). Both
MATCH → SURVIVED. Why: every fixture's server state is already settled by the time the counter
looks (survivors are long-lived `bao server -dev`; the reference server is killed by
PR_SET_PDEATHSIG at, or before, the `wait "$pid"` that precedes the sample). The 5 s window is
therefore not exercised at all: a regression that only reports orphans *after* a delay (for example
a server that exits ~0.2 s after a plain SIGKILL because its own child reaper is slow) would be
invisible to the whole control set. Uncovered shape needed: a fixture whose server dies 0.5–4 s
after the kill.

### F3 — M6b (drop G5 old/new equality) SURVIVED · severity note · names a ceiling
Command: `bash $S/lane/plans/m6b-g5content.sh --tree $S/repos/c2-P` → rc=0, last line
`C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK … R38-01=OK` (control K2-P
expects 0) → MATCH → SURVIVED. Why: every C2 fixture writes the journal through `migrate.py`, which
records the true `old_expect`/`new_expect`, so no control presents a journal entry whose values
disagree with the ledger. The `old_expect`/`new_expect` equality is unexercised: a migrated row
whose journal says the wrong thing (the exact drift the journal exists to expose) passes the
counter. `migrate.py` is a frozen fixture, so this is a routed coverage gap, not something to fix
here.

### F4 — M8 (count only FAIL) SURVIVED · severity defect (control-set gap) · names a ceiling
Commands: `bash $S/lane/plans/m8-failonly.sh --tree $S/repos/c2-0` → rc=0,
`C2_LEDGER_DRIFT: value=10 … R13-01=FAIL …` (expects 10, MATCH) and `--tree $S/repos/c2-F5` → rc=0,
`value=5 … R13-01=OK R21-02=OK R22-03=FAIL …` (expects 5, MATCH) → SURVIVED. The predicate counts
`FAIL`, `POLICY` and `LAYOUT-INCOMPLETE`, but all fifteen pre-freeze controls produce only FAIL/OK
readings, so dropping the POLICY arm changes nothing under any of them. Supplementary probe (above)
shows the arm is reachable and worth 4 of 10 on a symlink-refused census row: pristine 10 vs mutant
6. Suggested (routed) control: a BASE clone whose `corpus/sources-census.sh` is a same-content
symlink, expected 10 (pristine), 6 (M8) — a policy arm the frozen set should pin. Frozen controls
were not edited.

### Killed mutants — detectors that did their job
| mutant | command | rc | last output line |
|---|---|---|---|
| M1 | `bash $S/lane/plans/m1-suvivors.sh --tree $S/trees/c1-0` | 0 | `C1_ORPHAN_SAFE: value=3 positive=1 reaped=3 K1:observed=1,captured=1,survivors=1 K2:…survivors=1 K3:…survivors=1` (expected 0) |
| M2 | `bash $S/lane/plans/m2-positive.sh --tree $S/trees/c1-F4` | 0 | `C1_ORPHAN_SAFE: value=3 positive=0 reaped=0 K1:…survivors=0 K2:…survivors=0 K3:…survivors=0` (expected SETUP) |
| M5 | `bash $S/lane/plans/m5-g6.sh --tree $S/repos/c2-F1` | 0 | `C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 R13-01=OK … R38-01=OK` (expected SETUP) |
| M6 | `bash $S/lane/plans/m6-g5.sh --tree $S/repos/c2-F3` | 0 | `C2_LEDGER_DRIFT: value=0 ids=10 changed=10 verify_rc=1 … R38-01=OK` (expected SETUP) |
| M7 | `bash $S/lane/plans/m7-g2.sh --tree $S/repos/c2-F2` | 0 | `C2_LEDGER_DRIFT: value=1 ids=10 changed=10 verify_rc=2 R13-01=POLICY R21-02=OK …` (expected SETUP) |

M7's kill is robust for a second reason worth recording: with G2 gone the repoint fixture's new
command (`echo 67`, byte-different from BASE) is itself refused by the ledger's `policy_check`, so
the mutant reads `POLICY (claims=10 policy=1 stamped=124)` → value 1, not 0; either way the control
expectation SETUP is missed.

## Pristine baseline (same detector, unmutated bytes)

| run | command | rc | last line |
|---|---|---|---|
| p-c1_t0 | `bash $S/lane/plans/p-c1.sh --tree $S/trees/c1-0` | 0 | `C1_ORPHAN_SAFE: value=0 positive=1 reaped=3 K1:observed=1,captured=1,survivors=1 K2:…survivors=1 K3:…survivors=1` |
| p-c2_c0 | `bash $S/lane/plans/p-c2.sh --tree $S/repos/c2-0` | 0 | `C2_LEDGER_DRIFT: value=10 ids=10 changed=0 verify_rc=1 R13-01=FAIL … R38-01=FAIL` |

Both equal the committed pre-freeze expectations (K1-0 = 0, K2-0 = 10), so the local harness
reproduces the frozen receipt before any mutation is applied; no baseline failure to excuse.
`p-c1.sh` / `p-c2.sh` hashed `fe6dc81…` / `449979b…` = the frozen instrument hashes.

## Harness notes / honesty

- Two first-pass runs exited rc=127 with empty output (`p-c1_t0`, `p-c2_c0`): I passed the counter
  basename without its `.sh` suffix, so `bash <path>` had no file. Re-run correctly (table above);
  the rc=127 rows remain in `results.txt` and receipts.
- Counts: 9 mutants (8 assigned + 1 supplementary M6b), 5 KILLED (M1, M2, M5, M6, M7),
  4 SURVIVED (M3, M4, M6b, M8), 17 counter invocations total.
- Every C1 run's own scratch went under `$S/kagi-r50/…` (`HYAKU_SCRATCH=$S` passed per run) and the
  counters removed it; no `bao` process remained (`pgrep -af 'bao server'` → none after the wave).
  The two pre-existing `/fast/scratch/hyaku/kagi-r50/c1-counter.*` dirs (19:23/19:24) are other
  seats' and were left alone.

## Restoration evidence

- Frozen instruments in the lane, after the wave:
  `sha256sum plans/round-50-c1.sh plans/round-50-c2.sh` →
  `fe6dc81212dac9f1d9ab52b6f34068009ad14a8d27c1f0d52eb0e33c22a5aaf6`,
  `449979bfe11a4506ce8a715f87942333df2aa78b402a9acc9969fe8b57cbb023` — unchanged (identical to
  `.ufo/waves/round-50/controls/instrument-sha256.txt`); fixtures' `migrate.py` =
  `d10d3a20…` unchanged. `git status --porcelain` in the lane shows no file touched by this seat.
- Mutations existed only as separate copies; the pristine copies were never written
  (`mutants.json` carries sha_before/sha_after for every mutant; every mutant differs from its
  source by exactly one line and keeps the line count).
- Seat scratch `/fast/scratch/hyaku/kagi-r50/R50bMutCounters` removed at exit (`rm -rf`), after the
  receipts were copied to `.ufo/waves/round-50/residual/R50bMutCounters-receipts/`.

## Coverage statement

Frozen predicates attacked: 9 mutants over both counters; 5 killed by an existing pre-freeze
control, 4 survived. The unexercised surfaces inside the frozen instruments are: the per-kill-point
OBSERVED arm at K2/K3 (F1), the 5 s post-kill window (F2), the journal's old/new equality (F3) and
the POLICY arm of C2's value (F4). None of these changes a reading at BASE or at the landed
candidates — C1's 3-kill-point reading and C2's 0 both rest on the killed checks (survivors,
POSITIVE, G6, G5-presence, G2) — so no frozen claim is falsified here; the four survivors name
ceilings, not defects in the landed counters.


