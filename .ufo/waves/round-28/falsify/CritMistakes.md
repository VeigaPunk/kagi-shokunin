# CritMistakes — M28-1..M28-4 evidence, captured-by and fix (candidate 62a33b1b)

Scope: `corpus/lessons/round-28.md:85-90`, QM27–QM29 (`corpus/QUALITY.md:134-136`), `round-conformance.py`,
frozen `c1-measure.py`/`c2-measure.py`; all at committed `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (scratch clone).

## Verdict
**FAIL overall.** The C1 and C2 mechanism fixes hold. The conformance fix (M28-1, and M28-4's
"measured by the conformance check") does not fail the bad cases QM29 names.

| id | evidence | captured-by | fix fails bad case? | verdict |
|---|---|---|---|---|
| M28-1 | holds (rounds 22–27 all C1 FAIL-SCOPE; r27 touched=1874 outside=1873; no r27 census) | `none` accurate | **no**: 4 synthetic QM29 violations PASS | **FAIL** |
| M28-2 | holds (BASE F1/F2/F3 mishandled, F4 OTHER = 3/4) | column names a rule that did *not* capture | yes: MISHANDLED 3/4 → 0/4, TYPED 0/4 → 4/4 | PASS (wording nit) |
| M28-3 | holds (r27 lesson:213-218 quote verbatim; G1–G4 CLEAN 4/4 at BASE) | `none` accurate | yes: ACCEPTED 4/4 → 0/4, EXACT 0/4 → 4/4 | PASS |
| M28-4 | holds (plan:110-114, plan:93-101, plan:103-110) | BUILD critics, accurate | **"measured by the conformance check above" is false** | **FAIL** |

## Findings

**F1 (M28-1 fix, HIGH): the check does not enforce "claims file committed ALONE before any work commit".**
QM29 (`corpus/QUALITY.md:136`) requires the plan to land before any work commit. `round-conformance.py`
C1 (lines 130-159) only checks the path scope of the plan's *first* commit, and C2 (161-190) only checks
that the census is not later than the plan. Neither compares the plan against work commits, and the tool
has no BASE argument (line 104: `<lane> <round>` only). Counterexample **A**: base → work commit
(`corpus/release-clock.py`) → plan + census committed alone *afterwards*. Result: `VERDICT PASS`, exit 0.
Round 27's shape (control **E**, plan with code in one commit) still fails, exit 1. So the fix catches
the one historical shape it was tuned on, not the rule it claims to enforce.

**F2 (M28-1 fix, HIGH): appending a correction after work, or rewriting the frozen prose, is invisible.**
QM29 says "a plan correction is appended only before the first work commit" and names "a frozen scope
widened by an appended correction after measurement" as the anti-pattern. M28-1's third evidence item
is exactly that defect. Counterexamples:
- **B**: plan → work → correction appended *after* the work commit, widening C2 and changing EXACT to
  3/4. Result: PASS, exit 0.
- **C**: after the work commit, the frozen fixture value is rewritten (`observed_version=3.15.01` →
  `3.15.1`), the predicate changes (`MISHANDLED k/4 → 0/4` → `1/4`), and the C2 axis header is
  rewritten. All three are in the frozen part above `## Plan corrections`. Result: PASS, exit 0.

C3 (lines 83-93) protects only fenced or 4-space-indented lines (here the two command lines), so the
fixtures and predicates frozen at plan:30-44 and plan:60-68 are unprotected even for round 28. The
lesson's "vacuous on prose commands" limit (`lessons/round-28.md:87`) understates this. Round 27's
FAIL comes only from C1 and C2 (C3 `lines=0`), so its widened-after-measurement half has no failing check.
Smallest safe correction for F1 and F2: take BASE as an argument; require plan + census to be the first
commit after BASE; require every later plan diff to be pure appends below `## Plan corrections` and
dated before the first work commit; or downgrade the M28-1 fix text to "plan-with-code shape only".

**F3 (M28-4 fix, MED): the conformance check measures none of M28-4's three overclaims.**
`lessons/round-28.md:90` says "measured by the conformance check above". Counterexample **D**: the
candidate plan with the whole `## Plan corrections` section deleted, so it still says "SemVer S042 §2"
(plan:22), keeps the table-only fixtures, and books C2 as calibration (plan:46). Result: PASS, exit 0.
The tool reads no `SOURCES.md` row, axis or fixture construction (lines 10-28). The fix that actually
exists is the corrections appended at `b9a42c0` and `2dfb534`, which are human review. Smallest safe
correction: drop "measured by the conformance check above" and state that M28-4 has no mechanical check.

**F4 (M28-1/QM29, MED): QM29 is not a gate, so "captured-by: none" stays true going forward.**
The tool lives under `.ufo/waves/round-28/tools/`; no ledger row runs it (ids stay 65:
`corpus/claim-ledger.tsv:54` R21-04 `^65$`, R24-14 unchanged; only `LOG.md:1544` and the lesson name
it). A round-29 repeat of the round-27 shape turns nothing red [INFERENCE: unless the L1 runs it by hand].

**F5 (QM29 proxy, LOW, tradeoff not defect): commit order is not measurement order.**
The axis re-booking correction says "after BUILD reports" (`plans/round-28.md:103`), and BUILD had
already produced sandbox measurements (`build/XC1Measure-base-c1.json`, `XC2Measure-c2-base.json`) before
`2dfb534`. QM29's "before the first work commit" cannot see this; it passed only because it narrowed.

**F6 (M28-2 wording, LOW):** captured-by "QM25 orders values, not token form" (`lessons/round-28.md:88`)
names a rule that did not capture; by M28-1/M28-3 convention: `none (QM25 orders values, not token form)`.

**Axis (PASS):** no conflated claim. SCORECARD's freshness row holds the one claim (C1+C2), and
calibration reads "No claim (re-booked)". The note "QM27–QM29 learn M28-1..M28-4" is in the calibration
evidence cell, not a claim; lesson 14-18 and LOG agree (frozen §C2 header stays by append-only design).

## Commands run (scratch clone at 62a33b1b; TMPDIR on /fast/scratch)
| Command | Exit | Result |
|---|---|---|
| `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d499… 3553d49 out.json` | 0 | `mishandled=3/4 typed=0/4 other=1/4 control_clean=True` |
| same with `62a33b1b…` | 0 | `mishandled=0/4 typed=4/4 other=0/4 control_clean=True` |
| `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d499… 3553d49 out.json` | 0 | `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True` |
| same with `62a33b1b…` | 0 | `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True` |
| `round-conformance.py . N` for N = 22..27 | 1 each | C1 FAIL-SCOPE 6/6; C2 FAIL-MISSING for 22, 23, 26, 27; C3 vacuous `lines=0` 6/6 |
| `round-conformance.py . 28` | 0 | PASS, C3 `lines=2` |
| Synthetic repos A / B / C / D (round-28 frozen plan text) | 0 / 0 / 0 / 0 | all PASS (counterexamples) |
| Synthetic control E (plan with code) | 1 | FAIL-SCOPE |
| `python3 -I -B corpus/release-clock.py --selftest` | 0 | `PASS (106 cases)` |
| `python3 -I -B corpus/release-clock.py` | 0 | `CLEAN (on_release=30 … fired=3 derived=15)` |

Receipts: `.ufo/waves/round-28/sandboxes/CritMistakes/receipts/` (c1/c2/conf/syn logs); scratch clone
and sandbox exports deleted. No tools installed or updated.

**Not checked:** per-case NON-CANONICAL/DERIVATION selftests failing on BASE code and source mutations
of `release-clock.py` (mutation-tester seats); S044–S049 captures and quote location; "6/6 rounds
22–27" beyond the tool's C1 output; XC1/XC2 build JSONs beyond their summary claims.
