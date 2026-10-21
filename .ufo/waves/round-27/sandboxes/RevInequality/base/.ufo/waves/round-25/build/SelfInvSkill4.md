# SelfInvSkill4 — C1 self-count inventory, SKILL.md L391–520

Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03 (sandbox `/fast/scratch/kagi-r25/SelfInvSkill4/lane`). The real-tree SKILL.md and 12 corpus/doc files read here are byte-identical to BASE (`cmp -s`, all SAME). No lane file edited. No tools installed (none needed).

Commands run (sandbox clone, read-only, no lane script executed, all completed without error):
- `git clone -q --no-hardlinks …; git checkout -q 4587c61…; rev-parse HEAD` → `4587c61a348e4528717404a68912c373f3ef4d03`
- `awk 'NR>=423&&NR<=460&&/^- \[ \]/' SKILL.md | wc -l` → 16 checklist items
- `grep -c '^# scan' corpus/surface-census.tsv` → 4 (lines 17–20)
- `grep -cv '^#' corpus/drift-baseline.tsv` → 15; `grep -cv '^#' corpus/drift-symbols.tsv` → 20
- `awk -F'\t' '$2=="runnable"' corpus/checklist.tsv | wc -l` → 9; `$2=="by-hand"` → 7; `grep -cE '^[EH][0-9]+\t'` → 16 rows
- `grep -n 'warns=2' corpus/transcript-scan.sh` → 78
- `git show e64e81b:corpus/drift-symbols.tsv | grep -cv '^#'` → 19; same at `4b8c018` → 20
- Digit and number-word sweep of L391–520 (grep); raw read of L434 (truncated in default view)

UNRUN: `checklist-run.sh --ratio/--list/verify` (non-selftest gate modes, outside the bound); `transcript-scan.sh`, `drift-pins.sh`, `opencode debug` (host reads, forbidden). No `--selftest` run was needed: the range contains no selftest count.

| file:line | phrase | CURRENT/HISTORICAL | claimed | live | source (ledger id / command) | STALE? |
|---|---|---|---|---|---|---|
| SKILL.md:426-427 | "9 items carry a runnable check" | CURRENT | 9 | 9 | `awk -F'\t' '$2=="runnable"' corpus/checklist.tsv \| wc -l`; bound by R15-03/R15-05 (non-host; UNRUN) | no |
| SKILL.md:427 | "7 declare a `by-hand` class" | CURRENT | 7 | 7 | same, `$2=="by-hand"`; R15-03 `by_hand=7` | no |
| SKILL.md:434 | "no undeclared child sits in the 4 enumerable dirs" | CURRENT | 4 | 4 | `grep -c '^# scan' corpus/surface-census.tsv`; parsed at surface-census.sh:160. **No ledger row.** Same unbound "4" at SKILL.md:34, PROVINCE.md:34,46, corpus/README.md:40, SCORECARD.md:49 | no (UNBOUND) |
| SKILL.md:512 | "(4 baseline WARN rows are exactly that)" | CURRENT | 4 | 2 (documented, not re-measured) | transcript-scan.sh:76-78 "Baseline 2026-09-28 (THIS shipped revision…) … warns=2". No ledger row pins warns (H7 uses `warns=[0-9]+`; R11-06 host-only). "4" is the round-8 figure, superseded per lessons/round-9.md:146-158 | **STALE** (4≠2) |
| SKILL.md:434 | "(15 files / 20 pins as of round 12; 19 before it)" | HISTORICAL (dated r12) | 15 / 20 / 19 | 15 / 20 / 19 | `grep -cv '^#'` on drift-baseline.tsv (15) and drift-symbols.tsv (20); 19 = `git show e64e81b:…` (20 at 4b8c018). Exact-count binding only via host-run R18-01 and checklist E1 | n/a (matches) |
| SKILL.md:392,396,397,399,495,496 | "9 provider defs", "23 agents", "56 permission rules", "all 8 recorded daemon starts since 2026-08-29", "`steps: 8`" | CURRENT, HOST-OBSERVED (opencode runtime; not a lane-artifact count) | as stated | UNRUN (host read forbidden) | no ledger row. Lane copies agree: knowledge/config-layering.md:26,32,35,52; corpus/README.md:32. "8 starts" is text-identical to lessons/round-7.md:56 | UNBOUND, not scored |
| SKILL.md:518 | "exited 0 through four rounds of stale `L17` refs" | HISTORICAL | 4 rounds | n/a (narrative) | — | n/a |

Not counted (not lane-artifact counts): pointers L194, L214–219, L19/L17; ports 9222 and 40961; HTTP 401; exit codes (L438, 454, 478, 483); file modes; dates; round labels (L425, L434, L503); receipt example values (L467); "Two parsers" (L490, host CLI). The brief's examples (63 stamps, 39 claims, `--selftest` 70) do not occur in L391–520.

**CURRENT stale claims: 1** (SKILL.md:512). CURRENT lane-artifact claims scored: 4 (3 match, 1 stale).

Planner notes (nothing applied):
1. Bound by non-host rows: 9 and 7 (R15-03/R15-05). Unbound: the 4 scan dirs and the WARN count. Exact drift 15/20 bound only by host-run rows.
2. The same stale "4 WARN" appears at corpus/knowledge/transcript-hygiene.md:57 ("Baseline 2026-09-28 has 4 WARN cells"), contradicting transcript-scan.sh:78 for the same date. Outside the target; flagged.
3. Candidate non-host rows (not added): `grep -c '^# scan' corpus/surface-census.tsv` → `^4$`; `grep -cv '^#' corpus/drift-baseline.tsv` → `^15$`; `grep -cv '^#' corpus/drift-symbols.tsv` → `^20$`.
4. Fix candidate for SKILL.md:512: "2 baseline WARN cells (transcript-scan.sh:78)". The host-DB value stays UNRUN by design.
5. R15-05's full expectation `runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` matches the rows: checklist-run.sh:242-245 counts runnable rows whose check matches `^bash[[:space:]]+corpus/`, giving E1, E5, H7 = 3. Static derivation; not executed.
