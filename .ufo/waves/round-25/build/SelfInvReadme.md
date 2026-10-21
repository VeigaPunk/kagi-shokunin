# SelfInvReadme — C1 current-tense self-counts (round-25 build)

Scope: `README.md` (14 lines, no count claims) and `corpus/README.md` (166 lines). Read-only; no lane file edited.
Revision: BASE `4587c61a348e4528717404a68912c373f3ef4d03` (lane HEAD; real tree = BASE plus untracked `.ufo/waves/round-25/`, `plans/round-25.md`). Live values: lone clone `/fast/scratch/kagi-r25/SelfInvReadme/lane` at BASE.
Legend: CUR = undated registry/decision text a reader would act on today. HIST = dated in-row, by header (`read 2026-09-28`), or by the file's own correction; not scored. UNVERIFIED = needs a host-reading mode (not run) or is interpretive; never counted as stale.

| file:line | phrase | CUR/HIST | claimed | live | source | STALE? |
|---|---|---|---|---|---|---|
| corpus/README.md:33,34 | 8 columns (checklist schema) | CUR | 8 | 8 (16 data rows, NF=8) | awk NF on checklist.tsv | no |
| corpus/README.md:33 | bijection over the 16 items | CUR | 16 | 16 (SKILL.md:434-456 `- [ ]`=16; `--list` rows=16) | R15-03 | no |
| corpus/README.md:33 | `--selftest` (34 cases) | CUR | 34 | 34 | R15-02 | no |
| corpus/README.md:33 | items=16 runnable=9 by_hand=7 failed=0 | CUR | 16/9/7/0 | 16/9/7 match; failed=0 UNRUN (R15-01 runs host gates E1/E5/H7) | R15-03, R15-01 | UNVERIFIED |
| corpus/README.md:33 | runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6 | CUR | 9/16,8,7,3,6 | same | R15-05 | no |
| corpus/README.md:34 | competing `3/13` and `8/8` readings | HIST (round-15 alternative readings, checklist-execution.md:92-97) | 3/13; 8/8 | not a live measure; shipped ratio is 9/16 | — | n/a |
| corpus/README.md:34 | 12 bounds | CUR | 12 | 12 (checklist-execution.md:113-166) | count | no |
| corpus/README.md:34 | 10 falsifiers | CUR | 10 | 10 (checklist-execution.md:173-191) | count | no |
| corpus/README.md:36 | `--selftest` (13 cases) | CUR | 13 | 13 | R11-05 | no |
| corpus/README.md:37 | 15 cited host files | CUR | 15 | 15 rows | grep -cv '^#' drift-baseline.tsv | no |
| corpus/README.md:37 | 6 private 0600 files carry `-` | CUR | 6 | 6 (all mode 600) | awk $4=="-" | no |
| corpus/README.md:38 | 20 content claims | CUR | 20 | 20 rows | grep -cv '^#' drift-symbols.tsv | no |
| corpus/README.md:39 | 13-case selftest evidence | CUR | 13 | 13 | R11-05 | no |
| corpus/README.md:40 | 4 enumerable dirs | CUR | 4 | 4 `# scan` (surface-census.tsv:17-20) | grep -c '^# scan' | no |
| corpus/README.md:40 | `--selftest` (16 cases) | CUR | 16 | 16 | R11-03 | no |
| corpus/README.md:41 | 35 rows | CUR | 35 | 35 | R11-11 | no |
| corpus/README.md:41 | (20 asset / 15 runtime) | CUR | 20/15 | 20/15 | awk class column | no |
| corpus/README.md:41 | 4 `# scan` directives | CUR | 4 | 4 | grep -c | no |
| corpus/README.md:41 | one `mode = -` row | CUR | 1 | 1 (surface-census.tsv:52) | awk $4=="-" | no |
| corpus/README.md:42 | 22 rows | CUR | 22 | 22 | R11-10 | no |
| corpus/README.md:43 | `--selftest` (61 cases) | CUR | 61 | 61 | R16-02 | no |
| corpus/README.md:43 | `--falsify` (18/18 mutations) | CUR | 18/18 | UNRUN (host-measuring mode); declared 9+9 | R16-03 | UNVERIFIED |
| corpus/README.md:44 | 5 owned prefixes | CUR | 5 | 5 | R16-04 | no |
| corpus/README.md:44 | 27/35 census rows | CUR | 27/35 | 27/35 static prefix match (gate verdict R16-01 UNRUN) | awk over surface-census.tsv, adjacency.tsv | no |
| corpus/README.md:44 | 4 shared groups (8 rows) | CUR | 4/8 | 4 group rows; 35-27=8 | R16-05 | no |
| corpus/README.md:44 | 8 no-enumerate boundaries | CUR | 8 | 8 | R16-06 | no |
| corpus/README.md:44 | 4 derived leaf breadth pins | CUR | 4 | 4 | R17-02 | no |
| corpus/README.md:44 | live leaf ratios 20/4, 105/2, 4/1, 53/1 | HIST (:138-139 "historical 2026-09-29") | same | equal committed pins (adjacency.tsv:75-78); host UNRUN | R17-01 | n/a |
| corpus/README.md:46 | 13 bounds | CUR | 13 | **9** numbered Bounds (adjacency-breadth.md:116-137); 13 = failure-token rows (:88-95) | count | **STALE** |
| corpus/README.md:46 | 18 mutation classes | CUR | 18 | 18 declared (adjacency-breadth.md:158); run UNRUN | R16-03 | UNVERIFIED |
| corpus/README.md:48 | 10 probes | CUR | 10 | 7 default (surface-census.md:150-156) + 3 `--deep` (:158-160) | count | no |
| corpus/README.md:48 | 11 falsifiers | CUR | 11 | 11 (surface-census.md:270-288) | count | no |
| corpus/README.md:54 | 32+5 patterns | CUR | 32+5 | 32+5 (transcript-scan.sh:83-96) | eval of array, count | no |
| corpus/README.md:54 | 5 credential-table tripwires | CUR | 5 | 5 (transcript-scan.sh:66) | count | no |
| corpus/README.md:54 | 888 cells | CUR | 888 | host DB, UNRUN; script comment dates it 2026-09-28 (transcript-scan.sh:76) | transcript-scan default (R11-06) | UNVERIFIED |
| corpus/README.md:63 | `--selftest` 97 cases | CUR | 97 | **151** (run PASS) | R11-09 (R18-03) | **STALE** |
| corpus/README.md:63 | five citation classes + brace sets | CUR | 5 | 5 classes (claim-ledger.sh:609-617) + brace sets | static | no |
| corpus/README.md:66 | six classes | CUR | 6 | 6 (knowledge/claim-ledger.md Class 1-6) | heading count | no |
| corpus/README.md:66 | the three audit teeth | CUR | 3 | no literal "three"; "The teeth" bullet (claim-ledger.md:183-189) names 2; re-resolve = MISSING-ID (:218) | static | UNVERIFIED |
| corpus/README.md:66 | 30 bounds | CUR | 30 | 30 (claim-ledger.md:310-455) | count | no |
| corpus/README.md:67 | 21 row-linked / 3 by-hand / 24 pinned at round 21 | HIST (round 21) | 21/3/24 | 22/3/25 (25 entries) | R14-01 (not run: docs re-runs host rows) | n/a |
| corpus/README.md:67 | floor is `ceil(24/2) = 12` | CUR | 12 | **13**: claim-ledger.sh:1108 `(DA_N+1)/2`, DA_N=25 | static; R14-01 expects entries=25 | **STALE** |
| corpus/README.md:69 | `--selftest` (36 cases) | CUR | 36 | 36 (op logging stub; 0 stub calls) | R12-02 | no |
| corpus/README.md:69 | four POLICY-bypass cases | CUR | 4 | 4 `policy_case` (op-ref-probe.sh:708-711) | count | no |
| corpus/README.md:74 | 5 bounds | CUR | 5 | 5 (substrate-deferral.md:59-74) | count | no |
| corpus/README.md:116 | 21 entries lack source/verified-at/recheck | CUR | 21 | 21 lack source; 21 lack verified-at; 21 lack recheck; 21 lack all three | grep -L '^source:' corpus/knowledge/*.md, then wc -l | no |
| corpus/README.md:19,22 | host line counts 333 / 117 / 88 | HIST (table "read 2026-09-28") | 333/117/88 | equal drift-baseline.tsv:1,2,10; host UNRUN | — | n/a |
| corpus/README.md:64,65 | 39 ledger rows / 63 stamp rows at round 21 | HIST | 39 / 63 | 61 claim ids (R21-04); 83 stamp rows (R12-03) | R21-04, R12-03 | n/a |
| corpus/README.md:35,47,62,68,71,73,75,104,126,145 | round-dated lesson/record counts, rounds 10-22 | HIST | — | not scored | — | n/a |

**CURRENT stale claims: 3** — :46 "13 bounds" (live 9); :63 "`--selftest` 97 cases" (live 151); :67 "floor is ceil(24/2) = 12" (live 13). Of 43 CURRENT rows: 35 match, 3 stale, 5 unverified.

Findings
- Calibration: the 3 stale rows are the routed D1 class inside this doc. Two bind to existing rows (R11-09 expects 151; R14-01 pins entries=25). :46 has no row and contradicts its own correction at :128-131 (13 is the failure-token count; numbered Bounds = 9).
- C1 binding gap: 20 of 43 CURRENT rows carry a ledger row. The other 23 (bounds, falsifiers, probes, classes, pattern arrays, file-internal counts) have none; `rows:<path>` (non-blank lines) cannot count numbered items inside a section. C1 needs section-scoped locators or new rows.
- Operability: `op-ref-probe.sh --selftest` needs an `op` resolvable on PATH. With none, `janitor-binary-missing` returns `OP_REF_PROBE: SETUP (op binary not found: op)` (op-ref-probe.sh:483-484 precedes the janitor check at :485): 1 of 36 FAIL. A logging stub restores PASS (36 cases). Environment dependence, not a count defect.
- Freshness: all host-only figures (888 cells; 333/117/88 lines; leaf ratios) are pinned or dated, never live-checked from the lone clone.

Commands (all `env -i PATH=$S/bin HOME=$S/home`, `S=/fast/scratch/kagi-r25/SelfInvReadme`; `$S/bin` = /usr/bin symlinks minus op, plus a logging `op` stub that never execs; cwd = lane clone)
- `bash corpus/checklist-run.sh --selftest` -> `CHECKLIST_SELFTEST: PASS (34 cases)` exit 0
- `bash corpus/checklist-run.sh --list` -> `CHECKLIST_LIST: rows=16 runnable=9 by_hand=7` exit 0; `--ratio` -> `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` exit 0
- `bash corpus/drift-pins.sh --selftest` -> `DRIFT_SELFTEST: PASS (13 cases)` exit 0; `bash corpus/surface-census.sh --selftest` -> `SELFTEST: PASS (16 cases)` exit 0
- `bash corpus/scope-gate.sh --selftest` -> `SCOPE_SELFTEST: PASS (61 cases)` exit 0; `bash corpus/claim-ledger.sh --selftest` -> `SELFTEST: PASS (151 cases)` exit 0
- `bash corpus/op-ref-probe.sh --selftest` -> `OP_REF_SELFTEST: PASS (36 cases)` exit 0; stub-op invocations 0
- Pass 1 ran the first six with PATH=/usr/bin:/bin (contains /usr/bin/op): no op output. Pass 2 op-free reproduced all six line-identical (cmp). Pass-2 exit file omitted the op-ref line; superseded by the stub run above.
- Static: grep -cv '^#', grep -c, awk NF and $4; `grep -L '^source:' corpus/knowledge/*.md | wc -l` = 21; `sed -n 83,95p transcript-scan.sh` = 32 hits; line 96 = 5 warns; line 66 = 5 tables.
- UNRUN (host-reading or substrate, excluded by rule): checklist default (R15-01); scope-gate default/--breadth/--falsify (R16-01, R17-01, R16-03); drift default (R11-04, R18-01); transcript-scan default (R11-06); docs (R14-01); citations (R11-08); cells (R13-03); census default/--verbs (R11-01/02).
- Installs/updates: none. Real lane: read tool plus read-only `git rev-parse` and `git status`; no writes except this file.
- Lane state observed: untracked `corpus/__pycache__/` (`rendered-text-v1.cpython-314.pyc`, mtime 07:38:17) appeared after my first status (no pycache then). My real-tree commands executed no Python; all Python ran in the sandbox, which has no pycache. Left untouched; owner unknown (likely a sibling seat).
