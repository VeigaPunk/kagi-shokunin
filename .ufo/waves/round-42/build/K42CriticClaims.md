# K42CriticClaims — scoped findings (round 42, pre-freeze critic)

Full evidence, commands and outputs: `.ufo/waves/round-42/build/K42CriticClaims/critic.md`. Receipts and reference patches are in the same directory. No lane edits; no commits; scratch deleted at yield.

## Verdicts

- N1 NOT-DEFECT — C1 BASE 4 vs target 5; do-nothing cannot reach 5.
- N2 NOT-DEFECT — controls runner from a clean clone reads 4 / 0 / 0 / D 1 / 0 (receipt byte-diff only from a 17-line detached-HEAD stderr note).
- N3 NOT-DEFECT — A1 holds: frozen `5142b52` counter byte-identical to `98dd4de`; D re-derives to 1; worktree reading 3.
- N4 NOT-DEFECT — C1 touches `corpus/expect-journal.sh` only; C2 touches `plans/round-41-controls.sh` only.
- N5 NOT-DEFECT — census: `kagi ok`, rows 98, A 94, B 2, C 2, mined 93, queued 1, rejected 4.
- N6 NOT-DEFECT — no ledger-id deletion in 40 ledger commits; landing check CLEAN (6/6) with the reference rule.
- N7 NOT-DEFECT — reference C1 `DELETED <ID>` rule reads 5 and refuses `R17-02` with the frozen token.
- F1 DEFECT (C2, high) — a `exit 0` runner reads the committed receipt `1`; counter prints 1. Target reachable by do-nothing.
- F2 DEFECT (C2, high) — counter copy is the lane's `plans/round-41-c2.sh`; a one-line `echo 1` tamper passes. A1 froze D only.
- F3 DEFECT (both, medium) — counters and runner read from the candidate tree; no kill rule pins them to `98dd4de`.
- F4 DEFECT (C1, medium) — claim header is universal ("an unjournaled ledger-row deletion is refused"); counter tests one row.
- F5 DEFECT (C1) — ceiling sentence "whose id survives" is self-contradictory.
- F6 DEFECT (C1) — kill rule (c) names no command or case; selftest still `cases=7`.
- F7 DEFECT (frontier) — S094 locator "SOURCES.md Rules item 2, line 116" is wrong (CORPUS.md rule 2, line 116 at f47ad6b); the rule governs registry rows; QM14 (`corpus/QUALITY.md:73`) is the in-lane rule for C1.
- F8 DEFECT (frontier) — "Mistake mined: M41-4 (below)" has no referent; round-41 lesson mines M41-1..3 only.
- F9 DEFECT (C2 ceilings) — F1 and F2 undeclared.
- F10 DEFECT (minor) — "claim BASE" used for `e8265c0` and `19025d9`; stray "Considerthese" token.

## Reference deliverables (sandbox, uncommitted)

- `reference-c1-deleted-rule.patch`: counter 5; landing CLEAN (6/6); selftest PASS (cases=7).
- `reference-c2-runner-archive.patch`: C2 BASE line from `git archive 19025d9`; reads 1. Still open to F2.

## Not checked here

Mutation runs, the candidate scoring and the full claim-ledger verify (outside this seat's assignment). Live CORPUS.md re-open used `curl -fsSL` at the pinned revision on 2026-11-05.

## Tooling

No installs. Used `curl`, `git`, `bash`, `python3` (already present). No new tools recorded.
