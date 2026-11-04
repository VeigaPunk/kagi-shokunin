# Round 35 — proposed live-document changes (draft only)

Axes: calibration (producer-result integrity), completeness (all live contract copies), history preservation. These snippets describe the frozen intended contract, not execution observed by this seat. L1 owns installation and final receipt-backed wording. Source snapshots: SKILL.md#5EEB, PROVINCE.md#C07D, corpus/README.md#22C0, corpus/knowledge/prefreeze-controls.md#EAAE. Line locations are the read-time locations, not promises after concurrent edits.

## SKILL.md:820 — replace complete registry row

Before:
```markdown
| pre-freeze BASE controls (`corpus/prefreeze-control.sh`) | gate | `bash corpus/prefreeze-control.sh run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]` | 0 `PREFREEZE: CLEAN (controls=N mismatch=0)`; 1 `PREFREEZE: MISMATCH (controls=N mismatch=M)`; 2 `PREFREEZE: SETUP <reason>` | `bash corpus/prefreeze-control.sh --selftest` (12 cases; round 34) | `plans/round-33.controls.tsv`, `plans/round-34.controls.tsv`; caller-selected BASE commit and controls TSV (`id`, integer `expect`, command); timeout default 300 seconds; final digit run on last nonempty stdout line | extracts BASE and stores stderr under temporary `--work`/`TMPDIR`, removed on exit; executes caller-supplied commands, not a write sandbox; selftest isolated temporary Git fixtures | kagi |
```

New:
```markdown
| pre-freeze BASE controls (`corpus/prefreeze-control.sh`) | gate | `bash corpus/prefreeze-control.sh run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]` | 0 `PREFREEZE: CLEAN (controls=N mismatch=0)`; 1 `PREFREEZE: MISMATCH (controls=N mismatch=M)`; 2 `PREFREEZE: SETUP <reason>` | `bash corpus/prefreeze-control.sh --selftest` (current exact expectation: ledger R33-01 and R34-02) | `plans/round-33.controls.tsv`, `plans/round-34.controls.tsv`; caller-selected BASE commit and controls TSV (`id`, integer `expect`, command); timeout default 300 seconds; round-35 producer contract: one nonempty unsigned-integer stdout line, no stderr, rc0 or rc1 with zero only; all other results are NORESULT/SETUP | extracts BASE and stores stderr under temporary `--work`/`TMPDIR`, removed on exit; executes caller-supplied commands, not a write sandbox; selftest isolated temporary Git fixtures; a deliberately false valid integer or caller-masked upstream failure remains undetectable | kagi |
```

## PROVINCE.md:77 — replace complete gate bullet

Before:
```markdown
- `corpus/prefreeze-control.sh` — freeze-time BASE controls (round 33): `run --base <rev> --controls <tsv>` extracts the named revision with `git archive` into scratch, runs every command listed as `id<TAB>expect<TAB>command` with that extraction as cwd (`BASE`/`LANE` exported) and compares the last non-empty stdout line's final integer with the declared value; `--selftest` proves 12 cases (round 34 adds relative-work). Verdict `PREFREEZE: CLEAN|MISMATCH (controls=N mismatch=M)` exit 0/1, `SETUP <reason>` exit 2 — a `NORESULT` row is SETUP, never a pass. Red witness: `plans/round-32.controls.tsv` at `32c35fe` reports `MISMATCH` on both declared values the round-32 plan froze (`sd5 expect=3 measured=1`, `total expect=10 measured=8`).
```

New:
```markdown
- `corpus/prefreeze-control.sh` — freeze-time BASE controls (round 33; producer-result contract tightened round 35): `run --base <rev> --controls <tsv>` extracts the named revision with `git archive` into scratch and runs every `id<TAB>expect<TAB>command` with that extraction as cwd (`BASE`/`LANE` exported). A usable producer result is one nonempty unsigned-integer stdout line, no stderr, and rc0, or rc1 with zero only (`grep -c` no-match); that integer is compared with the declared value. Other exits, empty/multiline/prose output, diagnostics and timeout are `NORESULT`, making the final verdict `SETUP` exit 2, never CLEAN. Valid results yield `PREFREEZE: CLEAN|MISMATCH (controls=N mismatch=M)` exit 0/1. `--selftest` exercises isolated temporary Git fixtures; its exact current expectation is ledger R33-01 and R34-02. A dishonest producer emitting a valid plain integer with rc0, including a pipeline masking upstream failure, remains outside the guarantee. The historical round-32 replay at `32c35fe` reported `MISMATCH` on both declared values (`sd5 expect=3 measured=1`, `total expect=10 measured=8`); historical receipts are not retroactively regraded.
```

## corpus/README.md:92 — replace complete index row

Before:
```markdown
| Pre-freeze BASE controls (gate + entry, round 33) | `corpus/prefreeze-control.sh`, `corpus/knowledge/prefreeze-controls.md` | `run --base <rev> --controls <tsv>` extracts the revision, runs each declared counting command in it and compares the last integer; `--selftest` proves 12 cases (round 34 adds relative-work); red witness on `plans/round-32.controls.tsv` (`MISMATCH 2/2`) |
```

New:
```markdown
| Pre-freeze BASE controls (gate + entry, round 33; strict producer-result contract round 35) | `corpus/prefreeze-control.sh`, `corpus/knowledge/prefreeze-controls.md` | `run --base <rev> --controls <tsv>` extracts the revision and compares each usable producer integer with its declaration: one nonempty unsigned-integer stdout line, no stderr, rc0 or rc1 with zero only; invalid results become `NORESULT`/final `SETUP` exit 2. `--selftest` expectation: ledger R33-01 and R34-02. Valid plain-integer lies and caller-masked upstream failures remain outside the guarantee; historical round-32 red receipt: `MISMATCH 2/2` |
```

## corpus/knowledge/prefreeze-controls.md — preserve original body and append scoped erratum

Before (exact existing EOF, lines 101–103):
```markdown
4. Deleting the numeric comparison in the script must make `--selftest` FAIL.
5. Treating `NORESULT` as a pass must make `--selftest` FAIL.
6. An empty controls file (only comments) must produce `SETUP`, never CLEAN.
```

New EOF (retain those lines, append following):
```markdown

## Round-35 contract erratum — strict producer-result envelope

The original Interface measurement rule and §Why the exit code is part of the
measurement above describe the round-33/34 implementation, not the current
producer-result contract. Their last-digit extraction and ignored-exit behavior
are superseded here; the historical receipts and their original outcomes remain
historical and are not retroactively regraded. The claim-ledger last-line rule
is a different contract and is not changed by this erratum.

For this gate, a usable producer result has exactly one nonempty
unsigned-integer stdout line and no stderr, with rc0, or rc1 with zero only
(the `grep -c` no-match convention). The gate compares that integer with the
row's declared value: equal means `OK`, unequal means `MISMATCH`. Empty output,
multiple lines, prose or SETUP/POLICY-shaped output, stderr, other exits and
timeouts are `NORESULT`; any such row forces the final `PREFREEZE: SETUP`
verdict, exit 2, even if another row mismatches. A valid count mismatch remains
exit 1; usable matching results remain exit 0.

This is producer-envelope validation, not a proof that arbitrary shell commands
are honest or confined. A producer deliberately printing a valid plain integer
with rc0 can still lie; a pipeline that masks an upstream failure can expose
the same accepted envelope. Neither is claimed detectable by this contract.

The frozen round-35 plan (`plans/round-35.md`) and instrument
(`.ufo/waves/round-35/controls/measure.py`) define the public-path calibration
population and independent expected exits/findings. Their target is not itself
execution evidence. Current selftest expectations live in ledger R33-01 and
R34-02; consult receipt-backed round-35 reporting for observed outcomes rather
than inferring them from this contract.

Falsifier: a producer printing a numeric CLEAN/SETUP-shaped diagnostic, printing
an integer alongside stderr, or returning an unaccepted exit with an integer
must produce `NORESULT` and final SETUP exit 2. Ordinary rc0 zero and rc1 zero
with no stderr must remain usable, and a valid unequal count must remain
MISMATCH exit 1.

Recheck trigger (supplements the existing header): on-change — re-run the gate
selftest and the unchanged frozen round-35 public-path measurement after producer
parsing, exit handling or stderr handling changes; preserve complete outputs and exits.
```

The provenance header remains historical evidence of reopened S088, not evidence that its pinned old source implements the new contract. Do not silently re-point S088 or its capture to candidate bytes. Coordinate any current-execution annotation with source-curation owner and use observed receipts only.
