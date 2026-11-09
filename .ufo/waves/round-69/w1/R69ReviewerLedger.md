# R69ReviewerLedger — single-row ledger probe (round 69, attempt 2)

Seat: R69ReviewerLedger (reviewer, leaf, no production edits, no commits, no subagents).
Lane: `kagi-shokunin`, BASE `264917aa8fc9e71b6595d0d5166c4b615120fb8b`, HEAD measured `6a93ca6`.
Receipts: `.ufo/waves/round-69/w1/R69ReviewerLedger/` (`commands.txt` plus one `.out` per run).
Method: read-only `git archive` extractions of BASE and HEAD into scratch; every mutated
ledger is a scratch copy. The lane tree was not written.

## Hypothesis H — verdict

**H is falsified in its exact form.** The gate treats a reduced single-row ledger differently
from the full ledger on four counts: (1) a valid row does not produce `CLEAN` by default;
(2) `true` as a command is refused as POLICY (exit 2), not run to a `FAIL` (exit 1); (3) the
full gate itself cannot read CLEAN at BASE or HEAD; (4) the C2 `ledger` leg's one named row
(`R68-02`) exits 2 under the full verify. Case (c) (host-invocation → POLICY) holds exactly.

## Measured last lines (stdout last line, exit code)

Single-row copies, `cd <tree> && bash corpus/claim-ledger.sh verify [--docs <file>]`.

| case | copy | last stdout line | exit | receipt |
|---|---|---|---|---|
| (a) as specified: R24-14 (`bash corpus/row-identity.sh ledger-ids`), not restamped, default docs | a | `CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0 stamped=168 stale=1 missing=0 unresolved_ids=1659 labeled_ids=172 host_skipped=0)` | 1 | `a.out` |
| (a) R24-14 line before the summary | a | `FAIL R24-14 reason=verdict-not-final exit=0` | — | `a.out` |
| (a') valid R11-10 (`grep -cv '^#' corpus/state-shape.tsv`, expect `^22$`), **restamped**, `--docs` = empty file | f1 | `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=168 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)` | 0 | `f1.out` |
| (a'') same row, **not restamped** | f4 | `CLAIM_LEDGER: FAIL (claims=1 failed=0 deferred=0 stamped=168 stale=1 missing=0 unresolved_ids=0 labeled_ids=0 host_skipped=0)` (preceded by `STALE corpus/claim-ledger.tsv sha=c5cd548f3fec->9e1db91473b8 lines=119->19 bytes=59746->1668`) | 1 | `f4.out` |
| (a''') R11-10 restamped, **default docs** (no `--docs`) | a2-like | `CLAIM_LEDGER: FAIL (... unresolved_ids=1649 ...)` (1649 `MISSING-ID` lines) | 1 | `a2.out`, `a3.out` |
| (a'''') R11-03 restamped, default docs | a2 | `CLAIM_LEDGER: FAIL (claims=1 failed=0 ... unresolved_ids=1649 ... host_skipped=1)` — R11-03 is host-tagged, so it is host-skipped, not run | 1 | `a2.out` |
| (a''''') R11-03 restamped, `--docs QUALITY.md` (7 R-ids in that file) | a2-docs | `CLAIM_LEDGER: FAIL (claims=1 failed=0 ... unresolved_ids=10 labeled_ids=0 host_skipped=1)`; `MISSING-ID corpus/QUALITY.md:246 R36-03` | 1 | `a2-docs.out` |
| (b) as specified: R24-14 with command `true` | b | `POLICY R24-14 reason=first-token:true` then `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` | **2** | `b.out` |
| (b') R11-10 with command `true` | f3 | `POLICY R11-10 reason=first-token:true` / `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` | **2** | `f3.out` |
| (b'') R11-10, expect wrong (`^9999$`), restamped | f2 | `FAIL R11-10 reason=verdict-not-final exit=0` then `CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0 stamped=168 stale=0 missing=0 unresolved_ids=0 labeled_ids=0 host_skipped=0)` | 1 | `f2.out` |
| (c) synthetic row `X1 bash corpus/drift-pins.sh` (untagged host) | c | `POLICY X1 reason=untagged-host script=corpus/drift-pins.sh` then `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` | 2 | `c.out` |
| R29-01 `python -I -B corpus/feed-token-agree.py --selftest`, restamped, empty docs | p1 | `POLICY R29-01 reason=first-token:python` / `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` | 2 | `p1.out` |
| R29-02 `python -I -B corpus/feed-token-agree.py`, restamped, empty docs | p2 | `POLICY R29-02 reason=first-token:python` / `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` | 2 | `p2.out` |
| **full** verify, BASE `264917aa` | full-base | `CLAIM_LEDGER: POLICY (claims=101 policy=5 stamped=168)` | 2 | `full-base.out` (845 s) |
| **full** verify, HEAD `6a93ca6` | full-cur | `CLAIM_LEDGER: POLICY (claims=101 policy=5 stamped=168)` | 2 | `full-cur.out` (845 s) |

The full BASE and full HEAD outputs are identical on every verdict and policy line:
22 `FAIL`, 13 `HOST-SKIP`, 5 `POLICY` (R29-01, R29-02 first-token `python`; R38-03, R57-01,
R62-04 `python-script`). `R68-02` prints `FAIL R68-02 reason=exit-mismatch exit=2 want=0`.

Other receipts (run in the transcript; commands reproduced in `commands.txt`):
- `bash corpus/row-identity.sh ledger-ids` on HEAD: `ROW_IDENTITY: ledger-ids count=101 sha256=13167dd77e5a06382b73d5ae618129925434f1fbb46c3ae34cbe557c17f8fb0d`, exit 0. This matches R24-14's pinned expect.
- Same on the one-row copy f1: `count=1 sha256=7c42bb821f7d7b35e3e437952dcde1ae24677b999b2f532d7b21063331a5c43d`, exit 0.
- `CLAIM_LEDGER_DEPTH=1 bash corpus/claim-ledger.sh verify` on HEAD: `claim-ledger: refusing a nested self-audit (CLAIM_LEDGER_DEPTH=1; ...)`, exit 2.
- `expect-journal.sh --base-ledger <BASE> --ledger <HEAD> --journals <copy of lane journal>`: `EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)`, exit 0, with `WARN ORPHAN` for R21-04, R24-14, R68-02.

## Semantic differences (the findings)

1. **A one-row ledger is not CLEAN by default (case a).** `verify` runs three things on every
   invocation: the claim rows, a stamp check (`stamp_cmp`), and an id audit (`idref_audit`).
   Editing `corpus/claim-ledger.tsv` makes the stamp row STALE (f4: exit 1). Restamping in
   scratch clears that. The id audit scans seven default documents (`LOG.md`, `SCORECARD.md`,
   `corpus/lessons/*.md`, …), finds 1649 to 1659 cited ids that the reduced ledger does not
   contain, and reports them as `MISSING-ID` → exit 1. The only exit-0 reading I obtained
   needed both a restamp and a `--docs` scope to an R-id-free file (f1). The frozen C2
   `ledger` (a) names neither. `verify` has no `--docs`-free path to CLEAN.
2. **R24-14 cannot be the probe row.** It pins the membership of the full ledger (`count=101`).
   On a one-row copy it reads `verdict-not-final`. A reduced ledger falsifies its own
   membership pin by design. R-row identity is a whole-ledger property.
3. **`true` is refused, not run (case b).** `policy_check` allows only the first tokens
   `bash grep sha256sum wc test python3`. `true` yields `POLICY … first-token:true` with exit 2.
   The frozen predicate's "exits 1 with a `FAIL R68-02` line" is therefore not reachable through
   the gate's own path. A valid negative is a wrong expect (f2: `FAIL <id> reason=verdict-not-final`,
   exit 1). That negative does hold, and it names the id.
4. **Case (c) holds exactly:** `POLICY X1 reason=untagged-host …`, exit 2, last line `CLAIM_LEDGER: POLICY (…)`.
5. **The full gate is never CLEAN, at BASE or HEAD (case d).** Two rows (R29-01, R29-02) start
   with `python`, which is not in `ALLOWED_RE`; three more (R38-03, R57-01, R62-04) are refused as
   `python-script`. The full verdict is `POLICY` exit 2 on both trees, with identical lines.
   A reduced copy that drops those five rows reads CLEAN where the full gate reads POLICY. So the
   C2 `ledger` leg, as a reduced row, measures something other than the full gate. This is a
   finding: a one-row "CLEAN" cannot evidence the full gate's health, and the full gate is red at BASE.
6. **`R68-02` exits 2 under the full verify (HEAD).** `FAIL R68-02 reason=exit-mismatch exit=2 want=0`.
   The row's command `bash plans/round-68-c2.sh` runs the ledger's `verify` inside
   the counter; a nested `verify` at depth ≥1 is refused (exit 2, measured above). This is consistent
   with, but not proven by, the full-run line: I did not execute the 3600 s counter. The frozen
   C2 `ledger` leg's premise, that R68-02 "exits 0 and its last line matches", is contradicted by
   the full-run receipt on the same tree.
7. **Row-count and policy semantics (d).** The gate has no minimum-row guard (grep of
   `claim-ledger.sh` finds only argument-count and reason-length checks), so the reduction does not
   trip a "≥2 rows" rule. The reduction does change the population: the seven self-invoking rows
   (R11-08, R11-09, R14-01, R13-03, R18-03, R23-01, R31-01) and the host/substrate rows drop out.
   `verify` does not skip self rows (only `cells` does, via `CELL_SELF_SKIP`), so the self-invocation
   path is not exercised by the reduced run. Full-ledger census: 101 rows, 2 host-tagged, 11
   substrate-tagged, 7 self-invoking, first tokens `bash 68`, `grep 17`, `python3 13`, `python 2`,
   `sha256sum 1`.
8. **expect-journal (c) is vacuous against HEAD.** HEAD's ledger equals BASE (`diff` of R68-02
   identical; 101 rows each), so `changed=0` and the leg passes without exercising any
   migration. The lane working-tree journal `.ufo/waves/round-69/journals/expectation-migrations.json`
   (untracked; sha256 prefix `2064a823…`) journals changes to R68-02 (`new_expect
   ^C1_RECORD_LEGS: legs=1,3 ok=2$`), R21-04 (`^101$`→`^103$`) and R24-14 (count 101→103). None
   of those changes exists in HEAD or in any candidate tree I was given. The leg cannot measure them.
   I did not evaluate the uncommitted candidate ledger.

## Ceilings

- Scratch trees are `git archive` of committed bytes. Uncommitted lane edits (for example the
  modified `plans/round-68-c1.sh` in `git status`) are not in them.
- The stamp re-pin in f1 and the `--docs` scope are my scratch edits. They are needed to reach CLEAN
  in this gate, and the frozen text names neither. Whether the seat that writes the candidate ledger
  re-pins the stamp is out of my scope.
- Full-run numbers are from one run each at HEAD and BASE, in parallel, 845 s.

## Tools

None installed or upgraded. Only `git archive` (read-only), `python3`, `bash`, `sha256sum`, `timeout`
and the lane's own gates were used. `disk-guard.sh status` was run before the heavy pass
(no pressure reported).

## Finding summary (for claim-falsification.tsv, one per line)

- C2-ledger-a: `bash corpus/claim-ledger.sh verify` on a one-row copy (R24-14, unrestamped, default docs) → `CLAIM_LEDGER: FAIL (claims=1 failed=1 ... stale=1 ... unresolved_ids=1659 ...)`, exit 1. Frozen predicate expects `CLAIM_LEDGER: CLEAN (claims=1` exit 0.
- C2-ledger-a': R11-10 restamped with `--docs <empty>` → `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=168 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`, exit 0 (the only CLEAN; needs restamp + docs scope).
- C2-ledger-b: R24-14 with command `true` → `POLICY R24-14 reason=first-token:true`, `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)`, exit 2. Frozen predicate expects exit 1 with `FAIL R68-02`.
- C2-ledger-b': R11-10 expect `^9999$` → `FAIL R11-10 reason=verdict-not-final exit=0`, exit 1 (names the id).
- C2-ledger-c: `POLICY X1 reason=untagged-host script=corpus/drift-pins.sh`, exit 2 (holds).
- C2-ledger-d-full-base: `CLAIM_LEDGER: POLICY (claims=101 policy=5 stamped=168)`, exit 2.
- C2-ledger-d-full-head: `CLAIM_LEDGER: POLICY (claims=101 policy=5 stamped=168)`, exit 2 (identical to BASE).
- C2-ledger-R68-02-full-head: `FAIL R68-02 reason=exit-mismatch exit=2 want=0`; the frozen premise is exit 0.
- C2-ledger-R29-01: `POLICY R29-01 reason=first-token:python`, exit 2 (R29-02 likewise).
- C2-ledger-journal-c: `EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)`, exit 0, vacuous against HEAD (no migration applied).

## Verdict

H falsified (cases a, b, d). Case (c) confirmed. Routed to the L1: the C2 `ledger` leg as frozen
cannot be satisfied through the gate's own path (no `true`, no unrestamped copy, id audit over the
default docs). Its `R68-02` premise is contradicted at HEAD. The full gate is POLICY at both trees.
No production edit was made.
