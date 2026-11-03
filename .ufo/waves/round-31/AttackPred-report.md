# AttackPred — report (same content as build/AttackPred.md)

Full findings with evidence and verdicts are in `.ufo/waves/round-31/build/AttackPred.md`. Summary:

- C1 MUST-FIX: F1 (UNCITED cells pass the grader), F2 (`cells >= 210` ungraded; H3 silent drop passes at cells=204), F3 (FAIL/POLICY set equality vs prose subset), F4 (stamp re-pin omits `corpus/claim-ledger.tsv`), F5 (correction-1 R11-08 exception rests on a premise cells mode does not exhibit: R11-08 is SKIP-SELF).
- C1 NOTE: F6 (migration measurement order; round-31 headings are scored cells), F7 ("causally separable" is false; correction 1 closes the numeric coupling), F13 (12 HOST-SKIP + 5 SKIP-SELF invisible), F15 (no honest-run format false-fail).
- C2 MUST-FIX: F8 (tier-A, date and body-id clauses ungraded; census reads only `source:`), F9 (S095 JP page self-declares "flip to C"; kill rule silent), F10 (C2 re-freeze path open; correction 1 covers C1 only).
- C2 NOTE: F11 (`legacy=21` content-blind), F12 (`rows=71` counts ids not identities).
- Controls: both BASE controls reproduced; a do-nothing round cannot reach either predicate (F14).

Pre-data state: lane HEAD `2d46e57` (plan correction 1 on `4767b04`); no work commit. Scratch experiments are deleted; no lane writes; no installs; no credential, vault, network or pacman use.
