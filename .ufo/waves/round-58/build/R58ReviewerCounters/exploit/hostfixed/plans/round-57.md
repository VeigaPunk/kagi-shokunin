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
    target 0 (BASE 3), frozen census POP=16 cases=3 match=7 epochs=2 clocks=2
    pop=2; GUARD adds the gate's pinned bytes and a forged-tree challenge (A3).

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

    C2_AUDIT_TRIAL: value = PASS when the trial's real run is HOLDS 5/5 twice,
    each of the five falsifier shims flips exactly its designated test (SH1->T1,
    SH2->T2, SH3->T3, SH4->T4, SH5->T5), a PATH with no `bao` reads SETUP rc2 with
    no HOLDS, and a client-side wrapper whose `bao audit list` prints nothing flips
    T1; else 0. Target 5 (BASE 0).

POP (round-57), all against throwaway `bao server -dev` instances on 127.0.0.1
with the random root token kept only in scratch, no secret on any argv, no server
log (amended at A2 after the labrat's measured default-refusal):
- T1 enable path: `bao audit enable file file_path=<scratch>` is REFUSED on a
  default dev server (rc!=0, `cannot enable audit device via API`) and ACCEPTED on
  a dev server whose config sets `unsafe_allow_api_audit_creation = true`;
  `bao audit list` then names `file/` and a second `-path=file2 ... log_raw=true`;
- T2 a KV write's audit entries carry the default `hmac-sha256:` value form for
  request and response (the same hash twice), the hash is stable for one input and
  input-distinct, and the written plaintext does not occur in that log;
- T3 the `log_raw=true` device records the value in plaintext AND the client token
  in cleartext (count only), while the default device's log carries neither;
- T4 `bao audit disable file/` then re-enable at the same path rotates the salt:
  the same input's HMAC differs from before;
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

`bash plans/round-57-controls.sh` (epoch B) → 11 MATCH, 0 MISMATCH:
K1-BASE 3, K1-F1 2, K1-F2 2, K1-F3 2, K1-F4 0, K1-F5 FAIL (population 1), K1-F6 6,
K1-F7 3, K2-BASE 0, K2-STUB 0, K2-MOCK 0. Epoch A's receipt
(`controls-prefreeze.txt`) bound the first C2 contract; epoch B
(`controls-prefreeze-epochB.txt`) binds A1+A2. `K1-REF`/`K2-REF` are pending until
the landing tree exists; the post-landing run re-executes the battery with REF and
is committed with the receipts.

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

## Amendments (pre-candidate; no target or kill rule changed)

- **A1 (2026-11-07, before the trial existed and before any candidate measurement).**
  The C2 observable contract follows the lane's round-48/49/51/52 trial convention
  (`TRIAL T<n> HOLDS|BROKEN|ERROR` + one summary line `OPENBAO_AUDIT_TRIAL:
  HOLDS|BROKEN|ERROR holds=N broken=N error=N bao=<ver>`, exit 0/1/2) instead of the
  first `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` sketch. The counter gains three legs:
  the real tree run twice, a PATH with no `bao` (SETUP rc2), and a client-side
  wrapper whose `bao audit list` prints nothing (T1 must flip). `K2-STUB` and
  `K2-MOCK` expectations move to 0 (both false-green shapes are now rejected).
- **A2 (same day, after the labrat's independent probe).** OpenBao 2.7.2 refuses
  `bao audit enable`/`disable` on a default dev server ("cannot enable audit device
  via API; use declarative, config-based audit device management instead"); the
  documented CLI path is reachable only with `unsafe_allow_api_audit_creation =
  true` in the server config, so T1 measures both sides. T3 additionally asserts
  the `log_raw` device's cleartext client token (the labrat measured 62-84 token
  occurrences on its runs; this trial counts them, never prints them). T4 measures
  the documented new-salt behaviour through disable+re-enable on the flagged server
  rather than across two instances.

- **A3 (same day, after the C1 reviewer's false-green attack; before the binding candidate
  measurement).** The first guard (population >= 8) admitted a delete-the-evidence shape: deleting the
  three stale phrases read `value=0` with population 13, and deleting historical MATCH tokens read 0 at
  population 8 (reviewer K1-F8). The guard now requires the exact frozen census
  (`population=16 cases=3 match=7 epochs=2 clocks=2 pop=2`), the gate's bytes at `GATE_SHA256_PIN`
  (`e36472b3640728ca637d6e6c380cb33b1cd07a27dda2aa53409dec0f5bb4a98a`), the gate's own reading equal to
  the checker's, and a forged-tree challenge (SCORECARD `20 cases` -> 19 must read exactly value+1; a
  printer stub fails). The counter now exits 1 unless `value=0` (SETUP 2). Controls K1-F8 (deleted
  statements -> FAIL) and K1-F9 (printer gate -> FAIL) were added; the battery re-ran 13 MATCH, 0
  MISMATCH (`.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt`). The C1 target, POP classes and
  kill rules are unchanged; the `corpus/lessons/round-56.md` repair missed by epoch B's path list is
  committed here.
