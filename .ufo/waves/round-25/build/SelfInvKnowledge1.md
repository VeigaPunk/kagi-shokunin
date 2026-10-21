# SelfInvKnowledge1 — C1 inventory of current-tense numeric self-claims (nine knowledge docs)

Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03, sandbox `/fast/scratch/kagi-r25/SelfInvKnowledge1/lane` (the nine docs are cmp-identical to the lane tree). Read-only; no lane edits; no installs; no host reads.
Files: `corpus/knowledge/` AB=adjacency-breadth, CE=checklist-execution, OR=op-ref-consumption, SC=surface-census, VO=vault-openbao-token-lease-lifecycle, OP=onepassword-machine-credentials. FB, CP, JC carry no in-scope lane counts (dates, IDs, host line refs only).
Classes: CURRENT = unqualified present tense, registry/table cell, or reproduction line. HISTORICAL = qualified in its own line, by a dated section, or by an erratum declaring it historical. "conceded" = the doc's own trailing erratum already calls the body text superseded; body left uncorrected.

## Hermetic runs — `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home bash corpus/<g> --selftest`, all exit 0
- scope-gate.sh → `SCOPE_SELFTEST: PASS (61 cases)` (R16-02 agrees)
- checklist-run.sh → `CHECKLIST_SELFTEST: PASS (34 cases)` (R15-02 agrees)
- op-ref-probe.sh → `OP_REF_SELFTEST: PASS (36 cases)` (R12-02 agrees)
- surface-census.sh → `SELFTEST: PASS (16 cases)` (R11-03 agrees; cases 15–16 SKIP, handler absent)

## Committed-file counts (sandbox; grep -c / awk row counts; code C-reg)
- surface-census.tsv 35 rows (asset 20, runtime 15), `# scan` 4 at lines 17–20 [R11-11]
- state-shape.tsv 22 rows: sqlite 9, json 8, log 3, lock 1, marker 1 [R11-10]
- drift-symbols.tsv 20 pins; drift-baseline.tsv 15 rows: 9 sha256, 6 `-`
- adjacency.tsv: `# breadth` 4 (20/4, 105/2, 4/1, 53/1), `# no-enumerate` 8 (67–74), `# own` 5
- checklist.tsv 16 rows, by-hand 7 (E2 E3 E6 E7 H2 H5 H6), runnable 9 [R15-04, R15-03]; SKILL.md 16 `- [ ]`
- reason floors: checklist-run.sh:156 `.{24,}`, :160 `ns >= 20`
- E4 pipeline (checklist.tsv:29) rerun as its own grep/wc pipelines (printf/test wrapper not re-run) → raw=5 ex=0; `op://vault/` lines: 2 docs + transcript-scan.sh:202
- static, op-ref-probe.sh: OPRUN 12 (:76–89), REFS 7 (:93), DIVERGENT 5 (:92), SIG 6 (:119–126), EDGE 9 keys + P8 = 10 (:99–109), edge.env 9 keys / 11 lines (:179–189), canned rc=1 cases 15 (:606–662), mask checks 2 (:331–334, :413–418)
- static, scope-gate.sh: falsify `total=18` (:677); cases :701–802 = 9 round-16 + 9 breadth

## Inventory

| file:line | phrase | class | claimed | live | source | STALE? |
|---|---|---|---|---|---|---|
| AB:5-6 | "the 35-row declared universe" | CURRENT | 35 | 35 | R11-11 | no |
| AB:6-7, AB:78 | "observed … four leaf dirs, 182 direct children, 8 buckets, 174 undeclared" (2026-09-29); "observed counts (94/2, 15/2, 48/1, 2/1)" | HISTORICAL | 4/182/8/174 | pin sums 4/182/8/174; host counts UNRUN | C-reg; R17-01 (host) | n/a |
| AB:20-24 | breadth table 20/4/16, 105/2/103, 4/1/3, 53/1/52; total 182/8/174 | CURRENT | as stated | pins 20/4, 105/2, 4/1, 53/1 → 182/8/174 | C-reg adjacency.tsv:75–78 | no |
| AB:26-27 | "Before round 17, grep … was 0" | HISTORICAL | 0 | 4 now | C-reg | n/a |
| AB:71, AB:135 | "Four aggregate ancestors are intentionally exempt"; "four exempt ancestors" | CURRENT | 4 | 4 aggregate no-enumerate rows (adjacency.tsv:71–74) | C-reg | no |
| AB:81 | "derived from the eight no-enumerate and four scan rows" | CURRENT | 8 + 4 | 8 + 4 | C-reg | no |
| AB:105, AB:144, AB:148 | "BREADTH_AUDIT: CLEAN (… children=182 declared=8 undeclared=174 …)"; "4 ADJACENCY_BREADTH lines" | CURRENT | 182/8/174; 4 | registry sums and 4 leaves match; host line UNRUN | C-reg; R17-01, R17-02 | no |
| AB:121 | "The 174 children remain foreign or out of scope" | CURRENT | 174 | 182 − 8 = 174 (registry); host UNRUN | C-reg | no |
| AB:152 | "# SCOPE_SELFTEST: PASS (61 cases)" | CURRENT | 61 | 61 | run; R16-02 | no |
| AB:155 | "# SCOPE_FALSIFY: PASS (caught=18/18 failed=0)" | CURRENT | 18/18 | total=18 static; run UNRUN (breadth cases read HOME) | static; R16-03 | UNRUN |
| AB:158 | "The 18 falsifiers are the round-16 nine plus nine breadth" | CURRENT | 18 = 9+9 | 18 cases, 9+9 (:701–802) | static | no |
| CE:5 | "corpus/checklist.tsv (16 rows)" | CURRENT | 16 | 16 | C-reg; R15-04 | no |
| CE:4, CE:15–21, CE:82, CE:94–96 | "(16 items, L420–447 at the round-15 revision)"; "16 `- [ ]` bullets"; "12 … 14 items"; "runnable=9/16 floor=8 by_hand=7"; "runnable=3 by_hand=13"; "8/8" | HISTORICAL (rounds 9–15; erratum L195) | — | r15 baseline 9/16/8/7 unchanged (R15-05); rest not live | R15-05 | n/a |
| CE:36 | "E1–E8 … H1–H8" | CURRENT | 16 | 16 | C-reg; R24-08 | no |
| CE:40 | "H7 accepts three exit codes" | CURRENT | 3 | 3 (H7 expect_exit 0/1/2) | static (checklist.tsv:40) | no |
| CE:42, CE:59 | reason "text ≥ 24 chars"; "≥ 20 non-space characters" | CURRENT | 24 / 20 | 24 (checklist-run.sh:156) / 20 (:160) | static | no |
| CE:63 | "--selftest proves 34 cases" | CURRENT | 34 | 34 | run; R15-02 | no |
| CE:80–81 | "Seven rows are by-hand: E2, E3, E6, E7, H2, H5, H6" | CURRENT | 7 | 7, ids verified | C-reg; R15-03 | no |
| CE:120 | "pins hits=0 excluded=5 raw=5" | CURRENT | 0/5/5 | 0/5/5 | E4 pipeline | no |
| CE:120–122 | "`vault` on the three documented example lines, FakeVault and wal inside the two gate scripts" | CURRENT | 3 doc lines | 2 doc lines (corpus/knowledge/op-env-refs.md:14; corpus/lessons/round-5-aggregator-audit.md:19) + 1 script line (transcript-scan.sh:202); FakeVault 1 (surface-census.sh:609); wal 1 (transcript-scan.sh:242); total 5 | E4 pipeline + grep | YES (unconceded; erratum L203–204 is provenance only) |
| CE:127–128 | "TRANSCRIPT_SCAN: HITS=2 … 2026-09-28 baseline" | HISTORICAL | 2 | host UNRUN | R11-06 (host) | UNRUN |
| SC:4–5 | "35 rows: 20 asset / 15 runtime" | CURRENT | 35 = 20/15 | 35 = 20/15 | R11-11 | no |
| SC:5 | "22 rows: 9 sqlite / 9 json / 3 log / 1 lock / 1 marker" | CURRENT | 9/9/3/1/1 (sum 23) | 9/8/3/1/1 (sum 22) | R11-10; C-reg | YES (conceded L295) |
| SC:9–11 | "Gates observed this round: … assets=20 runtime=15 …; SELFTEST: PASS (16 cases)" | HISTORICAL | 20/15/16 | 20/15/16; scanned/ok/absent host UNRUN | R11-03 | n/a |
| SC:32 | "(15 files, 19 symbol pins)" | CURRENT | 15 / 19 | 15 / 20 | C-reg (drift-symbols.tsv); R18-01 host symbols_bad=20 | YES (conceded L295–296) |
| SC:52–55, SC:200 | "(4 children), $STATE (5), (5), (2) — 16/16 declared"; "~/.config/opencode (20 children, 4 declared paths)" | HISTORICAL (erratum L292–293: child counts not remeasured) | host counts | scan 4 ✔; pins 20/4 ✔; host UNRUN | C-reg | n/a |
| SC:76 | "the baseline keeps the 16 published hashes" | CURRENT | 16 | 9 sha256 rows of 15 | C-reg (drift-baseline.tsv col 4) | YES (conceded L296–297) |
| SC:119–122 | "Floors are one third of the observed value (… tables_min 12 vs 20 … size_min 16384 vs 33687 B)" | CURRENT (policy withdrawn L298–299) | 1/3 | TSV floors match (state-shape.tsv:30–37); 2/7, 13/39, 18/55, 79/238 ≈ 1/3 but 12/20 = 0.60, 16384/33687 = 0.49 | C-reg; observed UNRUN | YES (conceded L298) |
| SC:117, SC:140, SC:226 | "--selftest case 10 / case 11 / case 14" | CURRENT | 10 / 11 / 14 | sqlite-unavailable / required-table-gone / fused-shape-row | run; R11-03 | no |
| SC:158 | "`--deep` adds the three probes" | CURRENT | 3 | 3 (surface-census.sh:584, 604, 625) | static | no |
| SC:249–264 | "Reproduction (2026-09-28)"; "16 total" | HISTORICAL (dated section) | 16 | 16 | R11-03 | n/a |
| OR:60–63 | "op run injects 12 keys, refs lists 7, divergent=5" | CURRENT | 12/7/5 | 12/7/5 static; op injection UNRUN | static; R12-01 note | no |
| OR:114 | "the gate mechanises exactly two of these rows" | CURRENT | 2 | 2 (:331–334, :413–418) | static | no |
| OR:125 | "The observed op.env holds 10 keys, 8 of which are op:// refs and 2 raw" | CURRENT (host credential file) | 10 / 8 / 2 | NOT READ (credential) | — | UNRUN |
| OR:275, OR:291 | "OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)" | CURRENT | 44/12/7/5/10/6 | 12/7/5/10/6 static ✔; checks=44 UNRUN (op exec; R12-01 pins regex only) | static; R12-01 | UNRUN (checks) |
| OR:276 | "OP_REF_SELFTEST: PASS (29 cases)" | CURRENT | 29 | 36 | run; R12-02 | YES (conceded L373–375) |
| OR:283 | "edge.env (10 classes: #/quote/CRLF/duplicate/${:-}/single-quote)" | CURRENT | 10 | 9 keys E1–E9, 11 lines (op-ref-probe.sh:179–189); the 10th edge row (P8) comes from two1.env | static | YES (unconceded) |
| OR:296–297 | "--selftest proves the comparator on 21 cases, including fifteen seeded mutations" | CURRENT (conceded L379–382) | 21 / 15 | 36 / 15 | run; R12-02; static | YES for 21; 15 agrees |
| OP:3; VO:4 | "reopened the six cited public documentation pages"; "the five pages above" | HISTORICAL (verified-at 2026-10-19) | 6; 5 | 6 S-IDs (OP:2); 5 S-IDs (VO:3) | static | n/a |
| VO:13; VO:113–118 | "Four clocks … (QA8)" table | HISTORICAL (erratum: "historical defective readings") | 4 | 4 rows | static | n/a |
| VO:78 | "grep -rliE 'sops … hashicorp' corpus/knowledge --exclude=… → no file, exit 1 (2026-10-19)" | CURRENT (reproduction) | 0 files, exit 1 | 1 file: corpus/knowledge/feature-bound-credential-review.md, exit 0 | C-vault (doc command verbatim) | YES (unconceded) |

CURRENT stale claims: 9 = 3 unconceded (VO:78, OR:283, CE:120–122) + 6 conceded by the doc's own trailing erratum but left uncorrected in the body (SC:5, SC:32, SC:76, SC:119–122, OR:276, OR:296–297).

Out of population (host, tool, vendor, credential; not lane artifacts): CP:82–83 host DB counts (not read); JC:3–5 and SC:6–7 host line counts (333/117/88 agree with drift-baseline.tsv:1, 2, 10); op 2.35.0 (OR:5–6, 100, 184, 190); OR:125 op.env (not read); VO:55, 89–93 vendor values and 2026-10-19 page counts; CP/JC host line refs and timeouts; OR:245 doc-internal "three blind spots".
UNRUN (contract): scope-gate --falsify/--breadth; checklist-run verify/--only; op-ref-probe default and --dotenv-bytes (op exec); surface-census default/--verbs/--deep; transcript-scan; drift-pins. checklist-run --list/--ratio not executed (selftest-only contract); counted from the TSV. Not inventoried: SKILL.md:46 (routed D1; not a target doc).
Not counted: SC:52–54 registry declares 6 direct rows under `$HOME/.local/state/the-janitor` (census:36–49) vs "(5)" host children; declared-but-absent runtime rows are legal, so host UNRUN.
