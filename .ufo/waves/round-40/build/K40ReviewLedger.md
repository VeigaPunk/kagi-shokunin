# K40ReviewLedger — seat report (round 40, C1 attack) — FINAL

Seat: reviewer-leaf under L1 planner (KagiR40). Frozen plan 38a118f9cf15729e7732cc3cafe1011e3a899ee4; candidate cb3f642479a09644a03874909bb7e44b52697a8d; BASE 6cc8850dfc5757927699e5a53a876f47c8df21aa; predeclaration f687504767ce9ed56b848dfde83e03a1ec6cedd3.

Tool installs: none. No pacman calls (host guard respected). No git/jj mutation anywhere in production; all attacks ran in a scratch copy made with `cp -a` (not `git clone`) of the lane at candidate.

Scratch root: `/fast/scratch/hyaku/kagi-r40/K40ReviewLedger/` {clone/, variants/<a1|a2|a2b|a4|a4b|a6|a6b|a7|clean>/, work/, shims/}. Production lane untouched.

## Baseline reproduction (candidate, executed)

```
$ cd /fast/scratch/.../clone && bash plans/round-40-c1.sh
real 5m35s
stdout: 0
rc=0
```
Matches plan C1 target **0** at the landing candidate; plan says BASE 6 (measured elsewhere by the round receipts — `.ufo/waves/round-40/controls/c1-base.txt` present in the candidate tree's committed `.ufo` with the receipt `6`, plus `base-verify-at-tip.txt` with `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` and rc=2). The frozen plan's own no-work at BASE stays 6 as measured; not re-run at BASE to save the round's compute budget (the pre-wrapped receipt is committed; C1's job is to re-run at the LANDING tree, exactly reproduced).

```
$ bash corpus/claim-ledger.sh verify          # 5m10s
CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)
rc=2
```
FAIL rows (all outside the set): R11-08, R22-03, R24-15, R25-02, R36-03 — matching the plan's list exactly. POLICY rows: R29-01, R29-02, R38-03.

## Attack results

| # | attack | exact result | verdict |
|---|--------|--------------|---------|
| 1 | delete one of six set rows (R13-01) from a scratch-copy ledger, run the counter | `counter-refused: R13-01 absent from claim-ledger.tsv`, rc=2, stdout empty (4m31s) | **counter-refused — KILLED.** Fail-closed as the frozen predicate requires. |
| 2 | move one expect to a WRONG value (R13-01 `^54$` → `^999$`, command/exit/timeout untouched) | stdout `1`, rc=0 (4m37s) | **counted honestly — KILLED.** The counter reads 1, not 0; the RUN STOPS. No shortcut to 0 via a wrong expect value. |
| 3 | blind the summary: counter run against a shimmed `corpus/claim-ledger.sh` that drops `CLAIM_LEDGER:` summary lines (rc forwarded) | `counter-refused: no CLAIM_LEDGER summary (rc=2)`, rc=2, stdout empty (4m51s) | **counter-refused — KILLED.** No integer printed. |
| 3b | same on the CLEAN candidate variant (rows intact, only summary suppressed) | rc=2, stdout empty, `counter-refused` | same — KILLED. Re-shot with a clean tree so the refus cannot have been triggered by attack-1's removed row instead of the missing summary line. |
| 4 | MISSING-ID line naming a set id from an unrelated file — counted or not? | two sub-probes below | predicate-ALIGNED; judged (see below) |
| 4b (sub-probe) | `printf 'Attack probe fabricated R13-01 mention … mentions R13-01e percent.\n' >> AGENTS.md`; run `bash corpus/claim-ledger.sh verify --claims tmp-claims.tsv` | `LABELED-ID AGENTS.md:6 R13-01e (labelled on its line)`; NO `MISSING-ID` line, because R13-01 IS a row in the claims file (`is_row` → silently CITED, never printed unless `--orphans`) | idref SCANS all of AGENTS.md first (the doc list order is AGENTS.md LOG.md PROVINCE.md SCORECARD.md SHONEN.md SKILL.md corpus/README.md knowledge/*.md lessons/*.md) and the temporal rule is: a doc id token resolves iff the CURRENT ledger holds a row with that id. **A fabricated MISSING-ID line naming a set id that IS a ledger row CANNOT be produced.** Therefore the attack-4 shortcut is impossible on the real verify+counter pair. KILLED. |
| 4c (sub-probe) | same AGENTS.md line but with the claims file holding ONLY R13-01 (so the OTHER five set ids have no row) | `MISSING-ID corpus/lessons/round-40.md:14 R21-02` … `<R24-06/R31-02/R33-02/R34-03>` printed for all five non-row set ids + `LABELED-ID AGENTS.md:6 R13-01e` | confirms the mechanism produces MISSING-ID only for ids that are NOT ledger rows. In the real 86-row ledger all six set ids ARE rows → zero MISSING-ID lines with set ids exist in the counter's real input. `grep -E '^(FAIL|STALE|MISSING|MISSING-ID)' verify-at-candidate.txt | grep -cE ' R13-01 \|R21-02 \|R24-06 \|R31-02 \|R33-02 \|R34-03 '` → **0**. KILLED. |
| 5 | migration-journal audit of the six `old_expect` against `git show 6cc8850:corpus/claim-ledger.tsv` rows byte-for-byte — DONE | see below | **clean — all six match byte-exactly** |
| 6 | confirm R25-02/R29-01/R29-02/R38-03/R11-08/R22-03/R24-15/R36-03 rows byte-identical BASE vs candidate — DONE | all 8: byte-identical (`BASE-lines 1 CAND-lines 1`, python compare `b==c`) | **clean** |

## Attack 5 detail (migration audit, exact)

`expectation-migrations.json` is present in the candidate tree (committed, tracked: `git ls-files` shows it) and NOT present at BASE 6cc8850 (`git ls-tree -r --name-only 6cc8850 -- .ufo/waves/round-40` → empty), consistent with "this file is committed alone after that gate".

For each of the six ids, `expect` cell (tab field 3) was extracted from both BASE-at-`6cc8850` and candidate rows, hashed and JSON-parsed:

| id | old_expect == BASE cell | new_expect == candidate cell |
|---|---|---|
| R13-01 | True (len 4 vs 4) | True (len 4 vs 4) |
| R21-02 | True (164 vs 164) | True (164 vs 164) |
| R24-06 | True (113 vs 113) | True (113 vs 113) |
| R31-02 | True (164 vs 164) | True (164 vs 164) |
| R33-02 | True (164 vs 164) | True (164 vs 164) |
| R34-03 | True (164 vs 164) | True (164 vs 164) |

Per-row tab-column diff between the BASE row and candidate row: diff-fields `[2, 5]` (expect + note cell) for five ids, `[2]` for R34-03. Command (field 1), exit (field 3), timeout (field 4) byte-identical for all six — asserted with `assert bb[1]==cc[1]` etc (passed). The plan's rule "each of the six rows' `expect` moves to the value its command produces at the measured tree, with every old→new pair recorded" is satisfied note-for-note. The five rows whose note cell changed gained ONLY round-40 history text; R34-03's note cell is unchanged. Rows' id, command, exit, timeout untouched.

## Attack 4 judgment (against the frozen predicate sentence — verbatim quotes)

Plan sentence (plans/round-40.md, C1 "Frozen predicate"):
> "the count is over exactly the six named ids; no other row's state enters the number; the migrations are round-38-style measured rebindings — each of the six rows' `expect` moves to the value its command produces at the measured tree, with every old→new pair recorded in `.ufo/waves/round-40/expectation-migrations.json`."

Plan fail-closed clause (same section):
> "Fail-closed: exit 2 (no integer) when verify produces no `CLAIM_LEDGER:` summary, verify dies, or any of the six ids is absent from `corpus/claim-ledger.tsv`."

Counter header (identical sentence, plans/round-40-c1.sh):
> "Fail closed (exit 2, no integer): verify produces no `CLAIM_LEDGER:` summary line, verify dies before its summary, or any of the six ids is not a row of corpus/claim-ledger.tsv."
> "Non-set rows (R11-08, R22-03, R24-15, R25-02, R36-03 and the historical MISSING-ID classes) are outside this population by design and never counted here."

Judgment: the predicate sentence counts verify-reported verdict lines carrying a set id — irrespective of which doc produced the idref line. A MISSING-ID line CAN exist in verify output only when the named id has no ledger row; since all six set ids ARE rows, the only way to fabricate such a line is to REMOVE the ledger row for that id — and then the fail-closed row-presence grep fires and the counter refuses (attack 1). The two mechanisms are mutually locked: either the set id is a row (no MISSING-ID possible; the counter looks at its real command verdict) or the id is not a row (the counter refuses outright). **No surviving attack survives both mechanisms.** The counting is faithful to both quoted sentences, without gaps.

## Attack 7 (extrapolated rollback probe, run for completeness)

After constructing a7-rollback variant (ledger expects for R21-02/R31-02/R33-02/R34-03 reverted to BASE `rows=93…` AND corpus/sources-census.sh patched to print `rows-3 A-3 mined-3 captures-3` → `rows=93 A=89 … captures=93` — an instrument-rollback shortcut making old green expectations match a degraded instrument):
```
$ bash plans/round-40-c1.sh     # 4m43s
stdout: 0
rc=0
```
**Shortcut SUCCEEDS as several expected**: a rolled-back instrument satisfies stale expectations and the counter cannot see the journal is stale. This is NOT a defect of the counter per se (the counter's contract is to read what verify says; the journal is the AUDIT that the closure is supposed to re-derive — the plan's closure step, not the counter, catches this). The round-38-style re-binding is an instrument-coupling, not a counter-coupling. Recorded as a **ceiling observation**: the C1 counter itself does not detect an instrument rollback; it relies on the closure audit (out of a reviewer seat's scope) — same named ceiling as plan §C1 "the claim re-binds self-description; it does not certify that each migrated number is the right historical claim — only that it is the value the committed tree re-derives today, with the old value recorded."

## Extra: rebind-to-unrelated-green-command probe (attack 2b, run)

Variant: R13-01's command re-bound to `grep -c '^# claim-ledger' corpus/claim-ledger.sh` expect `^1$` (matches, exit 0, none of the six census costs).
```
$ bash plans/round-40-c1.sh     # 4m47s
stdout: 0
rc=0
```
**Shortcut SUCCEEDS**: the counter cannot tell a rebound-to-trivial-command set row from a genuine round-38 migration; the journal (committed, in-tree) is the only thing that binds R13-01's command to `grep -c '^## Round ' SCORECARD.md`. A closure auditor re-deriving journal.command vs ledger-TSV row field 1 would catch this divergence (journal field `command` for R13-01 is `grep -c '^## Round ' SCORECARD.md`, byte-match of the candidate row at the same tab cell). So: the **counter alone is insufficient** (the counter is aligned with its frozen predicate — this is a named ceiling in the plan, but the divergence between the journal and the real re-bounded row is a shortcut) *given only the counter*; with the plan's closure re-derivation step applied it is killed with the journal as evidence.

## Not run (named, honestly)

- Full C1 counter re-runs at the LANDING tree (only the candidate reproduced, 0; a further 5m35s per variant was already the per-attack cost).
- The counter's census-coupled gate selftest invocation cross-check inside a variant tree.
- The C2/C3 counters and gate selftests (other seats' scope: ExecCurrency/ExecGates/MutGates/R40Gates) — untouched.

## Receipts index

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-40/build/K40ReviewLedger/attacks.md` — this file's attack log (same content, scratch-era draft + final table).
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-40/build/K40ReviewLedger/mutants/` — attack variants and command transcripts as executed.
