# C1 probe — SKIP-SELF reader false positive

## Result

At BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`, `cells_evidence` falsely classifies a row that only reads `corpus/claim-ledger.sh` as self-invocation. The scratch fixture's `R90-03` row was printed as `SKIP-SELF`, not executed. This is consistent with the baseline substring condition at `corpus/claim-ledger.sh:811-820`, specifically `[[ ${TF[1]:-} == *claim-ledger.sh* ]]` at line 816; it does not check command tokens.

## Exact retained evidence

Scratch clone: `/fast/scratch/kagi-r24/seats/ProbeSkipSelf-2`, checked out at BASE with:

```sh
test ! -e /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2 && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2 && git -C /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105
```

Copied `corpus/fixtures/cells-hermetic/` to `/fast/scratch/kagi-r24/seats/ProbeSkipSelf-2/probe/`, then copied the BASE gate to `probe/corpus/claim-ledger.sh`. The added row is `probe/claims.tsv:3`:

```text
R90-03<TAB>grep -c cells_evidence corpus/claim-ledger.sh<TAB>^3$<TAB>0<TAB>10<TAB>reads gate source only; no invocation
```

It is cited in the fixture scorecard at `probe/SCORECARD.md:8`. The copied script contains three matching lines (`probe/corpus/claim-ledger.sh:814-815, 816, 817`); the row command run directly from the fixture root produced `3` and exit 0:

```sh
grep -c cells_evidence corpus/claim-ledger.sh
```

The assigned gate invocation was run from the scratch clone (exit 0):

```sh
bash corpus/claim-ledger.sh cells --root /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2/probe --claims /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2/probe/claims.tsv --stamps /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2/probe/stamps.tsv --scorecard /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2/probe/SCORECARD.md --docs /fast/scratch/kagi-r24/seats/ProbeSkipSelf-2/probe/SCORECARD.md
```

Observed output:

```text
SKIP-SELF R90-03 (row invokes this gate; not re-run from inside the cell audit)
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=1 orphans=0)
EXIT=0
```

The scorecard cites three distinct claim IDs, but only two rows were re-run (`rows_run=2`); the readable row was omitted and counted as one self-skip. The final summary format and counters are emitted at BASE `corpus/claim-ledger.sh:1011-1012`.

## Test proposal

The classification predicate should be invocation-only: first command token is exactly `bash`, and the second token, after supported quote/`./`/repeated-slash normalization, resolves to `corpus/claim-ledger.sh`. A mention in a `grep` operand must not qualify.

Add a reader regression tcase using a fixture-local `corpus/claim-ledger.sh` containing `cells_evidence`, with a claim row `R6-01<TAB>grep -c cells_evidence corpus/claim-ledger.sh<TAB>^1$<TAB>0<TAB>5<TAB>reader only`, and a six-axis scorecard citing `R6-01`. Assert the complete final summary with a tcase such as:

```sh
tcase_last cells-reader-not-self 0 'CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)' "$0" cells --root "$R" --claims "$R/claims-reader.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-reader.md" --docs "$R/sc-reader.md"
```

Keep the positive counterpart: `R3-01` executes `bash corpus/claim-ledger.sh --selftest` (BASE selftest setup at `corpus/claim-ledger.sh:1131`); existing tcase `cells-self-row-skip` at line 1374 asserts its `SKIP-SELF` output. This pair distinguishes a reader from an actual command whose first token is `bash` and second token is the gate path.

## Files, risks, blockers

Only this assigned report was written in the lane. All fixture changes and command experiments were confined to the scratch clone; no code, ledger, stamp, host-private gate, or package/tool installation was changed or run. No blocker. This is a BASE behavior probe, not evidence that a post-integration fix passes; the parent should run the proposed reader/invocation cases against the integrated gate.
