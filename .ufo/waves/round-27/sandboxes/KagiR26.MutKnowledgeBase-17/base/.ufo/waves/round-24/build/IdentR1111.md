# Round 24 C3 — R11-11 identity-swap probe

BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.

## Claimed membership

`corpus/claim-ledger.tsv:25` is `R11-11`, command `grep -cv '^#' corpus/surface-census.tsv`, expected `^35$`, exit 0. Its note is exactly: `surface-census.tsv declares 35 rows (20 asset / 15 runtime)`. The membership claimed is the set of all 35 non-comment declaration records (surface paths), partitioned into 20 `asset` and 15 `runtime` rows; `# scan` directives are not declaration rows. BASE census data confirms 35 / 20 / 15.

## Mutant and stamping

One mutant in `/fast/scratch/kagi-r24/seats/IdentR1111-2` only:

```diff
 corpus/surface-census.tsv
@@ after BASE line 20 (# scan\t$HOME/.local/state/tac)
+
@@ BASE line 34
-$HOME/.local/state/tac/handoff-status.json\tasset\tfile\t600\tcustody/provenance record
```

This deletes one declared asset path and adds one blank line. BASE `grep -cv '^#'` = 35; mutant `grep -cv '^#'` = 35, with 34 nonblank data records + 1 blank record (asset/runtime split among data is now 19/15). `surface-census.tsv` was stamped at BASE (`corpus/stamps.tsv:78`), so I re-stamped the full pinned set in the clone: `bash corpus/claim-ledger.sh stamp <all 79 paths from corpus/stamps.tsv>`; exit 0, `STAMPED: n=79`. Updated clone pin is `corpus/stamps.tsv:73` (sha `0b1f75e220810a37c4be0c812a7d841efcc5214b01fd3512384afb4fe7c19003`, 54 lines, 4669 bytes). Stamp drift therefore was not the probe signal.

## Row runs

Control was an unmodified BASE clone; mutant was the clone above. R11-01 used `HOME=/fast/scratch/kagi-r24/seats/IdentR1111-2-home`, a synthetic tree matching declared asset kinds/modes with synthetic JSON shape keys; runtime files were omitted (informational absence). R11-02/03 used an empty scratch HOME and `THE_JANITOR_BIN=/nonexistent` to prevent host-handler execution. No host rows were run. The literal TSV command is only R11-11; I also ran all ledger rows invoking `surface-census.sh` (R11-01–03), which sets `CENSUS` to the TSV at `corpus/surface-census.sh:76`.

| Row / command | BASE control: exit; last non-empty line | Mutant: exit; last non-empty line | Result |
|---|---|---|---|
| R11-01 `bash corpus/surface-census.sh` | 0; `SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=28 absent=23 skipped=0)` | 1; `SURFACE_CENSUS: DRIFT (diverged=0 gone=0 link=0 unlisted=1 crosscheck=0 shape=0 unverified=0 ok=27 absent=23 skipped=0)` | **KILLED** |
| R11-02 `bash corpus/surface-census.sh --verbs` | 2; `surface-census: handler not on PATH: /nonexistent` | 2; same line | **SURVIVES** — same safe-environment setup failure; not a TSV-membership oracle |
| R11-03 `bash corpus/surface-census.sh --selftest` | 0; `SELFTEST: PASS (16 cases)` | 0; same line | **SURVIVES** — selftest fixtures are independent of the committed census |
| R11-11 `grep -cv '^#' corpus/surface-census.tsv` | 0; `35` | 0; `35` | **SURVIVES** |

The R11-01 mutant run was after successful re-stamping. `load_census` skips blank lines (`surface-census.sh:155-160`); the retained synthetic handoff file is a child of the scanned tac directory, so deleting its declaration produces `SURFACE UNLISTED` (`:249-260`) and the verify summary exits 1 (`:854-868`). Thus the reader detects the changed membership while R11-11's count-only command accepts it.

## Identity selector recommendation

For this note, digest one `<path>\t<class>` pair per non-comment, nonblank data row, sorted bytewise under `LC_ALL=C` (order-insensitive; retain duplicates, do not `sort -u`), serialized as one pair plus LF per member, then SHA-256. Report/pin `count`, asset/runtime subtotals, and `blank` separately; exclude `#` comments/directives from membership and exclude blank lines from member bytes while requiring/pinning `blank=0`. That binds both path identity and the asserted 20/15 partition, while unchanged BASE reproduces one fixed digest.

Scratch recomputation with that canonical form: BASE `count=35 blank=0 sha256=117b3d17224c26bbf8a992d935e9acbd44aa76d48f4ec2c1509abf446e2e8d17`; mutant `count=34 blank=1 sha256=3aee9ef25091181ef087fb8757ac9b2134f489d0d7a9a1bae79965a2842795c9`. The inspected in-flight `corpus/row-identity.sh:62-65` instead hashes only first fields; its path-only digest also changes for this deletion (BASE `9d34b393b708c3e0537c040c82ae0483932ce7267004d1a5b2dbfc52ef0c8d27`, mutant `28a7cd30b7fde562b688a551ffee9df6eca0a08c0585f8e04a62d0d0b2b35589`), but path-only identity would miss a path-preserving asset/runtime tag swap. Including class is needed to bind the note's full claim.

## Scope note

I accidentally targeted the lane census once with a lane-relative edit path while intending the scratch clone; I restored the original file from BASE. Immediately afterward, `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff -- corpus/surface-census.tsv` returned no output. Parent was notified. No tools were installed or updated.