# ConnCellsPatterns — round-23 falsification of the hermetic `cells` fixture

Seat: `KagiR23.ConnCellsPatterns`. Axes in play: **calibration**, **freshness**, **operability** (C3/D9 is the direct target). Read-only on the lane; the only lane write is this report. All scratch is under `/tmp` (owned, outside the repo). No installs, no network, no `verify` invocation, no host-bound row.

## What I attacked

`corpus/fixtures/cells-hermetic/` and its claim row `corpus/claim-ledger.tsv:59` (R23-01), compared against:

- the in-script selftest fixtures and all 27 `cells-*` cases (`corpus/claim-ledger.sh:1061-1094` generator, `:1361-1394` cases);
- round-22 falsification cells evidence: `.ufo/waves/round-22/falsify/RunCellsMalformed.md` (14 + 3 H1 cases), `RunCellsBlocked.md` (2 cases), `RunCellsVacuous.md` (4 cases);
- the round's own contract text: `corpus/lessons/round-23.md:121-130`, `:149-158`; `LOG.md:1203`; `SCORECARD.md:841`.

Observed fixture identity (measured, not inferred):

| File | Bytes | Lines | SHA-256 |
|---|---:|---:|---|
| `corpus/fixtures/cells-hermetic/SCORECARD.md` | 327 | 12 | `04b915601d019540bb54a895dc381702b1d743d6955f321e9f2923287cc2640e` |
| `corpus/fixtures/cells-hermetic/claims.tsv` | 232 | 2 | `1674d112af479ffdaa14368a8a1102a3ea62057f36534e98e5817831872e3ac4` |
| `corpus/fixtures/cells-hermetic/stamps.tsv` | 178 | 2 | `b521142b712e6329e7c14423ab14492e826e36875c0986210ff72716ee824121` |
| `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv` | 307 | 9 | `c17f7e17ff89f25518a3277331122b433d600b0eac7c1a6a74dacf5fea133843` |
| `corpus/fixtures/cells-hermetic/corpus/fx-ok.sh` | 38 | 2 | `29f98fbaaa2412f5544523eaa7af24c62d5f119c75f88af7ef12b757ec4da614` |

`find corpus/fixtures/cells-hermetic -type f | wc -l` → `5`. The fixture's own two stamp rows reproduce exactly (`sha256sum`, `wc -l/-c` match `stamps.tsv:1-2`). Cells: `SCORECARD.md:7-12`, all six pointing at `R90-01`/`R90-02`, freshness also naming `corpus/adjacency.tsv`. Claims: `claims.tsv:1-2`.

## Executions (all host-free; cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin` unless noted)

1. Exact R23-01 argv from `corpus/claim-ledger.tsv:59`:

```
bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims corpus/fixtures/cells-hermetic/claims.tsv --stamps corpus/fixtures/cells-hermetic/stamps.tsv --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md --docs corpus/fixtures/cells-hermetic/SCORECARD.md
```

Exit **0**, stdout exactly:
`CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`
The pinned line reproduces byte-for-byte.

2. Hermeticity probe, same argv under an emptied environment:

```
env -i PATH=/usr/bin:/bin HOME=/nonexistent-kagi-r23 TMPDIR=/tmp LC_ALL=C bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic ...
```

Exit **0**, identical CLEAN line. No `$HOME` dependence observed.

3. Foreign-cwd probe: `cd /tmp && bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic ...` → exit **2**, stderr `claim-ledger: root is not a dir: corpus/fixtures/cells-hermetic`. The row is cwd-relative.

4. Mutation battery on seven copies under `/tmp/kagi-r23-conncells-6NqAhX/` (copy of the committed fixture; no lane file touched). Each row below is `bash corpus/claim-ledger.sh cells --root <copy> --claims <copy>/claims.tsv --stamps <copy>/stamps.tsv --scorecard <copy>/SCORECARD.md --docs <copy>/SCORECARD.md`:

| Copy / mutation | Exit | Observed decision |
|---|---:|---|
| `m_uncited` — coverage cell replaced by prose | **1** | `UNCITED SCORECARD.md:8 coverage` + `BROKEN … uncited=1 row_pointed=5` |
| `m_badid` — `R90-02` → `R90-99` | **1** | 4× `MISSING-ID SCORECARD.md` + `BROKEN … missing_ids=4 uncited=2 row_pointed=3 orphans=1` |
| `m_rowfail` — `fx-ok.sh` prints `FX: NOPE` | **1** | `FAIL R90-01 reason=verdict-not-final exit=0` + `BROKEN … row_failures=1` |
| `m_stampstale` — adjacency header changed, count 8 preserved | **1** | `STALE-POINTER corpus/adjacency.tsv sha=c17f7e17ff89->d91ad48924be lines=9->9 bytes=307->315` + `BROKEN … stale_pointers=1` |
| `m_mutrow` — one declaration deleted (count 7) | **1** | `FAIL R90-02 reason=verdict-not-final` + `BROKEN … row_failures=1 stale_pointers=1` |
| `m_deadstamp` — `fx-ok.sh` rewritten, still prints `FX: OK` (sha `6201f0117679…`, pinned `29f98fba…`) | **0** | `CELL_AUDIT: CLEAN … stale_pointers=0` — **uncited stamp never compared** |
| `m_fakestamp` — `fx-ok.sh` stamp replaced with `deadbeefdeadbeef\t0\t0` | **0** | `CELL_AUDIT: CLEAN … stale_pointers=0` — fabricated stamp row survives |
| `m_emptystamps` — stamps emptied to 0 bytes | **2** | `claim-ledger: no stamp rows in … (refusing to report coverage with an empty stamp set)` |
| `m_score` — depth and adjacency scores 7 → 9 | **0** | identical CLEAN line; score values are not audited |
| `m_dollar` — all 8 `$HOME` → `xHOME`, inner stamp recomputed | **0** | identical CLEAN line; count row does not pin the literal token |
| `m_selfskip` — `R90-01` replaced by `bash corpus/claim-ledger.sh --selftest` | **0** | `SKIP-SELF R90-01` + `CLEAN … rows_run=1 … self_skipped=1` (line differs from the pin, so R23-01 would fail) |

5. Id-audit isolation, to test whether the fixture's id vocabulary leaks into the real doc set. Scratch scorecard (six axes, all citing the real `R23-01`), real `corpus/claim-ledger.tsv` + `corpus/stamps.tsv`, `--docs "<scratch>/SCORECARD.md <repo doc>"`:

- with `corpus/lessons/round-23.md`: exit **1**, `MISSING-ID corpus/lessons/round-23.md:152 R90-01`, `CELL_AUDIT: BROKEN (cells=6 … missing_ids=1 … rows_run=0 … self_skipped=1 …)`.
- with `corpus/lessons/round-22.md` as the control: exit **0**, `CELL_AUDIT: CLEAN … missing_ids=0`.
- with the full default doc set (`AGENTS.md LOG.md PROVINCE.md SCORECARD.md SHONEN.md SKILL.md corpus/README.md corpus/knowledge/*.md corpus/lessons/*.md`): 17 `LABELED-ID` lines and exactly one unlabeled missing id — `corpus/lessons/round-23.md:152 R90-01`; exit **1**, `missing_ids=1`. No production claim row ran (the only cited row, `R23-01`, is `SKIP-SELF` at `claim-ledger.sh:817`).

6. Repo state and delta probes:
- `git status --porcelain -- corpus/fixtures/cells-hermetic corpus/claim-ledger.sh` → ` M corpus/claim-ledger.sh` / `?? corpus/fixtures/cells-hermetic/` (exit 0). The fixture is **untracked** at measurement.
- `git diff --stat d218603b74099ddca0bd8f869516fc41db0979bf -- corpus/claim-ledger.sh` → `1 file changed, 3 insertions(+), 3 deletions(-)`; both hunks are the `closure-dispositions.py` comment/allowlist (`PYTHON_SCRIPT_RE`). No `cells`-region line changed; no new `cells-*` selftest case.
- `grep -c "tcase cells-" corpus/claim-ledger.sh` → `27`.
- `grep -n "fixtures" corpus/stamps.tsv` → no match (exit 1); production stamps has 70 rows, none covering any of the 5 fixture files.

## Findings

### F1 — DEFECT (calibration, freshness): the round's own C3 fixture contract is false and, as written, unreachable

`corpus/lessons/round-23.md:151-153` states the fixture "holds a four-file fixture: a six-axis scorecard whose cells cite `R90-01`, a claims file whose one row runs a local script, an empty-but-valid stamps file, and `corpus/fx-ok.sh`."

Measured artifact: **five** files, **two** claim rows (`R90-01` script, `R90-02` count), and a **two-row** stamps file (`corpus/fx-ok.sh` plus `corpus/adjacency.tsv`). `LOG.md:1203` repeats "`corpus/fixtures/cells-hermetic/` (4 files)". The pinned CLEAN line at `corpus/claim-ledger.tsv:59` requires `stamp_pointed=1`, which is impossible with the contract's "empty-but-valid stamps file", and an empty stamps file is not "valid" at all: `corpus/claim-ledger.sh:321` refuses it with exit **2** (`m_emptystamps`, run 4). The contract therefore describes an input the gate rejects and cannot produce the line the row asserts. The artifact is authoritative; the lesson/LOG prose is falsified as a description of what was measured. This is a calibration/provenance defect in the round's own closure narrative, not in the fixture bytes.

### F2 — DEFECT (operability; cross-gate): the fixture's id namespace breaks the default-document id audit that `verify` and `cells` both run

`corpus/lessons/round-23.md:152` cites the fixture-only id `R90-01` with no labeling keyword. `R90-01` is not a production claim row. The default doc set includes `corpus/lessons/*.md` (`corpus/claim-ledger.sh:526`); `verify` calls `idref_audit` at `:972` and `cells` calls it at `:998`. Run 5 measures the consequence: the id audit emits

`MISSING-ID corpus/lessons/round-23.md:152 R90-01`

and `missing_ids=1`, exit 1, for **both** gates. The round-22 lesson control yields `missing_ids=0`, and over the full default doc set this is the **only** unlabeled missing id (17 labeled occurrences, all fabricated ids correctly marked per `ID_MARK_RE`, `:641`). Round 23 thus converts a previously clean id audit into a red one.

The fixture's CLEAN line hides this because R23-01 passes `--docs` = the fixture `SCORECARD.md` only (`corpus/claim-ledger.tsv:59`), excluding the lesson. That is the sharpest coverage the fixture wrongly implies: `CELL_AUDIT: CLEAN` here is **not** a statement that the same gate is clean on the tree; the C3 operability evidence is produced by a command whose doc set is selected to omit the one document that fails the audit. D9's "the real-tree claim is not made" (`round-23.md:121-130`) does not disclose that the round's own documentation makes the id audit red.

### F3 — DEFECT/BOUND (freshness): one of the fixture's two stamp rows is inert

`cells_evidence` compares only paths cited by a cell (`corpus/claim-ledger.sh:830`, loop over `CEL_PATHS`). No cell cites `corpus/fx-ok.sh`; only `corpus/adjacency.tsv` is cited (`SCORECARD.md:10`). Consequently:

- rewriting `fx-ok.sh` to a different digest while preserving `FX: OK` (`m_deadstamp`) leaves `CELL_AUDIT: CLEAN … stale_pointers=0`, exit 0;
- replacing its stamp row with `deadbeefdeadbeef\t0\t0` (`m_fakestamp`) also leaves exit 0 CLEAN.

So `stamp_pointed=1` counts *cells with a stamp*, not *stamps verified*, and `stale_pointers=0` covers 1 of the fixture's 2 pins. A reader of the fixture will reasonably believe both pinned files are re-checked; only one is. Half the fixture's pinning apparatus cannot fail.

### F4 — BOUND (calibration): what the pinned counters do not mean

- `row_pointed=6` is 6 cells resting on **2** distinct rows (`rows_run=2`), not six independent measurements; `cells_evidence` runs each cited row once.
- Scores are not audited: changing two axes from 7 to 9 (`m_score`) leaves the exact CLEAN line unchanged. The six `7`s in the fixture are decorative.
- `R90-02` mirrors `R17-03`'s regex `^# no-enumerate[[:space:]]+.HOME/`. The `.` matches any character: with all eight `$HOME` tokens replaced by `xHOME` and the inner stamp recomputed (`m_dollar`), the row still counts 8 and the audit is CLEAN. The count row does not pin the literal non-enumeration tokens, only "8 lines matching any-char+`HOME/`".
- `corpus/claim-ledger.tsv:59` says the run is over "committed fixtures", but `git status --porcelain` reports `?? corpus/fixtures/cells-hermetic/` and no fixture path appears in `corpus/stamps.tsv` (70 rows). The fixture's bytes are unpinned: `m_deadstamp` and `m_score` are precisely content drifts that leave R23-01 green. Only its behavior counters are asserted; its identity is not.

## Duplicate or meaningful extension?

**Mostly duplicate; two genuine, narrow extensions.**

- The fixture scorecard is the selftest `six()` table (`claim-ledger.sh:1061-1070`): same `| Axis | Score | Evidence |` header, same six axes, same score `7`, same pointer shape — with `## Round 1 — pre-move` renamed `## Round 90 — pre-move` and a title H1 added. Its pointer topology (all six cells row-pointed; one cell also stamp-pointed) is the `sc-stale-pointer` topology (`:1110`, `:1378`), with the digest corrected. Against `cells-clean` (`:1361`) the positive line differs only by `row_pointed` 5→6 and `rows_run` 1→2.
- No new parser branch is covered: one section only — no second pre/post section, no blocked heading, no malformed heading, no retired table, no numeric-anchor edge, no policy case. All 27 `cells-*` selftest cases and the 23 round-22 executed attack cases already cover those; the round-23 diff to `claim-ledger.sh` is 3+/3- in the python3 allowlist and adds zero `cells-*` cases.
- Genuine extension (i): the gate is now reader-runnable from the tree, without regenerating selftest heredocs — the D9 operability point.
- Genuine extension (ii): `rows_run=2` exercises two distinct command shapes, including the last-line count rule over a data file, which is the R17-03 obligation named in `.ufo/waves/round-23/parent-build/ClaimR17X03.md:180-186`. This is mechanical only: the count runs over a 9-line synthetic file yielding 8 matches, versus the 83-line production `corpus/adjacency.tsv` also yielding 8. No production content is re-measured, and the fixture would pass unchanged if production adjacency lost a declaration.

**Coverage wrongly implied** (summary): that the fixture is the four-file/one-row/empty-stamps artifact the lesson describes (F1); that `stamp_pointed=1`/`stale_pointers=0` validate both fixture pins (F3); that six row-pointed cells are six independent checks or that their scores are audited (F4); that the fixture is committed/pinned (F4); and that its CLEAN line says anything about the gate on the real doc set (F2).

## Confirmations (things that held under attack)

- R23-01's exact expected line reproduces exactly, exit 0.
- Hermeticity holds: emptied environment with `HOME=/nonexistent` gives the identical line, exit 0.
- The three mutations the lesson's C3 paragraph names (`round-23.md:157-158`) all fail closed, as does a stale cited stamp and a count mutation (run 4): `uncited`, `bad row id`, `failing row` → exit 1, with the exact `BROKEN` lines above.
- The `SKIP-SELF` guard is pinned by the exact line: substituting a self-invoking row yields `rows_run=1 self_skipped=1`, which cannot match R23-01's `rows_run=2 self_skipped=0`. M23-3's bound is genuinely closed *for this fixture*.
- The fixture's inner stamp values match the files (digests, line and byte counts).

## Risks / second-order effects

1. F2 makes both `verify` and `cells` report `unresolved_ids/missing_ids=1` on the real tree. Any round-23 statement of a clean whole-tree gate is false until `round-23.md:152` is labeled or the id is removed/registered. The defect is caused by the round's documentation of the fixture, not by the fixture bytes, so it will survive a fixture rewrite.
2. F3 means a later edit to `fx-ok.sh` (or a poisoned stamp for it) is invisible to R23-01 while the row stays green — an unverified pin that looks verified.
3. F4 means the fixture is untracked and unpinned; a reset/commit exclusion makes R23-01 exit 2 (`root is not a dir`), and score/value drift is behaviorally invisible.
4. The `R90-*` namespace is unregistered. A future allocation of R90 would silently resolve the lesson citation and could make the fixture's ids resolve against production rows, changing R23-01's meaning without touching it.
5. No production gate harm from the fixture *files* outside R23-01: the default doc set (`claim-ledger.sh:514-527`) does not include `corpus/fixtures/**`, and `revision-audit.py` reads `git ls-tree` of a history OID plus `corpus/stamps.tsv` paths (`revision-audit.py:241`), so untracked fixture files do not perturb R22-03. The harm is the id token in the lesson (F2).

## Bound the claim must state

1. `CELL_AUDIT: CLEAN` here covers 2 fixture rows and 1 cited stamp over a 5-file fixture; it is not evidence about the production scorecard, production `corpus/adjacency.tsv`, or the default document set.
2. `stale_pointers=0` covers only stamp paths cited by a cell (`claim-ledger.sh:830`); the `corpus/fx-ok.sh` pin is never compared. `stamp_pointed=1` counts cells, not verified stamps.
3. `cells` does not audit score values and R23-01 does not pin fixture bytes; the six `7`s and any content drift that preserves the counters are invisible.
4. R23-01 is cwd-relative and exits 2 outside the repo root; as measured the fixture is untracked, so "committed fixtures" is not yet true.
5. `R90-01` is a fixture-only, unregistered id. Until `corpus/lessons/round-23.md:152` is labeled with an existing marker (`fabricated|illustrative|example` or the `MARK_RE` set) or its id token is removed, the default-doc id audit reports `MISSING-ID …:152 R90-01` and both `verify` and `cells` exit 1.

## Proposed bounded correction (not applied)

- Mark or remove the `R90-01` token at `corpus/lessons/round-23.md:152` (e.g., "a fixture row" or "illustrative `R90-01`"); this alone restores `missing_ids=0` on the measured doc set. Cheapest fix with the largest effect. Verified in scratch: a copy of the lesson with line 152 changed to "cite the illustrative fixture row `R90-01`" and the same scratch scorecard yields `LABELED-ID round-23-marked.md:152 R90-01` + `CELL_AUDIT: CLEAN … missing_ids=0`, exit **0** (same argv shape as run 5, `--docs` = scratch scorecard + marked lesson copy).
- Either cite `corpus/fx-ok.sh` from one fixture cell (making its stamp live) or delete that stamp row; today it is an unverified pin that reads as verified.
- Correct `corpus/lessons/round-23.md:151-153` and `LOG.md:1203` to the measured 5-file / two-row / two-stamp fixture; drop "empty-but-valid stamps file", which `claim-ledger.sh:321` rejects with exit 2.
- If durable negative coverage is wanted, commit one failing fixture (one deleted adjacency declaration) behind its own row; today every failure case is ephemeral, produced only by an external mutation wave.

## Limits

No production `verify` (forbidden by the round contract), no host-bound row, no full `cells` over the real scorecard, no repo writes beyond this report, no network, no installs, no git/jj mutation. The id-audit isolation runs used a scratch scorecard and the real claims/stamps/docs read-only; the only cited row (`R23-01`) was `SKIP-SELF` and never executed. I did not adjudicate C1 or C2.

Report path: `.ufo/waves/round-23/falsify/ConnCellsPatterns.md`
