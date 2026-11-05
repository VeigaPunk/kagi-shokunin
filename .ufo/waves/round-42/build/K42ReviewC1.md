# K42ReviewC1 — round-42 pre-freeze attack findings on claim C1 (reviewer, leaf)

Sandbox: shared clone at 98dd4de, toplevel asserted, no lane edits, scratch removed at yield.
Full attacks with evidence and verdicts: `.ufo/waves/round-42/build/K42ReviewC1/attacks.md`
(+ `receipts/`, 24 files incl. the four fake gates and the patched gate copy). The C1 counter is
unchanged by amendment A1 (empty `git diff 98dd4de fdbb83d -- plans/round-42-c1.sh`); harness
validated: committed counter + committed gate = N=4 = committed `c1-base.txt`.

1. **[NOT-DEFECT]** Append-only premise verified over the FULL history: 42 commits / all 41
   consecutive pairs of `corpus/claim-ledger.tsv`; 18 pairs changed the id set, all pure
   additions; `removed=[]` everywhere; no id was ever removed or re-added.
2. **[NOT-DEFECT]** F5 premise exact: `R17-02` is line 46 of base 6cc8850 (and of P0 6f1588c);
   zero occurrences in the round-40 and round-41 journals at 209147c.
3. **[DEFECT — undeclared ceiling]** The frozen C1 counter cannot discriminate an answer-key gate:
   a hardcoded per-id fake that accepts P0 and refuses F1–F5 reads **N=5** with both blanket
   controls at 0 (receipts/item3-fakeC.txt). Journal-blind gates cap at **N=2** (F2's fixture
   ledger is byte-identical to P0's; F1's and F3's are byte-identical to each other under two
   different required tokens); a blanket-refuse-shaped fake reads 0 via the P0 precondition.
   Scope: the predicate/target/kill rules need no change — but §C1 must declare this ceiling
   exactly as §C2 declares its constant-runner ceiling; kill rule (c) + code review are the only
   remaining controls. This is the one surviving defect of the round.
4. **[NOT-DEFECT]** Kill rule survives a faithful DELETED rule: BASE gate + 6-line DELETED loop
   keeps the round-41 landing check (5142b52 → 209147c, rc 0, `CLEAN (changed=6 journaled=6)`)
   and P0 CLEAN; refuses F5 (`REFUSE DELETED R17-02`, rc 1); landing id-set diff `removed=[]
   added=[]`; BASE selftest green (PASS cases=7) before the F5 case is added.
5. **[VERDICT: calibration]** C1 enforces the corpus's already-stated append-only rule (S094)
   that the round-41 gate classes silently omitted; the class is added to the gate's documented
   frozen rules + selftest (kill rule c), so self-description and behavior stay discriminated.
   Name in the lesson: the new input dimension (row presence) and the attack-3 answer-key ceiling.

Tooling: nothing installed or upgraded (operator authorization noted; pacman paused host-wide;
existing git/python3/bash sufficed).
