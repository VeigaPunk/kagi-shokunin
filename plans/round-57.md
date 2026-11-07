# Round 57 — plan (frozen predeclaration before candidate work)

Lane kagi, round 57, attempt 1. Claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`
(the round-56 verifier spot-check tip). Frozen instruments: this plan,
`plans/round-57-c1-check.py`, `plans/round-57-c1.sh`, `plans/round-57-c2.sh`,
`plans/round-57-controls.sh`. The predeclaration commit that carries them lands
before any candidate edit or candidate measurement; instrument hashes are printed
by `plans/round-57-controls.sh` (`INSTRUMENT` lines).

Motivating evidence (round-56 verifier spot-check, non-author:
`corpus/lessons/round-56-verifier-spotcheck.md`):
- D5/D6: five committed current-tense self-descriptions of last round's own
  instruments were stale at the tip — `SCORECARD.md:1850` "`--selftest` 18 cases"
  (the gate prints 20), the capability row and the appended note naming epoch E/D
  receipts while epoch F is authoritative, `LOG.md:1924` "four freeze epochs"
  and `corpus/lessons/round-56.md:9` "Three freeze epochs" against the six the
  plan declares. No lane gate read any of them.
- Routed item: the round-56 closure measured `value=3` by hand; the lane had no
  standing check for the class.

## C1 — calibration: the audited surface's numeric self-descriptions agree with their authorities

Frozen predicate (verbatim; the same sentence is in the counter header):

    C1_CURRENT: value = MISMATCH+UNBOUND over POP when GUARD = 1, else FAIL;
    target 0 (BASE 3), population floor 8.

POP (round-57): every statement of the four declared classes inside the audited
surface — `SCORECARD.md` `## Round 56 — post-move`, `LOG.md` `## Round 56 (`, and
`corpus/lessons/round-56.md` header + `## Claims`:
- `N cases` on a line naming `recheck-replay` → the instrument's own
  `--selftest` PASS count (20);
- `N MATCH` on a line naming a receipt path → that receipt's
  `CONTROLS: match=N mismatch=0`; on a line with several numbers and no receipt
  path, each number pairs with the nearest preceding `A`–`F` letter followed by a
  backticked revision;
- `W freeze epochs` → the distinct `epoch-[A-F]` tokens declared in
  `plans/round-56.md` (6);
- `N clocks` and `N/N MATCH` → the data rows of `corpus/recheck-captures.tsv` (10).

BASE reading: `C1_CURRENT: value=3 population=16 gate=0 guard=1` — the three
mismatches named in the motivating evidence (cases 18→20, LOG epochs four→six,
lesson epochs Three→Six). The measured capability row's "22 MATCH" names epoch E
and is numerically true of epoch E; the defect there is the reference, repaired
with the same row and recorded, not counted.

Landing: repair the three counted statements; repair the two epoch references
(capability row → epoch F / 23 MATCH; round-56 note → epoch F); land the reusable
gate `corpus/current-claims.py` (same classes, `--root`, `--selftest`) so the
class is checked every round instead of by hand.

Kill rules (any one fails the claim): (a) the landing tip reads `value=0` with
`population>=8`; (b) any of K1-F1..K1-F4 does not read its frozen expectation;
(c) the committed gate's `--root` reading at the landing tip differs from the
frozen checker's value/population. Do-nothing control: BASE reads 3 (target 0).

## C2 — operability: OpenBao audit-device custody trial (capability acquisition)

Frozen predicate (verbatim; the same sentence is in the counter header):

    C2_AUDIT_TRIAL: value = PASS when the trial's real run is `AUDIT_TRIAL: CLEAN
    (tests=5 pass=5)` and each of the five falsifier shims flips exactly one test
    to BROKEN (`AUDIT_TRIAL: FAIL ... pass=4`), else 0; target 5 (BASE 0).

POP (round-57), all against a throwaway `bao server -dev` on 127.0.0.1 with the
random root token kept only in scratch, no secret on any argv, no server log:
- T1 `bao audit enable file file_path=<scratch>` then `bao audit list` names `file/`;
- T2 a KV write's audit entry exists for request and response, carries the
  default `hmac-sha256:` value form, and the written plaintext does not occur;
- T3 a second device with `log_raw=true` records the same value in raw form while
  the default device still HMACs it;
- T4 `bao audit disable file/` then re-enable at the same path creates a new salt:
  the same value's HMAC after re-enable differs from before;
- T5 the documented non-audited `sys/seal-status` path (`bao status`) leaves no
  audit entry while a KV read in the same window does.

Sources: S115 `https://openbao.org/docs/audit/` and S116
`https://openbao.org/docs/commands/audit/`, both opened live 2026-11-07 with the
browser user agent (default UA: not yet tested); the HMAC/salt/non-audited-path
sentences and the `log_raw` and `hmac_accessor` parameter rows are the ground.

Landing: `corpus/openbao-audit-trial.sh` (tests above, `--work DIR`, shims
`KAGI_AUDIT_SHIM=SH1..SH5`), `corpus/knowledge/openbao-audit-device-custody.md`
(entry with `source:`, `verified-at:`, `recheck:`, measured table, bounds,
falsifiers), registry rows S115/S116 (tier A, status mined), capability row,
coverage-map row.

Kill rules: (a) the landing tip reads `value=5`; (b) a shim leaves the real run
at 5/5; (c) the trial or its receipts print a token-shaped string, a vault ref, or
the written value. Do-nothing control: BASE reads 0 (trial absent); K2-STUB (a
printer that ignores the shims) reads 0; K2-MOCK (a shape-keyed mock that honours
the shims without mechanics) reads 5 — the declared ceiling, the live mechanics
and the non-author probe are the check.

## Pre-freeze controls (executed before this commit, receipt under the wave dir)

`bash plans/round-57-controls.sh` → 11 MATCH, 0 MISMATCH:
K1-BASE 3, K1-F1 2, K1-F2 2, K1-F3 2, K1-F4 0, K1-F5 FAIL (population 1), K1-F6 6,
K1-F7 3, K2-BASE 0, K2-STUB 0, K2-MOCK 5. `K1-REF`/`K2-REF` are pending until the
landing tree exists; the post-landing run re-executes the battery with REF and is
committed with the receipts.

## Axes

C1 calibration, C2 operability. All six axes stand at 9; no axis is re-scored by
a claim move (rounds 36–56 convention). The stagnation nudge is not claimed: a
capability entered round 56 and C2 is a capability acquisition by choice, not by
nudge. No retirement, no split, no harm expected; the harm check is a wave seat.

## Wave (one v1 wave, 12 seats, run-15 band 8–16)

`.ufo/waves/round-57/w1-spec.json`: 2 scout, 2 executor, 2 scribe, 1 reviewer,
1 critic, 1 mutation-tester, 1 sentinel, 1 labrat, 1 connector. Attack share 5/12
(reviewer, critic, mutation-tester, sentinel, labrat). Connector 1. L1 holds the
planner seat: bounded planning data-walks ride the two scouts. Roles route through
the host table; no model is passed.

## Named ceilings

- C1: an authority file forged to agree with its statement passes; the class set is
  closed (a numeric statement of another shape is not counted); a statement's
  subject is resolved by the line's own text; the audited surface is the previous
  round's landing (the round the spot-check reads), not the whole file.
- C2: shape-keyed mocks honouring the shim variable score (K2-MOCK); documentation
  is measured against one binary (OpenBao 2.7.2) on one host; the dev server's
  in-memory storage is not a deployment; `log_raw` output is judged by shape inside
  the trial, never committed.
