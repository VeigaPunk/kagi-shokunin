# R68ExecLedger — claim ledger repair and extension (round 68, wave kagi-r68-w1)

Seat: R68ExecLedger (executor). Sole writer of `corpus/claim-ledger.tsv`, `corpus/stamps.tsv`,
`corpus/claim-ledger.sh`, `.ufo/waves/round-68/journals/*`; `corpus/claims-declared.tsv` rows per
this seat's spec. Lane `kagi-shokunin`, claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`,
predeclaration `23a8e0290d8d3a6f1de16eafce40fd1a189ef636`, plan `plans/round-68.md` (§C2 L1–L3,
Amendment A1).

## Files changed

| file | change |
|---|---|
| `corpus/claim-ledger.tsv` | `R21-03` expect migrated 88 -> **98 cases** (the landed gate's selftest count); `R11-09`/`R18-03` 170 -> 175; `R68-01`/`R68-02` minted from the plan; `R21-04` 87 -> 101 and `R24-14` 86 -> 101 + digest re-derived (direct consequence of the two new rows). No row deleted; every other row's command and expect byte-identical. |
| `corpus/claim-ledger.sh` | `cells`: `## Round <N> — planned` and one parenthetical suffix with no `|` inside (`— planned (next)`) are skipped as non-scored; a `|` table under either is a loud setup error (the critic's rename-hide bypass); a suffix outside that shape is still unrecognised; a scored section missing an axis still dies. Five isolated selftest cases (97–101). |
| `corpus/stamps.tsv` | three rows re-pinned from measured bytes: `corpus/claim-ledger.sh`, `corpus/claim-ledger.tsv`, `corpus/knowledge/source-capture-binding.md` (final scribe bytes). Membership unchanged at 164 rows; no pin dropped. |
| `corpus/claims-declared.tsv` | `68<TAB>C1<TAB>freshness`, `68<TAB>C2<TAB>calibration` (63 claim rows, the plan's predicted count). |
| `.ufo/waves/round-68/journals/expectation-migrations.json` | five migrations: `R11-09`, `R18-03`, `R21-03`, `R21-04`, `R24-14`. |

Receipts: `.ufo/waves/round-68/w1/R68ExecLedger/` (`L1-journal-clean.txt`,
`L2-claims-declared.txt`, `L3-selftest.txt`, `L3-cells-after.txt`, `L3-cells-before.txt`,
`preexisting-drift.txt`, `R68-01-counter-run.txt`, `L1-census-selftest.txt`).

## L1 — freshness: the census selftest pin (C2 leg L1)

Measured on first contact (gate bytes at that moment, before the gate seat's widened case set landed):

```
$ bash corpus/sources-census.sh --selftest | tail -1
SOURCES_CENSUS_SELFTEST: PASS (89 cases)
```

While the gate seat was landing the widened reason cases the same command read
`FAIL (98 cases, 2–3 failed)`; the pin was re-derived twice and ends on the gate's own **landed PASS
line**:

```
$ bash corpus/sources-census.sh --selftest | tail -1
SOURCES_CENSUS_SELFTEST: PASS (98 cases)
```

So the journal pair is `88 -> 98` (89 was the count at first contact; 98 is the landed gate's count —
the growth is the round's own `capture-whitespace` / `capture-token` / `normalized-digest-mismatch` /
`SC_FETCH cr-in-tsv` cases). The case **count** has been stable at 98 across the gate seat's final
edits; the gate's **verdict** flipped back to `FAIL (98 cases, 79 failed)` at 10:04 while that seat kept
editing, so the count is pinned and the landing tree must still show `PASS (98 cases)` for the row to
read green. Re-derive both if the gate's bytes move again.

`R21-03` was the only row whose value this round's *claim* moves. The gate-count migration protocol
holds: the old expect (88) is the BASE ledger's byte-exact value, the new expect is the candidate's,
both anchored and fully literal, and `expect-journal.sh` re-derives `CLEAN`.

```
$ bash corpus/expect-journal.sh --base-ledger /fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e/corpus/claim-ledger.tsv \
      --ledger corpus/claim-ledger.tsv --journals .ufo/waves/round-68/journals
EXPECT_JOURNAL: CLEAN (changed=5 journaled=5)
EXIT: 0
```

## L2 — calibration: the round's two claims are ledger rows

```
R68-01  bash plans/round-68-c1.sh   ^C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1$
R68-02  bash plans/round-68-c2.sh   ^C2_RECORD: mismatches=0 population=3 guard=1$
```

Each note names its plan section and the frozen target string. `R68-01` pins the **landed counter's**
final line: §C1 as amended by A1 (38/33 — the recut-only tree reads 37/32 and the round's own S167
fetch row is the second +1). `R68-02` pins §C2's frozen predicate unchanged.

The counters were executed on the candidate tree, not merely text-checked:

```
$ bash plans/round-68-c1.sh --tree .        (receipt R68-01-counter-run.txt, final run)
c1-verified: guard a=1 b=1 c=1 d=1 e=1 defe defects=0
C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1
EXIT: 0
```

This is the frozen target line exactly, and ledger row `R68-01` was then run through the ledger's own
verdict machinery (command + exit + last-line): `CLAIM_LEDGER: FAIL (claims=2 failed=0 …)` over the
`R21-03`/`R68-01` pair — both rows pass. All six mutation legs fired with the expected reasons (M1/M2
`capture-whitespace`, M3 FAILED via `SC_FETCH`, M4 `capture-digest-mismatch`, M5
`normalized-digest-mismatch`, M6 `capture-bytes-mismatch`+`capture-digest-mismatch`), `defects=0` over
the whole fetch population, and the BASE-blindness witness (leg c) reads CLEAN.

Recorded history, because a SETUP is never a pass: an earlier run of the same command printed
`guard=0` with `guard-c … SOURCES_CENSUS: SETUP (rendered-text-v1.py absent beside the gate)` — a
staging defect in the counter's leg (c) that its owner fixed after this seat reported the exact line.

`R68-02` itself was not executed to completion by this seat: the counter's owner was running its own
copy (its `python3 … R68ExecCounterC2/base-tree` process) while the script was still being edited, so a
second concurrent run (each runs `verify` twice plus a ~15 min `cells`) was cancelled and the empty
receipt replaced with that note. The row is pinned to the frozen target; the legs this seat could
measure are below (L2 `claims-declared` CLEAN, L1 journal CLEAN, L3 cells verdict line present).

`claims-declared` rows landed (63 = the plan's predicted candidate count). While the round's
`## Round 68 — post-move` section was still unlanded the gate read
`CLAIMS_DECLARED: MISMATCH (claims=63 mismatch=2)` with two `section-missing` findings — reported, not
worked around, because `SCORECARD.md` is the integration owner's file. After the L1 landed the section:

```
$ bash corpus/claims-declared.sh --root .
CLAIMS_DECLARED: CLEAN (claims=63)
EXIT: 0
```

## L3 — calibration: the cells audit no longer stops at a planned heading

Before (BASE and candidate, same die):

```
claim-ledger: unrecognised round heading in …/SCORECARD.md: '## Round 63 — planned'
              (expected '## Round <N> — pre-move|post-move')
```

After (tightened by the wave critic's bypass finding, then amended by the L1 ruling that historical
SCORECARD headings are records): the skipped shape is
`^## Round [0-9]+ — planned( \([^|)]*\))?$` — the exact heading, or one parenthetical suffix that
carries no `|`/`)` (`— planned (next)`). Two boundaries carry the critic's point: a heading outside
that shape (`… — planned claims table`) is still an unrecognised round heading, and **any `|` table
line between a skipped planned heading and the next heading dies loudly**, so a scored section can
never be renamed `planned` to escape the six-axis check or the pointer audit (a rename without a table
hides nothing; a rename with one dies). A scored section that has lost an axis still dies.

Selftest, one case per direction, on isolated scratch fixtures:

```
$ bash corpus/claim-ledger.sh --selftest
ok-case  97 cells-planned-section-skipped      exit=0   (skip-planned passes, CLEAN)
ok-case  98 cells-planned-scored-five-refused  exit=2   (scored-missing-axis dies: 'all six axes')
ok-case  99 cells-planned-rename-hide-refused  exit=2   (table under planned dies: 'score table under an unscored planned heading')
ok-case 100 cells-planned-suffix-refused       exit=2   (suffix outside the parenthetical shape dies: 'unrecognised round heading')
ok-case 101 cells-planned-paren-skipped        exit=0   ('## Round 64 — planned (next)' with no table is CLEAN)
SELFTEST: PASS (175 cases)
```

Real tree (`bash corpus/claim-ledger.sh cells`, 922 s wall, receipt `L3-cells-after.txt`):

```
CELL_AUDIT: POLICY (cells=576 row_pointed=286 stamp_pointed=247 policy=3)
EXIT: 2
```

A **verdict line**, not a SETUP: the `unrecognised round heading … '## Round 63 — planned'` die is
gone, both historical planned headings (`## Round 63 — planned`, `## Round 64 — planned (next)`) are
skipped, and the scan reaches the end of the file. The remaining verdict is not the parser: three
cited rows are policy-refused (`R29-01`/`R29-02` first-token `python`, `R38-03` `python-script`) and
118 cells across rounds ~43–68 carry no resolving pointer (`UNCITED`) — pre-existing scorecard and
policy-allowlist debt that the old die hid by aborting at line 2182. Both are outside this seat's
files (`SCORECARD.md` is the integration owner's; the policy allowlist is a deliberate
execution-surface gate). One `STALE-POINTER` line names `corpus/source-fetches.tsv`, which is
mid-edit by the recut seat at measurement time.

The hermetic fixture row `R23-01` is unchanged by the edit:

```
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2
                   row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0 host_skipped=0)
```

## Stamps

Re-pinned from measured bytes only (never from a message); the scribe edited its entry twice
after a first pin, and each time the row was re-derived from the live file:

```
corpus/claim-ledger.sh                              ca923b0d942f…  1864 lines  122099 B
corpus/claim-ledger.tsv                             a7e8713eb2e2…   119 lines   59692 B
corpus/knowledge/source-capture-binding.md          8edec03c3ff2…   342 lines   23146 B
```

Membership unchanged (164 rows) — no pin dropped, no `--prune` used. The one-argument `stamp` the
seat spec names is refused by design (it regenerates the whole row set from the paths given), and the
refusal is recorded rather than forced:

```
$ bash corpus/claim-ledger.sh stamp corpus/knowledge/source-capture-binding.md
claim-ledger: refusing to shrink …/corpus/stamps.tsv: 'corpus/adjacency.tsv' is pinned and would be
dropped (existing 164 rows, new 1; pass --prune to accept)
EXIT: 2          # stamps.tsv untouched, still 164 rows
```

The row updates were therefore surgical (same measurement, no other seat's mid-flight bytes re-hashed:
`corpus/sources-census.sh`, `corpus/source-fetches.tsv`, `corpus/SOURCES.md` and `SCORECARD.md` are all
still mid-wave). `docs` after the pins:

```
DOC_AUDIT: CLEAN (entries=48 row_linked=45 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)
```

## Pre-existing drifted expectations — routed to round 69, NOT migrated

L1 ruling: these are historical drifted pins; C2's guard (b) is a BASE-vs-candidate finding-id set
difference, and rewriting a dozen historical pins is outside this round's claims. Measured values
(`preexisting-drift.txt`):

| row | expect | measured 2026-11-08 |
|---|---|---|
| `R21-02`, `R31-02`, `R33-02`, `R34-03` | `rows=114 … captures=114` | `rows=158 A=141 B=2 C=15 queued=3 mined=138 rejected=17 entries_sourced=27 legacy=21 captures=158` |
| `R14-01` | `entries=38 row_linked=35` | `entries=48 row_linked=45 by_hand=3` |
| `R12-03` | `^125$` | `164` |
| `R24-05` | `count=125 sha256=369e92e5…` | `count=164 sha256=cefa14d3…` |
| `R13-01` | `^73$` | `98` |
| `R24-06` | `count=73 sha256=eea94d35…` | `count=98 sha256=82240326…` |
| `R22-03` | `REVISION_AUDIT: CLEAN (… added=62 …)` | `REVISION_AUDIT: DRIFT (stale=5 … added=101 …)` |
| `R24-15` | `ROW_IDENTITY: revision-added count=62 …` | `ROW_IDENTITY: SETUP (revision-audit --history failed)` |

Class for round 69: **expectation drift is a standing debt** — a count/membership row goes stale on
the same commit that moves the object it counts (the qm90 class), and rounds 51–67 stopped
re-deriving them. `R21-03` is the same class, which is why C2 L1 exists.

## Blockers and observations (measured, not inferred)

1. **Gate state at handoff.** `corpus/sources-census.sh --selftest` read `PASS (98 cases)` at 09:58
   (the line `R21-03` is pinned from, 88 -> 98), then flipped back to `FAIL (98 cases, 79 failed)` at
   10:04 while the gate seat kept editing; the case count stayed 98 throughout. The pin is the landing
   tree's `PASS (98 cases)`; if the gate's bytes or count move again, `R21-03` and the journal pair
   must be re-derived in the same commit.
2. **C1 counter guard leg (c) is a staging defect** (owner: R68ExecCounterC1; messaged with the exact
   line): `SOURCES_CENSUS: SETUP (rendered-text-v1.py absent beside the gate)`. The BASE-gate copy
   needs `corpus/rendered-text-v1.py` (and `inrow-pins.tsv`) staged beside it, as the C2 counter
   already does. Until then the counter prints `guard=0` and `R68-01` reads red.
3. **C2 counter leg3 hidden-table fixture is unreachable** (owner: R68ExecCounterC2; messaged).
   Its `l3-hidden` fixture writes `claims.tsv` = `# fixture`, and `cells` refuses an empty ledger
   (`no claim rows … refusing to resolve ids against an empty ledger`, exit 2) before the scorecard is
   ever parsed, so no `UNCITED` line can be produced. Under the critic-tightened rule a planned table
   is a setup error, not `UNCITED`, so the control must now assert the die message; it also needs one
   real claim row + script (as its own scored-missing-axis fixture already has).
4. **`cells` on the real tree is not CLEAN for reasons outside this seat**: 118 `UNCITED` cells
   (rounds ~43–68) and three policy-refused cited rows (`R29-01`, `R29-02`, `R38-03`); the verdict is
   `CELL_AUDIT: POLICY (cells=576 row_pointed=286 stamp_pointed=247 policy=3)`, exit 2, 922 s wall.
   The planned-heading SETUP is gone; the rest is the scorecard's and the policy allowlist's debt.
   Consequence for the C2 counter (reported to its owner): leg3's `if rc != 0: fail` and its 900 s
   budget are both unreachable/false on this lane — the gate should accept a `CELL_AUDIT:` verdict line
   with no `unrecognised round heading` and no planned-heading defect, plus its fixture-level
   negative controls.
5. No tool installed or upgraded this wave (operator channel unused).
