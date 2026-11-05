# K41MutGates notes — round-41 mutation runners

Predictions below were written BEFORE any runner execution. Actual readings are appended at the
bottom under "Actual results" and are marked as such.

## Scope and commands

- Deliverable runner: `run-mutants.sh <LANE> [c1|c2|both]` (this directory). This seat does NOT run
  it against the lane tree; the L1 runs it after landing. When invoked, it:
  - takes the lane path as the first argument; reads the lane only;
  - refuses with exit 2 if `corpus/expect-journal.sh` or the `Sources (` paragraph in
    `corpus/rendered-text-v1.py` (plus the counters) is missing;
  - writes only under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41MutGates/mut-run.<pid>`
    (never `/tmp`) and deletes that scratch dir on exit via trap;
  - checks the unmutated baseline first (gate must read 4, paragraph must read 3); a baseline
    failure marks every mutant INCONCLUSIVE, never killed.
- C1 mutant judge: `EXPECT_JOURNAL=<mutant> bash <LANE>/plans/round-41-c1.sh`; killed when the
  reading is not 4. C2 mutant judge: `RTV1=<mutant> bash <LANE>/plans/round-41-c2.sh`; killed when
  the reading is not 3.
- Runner self-test fixtures (this seat's scratch, deleted before yield):
  1. C1: shared clone of the lane at predeclaration commit 5142b52, `git rev-parse --show-toplevel`
     asserted equal to the clone root, with a fixture gate written at
     `<clone>/corpus/expect-journal.sh` implementing the frozen interface (R1; R2 OLD/COMMAND/NEW;
     R3 literal-anchored; R4 WARN ORPHAN; refusal lines `EXPECT_JOURNAL: REFUSE <CLASS> <ID>`;
     final `CLEAN`/`REFUSED` lines; exit 0/1/2). The counter's own fixtures come from committed
     bytes: BASE 6cc8850 ledger, P0 6f1588c ledger + round-40 journal
     (`.ufo/waves/round-40/expectation-migrations.json`).
  2. C2: a fake lane in scratch: the lane's `plans/round-41-c2.sh` copied in; the executor's
     candidate paragraph draft (`.ufo/waves/round-41/build/K41ExecDocs/rendered-text-v1.py`) as
     `corpus/rendered-text-v1.py`; BASE `corpus/SOURCES.md` (has `supersedes S027` via the S040
     row; no `supersedes S095|S096|S097`); a synthesized S095 capture body + `source-fetches.tsv`
     row whose column 10 is the body's sha256.
- Controls at BASE: `always-refuse.sh` and `always-accept.sh` written in scratch;
  `EXPECT_JOURNAL=<control> bash plans/round-41-c1.sh` must read 0 for each (P0 refused / nothing
  refused).
- Install record: none. Only bash, python3, git used; no tool installed or upgraded.

## Predicted C1 mutants (mutate `corpus/expect-journal.sh`; counter target 4)

| mutant | change | predicted reading | verdict | reason — what the counter sees |
|---|---|---|---|---|
| drop_R1 | UNJOURNALED emission disabled | 3 | killed | P0 still accepted; F1's exact line `EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01` no longer printed (F1's journal entry is removed, and no other rule prints F1's required token), F2/F3/F4 unchanged → 3 counted |
| drop_R2_OLD | OLD_MISMATCH emission disabled | 3 | killed | F2's exact line missing; F1/F3/F4 unchanged |
| drop_R2_CMD | COMMAND_MISMATCH emission disabled | 3 | killed | F4's exact line missing (rebound command vs journal `command`) |
| drop_R2_NEW | NEW_MISMATCH emission disabled | 4 | SURVIVES | no forgery among F1–F4 violates NEW_MISMATCH: F3 forges the journal `new_expect` to EQUAL the candidate expect by construction; F1 has no entry (R1 path); F2/F4 entries match. Coverage gap: the counter never exercises NEW_MISMATCH |
| drop_R3 | NOT_LITERAL emission disabled | 3 | killed | F3 is the only forgery whose sole firing rule is R3: its journal entry exists (R1 quiet), `old_expect` still equals the base expect and `command` is unchanged (R2 quiet), and the journal `new_expect` was forged to equal the candidate expect (NEW quiet). Gate then accepts F3 (rc 0, CLEAN) → counter counts 3 |
| r4_downgrade | `WARN ORPHAN` → `REFUSE ORPHAN` | 4 | SURVIVES | R4 is a warning; no fixture (P0 or F1–F4) contains an orphan entry — every round-40 journal entry corresponds to a changed row — so the downgrade never fires and the reading stays 4 |
| refuse_exit0 | `exit 1` → `exit 0` | 0 | killed | counter requires rc 1 plus the exact REFUSE line to count; refusals now exit 0 → nothing counted; P0 accepted → reading 0 |
| clean_on_violation | final `REFUSED` line → `CLEAN` (rc 1 and per-violation REFUSE lines kept) | 4 | SURVIVES | the counter only checks rc and the exact per-violation line; it never parses the final verdict line — coverage gap |
| first_violation_only | refusal emitter truncated after first line | 4 | SURVIVES | each forgery violates exactly one frozen rule (F1:R1 — the entry is removed so the `continue` skips later rules; F2:OLD; F3:R3; F4:COMMAND), so the needed line is still the first and only one; P0 has no violations |
| non_json_accept | journal discovery `*.json` → `*` | 4 | SURVIVES | every fixture journal file is named `expectation-migrations.json`, so relaxed acceptance changes nothing on the counter's inputs — coverage gap |
| unknown_id_ignore | journal entries whose id is absent from the candidate ledger are skipped | 4 | SURVIVES (if generated) | every journal id in the fixtures (R13-01, R21-02, R24-06, R31-02, R33-02, R34-03) is present in the candidate ledger, so the relaxation is unexercised. Generation depends on recognizing the gate's journal-entry loop — NGEN is likely on the real gate text |

Predicted C1 line: `MUTANTS C1: killed=5 survived=6 total=11` on the fixture gate; on the real
gate, `unknown_id_ignore` may be NGEN, which would give `killed=5 survived=5 total=10` plus a
`C1 NOT-GENERATED:` line.

## Predicted C2 mutants (mutate the Sources paragraph; counter target 3)

| mutant | change | predicted reading | verdict | reason |
|---|---|---|---|---|
| drop_S095 | S095 token removed | 3 | SURVIVES | (a) stays 1 via the remaining cited ids (S096, S097); (b) never requires S095 inside the paragraph — its binding reads the S095 row of `corpus/source-fetches.tsv` and runs `locate` on the lane normalizer — so quote-present + binding + locate all still hold; (c) 1 |
| drop_S096 | S096 token removed | 3 | SURVIVES | two good ids remain for (a); (b)/(c) untouched |
| drop_S097 | S097 token removed | 3 | SURVIVES | two good ids remain for (a); the counter cannot notice that S097 grounds the str.isspace() definition — coverage gap |
| cite_S027 | one cited id replaced by superseded S027 | 2 | killed | (a)=0: S027 appears in a `supersedes S###` cell (the S040 row supersedes S027) |
| split_quote | newline inserted inside the frozen quote | 2 | killed | (b)=0: the fixed-string grep is line-based |
| drop_quote | quote removed | 2 | killed | (b)=0 |
| syntax_break | module-level syntax break appended (selftest path dead) | 2 | killed | (c)=0 (`--selftest` rc != 0). Note (b) stays 1: term (b)'s `locate` subprocess runs the lane's own `corpus/rendered-text-v1.py`, not the mutant — the counter hardcodes that relative path |

Predicted C2 line: `MUTANTS C2: killed=4 survived=3 total=7`.

## Controls (both must read 0)

- `EXPECT_JOURNAL=<scratch>/always-refuse.sh` → predicted 0 (positive control P0 is refused, counter zeroes).
- `EXPECT_JOURNAL=<scratch>/always-accept.sh` → predicted 0 (no forgery refused).

## Actual results

All commands run with absolute paths from the fleet root. rc = exit code. Scratch root:
`/fast/scratch/hyaku/kagi-r41/K41MutGates` (deleted before this seat yielded).

### Controls at BASE (both must read 0)

| command | stdout | rc |
|---|---|---|
| `EXPECT_JOURNAL=<scratch>/always-refuse.sh bash plans/round-41-c1.sh` | `0` | 0 |
| `EXPECT_JOURNAL=<scratch>/always-accept.sh bash plans/round-41-c1.sh` | `0` | 0 |

Both read 0 as predicted: blanket-refuse fails the positive control P0; blanket-accept refuses
nothing.

### Runner self-test, C1 (fixture gate in a shared clone of the lane at 5142b52; counter
fixtures built by the counter from committed bytes BASE 6cc8850, P0 6f1588c + round-40 journal)

`bash run-mutants.sh <scratch>/work c1` → rc=0.

```
C1 BASELINE rc=0 reading=4 target=4
drop_R1              reading=3 killed      (comment UNJOURNALED emit)
drop_R2_OLD          reading=3 killed      (comment OLD_MISMATCH emit)
drop_R2_CMD          reading=3 killed      (comment COMMAND_MISMATCH emit)
drop_R2_NEW          reading=4 SURVIVED    (comment NEW_MISMATCH emit)
drop_R3              reading=3 killed      (comment NOT_LITERAL emit)
r4_downgrade         reading=4 SURVIVED    (WARN ORPHAN -> REFUSE ORPHAN)
refuse_exit0         reading=0 killed      (exit 1 -> exit 0)
clean_on_violation   reading=4 SURVIVED    (final REFUSED -> CLEAN)
first_violation_only reading=4 SURVIVED    (first-refuse guard in emitter fn)
non_json_accept      reading=4 SURVIVED    (endswith('.json') -> endswith(''))
unknown_id_ignore    reading=4 SURVIVED    (skip journal ids absent from candidate rows)
MUTANTS C1: killed=5 survived=6 total=11
```

Every verdict matches the advance prediction, including the two named mandatory predictions:
R4 downgrade survives (R4 is a warning; no fixture contains an orphan) and drop-R3 is killed via
F3 alone (counter sees the gate ACCEPT F3: rc 0, CLEAN — entry exists, old_expect/command unchanged,
journal new_expect forged to equal the candidate expect — so with literalness unchecked the
non-literal loosening slips through).

### Runner self-test, C2 (fake lane: lane `plans/round-41-c2.sh` + executor paragraph draft
`.ufo/waves/round-41/build/K41ExecDocs/rendered-text-v1.py` + BASE `corpus/SOURCES.md` +
synthesized S095 capture body and `source-fetches.tsv` row, col10 = body sha256
`17bd2013bbcb1a0f4761a678ef492df5c9a0785bfba20cf31faef396eb7b8bd1`)

`bash run-mutants.sh <scratch>/fakelane c2` → rc=0.

```
C2 BASELINE rc=0 reading=3 target=3
drop_S095   reading=3 SURVIVED
drop_S096   reading=3 SURVIVED
drop_S097   reading=3 SURVIVED
cite_S027   reading=2 killed   (cite S027 via S095)
split_quote reading=2 killed   (newline inside quote)
drop_quote  reading=2 killed   (quote removed)
syntax_break reading=2 killed  (module-level syntax break; note (b) stayed 1 because term (b)'s
                              locate runs the lane normalizer path, not the mutant)
MUTANTS C2: killed=4 survived=3 total=7
```

Every verdict matches the advance prediction.

### Other runner paths exercised

- Baseline-inconclusive discipline: `run-mutants.sh <scratch>/work c2` → `C2 BASELINE rc=0
  reading=1` (the BASE paragraph cites no id — exactly the plan's no-work reading), then
  `C2 INCONCLUSIVE-BASELINE ... MUTANTS C2: killed=0 survived=0 total=0`, rc=0.
- Fail-closed exit 2: missing lane dir → rc=2; lane without gate/counter → rc=2
  (`run-mutants: missing counter: .../plans/round-41-c1.sh`).
- Fixture gate on P0 direct: `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, rc=0.

### Generation defects found during self-test (fixed in run-mutants.sh before the final runs)

1. `first_violation_only` was NGEN: the def-line regex did not allow a trailing comment after the
   opening brace; fixed to `^name()\s*\{[ \t]*(?:#.*)?$`.
2. `unknown_id_ignore` first generated a CORRUPT mutant: the reconstruction used regex group 2
   (the dict name) where the line was needed, leaving a bare `entries` expression statement. The
   corrupt gate refused every row (reading 0) — a false kill, not a semantic kill. Fixed to
   reconstruct the line from the full match minus the measured indent; the final self-test shows
   the true reading (4, survived).

Neither defect touched the lane tree; only run-mutants.sh changed.

### Outcome vs prediction

All 11 C1 verdicts and all 7 C2 verdicts match the tables above; predicted summary lines
`MUTANTS C1: killed=5 survived=6 total=11` and `MUTANTS C2: killed=4 survived=3 total=7` were
produced exactly. Install record: none (bash, python3, git only).

### Restoration

The lane tree was never edited by this seat (writes only under
`.ufo/waves/round-41/build/K41MutGates/`). The fixture clone, fake lane, control scripts and all
mutants lived only in this seat's scratch and were removed before yield.
