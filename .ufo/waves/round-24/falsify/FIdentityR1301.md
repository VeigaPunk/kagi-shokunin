# FIdentityR1301 — C3 / R13-01

## Verdict
**R13-01 identity mutant: KILLED at the frozen revision.** The claimed old count is preserved; the selector's membership digest changes; the only selected-row failure is R24-06. No survivor or invalid-mutant result for this row.

## Revision and population
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (sandbox clone at `/fast/scratch/kagi-r24-recovery/FIdentityR1301-9/lane`; clean immediately after checkout). No production files changed; no tools installed.

`corpus/claim-ledger.tsv:29` pins R13-01 to `grep -c '^## Round ' SCORECARD.md`, expected `29`; its note's population arithmetic is 25 at round-22 close + two round-23 + two round-24 headings = 29. R24-06 (`claim-ledger.tsv:69`) says it projects every matching heading line in file order, 27 at round-23 close + two round-24 = 29. `row-identity.sh scorecard-rounds` uses that same grep/file-order population. The old `build/IdentR1301.md` is explicitly a BASE (`4f94b52…`) report with count 27 and a surviving pre-C3 mutant; it is historical, not evidence for this frozen revision.

Pristine selector output: `ROW_IDENTITY: scorecard-rounds count=29 sha256=18e0c4fd9068addbdda53c056bdc4e1aa78b8a84d17cc8e4e1522756e9e2f38c` (matches R24-06). `grep -c '^## Round ' SCORECARD.md` returned `29`.

## Bounded control and mutant
Ran the R13-01 subset: R13-01 plus non-host R24-01..R24-16 (17 rows), excluding rows whose command invokes `claim-ledger.sh`, matching frozen `identity-swap.py` subset logic. Checks used `env -i PATH=/usr/bin:/bin HOME=<empty sandbox home> LANG=C.UTF-8`; no full harness or host rows.

Pristine control: `bash corpus/claim-ledger.sh verify --claims <17-row subset> --stamps corpus/stamps.tsv` exited 1; summary was `CLAIM_LEDGER: FAIL (claims=17 failed=0 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=488 labeled_ids=54 host_skipped=0)`. No selected-row `FAIL`/`POLICY` lines. Thus the selected control rows pass under the frozen instrument's row-level criterion; this is not a whole-ledger CLEAN receipt (the partial claims file leaves 488 unresolved IDs).

Applied exactly the assigned replacement in the sandbox: `## Round 9 — pre-move` → `## Round 90 — pre-move`; the unique target line remains a `^## Round ` match. The content stamp was refreshed in the sandbox from `e144b897… 885 103281` to `abad1bf35eb95ce98950fcf5d096b8ac3166899e4d05c7177c9f5834f2eef79b 885 103282`.

Mutant outputs: count remains `29`; selector is `ROW_IDENTITY: scorecard-rounds count=29 sha256=8e05d98f6717416c5e4ebdb0a91bb0158f2685321ed91a63f3a17be6eab1b9ce` (different membership digest). `row-identity.sh stamps` remains `count=83 sha256=136fde8b3656149c61f721eff42e1c0f973576a97d28eab2de079e962103b584`; verify reports `stale=0`. The same subset verify exited 1 with sole selected-row failure `FAIL R24-06 reason=verdict-not-final exit=0`; summary: `claims=17 failed=1 ... stamped=83 stale=0 ...`. R13-01's count expectation still passes. `claim-ledger.sh` marks a nonmatching final verdict as `verdict-not-final` (lines 548-555); here the final selector digest differs, while stamp drift and stamp-membership changes are ruled out.

## Residual risk / gaps
The control's process exit/global summary is FAIL because subset verification leaves unrelated document IDs unresolved; frozen `identity-swap.py` classifies by row-level FAIL/POLICY records and ignores that process status. This report therefore claims only the selected-row control and R13-01 kill, not a CLEAN full-ledger run. No LSP device was mounted (`read xd://lsp` returned no such tool); no LSP semantic checks were available. No other C3 population row was run.