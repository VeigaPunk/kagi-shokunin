# ScribeDocs — round-33 prose artifacts (final report)

Seat: `ScribeDocs` (scribe, leaf). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE: `76f4eeae7aa9af4dbb9423f5632b55791824253a`. Frozen claims contract
`plans/round-33.md` (commit `880824b1d3da5f70b2fe489a34fe866a47314672`), read first.
No lane-tracked file was written by this seat. No vault, account, handler, CDP or
`op` reference contact: `op --version` only (`2.41.1`, `/usr/bin/op`). No network
beyond the ten NIST URLs the plan names. No tool installed or upgraded.
Scratch `/fast/scratch/hyaku/kagi-r33/ScribeDocs/` removed before yield.

## Deliverables (7 prose artifacts + this report)

Under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-33/build/docs/`:

| file | contents |
|---|---|
| `round-33-lesson.md` | Gate (5 candidates), Mistakes (M33-1..M33-4), Migrations (11 rows), Measurements, Self-evaluation |
| `quality-QM34.md` | the landed QM34 row verbatim under the assignment's `## Criterion from the round-33 build` heading, the measured fix-shown-able-to-fail, both red-before states, and the no-duplicate landing note |
| `scorecard-round33.md` | pre-move (6 rows, 4 cols), post-move (6 rows, 4 cols), capability row (4 cols), R32-4 prose repair |
| `province-core-bullet.md` | byte-exact delete of the Frontier line, the Core bullet, three landing checks |
| `readme-frontier-removal.md` | byte-exact delete of lines 115-117, the coverage-map sentence, four landing checks |
| `round32-captured-by.patch` | unified diff; `git apply --check` OK against the pre-patch revision `880824b` in a fixture repo (and on a fresh shared clone before the L1's build commit); a cell-level check shows only `captured-by` changed (M32-2 → `QM34`, M32-3 → `none`) |
| `s072-scope-fix.md` | the BASE old text and the exact landed new text |

## What the L1 had already installed at hand-off (and the drift)

The L1 landed and committed the build as `441581b` (`round-33: prefreeze BASE controls (C1) + NIST key-management assimilation (C2); QM34, routed R32-2..R32-4`), so parts of these drafts are already lane bytes:

- `PROVINCE.md`: the Frontier line is replaced by the round-33 Core bullet from
  `province-core-bullet.md`; the L1 additionally amended the round-31 bullet's tail to
  say the NIST leads "moved to core in round 33 (below)" (a sensible companion edit,
  not in my draft).
- `corpus/README.md`: the Frontier block is deleted and the coverage-map sentence from
  `readme-frontier-removal.md` is present; the L1 also added three coverage rows for
  the round-33 artifacts.
- `corpus/lessons/round-32.md`: exactly the two `captured-by` cells changed, byte for
  byte as in `round32-captured-by.patch`.
- `SCORECARD.md`: both round-33 sections, the capability row, and the repaired prose
  sentence are installed; the chosen repair names **33**, not 29 — see "R32-4" below.
- `corpus/QUALITY.md`: QM34 is landed under
  `## Criterion from the round-33 C1 capability (landed round 33)`, i.e. the L1 kept
  the landed heading rather than the assignment's `## Criterion from the round-33
  build`. The row bytes satisfy the assignment; appending a second QM34 would be a
  duplicate id, so `quality-QM34.md` records the reconciliation instead.
- `corpus/lessons/round-33.md` was installed from an **earlier snapshot** of my draft
  (10:41; my final draft is later and is the version in `build/docs/`). The installed copy already carries M33-4 and the
  two extra Migrations rows (S078/S079 normalization; the `prefreeze-32.txt` write
  collision), which I merged back into `round-33-lesson.md`. My draft additionally
  carries: the final C1 measurements (`b634a8d1…`, 11 cases), the measured C2 verdict
  with `captures=82`, the fuller M33-3 evidence with the real controls path, the
  connector paragraph, and the updated self-evaluation. **A re-install from
  `build/docs/round-33-lesson.md` is the complete version**; nothing in it contradicts
  the installed bytes, it only completes them.

## Measured final state (read once, from committed receipts; cheap counters run once)

| reading | value | source |
|---|---|---|
| gate bytes | sha256 `b634a8d1a1a1…`, 256 lines | `corpus/prefreeze-control.sh` |
| round-33 controls | `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0 | `final/c1-final.txt`, `final/final-gates.txt` |
| selftest | `PREFREEZE_SELFTEST: PASS (11 cases)` exit 0 (11th = `base-isolation`) | `final/c1-final.txt` |
| round-32 replay | `MISMATCH sd5 expect=3 measured=1`, `MISMATCH total expect=10 measured=8`, `PREFREEZE: MISMATCH (controls=2 mismatch=2)` exit 1 | `final/c1-red-witness.txt`, `build/prefreeze-32.txt` |
| captures red witness | `MISMATCH captures expect=101 measured=72` exit 1 | `final/c1-captures-red.txt` |
| NIST entries | 2 | `ls corpus/knowledge/nist-key-management-*.md` |
| registry rows | 82 | plan counter, run once |
| Frontier NIST lines | 0 | plan counter, run once |
| capabilities rows naming the gate | 1 | plan counter, run once, `SCORECARD.md` |
| lane census | `SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=22 captures=82 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0 | `final/census-c2-at-tip.txt`, `final/final-gates.txt` |
| sweep | `SELF_DESCRIPTION: MISMATCH n=2 (SD1..SD5=0 SD6=2)` | `final/c2-and-calibration-gates.txt` |
| eol | `EOL_SWEEP: CLEAN (crlf=0 attrs=5 scope=lane-minus-git-jj-ufo)` exit 0 | `final/final-gates.txt` |

## Findings

1. **C1 is met on the final bytes.** CLEAN 4/0, replay MISMATCH 2/2, selftest 11 cases,
   capability row 1. Residual: the red-witness receipt is bound to the pre-hardening
   script `c265a5d8…`; M33-4's hardening added a selftest case only, and the final bytes
   `b634a8d1…` re-verify CLEAN + 11 cases. The receipt/script binding gap is disclosed
   in `round-33-lesson.md` §Migrations and §Measurements rather than claimed clean.
2. **C2 is not admitted under its frozen kill rule (M33-3).** The plan declares BASE
   `captures=101` and target `captures=111`; the census counter counts registry ids that
   carry a capture, so its maximum is the registry row count. The BASE pin `R21-02`
   itself said `captures=72`, and the plan's named command
   (`scripts/sources-census.sh validate`) prints no `captures=` field at all. Measured
   pair: 72 → 82. The gate this round builds fires on the plan's figure
   (`final/c1-captures-red.txt`). The artifacts (2 entries, 10 rows, 10 captures,
   Frontier removed) landed; the claim is a partial move.
3. **M33-4 (found by MutGate, recorded in the installed lesson).** The ten-case selftest
   could not witness `--base`: a mutant that measured the live worktree passed. The fix
   is an eleventh `base-isolation` case; `final/c1-final.txt` records `PASS (11 cases)`.
   I merged this row into the lesson draft and updated the scorecard/criterion counts.
4. **Connector.** 0 of 20 sibling lanes hold NIST key-management source ground (C2
   source ground sole). One capability-class neighbour: kasegi
   `corpus/instruments/freeze-check.py:2-12` states the same replay-predicate class as
   C1. Reported in the lesson, the scorecard adjacency row and the PROVINCE landing
   checks; not absorbed or adjudicated.
5. **R32-4 prose repair.** The stale sentence was `The latest first-working round in
   this table is 25 (release-clock observation).` Against the pre-round-33 table the
   correct value was 29; once the round-33 capability row lands, the correct value is
   **33 (pre-freeze BASE control execution)**. The installed SCORECARD already says 33;
   `scorecard-round33.md` now matches that and explains why 29 was the interim value.
6. **QUALITY heading.** The assignment asked for `## Criterion from the round-33 build`;
   the lane already carries QM34 under `## Criterion from the round-33 C1 capability
   (landed round 33)`. The file's row is valid and cites M32-2 plus this round's red
   witness. `quality-QM34.md` presents the row under the requested heading and states
   that exactly one heading must land (re-head is content-preserving; no duplicate row).
7. **S078/S079 normalization.** The two legacy PDF capture rows were corrected from
   `rendered-text-v1` + a `pdftotext`-derived digest to `raw-literal-v1` + `-`, because
   the declared normalizer refuses PDF bytes (`SETUP`). Their capture digest
   (`68266cb1…` / `52b9a7d3…`, 622,785 / 663,635 bytes) equals the staged campaign pin
   and this seat's independent body hash. Recorded in the lesson Migrations.
8. **Receipt write collision (disclosed in the installed lesson).** The L1's re-run and
   ExecGate's run wrote `build/prefreeze-32.txt` at the same path; ExecGate restored the
   measured bytes (sha256 `6e7a3768…`) and copied them to `final/c1-red-witness.txt`.
   Both writers measured the same verdict, so the evidence stands; the collision is the
   L1's scratch-discipline defect and is recorded, not smoothed over.
9. **Lane gates at the tip.** Cells: `CELL_AUDIT: POLICY` with `R25-02` FAIL and
   `R29-01`/`R29-02` POLICY (operator-owned), plus STALE-POINTER rows for PROVINCE,
   SCORECARD, LOG and SOURCES that the L1's re-stamp commit resolves. Self-counts:
   `POLICY` with the two allowlist rows. Sweep: `n=2`, both SD6 integrator-owned. These
   are the L1's landing duties; no claim of a green ledger is made here.

## Evidence: the ten sources re-opened by this seat (2026-11-04)

`curl -fsSL --compressed --max-time 90`, no credentials, HTTP 200 for all ten.

| id | bytes | body sha256 (this seat) | prefix agrees with the capture row |
|---|---|---|---|
| S073 | 47203 | `fd216d3037001607f8e4ea4e4f25b6a4ac2912ab32e8356dccaa07de75ac60de` | raw differs (volatile page), size agrees |
| S074 | 45351 | `7587435e6e089adb4bb729cdc303f683df8f2b6b10820f662a053665318fcbdd` | same |
| S075 | 42741 | `abf52314e578d13cc3268c155a5f5ca220ae47606849a41d89b7639719a924a2` | same |
| S076 | 44782 | `c36833f44611700de7172efa190634c9ea4a9e4770efd78349fd5b62242b2ffb` | same |
| S077 | 44903 | `81dcbd0d1632c4fedc8394134cbe782ef4b2968d0649c5474b46e7f1d0c77865` | same |
| S078 | 622785 | `68266cb10868a1fee83fb8bcebbee9573fc738cee9141ee94d03649bad8538d5` | equals capture `fsha` and campaign pin |
| S079 | 663635 | `52b9a7d321ab0f8173032869290b3b4620dd1ced57e36c42e65e7e50ff38c3a3` | equals capture `fsha` and campaign pin |
| S080 | 49598 | `7faff667dfba4bbd261ad1d82614ccc1da121ee8c6014772ddd8144b4c50ed1e` | raw differs (volatile page), size agrees |
| S081 | 45934 | `0f915d5cdfb3e687ca845d383b746b56f575680d7607e9d85acc59c3943a4b13` | same |
| S082 | 45595 | `d19603eadd61b264012e70c7ccabdcf6e0466dd964dfe954f631ca3cb5acf903` | same |

Located quotes (whitespace-normalized; word counts by `split()`; all ≤25):

| id | anchor | quote | words |
|---|---|---|---|
| S073 | Document History | `05/04/20: SP 800-57 Part 1 Rev. 5 (Final)` | 8 |
| S073 | metadata | `Date Published: May 2020` | 4 |
| S073 | metadata | `Supersedes: SP 800-57 Part 1 Rev. 4 (01/28/2016)` | 8 |
| S074 | title | `(Initial Public Draft)` | 3 |
| S074 | metadata | `Date Published: April 17, 2026` | 5 |
| S074 | metadata | `Comments Due: June 16, 2026 (public comment period is CLOSED)` | 10 |
| S074 | Planning Note 06/30/2026 | `The public comments received are now available.` | 6 |
| S075 | Document History | `06/04/20: SP 800-133 Rev. 2 (Final)` | 6 |
| S076 | page alert | `Withdrawn on May 23, 2019` | 5 |
| S076 | page alert | `Superseded by SP 800-57 Part 2 Rev. 1` | 8 |
| S077 | page alert | `Withdrawn on January 22, 2015` | 5 |
| S077 | page alert | `Superseded by SP 800-57 Part 3 Rev. 1` | 8 |
| S078 | PDF p.1 Warning Notice | `The attached publication has been withdrawn (archived), and is provided solely for historical purposes.` | 14 |
| S078 | PDF p.1 Withdrawal Date | `Withdrawal Date May 23, 2019` | 5 |
| S078 | PDF p.1 Withdrawal Note | `SP 800-57 Part 2 is superseded in its entirety by the publication of SP 800-57 Part 2 Revision 1.` | 19 |
| S079 | PDF p.1 wrapper | `The attached publication has been archived (withdrawn), and is provided solely for historical purposes.` | 14 |
| S079 | PDF p.1 Withdrawal Date | `Withdrawal Date: January 2015` | 4 |
| S079 | PDF p.1 Withdrawal Note | `SP 800-57 Part 3 is superseded in its entirety by the publication of SP 800-57 Part 3 Revision 1 (January 2015).` | 21 |
| S080 | Document History | `05/23/19: SP 800-57 Part 2 Rev. 1 (Final)` | 8 |
| S080 | Planning Note 07/01/2025 | `This publication is currently being reviewed.` | 6 |
| S081 | Document History | `01/22/15: SP 800-57 Part 3 Rev. 1 (Final)` | 8 |
| S081 | Planning Note 07/01/2025 | `This publication is currently being reviewed.` | 6 |
| S082 | Document History | `03/21/19: SP 800-131A Rev. 2 (Final)` | 6 |
| S082 | Planning Note 10/21/2024 | `An initial public draft of Revision 3 has been posted for public comment through December 4, 2024.` | 17 |

## Undrafted without inventing evidence

- The C1 red-witness verdict on the **final** gate bytes: only the pre-hardening receipt
  exists; I state that gap instead of implying a re-run.
- The L1's stamp/ledger/census projections (`stamp`, `verify`, `cells`, `self-counts`):
  named as the L1's landing duties, not asserted.
- Which QM34 heading survives: recorded as a decision for the L1, with the
  content-preserving option; the landed heading is valid.

## Scope compliance

- Wrote only `build/docs/*` and this report; no lane-tracked file, no `considerthese/`,
  no fleet-root tracked file, no sibling repo, no `~/.local/bin`.
- Read-only git only (`rev-parse`, `show`, `log`, `diff`, `status`, `clone --shared`);
  the one fixture clone for the patch check was
  `/fast/scratch/hyaku/kagi-r33/ScribeDocs/check4`, whose `rev-parse --show-toplevel`
  printed that path before `git apply --check` exited 0.
- Ten `GET`s, no credentials; `op --version` only.

## Result

Seven draft artifacts exist and are structurally valid: the lesson has the five named
sections and four mistake rows; QM34 is a 4-column row under the requested heading; both
SCORECARD tables are 4 columns with six rows each; the captured-by patch applies cleanly
to a fresh clone and changes exactly the two cells; the S072 old→new is the exact landed
text. C1's readings are met on the final bytes; C2 is recorded as not admitted under its
frozen kill rule, with the plan's unmeasured census figure (M33-3) named and witnessed,
and the round's own selftest hardening (M33-4) recorded.
