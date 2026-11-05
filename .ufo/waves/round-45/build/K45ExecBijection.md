# K45ExecBijection — C1 bijection candidate (scratch only)

**Axes:** calibration (plan-to-manifest bijection check) / coverage (one assimilated entity not in scope — C1 only) / freshness (predeclaration tree 307fb50d repinned).

## What was built
Patched `corpus/claims-declared.sh` (in scratch archive of 307fb50da825d6e6f2b5c7981c71556d35611142 only; lane untouched) adding the plan-to-manifest direction per frozen plan `plans/round-45.md` §C1 scope: rounds R ≥ 39 whose `plans/round-R.md` carries `## C<k> — <axis>:` headings AND whose `SCORECARD.md` carries `## Round R — post-move`. Each such heading must have exactly one manifest row (R,Ck,axis) in `corpus/claims-declared.tsv`; missing prints `MISMATCH R Ck no-manifest-row`, `bad++`, exit 1 via the existing final branch. Existing manifest-to-plan checks, `CLAIMS_DECLARED: CLEAN (claims=15)` / `MISMATCH (claims=N mismatch=M)` output, and exit codes 0/1/2 unchanged.

## Measurements (exact rc + last line each)
- (a) Real tree `sh "$S/tree/corpus/claims-declared.sh" --root "$S/tree"` → rc=0, last line `CLAIMS_DECLARED: CLEAN (claims=15)` — **CLEAN, matches expectation.** Round 45 correctly skipped (no post-move in SCORECARD → in-flight); rounds <39 skipped by freeze.
- (b) Frozen fixtures A/B/C copied from `plans/round-45-c1.sh` (counter unmodified) → rc A=1 `MISMATCH 90 C2 no-manifest-row`, B=1 `MISMATCH 90 C1 no-manifest-row`, C=1 `MISMATCH 90 C1 plan-heading-not-calibration` + `MISMATCH 90 C1 no-manifest-row` — **A=1 B=1 C=1, matches expectation.** DETECTED=2 POSITIVE=1 REAL=CLEAN → would be value=2 under frozen predicate.
- (c) `sh "$S/tree/corpus/claims-declared.sh" --selftest` → rc=0, last line `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` — **matches expectation (8 cases pass, includes new direction).**

## Evidence
- Patched script: `.ufo/waves/round-45/build/K45ExecBijection/claims-declared.sh`
- Diff vs 307fb50d: `.ufo/waves/round-45/build/K45ExecBijection/claims-declared.diff` (added block only; `diff -u` rc=1 = files differ, as expected)
- Receipts: `.ufo/waves/round-45/build/K45ExecBijection/receipts.txt`
- Scratch: `/fast/scratch/hyaku/kagi-r45/K45ExecBijection/tree` + fixtures `fxA/fxB/fxC`, `fixtures-c1.sh`

## Collision/quarantine
N/A — single-file candidate in scratch; no registry/knowledge/API surface; lane `git status` shows no edit to `corpus/claims-declared.sh` (only `corpus/SOURCES.md` modified by a peer + wave dispatch scratch files).

## Risks / defects named
- Fixture C now reports two mismatches for one claim (existing axis check + new no-manifest-row); still rc=1, unaffected counters that test rc==1 only. Not a defect on real rows (an axis relabel still lacks the (R,Ck,relabeled-axis) row).
- Heading extraction uses `^## C[0-9]+ — [a-z]+:` with the same fence/HTML-comment stripping as the existing manifest-to-plan awk; non-matching heading spellings are ignored in both directions consistently.
- Scope is strictly numeric `plans/round-*.md` with a post-move section and R≥39; any other file shape is out of scope by freeze.
- No mutation tested for spoofing both directions simultaneously (conspiratorial relabel D4 remains a named ceiling per gate header, unchanged).

## Blockers
None.
