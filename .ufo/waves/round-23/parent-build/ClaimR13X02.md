# ClaimR13X02 — R13-02 semantic audit (read-only, advisory)

Seat: ClaimR13X02 (scout), round-23 parent-held build wave. Axes: calibration, freshness, operability. No judgment/admission authority.

## Observed revisions

- **Frozen population.** HEAD `d218603b74099ddca0bd8f869516fc41db0979bf`.
  - `corpus/claim-ledger.tsv` is sha256 `e6806968…1dce8305`, 17844 B, 58 lines. This equals `corpus/stamps.tsv:5` and `.ufo/waves/round-22/final-verification-inputs.json`.
  - R13-02 is at line 31. Its scoping comment is at line 30: "R13-02 counts R1x rows only … total is pinned by R21-04".
- **In-flight working copy (WT).** Uncommitted, observed 2026-10-21 00:53–00:56 -0300.
  - Ledger is sha256 `6fa0c24f…`, 19451 B, 60 lines.
  - **R13-02 is byte-unchanged.** The WT diff touches R13-01 and R21-01..04, and appends R23-01 and R23-02.
- **Row.** `grep -c '^R1' corpus/claim-ledger.tsv` · expect `^35$` · exit `0` · timeout `30` · no `[substrate]` tag.

## Verdict on the obligation

| facet | evidence | status |
|---|---|---|
| last line `^35$` | Static Python parse of HEAD and WT bytes: 35 lines start `R1`. All are `R1[0-9]-[0-9]{2}` rows with 5–6 fields. No non-comment line deviates from the `R<d>-<d>\t` shape. | supported |
| exit `0` | `grep -c` exits 0 iff there is at least one match. Zero matches print `0` and exit 1; a missing file exits 2. Both surface as `FAIL … exit-mismatch` (`claim-ledger.sh:426-442`). | supported |
| timeout `30` | Measured 0.002 s (`final-verification.json` `safe_rows[9]`). Same bound as the sibling count rows R11-10, R11-11, R12-03 and R13-01. | supported, generous |
| policy | First token `grep` passes the allowlist (`:160`). There is no metachar (`:163`), no backslash or empty quote pair, and no deny word in the quote-stripped text (`:167-192`). | runs, never POLICY |
| `[substrate]` | Untagged is correct: the row reads one committed file, and a deferral (`:416-417`) would hide a real failure. A mistaken tag would move R18-02 from `^11$` to 12, so the two rows cross-guard. | supported |
| SKIP-SELF | The predicate is `*claim-ledger.sh*` on the command text (`:816`). R13-02 names `claim-ledger.tsv`, so `cells` re-runs it, as the comment at `:811-815` intends. | supported but **unpinned** (see Primary risk) |
| hermetic | The row is intrinsically host-free and sits in the QM12 safe-row set (`.ufo/waves/round-22/safe-row-plan.json`). `--selftest` never reads the real ledger. The in-flight R23-01 fixture uses its own claims and ids (`R90-*`), so it neither runs nor substitutes R13-02. | supported |

**What flips the verdict:**
- adding or deleting any `^R1` line (34 or 36 → `verdict-not-final`);
- an empty R1x set (exit 1);
- a missing file (exit 2).

**What does not flip it:**
- R2x/R23 additions (by design — that is R21-04's job);
- a same-count R1x swap;
- in-place edits to an R1x command or expect.

**Other teeth for those gaps:**
- **idref.** A deleted id that is cited somewhere becomes `MISSING-ID`, unless every line citing it carries a marker word. A static scan finds all 43 ids cited and 0 orphans.
- **stamps pin.** `stamps.tsv:5` catches byte changes until it is re-pinned.
- **QM14 journals.**

## Historical vs current evidence

| boundary | R1x / all rows | R13-02 expect | semantics |
|---|---|---|---|
| `4391b3b` (round-13 pre-move base) | 11/11 | row absent | — |
| `4b8c018` (round-13 close) | 17/17 | `^17$` | "holds 17 rows … matches every row id" — the total |
| `2486643`/`587fda0`/`8a6ec16`/`bc1af88` | 18/23/29/32 | equal to count | total |
| `fecee87` (round 18) … `aea7a43` | 35/35 | `^35$` | total |
| `c41af82` (round 21) … `c2cab35` | 35/39 | `^35$` | **narrowed to the R1x subset**; R21-04 takes the total |
| `8ada17a` | 35/43 | `^35$` | ledger sha `87fed349…` |
| `4be5da3` = `254d632` = `d218603` | 35/43 | `^35$` | ledger sha `e6806968…` |

The note's history (29/32/+3) matches `8a6ec16`/`bc1af88`/`fecee87`. The round-21 note-only migration is preserved old/new in `.ufo/waves/round-22/round21-migrations.json`, and `corpus/lessons/round-22.md:67-68` records it.

**Receipt:** `final-verification.json` `safe_rows[9]` — exit 0, last line `35`, passed.
- Its `.h1` is `8ada17a5`, but the `8ada17a` ledger blob differs (`87fed349…`). The measured bytes are bound only by the inputs file (`e6806968…`, which equals HEAD). This is routed defect D6.
- R1x is 35 at both revisions, so D6 does not change this verdict.
- The receipt is stale once the round-23 ledger bytes land. The re-run must bind the measured commit.

## Primary risk (one): the SKIP-SELF reader exemption is untested, so `cells` can report false-clean

**Evidence.** Only the string test at `claim-ledger.sh:816` keeps R13-02 re-run inside `cells`.
- The 27 selftest `cells` cases use the fixture claims files created at `:1057`, `:1058` and `:1131`. Their commands are `grep -c EXPECTED corpus/ok.txt`, `grep -c EXPECTED corpus/absent.txt` and `bash corpus/claim-ledger.sh --selftest`.
- `cells-self-row-skip` (`:1374`) checks only the substring `SKIP-SELF R3-01`.
- The in-flight R23-01 fixture rows are `bash corpus/fx-ok.sh` and a `grep -cE` over the fixture's `adjacency.tsv`.
- None of these names the ledger file without `.sh`.

**Mutant M1.** Change the predicate from `*claim-ledger.sh*` to `*claim-ledger*` — the "stem" reading that the comment at `:814-815` rejects. By inspection, M1 survives the 121-case selftest and R23-01.

**Consumer effect at HEAD.** Scored cells cite two ledger readers: R13-02 (`SCORECARD.md:86`) and R18-02 (`SCORECARD.md:322`). Under M1 both would be SKIP-SELF.
- A static simulation of the cells pass (not a gate run) gives `rows_run` 36→34 and `self_skipped` 5→7.
- R13-03's expect accepts any `rows_run=`/`self_skipped=`, so `CELL_AUDIT: CLEAN` would still print while R13-02 is red (for example with 34 R1x rows).
- This is the in-flight M23-3 class (`corpus/lessons/round-23.md:143`), reached from the reader side.

**Minimal synthetic falsifier and fix.** This is a proposal; nothing was measured. It needs zero migration and fits the in-flight C3 work:
1. Add the fixture file `corpus/fixtures/cells-hermetic/corpus/claim-ledger.tsv` with two lines, `R1-01 fixture` and `R1-02 fixture`. It is data only and never passed as `--claims`.
2. Add the claims row `R90-03<TAB>grep -c '^R1' corpus/claim-ledger.tsv<TAB>^2$<TAB>0<TAB>10<TAB>reader control, byte-identical to R13-02's command; names the ledger data file, not the gate`.
3. Cite `R90-03` in one fixture cell.
4. Set R23-01's expect to `rows_run=3 … self_skipped=0`.

Expected outcome:
- On the unmutated gate, `cells` reports CLEAN with `rows_run=3`.
- Under M1, `rows_run=2 self_skipped=1`, and R23-01 fails with `verdict-not-final`.

Alternative: a selftest case pairing R3-01 with a reader row, asserting `rows_run=1 … self_skipped=1`. That moves the selftest to 122 cases, so R11-09 and R18-03 need a QM14 migration.

## Secondary observation (calibration, not a gate defect)

`SCORECARD.md:86` has been unchanged since `4b8c018`. It reads "(`symbols=19`, `claims=11`). Pointer: counts re-pinned by `R12-03` and `R13-02`."

- R13-02 was the total-claims pin when that pointer was written.
- Since `c41af82`, R13-02 pins only the closed R1x subset.
- The `claims=` total is verify's `C_N` (`:415`, `:982`): 43 at HEAD, 45 in the WT. It is pinned by R21-04, which no scored cell cites (static scan: 41 cited ids, R21-04 is not among them).
- A reader following this cell's pointer gets 35. `cells` scores the cell as row-pointed and green no matter what happens to R2x rows.
- This is the documented "POINTER, not relevance" bound (`claim-ledger.sh:63-64`), and R13-02's own note discloses the narrowing.

Fix: append a dated pointer erratum (append-only) naming R21-04 for `claims=`. No change to the expectation.

Not owned: R12-03 counts stamp rows, not `symbols=`. Whether the cell's numbers pair one-to-one with its pointers is for R12-03's owner.

## What C3 and C1 must retain for R13-02

- **Keep the row as it is.** `^35$`, untagged, and in the safe-row set. R23-01 and R23-02 do not match `^R1`, so R13-02 needs no migration; R21-04 43→45 carries the total, and the WT agrees.
- **C3 must not substitute for R13-02.**
  - Row commands run with `cd "$ROOT"` (`:426`), but the rows come from `--claims`, which defaults to `$SCRIPT_DIR` (`:105`).
  - So a production reader row executed under `--root` measures fixture bytes (false-clean) or a missing file (false-fail).
  - The in-flight R23-01 avoids this: it passes fixture-local claims, stamps, scorecard and docs, and uses non-colliding `R90-*` ids. Keep that, and add the reader control above.
- **C1 must keep count rows out of `fixed` evidence.**
  - In-flight `corpus/closure-dispositions.json` cites neither R13-02 nor R21-04. Keep it that way.
  - D9's pointer is the whole of `corpus/claim-ledger.tsv`. `resolve_pointer` (`corpus/closure-dispositions.py:104-121`) accepts the id token anywhere in the file.
  - In the WT, `D9` appears only in R23-01's note (line 59), so today it resolves through the right row.
  - But the HEAD ledger already contains an unrelated `D2` (R16-06 note, line 44, "reviewer D2"). A future `fixed` D2 disposition pointing at the ledger would resolve on round-16 text.
  - Synthetic falsifier: a source with `- D2 …`, and D2 marked `fixed` → `ledger.tsv`, where the only `D2` is in a historical note. It should FAIL; the current code returns CLEAN. That case is latent: D2 is currently `reported`.
  - Recommendation: row-scoped pointers (file plus row id), with the token checked on that row.

## In-flight WT observations (uncommitted, not owned)

- **Stale lesson text.** `corpus/lessons/round-23.md:151-153` (as of 00:56) says the fixture cites only R90-01, has one claims row, and uses an "empty-but-valid stamps file". The fixture actually has R90-01 and R90-02 with 2 stamp rows, and `claim-ledger.sh:320-321` refuses an empty stamp set with exit 2. Messaged to KagiR23.
- **Duplicated sentence.** The WT R13-01 note repeats one sentence. Messaged to KagiR23.
- **Corrected transient.** The WT SCORECARD operability cell read `rows_run=1` at 00:53:44. By 00:56:35 it read `rows_run=2`, which matches the fixture-derived count and R23-01's expect. The fixture stamps match statically on sha, lines and bytes.

## Bounds of R13-02

- **Regex, not the gate's parser.** The gate's row universe is every non-blank, non-`#` line (`:405`). A row whose id has leading whitespace is a gate row but uncounted. Any `R1…` id (`R1-xx`, `R100-xx`) would be counted. The two agree today; the horizon is round 100.
- **Cardinality only.** The row pins how many R1x rows exist, not which rows or what they contain. `^35$` is a closed-set pin, so any late R1x row needs a QM14 migration.

## Conformance and limits

- **Breach: I executed row commands.** Early on I ran the literal command text of R13-02 and R21-04 once each, as plain greps from the repo root (outputs 35 and 43). The working copy was HEAD-identical at the time. This breaches "do NOT execute that command".
  - It was read-only, touched no host or private surface, and is not used as a receipt.
  - The conclusions rest on static parsing, git blob reads and committed receipts.
  - The history table applied the same patterns to `git show` blob output.
- **One unlocked git status.** I ran `git status --porcelain` once without `--no-optional-locks`. `.git/index` has mtime 2026-10-20 21:12 -0300, which predates this session, so no index write occurred. Every other git read used `--no-optional-locks`.
- **Nothing else run.** No jj, gates, handlers, op, vault, network, installs or public sources (so no quotes).
- **Writes.** Only this report, plus one message to KagiR23.
