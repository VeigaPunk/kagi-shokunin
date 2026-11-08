# R68ExecCounterC1 — C1_VERIFIED counter

Seat: R68ExecCounterC1 (executor, counter C1). Lane `kagi-shokunin`, branch master. Sole writer of `plans/round-68-c1.sh`; no other file touched. Frozen predicate `plans/round-68.md` §C1 enforced as written; no predicate, counter, kill rule, population or target amended.

## Deliverable

`plans/round-68-c1.sh` (1070 lines, sha256 `60e3f680a226d5143ee1fcc62b229c5695f76d562f8445b8b382300354b84c59`). Bash wrapper (modes `--tree DIR` default lane, `--base-tree DIR`, `--scratch DIR`, `--selftest`) drives an embedded `python3 -I -B` derivation. Final verdict line, exactly one:

```
C1_VERIFIED: verified=<n> col15=<n> caught=<k>/6 guard=<0|1>
```

Exit 0 iff `guard=1`, `caught=6/6` and the candidate derivation has zero defect rows; else 1; SETUP exits 2 printing one `C1_VERIFIED: SETUP <reason>` line and no counts (verified: `--tree /nonexistent` → `C1_VERIFIED: SETUP bad-tree /nonexistent` rc 2; `--bogus` → `C1_VERIFIED: SETUP unknown-arg --bogus` rc 2).

## How every number is derived (nothing hard-coded)

- **verified**: rows of `corpus/source-fetches.tsv` (file order, non-comment, NF==16) whose col 16 *is* exactly one whitespace-delimited `.ufo/waves/` token (equality + path-shape `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`, so a trailing space, a comma-joined duplicate, or mixed prose is not pure) and whose token resolves to an in-tree regular file with raw sha256 == col 10, size == col 11, and col-13 quote locating count>=1 under col 14 (`rendered-text-v1` via the trusted normalizer, `raw-literal-v1` by literal bytes).
- **col15**: of the verified rows with col 14 `rendered-text-v1`, those whose recomputed `normalized_sha256` equals col 15.
- **caught**: six mutated copies of the measured tree (hardlink clones carrying `corpus/` plus every token-named capture; mutated files unlinked first), M1 trailing space → `capture-whitespace`, M2 comma-joined duplicate → `capture-whitespace`, M3 whole-TSV CRLF → file-level `SC_FETCH cr-in-tsv`, M4 one hex digit of col 10 → `capture-digest-mismatch`, M5 another hex64 in col 15 → `normalized-digest-mismatch`, M6 one byte appended to the anchor body → `capture-bytes-mismatch`. Anchor = the LAST row in file order, derived never named, that names a `.ufo/waves/` token whose first token binds on the unmodified tree (raw sha + size + quote locate) and carries a rendered hex64 col 15 (so M5 applies); no anchor is SETUP. A leg counts only when the candidate gate's own stdout exits 1 with `SOURCES_CENSUS: FAILED` and the expected finding line for the anchor id (M3: the `cr-in-tsv` fetch line). The counter never classifies a mutated copy itself.
- **guard** a–e exactly as frozen: (a) unmodified tree prints CLEAN `SOURCES_CAPTURES:` immediately before a CLEAN verdict with the four counts (`path_rows bound located prose`) equal to the counter's derivation (pure count / pure binding / pure locating / no-`.ufo/waves/`-token count); (b) `bash <tree>/corpus/sources-census.sh --selftest` rc 0 with `PASS (N cases)`, N>=89; (c) the BASE gate (`--base-tree`'s `corpus/sources-census.sh`, else `git show` of `d3b2a4e8…`) on the M3 CRLF copy prints `SOURCES_CENSUS: CLEAN`; (d) the fleet wrapper exits 0 with `kagi ok` naming the measured tree's `corpus/SOURCES.md` — only when the tree IS the lane (copies record `venue=skip` and do not fail, the wrapper validates the fleet lane, never a copy); (e) no-token (prose) rows produce no `SC_CAPTURE` finding on the unmodified tree. The trusted normalizer is the BASE tree's `rendered-text-v1.py` else this lane's, never the measured tree's copy alone. Scratch defaults to `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68ExecCounterC1` and refuses to sit inside the tree; no hardcoded `/tmp` in the script (one comment line mentions it).

## Measured results (exact lines, receipts in `R68ExecCounterC1/`)

- Counter selftest (`--selftest`, fixture trees under scratch only): `C1_VERIFIED_SELFTEST: PASS (56 cases)` rc 0 (`selftest.txt`). Negative vector per leg plus stub-gate refusal: constant-CLEAN gate replays to caught 0/6, its fixed counts disagree with the derivation on the CRLF copy, and the constant-FAILED gate reaches 6/6 but its clean run is not CLEAN (guard-a refuses it).
- BASE run (`--tree <fresh git archive of d3b2a4e8eed710277951e430efd3d27b5983033c> --base-tree <same>`, `base-run.txt`, rc 1 as expected for a miss): `C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0`. All six legs read CLEAN under the BASE gate (anchor `S166`, mixed token the old gate never reads), guards a=0 (gate prose 121 vs derived 120), b=1 (`PASS (89 cases)`), c=1 (BASE gate on CRLF prints CLEAN), d=skip, e=0. Runtime ~40–50s.
- Candidate run on a scratch copy with the S166 recut applied (fresh BASE archive + widened `sources-census.sh` + `§1.2 Concept Overview; capture …` → `.ufo/waves/round-67/capture/S166.body`, `cand-run.txt`): `C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=0`. Guards a,c,d(skip),e pass; guard-b fails (see Risks). Runtime ~50–60s. With `--base-tree` the CRLF blindness witness (c) passes; without it the `git show` fallback gate file alone lacks a normalizer and reports SETUP — callers must pass `--base-tree` per the frozen predicate, as the L1 run does.
- Live-lane run (tree = lane root, `--base-tree` fresh archive, `lane-run.txt`): `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=0`, anchor `S167`. The live TSV now also carries the already-landed S167 frontier row (verified 38 = 36 BASE + S166 recut + S167), so the live number does not equal the frozen counter's controlled-candidate 37; that is the S167 row's contribution, not a miscount.

## Dead ends / tensions measured (reported, not papered over)

1. **Supplied BASE extraction is polluted**: `/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e/corpus/source-fetches.tsv` (sha256 `aa6fa318…`) differs from the committed blob `d3b2a4e:corpus/source-fetches.tsv` (sha256 `90dd4a2c…`) by one trailing space in S164 col16; running against it derives `verified=35 col15=30` with S164+S166 both token-shape defects. A fresh `git archive` of `d3b2a4e` (sha256 `90dd4a2c…`, S164 pure) gives the exact frozen BASE numbers above. This seat used its own fresh archive under scratch and deleted it after copying receipts; the L1 should regenerate or re-verify that extraction. The seat did not edit the L1 directory.
2. **Plan parenthetical anchor ids do not match the derived rule**: `plans/round-68.md` says the anchor is `S166` at the candidate, `S164` at BASE. The derived LAST-binding rule (seat spec, authoritative here) yields `S166` at the candidate and `S166` at BASE (mixed token that binds; the old gate never reads it — which is exactly what produces the expected BASE `caught=0/6`). Pure-last on BASE bytes would be `S156` (caught 2/6 with the old gate: M4/M6 are digest/bytes checks it already does), and `S164` matches neither rule (file order tail is S164, S155, S156, S166). The counter derives and prints the anchor id; the definition governs, the parenthetical is informative. No id is hard-coded.
3. **Gate selftest is red (guard-b blocker)**: at receipt time `bash corpus/sources-census.sh --selftest` prints `SOURCES_CENSUS_SELFTEST: FAIL (98 cases, 2 failed)` — `capture-symlink-escape` and `capture-whitespace-cr` (expect `SC_CAPTURE findings=1`, gate emits findings=1 but the case harness fails them; earlier in the wave it was 4 failed including `fetch-cr-in-tsv` and `capture-token-slashslash`). The counter correctly reports guard=0; the frozen claim's `guard=1` can only be measured once R68ExecGate's selftest is green. It is gate-side, not counter-side: the mutation legs, count cross-check (a), blindness witness (c), fleet wrapper (d) and prose check (e) all pass.

## Tooling

Read `/home/vgpnk/.omp/agent/RULES.md` (operator rule, 2026-10-19). No tool installed or upgraded; system `python3` 3.14.8 (`/usr/bin/python3`) + `bash` only, stdlib only. pacman paused, not run.

## Files changed

`plans/round-68-c1.sh` (new). Scratch `/fast/scratch/hyaku/kagi-r68/R68ExecCounterC1/` plus `/fast/scratch/hyaku/kagi-r68/selftest-scratch/` (fresh archive, controlled candidate, fixtures) deleted after receipts were copied to `.ufo/waves/round-68/w1/R68ExecCounterC1/` (`base-run.txt`, `cand-run.txt`, `lane-run.txt`, `selftest.txt`, `gate-selftest.txt`).

Report: .ufo/waves/round-68/w1/R68ExecCounterC1.md
Receipts: .ufo/waves/round-68/w1/R68ExecCounterC1/
