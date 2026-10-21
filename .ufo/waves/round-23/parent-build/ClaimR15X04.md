# ClaimR15X04 — R15-04: outside count of the checklist declaration rows

Read-only audit. **No claim-ledger row command, runner, or sibling gate was executed**; no
packages/services were touched and no tools were installed. Root for all relative paths:
`/home/vgpnk/Projects/shokunin/kagi-shokunin`.

Observed revision: `HEAD d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300,
"round-22 verifier spot-check"). One in-flight, untracked file appeared during this audit:
`corpus/closure-dispositions.py` (mtime 2026-10-21 00:45, absent from `git log`). It is outside the
frozen population; §6 assesses it as the C1 integration target, not as audited production state.

## 1. Row and source boundaries

- **Row** `corpus/claim-ledger.tsv:36`:
  `grep -cE '^[EH][0-9]+[[:space:]]' corpus/checklist.tsv` / expect `^16$` / exit `0` / timeout `30`.
  Note (field 6) begins: "checklist.tsv holds 16 declaration rows (E1-E8 evidence, H1-H8 handler)."
  No `[substrate]` tag; command does not name `claim-ledger.sh`.
- **Data** `corpus/checklist.tsv`: sha256 `28bd238e549c579d92b9818a9a2e98c0e8153957a18bc89384b1cc5c39972f04`
  (`corpus/stamps.tsv:3`, lines=40, bytes=11694). Physical file is 41 lines because the final `H8`
  row has **no trailing newline**; declaration rows are lines 26–41: `E1`–`E8` (26–33) and
  `H1`–`H8` (34–41), all 8 columns (static parse, Python `re` on the bytes — not the row command).
- **Item population** `SKILL.md:423` (`## Credential-hygiene checklist`): 16 `- [ ]` items at
  `434–441` (Evidence) and `444–449, 452, 456` (Handler); section ends at the next `##` heading
  (`## Evidence-receipt patterns`, 461). `corpus/checklist-run.sh:100` `extract_items` uses exactly
  that heading-to-next-`##` slice; a whole-file bullet count also yields 16.
- **Runner** `corpus/checklist-run.sh`: id shape `^[A-Z][0-9]+$` and uniqueness (139, 193–196),
  item/row counts and `UNDECLARED`/`EXTRA` (206–207), `lead` bijection (209–228),
  `--ratio` performs declaration+bijection and executes no row (177, 250–257).
- **Consumers** `SCORECARD.md:215` (Round 15 post-move section, heading `:211`) cites R15-04;
  `corpus/knowledge/checklist-execution.md:11` (`Reverify:` names it), `:36` (id contract
  `E1–E8`/`H1–H8`), `:174` (falsifier: "row `R15-04` pins the declaration count as the outside
  check"), `:195` (round-22 erratum: execution baseline is historical).

## 2. Expected verdict / last line / exit / timeout — supported (machine claim)

- **`16` and exit 0**: static parse gives exactly 16 qualifying lines; GNU `grep -c` prints the
  unterminated final line's match and prints one line for one file argument. The persisted receipt
  `.ufo/waves/round-22/final-verification.json` `safe_rows[13]` records argv, `exit 0`,
  `stdout "16\n"`, `last "16"`, `passed true`, `seconds 0.001`. The R15-04 line is byte-identical
  at `587fda0` and `HEAD` (`git show 587fda0:corpus/claim-ledger.tsv` vs `HEAD`), and the working
  tree blobs equal the `HEAD` blobs for `claim-ledger.tsv`, `checklist.tsv`, `checklist-run.sh`
  and `SKILL.md` (`git hash-object` vs `git rev-parse HEAD:path`); `checklist.tsv` also matches
  the committed stamp — the receipt transports to current HEAD.
- **Timeout 30 s**: justified. 0.001 s measured on an 11.7 KB file; no host read, no child
  process of its own, no network. Same 30 s class as the sibling pure-count rows (R11-10/R11-11/R13-02).
- **Exit is not independent of the line**: `grep -c` prints a count even at 0 (exit 1), so a
  population change moves the last line; the row fails on line or exit. That is a correct pin.

## 3. Causality — what the count binds, what it does not

**Binds (supported):** the number of `[EH]<digits><space>` declaration lines in `checklist.tsv`.
Against the runner's item count from `SKILL.md` (16), the coverage is complementary:

| mutation | runner | R15-04 |
|---|---|---|
| delete row only | `UNDECLARED` (16 items / 15 rows) | 15 → fail |
| delete item only | `EXTRA` (15 items / 16 rows) | 16 → pass (runner catches) |
| delete row **and** its item | CLEAN (15/15) | 15 → fail |

So the paired-deletion hole is exactly what the outside count closes; the note's "outside check"
framing is accurate **for population size**. Its final clause ("would need both edits to stay
green") is accurate only when scoped to the runner; the ledger itself fails at 15, as the table
shows.

**Does not bind (gap):** that the 16 rows are exactly `E1–E8` (evidence) and `H1–H8` (handler).
The runner constrains id shape, uniqueness, class, columns and the `lead` bijection over a
**flattened** item list; it never constrains the numeric range or that an `E` row's lead lies in the
Evidence section (and `H` in Handler). The note's parenthetical and
`checklist-execution.md:36` therefore assert more than any gate checks (§7).

## 4. `[substrate]` deferral, SKIP-SELF, hermetic mode

- **Deferral**: the tag test is literal and note-only (`claim-ledger.sh:416`, `substrate_present`
  at 140). R15-04's note has no `[substrate]`, so it runs on any host — correct, since its only
  input is a repo file. It is outside R18-02's 11-tag population (static count: 11 tags, R15-04
  absent).
- **SKIP-SELF**: `cells_evidence` skips only rows whose command contains `claim-ledger.sh`
  (`claim-ledger.sh:816–817`). R15-04 does not, is cited at `SCORECARD.md:215`, so
  `claim-ledger.sh cells` (R13-03) **re-runs it** under the same exit+last-line rule. Obligation
  preserved.
- **Hermetic**: no host dependence. Round 22 already classified it safe
  (`.ufo/waves/round-22/safe-row-plan.json` `safe_rows[13]`; policy: "Each safe row will be invoked
  and checked by exit and last line"). Note the adjacent asymmetry: `R15-01` (executes census+drift /
  op-probe / transcript-scan) **is** `[substrate]`; `R15-03` (`--list`) and `R15-05` (`--ratio`) are
  not. A hermetic proof can establish the count (R15-04) and the declaration+bijection (R15-05),
  but not R15-01's executed CLEAN.

## 5. C3 (hermetic cells) must retain for this row

1. **Per-id accounting of all 43 rows**, one disposition each: R15-04 must land in the
   *executed-hermetic* set, never deferred (no tag) and never SKIP-SELF.
2. **The committed data bytes in the fixture root**: `corpus/checklist.tsv` (digest `28bd…`),
   including the unterminated final line. The round-22 frozen subset
   `.ufo/waves/round-22/frozen/before/corpus/` contains **no `checklist.tsv`**; rooting a hermetic
   cells run there makes R15-04 exit 2 (`grep: ... No such file`) → `FAIL reason=exit-mismatch`,
   a false-fail of a hermetic row. Rebuilding the file from `stamps.tsv` `lines=40` (a `wc -l`
   count) drops `H8` → 15 → false-fail.
3. **Synthetic vs shipped**: a synthetic 16-row TSV proves the count *rule* only; it does not
   preserve the causal link to the shipped 16-item population. If used, label it and keep a
   separate shipped-data run.
4. **No live substrate command** is needed for R15-04; the 11 tagged rows stay deferred.

## 6. C1 (closure-disposition) must retain for this row

The in-flight `corpus/closure-dispositions.py` parses obligations only from
`corpus/lessons/round-22-verifier-spotcheck.md` (`D1–D9`, `SPOT-01..05`, `ADJ`); R15-04 is not an
obligation there. If the 43 command rows are wired into C1:

- A disposition for R15-04 must **follow the row's command** to `corpus/checklist.tsv` (count 16
  declared rows) and the item side to `SKILL.md:423–456` (or explicitly delegate the item side to
  R15-01/R15-05). Membership of the row id in the ledger is claim-count assurance, not closure.
- The checker's `fixed` pointer rule (`resolve_pointer`, POINTER-ID) requires the pointed file to
  contain the obligation's id token. **`corpus/checklist.tsv` does not contain "R15-04"**; the only
  file containing both the id and the command is `corpus/claim-ledger.tsv` — a self-referential
  pointer. Integration needs a row-pointer form (row id resolved in the ledger, data pointer
  checked separately) or a receipt/journal that names R15-04 and binds the data digest.
- If D9 ("Add a hermetic, host-free cells run over committed fixtures") is dispositioned `fixed`
  by pointing at a script, that pointer alone does not prove R15-04 ran. The receipt/pin must list
  the executed rows and the digests they read.
- `checklist-execution.md` may name R15-04 (`:11`) but its execution baseline is marked historical
  (`:195`); it cannot serve as current execution evidence.

## 7. Concrete consumer-visible false-clean + minimal synthetic falsifier

**Risk (false-clean).** A checklist row id outside the documented set passes every check. Rename
`E8` → `E9` in `corpus/checklist.tsv` (one field, still 16 rows, all other bytes identical):

- R15-04's command still prints `16`, exit 0 (`E9` matches `^[EH][0-9]+`).
- `checklist-run.sh` stays CLEAN: `E9` satisfies `^[A-Z][0-9]+$` (`:139`), is unique, and the
  unchanged lead still matches item 8; range and section/id mapping are unchecked.
- `checklist-execution.md:36` and the row's note ("E1-E8 evidence, H1-H8 handler") are then false
  while the ledger is green.
- A sharper variant of the same gap: swap the `lead` values of the `E1` and `H1` rows — both match
  exactly one item, so the bijection (`:209–228`) stays green while an Evidence row declares a
  Handler item.

**Minimal fixture proposal (for L1 to execute; not executed here).** In a scratch dir, copy
`corpus/checklist.tsv` and `SKILL.md`; replace the leading `E8<TAB>` with `E9<TAB>`, preserving all
other bytes (including the unterminated final line). Then:
1. `bash corpus/checklist-run.sh --tsv <scratch>/checklist.tsv --skill <scratch>/SKILL.md --ratio`
   → today exit 0, `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`
   (declaration+bijection pass; no row executed). **This is today's false-clean.**
2. Run the row's count command on the scratch TSV → today `16`, exit 0. **Same false-clean.**
3. L1 assertion: after the fix, (1) or (2) must fail (the mutated declaration is detected).

**Fix (smallest first).** Tighten R15-04's ERE to `^[EH][1-8][[:space:]]`: with 16 unique ids this
makes the set exactly `{E1..E8,H1..H8}` (E9 → 15 → row fails; duplicate ids are already refused by
the runner). Optionally add a runner check that `E` rows' leads match only Evidence items and `H`
rows' only Handler items (this needs section-aware item extraction and a re-pin of R15-02's pinned
34-case count; R15-01/03/05 outputs are unchanged). The ERE change costs nothing on committed data
(still 16).

## 8. Historical vs current evidence; limits

- **Historical**: introduction at `587fda0` (2026-09-28); round-15 CLEAN baseline (now marked
  historical by the round-22 erratum). Round-22 spot-check used the row as a safe/executed row.
- **Current**: the ledger row, `checklist.tsv`, `checklist-run.sh` and `SKILL.md` working-tree
  blobs all equal their `HEAD` blobs, and the R15-04 line is byte-identical at `587fda0`; the stamp
  digest matches; the round-22 receipt is the latest persisted observation and is consistent with
  current bytes. Its `.h1` (`8ada17a5`) differs from the measured commit (`4be5da3`, spot-check D6)
  — immaterial here because R15-04's only input predates both.
- **Limits**: no execution of the row/runner/gates; the 16-count is a static parse plus the
  persisted round-22 receipt. No persisted **ledger-mediated** run exists (the round-22 harness
  invoked argv directly; R13-03 cells was skipped), so `policy_check` acceptance for this command
  is static-only (first token `grep`; no metacharacter/deny-word/backslash match). The in-flight
  `closure-dispositions.py` may change; §6 applies to the copy read at 00:45. No public sources
  were used, so no external quote applies.
