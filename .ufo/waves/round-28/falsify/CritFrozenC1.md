# CritFrozenC1 — C1 instrument vs frozen F1–F4 text (pinned 62a33b1b)

**Verdict: FAIL** on the clause "classifier excludes BASE-era categories honestly". The candidate's
own counts are unaffected: BASE 3/4 MISHANDLED → candidate 0/4 MISHANDLED with 4/4 TYPED. They reproduce
with both the shipped classifier and a corrected one. Other clauses: frozen text PASS; "table+receipt
only F1/F2" PASS; F3/F4 construction deviates from the frozen text with no appended correction (result-neutral,
probed); "BASE 3 MISHANDLED, F4 OTHER" reproduces, but only under a non-literal predicate reading, and the
cited build receipt says 4/4.

## Findings (candidate path:line unless marked BASE)

1. **FAIL — BASE-era `NOT OBSERVED` is counted as TYPED.** `.ufo/waves/round-28/tools/c1-measure.py:210-211`
   takes `stripped.split()[0]` as the category. release-clock prints `"%s %s" % (category, row_id)`
   (BASE `corpus/release-clock.py:646`, candidate `:715`), so `NOT OBSERVED S040` tokenizes to `NOT`, which is
   not in `BASE_ERA_CATEGORIES` (`c1-measure.py:64-67`). The docstring promise at `:42-47` is false for one of
   its seven listed categories.
   Counterexample M1 (scratch-clone commit 8cf85626, candidate plus a two-line change at `corpus/release-clock.py:631,680`:
   `("NON-CANONICAL", source_id)` → `("NOT OBSERVED", source_id)`). The instrument reports
   `mishandled=0/4 typed=4/4 other=0/4` with typed lines `['NOT OBSERVED S040']`. Every "typed" finding is
   a BASE-era category, so the honest result is OTHER 4/4.
2. **FAIL — F1/F2 row scoping is vacuous.** `c1-measure.py:284` passes `feed_url=""`, and `:209` tests
   `feed_url in stripped`, which is always true for `""`. For F1/F2, any non-BASE-era finding on any row
   counts as "a typed finding for the fixture's row" (frozen predicate, `plans/round-28.md:40-41`).
   Counterexample M2 (commit 8dae6842, same two lines → `("NON-CANONICAL", feed_source_id)`): F1/F2 are TYPED
   on `NON-CANONICAL S039`, while F3/F4 are OTHER on the identical output. Result: `typed=2/4 other=2/4`. Under
   the same frozen predicate, the table and observe fixtures disagree.
3. **Deviation, result-neutral — F3/F4 are not "unchanged table" and not a "local copy of the python.org
   feed".** `c1-measure.py:294-300` narrows `release-clocks.tsv` to S040 and `SOURCES.md` to S040+S039.
   `:303` with `:99-115` serves a synthetic two-entry Atom document, not the RSS capture
   `.ufo/waves/round-26/captures/S039.body` (sha256 11c86a34…, which the default receipt pins). Injection is an
   in-process `request_body` stub (`:87-95`); the shipped CLI admits only public HTTPS, a frozen-spec
   defect the instrument docstring records at `:26-36`. None of this is in the appended corrections
   (`plans/round-28.md:91-115`, which cover only receipt mirroring, axis booking and sourcing). Build seat
   CritFrozenCommands specified the real capture with an in-place title swap and the full table. Probes:
   P1 (real capture, in-place `<title>Python 3.15.1</title>` swap) and P2 (P1 plus an un-narrowed table and
   registry) give the same verdicts as the shipped instrument at BASE and candidate (table below).
4. **Reading dependency — "BASE 3 MISHANDLED".** The frozen predicate (`plans/round-28.md:38-39`) reads
   "exits 0 with `RELEASE_CLOCK: CLEAN` (or a written fired observation)". `c1-measure.py:242` (and
   `:21-22`) counts a fired receipt at any exit code. BASE F3 exits **1** (`RECEIPT-MISMATCH S040`) with
   a fired S040 receipt. Literal grammar gives BASE 2/4 MISHANDLED, 2/4 OTHER; the instrument gives 3/4. Plan C1
   prose ("never a release event", `:23-24`) supports the instrument's reading, and k is unspecified in the
   frozen text, so after-state admission is unaffected. This reading is an L1 choice that appears only in a code
   comment, not in the plan corrections.
5. **Provenance — the cited BASE receipt comes from a different instrument.** The committed
   `.ufo/waves/round-28/build/XC1Measure-base-c1.json` (rev 3553d499) records `mishandled 4/4`, with F3 exit
   0 and F4 MISHANDLED exit 1. The shipped instrument gives 3/4 with F4 OTHER at the same rev. That
   receipt predates the F3/F4 "identity edit" (`c1-measure.py:289-293`). `corpus/lessons/round-28.md:88`
   cites it as BASE evidence, while `SCORECARD.md:1121` states 3/4 "F4 already caught by the observer". Both
   are in the same commit and contradict each other. The tool's only commit is 62a33b1, which also carries the
   patch, so git cannot show the tool predates the patch (plan `:27`, "written this round, then never changed").

## Measurements (all exit 0; `TMPDIR` in scratch; tool archived from scratch clone of the lane)

| run | instrument | F1 | F2 | F3 | F4 | summary |
|---|---|---|---|---|---|---|
| BASE | shipped | MISH (exit0 CLEAN fired=4) | MISH (Traceback, exit1) | MISH (exit1, fired receipt) | OTHER (exit1, observe error, RECEIPT-MISMATCH) | 3/0/1 |
| cand | shipped | TYPED NON-CANONICAL S040 | TYPED | TYPED | TYPED | 0/4/0, control CLEAN30 exit 0 |
| M1 | shipped | TYPED `NOT OBSERVED S040` | TYPED | TYPED | TYPED | **0/4/0 (false)** |
| M2 | shipped | TYPED `NON-CANONICAL S039` | TYPED | OTHER | OTHER | **0/2/2 (asymmetric)** |
| BASE / cand | P1 real feed; P2 real feed + full table | = shipped | | | | 3/0/1 ; 0/4/0 (both) |
| BASE / cand / M1 / M2 | P3 fixed classifier | | | | | 3/0/1 ; 0/4/0 ; 0/0/4 ; 0/0/4 |

Summary is mishandled/typed/other. The control is `RELEASE_CLOCK: CLEAN (… observed=30 fired=3 derived=15)` exit 0 in every run.
Commands were run in a `git clone --no-checkout` of the lane at `/fast/scratch/hyaku/kagi-r28/CritFrozenC1/clone`:
- `TMPDIR=… python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>` for 3553d499…,
  62a33b1b…, 8cf85626 (M1) and 8dae6842 (M2) → exit 0 each. The P1–P3 scratch copies also exit 0 each.
- `diff <(git show bdf90f5:plans/round-28.md) <(git show 62a33b1:plans/round-28.md)` → exit 1, but only lines
  92-115 are appended, so the frozen lines 1-91 are byte-identical. One mutant-builder assertion exited 1 and was rerun.

## Smallest safe correction (advice; frozen command/predicate untouched)

At `c1-measure.py:207-212`, parse `category, _, ident = stripped.rpartition(" ")`. Then require
`ident == row_id or (feed_url and ident == feed_url)` and `category not in BASE_ERA_CATEGORIES`. Probe P3
shows this keeps BASE at 3/4 and the candidate at 0/4 → 4/4, and rejects M1 and M2 (0/0/4). Since the
tool is frozen, L1 should record defects 1–2 and the F3/F4 construction and predicate reading (3–4) as
appended plan corrections, or as findings. It should also mark `XC1Measure-base-c1.json` as a pre-freeze
receipt, or stop citing it at `corpus/lessons/round-28.md:88`. The canonical judge decides whether a defective
frozen classifier blocks admission. On this evidence it does not change the candidate's measured outcome.

Impacted axes: freshness (C1 measurement integrity); calibration is not claimed this round (`plans/round-28.md:103-110`).

## Not checked

C2 and `c2-measure.py`; the selftest count growth; ledger and stamps pins; SOURCES rows S044–S049; non-canonical
forms beyond F1–F4; any live feed. No tools were installed. The mutant diffs are inline above, the scratch clone
was deleted, and this report is the only lane write.
