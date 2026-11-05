# K41ReviewJournal — scoped findings (round 41, BEFORE evidence + attacks on C1)

All commands executed as documented in `build/K41ReviewJournal/notes.md`; nothing below is assumed.
Sandbox teardown confirmed before this report was filed.

## Measured BEFORE evidence (four parallel sandbox clones at P0 6f1588c, `bash corpus/claim-ledger.sh verify`, timeout 900 each)

| Forgery | rc | Summary line | Any line naming the forged id |
|---|---|---|---|
| F1 (R13-01 expect := `^[0-9]+$`, journal entry removed) | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` | none — accepted silently |
| F2 (journal R21-02 old_expect := new_expect; ledger unchanged) | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` | none — accepted silently |
| F3 (R13-01 loosened + journal new_expect := same) | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` | none — accepted silently |
| F4 (R24-06 command := echo of its expected line) | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=4 stamped=122)` | `POLICY R24-06 reason=first-token:echo` |

Durations 345/345/346/346 s. Pairwise diffs prove F1/F3/F4 differ from the F2 (P0) baseline only by
the stamps `STALE corpus/claim-ledger.tsv …` line, the R22-03/R24-15 flip, and F4's extra POLICY
line — no other line moves.

**Findings:**
1. F1–F3 confirm the round-40 spot-check: the pre-change gate has no journal semantics; unjournaled
   loosening (F1), journal laundering (F2) and journaled-but-non-literal loosening (F3) all pass
   without any line naming the forged row.
2. **Erratum candidate for the plan §C1 existing-gate control:** "accepts F1–F4 by construction" is
   measured FALSE for F4's echo construction — the old gate's policy allowlist refuses the rebind
   before execution (`first-token:echo`), never exercising the forged output. The control still
   discriminates the two mechanisms (old: whole-run POLICY rc 2; new: `EXPECT_JOURNAL: REFUSE
   COMMAND_MISMATCH R24-06` rc 1), but the round report should not state blanket acceptance of F4.
3. The whole-run verdict at P0 is rc 2 POLICY (standing operator-owned rows R29-01/R29-02
   `first-token:python`, R38-03 `python-script`), so this control must be adjudicated per-row, not
   by run rc. Landing-time readers should expect the same three standing POLICY rows.
4. Environmental, non-forgery deltas explained and grounded: stamps STALE fires on the edited
   ledger FILE in F1/F3/F4; R22-03/R24-15 measure `added=59`/`count=59` in a clean clone vs the
   ledger's landing-tree `added=49`/`count=49` (executed directly in F2, rc 0), flipping their FAIL
   reasons between pristine and edited clones. Neither touches the forged rows.

## Attacks (build/K41ReviewJournal/attacks.md — 11 total, 7 required classes plus 4)

Predicted-refusal set: A1 (non-`.json` journal → UNJOURNALED), A3 (trailing CR on expect cell →
NEW_MISMATCH + NOT_LITERAL), A4 (trailing whitespace in journal id → UNJOURNALED), A7 (loosened
expect in a duplicate-id second row → UNJOURNALED row-wise), A9 (bare `[` → NOT_LITERAL), A11
(unjournaled + non-literal overlap → both tokens greppable). Predicted-accept set: A5 (orphan entry
must only WARN, rc 0), A6 (row deletion — frozen classes are silent: recorded blind spot), A8
(properly journaled command rebind must be ACCEPTED — positive path), A10 (over-escaped literal —
accepted by the disclosed ceiling). A2 (duplicate migration id) is implementation-divergent by the
frozen text and must be decided by the L1's post-landing run.

## Ambiguities (build/K41ReviewJournal/ambiguities.md — 15 items, sentence by sentence)

Pinned by the counter: token lines include ids, P0 gatekeeping, forgery "its"/echo targets,
separability. Under-determined by the frozen text (implementation will silently decide): row-pairing
key under duplicate ids, byte-literal vs normalized compares, entry quantification with duplicate
ids, escape-pair scanning in R3, orphan accounting in the final line, and — material for the kill
rule — the BASE revision (6cc8850 vs 19025d9) for the six-migration landing check, which only the
counter's fixture block pins (6cc8850).

## Defects to route (not fixed in the lane by this seat)

- Plan §C1 existing-gate-control sentence overstates F4 acceptance (finding 2 above).
- Gate blind spot: candidate-ledger row DELETION is refused by nothing (attack A6) — the frozen
  class set referees changes only; worth one sentence in the round lesson's disclosed ceilings.
- Standing P0 rc-2 POLICY baseline means every `claim-ledger.sh verify` control in this round ends
  POLICY before FAIL/STALE reach the summary line.

Tooling installed: none. Lane mutations: none. `verify` invocations: four (one per sandbox clone).
