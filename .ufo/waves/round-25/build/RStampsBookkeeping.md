# RStampsBookkeeping — round-25 bookkeeping checklist

Seat KagiR25.RStampsBookkeeping-2 (leaf, read-only lane). Base `4587c61a348e4528717404a68912c373f3ef4d03` (lane HEAD via `rev-parse`; `git status` not run). Sandbox `/fast/scratch/kagi-r25/RStampsBookkeeping-2`: clone at BASE plus scratch copies `sim`, `simB`, `simC`. No installs (python3 3.14.8, git 2.56.0 present). No op/host/vault/CDP row run; no `verify`/`cells` on the lane; no lane file edited.

## A. BASE measured (`env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`, each row's own cmd and expect)
- Every row a round-25 pin can move MATCHes: R12-03 `83`, R21-04 `61`, R13-01 `29`, R13-02 `35`, R14-01 `entries=25`, R21-02 `rows=32 … captures=32`, R22-03 `added=20`, R24-03..R24-16 (e.g. `ROW_IDENTITY: stamps count=83 sha256=136fde8b…b584`).
- SOURCES.md `recheck: on-release` = 28 = 25 mined + 1 queued + 2 rejected (awk over `NF==13`, col 11). C3's population includes non-mined rows.

## B. Checklist — self-counts.py/.tsv, release-clock.py/.tsv, round-25 lesson, ledger rows
1. Content before stamp. Pinned: claim-ledger.sh/.tsv, SOURCES.md, source-fetches.tsv, SKILL.md, SCORECARD.md, lessons/*, and each new file. Any later byte change is STALE (measured: one lesson edit gave `STALE corpus/lessons/round-25.md sha=5c43955d472e->d350379c24d8`).
2. Python gates: `PYTHON_SCRIPT_RE` (claim-ledger.sh:248) admits 4 scripts; `grep -cE 'self-counts|release-clock'` = 0 (control `closure-dispositions` = 2). Unregistered row → `POLICY R9-01 reason=python-script`, exit 2 (measured). Register in code and add a policy case (:1484-1492).
3. release-clock.py: offline check only in a ledger row; `--observe` (writes a receipt, reads feeds) must not be a row command. Policy reads command text only (:248-290). INFERENCE: a registered script can do anything once admitted.
4. self-counts.tsv / release-clocks.tsv: stamp (R12-03 +1, R24-05 digest). release-clocks must bind all 28 on-release rows, queued and rejected included.
5. Round-25 lesson: stamp (+1 pin). Its `source:` line must name every new S-id (sources-census.sh:229-231; measured `FINDING SC_USEDBY_NOCITE id=S033 path=corpus/lessons/round-25.md`, rc=1). Every R25-xx token must be a ledger row (idref; lessons in DOCS_LIST, claim-ledger.sh:679; measured `MISSING-ID corpus/lessons/round-25.md:7 R25-09`).
6. New feed S-rows: 11-column registry row, `mined`, used-by exactly `corpus/(knowledge|lessons)/<n>.md` (usedby_re :215); one 16-column `source-fetches.tsv` row per id (:252-287; measured `FINDING SC_FETCH id=S033 missing-provenance`, rc=1); never an in-row `Fetch sha256:` (:326, inrow-pin-not-historical).
7. New ledger rows: 6 columns (claim-ledger.sh:526), numeric exit (:529), positive timeout (:530), literal expect (:533), and no `[host]`/`[substrate]` text anywhere in the note (`is_host_note` :167; measured `HOST-SKIP R9-04 reason=host-row-not-authorized`).
8. Any new `## Round 25 — pre/post` section needs all six axes exactly once (claim-ledger.sh:855-866; tcase :1559).
9. Prose counts to re-measure: SKILL.md:46 "63 stamps + 39 claims" (BASE 83/61), :47 "70 cases"; PROVINCE.md:52 "declares 151 cases", :53 "70 cases"; corpus/README.md:33 "34 cases", :42 "22 rows", :43 "61 cases". Sentences dated "at round N" are outside C1's population.
10. Then re-stamp (§D), migrate (§E), and let the main agent run verify once.

## C. Rows that move (sandbox sim: +5 pins, +2 claim rows, +1 S-row, +2 SCORECARD headings; scratch values)
| row | BASE | sim | cause |
|---|---|---|---|
| R12-03 `^83$` | 83 | 88 | every new pin (`grep -c '[^[:space:]]'`) |
| R21-04 `^61$` | 61 | 63 | every new R-row |
| R24-14 ledger-ids | 61 `f8fe9874…` | 63 `04ae8747…` | new ids |
| R24-05 stamps | 83 `136fde8b…` | 88 `495c8e0e…` | membership; order-independent (C-order file still `136fde8b…`, measured) |
| R22-03 `added=20` | 20 | 25 | ADDED = pins outside c2cab35 (revision-audit.py:368-371, not failing :391); "reviewed" in the note is prose only |
| R24-15 revision-added | 20 `574d0da4…` | 25 `ca5003fa…` | the ADDED list |
| R21-02 census | rows=32 A=30 mined=29 captures=32 | rows=33 A=31 mined=30 captures=33 | per S-row; captures = fetch rows (sources-census.sh:317) |
| R13-01 `^29$`; R24-06 | 29; `18e0c4fd…` | 31; `1c4c227c…` | only if SCORECARD gets round-25 headings |
| R11-09 + R18-03 `151 cases` | 151 | not measured | both move together if the claim-ledger selftest gains cases (C2) |
| R21-03 `70 cases` | 70 | not measured | only if the sources-census selftest changes |
| R24-03,04,07-13,16; R13-02 `35`; R14-01; R18-02 `11` | — | identical | no R1x rows, no knowledge entry, no new substrate tag |

## D. Safe re-stamp (measured)
- Use `LC_ALL=en_US.UTF-8 bash corpus/claim-ledger.sh stamp --out <scratch> $(cut -f1 corpus/stamps.tsv) <new paths>`, review the diff, then install. Regenerating BASE's 83 paths gives `STAMPED: n=83` and `cmp` YES.
- `LC_ALL=C` moves 11 rows: claim-ledger.sh:418 `sort` inherits the caller's locale and never sets LC_ALL (row-identity.sh:39 and sources-census.sh:118 do).
- Guards: omitting a pinned path → `refusing to shrink … 'corpus/adjacency.tsv' is pinned and would be dropped`, rc=2 (:392-393); absent path → `not found: corpus/does-not-exist.py`, rc=2 (:407). Without `--out` the write goes in place (:419).

## E. Migration evidence round 24 kept (QM14: keep old and new)
- `.ufo/waves/round-24/expectation-migrations.json`: base `4f94b52`, per-row `motivation`, `migrations[]` = 28 `{id, expect:{old,new}, note}`: R11-09 121→140, R12-03 79→83, R13-01 27→29, R21-02 26→31 (superseded), R21-03 59→70, R21-04 45→61, R22-03 16→20, R24-01..16 (old null). R18-01/R18-02 hold null old/new (command-only edits; the old text is not kept).
- `.ufo/waves/round-24/recovery-migrations.json`: a second schema, `expectations[]{id,old,new,reason}` (R21-02 31→32, R24-01 20→22), plus `stamp_command` (83-path argv), `stamp_exit` 0, `stamp_stdout`, `dropped []`, `added []`, `tuples[{path,old,new}]` (sha, lines, bytes). Its policy line is "no stamp membership changes".
- Round 25 needs one file: the main schema, the recovery stamp block with `added` filled, old/new for every row in §C, and no supersession chain.

## F. Hazards
1. Locale-dependent stamp order (§D).
2. `verify --claims <file>` makes that file the id universe (`load_ids`, :761-771): subset runs printed 529 spurious MISSING-ID. Test idref only against the full ledger.
3. A prose tag in a note makes a row a host row (:167; round-24 M24-7, corpus/lessons/round-24.md:154).
4. `cells` is not refused when nested (:355 covers verify only). INFERENCE: a `ledger:` binding that re-enters cells or self-counts can recurse until timeouts; bind only to plain count rows.
5. corpus/README.md is scanned for ids and citations (:678), but no gate reads its index rows.

## G. Commands and exits
- Read-only: `bash corpus/row-identity.sh <selector>` (14 selectors) rc=0; `python3 corpus/revision-audit.py --history c2cab35bc92e…` rc=0; `bash corpus/sources-census.sh` rc=0.
- Stamp: en_US rc=0 (cmp YES); C-locale rc=0 (cmp NO, 11 rows moved); shrink rc=2; absent path rc=2.
- Sim (scratch): `_edit` added an S033 row and SCORECARD headings; `_write` added 5 files; restamp `STAMPED: n=88`; census rc=0 (`rows=33 A=31 … captures=33`); harness MISMATCH on R12-03, R13-01, R21-02, R21-04, R22-03, R24-05/06/14/15; MATCH on R13-02 and R25-01.
- Negatives: E1 rc=1 SC_FETCH; E2 rc=1 SC_USEDBY_NOCITE; E3 rc=2 POLICY; E4 HOST-SKIP; E5 MISSING-ID.
- Not run: op/op-ref/transcript/surface/drift rows, verify/cells on the lane, network. Installs: none.
