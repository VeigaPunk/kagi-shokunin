# SelfInvKnowledge3 — C1 inventory of current-tense numeric self-counts (round 25 BUILD)

BASE 4587c61a348e4528717404a68912c373f3ef4d03 (sandbox `git rev-parse HEAD` → match, exit 0). Targets: the 8 knowledge files under `corpus/knowledge/`. No edits to lane files. No tools installed (none needed). Classification rule: CURRENT = present-tense / registry / decision-table / committed-inventory description a reader acts on today; HISTORICAL = explicitly round-dated, revision-pinned (sha, `ea77bf0`), or host-DB measurements already qualified by the docs' round-16/22 errata.

Method (all in sandbox `/fast/scratch/kagi-r25/SelfInvKnowledge3/lane`, gate runs under `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`, hermetic `--selftest` only):
- `bash corpus/drift-pins.sh --selftest` → `DRIFT_SELFTEST: PASS (13 cases)`, exit 0.
- `bash corpus/surface-census.sh --selftest` → `SELFTEST: PASS (16 cases)`, exit 0; exactly 2 `skip-case` lines (15 verbs-sandboxed, 16 verbs-break-injection).
- `wc -l corpus/drift-pins.sh` → 451; `sha256sum` → `c138d34c7f0d…c70feb` = doc's `c138d34c…0feb` (file is still the cited round-9 v2 revision).
- `grep -cv '^#' corpus/drift-baseline.tsv` → 15; same on `drift-symbols.tsv` → 20; `grep -c 'op://'` → 0 / 0; `grep -cP '\t-\t?$|\t-$' drift-baseline.tsv` → 6 (no-hash rows).
- `transcript-scan.sh` inventory: `SCAN_COLS[` = 11 tables / 24 text columns; `PATTERNS_HIT` (:83) = 32 entries; `PATTERNS_WARN` (:96) = 5; `TRIPWIRE_TABLES` (:66) = 5; `run_scan` (:135) increments cells once per column×pattern → 24×37 = 888 (static).
- `grep -nE '(^|[^a-z])mv ' corpus/drift-pins.sh` → :365, :366 (the `--pin` write pair) + :428, :430 (selftest fixtures).

| file:line | phrase (excerpt) | class | claimed | live | source | STALE? |
|---|---|---|---|---|---|---|
| drift-gate.md:3 | "`drift-pins.sh` (round-9 v2, 451 lines, sha256 `c138d34c…0feb`)" | CURRENT | 451 | 451 | `wc -l` + sha256sum match (ledger R11-05's subject file) | no |
| drift-gate.md:4 | "`drift-baseline.tsv` (15 rows)" | CURRENT | 15 | 15 | `grep -cv '^#'`; corroborated by ledger R18-01 expect `files_bad=15` | no |
| drift-gate.md:4 | "`drift-symbols.tsv` (20 rows)" | CURRENT | 20 | 20 | `grep -cv '^#'`; corroborated by R18-01 `symbols_bad=20` | no |
| drift-gate.md:97 | everything-else hash-policy row: "9 files, mode 644/755" | CURRENT | 9 | 9 | drift-baseline.tsv: 15 rows − 6 sha-`-` = 9 hashed | no (count; "mode 644/755" wrong for 1 of 9 — NMH manifest is 600 — already corrected by the doc's own round-22 erratum) |
| drift-gate.md:101-102 | "for the 6 no-hash files" | CURRENT | 6 | 6 | `grep -c` sha `-` column = 6 | no |
| drift-gate.md:110 | "committed TSVs contain 0 `op://` refs and 0 `op.env` key names" | CURRENT | 0 | 0 | `grep -c 'op://'` both TSVs = 0, 0; key-name half UNRUN (needs host op.env key list — forbidden read) | no (verified half) |
| drift-gate.md:131 | "the two `mv` calls are not one transaction" (`--pin`) | CURRENT | 2 | 2 | grep: `--pin` writes mv at drift-pins.sh:365,366 (2 more are selftest fixtures :428,:430) | no |
| drift-gate.md:143 | "6 of 15 files are content-unhashed" | CURRENT | 6/15 | 6/15 | no-hash grep 6; row count 15 | no |
| drift-gate.md:145 | "10 assignments before and after is `OK`" (op.env count pin) | CURRENT | 10 | 10 | drift-symbols.tsv row `op.env #10 … shape` | no |
| drift-gate.md:159 | "the explicit 15-row list" | CURRENT | 15 | 15 | `grep -cv '^#' drift-baseline.tsv` | no |
| drift-gate.md:197 | "clean run, 13-case selftest" (Falsification, imperative) | CURRENT | 13 | 13 | ledger R11-05 (`drift-pins.sh --selftest`, expect `PASS (13 cases)`); sandbox run agrees, exit 0 | no |
| substrate-deferral.md:42 | "The census selftest's two verb cases" | CURRENT | 2 | 2 | sandbox census selftest: 2 skip-case verb rows; ledger R11-03 note | no |
| substrate-deferral.md:44 | "The case count is unchanged (16)" | CURRENT | 16 | 16 | ledger R11-03 (`surface-census.sh --selftest`, expect `PASS (16 cases)`); sandbox run agrees, exit 0 | no |
| substrate-deferral.md:50 | R18-01 "pins the all-GONE … (`files_ok=0 files_bad=15 …`) verdict" | CURRENT | 15 | 15 | committed drift-baseline.tsv row count = 15 (row is `[host]` since round 24 — NOT executed; `--allow-host-rows` unused per contract; ledger R18-01 expect pins the identical line) | no |
| transcript-hygiene.md:28 | "`SCAN_COLS` map, 11 tables" | CURRENT | 11 | 11 | 11 `SCAN_COLS[...]` assignments, transcript-scan.sh:50-60 | no |
| transcript-hygiene.md:34 | "the shipped revision 888 cells rather than round-8's 270" | CURRENT (888) | 888 | 888 | static coverage: 24 scanned columns × 37 patterns (script :50-60, :83, :96, run_scan :135); 270 is the round-8 revision (HISTORICAL) | no |
| transcript-hygiene.md:71 | "888 cells × 32+5 patterns" (inventory part) | CURRENT | 32+5 | 32+5 | `PATTERNS_HIT` = 32 entries (:83), `PATTERNS_WARN` = 5 (:96) | no |
| transcript-hygiene.md:64,71 | "all 5 tripwires empty" (count part) | CURRENT | 5 | 5 | `TRIPWIRE_TABLES` (:66) = 5 names; "empty" is a host-DB state (HISTORICAL, erratum-qualified) | no |
| transcript-hygiene.md:123 | "the shipped revision carries 32" | CURRENT | 32 | 32 | `PATTERNS_HIT` entry count = 32 | no |

HISTORICAL occurrences (out of C1 population by rule, listed for completeness; live not computed): drift-gate.md:13 "13 host files" + :18 "2 of 13 files" (v1 audit, pinned "read at HEAD `ea77bf0`" :5, erratum-qualified); :63-64 "`GONE` ×2 … files_ok=2 files_bad=0 symbols_ok=0 symbols_bad=2" (scratch-fixture experiment output, not an artifact count — excluded); :119 "the round-9 pin printed three `REPIN` lines" (round-9 dated); :169-170 dated Reproduction block (`CLEAN (files=15 symbols=20)`, `PASS (13 cases)` — same quantities as CURRENT rows above, dated 2026-09-28). substrate-deferral.md:8-11 round-18 gate summaries (`gone=23 absent=37`, `files_bad=15 symbols_bad=20`, `failed=6`, `breadth_drift=6` — explicitly re-marked historical by the round-22 final clarification); :21 "Eleven rows fell into that class on 2026-10-14" (dated; live `[substrate]` row count is 11 per ledger R18-02, coincidentally equal); :85 "cases 95-97" (withdrawn ordinals — round-22 clarification says use named `defer-substrate-*` cases; live ledger selftest is 151 per R11-09/R18-03). transcript-hygiene.md:57 "4 WARN cells spanning 5 distinct sessions"; :64 round-8 "0 HIT, 4 WARN … 270 cells × 30 patterns" (doc: "treat it as historical"); :71 findings "HITS=2, warns=2" (host-DB, round-22 erratum: "all live database row counts, findings and WARN figures … original observations"); :122 round-8 "25 HIT patterns"; :125 "7 sessions / 39 messages / 55 parts / 238 events" ("the 2026-09-28 census, not invariants").

Excluded from population (not lane artifacts): all host-substrate numbers in cdp-bridge-1password.md (op 2.35.0, NMH line refs), config-layering.md (455 lines, 9 providers, 23 agents, 56-entry ruleset, 20 vars), handler-trust-boundary.md (333/117/14 lines, 162 paths, 26 entries, 51 ms, DB census, `janitor_auth.ts` 14 lines), janitor-lifecycle.md, op-env-refs.md (1078 B) — a numeric+noun grep sweep (`\d+ (cases|rows|stamps|claims|items|pins|symbols|tables|patterns|captures|criteria)`) over those five files returned zero matches; all are round-16/22-erratum-qualified historical host reads. SKILL.md:46 ("63 stamps + 39 claims") is outside this item's 8-file target (planner D1, other seats).

**CURRENT stale claims: 0.** Every in-population current-tense self-count in the 8 target docs matches its live value at BASE. UNRUN: the `op.env` key-name half of drift-gate.md:110 and execution of ledger row R18-01 (host row; hermetic row-count substitute used, identical expected value).
