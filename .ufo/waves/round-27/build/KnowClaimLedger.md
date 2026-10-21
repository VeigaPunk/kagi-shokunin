# KnowClaimLedger — round-27 C1 inventory: `corpus/knowledge/claim-ledger.md`

Seat: `KagiR26.KnowClaimLedger-17` (leaf; no subagents). Lane-authored advice, not
non-author closure. Observed 2026-10-21T12:12–12:32-03:00; the target moved twice while
this census ran, so every status below carries its observation time.

- Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (HEAD observed equal throughout).
- Target at BASE: blob `4bfe3d6c…` — 505 lines / 34510 bytes.
- Target obs. 1 (12:12:25, "draft A"): sha256 `591e491c…` — 505 lines / 34668 bytes.
  This is the revision my first census measured.
- Target obs. 2 (12:23:38, "draft B", current when written): sha256
  `9da1a91f74d121a9d83442d9b6c28155f6e3c1a6576172280309e38ebc04a54f` — 514 lines /
  35231 bytes. Reproduction lines still 301-304; Errata at 491 and 507.
- Live anchors: `corpus/stamps.tsv` sha256 `38dea69a…`, 90 non-blank lines, mtime 12:16:58;
  `corpus/claim-ledger.tsv` sha256 `c44b02ad…`, 83 lines, mtime 12:25:18;
  `corpus/self-counts.tsv` mtime 12:24:58, 60 data rows, 22 `KN-*` rows.
- Method: static census of the entry, then the pinned expectations in
  `corpus/claim-ledger.tsv` plus direct data-file counts (`grep -c`, `wc`, `sha256sum`, `stat`)
  and regex tests of every locator on BASE and the live file. **No gate, binder, row, or
  selftest was executed** (contract: pins only), and nothing outside this report was written.

## Population rule applied

A number is **current** when it states an artifact's present size, count, or bound and no
explicit history clause sits in the same clause (QM21; `corpus/QUALITY.md:118`, QM26 at `:133`).
A history clause is not a binding target, but it *is* a dated claim and must be true — that is
where the freshness defects below lived. Binder-expressible sources are exactly `rows:<file>`
(non-blank, non-comment data lines), `ledger:<ID>` (a non-host row's own command, last line),
and `expect:<ID>` (a committed pin) — `corpus/self-counts.py:1-35`.

## A — the BASE inventory (current-tense, bindable) and its status per draft

All four text occurrences are three facts; the selftest count appears twice on one line.
Locators were tested against BASE and the live file: each matches **exactly one line** and
captures one integer (binder rules: `corpus/self-counts.py:326-337`).
Line numbers are unchanged across BASE / draft A / draft B for these lines.

| id (self-counts) | line | BASE text | source | extract | live | BASE | draft A (12:12) | draft B (12:23) |
|---|---|---|---|---|---|---|---|---|
| `KN-LEDGER-REPRO-CLAIMS` | 301 | `claims=17` | `ledger:R21-04` | `^([0-9]+)$` | **65** | STALE (17≠65) | `claims=65` → OK | no literal; `claims=N` + row pointer → row retired |
| `KN-LEDGER-REPRO-STAMPS` | 301 | `stamped=33` | `ledger:R12-03` | `^([0-9]+)$` | **90** | STALE (33≠89) | `stamped=89` → **STALE (89≠90)** | no literal; `stamped=M` + row pointer → row retired |
| `KN-LEDGER-REPRO-SELFTEST` | 304 | `# 72 scratch cases` | `ledger:R11-09` | `^SELFTEST: PASS \(([0-9]+) cases\)$` | **170** | STALE (72≠170) | `# 170` → OK | `# 170` → OK |
| *(no row at A)* | 304 | `SELFTEST: PASS (72 cases)` | `ledger:R11-09` | same | **170** | STALE | `(170 cases)` → OK but **unbound** | bound by the backreference locator below |

Locators:

```
A1  ^bash corpus/claim-ledger\.sh verify .*?\(claims=([0-9]+)          # shipped; now UNLOCATED
A2  ^bash corpus/claim-ledger\.sh verify .*? stamped=([0-9]+)          # shipped; now UNLOCATED
A3  ^bash corpus/claim-ledger\.sh --selftest +# ([0-9]+) scratch cases # shipped; OK
A4  ^bash corpus/claim-ledger\.sh --selftest .*?SELFTEST: PASS \(([0-9]+) cases\)
```

A1/A2 were the shipped `self-counts.tsv:68-69` for draft A; draft B removed both rows because
the numbers they bound no longer exist (see D4). A3's shipped row was replaced in draft B by a
backreference form that binds **both** copies in one capture:

```
^bash corpus/claim-ledger\.sh --selftest +# ([0-9]+) scratch cases +→ SELFTEST: PASS \(\1 cases\)
```

Tested (regex level, not through the binder): one hit on BASE (captures `72`) and on draft B
(captures `170`); mutating **either** copy alone makes the pattern non-matching (the row fails
as `UNLOCATED`); mutating both copies consistently matches and compares the captured number to
`R11-09` (→ `STALE`). Every mutation class fails the binder, so the A4 gap is closed.

### Live values and their defining rows

| source | pin (live tree) | observed value | evidence |
|---|---|---|---|
| `ledger:R21-04` | `corpus/claim-ledger.tsv:54` — `^65$` | 65 | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → 65 (BASE → 65) |
| `ledger:R12-03` | `corpus/claim-ledger.tsv:28` — `^90$` | 90 | `grep -c '[^[:space:]]' corpus/stamps.tsv` → 90 (BASE → 89); `R24-05` (`:68`) pins `count=90` |
| `ledger:R11-09` | `corpus/claim-ledger.tsv:23` — `^SELFTEST: PASS \(170 cases\)$` | 170 | `grep -cE '^[[:space:]]*tcase(_last)? ' corpus/claim-ledger.sh` → 170 (BASE → 170) |

`verify`'s `claims=`/`stamped=` are `C_N`/`V_ROWS` (`corpus/claim-ledger.sh:535,554,1200-1232`):
rows read, including host-skipped and deferred rows, so the row-count sources are the correct
definers. `stamped=` could equivalently be `rows:corpus/stamps.tsv` (90; no comment/blank lines).

## Timeline of the live drift (why the statuses above differ)

| time | event | consequence |
|---|---|---|
| 12:12:25 | draft A written: `claims=65 … stamped=89`, labels `round-10 output read …`, `72 at round 10` | 89 already stale — the stamp count was still 89 at BASE but the round-27 re-stamp had not landed yet; the proposed value was one behind the pending re-stamp |
| 12:16:58 | stamps re-stamped with `corpus/lessons/round-27.md`; `R12-03`→`^90$`, `R24-05`→`count=90` | draft A's `stamped=89` became stale against its own defining row |
| 12:23:38 | draft B: `claims=N`/`stamped=M` with pointers to `R21-04`/`R12-03`; labels `round-13-close output read`; selftest bound by backreference; `:81` adds `(the 16th case when written)`; new round-27 Erratum at `:507-513` | A2 resolved (no literal), A4/F2 resolved; A1/A2 binder rows retired |
| 12:24:58 | `self-counts.tsv` updated: 60 data rows / 22 `KN-*`; the two claim/stamp rows retired | binder population reflects draft B |
| 12:25:18 | `claim-ledger.tsv` repinned: `R25-02` → `^SELF_COUNTS: CLEAN \(claims=60 stale=0\)$` (`:81`) | its stamp row (`32c2ca7c…`, 83 lines) now mismatches (sha `c44b02ad…`) |

## B — current-tense numbers with no binder-expressible source (out of population)

Statements about the shipped gate (`corpus/claim-ledger.sh`, 1807 lines at BASE) or a ledger
field. Each has a lane-local definer, but none of `rows:`/`ledger:`/`expect:` can express it.
Verified statically:

| line | text | live definer | locator (proposed; one capture group) | verdict |
|---|---|---|---|---|
| 91 | `300 s for the gates` | timeout column of `corpus/claim-ledger.tsv` (19 of 65 rows are 300) | `^Timeouts: each row declares its own bound \(([0-9]+) s for the gates` | **imprecise**: `R25-02`=600 (`:81`), `R21-02`=60 (`:52`), `R15-03`=60; "the gates" is not uniformly 300 |
| 91 | `120 s for drift` | `R11-04`, `R18-01`=120 (`:18`, `:48`) | `^Timeouts: each row declares its own bound \([0-9]+ s for the gates, ([0-9]+) s for` | OK for the drift **verify** rows; `R11-05` (drift `--selftest`, `:19`) is 300, so not for "drift" as a class |
| 92-93 | `timeout -k 5`, `tmo`+5 s, rc 124/137 | `corpus/claim-ledger.sh:595`, rc at `:597` | ``the runner adds `timeout -k ([0-9]+)`` | OK (code/format constants; 124/137 is coreutils behavior) |
| 73 | `R11-06` carries `1` | `corpus/claim-ledger.tsv:20` (exit column 1) | ``^\s+`([0-9]+)` because the recorded baseline`` | OK; a field value, not a size |
| 364 | `six commands: bash, grep, sha256sum, wc, test, python3` | `ALLOWED_RE`, `corpus/claim-ledger.sh:262` (exactly 6) | none — spelled `six`; binder needs an integer | OK |
| 394 | `four selftest cases cover the guard` | `tcase` lines `corpus/claim-ledger.sh:1635,1636,1639,1642` (exactly 4) | none — spelled `four` | OK |
| 226, 411 | four by-hand classes; `≥24`-char floor | `BYHAND_CLASSES`, `corpus/claim-ledger.sh:1101` (4); floor message `:1177` (24) | `The reason must be ≥([0-9]+)$` (L226), `reason-length floor \(([0-9]+)\) is arbitrary` (L425); class count spelled | OK |
| 452-453 | six axes | `for ax in depth coverage operability freshness calibration adjacency`, `corpus/claim-ledger.sh:957` (and `:1324-1354`) | none — spelled `six` | OK |
| 111 | `the two corpus shorthands` (`knowledge/`, `lessons/`) | Class-3 table in this entry; doc rule, not code-verified | none — spelled `two` | OK as described |
| 95 | `the three sibling gates` | rows `R11-01..R11-07` still name three gates | none — spelled `three` | OK, but framed as round-11 history |
| 32 | `the gate makes the three classes mechanical` | the entry now has six `## Class N` sections | none — spelled `three` | **undercount/ambiguous**; see D5 |

The numeric locators above were tested like Table A's (one hit each on BASE and draft B).
Spelled counts cannot be bound at all (`corpus/self-counts.py:121,338` requires an integer).

## C — excluded numbers and why

Grouped; every item is out by rule, not by omission. Lines whose only digits are markdown list
markers (`1.`–`30.`) or heading ordinals (`## Class N`, `1.`/`2.` in the claim criteria) are not
artifact numbers and are not listed individually.

1. **History clauses / dated source basis (QM21, QM26).**
   - `:3-7` — `2026-09-28`, `round 11`, `436 lines at the frozen wave revision` (gate is 1807
     lines now; the clause is pinned to the round-11 revision), `9 rows at that revision; 14 at
     round-12 close, 17 at round-13 close`.
   - `:19-20` — `62 claims` / `49 VERIFIED / 9 STALE / 4 UNCHECKABLE` (past-tense round-10 report
     adjudication).
   - `:27` — `D-19, OPEN, 9 occurrences` (another repo's round-10 report).
   - `:61` — `four of its clauses` (round-10 loss).
   - `:131-132` — `labeled=1` round-11 baseline and the relocated round-2 aggregate.
   - `:157-158` — `five rows were orphans` at the round-12 close (`R11-01/02/04/05/07`).
   - `:171-176` — `12 cells to 11`, `six cells` (round-13 planner/sentinel).
   - `:180` — `all 48 real cells`.
   - `:207-209` — `at 4b8c018 … 1 of 17 … 0 of 17 … 10 of 17`.
   - `:252-279` — the round-14 / round-13 / round-11 before→after tables (headings included;
     e.g. `17 of 17`, `undeclared=17 unpinned=10`, `row_linked=1 … floor=2`, `cites=268 docs=37 …`,
     `cites=374 …`, `cites≈500 docs=39`).
   - `:291-296` — `Measured this way in round 11: … cites=517 docs=39`.
   - `:338-358` — round-11 lone-clone `PASS (39 cases)`, `exit=1 want=0`; round-25 lone-clone
     `BASE 4587c61a`, `unresolved=88 (57 sibling, 31 ufo; 42 …)`, `175 checked citations`.
   - `:385-388` — round-12 `18 rows` / `10-path stamp`.
   - `:404-408` — round-14 coverage list, including the quoted `20 vars` from
     `credential-isolation` (a quotation, not this entry's claim).
   - `:416-417` — `nine entries` (round-14 labrat measurement).
   - `:439-440` — `calibration | 9 | R11-10` historical counterexample.
2. **Semantic constants, format, templates, examples.**
   - `:38` — 4-column TSV shape; `:45` — `old12`/`new12` (code uses `${CMP_OSHA:0:12}`,
     `corpus/claim-ledger.sh:522-523`: format width); `:47`, `:199-201`, `:249` — summary
     templates with `N/M/R/S/K/O`.
   - `:87-89` and every `exit 0/1/2/3` mention — exit-code semantics.
   - `:110-114` — citation-resolution examples with line refs; `:140-159` — round-11/12 history,
     the id vocabulary with `R12-03a`/`xR12-01`/`R12-01..03`/`r13-99`, the fabricated `R13-99`
     example and the upper-case-`R` bound; `:187-197` — exit-2 semantics, case names, `F3`;
     `:233-245` — ratio-floor formula and the `R14-01` self-reference.
   - `:217-218` — `Reverify: R11-04, R11-05` example; `:370` — `1-bit oracle`; `:468` — `cited=0`.
3. **Fixture / falsifier literals.** `:188` `deadbeef/0/0`; `:478-488` expected exits and fixture
   values (`1`, `2`, `5`, `13`, `99`, `3`, `7`) — falsifier commands, not artifact sizes.
4. **Positional case index (QM26).** `:288` "pinned by selftest case 21". `:81`'s positional
   index is now a history clause ("the 16th case when written"); `:288` still has none — see D5.
5. **Labels / ids.** `:9` (`Class 4`, `Class 5`), `:12` (four claim ids, not a stated count),
   `:16`, `:35/64/102/138/161/204` (class numbers), `:59` (`L2`), `:343` (`Round 25`), `:491`,
   `:507` (round labels).
6. **Vendor facts / host measurements.** None of the vendor kind appears. The only host-shaped
   numbers are the lone-clone measurements in item 1, which are dated.

## D — open items at the last observation (draft B + repins)

**D1 — two stamped rows are now stale inside the working tree (expected mid-integration; must
not survive closure).** The entry is `9da1a91f…` / 514 lines / 35231 bytes, but its stamp row is
still `591e491c…` / 505 / 34668 (`corpus/stamps.tsv:31`). `corpus/claim-ledger.tsv` is
`c44b02ad…`, but its row is `32c2ca7c…` / 83 / 28011 (`:13`). Until L1 re-stamps after the last
edit, `verify` reports `STALE corpus/knowledge/claim-ledger.md` and
`STALE corpus/claim-ledger.tsv` (exit 1). Re-stamping existing paths leaves the stamp **count**
at 90 unless a new path is added; any added path makes the 90 in `R12-03`/`R24-05` move.

**D2 — the round-27 lesson and migration record still describe draft A, not draft B.**
`corpus/lessons/round-27.md:49-55` still says "18 bindings", "claims 17→65 and stamped 33→89",
and "Unbindable round-10 outputs … are labelled as round-10 output"; `.ufo/waves/round-27/knowledge-migrations.json:4`
still says "unbindable round-10 outputs labelled", and its `claim-ledger.md` change records
(`:18-21` for the `:81` edit, `:36-45` for `:301-304`) carry the draft-A text (`claims=65 …
stamped=89`, `round-10 output read …`, `72 at round 10`, and a `:81` replacement without
"(the 16th case when written)"). The current
entry has no 65/89 literals and says `round-13-close`. The lesson is a stamped artifact
(`corpus/stamps.tsv`, `corpus/lessons/round-27.md` row) and the JSON is the round's migration
record; both must be updated to draft B and the lesson re-stamped. Counts to correct there:
`KN-*` rows = 22, binder claims = 60, entry = 514 lines.

**D3 — the round-22 Erratum sentence is now overbroad.** `:493-495` says the summaries are
"not current claim/stamp/selftest/cell totals", but the selftest line still leads with a current
`170` bound by `KN-LEDGER-REPRO-SELFTEST`; only the tails (17/33, 700/43, 60, 72) and the N/M
placeholders are historical. The new round-27 Erratum at `:507-513` clarifies the rest; narrow
the old sentence to "the round-13-close tails are historical; the selftest lead is current and
bound", or merge the two errata.

**D4 — the pointer form removes the machine-checkable digits for claims/stamps.** `claims=N` /
`stamped=M` with pointers to `R21-04`/`R12-03` cannot drift and is honest, but the plan's
"a one-digit knowledge mutation turns the binder STALE" now has no digit to mutate for those two
facts, and the two `KN-*` rows were retired (population 56→60 reflects other additions:
`self-counts.tsv` currently has 60 data rows, 22 `KN-*`). If this is the chosen design, record
it in the lesson (currently the lesson claims numeric correction to 65/89, which no longer
matches the entry). The alternative — keep `65`/`90` literals and bind them — remains available
and would preserve per-digit sensitivity.

**D5 — minor consistency.** `:32` says "the three classes" while the entry documents six
`## Class N` sections ("the three foundational classes" would be exact). `:81`'s positional
index now carries a history clause; `:288`'s "selftest case 21" does not (two conventions).
`:91`'s `300 s for the gates` is false for `R25-02` (600), `R21-02` (60) and `R15-03` (60), and
`120 s for drift` excludes the drift selftest (`R11-05`, 300) — illustrative, out of population.

## What I did NOT check (unrun ≠ pass)

- Did not execute `corpus/claim-ledger.sh` (any mode), `corpus/self-counts.py`, any ledger row, or
  `.ufo/waves/round-27/tools/c1-measure.py`. The STALE/UNLOCATED consequences above are derived
  from the binder's documented extraction (`corpus/self-counts.py:326-355`) and observed data;
  the backreference test was a plain `re` match, not a binder run.
- Did not re-measure after 12:32-03:00; the tree is live. Further stamp rows change D1; further
  entry edits change the sha and every line number cited here (draft B is 514 lines).
- Did not census the other knowledge entries (ticket scope is this entry). Overlap is stated, not
  claimed as novelty: `.ufo/waves/round-27/build/CritC1Population.md` CE4 independently reached
  the round-13 provenance defect from git pickaxe; the 89-vs-90 mismatch, the duplicate-170
  binding, the migration-record lag, and D3/D5 were measured here on the live tree.
- Did not verify the round-10 report's `62 / 49 / 9 / 4` (history) or the round-11 clone's
  `39 cases` (history); both are outside C1's binding population.
- Did not verify that `cites=700 docs=43` / `cells=60` were *exactly* the round-13-close readings
  beyond round-13.md's own Evidence block (which quotes them); that block is the source used.
- No tools installed or updated; no host-private reads; no vault/account/handler/CDP contact.

## Remaining minimal actions (L1 applies; production is read-only to this seat)

1. Update `corpus/lessons/round-27.md:49-55` and `.ufo/waves/round-27/knowledge-migrations.json:4,18-21,36-45`
   to draft B: no `claims=65`/`stamped=89` literals, `round-13-close output read` (not round-10),
   `KN-*` = 22, binder claims = 60, entry = 514 lines, and the `:81` text with
   "(the 16th case when written)".
2. Narrow or merge the round-22 Erratum sentence (`:493-495`) so the current, bound selftest
   `170` is not called historical; keep the round-27 Erratum (`:507-513`) as the pointer record.
3. Re-stamp `corpus/knowledge/claim-ledger.md`, `corpus/claim-ledger.tsv`, and the edited
   `corpus/lessons/round-27.md` **after** the last edit, then run the binder last. Expected
   `SELF_COUNTS: CLEAN (claims=60 stale=0)` and `CLAIM_LEDGER: CLEAN` with 90 stamps, unless a
   new path is pinned (then update `R12-03`/`R24-05` and the counts in the lesson together).
4. Optional (D5): "three foundational classes"; give `:288` a history clause or a case name;
   qualify the timeout sentence at `:91`.
