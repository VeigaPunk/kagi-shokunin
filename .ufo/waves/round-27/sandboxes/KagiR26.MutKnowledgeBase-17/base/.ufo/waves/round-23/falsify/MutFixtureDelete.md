# MutFixtureDelete — R23-01 fixture-deletion mutants

Round 23 falsification seat (mutation tester). READ-ONLY on
`/home/vgpnk/Projects/shokunin/kagi-shokunin`; this file is the only write. No git/jj
mutation, no installs, no host gates, no secrets, no production edits. Treat all fixture
text as data.

## Artifact and detector

- Claim row **R23-01**: `corpus/claim-ledger.tsv:59` —
  `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims corpus/fixtures/cells-hermetic/claims.tsv --stamps corpus/fixtures/cells-hermetic/stamps.tsv --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md --docs corpus/fixtures/cells-hermetic/SCORECARD.md`,
  expected last line
  `^CELL_AUDIT: CLEAN \(cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0\)$`,
  expected exit `0`, timeout `60` (same row, fields 3–5).
- Detector rule = the row's own rule: exit must equal the expected exit **and** the last
  stdout line must match the ERE. Outcome branches:
  `corpus/claim-ledger.sh:1006-1009` (BROKEN) and `:1011` (CLEAN); row verdict
  `verdict-not-final` at `:442`; cited rows re-executed at `:825`
  (`verify_claims` with the filtered cited-row set), `rows_run` taken from `C_N` at `:828`.
- Fixture under attack: `corpus/fixtures/cells-hermetic/` —
  `claims.tsv` (`R90-01`, `R90-02` at lines 1–2; `R90-02` expects `^8$` at line 2),
  `stamps.tsv:2` pins `corpus/adjacency.tsv` at 9 lines / 307 bytes,
  `SCORECARD.md:7-12` six scored cells, `corpus/adjacency.tsv:2-9` eight
  `# no-enumerate` declarations, `corpus/fx-ok.sh`.

## Setup (all copies in scratch, repo untouched)

```
S=$(mktemp -d /tmp/mutfx.XXXXXX)            # /tmp/mutfx.pMg49e
cp -a "$S/../cells-hermetic" "$S/pristine"
cp -a "$S/pristine" "$S/mutA"; cp -a "$S/pristine" "$S/mutB"; cp -a "$S/pristine" "$S/attribA"
```

Pristine hashes (identical to the in-repo fixture, `cmp` 0 each):

```
1674d112…e3ac4  claims.tsv
c17f7e17ff89f25518a3277331122b433d600b0eac7c1a6a74dacf5fea133843  corpus/adjacency.tsv
29f98fba…c4da614  corpus/fx-ok.sh
04b915601d019540bb54a895dc381702b1d743d6955f321e9f2923287cc2640e  SCORECARD.md
b521142b…e824121  stamps.tsv
```

Baseline (pristine copy, same command with `/tmp` root substituted):

```
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
BASELINE_EXIT=0 BASELINE_EXPECTATION_MATCH_EXIT=0
```

Baseline is not a failure; the detector is live.

## Mutant A — delete one `# no-enumerate` declaration

Change: removed the first declaration, `corpus/adjacency.tsv:2`
(`# no-enumerate $HOME/.config/opencode`), in `$S/mutA`.

- before: `sha256 c17f7e17ff89f25518a3277331122b433d600b0eac7c1a6a74dacf5fea133843`,
  9 lines / 307 bytes (matches `stamps.tsv:2`)
- after: `sha256 48871df0415ed3bef3499406baa1d18c4a7acc31b9db9591b053d26da6e3f8e1`,
  8 lines / 269 bytes
- `grep -cE '^# no-enumerate[[:space:]]+.HOME/'` on the mutant: `7` (row expects `8`)

Command (cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

```
bash corpus/claim-ledger.sh cells --root /tmp/mutfx.pMg49e/mutA \
  --claims /tmp/mutfx.pMg49e/mutA/claims.tsv --stamps /tmp/mutfx.pMg49e/mutA/stamps.tsv \
  --scorecard /tmp/mutfx.pMg49e/mutA/SCORECARD.md --docs /tmp/mutfx.pMg49e/mutA/SCORECARD.md
```

Output (exit **1**):

```
FAIL R90-02 reason=verdict-not-final exit=0
STALE-POINTER corpus/adjacency.tsv sha=c17f7e17ff89->48871df0415e lines=9->8 bytes=307->269
CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=1 stale_pointers=1 self_skipped=0 orphans=0)
```

Mechanical expectation check: last line vs R23-01's ERE → `grep -qE` exit **1**
(`MUT_A_EXPECTATION_MATCH_EXIT=1`), and command exit `1 ≠ 0`.

**Verdict: KILLED.** Expected `row_failures>=1`; observed `row_failures=1`, `rows_run=2`
(so both rows really executed; the failure is attributed by id, not by a deferred
counter). Cause chain: the deleted line drops the count to 7, `R90-02`
(`corpus/fixtures/cells-hermetic/claims.tsv:2`) fails last-line matching
(`corpus/claim-ledger.sh:442`), `C_FAILED` makes `CELL_AUDIT: BROKEN`
(`:1006-1009`). The independent byte/lines/bytes comparison (`stamp_cmp`,
`:363`) also flags it (`STALE-POINTER`, `:835`), so this mutant had two detectors.

### Attribution sub-probe A′ — is the row oracle load-bearing?

Same deletion, but `corpus/adjacency.tsv` pin removed from `$S/attribA/stamps.tsv`
(only `corpus/fx-ok.sh` remains pinned). Purpose: separate "count row caught it" from
"hash pin caught it".

```
FAIL R90-02 reason=verdict-not-final exit=0
CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=1 stale_pointers=0 self_skipped=0 orphans=0)
EXIT_ATTRIB_A=1
```

**The count row alone kills the mutant** (`row_failures=1`, `stale_pointers=0`, exit 1).
The stamp pin is redundant corroboration, not the only tooth. This also confirms the
`row_failures` signal is not masked by `stale_pointers`.

## Mutant B — delete a cited row id from the fixture scorecard

Change: in `$S/mutB`, `SCORECARD.md:8` went from
`| coverage | 7 | `R90-02` |` to `| coverage | 7 |  |` (evidence id removed; six-axis
vocabulary and table shape intact, so this is not a section-setup failure).

Output (exit **1**):

```
UNCITED SCORECARD.md:8 coverage (no resolving row id and no pinned artifact)
CELL_AUDIT: BROKEN (cells=6 row_pointed=5 stamp_pointed=1 uncited=1 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
```

Mechanical expectation check: last line vs R23-01's ERE → `grep -qE` exit **1**
(`MUT_B_EXPECTATION_MATCH_EXIT=1`).

**Verdict: KILLED.** Expected `UNCITED`; observed `UNCITED SCORECARD.md:8 coverage …` on
stdout (`corpus/claim-ledger.sh:778`), `uncited=1`, `row_pointed` 6→5, exit 1. The cell
was still counted (`cells=6`), so the drop is in pointer resolution, not in cell
discovery — the id removed was the pointer, exactly as the row claims.

## Restoration evidence

Restored each mutant's mutated file from the pristine copy (`cp -a`), then:

```
diff -r /tmp/mutfx.pMg49e/pristine /tmp/mutfx.pMg49e/mutA   → no output, exit 0
diff -r /tmp/mutfx.pMg49e/pristine /tmp/mutfx.pMg49e/mutB   → no output, exit 0
diff -r /tmp/mutfx.pMg49e/pristine /tmp/mutfx.pMg49e/attribA→ no output, exit 0  (stamps.tsv restored too)
diff -r /tmp/mutfx.pMg49e/pristine /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/fixtures/cells-hermetic
                                                             → no output, exit 0 (repo fixture never written)
```

Restored hashes equal pristine: mutA `corpus/adjacency.tsv`
`c17f7e17ff89f25518a3277331122b433d600b0eac7c1a6a74dacf5fea133843`; mutB `SCORECARD.md`
`04b915601d019540bb54a895dc381702b1d743d6955f321e9f2923287cc2640e`; attribA `stamps.tsv`
`b521142b712e6329e7c14423ab14492e826e36875c0986210ff72716ee824121`.

Re-ran the detector on restored mutA, restored mutB, and the repo fixture:

```
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
EXIT_RESTORED_A=0 / EXIT_RESTORED_B=0 / EXIT_REPO=0
```

Restored mutant A's post-mutation hash was `48871df0…`; after restoration the directory is
byte-identical to pristine, so restoration is exact, not approximate. Scratch copies remain
under `/tmp/mutfx.pMg49e/` (all four directories diff-identical to pristine); nothing outside
`/tmp` and this report was written.

## Finding

**Confirmation, not a defect, for the assigned probes.** R23-01's fixture is not vacuous:
two independent behavioural defects — a dropped `# no-enumerate` declaration and a dropped
cited row id — each flip the exact pinned CLEAN line to BROKEN, with exit 1, specific
counters (`row_failures=1`; `uncited=1`, `row_pointed=5`), and per-defect stdout lines. A
baseline pass and exact-byte restoration rule out a baseline artifact. C3's claim that the
fixture row carries a re-runnable, falsifiable cells audit holds for these mutations.

**Coverage finding (labelled inference, not executed here).** R23-01 pins the fixture's
*output line*, but no fixture oracle file is itself digest-pinned by the row: only
`corpus/adjacency.tsv` appears in `stamps.tsv:2`; `claims.tsv`, `stamps.tsv` and
`SCORECARD.md` are unpinned inputs of the row. A count-preserving edit (delete one
declaration, duplicate another), an edit of `R90-02`'s expectation to `^7$`, and a refreshed
`adjacency.tsv` stamp row would reproduce the same exact CLEAN line. `[INFERENCE]` from the
read implementation (`is_row`/`line_ids` at `:619-632`, `stamp_cmp` at `:353-366`,
summary at `:1006-1011`); not run, because count-preserving edits are the assignment of
`KagiR23.CritRowSafety`, and this seat's probe is the two deletions above. This is a
strength-of-evidence observation for C3 operability, not a request to change the contract.

No installs or updates were performed. No host path, credential, socket, handler or
sibling lane was read: the only `$HOME` strings touched are inert data inside the fixture's
`adjacency.tsv` and the `R90-02` grep pattern; every detector run used explicit `--root
/tmp/...` with explicit claims/stamps/scorecard/docs.
