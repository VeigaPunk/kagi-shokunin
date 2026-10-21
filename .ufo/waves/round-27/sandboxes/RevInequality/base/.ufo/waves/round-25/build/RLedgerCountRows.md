# RLedgerCountRows — C1 doc-count binding reuse check (round-25 build)

Seat KagiR25.RLedgerCountRows-2 · leaf, no subagents · 2026-10-21 · BASE 4587c61a348e4528717404a68912c373f3ef4d03. Lane SKILL.md, README.md, PROVINCE.md, corpus/README.md, corpus/claim-ledger.{tsv,sh}, corpus/stamps.tsv are `cmp`-identical to BASE. Sandbox `/fast/scratch/kagi-r25/RLedgerCountRows/lane` (clone @BASE); ledger rows run as argv, cwd=lane, `env -i`-style `PATH=/usr/bin:/bin HOME=<sandbox>/home`. Lane writes: this file only. Not run: `verify`, `cells`, any op/handler/CDP/vault action. Tools installed: none. Host: `test -x $HOME/.local/bin/the-janitor` → absent (2026-10-21); claim-ledger.sh:157-163 defines substrate presence this way.

## 1. Verdict
- README.md has no digit lines (14 lines). PROVINCE.md 82 lines, corpus/README.md 166, SKILL.md 778; every digit line read, truncated rows read raw.
- 55 current-tense count locators tested (doc regex must match exactly one line; group = doc value): **41 OK · 4 STALE · 8 HOST · 2 UNRUN**; 0 ambiguous, 0 unlocated after anchor fixes.
- **STALE: 4 numbers on 3 lines (plan names only SKILL.md:46):**
  - SKILL.md:46 `63 stamps` → R12-03 = 83; `39 claims` → R21-04 = 61
  - SKILL.md:243 `# 97 scratch cases` → R11-09 = 151 (not in plan)
  - corpus/README.md:63 `` `--selftest` 97 cases `` → R11-09 = 151 (not in plan)

## 2. Binding proposal — ledger row (extract regex, one group) ← doc locators (doc regex, one group) [doc≠live | doc=live]
R12-03 `grep -c '[^[:space:]]' corpus/stamps.tsv` · `^(\d+)$` ← SKILL.md:46 `\((\d+) stamps \+ \d+ claims` [63≠83]
R21-04 `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` · `^(\d+)$` ← SKILL.md:46 `stamps \+ (\d+) claims \+ claim ids` [39≠61]
R11-09 `claim-ledger.sh --selftest` · `^SELFTEST: PASS \((\d+) cases\)` ← SKILL.md:243 `--selftest # (\d+) scratch cases` [97≠151]; corpus/README.md:63 `` `--selftest` (\d+) cases; POLICY refuses `` [97≠151]; PROVINCE.md:52 `declares (\d+) cases \(121 at round 23` [151=151]
R21-03 `sources-census.sh --selftest` · `^SOURCES_CENSUS_SELFTEST: PASS \((\d+) cases\)$` ← SKILL.md:47 `` `--selftest` (\d+) cases; read-only `` [70=70]; PROVINCE.md:53 `proves (\d+) cases \(40 at first landing` [70=70]
R11-05 `drift-pins.sh --selftest` · `^DRIFT_SELFTEST: PASS \((\d+) cases\)$` ← SKILL.md:181 `fires \((\d+) cases\)` [13=13]; corpus/README.md:36 `` `--selftest` \((\d+) cases: content `` [13=13]; corpus/README.md:39 `(\d+)-case selftest evidence` [13=13]
R15-05 `checklist-run.sh --ratio` · `runnable=(\d+)/` · `/(\d+) floor=` · `floor=(\d+)` · `by_hand=(\d+)` ← SKILL.md:41 `CHECKLIST_RATIO: runnable=(\d+)/16 floor=8` [9=9]; `runnable=9/(\d+) floor=8` [16=16]; `runnable=9/16 floor=(\d+) by_hand=7` [8=8]; `floor=8 by_hand=(\d+)` [7=7]; SKILL.md:426 (\d+) items carry [9=9]
R15-04 `grep -cE '^[EH][0-9]+[[:space:]]' corpus/checklist.tsv` · `^(\d+)$` ← SKILL.md:41 `CHECKLIST_RUN: CLEAN \(items=(\d+) ` [16=16, proxy rows=items]; PROVINCE.md:50 `bijection over the (\d+) items` [16=16]; corpus/README.md:33 `bijection over the (\d+) items both ways` [16=16]
R15-02 `checklist-run.sh --selftest` · `^CHECKLIST_SELFTEST: PASS \((\d+) cases\)$` ← PROVINCE.md:50 `proves (\d+) cases on scratch fixtures` [34=34]; corpus/README.md:33 `` `--selftest` \((\d+) cases\); `` [34=34]
R11-11 `grep -cv '^#' corpus/surface-census.tsv` · `^(\d+)$` ← SKILL.md:35 `partitions the (\d+) census rows` [35=35]; SKILL.md:140 `Declared vs undeclared\.\*\* (\d+) rows` [35=35]; PROVINCE.md:51 `prints all (\d+) row assignments` [35=35]; corpus/README.md:41 `(\d+) rows \(20 asset / 15 runtime\)` [35=35]; corpus/README.md:44 `\(\d+/(\d+) census rows\)` [35=35]
R11-10 `grep -cv '^#' corpus/state-shape.tsv` · `^(\d+)$` ← corpus/README.md:42 `(\d+) rows \(count pinned by ledger row` [22=22]
rows:corpus/drift-symbols.tsv (non-blank non-# lines; no ledger row needed) ← SKILL.md:186 `shape\]`, (\d+) rows\.` [20=20]; PROVINCE.md:47 `drift-symbols\.tsv` \((\d+) claims` [20=20]; corpus/README.md:38 `(\d+) content claims` [20=20]
rows:corpus/drift-baseline.tsv ← PROVINCE.md:47 `drift-baseline\.tsv` \((\d+) files\)` [15=15]; corpus/README.md:37 `(\d+) cited host files` [15=15]
R16-02 `scope-gate.sh --selftest` · `^SCOPE_SELFTEST: PASS \((\d+) cases\)$` ← PROVINCE.md:51 `` `--selftest` proves (\d+) cases; `--falsify` `` [61=61]; corpus/README.md:43 `` `--selftest` \((\d+) cases\), `--falsify` `` [61=61]
R16-04 `grep -cE '^# own…' corpus/adjacency.tsv` · `^(\d+)$` ← PROVINCE.md:51 `declares (\d+) owned prefixes` [5=5]; corpus/README.md:44 `(\d+) owned prefixes \(27/35` [5=5]
R16-05 `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv` · `^(\d+)$` ← PROVINCE.md:51 `(\d+) shared groups \(8 rows\)` [4=4]; corpus/README.md:44 same anchor [4=4]
R16-06 `grep -cE '^# no-enumerate…' corpus/adjacency.tsv` · `^(\d+)$` ← PROVINCE.md:51 `(\d+) no-enumerate boundaries and` [8=8]; corpus/README.md:44 `(\d+) no-enumerate boundaries, 4` [8=8]
R17-02 `grep -cE '^# breadth…' corpus/adjacency.tsv` · `^(\d+)$` ← PROVINCE.md:51 `(\d+) derived leaf breadth pins\. Default` [4=4]; corpus/README.md:44 `(\d+) derived leaf breadth pins; \`path` [4=4]
R24-01 `rendered-text-v1.py --selftest` · `^RENDERED_TEXT_V1_SELFTEST: PASS \(cases=(\d+)\)$` ← SKILL.md:750 `R24-01, (\d+) cases\)` [22=22]; PROVINCE.md:54 `` `--selftest` (\d+) cases, including two malformed-tag `` [22=22]
R24-02 `closure-dispositions.py --selftest` · `^CLOSURE_DISPOSITIONS_SELFTEST: PASS \((\d+) cases\)$` ← SKILL.md:749 `R24-02, (\d+) cases\)` [14=14]; PROVINCE.md:55 `declares (\d+) isolated cases` [14=14]
R21-02 `sources-census.sh` · `legacy=(\d+)` (no new row) ← corpus/README.md:116 `(\d+) existing knowledge entries lack` [21=21; independent `^source:` count = 21]
HOST (C1 must DEFER) R11-03 `surface-census.sh --selftest` · `^SELFTEST: PASS \((\d+) cases\)$` ← SKILL.md:36 `--deep` = 10 probes / 0 skips; `--selftest` proves (\d+) cases [16]; SKILL.md:138 `both fire \((\d+) cases\)` [16]; PROVINCE.md:46 `proves (\d+) cases on a scratch tree` [16]; corpus/README.md:40 `--selftest` \((\d+) cases\) (row end) [16]
HOST R12-01 `op-ref-probe.sh` · `checks=(\d+)` ← SKILL.md:33 `exit 0 \`OP_REF_PROBE: CLEAN \(checks=(\d+) ` [44]; SKILL.md:31 `` `op run` injects (\d+) keys `` [12]
HOST R17-01 `scope-gate.sh --breadth` · `children=(\d+)` ← SKILL.md:35 `children=(\d+) declared=8` [182]
HOST R16-01 `scope-gate.sh` · `owned=(\d+)` ← corpus/README.md:44 `\((\d+)/35 census rows\)` [27]
UNRUN (op binary, §5.4) R12-02 `op-ref-probe.sh --selftest` · `^OP_REF_SELFTEST: PASS \((\d+) cases\)$` ← PROVINCE.md:49 `proves (\d+) cases \(comparator` [36]; corpus/README.md:69 `\((\d+) cases incl\. the four POLICY-bypass` [36]

## 3. Pinned-count ledger rows → extract regex → live value (44 rows re-run; `ALL_CATALOGUE_OK`)
- `^(\d+)$`: R11-10 22 · R11-11 35 · R12-03 83 · R13-01 29 · R13-02 35 · R15-04 16 · R16-04 5 · R16-05 4 · R16-06 8 · R17-02 4 · R17-03 8 · R18-02 11 · R21-04 61
- `^<NAME>: PASS \((\d+) cases\)$`: R11-05 13 · R11-09 151 and R18-03 151 (no trailing `$` in R11-09) · R15-02 34 · R16-02 61 · R21-03 70 · R24-02 14. Other shapes: R24-01 `^RENDERED_TEXT_V1_SELFTEST: PASS \(cases=(\d+)\)$` 22 · R22-02 `^FEATURE_CLAIMS_SELFTEST: PASS cases=(\d+)$` 12 · R22-04 `^REVISION_AUDIT_SELFTEST: PASS \(cases=(\d+) failed=0\)$` 17
- key=value: R14-01 `entries=(\d+)` 25 · R15-03 `rows=(\d+)` 16 / `runnable=(\d+)` 9 / `by_hand=(\d+)` 7 · R15-05 `runnable=(\d+)/` 9 / `/(\d+) floor=` 16 / `floor=(\d+)` 8 / `by_hand=(\d+)` 7 / `delegated=(\d+)` 3 / `direct=(\d+)` 6 · R21-02 `legacy=(\d+)` 21 / `rows=(\d+)` 32 / `entries_sourced=(\d+)` 4 · R22-01 `admitted=(\d+)` 4 · R22-03 `added=(\d+)` 20 · R23-02 `obligations=(\d+)` 15 · R24-03..R24-16 `^ROW_IDENTITY: \S+ count=(\d+) ` 22,35,83,29,35,16,5,4,8,4,11,61,20,17
- Not executed, pinned value from expect: R11-03 16 [HOST] · R15-01 16/9/7 [HOST] · R16-01 35/27/8/4 [HOST] · R16-03 18 [HOST] · R17-01 182/8/174 [HOST] · R11-06 HITS=2 exit 1 [HOST] · R13-03 cells [HOST] · R12-02 36 [UNRUN op] · R21-01 6 [UNRUN op; untagged]. Range-only: R11-01, R11-02, R11-04, R12-01 [HOST]. R11-08 pins `unresolved=0`; it fails in a lone clone (§6).

## 4. Doc numbers with no ledger source (not bound)
- SKILL.md: :36 `10 probes / 0 skips` (--deep) · :162 `7 probes` · :118 `11 tables` · :146-148 floors `12/20`, `2/13/18/79`, `1/3` · :79 `3 keys` · :99 `7 sessions/39 msgs/55 parts` · :389-399 `9 provider defs`, `23 agents`, `56 permission rules`, `8 daemon starts` · :359-362 `eight of the line shapes` (word; host R12-01 divergent=5 disagrees unless units differ) · :141 `Four dirs` (word; live `# scan` = 4)
- corpus/README.md: :33 `8 columns` (live 8) · :34 `12 bounds`, `10 falsifiers` · :37 `6 private 0600 files` (live 6) · :41 `4 # scan directives` (live 4) · :46 `13 bounds`, `18 mutation classes` · :48 `10 probes`, `11 falsifiers` · :50 `9 providers, 23 agents` · :51 `8 runs since 2026-08-29` · :52 `162 routes`, `51 ms` · :66 `30 bounds` · :69 `six error signatures` (word) · :96 `24/14/9/2 files` (other lanes)
- Host-gated, no C1 path: corpus/README.md:54 `888 cells`, `32+5 patterns`, `5 credential-table tripwires`; PROVINCE.md:8 `20 asset / 15 runtime` (kind column counts 20/15; printed only by host-gated R11-01)
- Exempt by date/round (not enumerated): SKILL.md:65, :184, :251-255, :434 (`as of round 12`), :568-778 `Round-N:` bullets; PROVINCE.md:8 header date, :10 erratum, :20-37 host surfaces; corpus/README.md:4-7, :19-22, :55, :63-68 (`at round 21/24`).
- Dated conflict: SKILL.md:124 `Baseline 2026-09-28: 0 HIT / 4 WARN` vs R11-06 `HITS=2` for the same 2026-09-28 baseline.

## 5. Findings (calibration · operability · freshness)
1. Population rule is under-specified. The plan exempts LOG/lessons/SCORECARD only, so SKILL.md's `Round-N:` bullets enter population and go stale: SKILL.md:607 `(files=15 symbols=19)` (live 20), :631 `SELFTEST: PASS (39 cases)` (live 151), :652 `entries=17` (live 25). SKILL.md:46 is current guidance with a bare round tag. Proposed rule: exempt only sentences with `at|as of|after|until round N`, a `Round-N:` label, a `YYYY-MM-DD` observation, or "historical". Then SKILL.md:46 is in, corpus/README.md:63-68 and SKILL.md:251 are out.
2. Before-state is stale=4 on 3 lines, not "≥1 at SKILL.md:46". After-state needs all four fixed (§1).
3. Host-gated locators (8) need a DEFER state. Host/substrate rows are HOST-SKIP by default (claim-ledger.sh:554-556) and DEFER when the substrate is absent even with `--allow-host-rows` (:558-560). The plan's exit map (OK/STALE/UNLOCATED/AMBIGUOUS; 0/1/2) has no such state; propose `DEFERRED n=…`, never CLEAN.
4. "Non-host" is unsafe as defined. claim-ledger.sh:179-180 classes `op-ref-probe.sh --selftest|--dotenv-bytes` host-free, so R12-02 and R21-01 count as non-host. R21-01 runs the installed `op` binary (`op run --env-file` under env -i): a C1 that runs untagged rows would execute op on the operator host. Needs an explicit allow-list. Not run here.
5. Expressiveness: `rows:` counts non-blank non-# lines only; it cannot express a split (20 asset/15 runtime), a filter (6 `-` sha rows), or a pipeline (`grep -L … | wc -l`). Word-form counts (SKILL.md:140 "Four", :361 "eight", corpus/README.md:69 "six") are invisible to digit regexes. corpus/README.md:116 needed no new row: R21-02 `legacy=21` pins it.
6. Anchor uniqueness is fragile: 3 first-draft locators matched 2 lines (SKILL.md:35/36 both carry "`--selftest` proves … cases"; SKILL.md:33 repeats in the Round-12 bullet). Context anchors fixed them; self-counts.py should refuse AMBIGUOUS at table-build time. Suggested TSV shape: `doc<TAB>doc_regex(1 group)<TAB>source(ledger:ID|rows:PATH)<TAB>ledger_regex(1 group)`.
7. Freshness: the date exemption hides a live contradiction (SKILL.md:124 vs R11-06, same 2026-09-28 baseline). Needs revision tags, not dates alone.
8. Ledger hygiene (minor): R14-01 expect lacks a closing `\)$` (prefix-only match); claim-ledger.tsv:3 says "fifth column" for the exit code, which is column 4.
9. Operability: all 41 OK bindings are host-free and total about 8 s (R16-02 6.3 s, R18-03 3.4 s, R11-09 3.1 s). C2 corroboration: lone-clone `citations` (R11-08) gives unresolved=88, matching the plan's premise.

## 6. Exact outputs (sandbox @BASE, cwd=lane)
`grep -c '[^[:space:]]' corpus/stamps.tsv` → `83` rc0 · `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → `61` rc0
`bash corpus/claim-ledger.sh --selftest` → `SELFTEST: PASS (151 cases)` rc0 3.1 s
`bash corpus/checklist-run.sh --ratio` → `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` rc0
`bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=32 … legacy=21 … inrow_nonreproducing=12)` rc0
`bash corpus/claim-ledger.sh citations` → `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)` rc1 52.6 s (lone clone)
Ledger runner: 61 rows = 46 run (45 PASS, R11-08 FAIL rc1) + 12 host/substrate HOST-SKIP + 3 excluded (R12-02, R21-01 op; R23-01 cells). Catalogue: 44 pinned rows re-run → `ALL_CATALOGUE_OK`. Binding test: 55 locators → 41 OK · 4 STALE · 8 HOST · 2 UNRUN.
