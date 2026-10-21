# SelfInvSkill1 — C1 inventory of CURRENT-tense numeric self-claims, SKILL.md:1-130

BASE 4587c61a348e4528717404a68912c373f3ef4d03. Live values computed in sandbox
`/fast/scratch/kagi-r25/SelfInvSkill1/lane` (clone of the lane, checked out at BASE);
gate selftest/list/ratio modes run hermetically: `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home bash …`.
No host-reading gate mode was run; no tool installs were needed. Ledger row ids cite
`corpus/claim-ledger.tsv`; each cited row's exact command was executed in the sandbox and its
observed last line matches the row's `expect`.

| file:line | phrase (exact, trimmed) | class | claimed | live | source (ledger id + command / run) | STALE? |
|---|---|---|---|---|---|---|
| SKILL.md:46 | "`bash corpus/claim-ledger.sh verify` (63 stamps + 39 claims + claim ids, round 21)" | CURRENT | 63 stamps / 39 claims | 83 / 61 | R12-03 `grep -c '[^[:space:]]' corpus/stamps.tsv` → 83; R21-04 `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → 61 (both exit 0 in sandbox) | **STALE (both numbers)** |
| SKILL.md:47 | "`--selftest` 70 cases" (sources-census.sh) | CURRENT | 70 | 70 | R21-03 `bash corpus/sources-census.sh --selftest` hermetic → `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` rc=0 | no |
| SKILL.md:41 | "`CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7 failed=0)`" | CURRENT | 16 / 9 / 7 / 0 | 16 / 9 / 7 live; failed=0 UNRUN (row execution is host) | R15-04 `grep -cE '^[EH][0-9]+[[:space:]]' corpus/checklist.tsv` → 16; R15-03 `bash corpus/checklist-run.sh --list` hermetic rc=0 → `rows=16 runnable=9 by_hand=7`; failed=0 owned by R15-01 [substrate] | no (declaration counts; failed=0 UNRUN) |
| SKILL.md:41 | "`CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7`" | CURRENT | 9/16, floor 8, by_hand 7 | 9/16, 8, 7 | R15-05 `bash corpus/checklist-run.sh --ratio` hermetic rc=0 → `runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` | no |
| SKILL.md:36 | "`--selftest` proves 16 cases" (surface-census.sh) | CURRENT | 16 | 16 | R11-03 `bash corpus/surface-census.sh --selftest` hermetic → `SELFTEST: PASS (16 cases)` rc=0 | no |
| SKILL.md:36 | "`--deep` = 10 probes / 0 skips" | CURRENT | 10 / 0 | 10 probe definitions; 0-skips UNRUN (host) | static `grep -c 'probe_open ' corpus/surface-census.sh` → 10; host run = R11-02 [substrate] | no (skip count UNRUN, not contradicted) |
| SKILL.md:35 | "`scope-gate.sh` partitions the 35 census rows" | CURRENT | 35 | 35 | R11-11 `grep -cv '^#' corpus/surface-census.tsv` → 35 | no |
| SKILL.md:35 | "`BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174 …)`" | CURRENT | 4/4/4/4, 182, 8, 174 | UNRUN (host-substrate row); static partial: breadth pins=4 | R17-01 [substrate] is the designated live source; static `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv` → 4 | UNRUN (host counts 182/8/174 unverifiable under policy) |
| SKILL.md:35 | "`--selftest` proves 61 cases" (scope-gate.sh) | CURRENT | 61 | 61 | R16-02 `bash corpus/scope-gate.sh --selftest` hermetic → `SCOPE_SELFTEST: PASS (61 cases)` rc=0 | no |
| SKILL.md:35 | "`--falsify` catches 18/18 shipped mutations" | CURRENT | 18/18 | mutation total=18 (static); caught=18/18 UNRUN (host) | static `scope-gate.sh:677` `local -i … total=18`; host run = R16-03 [substrate] (2 breadth mutations read live host dirs) | UNRUN (total agrees; catch-rate unverifiable) |
| SKILL.md:35 | "--breadth … the four derived leaf boundaries" | CURRENT | 4 | 4 | R17-02 command as above → 4 (R24-12 pins membership) | no |
| SKILL.md:34 | "`UNLISTED` = an undeclared child of one of the 4 enumerable dirs" | CURRENT | 4 | 4 | `grep -cE '^# scan' corpus/surface-census.tsv` → 4 scan directives (lines 17-20) | no |
| SKILL.md:33 | "`OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)`" | CURRENT | 44/12/7/5/10/6 | UNRUN — row needs `op` on PATH + handler (documented host-state dependence) | R12-01 [substrate] `bash corpus/op-ref-probe.sh`; counts are contract-array-derived (op-ref-probe.sh:460-468) | UNRUN (host-bound; no live number under policy) |
| SKILL.md:31 | "`op` 2.35.0 fixture: `op run` injects 12 keys, `refs` lists 7, `divergent=5`" | CURRENT | 12 / 7 / 5 | UNRUN — same host dependence as R12-01 | R12-01 [substrate] (ledger note pins "oprun=12 refs=7 divergent=5 sig=6 at v2") | UNRUN (host-bound) |
| SKILL.md:118 | "`transcript-scan.sh` scans all text-bearing columns in 11 tables" | CURRENT | 11 | 11 | `grep -c '^SCAN_COLS\[' corpus/transcript-scan.sh` → 11 (part, message, event, session, session_input, session_message, session_context_epoch, todo, project, workspace, permission — matches the line's list) | no |

## HISTORICAL / out-of-population numbers in lines 1-130 (no live binding required)

| file:line | phrase | why out |
|---|---|---|
| SKILL.md:65 | "any of the 26 loaded agents (round-7 scratch `GET /agent`; 23 resolve offline…" | HISTORICAL — explicitly round-7-dated; also host runtime, not a lane artifact count |
| SKILL.md:99 | "(observed 7 sessions/39 msgs/55 parts)" | host `opencode.db` observation snapshot, not a lane artifact count |
| SKILL.md:124 | "Baseline 2026-09-28: 0 HIT / 4 WARN" | HISTORICAL — explicitly dated baseline of a host scan (R11-06 owns the live clock) |
| SKILL.md:8,31 | "`op` 2.35.0" | version pin, not an artifact count |
| SKILL.md:42,79,63,~110 | "2→5→9→19→30 s", "≈58 s", "3 keys", "51 ms", "120 probes", "3600 s" | handler/host behavior constants and measurements, not lane-artifact counts |

## Classification notes

- SKILL.md:46 is classified CURRENT despite the trailing ", round 21": the phrase sits in the
  decision table's "Correct surface" column as the output a reader gets from `verify` today
  (the same pattern the round-25 plan routes as D1 and counts as `stale>=1` before C1).
  The genuinely round-dated numbers (65, 124) are HISTORICAL and excluded by rule, not omission.
- `claim-ids` in the same phrase carries no number; only the two counts were judged.

## Counts

CURRENT stale claims: **1** (SKILL.md:46 — "63 stamps + 39 claims" vs live 83 / 61; one claim line, both numbers stale).
CURRENT claims inventoried: 15 rows above; stale 1; UNRUN-host-bound 4 (SKILL.md:33, :31, plus the host-only
halves of :41 failed=0, :35 children=182/declared=8/undeclared=174 and :36 "0 skips", :35 falsify catch-rate).
UNRUN rows are not marked STALE: claimed ≠ live could not be established without a host gate run,
which this wave's policy forbids; each names its owning ledger row as the live source.
