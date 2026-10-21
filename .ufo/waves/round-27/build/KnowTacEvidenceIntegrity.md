# KnowTacEvidenceIntegrity — round-27 C1 inventory

| item | value |
|---|---|
| agent | `KagiR26.KnowTacEvidenceIntegrity-17` (leaf scout; no subagents) |
| frozen BASE | `0a47dd189356ea66ec83c3891eed54526e95b89b` |
| target | `corpus/knowledge/tac-evidence-integrity.md` (92 lines / 4437 bytes / sha256 `d53339af7683bb5036621ee620c75a68e476f0b960515f65f817cb6179023191`) |
| target identity | byte-identical at `0a47dd1:`, `144babc:` and the working tree (same sha/lines/bytes); `corpus/stamps.tsv:49` at both revisions carries the same tuple |
| scope | C1 inventory only. No production writes, no host reads, no gate runs, no installs |
| report | this file only |

**Revision hygiene.** The assignment's frozen BASE is `0a47dd1`; BASE citations below use
`git show 0a47dd1:<path>`. During this audit HEAD advanced to `144babc` ("round-27:
knowledge numbers bound; numeric release regression refused (candidate)"), which commits
the after table and the C2 change. The target entry is byte-identical at BASE, at
`144babc`, and in the working tree, so its line numbers and stamp are unaffected. At
report time the only modified production path is `corpus/lessons/round-27.md`; the wave's
reports/tools under `.ufo/waves/round-27/` are untracked or modified. Citations to
`self-counts.tsv`, `stamps.tsv`, `QUALITY.md`, `README.md` and `claim-ledger.tsv` use
`git show` at the stated revision.

## Godspeed axes

| axis | move in this slice |
|---|---|
| calibration | classify every digit in the entry; bind only where a lane-local source exists; never print `OK` without a committed pin |
| freshness | separate a dated/erratum-declared historical measurement from a current value; do not re-measure absent substrate |
| evidence | exact BASE `path:line` citations, committed-pin values, and a tested one-group locator per candidate |
| scope | read-only; no `drift-pins`, `surface-census`, `claim-ledger`, `self-counts`, or `release-clock` execution |

## Verdict (read first)

1. **Zero numbers in this entry are bindable in `corpus/self-counts.tsv` under the three
   permitted source forms (`rows:`, `ledger:`, `expect:`).** The round-27 candidate
   `144babc` (60 data rows, 22 of them knowledge entries; BASE `0a47dd1` has 38) has no
   `KN-*` row for this entry, and that exclusion is correct under both readings of its one
   ambiguous date (current vs. historical): no source form can extract the values either
   way.
2. **Eight near-candidates were found** — the `88` size, five `L…` ranges, the `9-line`
   block count, and one host field value (`confirmed_recipients: 0`). Two rows
   (`TAC-SIZE-88` and the `63`/`69` anchors inside `TAC-LOC-OUTPUT`) agree with committed
   pins; the rest have no pin and/or no in-repo source to compare against. None is a pass.
3. **No stale number is provable from committed evidence.** The only stale source pointer
   in this entry's history (the `~/.agents/AGENTS.md` janitor-quote attribution) was
   already withdrawn by the BASE erratum at
   `corpus/knowledge/tac-evidence-integrity.md:82-92`.
4. **C2 does not apply to this entry.** It contains no release clock, no `on-release`
   line and no version anchor, so the round-27 regression rule has nothing to order here.
5. The complete digit census is 25 lines (below); every digit-bearing line of the 92 is
   classified. **A one-digit mutation of `88` or `9` in this file would leave the
   `self-counts.py` binder CLEAN** — there is no id to mutate (inferred from the absent
   row; the binder was not run). (The separate `claim-ledger` stamp gate would flag the
   file's changed bytes, but it cannot see which digit changed.) That is a named limit of
   the round's mutation claim, not a pass.

## Population rule applied

The assignment applies the round-25 rule, quoted from BASE:

- `corpus/QUALITY.md:118` (QM21): a current-tense number a committed doc states about this
  lane's own artifacts is bound to the live source that defines it; a "round N" tag alone
  does not make it historical; an explicit history clause with a newer value beside it does.
- `corpus/lessons/round-25.md:49-57` (R25-C6): current = states an artifact's present size
  with no newer value in the same clause; an explicit history clause ("63 at round 21",
  dated Round-N bullets) is out. R25's bound population covered SKILL/PROVINCE/README;
  knowledge entries were left as named debt.
- BASE `corpus/self-counts.tsv:3-14`: the population is selected lane-artifact numbers
  **that have a lane-local live source**; out of population by rule are round-dated
  history clauses, **host measurements**, and counts with no machine source. Sources:
  `rows:<file>` counts nonblank/non-comment data lines; `ledger:<ID>` runs a non-host
  row's command and reads its last-line verdict; `expect:<ID>` reads a host/substrate
  row's committed expectation regex and runs nothing.

Applied here: line 3's `88` is a **dated measurement** ("read 2026-09-28") and the
source-layer facts above are declared historical by the entry's own erratum (`:82-92`:
"receipt fields, custody paths, checker output and handler behavior above belong to their
original measurement"). The five `L…` ranges are present-tense locators, but they point
into a **host file** (`~/.local/bin/tac-check`) whose committed representation is limited
to TSV fields, two symbol pins, and the quoted output block — none of the three source
forms. The `9-line` count is a self-count of the entry's own quoted block (covered by the
erratum's "checker output … above"), for which no permitted source exists; if a reader
rejects that coverage, the count is still unbindable, so the row count stays 0. Therefore
this entry contributes **0 rows** to the binding table; the lesson's host/substrate
exclusion class covers it, but the specific source-form gap (a TSV field pin cannot be
read by `rows:`/`ledger:`/`expect:`) is not named and should be.

## Identity and freshness of the entry itself

| check | observation |
|---|---|
| `sha256sum` at working tree | `d53339af…` / 92 lines / 4437 bytes — exact |
| `git show 0a47dd1:… \| sha256sum` | `d53339af…` — committed bytes identical |
| `git show 144babc:… \| sha256sum` | `d53339af…` — candidate bytes identical |
| `git show 0a47dd1:…` / `git show 144babc:…` `\| wc -lc` | `92 4437` — exact at both revisions |
| `corpus/stamps.tsv:49` (BASE, candidate and working tree) | `corpus/knowledge/tac-evidence-integrity.md d53339af… 92 4437` — exact |
| `git status --porcelain -- <entry>` | empty — not modified by the wave |
| declared reverify rows (`:7`) | `R11-01`, `R11-04`, both `[substrate]` at BASE `corpus/claim-ledger.tsv:15,18` |

The erratum already says the substrate is missing and that "deferred rows are not passes"
(`:84-87`). That is the only freshness statement this entry makes about itself; it is
honest and needs no rearm. I did not re-measure the substrate (contract).

## Near-candidates — the only present-tense artifact numbers

None of these is in population. The `status` column gives `STALE`/`OK` only where a
committed pin exists, and marks it historical — it is never a live pass. The locators were
tested at BASE: each is a Python regex with exactly one capture group and matches exactly
one line of the 92.

| id | line | exact text (BASE) | source form attempted | pinned live value | status | locator (one group) |
|---|---|---|---|---|---|---|
| TAC-SIZE-88 | 3 | ``Source: `~/.local/bin/tac-check` (88 lines, read 2026-09-28),`` | `rows:corpus/drift-baseline.tsv` → 15 (data lines), not 88; `ledger:R11-04` → `[substrate]`, verdict has `files=… symbols=…`, no 88; `expect:R11-04` → regex captures `files`/`symbols`, no 88 | `88` — `corpus/drift-baseline.tsv:10` field 3 (sha `af95ca97…` field 4) | OUT (dated measurement); OK-vs-pin (historical); **not** a live check | `\(([0-9]+) lines, read 2026-09-28\)` |
| TAC-LOC-PATHS | 12 | `check over one receipt file. Hardcoded paths (L83–88):` | none — no row, verdict or pin carries 83–88 | — | OUT (host locator, no lane-local extractor); UNVERIFIED (substrate absent) | `Hardcoded paths \(L([0-9]+)–88\):` |
| TAC-LOC-FIELDS | 18 | ``fixed set of `live_model_check` fields (L19–31): `status: succeeded`,`` | none — no pin for 19–31 | — | OUT (host locator); UNVERIFIED | `fields \(L([0-9]+)–31\)` |
| TAC-LOC-OUTPUT | 25 | `Success output vocabulary (L63–71), safe to quote verbatim in handoffs:` | none — `rows:corpus/drift-symbols.tsv` → 20 (data rows), not 63/71; `expect:R11-04` has no 63/71 | `63` (`drift-symbols.tsv:26`, `LOCAL_RECEIPT_INTEGRITY: OK`) and `69` (`:27`, `LIVE_ACCESS_NOW`); `71` unpinned | OUT (host locator); OK for 63/69 anchors (historical); 71 unpinned; **not** a pass | `Success output vocabulary \(L([0-9]+)–71\)` |
| TAC-LOC-REGISTER | 42 | ``  `0700` dir (L36–49): it **never replaces** an existing record — a tampered`` | none — no pin for 36–49 | — | OUT (host locator); UNVERIFIED | `\(L([0-9]+)–49\):` |
| TAC-LOC-CHECKSUM | 43 | `  receipt just fails the later checksum comparison (L52–58), not silent` | none — no pin for 52–58 | — | OUT (host locator); UNVERIFIED | `checksum comparison \(L([0-9]+)–58\)` |
| TAC-BLOCK-LINES | 78 | ``- `the-janitor tac-check` → the 9-line output block above, exit 0.`` | none — self-count of the fenced block; `rows:` cannot count fenced lines, and no ledger/pin carries 9 | self-count `9` — block lines 28–36 (enumerated: 9 lines) | OUT (no lane-local source); count is accurate but unbound | `the ([0-9]+)-line output block above` |
| TAC-RECIPIENTS-0 | 70 | ``  `current_l1_relay.confirmed_recipients: 0`,`` | none — `corpus/state-shape.tsv:45-46` pins mode + key **names** only, note "presence only"; no value read | — (no value pin exists) | OUT (host field value; erratum historical); UNVERIFIED | `confirmed_recipients: ([0-9]+)` |

Notes on the four that have committed anchors:

- **`88` (`:3`)** — the committed `drift-baseline.tsv:10` row is `path <TAB> mode <TAB>
  lines <TAB> sha256` (`corpus/drift-pins.sh:9` documents the schema), so field 3 `88`
  is the same quantity. It matches, but it is a **field of a data row**, not a data-row
  count; `rows:` yields 15, and `R11-04`'s verdict does not print the line count. The
  date makes it historical under QM21; even without the date it would be unbindable.
- **`L63–71` (`:25`)** — the block at `:28-36` has `LOCAL_RECEIPT_INTEGRITY` first and
  `LIVE_ACCESS_NOW` seventh. With the pin `63 = LOCAL_RECEIPT_INTEGRITY`, the seventh
  line is `63 + 6 = 69`, matching `drift-symbols.tsv:27`; nine lines starting at 63 end at
  `71`. This is arithmetic consistency between two data-field pins and two entry
  assertions, not an independent measurement of `71`. It is the only pair of committed
  content anchors for any locator in this entry.
- **`L19–31`, `L36–49`, `L52–58`, `L83–88`** — no drift-symbols row and no baseline field
  pins these positions. They cannot be checked without reading the host script, which is
  absent and which this seat is forbidden to read; the round-22 audit
  (`.ufo/waves/round-22/build/Entry22.md` §3, a prior wave artifact, untracked in this
  checkout) already recorded that no in-repo copy of the script exists, and the
  string searches below found no plain-text copy.
- **`0` (`:70`)** — the shape pin is deliberately presence-only; a recipient count that
  changed to `1` would not be caught by `drift-pins` (it compares path/mode/lines/sha or
  the pinned symbol lines, not JSON values). The erratum is the only thing preventing
  this from reading as a current claim.

**No paste-ready `self-counts.tsv` block is emitted.** `load_claims` accepts only the three
source forms; every candidate's only possible slot would be rejected (a `[substrate]`
`ledger:`) or bind a different quantity (`rows:` row count instead of field 3). The table
above is the inventory, not a binding.

## Complete digit census — 25 of 92 lines

Every digit-bearing line is listed; lines with no digit are omitted. Classes: **CAND**
= near-candidate analysed above; everything else is excluded with the reason shown.

| line | token(s) | class | disposition / exclusion reason |
|---|---|---|---|
| 3 | `88`; `2026-09-28` | CAND; DATE | `88` → TAC-SIZE-88; date = reading date (dated measurement) |
| 7 | `R11-01`, `R11-04` | ID | claim ids, not counts; declaration has no numeral |
| 12 | `L83–88`; `one` | CAND; SPELLED | range → TAC-LOC-PATHS; "one receipt file" is a design fact, not a variable size |
| 17 | `1` | CONSTANT | `schema_version == 1` is a protocol value the checker validates, not an artifact size |
| 18 | `L19–31` | CAND | → TAC-LOC-FIELDS |
| 21 | `0` | CONSTANT | `exit_code 0` is a required receipt field value |
| 22 | `0` | CONSTANT | `tool_events_observed 0` is a required receipt field value |
| 23 | `1` | EXIT | process exit code on failure |
| 25 | `L63–71` | CAND | → TAC-LOC-OUTPUT |
| 33 | `256` | NAME | `SHA256` algorithm name |
| 41 | `0600` | MODE | file permission bits |
| 42 | `0700`; `L36–49` | MODE; CAND | mode bits; range → TAC-LOC-REGISTER |
| 43 | `L52–58` | CAND | → TAC-LOC-CHECKSUM |
| 45 | `256` | NAME | `receipt_sha256` field name |
| 57 | `256` | NAME | `SHA-256` algorithm name |
| 59 | `2026-09-06` | DATE | dated historical attestation |
| 60 | `2026-09-06`; `one` | DATE; SPELLED | date; "one benign challenge" is a dated historical observation |
| 69 | `1` | NAME | `L1s` identifier/acronym, not a count |
| 70 | `0` | CAND (host) | → TAC-RECIPIENTS-0; host field value, no value pin |
| 71 | `false` | BOOL | `all_current_l1s_notified: false`; host field, not a count |
| 74 | `0600`, `0700` | MODE | permission bits |
| 78 | `9`; `0` | CAND; EXIT | block count → TAC-BLOCK-LINES; `exit 0` is a process status |
| 79 | `one`; `1` | SPELLED; EXIT | "one byte" is a mutation action; `exit 1` is a process status |
| 82 | `22` | ROUND | `Erratum (round 22 …)` history tag |
| 92 | `22` | ROUND/PATH | `round-22/build/Entry22.md` audit path |

Spelled/ordinal quantities with no digit are also out: `one receipt file` (`:12`),
`one benign challenge` (`:60`), `one byte` (`:79`), `second run` / `twice` (`:80`). They
are descriptions of a historical observation or a test action, not artifact sizes.

## What a valid binding would require (and why none is proposed)

- `rows:` cannot bind `88`: it counts nonblank/non-comment lines of a file
  (`corpus/self-counts.py`, `load_claims`: `rows:` requires extract `-`). It would compare
  `88` against `15` and report a false STALE. The candidate's own
  `KN-DRIFT-BOUND-FILES` row (`corpus/self-counts.tsv` at `144babc`) already binds `15`
  from `rows:corpus/drift-baseline.tsv`, confirming that this source yields the baseline's
  row count, not field 3.
- `ledger:R11-04` cannot be used at all: `self-counts.py`'s `ledger_command` refuses any
  ledger row whose note contains `[host]` or `[substrate]` (`corpus/self-counts.py:259-260`),
  and R11-04 is `[substrate]` (`claim-ledger.tsv:18`). In any case its last-line verdict is
  `DRIFT_PINS: CLEAN (files=N symbols=M)` — no `88`, `63`, or `71`.
- `expect:R11-04` runs nothing, but its committed regex captures only `files=N` and
  `symbols=M` (`claim-ledger.tsv:18`). There is no group for the line count or a symbol
  line number.
- The `drift-symbols.tsv` line numbers (`63`, `69`) are **fields of data rows**, not
  row counts; `rows:corpus/drift-symbols.tsv` would yield `20`.
- Binding any of these would need a new source form that reads a TSV field or a committed
  file's internal line (e.g. `field:<path>:<key>:<column>`), with its own selftest cases.
  That is a binder capability change, not a C1 document edit, and is **not** proposed for
  this round. The correct move is to name the exclusion.

## Counterexamples and named gaps for L1

1. **`corpus/README.md:22` carries the same number, undated and unbound.** BASE line:
   ``| TAC / local-evidence integrity | `knowledge/tac-evidence-integrity.md` | `~/.local/bin/tac-check` (88 lines), … |``
   BASE `corpus/self-counts.tsv` has 38 data rows and **no row containing `88`, `tac`, or
   `local-evidence`** (checked with `git show 0a47dd1:corpus/self-counts.tsv`; the
   candidate `144babc` table has 60 rows and also no such row). It is out of
   population if "host measurements" covers a host file's size, but the header's examples
   name "breadth, handler/DB counts", not file-size pins. No README-row locator matches
   that line (tested at BASE: zero hits for all `corpus/README.md` rows against line 22),
   so mutating `README.md:22` 88→89 leaves the `self-counts.py` result CLEAN; only the
   stamp gate would flag the changed bytes. If the host-measurement exclusion is
   intended to cover this, **name it** in the round-27 exclusion note so the mutation
   limit is explicit.
2. **Line 3 is the judgment call, and both readings end in "no row".** If `read
   2026-09-28` is provenance and the number is current, the entry has one current number
   whose only committed source is `drift-baseline.tsv:10` field 3 — unreadable by the
   three source forms. If the date makes it history, QM21 excludes it. Either way the
   table gains no row; the lesson should say which reading it used rather than implying
   the entry has no numbers at all.
3. **`confirmed_recipients: 0` has no value-level pin anywhere.** `state-shape.tsv:45-46`
   pins mode 600 and the key set with the note "presence only". If the substrate is
   restored and the relay count changes, no lane gate notices; only the erratum's
   historical clause prevents a current-claim reading. Keep that clause.
4. **The one-digit mutation control cannot reach this entry.** `c1-measure.py --mutate
   <id>` needs a table row; this entry has none. A mutation of `88` (`:3`) or `9` (`:78`)
   leaves `self-counts.py` CLEAN (inferred from the absent row; not executed; the stamp
   gate flags only the byte change). Do not present the mutation control as covering all
   knowledge digits; the round-27 lesson's "not every digit" limit already says this, and
   this entry is a concrete instance.
5. **Range locators can bind only one endpoint.** All five locators above fix the second
   number as a literal (e.g. `–88`) and capture the first. If a future `field:` source is
   added, a range would still need either two rows or a literal endpoint; one capture
   group cannot assert both. This is a schema limit, not a defect in the entry.
6. **`Reverify: R11-01, R11-04` is structurally checked only as a total.** BASE
   `claim-ledger.tsv:32` (R14-01) expects `entries=25 row_linked=22 by_hand=3`; the entry
   declares two rows but states no numeral. Changing the line would move the totals
   `[INFERENCE from R14-01's field semantics: row_linked 22→21, by_hand 3→4]`; the
   entry's text does not need to change, so no migration is earned.

## Checks I ran (read-only) and did not run

Ran, all against committed bytes/lane files:

- `sha256sum` and `git show 0a47dd1:` / `git show 144babc:` identity of the entry;
  `git status --porcelain` for it; comparison with `corpus/stamps.tsv:49`.
- Read `drift-baseline.tsv:10`, `drift-symbols.tsv:26-27`, `state-shape.tsv:45-46`,
  `adjacency.tsv:50`, `surface-census.tsv:31`, `claim-ledger.tsv:15,18,32` (same rows at
  BASE and candidate), `self-counts.tsv` (BASE `0a47dd1` and candidate `144babc`),
  `QUALITY.md:118` (both), `lessons/round-25.md:49-57`.
- Counted data rows for `rows:` attempts: drift-baseline 15, drift-symbols 20,
  state-shape 22; BASE self-counts 38 rows, candidate `144babc` 60 rows (22 knowledge
  bindings); neither has a `tac-evidence` row.
- Enumerated the fenced block (`:28-36`, 9 lines) and tested every locator above for
  exactly-one-line match and exactly one capture group.
- Searched the tree for script bytes: `af95ca97…` occurs only in
  `corpus/drift-baseline.tsv:10` (plus prior wave reports/sandbox copies);
  `LOCAL_RECEIPT_INTEGRITY` occurs only as pinned/quoted text (drift-symbols, this
  entry, a lesson, SKILL.md, prior reports), never in an independent script; the unique
  code strings `O_WRONLY|O_CREAT|O_EXCL` and `DAYBREAK_ACCESS_OK_` appear only in the
  entry path or copies of it. No plain-text in-repo copy of `tac-check` was found.

Did **not** run / check:

- No host reads: `~/.local/bin/tac-check`, the three state JSONs, `~/.agents/AGENTS.md`,
  or any session transcript. The `L…` ranges and the `0` recipient value are therefore
  **unverified**, not OK.
- No gate execution: `drift-pins.sh`, `surface-census.sh`, `claim-ledger.sh`,
  `self-counts.py`, `release-clock.py`. The substrate-absent/DEFER state is taken from
  the entry's erratum and round-22 `Entry22.md`, not re-observed.
- No check of other knowledge entries, of L1's after-table validity beyond this entry's
  absence, or of the C2 release-clock change.
- No production edits, no sandbox code, no commits, no installs (nothing needed).

## Reproduction

```bash
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
sha256sum corpus/knowledge/tac-evidence-integrity.md
git show 0a47dd1:corpus/knowledge/tac-evidence-integrity.md | sha256sum
git show 0a47dd1:corpus/knowledge/tac-evidence-integrity.md | wc -lc
git show 0a47dd1:corpus/stamps.tsv | grep tac-evidence
git show 0a47dd1:corpus/drift-baseline.tsv | sed -n '10p'
git show 0a47dd1:corpus/drift-symbols.tsv | grep tac-check
git show 0a47dd1:corpus/state-shape.tsv | grep handoff-status
git show 0a47dd1:corpus/self-counts.tsv | grep -n '88\|tac\|local-evidence' || echo 'no 88/tac rows at BASE'
git show 144babc:corpus/self-counts.tsv | grep -n 'tac-evidence' || echo 'no tac row at candidate'
git show 144babc:corpus/self-counts.tsv | awk 'NF && $0 !~ /^[[:space:]]*#/' | wc -l
```

The locator test used the regexes in the near-candidate table with
`re.compile(...).search(line)` over all 92 lines; each produced exactly one hit and
`regex.groups == 1`. The block enumeration is `sed -n '28,36p'` = 9 non-empty lines.

Revision: BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`; report written 2026-10-21
(round 27, read-only). This is lane-authored advice; L1 is the sole integrator.
