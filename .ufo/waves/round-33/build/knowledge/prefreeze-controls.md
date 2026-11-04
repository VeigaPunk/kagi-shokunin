# Pre-freeze BASE controls — declared values are measured, never estimated

Source basis: written 2026-11-04 (round 33) from the shipped gate itself —
`corpus/prefreeze-control.sh` (stamped in `corpus/stamps.tsv`), the two frozen controls
files `plans/round-33.controls.tsv` and `plans/round-32.controls.tsv`, and the runs quoted
below. The motivating defect is round 32's: `plans/round-32.md` froze `SD5=3` and a total of
`10` at BASE `32c35fe`, while the counter it shipped measured `SD5=1` and `8`
(`corpus/lessons/round-32.md` §Mistakes M32-2; `corpus/lessons/round-32-verifier-spotcheck.md` §2).
Nothing here is copied from a draft: every verdict string in this entry was produced by the
committed script at the revision that carries it.

Reverify: R33-01

## The defect the gate exists for

The round contract requires a plan to carry a *falsifiable before→after* and to be committed
alone before any data. It also requires the cheapest do-nothing control to be scored with the
frozen counter before the freeze. Round 32 did neither mechanically: the plan's BASE numbers
were an estimate, the counter existed only after the freeze, and when the counter ran over the
BASE tree it disagreed with the plan. The disagreement was caught by a dispatched reviewer, not
by a gate, and the round could not repair it afterwards without re-scoping a frozen predicate.

A frozen plan that names its BASE values is therefore only as good as the measurement behind
those values. `prefreeze-control.sh` is that measurement as a command: it takes the plan's own
controls file, extracts the named revision, runs each declared counting command against that
extraction, and compares the printed value with the declared one.

## Interface

    corpus/prefreeze-control.sh run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]
    corpus/prefreeze-control.sh --selftest

- `--base` is any revision `git -C <lane> archive` accepts; the extraction happens under
  `$TMPDIR` (or `--work`) and is removed on exit.
- The controls file is TAB-separated `id<TAB>expect<TAB>command`. Blank lines and lines whose
  first field starts with `#` are skipped. A row that does not split into exactly three fields is
  a policy error, not a measurement.
- Each command runs with `bash -c` and cwd set to the extraction; `$BASE` (the extraction root)
  and `$LANE` (the live lane root) are exported for commands that need a counter from the tip
  tree — the round-32 replay needs exactly that, because the counter it scores was shipped after
  the BASE revision existed.
- Measurement is the **last non-empty stdout line**, reduced to its final run of digits. A
  command that prints no integer is `NORESULT`.
- Per-row lines: `OK <id> expect=<e> measured=<m>` / `MISMATCH <id> expect=<e> measured=<m>` /
  `NORESULT <id> expect=<e>`.
- Verdict line (last):
  `PREFREEZE: CLEAN (controls=<n> mismatch=0)` exit 0;
  `PREFREEZE: MISMATCH (controls=<n> mismatch=<m>)` exit 1;
  `PREFREEZE: SETUP <reason>` exit 2.
- `--selftest` builds throwaway fixture repositories under `$TMPDIR` and proves one case per
  verdict path plus the exit-code and empty-population cases; it prints
  `PREFREEZE_SELFTEST: PASS (<k> cases)` exit 0 or `... FAIL (<k> cases)` exit 1.

## Why the exit code is part of the measurement

A count command that finds nothing exits 1 while printing `0` (`grep -c` semantics). The gate
therefore does **not** treat a nonzero command exit as a failure: it treats "printed an integer"
as the measurement and lets the comparison decide. Only an unmeasurable row — no integer on the
last line, a timeout, a missing file — is `NORESULT`, and any `NORESULT` makes the whole run
`SETUP` (exit 2) rather than a clean pass. This is the same last-line rule the claim ledger uses
(`corpus/knowledge/claim-ledger.md`), applied to a tree that is not the working tree.

## The two frozen controls files this round ships

`plans/round-33.controls.tsv` declares four BASE values for round 33 (registry rows, NIST entry
count, the gate's own absence, and the Frontier NIST line count). `plans/round-32.controls.tsv`
replays the two values `plans/round-32.md` declared for its own BASE. The second is the red
witness: it must print `MISMATCH (controls=2 mismatch=2)` naming `sd5 expect=3 measured=1` and
`total expect=10 measured=8`. A harness that reported CLEAN on that file would be the defect it
exists to catch.

## What this entry does not establish

- It does not decide whether a declared value is the *right* target; it only proves the value the
  plan states is the value its own counter measures on the named revision.
- It measures numeric counters only. A predicate that is a verdict string, or a claim whose
  before→after is not a number, stays outside it (those are the ledger's last-line rows).
- It does not replace the wave. A green controls run says the plan's arithmetic is honest; it
  says nothing about whether the work then lands.
- The extraction is a snapshot of committed bytes. An uncommitted edit in the working tree is
  invisible to it by construction — which is the point, and also the limit.

## Reproduction

    bash corpus/prefreeze-control.sh run --base 76f4eeae7aa9af4dbb9423f5632b55791824253a \
      --controls plans/round-33.controls.tsv
    bash corpus/prefreeze-control.sh run --base 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b \
      --controls plans/round-32.controls.tsv
    bash corpus/prefreeze-control.sh --selftest

## Falsifiers

1. A controls file with one `expect` changed by +1 must produce `MISMATCH` naming that id.
2. A command printing a verdict line whose last token is not a number must produce `NORESULT`.
3. A run whose extraction is the live tree must disagree with the same run against the frozen
   revision as soon as the tree differs.
4. Deleting the numeric comparison in the script must make `--selftest` FAIL.
5. Treating `NORESULT` as a pass must make `--selftest` FAIL.
6. An empty controls file (only comments) must produce `SETUP`, never CLEAN.
