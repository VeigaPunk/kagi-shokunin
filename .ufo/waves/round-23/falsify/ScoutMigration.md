# ScoutMigration — round-23 expectation migrations (falsification seat)

Read-only lane. No production edit, no `verify`, no host-bound row, no `.ufo/state`, no
MANIFEST read. Page/TSV text treated as data.

**The tree moved during this measurement.** Integration re-pinned stamps and rewrote
R12-03 while I was attacking it. Three snapshots are reported so the race is auditable:

- **E1** 2026-10-21 ~01:00–01:02 -03: `corpus/claim-ledger.tsv` R12-03 `^70$`,
  `corpus/stamps.tsv` 70 rows, 9 stale stamp records, lesson/SCORECARD said "seven
  distinct URLs", no migration record.
- **E2** 2026-10-21T01:04:28-03:00: R12-03 `^79$`, stamps 79 rows, 1 stale record,
  lesson/SCORECARD corrected to "nine distinct URLs", still no migration record.
  Hashes at E2: ledger `0d3d75008122…`, stamps `b5221fc1a4eb…`, lesson `2f53cf690d81…`.
- **E3** 2026-10-21T01:05:50-03:00 (final): R12-03 `^79$`, stamps 79 rows, **0 stale**
  (`sha256sum corpus/stamps.tsv` = `75c3e14915bf…` at 01:05:46), R12-03 note unchanged at
  the 70 arithmetic, still no migration JSON.

Base throughout: `d218603b74099ddca0bd8f869516fc41db0979bf`.

## Live re-measurement (E3, 01:05:50)

| row | base `expect` | E1 (01:0x) | E2–E3 | live value | result |
|---|---|---|---|---|---|
| R12-03 | `^70$` | `^70$` / 70 rows | `^79$` / 79 rows | 79 non-blank, 79 unique paths | matches, note stale |
| R13-01 | `^25$` | `^27$` | `^27$` | 27 `## Round ` headings | matches |
| R21-02 | `rows=23 A=21 … mined=21` | `rows=26 A=24 … mined=24` | same | exact tail line below | matches |
| R21-03 | `47 cases` | `59 cases` | same | 59 executed cases | matches |
| R21-04 | `^43$` | `^45$` | same | 45 rows, 45 unique ids | matches |

Commands and exits (cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

```
git show d218603…:corpus/claim-ledger.tsv > /tmp/cl-base.tsv          # exit 0
grep -c '^## Round ' SCORECARD.md                                     # exit 0 -> 27
git show d218603…:SCORECARD.md | grep -c '^## Round '                 # exit 0 -> 25
grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv                    # exit 0 -> 45
grep -c '[^[:space:]]' corpus/stamps.tsv                              # exit 0 -> 79 (E2/E3; 70 at E1)
grep -cv '^[[:space:]]*#' corpus/stamps.tsv                           # exit 0 -> 79 (identical)
bash corpus/sources-census.sh                                         # exit 0 (all three epochs)
bash corpus/sources-census.sh --selftest                              # exit 0 (all three epochs)
bash corpus/claim-ledger.sh --selftest                                # exit 0 -> PASS (121 cases)
```

Census tail, byte-identical to the `corpus/claim-ledger.tsv:52` expectation at all three epochs:

```
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
```

Selftest: `PASS (59 cases)` at all epochs; 59 executed case lines, 12 of them `fetch-*`;
the base `sources-census.sh` has zero `SC_FETCH` occurrences (`grep -c` -> 0, exit 1), so
the 47→59 delta is real. Ledger selftest `PASS (121 cases)` (121 `ok-case` lines), so
R18-03's unchanged `^121 cases$` holds.

R21-02 arithmetic: 26 rows in `corpus/SOURCES.md`; the `Fetch sha256:` pins are exactly
S001–S016 (16), `source-fetches.tsv` holds exactly S017–S026 (10), union covers all 26;
tiers 24 A / 2 C. Registry distinct URLs 18 at base -> 19 now. R13-01: 25 base headings
intact, only the two Round 23 headings added (`SCORECARD.md:824`, `:835`), 14 distinct
round numbers (Round 20 appears once as the blocked attempt). R13-02 (`^35$`) and R18-02
(`^11$`) still measure 35 and 11 after the two added rows.

## Field diff vs base — what moved, and the E2–E3 race

At E1 a field-level diff of every row (`cmd`, `expect`, `exit`, `timeout`, note) showed:
changed `expect` R13-01, R21-02, R21-03, R21-04; no `cmd`/`exit`/`timeout` change anywhere;
added R23-01/R23-02; notes changed on R13-01, R21-01, R21-02, R21-03, R21-04. Nothing
hidden in the ledger fields.

Then R12-03 moved too, between snapshots:

```
E1 01:0x  R12-03  ^70$   stamps 70 rows
E2 01:04  R12-03  ^79$   stamps 79 rows (24 insertions / 15 deletions vs base)
```

R12-03's **note was not updated** with the expectation. At E2–E3 it still reads "original 63
retained, six reviewed integration additions and one late source-errata lesson pin"
(`corpus/claim-ledger.tsv:28`) = 63 + 6 + 1 = 70, while the row expects `^79$` and the live
file has 79 rows. The 9-row delta is exactly the 9 new pins (closure-dispositions.py/.json,
fixtures/cells-hermetic/{SCORECARD.md,claims.tsv,corpus/adjacency.tsv,corpus/fx-ok.sh,
stamps.tsv}, lessons/round-23.md, source-fetches.tsv); the 15 re-pins are the modified
artifacts. So the *membership update happened* (the E1 defect "3 new artifacts unpinned" is
resolved at E2), but neither the expectation's motivating note nor a QM14 record moved with it.

## Defect 1 — no round-23 migration record (QM14; persists at E3)

`corpus/QUALITY.md:73` requires "a committed migration record with old/new values";
`plans/round-23.md:47-48` says the two executable TSV snapshots "are updated with old/new
migration records per QM14". The round-22 precedent is a tracked file
(`git ls-files .ufo/waves/round-22/round21-migrations.json` -> that path; 232 round-22 wave
files tracked; referenced from `corpus/README.md:126`) whose `rewritten_claim_rows` carries
full old and new TSV lines.

Round 23 has no equivalent at any snapshot:

```
find .ufo/waves/round-23 -maxdepth 3 -type f     # spec/dispatch/registry + audit .md only
find .ufo/waves/round-23 -iname '*migration*.json' | wc -l  # 0 (E3; ScoutMigration.md excluded)
git status --porcelain                          # "?? .ufo/waves/round-23/" — untracked
```

Per-row record status at E3:

| row | old value preserved where | verdict |
|---|---|---|
| R12-03 | none: note says 70, base copy `e6806968…` only in git/stamps history; the 70→79 move has no record | absent (and note contradicts) |
| R13-01 | inline "25 at round-22 close, plus round-23 pre/post" (`claim-ledger.tsv:29`) | partial, inline only |
| R21-02 | "16 of 23 rows" in `corpus/lessons/round-23.md:61` C2-before; exact old line only in git base | partial |
| R21-03 | literal 47 nowhere in the round-23 tree; note derives 40 + 7 (`claim-ledger.tsv:53`); 47 survives only in historical SCORECARD.md:685/:765, LOG.md:1040, SKILL.md:47 | absent/derived |
| R21-04 | literal 43 nowhere; note still points at the round-22 journal (`claim-ledger.tsv:54`), which records **39→43** (`pin-migrations-integration.json` `rewritten_claim_rows`.R21-04 old `^39$` new `^43$`) | absent + stale pointer |

R21-04 is the clean QM14 failure: 43→45 with the note pointing one epoch behind. The only
places the 43→45 pair is written are sibling audit prose
(`parent-build/ClaimR21X04.md:137-156`, `ClaimR11X01.md:187-188`), not a migration record.

## Defect 2 — R12-03 note/expectation inconsistency (introduced during this run)

At E2–E3 the row passes on the literal (`^79$` vs 79) but its note still justifies 70 and
its old value is unrecorded. This is the exact "expectation rewrite with no old-value
evidence" class QM14 names (`QUALITY.md:73`). A reader cannot tell from the row why 79 is
correct or what the previous value was; the uncommitted diff is the only evidence. The
row's own bound ("Count is pointer membership, not source currentness") does not excuse the
arithmetic mismatch.

## Defect 3 — stale-pin window during the re-pin; standing self-pin blind spot at E3

Independent recompute of all 79 `path sha256 lines bytes` records (Python, exit 0) across
the window:

- E1 (01:00–01:02): **9 stale, 0 missing** — exactly the 9 modified stamped files
  (claim-ledger.sh, claim-ledger.tsv, op-ref-consumption.md, sources-census.sh, SOURCES.md,
  surface-census.sh, LOG.md, SCORECARD.md, SKILL.md), with stamps byte-identical to base
  (`sha256sum /tmp/cl-base.tsv` = `e6806968…` = then stamps line 5; base SCORECARD =
  `96cf354a…` = then line 68).
- E2 (01:04:28): **1 stale** — `corpus/stamps.tsv:13` `corpus/claim-ledger.tsv`.
- E3 (01:05:50): **0 stale**; the re-pin completed (stamps sha `75c3e14915bf…`).

The transient state is still evidence: at 01:05:35 the record read
`f1a73f09…`/60/19506 while the live ledger was `0d3d7500…`/60/19558 — a 52-byte divergence
at identical line count, i.e. exactly the hash-only change R12-03's membership count cannot
see. Two durable points survive E3: (a) the re-pin changed 15 record values and added 9
rows with no QM14 `changed_stamp_records`/`removed_members` record, and (b)
`corpus/stamps.tsv` is not self-pinned (grep count 0), so no re-pin can make the file fully
self-consistent.

## Defect 4 — minor record-quality defects (persist at E3)

- `corpus/claim-ledger.tsv:29` (R13-01) repeats the identical sentence "Includes the
  preserved blocked round-20 attempt, which cells excludes from scored sections only;
  malformed actual scored headings still fail closed." twice (2 occurrences, stripped
  clauses equal at 101 bytes each). It also omits the 24-scored + 1-blocked split the
  parent audit requested.
- `SKILL.md:47` (live capability table) still says census "`--selftest` 47 cases"; the live
  gate reports 59. SKILL.md was edited this round (op-ref 29→36 only), so this is live
  text, not append-only history. Historical occurrences (SCORECARD.md:685/:765, LOG.md:1040)
  are epochs and need not change.

## Resolved during the run (recorded so it is not graded as current)

- E1's C2 wording defect — `corpus/lessons/round-23.md:165` and `SCORECARD.md:840` said
  "seven distinct URLs" for the 10 S017–S026 rows — is **corrected at E2**: lesson:169 and
  SCORECARD.md:840 now say "nine distinct URLs". My independent measurement agrees: 9
  distinct `url` strings and 9 distinct `final_url` (trailing slash stripped); S021 and
  S026 share `openbao.org/docs/concepts/tokens/`, S024 and S025 add new strings. The
  round-23 claim context given to this seat still says "7 URLs" and must not be restated
  as current.
- E1's "3 new artifacts unpinned" is resolved at E2: closure-dispositions.py/.json and
  source-fetches.tsv (plus round-23.md and the fixture files) are now stamped.

## Confirmations

- All five expectations match live measurement at E3; R21-02's expected line is byte-equal
  to the live census tail, not merely ERE-plausible.
- Only the named expectations moved versus base; `cmd`/`exit`/`timeout` untouched; additions
  are exactly R23-01/R23-02; 45 rows are 45 unique ids.
- R21-03's 59 is executed, not printed: 59 case lines, 12 `fetch-*` names, base has 0
  `SC_FETCH`; 47 = 40 + 7 per the note.
- R12-03's 79 equals the non-comment row count; the 9-row delta is accounted for by the 9
  new pinned paths; no path was removed (`removed_members` equivalent: 0).
- No expectation change is hidden in the working tree; every change is visible against the
  frozen base.

## Bounds the claim must state

1. No round-23 committed migration record exists (QM14). Old/new evidence for R12-03
   (70→79), R21-04 (43→45), R21-03 (47→59), R21-02 (23→26), R13-01 (25→27) is owed; the
   claim is pre-record unless integration lands it.
2. R21-04's "round-22 journal" pointer is stale by one epoch (that journal records 39→43).
3. R12-03's note still justifies 70 while the row expects 79; the old value is unrecorded.
4. The ledger pin was transiently stale during the re-pin (E1 9/79, E2 1/79, E3 0/79);
   `stamps.tsv` is not self-pinned. The claim must bind to the E3 stamp hash `75c3e149…`
   and state that the 15 re-pins + 9 additions landed without a QM14 stamp record.
5. C2 declared provenance is 10 rows over **nine** distinct URLs (the E2/E3 artifacts say
   nine; the wave context's "7" is wrong).
6. R13-01 remains pure cardinality: a duplicate/renumbered `## Round ` heading that
   preserves 27 passes. Its note is duplicated and omits the scored/blocked split.
7. `SKILL.md:47`'s 47-case text is stale against the 59-case gate.

## Not run (stated, so not credited)

- `bash corpus/claim-ledger.sh verify` — forbidden by the lane contract; stamp freshness
  was measured by independent sha256/line/byte recomputation instead.
- The 43 legacy row audits (including R14-01 `docs`, R22-03 revision audit) were not
  re-run.
- No network fetch; C2 digests themselves are other seats' target.

Confidence: every number and field above is directly observed at the cited command output,
path:line or hash. The E1–E3 window is wall-clock observed; the only inference is that the
stamp re-pin and lesson correction came from the concurrent integration owner (marked
[INFERENCE]). The missing migration record is observed at all three snapshots.
