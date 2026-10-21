# CritFrozenC2: falsifying the C2 instrument at 62a33b1

Verdict: **FAIL**. The contract under attack has three parts: the instrument
derives exactly four groups; it matches only the DERIVATION category; a
receipt-only failure cannot count EXACT. The last two parts are false for the
committed instrument. The candidate's actual 4/4 is still genuine (every counted
finding really is `DERIVATION`), but the predicate doesn't guarantee that. It
would give the same 4/4 to findings that aren't derivation findings, including a
pure receipt failure.

## Findings

1. **The instrument matches by deny-list, not by DERIVATION.**
   - `.ufo/waves/round-28/tools/c2-measure.py:60-61` (`BASE_CATEGORIES`) and `:111`
     (`item["category"] not in BASE_CATEGORIES`) accept any category that isn't one of BASE's seven.
   - The same candidate commit adds a non-derivation category, `NON-CANONICAL`
     (`corpus/release-clock.py:631`, `:680`), which the deny-list omits. At BASE, `grep -c NON-CANONICAL` gives 0.
   - The tool and the clock patch both first appear in 62a33b1 (`git log 3553d49..62a33b1`).
   - Plan text (`plans/round-28.md:66-67`): "EXACT when … the typed **derivation** findings name exactly that group's row ids".
   - Counterexample B (mutant clock): change only `corpus/release-clock.py:625` from
     `("DERIVATION", source_id)` to `("NON-CANONICAL", source_id)`, or to an arbitrary
     `("UNTYPED", source_id)`. Then run the committed `measure_clone` on the frozen G1..G4 fixtures.
     Result: `exact=4/4 accepted=0/4 control_clean=True`, sample G4 output
     `['NON-CANONICAL S029']` / `['UNTYPED S029']`. The instrument can't tell a mislabelled
     or untyped finding from a DERIVATION finding.
   - Impacted axis: freshness (C2 is booked under freshness per `plans/round-28.md:103-110`).
     The counting predicate is the score.

2. **A receipt-only failure counts EXACT.**
   - At `corpus/release-clock.py:679-681`, a receipt record whose `error` starts with
     `non-canonical version token: ` is reported as `NON-CANONICAL <id>`, not
     `RECEIPT-MISMATCH`. That category passes `:111`.
   - Counterexample A: keep the candidate's `release-clocks.tsv` unmodified, so no table
     edit and no DERIVATION is possible. Take a copy of the default receipt `observe-2.json`
     in which only S008–S011 get `"error": "non-canonical version token: 3.13.03"`. Run with
     `--receipt` and `--receipt-sha`, then pass the result to the committed `classify(…, G1)`.
     Result: `exit=1`, findings `['NON-CANONICAL S008','NON-CANONICAL S009','NON-CANONICAL S010','NON-CANONICAL S011']`,
     `derivation_exact=True`. The receipt-only failure is scored as G1 EXACT.
   - Ordinary `RECEIPT-MISMATCH` lines are correctly excluded, because that category is
     in the deny-list. The hole is the receipt branch that relabels its failures as `NON-CANONICAL`.

3. **"Derives exactly four groups" holds only because the groups are hardcoded;
   nothing checks completeness. This is latent, not a defect at this revision.**
   - The groups are a literal `GROUPS` table (`c2-measure.py:53-59`), which matches the
     frozen enumeration at `plans/round-28.md:62-64`.
   - `:156-168` checks that every listed row is a `derived:` row on its feed. It never
     checks that the table has no *other* `derived:` rows.
   - At the candidate, `awk` over `corpus/release-clocks.tsv` finds exactly 15 derived rows:
     S033 has S008–S011; S034 has S013, S022–S024; S035 has S014–S016, S021, S025, S026;
     S037 has S029. That equals the four groups. A later revision that adds a derived row
     would not be detected.

4. **Minor robustness issue (no effect on scoring).** `extract_tree` (`c2-measure.py:73`)
   runs `git -C LANE archive`, where LANE comes from `__file__`. Run from a copy below the
   repo top-level (my sandbox), `git archive` archives only that subdirectory. Here that
   gave a 10240-byte tar with 0 members, and the tool died with a
   `tarfile.ReadError: end of file header` Traceback. The frozen form (lane-root relative path) is unaffected.

## Smallest safe correction (advice only; the command is frozen)

- In `classify`, replace the deny-list with an allow-list: `item["category"] == "DERIVATION"`
  for every finding line (`:111`). Optionally assert that the set of `derived:` row ids in
  the table equals the union of the `GROUPS` rows.
- This narrows the predicate to the plan's own words ("typed derivation findings"); it
  doesn't widen scope. Its effect on the candidate's count is nil: the real G1..G4 output is pure `DERIVATION`.
- The command line and fixtures are frozen and **must not** be redefined mid-round, so L1
  should record this as an instrument defect and limitation, not patch the tool.
- [INFERENCE] If the tool is left unchanged, the C2 4/4 is "correct at 62a33b1 but not
  mutation-resistant". The canonical judge decides whether that tradeoff admits.

## Commands run (sandbox `.ufo/waves/round-28/sandboxes/CritFrozenC2/`)

- `git archive 62a33b1… | tar -x -C …/cand`: exit 0.
- Frozen command from the sandbox copy (cwd=`cand`): exit 1, with the Traceback in finding 4.
- The committed tool, run unchanged through `run-frozen.py` (sets only `LANE` to the lane root; Python 3.14.8):
  - Rev 62a33b1: `C2_MEASURE cand: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0`,
    exit 0. G1–G4 all exit 1 printing only `DERIVATION <group ids>`; control is CLEAN30 (`fired=3 derived=15`).
  - Rev 3553d49: `C2_MEASURE base: groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0`, exit 0.
- `python3 -I -B probe.py` (counterexamples A and B, using the committed `classify` and `measure_clone`): exit 0, output quoted above.
- `git log 3553d49..62a33b1 -- <tool> corpus/release-clock.py`: both files come from 62a33b1.
- `git diff --quiet 62a33b1 -- <tool>`: exit 0, so the worktree tool equals the committed one.
- Scratch `/fast/scratch/hyaku/kagi-r28/CritFrozenC2` was removed; the tool's own tempdirs were auto-deleted.

## Not checked

- I didn't run the frozen command from the lane root (no code runs in the lane checkout); the `LANE`-redirect wrapper substitutes.
- I didn't check C1 (`c1-measure.py`), SOURCES.md anchor values against the live feeds, or clock selftests.
- I didn't check whether a natural (non-mutant) table edit can make the candidate emit
  `NON-CANONICAL` for exactly one group. The frozen lowered values are canonical, so the actual G1..G4 can't.
- No tools were installed or updated.
