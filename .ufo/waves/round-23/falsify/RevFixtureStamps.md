# RevFixtureStamps — round-23 falsification (fixture stamp rows / `cells` teeth)

## Snapshot identity

The round-23 tree moved during this review (base `d218603b` + dirty → `e1884c6` →
`b55e0e7` → `7af07b4`; later HEAD `638d44c` has identical fixture blobs). Final
measurements below are pinned to the content that is identical across `b55e0e7`/`7af07b4`/
`638d44c` (fixture blobs unchanged across all three; `git diff --quiet -- <paths>` exit 0
at measurement):

| fixture file | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/fixtures/cells-hermetic/SCORECARD.md` | `2358325254a1e7eae0d8b0a6a6b201c7a3b5ea4766a24af3b4849564eb58566e` | 13 | 396 |
| `corpus/fixtures/cells-hermetic/claims.tsv` | `1a0737717ddc5b0ca053ac3677621be36f598d4158f34956d58dadf1feae7915` | 2 | 232 |
| `corpus/fixtures/cells-hermetic/stamps.tsv` | `401ebb3c8b15888c98b6b060972c49412b1da5980b3f1f36d09a0c113811031d` | 2 | 178 |
| `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv` | `fa15a53c7e586165a946c13c73f62995dfae9dff4fda2f55d3350a6682c8efaa` | 9 | 307 |
| `corpus/fixtures/cells-hermetic/corpus/fx-ok.sh` | `29f98fbaaa2412f5544523eaa7af24c62d5f119c75f88af7ef12b757ec4da614` | 2 | 38 |

The same five blobs were re-measured unchanged at HEAD `638d44c` after the final run;
R23-01 printed the identical CLEAN line, exit 0.

`HEAD` at final measurement: `7af07b4d80009988202ab771b47e4f5c1a788903`. The five fixture
files are tracked (`git ls-files corpus/fixtures` lists all five), and
`corpus/stamps.tsv:21-25` pins exactly the five rows above (values and wc columns match).
R23-01 is committed at `corpus/claim-ledger.tsv:59`. Read-only review; all mutations were
performed on `cp -a` copies under `/tmp` (removed). No installs, no host/network access,
no production edits.

## Verdict

- Both fixture stamp rows recompute exactly. No drift.
- A content mutation of the **cited** stamp path (`corpus/adjacency.tsv`) is detected as
  `STALE-POINTER`, exit 1, with all three columns reported, **even when the cited row still
  passes** (`row_failures=0`). Confirmation of the `cells` stamp tooth.
- The fixture's second stamp row (`corpus/fx-ok.sh`) is named by no scorecard cell.
  `cells` never compares uncited stamp rows: a comment-only edit to that stamped fixture
  file reproduces the **exact** R23-01 `CELL_AUDIT: CLEAN` line and exit 0. The lesson now
  states this bound (`fx-ok.sh` stamp "inert in this run"), and the repository `verify`
  compensates via `corpus/stamps.tsv:21-25`. Bound confirmed, not a capability failure.
- A cell citing a stamp but no row is counted as pointed (`UNCITED=0`, exit 0). The
  fixture's pinned `cells=6 row_pointed=6` structurally forces every cell to cite a row;
  that is the guard, not a per-cell gate rule.
- The pinned counts are cardinality, not membership: R23-01 alone passes a count-preserving
  scorecard pin swap and a mutation + matching fixture re-pin. At HEAD the repository-level
  pins (`corpus/stamps.tsv:21-25`) close those paths; the claim must keep them in its
  evidence chain.
- No defect remains in the current stamp rows, fixture commit, or C3 contract; one minor
  wording gap remains in the C3 table row (below).

## Recompute (final snapshot)

```
$ cd corpus/fixtures/cells-hermetic
$ sha256sum corpus/adjacency.tsv corpus/fx-ok.sh
fa15a53c7e586165a946c13c73f62995dfae9dff4fda2f55d3350a6682c8efaa  corpus/adjacency.tsv
29f98fbaaa2412f5544523eaa7af24c62d5f119c75f88af7ef12b757ec4da614  corpus/fx-ok.sh
$ wc -l corpus/adjacency.tsv corpus/fx-ok.sh   # 9, 2
$ wc -c corpus/adjacency.tsv corpus/fx-ok.sh   # 307, 38
```

Matches `stamps.tsv:1-2` exactly (sorted: adjacency first, fx-ok second). Both are regular
files, not symlinks, and end with `0a`. Independent execution: `bash corpus/fx-ok.sh` →
`FX: OK` rc0; `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` → `8` rc0.

## Baseline R23-01 (final snapshot)

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --claims corpus/fixtures/cells-hermetic/claims.tsv \
    --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
    --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
    --docs corpus/fixtures/cells-hermetic/SCORECARD.md
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
EXIT=0
```

The last line matches R23-01's ERE (`corpus/claim-ledger.tsv:59`) under the gate's own
`[[ $last =~ $EXPECT ]]` (**MATCH**, exit 0). The same line/exit were observed with
`CLAIM_LEDGER_DEPTH=1/2` (the outer `verify` runs rows at depth 1) and with
`KAGI_SUBSTRATE=absent`; `cells` mode is not depth-guarded and the fixture rows carry no
`[substrate]` tag.

## Mutation matrix (copies of the final fixture unless marked S0)

Run form: `bash corpus/claim-ledger.sh cells --root /tmp/<copy> --claims
/tmp/<copy>/claims.tsv --stamps /tmp/<copy>/stamps.tsv --scorecard
/tmp/<copy>/SCORECARD.md --docs /tmp/<copy>/SCORECARD.md`.

| id | mutation | exit | observed |
|---|---|---|---|
| A | append comment to cited `corpus/adjacency.tsv` (R90-02 count stays 8) | 1 | `STALE-POINTER corpus/adjacency.tsv sha=fa15a53c7e58->3e97915b5891 lines=9->10 bytes=307->329`; `BROKEN (… row_failures=0 … stale_pointers=1 …)` |
| B | append comment to uncited `corpus/fx-ok.sh` (output still `FX: OK`) | **0** | identical `CELL_AUDIT: CLEAN (… stamp_pointed=1 … stale_pointers=0 …)` |
| B′ | same copy, fixture `verify` mode | 1 | `STALE corpus/fx-ok.sh sha=29f98fbaaa24->ff3665abb15e lines=2->3 bytes=38->60`; `CLAIM_LEDGER: FAIL (claims=2 failed=0 … stamped=2 stale=1 …)` |
| C | append well-formed dead row `corpus/absent-not-cited.txt deadbeef… 1 1` to fixture `stamps.tsv` | **0** | identical CLEAN line (no stamp-row count in the summary) |
| C′ | same copy, fixture `verify` mode | 1 | `MISSING corpus/absent-not-cited.txt`; `FAIL (… stamped=3 … missing=1)` |
| D1 | scorecard variant: `adjacency` cell cites only `corpus/adjacency.tsv` (no row) | **0** | `CLEAN (cells=6 row_pointed=5 stamp_pointed=2 uncited=0 …)` |
| D1b | D1 + comment mutation of `adjacency.tsv` | 1 | `STALE-POINTER corpus/adjacency.tsv sha=fa15a53c7e58->4cec4bfb6278 lines=9->10 bytes=307->320`; `BROKEN (… row_pointed=5 … stale_pointers=1)` |
| D2 | scorecard variant: `calibration` cites only `corpus/fx-ok.sh` (fresh pin, no row) | **0** | `CLEAN (cells=6 row_pointed=5 stamp_pointed=2 uncited=0 …)` |
| E (S0) | delete cited `adjacency.tsv` | 1 | `FAIL R90-02 reason=exit-mismatch exit=2 want=0`; `MISSING-POINTER corpus/adjacency.tsv`; `row_failures=1 stale_pointers=1` |
| F (S0) | append comment to `adjacency.tsv` **and rewrite its fixture stamp row to match** | **0** | identical CLEAN line |
| G (S0) | append `printf 'TAMPER\n'` to the uncited script (behaviour change) | 1 | `FAIL R90-01 reason=verdict-not-final exit=0`; `BROKEN (… row_failures=1 stale_pointers=0 …)` |
| H (S0) | remove one `# no-enumerate` line (count 7) + comment | 1 | `FAIL R90-02 reason=verdict-not-final`; `STALE-POINTER … 307->273`; both counters 1 |
| I (S0) | scorecard pin swap `adjacency.tsv`→`fx-ok.sh`, counts unchanged | **0** | identical CLEAN line |
| I2 (S0) | I + comment mutation of now-uncited `adjacency.tsv` | **0** | identical CLEAN line |
| J (S0) | scorecard variant: one cell is prose only | 1 | `UNCITED …:12 adjacency`; `BROKEN (… row_pointed=5 uncited=1 …)` |
| K (S0) | scorecard variant: one cell cites `R90-99` | 1 | `MISSING-ID …:12 R90-99`; `UNCITED …`; `BROKEN (… missing_ids=1 uncited=1)` |

S0 = measured on the `d218603b` + dirty tree before the round-23 commit; the fixture cells,
gate code path and claims text it depends on are unchanged except the D9 comment line and
R90-02's timeout 10→30. The current fixture reproduces A/B/B′/C/C′/D1/D1b/D2 directly.

`stamp` reproducibility (S0): `bash corpus/claim-ledger.sh stamp --root <copy> --out
<copy>/stamps-generated.tsv corpus/fx-ok.sh corpus/adjacency.tsv` → `STAMPED: n=2` exit 0;
`diff` exit 1 was **row order only** (gate `stamp` sorts at `claim-ledger.sh:299`). At HEAD
the fixture `stamps.tsv` is sorted (`adjacency.tsv` then `fx-ok.sh`), so this is resolved.

## Findings

### F1 — Minor (claim wording): the C3 table overstates what R23-01 alone catches

`corpus/lessons/round-23.md:62` says "`R23-01` runs `cells` … a fixture mutation fails",
without naming the command. B shows an exact counterexample for R23-01 alone: a comment-only
edit to `corpus/fx-ok.sh` — a file pinned at `stamps.tsv:2` — yields the **exact** CLEAN line
and exit 0, because `cells` compares only paths a scorecard cell names (`CEL_PATHS`,
`corpus/claim-ledger.sh:770-772`, compared at `:830-840`). The fixture's own `verify`
reports `STALE` (B′), and at HEAD the repository pins `corpus/stamps.tsv:21-25` include
`fx-ok.sh` (row 24) and the fixture stamps file (row 25), so the repository `verify` catches
the mutation. The lesson contract already states the bound at `:159-160` ("`fx-ok.sh` stamp
is inert in this run"). The table row should either say "a mutation of a cited pointer or a
row fails" or name the repository `verify` as the command that catches uncited fixture
edits. This is a precision fix, not a capability failure.

### F2 — Bound (gate semantics, not a defect): a stamp-only cell is pointed

A cell whose only evidence is a path in `stamps.tsv` is not `UNCITED`; D1/D2 produce
`CLEAN (row_pointed=5 stamp_pointed=2 uncited=0 …)` exit 0, and the stamp is genuinely
hash-checked (D1b). The gate's non-vacuity rule is global — at least one cell must cite a
row (`claim-ledger.sh:779-790`) — not per-cell. The fixture is protected only because its
pinned line requires `cells=6 row_pointed=6`: with six cells, each contributes at most one
to `row_pointed`, so 6/6 forces every cell to cite a row. The claim must not present `cells`
CLEAN as "every cell rests on a re-run"; the exact pinned counts are doing that work.

### F3 — Bound: pinned counts are cardinality, not membership

`stamp_pointed` counts cells with at least one stamp pointer; no count identifies *which*
path. The exact CLEAN line survived a count-preserving evidence swap (I), after which a
comment mutation of the data file was invisible (I2). F (mutation + matching fixture re-pin)
is likewise CLEAN under R23-01: `STALE-POINTER` is consistency with the passed stamps file,
not an independent commitment. At HEAD the repository `verify` closes both paths because
`corpus/stamps.tsv:21` pins `SCORECARD.md`, `:23` pins `adjacency.tsv`, and `:25` pins the
fixture `stamps.tsv`; a fixture edit without a matching edit to `corpus/stamps.tsv` is
STALE there. The claim must keep `corpus/stamps.tsv:21-25` in the evidence chain; R23-01's
line alone does not authenticate the fixture metadata set.

### F4 — Confirmation: cited-stamp drift is caught independently of row verdicts

A reports `row_failures=0` with `stale_pointers=1`, and the `STALE-POINTER` line carries
old→new sha, lines and bytes (`claim-ledger.sh:830-838`, comparison at `stamp_cmp:353-365`).
A deleted cited file yields `MISSING-POINTER` plus the row's own failure (E). The intended
fixture mutations (uncited cell, bad id, failing row) fail (J/K/G). No drift was found in
either current stamp row.

### F5 — Resolved during review (recorded for the timeline)

The S0 tree (`d218603b` + dirty) had an untracked fixture, an unsorted `stamps.tsv`, and a C3
contract that said "four-file fixture… one row… empty-but-valid stamps file"
(`corpus/lessons/round-23.md:151-158` then), omitting `adjacency.tsv`; an empty stamps file is
in fact exit 2 (`claim-ledger.sh:319-321`, selftest `:1340`). The committed round-23 tree now
has the five-file fixture, two claims rows, two sorted stamp rows, the fx-ok bound, and the
fixture tracked at HEAD. No action remains; the S0 observation is recorded so the timeline is
not laundered.

## Bounds the claim must state (current)

1. R23-01 checks stamp pointers **only for paths a scorecard cell names**; the `fx-ok.sh`
   fixture stamp is inert in R23-01 (already stated at `corpus/lessons/round-23.md:159-160`).
   The repository `verify` pins all five fixture files at `corpus/stamps.tsv:21-25`; a
   fixture mutation is caught there, not by R23-01 alone.
2. `stamp_pointed=1` counts **cells**, not stamp rows. The fixture has two stamp rows; only
   `corpus/adjacency.tsv` is checked by R23-01.
3. A stamp-only cell is not `UNCITED` (D1/D2). The fixture's `cells=6` + `row_pointed=6`
   is what forces every cell to cite a row; the gate does not enforce it per cell.
4. Row re-execution checks exit + last line only: value changes are caught (H), comment-only
   edits to cited data are caught only by the stamp (A), and behaviour changes to an uncited
   script are caught by the row (G), not by its stamp (B).
5. The pinned counts are cardinality, not membership. A count-preserving scorecard pin swap
   (I) or a mutation + matching fixture re-pin (F) keeps R23-01's exact line; the
   repository-level `corpus/stamps.tsv` pins are the authenticating layer and must be in the
   claim's evidence chain.
6. "Committed fixture root" is now substantiated: the five fixture files are tracked at HEAD
   `7af07b4` (and were committed at `e1884c6`). If the verdict is measured at a later
   revision, name that OID and re-run R23-01; the fixture blob hashes above identify the
   measured content.

## Residual risk / verification gaps

- I did not run the full 45-row `verify` (explicitly out of scope). R23-01's exact command was
  run directly and at `CLAIM_LEDGER_DEPTH=1/2`; the repository-level fixture-pin coverage is
  established by `verify_stamps` iterating every stamp row (`claim-ledger.sh:371-403`) plus a
  manual sha/lines/bytes comparison of `corpus/stamps.tsv:21-25` against the five blobs, not
  by executing the full gate.
- E/F/G/H/I/I2/J/K were measured at S0; the gate code path and fixture cell text they depend
  on are unchanged at HEAD (D9 comment and R90-02 timeout are irrelevant to those cases), and
  A/B/C/D1/D2 were re-measured on the final fixture.
- The round-23 tree moved across five observed OIDs (`d218603b` → `e1884c6` → `b55e0e7` →
  `7af07b4` → `638d44c`); all final facts are pinned to the hashes and OID above. If HEAD
  advances again, re-run the two commands and compare the fixture blobs.
- No production edits; `/tmp` scratch copies were removed.
