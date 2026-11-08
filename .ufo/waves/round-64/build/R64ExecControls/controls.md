# R64ExecControls — round-64 pre-freeze control battery

Seat: R64ExecControls. Files written:

- `plans/round-64-controls.sh` (new; this seat's file).
- `plans/round-63-controls.sh` — **not touched**: the C2 seat (`R64ExecC2Counter`)
  confirmed by message (2026-11-08) that it lands the `R63_CONTROLS_FIXTURE_ONLY`
  branch there (its prompt item 1). The branch is present at write time
  (`plans/round-63-controls.sh:571`; with the flag set, `probe_counters` and the
  PRIOR delegation are skipped and the C1-F8/C2-F6 stub controls still run).
  This battery detects the branch in the prior battery's bytes and adapts its
  delegation mode; it does not require the file.
- Receipts in this directory: `controls.md`, `base-run.out`, `base-run.txt`,
  `fixture-accept.out/.txt`, `fixture-run.out/.txt`, `stub-run.out/.txt`,
  `c1-direct2.out`, `counters.sha256`.

Scratch: `/fast/scratch/hyaku/kagi-r64/R64ExecControls/` (deleted before yield).
No tool install, upgrade or pacman transaction was made.

## What the battery is

`plans/round-64-controls.sh [TREE]` / `--selftest`, same shape as
`plans/round-63-controls.sh`: per-control lines
`CONTROL <id> expect=<…> observed=<…> verdict=match|mismatch|skip`, a
`CONTROLS: match=N mismatch=M` summary, exit 0 iff mismatch=0, 1 on mismatch,
2 SETUP. `TREE` defaults to this script's lane.

| control | instrument | expectation | reads `mismatch` when |
|---|---|---|---|
| `C1-F9` | printer-stub copy of `plans/round-64-c1.sh` (`mk_stub_counter`: byte copy + a dispatch after the shebang printing the constant `C1_HELDOUT: heldout=0 population=8 guard=1 …`, exit 0) | the stub's constant line against the independently expected BASE `heldout=8` | the stub line differs from BASE (a printer stub is refused) |
| `C2-F7` | constant-verdict copy of `plans/round-64-c2.sh` (constant `C2_REFUSAL: killed=5 population=5 guard=1 … terminates=1 bound=1`, exit 0) | the stub line against the expected BASE `terminates=0`, `killed=0` | the stub line differs from BASE |
| `C2-BOUND` | the real counter: `C2_RECURSION_BOUND=0 timeout 240 bash <tree>/plans/round-64-c2.sh --tree <tree>` | **no** `C2_REFUSAL:` line (no termination) | any verdict line appears under bound=0 — a printed line is a termination whatever its own `terminates=` field says |
| `C1-NOWORK` | unmutated `plans/round-64-c1.sh <tree>` (one run, shared) | `heldout=8 population=8` | the reading moved |
| `C2-NOWORK` | unmutated `plans/round-64-c2.sh <tree>` (one run, shared) | `terminates=0`, either as a line with `killed=0 population=5 terminates=0` **or** as the frozen BASE non-termination (`rc=124`, no line, §C2 census) | a line with `terminates=1`/`killed>0`, a SETUP line, or a non-124 crash without a line |
| `C1-REAL` | unmutated `plans/round-64-c1.sh <tree>` | verdict line with `guard=1` | no line or `guard=0` |
| `C2-REAL` | unmutated `plans/round-64-c2.sh <tree>` | verdict line with `guard=1` | no line or `guard=0` |
| `PRIOR-<id>` | `<tree>/plans/round-63-controls.sh` on a private snapshot | each CONTROL row re-emitted with its verdict | the prior battery's own verdict was `mismatch` |
| `PRIOR-SELFTEST` | same, only when the prior selftest emits no CONTROL rows | `CONTROLS_SELFTEST: PASS` | the prior selftest failed |

Design points that exist because of measured round-63 defects:

- The two unmutated counter runs happen **once** (`probe_counters`) and are
  parsed into `U1_*`/`U2_*`; the stub controls' `R1_*`/`R2_*` parses cannot
  clobber them (the bug class the round-63 selftest caught).
- Instrument resolution is the round-63 semantics: the measured tree's own
  counter when present, else the lane's (`$R64_CONTROLS_REPO`, default this
  script's repo) — so a pre-freeze BASE tree (which predates the instruments)
  still measures the committed counters. A copy of the script outside
  `<lane>/plans` needs `R64_CONTROLS_REPO` set; without it, the fallback
  resolves to the copy's parent and every instrument row reads `skip`
  (observed once during this seat's work; the run below sets nothing because
  it runs from the lane path).
- `ctrl_prior` picks its delegation mode from the prior battery's bytes:
  `R63_CONTROLS_FIXTURE_ONLY=1 <battery> <snap>` when the branch is present
  (no counter re-entered), otherwise `--selftest` only (the pre-landing full
  battery would hang on the round-63 recursion defect) with a
  `PRIOR-SELFTEST` row when no CONTROL rows come back.
- Probe budgets: `R64_PROBE_TIMEOUT_C1` (default 2400 s) and
  `R64_PROBE_TIMEOUT_C2` (default 1300 s = the frozen `timeout 1200` budget +
  100 s slack); `R64_BOUND_TIMEOUT` (default 240 s) is the refutation leg's
  budget. The selftest shrinks all three on its fixtures.

## Commands and outputs

### 1. Syntax

```
$ bash -n plans/round-64-controls.sh
(no output; rc=0)
```

### 2. Selftest (fixture-driven; no lane instruments, no bao)

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-64-controls.sh --selftest
CONTROLS_SELFTEST: PASS (cases=36)
rc=0
```

Case families (a failing case prints `FINDING R64C-CTL-ST-<case>` and the
selftest exits 1):

- parser units on the two frozen line shapes: `c1-parse-base`, `c1-parse-stub`,
  `c2-parse-base`, `c2-parse-stub`;
- stub builder: `stub-build-ok`, `stub-refuses-no-shebang`;
- stub-vs-BASE line difference: `c1-stub-mismatch-base`, `c2-stub-mismatch-base`;
- report counting / exit contract: `report-counting`, `report-exit-contract`;
- end-to-end fixture trees, each run as a subprocess:
  - `fixture-base` (BASE-census counters): `C1-F9`/`C2-F7`/`C2-BOUND`
    `mismatch`, both NOWORK and both REAL `match`, PRIOR rows re-emitted,
    summary `match=5 mismatch=4`, rc=1;
  - `fixture-cand` (target-line counters): both NOWORK `mismatch`, both REAL
    `match`, `C2-BOUND` `mismatch`;
  - `fixture-empty` (no counters): the seven round-64 controls `skip`, PRIOR
    still runs, rc=0;
  - `fixture-bound` (counter sleeps under bound=0): `C2-BOUND` `match`,
    `C2-NOWORK` `mismatch`;
  - `fixture-decorative` (acceptance pattern: BASE census at the default bound,
    terminates under bound=0): `C1-F9`/`C2-F7`/`C2-BOUND` `mismatch`, both
    NOWORK `match`, rc=1;
  - `fixture-hang` (C2 counter never terminates): `C2-NOWORK` `match` with
    `observed=no-verdict-line;rc=124`, `C2-REAL` `mismatch`.

### 3. Acceptance-pattern tree run (fixture counters, decorative bound)

Tree `/fast/scratch/hyaku/kagi-r64/R64ExecControls/fixaccept`: fixture
`plans/round-64-c1.sh` prints `C1_HELDOUT: heldout=8 population=8 guard=1` rc 1;
fixture `plans/round-64-c2.sh` prints `C2_REFUSAL: killed=0 population=5
guard=1 … terminates=0 bound=1` rc 0 **also under `C2_RECURSION_BOUND=0`** (the
decorative bound `C2-BOUND` must catch); the BASE `plans/round-63-controls.sh`
is copied in.

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku R64_BOUND_TIMEOUT=5 \
    bash plans/round-64-controls.sh fixaccept       # rc=1
CONTROL C1-F9 expect=heldout=8 mismatch observed=heldout=0 population=8 verdict=mismatch
CONTROL C2-F7 expect=terminates=0 mismatch observed=terminates=1 killed=5 population=5 verdict=mismatch
CONTROL C2-BOUND expect=nontermination-bound=0 mismatch-if-terminates observed=verdict-line;terminates=0;rc=0 verdict=mismatch
CONTROL C1-NOWORK expect=heldout=8 population=8 observed=heldout=8 population=8 rc=1 verdict=match
CONTROL C2-NOWORK expect=killed=0 population=5 terminates=0 observed=killed=0 population=5 terminates=0 rc=0 verdict=match
CONTROL C1-REAL expect=verdict-line;guard=1 observed=guard=1 heldout=8 rc=1 verdict=match
CONTROL C2-REAL expect=verdict-line;guard=1 observed=guard=1 killed=0 rc=0 verdict=match
CONTROL PRIOR-SELFTEST expect=CONTROLS_SELFTEST: PASS observed=pass;mode=selftest;rc=0 verdict=match
SKIPS: 0
CONTROLS: match=5 mismatch=3
```

Full output `fixture-accept.out`; receipt body `fixture-accept.txt`.
This is the acceptance pattern in one tree: `C1-F9`/`C2-F7`/`C2-BOUND` all
`mismatch` while both no-work controls read `match`.

### 4. BASE-behaviour tree run with a real bound (refutation does not fire)

Tree `fixbase`: the same fixture counters, but the C2 fixture sleeps under
`C2_RECURSION_BOUND=0` (the bound is load-bearing).

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku R64_BOUND_TIMEOUT=5 \
    bash plans/round-64-controls.sh fixbase         # rc=1
CONTROL C1-F9 … verdict=mismatch
CONTROL C2-F7 … verdict=mismatch
CONTROL C2-BOUND expect=nontermination-bound=0 mismatch-if-terminates observed=no-verdict-line;rc=124;timeout=5s verdict=match
CONTROL C1-NOWORK … verdict=match
CONTROL C2-NOWORK … verdict=match
CONTROL C1-REAL … observed=guard=0 heldout=8 rc=1 verdict=mismatch
CONTROL C2-REAL … observed=guard=0 killed=0 rc=1 verdict=mismatch
CONTROLS: match=4 mismatch=4
```

The two REAL rows mismatch honestly: a BASE-behaviour counter carries
`guard=0`. Full output `fixture-run.out`; receipt body `fixture-run.txt`.

### 5. Printer-stub tree run (all three refusal controls fire together)

Tree `fixstub`: both fixture counters print the **candidate-success** lines and
exit 0 (a printer stub).

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku R64_BOUND_TIMEOUT=5 \
    bash plans/round-64-controls.sh fixstub         # rc=1
CONTROL C1-F9 … verdict=mismatch
CONTROL C2-F7 … verdict=mismatch
CONTROL C2-BOUND … verdict=mismatch            (the stub terminates under bound=0)
CONTROL C1-NOWORK observed=heldout=0 … verdict=mismatch
CONTROL C2-NOWORK observed=killed=5 … terminates=1 … verdict=mismatch
CONTROL C1-REAL observed=guard=1 … verdict=match
CONTROL C2-REAL observed=guard=1 … verdict=match
CONTROLS: match=3 mismatch=5
```

Full output `stub-run.out`; receipt body `stub-run.txt`.

### 6. BASE tree run (claim BASE 09cbee8, slim extraction)

```
$ git -C kagi-shokunin archive 09cbee831d57be7c4edfbe77bf238f46bf729047 \
    plans LOG.md SKILL.md corpus/lessons/round-60.md .ufo/waves/round-60/w1-results.json \
  | tar -x -C /fast/scratch/hyaku/kagi-r64/R64ExecControls/basetree
$ HYAKU_SCRATCH=/fast/scratch/hyaku R64_BOUND_TIMEOUT=240 \
    bash plans/round-64-controls.sh basetree
```

Measured counter sha256 at this run (`counters.sha256`):

```
C1  e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484  plans/round-64-c1.sh
C2  e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b  plans/round-64-c2.sh
```

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku R64_BOUND_TIMEOUT=240 \
    bash plans/round-64-controls.sh basetree      # rc=1, 1992 s wall
# round-64 pre-freeze control battery (plans/round-64-controls.sh)
# SELF e37d497dc6bf56e02b26d8fec8ed24cf66d252968287302b74267ef158d8a678
# utc 2026-11-08T07:11:43Z
# repo /home/vgpnk/Projects/shokunin/kagi-shokunin
# candidate /fast/scratch/hyaku/kagi-r64/R64ExecControls/basetree
# instrument-c1 /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-64-c1.sh
# instrument-c2 /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-64-c2.sh
INSTRUMENT plans/round-64-c1.sh MISSING   (the BASE tree predates the instruments: lane fallback)
INSTRUMENT plans/round-64-c2.sh MISSING
INSTRUMENT plans/round-63-controls.sh cb8134ad1ce486d9e5fe6f4397bf3af4ae8fa034c15e565cc1439e90d4b2cb87
CONTROL C1-F9 expect=heldout=8 mismatch observed=heldout=0 population=8 verdict=mismatch
DETAIL C1-F9 stub-constant-line-refused line=C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)
CONTROL C2-F7 expect=terminates=0 mismatch observed=terminates=1 killed=5 population=5 verdict=mismatch
DETAIL C2-F7 stub-constant-line-refused line=C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)
CONTROL C2-BOUND expect=nontermination-bound=0 mismatch-if-terminates observed=no-verdict-line;rc=124;timeout=240s verdict=match
DETAIL C2-BOUND refutation: no verdict line under bound=0 inside timeout 240s
CONTROL C1-NOWORK expect=heldout=8 population=8 observed=heldout=8 population=8 rc=1 verdict=match
DETAIL C1-NOWORK no-work control: BASE census reproduced
CONTROL C2-NOWORK expect=killed=0 population=5 terminates=0 observed=no-verdict-line;rc=124 verdict=match
DETAIL C2-NOWORK no-work control: BASE reading is non-termination (frozen §C2 census: rc=124, 7-byte receipt)
CONTROL C1-REAL expect=verdict-line;guard=1 observed=guard=0 heldout=8 rc=1 verdict=mismatch
DETAIL C1-REAL blanket-refusal-or-no-verdict line=C1_HELDOUT: heldout=8 population=8 guard=0 (real=1 selftest=0 resid=1 stub=1 vehicle=1)
CONTROL C2-REAL expect=verdict-line;guard=1 observed=guard=none killed= rc=124 verdict=mismatch
DETAIL C2-REAL blanket-refusal-or-no-verdict line=none
CONTROL PRIOR-SELFTEST expect=CONTROLS_SELFTEST: PASS observed=pass;mode=selftest;rc=0 verdict=match
DETAIL PRIOR-SELFTEST CONTROLS_SELFTEST: PASS (cases=25)
SKIPS: 0
CONTROLS: match=4 mismatch=4
```

Full output `base-run.out`; receipt body `base-run.txt`.

The four `mismatch` rows are the expected BASE-side readings: the two stub
refusals and the two positive controls (a pre-candidate counter cannot honestly
carry `guard=1` at BASE). The two no-work controls read `match` — `heldout=8`
from the lane's C1 counter and the frozen non-termination from the C2 counter.

**Transient observed and recorded:** an earlier run at 06:33 UTC read
`C1-NOWORK … rc=2` (SETUP, no verdict line) while the C1 seat was still
writing `plans/round-64-c1.sh`; the same bytes (`sha e03a4d69…`) measured
directly right after read `C1_HELDOUT: heldout=8 population=8 guard=0 …` rc 1
(`c1-repro.out` / `c1-repro.err`, 626 s), and the re-run above reads
`heldout=8`. The battery reported the SETUP honestly as a `mismatch` with the
rc and the absent line; no row was softened.


## BASE reading note

At claim BASE `09cbee8` the round-64 counters do not exist in the extracted
tree, so `resolve_instruments` falls back to the lane's committed copies
(`$LANEREPO/plans/round-64-*.sh`) — the pre-freeze semantics inherited from the
round-63 battery. Consequences, restated so no row is over-read:

- `C1-NOWORK`/`C2-NOWORK` measure the **lane's** counters on BASE inputs. The
  expected readings are the frozen BASE census: `heldout=8 population=8` for
  C1, and for C2 either a `terminates=0` line or the frozen non-termination
  (`rc=124`, no line — §C2's "committed receipt is 7 bytes").
- `C1-REAL`/`C2-REAL` need `guard=1`, which a pre-candidate counter cannot
  honestly reach on a BASE tree; on a BASE tree these rows read `mismatch`
  (the positive-control reading belongs to the candidate tree, the L1's run).
- `C2-BOUND` reads `match` only when the bound=0 run actually fails to
  terminate inside 240 s (no verdict line).
- The C1 counter's own run cost on BASE was measured separately at 913 s
  (`c1-direct2.out`, sha `e03a4d69…`), producing
  `C1_HELDOUT: heldout=8 population=8 guard=0 (real=1 selftest=0 resid=1
  stub=1 vehicle=1)` rc 1 — the census the battery's `C1-NOWORK` expects.

## Named ceilings

- A printer stub that prints **exactly** the independently expected BASE line is
  indistinguishable by output alone (`C1-F9`/`C2-F7` would read `match`); the
  refusal here is specific to a stub whose constant line names the target
  reading. Plan ceiling, unchanged.
- `C2-BOUND` proves the bound changes termination behaviour, not that the
  bounded run's five legs fire for the right reasons — that is `C2-NOWORK`'s and
  the C2 counter's own guard legs' job.
- The battery never reads `plans/round-64-heldout.tsv`; it inherits the seal
  discipline from the C1 counter it measures.

## Risks

- `C2-BOUND` costs one 240 s timeout on every real run; the C2 probe costs up to
  1300 s when the counter cannot terminate (BASE) — the L1's pre-freeze run measured
  1992 s at BASE (33 min).
- `ctrl_prior` copies the measured tree (`cp -a`) and runs the prior battery on
  the snapshot; on a full 200 MB tree that copy dominates. Bounded by
  `timeout 600`.
- The prior delegation mode is chosen by grepping the prior battery's bytes for
  the branch name; a prior battery mentioning the name only in a comment would
  be run with the flag set (safe: the flag is additive) — the grep is a mode
  switch, not a safety gate.

SEAT-STATUS: complete
