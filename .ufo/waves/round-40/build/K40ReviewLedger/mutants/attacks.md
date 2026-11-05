# attack log

Each entry: exact command(s), exit code, captured stdout/stderr.

## A0 baseline reproduction (candidate, no mutation)
cd /fast/scratch/hyaku/kagi-r40/K40ReviewLedger/clone && bash plans/round-40-c1.sh
→ rc=0, stdout "0", 5m35s. Candidate C1 = 0 (target met).

A0b: bash corpus/claim-ledger.sh verify → rc=2, summary `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`; FAIL rows R11-08/R22-03/R24-15/R25-02/R36-03, POLICY rows R29-01/R29-02/R38-03, MISSING-ID lines named only non-row historical ids (R32-*, R33-*, R34-2/3, R35-*, R36-*), never any of the six set ids (0 exact-token hits for any set id on a counted line).

## A1 delete set row (R13-01) from scratch-copy ledger
bash work/fix-a1-delrow.sh <variant>   # grep -v '^R13-01\t' > .new && mv
cd variants/a1-delrow && bash plans/round-40-c1.sh
→ rc=2, stdout empty, stderr `counter-refused: R13-01 absent from claim-ledger.tsv` (4m31s)
KILLED: fail-closed row-presence branch fires; no integer.

## A2 wrong expect value (R13-01 → ^999$)
bash work/fix-a2-wrongexpect.sh <variant>   # python line-edit of tab field 3
cd variants/a2-wrongexpect && bash plans/round-40-c1.sh
→ rc=0, stdout "1" (4m37s)
KILLED: reading 1; mismatch is counted; no path to 0.

## A2b rebind R13-01 to unrelated green command (grep -c '^# claim-ledger' corpus/claim-ledger.sh, ^1$, exit 0)
cd variants/a2b-rebind3 && bash plans/round-40-c1.sh
→ rc=0, stdout "0" (4m47s)
SURVIVED (counter-level; ceiling):
expectation-migrations.json records R13-01 command grep -c '^## Round ' SCORECARD.md, so the closure re-derivation catches it; the counter alone cannot.

## A3 blind summary (drop CLAIM_LEDGER lines via PATH shim)
bash work/run-shimmed.sh variants/a1-delrow drop-summary
→ rc=2, stdout empty, stderr `counter-refused: R13-01 absent from claim-ledger.tsv` (row-presence refused first)
A3b on clean candidate variant: bash run-shimmed.sh variants/clean drop-summary
→ rc=2, stdout empty, stderr `counter-refused: no CLAIM_LEDGER summary (rc=2)` (from bg job, transcript-captured)
KILLED both: no integer printed.

## A4 unrelated doc MISSING-ID probes (idref)
A4: appended label-bearing probe line to AGENTS.md; verify --claims tmp-claims.tsv → `LABELED-ID AGENTS.md:6 R13-01e (labelled on its line)`; no MISSING-ID (R13-01 IS a row → CITED silently).
A4b: appended unlabeled line `This file mentions R13-01 ph …` to AGENTS.md; verify --claims tmp-claims.tsv (only-row fixture) → R13-01 silently CITED; ids NOT in the fixture (R21-02/R24-06/R31-02/R33-02/R34-03 as lesson tokens) print MISSING-ID.
Conclusion: MISSING-ID lines with set ids are impossible in real-87-row verify output because is_row is true for all six; fabricating one requires removing the row → A1 refusal. `grep -E '^(FAIL|STALE|MISSING|MISSING-ID)' verify-at-candidate.txt | grep -cE ' (R13-01|R21-02|R24-06|R31-02|R33-02|R34-03) '` → 0.
KILLED (mutually locked with the row-presence branch).

## A5 migration-journal audit
python byte-compare of expectation-migrations.json old/new vs BASE(6cc8850)/candidate expect cells: all six True; row diff-fields only [2,(5)] (expect+note); command/exit/timeout id-identical. Journal not present at BASE (committed by design in the candidate).

## A6 outside-row byte-identity (R25-02,R29-01,R29-02,R38-03,R11-08,R22-03,R24-15,R36-03)
python compare of full lines BASE vs candidate: all 8 byte-identical (BASE-lines 1 CAND-lines 1).

## A7 instrument rollback (stale expectations + rolled-back census)
saw ledger expects R21-02/R31-02/R33-02/R34-03 → BASE rows=93… text; patched sources-census.sh summary args rows-3 A-3 mined-3 captures-3 (prints rows=93 A=89 … captures=93 as confirmed by a live census run).
cd variants/a7-rollback && bash plans/round-40-c1.sh → rc=0, stdout "0" (4m43s)
SURVIVED (counter-level; ceiling): a rolled-back instrument satisfies stale expectations; journal is the closure-audit's catch, not the counter's.

## A6c delist shortcut probes (counter list manipulation)
A6: counter ids= line missing R13-01, ledger untouched → rc=0, stdout "0" (4m45s)
A6b: counter ids= missing R13-01 AND ledger R13-01 row comment-ized (# prefix, so ^R13-01<TAB> absence masked as a non-row) → rc=0, stdout "0" (4m44s)
SURVIVED (counter-level; document-integrity ceiling): the counter cannot detect that IT was edited; kill rules place the counter under the frozen-plan hash discipline (plans/round-40-c1.sh is itself committed; any edit is a no-longer-frozen counter and fails the closure's counter-identity check against the frozen text, which I verified byte-matches the shipped file outside variants).
