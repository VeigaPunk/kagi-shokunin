# ScoutMigration — round-23 expectation migrations (falsification seat)

Base: `d218603b74099ddca0bd8f869516fc41db0979bf`. Measured tree: uncommitted round-23
working tree. Read-only; no production edit, no `verify`, no host-bound row, no `.ufo/state`,
no MANIFEST read. All page/TSV text treated as data.

## What I attacked

The five expectation migrations named in the dispatch — R12-03, R13-01, R21-02, R21-03,
R21-04 — plus the QM14 old/new-record obligation and the count-preserving-edit blind spots
behind each count.

## Live re-measurement

| row | base `expect` (`d218603`) | working-tree `expect` | live value | result |
|---|---|---|---|---|
| R12-03 | `^70$` | `^70$` (unchanged) | 70 non-blank rows | matches |
| R13-01 | `^25$` | `^27$` | 27 `## Round ` headings | matches |
| R21-02 | `rows=23 A=21 … mined=21` | `rows=26 A=24 … mined=24` | exact tail line below | matches |
| R21-03 | `47 cases` | `59 cases` | 59 executed cases | matches |
| R21-04 | `^43$` | `^45$` | 45 rows, 45 unique ids | matches |

Commands and exits (run in `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

```
git show d218603…:corpus/claim-ledger.tsv > /tmp/cl-base.tsv          # exit 0
grep -c '^## Round ' SCORECARD.md                                     # exit 0 -> 27
git show d218603…:SCORECARD.md | grep -c '^## Round '                 # exit 0 -> 25
grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv                    # exit 0 -> 45
grep -c '[^[:space:]]' corpus/stamps.tsv                              # exit 0 -> 70
grep -cv '^[[:space:]]*#' corpus/stamps.tsv                           # exit 0 -> 70
bash corpus/sources-census.sh                                         # exit 0
bash corpus/sources-census.sh --selftest                              # exit 0
bash corpus/claim-ledger.sh --selftest                                # exit 0
```

Census tail, byte-identical to `corpus/claim-ledger.tsv:52` expectation:

```
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
```

Selftest tails: `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` (exit 0; 59 executed case lines,
12 of them `fetch-*`) and `SELFTEST: PASS (121 cases)` (exit 0; 121 executed `ok-case` lines,
so R18-03's unchanged `^121 cases$` still holds).

Independent arithmetic for R21-02: `corpus/SOURCES.md` has 26 rows; the `Fetch sha256:`
in-row pins are exactly S001–S016 (16), the `corpus/source-fetches.tsv` rows are exactly
S017–S026 (10), and their union covers all 26. Tier cells are 24 A / 2 C. Registry distinct
URLs: 18 at base, 19 now (base/current SOURCES.md, first URL per row). R13-01: 25 base
headings intact, exactly the two Round 23 headings added (`SCORECARD.md:824`, `:835`), no
removed heading; 14 distinct round numbers (Round 20 appears once as the blocked attempt,
the rest pre/post pairs). R13-02 (`^35$`) and R18-02 (`^11$`) still measure 35 and 11, so
the two added rows did not disturb their cohorts.

## No silently changed expectation

A field-level diff of every TSV row against the base copy (`cmd`, `expect`, `exit`,
`timeout`, note) reports exactly:

- changed `expect`: R13-01, R21-02, R21-03, R21-04 — all four named by the round;
- no change to any `cmd`, `exit` or `timeout` field in any surviving row;
- added: R23-01, R23-02 (`corpus/claim-ledger.tsv:59-60`);
- changed notes: R13-01, R21-01, R21-02, R21-03, R21-04 only;
- `corpus/claim-ledger.sh` diff is one allowlist token (`closure-dispositions`) at
  `PYTHON_SCRIPT_RE`; no last-line/ERE matching semantics changed.

So nothing was changed silently *in the ledger fields*. The defect is the missing QM14
record, not a hidden edit.

## Defect 1 — no round-23 migration record (QM14, primary)

`corpus/QUALITY.md:73` requires "a committed migration record with old/new values".
`plans/round-23.md:47-48` says the two executable TSV snapshots "are updated with old/new
migration records per QM14". The round-22 precedent is a real tracked file:
`git ls-files .ufo/waves/round-22/round21-migrations.json` → that path (232 round-22 wave
files tracked), referenced from `corpus/README.md:126`; its `rewritten_claim_rows` carries
full old and new TSV lines.

Round 23 has no equivalent:

```
find .ufo/waves/round-23 -maxdepth 3 -type f
# falsify-dispatch.err/.json, falsify-spec.json, falsify/swarm-registry.json,
# parent-build/*.md (audit prose), parent-build-spec.json, parent-build-dispatch.json,
# parent-build/swarm-registry.json  — no migrations/migration JSON, and the whole
# .ufo/waves/round-23/ tree is untracked (git status: "?? .ufo/waves/round-23/")
```

Per-row record status:

| row | old value preserved where | verdict |
|---|---|---|
| R13-01 | inline: "25 at round-22 close, plus round-23 pre/post" (`claim-ledger.tsv:29`); actually 25→27 | partial (inline only; no record file; note defect below) |
| R21-02 | old row count "16 of 23 rows" in `corpus/lessons/round-23.md:61` C2-before; exact old census line only in git base | partial |
| R21-03 | literal 47 appears nowhere in the round-23 tree; note gives 40 at c41af82 + seven = 47 (`claim-ledger.tsv:53`); old literal survives only in historical SCORECARD.md:685/:765, LOG.md:1040, SKILL.md:47 | absent/derived |
| R21-04 | literal 43 appears nowhere in round-23 docs; note still says "old/new value recorded in round-22 journal" (`claim-ledger.tsv:54`), but that journal records **39→43** (`pin-migrations-integration.json` `rewritten_claim_rows`.R21-04 old `^39$` new `^43$`) | absent + stale pointer |
| R12-03 | no value change (70→70) | no record needed for the count itself (but see Defect 2) |

R21-04 is the concrete QM14 failure: the expectation moved 43→45 with no round-23 old/new
value, and the note points one epoch behind. The only places the 43→45 pair is written are
sibling audit prose (`parent-build/ClaimR21X04.md:137-156`, `ClaimR11X01.md:187-188`), which
is analysis, not the required record.

## Defect 2 — R12-03 membership is count-only and the pins are stale (count-preserving blind spot)

`corpus/stamps.tsv` is byte-identical to the base (the file is absent from
`git diff d218603 -- corpus/stamps.tsv`), so membership is genuinely unchanged: 70 rows,
70 non-blank lines, 70 unique paths, 0 missing files. But an independent full recompute of
`path sha256 lines bytes` (Python sha256/line-count/byte-count over all 70 rows, exit 0)
finds **9 stale records and 0 missing**, and they are exactly the 9 files modified this
round:

| stamps.tsv line | path | old bytes → current |
|---|---|---|
| 4 | corpus/claim-ledger.sh | 1428/88425 → 1428/88480 |
| 5 | corpus/claim-ledger.tsv | e6806968… 58/17844 → 6fa0c24f… 60/19451 |
| 29 | corpus/knowledge/op-ref-consumption.md | 384/25991 → 385/26095 |
| 60 | corpus/sources-census.sh | 450/25950 → 613/36022 |
| 61 | corpus/SOURCES.md | 118/22843 → 121/24995 |
| 63 | corpus/surface-census.sh | 886/44212 → 887/44220 |
| 66 | LOG.md | 1178/83259 → 1221/85794 |
| 68 | SCORECARD.md | 96cf354a… 822/96871 → d3214edb… 862/100130 |
| 70 | SKILL.md | 742/64547 → 742/64547 (content changed, same size) |

The stamps file pins the *base* bytes exactly (`sha256sum /tmp/cl-base.tsv` =
`e6806968…` = stamps line 5; base SCORECARD sha = `96cf354a…` = stamps line 68), so this is
an unmigrated pre-integration state, not a re-pin.

Two ways this stays green while provenance moved:

1. R12-03 counts membership, so 9 stale pointers cannot fail it (the note's own bound:
   "Count is pointer membership, not source currentness").
2. Three round-23 corpus artifacts are uncited by stamps while being cited in-tree:
   `corpus/closure-dispositions.py`, `corpus/closure-dispositions.json` (R23-02 command,
   SCORECARD round-23 cells) and `corpus/source-fetches.tsv` (C2, SCORECARD.md:840/842).
   `corpus/README.md:65` says stamps cover "every cited in-repo artifact". Adding them
   would move R12-03; adding them plus dropping three others keeps 70 and the count green.
   The plan's "stamps updated with old/new migration records" did not happen at all in this
   tree.

## Defect 3 — C2's "ten rows over seven distinct URLs" is false

`corpus/lessons/round-23.md:165` ("10 declared provenance rows (S017-S026) over seven
distinct URLs") and `SCORECARD.md:840` ("S024-S026 are correction rows over seven distinct
URLs") — and the wave context given to this seat — state seven. Measured from
`corpus/source-fetches.tsv` column 4 (`url`) and column 5 (`final_url`):

```
awk -F'\t' '$1 ~ /^S0/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l   # 9
awk -F'\t' '$1 ~ /^S0/ {u=$5; sub(/\/$/,"",u); print u}' … | sort -u | wc -l   # 9
```

Nine distinct URL strings: S021 and S026 share `openbao.org/docs/concepts/tokens/`; S024
(kv-v2) and S025 (openbao auth/jwt) are additional strings. Seven is the S017–S023 row
count, not the file's URL count. R21-02's expectation is unaffected (the census counts
registry rows), but the claim's declared provenance arithmetic must say nine, or say
"seven reopened rows".

## Defect 4 — minor record-quality defects

- `corpus/claim-ledger.tsv:29` (R13-01) repeats the identical sentence
  "Includes the preserved blocked round-20 attempt, which cells excludes from scored
  sections only; malformed actual scored headings still fail closed." twice (two
  occurrences; stripped clauses equal at 101 bytes each). No content lost versus base, but
  it is not a clean QM14 note, and it still omits the 24 scored + 1 blocked split the parent
  audit asked for.
- `SKILL.md:47` (live capability table) still advertises "`--selftest` 47 cases" for
  `corpus/sources-census.sh`; the live gate reports 59. SKILL.md *was* edited this round
  (only the op-ref 29→36 correction), so this stale count is live text, not append-only
  history. Historical occurrences (SCORECARD.md:685/:765, LOG.md:1040) are epochs and need
  not change.

## Confirmations

- All five live counts match their working-tree expectations exactly; R21-02's expected
  line is byte-equal to the live tail, not merely ERE-plausible.
- Only the four named expectations moved; `cmd`/`exit`/`timeout` are untouched everywhere;
  the two additions are exactly R23-01/R23-02; 45 rows are 45 unique ids (no dup).
- R21-03's delta is real: 59 executed cases, 12 `fetch-*` case names, and the base
  `sources-census.sh` contains zero `SC_FETCH` occurrences (grep exit 1, count 0). 47 is
  exactly 40 + 7 per the row note.
- R12-03's 70 equals the non-comment row count and membership did not move.
- No expectation change is hidden: every change is visible against the frozen base.

## Bounds the claim must state

1. Round-23 has **no committed migration record**; QM14 old/new evidence for R21-04
   (43→45), R21-03 (47→59), R21-02 (23→26) and R13-01 (25→27) must land with integration,
   or the claim must be labelled pre-integration with the record owed.
2. R21-04's "round-22 journal" pointer is stale by one epoch (that journal records 39→43).
3. R12-03 proves membership only; it cannot see 9 stale pins or 3 uncited new artifacts.
   Stamps re-pin plus a `changed_stamp_records`-style record is still owed.
4. C2 declared provenance is 10 rows over **nine** distinct URLs, not seven.
5. R13-01 remains a pure cardinality check: a duplicate or renumbered `## Round ` heading
   that preserves 27 passes. Its note is duplicated and does not state the scored/blocked
   split.
6. `SKILL.md:47`'s 47-case text is stale against the 59-case gate.

## Not run (stated, so not credited)

- `bash corpus/claim-ledger.sh verify` — forbidden by the lane contract; stamp freshness
  was measured by independent recomputation instead.
- The 43 legacy row audits (including R14-01 `docs`, R22-03 revision audit) were not
  re-run.
- No network fetch; the C2 digests themselves are other seats' target.

Confidence: every numeric/field claim above is directly observed at the cited path:line or
command output. The only inference is the intent that stamps re-pinning belongs to
integration (marked [INFERENCE]); the measured absence of any record is observed.
