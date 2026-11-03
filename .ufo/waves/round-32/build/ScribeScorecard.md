# ScribeScorecard — round-32 scorecard sections (draft)

Seat: `ScribeScorecard` (scribe, leaf; no sub-spawns). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; contract `plans/round-32.md` (commit `507dd9f`).
Lane HEAD at read time `76241c0` (round-31 late-seat evidence, verifier R2 — `.ufo/` only; `507dd9f`
adds only `plans/round-32.md`), so 32c35fe is still the correct content label for the pre-move row.

## Behavior delivered

Drafted the two round-32 sections for `SCORECARD.md` plus the one-line Move-log row, in
`.ufo/waves/round-32/build/scorecard/round-32-sections.md`:

- `## Round 32 — pre-move (repo HEAD 32c35fe, round-31 close)` — one table, six axis rows, all at **9**
  (the round-31 post-move values). Calibration row names `R25-02`, `R29-01`, `R29-02` and states the 9 is
  kept with the reason (operator-routed POLICY/FAIL: the cell audit reports a red the lane cannot clear
  without an operator gate-policy decision). Depth/coverage/operability/adjacency rows state unchanged with
  a row pointer.
- `## Round 32 — post-move (claims C1 calibration, C2 freshness)` — one table, six axis rows, each
  `9 → 9` (no score cell in this file has ever used 10; the round records a mechanism landing, not a scalar
  move). Calibration row = C1 `SELF_DESCRIPTION`, freshness row = C2 `BYTE_PIN`, calibration row names all
  three routed reds again (SD5 reads the *latest* calibration row). Both moved rows state the counting
  command; every measured value is `[L1-FILL]`.
- Move-log row: `| 32 | calibration + freshness | 9 | 9 | … |`, carried as an indented code line so the
  post-move section keeps exactly one table.

Nothing in the draft changes a predicate, counter, kill rule or target. Nothing outside my two write
paths was touched; no commit, no git/jj mutation, no vault contact (`op` was invoked once, read-only,
`op --version`).

## Checks run (each once, on the delivered bytes)

| Command | Exit | Result |
|---|---|---|
| `op --version` | 0 | `2.41.1` (grounds the version the draft and C2 name) |
| `git -C <lane> rev-parse HEAD`; `git merge-base --is-ancestor 32c35fe HEAD` | 0 / 0 | HEAD `76241c0`; 32c35fe is an ancestor |
| `git -C <lane> show --stat 76241c0` / `507dd9f` | 0 / 0 | `.ufo/` evidence only / `plans/round-32.md` only |
| heading check: `SEC_RE`/`ROUND_RE`/`AXES_RE` extracted from `corpus/claim-ledger.sh` with `sed`, then `grep -E` on the draft + an awk replica of the `cells` loop | 0 | `sec_matches=2`, `round_matches=2` (the same two lines), `unrecognised=0` |
| per-section structure (same replica) | 0 | each section `axes=6` (all six, once each), `tables=1` per section, `axis_rows_total=12` |
| pointer resolution (`verify-pointers.txt`) | 0 | 10 distinct row ids, all present in `corpus/claim-ledger.tsv`; 9 of 11 path-like tokens exist (the two misses are the bare `claim-ledger.sh` prose token — not a checked citation class — and `corpus/self-description-sweep.sh`, which lands this round; finding 2) |
| cell projection (parser rules vs `corpus/stamps.tsv`) | 0 | `cells=+12 row_pointed=+12 stamp_pointed=+5` → spliced file projects `234/174/108` |
| `grep -c` of the routed reds in `SCORECARD.md` | 0 | `R25-02`=5, `R29-01`=9, `R29-02`=7 occurrences — the new rows add no id to the re-run set |
| receipt read `.ufo/waves/round-31/final/receipts/cells-at-tip.txt:42-43` | 0 | `CELL_AUDIT: POLICY (cells=222 row_pointed=162 stamp_pointed=103 policy=2)`, `cells-exit=2` |

Regex actually verified against (verbatim from `corpus/claim-ledger.sh`):

    SEC_RE='^ {0,3}##[[:blank:]]+Round [0-9]+ — (pre|post)-move([[:blank:]]|$)'

Both drafted headings match it, and every line matching `ROUND_RE` is in that accepted set, so the gate
cannot die with `unrecognised round heading`.

## Findings for the L1 (act before the cells/citations run)

1. **Two ledger rows must migrate on S072.** `R21-02` and `R31-02` anchor
   `^SOURCES_CENSUS: CLEAN \(rows=71 …` and the plan's census-after is `rows=72` (S072 only). Until both
   are migrated (old→new logged), `cells` re-runs two failing rows and `verify` fails on them.
2. **Splice ordering.** The post-move text cites `corpus/self-description-sweep.sh`, which does not exist
   yet (citations class `local`, `corpus/*`). Splicing the sections before that file lands makes
   `claim-ledger.sh citations` print `UNRESOLVED` for it — and SD6 counts exactly those lines.
3. **Stamp re-pin set.** Tokens in the new rows that the `cells` audit treats as stamp pointers:
   `corpus/eol-sweep.sh`, `corpus/claim-ledger.sh`, `corpus/sources-census.sh` (unchanged this round);
   `corpus/knowledge/op-ref-consumption.md` (§11.1 lands), `corpus/README.md` (SD2 tombstone removal),
   `SHONEN.md` (SD3 token fix), `SCORECARD.md` (the splice). The last four change this round, so their
   stamps must be re-taken after the edits or the audit reports `STALE-POINTER`.
4. **Cell counts move.** +12 cells / +12 row-pointed / +5 stamp-pointed → projected `234/174/108`.
   `R31-01`'s anchored expectation (`cells=[0-9]+ …`) still passes, but any prose that restates
   `cells=222` must present it as the round-31 receipt value (the pre-move intro says so explicitly).
5. **`[L1-FILL]` points (12).** Line 39 (calibration ×4: measured sum, sweep last line, sweep exit,
   selftest case count), line 40 (freshness ×4: version-count, probe BASE line, probe last line, exit),
   line 42 (coverage ×2: census line, exit), line 52 (move-log counts). Line 26 is the intro's mention of
   the convention, not a value.
6. **SD5 is satisfied twice.** Both calibration rows name `R25-02`, `R29-01`, `R29-02`, so SD5 reads 0
   whichever of the two sections the sweep treats as latest. The three rows stay red and operator-owned:
   naming them is the fix, clearing them is not (that is the `PYTHON_SCRIPT_RE` gate-policy decision).
7. **Score convention is an author choice in the draft.** Post-move `9 → 9` follows every round since 28
   and the seat's own Move-log template. If the L1 admits a scalar move, edit the after cell *and* the
   Move-log row together; do not leave the two disagreeing.

## Not run (deliberately) / known limits

- Not run: `claim-ledger.sh cells|citations|verify`, `sources-census.sh`, `self-counts.py`,
  `op-ref-probe.sh`, `self-description-sweep.sh` (absent), any stamp or commit. The L1 runs the gates.
- Heading acceptance is verified by the parser's own regexes extracted from source plus a replica of its
  loop, not by a gate run; the per-cell counts are a projection of the parser's rules.
- Pointer *relevance* is unverifiable by the gate (round-13 ceiling); pointers here resolve and are on the
  axis they are cited for, but a re-run of those rows is the L1's evidence, not this draft's.
- `[L1-FILL]` values are unmeasured by design; a non-clean C1 or C2 must be reported as a partial move
  under the plan's kill rules, not re-scoped.
- The pre-move 9s restate round-31 close values (reference line, not a round-32 measurement).
- Tooling: nothing installed or upgraded this seat (no pacman/uv/npx use).

## Files written

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/scorecard/round-32-sections.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/scorecard/verify-headings.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/scorecard/verify-pointers.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ScribeScorecard.md` (this report)

Scratch `/fast/scratch/hyaku/kagi-r32/ScribeScorecard/` was created with `mkdir -p`, used with
`TMPDIR=…/tmp`, and removed by the shell trap. Final draft: sha256
`882529fd111151bb588d41177dfa19d05ee1db14bd8bc011453122a81f1e9a64`, 7346 bytes, 52 lines.
