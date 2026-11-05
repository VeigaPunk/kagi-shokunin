# K39ReviewDeclared — round 39 attack report (C2 declared-axis gate)

Seat: reviewer pair 2/2, calibration lane. Leaf; no delegation, no commits.
Scratch: `/fast/scratch/hyaku/kagi-r39/K39ReviewDeclared/` (cand = `6742fdef`,
base = `06144518`, predecl = `1909e387`; one `git archive` extraction each, verified
`git -C lane rev-parse --show-toplevel` = lane before nothing was committed anywhere —
zero commits made, zero git mutations performed).

Candidate-vs-predeclaration inputs are byte-identical for every C2 input
(`corpus/claims-declared.sh`, `corpus/claims-declared.tsv`, `plans/round-39-c2.sh`;
digests in `receipts/sha256-candidate-inputs.txt`).

## Reproduction (required slices)

- `bash plans/round-39-c2.sh` on the candidate, `HYAKU_SCRATCH` = my scratch: prints `3`, rc 0
  (receipt `receipts/c2-counter.txt`).
- `bash plans/round-39-c1.sh` on the candidate: prints `3`, rc 0 (receipt `receipts/c1-counter.txt`).
- Controls reproduced on the candidate tree with the lane's own runner
  (`plans/round-39-controls.sh`): `c1_nowork` → 0, `c2_nowork` → 0.
- Real-tree gate rules hold on the candidate: `bash corpus/claims-declared.sh --root .` →
  `CLAIMS_DECLARED: CLEAN (claims=2)`, exit 0; the real `[C1]` row's first cell is `freshness`
  and the real `[C2]` row's first cell is `calibration`, exactly one tagged row each in the
  round-39 post-move section (SCORECARD.md lines 1489–1490).
- Counter internals: same 3 as the predeclaration control `c2_positive_three`. The counter's
  positive control is its own miniature fixture, so it measures the gate against its own
  planted mutants, not against the real lane text (that reading is the kill rule's separate
  real-tree run, verified above).

Both frozen targets reproduce as declared. No counter-freshness drift; the counter is not
read-different on the candidate than on the predeclaration (inputs are identical).

## Attack battery (17 fixtures, `attack.py`, full log `receipts/attack-battery.txt`)

| Fixture | Attack idea | Gate verdict |
|---|---|---|
| base / base_again | do-nothing control | CLEAN (claims=2), deterministic |
| a1_dup_manifest | exact duplicate manifest row | **CLEAN — undetected (D1)**, claims=3 on CLEAN banner |
| a1b_dup_conflict | duplicate row with a conflicting axis (depth) | caught (rc=1), MISMATCH |
| a2_fence_heading | heading inside a fenced code block | **CLEAN — undetected (D2)** |
| a2b_comment_heading | heading inside an HTML comment | **CLEAN — undetected (D2)** |
| a2c_spacing | double space before `##` | caught, plan-heading-not-calibration |
| a3_missing_row | tagged row deleted | caught, tagged-rows-0 |
| a4_dup_tag | two `[C2]` rows inside the round-39 section | caught, tagged-rows-2 |
| a4b_cross_section_tag | genuine `[C2]` row kept only in the round-38 section | **CLEAN — undetected (D3)** |
| a5_wrong_section | tagged row moved to the wrong section | caught, tagged-rows-0 |
| a6_axis_relevance | conspiratorial relabel: manifest + heading + scorecard all moved to `depth` | **CLEAN — undetected (D4)** |
| a6b_heading_only | heading alone relabelled | caught, plan-heading-not-calibration |
| a7_suffix_after_colon | suffix appended after the heading colon | CLEAN (over-match ceiling, named below) |
| a8_padded_first_cell | `|   freshness   |` padded axis cell | **CLEAN — undetected (D5)** |
| a9_double_space_heading | `## Round  39 — post-move` heading drifted | caught, tagged-rows-0 (fragile, not a defect) |
| a10_trailing_after_colon | description text after the colon changed | CLEAN (over-match ceiling, named below) |

Refinement battery + edge cases (`axis-probes.py`, receipts `axis-probes.txt`; plus fixtures
in `attack2/` and `attack/` outside the two scripts):

- k1/k2: whitespace padding around the axis cell → CLEAN
  (gate's awk `sub(/^\| */)` and `sub(/ *\|.*/)` swallow padding) → D5.
- k3/k4/k5: wrong/typo/uppercase axis cell → caught, MISMATCH.
- k6: `[C2]` smuggled into the middle ("what moved") cell → CLEAN — the tag is searched by
  `index($0, tag)` anywhere on the row, but the count is per tagged *row*, so a smuggled tag
  in the real tagged row's own cell (or the same row) is tolerated; a smuggled tag on a
  *different* row makes `tagged-rows-2`, which was caught (damp2). Only the sweeping `first
  cell = axis` check for k7 fires correctly.
- damp5 (pre-section table), damp6 (Round 40 section), damp7 (`Round 39b` heading):
  CLEAN — out-of-window rows are invisible by design; not a defect for round 39, matches
  the attentive prefix/section semantics.
- damp8 (`| 9 | [C2] …` with no axis cell), damp9 (empty axis cell): caught.
- e1 (`#`-commented heading), e2 (heading inside an unclosed comment), b1/b5 (heading only
  inside a fence), h1 (`## C1 — freshness: ` with empty description), h2 (heading with junk
  suffix), a7, a10: CLEAN — these are the substring-heading over-match window (D2/D6).
- j1 (a second duplicated `## Round 39 — post-move` heading with a decoy tagged row):
  caught, tagged-rows-2 — duplicate sections are not exploitable for a single legal row.
- damp2 (tag smuggled into the evidence cell of an unrelated row): caught (row count inflates).
- z1 (heading placed in the wrong plan file `plans/round-40.md`): caught.
- z2 (symlinked `plans/round-39.md` → another file): the gate follows symlinks; reads the
  linked body, not the link name. Matches R38-D4-class symlink concerns; already routed
  (not this round's counter) and unclaimed here.
- g1 (twin tagged rows with identical first cell): caught, tagged-rows-3.
- y1: arrow-cell (`9 → 9`) fixture mirrors the real scorecard shape and still matches the
  fixture card used in the counter. No discrepancy.

## Defects (calibration lane, so counted even when the counter reads 3)

- **D1 — duplicate manifest rows silently inflate `claims=N` on the CLEAN banner.** Two
  identical rows for the same `(round, claim)` read CLEAN with `claims=3` (fixture `a1`).
  Consequence: the gate's CLEAN count overstates the number of distinct declared claims; a
  spoofed manifest can look like an extra covered claim without triggering anything. The
  frozen C2 counter result (3) is unaffected because the counter only counts detections of
  relabels, not the banner. Severity: low, cosmetic on CLEAN.
- **D2 — heading is matched by `grep -qF` mid-line, so it passes anywhere in the file.** A
  fake "heading" inside a fenced code block, inside an HTML comment, after a `#` text line
  (`# ## C1 — …`), or with the real heading removed and the string kept only as prose, all
  read CLEAN (a2, a2b, e1, e2, b1/b5 variants). The counter's planted X2 mutant (a literal
  heading relabelled line-by-line) is still caught because the relabel genuinely removes
  the correct line; the fake-text window is outside the frozen mutant set. Severity: medium —
  a `## C1 — freshness:` string in a code fence can satisfy clause (a) of the predicate with
  no real heading present.
- **D3 — `tagged-rows-N` counting is confined to the section matching `## Round <round> —
  post-move`, so a legal tag in a *previous*-round section is invisible.** Fixture `a4b`
  puts the exact same `[C2]` row inside the round-38 post-move section (counter fixture
  claims it "must not be read") and the round-39 section — everywhere CONSISTENT, this is
  meant to show the round-38 residue is safely ignored; but it means a round-39 claim row
  could be removed (a3 catches) or the round-39 section's row edited to a decoy that leaves
  its pill as Round-38 residue uncounted (a4b is precisely the residue that "must not be
  read", so the residual tag is not an error; the C2 predicate wording "holds exactly one
  table row tagged `[<claim>]`" is confined, matching the intended section restriction).
  Not a defect: windowing is deliberate and matches the plan's "post-move section" wording;
  documented so nobody misreads a4b as an attack.
- **D4 — axis relevance is unratable by the gate (also asserted by the plan's named
  ceiling).** A conspiratorial relabel of all three surfaces (manifest row + plan heading +
  SCORECARD axis cell) reads CLEAN on a full lane-tree copy in scratch
  (`receipts/lane-copy-attack.txt`, and fixture a6). This is explicitly the plan's named
  ceiling ("does not judge whether the axis is the right one for the move"); it is reproduced
  here so the ceiling is witnessed rather than assumed. Not a defect against the frozen
  predicate; it *is* the calibration claim's honest limit.
- **D5 — the axis-cell extractor strips padding, so an axis token re-cased, re-spaced, or
  padded inside the first cell of the tagged row passes the `first cell` equality check when
  the manifest entry also has no padding.** Concretely `|   freshness   |` pads to
  `freshness` via the awk `sub(/^\| */)`/`sub(/ *\|.*/)` trims. Result: whitespace-shaped
  axis cells are impossible to distinguish from the true declaration. This is benign for a
  frozen manifest (rows are frozen) but is a hole when the manifest itself is
  de-padded/whitespace-normalized upstream of the gate. Severity: low; only exploitable with
  dual-edit access to both surfaces, which is outside the gate's threat model.

## Over-match ceilings, witnessed (not defects)

- a7 and a10: heading equality is substring (`grep -qF`) over the whole line: any string
  starting `## C1 — freshness:` passes, including one with a different description tail or a
  code fence around it. Trailing junk after the colon is accepted (a7, a10); so is a fenced
  or commented-out heading (D2). The predicate's "carries the heading" is implemented
  as "carries the string", looser than the plan prose.
- Section case-jigs (a9, i1) all catch robustly; only one padded-axis shape (k1/k2) walks
  through (`D5`). This is a calibration claim, not a fitness claim; it holds for the three
  frozen mutants.

## "Is declared calibration actually measured?" 

Yes, for the frozen claim definition: the C2 counter prints the number of planted
declared-axis mutants on the fixture lane the gate reports as `MISMATCH`, and the
do-nothing control (`c2_nowork` = no instrument) prints 0 — reproduced on the candidate
tree with the lane's own runner (didn't just take the predeclaration's word). The
calibration reading is also consistent with the gate's real-tree behavior: real lane text
is CLEAN with the real `[C1]`/`[C2]` rows at the declared axes.

What the claim does *not* measure (all named as ceilings in the plan, and witnessed here):
axis semantic fitness (D4/a6), non-declared history (round-38 residue, damp6), surrogate
detection of gate-defeating mutants (a neutered or exit-code-inverted gate drives the
counter to 0 — receipts in `attack2/`/counter-dup runs — but that is a *counter* ceiling
against an altered instrument, outside the "relabeled lane text" claim). The X1–X3 planted
mutants are lane-text relabels, which is the exact scope of the calibration claim.

## Residual risk / verification gaps

- The counter builds a fresh fixture per mutant and asserts `CLEAN` on the unmutated one;
  both global counter-internals (mktemp suffix reuse across runs of the same script in the
  same scratch) and the gitless `cp -r` extraction make it a read-only instrument, so no
  build/test verification exists or is required by the slice.
- `D1` is cosmetic on the CLEAN banner; no lane-facing integer is wrong (the counter's `N`
  is the mutant-detection count, not the banner).
- I did not mutate the lane's frozen counter file `plans/round-39-c2.sh` itself in the
  reported numbers; my counter run is a byte-identical script either from the candidate or
  predecl tree (same digest). The instrument-level attack runs (neutered gate, exit-code
  inversion, duplicate row inside the counter fixture) suggest three counter-side ceilings
  (scripts in `attack2/`/`scratch` scripts, reproduced visibly in my runs) — round-40
  amendment material if the wave wants them; they do not falsify C2 today.
