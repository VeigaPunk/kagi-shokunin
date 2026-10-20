# RunCellsVacuous — assigned `cells` fixture run

## Result

**PASS for the assigned behavior.** The copied integrated `claim-ledger.sh` rejected an empty scorecard and a scorecard with no scored sections (both exit 2). It also rejected a recognized but incomplete round section (exit 2), while accepting a matched six-axis pre/post control with all 12 rows pointed to a working local claim (exit 0). No production implementation was changed. This observes the calibration-cell gate only; it makes no freshness result or broader round-22 calibration claim.

## Read input and clone identity

The read set was frozen by `.ufo/waves/round-22/integration-manifest.json`, SHA-256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`. The manifest declares historical base `c2cab35bc92e57e39e5489bac3386db078345b3f`; the falsification card identifies the integrated landing as `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. I did not infer a revision from detached HEAD. The manifest's `corpus/claim-ledger.sh` input is 83,655 bytes / 1,371 lines with SHA-256 `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5`; both that source file and its private copy at `/tmp/kagi-r22-w2-CellsVacuous/corpus/claim-ledger.sh` had that exact digest.

## Immutable local fixture inputs

All fixtures are isolated under `/tmp/kagi-r22-w2-CellsVacuous/fixtures`; each case has its own `corpus/anchor.txt` containing exactly `FIXTURE\n` (1 line, 8 bytes, SHA-256 `2ec2acf8040dbe2ed520d24e2d45e08377277414a1222416bc393e5efa74270b`). Shared fixture files:

- `common/claim-ledger.tsv` (1 line, 68 bytes, SHA-256 `272b92effe862072d371c6ec361d542ee4aa5dc6d4aed00acec45854e2e5f8c3`): `R22-01<TAB>grep -c FIXTURE corpus/anchor.txt<TAB>^1$<TAB>0<TAB>5<TAB>fixture-only count`.
- `common/stamps.tsv` (1 line, 87 bytes, SHA-256 `4e2516959b988fba053af7c6616dc396b569c9951d150914bc68f33fb1dc5eef`): `corpus/anchor.txt<TAB>2ec2acf8040dbe2ed520d24e2d45e08377277414a1222416bc393e5efa74270b<TAB>1<TAB>8`.

Scorecards, each with its final newline except the zero-byte case:

| Case | Exact content | Bytes / lines | SHA-256 |
|---|---|---:|---|
| `empty/SCORECARD.md` | empty | 0 / 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `prose/SCORECARD.md` | `# Fixture with no score sections\n\nThis scorecard has only prose.\n` | 65 / 3 | `2fe7241b71c1648020b87a8436ef7d9aa1babd2b5cbcb90adc3bfcceca84389a` |
| `heading-only/SCORECARD.md` | `## Round 22 — pre-move\n\nNo score table is present.\n` | 53 / 3 | `96c498af8b4789fd96927bdfbb382abc24e7c7fb743f8aa630589847c4700f43` |
| `matched/SCORECARD.md` | Two `## Round 22 — pre-move` / `## Round 22 — post-move` tables, each containing the six rows `depth`, `coverage`, `operability`, `freshness`, `calibration`, `adjacency`, each score `7`, each evidence cell `` `R22-01` ``; exact file SHA-256 below. | 486 / 21 | `351f3361adb0a9df5cdd846125c88aef98de743b9196d36e2ad45df412596df3` |

The matched scorecard's full exact bytes were written to `/tmp/kagi-r22-w2-CellsVacuous/fixtures/matched/SCORECARD.md`. Its hash, and all other fixture file hashes above, were measured after execution. The row is fixture-only: the gate reruns `grep -c FIXTURE corpus/anchor.txt` inside the selected fixture root; no repository or host-private command was used.

## Exact executions

Working directory for each command: `/home/vgpnk/Projects/shokunin`. The following argv strings were executed as written (only the fixture case/root/scorecard differs):

```text
bash /tmp/kagi-r22-w2-CellsVacuous/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsVacuous/fixtures/empty --claims /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/claim-ledger.tsv --stamps /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsVacuous/fixtures/empty/SCORECARD.md --docs /tmp/kagi-r22-w2-CellsVacuous/fixtures/empty/SCORECARD.md
```

stderr: `claim-ledger: no scored cells found in /tmp/kagi-r22-w2-CellsVacuous/fixtures/empty/SCORECARD.md (refusing to report coverage over a scorecard with no round tables)`; exit **2**.

```text
bash /tmp/kagi-r22-w2-CellsVacuous/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsVacuous/fixtures/prose --claims /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/claim-ledger.tsv --stamps /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsVacuous/fixtures/prose/SCORECARD.md --docs /tmp/kagi-r22-w2-CellsVacuous/fixtures/prose/SCORECARD.md
```

stderr: `claim-ledger: no scored cells found in /tmp/kagi-r22-w2-CellsVacuous/fixtures/prose/SCORECARD.md (refusing to report coverage over a scorecard with no round tables)`; exit **2**.

```text
bash /tmp/kagi-r22-w2-CellsVacuous/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsVacuous/fixtures/heading-only --claims /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/claim-ledger.tsv --stamps /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsVacuous/fixtures/heading-only/SCORECARD.md --docs /tmp/kagi-r22-w2-CellsVacuous/fixtures/heading-only/SCORECARD.md
```

stderr: `claim-ledger: scorecard section '## Round 22 — pre-move' does not carry all six axes exactly once (found=0 missing=depth coverage operability freshness calibration adjacency)`; exit **2**.

```text
bash /tmp/kagi-r22-w2-CellsVacuous/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsVacuous/fixtures/matched --claims /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/claim-ledger.tsv --stamps /tmp/kagi-r22-w2-CellsVacuous/fixtures/common/stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsVacuous/fixtures/matched/SCORECARD.md --docs /tmp/kagi-r22-w2-CellsVacuous/fixtures/matched/SCORECARD.md
```

stdout: `CELL_AUDIT: CLEAN (cells=12 row_pointed=12 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`; exit **0**.

## Assessment, limits, handoff

The empty and prose-only cases hit the no-scored-cells setup refusal; the heading-only case independently shows the per-section six-axis completeness guard still refuses an incomplete round. The matched control proves both correctly shaped pre/post sections can pass when their evidence resolves and the claim rerun succeeds. No correction is indicated by these observations. The test intentionally supplies a nonempty valid stamp table for setup, but cites no stamp path (`stamp_pointed=0`), so it does not test revision freshness. It also does not run the live corpus gate, host-private checks, or the complete ledger selftest. No installation or external-source access occurred.

Report path: `.ufo/waves/round-22/falsify/RunCellsVacuous.md`
