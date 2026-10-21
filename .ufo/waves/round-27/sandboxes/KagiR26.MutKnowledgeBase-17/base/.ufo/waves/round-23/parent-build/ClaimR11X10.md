# ClaimR11X10 — R11-10 semantic audit (read-only, advisory)

Scope: the exact ledger row `R11-10`, nothing else. Axes: calibration, freshness, operability.
This is advice only. It carries no judgment or admission authority and changes no production file.

## Observed revision

- Frozen base: `d218603b74099ddca0bd8f869516fc41db0979bf` (`plans/round-23.md:3`).
- Row: `corpus/claim-ledger.tsv:24` at HEAD. The HEAD ledger sha256 is `e6806968…8305`, which equals the pin at `corpus/stamps.tsv:5`. The row is byte-identical from its introduction in `301b9ec` (round 11, 2026-09-28) through HEAD, and the worktree row is also identical.
- Input `corpus/state-shape.tsv`: blob `bb1490d4…`, sha256 `abf9ca14…ecac`, 53 lines, 4567 B. This equals `corpus/stamps.tsv:62`. The blob and the pin are the same at `8ada17a` (round-22 `h1`), at `4be5da3` (round-22 measured commit, spot-check D6) and at `d218603`. The worktree copy equals HEAD.
- Only two commits ever changed the input: `03477c0` (round 10) and `8ada17a`. `8ada17a` appended 5 `#` erratum lines, which does not change the count.
- The worktree holds in-flight, uncommitted L1 edits:
  - `claim-ledger.sh` lines 91-92 and 161 (`PYTHON_SCRIPT_RE`), edited in place
  - ledger rows R13-01 and R21-01..04, plus new rows R23-01 and R23-02
  - the round-23 sections of `SCORECARD.md`
  - `corpus/fixtures/cells-hermetic/` and `corpus/closure-dispositions.{py,json}`

  None of these changes R11-10 or its inputs. Every `claim-ledger.sh` line number cited below is the same at HEAD and in the worktree.

## Row under audit

`R11-10 | grep -cv '^#' corpus/state-shape.tsv | ^22$ | 0 | 30 | state-shape.tsv declares 22 rows and has no blank lines (so '^#' is an exact row count) (README/PROVINCE cited 20/21 before round 11)`

## Expected verdict, last line, exit and timeout: SUPPORTED at HEAD

- **Count.** An independent byte-level parse (Python, not the row command) gives:
  - 53 physical lines: 31 `#` lines and 22 data lines.
  - 0 empty lines and 0 CR characters.
  - All 22 data rows have exactly 5 TAB fields and start with `$`. The file ends with a final LF.
  - Kinds: 9 sqlite / 8 json / 3 log / 1 lock / 1 marker.

  A count that mirrors the census loader also gives 22. `03477c0` and `301b9ec` both give 22 data lines and 0 blank lines.
- **Last line.** `grep -c` on one file prints exactly one line. The harness takes the last non-blank line of the merged stdout and stderr (`claim-ledger.sh:427,436`). It matches `^22$`, which is anchored at both ends, so `122` or `220` would fail (`:441-442`).
- **Exit 0.** GNU grep exits 0 only when at least one line is selected (public quote below). Both failure paths fail closed:
  - A missing file gives exit 2.
  - Zero data lines prints `0` with exit 1.

  Either way the row FAILs with `exit-mismatch`. The harness runs the command in a child `bash -c`, which resolves to `/usr/bin/grep` (GNU grep 3.12).
- **Timeout 30.** The round-22 receipt took 0.003 s (`.ufo/waves/round-22/final-verification.json` `safe_rows[4]`). Selftest `claim-timeout` (`claim-ledger.sh:1296`) proves the timeout path. 30 s is generous and not flaky.
- **Policy.** The first token `grep` is allowed. The command has no metacharacter, backslash, empty quote pair or denied word.

## Causality versus a count of authored lines: the note's premise is REFUTED as a mechanism

What consumers read as the claim is "22 shape assertions that `surface-census.sh` evaluates":
- `corpus/README.md:42`: "22 rows (count pinned by ledger row `R11-10`)"
- `PROVINCE.md:46`
- `SCORECARD.md:61,83`: "22 runtime shape pins … Pinned by `R11-01`, `R11-10`, `R11-11`"
- `corpus/knowledge/surface-census.md:5,14`

The command instead measures a stand-in: physical lines that do not start with `#`. The shape loader trims leading tabs (IFS whitespace), then skips any line whose first field is empty or starts with `#` (`surface-census.sh:333-336`).

The stand-in equals the real count only if the note's premise "has no blank lines" holds, and the command never checks that premise. QM13 (`corpus/QUALITY.md:72`) says an authored count is not calibration.

The same class was already found and fixed elsewhere in this repo, but never here:
- **Round 12, stamps file.** `corpus/lessons/round-12.md:107` records a "blank-line substitution that passes a `grep -c` count while `verify` loses a row".
  - The stamps loader now refuses blank lines (`claim-ledger.sh:324-326`; selftest `stamps-blank-row` at `:1347-1349`).
  - R12-03 counts non-blank lines, "not `^#`-inverted" (`corpus/knowledge/claim-ledger.md:374-377`).
- **R16-05.** It already uses `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv`, and it passed the round-22 safe-row run.
- **Round 10, this file.** The `daybreak-blue-access.json mode 600` assertion was silently dropped while the summary still read CLEAN (`corpus/lessons/round-10.md:78-84`).
  - That happened through a fused row. The loader now refuses fused rows (`surface-census.sh:337`), and R11-10 would also catch one (count 21).
  - The blank-line route is caught by neither.

## `[substrate]`, SKIP-SELF, hermetic and synthetic modes

- **`[substrate]`.** The note carries no tag, so the row is never deferred (`claim-ledger.sh:416-418`). That is correct: its only input is a committed repo file. The round-22 safe-row classification agrees.
- **SKIP-SELF.** The skip rule is a substring match `*claim-ledger.sh*` on the command (`claim-ledger.sh:811-820`). R11-10 does not match, so `cells` re-runs it whenever a cell cites it. Two cells do: `SCORECARD.md:61` (Round 11 pre-move) and `:83` (Round 12 pre-move).
- **Synthetic and hermetic modes.**
  - The ledger selftest proves the harness behaviour R11-10 relies on: `verdict-not-final` (`:1294`, `:1317`), `exit-mismatch` (`:1295`), `timeout` (`:1296`) and anchor refusal (`:1333`).
  - The census selftest only reads its own scratch `$R/shapes.tsv` (`surface-census.sh:762-764`), never the shipped file.
  - So the harness half of the obligation is preserved. No mode proves the data half (the note's premise).
- **No other guard on this file's content.**
  - R11-01 is tagged `[substrate]`, so it is deferred on hosts without the handler. Its expectation accepts any positive `ok=`.
  - R11-03 uses scratch data.
  - The drift pins never mention the file.
  - The stamp at `corpus/stamps.tsv:62` catches an unreviewed edit, but only in `verify` (`:970`) and only until a restamp. Restamping is the reviewed workflow (`claim-ledger.sh:18`), and QM5 requires it alongside any edit.
  - `cells` runs only `idref_audit`, `cells` and `cells_evidence` (`:998-1000`). Cells 61 and 83 cite no `state-shape.tsv` path, so the stamp never protects them.

## Consumer-visible risk and minimal synthetic falsifier

This is a proposal for L1 and was not executed. Outcomes are predicted from documented grep and bash behaviour plus reading the code.

**F1: false-clean.**

Setup (scratch only):
1. Create `R=$(mktemp -d)` and `mkdir -p $R/corpus`.
2. Copy `corpus/state-shape.tsv` into the scratch tree.
3. Replace physical line 47 with an empty line, keeping the newline. Line 47 is `$HOME/.local/state/tac/daybreak-blue-access.json<TAB>json<TAB>mode<TAB>600<TAB>…`, the same assertion round 10 lost.
4. Write a scratch claims row that copies R11-10 exactly, and a scratch doc that cites `R11-10`.
5. Stamp the mutated scratch file with `claim-ledger.sh stamp --root $R --out $R/stamps.tsv corpus/state-shape.tsv`. This models the reviewed restamp.
6. Run `claim-ledger.sh verify --root $R --claims $R/claims.tsv --stamps $R/stamps.tsv --docs $R/doc.md`.

What should happen: FAIL, because 21 assertions are evaluated but 22 are published.

Predicted result:
- grep prints `22` and exits 0, so the row passes. The summary is `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 …)` with exit 0.
- The census loader skips the empty line (`surface-census.sh:335`) and evaluates 21 rows without any error.
- `CELL_AUDIT: CLEAN` stays green for cells 61 and 83.
- README, PROVINCE and SCORECARD still say 22 are pinned.

**F1b.** Replace line 47 with `<TAB># retired` instead. grep counts the line. The `IFS=$'\t' read` call trims the leading tab, so the loader sees `# retired` and skips it (`:336`). Same false-clean.

**F2: false-fail.** Append one empty line at the end of the file. grep prints `23`, so the row FAILs with `verdict-not-final`. Meanwhile the loader still evaluates 22 rows, and every published "22" is still true.

## Recommendation for L1 (needs a QM14 migration record)

- **Command.** Change it to `grep -cE '^[^#[:space:]]' corpus/state-shape.tsv`, the form R16-05 already uses. Keep expect `^22$`, exit `0` and timeout `30`.
  - The new form gives 22 at HEAD, `03477c0` and `301b9ec`, so the expectation does not change.
  - It passes the policy check: no `$`, no backslash, no metacharacter.
- **Note.** Remove the unchecked premise and state what the command actually checks. For example: "counts lines whose first byte is neither `#` nor whitespace — the rows `surface-census.sh`'s shape loader evaluates; blank/indented lines are not rows".
- **QM14 record.** Include the old and new command and note, the motivation (the `lessons/round-12.md:107` class plus this report), and these checks. They count only once actually run:
  - (a) the new command on HEAD gives `22`
  - (b) F1 and F1b give `21`, so the row FAILs with `verdict-not-final`
  - (c) F2 gives `22`, so the row passes
- **What the fix still misses.**
  - A data row indented with a TAB would not be counted, even though the loader trims the tab and evaluates it. That is a false-fail, the safe direction.
  - The row pins how many assertions there are, not which ones. Swapping one assertion for another keeps the count at 22. Identity is the stamp's job, and only until a restamp.
  - It pins the total, not the split by kind.
- **Stronger alternative, not recommended as the minimal change.** Make the shape loader refuse blank lines the way the stamps loader does. That touches another surface (`surface-census.sh`) and moves R11-03's selftest count.

## What C3 and C1 integration must keep for R11-10

### C3: hermetic cells (R23-01, uncommitted worktree as observed)

- The fixture uses fixture-local ids R90-01 and R90-02. Its data, claims, stamps, scorecard and docs all live under `corpus/fixtures/cells-hermetic/`. It neither runs nor claims R11-10, so R11-10's obligation is preserved by being left out.
- Keep it that way: never reuse production ids in the fixture, and never copy `state-shape.tsv` into it.
  - With `--root` set to the fixture, a production row runs with the fixture as its working directory (`claim-ledger.sh:426`).
  - It would then measure a copy (false-clean) or a missing file (exit 2, false-fail).
- R23-01's CLEAN must not be read as a re-run of R11-10 or of cells 61 and 83.
  - The production `cells` row R13-03 is still deferred on hosts without the handler.
  - R11-10 itself is still discharged directly by `verify` (it carries no tag) and by the safe-row run.
- If a fixture count row ever copies R11-10's form, use the corrected form. Copying the current form would build F1 into the fixture.

### C1: closure dispositions (R23-02, uncommitted worktree as observed)

- C1 has no R11-10 obligation, and `closure-dispositions.json` has no pointer at R11-10 or `state-shape`.
- Keep that: a count row must never be the `fixed` pointer for an obligation that is not about counts. A pointer that resolves is not proof of relevance (`closure-dispositions.py:41-45`; `corpus/knowledge/claim-ledger.md:421-426`).
- D6 is marked `fixed` going forward: the round-23 verdict file carries `measured_commit` (`corpus/lessons/round-23.md:99-101`).
  - D6 does not affect R11-10's round-22 receipt, because the bytes are identical across `h1`, the measured commit and the base.
  - The round-22 inputs record bound 7 files but not `state-shape.tsv`. It reached that file only indirectly, through the pin at `stamps.tsv:62`.
  - Keep: the round-23 `final-verification.json` should list R11-10 with `measured_commit`, which binds commit to tree to blob.

## Historical versus current

**Historical:**
- Round 10: the fused-row drop (`corpus/lessons/round-10.md:78-88`).
- Round 11: the row was created because docs said 20 or 21 (ledger header `:11-14`; `LOG.md:283-285`).
- Round 12: the blank-line class was fixed for stamps only.
- Round 13: R11-10 was named as the example of an irrelevant cell pointer (`corpus/lessons/round-13.md:100`; `corpus/knowledge/claim-ledger.md:421-426`).
- Round 14: R11-10 was rejected for three Reverify links and kept only on `surface-census` (`corpus/lessons/round-14.md:83-92`).
- Round 22:
  - The safe-row receipt: argv `grep -cv ^# …`, exit 0, last line `22`, passed, `h1=8ada17a5`.
  - `.ufo/waves/round-22/build/Entry21.md:71-73`: R11-10 pins only the total.
- `corpus/knowledge/surface-census.md:5` still lists "9 json". That split adds up to 23 and the real figure is 8. The round-22 erratum (`corpus/knowledge/surface-census.md:295-297`) already supersedes it, so this is not a new finding.

**Current:**
- `^22$` holds by byte identity at `d218603`. It is not re-executed here.
- The premise holds today (0 blank lines) but nothing enforces it.

## Public sources (fetched 2026-10-21)

- grep(1), §OPTIONS › General Output Control, https://man7.org/linux/man-pages/man1/grep.1.html — "With the -v, --invert-match option (see above), count non-matching lines."
- grep(1), §EXIT STATUS, same URL — "Normally the exit status is 0 if a line is selected, 1 if no lines were selected, and 2 if an error occurred."
- bash(1), §EXPANSION › Word Splitting, https://man7.org/linux/man-pages/man1/bash.1.html — "Word splitting begins by removing sequences of IFS whitespace characters from the beginning and end of the results of the previous expansions"
- bash(1), §SHELL BUILTIN COMMANDS › read, same URL — "split the line into words using the same rules the shell uses for expansion (described above under Word Splitting)."
- Installed versions: GNU grep 3.12 (package `grep 3.12-2`), GNU bash 5.3.20.

## Outcome summary

| Observation | Status |
|---|---|
| `^22$`, exit 0 and timeout 30 are justified at HEAD and at every committed revision of the input | supported |
| Not tagged `[substrate]`, so never deferred; not SKIP-SELF, so always re-run when cited | supported |
| Note premise "has no blank lines (so '^#' is an exact row count)" is enforced by the command | refuted |
| "Pinned by R11-10" guarantees 22 evaluated assertions (README:42, PROVINCE:46, SCORECARD:61,83) | refuted under F1/F1b |
| C3 fixture preserves R11-10 by leaving it out | supported (in-flight; may change) |
| Round-23 receipt will bind R11-10 with `measured_commit` | unresolved (file not yet present) |
| F1, F1b and F2 outcomes | predicted, not executed |

## Limits and deviations

- **Deviation.** In one early tool call I ran the row's literal command text once, read-only, in the agent tool shell. In that shell `grep` is a harness builtin (`pi-uu-grep 0.2.0`), not GNU grep, and it printed `22`. This did not go through the ledger harness. It is not a gate verdict and it is not used as evidence here: every count above was re-derived with a Python byte parse.
- I did not execute any ledger mode, census run, selftest, sibling gate, handler, or op, vault or host command. I did not execute any falsifier.
- Worktree observations about R23-01, R23-02, the fixture and the round-23 SCORECARD sections are of uncommitted, in-flight work.
- R11-11 uses the same command form. It belongs to ClaimR11X11; I sent them an FYI and did not audit it here.
- Tools: nothing installed or updated. I used read-only git (`rev-parse`, `log`, `show`, `hash-object` without `-w`, and `--no-optional-locks`), python3 for parsing, local man pages, and the man7.org pages above.
