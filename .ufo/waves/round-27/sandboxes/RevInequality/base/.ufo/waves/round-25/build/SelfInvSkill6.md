# SelfInvSkill6 — C1 current-tense numeric inventory, SKILL.md:651-778

Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03. Sandbox clone `/fast/scratch/kagi-r25/SelfInvSkill6/lane`; `git rev-parse HEAD` confirmed. Lane `SKILL.md` is `cmp`-identical to the BASE copy (778 lines; the range runs to EOF). Read-only: no lane edits, no lane git/jj mutation, no `verify`/`cells` on the real tree, no host rows, no installs or updates.

| file:line | phrase | CURRENT/HISTORICAL | claimed | live | source (ledger id or command) | STALE? |
|---|---|---|---|---|---|---|
| SKILL.md:749 | `--selftest` (R24-02, 14 cases) | CURRENT (registry row) | 14 cases | 14: `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)`, exit 0, 14 `case` lines | R24-02 `python3 corpus/closure-dispositions.py --selftest` (sandbox) | no |
| SKILL.md:750 | `--selftest` (R24-01, 22 cases) | CURRENT (registry row) | 22 cases | 22: `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0, 22 `case` lines | R24-01 `python3 corpus/rendered-text-v1.py --selftest` (sandbox) | no |
| SKILL.md:750 | (sources S027-S029, S031; S030 rejected) | CURRENT (registry row) | 4 included; S030 rejected | S027, S028, S029, S031 `mined`; S030 `rejected`; all tier A | `awk -F'\|'` status column, corpus/SOURCES.md:33-38 (no ledger row) | no |
| SKILL.md:751 | `row-identity.sh <selector>` (R24-03..R24-16) | CURRENT (registry row) | 14 ids | 14 rows, each `bash corpus/row-identity.sh ...` (claim-ledger.tsv:66-79) | `grep -cE '^R24-(0[3-9]\|1[0-6])[[:space:]]' corpus/claim-ledger.tsv` = 14 | no |
| SKILL.md:662-663 | "The three by-hand entries (`config-layering`, `control-plane-hardening`, `handler-trust-boundary`)" | CURRENT by tense (N2) | 3 | 3, same three names | R14-01 by_hand=3; `grep -l '^Reverify: by-hand:' corpus/knowledge/*.md \| wc -l` = 3 | no |
| SKILL.md:652-653 | `DOC_AUDIT: CLEAN (entries=17 row_linked=14 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`, exit 0 | HISTORICAL (N1) | entries 17; row_linked 14; by_hand 3; 0/0/0/0; exit 0 | entries 25; row_linked 22; by_hand 3; 0/0/0/0; exit 0 | R14-01 `bash corpus/claim-ledger.sh docs` (sandbox, exit 0); direct: 25 files, 22 non-by-hand | STALE (hist): entries 17→25, row_linked 14→22 |
| SKILL.md:654 | `DOC_AUDIT_RATIO: row_linked=14/17 floor=9 by_hand=3 duplicate_reasons=0` | HISTORICAL (N1) | 14/17; floor 9; by_hand 3; dup 0 | 22/25; floor 13; by_hand 3; dup 0 | R14-01 (same run); floor = ceil(25/2) = 13 | STALE (hist): 14/17→22/25, floor 9→13 |
| SKILL.md:752 | historical in-row set S001-S016 in the script | HISTORICAL (explicit "historical") | 16 | inrow=16; `HIST_RE='^S0(0[1-9]\|1[0-6])$'` at corpus/sources-census.sh:295 | R21-02 `bash corpus/sources-census.sh` (sandbox, exit 0): `inrow=16 inrow_only=0 inrow_nonreproducing=12` | no (hist) |
| SKILL.md:650 (adjacent, outside 651-778) | of the 17 `corpus/knowledge/*.md` entries | HISTORICAL (same bullet) | 17 | 25 | R14-01 entries=25; `ls corpus/knowledge/*.md \| wc -l` = 25 | STALE (hist) |

**CURRENT stale claims: 0 of 5** under the explicit-date rule (all five CURRENT claims at 662, 749, 750 ×2, 751 match live). Under the act-today rule (N1) the Round-14 repro rows 650/652/654 would count as CURRENT and STALE: 3.

Notes
- N1 (main finding; counterexample to the plan's population rule). SKILL.md:649-665 is a dated "Round-14:" bullet. I classed it HISTORICAL on two grounds: its date, and SKILL.md:669-670 ("command outcomes … earlier in this file are historical"). But its lines are written as executable present-tense repro expectations; a reader who runs them today gets 25/22 and exit 0. Two tests conflict: "a reader would act on it today" (CURRENT) and "explicitly dated" (HISTORICAL, your own example "round 21: 59 cases"). I applied the explicit-date test. The C1 plan exempts "explicitly round-dated, in LOG/lessons/SCORECARD history"; this block is in SKILL.md, a live registry file, so the literal exemption does not clearly cover it. Read literally, SKILL.md:650/652/654 enter the BASE population as STALE rows. Options for L1: re-date and point at R14-01, or widen the exemption. I have not decided this.
- N2. SKILL.md:662 is CURRENT by tense though it sits in the dated bullet. Live agrees (3), so the stale count does not depend on the call.
- N3. Excluded from population (not current lane-artifact counts): synthetic fixture expectations at 655-661 (copied-root cases: "one", "two", "three", `R9-99`, `floor=2`, exits 1/2); exit-code maps 0/1/2 at 696-699, 703, 748-752; "accepts at most one entry directory" (721, CLI arity); `host_skipped=N` (755, placeholder); round/ID labels (Round-22, R12-03, S022/S023, QA10, C1/C3, QM12/QM15, R21-01, SHA-256, H2). Lines 689-690 explicitly disclaim a current selftest tally.
- N4. Outside range, not inventoried: SKILL.md:46 "63 stamps + 39 claims … round 21". Live: 83 stamps (`grep -c '[^[:space:]]' corpus/stamps.tsv`, R12-03) and 61 claim rows (`grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv`, R21-04). Its "round 21" qualifier is an explicit date, so the classifier must decide whether a dated parenthetical in a registry row is HISTORICAL. The plan's D1 treats it as stale.

Verification record (sandbox; every run `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/SelfInvSkill6/home TMPDIR=/fast/scratch/kagi-r25/SelfInvSkill6/tmp`, cwd = sandbox lane)
- `cmp` lane vs sandbox SKILL.md: identical, exit 0; `wc -l`: 778.
- `closure-dispositions.py --selftest`: exit 0, `PASS (14 cases)`. `rendered-text-v1.py --selftest`: exit 0, `PASS (cases=22)`.
- `claim-ledger.sh docs` (R14-01): exit 0, `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`, `DOC_AUDIT_RATIO: row_linked=22/25 floor=13 by_hand=3 duplicate_reasons=0`.
- `sources-census.sh` (R21-02): exit 0, `SOURCES_CENSUS: CLEAN (rows=32 ... inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
- Direct counts: `ls corpus/knowledge/*.md` 25; by-hand 3; non-by-hand 22; R24-03..16 rows 14; stamps 83; R-id rows 61.
- R14-01 and R21-02 are untagged, non-host ledger rows, run only in the sandbox clone. That goes beyond selftest-only, so it is flagged here. Every value they produce has a direct-count cross-check except the ratio/floor, which is arithmetic (ceil(25/2)=13) and agrees.
- UNRUN: none in range. Out-of-range values in N4 are grep counts only.
- Installs or updates: none. This report is the only file written.
