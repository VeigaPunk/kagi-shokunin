# K39ConnOverlap — sibling overlap scan: anchor-cell pins and frozen claim-axis vs SCORECARD

Seat: connector, round 39 build wave kagi-r39. Read-only; no sibling material absorbed or changed.
Lane HEAD = candidate `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee` (verified `rev-parse`); tracked worktree clean
(0 dirty tracked files; only untracked wave-dispatch files), so worktree bytes == candidate bytes.
BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7` is an ancestor of candidate; predeclaration
`1909e3876341cc90246516886def37a7c9ea92f9` is an ancestor of candidate; frozen plan `7c11e769cd7c2450cf46faabcd3b43fca993f388`.

## 1. Frozen C1/C2 reproduction (freshness + calibration)

One extraction only: `git archive 6742fdef` into scratch `/fast/scratch/hyaku/kagi-r39/K39ConnOverlap/`.

| Check (command, form) | Expected | Measured | Receipt (`build/K39ConnOverlap/`) |
|---|---|---|---|
| `bash plans/round-39-c1.sh` at lane root (target 3) | `3` | `3`, rc=0 | `c1-counter-lane.out` |
| `bash plans/round-39-c2.sh` at lane root (target 3) | `3` | `3`, rc=0 | `c2-counter-lane.out` |
| same two counters from the pristine extraction | 3 / 3 | `3` / `3`, rc=0 | `c1-counter-extract.out`, `c2-counter-extract.out` |
| `bash corpus/anchor-pins.sh` (C1 kill rule) | `ANCHOR_PINS: CLEAN (pins=3)` | exact, rc=0 | `gate-c1-lane.out`, `gate-c1-extract.out` |
| `bash corpus/claims-declared.sh --root .` (C2 kill rule) | `CLAIMS_DECLARED: CLEAN (claims=2)` | exact, rc=0 | `gate-c2-lane.out`, `gate-c2-extract.out` |
| `bash corpus/sources-census.sh` (C1 kill rule) | CLEAN, rows 93→94, `entries_sourced` unchanged | `CLEAN (rows=94 A=90 B=2 C=2 queued=1 mined=90 rejected=3 entries_sourced=14 legacy=21 captures=94 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | `census-lane.out` |
| BASE0 (no instrument at BASE) | counters read 0 | instruments absent at BASE (`cat-file -e` fatal for both); counter's absent-instrument branch prints 0; `c1_nowork`/`c2_nowork` controls recorded CLEAN 4/4 at prefreeze | `freeze-stability.txt` |

**Frozen bytes stable** (empty diffs): the 8 instrument/control files are byte-identical predeclaration→candidate,
and `plans/round-39.md` is byte-identical frozen-plan→candidate (`freeze-stability.txt`). No kill rule trips:
pins unchanged, anchor cells S034 `v2.2.0` / S035 `v2.7.1` / S039 `Python 3.15.1` unmutated, plan headings
`## C1 — freshness:` (line 40) and `## C2 — calibration:` (line 77) present.

Verdict posture: **reproduced, not falsified**. No admission verdict is issued from this seat.

## 2. Overlap map — owners × paths

| Surface | Owning sibling(s) | Paths | Cross-surface intersection |
|---|---|---|---|
| C1 anchor-pin gate | `K39ExecAnchor` (executor) | `corpus/anchor-pins.sh`, `corpus/anchor-pins.tsv`, `plans/round-39-c1.sh` | gate READS `corpus/SOURCES.md` |
| C2 declared-axis gate | `K39ExecDeclared` (executor) | `corpus/claims-declared.sh`, `corpus/claims-declared.tsv`, `plans/round-39-c2.sh` | gate READS `plans/round-39.md` + `SCORECARD.md` |
| Registry append S094 | `K39ExecSources` (executor) | `corpus/SOURCES.md` (+1 line), `corpus/source-fetches.tsv` (+1), `.ufo/waves/round-39/capture/S094.body` | WRITES the C1 gate's read surface |
| Lessons/log | `K39ScribeTrial` (scribe) | `corpus/lessons/round-39.md`, `LOG.md` (+8, round-39 entry) | none vs gates |
| Review/mutation | `K39ReviewAnchor`, `K39ReviewDeclared`, `K39CriticClaims`, `K39MutInstruments` | review reports; mutant copies in scratch | no lane-tree overlap |

Relevant differences found:

- **The single real write/read intersection is benign and verified.** `K39ExecSources` appends one row (S094,
  own-work) to `corpus/SOURCES.md`; the C1 gate is row-id-scoped (awk exact id match on field 2, anchor on field 7),
  so an append cannot flip a pin check unless a row reuses a pinned id. S094 does not collide with S034/S035/S039;
  the SOURCES diff is exactly +1 line — **append-only rule respected; pinned anchor rows untouched**; gate CLEAN pins=3.
- **Gate input sets are disjoint**: C1 reads {`anchor-pins.tsv`, `SOURCES.md`}; C2 reads {`claims-declared.tsv`,
  `plans/round-39.md`, `SCORECARD.md`}. Neither claim verifies through the other — causal separability holds in
  bytes, not just in the plan's prose.
- **SCORECARD round-39 tagged rows are lead-owned, not seat-owned.** No seat may write `SCORECARD.md` (host guard:
  fleet-root tracked files); the `[C1]`/`[C2]` rows landed inside the candidate commit itself. Ownership boundary is
  clean; the C2 gate depends on a surface no executor seat controls, which is correct under the guard but worth
  remembering for landing-order effects: the gate reads CLEAN only after the lead's rows exist.
- Candidate's non-claim diffs are small and declared: `corpus/laneguard.sh` is exactly the R38-EG-1 usage-line doc
  fix (3 usage strings, no code change — matches "documentation fix, not a claim"); `LOG.md` +8, `corpus/QUALITY.md`
  +7, `SOURCES.md` +1, `source-fetches.tsv` +1. No bleed into either claim's file set.

## 3. Frozen claim-axis vs SCORECARD — differences

- Manifest `corpus/claims-declared.tsv` (39 C1 freshness / 39 C2 calibration) == plan headings == tagged SCORECARD
  rows: `## Round 39 — post-move` holds exactly one `[C1]` row with first cell `freshness` and exactly one `[C2]`
  row with first cell `calibration` (candidate lines 1489/1490). No difference.
- History preserved, not smoothed: `## Round 38 — post-move (claims C1 freshness, C2 operability as measured)` keeps
  the R38-D1 relabel visible, and its rows carry **no tags at all**; round 38 is not in the manifest, so the gate
  correctly ignores it (section-scoped awk). Consistent with the plan's named ceiling ("history before round 39 is
  not gated").
- Round-39 pre-move SCORECARD section records the freshness gap (R37-V4) and calibration gap (R38-D1) with the same
  wording the plan claims to close — plan/SCORECARD/manifest fully aligned.

## 4. Surviving observations (recorded; not adjudicated)

1. **Tag matching is substring-based** (`corpus/claims-declared.sh`: `insec && /^\|/ && index($0, tag) > 0`): a
   future round-39-section row mentioning the literal `[C1]` or `[C2]` anywhere in prose (e.g., an evidence cell)
   would make `tagged-rows` read 2 → MISMATCH. Reads CLEAN at candidate because no other row contains the tags.
   Same class as the routed R38-D4 frozen-counter amendments — fits that existing round-40 route; opening a new
   lane would duplicate it. [INFERENCE on future behavior; current bytes verified CLEAN]
2. **C1 counter's positive control reads the live lane root**, not a pristine copy (`clean_out` runs
   `anchor-pins.sh --root $root` where root is the lane). If any sibling dirties tracked files at measurement time,
   the clean-control could read worktree bytes instead of HEAD bytes. Today moot (worktree clean, both forms read 3);
   a landing-time measurement-hygiene note for L1, not a defect in the frozen predicate.
3. Named ceilings unchanged, re-confirmed: pins cover only S034/S035/S039 (a pin+row co-rewrite passes — QM40);
   the gate does not test anchors against live vendor feeds (anchors are historical fetches of 2026-10-21, 90d
   recheck due 2027-01-19 — no lane-side drift; vendor-side drift is out of scope by design). S094's anchor pins a
   lane-revision raw URL (own-work class), not a pinned release anchor. R25-02 FAIL and R29-01/R29-02/R38-03 POLICY
   and verifier-owned SD6 history untouched, as required.

## 5. Proposed move (one, bounded) — measurement-hygiene for the landing counter runs

Run the two landing counters from a pristine `git archive HEAD` extraction rather than the lane worktree
(`git archive HEAD | tar -x` into scratch, then `bash <scratch>/plans/round-39-c1.sh` / `...-c2.sh`; both counters
derive their root from their own location). This removes observation 2's worktree-dirt exposure from the freshness
and calibration measurements with **zero file changes** — it cannot harm either axis, the scores, or any sibling
surface. Both forms were exercised this round and agree (receipts in §1), so adoption is a pure robustness gain
for L1's landing measurement; keep the lane-rooted runs as the secondary witness. Observation 1 is recorded into
the existing R38-D4 round-40 amendment route rather than a new lane (compatible synthesis with the plan's routing).

## 6. Risks

- Archive-rooted runs measure committed bytes, not the worktree: if L1 lands the counters from a dirty tree on
  purpose, the two forms can diverge — the divergence itself is diagnostic (worktree drift), which is the point.
- None of my checks mutated lane, fleet, or sibling state; scratch is self-cleaning (`mktemp` + trap inside the
  counters) and my extraction dir is deleted after receipt preservation.

## 7. Verification & receipts

All receipts under `build/K39ConnOverlap/`: `worktree-state.txt`, `c1-counter-lane.out`, `c2-counter-lane.out`,
`gate-c1-lane.out`, `gate-c2-lane.out`, `census-lane.out`, `freeze-stability.txt`, `gate-c1-extract.out`,
`gate-c2-extract.out`, `c1-counter-extract.out`, `c2-counter-extract.out`.
Tool installs: none (no new tooling needed; RULES.md install ledger intentionally empty).
Scratch `/fast/scratch/hyaku/kagi-r39/K39ConnOverlap/` deleted after receipts were preserved; lane untouched
(read-only commands and receipt writes only). No commits, no pushes, no git/jj mutation.
