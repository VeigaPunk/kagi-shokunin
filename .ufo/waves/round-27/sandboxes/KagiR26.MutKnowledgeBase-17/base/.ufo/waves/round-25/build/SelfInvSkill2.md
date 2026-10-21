# SelfInvSkill2 — C1 inventory, SKILL.md:131-260

Revision: BASE `4587c61a348e4528717404a68912c373f3ef4d03` (lane HEAD matches). Live values come from the sandbox clone `/fast/scratch/kagi-r25/SelfInvSkill2/lane` at BASE, run as `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/SelfInvSkill2/home`. The real lane tree was only read; nothing was edited.
Method: every line in 131-260 matching `[0-9]` or a number word was read. CURRENT = present tense, registry or decision table. HISTORICAL = dated in the same sentence. Ledger ids are from `corpus/claim-ledger.tsv`.

| file:line | phrase | CURRENT/HISTORICAL | claimed | live | source (ledger id or command) | STALE? |
|---|---|---|---|---|---|---|
| SKILL.md:138 | `--selftest … (16 cases)` | CURRENT | 16 | 16 | R11-03 (ledger:17) `bash corpus/surface-census.sh --selftest` → `SELFTEST: PASS (16 cases)`, exit 0; 14 ok + 2 substrate-skip | no |
| SKILL.md:140 | `35 rows` (surface-census) | CURRENT | 35 | 35 | R11-11 (ledger:25) `grep -cv '^#' corpus/surface-census.tsv` | no |
| SKILL.md:141 | `Four dirs are enumerated one level deep` | CURRENT | 4 | 4 | `grep -c '^# scan' corpus/surface-census.tsv` (lines 17-20) | no |
| SKILL.md:147 | `table floor 12` | CURRENT | 12 | 12 | `grep -n tables_min corpus/state-shape.tsv` (line 30) | no |
| SKILL.md:147 | `observed 20` (opencode.db tables) | CURRENT | 20 | UNOBSERVABLE: host DB, not read (state-shape.tsv:30 note) | — | not checked |
| SKILL.md:148-149 | row floors `session:2`, `message:13`, `part:18`, `event:79` | CURRENT | 2/13/18/79 | 2/13/18/79 (declared) | `grep -n rows_min corpus/state-shape.tsv` (lines 32-35) | no |
| SKILL.md:148 | `row floors at one third of observed` | CURRENT (policy) | one third | policy withdrawn: state-shape.tsv:49-50, knowledge/surface-census.md:298 | — | POLICY-DRIFT (not counted) |
| SKILL.md:160 | `the 6 private 0600 files keep -` | CURRENT | 6 | 6 (sha `-`, mode 600) | `cut -f4 corpus/drift-baseline.tsv \| grep -c '^-$'` → 6 (rows 4,5,11-14) | no |
| SKILL.md:162 | `Default set (7 probes)` | CURRENT | 7 | 7 (static; `--verbs` UNRUN) | `grep -c 'probe_open [a-z]' corpus/surface-census.sh` → 10, minus `grep -c 'if \[\[ -z "\${DEEP:-}" \]\]'` → 3 (lines 585,605,627) | no |
| SKILL.md:169 | `3 odd key shapes are silently omitted` | CURRENT (finding) | 3 | UNRUN (needs handler `refs`); static: 3 `omitted-*` checks (surface-census.sh:556-558) | — | not checked |
| SKILL.md:172 | `11 falsifiers` | CURRENT | 11 | 11 | `sed -n '266,289p' corpus/knowledge/surface-census.md \| grep -cE '^[0-9]+\. '` → 11 | no |
| SKILL.md:181 | `(13 cases)` drift selftest | CURRENT | 13 | 13 | R11-05 (ledger:19) `bash corpus/drift-pins.sh --selftest` → `DRIFT_SELFTEST: PASS (13 cases)`, exit 0 | no |
| SKILL.md:185 | `(15 files as of round 9)` | HISTORICAL | 15 | 15 | `grep -cv '^#' corpus/drift-baseline.tsv` | n/a (dated; agrees) |
| SKILL.md:186 | `20 rows` (drift-symbols) | CURRENT | 20 | 20 | `grep -cv '^#' corpus/drift-symbols.tsv` | no |
| SKILL.md:186-189 | `The two endpoint rows` | CURRENT | 2 | 2 | `grep -c 8080 corpus/drift-symbols.tsv` (lines 12, 21) | no |
| SKILL.md:193, 224 | `op.env` `#10` count pin | CURRENT | #10 | UNOBSERVABLE: credential file, not read; pin text drift-symbols.tsv:22 | — | not checked |
| SKILL.md:193 | `two handoff-status.json field names as #1` | CURRENT | 2 | 2 (both `#1`) | `grep -c handoff-status.json corpus/drift-symbols.tsv` (lines 28-29) | no |
| SKILL.md:196 | `only 2 of 13 files` (round-8 audit) | HISTORICAL | 2 of 13 | not re-measurable | — | n/a (dated) |
| SKILL.md:220-221 | `Hash policy (6 of 15 files)`; `the two TAC receipt/custody files` | CURRENT | 6/15; 2 | 15 rows; 6 sha `-`; TAC rows 11,12 | `grep -cv '^#' corpus/drift-baseline.tsv` → 15; `cut -f4 … \| grep -c '^-$'` → 6 | no |
| SKILL.md:243 | `97 scratch cases` (claim-ledger `--selftest`) | CURRENT | 97 | **151** | R11-09 (ledger:23) and R18-03 (ledger:50) `bash corpus/claim-ledger.sh --selftest` → `SELFTEST: PASS (151 cases)`, exit 0 | **YES** |
| SKILL.md:243 | `94 until round 18` | HISTORICAL | 94 | n/a (ledger history 108→121→140→151, R18-03 note) | — | n/a (dated) |
| SKILL.md:251 | `18 rows as of round 14` (claim rows) | HISTORICAL | 18 | 61 | R21-04 (ledger:54) `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → 61 | n/a (dated) |
| SKILL.md:252 | `three sibling gates across 9 modes` | HISTORICAL (dated by sentence) | 3 gates / 9 modes | not measured | — | n/a |
| SKILL.md:254 | `five count rows` | HISTORICAL (dated by sentence) | 5 | not measured | — | n/a |

**CURRENT stale claims: 1** (SKILL.md:243, `97` vs live `151`).

## Notes
1. CURRENT tally: 18 rows. 13 match live, 1 STALE (243), 1 POLICY-DRIFT (148), 3 not verifiable in the sandbox (147 observed-20, 169 UNRUN, 193/224 op.env). 6 HISTORICAL rows, live shown for reference only.
2. 148: the numbers still equal floor(observed/3) for the four row floors (7→2, 39→13, 55→18, 238→79; state-shape.tsv:32-35). The round-22 erratum calls the one-third policy "historical and overbroad" (state-shape.tsv:49-50; knowledge/surface-census.md:298). The present-tense SKILL text contradicts that erratum.
3. 243: neither `97` nor `94` appears in any ledger row (`grep -n '\b9[47]\b' corpus/claim-ledger.tsv` → no hits). R18-03 records 108→121→140→151, so the printed number was never a recorded expectation.
4. Out of range, not inventoried: SKILL.md:46 `(63 stamps + 39 claims + claim ids, round 21)` sits in a decision-table cell. Under the C1 rule it is CURRENT despite the "round 21" tag. Live: 83 (R12-03 ledger:28, `grep -c '[^[:space:]]' corpus/stamps.tsv`) and 61 (R21-04), so STALE. This confirms plan D1.
5. C1 bindability: ledger-bound today are 16 (R11-03), 13 (R11-05), 151 (R11-09), 35 (R11-11) and 61 (R21-04). `rows:` fits 35, 15 and 20. Four scan dirs, 7 default probes, 11 falsifiers, 2 endpoint pins, 2 handoff pins and the 6-of-15 split have no ledger row or row file. C1's two source kinds cannot bind them without a new count row.
6. Excluded as not lane-artifact counts: exit codes and placeholders (`files=N`, `#10->#11`, `<sha12>`; lines 206-217, 239, 253); dated events (143 round-6, 156 round-10, 195 round-8, 204 round-4→8); format or policy constants (147 16-byte magic, 151 >3×, 212 and 257 "exactly once/one", 246 6-column schema, 259 4-class set, 260 ≥24-char); location pins (187-192), checkable only by the host-reading `drift-pins.sh`; relation words ("both", "one row per file").
7. Method: `--verbs` was not run because it executes handler probes. The 7-probe count is static: 10 `probe_open` call sites (surface-census.sh:478, 506, 519, 536, 569, 584, 604, 625, 653, 675), less the 3 `DEEP` guards (585, 605, 627). Without `--deep`, the 3 deep-only probes SKIP.

## Commands and exit codes (sandbox, BASE)
- `… bash corpus/surface-census.sh --selftest` → exit 0, `SELFTEST: PASS (16 cases)`; cases 01-14 ok, 15-16 `substrate-absent`.
- `… bash corpus/drift-pins.sh --selftest` → exit 0, `DRIFT_SELFTEST: PASS (13 cases)`.
- `… bash corpus/claim-ledger.sh --selftest` → exit 0, `SELFTEST: PASS (151 cases)`; ok-case 1-151.
- Count commands in the table: each run in the sandbox at BASE, exit 0.

UNRUN (contract): `surface-census.sh --verbs [--deep]` (handler/op exec); `claim-ledger.sh verify|cells` on the real tree (forbidden; not needed here); `drift-pins.sh` (host gate); any read of op.env, `refs`, or opencode.db.

Tooling: no installs or updates. Host coreutils, grep, sed, cut, sort, wc and awk were used for counting only. No pacman.
