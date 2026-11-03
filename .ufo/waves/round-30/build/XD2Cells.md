# XD2Cells — round-30 C1 doc-cell pre-integration

Tree measured: `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (frozen BASE `f67232c` + plan commit).
Host: Arch Linux, `python3` 3.14.8 at `/usr/bin/python3`; `sqlite3` present; the-janitor substrate
absent; `op 2.41.1` read only as `--version` class (never executed here). No installs; no lane
production file edited; no lane git/jj mutation; no credential reads.
Drafts + receipts: `.ufo/waves/round-30/final/c1/` (file `cells-draft.md` carries the exact
before/after line texts).

## Result

Eight bound doc cells are stale at this revision, not six; one further current-tense number is
stale and has no `self-counts.tsv` binding at all. Drafts for all of them are in
`final/c1/cells-draft.md`. Applying them to a scratch mirror drops `self-counts` from
`stale=8` to `stale=0` with every other binding intact.

## The six routed cells (4 lines)

| cell | file:line | old | new | live source |
|---|---|---|---|---|
| SC-SKILL-STAMPS | `SKILL.md:46` | `91 stamps` | `94 stamps` | `grep -c '[^[:space:]]' corpus/stamps.tsv` ⇒ 94 |
| SC-SKILL-CLAIMS | `SKILL.md:46` | `65 claims` | `67 claims` | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` ⇒ 67 |
| PV-STAMPS | `PROVINCE.md:73` | `91 revision stamps` | `94 revision stamps` | same stamps source |
| PV-CLAIMS | `PROVINCE.md:73` | `65 claim rows` | `67 claim rows` | same ledger source |
| RD-LEDGER-ROWS | `corpus/README.md:64` | `65 rows` | `67 rows` | same ledger source |
| RD-STAMPS | `corpus/README.md:65` | `91 rows` | `94 rows` | same stamps source |

Exact old→new (substring-level; whole lines in the draft file):

- `SKILL.md:46` — `(91 stamps + 65 claims ` → `(94 stamps + 67 claims ` (file is CRLF today; the
  line must land LF-only under C2).
- `PROVINCE.md:73` — `` `verify` (91 revision stamps + 65 claim rows; `` → `` `verify` (94 revision stamps + 67 claim rows; ``.
- `corpus/README.md:64` — `| 65 rows (39 at round 21` → `| 67 rows (39 at round 21` (parenthetical
  history untouched; optional `; round 29 added `R29-01..02`` noted in the draft).
- `corpus/README.md:65` — `| 91 rows (89 at round 26` → `| 94 rows (89 at round 26` (optional
  `91 at round 28, ` anchor noted in the draft).

Cluster cause: round-29 work commits added three stamps (`corpus/feed-token-agree.py`,
`corpus/knowledge/feed-token-boundaries.md`, `corpus/lessons/round-29.md`) and two ledger rows
(`R29-01`, `R29-02`). Round-28 receipts (91/65) are the last correct values.

## Two more stale bound cells — same surface, plan prose undercounts

| cell | file:line | old | new | live source |
|---|---|---|---|---|
| RD-DOCS-ROWLINKED | `corpus/README.md:67` | `22 row-linked` | `23 row-linked` | `bash corpus/claim-ledger.sh docs` |
| RD-DOCS-ENTRIES | `corpus/README.md:67` | `25 pinned` | `26 pinned` | same (`entries=26 row_linked=23 by_hand=3`) |

These are inside the plan's own R14-01 migration scope, so this is not new scope — only the
plan's "six STALE cells" statement is off. Measured at BASE (`f67232c`) **and** at the plan commit:
`SELF_COUNTS: POLICY (claims=62 stale=8 … policy=2 setup=1)`; the four extra are these two plus the
four routed PV/SC pairs. Receipt: `final/c1/XD2Cells-before-selfcounts.txt`.

## One more stale current-tense number, with no binding at all

`PROVINCE.md:36`: `sources-census validate (CLEAN rows=51)` → `… (CLEAN rows=52)`.
Live: `SOURCES_CENSUS: CLEAN (rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5
legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
Provenance: the line was written in `fc65112`, the round-29 commit that added S052 — `SOURCES.md`
already had 52 registry rows there, so the number was stale when written, not round-dated history.
`self-counts.tsv` has **no** registry-row binding, which is why the cell survived the gate.
Recommendation: bind it (`ledger:R21-02`, extract `rows=\(([0-9]+)`) or drop the number; the other
counts on that line are correct (`34` live, `36` R12-02 pin, `116` live).

## Sweep — checked, unchanged (no edit)

Declaration/file-derived counts all still match: surface `35` (20 asset / 15 runtime, 4 `# scan`,
1 `mode = -`), state-shape `22`, drift baseline `15` files with `6` `-` hashes, drift symbols `20`,
checklist `16` rows / `9` runnable, adjacency `5` `# own` / `4` groups / `8` no-enumerate /
`4` breadth / owned `27 = 35−8`, ledger `170` selftest cases, closure `14`, rendered `22`,
self-counts `48`, release-clock `116`, sources-census `70`, scope `61`, checklist `34`, op-ref `36`,
`30 bounds` in `knowledge/claim-ledger.md`. Every one is listed with file:line and binding in
`cells-draft.md` §D.

Deliberately out of population, **no** draft:

- `README.md:44` / `PROVINCE.md:72` breadth ratios `20/4, 105/2, 4/1, 53/1`. Declaration-derived
  parts are current; the child counts are host state measured with the substrate present and they
  differ here (`5`, `112`, `3`, chrome-profile **absent**; totals 120 vs the pinned 182) — receipt
  `XD2Cells-breadth-host.txt`. `R16-01`/`R17-01` are `[substrate]`-tagged and DEFER with the
  handler absent, so this is a correct host output. Re-pinning from this host would encode a
  substrateless state as truth: **do not**.
- Round-dated history lines (`SKILL.md:187/198/253/620/631–633/654–656`, `README.md:35/64/65/67`
  parentheticals, `PROVINCE.md:30–33/37/73` round clauses, `README.md:76–78` read dates): untouched.

## Cross-claim calibration notes (evidence, not judgments)

1. **Plan prose vs measured before-state.** "self-counts.py ⇒ exit 2, six STALE cells" is
   understated: eight at BASE (`f67232c`) and at the plan commit. The extra two are the
   `README.md:67` docs cells; they are in the R14-01 migration scope, so the *scope* is sound but
   the *count* in the plan text (and any receipt that repeats it) is not.
2. **C2's frozen counter 2 cannot print `0` as written.**
   `grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l` ⇒ **166** at the lane root
   (135 of them tracked: 132 `.ufo` evidence files — HTTP header captures, round-29 receipts — plus
   `SKILL.md`, `corpus/SOURCES.md`, `corpus/claim-ledger.tsv`). `--exclude-dir=.ufo` ⇒ **3**, which
   is the plan's stated "before". The counter needs its scope named (tracked lane sources, or
   `--exclude-dir=.ufo`) before it can be a 0/3 gate; converting CR-bearing evidence captures
   would corrupt receipts. Plan corrections are still appendable (no work commit has landed).
3. **C1's counting command #1 is C2-coupled through one non-enumerated row.** `self-counts` reaches
   `CLEAN` only with `setup=0`, and `KN-CHECKLIST-FALSIFY-FLOOR` (`ledger:R15-05`) is `SETUP exit=2`
   while `corpus/checklist-run.sh --ratio` cannot see its section under CRLF. Scratch proof
   (CR stripped, nothing else changed): `--ratio` ⇒ exit 0
   `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`, and the row becomes
   `OK … claimed=8 live=8` with `setup=0`. So the twelve enumerated rows are separable as planned,
   but the *frozen counting command* is not: C1's after-state depends on C2's byte repair.
4. **R29-01/R29-02 policy is a two-gate split.** `self-counts.py` allows first token
   `{bash,grep,python3}` (`ALLOWED_COMMANDS`, L54) and does not inspect arguments, so re-hosting
   to `python3 …` clears its `POLICY` (it will then execute the gate). `claim-ledger.sh` is
   stricter: `PYTHON_SCRIPT_RE` (L263) requires `^python3[[:space:]]+corpus/(feature-claims|
   revision-audit|closure-dispositions|rendered-text-v1|self-counts|release-clock)\.py` with **no
   flags** and a closed alternation — `feed-token-agree.py` is absent from it and `-I -B` breaks
   the shape. The plan's prescribed `python3 -I -B …` fix therefore clears `self-counts` but not
   `claim-ledger verify`; passing needs gate code (registration/flag tolerance), i.e. a semantics
   change, which C1's kill rule forbids. Independent of seat XD1Rows, whose receipt reports the
   same.
5. **`self-counts` cannot reach `CLEAN` at all while `policy=2`.** Even with all doc cells and all
   ledger pins migrated, the verdict stays `SELF_COUNTS: POLICY (…)` until R29-01/R29-02 stop being
   `python`-first-token. The plan lists those two rows in C1's scope, so this is expected — it is
   flagged only so the after-receipt is read with the right expectation.

## Files changed

- `kagi-shokunin/.ufo/waves/round-30/final/c1/cells-draft.md` (new; exact before/after lines)
- `kagi-shokunin/.ufo/waves/round-30/final/c1/XD2Cells-before-selfcounts.txt` (new; lane tree)
- `kagi-shokunin/.ufo/waves/round-30/final/c1/XD2Cells-after-selfcounts.txt` (new; scratch mirror)
- `kagi-shokunin/.ufo/waves/round-30/final/c1/XD2Cells-cell-diff.txt` (new; 6 changed lines)
- `kagi-shokunin/.ufo/waves/round-30/final/c1/XD2Cells-live-counts.txt` (new; measured values)
- `kagi-shokunin/.ufo/waves/round-30/final/c1/XD2Cells-breadth-host.txt` (new; host breadth table)
- `kagi-shokunin/.ufo/waves/round-30/build/XD2Cells.md` (this report)
- `kagi-shokunin/.ufo/waves/round-30/XD2Cells-report.md` (pointer)

No lane production file was written; nothing outside the lane; no tool installed.

## Risks / blockers for integration

- If the L1 applies only the six routed cells, `self-counts` stays `stale=2` (`README.md:67`);
  §B is required for `stale=0`.
- `SKILL.md:46` must be written LF-only; a CRLF write re-creates D5 on the largest doc.
- `PROVINCE.md:36` has no binding: leaving it is invisible to every gate and will drift again on
  the next registry row. Treat as a binding gap, not a one-off correction.
- `claim-ledger verify` for `R29-01/R29-02` cannot pass by value migration; if the L1 claims C1
  CLEAN on the strength of `self-counts` alone, that is `POLICY`, not CLEAN
  (`SELF_COUNTS: POLICY … policy=2`).
- Scratching my seat's numbers against seat XD1Rows' live receipts: they agree exactly
  (94 / 67 / 35 / 26-23 / 52 / added=31; identity shas `94df9364…`, `917ef251…`, `92016a58…`,
  `b0d0f6f5…`).
