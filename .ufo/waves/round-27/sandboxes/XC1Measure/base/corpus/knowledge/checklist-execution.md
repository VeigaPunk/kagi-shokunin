# checklist-execution — the credential-hygiene checklist, executed per item

Source basis: measured 2026-09-28 (round 15) on the live host against
`SKILL.md` §Credential-hygiene checklist (16 items, L420–447 at the round-15
revision), `corpus/checklist.tsv` (16 rows) and `corpus/checklist-run.sh`;
every number below is a line one of those commands prints. Siblings this entry
does not duplicate: the surface list is `surface-census.md`'s, the `op.env`
loader contract is `op-ref-consumption.md`'s, the transcript scan is
`transcript-hygiene.md`'s. This entry is only about the *execution* layer.

Reverify: R15-01, R15-02, R15-03, R15-04, R15-05

## 1. The gap this closes

Before round 15 the checklist was 16 `- [ ]` bullets and nothing else: no
command mapped an item to an outcome, so "the checklist is done" was a claim
with no artefact, and the split between *checked* and *judged* items was
asserted in prose (the round-9/10/11 scorecard said "12 checklist items are
still operator judgement" — a number no gate measured, and one that was already
wrong when written, since ≥3 items name a live gate and the list held 14 items
at those revisions; round-15 census).

The execution layer is now two files:

| File | Role |
|---|---|
| `corpus/checklist.tsv` | one row per checklist item: the declaration |
| `corpus/checklist-run.sh` | the runner: validates the declaration, executes the runnable rows, prints one verdict |

## 2. The declaration — eight columns

`id <TAB> class <TAB> lead <TAB> check <TAB> expect_exit <TAB> expect_last <TAB> reason <TAB> note`

| Column | Contract |
|---|---|
| `id` | `<letter><digits>`: `E1–E8` (Evidence production), `H1–H8` (Handler operation). Unique. |
| `class` | `runnable` or `by-hand`; anything else is `POLICY`, exit 2. |
| `lead` | an ERE matched against the item text. **The mapping is a bijection**: one row per item, one item per row. |
| `check` | `runnable`: a shell command run with `cwd` = repo root under `timeout ${CHECKLIST_TIMEOUT:-240}`; `by-hand`: `-`. |
| `expect_exit` | `runnable`: `N` or `A\|B\|C…` (any number of accepted alternatives — H7 uses three); `by-hand`: `-`. |
| `expect_last` | `runnable`: ERE matched against the last non-blank stdout line; `by-hand`: `-`. |
| `reason` | `by-hand` only: `<class>: <text ≥ 24 chars>`, class in (`authoring-duty`, `runtime-behavior`, `cross-lane`, `manual-change`, `operator-scope`), text **unique** across rows; `runnable` rows must carry `-`. |
| `note` | what the row verifies and what it leaves to the operator (`runnable`), or why no command shape exists and what would create one (`by-hand`). Required on both. |

## 3. Verdicts and exit codes

| Line | Exit | Meaning and reader action |
|---|---|---|
| `CHECKLIST_RUN: CLEAN (items=N runnable=K by_hand=M failed=0)` | 0 | every row executed and matched, and the declaration is complete |
| `CHECKLIST_RATIO: runnable=K/N floor=F by_hand=M delegated=D direct=K-D` | — | the number this axis is measured by (`floor = ceil(items/2)`), split into what was already delegated to an existing gate and what this file newly asserts |
| `ITEM-FAIL <id> (exit a want b)` (+ `TIMEOUT`, + up to 6 lines of the row's output) | 1 | the row's command disagreed with its declared exit — re-read the named path before citing anything from this item |
| `ITEM-LASTLINE <id> (want /…/ got …)` | 1 | the command ran, its verdict line moved — the row is the drift signal (see H7) |
| `UNDECLARED` / `EXTRA` | 1 | item count ≠ row count: a new bullet in SKILL.md has no row, or a row declares an item that is gone |
| `UNMATCHED-ITEM j` / `DUPLICATE-ITEM j` | 1 | the bijection broke in the item direction: no row (or more than one) declares item j |
| `UNMATCHED-LEAD id` / `DUPLICATE-LEAD id` | 1 | a row's `lead` matched no item, or matched several — the row is attached to nothing / to everything |
| `DUPLICATE-REASON` | 1 | two by-hand rows share one reason string (a lazy map of everything to one sentence) |
| `RATIO (runnable=K floor=F items=N)` | 1 | too few rows are mechanised to meet the floor |
| `CHECKLIST_ROW: CLEAN\|BROKEN (id=…)` | 0 / 1 | printed instead of the checklist verdict under `--only ID`: one row is not the checklist, so the line cannot be mistaken for a whole-run pass |
| `POLICY …` | 2 | shape/policy: bad column count, unknown class, non-`-` field on a by-hand row, short/non-conforming reason (including a padded one — reasons need ≥20 non-space characters), runnable row with a reason, duplicate id, or a `check` naming a denied surface |
| `SETUP …` | 2 | missing TSV, unreadable checklist source, no checklist section, `--only` with an unknown id; **nothing executed** |

Modes: default `verify`; `--list` prints the map and runs nothing;
`--only ID` runs (or reports) one row; `--selftest` proves 34 cases on scratch
fixtures.

## 4. The delegation map

| Rows | What they execute |
|---|---|
| `E1` | `surface-census.sh` **then** `drift-pins.sh` (`&&`, so both exits are asserted; the pinned last line is drift's verdict) |
| `E5` | `op-ref-probe.sh` — the item's own named command |
| `H7` | `transcript-scan.sh` |
| `E4` | direct: a reference-shaped-literal sweep over every non-`.git` file in the repo (any extension), printing `hits`/`excluded`/`raw` — counts only, and the allowlist is visible instead of silent |
| `E8` | direct: `handoff-status.json` key names, boolean values and the two receipt keys |
| `H1` | direct: the `flock`/`LOCK_FILE` premise in the CLI + the lock file's mode |
| `H3` | direct: the overlay's four knobs + that the global config parses (the merge path) |
| `H4` | direct: the agent front-matter permission map is **exactly** `{"*": deny, janitor_auth: allow}` with `steps: 4` |
| `H8` | direct: `OPENCODE_SERVER_PASSWORD` occurrences in CLI+client, listening/established sockets on 40961 |

Seven rows are `by-hand`: `E2` (manual-change), `E3`, `E6`, `E7` (authoring-duty),
`H2` (runtime-behavior), `H5` (cross-lane), `H6` (authoring-duty). Baseline at
the round-15 revision: `runnable=9/16 floor=8 by_hand=7` — the floor is met with
one row of margin.

## 5. What "runnable" does and does not mean

A runnable row verifies the item's **machine-checkable half** and says so in its
`note`; it does not verify the operator's duty. `H4` proves the permission map
is not widened, not that nobody widens it between runs; `H8` proves the handler
does not set a server password and no established socket points at the port, not
that no local process ever POSTs there. The by-hand rows are where *no* command
shape exists at all, and the alternative reading was measured, not asserted: a
stricter criterion ("the item's own stated outcome, nothing less") was applied
by a round-15 planner lane and yields `runnable=3 by_hand=13`, below the floor.
A second lane put `E5` at the boundary because `op-ref-probe.sh` execs `op run`
(albeit over generated plain fixtures with a ref-token guard) → `8/8`, exactly
the floor. Both readings are recorded rather than smoothed over. The shipped
criterion is "is there a command whose verdict is a defect signal for this
item?" — and the `note` column is what makes that claim honest, because the
`note` names the duty the row leaves to the operator. That property is **not
gate-enforceable** (a lane verified the notes by reading all nine): it is a
per-row review item, and the `CHECKLIST_RATIO` split (`delegated` vs `direct`)
is the only mechanical signal that a row is not simply re-asserting an existing
gate's exit.

The by-hand rows split into two reasons, and the second is *hard*, not merely
awkward: `H2`/`E6`/`H6` cannot be mechanised because the contract forbids the
only mechanisation (start/stop and `the-janitor run` are denied surfaces, and a
check for H6 would have to read the request text the item forbids persisting).

## 6. Bounds

1. **Premise, not duty** — see §5; every runnable row's `note` names what it
   does not cover, and the ratio counts premises, not duties.
2. **Nothing schedules this gate** (or any other in this repo): it is a
   run-on-demand artifact. `systemctl --user list-timers` / `crontab -l` show no
   entry for any `corpus/*.sh`; the operability ceiling is therefore unchanged
   and this round does not claim it.
3. **`E4`'s allowlist is visible, not silent** — the sweep prints `hits`,
   `excluded` and `raw`, and pins `hits=0 excluded=5 raw=5`. The three exempt
   placeholder/fixture vault names (`vault` on the three documented example
   lines, `FakeVault` and `wal` inside the two gate scripts) are therefore
   counted on every run: a *live* reference path under any other vault name
   still hits, and removing one of the example lines is a reviewed re-pin
   rather than a pass. The residual, named: a genuine path published under a
   vault literally named `vault` would be exempted by name.
4. **`H7` pins a hit count and names exactly two states** — `TRANSCRIPT_SCAN:
   HITS=2` is the 2026-09-28 baseline and exit 1 is by design, so the *pinned
   last line* is the teeth: a new hit, or a changed scan shape, fails the row.
   The second accepted state is the one the item above it prescribes — after
   `stop` + `rm -rf xdg-data` the DB is legitimately gone
   (`surface-census.tsv` classes `opencode.db*` runtime/absent) and the gate
   exits 2 with `transcript-scan: db not found: <path>`. Any third state fails.
   Re-pin only after reading the `HIT` lines.
5. **`H8` reports the listener, asserts its scope** — a listening 40961 is
   legitimate while the handler runs, so the count is printed while
   `password_refs=0`, `non_loopback=0` and `established=0` are asserted: a
   wildcard or `[::]` bind would expose the unauthenticated API off-host and
   fails the row (branch-proven on scratch ports by a lane).
6. **`H3` reports the foreign list** — the global `~/.config/opencode/opencode.json`
   is not kagi's surface (round-10 adjacency), so its provider list is printed,
   never asserted.
7. **The deny list governs the row's own command, lexically** — `check` may not
   name `op.env`, `op run|read|inject`, a handler start/stop/run or
   `claim-ledger.sh` (recursion). A row that *delegates* inherits the delegate's
   policy, which is why `E5`'s `op` execution is declared on the row instead of
   hidden. A lane's executed counterexample: a check that *builds* the string
   (`$(printf op)$(printf .env)`) bypasses the lexical test, so the deny list
   raises the cost of an accidental leak, not of a deliberate one.
8. **The gate echoes a failing row's output** (≤6 lines) — so every row must be
   metadata-only by construction; a row that printed a value would leak it into
   the run log. The class rule is enforced by review, not by the gate.
9. **`UNMATCHED-LEAD` is a text match, not a semantic one** — a `lead` proves the
   row points at *an* item; whether the command verifies what that item asks is
   the reviewer's call (the round-13 pointer-relevance ceiling in checklist
   form).
10. **`by-hand` uniqueness is not evidence** — unique reasons prevent a lazy
    one-sentence map, not an honest-looking by-hand label on a mechanisable item.
11. **The gate does not measure a row's semantic strength** — a lane's executed
    counterexample: a 16-row TSV whose every runnable `check` is a constant
    `printf` passes `CLEAN (runnable=16/16)` and clears the floor, and a `check`
    that greps an unanchored pattern can be satisfied by a comment. The
    countermeasures here are partial and named: H1 is line-anchored for exactly
    that reason, the ratio splits `delegated` from `direct`, and the rest is
    review. No guard can tell a meaningful assertion from a well-formed one.
12. **`H8`'s scope is the handler's own code path** — `password_refs=0` counts
    occurrences in the CLI and client; an operator running a *different*
    launcher with `OPENCODE_SERVER_PASSWORD` set in its environment is outside
    what this row reads (a lane's counterexample).

## 7. Falsifiers

1. Add a 17th `- [ ]` bullet to SKILL.md → `UNDECLARED (items=17 rows=16)`,
   exit 1 (row `R15-04` pins the declaration count as the outside check).
2. Delete the `H7` row → `UNDECLARED`, and item 15 loses its row.
3. Change a `lead` to text that appears twice → `DUPLICATE-LEAD`; to text that
   appears nowhere → `UNMATCHED-LEAD`; to another row's lead → `DUPLICATE-ITEM`.
4. Give two by-hand rows the same reason → `DUPLICATE-REASON`.
5. Convert three runnable rows to by-hand → `RATIO (runnable=6 floor=8 items=16)`,
   exit 1.
6. Point a `check` at `$CONFIG_DIR/op.env` (or at `the-janitor run`, or at
   `claim-ledger.sh`) → `POLICY … denied surface`, exit 2, nothing executed.
7. Widen the permission map with `bash: allow` → `JANITOR_PERMS: DEFECT (entries=3 steps=4)`
   → `ITEM-LASTLINE H4` (selftest: a half-anchored ERE would have passed here;
   the row compares the parsed entry list exactly).
8. Set `share: "enabled"`, or delete a row's expected line, or make a row's
   command exit 0 printing nothing → `ITEM-LASTLINE`, exit 1 — never a silent
   pass (the round-15 build shipped two silent-death bugs of exactly this class,
   both caught by lanes before commit).
9. Strip the checklist section from SKILL.md → `SETUP`, exit 2.
10. `rm corpus/checklist.tsv` → `SETUP checklist.tsv not readable`, exit 2.

## Erratum (round 22 — historical execution and locator scope)

Source-status: historical — the round-15 CLEAN checklist baseline and
handler-dependent row outcomes above are not current executions on an
absent-substrate host. A passing file-absence condition is not proof that
the intended host file was inspected. Deferred live rows stay unverified.
Use the named SKILL checklist section rather than the old numeric span;
its heading and item endpoints do not share one range.

The modes description also includes `--ratio` (declared by R15-05), which
does not execute checklist rows. The hygiene allowlist provenance includes
a synthetic selftest fixture, not only documented prose examples. The old
scorecard phrase's historical revision attribution is narrowed in
`kagi-shokunin/.ufo/waves/round-22/build/Entry04.md`.
No checklist or host gate was executed for this static correction.