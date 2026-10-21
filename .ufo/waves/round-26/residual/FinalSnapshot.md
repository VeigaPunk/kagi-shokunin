# FinalSnapshot — replay wrapper pins, paired frozen/rearmed inputs

Seat: `KagiR26.FinalSnapshot` (critic). Candidate `d30c9892a7377b8b5a51817d1db8b81eaddcc397`,
BASE `1bf3eec48d3761580ffd375c88143232485ae814`. Lane-authored advice, not non-author closure.
No production edits, no index/jj writes, no build/test/lint/format, no wrapper or gate execution,
no tool installs. Every blob below was read with `git show d30c989:<path>`. The working tree for
`frozen/`, `rearmed/` and `tools/` has no diff against the candidate (`git diff --stat` was empty),
and `find` shows no untracked or `__pycache__` files in either snapshot.

## Verdict

The literal pin chain is intact and digest-consistent; no digest mismatch exists. I found no
counterexample that turns a tampered snapshot CLEAN through the documented tamper route of
editing a receipt plus its manifest. Three fixable defects and two tradeoffs remain. Each
concerns tamper *classification* or an unenforced duplicate authority, not a false CLEAN at the
candidate.

## Axes

- **A1 pin integrity:** the wrapper literal pins the manifest, which pins the inputs.
- **A2 tamper classification:** tampering gives exit 2 and `snapshot_tampered`, never exit 0 or 1.
- **A3 identity/provenance:** each snapshot's bytes equal its claimed BASE or candidate origin.
- **A4 single authority:** one authority per expected digest or outcome.
- **A5 label honesty:** current41 inclusion, historical38/28 exclusion, and the "current"/"historical" names.

## Observed (exercised source checks)

1. **Manifest pins match (A1).** `sha256sum` of `frozen/inputs.sha256` is `cbb420c5…0361` and
   `rearmed/inputs.sha256` is `2e476782…19f8`. These equal `tools/replay-current.sh:13` and `:10`.
2. **Every manifest line recomputes OK (A1).** That is 11/11 frozen lines and 10/10 rearmed lines,
   recomputed from candidate blobs. The only unpinned tree files per snapshot are `expected.json`
   and `inputs.sha256`.
3. **The `expected.json` `input_sha256` maps equal their manifests exactly** (frozen 11 entries,
   rearmed 10), checked by parsing both.
4. **Snapshot provenance (A3)**, observed by digest against production blobs:
   - **frozen:** `before/after SOURCES.md` and `source-fetches.tsv` equal BASE `corpus/*`
     (`de198f…`, `afa2dd…`). `before/release-clocks.tsv` equals the BASE table (`53264a…`).
     `release-clock.py` equals the BASE `corpus/release-clock.py` (`f1a823…`).
     `observe-1.json` equals `.ufo/waves/round-26/observe-1.json` (`9a1cef…`).
     `observe-round25.json` equals `.ufo/waves/round-25/observe-1.json` (`b74c8e…`, which is
     `HISTORICAL_SHA` at `final-measure.py:18`).
   - **frozen/after table** (`ee0faf…`) matches no production revision. Its diff from
     `frozen/before` is only the S027/S028 lines 24–25 (observed 3.15.0→3.15.1, not-fired→fired,
     note extended). That matches `corpus/lessons/round-26.md:67-68`.
   - **rearmed:** `SOURCES.md` (`600878…`), `source-fetches.tsv` (`a1415d…`),
     `after/release-clocks.tsv` (`99a9b4…`), `release-clock.py` (`ef1765…`) and `observe-2.json`
     (`13b854…`) are byte-identical to candidate `corpus/*`, `.ufo/waves/round-26/observe-2.json`,
     `CURRENT_SHA` (`final-measure.py:19`) and `DEFAULT_RECEIPT_SHA256` (rearmed
     `release-clock.py:28`). `rearmed/before/release-clocks.tsv` equals the BASE table.
     The rearmed before→after diff is S027/S028 lines 24–25 plus added S040/S041 lines 30–31.
   - **Evaluators:** frozen and rearmed `release-clock.py` differ only at lines 28, 450 and 1562
     (the default receipt). Replay always passes explicit `--receipt`/`--receipt-sha`
     (`replay-current.sh:27-28`), so both snapshots evaluate with identical logic.
5. **Registry labels (A5)**, parsed from `| S…` rows:
   - frozen before/after: 38 rows, 28 on-release, with S039–S041 absent.
   - rearmed before/after: 41 rows, 30 on-release, with S039–S041 present.

   This matches SKILL.md:808-809 ("historical28-record … excludes the successor rows"),
   `rearmed/expected.json:41` ("current41-row registry"), `corpus/lessons/round-26.md:72-73` and
   SCORECARD.md:1029 (registry 38→41). The "28" is the receipt/on-release count and the "38" is
   the registry row count. No doc conflates them; `git grep` finds no `historical38` or `38-row`
   label anywhere.
6. **Receipt identity**, on the fields `final-measure.py:103`:
   - round25 receipt vs `frozen/observe-1.json`: 28 vs 28 records, same ID set, changed IDs
     exactly `[S027, S028]`.
   - `rearmed/observe-2.json` adds only S040/S041 (30 records) and changes none of the 28 shared
     records.
7. **The replay reads only pinned bytes.** In `--root` mode the evaluator reads
   `corpus/SOURCES.md` (:59), `release-clocks.tsv` (:100), `source-fetches.tsv` (:135) and the
   receipt (:416). `load_normalizer` (:593-600) is reached only from the `--observe` path
   (:812-815), so the pinned `rendered-text-v1.py` is never executed by replay (harmless
   over-pinning). The round25 receipt copy is pinned in frozen but never selected by the wrapper.
8. **Receipt-plus-manifest tamper (A2), by code reading.** The wrapper hashes the receipt itself
   (`replay-current.sh:25-26`), which neutralises the evaluator's own `--receipt-sha` check
   (`release-clock.py:420-424`). The only receipt authority is therefore literal pin → manifest →
   receipt. Editing receipt plus manifest changes the manifest digest, which hits `:17-19` (exit 2).
   The `final-measure.py:127-136` controls are failure-capable: the appended `b" "` keeps the JSON
   valid, so without the pin the run would be CLEAN. Switching pins by deleting or planting
   `observe-2.json` also fails at `:17`, because each manifest's digest is the other branch's
   wrong pin.

## Counterexamples / defects

### D1 — Missing manifest is exit 1, not `snapshot_tampered`/exit 2 (A2, fixable)

`replay-current.sh:16` runs `actual_manifest=$(sha256sum -- "$frozen/inputs.sha256")` under
`set -euo pipefail` (`:3`). If the manifest is missing, errexit fires at `:16` before the
tamper branch.

Observed via a generic shell probe (not the wrapper):

- `bash -c 'set -euo pipefail; x=$(sha256sum -- /nonexistent-kagi-r26-probe/inputs.sha256); echo reached'`
  gives `sha256sum: …: No such file or directory`, exit 1, with `reached` never printed.
- `realpath -- /nonexistent-kagi-r26-probe` succeeds (exit 0), so a non-existent root also
  reaches `:16`.

[INFERENCE] A snapshot with its manifest deleted, or a mistyped frozen-root, therefore exits 1 with
empty stdout. That exit code collides with the gate's legitimate FAILED exit, and both `before`
legs expect exit 1 (`frozen/expected.json:17`, `rearmed/expected.json:17`).
`final-measure.py:59` also requires the summary text, so it would not false-pass. However, it
contradicts SKILL.md:810-812 and `corpus/lessons/round-26.md:80-83` ("snapshot_tampered/exit2"),
and an exit-only consumer of "before must fail" (README.md:209) would accept it.

**Smallest correction:** before `:16`, add
`[[ -f $frozen/inputs.sha256 ]] || { printf 'ROUND26_REPLAY: snapshot_tampered\n'; exit 2; }`,
or guard the substitution with `|| { …; exit 2; }`.

### D2 — "pins all evaluated inputs" excludes unlisted files on the import path (A1/A2, fixable or reword)

`sha256sum --check` verifies only the files listed in the manifest; added files are invisible to it.
The wrapper runs `python3 -B "$frozen/release-clock.py"` (`:27`), so `sys.path[0]` is the snapshot
directory.

Observed on the host: Python 3.14.8 with `sys.flags.safe_path` False. None of the evaluator's
imports except `os`/`stat` are preloaded at startup: `argparse`, `json`, `hashlib`, `re`,
`pathlib` and the others are all absent from `sys.modules` before the script runs.

[INFERENCE, not executed: no file was planted] An unpinned `rearmed/json.py` or `argparse.py` would
pass both checks at `:17` and `:21` and then run as part of the evaluator. `-B` stops bytecode
writes, not imports. This contradicts LOG.md:1461-1462 ("snapshots pin all evaluated inputs") and
SKILL.md:810-811 ("verifies every input before evaluation"). It requires a committed or diff-visible
addition, so this is a claim-precision defect, not a live exploit at the candidate.

**Smallest correction:** run `python3 -I -B …` (isolated mode, which implies safe-path and ignores
`PYTHON*` env vars). Optionally also assert that the snapshot's regular-file set equals the manifest
paths plus `{inputs.sha256, expected.json}`. Alternatively, narrow the doc wording to "every listed
input".

### D3 — `expected.json` is an unpinned oracle carrying unenforced duplicate digests (A4, fixable)

`final-measure.py:67-71` takes each leg's exit code, summary and finding strings from
`<profile>/expected.json`, which is outside the manifest and the wrapper pin. That file also carries
three fields that no code consumes:

- `input_sha256` (frozen `:4`, rearmed `:4`);
- `receipt_sha256` (rearmed `:16`);
- `historical_receipt_sha256` (frozen `:33`).

They currently agree with the manifests and constants (observed in items 3 and 4), but they are a
second, dead authority that can silently diverge. The finding-key schema is also skewed:
`finding_ids` (frozen `:19`) versus `findings` (rearmed `:20`), bridged by
`final-measure.py:71`'s fallback. A misspelled key would silently degrade to `[]`.

Finding checks are also contains-only (`final-measure.py:59`). [INFERENCE] Extra unexpected
findings in a `before` leg would not fail it, because the FAILED summary lacks a finding count.

**Smallest correction:** in `final-measure.py`, assert:

- `expected["input_sha256"]` equals the parsed `inputs.sha256`;
- `receipt_sha256` equals `CURRENT_SHA`, and `historical_receipt_sha256` equals `HISTORICAL_SHA`;
- the finding key is present.

Otherwise, delete the duplicate fields. Optionally pin each `expected.json` digest beside the
wrapper's manifest pins.

## Tradeoffs (not judge-reject; surface for L1)

### T1 — "current" is a frozen snapshot with no live identity check (A3)

The rearmed bytes equal candidate production today (item 4). However, nothing in
`final-measure.py` asserts that `rearmed/after/corpus/*`, `rearmed/release-clock.py` or
`rearmed/observe-2.json` equal the measured revision's production paths. The same holds for frozen
versus BASE. The `active-default` leg (`final-measure.py:73-74`) matches only the summary string.

[INFERENCE] A later production edit to `corpus/release-clocks.tsv` would leave
`replay-current.sh after` ("for the current profile", SKILL.md:804) CLEAN on stale bytes.

**Correction:** add byte-equality records against `git show <revision>:<path>` and against BASE
blobs. All of these hold at d30c989 per the observed digests.

### T2 — Superseded label and unexercised historical claim (A5)

- `frozen/expected.json:34` still says "Current profile is an explicitly selected frozen
  observation", and the pinned `frozen/after/corpus/release-clocks.tsv` lines 24–25 say "round26
  current profile". Both predate the rearm correction (`plans/round-26.md:19-29`), whereas active
  docs call `rearmed/` current and `frozen/` historical (`corpus/lessons/round-26.md:64-74`). The
  pinned table bytes must not be rewritten. Only the unpinned `expected.json:34` wording could be
  relabelled, and that is L1's call.
- SCORECARD.md:1026 says the "original round25 receipt/code/tables remain separately replayable".
  The wrapper never selects `frozen/observe-round25.json` (`replay-current.sh:14`), and
  `final-measure.py:94-97` checks that receipt's bytes only. [INFERENCE] A replay needs an
  undocumented explicit `--receipt frozen/observe-round25.json --receipt-sha b74c8e…`, because the
  frozen default path would resolve under `frozen/before/.ufo/…`, which is absent.

  **Correction:** either add one exercised historical leg, or reword to "preserved and pinned".

## Commands run (all read-only)

- `git show d30c989:.ufo/waves/round-26/{tools/replay-current.sh,tools/final-measure.py,frozen/*,rearmed/*,expectation-migrations.json}`
- Per-manifest recompute: `git show …/inputs.sha256 | while read h p; do git show "$C:…/$p" | sha256sum; done`
- `git show <BASE|C>:corpus/{SOURCES.md,release-clocks.tsv,rendered-text-v1.py,source-fetches.tsv,release-clock.py} | sha256sum`
- `diff` of frozen/rearmed before/after tables and the two evaluators
- Inline `python3 -B` parsers for the expected-vs-manifest equality, registry row and on-release
  counts, and receipt identity comparison
- `git grep` for labels and pins
- `python3 -B -c` for the `sys.modules` and `safe_path` probe
- The two generic `bash -c` errexit/realpath probes quoted in D1

No tests, wrapper runs, gate runs or tool installs.
