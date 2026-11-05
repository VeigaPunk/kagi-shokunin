# K39ReviewAnchor — C1 anchor-gate + frozen-counter attack report

Lane branch master; commit under test `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee` (candidate), BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`, predeclaration `1909e3876341cc90246516886def37a7c9ea92f9`, frozen plan `7c11e769cd7c2450cf46faabcd3b43fca993f388`. Scratch extraction (one git archive 6742fde|tar -x into /fast/scratch/hyaku/kagi-r39/K39ReviewAnchor/) at 2026-11-05 08:15Z; a fixture copy at /tmp/c1t was used for the attack battery; scratch clone was committed once for prefreeze experiments and then discarded.

## Reproduced
1. **C1 counter**: `bash plans/round-39-c1.sh` prints 3, rc 0. /receipt: c1-canonical.txt
2. **C2 counter**: `bash plans/round-39-c2.sh` prints 3, rc 0. /receipt: c1-canonical.txt
3. **BASE0**: on an archive of BASE, both counters print 0, rc 0. /receipt: c1-canonical.txt
4. **Predeclaration PREFREEZE**: `bash corpus/prefreeze-control.sh run --base 1909e38… --controls plans/round-39.controls.tsv` from the canonical lane prints `OK c1_nowork expect=0 measured=0`, `OK c1_positive_three expect=3 measured=3`, `OK c2_nowork expect=0 measured=0`, `OK c2_positive_three expect=3 measured=3`, `PREFREEZE: CLEAN (controls=4 mismatch=0)`. /receipt: c1-canonical.txt
5. **Frozen predicate consistency**: the pinned anchor cells S034/S035/S039 exactly match pins in `corpus/anchor-pins.tsv` (recomputed sha256 equal) at candidate and predeclaration.
6. **Counter stability**: five repeated home-scratch runs of `plans/round-39-c1.sh` print 3 (idempotent); C2 counter reproduced at the same 3 across fixture-complete reruns including missing-manifest-row state.

## C1 gate — surviving defects
The declared target (3/3) is achieved; the anchor-pin gate itself has several false-clean paths an adversary can drive silently:

- **F1 duplicate registry row** (seat assignment): inserting a duplicate `| S034 |` row with a corrupt anchor after the real one leaves the gate CLEAN (pins=3) rc 0 — awk exits at first match, so subsequent rows are unread. A duplicate *first* row (corrupt) reads `DRIFT S034 row-missing` rc 1 — detected, but for the wrong reason. /receipt: c1-attacks.txt item 1, 1b
- **F2 tab-indented registry row**: leading tab before the whole row leaves gate CLEAN rc 0 — the gate reads cwd-relative-from-pipe `|`. /receipt: c1-attacks.txt item 2b
- **F3 extra trailing pipe cells** after the anchor column, still with the right anchor at column 7: CLEAN rc 0 — schema drift to the right is tolerated. /receipt: c1-attacks.txt item 4
- **F4 missing pin row** (pin file attenuated to 2 rows): CLEAN (pins=2) rc 0 — the gate enforces nothing about the pin set size; the count mode reports whatever pin count is present and still exits clean. This is a frozen predicate failure at the "pins=N" level (pin rows are not bound to a frozen set of 3). /receipt: c1-attacks.txt item 9
- **F5 missing-pin masking drift**: with the S034 pin removed AND its anchor cell drifted to v2.2.1, the gate still reads CLEAN (pins=2) rc 0 — one removed pin erases the corresponding drift check silently. /receipt: c1-attacks.txt item 10
- **F6 pin file without trailing newline**: the last pin (S039) is silently dropped by bash `read`; gate reads CLEAN (pins=2) rc 0. `/usr/bin/env bash` `read` semantics: a last line without newline that ends with EOF status still returns non-zero. /receipt: c1-attacks.txt item 13
- **F7 pin+row co-rewrite**: for all three rows, anchor rewrites M1–M3 plus updated pins reads CLEAN (pins=3) rc 0 at gate and counter level — the gate **cannot** detect that the whole pin file was rewritten together with the rows; the ceiling named QM40 in the plan is exactly this fact, and there is no second instrument on it. /receipt: c1-attacks.txt item 6, 12

## What the gate actually catches, as designed
Anchor-cell drift, extra columns ahead of the anchor, columns collapsed, in-cell mid-whitespace, padded cells, corrupted/truncated pins, CRLF pin lines, extra pin rows for nonexistent ids: all read DRIFT rc 1 as claimed. /receipt: c1-attacks.txt items 3-5, 7-8, 14-18.

## C2 spot observations
- **Tag-count assertion inside a single row does not change verdict** (attacked with a repeated inline tag), the row-level `index($0,tag)` remains idempotent: CLEAN rc 0 — cosmetic, acceptable, recorded.
- When a second separate row tagged [C1] is added, the gate reports `MISMATCH … tagged-rows-7` (a miscount, artifact of the awk `first/sub` extraction): DETECTED rc 1, but its reported reason is surprising and hard to audit, not part of the declared predicate rationale. /receipt: c2-spot.txt item B
- The plan heading test is `grep -qF` over the whole `plans/round-<round>.md` file without uniqueness or position constraint: a section header repeated in a comment block appended at the end also passes (CLEAN rc 0). /receipt: c2-spot.txt item K
- Counter prints the frozen integer 3 even when `corpus/claims-declared.tsv` is missing one of its two rows in the root tree (the fixture stays CLEAN inside): the frozen counter does not re-derive the root manifest row count. /receipt: c2-spot.txt trailing entry
- Round 38's section is not gated (clean read 0, expected — history rows are outside the manifest by design). /receipt: c2-spot.txt item L
- Duplicate plan-heading scenario under **two columns of the same heading name** for separate sections was not used alone, because the silent behavior is a correctness requirement a duplicate cannot misrepresent.

## Frozen predicate and claimed freshness gain — assessment of the C1 triage
- The gate as shipped does bind the three anchor cells to the committed sha256 pins, and a genuine rewrite of any anchor cell to `v2.2.1/v2.7.2/3.15.2`-class mutants is caught (counter's three mutants reproduce 3). The `0 → 3` claim as stated is supported.
- **However, the plan's sentence fragment "any other value, or no such row, prints `DRIFT <id>`"** is upheld more broadly than the pinned set alone — a fresh DRIFT output shape also fires for pin-row loss (F4/F5), where nothing is DRIFT at all; the run exits 0 there, so the *counter* silently shows **0** with no error indicator and cannot distinguish "no instrument" from "instrument present but pin-set attenuated". This blurs the do-nothing reading: a freshly removed S034 pin returns the same 0 as a lane whose `anchor-pins.sh` was never written. Two different states print the same integer with no breadcrumb. Because the counter's frozen predicate language treats `0` as the single "do-nothing reading," the gate's extra SETUP/attenuated-pins reading class collapses into this 0 and the counter's value, in this state, is **not** a decision-capable number; the pre-freeze protocol cannot detect this by any of its four frozen controls (all four read identical in that state).
- **QM40 co-rewrite ceiling is real and load-bearing**: the counter's drift detection exists only as long as the anchor rewrites and the pin file stay out of step. A producer can rewrite the registry rows and the pin file together and the frozen control set is blind to it (F7). This is declared in the plan's ceiling clause; the six undeclared attack paths here (F1-F6) are **not** declared anywhere and report no witness histories the pre-freeze set exercises.

## Residual risk and verification gaps
- The C1 counter's positive control (`c1_positive_three`) reads its target only when the root tree is CLEAN; **none of the seven C1 attacks are covered by the frozen control battery** (F1 duplicate rows, F2 tab-indent, F3 trailing cells, F4/F5 attenuated pins, F6 newline-less EOF, F7 co-rewrite). These build silent 0s when they should produce nonzero-failure states distinguishable at a glance. This is a control-set gap I verified empirically, not a claim of fixing it.
- Prefreeze-control harness, extracted into a fresh scratch tree and committed, throws `bad-rev` if it cannot peel the base rev and my lane scratch-tree must run the canonical script at its own path for the controls to pass. A committed copy of the harness measuring its own lane is a documented design; leading to a `$TMPDIR=undefined nuance': the scratch run at `/tmp/hyaltp/tree` with `PREFREEZE_REPO=/tmp/hyaltp/altrepo` ran its own committed-tree controls against altrepo and PASSED; the same command run from a copy of the tree *placed inside a git archive minus .git /* returned `bad-rev`, since `REPO=$LANE_DEFAULT` derives from the script's directory which at that path is not a git repository. That tripped `-C DEST fatal: not a git repository` while RESOLVING the lane, not a mutation mishap. Ran reproducibly; recorded in scratch transcript below.
- The counter is stable, idempotent, and reproducible.

## git rev-parse --verify audit (the one live lane-adjacent surface this seat touched)
`corpus/prefreeze-control.sh:272` uses `rev-parse --verify --quiet "$BASE_REV^{commit}"` — the SAFE peel form. I audited the lane for other `verify` uses: no non-peeled `--verify <40hex>` anywhere (grepped the lane and every committed copy). I verified empirically that git's non-peeled `rev-parse --verify --quiet <40hex>` accepts unknown/invalid SHA-like input with exit 0 (multiple witnesses recorded in the scratch transcript), so any future changed call-chain that loses the `^{commit}` peeling would become a silent pass-through. The current code base is correct.

## git verify probe witnesses
- `bash corpus/prefreeze-control.sh` from a x copy of the candidate into a fresh commit (`scratch-extracted candidate tree`) returned `SETUP noresult` at 08:xx (probe: BASE object not in the scratch git dir). Re-run outside the tree location (`/tmp/hyaltp/tree`) PASSED. The one-pass `bad-rev`/`noresult` artifacts sampled above are a RESOLUTION issue in the run directory environment, not a candidate defect; the candidate tree does not ship its own `prefreeze-control.sh`.

— Not an admission verdict. Evidence only: the C1 and C2 frozen predicates are real, the two counters reproduce their declared targets 3/3 from BASE 0/0 in this lane, the predeclaration is CLEAN 4/4, QM40 load-bearing ceiling holds, and the eleven 0-exit / false-clean paths (F1, F2, F3, F4, F5, F6, F7, plus C2's B/K/trailing entries) are the surviving defects to record.

## Tool installs
None. No tools installed or updated this session. No pacman/service/kernel changes.
