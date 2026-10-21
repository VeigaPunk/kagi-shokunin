# CritFinalSeparability — round 27 residual, C1 × C2 causal separability

Seat: KagiR26.CritFinalSeparability-27-t3 (critic, advice only; no SHONEN mark,
no production write). Candidate `144babcb892f0a30154880a9f94aa59ca8ddf9c5`
(lane HEAD at read time), BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Axes: calibration (C1), freshness (C2), provenance of the separability claim.
Everything below was run in `/fast/scratch/critsep27` clones; no gate ran in
the lane checkout. No tools were installed or updated.

## Verdict

At the gate layer, C1 and C2 are causally separable except for the declared
SC/PV-CLOCK-SELFTEST edge. That edge is the only C1↔C2 coupling I could
produce, and it closes exactly when C2's two doc lines move. Superposition
holds byte for byte: C1 alone leaves every clock output identical to BASE, and
C2 alone leaves every non-clock self-count line identical to BASE. The
candidate equals the C1-only result for all 22 `KN-*` lines and the C2-only
result for every fixture, selftest and default stdout.

The lesson does describe the edge too narrowly (CE1), names it on the wrong
population (CE2), and its executed evidence is not in the candidate tree
(CE4). The tool's headline metric also has a blind spot (CE3). These are
fixable wording, receipt and metric defects. None of them is a hidden pass at
the candidate.

## Commands run (exact argv, exit, last lines)

1. `cd /home/vgpnk/Projects/shokunin/kagi-shokunin && python3 .ufo/waves/round-27/tools/separability.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 /fast/scratch/critsep27/sep.json`
   took 33 s and exited 0. This run omitted `-I -B`; see CE6. An earlier
   attempt wrapped in `/usr/bin/time` exited 127 because that binary is not
   installed, so nothing ran.
2. `python3 -I -B .ufo/waves/round-27/tools/separability.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 /fast/scratch/critsep27/sep-canonical.json`
   is the canonical argv from the lesson. It took 29.7 s, exited 0, and printed:
   ```
   SEPARABILITY c1-only: knowledge=22 stale_knowledge=0 clock_selftest='RELEASE_CLOCK_SELFTEST: PASS (67 cases)' downgrades_accepted=4/4
   SEPARABILITY c2-only: regressed_exact=4/4 accepted=0/4 control_clean=True selftest='RELEASE_CLOCK_SELFTEST: PASS (76 cases)' knowledge=0 self_counts='SELF_COUNTS: STALE (claims=38 stale=2 unlocated=0 ambiguous=0)'
   ```
   `sep.json` and `sep-canonical.json` are identical after canonical JSON
   sorting. Both match the working-tree `.ufo/waves/round-27/separability.json`
   field by field (exit and stdout for every arm).
   - C1-only: `SELF_COUNTS: CLEAN (claims=60 stale=0)`, exit 0; `stale_all=[]`.
   - C2-only: exit 1 with `STALE SC-CLOCK-SELFTEST SKILL.md:48 claimed=67 live=76`
     and `STALE PV-CLOCK-SELFTEST PROVINCE.md:54 claimed=67 live=76`; the
     default receipt gives `RELEASE_CLOCK: CLEAN (on_release=30 … fired=3 derived=15)`.
3. `python3 -I -B /fast/scratch/critsep27/probe.py` took 188 s and exited 0.
   It builds independent scratch clones and loads the candidate-committed
   `c2-measure.py` through `git show`, not the working-tree copy. Results are
   in `/fast/scratch/critsep27/probe.{out,json}`. Each tree below was given
   `self-counts.py`, `release-clock.py --selftest`, the clock default,
   `bash corpus/sources-census.sh`, and the five c2-measure fixtures:

   | tree | self-counts | clock selftest | downgrade fixtures (lie / rollback / unfire / nonnumeric) | sources-census |
   |---|---|---|---|---|
   | BASE | CLEAN 38, exit 0 | PASS 67 | all exit 0 CLEAN | CLEAN rows=41 |
   | candidate | CLEAN 60, exit 0 | PASS 76 | all exit 1, regressed_exact | CLEAN rows=43 |
   | c1-only (the tool's overlay) | CLEAN 60, exit 0 | PASS 67 | all exit 0 CLEAN | CLEAN rows=41 |
   | c2-only (the tool's overlay) | STALE 2 (SC/PV-CLOCK), exit 1 | PASS 76 | all exit 1, regressed_exact | CLEAN rows=41 |
   | c2-wide: c2-only + `SOURCES.md` + `source-fetches.tsv` + the candidate's SKILL.md:48 / PROVINCE.md:54 clock lines spliced in | CLEAN 38, exit 0 | PASS 76 | all exit 1, regressed_exact | FAILED, 2× `SC_USEDBY_MISSING path=corpus/lessons/round-27.md` |
   | c2src: c2-only + `SOURCES.md` + `source-fetches.tsv` | STALE 2, exit 1 | PASS 76 | all exit 1, regressed_exact | FAILED, same two findings |
   | mut_c2_rule_off: candidate with `and seen < anchor` changed to `and False and seen < anchor` | SETUP, exit 2: `SETUP SC/PV-CLOCK-SELFTEST ledger:R25-03 exit=1 expected=0` | FAIL (first: `… return to the anchor after a recorded newer observation was not regressed`) | all exit 0 CLEAN | CLEAN rows=43 |
   | mut_both: mut_c2_rule_off + drift-gate.md `of 15 files` changed to 16 | SETUP, exit 2 (`stale=1 … setup=2`; the STALE KN-DRIFT-BOUND-FILES line is still printed) | — | — | — |
   | knowledge digit (same drift-gate edit) on BASE / c1-only / c2-only / candidate | exit 0 CLEAN38 / exit 1 KN-DRIFT-BOUND-FILES / exit 1 SC/PV-CLOCK only / exit 1 KN-DRIFT-BOUND-FILES | | | |

   Superposition checks, all printed by `probe.py`:
   - The 22 `KN-*` lines are identical between c1-only and the candidate.
   - Every non-clock self-count line is identical between c2-only and BASE.
   - Fixture stdout is identical for all five fixtures in each comparison:
     c2-only vs candidate, c2-wide vs candidate, and c1-only vs BASE.
   - Clock selftest and default stdout: c2-only matches the candidate and
     c1-only matches BASE.
   - Sources-census stdout: c1-only matches BASE.
   - The only non-clock self-count difference between c1-only and the
     candidate is SC-SKILL-STAMPS, PV-STAMPS and RD-STAMPS (89/89 vs 90/90).
     That is joint stamp bookkeeping, consistent on both sides.
4. The UNLOCATED probe started from a fresh BASE clone with the tool's nine C1
   blobs overlaid from the candidate. I changed `adjacency-breadth.md:155` from
   `caught=18/18` to `caught=18/19`, then ran `python3 -I -B corpus/self-counts.py`.
   It exited 1 with `UNLOCATED KN-BREADTH-FALSIFY corpus/knowledge/adjacency-breadth.md`
   and `SELF_COUNTS: STALE (claims=60 stale=0 unlocated=1 ambiguous=0)`.
   `separability.py`'s regex `^STALE (\S+)` yields `stale_knowledge = []`,
   while `c1-measure.py`'s findings regex yields `[('UNLOCATED', 'KN-BREADTH-FALSIFY')]`.
5. Bytecode check, run in a scratch copy of `tools/`: loading `c2-measure.py`
   through `importlib` with `python3 -I -B` writes no `__pycache__`; without
   `-B` it writes one.

## What holds

- **C1 does not cause C2.** With all C1 blobs overlaid, the release clock's
  selftest, default receipt and five fixtures are byte-identical to BASE: four
  downgrades still accepted CLEAN, 67 cases. `release-clock.py` reads only
  `SOURCES.md`, `source-fetches.tsv`, `rendered-text-v1.py`,
  `release-clocks.tsv` and receipts (`corpus/release-clock.py:59,135`); C1
  touches none of them. Sources-census is also unchanged by C1's knowledge
  edits.
- **C2 does not cause C1's KN population.** No `KN-*` row sources R25-03 or
  R25-04. The KN sources are R16-02/03, R15-02/04/05, R11-09, R11-03, R12-02,
  R17-02, R18-01 and `rows:`. All 22 KN results are identical with and without
  C2. The build-time CE1 (`KN-LEDGER-REPRO-STAMPS` tied to R12-03) is gone at
  the candidate: no KN row sources R12-03 or R21-04.
- **C1's detection is C1-caused.** A knowledge-digit mutation is caught only in
  trees that carry C1's table (c1-only and candidate), never in BASE or
  c2-only.
- **The declared edge is exactly two lines.** c2-wide, which adds only the
  candidate's SKILL.md:48 and PROVINCE.md:54 clock lines, brings self-counts
  back to CLEAN 38 with exit 0. No other C1 artifact is needed.

## Counterexamples

**CE1 — the edge is wider than declared (calibration, freshness).** The lesson
says a C2 selftest *change* "turns C1's binder STALE until the doc moves"
(`corpus/lessons/round-27.md:122-126`, plan correction in the working tree).
In mut_c2_rule_off, a C2 *defect* that disables the rule produces no STALE. It
produces `SELF_COUNTS: SETUP` with exit 2. `self-counts.py:298-299` requires
the ledger exit, and `:363-368` ranks SETUP above STALE. No doc edit can clear
it. In mut_both, a real concurrent C1 finding (`STALE KN-DRIFT-BOUND-FILES`,
which would be exit 1) is reported under SETUP exit 2. The line and `stale=1`
are still printed, so the information survives, but the exit class is C2's.
Every downgrade fixture in that mutant is accepted CLEAN, and the default is
CLEAN30. So the only red signals are R25-03 and, through this edge, R25-02,
which is a calibration row.
Smallest correction (wording): "a C2 selftest count change turns SC/PV-CLOCK
STALE until the docs move; a failing C2 selftest turns the binder SETUP
(exit 2), which outranks any concurrent KN STALE. Read a red R25-02 that shows
SETUP on SC/PV-CLOCK-SELFTEST next to a red R25-03 as one freshness cause."

**CE2 — the edge lands on round-25 rows, not on C1 (provenance).**
SC-CLOCK-SELFTEST and PV-CLOCK-SELFTEST are BASE rows
(`git show BASE:corpus/self-counts.tsv`, lines 22 and 38, `ledger:R25-03`),
part of the round-25 R25-02 population. Their labels differ: "C1's binder"
in the working-tree plan correction, "the declared C2→C1 doc edge" in the
lesson's working-tree measurement section. C1's own measured quantity (22 KN
lines) is unaffected. What is joint is the self-counts exit code and the R25-02
pin `CLEAN (claims=60 stale=0)`, which requires both C1's 22 rows and C2's doc
move.
Smallest correction: name the edge "C2 → R25-02 via the pre-existing
SC/PV-CLOCK-SELFTEST rows (shared gate exit), not C2 → KN-*".

**CE3 — the tool's headline C1 metric counts only STALE (calibration).**
`separability.py:76-78` uses `re.findall(r"^STALE (\S+)")`. Probe 4 shows an
UNLOCATED KN row giving `stale_knowledge=0` and a summary line that reads
clean, while self-counts exits 1. Per the working-tree lesson's measurement
section, four of the 22 KN rows (backreference locators) fail as UNLOCATED under mutation, so this class is
real. The candidate result is not affected: C1-only `self_counts.exit` is 0,
CLEAN60, in `separability.json`. The printed SEPARABILITY line cannot show
that difference, though.
Smallest correction: reuse `c1-measure.py:64`'s
`^(STALE|UNLOCATED|AMBIGUOUS|POLICY|SETUP) (\S+)` filtered to KN ids, and print
C1-only `self_counts` exit and last line in the summary.

**CE4 — the executed separability evidence is not in the candidate
(provenance).** At `144babc`:
- `.ufo/waves/round-27/separability.json`, `c1-before.json`, `c1-after.json`,
  `c2-after.json`, `measurement-invocations.json` and `receipts/` are
  untracked (`git status --porcelain`).
- The "Plan corrections" section of `plans/round-27.md` is uncommitted. The
  committed plan (lines 38-41) still says "C1 and C2 touch disjoint production
  files … shared bookkeeping … is separated by executed claim-only overlays".
- The lesson's "Executed claim measurements" section exists only in the
  working tree (50 uncommitted lines).
- The committed lesson's M27-2 cites `.ufo/waves/round-27/c1-before.json`,
  which is not in the candidate tree.

The claim is still reproducible from the candidate, because
`tools/separability.py` is committed and identical to the working tree, and my
rerun matched the working-tree receipt exactly. A reader of `144babc`, however,
gets "executed, not asserted" backed by an instrument and no receipt.
Smallest correction: L1's integration commits the receipts and the plan and
lesson corrections, or the candidate lesson cites the command and expected
lines instead of implying a receipt.

**CE5 — the C2-only overlay skips C2's sourcing (freshness; coverage only).**
`C2_PATHS` is `corpus/release-clock.py` alone. Adding C2's S042/S043 rows
(c2src, c2-wide) changes no clock output: fixtures and selftest are
byte-identical. So "sourced by version-precedence rows" has no causal effect
on the rule, which is expected for citations. In those trees, sources-census
fails with `SC_USEDBY_MISSING path=corpus/lessons/round-27.md` twice: C2's
source rows require the shared round-27 lesson to exist. That is a
C2 → shared-bookkeeping dependency, not a C1 edge, and the tool never
exercises it.
Smallest correction: list it under "shared bookkeeping" in the edge statement,
or add a c2-wide arm (code, sources and the two doc lines) to the tool. That
arm would also demonstrate the edge closing, as my c2-wide does.

**CE6 — instrument hygiene (minor).**
- `separability.py:37-40` imports `c2-measure.py` from its own filesystem
  location, which is the working tree, not the measured revision. Today the
  difference is docstring-only (`git diff HEAD -- tools/c2-measure.py`).
- Run without `-B`, the import writes `tools/__pycache__/` into the lane
  checkout. My command 1 did this at 12:42:44 −0300, and I removed that
  directory.
- A second `tools/__pycache__/c2-measure.cpython-314.pyc` appeared at
  12:48:07 −0300. None of my processes touched lane tools then: probe.py
  imports a scratch copy, and command 2 used `-I -B`, which writes nothing
  (probe 5). I left it in place as another seat's artifact. Which seat wrote
  it is [INFERENCE], not checked.

Smallest correction: set `sys.dont_write_bytecode = True` before
`exec_module`, and load `c2-measure.py` from `MEASURED_REV` through `git show`,
as probe.py does.

## Impacted axes

- **Calibration:** CE1 (exit class of C1's counting command is
  C2-contaminated), CE2 (edge label) and CE3 (metric blind spot).
- **Freshness:** CE1 (a C2 regression is reported twice, once as a calibration
  SETUP) and CE5 (sourcing is outside the ablation).
- **Provenance:** CE4 (receipts and corrections not in the candidate) and CE6.

None of these refutes separability at the candidate. A canonical judge should
treat CE4 as a defect for L1 to fix (receipts before closure). CE1 and CE2 are
wording, and CE3, CE5 and CE6 are instrument improvements.

## Not checked (unrun ≠ pass)

- I did not run `claim-ledger.sh verify/citations/cells/--selftest`, so ledger
  pins and stamp hashes of the overlay trees are unverified. As the tool
  docstring says, the overlays are not ledger-clean commits.
- I did not run `c1-measure.py`, `c2-measure.py` as scripts, or `--mutate` over
  all 22 KN ids. I called c2-measure's `measure_clone` from the committed
  module and mutated one KN row in a single digit-change form (plus one
  UNLOCATED form).
- I did not check the "selftest grows only by the new cases" claim (no
  case-name diff), nor the correctness of any KN locator or of the excluded
  population.
- I did not check claim-ledger R21-02's pin against the candidate
  sources-census output beyond noting that the candidate prints CLEAN rows=43.
- I tried one C2 mutant (rule disabled). Others, such as the feed floor
  disabled or the comparison flipped, would also fail the selftest and
  [INFERENCE] would follow the same SETUP path.
- I did not check the README's unbound round-27 numbers ("22 … eight …
  five stale ones" vs the lesson's 4 STALE ids); that belongs to C1/Docs.
- No public URLs were opened; this item needed none.
