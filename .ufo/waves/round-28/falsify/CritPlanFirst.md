# CritPlanFirst — round28 falsify: plan-first / frozen counting commands

Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; all line refs are `62a33b1:<path>:<line>`.
Seat: KagiR28.CritPlanFirst (critic). Lane-authored advice, not closure.

## Verdict: FAIL (the literal ordering holds; the frozen fixtures were changed)

| sub-claim | result |
|---|---|
| bdf90f58 touches only the plan + START census | PASS (2 paths: `plans/round-28.md`, `.ufo/waves/round-28/census-start.txt`) |
| b9a42c0, 2dfb534 are plan-only and land before the candidate | PASS (linear chain BASE→bdf90f5→b9a42c0→2dfb534→62a33b1; each touches only `plans/round-28.md`; the candidate does not touch the plan) |
| counting-command lines unchanged | PASS byte-level (`plans/round-28.md:29`, `:59` identical; bdf90f58→62a33b1 plan diff is 24 insertions, 0 deletions) |
| frozen fixture set unchanged ("Frozen fixture set", `:31`, `:61`) | **FAIL**: b9a42c0 changed how the fixtures are built and flipped the BASE outcomes (below) |
| conformance check "measures" the corrections (lesson M28-4) | **FAIL**: false provenance (below) |

## Findings

**F1 (high): b9a42c0 redefines the frozen fixtures and flips BASE results.**
- **Where:** `plans/round-28.md:93-101`. It says it is "not a widening" and that "values and predicates are unchanged". It adds a mirrored copy of the receipt plus `--receipt/--receipt-sha` to F1, F2 and G1..G4.
- **What the frozen text says:** F1 (`:32`) and G1..G4 (`:61-65`, "release-clocks.tsv edits only") are table edits only.
- **Counterexample (sandbox, BASE tree, literal fixture):**
  - F1 table-only (S040 `observed_version=3.15.01`, `verdict=fired`) gave `RECEIPT-MISMATCH S040`, `RELEASE_CLOCK: FAILED`, exit 1, no traceback. Under the frozen predicate's wording (`:40-41`: exit 1, no traceback, names a typed finding for the row) that is TYPED.
  - F2 table-only gave a `ValueError ... 4301 digits` traceback, exit 1, so MISHANDLED either way.
  - **C1 literal BASE:** MISHANDLED 3/4 at most, not the recorded 4/4 (`build/XC1Measure-base-c1.json`: F1 exit 0 CLEAN).
  - G4 table-only (S029 anchor and observed both lowered to `8.22.0`, `not-fired`) gave `RECEIPT-MISMATCH S029`, `RELEASE_CLOCK: FAILED`, exit 1. That is not ACCEPTED (`:66`).
  - **C2 literal BASE:** ACCEPTED is at most 3/4. The lesson's "G1–G4 accepted CLEAN 4/4 at BASE" (`corpus/lessons/round-28.md:89`, M28-3) exists only under the corrected construction. G1..G3 were not run; [INFERENCE] they behave the same way, since every row is pinned (`:94-95`), which would make literal BASE ACCEPTED 0/4 and leave C2 with no before→after change.
- **Impacted axis:** freshness (C1 and C2 are re-booked onto it, `:103-110`). The before-counts are the evidence for the claim.
- **Fixable defect vs tradeoff:** the correction is technically sensible (a table-only edit measures the receipt pin, not the behaviour). But it changes a frozen fixture set, which the wave contract says is NEVER changed: a defect gets reported, not redefined. The judge must see it as a fixture change with measured effect, not as a "clarification".

**F2 (high): `round-conformance.py` cannot detect frozen-content changes, yet M28-4 cites it as the measurement.**
- **Where:** `corpus/lessons/round-28.md:90` says "corrections appended before any work commit … measured by the conformance check above".
- **What the tool actually checks:** first-commit scope (C1), census order (C2), and byte equality of the indented command lines only (C3) (`.ufo/waves/round-28/tools/round-conformance.py:10-28, 83-93, 192-223`). It has no check on when corrections land relative to tool or patch commits, and none on fixture or predicate prose or on the bodies of the named tools.
- **Counterexample (throwaway branch in a scratch clone, both commits on top of 62a33b1):**
  - CE-A changed the frozen F1 value to `3.15.1` (`:32`), the C1 target to `MISHANDLED k/4 → 2/4, TYPED → 2/4`, and the C2 target to `ACCEPTED k/4 → 4/4`. Result: `VERDICT PASS`, exit 0.
  - CE-B replaced `.ufo/waves/round-28/tools/c1-measure.py` with `print("MISHANDLED 0/4 TYPED 4/4")`. Result: `VERDICT PASS`, exit 0.
- **Impacted:** the frontier "mine a mistake" fix (`plans/round-28.md:74-77`) and M28-1/M28-4 provenance. The lesson admits only the "vacuous on prose commands" limit (`:87`), not these.

**F3 (medium): the C1 tool's predicate differs from the frozen text, and no plan correction records it.**
- **Where:** `tools/c1-measure.py:38-48, 235-246`.
- **Differences:**
  - It adds an `OTHER` bucket.
  - TYPED requires a category outside a BASE-era set that includes `RECEIPT-MISMATCH`.
  - It counts "a written fired observation" as MISHANDLED whatever the exit code. Frozen `:38-39` attaches it to the exit-0 clause.
  - F3/F4 run release-clock.py's `main()` with a stubbed `request_body` and a narrowed table and registry, because the frozen `--observe` over a local feed is unreachable (`:26-36`; lesson Limits).
- **Effect:** none of this changes the recorded counts. BASE F1/F3 are exit 0 CLEAN and F2/F4 are tracebacks (`XC1Measure-base-c1.json`).
- **Gap:** b9a42c0 and 2dfb534 still say "predicates are unchanged" (`:101`, `:110`), while the tool's docstring is the only record of the change.

**F4 (low, timing evidence):** the committed `tools/__pycache__/c2-measure.cpython-314.pyc` header records source mtime 2026-10-21T14:13:00-03:00 and size 10953, which equals the committed size.
- c2-measure.py therefore existed in final form after b9a42c0 (14:06:44) and before 2dfb534 (14:23:24). 2dfb534's "before any tool/patch commit" is literally true, but the axis re-booking was decided after the instrument existed.
- `swarm-registry.json` says the BUILD seats were spawned by 17:06:18Z (14:06:18 −03:00). That is consistent with b9a42c0's "before any measurement tool exists". No counterexample there.
- **Not plan-first scope:** `separability.py`'s committed pyc records source size 33967 (mtime 14:41:49), but the committed file is 34475 bytes, so it was edited after its last compile. The committed `__pycache__` is dead weight, and the c2-measure pyc implies an invocation without `-B` ([INFERENCE] the origin was not located).

## Smallest safe correction (advice; L1 integrates)
1. Report the literal-fixture BASE counts (C1 MISHANDLED 3/4; C2 G4 not ACCEPTED, G1–G3 to be measured) next to the corrected-construction counts. Book b9a42c0 as a fixture change with that effect, not "values/predicates unchanged". Do not restate the frozen text.
2. Strike "measured by the conformance check above" from M28-4, or extend the check before claiming it:
   - C3 hashes the entire frozen part (everything above `## Plan corrections`).
   - Pin each named tool's sha256 at its first measurement receipt.
   - Require every correction commit to be an ancestor of the first tool/patch commit.
3. Remove `.ufo/waves/round-28/tools/__pycache__/` from the candidate.

## Commands run (exit codes)
- `git log/show --stat/diff` for 3553d499..62a33b1, plus plan diffs: exit 0 (read-only, lane).
- pyc header decode of the c2-measure and separability pycs via `git show | python3`: exit 0.
- `git clone --no-local` into `/fast/scratch/hyaku/kagi-r28/CritPlanFirst/clone`, then `round-conformance.py . 28` at 62a33b1: exit 0, `VERDICT PASS lines=2`. CE-A and CE-B: exit 0, PASS.
- BASE `git archive 3553d499` into scratch, then `python3 -I -B corpus/release-clock.py`: F1 table-only exit 1 RECEIPT-MISMATCH; F2 table-only exit 1 Traceback; G4 table-only exit 1 RECEIPT-MISMATCH.
- Scratch clone and copies deleted (rm exit 0). No lane writes except this report. No installs.

## Not checked
- G1–G3 literal table-only at BASE.
- Literal fixtures at the candidate (the "after" side).
- c2-measure predicate fidelity.
- Whether the lane working tree tools differ from the committed ones (a mutable artifact, not read).
- census-start content vs a re-run (`census-start.txt:1` 13:38:30 precedes bdf90f58 at 13:44:04; not re-executed).
- BASE "local=remote, clean" (`plans/round-28.md:4`).
