# K49MutCounters — mutation test of the frozen round-49 counters

Seat: `K49MutCounters` (mutation-tester). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`. BASE `89afe91878f10805921d3caa67d28d21b33226da`, predeclaration
`082bfb3f6baa2407df2a23c0489043495b4dce4d`.

Targets (FROZEN — read, copied, never edited):
`plans/round-49-c1.sh`, `plans/round-49-c2.sh`, `plans/round-49-controls.sh`.

**Verdict: 12 mutants, 7 killed, 5 survived. Every survivor has a proposed killing control,
and each proposal was executed against both the frozen counter and the mutant (all five flip
frozen→mutant as predicted).** No frozen byte was modified; the pristine detector was green
before and after.

---

## 1. Method

Detector = the frozen 19-control suite `plans/round-49-controls.sh` (10 C1 fixtures `k1-*`,
9 C2 fixtures `k2-*`), unchanged except for one line: the `C1=`/`C2=` assignment pointing at
the mutant under test. Each mutant is a byte-copy of the frozen counter with exactly one
behaviour-bearing site changed (single-occurrence replacement asserted at generation time;
full unified diffs in `K49MutCounters/receipts/mutant-diffs.txt`).

Provenance of the measured tree:

```
S=/fast/scratch/hyaku/kagi-r49/K49MutCounters
git clone -q --shared --no-checkout <lane> $S/lane && git -C $S/lane checkout -q --detach 89afe91…
cp -p <lane>/plans/round-49-{c1,c2,controls}.sh   $S/lane/plans/
cp -p <lane>/.ufo/waves/round-49/controls/fixtures/* $S/lane/.ufo/waves/round-49/controls/fixtures/
```

`$S/lane` is a git repo whose HEAD is BASE, so the controls' `$L`-relative `git archive BASE`
and `git clone --shared $L` work exactly as in the lane, and the C2 counter's `git -C "$LANE"`
BASE lookups resolve. Instrument hashes in the scratch copy equal the lane's:

| file | sha256 |
|---|---|
| plans/round-49-c1.sh | `39b4f5520ed7b22b9d9ac693df7cb513128b57316e7fbac7cc2902fc0d3f167c` |
| plans/round-49-c2.sh | `ad6edc35d3a4689f2f767e362294ad8d401188c1a4840be0fc6c606352511171` |
| plans/round-49-controls.sh | `5b227561d4e8f27fe4e257c71abae0c57181bcc4c2a1ecab36ebc2ce7efff8a3` |
| fixtures/openbao-token-trial.ref.sh | `406e462f2f6a52399703cc0432a71ced7c46a78042fab65426b33181a77ca7e4` |
| fixtures/entry-measured.ref.md | `2339e256c343f0c4d95f69c2b56012b760192a21764a77d126ba2c22223fe59d` |

Baseline (pristine bytes, same scratch copy, same command):

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku bash $S/lane/plans/round-49-controls.sh
CONTROLS: ALL-MATCH (match=19 mismatch=0)          # 100 s wall
```

A mutant is **killed** when ≥1 control prints `MISMATCH` (observed ≠ predeclared expected);
**survived** when all 19 still MATCH. Every mutant suite ran the full 19 controls, including
the half that cannot see the mutated file, so a kill is attributable to a named control.

Mutant runs: `bash $S/lane/plans/ctl-<mutant>.sh` (that file is the frozen controls script
with only the `C1=`/`C2=` line rewritten), 4–8 suites concurrently, each in its own
`mktemp -d $SCR/controls.XXXXXX`, `trap`-removed. All `bao` servers were the trial's own
throwaway `bao server -dev` on a random 127.0.0.1 port; none survived its run.

---

## 2. C1 kill table (`plans/round-49-c1.sh`)

| # | mutant | single change | killed by (expected → observed) | survivor? |
|---|---|---|---|---|
| C1-1 | `c1-m1-drop-entry` | `ok=0; [ rv=HOLDS ] && [ sv=BROKEN ] && ok=1` — the `[ "$ev" = 1 ]` conjunct is dropped | `k1-f3` 0→**5**, `k1-f5` 0→**5** | no |
| C1-2 | `c1-m2-dup-as-holds` | `verdict()`: `n>1` returns `HOLDS` instead of `DUP` | — (19/19 MATCH) | **YES** |
| C1-3 | `c1-m3-drop-nosecret` | final gate drops `[ $nosecret -eq 1 ]` | `k1-f7` 0→**4** | no |
| C1-4 | `c1-m4-swap-shim34` | T3 runs under `sh4`, T4 under `sh3` | `k1-p` 5→**3**, `k1-f4` 4→**2** | no |
| C1-5 | `c1-m5-none-as-broken` | `verdict()`: `n=0` returns `BROKEN` instead of `NONE` | — (19/19 MATCH) | **YES** |
| C1-6 | `c1-m6-drop-pin` | sha256 pin check replaced by `:`; `pins=1` unconditionally | `k1-f6` SETUP→**5** | no |
| C1-7 | `c1-m7-drop-setup-ok` | final gate drops `[ $setup_ok -eq 1 ]` | — (19/19 MATCH) | **YES** |

Detail worth recording: C1-4's swap is caught twice and for the right reason — `k1-p` shows
`T3:real=HOLDS,shim=HOLDS` and `T4:real=HOLDS,shim=HOLDS` (SH4 does not touch a batch
`token create`; SH3 does not touch a userpass `login`), so the mutant loses exactly the two
tests whose designated falsifier it displaced.

## 3. C2 kill table (`plans/round-49-c2.sh`)

| # | mutant | single change | killed by (expected → observed) | survivor? |
|---|---|---|---|---|
| C2-1 | `c2-m1-drop-G1` | G1 byte-identity block removed | `k2-f3` SETUP→**0** | no |
| C2-2 | `c2-m2-drop-G5` | G5 POLICY-line block removed | — (19/19 MATCH) | **YES** |
| C2-3 | `c2-m3-setup-as-ok` | `[ "$v" = OK ] \|\| [ "$v" = SETUP ] \|\| value++` | `k2-0` 6→**3**, `k2-f4` 3→**0** | no |
| C2-4 | `c2-m4-drop-G4` | G4 stamps-row block removed | `k2-f2` SETUP→**0** | no |
| C2-5 | `c2-m5-min-lines-0` | `MIN_LINES=63` → `MIN_LINES=0` (G6 disabled) | — (19/19 MATCH) | **YES** |

C2-3 is killed because BASE is 3×STALE + 3×SETUP (`k2-0`: `SC-SKILL-STAMPS=STALE
PV-STAMPS=STALE RD-STAMPS=STALE RD-DOCS-ROWLINKED=SETUP RD-DOCS-BYHAND=SETUP
RD-DOCS-ENTRIES=SETUP`), so counting SETUP as OK collapses the BASE reading from 6 to 3.

---

## 4. Survivors and proposed killing controls

Each proposal was built in scratch, run against the **frozen** counter (to pin the expected
value) and against the **mutant** (to prove the flip). Fixture recipes:
`K49MutCounters/receipts/proposed-control-fixtures.diff`; outputs:
`K49MutCounters/receipts/props/`. **Routed, not applied** — the frozen instruments were not
edited.

| survivor | proposed control | frozen | mutant | flip |
|---|---|---|---|---|
| C1-2 `DUP→HOLDS` | `k1-f9`: reference trial whose `report()` prints the line twice on `HOLDS` → real run is `DUP` for T1..T5 | `value=0` (`T1..T5: real=DUP, shim=BROKEN`) | `value=5` | killed |
| C1-5 `NONE→BROKEN` | `k1-f10`: reference trial with T3's `BROKEN` branch silenced (`else :;`) → shim run emits no T3 line | `value=4` (`T3: shim=NONE`) | `value=5` | killed |
| C1-7 `drop setup_ok` | `k1-f12`: reference trial whose no-bao guard exits 0 instead of 2 → none-run rc=0 while the trial still discriminates | `value=0` (`discriminating=5 setup_ok=0 none_rc=0`) | `value=5` | killed |
| C2-2 `drop G5` | `k2-f8`: reference fix + `PV-FEEDTOKEN-SHAPES`/`PV-FEEDTOKEN-SELFTEST` rows removed from `corpus/self-counts.tsv`, plus 2 padding rows so the claim count stays 63 | `SETUP reason=G5-policy=` | `value=0 lines=63` | killed |
| C2-5 `MIN_LINES=0` | `k2-f9`: reference fix + 2 ordinary claim rows deleted (61 verdict lines) | `SETUP reason=G6-lines=61` | `value=0 lines=61` | killed |

Failed proposal, recorded honestly: a first attempt at C1-7 used a constant-`HOLDS` trial with
no bao guard (`k1-f11`). It does **not** kill the mutant — `k1-f11` frozen `value=0`
(`setup_ok=0`) and mutant `value=0`, because a constant-`HOLDS` trial has
`discriminating=0` and the mutant only removes the `setup_ok` conjunct. The killing control
must keep the trial discriminating (`k1-f12`).

Why each survivor is a coverage gap, not an equivalent mutant: each one changes the
counter's answer on an input class the 19 controls never produce — a duplicated `TRIAL`
line, a missing `TRIAL` line under a shim, a none-run that exits 0 while printing `HOLDS`,
a POLICY-line set that drifts without touching `self-counts.py`, and a truncated
`self-counts.py` output that still ends with a final line. In each case the mutant *raises*
the reported value (or removes a SETUP), i.e. the defect direction is toward over-crediting
the producer.

---

## 5. Harness note (methodology, not a counter finding)

The first C2 mutant batch was run with the mutant scripts under `$S/mut/`. The C2 counter
derives `LANE=$(cd "$(dirname "$0")/.." && pwd)`, so `LANE` resolved to a non-git directory
and every control returned `C2_SELF_COUNTS: SETUP reason=base-missing`. Those runs were
**inconclusive, not kills**, and were discarded; the C2 mutants were relocated to
`$S/lane/plans/mut-c2-*.sh` (so `LANE=$S/lane`, a BASE clone) and all five suites re-run from
scratch. The C1 counter's `--tree` path never consults `LANE`, so the C1 batches were valid
as run — confirmed by their non-SETUP values.

---

## 6. Restoration evidence

No frozen byte was ever written: the instruments were copied into scratch and the mutants are
separate files. After all runs:

```
$ sha256sum <lane>/plans/round-49-{c1,c2,controls}.sh
39b4f552…f167c  plans/round-49-c1.sh        # identical to §1
ad6edc35…1171   plans/round-49-c2.sh
5b227561…f8a3   plans/round-49-controls.sh
$ git -C <lane> status --porcelain -- plans/
 M plans/round-47.md          # NOT this seat: no round-49 instrument is dirty
```

`plans/round-47.md` is a sibling seat's live edit in the shared lane; this seat never wrote
under `plans/`. The authoritative check is the three instrument hashes above, which match the
pre-run values exactly.

Restored-bytes detector run (same command as the baseline, after every mutant run):

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku bash $S/lane/plans/round-49-controls.sh
CONTROLS: ALL-MATCH (match=19 mismatch=0)          # 125 s wall
```

The 19 `CONTROL …` lines of the restored run are byte-identical to the baseline run's
(`diff` over the lines with the `::` detail suffix stripped: IDENTICAL), so the detector is
green on pristine, red only on the mutated file, and green again afterwards. Receipt:
`K49MutCounters/receipts/suites/pristine-restored.txt`.

Scratch was removed after the receipts were copied; no `bao` process started by this seat
survived its run (checked by `readlink /proc/<pid>/cwd` against the scratch path: none).

---

## 7. Receipts

- `K49MutCounters/mutants/` — the 12 mutant sources (byte-copies with one site changed).
- `K49MutCounters/receipts/hashes.txt` — sha256 of frozen instruments, fixtures, mutants.
- `K49MutCounters/receipts/mutant-diffs.txt` — unified diff of every mutant vs its frozen source.
- `K49MutCounters/receipts/suites/` — full stdout of the 12 mutant suites + the pristine
  baseline and the restored-bytes re-run.
- `K49MutCounters/receipts/props/` — frozen-vs-mutant runs on each proposed killing control.
- `K49MutCounters/receipts/proposed-control-fixtures.diff` — exact fixture edits for §4.
- `K49MutCounters/receipts/{genmut.py,buildprop.sh,runprop.sh,analyze.py}` — generators/drivers.

Every suite receipt ends with its `CONTROLS: ALL-MATCH|MISMATCH (match=N mismatch=M)` line;
every prop receipt ends with its single `C1_OPENBAO_TRIAL:`/`C2_SELF_COUNTS:` line. No receipt
contains a token: the counters' own `nosecret` scan covers their stdout, and the trial writes
its dev root token only inside its scratch dir, which is removed by its `trap`.
