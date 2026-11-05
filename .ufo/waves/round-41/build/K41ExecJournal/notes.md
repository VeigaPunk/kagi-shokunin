# K41ExecJournal notes — C1 gate corpus/expect-journal.sh

Sandbox: S=/fast/scratch/hyaku/kagi-r41/K41ExecJournal; clone of the lane, detached at 5142b52
(`git rev-parse --show-toplevel` = $S/work, asserted before writes). Gate file:
$S/work/corpus/expect-journal.sh (14758 bytes).

## Gate identity

sha256sum corpus/expect-journal.sh =
807501052598f05c162d780e4e327697a155d0369a0fd3ecf29a354489343756

## Measurements (exact commands, exit codes)

Every git call named `-C $S/work` explicitly; no command wrote into the lane tree.

(a) Selftest
- `bash $S/work/corpus/expect-journal.sh --selftest`
- stdout+stderr: `EXPECT_JOURNAL_SELFTEST: PASS (cases=7)`, exit 0 (saved: selftest.txt)
- scratch `selftest-$$` removed on exit; verified 0 `selftest-*` dirs remain.

(b) P0 run on real committed bytes
- `git -C $S/work show 6cc8850dfc5757927699e5a53a876f47c8df21aa:corpus/claim-ledger.tsv > $S/p0run/base.tsv` (rc=0)
- `git -C $S/work show 6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0:corpus/claim-ledger.tsv > $S/p0run/p0.tsv` (rc=0)
- `git -C $S/work show 6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0:.ufo/waves/round-40/expectation-migrations.json > $S/p0run/journals/expectation-migrations.json` (rc=0)
- `bash $S/work/corpus/expect-journal.sh --base-ledger $S/p0run/base.tsv --ledger $S/p0run/p0.tsv --journals $S/p0run/journals`
- output: `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, exit 0 (saved: p0-run.txt) — frozen expectation met.
- Ledger shape verified: both revisions have 86 rows, no duplicate ids, exactly the six frozen ids
  (R13-01, R21-02, R24-06, R31-02, R33-02, R34-03) differ, expects only (commands identical).

(c) Frozen C1 counter at the candidate
- `EXPECT_JOURNAL=$S/work/corpus/expect-journal.sh bash $S/work/plans/round-41-c1.sh`
- reading 1 (first AND final; no gate fix was needed): `4`, exit 0 (saved: c1-counter-readings.txt)
- target N=4 met; positive control P0 accepted (rc 0) inside the counter.

(d) Blanket controls (counter with synthetic gates)
- refuse-all gate (`EXPECT_JOURNAL: REFUSED (violations=1)`; exit 1): counter read `0`, exit 0
- accept-all gate (`EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)`; exit 0): counter read `0`, exit 0
- both saved with rc in controls-self.txt; both must be 0 and are 0.

Extra behavior probes (not required by the plan; recorded for the reviewer)
- missing base file: exit 2, stdout 0 bytes, stderr `expect-journal: setup error: base ledger not readable: ...`
- unreadable journal JSON: exit 2, stdout 0 bytes, stderr `expect-journal: setup error: unreadable journal json ...`
- journal id absent from the candidate ledger: `EXPECT_JOURNAL: REFUSE MISSING_ROW ZZ-99` +
  `EXPECT_JOURNAL: REFUSED (violations=1)`, exit 1.

## Implementation decisions (all inside the frozen rules; none reinterpreted)

- Ledger parse: tab-separated; lines starting with `#` and empty/whitespace-only lines skipped;
  a row with fewer than 3 columns is an unreadable ledger (setup, exit 2); a duplicate id within one
  ledger is an unreadable ledger (setup, exit 2). Both pins have neither.
- Journals: every `*.json` under `--journals`, recursive; a JSON without a `migrations` list, a
  non-object entry, or an entry missing any of the four string fields (id, command, old_expect,
  new_expect) is an unreadable journal (setup, exit 2). Empty `migrations` is valid.
- changed row = present in both ledgers with command or expect differing from base. `changed=` counts
  those rows; `journaled=` counts changed rows having at least one migration entry.
- Multiple entries with the same id (any journal): every entry must satisfy the R2 equalities;
  violation lines deduplicate by (class, id) so each violation is one line.
- R3 is positional: expect[0] == '^', expect[-1] == '$'; interior walked left to right, a backslash
  escapes the next character, any unescaped metacharacter of `.[]()*+?{}|^$` is NOT_LITERAL; a
  dangling interior backslash (escapes nothing inside the interior) is NOT_LITERAL (fail closed).
  R3 fires only when the expect itself changed; a command-only change (F4 shape) does not fire R3.
- R4 orphans: journal id present in the candidate ledger whose row did not change →
  `EXPECT_JOURNAL: WARN ORPHAN <ID>`, printed before refusal lines, sorted; never refuses.
  An id in the candidate ledger but absent from base is also unchanged → ORPHAN.
- MISSING_ROW: journal id absent from the candidate ledger → refusal (per the seat assignment's
  frozen token list).
- Output order: WARN lines, then REFUSE lines (sorted by class, id), then the final
  CLEAN/REFUSED line. Nothing else is printed on stdout; setup errors print stderr only, exit 2.
- Normal mode writes no files anywhere. `--selftest` builds all fixtures under
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41ExecJournal/selftest-$$` from committed bytes
  (BASE 6cc8850 ledger, P0 6f1588c ledger + round-40 journal, fetched via `git show` against the
  repo root that contains the gate), builds F1–F4 exactly per plans/round-41.md §C1, and removes
  the fixture dir on exit (trap). Selftest failure exits 1 with
  `EXPECT_JOURNAL_SELFTEST: FAIL (<case>)` on stderr.
- Selftest cases (7): P0 accept (CLEAN changed=6 journaled=6); F1→UNJOURNALED R13-01;
  F2→OLD_MISMATCH R21-02; F3→NOT_LITERAL R13-01; F4→COMMAND_MISMATCH R24-06; literal anchored
  expect `^2 \(two\) items$` accepted (CLEAN changed=1 journaled=1); orphan entry warns
  (`WARN ORPHAN ORP-01`, CLEAN changed=0 journaled=0). Each case asserts exit code and exact lines.

## Defects

- None found in the gate (counter read 4 on the first run; no gate fix, no rerun).
- plans/round-41*.sh untouched; no counter or plan defect observed.
- Tool installs: none.

## Deliverables (this directory)

expect-journal.sh (byte copy, sha256 above), selftest.txt, p0-run.txt, c1-counter-readings.txt,
controls-self.txt, gate-sha256.txt, notes.md. Seat report: ../K41ExecJournal.md.
