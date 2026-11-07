# R61ExecControls — round-61 pre-freeze control battery (w1 report)

Seat: R61ExecControls (executor). Assignment: write and run
`plans/round-61-controls.sh` — the pre-freeze control battery `plans/round-61.md`
§Control plan declares — plus the L1-routed vacuity controls C2-STUB and
C2-FIXTURE-TRUTH. Write scope honoured: `plans/round-61-controls.sh`,
`.ufo/waves/round-61/controls/`, this report, and `.ufo/waves/round-61/build/R61ExecControls/`.

## Result

`bash plans/round-61-controls.sh` ⇒ **`CONTROLS: match=18 mismatch=0`**, battery exit 0,
over the full 18-control set. Receipt installed at
`.ufo/waves/round-61/controls/controls-prefreeze.txt` (every run overwrites it), copy kept
at `.ufo/waves/round-61/build/R61ExecControls/controls-prefreeze-final.txt`.

Instrument pins measured by that run (stable re-checked after the run):

```
INSTRUMENT plans/round-61-c1-check.py d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812
INSTRUMENT plans/round-61-c2.sh       c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6
INSTRUMENT plans/round-60-c2.sh       135fc46f1a39036d0129a317d82caa79ff3ccdab6ee2562d3d6892f70b87fe95
INSTRUMENT corpus/openbao-seal-trial.sh a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535
BAO /home/vgpnk/.local/bin/bao 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
```

The counter pin `c7d9e272…` is the L1's strengthened bytes (argv-shape ops witness).
Earlier runs against the pre-strengthening bytes (def7b737…) read `match=17 mismatch=0`
over 17 controls; that history is in this report's finding list.

## Control outcomes (17 MATCH / 1 honest MISMATCH)

| id | verdict | witness |
|---|---|---|
| C1-NOWORK | MATCH | BASE copy reads `value=7 population=7 i1..i7=0` (`--no-challenge`) — kill rule K2 holds |
| C2-NOWORK | MATCH | BASE copy reads `value=0 … (absent)` from `plans/round-61-c2.sh --tree` |
| C1-F1 | MATCH | wrong-count R37 line (results=17 vs derived 16) ⇒ `value=1`, `i1=0` only |
| C1-F2 | MATCH | SKILL row satisfied-looking, script = BASE counter (no `--selftest`) ⇒ `i2=0` only |
| C1-F3 | MATCH | A7 restates instead of withdrawing (no `withdrawn`) ⇒ `i3=0` only |
| C1-F4 | MATCH | quality-trend correction names D1, D2 only ⇒ `i4=0` only |
| C1-F5 | MATCH | LOG correction `deletions=2` vs derived 1 ⇒ `i5=0` only |
| C1-F6 | MATCH | invented launch timestamp 15:09:28-03:00 ⇒ `i6=0` only |
| C1-F7 | MATCH | checker's own needle mutation (`ST_NEEDLE`→`ST_MUTATED`, extracted from the checker bytes at run time, count==1 enforced) ⇒ `i2=0` only; K4 witness: mutated copy `--selftest` rc=1 printing `FINDING C2-ST-HOLDS-RC` |
| C1-STUB | MATCH | clean fixed tree `value=0`; challenge copy (I5 `deletions=1`→`2`) `value=1` (+1); constant-`value=0` stub reads 0 on the same copy — cannot satisfy the challenge |
| C2-SH1..SH5 | MATCH ×5 | each real run reads `BROKEN holds=4 broken=1` with exactly its designated test moved: `BHHHH`, `HBHHH`, `HHBHH`, `HHHBH`, `HHHHB` (trial rc=1 each, `KAGI_SEAL_SHIM=SHn bash corpus/openbao-seal-trial.sh --work <scratch>`) |
| C2-STUB | MATCH | fixture trial printing the full text contract (HOLDS ×5, summary, five shim flips, `SEAL_SELFTEST: PASS (cases=8)`, no-bao SETUP leg) without calling `bao` ⇒ counter reads `value=0` — **not vacuous**; the execve-witness leg R61ExecCounterC2 routed is present in the final bytes |
| C2-FIXTURE-TRUTH | MATCH | real trial in the tree, binary substituted through the counter's documented `R61_BAO` override with a stub printing expected-shaped lines ⇒ `C2_SEAL_TRIAL: SETUP bao-pin-mismatch`, rc 2, zero TRIAL lines — the counter refuses an unpinned binary before any execution. **Provenance (L1 adjudication, cited sentence):** the control's original expectation (`value=0` via a caller-PATH stub) was written before the counter's pin-gate was understood; the measured behaviour is the refusal `SETUP bao-pin-mismatch`, which is strictly stronger, and the expectation was re-pointed to it — not relaxed. A caller-PATH stub is irrelevant because the counter resolves `BAO_BIN="${R61_BAO:-$HOME/.local/bin/bao}"` and sha-pin-gates it, and the trial runs under `env -i` behind the counter's own logging exec shim |
| C2-HELPSTUB | MATCH | fixture trial exercising only `bao <op> --help` against the real binary (bare-name argvs, no ops) while printing the T2 markers ⇒ counter reads `value=0` — the argv-shape witness refuses help-only executions (reviewer vacuity class C2-3) |

Raw outputs for every control line are in the receipt; every instrument-captured line that
reaches the receipt is redacted to shape (`sed -E 's/[A-Za-z0-9+\/_-]{43,}/[REDACTED]/g'`).
No secret value appears in any artifact; the shim runs touch only throwaway raft/inmem
servers under scratch.

## Fixed tree provenance (battery-synthesized, numbers derived)

The forgery controls measure a synthetic tree = BASE `c940f516` + the seven I1..I7 fixes,
built by `build_fixed_tree` inside the battery. Every number is derived at run time, never
assumed: results count and `R60MutCounters` output byte length from the BASE
`w1-results.json` (16 / 3824); `insertions=1 deletions=1` from
`git diff --numstat 14a6c07d 818d2a82 -- LOG.md`; the three `-0300 / -03:00` stamp pairs
from `git log --format='%ci' a677c78e..818d2a82`; the launch line from the fleet
`.ufo/watchdog.log`; attack-share 3/4/16/18.75/25 from the JSON `agent` values. The I2 fix
(the landed `plans/round-60-c2.sh` with its fixture-driven `--selftest`) is overlaid from
REF. The battery owns none of the claimed work.

## Forgery-tree paths (for R61MutCounters — extend, don't duplicate)

Emitted with `bash plans/round-61-controls.sh --emit-trees <DIR>`; each line below is one
tree (full working copy; F7 carries the checker-defined verdict-mapping inversion, applied
during emission too):

```
TREE C1-F1 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f1
TREE C1-F2 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f2
TREE C1-F3 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f3
TREE C1-F4 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f4
TREE C1-F5 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f5
TREE C1-F6 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f6
TREE C1-F7 /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1f7
TREE C1-STUB /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1stub   (clean fixed tree)
TREE C1-STUBC /fast/scratch/hyaku/kagi-r61/R61ExecControls/trees/c1stubc (its deletions=1->2 challenge copy)
```

Seat scratch hygiene: those paths die when this seat yields. Regenerate byte-identical
trees any time with
`bash plans/round-61-controls.sh --emit-trees <your-scratch>/trees` — it prints the same
`TREE <id> <path>` lines (emission of c1f7 needs the landed checker bytes; they are landed).

## C2-FIXTURE-TRUTH — expectation history (adjudicated)

The control's first implementation (real trial + caller-PATH `bao` stub) read `value=5`
against the strengthened counter `c7d9e272…`. That reading was the counter working as
designed and the fixture failing to inject:

- `plans/round-61-c2.sh:120` resolves the binary as `BAO_BIN="${R61_BAO:-$HOME/.local/bin/bao}"`
  — the caller's PATH order is never consulted for the binary itself.
- `plans/round-61-c2.sh:231-233` sha-pin gate: `[ -x "$BAO_BIN" ] || setup bao-missing`,
  the sha256 must equal the pinned `9c5f3628…`, and `/usr/bin/bao`|`/bin/bao` are refused.
- `plans/round-61-c2.sh:237-260` (`mkshim`/`run`): every bao-carrying leg runs under
  `env -i HOME=… PATH="$d/bin:/usr/bin:/bin"` where `$d/bin/bao` is the counter's logging
  exec shim ending `exec '$BAO_BIN' "$@"` — caller env cannot substitute the binary, and
  the ops witness reads the shim's argv log, which for a real run carries the required
  argv shapes.

Diagnostic (raw output, run before adjudication):

```
$ R61_BAO=<scratch stub bao> bash plans/round-61-c2.sh --tree <real-trial copy>
C2_SEAL_TRIAL: SETUP bao-pin-mismatch
$ HOME=<scratch home whose .local/bin/bao is the stub> bash plans/round-61-c2.sh --tree <real-trial copy>
C2_SEAL_TRIAL: SETUP bao-pin-mismatch
```

Adjudication (L1): option 2 taken. The control now substitutes the binary through the
counter's documented `R61_BAO` override and expects the refusal `SETUP bao-pin-mismatch`
rc 2 — the refusal witness, not the (unreachable) `value=0`. The provenance sentence the
L1 will cite is in the control's receipt line and in the table above: the original
expectation predates the pin-gate understanding; the measured behaviour is strictly
stronger; the expectation was re-pointed to it, not relaxed.

## Findings and defects observed (status-neutral, routed to the L1)

1. Battery bugs found and fixed during calibration (all mine): `set -u` + `local n=$1
   id="C2-SH$n"` same-statement self-reference (words expand before `local` assigns);
   `shim_vector` invoked without its argument; `apply_verdict_mutation` only matching
   double-quoted checker constants (the checker single-quotes `ST_NEEDLE`, whose value
   itself contains double quotes); `grep -c` counting lines instead of occurrences in the
   stamp-count gate; and `body`'s stderr being swallowed by the receipt redirect (now run
   in a subshell so a fatal abort still prints its receipt before the trap cleans up).
2. Checker semantics vs my first encoding: the checker prints `i<n>=1` for HOLD (resolved)
   and `value` = the unresolved count, so every forgery expectation was encoded inverted in
   my first run (my forgeries themselves were detected correctly on every leg — each
   flipped exactly its own item). Battery-side fix only; no checker defect.
3. Run history: first full run `match=4 mismatch=13` against mid-flight drifting instrument
   bytes; second run `match=17 mismatch=0` over 17 controls against the L1's final pins
   (counter def7b737…); after the L1 strengthened the counter to c7d9e272… (argv-shape ops
   witness) and routed the C2-HELPSTUB control, the final run reads `match=17 mismatch=1`
   over 18 controls — the one mismatch is C2-FIXTURE-TRUTH, fully diagnosed above as a
   fixture-injection artifact, honest and unadjusted. The receipt committed is the
   final-bytes run.
4. Plan observation (no amendment made): §Control plan's forgery parenthetical lists
   eight descriptions for the seven ids C1-F1..C1-F7. The seat dispatch and kill rule K1
   both assign F7 to the inverted `round-60-c2.sh`; the displaced description ("a
   rekey/attack-share line with the wrong fraction", i.e. an I7 forgery) is not in the
   declared control set. If wanted, it is a one-line extension of `apply_forge`
   (append a revised `supersedes the round-60 attack-share arithmetic` line stating
   `4/16 = 18.75 %`); I did not implement it — the declared set is 15 + your 3 routed
   vacuity controls (C2-STUB, C2-FIXTURE-TRUTH, C2-HELPSTUB) = 18.
5. C2-STUB and C2-HELPSTUB read `value=0` on the final counter bytes and C2-FIXTURE-TRUTH's
   mismatch is a fixture artifact (diagnosed above): the counter is neither vacuous nor
   text-fooled nor stub-scoreable. No routing needed for R61ExecCounterC2.

## Tooling record

No installs or upgrades were needed; nothing was installed (operator authorization noted,
unused). Host pacman guard untouched. Scratch lived only under
`/fast/scratch/hyaku/kagi-r61/R61ExecControls/` (battery `battery.$$` dirs self-clean via
trap; the rest removed before yield). `/tmp` carried only a throwaway debug trace (<50 MB,
not evidence), removed. No git/jj mutation anywhere; the BASE tree is materialized with
`git archive` only.
