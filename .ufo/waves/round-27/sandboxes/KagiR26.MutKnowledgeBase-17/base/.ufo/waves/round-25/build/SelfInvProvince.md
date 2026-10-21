# SelfInvProvince: C1 self-count inventory (round 25, build)

Seat `KagiR25.SelfInvProvince-2`. BASE `4587c61a348e4528717404a68912c373f3ef4d03`. Read-only: no lane file edited.
Target identity: lane == BASE (sha256, 16 hex) for PROVINCE.md `642b5d2831337a01`, AGENTS.md `c62ffaf4e92d50e4`, SHONEN.md `1bb89fc5c006f4a9`, corpus/claim-ledger.tsv `98e70b0ee9fe86d9`.
Live values: sandbox `/fast/scratch/kagi-r25/SelfInvProvince-2/lane` (clone + checkout BASE), `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/SelfInvProvince-2/home`. Host-reading modes were not run. Tools: none installed.
Rules: CURRENT = present tense, registry, or gate description with no round/revision/date. HISTORICAL = dated (round N, revision, date, LOG/lesson pointer) or host-substrate measurement (PROVINCE.md:10-17 erratum; R18-01 last recorded state 2026-10-14, all GONE). Out of population: ports, modes, dates, OpenBao 2.7.x (vendor), `steps: 4` (host config, PROVINCE.md:28), exit codes, section/ID numbers. AGENTS.md has zero numeric claims.
P = PROVINCE.md, S = SHONEN.md.

| file:line | phrase | CURRENT/HISTORICAL | claimed | live | source (ledger id or command) | STALE? |
|---|---|---|---|---|---|---|
| P:8 | enforces 20 asset / 15 runtime rows | CURRENT | 20/15 | 20/15 | awk col2 on surface-census.tsv | no |
| P:34 | The 4 enumerable dirs | CURRENT | 4 | 4 | grep -cE '^# scan' surface-census.tsv | no |
| P:46 | --selftest proves 16 cases | CURRENT | 16 | 16 | R11-03 (substrate-tagged; ran hermetic) | no |
| P:46 | --verbs --deep adds the three probes | CURRENT | 3 | 3 | grep -c 'requires --deep' surface-census.sh | no |
| P:46 | surface-census.tsv (35 rows | CURRENT | 35 | 35 | R11-11 | no |
| P:46 | state-shape.tsv (22 rows | CURRENT | 22 | 22 | R11-10 | no |
| P:47 | drift-baseline.tsv (15 files) | CURRENT | 15 | 15 | grep -cv '^#' drift-baseline.tsv | no |
| P:47 | drift-symbols.tsv (20 claims | CURRENT | 20 | 20 | grep -cv '^#' drift-symbols.tsv | no |
| P:49 | --selftest proves 36 cases | CURRENT | 36 | 36 | R12-02 | no |
| P:49 | the seven byte-comparator cases | CURRENT | 7 | 7 | grep -c 'tcase bytes-' op-ref-probe.sh (1 is POLICY) | no |
| P:49 | four error signatures | CURRENT | 4 | 6 | SIG_CONTRACT op-ref-probe.sh:120-125 (6 rows; probed :351, checked :420); R12-01 note "sig=6 at v2, 4 at v1" | **YES** |
| P:50 | one row per SKILL.md checklist item (8 columns | CURRENT | 8 | 8 | awk NF on checklist.tsv (16 rows, all NF=8) | no |
| P:50 | bijection over the 16 items | CURRENT | 16 | 16 | SKILL.md:433-460 (8 E + 8 H bullets); R15-05 denominator | no |
| P:50 | --selftest proves 34 cases | CURRENT | 34 | 34 | R15-02 | no |
| P:50 | corpus/checklist.tsv (16 rows) | CURRENT | 16 | 16 | R15-04 | no |
| P:51 | declares 5 owned prefixes | CURRENT | 5 | 5 | R16-04 | no |
| P:51 | (27 census rows) | CURRENT | 27 | 27 | awk partition: adjacency `# own` x census paths | no |
| P:51 | 4 shared groups | CURRENT | 4 | 4 | R16-05 | no |
| P:51 | (8 rows) | CURRENT | 8 | 8 | awk partition not-owned (35-27) | no |
| P:51 | 8 no-enumerate boundaries | CURRENT | 8 | 8 | R16-06 | no |
| P:51 | 4 derived leaf breadth pins | CURRENT | 4 | 4 | R17-02 | no |
| P:51 | --map prints all 35 row assignments | CURRENT | 35 | 35 | R11-11 (census rows; --map not run) | no |
| P:51 | --breadth (20/4, 105/2, 4/1, 53/1; 182/8/174) | CURRENT | 182/8/174 | UNVERIFIED-host; pins adjacency.tsv:75-78 sum to 182/8/174 | R17-01 (tagged, not run) | UNVERIFIED |
| P:51 | --selftest proves 61 cases | CURRENT | 61 | 61 | R16-02 | no |
| P:51 | --falsify catches 18/18 mutations | CURRENT | 18/18 | UNVERIFIED-host | R16-03 (tagged, not run) | UNVERIFIED |
| P:52 | --selftest declares 151 cases | CURRENT | 151 | 151 | R11-09 | no |
| P:53 | --selftest proves 70 cases | CURRENT | 70 | 70 | R21-03 | no |
| P:54 | --selftest 22 cases | CURRENT | 22 | 22 | R24-01 | no |
| P:54 | including two malformed-tag regex bounds | CURRENT | 2 | 2 "malformed" in docstring rendered-text-v1.py:21-23; 3rd CritC2 bound (attributed closer) not so labelled | grep -n malformed rendered-text-v1.py; read :144-147 | AMBIGUOUS |
| P:55 | --selftest declares 14 isolated cases | CURRENT | 14 | 14 | R24-02 | no |
| S:12 | ownership rules R1-R11 | CURRENT | 11 | 11 (scope-gate.sh:29-44; R12-R13 breadth) | grep rule header | no |
| P:8 | scanned=4 (2026-09-29) | HISTORICAL | 4 | UNVERIFIED-host (structural `# scan` count is 4) | host verify (not run) | n/a |
| P:8 | absent=2 runtime rows; symlinks=0; UNLISTED=0 | HISTORICAL | 2/0/0 | UNVERIFIED-host; R18-01 (2026-10-14): all GONE | host verify (not run) | n/a |
| P:20,21,27,37 | the-janitor 333 / client.py 117 / opencode.json 455 / tac-check 88 lines | HISTORICAL | 333/117/455/88 | UNVERIFIED-host; committed pins drift-baseline.tsv:1,2,6,10 agree | host (not run) | n/a |
| P:21 | round-15 grep => 0; L12, L130/139/175, L131/140/176 | HISTORICAL | 0; line refs | UNVERIFIABLE (host; no drift-symbols pin) | none | n/a |
| P:46 | this said 21 until round 11 | HISTORICAL | 21 | 22 (R11-10) | R11-10 | n/a |
| P:46 | Round 10: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0) | HISTORICAL | line | rows 20/15 match; host fields UNVERIFIED | none | n/a |
| P:47 | 20 since round 12 added cmd_run L248 row | HISTORICAL | 20 | 20 rows; L248 pinned drift-symbols.tsv:30 | grep -cv '^#' | n/a |
| P:49 | 29 before the --dotenv-bytes arm | HISTORICAL | 29 | 29 = 36-7 | arithmetic | n/a |
| P:50 | this line said 28 until round 21 | HISTORICAL | 28 | 34 | R15-02 | n/a |
| P:50 | Round-15 baseline: items=16 runnable=9 by_hand=7 failed=0; ratio 9/16 floor=8 by_hand=7 | HISTORICAL | 16/9/7/0 | ratio matches R15-05; CHECKLIST_RUN host (R15-01 tagged, not run) | R15-05 | n/a |
| P:52 | verify (83 revision stamps + 61 claim rows at round 24 | HISTORICAL (dated; D1 shape) | 83/61 | 83 (R12-03), 61 (R21-04): match | R12-03, R21-04 | n/a |
| P:52 | (121 at round 23; 140 ...; eleven fresh ...) | HISTORICAL | 121/140/11 | not separately pinned; total 151 | arithmetic | n/a |
| P:53 | (40 at first landing; seven; twelve; eleven) | HISTORICAL | 40/7/12/11 | sums to 70 | arithmetic | n/a |
| S:6 | CITATION_GATE: CLEAN (cites=891 docs=53 unresolved=0 ephemeral=0 labeled=13) at LOG.md:758 | HISTORICAL (LOG pointer verified) | 891/53/0/0/13 | UNRUN: citations is fleet-layout-bound; R11-08 pins only the shape | R11-08 (not run) | n/a |
| S:10 | all seven safe gates re-ran green (97/13/16/61/29/34-case selftests) | HISTORICAL (2026-10-14 erratum; lesson :45 verified) | 97/13/16/61/29/34 | 6 selftests + transcript seeded-hit = 7; census 16, scope 61, checklist 34 match; ledger now 151, op-ref now 36 | R11-03, R16-02, R15-02, R12-02, R11-09 | n/a |
| S:12 | SCOPE_FALSIFY: PASS (caught=18/18 failed=0) at LOG.md:686 | HISTORICAL (LOG pointer verified) | 18/18 | UNRUN (R16-03 tagged) | R16-03 (not run) | n/a |

CURRENT stale claims: 1 of 31 (P:49 "four error signatures": claimed 4, live 6). Other CURRENT: 27 match, 2 UNVERIFIED-host, 1 AMBIGUOUS.

Notes
1. P:49 STALE: SIG_CONTRACT has 6 rows (op-missing-envfile, op-no-command, op-dotenv-badchar, op-envfile-directory, janitor-refs-missing, janitor-run-no-command). R12-01 records 4 as the v1 total, so the doc kept a superseded number. Only the op-side subset (4 of 6) would match, and the sentence does not say so.
2. Classification pressure for the planner: the explicit-date rule makes dated registry lines HISTORICAL even when a decision table reads them as current. Out of target, read only: SKILL.md:46 "(63 stamps + 39 claims + claim ids, round 21)", live 83/61 (the D1 site). In target: P:52 "83/61 at round 24" matches today but has the same shape. A gate that binds only undated CURRENT lines would miss D1-shaped drift.
3. Erratum scope: P:10-17 says "the surfaces below" are HISTORICAL. I applied that to host-surface measurements only; the gate list (P:45-55) and P:34 are CURRENT by content.
4. Composition wording: R24-01 note "Inherited20 cases plus two malformed-tag bounds" does not match code. CASES has 20 tuples (rendered-text-v1.py:126-147; 6 added in round 24 at :140-147) plus 2 explicit checks (`n = len(CASES) + 2`, :160) = 22.
5. Not executed: the 11 other tagged rows (host or substrate): R11-01/02/04/06, R12-01, R13-03, R15-01, R16-01/03, R17-01, R18-01. R11-03 (also tagged) was run only as `--selftest` under env -i with scratch HOME; its two verb cases SKIP (handler absent), total still 16.
6. Derived live values (no ledger row pins them): 20/15 and 27/8 (awk), 4 scan dirs, 7 bytes-cases, 3 deep probes, 6 signatures, 8E+8H SKILL items (SKILL.md:434-460), 11 ownership rules (scope-gate.sh:29-44).

Commands (sandbox, env -i, cwd = sandbox lane; all exit 0; stdout in sandbox out-*.txt):
- bash corpus/surface-census.sh --selftest: SELFTEST: PASS (16 cases) | bash corpus/op-ref-probe.sh --selftest: OP_REF_SELFTEST: PASS (36 cases)
- bash corpus/checklist-run.sh --selftest: CHECKLIST_SELFTEST: PASS (34 cases) | --ratio: CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6
- bash corpus/scope-gate.sh --selftest: SCOPE_SELFTEST: PASS (61 cases) | bash corpus/claim-ledger.sh --selftest: SELFTEST: PASS (151 cases)
- bash corpus/sources-census.sh --selftest: SOURCES_CENSUS_SELFTEST: PASS (70 cases) | python3 corpus/rendered-text-v1.py --selftest: cases=22 | python3 corpus/closure-dispositions.py --selftest: 14 cases
- grep -cv '^#' on surface-census.tsv=35, state-shape.tsv=22, drift-baseline.tsv=15, drift-symbols.tsv=20; grep -c '[^[:space:]]' stamps.tsv=83; grep -cE '^R[0-9]+-[0-9]+' claim-ledger.tsv=61; adjacency.tsv '# own'=5, group rows=4, '# no-enumerate'=8, '# breadth'=4.
