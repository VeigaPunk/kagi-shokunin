# Draft — SCORECARD erratum (round-47 non-claim work, closure routed 1)

Target file: `/home/vgpnk/Projects/shokunin/kagi-shokunin/SCORECARD.md` — **appended** at end of file
(after the round-46 post-move section, `SCORECARD.md:1689-1700`). The text below is a draft; the L1
applies it. Nothing in it rewrites an existing line, and no score changes.

Provenance of the defect: `corpus/lessons/round-46-verifier-spotcheck.md:104` (routed item 1) names the
miscount; this draft measures it against the committed bytes before writing the correction.

## Proposed appended section

```markdown
## Errata (append-only; a correction never overwrites the line it corrects)

- **E47-1 — round-46 operability row (`SCORECARD.md:1695`).** The row says the declared-claim gate's
  own `--selftest` went "`(8 → 11 cases)`" and names its evidence as "`corpus/claims-declared.sh`
  cases 9–11". Both cells are wrong against the committed bytes: the `--run-selftest` block asserts
  **12** cases, and case 12 exists. Correct reading: **`(8 → 12 cases)`**, evidence
  **`corpus/claims-declared.sh` cases 9–12**. Measured at the round-46 landing `f4a33d3d`:

      $ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show f4a33d3d:corpus/claims-declared.sh | grep -n 'cases" -eq'
      122:  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 12 ]; then

      $ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show f5977284:corpus/claims-declared.sh | grep -n 'cases" -eq'
      102:  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 8 ]; then

      $ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show f4a33d3d:corpus/claims-declared.sh | grep -n 'case 12' -A3
      118:  # case 12 (round 46, reviewer K46RP-02): the manifest key carries the axis -- a
      119-  # claim with a second plan heading on another axis and no row for it is reported.
      120-  mfix; printf '# fixture plan\n\n## C1 — freshness: a\n\n## C1 — depth: b\n\n## C2 — calibration: c\n' > "$s/plans/round-90.md"
      121-  chk same-claim-second-axis "$GATE_SRC" 1 'MISMATCH 90 C1 no-manifest-row'

  so `8` (BASE `f5977284` line 102) → `12` (candidate `0bd8888` and landing `f4a33d3d` line 122);
  `11` is neither endpoint. The same two numbers are already right elsewhere: `corpus/lessons/round-46.md:7`
  (`8 → 12 cases`), `LOG.md:1827` (`cases 9–12` … `CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`), and the
  round-46 receipts — `.ufo/waves/round-46/final/measured-at-candidate.txt:4` and `:64`
  (`CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`), `.ufo/waves/round-46/controls/c1-base.txt:2`
  (`PASS (8 cases)`), `.ufo/waves/round-46/controls/gates-base.txt:15` (`PASS (8 cases)`). The SCORECARD
  cell is the only cell that drifted.

  Why the omission matters: case 12 (`same-claim-second-axis`) is the case that pins reviewer K46RP-02's
  axis-keyed finding (`corpus/lessons/round-46.md` §Amendment notes, K46RP-02). A row that cites "cases
  9–11" leaves out the case that answers its own reviewer, while the sentence beside it ("the four
  equivalent mutants still pass") needs case 12 present to be true.

  Not changed by this erratum: operability `9 → 9`; C1's `0 → 3`; the kill/equivalence counts; the
  "surface: the `--run-selftest` block only" sentence; the case descriptions for 9, 10 and 11 (landed
  round, in-flight round, floor 39 inclusive — all confirmed at `f4a33d3d` lines 105–117). The line at
  1695 keeps its text; this entry is the correction.

  Receipts: `.ufo/waves/round-47/build/K47ScribeLesson/case-count-check.txt` (commands and outputs
  above, run 2026-11-06T19:35Z).
```

## Suggested LOG.md companion line (routed item 1 asks for "a new SCORECARD/LOG entry")

Append where the round-47 entry records non-claim work:

```markdown
- Erratum E47-1 (SCORECARD.md:1695, round-46 operability row): `(8 → 11 cases)` / "cases 9–11" reads
  `(8 → 12 cases)` / "cases 9–12"; verified at `f4a33d3d:corpus/claims-declared.sh:122` (`$cases -eq 12`)
  against `f5977284:...:102` (`-eq 8`); receipts `build/K47ScribeLesson/case-count-check.txt`.
```

## Checks this draft rests on (all run, none inferred)

| claim | command | observed |
|---|---|---|
| landing asserts 12 | `git show f4a33d3d:corpus/claims-declared.sh \| grep -n 'cases" -eq'` | `122:  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 12 ]; then` (rc 0) |
| round-46 BASE asserted 8 | `git show f5977284:corpus/claims-declared.sh \| grep -n 'cases" -eq'` | `102:  … -eq 8 ]; then` (rc 0) |
| round-47 BASE still 12 | `git show 252ef1ca:corpus/claims-declared.sh \| grep -n 'cases" -eq'` | `122: … -eq 12 ]; then` (rc 0) |
| case 12 exists and is K46RP-02's | `git show f4a33d3d:corpus/claims-declared.sh \| grep -n 'case 12' -A3` | lines 118–121, quoted above |
| receipts print 12 | `grep -n 'PASS (12 cases)\|PASS (8 cases)' .ufo/waves/round-46/final/measured-at-candidate.txt .ufo/waves/round-46/controls/{c1-base,gates-base}.txt` | `measured-at-candidate.txt:4`, `:64`; `c1-base.txt:2`; `gates-base.txt:15` |

Note for the integrator: `SCORECARD.md` has no `## Errata` section today (`grep -n '^## Errata'
SCORECARD.md` → nothing; the file is 1700 lines and ends with the round-46 adjacency row). The round-46
lane put its errata in the lesson (`corpus/lessons/round-46.md` §Errata, E46-1/E46-2) and the round-46
closure routed this one to SCORECARD. Appending the section is the only edit this draft asks for.
