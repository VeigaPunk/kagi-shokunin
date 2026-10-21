# RevFixtureRun — R23-01 hermetic-cells falsification

Round 23 falsification seat (fixture-run attacker), scoped to C3/D9:
`corpus/fixtures/cells-hermetic/` + `corpus/claim-ledger.tsv:59` (`R23-01`).
READ-ONLY on `/home/vgpnk/Projects/shokunin/kagi-shokunin`; the only lane
write is this file. All mutants were built from copies under `/tmp/r23attack`;
no production file was edited. No installs or updates were performed. No git/jj
mutation, no host gates, no secrets.

Measured tree: `HEAD = d218603b74099ddca0bd8f869516fc41db0979bf` plus the
uncommitted round-23 tree. Working-tree hashes are in §Manifest and were
stable across the whole measurement window (fixture mtimes 2026-10-21
00:51–00:53, before this seat started; sibling `MutFixtureDelete.md` recorded
the same pristine hashes).

## Verdict on the three assigned attacks

| Attack | Result |
|---|---|
| Defaults leaking from the real lane | **Not found.** All four path overrides dominate; a sandbox with poisoned `SCRIPT_DIR` defaults still prints the identical line, and the default-reading control fails. `strace` shows no `$HOME`, no network, no foreign path. |
| `rows_run`/`self_skipped` ambiguity | **Confirmed at gate level** (F1, F2): `rows_run` counts *selected* rows, including substrate-deferred ones, and `SKIP-SELF` is a substring match that can absorb a would-fail row. The shipped R23-01 line is nevertheless a sufficient discriminator because it pins `row_deferred=0` and `self_skipped=0` as well. The note's stated reason ("rows_run/self_skipped pinned so an all-deferred … fixture cannot pass") is causally wrong for the deferred case: `rows_run` stays `2`. |
| Fixture passing with zero real row executions | **Reachable for the gate** (self-skip, defer, PATH shadow — all exit 0 with `CELL_AUDIT: CLEAN`), **not reachable while matching R23-01's ERE** except by hijacking the process environment (`timeout`/`bash` via `PATH`). The shipped fixture really executes both rows (trace below). |

The shipped claim row reproduces exactly. Findings F1–F5 are gate-semantics,
documentation-contract, and provenance findings; none invalidates the deployed
`R23-01` line.

## 1. Exact reproduction (byte-for-byte)

The command was extracted from `corpus/claim-ledger.tsv:59` field 2 and run
verbatim from the lane root (never through `verify`, so no other row ran):

```
CMD=$(awk -F'\t' 'NR==59{print $2}' corpus/claim-ledger.tsv)
bash -c "$CMD"
```

`bash -c` exit **0**, elapsed **35 ms** (row timeout is 60 s), stderr **0
bytes**, stdout exactly one line:

```
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
```

Byte comparison against field 3 (`^…$` anchors stripped, `\(`/`\)` unescaped
to literals): expected and actual are **equal, 164 characters each**
(`BYTE_EQUAL: True`). The gate's own rule (`[[ $last =~ $expect ]]`,
`corpus/claim-ledger.sh:441-443`) also matches. A final re-run after the
manifest hashes were taken produced the identical line and exit 0.

## 2. The two rows really execute

`bash -x` trace (`/tmp/r23_fx_x.trace`, 3,082 lines) shows both selected rows
as real child processes, each after a `cd` into the fixture root:

```
2911:++ cd corpus/fixtures/cells-hermetic
2913:++ timeout -k 5 10 bash -o pipefail -c 'bash corpus/fx-ok.sh'
3010:++ cd corpus/fixtures/cells-hermetic
3012:++ timeout -k 5 10 bash -o pipefail -c 'grep -cE '\''^# no-enumerate[[:space:]]+.HOME/'\'' corpus/adjacency.tsv'
```

Mechanism: `corpus/claim-ledger.sh:426` (`out=$(cd "$ROOT" && …)`), `:427`
(`timeout -k 5 "$tmo" bash -o pipefail -c "$cmd"`), last-line rule `:436`,
verdict rule `:442`. `rows_run` is assigned from `C_N` at `:828`.

So for *this* fixture `rows_run=2` is two executions. It is not that in general
(F1).

## 3. Hermeticity / default-leak attack — no leak found

All commands below were run from the lane root unless stated; each printed the
same CLEAN line and exit 0.

1. **Syscall trace.** `strace -f -e trace=openat,connect` over the exact
   command: 639 trace lines, **0 `connect()` calls**. No `/home/vgpnk` path
   appears at all — neither inside nor outside the repo — and no
   `.local`/`.config`/`.agents`/`the-janitor` access. The unique non-library
   open set is the gate script, the fixture files (relative, under the fixture
   cwd), `/dev/null`, `/dev/fd/*`, and one `/tmp/tmp.*` (the gate's
   `mktemp`). Write-mode opens target `/dev/null` only (`O_WRONLY|O_CREAT`),
   plus the `/tmp` temp; no repo path is opened for write.
2. **Environment override.** Identical line/exit with
   `HOME=/nonexistent`; with `KAGI_SUBSTRATE=absent`; with
   `KAGI_SUBSTRATE=present`; and with `PATH=/usr/bin:/bin HOME=/nonexistent`.
   `CLAIM_LEDGER_DEPTH=0|1|5` likewise unchanged.
3. **Override dominance (poisoned defaults).** Copied
   `claim-ledger.sh` and the fixture to `/tmp/r23attack/leak`, then poisoned
   the *default* files beside the copied script:
   `corpus/claim-ledger.tsv` = one failing row `R00-01`, `corpus/stamps.tsv` =
   bogus `poison.txt deadbeef 0 0`, `corpus/SCORECARD.md` = junk. Running the
   exact relative command from the copy root still produced the identical
   CLEAN line, exit 0. **All four overrides (`--root`, `--claims`, `--stamps`,
   `--scorecard`/`--docs`) are load-bearing and no default leaks through.**
4. **Control: defaults are the script-relative ones.** Same sandbox, omitting
   `--claims`/`--stamps`: the poisoned defaults are read, yielding six
   `MISSING-ID SCORECARD.md:7-12` lines and
   `claim-ledger: no cell in … cites a claim row …` (die at
   `corpus/claim-ledger.sh:790`), exit **2**.
5. **Root binding.** Fixture claims/stamps/scorecard/docs supplied as
   absolute paths but with the default root (the real lane): exit **1**,
   `FAIL R90-01 reason=exit-mismatch exit=127 want=0`,
   `STALE-POINTER corpus/adjacency.tsv sha=c17f7e17ff89->4d9bfb1145aa
   lines=9->83 bytes=307->5660`, `CELL_AUDIT: BROKEN … row_failures=1
   stale_pointers=1`. A root mix-up fails loudly; it cannot pass.
6. **CWD coupling (bound).** The row uses a relative `--root`. Run from `/tmp`
   it exits **2**, `claim-ledger: root is not a dir:
   corpus/fixtures/cells-hermetic`. It is safe only because the ledger runs
   every row with `cwd=$ROOT` (`corpus/claim-ledger.sh:426`); direct invocation
   from another directory is not portable.

## 4. Zero-real-execution attack

Mutants are copies of the fixture under `/tmp/r23attack/`; the detector is the
row's own rule (exit equality + last non-empty line vs R23-01's ERE, applied
with `bash -c '[[ $1 =~ $2 ]]'`).

| Mutant | Gate exit | Last line | Matches R23-01 ERE |
|---|---|---|---|
| shipped fixture | 0 | `rows_run=2 row_deferred=0 … self_skipped=0` | **yes** |
| both rows `bash corpus/claim-ledger.sh --selftest` (self-skip) | 0 | `rows_run=0 … self_skipped=2` | no |
| both rows note-tagged `[substrate]`, `KAGI_SUBSTRATE=absent` (defer) | 0 | `rows_run=2 row_deferred=2 … self_skipped=0` | no |
| rows `bash corpus/fx-ok.sh claim-ledger.sh` (false-skip) | 0 | `rows_run=0 … self_skipped=2` | no |
| `timeout` shim first in `PATH` | 0 | exact clean line | **yes, with zero real executions** |

- **Self-skip:** both cited rows become `SKIP-SELF` (gate `:816-819`); the gate
  prints `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 … rows_run=0 …
  self_skipped=2 …)`, exit 0. The ledger line rejects it.
- **Defer:** both rows DEFER (`:416-419`); the gate prints `CLEAN …
  rows_run=2 row_deferred=2 …`, exit 0 with **zero executions**. The ledger
  line rejects it via `row_deferred`, not via `rows_run`.
- **False-skip (F2):** two ordinary commands that merely *mention*
  `claim-ledger.sh` as an inert argument. Row 2 would fail if run (prints
  `FX: OK`, expects `^8$`), yet it is never run: both are reported
  `SKIP-SELF`, `CLEAN … rows_run=0 … self_skipped=2`, exit 0. The substring
  test at `:816` is `${TF[1]:-} == *claim-ledger.sh*`, not an invocation
  check, so a red row can be laundered into the skip count. **Control:** the
  same two commands with a non-matching token (`claim-ledgerXsh`) execute and
  yield `FAIL R90-02 reason=verdict-not-final exit=0`, gate exit **1**,
  `BROKEN … row_failures=1`; the row's failure is real, not hypothetical.
- **PATH shadow (environment trust, residual):** a fake `timeout` placed first
  in `PATH` fabricates each row's expected last line (`FX: OK`, `8`) and exits
  0. The gate prints the **exact** R23-01 line with **zero fixture command
  executions**. This is not fixture-specific — every one of the 45 rows is
  launched through bare `timeout`/`bash` at `:427` — but it shows that
  "host-free" here means no `$HOME`/network/foreign files, not a sanitized
  process environment.

Conclusion: for fixture-level mutations, the exact line is a genuine execution
witness (defer and skip change pinned fields; policy refusal exits 2 before
CLEAN). The only way to satisfy the exact line without executing is to own the
environment, which the ledger row cannot defend against.

## 5. Findings

### F1 (Medium) — `rows_run` counts deferred rows; the note's discriminator is wrong

`C_N` is incremented at `corpus/claim-ledger.sh:415`, **before** the substrate
defer branch at `:416-419`; `CL_ROWS_RUN=$C_N` at `:828`. Executed defer mutant
proves the consequence: `CLEAN … rows_run=2 row_deferred=2 …`, exit 0, with
zero command executions. The `R23-01` note (`corpus/claim-ledger.tsv:59`) says
"Exact rows_run/self_skipped pinned so an all-deferred or self-skipped fixture
cannot pass." For the deferred case that is false as stated — `rows_run` stays
`2` and `self_skipped` stays `0`; the field that rejects the mutant is
`row_deferred`, which the note does not name. The shipped line is still safe
(`row_deferred=0`, and both rows executed), and the live cell
`SCORECARD.md:841` quotes `rows_run=2 row_deferred=0 self_skipped=0` accurately,
but "rows_run" reads as executions to a reviewer and does not mean that.

### F2 (Medium) — `SKIP-SELF` is a substring match, not an invocation check

`corpus/claim-ledger.sh:816` skips any cited row whose command *contains*
`claim-ledger.sh`, even as an unused argument. Executed false-skip mutant: rows
`bash corpus/fx-ok.sh claim-ledger.sh`; row 2 is a would-fail row (output
`FX: OK` vs expected `^8$`) but is never executed and disappears into
`self_skipped=2`; gate exit 0. Control with the same commands and the token
changed to `claim-ledgerXsh`: row 2 runs and produces `FAIL R90-02
reason=verdict-not-final exit=0`, gate exit 1, `row_failures=1` — the failure
the shipped test hides is real. The lesson's stated bound
(`corpus/lessons/round-23.md:123-126`) describes rows that "re-invoke the
gate"; the implemented condition is broader, so the count is not a reliable
description of *why* a row was skipped. `R23-01` is unaffected because its line
pins `self_skipped=0`, and the shipped fixture cites no gate-invoking row.

### F3 (Low-Medium) — documented fixture contract does not match the shipped fixture

`corpus/lessons/round-23.md:151-153` says "a four-file fixture: a six-axis
scorecard …, a claims file whose one row runs a local script, an empty-but-valid
stamps file, and `corpus/fx-ok.sh`". Actual:

- **five** files: `SCORECARD.md`, `claims.tsv`, `stamps.tsv`,
  `corpus/fx-ok.sh`, `corpus/adjacency.tsv`;
- `claims.tsv` has **two** rows (`R90-01` script, `R90-02` grep count);
- `stamps.tsv` has **two** rows (`fx-ok.sh`, `adjacency.tsv`), not empty.

`LOG.md:1203` repeats "(4 files)", and `corpus/claim-ledger.tsv:59` says "one
local script row" while eliding `R90-02`. A reviewer following the lesson
contract would copy the wrong shape. The falsify-wave instruction attached to
the same section ("mutated (uncited cell, bad row id, failing row) and must
fail") is accurate — see §6.

### F4 (Low) — "committed fixture" is not true in the measured tree, and the fixture has no lane-level revision pin

`corpus/lessons/round-23.md:62,121`, `LOG.md:1199` and `SCORECARD.md:841` call
the fixture "committed". Measured: `git ls-files corpus/fixtures` = **0**;
`git status --short` = `?? corpus/fixtures/`; `HEAD` is `d218603` (round 22).
The fixture is untracked in this working tree, so "committed" is a prospective
statement, not a verifiable one. `corpus/stamps.tsv` contains **no** fixture
path (its only `corpus/adjacency.tsv` row is the live file: 83 lines / 5660
bytes), so no lane-level revision pin covers the fixture either. Only R23-01's
counters constrain it — and they do not pin content: replacing `fx-ok.sh` with
different bytes that print the same text (sha `aa5245d1…` vs stamped
`29f98fba…`) leaves the exact CLEAN line and exit 0 (F5). Fixture provenance is
unverifiable until it is committed and/or pinned.

### F5 (Low) — the `fx-ok.sh` stamp row is inert for this run

`corpus/fixtures/cells-hermetic/stamps.tsv:1` pins `corpus/fx-ok.sh`, but no
scorecard cell cites that path (the operability/calibration cells cite
`R90-01` only, `SCORECARD.md:9,11`), and `cells_evidence` re-compares only
paths collected from cells (`corpus/claim-ledger.sh:831-846`). Executed mutant:
`fx-ok.sh` rewritten to `#!/bin/sh` + `printf '%s\n' 'FX: OK'` (sha changes
`29f98fba…` → `aa5245d1…`; the stamp is now stale) — gate output is the
identical CLEAN line, exit 0, `stamp_pointed=1` (adjacency only). `R90-01` is
still behavior-tested by its verdict line, so this is inert *revision*
evidence, not an unexecuted row. Anyone reading `stamp_pointed=1` should not
infer both fixture artifacts are pinned.

## 6. Negative results — mutations the row correctly rejects

Each mutant was a `/tmp` copy; the command was R23-01 with `--root` and the
four file paths pointed at the copy. All six exit **1**, and none matches the
R23-01 ERE.

| Mutation | Exit | Verdict detail |
|---|---|---|
| freshness cell evidence → `—` (uncited) | 1 | `BROKEN … uncited=1` |
| cell id `R90-02` → `R90-99` | 1 | `BROKEN … missing_ids=1` |
| `R90-01` expected `^FX: OK$` → `^FX: NOPE$` | 1 | `BROKEN … row_failures=1` |
| `fx-ok.sh` prints `FX: OK` then `exit 3` | 1 | `BROKEN … row_failures=1` |
| `adjacency.tsv` + 1 line (stale path pointer) | 1 | `BROKEN … stale_pointers=1` |
| both rows `[substrate]`, substrate absent | 0 | `CLEAN rows_run=2 row_deferred=2` — ledger ERE rejects (F1) |

The deletion-mutant family is independently covered by
`.ufo/waves/round-23/falsify/MutFixtureDelete.md`; this seat's pristine hashes
agree with that report.

## 7. Residual risk and verification gaps

- **Environment trust.** PATH-shadowing `timeout` reproduces the exact line
  with zero executions. Applies to all 45 rows (`:427`), not just C3; outside
  the fixture's control. Not counted as a C3 defect, but it bounds any claim
  that `rows_run=2` proves work happened.
- **Unpinned fixture inputs.** `claims.tsv`, `SCORECARD.md` and `stamps.tsv`
  are not hashed by anything in the lane. A counter-preserving edit (e.g.
  changing `R90-02`'s source while keeping a matching count) would pass. I
  demonstrated the weaker content-preserving case via `fx-ok.sh` (F5), not a
  full command swap.
- **Untested.** Gate `--selftest` case counts (13/59) belong to other seats;
  the parent's 43 rows and live-lane `cells` (host-bound rows) were not run per
  contract. I did not execute a renamed-copy-of-the-gate row (evades the
  textual self-skip test and would recurse until timeout); the recursion is
  timeout-bounded but was not measured. No symlink/TOCTOU race was attempted.
- **Point-in-time.** All results are for the working-tree hashes in §8. The
  exact command was re-run after hashing and still matched. Scratch remains in
  `/tmp/r23attack`, `/tmp/r23shim`, `/tmp/r23_*`; no lane file was written
  except this report.

## 8. Manifest (sha256 at measurement)

```
c20c2d04a354b54b42cf66d2d70081a581c873f139686b0c04ee8ae02e3a3b93  corpus/claim-ledger.sh
6fa0c24fc696e82b24d3d79ad0667c58faeb02b12aa2ad4b8ef7074fe720ee0b  corpus/claim-ledger.tsv
1674d112af479ffdaa14368a8a1102a3ea62057f36534e98e5817831872e3ac4  corpus/fixtures/cells-hermetic/claims.tsv
b521142b712e6329e7c14423ab14492e826e36875c0986210ff72716ee824121  corpus/fixtures/cells-hermetic/stamps.tsv
04b915601d019540bb54a895dc381702b1d743d6955f321e9f2923287cc2640e  corpus/fixtures/cells-hermetic/SCORECARD.md
29f98fbaaa2412f5544523eaa7af24c62d5f119c75f88af7ef12b757ec4da614  corpus/fixtures/cells-hermetic/corpus/fx-ok.sh
c17f7e17ff89f25518a3277331122b433d600b0eac7c1a6a74dacf5fea133843  corpus/fixtures/cells-hermetic/corpus/adjacency.tsv
```

## 9. Bottom line for the integrator

- `R23-01` is reproducible exactly: exit 0, one line, 164/164 bytes, 35 ms,
  stderr empty; both rows execute in the fixture root.
- The fixture-boundary claim holds where it matters: no real-lane default,
  `$HOME`, network, or substrate probe is reachable under the command, and a
  root substitution fails loudly.
- Do not cite `rows_run` alone as "rows executed" (F1), do not read
  `self_skipped` as "the row re-invokes the gate" (F2), and fix the lesson/LOG
  fixture description and "committed" wording before the round is claimed as
  provenance (F3/F4). The `fx-ok.sh` stamp is inert as revision evidence (F5).
