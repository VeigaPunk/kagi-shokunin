# ScoutProtected — round-23 falsification (protected boundaries + spot re-measurement)

Seat: `KagiR23.ScoutProtected` (leaf, read-only lane).
Window: 2026-10-21 00:59–01:08 -03:00.
Base: `d218603b74099ddca0bd8f869516fc41db0979bf`.
Revisions observed (the lane committed while this seat measured):

| rev | time | subject |
|---|---|---|
| `d218603` | — | round-22 verifier spot-check (base) |
| `e1884c6` | 01:04:19 | round-23: closure dispositions, declared source provenance, hermetic cells |
| `ea5b734` | 01:05:47 | round-23: measured verdict, corrected provenance wording, final pins |
| `b55e0e7` | 01:07:08 | round-23: S015 debt, D7 wording, relocated seat reports (final observed) |

Verdict: **protected sweep CLEAN; C1 and C3 confirm; C2 executable verdict confirms but one stated bound is false, and one fatal pre-commit script state is documented below.** The lane was still committing while measured; all claims here are pinned to the revision/script hash named.

## 1. Protected-path sweep (primary assignment)

Attacked: every inherited lesson, aggregator audit, verifier spot-check, `plans/round-22.md`, tracked `.ufo` history, and sibling-lane paths, across base → `b55e0e7`.

Commands and results (all read-only):

```
git rev-parse HEAD                          # b55e0e7b19b1c6e18094bbd194bf37c236533a6a
git diff --name-status d218603 b55e0e7 -- corpus/lessons plans .ufo | grep -v round-23
                                            # no matches, exit 1
for f in $(git ls-tree -r --name-only d218603 corpus/lessons plans); do sha256(base) vs sha256(final); done
                                            # inherited_changed=0 (32 lessons + 4 plans)
git show --name-status --format='' b55e0e7 | grep -E 'MANIFEST|\.ufo/state|shokunin/|lessons/round-(1|2[0-2])|spotcheck|aggregator|plans/round-2[12]'
                                            # no matches, exit 1
git status --porcelain=v1 -uall | grep -v '^?? \.ufo/waves/round-23/'
                                            # only " M .ufo/waves/round-23/falsify/ScoutMigration.md"
                                            # (a peer's in-flight report; not protected)
git diff --summary                          # empty (no mode/deletion changes)
```

Specific confirmations:

- `corpus/lessons/round-22-verifier-spotcheck.md` sha256 `65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7`, identical to `corpus/closure-dispositions.json:source_sha256`.
- `corpus/lessons/round-21-verifier-spotcheck.md` sha256 `6e4fa622...` unchanged.
- Aggregator audits (`round-{1,4,5,6,8,9}-aggregator-*`) unchanged (0 hash deltas).
- `plans/round-22.md` sha256 `37b8eb0b...` unchanged.
- Commits `e1884c6`, `ea5b734`, `b55e0e7` add only round-23 paths: `corpus/lessons/round-23.md`, `plans/round-23.md`, `.ufo/waves/round-23/**`, plus the allowed production files. No path outside the kagi repo and no `MANIFEST.json` / `.ufo/state` entry.
- The only unexpected machine-visible state is outside this lane: the fleet repo at `/home/vgpnk/Projects/shokunin` shows ` M .ufo/watchdog.log`, 14 untracked `.ufo/state/*.report-baseline`, and `.ufo/waves/round-23/parent-build/ClaimR11X11.md`. Authorship is not attributable here (concurrent fleet orchestration); recorded, not counted as a kagi violation.

Finding: **no protected file was edited, deleted, or re-pinned to a changed hash.**

## 2. C1 — closure dispositions (calibration)

```
python3 corpus/closure-dispositions.py
  -> CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)   exit 0
python3 corpus/closure-dispositions.py --selftest
  -> CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)                                                                        exit 0
```

Independent count from the pinned source (`corpus/lessons/round-22-verifier-spotcheck.md`): 9 `^- D[0-9]` bullets (lines 165–183) + 5 admit/reject table rows (103–107) + 1 `**ADMITTED.**` adjudication (157) = 15 obligations; JSON has 15 unique ids. Independent mutation on a `/tmp` copy (baseline CLEAN, exit 0): drop `D5` → `DISPOSITION MISSING D5` / `FAILED (obligations=15 dispositions=14 missing=1 unknown=0 unresolved=0)` exit 1. Gate is sensitive to the claimed classes.

Bound (already stated at `corpus/lessons/round-23.md:181-190`): pointer resolution is presence-only — a `fixed` pointer proves file + anchor substring + id token, not fix content; the source digest is pinned inside the same lane-writable JSON (internal consistency, not immutability). Confirm.

## 3. C2 — declared source provenance (freshness)

Current executable verdict, at `b55e0e7`:

```
bash corpus/sources-census.sh
  -> SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)   exit 0
bash corpus/sources-census.sh --selftest
  -> SOURCES_CENSUS_SELFTEST: PASS (59 cases)                                                                 exit 0
```

Data: 10 provenance rows `S017`–`S026`, **9 distinct URL strings** (S021/S026 share `https://openbao.org/docs/concepts/tokens/`); 16 legacy in-row pins `S001`–`S016`; no registry row without a pin or a provenance row (checked independently). `LOG.md:1202` correctly says “10 declared captures over 9 distinct URLs”; the dispatch brief's “7 URLs” is wrong — correct the brief, not the artifact.

Independent mutations on a `/tmp` copy of `SOURCES.md` + `source-fetches.tsv` + entries (baseline CLEAN, exit 0):

```
S017 status mined->queued   -> FINDING SC_FETCH id=S017 status=queued registry=mined   exit 1
delete S017 provenance row  -> FINDING SC_FETCH id=S017 missing-provenance             exit 1
S026 col15 normalized sha    -> FINDING SC_FETCH id=S026 same-url-normalized-disagreement exit 1
```

### Defect C2-A (bound stated is false)

`corpus/lessons/round-23.md:53-54` says “so no cross-capture equality is enforced”; `corpus/source-fetches.tsv:21` repeats “No cross-capture equality is enforced.” The committed gate does enforce equality for same-URL rendered-text rows: `corpus/sources-census.sh:287-289` (`same-url-normalized-disagreement`), exercised by selftest case `fetch-disagree` (`corpus/sources-census.sh:569`, expected exit 1) and by the mutation above. The blanket bound is contradicted by the shipped code and its own selftest.

Impact: current CLEAN is unaffected (S021/S026 agree), but a future chrome-driven change to the tokens-page normalized digest between two declared rows would fail a capture the lesson says is permitted. The claim must state the narrower bound: *same-URL, same-normalization declared rows are equality-compared; raw digests are compared only for non-volatile representations.* The working-tree/committed wording should be corrected, not silently kept.

### Defect C2-B (in-flight fatal state; fixed before commit)

At 00:59–01:01 the live (uncommitted) `corpus/sources-census.sh` sha256 `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` failed the exact R21-02 command twice:

```
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
exit 1
```

Cause: the new supersedes loop assigned `SUPERSEDED[$fid]=1` with no associative-array declaration (declarations at old :203/:229 omit it), under `set -uo pipefail` (:107). Minimal repro: `bash -c 'set -u; A[S007]=1'` fails; with `declare -A A=()` it succeeds. The 59-case selftest passed on that same buggy hash because the fixture contains no supersedes cell (`grep -c supersedes` = 1, the awk regex itself), so the real-data path was uncovered.

At 01:02:21 the file became sha256 `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` (supersedes block removed) and CLEAN reproduced with the exact expected line. `git log d218603..HEAD -- corpus/sources-census.sh` shows only `e1884c6`, whose bytes are `24d834`; the failing `80966e` state was never committed. `corpus/stamps.tsv` pins `24d834`.

Bound: R21-02's expectation line does not name the script revision; only `stamps.tsv` does. The claim/report must pin the measured script sha (or the final commit), because the CLEAN line was not reproducible on the intermediate tree that existed after the claim prose was written.

## 4. C3 — hermetic `cells` (operability)

Exact R23-01 command (`corpus/claim-ledger.tsv:59`):

```
bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
  --claims corpus/fixtures/cells-hermetic/claims.tsv \
  --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
  --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
  --docs corpus/fixtures/cells-hermetic/SCORECARD.md
  -> CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)   exit 0
```

Fixture is host-free (only `printf` and `grep`; the `$HOME` strings in `corpus/adjacency.tsv` are data, matched literally by `[[:space:]].HOME/`). Mutation sensitivity, on `/tmp` copies:

```
claims R90-01 expect ^FX: OK$ -> ^FX: NOPE$
  -> FAIL R90-01 reason=verdict-not-final exit=0
     CELL_AUDIT: BROKEN (... row_failures=1 ...)   exit 1
append one line to corpus/adjacency.tsv
  -> STALE-POINTER corpus/adjacency.tsv sha=fa15a53c7e58->645316d56ac2 lines=9->10 bytes=307->315
     CELL_AUDIT: BROKEN (... stale_pointers=1 ...)  exit 1
```

Fixture churn observed during the window (parent edits): `adjacency.tsv` separators spaces→tabs at 01:03:17, `claims.tsv` R90-02 timeout 10→30; the exact CLEAN line was re-run after the churn and unchanged. Confirm. Bound: this proves the `cells` mechanics on fixtures only; `rows_run=2` counts selected rows, and the mutation test is manual, not a ledger row.

## 5. Revision / evidence hygiene

- `.ufo/waves/round-23/final-verification.json` (committed in `ea5b734`) records `measured_commit: e1884c6` and `generated: 2026-10-21`; its R21-02/R21-03/R23-01/R23-02 result lines match my re-runs at `b55e0e7`. But the final revision is `b55e0e7`, two commits later, and `source-fetches.tsv`/`stamps.tsv`/`round-23.md` changed after the recorded commit. Re-run the four rows at the final hash, or state the delta is comment/pin-only; a `measured_commit` field that trails the claimed revision is a provenance defect.
- `corpus/lessons/round-23.md:183` commits “The 64-seat falsification wave confirmed the three claims” while the wave was still in flight (95 untracked run artifacts under `.ufo/waves/round-23/` at 01:07:44). The executable verdicts do reproduce from this seat, but the sentence should not be read as a closure of the wave; the lane's own text says the parent's non-author closure owns admission. Add the C2-A bound to the named bounds before that sentence is used as closure evidence.
- No installs, no packages, no host gates, no secrets, no git/jj mutation were performed by this seat. Only this report file was written.

## 6. Bounds the claims must state

1. C1: pointer test is presence-only (file + anchor substring + id token); digest pin is lane-writable internal consistency; anchor matches any `#` line.
2. C2: shape/identity only, not content; 10 rows over **9** distinct URLs; **same-URL rendered-text rows are equality-compared** (contradicts the current “no cross-capture equality” wording); historical in-row pins are uncompared; digests are point attestations.
3. C2 provenance: cite the final script sha `24d834…` / commit `b55e0e7`; the pre-01:02 intermediate `80966e…` fails R21-02 with `S007: unbound variable` and its 59-case selftest did not cover the supersedes path.
4. C3: fixture mechanics only; mutation test manual; `rows_run` counts selected rows (hence `row_deferred=0`/`self_skipped=0` are the real guards).
5. Round evidence: `final-verification.json.measured_commit` (`e1884c6`) is behind the final observed revision (`b55e0e7`); re-measure or disclose the delta.

## 7. Addendum — lane advanced while this report was written (HEAD `284d40e`, 01:10:14)

The lane committed repeatedly during the window: `e1884c6` 01:04:19 → `ea5b734` 01:05:47 → `b55e0e7` 01:07:08 → `7af07b4` 01:09:01 → `284d40e` (last observed, 01:09:5x). Re-measured at `284d40e`:

- Protected sweep re-run: `git diff --name-status d218603 284d40e -- corpus/lessons plans .ufo` (excluding round-23 paths) → no matches; `git diff --quiet d218603 284d40e -- corpus/lessons/round-22-verifier-spotcheck.md corpus/lessons/round-21-verifier-spotcheck.md plans/round-22.md corpus/lessons/round-6-aggregator-audit.md` → exit 0; inherited hash delta still 0 across all 32 lessons + 4 plans. No protected file edited in any observed commit. At the 01:10:14 snapshot the worktree had only a peer's in-flight `ScoutMigration.md`; the lane resumed editing production files immediately after (pending diffs at 01:10:38), so a freeze has not yet occurred.
- C1 gate CLEAN exit 0; `--selftest` now `PASS (14 cases)` exit 0 (symlink pointer-escape case added in `7af07b4`).
- C2 gate CLEAN exit 0; C3 exact `CELL_AUDIT: CLEAN` exit 0 (unchanged).
- C2-A persists at `284d40e`: `sources-census.sh:287-289` still enforces `same-url-normalized-disagreement`, while `round-23.md:54` and `source-fetches.tsv:21` still state “no cross-capture equality is enforced”. Correction still required.
- New minor defect C1-A: `SCORECARD.md:851` still advertises `--selftest` “(13 cases)” while the shipped selftest emits `PASS (14 cases)`; `round-23.md:60` repeats 13 and only the late section `round-23.md:205` records 14. The live capability table and the claim table must say 14 or point at `:205`.
- The late bounds section (`round-23.md:198-205`) now acknowledges that the 59-case census selftest exercises only the declared-provenance branch; this is consistent with this report's C2-B coverage note.
- Because HEAD moved during the window, any claim text citing a count or revision must pin the measured commit. This addendum pins `284d40e` as the last observed revision; re-run at freeze if HEAD advances again.
