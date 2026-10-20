# Round 22 — Entry01: adjacency-breadth freshness and calibration audit

Axes: **calibration (C1)** and **freshness (C2)**. This seat is read-only: no host gate, test, build, lint, formatter, vault/account read, or installation was run. Counts marked "static" are derived from shipped source text, not executed.

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD`; matches `plans/round-22.md`). Tracked worktree clean; untracked `.ufo/waves/` and `plans/round-22.md` only. Target: `corpus/knowledge/adjacency-breadth.md` (161 lines, 7729 bytes) and its row at `corpus/stamps.tsv:9`.

## Verdict

| question | verdict |
|---|---|
| Actual stale-byte mismatch? | **No.** Current SHA-256/lines/bytes equal the stamp row exactly. The file is unchanged since `bc1af88`. |
| Substantive freshness? | **Unverified and date-bound.** The only host observation is `2026-09-29` (`adjacency-breadth.md:5`), 21 days before 2026-10-20. Host counts cannot be re-verified in this lane. |
| Absent-source limit? | **Yes, by design.** No `SOURCES.md` S-row exists for this host-observation contract; the four private host roots are outside the clone, and the four aggregate totals are explicitly not committed pins. |
| Appended correction to this doc? | **Not needed.** The doc states its date, host dependence, and no-scheduling bound; restamping unchanged bytes would add no evidence. |
| Correction elsewhere? | **Yes, calibration metadata.** `corpus/README.md:46` and `SCORECARD.md:306` say "13 bounds"; the shipped contract has **9** numbered `§Bounds` items and **13 distinct failure tokens**. |

## 1. Stamp-row verification (byte)

| item | stamped (sha256 / lines / bytes) | observed 2026-10-20 | verdict |
|---|---|---|---|
| `corpus/knowledge/adjacency-breadth.md` | `94ee01d7f0b010316d3d21d1103cb3f9c93459fbaec0ea22546637b670c35e36` / 161 / 7729 | identical | **FRESH** |
| `corpus/scope-gate.sh` | `078a260184e25282096ef5f611b01ac1fb97deddb52d78facc1d551ff61f8082` / 1129 / 55002 | identical | **FRESH** |
| `corpus/adjacency.tsv` | `4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549` / 83 / 5660 | identical | **FRESH** |
| `corpus/surface-census.tsv` | `4af0dbcc81fdb7229f816bf23920174b1d699ba279405272fb78c5922f368992` / 54 / 4752 | identical | **FRESH** |

The row has exactly four fields, no duplicate path, and is not a symlink/final-component issue. All three cited bases are also byte-fresh, so the entry's dependency closure has no stale-byte edge.

Current byte-stale set (context; not this entry): five content files plus `LOG.md`:

| path | stamped sha12/l/b | actual sha12/l/b |
|---|---|---|
| `corpus/knowledge/config-layering.md` | `848b8e502ea2`/109/6621 | `9d4ac8c24981`/136/8088 |
| `corpus/knowledge/handler-on-disk-state.md` | `811572dcf630`/247/17609 | `df6a5e5d05f4`/277/19329 |
| `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e734c`/285/17669 | `fa17fff38dfb`/316/19410 |
| `corpus/knowledge/janitor-env-contract.md` | `88dca63ac7e6`/90/5111 | `dac43ef97393`/113/6372 |
| `corpus/lessons/round-18.md` | `614335f2a8cb`/73/4216 | `b00b7dd8d5b2`/80/4557 |
| `LOG.md` | `60a8fd366c83`/1043/74864 | `51e76cf1f69f`/1050/75404 |

`adjacency-breadth.md` is in neither set. The five content-file stamps are consistent with the plan's "five stale stamps" (their exact outside-verifier identity is not re-adjudicated here); `LOG.md` is an additional byte-stale append-only log.

Historic membership: the file and its stamp row were introduced together at `bc1af88` (`2026-09-29 01:37:49 -0300`, round 17). `git log -S 'corpus/knowledge/adjacency-breadth.md' -- corpus/stamps.tsv` returns only `bc1af88`; `git diff bc1af88 HEAD -- corpus/knowledge/adjacency-breadth.md` is empty; `git diff bc1af88 HEAD -- corpus/stamps.tsv` contains no deletion or replacement of this path's row. Committed stamp-row counts on master rise monotonically (`28, 33, 44, 48, 52, 54, 56, 63, 63`), so no net nine-row deletion appears on this history. Whether the outside verifier's nine refers to a different snapshot is left to the C2 history seat; **this row is present in every post-introduction commit and is not one of the nine**.

## 2. Source-bound calibration checks (static)

Distinction: the contract's **mechanism** claims (rules, tokens, derivation, reproduction counts) are current against the shipped script; its **live counts** are a dated observation, not a standing promise. The table keeps those categories separate.

| doc claim | source check | verdict |
|---|---|---|
| Source basis is `scope-gate.sh` v2 / round 17 | `scope-gate.sh:18-20`; commit `bc1af88` | supported |
| Four required leaf directories, derived not self-declared | `scope-gate.sh:505-517`; pins at `adjacency.tsv:75-78`; eight `# no-enumerate` rows with four aggregate ancestors | supported |
| 182 direct children | pins `20 + 105 + 4 + 53 = 182` | supported |
| 8 declared child buckets | direct-child derivation over census rows: opencode `4` (json, agents, plugin, tools), local bin `2`, agents `1`, profile `1` | supported |
| 174 undeclared | `182 - 8 = 174`; per-dir `16/103/3/52` | supported |
| 35-row declared universe | `surface-census.tsv` non-comment, non-blank rows = 35 (`20 asset / 15 runtime`) | supported |
| `--selftest` = 61 cases | 56 `run_case` invocations + 5 manual `cases=$((cases + 1))` increments (`:902`, `:1076`, `:1087`, `:1103`, `:1112`); counter at `:883` | supported statically |
| `--falsify` = 18/18 | 9 partition cases (8 `mutate_case` + 1 manual resolved-root case, `:749-765`) + 9 breadth `mutate_case`; `total=18` at `:678` | supported statically |
| 13 failure tokens | all 13 listed in `adjacency-breadth.md:88-95` are present in `scope-gate.sh`; token set matches | supported |
| Exit 1 on token, exit 2 on setup/missing NUL-list | doc `:97-98`; `die` exit 2 and breadth `mktemp` failure path | supported |
| Gate never prints child names | breadth prints counts and root dirs only (`:604`, `:615`, `:663`) | supported |
| `--breadth` final line is `BREADTH_AUDIT` | ordering at `:618-663`: per-dir → scope line → set line → `BREADTH_AUDIT` | supported |
| "13 bounds" | `adjacency-breadth.md:114-137` contains **9** numbered bounds; the only 13-item enumeration in the file is **13 distinct failure tokens** | **unsupported label/count** |

## 3. Findings

### F1 — Medium (calibration): "13 bounds" overclaims the shipped contract

- **Locations:** `corpus/README.md:46` and `SCORECARD.md:306`, both created at `bc1af88`.
- **Source facts:** `adjacency-breadth.md:114-137` has nine numbered `§Bounds` items. The rules table at `:88-95` has thirteen distinct failure tokens. "13 bounds" matches neither taxonomy: it is not nine bounds, and if tokens were intended the label is wrong.
- **Why stamps did not catch it:** both index files are byte-fresh to their **current** stamps (the rows were refreshed as the files grew after `bc1af88`). `README.md` = `6837d22b1e14a1ace6956f74e2f02c5c171039e03f2a6ba7658334a3c6614c6d`/118/22365; `SCORECARD.md` = `29f9f0231f2f57628e74d3e55bab2f950a8b784243777741c094c1994b687303`/691/87010. The "13 bounds" lines themselves were created at `bc1af88` and remain unchanged (`git blame`); the stamps certify the current text as-is, not its correctness.
- **Proposed correction:** append a dated Round 22 erratum that records the exact old text, the 9-bound count, the 13-token count, and the source lines. Correct the active index wording to "9 bounds" — or "13 failure tokens" if that was the intent. Do **not** rewrite the historical Round 17 `SCORECARD` cell in place. If either file is edited, restamp the full set (no `--prune`) and preserve the old hash in the erratum/git history.
- **Acceptance:** a reader counting `§Bounds` in the doc and the two index sites gets the same number; the historical row remains historically intact.

### F2 — Low (freshness): "live leaf ratios" lacks its measurement date in the index

- `corpus/README.md:44` calls `20/4, 105/2, 4/1, 53/1` "live leaf ratios"; the doc dates them `2026-09-29` (`:5`) and states host access and no scheduling (`:133-137`). The index wording implies a current host measure.
- **Proposed correction:** change to "pinned leaf ratios (2026-09-29)" or point at the doc; same append-only erratum path. Do not present a future re-pin as a re-verification.

### F3 — Informational: byte-fresh is not re-verified

- `claim-ledger.sh verify` compares SHA-256, lines, and bytes only (`:330-375`). The stamp row carries no verification date or verdict. Restamping the unchanged doc would reproduce the identical row and would not demonstrate host freshness.
- The doc itself is honest about this: measurement date `:5`, host-access bound `:133-134`, aggregate non-promises `:135-136`, no-scheduling bound `:137`. **No appended correction to this doc is needed for this reason.**

### O1 — C2 expectation-migration precedent (and one recorded gap)

- At `bc1af88`, `R16-01..03` expectations were migrated in place: `R16-02` `SCOPE_SELFTEST: PASS (43 cases)` → `(61 cases)`, `R16-03` `caught=9/9` → `caught=18/18`, and `R16-01` gained the breadth fields. Exact `R16-01` delta (`8a6ec16` → `bc1af88`): the old regex ended `basis_escape=0 own_unlisted=0)`; the new regex inserts `breadth_required=4 breadth_pins=4 breadth_checked=4 breadth_ok=4 breadth_missing=0 breadth_invalid=0 breadth_drift=0 breadth_exceeds=0 breadth_unverified=0` before the closing `)`. The old 43/9 values remain in the R16-02/R16-03 notes; `git diff 8a6ec16 bc1af88 -- corpus/claim-ledger.tsv` preserves the old strings. `R12-03`'s note likewise preserves stamp counts (`54` at round 17, `63` now).
- **Gap:** `R16-01`'s note says "plus breadth extension" but does not print the exact old expected line. If a self-contained migration record is required, append the old→new string with the commit ID; do not restamp to hide the change.

## 4. Exact recheck scope (operator-authorized; NOT run here)

1. `bash corpus/scope-gate.sh`
   Expected: `BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174 missing=0 invalid=0 drift=0 exceeds=0 unverified=0)`, then `ADJACENCY_SCOPE: CLEAN (... breadth_required=4 breadth_pins=4 ...)`, exit 0.
2. `bash corpus/scope-gate.sh --breadth`
   Expected: four `ADJACENCY_BREADTH` lines with `20/4`, `105/2`, `4/1`, `53/1`; `ADJACENCY_BREADTH_SET: dirs=$HOME/.agents,$HOME/.config/opencode,$HOME/.local/share/the-musketeer/chrome-profile`; final `BREADTH_AUDIT: CLEAN ...`; exit 0.
3. `bash corpus/scope-gate.sh --selftest`
   Expected: `SCOPE_SELFTEST: PASS (61 cases)`, exit 0. This is hermetic (scratch `$R/host`).
4. `bash corpus/scope-gate.sh --falsify`
   Expected: `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`, exit 0. This reads `$HOME` via default `ROOT`; operator-only.
5. `bash corpus/claim-ledger.sh verify --root .` on an authorized host
   Expected: this row `OK`; the five content stamps plus `LOG.md` report `STALE`; no restamp until each change is adjudicated.

On mismatch:

- `BREADTH-CHILDREN-DRIFT`, `BREADTH-DECLARED-DRIFT`, or `BREADTH-EXCEEDS`: re-measure with `--breadth`, append a dated correction with live counts/token, update `corpus/adjacency.tsv` breadth pins by review, restamp `adjacency.tsv` and the doc, and record old→new pins in `LOG.md`/the round lesson with date and commit. Do not edit the `2026-09-29` measurement in place.
- `BREADTH-MISSING`, `BREADTH-INVALID`, `BREADTH-SCOPE`, `BREADTH-NOENUM`, `BREADTH-SCAN`: data/schema defects, not host drift. Fix the pin set; leave the historical observation intact.
- A new census row below an already-live direct child triggers `BREADTH-EXCEEDS`: add ownership/census review first, then repin.

## 5. Provenance and append-only preservation requirement

- **Stamp row is a mutable snapshot, not an append-only log.** `claim-ledger.sh stamp` replaces the row set and refuses to shrink unless `--prune` (`:225-274`); `verify` compares all three stamped columns (`:330-375`). Any edit must restamp the complete 63-path set without `--prune`; old row values remain in git and must be recorded in the migration note.
- **Doc preservation:** any correction to `adjacency-breadth.md` must append a dated section after line 161, leaving the `2026-09-29` measurement and all nine bounds intact. Record old hash `94ee01d7…` and the new hash. No silent replacement.
- **Metadata correction:** append the erratum; if the current `README` row is edited, record old text/hash and new text/hash. Do not alter the Round 17 scorecard cell in place.
- **No silent stamp deletion.** This row is present continuously; any restoration of missing members must name the source commit and the expected row, and must not use `--prune` to remove another pin.

## 6. Limits and confidence

- No host gate was run. Live `182/8/174` and the aggregate `94/2, 15/2, 48/1, 2/1` are unknown today; the doc already bounds the aggregates as non-promises.
- No external source: `SOURCES.md` has no S-row for this host-observation contract. Absent-source is structural, not a defect.
- `61` and `18` are static decompositions, not executed PASSes. Confidence: high on byte equality; high on code-structure counts; high on the 13-vs-9 mismatch; medium on the intended label (9 bounds vs 13 tokens).
- The nine reported dropped stamps are outside this per-file verdict. Committed master shows monotonic growth and no deletion of this row after introduction.

## 7. Checks parent should run after integration

- Operator, not this seat: the four gate commands in §4.
- Once `corpus/revision-audit.py` lands: compare `stamps.tsv` to HEAD; expect this row `OK`, the five content files plus `LOG.md` stale, no auto-restamp.
- After any metadata correction: full-set stamp of 63 paths; `R12-03` must remain `63`; verify new `README`/`SCORECARD` hashes; re-run `claim-ledger.sh verify` only on an authorized host.

Report: `.ufo/waves/round-22/build/Entry01.md`
