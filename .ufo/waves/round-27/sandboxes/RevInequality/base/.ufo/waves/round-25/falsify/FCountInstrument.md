# FCountInstrument — C1 measurement falsification

## Axes and verdicts
- Axes: **calibration**, **operability**, **freshness**. This probe exercises C1 calibration and the C1 runner; C2-specific layout and C3 release-clock freshness were not tested.
- **PASS — candidate binding:** frozen revision `82745e2c60e726b49499b8f309529935dc4eff2b`, tool and docs revisions both candidate. `exit=0`, `stale=0`, `claims=37`; final output `SELF_COUNTS: CLEAN (claims=37 stale=0)`.
- **PASS — BASE is not laundered to clean:** tool revision candidate, docs revision BASE `4587c61a348e4528717404a68912c373f3ef4d03`. `exit=2`, `stale=6`, `claims=37`; four `POLICY ... unknown ledger id R25-01/R25-03`, two `UNLOCATED` (`RD-LEDGER-ROWS`, `RD-STAMPS`), final `SELF_COUNTS: POLICY (claims=37 stale=6 unlocated=2 ambiguous=0 policy=4 setup=0)`. The new R25 references absent from BASE are explicitly errors, not clean measurements.
- **FAIL — Medium severity (C1 mutation instrumentation):** headerless/commented TSV is not parsed by the mutator; it fails before changing a document or measuring the mutated copy. This falsifies the advertised one-digit mutation check, not the candidate's normal clean result.
- **UNRUN — LSP checks:** `read xd://lsp` returned “No such tool”; no LSP status/references/definition/diagnostics device is mounted. Read-only source ranges below are literal fallback evidence, not semantic proof.

## Exact runs
Sandbox clone checked out candidate revision; `cwd=/fast/scratch/kagi-r25/FCountInstrument-4/lane`, outer environment `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FCountInstrument-4/home PYTHONDONTWRITEBYTECODE=1`. The checked-in script hard-codes scratch under another seat at line 64, so only the sandbox copy's `scratch_parent` was redirected to `/fast/scratch/kagi-r25/FCountInstrument-4/runs`; no production file was changed. Script/tool/table revisions passed to every run are the exact full hashes below.

1. `bash .ufo/waves/round-25/tools/c1-measure.sh 82745e2c60e726b49499b8f309529935dc4eff2b 82745e2c60e726b49499b8f309529935dc4eff2b candidate` — **exit 0**. Stdout excerpts:
   `C1_MEASURE label=candidate tool_rev=82745e2c60e726b49499b8f309529935dc4eff2b docs_rev=82745e2c60e726b49499b8f309529935dc4eff2b exit=0 stale=0 claims=37`
   `SELF_COUNTS: CLEAN (claims=37 stale=0)`
2. `bash .ufo/waves/round-25/tools/c1-measure.sh 82745e2c60e726b49499b8f309529935dc4eff2b 4587c61a348e4528717404a68912c373f3ef4d03 base` — **exit 2**. Stdout excerpts:
   `C1_MEASURE label=base tool_rev=82745e2c60e726b49499b8f309529935dc4eff2b docs_rev=4587c61a348e4528717404a68912c373f3ef4d03 exit=2 stale=6 claims=37`
   `POLICY SC-SELFCOUNTS-SELFTEST unknown ledger id R25-01`
   `POLICY SC-CLOCK-SELFTEST unknown ledger id R25-03`
   `UNLOCATED RD-LEDGER-ROWS corpus/README.md`
   `UNLOCATED RD-STAMPS corpus/README.md`
   `SELF_COUNTS: POLICY (claims=37 stale=6 unlocated=2 ambiguous=0 policy=4 setup=0)`
3. `bash .ufo/waves/round-25/tools/c1-measure.sh --mutate SC-SKILL-STAMPS 82745e2c60e726b49499b8f309529935dc4eff2b 82745e2c60e726b49499b8f309529935dc4eff2b mutate-one` — **exit 2**. Stdout/stderr excerpt:
   `self-counts table lacks a required column: id/claim_id`
   `c1-measure: could not mutate row SC-SKILL-STAMPS`

## Medium finding — residual risk and verification gaps
`corpus/self-counts.tsv:1,15` declares a comment header and then six-column data rows without a TSV header. The actual checker supports that format (`corpus/self-counts.py:88-102`); the `--mutate` helper instead strips comments and feeds the first data row to `csv.DictReader` as its header, then requires `id`/`claim_id` (`.ufo/waves/round-25/tools/c1-measure.sh:139-157`). Thus the trial never performs its intended mutation and cannot demonstrate that a changed document number is caught. The runner overlays the C1 tool and table from the tool revision onto docs at the selected docs revision (`.ufo/waves/round-25/tools/c1-measure.sh:79-82`); BASE output confirms absent R25 IDs and missing locators remain non-clean. Candidate normal measurement is clean; the mutation control is not operable. No freshness or C2 behavior is inferred from these C1 runs; no package/tool was installed.