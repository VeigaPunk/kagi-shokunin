# K42ReviewC1 — pre-freeze attacks on claim C1 (plans/round-42.md §C1)

Reviewer leaf, round 42, attempt 1. Claim BASE e8265c0; sandbox: shared clone at 98dd4de
(`/fast/scratch/hyaku/kagi-r42/K42ReviewC1/work`, toplevel asserted equal to the clone; scratch
removed at yield). No lane tree edits. The C1 counter is unchanged by amendment A1
(`git diff 98dd4de fdbb83d -- plans/round-42-c1.sh` is empty), so all runs below are runs of the
frozen counter. Harness validation: the committed counter with its own gate reads **N=4**,
equal to the committed receipt `c1-base.txt` (receipts/item3-real.txt, receipts/item3-committed-receipts.txt).
All commands were run with `HYAKU_SCRATCH` pointed inside the sandbox. Every verdict below is a
reviewer recommendation, not an admission. Receipts: `receipts/` beside this file.

---

## Attack 1 — premise "no base-ledger id was ever removed" — NOT-DEFECT (premise holds)

**Claim under test:** F5's class (`DELETED R17-02`) presupposes an append-only ledger history; if
ids had been removed and re-added before, the class would be policing a fiction.

**Evidence (full result, not a sample):** all 42 commits that touch `corpus/claim-ledger.tsv`
(receipts/item1-commits.txt) and all 41 consecutive (child, parent) pairs, first-column id sets
compared in both directions (receipts/item1-removals.txt):

```
consecutive pairs compared: 41; pairs with id-set change: 18
removed=[] in every one of the 41 pairs; 18 pairs are pure additions (R12..R38 waves)
tip set (209147c, newest commit touching the ledger): 86 ids
```

No id ever disappeared, therefore none was ever re-added. Note: 209147c is the newest commit
touching the ledger, i.e. the ledger bytes at 98dd4de/e8265c0 are the 209147c bytes.

**Verdict: NOT-DEFECT.**

## Attack 2 — F5 premise: R17-02 in base 6cc8850 and in no journal at 209147c — NOT-DEFECT (verified)

**Evidence** (receipts/item2-f5-premise.txt):

```
git show 6cc8850dfc5…:corpus/claim-ledger.tsv | grep -n '^R17-02'
  -> 46:R17-02  grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv  ^4$  0 30  …
git show 209147c:.ufo/waves/round-40/expectation-migrations.json | grep -c R17-02  -> 0
git show 209147c:.ufo/waves/round-41/expectation-migrations.json | grep -c R17-02  -> 0
git show 6f1588cc0…:corpus/claim-ledger.tsv | grep -n '^R17-02'  -> line 46 (same row in P0)
```

**Verdict: NOT-DEFECT.** R17-02 is a real base row (line 46), occurs in zero migration entries in
either journal at 209147c, and is present in P0, so the counter's `delete_row(p0,"R17-02")`
fixture is well-formed and `DELETED R17-02` can never collide with an existing class for this id.

## Attack 3 — the frozen counter vs gates that are not real journal gates — DEFECT (undeclared answer-key ceiling)

**Question:** can a non-journal gate reach N=5 with both blanket controls at 0?

**Evidence** — ran the frozen counter with `EXPECT_JOURNAL=<fake>` (fakes in receipts/, per-run
outputs item3-*.txt):

| fake gate | what it reads | N | caught by |
|---|---|---|---|
| fakeA: refuses only the DELETED class, journal-blind | base+cand ledgers | **1** | target (5) only; controls stay 0 |
| fakeB: prints the five frozen tokens, exit 1 always | nothing | **0** | P0 precondition; identical in shape to the committed blanket-refuse control (also 0) |
| fakeC: accepts P0, refuses F1–F5 by hardcoded per-id matching (answer key; reads journals only to look up five ids) | both ledgers + journal ids | **5** | **nothing committed** |
| fakeA+: strongest possible journal-blind gate (DELETED + NOT_LITERAL) | base+cand ledgers | **2** | target |

Journal-blind ceiling proof (receipts/item3-fixture-identity.txt): the counter's F2 ledger is
byte-identical to the P0 ledger (`write_ledger("f2-ledger.tsv", p0)`, line 92) and its F1 and F3
ledgers are byte-identical to each other (`edit_row(p0,"R13-01",2,"^[0-9]+$")`, line 98) while
requiring different tokens (`UNJOURNALED` vs `NOT_LITERAL`) — so no journal-blind gate can exceed
N=2, and reaching 5 requires reading journals. Once a fake reads journals, ~30 lines of hardcoded
per-id checks suffice (fakeC) and P0 stays accepted because the answer key mirrors the journal
contract for exactly five ids.

**Verdict: DEFECT** — scoped: the *declared-ceilings paragraph of §C1 is incomplete*. The counter
faithfully measures its frozen sentence (it counts refusals of the five forgeries under a P0
precondition, and the plan only ever claimed the two blanket shapes are caught), so no predicate,
target, or kill rule needs to change — but §C2 declares its analogue ("a runner that writes the
constant 1 passes — named ceiling") while §C1 declares nothing for the identical property: an
answer-key gate reaches the target with the no-work controls at 0. The lesson must name this
ceiling; kill rule (c) (selftest with the F5 case) and code review of the candidate gate are the
only remaining controls against teaching-to-the-test.

## Attack 4 — kill rule vs a faithful DELETED rule — NOT-DEFECT

**Question:** does the candidate rule (refuse every base-ledger id absent from the candidate,
unconditionally) break the round-41 landing check or P0?

**Evidence** — scratch copy of the BASE gate plus a 6-line DELETED loop and nothing else
(receipts/gate-deleted.sh, inserted directly after the real gate's `journaled = 0`):

```
(a) landing check: --base-ledger 5142b52 ledger --ledger 209147c ledger --journals round-41 journal
    -> rc=0 | EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)
(b) P0: --base-ledger 6cc8850 ledger --ledger 6f1588c ledger --journals round-40 journal
    -> rc=0 | EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)
(c) sanity, F5 (P0 minus R17-02): -> rc=1 | REFUSE DELETED R17-02 … REFUSED (violations=1)
    original BASE gate on the same three cases: all three rc=0 CLEAN (F5 passes — the routed defect)
```

Supporting facts: the 5142b52 → 209147c ledger id-set diff is `removed=[] added=[]` (the six
round-40 expects migrate in place, so a faithful DELETED rule has nothing to fire on), and the
BASE gate's selftest is green (`EXPECT_JOURNAL_SELFTEST: PASS (cases=7)`, receipts/item4-selftest.txt),
so kill rule (c) starts from a passing selftest and only gains a case.

**Verdict: NOT-DEFECT.** Both kill-rule (a) inputs stay CLEAN because the round-41 landing and P0
delete no base rows (consistent with attack 1); the rule refuses F5 exactly as claimed.

## Attack 5 — axis fit: is "refuse an unjournaled deletion" calibration or coverage? — VERDICT: calibration

**Reasons:**

1. **The invariant already exists as a stated rule.** C1 is sourced on registry row S094 /
   `corpus/SOURCES.md`'s append-only rule (the plan's own §C1 "Sourced claim"). The round-41
   gate's frozen classes silently omitted the removal half of that rule — a deleted base row
   passed CLEAN (round-41 routed item 4, reviewer attack A6, reproduced in attack 4's control
   line). Enforcing a rule the corpus already states, through its designated instrument, is
   discrimination of a description/behavior gap, not new policing of unstated content.
2. **The move is self-description-preserving.** The candidate rule writes DELETED into the gate's
   documented frozen rules with its own token, and kill rule (c) requires the F5 case in the
   gate's own selftest — after the move the gate again refuses exactly what it says it refuses
   (and the attack-4 simulation shows it refuses *only* that, on inputs that were CLEAN before).
3. **The ledger's input contract does not widen.** Four-column format, migration schema, journal
   discovery, MISSING_ROW: all unchanged; the only new dimension is row *presence*, which the
   append-only rule already speaks about.
4. **Residual coverage-flavor to name, not to re-classify:** DELETED examines a population
   (base\candidate ids) that no round-41 class looked at, and — per attack 3 — the counter cannot
   tell the new class from an answer key. Both belong in the lesson as named ceilings, exactly the
   way §C2 names its constant-runner ceiling.
