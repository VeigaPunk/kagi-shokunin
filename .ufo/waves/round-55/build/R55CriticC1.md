# R55CriticC1 — C1 (calibration) counter attack, round 55

Seat: R55CriticC1 (leaf, no dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
measured revisions obtained with `git -C <lane> rev-parse` and written literally:

- BASE `ebe095857a734caf5efdd7bd776feb22b4e23972`
- predeclaration `f2b986fadd8f8551e760cc89f59e0ae0edb0d499`
- candidate `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`

Scratch `/fast/scratch/hyaku/kagi-r55/R55CriticC1` (trees `t`, `base`, `basetree`,
`c1only`, `c2only`, forgeries `fA`–`fL`); every counter run is
`bash <lane>/plans/round-55-c1.sh <rev>` or `--tree <scratch tree>` (each extracts into
its own scratch). Receipts in `.ufo/waves/round-55/build/R55CriticC1.d/`.

## Headline

The candidate reading is real, not a do-nothing and not a cheaper-landing artefact:

- candidate `bash plans/round-55-c1.sh 348aa3b8…` ⇒
  `C1_USEDBY_GAP: value=0 gap=0 citations=90 entries=37 guard=1 (bad=none)` exit 0
  (`receipt-c1-candidate.txt`).
- BASE `bash plans/round-55-c1.sh ebe09585…` ⇒
  `C1_USEDBY_GAP: value=25 gap=25 citations=88 entries=37 guard=1 (bad=none)` exit 0,
  25 `GAP` lines (`receipt-c1-base.txt`).

Every cheap route to 0 is closed by g1/g2/g3/g4: the pair set is pinned (g1), the entry
names (g2), the row ids (g3), and every mined row's used-by part must carry a `source:`/
`cites:` record (g4). With no pair removable, GAP=0 requires the used-by path in the row,
so the 20 pre-existing cells (25 paths) and the 10 entry records cannot be skipped, and
g5 forces the gate change: `fM` (the candidate tree carrying the BASE census) reads
`FAIL gap=0 … g5:census-exit`, the BASE census reporting exactly 25 `SC_USEDBY_NOCITE` —
the 25 new used-by cells whose record is a `cites:` line (`receipt-fM-base-census.txt`).

What survives is instrument strength, not a false value at the candidate.

## Attack table (all forgeries are mutations of a scratch copy of the candidate tree)

| # | forgery | command | counter line | verdict |
|---|---|---|---|---|
| 1 | do-nothing (BASE) | `c1.sh ebe09585…` | `value=25 … guard=1` | killed as a 0 (no-work reads 25) |
| 2 | predeclaration | `c1.sh f2b986fa…` (lane receipt) | `value=25 … guard=1` | killed as a 0 |
| 3 | strip one BASE mention (control F1) | controls receipt | `FAIL … g1:2-base-citations-gone` | killed |
| 4 | pad a used-by cell with a knowledge entry that has no record (control F2) | controls receipt | `FAIL … g4:1-used-by-parts-without-record,g5:census-exit` | killed |
| 5 | pad all 25 paths + replace the census by a printer (control F3) | controls receipt | `FAIL gap=0 … g4:25-used-by-parts-without-record` | killed (g4 is independent of g5) |
| 6 | delete an entry (control F4); rename an entry and rewrite its used-by cells (`fE`) | `c1.sh --tree fE` | `FAIL gap=0 … g1:5-base-citations-gone,g2:1-base-entries-gone` | killed |
| 7 | symlink an entry file (control F5) | controls receipt | `FAIL … g1/g2` | killed |
| 8 | **symlink the whole `corpus/knowledge` directory** (`fJ`) | `c1.sh --tree fJ` | `value=0 … entries=37 guard=1` | **survives** (entries read through the symlink; C2 already rejects symlinked capture components, C1 does not) |
| 9 | rewrite a BASE token `S047`→`S-047` (control F6) | controls receipt | `FAIL … g1:1-base-citations-gone` | killed |
| 10 | **add non-token mentions** `S 104`, `S-103` (`fG`), fullwidth-digit / Cyrillic-Ѕ ids (`fI`) | `c1.sh --tree fG`, `… fI` | `value=0 … citations=90 guard=1` | **survives by declared ceiling** (counter header, plan, SCORECARD cell all name "a form the token rule does not match") |
| 11 | delete a registry row (control F7) | controls receipt | `FAIL … g1:1,g3:1` | killed |
| 12 | land the reference tree on the BASE census (control F8), rebuilt as `fM` | `c1.sh --tree fM` | `FAIL gap=0 … g5:census-exit`; BASE census `findings=25` SC_USEDBY_NOCITE | killed |
| 13 | withdraw one used-by record (control F9) | controls receipt | `FAIL gap=1 … g5:census-exit` | killed |
| 14 | a second column-1 `cites:` line (`fC`) | `c1.sh --tree fC` | `FAIL gap=0 … g5:census-exit` | killed (census `multiple-cites-lines`; the counter's `field()` sees only the first — a census-fatal disagreement) |
| 15 | **`cites:` line inside a fenced code block** (`fB`: `# …`, ```` ``` ````, `cites: S072, S112 (…)`, ```` ``` ````) | `c1.sh --tree fB` | `value=0 … guard=1` | **survives** (both `field()` and the census `cites_field()` are fence-blind; the registry row parser is fence-aware) |
| 16 | **remove every body mention, keep the ids only on the `cites:` line** (`fK`) | `c1.sh --tree fK` | `value=0 … guard=1` | **survives** (CITATION reads the whole file, so the record manufactures the pair g1 preserves; the record is not corroborated by the prose) |
| 17 | **move the `cites:` ids onto the `source:` line** and delete the `cites:` line, 9 sourced entries (`fH`) | `c1.sh --tree fH` | `value=0 … guard=1` | **survives** (cross-references become support; SC_ENTRY_CITE then accepts them because the same used-by cells list the entry) |
| 18 | CRLF line endings on an entry (`fD`) | `c1.sh --tree fD` | `value=0 … guard=1` | no effect (robust, not a lever) |
| 19 | pad a used-by cell with a lesson path that does not record the id (`fF`) | `c1.sh --tree fF` | `FAIL gap=0 … g4:1-used-by-parts-without-record,g5:census-exit` | killed |

Full lines for every row are in the receipts named above (`receipt-f*.txt`, `receipt-h*.txt`).

## Cross-checks

- **The new gate and the counter agree on the motivating population.** The candidate
  census run on the BASE tree (candidate `corpus/sources-census.sh`, BASE entries and
  registry) gives `SOURCES_CENSUS: FAILED (findings=25 rows=112)` with exactly 25
  `FINDING SC_BODY_CITE`, per-entry distribution identical to the counter's 25 `GAP`
  lines (oidc 4, cdp 3, onepassword-machine 4, vault 4, openbao-kv 1, secret-scan 3,
  nist-guidance 1, nist-parts 1, op-ref 2, sops-age 2). `receipt-census-candidate-on-base.txt`.
  This also proves no BASE pair was already on its entry's `source:` line (otherwise the
  census would not have flagged it and findings would be < 25), so g4 forces new records
  rather than accepting an existing line.
- **The motivating mentions are real prose.** All 25 BASE occurrences are sentences such
  as `rows S047/S050`, `(S017/S018, with S020's announcement …)`, `S023 corrects S013's`,
  `rows S055-S056` — not command text or file names. `receipt-c1-base.txt` + BASE greps.
- **No hidden id forms at BASE or candidate.** Greps of the BASE entries for
  `S<space>NNN`, `S-NNN`, 1–2-digit `SNN` and `S0NNx` forms return no registry-id
  occurrences (the only `S1`/`S2` hits are the sentinel names at
  `adjacency-scope.md:179,185`); the candidate adds none. The token-rule ceiling
  (`S 104`, `S-103`, fullwidth/Ѕ forms) is therefore not exploited by either tree — it is
  a boundary a future round could cross, not a defect in this landing.
- **Kill rule.** `git diff --stat f2b986fa 348aa3b8 -- plans/round-55.md plans/round-55-c1.sh plans/round-55-c2.sh plans/round-55-controls.sh` prints nothing, exit 0
  (matches `.ufo/waves/round-55/final/kill-rules.txt`). The instruments are frozen.
- **Selftest.** Every 0/1 run above passed g5, i.e. the candidate tree's
  `corpus/sources-census.sh --selftest` ended `SOURCES_CENSUS_SELFTEST: PASS` (78 cases,
  `receipt-c1-candidate.txt` run; standalone lane receipt also shows `PASS (78 cases)`).
- **Landing counts.** 10 files carry exactly one column-1 `cites:` line (grep: 10 matches
  in 10 files); 25 knowledge paths were added to used-by cells of **20** pre-existing rows,
  and the two new rows S113/S114 add 4 lesson paths (29 added paths, 22 touched cells).
  The claim's "25 used-by cells" is really "25 added knowledge paths in 20 cells"; the
  4 lesson paths are C2's new rows. Wording nit only.

## Axis fit

`SCORECARD.md:4` — "Axes owned by this lane: **freshness + calibration**". C1 compares a
lane statement (the registry's used-by cell, "which entries cite this row") against
observed state (the entries' bytes). That is calibration, the axis the lane owns, and the
discrepancy class is real (round-54 D1 found one instance; the counter finds 25 at BASE).
Axis fit: **yes**. Note the prior SCORECARD kept calibration at 9 while these 25
mismatches existed on a surface the axis covers; the round's cell keeps 9 → 9 and does not
say the earlier 9 was earned on the other calibration surfaces (claims, stamps, gates).
That is a disclosure nit, not a claim defect: after this landing the 9 is defensible and
gated. C1 is bookkeeping (registry ↔ entries); the lane's domain (secrets/key management)
is carried by C2 (ISO/IEC 11770-3), which is also a lane-owned axis.

## Do-nothing control

Not reachable. BASE reads `value=25 … guard=1` (my run and the lane's `c1-base.txt`); the
controls table fixes K1-BASE = 25 before the run and the pre-freeze receipt shows
`CONTROL K1-BASE expect=25 got=25 MATCH`. A no-work tree cannot read 0: g1/g2/g3 keep the
pair set and g4 requires the record. Control F3 (all 25 paths padded with no records) still
reads `FAIL` on g4 even with the census replaced by a printer.

## Separability (C1 vs C2)

- `c1only` = candidate minus C2's landing (S113/S114 rows and tsv rows removed, S113/S114
  capture files removed, the ISO entry restored from BASE; C1's cites lines, used-by cells
  and census kept): C1 ⇒ `value=0 gap=0 citations=88 guard=1`; C2 ⇒
  `value=0 amd=0 recheck=0 guard=1`. C1 lands without C2 and C1's landing does not lift C2.
- `c2only` = BASE plus C2's landing only (S113/S114 rows, ISO entry, lesson, fetch/quote
  rows, captures; BASE census): C1 ⇒ `value=25 gap=25 citations=90 guard=1`; C2 ⇒
  `value=2 amd=1 recheck=1 guard=1`. C2 lands without C1 and C2's landing does not lift C1.
- **Structural caveat (counterexample `fL`):** C1's g4 iterates *every measured mined row*,
  so on the candidate it reads C2's two rows and their used-by targets (the ISO entry and
  `corpus/lessons/round-55.md`). Removing `S114` from the lesson's `source:` line while
  every C1-owned edit stands flips C1 to
  `FAIL gap=0 … g4:1-used-by-parts-without-record,g5:census-exit` (`receipt-fL-crossread.txt`).
  So the plan's "Neither counter reads the other claim's surface beyond the census exit" is
  literally false for C1. The dependency is benign at the candidate (both targets record
  S113/S114 on their `source:` lines) and moves neither value; smallest correction is to
  reword the separability sentence (C1's row population is the measured registry, which
  includes C2's rows), not to change the counter.

## Impacted axes

- **calibration** — C1's value is real and 25 → 0; the surviving holes are precision of the
  instrument (fenced record, self-created record, `source:` mislabel, symlinked entry dir).
- **freshness** — indirectly: C1's g4 reads C2's S113/S114 rows; benign at the candidate,
  but the separability sentence overstates independence.

## Smallest safe corrections (each patched in scratch, each still reads 0/1 on the candidate)

1. **Fence-aware field extraction** (`field()` in `plans/round-55-c1.sh`; same change in
   `src_field`/`cites_field` in `corpus/sources-census.sh`, and `grep -c '^cites:'` must not
   count fenced lines). Patched counter `patched/round-55-c1-h5.sh`: candidate
   `value=0 … guard=1`; `fB` ⇒ `FAIL … g4:2-used-by-parts-without-record`
   (`receipt-h5-candidate.txt`, `receipt-h5-fB.txt`).
2. **Body-pair preservation in g1**: each BASE pair whose id occurs outside the BASE
   `source:`/`cites:` fields must still occur outside the measured fields. Patched counter
   `patched/round-55-c1-h1b.sh`: candidate `value=0 … guard=1`; `fK` ⇒
   `FAIL … g1b:3-base-body-citations-gone` (`receipt-h1b-*.txt`).
3. **No new sourcing in g4**: a BASE pair whose id was not on the BASE entry's `source:`
   line must be recorded on the measured `cites:` line (BASE ids only — C2's new rows are
   exempt). Patched counter `patched/round-55-c1-h4b.sh`: candidate `value=0 … guard=1`;
   `fH` ⇒ `FAIL … g4:23-used-by-parts-without-record` (`receipt-h4b-*.txt`; the first
   version h4 without the `sid in rb` narrowness flagged C2's S113/S114 rows, which is why
   the exemption matters).
4. **Reject a symlinked entry directory** in `entries()` (and the census's `$kdir`), the
   same rule C2 already applies to capture paths. Patched counter
   `patched/round-55-c1-h6.sh`: candidate `value=0 … guard=1`; `fJ` ⇒
   `FAIL … g1:88-base-citations-gone,g2:37-base-entries-gone`
   (`receipt-h6-candidate.txt`, `receipt-h6-fJ.txt`).

None of these changes the candidate's reading, and none may land this round (kill rule
freezes the instruments); the first two are the ones a canonical judge should require
before the claim's "names" is read as prose naming again.

## What I did not run

- The full 22-control script was not re-executed (the host is loaded 200+); the lane's
  `controls-prefreeze.txt` (22 MATCH) is cited, and I independently reproduced K1-BASE = 25
  and K1-REF-class = 0, plus the F1/F2/F3/F4/F5/F6/F7/F8/F9 classes I could rebuild as
  `fB`–`fL`/h\* runs.
- No live ISO fetch (out of scope for C1; C2's own seat carries the re-fetch).

## Receipts (`.ufo/waves/round-55/build/R55CriticC1.d/`)

`receipt-c1-base.txt`, `receipt-c1-candidate.txt`, `receipt-census-candidate-on-base.txt`,
`receipt-fA-metadata-move.txt`, `receipt-fB-fenced-cites.txt`, `receipt-fC-two-cites.txt`,
`receipt-fD-crlf.txt`, `receipt-fE-renamed.txt`, `receipt-fF-lesson-pad.txt`,
`receipt-fG-nontoken-forms.txt`, `receipt-fH-cites-to-source.txt`,
`receipt-fI-lookalike.txt`, `receipt-fJ-symlinked-dir.txt`,
`receipt-fK-metadata-only.txt`, `receipt-fL-crossread.txt`,
`receipt-c1only-c1.txt`, `receipt-c1only-c2.txt`, `receipt-c2only-c1.txt`,
`receipt-c2only-c2.txt`, `receipt-h1b-candidate.txt`, `receipt-h1b-fA.txt`,
`receipt-h1b-fH.txt`, `receipt-h1b-fK.txt`, `receipt-fM-base-census.txt`,
`receipt-h4-candidate.txt`, `receipt-h4-fH.txt`, `receipt-h4b-candidate.txt`,
`receipt-h4b-fH.txt`, `receipt-h5-candidate.txt`, `receipt-h5-fB.txt`,
`receipt-h6-candidate.txt`, `receipt-h6-fJ.txt`, and the patched counters
`round-55-c1-h1b.sh`, `round-55-c1-h4.sh`, `round-55-c1-h4b.sh`, `round-55-c1-h5.sh`,
`round-55-c1-h6.sh` (patched copies of the frozen counter, run with `REPO_OVERRIDE`; not
for use against the lane).
