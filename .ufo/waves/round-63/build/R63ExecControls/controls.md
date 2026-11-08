# R63ExecControls — round-63-controls.sh battery receipt

Seat: R63ExecControls. File written: `plans/round-63-controls.sh` (the only lane
path this seat owns). Scratch: `/fast/scratch/hyaku/kagi-r63/R63ExecControls/`
(deleted before yield).

## What the battery is

`plans/round-63-controls.sh [TREE]` / `--selftest`, same shape as
`plans/round-62-controls.sh`: per-control lines
`CONTROL <id> expect=<…> observed=<…> verdict=match|mismatch|skip`, a
`CONTROLS: match=N mismatch=M` summary, exit 0 iff mismatch=0, 1 on mismatch,
2 SETUP. Controls:

- `C1-F8` — printer-stub copy of `plans/round-63-c1.sh` (constant
  `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 …`, exit 0); on a
  BASE-reading tree its line mismatches the independently expected BASE census
  (`accepted=10 rejected=6`) → `verdict=mismatch`.
- `C2-F6` — constant-verdict copy of `plans/round-63-c2.sh` (constant
  `C2_REFUSAL: killed=5 population=5 guard=1 …` (amended POP, plan A2), exit 0); mismatches `killed=0`.
- `C1-NOWORK` / `C2-NOWORK` — the unmutated counters must reproduce the frozen
  BASE census (`accepted=10 rejected=6 population=10/6`; `killed=0 population=5`).
- `C1-REAL` / `C2-REAL` — positive controls: the unmutated counters must print
  a verdict line with `guard=1`.
- `PRIOR-<id>` — delegates to `<tree>/plans/round-62-controls.sh <tree>` on a
  private snapshot and re-emits each `CONTROL` line as `PRIOR-<id>` with its
  verdict preserved.

The unmutated counters are each run **once** (`probe_counters`) and the parsed
fields are kept in `U1_*`/`U2_*` so the stub controls' `R1_*`/`R2_*` parses
cannot clobber the NOWORK/REAL readings (a bug caught in selftest).

Stub construction: `mk_stub_counter` copies the measured counter and inserts
after the shebang a dispatch that prints the frozen stub line and exits 0 for
every non-`--selftest` invocation — a printer-stub *copy*, per the frozen
control description.

## Commands and outputs

### 1. Syntax

```
$ bash -n plans/round-63-controls.sh
(no output; rc=0)
```

### 2. Selftest (fixture-driven; no lane instruments, no bao)
```
$ bash plans/round-63-controls.sh --selftest
CONTROLS_SELFTEST: PASS (cases=25)
rc=0
```

Final script sha256 `cb8134ad1ce486d9e5fe6f4397bf3af4ae8fa034c15e565cc1439e90d4b2cb87`.

NOTE — plan Amendments A2/A3 landed while this file was being written
(commits `81bd56c`, `aeafc0e`): C2 population is **5** (L5 vacuous at BASE,
dropped), verdict `C2_REFUSAL: killed=K population=5 … (l1 l2 l3 l4 l6 …)`,
target killed=5; C1 guard gains leg (f) `chal=`. The battery's C2 constants,
stub line and fixtures carry the amended population=5 form; C1 parsing is
unaffected (accepted/rejected/population/guard fields unchanged).

The selftest runs the battery end-to-end as a subprocess on three fixture trees:

- fixture-base (counters print the BASE census): asserts `C1-F8`/`C2-F6`
  `verdict=mismatch`, `C1-NOWORK`/`C2-NOWORK`/`C1-REAL`/`C2-REAL` `verdict=match`,
  `PRIOR-*` rows re-emitted, summary `match=5 mismatch=2`, rc=1.
- fixture-cand (counters print the target lines): asserts both NOWORK controls
  `verdict=mismatch`, both REAL controls `verdict=match`.
- fixture-empty (no round-63 counters): asserts all six round-63 controls
  `verdict=skip`, PRIOR still runs, rc=0.

Plus parser unit cases, the stub builder's shebang refusal, the report
counter/exit contract, and named-FINDING recognition. A failing case prints
`FINDING R63C-CTL-ST-<case>`.

### 3. Fixture-tree run (stub counters + stub prior battery)

Fixture tree `/fast/scratch/hyaku/kagi-r63/R63ExecControls/fakerepo` with
`plans/round-63-c1.sh` printing `accepted=10 rejected=6 population=10/6 guard=1`,
`plans/round-63-c2.sh` printing `killed=0 population=5 guard=1` (amended POP), and the real
`plans/round-62-controls.sh` copied in:

```
$ bash plans/round-63-controls.sh .        # rc=1
CONTROL C1-F8    expect=accepted=10 rejected=6 mismatch  observed=accepted=0 rejected=0 population=10/6 verdict=mismatch
CONTROL C2-F6    expect=killed=0 mismatch   observed=killed=5 population=5              verdict=mismatch
CONTROL C1-NOWORK expect=accepted=10 rejected=6 population=10/6 observed=same rc=0      verdict=match
CONTROL C2-NOWORK expect=killed=0 population=5          observed=same rc=0              verdict=match
CONTROL C1-REAL  expect=verdict-line;guard=1 observed=guard=1 ...                     verdict=match
CONTROL C2-REAL  expect=verdict-line;guard=1 observed=guard=1 ...                     verdict=match
CONTROL PRIOR-*  (14 rows re-emitted from plans/round-62-controls.sh; on the
                  fixture tree all read verdict=skip — its instruments are absent)
SKIPS: 14
CONTROLS: match=4 mismatch=2
SEAT-STATUS: partial mismatch-count=2
```

### 4. BASE-tree run (extracted 0c07aab8)

```
$ git -C kagi-shokunin archive 0c07aab8df64b673a54a5113aebd7f34b622adbc | tar -x -C basetree
$ cp plans/round-63-controls.sh basetree/plans/
$ R63_CONTROLS_RECEIPT=/dev/null bash basetree/plans/round-63-controls.sh basetree
```

Full output: `base-run.txt` (same directory). Summary:

```
INSTRUMENT plans/round-63-c1.sh MISSING
INSTRUMENT plans/round-63-c2.sh MISSING
INSTRUMENT plans/round-62-controls.sh 93587e6d15d5c0ebb94fac3a6039235070632c45dd5c3db86ae7fbcf1107ea97
CONTROL C1-F8     expect=accepted=10 rejected=6 mismatch  observed=absent verdict=skip
CONTROL C2-F6     expect=killed=0 mismatch   observed=absent verdict=skip
CONTROL C1-NOWORK expect=accepted=10 rejected=6 population=10/6 observed=absent verdict=skip
CONTROL C2-NOWORK expect=killed=0 population=5          observed=absent verdict=skip
CONTROL C1-REAL   expect=verdict-line;guard=1 observed=absent verdict=skip
CONTROL C2-REAL   expect=verdict-line;guard=1 observed=absent verdict=skip
CONTROL PRIOR-*   14 rows re-emitted (prior battery's own verdicts on BASE bytes:
                  5 match / 7 mismatch / 2 skip — the round-62 candidate-side
                  controls mismatch on a BASE extraction, expected)
DETAIL PRIOR delegated=14 rc=1 prior-summary=SKIPS: 2 CONTROLS: match=5 mismatch=7
SKIPS: 8
CONTROLS: match=5 mismatch=7
SEAT-STATUS: partial mismatch-count=7
```

Wall time ~19 min under heavy sibling-seat load (the PRIOR delegation runs the
round-62 battery including its real bao trial legs).

## BASE reading note

At claim BASE `0c07aab8` the round-63 counters do not exist, so on a bare
extracted BASE tree `C1-F8`/`C2-F6`/`C1-NOWORK`/`C2-NOWORK`/`C1-REAL`/`C2-REAL`
all record `verdict=skip` (absent instrument) and only `PRIOR-*` rows emit.
The acceptance reading — F8/F6 `mismatch` with NOWORK `match` — requires the
tree to carry `plans/round-63-c1.sh`/`round-63-c2.sh` at their BASE behaviour
(i.e. the post-instrument-landing, pre-candidate tree), which is the state the
L1 measures. The fixture run in §3 demonstrates exactly that verdict pattern.
