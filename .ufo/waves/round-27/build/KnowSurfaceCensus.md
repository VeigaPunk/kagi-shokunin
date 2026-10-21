# KnowSurfaceCensus — C1 inventory for `corpus/knowledge/surface-census.md`

Seat: KagiR26.KnowSurfaceCensus-17. BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`
(`git rev-parse HEAD`; `corpus/knowledge/surface-census.md` is unmodified at BASE).
Every line number below is a **BASE line number**, read with
`git show 0a47dd18:corpus/knowledge/surface-census.md`. No production file was written.

Method: read-only. I did **not** run `surface-census.sh`, `--selftest`, `--verbs`,
`--deep`, `drift-pins.sh`, `claim-ledger.sh verify`, `self-counts.py`, or any C2 tool.
Live values come from the committed data files (`git show` for the ledger pins, direct
read for the two data TSVs, which are unmodified in the working tree) and from static
reading of `corpus/surface-census.sh`. Nothing here is a pass for an unrun check.

## Rule applied

- QM21 (`corpus/QUALITY.md:118` at BASE): a current-tense number a committed doc states
  about this lane's own artifacts is bound to the source that defines it; only an
  explicit history clause with a newer value beside it makes a number historical.
- R25-C6 (`corpus/lessons/round-25.md:49-59`): "current" = states an artifact's present
  size with no newer value in the same clause.
- QM26 is **not** at BASE; it is the round-27 draft (`corpus/QUALITY.md:133` in the
  working tree at read time, uncommitted). Its two operative sentences are used below as the build
  rule: a dated measurement section, Erratum history and a positional case index are
  excluded **by name**, and "an unbindable stale output is labelled with its round, not
  restated as current."

## Working-tree state (why BASE is cited, not the working copy)

`git status --short` at read time: HEAD is BASE; 15 tracked files are modified and
`.ufo/waves/round-27/`, `corpus/lessons/round-27.md`, `plans/round-27.md` are untracked.
For this entry the working diff is exactly one line (`:32`, `19 symbol pins` ->
`20 symbol pins; 19 when this entry was written`). `corpus/self-counts.tsv` at BASE has
38 binding rows and **zero** `KN-` rows; the working tree had 16 `KN-` rows when read
(peer edits were in flight), two of which target this entry (`KN-CENSUS-DRIFT-FILES`,
`KN-CENSUS-DRIFT-SYMBOLS`). The pins I quote
(R11-03, R11-10, R11-11, R18-01, R21-04, R24-03, R24-04) are unchanged between BASE and
the working tree, but BASE is authoritative.

## Table A — current-tense numbers stated about this lane's artifacts

Columns follow `corpus/self-counts.tsv` (`id, locator, source, extract, note`) plus the
BASE line, the pinned live value and the verdict. A `—` source means **no enrolled
`rows:`/`ledger:`/`expect:` row defines the value**: the defining bytes exist in a lane
data file, but `rows:` in `corpus/self-counts.py:339-341` counts whole data lines only,
so the field/subtotal needs a new non-host ledger row (Table B). Those rows are
lane-local but **unpinned**, the same class as `OP_REF_PROBE checks=44` in the
round-27 draft lesson — out of the *bindable* population unless the row is added.

| id | line | text (verbatim, truncated) | locator (one group) | source | extract | live | verdict |
|---|---|---|---|---|---|---|---|
| KN-CENSUS-ROWS | 4 | `` `corpus/surface-census.tsv` (35 rows: 20 asset /`` | ``^the live host; data files `corpus/surface-census\.tsv` \(([0-9]+) rows`` | `rows:corpus/surface-census.tsv` | `-` | 35 | OK |
| KN-CENSUS-ASSET | 4 | `20 asset /` | `\([0-9]+ rows: ([0-9]+) asset /` | — (P1) | `^([0-9]+)$` | 20 | OK |
| KN-CENSUS-RUNTIME | 5 | `15 runtime) and` | ``^([0-9]+) runtime\) and `corpus/state-shape\.tsv`` | — (P2) | `^([0-9]+)$` | 15 | OK |
| KN-CENSUS-STATE-ROWS | 5 | `` `corpus/state-shape.tsv` (22 rows:`` | `` `corpus/state-shape\.tsv` \(([0-9]+) rows:`` | `rows:corpus/state-shape.tsv` | `-` | 22 | OK |
| KN-CENSUS-SQLITE | 5 | `9 sqlite /` | `rows: ([0-9]+) sqlite /` | — (P3) | `^([0-9]+)$` | 9 | OK |
| **KN-CENSUS-JSON** | **5** | **`9 json /`** | `sqlite / ([0-9]+) json /` | — (P4) | `^([0-9]+)$` | **8** | **STALE** |
| KN-CENSUS-LOG | 5 | `3 log /` | `json / ([0-9]+) log /` | — (P5) | `^([0-9]+)$` | 3 | OK |
| KN-CENSUS-LOCK | 5 | `1 lock /` | `log / ([0-9]+) lock` | — (P6) | `^([0-9]+)$` | 1 | OK |
| KN-CENSUS-MARKER | 5 | `1 marker)` | `lock / ([0-9]+) marker` | — (P7) | `^([0-9]+)$` | 1 | OK |
| KN-CENSUS-DRIFT-FILES | 32 | `(15 files,` | `^\(([0-9]+) files, [0-9]+ symbol pins` | `rows:corpus/drift-baseline.tsv` | `-` | 15 | OK |
| **KN-CENSUS-DRIFT-SYMBOLS** | **32** | **`19 symbol pins`** | `^\([0-9]+ files, ([0-9]+) symbol pins` | `rows:corpus/drift-symbols.tsv` | `-` | **20** | **STALE** |
| KN-CENSUS-OPENCODE-DECLARED | 55 | `4 declared paths` | `children, ([0-9]+) declared paths` | — (P10) | `^([0-9]+)$` | 4 | OK |
| **KN-CENSUS-HASHES** | **76** | **`16 published hashes`** | `^([0-9]+) published hashes` | — (P8) | `^([0-9]+)$` | **9** | **STALE** |
| KN-CENSUS-FLOOR-SESSION | 119 | `` `session:2` `` | `` `session:([0-9]+)` vs 7`` | — (P11) | `^([0-9]+)$` | 2 | OK |
| KN-CENSUS-FLOOR-MESSAGE | 120 | `` `message:13` `` | `` `message:([0-9]+)` vs 39`` | — (P12) | `^([0-9]+)$` | 13 | OK |
| KN-CENSUS-FLOOR-PART | 120 | `` `part:18` `` | `` `part:([0-9]+)` vs 55`` | — (P13) | `^([0-9]+)$` | 18 | OK |
| KN-CENSUS-FLOOR-EVENT | 120 | `` `event:79` `` | `` `event:([0-9]+)` vs 238`` | — (P14) | `^([0-9]+)$` | 79 | OK |
| KN-CENSUS-TABLES-MIN | 120 | `` `tables_min 12` `` | `` `tables_min ([0-9]+)` vs`` | — (P15) | `^([0-9]+)$` | 12 | OK |
| KN-CENSUS-LOG-SIZE-MIN | 121 | ``log `size_min 16384` `` | `` log `size_min ([0-9]+)` vs 33687`` | — (P16) | `^([0-9]+)$` | 16384 | OK |
| KN-CENSUS-SCAN-DIRS | 198 | `` `maxdepth 1` over 4 dirs`` | `` `maxdepth 1` over ([0-9]+) dirs`` | — (P9) | `^([0-9]+)$` | 4 | OK |
| KN-CENSUS-PART-FLOOR-FALSIFY | 281 | `floor 18` | `SHAPE \(rows part 0 < floor ([0-9]+)\)` | — (P13) | `^([0-9]+)$` | 18 | OK (duplicate of :120) |

Every locator above was validated against the BASE text: exactly one matching line,
exactly one capture group, captured integer shown in `live` (Python
`re.search(pattern, line)` over all 306 lines). The `source`-less rows' live values were
measured with the exact commands in Table B, executed as `shlex.split` argv with
`shell=False` and `cwd` = repo root, which is how `corpus/self-counts.py` runs a
`ledger:` row.

Measured source facts:

- `corpus/surface-census.tsv`: 35 data rows; `grep -cP '\tasset\t'` = 20,
  `grep -cP '\truntime\t'` = 15; 4 `# scan` directives (`:17-20`); 1 `mode = -` row
  (`:52`, the contested chrome-profile dir).
- `corpus/state-shape.tsv`: 22 data rows; kinds 9 `sqlite` (`:27-35`), **8 `json`**
  (`:41-48`), 3 `log` (`:36-38`), 1 `lock` (`:39`), 1 `marker` (`:40`). Floors:
  `session:2` (`:32`), `message:13` (`:33`), `part:18` (`:34`), `event:79` (`:35`),
  `tables_min 12` (`:30`), log `size_min 16384` (`:37`). All match the prose.
- `corpus/drift-baseline.tsv`: 15 data rows; **9** rows carry a 64-hex digest, 6 carry
  `-` (`:4,5,11,12,13,14`). `corpus/knowledge/drift-gate.md:143` independently states
  "6 of 15 files are content-unhashed".
- `corpus/drift-symbols.tsv`: 20 data rows; `corpus/claim-ledger.tsv:48` (BASE
  `R18-01`) pins `symbols_bad=20`.

### Population judgment on `:4-5` (stated, not hidden)

Lines 4-5 sit in the paragraph whose first line is dated ("run on 2026-09-28 against the
live host"). I keep the data-file counts in population because the date modifies the
**run**, not the committed TSVs, and QM21's test is a newer value beside the number — of
which there is none. The counter-reading is real: if L1 rules the whole paragraph a
"dated measurement section" under the round-27 exclusion, then `35/20/15/22/9/9/3/1/1`
all fall out. Under that reading S1 (`9 json`) still needs a correction because the
entry's own erratum calls the subtotal superseded and QM26 forbids leaving the
correction elsewhere; S2 (`:76`) is outside that paragraph and stays in population
either way. The two readings differ on whether the values are *bound*; they do not
differ on whether `9 json` and `16 published hashes` are wrong.

## Stale findings (three at BASE; one is already fixed in the working tree)

### S1 — `:5` `9 json` is wrong: the file carries 8

`corpus/state-shape.tsv:41-48` has eight `json` rows. The stated subtotals sum to
**23** (`9 + 9 + 3 + 1 + 1`) beside the stated total of 22, and the file has 22 data
rows (`R11-10` pin `^22$`, `R24-03` count=22). The number was never true: at the
introducing commit `03477c0` the same file also had 8 `json` rows (9 sqlite / 8 json /
3 log / 1 lock / 1 marker).

The entry already knows: BASE `:295-297` says "The state-shape introduction's JSON
subtotal ... [is] superseded by the actual committed TSVs; the first subtotal was
internally inconsistent". That is a correction **220 lines away with no newer value**
— exactly QM26's weak signal ("a correction note elsewhere instead of a history clause
beside the number"), not a history clause under QM21.

Suggested text (keeps the old value beside the new one):

```
15 runtime) and `corpus/state-shape.tsv` (22 rows: 9 sqlite / 8 json / 3 log /
1 lock / 1 marker; the round-10 introduction said 9 json, a subtotal that summed
to 23 and was withdrawn by the round-22 erratum); ...
```

### S2 — `:76` `16 published hashes` is wrong: the baseline carries 9

`corpus/drift-baseline.tsv` has 15 rows, of which 9 have a sha256 and 6 have `-`
(measured `grep -cP '\t[0-9a-f]{64}$' corpus/drift-baseline.tsv` = 9). The phrase is
also split across `:75-76` ("the baseline keeps the / 16 published hashes"), so a
line-local reader cannot see the antecedent.

The entry already knows: BASE `:295-297` calls the `"16 published hashes"` phrase
"unsupported". No count of 16 exists in the file now or at its round-9 introduction
commit (`e64e81b`: 15 rows, 9 hashes). The only "16" nearby is the `sha16` **prefix
length** described in `drift-gate.md:13`; connecting the two is inference, not evidence.

Suggested text:

```
the baseline keeps the 9 published hashes (6 of its 15 rows are content-unhashed;
16 was the round-10 phrase, recorded as unsupported by the round-22 erratum), and
the cross-check keeps the two from disagreeing.
```

### S3 — `:32` `19 symbol pins` is stale at BASE: 20

`corpus/drift-symbols.tsv` has 20 data rows and `R18-01` pins `symbols_bad=20`. The
uncommitted working-tree fix is correct and keeps the old value beside the new one:

```
(15 files, 20 symbol pins; 19 when this entry was written)
```

The existing working-tree `KN-CENSUS-DRIFT-SYMBOLS` locator
`^\([0-9]+ files, ([0-9]+) symbol pins` captures 19 over BASE (STALE) and 20 after the
fix (OK). This is the one item of the round-22 erratum's three that the working tree
actually corrects.

### Erratum accounting (the calibration point)

The round-22 erratum at BASE `:295-297` names three superseded items **in the
introduction**: (a) the JSON subtotal, (b) the symbol-pin total, (c) the `"16 published
hashes"` phrase. At BASE all three are still stated in the present tense in the body;
the round-27 working tree corrects only (b). A reviewer applying QM26 to this entry
will find (a) and (c) still failing, with no newer value anywhere in the entry. This is
the honest counterexample to a claim that the entry's stale set is fully corrected.

## Table B — proposed non-host ledger rows for the unpinned values

None of these rows exists at BASE. `corpus/claim-ledger.tsv` has only `R11-10`,
`R11-11`, `R24-03`, `R24-04` over these files, and each returns a whole-file count or
path-key digest, never a field value. Each command below was executed exactly as the
binder would (`shlex.split`, `shell=False`, cwd = repo root) and returned the shown
value with exit 0; `grep` is in `ALLOWED_COMMANDS` and none takes a script argument, so
`enforce_command_policy` has nothing to walk. **They are proposals, not enrolled rows,
and they were not run through `ledger_command()` or the ledger selftest.**

| id | command (shlex argv) | output | binds |
|---|---|---|---|
| P1 | `grep -cP '\tasset\t' corpus/surface-census.tsv` | 20 | KN-CENSUS-ASSET |
| P2 | `grep -cP '\truntime\t' corpus/surface-census.tsv` | 15 | KN-CENSUS-RUNTIME |
| P3 | `grep -cP '\tsqlite\t' corpus/state-shape.tsv` | 9 | KN-CENSUS-SQLITE |
| P4 | `grep -cP '\tjson\t' corpus/state-shape.tsv` | 8 | KN-CENSUS-JSON |
| P5 | `grep -cP '\tlog\t' corpus/state-shape.tsv` | 3 | KN-CENSUS-LOG |
| P6 | `grep -cP '\tlock\t' corpus/state-shape.tsv` | 1 | KN-CENSUS-LOCK |
| P7 | `grep -cP '\tmarker\t' corpus/state-shape.tsv` | 1 | KN-CENSUS-MARKER |
| P8 | `grep -cP '\t[0-9a-f]{64}$' corpus/drift-baseline.tsv` | 9 | KN-CENSUS-HASHES |
| P9 | `grep -c '^# scan' corpus/surface-census.tsv` | 4 | KN-CENSUS-SCAN-DIRS |
| P10 | `grep -c '^\$HOME/\.config/opencode/' corpus/surface-census.tsv` | 4 | KN-CENSUS-OPENCODE-DECLARED |
| P11 | `grep -oP 'rows_min\tsession:\K[0-9]+' corpus/state-shape.tsv` | 2 | KN-CENSUS-FLOOR-SESSION |
| P12 | `grep -oP 'rows_min\tmessage:\K[0-9]+' corpus/state-shape.tsv` | 13 | KN-CENSUS-FLOOR-MESSAGE |
| P13 | `grep -oP 'rows_min\tpart:\K[0-9]+' corpus/state-shape.tsv` | 18 | KN-CENSUS-FLOOR-PART and `:281` |
| P14 | `grep -oP 'rows_min\tevent:\K[0-9]+' corpus/state-shape.tsv` | 79 | KN-CENSUS-FLOOR-EVENT |
| P15 | `grep -oP 'tables_min\t\K[0-9]+' corpus/state-shape.tsv` | 12 | KN-CENSUS-TABLES-MIN |
| P16 | `grep -oP 'log\tsize_min\t\K[0-9]+' corpus/state-shape.tsv` | 16384 | KN-CENSUS-LOG-SIZE-MIN |
| P17 | `grep -cP '\t-\t' corpus/surface-census.tsv` | 1 | (the spelled `single mode = - row`, `:205`; no digit in the doc, so this cannot be bound under the integer-capture convention) |

Bookkeeping cost if all are enrolled: every new `R27-xx` row increments `R21-04`
(BASE `:54`, pin `^65$`), which is itself read by `SC-SKILL-CLAIMS` (SKILL.md),
`PV-CLAIMS` (PROVINCE.md) and `RD-LEDGER-ROWS` (corpus/README.md) in
`corpus/self-counts.tsv`. The round-27 C1 change is therefore not "add KN rows only";
it moves the claim-row count and the three docs that quote it. The alternative, and
the QM26-sanctioned one for **S1/S2**, is to label the two round-10 values as round-10
outputs and not restate them as current, which needs no ledger row.

QM18 note: `P1`–`P16` are cardinalities. `corpus/row-identity.sh` digests only the
first TAB field of each row (`state-shape` and `surface-census` selectors, script
`:1-30`), so the existing `R24-03`/`R24-04` identity rows do not pin the `class` or
`kind` column. Bind these notes as "count", not "membership"; a digest over
`(path, class/kind)` would be needed to claim membership identity.

## Table C — excluded numbers and why (nothing silently dropped)

| BASE lines | numbers / text | why excluded |
|---|---|---|
| 3 | `v1`, `round 10`, `2026-09-28` | version label and round/date tags, not quantities; the date is the source-basis measurement date |
| 6-7 | `333 lines`, `L7-27`, `L293-333`, `88 lines`, `117 lines` | line counts/ranges of host files (`~/.local/bin/the-janitor`, `tac-check`, host `client.py`), not lane-owned artifacts; unmeasured here (no host reads). Coincidentally the same 333/88/117 sit in `corpus/drift-baseline.tsv:1-2,10`, but the prose cites the live host |
| 9-11 | `assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0`, `pass=7 skip=3`, `pass=10 skip=0`, `16 cases` | dated round-10 host receipts ("Gates observed this round"; source basis "run on 2026-09-28"). The `assets=20`/`runtime=15` values are bound from the data file at `:4-5`; the receipts themselves are host observations, not current artifact sizes |
| 14 | `R11-01 … R11-11` | row ids, not quantities |
| 18 | `Rounds 1-9` | round-dated history |
| 20, 26 | `Two concrete holes`, `two xdg-data artifacts` | spelled counts of narrative items / host artifacts |
| 44-48, 66, 70, 73-74 | `$STATE`, `3-4 octal digits`, `0-byte`, `16 bytes`, `15-char prefix`, `0600`, `round-9` | schema/format constants, a mode rule and a round tag |
| 52 | `Four dirs` | spelled; the same count appears as the digit `4` at `:198` (bound) |
| 53-54 | `4 children`, `5`, `5`, `2`, `16/16 declared` | observed children of the live host's scan dirs (host observation); the *declarations* are counted at `:4`/`:198` |
| 55 | `20 children`, `reports 0` | host child observation and expected `UNLISTED` count in a host run |
| 94-95, 115, 150-151, 155, 285 | `exit 0/1/2` | exit-code contract constants |
| 97-107 | `round 10`, `round-8` | history |
| 112 | `Three decisions` | positional list count |
| 117 | `case 10` | positional case index (verified: case 10 is `sqlite-unavailable`) |
| 122, 126 | `a third`, `0` | spelled policy fraction (withdrawn at `:298`) and a reset constant |
| 129, 135, 231 | `Two sqlite passes`, `Call A/B` | structural description of the read path |
| 140 | `case 11` | positional index (verified: case 11 is `required-table-gone`) |
| 150 | `2 origins`, `mode 600`, `sole NMH entry` | scratch-tree probe expectation about the handler's output, not a lane artifact size |
| 153 | `4 of 7 line shapes` | round-10 finding about the host `awk`'s match set |
| 156 | `5 static lines` | host handler's status output |
| 158 | `three probes` | spelled count of the `--deep` set |
| 161-162, 169, 171, 177-179 | `1/124`, `4 s`, `25 s`, `L234`, `One … three …`, `~60 s`, `round 3` | dated observations (`observed this round`) and the round-10 findings history |
| 187 | `All three gates` | spelled, and the referent is not named on the line (could be census/drift/transcript); not bindable as written |
| 200 | `20 children` | host child observation |
| 205 | `the single mode = - row` | spelled count; measured value is 1 (`corpus/surface-census.tsv:52`), but no integer appears in the doc, so the binder cannot capture it |
| 207, 209 | `755`, `>3x`, `one third` | host mode measurement; withdrawn floor policy (see C3 below) |
| 220-221 | `sixth field`, `more than five fields`, `exit 2` | schema/exit constants |
| 226 | `case 14` | positional index, verified correct (`fused-shape-row`); named debt in the untracked round-27 lesson |
| 245-264 | `16 cases`, `16 total`, `unverified=3`, `0/1/2`, case list | the whole **Reproduction (2026-09-28)** section is a dated measurement; the case list is also a positional index. There is no undated selftest count in the entry: `:11` is inside the dated source-basis paragraph and `:257` inside the dated Reproduction section, so no current selftest-count claim exists outside dated text |
| 270-288 | list ordinals `1-11`, exit codes, `case 10` | falsifier ordinals/contract; `:280`'s `case 10` is additionally wrong (C2 below) |
| 296-298 | `16`, `one third` | explicit Erratum history quoting the withdrawn phrases |
| 114, 129, 135 | list ordinals `0.`-`3.` | markdown enumeration markers, not quantities |
| 3, 18, 22, 28, 74, 91, 97, 102, 166, 177-179, 188, 195, 242, 290 | `round 6/8/9/10/22/3`-style tags | round labels, not size claims; R25-C6 says a round tag alone does not make a number historical, but a tag is not itself a count of an artifact |
| 154 | `first five bytes` | spelled length of the ref-scheme prefix, a constant; not an artifact size |
| 301, 305 | `exit 1`, `Entry21.md` | contract constant; path |

## Counterexamples beyond the three stale counts

**C1 — `:200` "only 2 paths declared there" has three candidate referents, and only one
gives 2.** Under `corpus/surface-census.tsv`, the two subtrees carry **5** declared rows
(2 under `xdg-cache`: `:39-40`; 3 under `xdg-state`: `:49-51`), the depth-1 child count
of `$STATE` is **2** (the two dirs themselves), and `corpus/state-shape.tsv` has **2**
rows for `xdg-cache/opencode/models.json` (`:43-44`). If "declared there" means the
declared rows inside the subtrees the sentence is stale (5); if it means the two
depth-1 dirs it is true but the sentence's "a file inside …" wording points at the
other reading. The number cannot be bound until the referent is named; this is a
wording defect, not a proven count error.

**C2 — `:280` "this exact case is selftest 10" is off by one.** Static count of
`corpus/surface-census.sh:767-845`: cases 1-9 are the nine `run_case` calls at
`:768-776`, case 10 is `sqlite-unavailable` (manual increment at `:779`), case 11 is
`required-table-gone` (`:790`), case 12 `row-floor`, case 13 `malformed-row`, case 14
`fused-shape-row`, cases 15-16 the verbs. The entry's own `:140` correctly calls the
dropped-table case 11, so `:280` contradicts `:140`. This is outside the C1 population
only because QM26 excludes positional case indexes by rule; it is still a wrong
current-tense statement (`Do not use a helper ordinal as its contract`, `:304`).

**C3 — `:119` "Floors are one third of the observed value" is false for two of its own
six examples.** `tables_min 12` vs observed 20 is 60%, and log `size_min 16384` vs
33687 B is 48.6%; `session 2/7` is 28.6%, `message 13/39` exactly one third,
`part 18/55` 32.7%, `event 79/238` 33.2%. The six floor values themselves match
`corpus/state-shape.tsv:30,32-35,37` and are OK. The generalisation is withdrawn only
at `:298` ("The blanket 'one third' floor policy is withdrawn"), another
correction-note-elsewhere. Suggested: "Floors are per-row declared floors; four are a
third of the recorded observation, `tables_min` is 60% and the log floor is 48.6%."
The observed values (`7, 39, 55, 238, 20, 33687`) are host DB measurements (the
round-27 rule excludes DB rows) and are not in the C1 population.

**C4 — the erratum is not a history clause under QM21.** It gives no new value for any
of its three items; it names them "superseded" and moves on. A one-digit mutation of
`:5` `9 json` -> `8 json` (or `:76` `16` -> `9`) is invisible to every BASE binding:
`corpus/self-counts.tsv` at BASE has zero `KN-` rows, and the working table's two rows
for this entry target only `:32`. The mutation check is **not executed** here (contract:
no gate/binder runs); the expected STALE result follows from the integer comparison in
`corpus/self-counts.py` and remains unrun.

## What I did NOT check

- Did not run any gate, selftest, binder, ledger verify/cells, drift, or release-clock
  command; no `--mutate` control was executed. Unrun checks are not passes.
- Did not read the live host: `333/88/117` line counts, `L7-27`, `L293-333`, `755`, the
  child counts, DB row counts, `opencode.db` shapes and every `2026-09-28` receipt are
  unverified here and were excluded on that basis, not because they are false.
- Did not execute `corpus/surface-census.sh --selftest`; the 16-case count is static
  reading of `:767-845` cross-checked against BASE `R11-03`'s pin
  (`corpus/claim-ledger.tsv:17`, `^SELFTEST: PASS \(16 cases\)`).
- Did not verify the other knowledge entries in the round-27 population (other seats),
  nor whether the working-tree `KN-*` rows outside this entry are complete — the file
  changed while I read it.
- Did not enroll P1-P16 or run `ledger_command()` over them; the 6-column TSV shape,
  expected-exit and timeout fields, and the policy walk are L1's to validate. Their
  measured outputs were obtained with the exact argv only.
- Did not check whether the round-22 erratum's `Entry21.md` still resolves, nor any C2
  (release-clock) claim; this entry has no `on-release` recheck and no version anchor,
  so it contributes nothing to C2.

## Tool installs

None. No package, binary or service was installed or upgraded for this item.
