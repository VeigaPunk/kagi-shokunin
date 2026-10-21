# RunCellsBlocked — round 22 falsification

Report path: `.ufo/waves/round-22/falsify/RunCellsBlocked.md`

## Axes and result

- **Calibration:** not adjudicated here; this is a scorecard-parser fixture, not a feature/source decision test.
- **Freshness:** the fixture confirms the blocked heading does not suppress validation of later scored sections. It does **not** establish that the production stamp set is fresh or resolve C2 revision accounting.

The assigned behavior passed in an isolated fixture. The exact blocked Round 20 interactive-attempt heading and its single uncited `depth` row were excluded; both complete scored sections were checked (`cells=12`, representing the 6 axes in Round 22 pre- and post-move). A negative control retained the blocked heading but omitted `adjacency` from a scored section; it failed closed with exit 2. No production implementation was changed.

## Frozen input identity

Read the integration manifest (`.ufo/waves/round-22/integration-manifest.json`, SHA-256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`) and verified these relevant working-tree files against its input digests:

| Input | SHA-256 |
|---|---|
| `corpus/claim-ledger.sh` | `2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5` |
| `SCORECARD.md` | `748790b416547fbbc66dcdc33907c7a2aa3fcb01badb1dd99965398a82bf132d` |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

These are observed file identities, not a claim inferred from a detached HEAD. The gate copy in `/tmp/kagi-r22-w2-CellsBlocked/corpus/claim-ledger.sh` had the same SHA-256 as the frozen source (`2dd83f8c4959ac7d66e0eaf127bb9f5e054070fa28c5e7789d4ccda99c27adb5`; 1,371 lines, 83,655 bytes).

## Fixture identity

The local fixture root was `/tmp/kagi-r22-w2-CellsBlocked/root`. Its complete inputs were:

| Fixture file | Lines | Bytes | SHA-256 |
|---|---:|---:|---|
| `corpus/claim-ledger.tsv` | 1 | 70 | `4b0b77a74630f159002d004960c2f339f13c3141c9a318e368deac3cd1a9f394` |
| `corpus/fixture.txt` | 1 | 11 | `18b69e27a965f158900f6773fbca25ef7783699f3d9e29711bc55c213c77ebc5` |
| `corpus/stamps.tsv` | 1 | 89 | `88ab6887f4b8f510a0a8ecc782c8fa7bcb0ff126a34c2f42a225bf22aa202520` |
| `SCORECARD-pass.md` | 27 | 642 | `ba7959aeeb6d06965b9b85ea130767cd5a7b040d7715e63e22b4c6c73fdf116e` |
| `SCORECARD-bad.md` | 15 | 377 | `4bfbfbe27f5998f190b6f381b97cefa34f7437ba1430a21c828b406d5984d788` |

Fixture content: `corpus/fixture.txt` is exactly `FIXTURE_OK\n`; the one claim row is `R1-01<TAB>grep -c FIXTURE_OK corpus/fixture.txt<TAB>^1$<TAB>0<TAB>5<TAB>fixture assertion<LF>`. The fixture stamp row pins that file as SHA-256 `18b69e27a965f158900f6773fbca25ef7783699f3d9e29711bc55c213c77ebc5`, 1 line, 11 bytes.

Both scorecards start with the exact blocked heading `## Round 20 — interactive attempt; blocked, not completed (2026-10-15)` and a single non-score depth row. `SCORECARD-pass.md` then has complete six-axis `## Round 22 — pre-move` and `## Round 22 — post-move` tables; `SCORECARD-bad.md` then has a Round 22 pre-move table containing the five axes depth, coverage, operability, freshness, and calibration only.

## Executions

Both invocations ran the copied script against only the isolated fixture root. The sole score-row command was `grep -c FIXTURE_OK corpus/fixture.txt`; no host-private gate, account, vault, service, loopback endpoint, launcher, or package tool was invoked.

1. **Blocked prose excluded; scored sections retained** — argv:

   ```text
   bash /tmp/kagi-r22-w2-CellsBlocked/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsBlocked/root --claims /tmp/kagi-r22-w2-CellsBlocked/root/corpus/claim-ledger.tsv --stamps /tmp/kagi-r22-w2-CellsBlocked/root/corpus/stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsBlocked/root/SCORECARD-pass.md --docs /tmp/kagi-r22-w2-CellsBlocked/root/SCORECARD-pass.md
   ```

   Exit: **0**. Exact stdout:

   ```text
   CELL_AUDIT: CLEAN (cells=12 row_pointed=12 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
   ```

2. **Scored-section completeness still enforced after blocked heading** — argv:

   ```text
   bash /tmp/kagi-r22-w2-CellsBlocked/corpus/claim-ledger.sh cells --root /tmp/kagi-r22-w2-CellsBlocked/root --claims /tmp/kagi-r22-w2-CellsBlocked/root/corpus/claim-ledger.tsv --stamps /tmp/kagi-r22-w2-CellsBlocked/root/corpus/stamps.tsv --scorecard /tmp/kagi-r22-w2-CellsBlocked/root/SCORECARD-bad.md --docs /tmp/kagi-r22-w2-CellsBlocked/root/SCORECARD-bad.md
   ```


   Exit: **2**. Exact stdout/stderr:

   ```text
   claim-ledger: scorecard section '## Round 22 — pre-move' does not carry all six axes exactly once (found=5 missing=adjacency)
   ```

## Limits and disposition

This establishes the requested parser behavior on a frozen gate copy and explicit local fixture only. It does not run the full repository `cells` audit, whose cited rows can invoke unrelated checks; it makes no claim about full-tree pass status, vendor facts, C1 calibration, or C2 production-stamp freshness. No blocker or correction was found for this scoped behavior. No install or system-state operation occurred.
