# FinalLoneScope — residual attack on r25 C2 INCOMPLETE/48 retention and lone-clone paths

Seat: KagiR26.FinalLoneScope (critic, lane-authored advice, not non-author closure).
Candidate: `d30c9892a7377b8b5a51817d1db8b81eaddcc397`; frozen BASE `1bf3eec48d3761580ffd375c88143232485ae814`.
Scope: retention of round-25 C2 lone-clone INCOMPLETE/48 semantics in `.ufo/waves/round-26/tools/final-measure.py` (`lone-citations-honesty`, `lone-verify-honesty`, `ledger-default-host-exclusion`), citation owned-path classification unchanged, sibling-source collisions, SHONEN author marks, no semantic/runtime inference.
Mode: source-based falsification only. I ran NO gate (`claim-ledger.sh verify|cells|citations`, `release-clock.py`, `replay-current.sh`, `final-measure.py`), no build/lint/test/formatter, no installs, no network. Read-only git probes plus a from-scratch static re-implementation of the gate's tokenize→normalize→classify→resolve pipeline (never executed). The re-implementation's output is *static simulation*; its BASE result is reconciled against the observed receipt `.ufo/waves/round-25/c2-lone-citations-after.txt` (`fleet_absent=48`, `unresolved=0` in `CITATION_GATE: INCOMPLETE`). This file is my only write.

## Verdict

**Blocking defect found (candidate-blocking).** `corpus/lessons/round-26.md:125` introduces `corpus/digit`, a checked-class (`local`) citation that resolves nowhere in the candidate tree. It is the first UNRESOLVED citation in the committed doc set since round 25 made lone-clone layout explicit. It makes `bash corpus/claim-ledger.sh citations` report `CITATION_GATE: BROKEN` (exit 1) in **every** layout — lone and fleet — so the retained `INCOMPLETE (… fleet_absent=48)` verdict becomes unreachable and the ledger loses `LAYOUT-INCOMPLETE` entirely. Three of `final-measure.py`'s checks are pre-failed by it. The 48-count itself is retained (my simulation reproduces `fleet_absent=48` at both BASE and candidate); the break is a brand-new lane-owned defect, not an inherited count drift — the retained honesty checks would correctly catch it, which also means they correctly fail.

## Findings

### F1 (blocking) — `corpus/digit` is an unresolved checked-class citation; kills INCOMPLETE/48 in every layout

Evidence (all paths/lines are candidate `d30c9892`):

- `corpus/lessons/round-26.md:125`: `D2 (C1 is not complete corpus/digit coverage). This supersedes the earlier` — the token `corpus/digit` is whitespace-separated and unmarked.
- Gate mechanics (all in unchanged `corpus/claim-ledger.sh`, `git diff BASE CAND` = 0 bytes):
  - class: `corpus/*) printf 'local'` (cite_class, ~line 643) — `local` is checked, never `fleet_only`.
  - resolve: `[[ -e $ROOT/$t ]]` (cite_target, ~line 658). `git ls-tree -r d30c9892 --name-only` contains no `corpus/digit` path → unresolved.
  - mark check is per-line (`MARK_RE`, line 640): the line contains none of `scratch|ephemeral|relocat|formerly|no longer|removed|renamed|historical` (observed by grep) → not `LABELED`.
  - verdict: `CIT_UNRESOLVED>0 → CITATION_GATE: BROKEN … exit 1` (lines 1269-1272); the `INCOMPLETE`/`fleet_absent` branch (1274-1277) is unreachable whenever `unresolved>0`.
  - verify: `LAYOUT-INCOMPLETE` requires `rc==3` **and** a last line matching `CITATION_GATE: INCOMPLETE (` (lines ~602-610); a `BROKEN` exit 1 falls through to `FAIL R11-08 reason=exit-mismatch` → `CLAIM_LEDGER: FAIL`.
- Static simulation (my re-implementation, exercised): scans the committed default doc set (`default_docs`, lines 758-767: six root docs + `corpus/README.md` + `corpus/knowledge/*.md` + `corpus/lessons/*.md`).
  - BASE `1bf3eec4`: `fleet_absent=48, unresolved=0, ephemeral=0` — **exactly** reproduces the observed round-25 lone receipt `.ufo/waves/round-25/c2-lone-citations-after.txt` (`fleet_absent=48`, `INCOMPLETE`). This reconciliation is why the simulation is trusted.
  - Candidate `d30c9892`: `fleet_absent=48` (zero CAND-only fleet-absent tokens), `unresolved=1` — the single new entry is `corpus/lessons/round-26.md:125 corpus/digit`. `EPHEMERAL=0`, `LABELED=19` unchanged.
- Cascade in `final-measure.py` (all [INFERENCE] of run outcome from gate source — not executed):
  - `lone-citations-honesty` (`final-measure.py` ~line 91): expects exit 3 + `CITATION_GATE: INCOMPLETE` + `unresolved=0` + `fleet_absent=48` → gets exit 1, `BROKEN` → FAIL. The lone clone itself is correctly isolated: `lone_parent = temp/"lone"` holds only `checkout/` — no `*-shokunin` dir, no `.ufo`/MANIFEST/AXES/ MISSION entries → `fleet_layout_present` false → `CIT_LONE=1`. Path construction is sound; the failure is doc content.
  - `lone-verify-honesty` (~line 93): expects `LAYOUT-INCOMPLETE R11-08` + `CLAIM_LEDGER: INCOMPLETE` + `layout_incomplete=1` + `host_skipped=12` → gets `FAIL R11-08` + `CLAIM_LEDGER: FAIL` → FAIL.
  - `ledger-default-host-exclusion` (~line 83): the fleet mirror run — `citations` still hits the same `corpus/digit` (local class resolves in no layout) → `CLAIM_LEDGER: FAIL` → FAIL.
  - Production equivalent: `bash corpus/claim-ledger.sh citations` at candidate in the real fleet reports `BROKEN`, so R11-08's expected `^CITATION_GATE: CLEAN` also fails there. This is not lone-only.
- Claim-consistency: `LOG.md` (candidate, ~line 1452) asserts "Round25 C2 remains honest INCOMPLETE/48, not silently closed"; `README.md` (~line 111) "Round25's C2 lone-clone INCOMPLETE/48 remains unclosed". The retained *count* is intact, but the retained *verdict* is unreachable at candidate. Fix is one token: rephrase `corpus/digit` so it is not a `corpus/`-shaped path (e.g. "corpus digit-count coverage") or put the line under a mark word. The uncommitted worktree copy of `corpus/lessons/round-26.md` still carries the same token at line 125 (observed `grep`), so the defect survives the currently-visible landing delta unless amended.

### F2 (low) — `source-census` substring is truncated before the tail counts

`final-measure.py` asserts `SOURCES_CENSUS: CLEAN (rows=41 A=39 B=0 C=2 queued=1 mined=37 rejected=3` — a substring test missing the closing `)` and the fields `entries_sourced=4 legacy=21 captures=41 inrow=16 inrow_only=0 inrow_nonreproducing=12` that R21-02's anchored regex (`corpus/claim-ledger.tsv` R21-02) requires. A census printing e.g. `rejected=30` or `mined=370` or drifted tail fields would still satisfy the substring. Mitigating coverage: `ledger-default-host-exclusion` runs `verify`, which re-runs R21-02 with the anchored full regex — so the gap is inside this recorder only, not the gate. [INFERENCE] of run behavior; string verified literally at `final-measure.py` (the `contains` entry under `run("source-census", …)`).

### F3 (named, by design) — mirror `verify` resolves fleet-only citations against live sibling checkouts, not pinned copies

`final-measure.py` builds `mirror/` by symlinking every `*-shokunin` directory, `.ufo`, and files of `LANE.parent` next to a pinned clone (`entry.name.endswith("-shokunin") or entry.name == ".ufo" or entry.is_file()`). `cite_target` resolves `*-shokunin/…` → `$ROOT/../…` and `ufo/…` → `$ROOT/../.ufo/…` (claim-ledger.sh ~lines 666-677), so the mirror's `verify`/`citations` see **current fleet bytes**, identical to production semantics but not pinned to BASE — a mirror failure can be fleet drift rather than candidate defect, and stale sibling files can mask a regression the candidate introduced into a sibling-cited claim. No collision found: `fleet_entry_in`'s `readlink -f != self` self-exclusion is correct, `kagi-shokunin` itself is skipped by name, and `kagi-shokunin/…` self-references resolve in-clone first (`$ROOT/$r`, line ~671). No `residual/` path is cited in any scanned doc at candidate (grep over the doc set), so the untracked `residual/` dir cannot become an extra UNRESOLVED.

## Sibling-source collision check — clean

- `corpus/release-clocks.tsv` binds S027/S028→S036 and new S040/S041→S039; S036 and S039 are two registry rows on the one Python feed URL. `sources-census.sh` enforces uniqueness only on row ids (SC_DUP, ~line 189); there is no URL-uniqueness rule, so no census collision. `release-clock.py` `parse_sources` indexes by id only. Consistent with `final-measure.py`'s note "One shared Python feed, two teaching/clock dispositions". Registry rows verified: S039/S040/S041 are `docs|A|mined`; S040/S041 carry `on-release` cadence, S039 `90d` (SOURCES.md lines 46-48).
- No cross-source `use_by`/`SC_USEDBY_NOCITE` risk observed: all three new rows' used-by path is `corpus/lessons/round-26.md`, which exists at candidate and cites each id [INFERENCE from grep presence of S039–S041 in the lesson's Paths/search-log text].

## SHONEN4 author marks — clean

`git diff BASE CAND -- SHONEN.md` is empty (0 lines); all four boxes remain `- [~]` (verified reading `SHONEN.md` lines 3-16). `corpus/lessons/round-26.md:128` states "It verified no SHONEN box and is not a round26 outside discernment check; all four boxes remain author [~]" — consistent. No `shonen`-shaped new marks or [x] promotion anywhere in the diff.

## Verified-consistent checks (exercised, no failures found)

- Receipt pins: `sha256(BASE:.ufo/waves/round-25/observe-1.json) = b74c8ee3…` == `HISTORICAL_SHA`; `sha256(CAND:.ufo/waves/round-26/observe-2.json) = 13b8540c…` == `CURRENT_SHA` == candidate `corpus/release-clock.py:28 DEFAULT_RECEIPT_SHA256` == `rearmed/observe-2.json`.
- `id-exact-drift` replication (pure data compare): old 28 vs new-`observe-1.json` 28, same id set, `changed == ['S027','S028']` on `(id,clock,url,http_status,error,parsed_version,located,verdict)` — S027/S028 went `not-fired@3.15.0 → fired@3.15.1`, everything else identical. `observe-2.json` = 30 records; S040/S041 `not-fired@3.15.1`.
- Snapshot integrity: `sha256(frozen/inputs.sha256)=cbb420c5…` and `sha256(rearmed/inputs.sha256)=2e476782…` equal `replay-current.sh`'s pinned `manifest_sha` branches; manifest contents equal `expected.json`'s `input_sha256` maps byte-for-byte. `frozen/release-clock.py`=`f1a8237c…` (BASE corpus blob); `rearmed/release-clock.py`=`ef17654e…` (candidate corpus blob); `frozen/after/corpus/release-clocks.tsv`=`ee0fafbc…` = BASE table + exactly the two S027/S028 fired-row edits (diff verified); `rearmed/before` tables/`SOURCES.md`/`source-fetches.tsv` == BASE/candidate as designed.
- Captures: `S039/S040/S041.body` sha256 == `captures/metadata.json` == `source-fetches.tsv` digests (`11c86a34…`, `0724d815…`, `8a541381…`). S039 feed: 10 `<item>`s, first title `Python 3.14.9`, contains `Python 3.15.1` (max stable) and `Python 3.16.0a1` (prerelease) — the `backport-first-parser-control` inputs hold. S040 contains `<dl id="index-32">`/`index-33` delimiters (grep count 2) and its scope carries the ASCII-flag and isspace phrases; S041 carries "uses the rules defined by the HTML 5 standard". Normalized-text quote membership not re-derived (would require executing the normalizer).
- Provenance: `observe-run.json` records argv `python3 -B corpus/release-clock.py --observe …/observe-1.json`, exit 1, `wrote 28 observations (failed=0 fired=3)` + `RECEIPT-MISMATCH S027/S028` — receipts are observe-produced, not hand-merged.
- `final-measure.py` interfaces vs `corpus/release-clock.py` (unchanged-interface check): `parse_sources`, `parse_bindings`, `HEADER`, `parse_latest_version`, `observe_one`, `request_body`, `--root/--receipt/--receipt-sha` all exist at candidate; `observe_one` ignores `normalizer` for `clock=="feed"`, so `observe_one(sources[sid], by_id[sid], None)` is well-typed; the monkeypatched `request_body` fake feed `<item><title>Python 3.15.2</title>` parses to `3.15.2` ≠ `3.15.1` → `fired` [INFERENCE from source semantics]. `rendered-text-v1.py` exposes `normalize_text`/`normalize_bytes`.
- Ledger consistency: `claims=65` (R21-04 pins 65 rows; no claim rows added — only expectation/note edits), `stamped=89` (stamps.tsv +1: `corpus/lessons/round-26.md` `8122023d…` 201/16091 — its own self-pin present), `host_skipped=12` unchanged (no new host rows in the diff). `self-counts.tsv` unchanged at 38 rows; SKILL/PROVINCE/README number edits (88→89 stamps; "at round 25" history clause added in PROVINCE) stay consistent with the unchanged bindings — `stale=0` plausible [INFERENCE].
- `claim-ledger.sh` byte-identical BASE↔candidate → **classification semantics are unchanged**; the F1 break is an input-side new debt, not a reclassification.
- `verify` LAYOUT-INCOMPLETE recognition requires `cmd == 'bash corpus/claim-ledger.sh citations'` verbatim — the pinned command matches.
- Worktree divergence (observed `git status`): production worktree differs from candidate in `tools/final-measure.py` (adds `authority` oracle table, `missing-manifest-fails-typed`, `original-round25-replay`, `rearmed-snapshot-is-measured-production`), `tools/replay-current.sh` (`realpath -e` + missing-manifest typed failure, `python3 -I -B`), `corpus/README.md` heading, `corpus/lessons/round-26.md` (+`Residual guidance clarifications`). All measured statements above are against the **candidate blob**, not the worktree; the worktree delta does not touch `corpus/digit`.

## Residual risk and gaps

- F1's exact UNRESOLVED line is static simulation, reconciled at BASE (48/0 matches the committed round-25 receipt). Residual simulation-vs-gate divergence is possible only in the ~6-token norm/pretokenize corner cases; `corpus/digit` is a plain alphanumeric token where all code paths agree — confidence high, but the live `citations` run was NOT executed (no-gates constraint).
- `per-clause-source-check` normalized-text membership not re-derived (would execute the normalizer). Raw scope/phrase presence verified only.
- Mirror `verify` fleet-citation outcomes are host-state dependent (F3); a lone failure there is not itself candidate-proof.
- `successors-fire-next-release`, missing-binding, tamper, replay `frozen-*`/`rearmed-*` checks: static inspection only — plausible by source, unexecuted.
- No install was needed; no tools added (per RULES.md: pacman paused, none required).

## Exercised commands (observed outputs, abridged)

- `git diff --name-status BASE CAND` — 1 `M`+`A` set listed above; `git diff BASE CAND -- corpus/claim-ledger.sh` → empty; `-- SHONEN.md` → empty.
- `sha256sum` of `git show` blobs — every pin in §Verified-consistent reproduced as stated.
- `git show d30c9892:corpus/lessons/round-26.md | sed -n '120,140p'` — line 125 carries `corpus/digit`.
- `git ls-tree -r --name-only d30c9892` — no `corpus/digit` entry; `corpus/lessons/*.md` count 69 docs at candidate vs 68 at BASE.
- `git show d30c9892:corpus/claim-ledger.sh` (1807 lines) — cite_class/cite_target/fleet_only_token/default_docs/verdict lines quoted above.
- `cat .ufo/waves/round-25/c2-lone-citations-{before,after}.txt` — observed `FLEET-ABSENT` list and `CITATION_GATE: INCOMPLETE (… fleet_absent=48)`.
- python3 inline simulation of the gate's tokenizer over `git show` doc blobs — BASE `fa=48 un=0 eph=0`; CAND `fa=48 un=1 eph=0` (sole new: `corpus/digit`, lessons/round-26.md:125); zero CAND-only FLEET-ABSENT tokens.
- `git status --porcelain` — worktree `M`/`??` set listed above (not part of candidate).

Report by KagiR26.FinalLoneScope. Lane-authored advice; L1 owns production integration and the final immutable suite.
