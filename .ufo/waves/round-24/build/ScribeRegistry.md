# ScribeRegistry — SKILL.md §Gate registry draft (round 24, D2)

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, BASE 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105.
Scope: draft rows for SKILL.md:692-699 only. SKILL.md, corpus/, scripts and plans were NOT edited.
Verification ran in scratch clone `/fast/scratch/kagi-r24/seats/ScribeRegistry` (checked out at BASE, plus the untracked `corpus/rendered-text-v1.py` copied in), with `HOME=/fast/scratch/kagi-r24/home.utd6`. Fetches went to `/fast/scratch/kagi-r24/seats/ScribeRegistry-fetch`. No host-private gate was run; no vault, account or credential access.
Tooling: none installed or upgraded. Used existing `curl`, `python3` 3.14.8, `bash`, `sha256sum`.

## Draft rows (format of SKILL.md:694-699)

| name | kind | entry command | verdict map | selftest | pinned values | write scope | owner |
|---|---|---|---|---|---|---|---|
| closure disposition review | gate | `python3 corpus/closure-dispositions.py` (default source `corpus/lessons/round-22-verifier-spotcheck.md`; the round-23 closure is NOT covered, see F1) | 0 CLEAN (`obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15`); 1 FAILED (missing, unknown or unresolved); 2 SETUP (unreadable, schema or source mismatch, digest mismatch, bad args) | `python3 corpus/closure-dispositions.py --selftest` prints `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)`, exit 0 | `corpus/closure-dispositions.json` sha256 67ac1a42427eca7bc38a0f6785385a3b8039f1e61de24a1716ab76c8bbc5ff60; source `corpus/lessons/round-22-verifier-spotcheck.md` sha256 65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7; code `corpus/closure-dispositions.py` sha256 8cfaa52fc2ef527600779fb38d01f6335473c754feeb4370ceada949fed7429c | read-only under `--root`; `--source` and `--dispositions` must be relative and non-escaping; pointers refuse escape and symlink targets; selftest writes only its own `tempfile.TemporaryDirectory` | kagi |
| rendered-text-v1 normalizer | gate (`digest`, `locate`) | `python3 corpus/rendered-text-v1.py digest FILE`; `python3 corpus/rendered-text-v1.py locate FILE QUOTE` | digest: 0 ok; 2 SETUP (unreadable, not strict UTF-8, usage). locate: 0 count>=1; 1 count=0; 2 SETUP (empty quote, not strict UTF-8). | `python3 corpus/rendered-text-v1.py --selftest` prints `RENDERED_TEXT_V1_SELFTEST: PASS (cases=16)`, exit 0; 1 FAIL; 2 SETUP | the 16-case `CASES` table literal in `corpus/rendered-text-v1.py`; normalizer sha256 0bf06adbde3cf6235553d819d6a748c186dc34c918124a221018c27b9e5e78e6 (NO stamps.tsv row yet); the 10 `normalized_sha256` values of S017-S026 in `corpus/source-fetches.tsv` (reproduced 10/10 today, F5) | reads one named file; strict UTF-8; no network, no writes | kagi |
| row identity reader | reader (UNVERIFIED kind) | `bash corpus/row-identity.sh <selector>` PROVISIONAL, see F2 | PROVISIONAL, from plans/round-24.md:55-57: `ROW_IDENTITY: <selector> count=N sha256=<64hex>`. Exit codes and any non-zero verdict are UNVERIFIED. | UNVERIFIED (no script, no selftest found) | UNVERIFIED. Round-24 ledger rows that pin count and digest are planned, not present. | UNVERIFIED | kagi |
| source registry/citation census | gate | `bash corpus/sources-census.sh` | 0 CLEAN; 1 FAILED; 2 SETUP. Observed CLEAN line today: `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`. The planned suffix `captures= inrow= inrow_only= inrow_nonreproducing=` is NOT emitted yet (UNVERIFIED until C2 lands). | `bash corpus/sources-census.sh --selftest` prints `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, exit 0 (observed) | `corpus/SOURCES.md` sha256 c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d (16 in-row `Fetch sha256:` pins); `corpus/source-fetches.tsv` sha256 6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d (10 declared rows S017-S026 today; planned 26 after C2); `corpus/inrow-pins.tsv` ABSENT, planned by C2 and not read by the census today; literal selftest expectations | read-only owned corpus; selftest isolated under mktemp; no network | kagi |

## Findings

F1 (closure gate scope — the row must say this). `closure-dispositions.py:60` sets `DEFAULT_SOURCE` to the round-22 lesson, and `closure-dispositions.json:3` pins that file. The round-23 closure, `corpus/lessons/round-23-verifier-spotcheck.md`, has its own `## Routed defects` with D1-D8 (lines 183-203), and no dispositions file covers it. Those D1-D8 obligations, which are the round-24 debt, are therefore not machine-checked. The row should state this scope and not imply the closure is gated. Recommend a round-23 dispositions file (or a parameterised source) before the C1-C3 closure.

F2 (row identity absent). `corpus/row-identity.sh` and `corpus/inrow-pins.tsv` do not exist in the lane working tree, in the scratch clone, or in any `.ufo/waves/round-24` tool. grep for `row-identity`, `ROW_IDENTITY` and `inrow-pins` finds only plans/round-24.md, build-spec.json and build-dispatch.json. Its row must stay PROVISIONAL until the script lands. Its verdict map, selftest and write scope cannot be read from the file.

F3 (census restates the normalizer). `corpus/sources-census.sh:72-73` (SC_FETCH header) restates rendered-text-v1 as "tags->single space, html.unescape, collapse whitespace, trim ends". Round 24 D6 requires one declaration with citation, not restatement. The census row should cite `corpus/rendered-text-v1.py`, and C2 should replace the restated text. `source-fetches.tsv:27-30` already says "collapse Unicode whitespace (Python \s)", which is the correct form.

F4 (normalizer bounds, undocumented in its docstring). Two consequences of the declared rules, verified by running `normalize_text` today:
- Comparison operators in prose are deleted: `"x < y and y > z"` normalizes to `"x z"`, because step 3 treats `<...>` as a tag.
- An unclosed `<script>` keeps its body as text: `"a<script>var x=1"` normalizes to `"a var x=1"`.
The row's bounds should state both. The docstring (lines 10-37) does not mention either.

F5 (freshness: normalizer reproduces round-23 digests today). Method: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>` for the 10 rows with a normalized digest (S017-S026), then `rendered-text-v1.py digest`. Result: normalized_sha256 matches 10/10. Raw sha256 matches 6/10; S020, S022, S023 and S024 differ, which is expected because all 10 are labelled `decoded-http-body-volatile-v1`. This was a same-day live fetch (2026-10-21), so it attests reproduction of today's bytes, not of the historical captures. The ASCII-only alternative (`[ \t\r\n\f\v]+`) fails on S022, S023 and S024 and matches on S017, which agrees with the lesson's rejected-row claim. `\s` equals `str.isspace()` over all 0x110000 code points (0 differences).

F6 (closure gate reproduces its ledger row). `python3 corpus/closure-dispositions.py` in scratch exits 0 with `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)`. This matches the R23-02 pattern at `corpus/claim-ledger.tsv:60`. Selftest exits 0 with 14 PASS (cases listed: clean, missing, duplicate, unknown, pointer-missing, pointer-id, pointer-anchor, bad-kind, note-short, pointer-escape, pointer-symlink, class-mismatch, source-drift, digest-mismatch). The `duplicate` and `bad-kind` cases exit 2 (SETUP), as the row's verdict map says.

F7 (stamps). `corpus/stamps.tsv:14-15` pins `closure-dispositions.json` and `.py` at the digests above; both match current bytes. `corpus/rendered-text-v1.py` has no stamps row (it is untracked in the lane), so its pin is UNVERIFIED until committed and stamped.

F8 (census verified). `bash corpus/sources-census.sh` exits 0 with the CLEAN line in the table; `--selftest` exits 0 with 59 PASS. Current census reads `source-fetches.tsv` (SC_FETCH, `sources-census.sh:244-257`) and does not read `inrow-pins.tsv`. Its header comment at lines 56-75 still carries F3's restatement.

## Not verified (explicit)
- row-identity.sh verdict map, exit codes, selftest and write scope: script absent (F2).
- inrow-pins.tsv contents and the census `captures= inrow= inrow_only= inrow_nonreproducing=` suffix: not landed, so not run.
- S001-S016 re-capture and the 6 non-reproducing in-row pins: C2 owner's item, not checked here.
- The lane working tree was not gated directly. All runs were in the scratch clone at BASE plus the copied untracked normalizer. The tree's modified `corpus/claim-ledger.sh` is not read by these three gates.
- Not run: `claim-ledger.sh verify` or `cells` (host-private), and any host-private gate.

## Draft SKILL.md text (for the integrator)
- Replace SKILL.md:692 header with a round-24 header, or append the three new rows and amend the census row in place. Keep the 8-column format.
- Put the F1 scope sentence in the closure row (it names the round-22 source).
- Put the F4 bounds in the normalizer row, not in prose.
- Keep the row-identity row PROVISIONAL until the script exists and a selftest is found. Do not write a verdict map for it yet.

## Hand-off checks for main agent (after all subagents land)
- `bash corpus/sources-census.sh` expected CLEAN; post-C2 suffix must be checked against the landed census.
- `python3 corpus/closure-dispositions.py --selftest` expected 14 cases.
- `python3 corpus/rendered-text-v1.py --selftest` expected 16 cases; then the 10 S017-S026 digests (F5 method, same profile).
- `bash corpus/row-identity.sh <selector>` only after it lands: check it exists and read its verdict map.
