# Round 44 — frozen plan (kagi, attempt 1)

Claim BASE: `d54109d943abc900e71613a02e5a7a2e46453c3a` (lane `master` at round start; the round-43
verifier spot-check verified the round-43 claims at this tip). Predeclaration (this plan, the three
counters `plans/round-44-c1.sh` / `-c2.sh` / `-c3.sh`, the controls runner
`plans/round-44-controls.sh`, the pre-freeze controls `plans/round-44.controls.tsv`, the BASE
receipts and fixtures under `.ufo/waves/round-44/controls/`, and the claims-declared repair below)
is committed alone before any candidate work. Frozen predicates, counter names, targets, kill
rules and controls below are not amended after data. A correction is appended only before the first
candidate measurement and is named in the lesson.

Axes: C1 → **calibration**; C2 → **operability**; C3 → **freshness**. All six axes stood at 9 at the
round-43 close (a tied lowest), so every claim works a tied-lowest non-retired axis; as in rounds
36–43 the claims are measured against the BASE readings below and no axis score is re-scored (the
rows record what moved).

Shape: ONE v1 wave of 11 seats (executor 2, scout 1, connector 1, reviewer 2, critic 1,
mutation-tester 1, sentinel 1, labrat 1, revenger 1); attack seats = reviewer 2 + critic 1 +
mutation-tester 1 + labrat 1 = 5/11 (45 %, floor 25 %); connector 1 (≤ 2). The planner seat is the
L1 (the validator rejects the role); the L1 holds the §3 planner duty and records it in the report.

Frontier step (§2b): census before `scripts/sources-census.sh validate --root
/home/vgpnk/Projects/shokunin kagi` → `kagi ok`, exit 0, 98 rows (19 W04 duplicate-url warnings,
warnings allowed); receipt `.ufo/waves/round-44/controls/census-start.txt`. Sourced claim: **C3**
rests on registry row **S099** (opened this round: the fleet repo's
`.ufo/prompts/kagi-round-44.md` at fleet commit `75dd2612`, §9 Claim sizing — "The claim is judged
on the counter, kill rule and predicate declared before data."; the lesson's Gate carries the
location, access date, sha256 and ≤25-word located quote; the landed corrections register cites the
row in its Basis line and the row's `used-by` cell moves old `—` → the register and the lesson).
Mistakes mined pre-freeze: M44-1 (below). Assimilation: **none** — the staged `merge/kagi/` themes
that remain unadopted (GB/T 17901 series, Sakura Cloud custody, ja/zh scanning vocabularies,
SP 800-131A tables) match none of the three instrument claims; the lane says so in the report's
Sources & frontier section. Considerthese: proposals 1 and 3 of `considerthese/2026-10-26.md`
remain unimplemented (proposal 1 is operator policy under HOLD; proposal 3 needs its own predicate);
not taken, reason carried to the lesson.

Named BASE repairs claimed this round (registry data, not instruments): `corpus/claims-declared.tsv`
gains the five rows rounds 41 and 43 omitted (41 C1 calibration, 41 C2 freshness, 43 C1 calibration,
43 C2 freshness, 43 C3 operability) — `bash corpus/claims-declared.sh` reads `CLEAN (claims=7)` at
the BASE because the gate checks only rows the manifest already holds (the QM41 ceiling: it cannot
see an omission); after the repair it must read `CLEAN (claims=12)`, and the three round-44 rows
join at landing once the SCORECARD post-move section exists. LOG.md records the repair.

## C1 — calibration: the counter-mutation battery discriminates the two surviving C2-counter mutants

**Improves:** round-43 routed item 2 (M43-7, `K43MutCounters` y1/y2): the round-43 C2 counter
(`plans/round-43-c2.sh`) survives two counter mutations — y1 (the N1 stale-refusal leg dropped) and
y2 (the N2 silent-refusal leg dropped) — each still reading the target 1 on the frozen battery; the
mutation seat proved only an accept-stale / accept-silent negative fixture gate kills them, and the
frozen battery holds neither. The lane holds no committed instrument that discriminates them today.

**Candidate rule (executor's work):** none on the lane tree — the instrument itself is the claim:
`plans/round-44-c1.sh` is committed at the predeclaration and carries the whole battery (frozen
mutant recipes applied to byte-copies of the candidate's round-43 counter; embedded negative
fixture gates accept-stale and accept-silent plus the always-refuse blanket; positive control P0).
The measured revision is the landed tip. The round-43 gate and counter bytes do not move:
`git diff --quiet 65f66e17a313efd839db2a77e7156a313a1e363d HEAD -- corpus/controls-replay.sh
plans/round-43-c2.sh` must stay rc 0 (verified rc 0 at the claim BASE; pre-freeze).

**Frozen predicate** (the same sentence appears in `plans/round-44-c1.sh`'s header): the counter
prints ONE unsigned integer N in 0..2 = the number of the two counter mutants y1 and y2 the battery
discriminates from the real round-43 C2 counter (the candidate's own `plans/round-43-c2.sh` bytes),
counted only if the positive control P0 holds (the real counter reads 1 with the candidate's own
`corpus/controls-replay.sh` gate); mutant m is discriminated iff, with its paired negative fixture
gate (y1: accept-stale; y2: accept-silent), the real counter reads 0, the mutant reads 1, and with
the always-refuse blanket the mutant reads 0; the candidate must carry the battery's own bytes at
`plans/round-44-c1.sh` (byte-identical to the invoked file); a candidate without the battery file
reads 0. **Target: N = 2 at the candidate.**

**Matrix** (frozen expected values; BASE receipts under `.ufo/waves/round-44/controls/`,
measured at the claim BASE; the full matrix was smoke-proved on a scratch clone of the lane at the
BASE carrying the instruments — receipt `smoke-matrix.txt`, fixture revisions in `smoke-revs.txt`):

| receipt | command (shape) | value |
|---|---|---|
| `c1-base` | `bash plans/round-44-c1.sh d54109d` (battery absent at BASE) | **0** |
| `c1-skipfix` (BASE) | `R44_SKIP_FIXTURES=1 bash plans/round-44-c1.sh d54109d` | **0** |
| `c1-real` (candidate) | `bash plans/round-44-c1.sh <cand>` | **2** |
| `c1-skipfix` (candidate) | `R44_SKIP_FIXTURES=1 ...` — the M43-7 state | **0** |
| `c1-partial` (candidate) | `R44_ONLY_FIXTURE=stale ...` | **1** |

Smoke matrix at the fixture (R2 `edecb282`): real 2, skip-fixtures 0, only-stale 1 — all three
readings reproduced before the wave.

**No-work control:** at the claim BASE the battery file does not exist (`battery_absent` prefreeze
row = 0), so no do-nothing tree reaches N = 2; `c1-skipfix` = 0 proves the negative fixture gates
are load-bearing (without them the battery cannot discriminate — the routed M43-7 state);
`c1-partial` = 1 proves each fixture gate carries exactly one mutant.

**Kill rule:** C1 is not admitted if (a) N ≠ 2 at the candidate; (b) `c1-skipfix` ≠ 0 or
`c1-partial` ≠ 1 re-measured at the candidate; (c) any BASE receipt `c1-base`, `c1-skipfix`
re-measured ≠ 0; (d) the instrument pin `git diff --quiet <predeclaration> HEAD --
plans/round-44-c1.sh plans/round-44-c2.sh plans/round-44-c3.sh plans/round-44-controls.sh
plans/round-44.controls.tsv` is not rc 0; (e) the gate pin of the candidate rule is not rc 0 at
landing; (f) the battery exits 2 at the candidate (a mutant recipe that fails to apply — fail
closed, not a pass).

**Declared ceilings (named, not closed):** the battery proves discrimination of the two frozen
recipes only; a counter mutant outside the recipe vocabulary (e.g. an echo-constant counter at 2)
is caught only by the no-work control at BASE (a constant-2 counter cannot read 0 at BASE) and is
otherwise outside the battery; the fixture gates inspect only the two shapes they were built for
(a third gate shape would need its own fixture); P0 remains basename-independent (the candidate's
own gate bytes run).

## C2 — operability: the replay gate runs, and a committed receipt binds that run

**Improves:** round-43 routed item 3: `corpus/controls-replay.sh` (landed round 43) is run by
nothing — no schedule, no runner, no receipt of its own execution exists at the tip. The lane-reach
able half of "add a schedule or a receipt of the gate's own run" is the receipt: a committed record
of the gate's run plus a counter that re-executes the gate, so the freshness gate is actually
exercised on demand and its verdict is durable evidence. (Scheduling itself stays refused: it
touches host state — the named operability ceiling of rounds 14–43.)

**Candidate rule (executor's work):** the receipt `.ufo/waves/round-44/final/replay-at-tip.txt` is
produced by a direct run of the gate in a fresh shared clone of the content revision (the landing's
parent commit K): `git clone --shared` K, `bash <clone>/corpus/controls-replay.sh --clone <clone>`,
rc 0, last line `controls-replay: CLEAN`; the receipt records exactly four lines: `controls-replay:
CLEAN`, `revision: <K>`, `gate-sha256: <sha of K's gate bytes>`, `exit: 0`. The clone's controls
directories byte-match their committed state after the run (`git status --porcelain` on both dirs
empty — the restore duty, r43 A2-6a lineage). The landing commit L adds the receipt; the measured
candidate is L.

**Frozen predicate** (the same sentence appears in `plans/round-44-c2.sh`'s header): the counter
prints N ∈ {0,1}; N = 1 iff (a) a receipt is provided (committed at the candidate at
`.ufo/waves/round-44/final/replay-at-tip.txt`; fixture override `R44_RECEIPT=<path>`); (b) it
parses as exactly four lines `controls-replay: CLEAN` / `revision: <R>` / `gate-sha256: <S>` /
`exit: 0` where R is a full 40-hex revision that exists, is an ancestor of the candidate, whose
gate bytes hash to S, and S equals the candidate's own gate hash; (c) executed: in a fresh shared
clone of the candidate the gate exits 0 with last line `controls-replay: CLEAN`. Otherwise N = 0;
a missing receipt reads 0. **Target: N = 1 at the candidate.**

**Matrix:**

| receipt | command (shape) | value |
|---|---|---|
| `c2-base` | `bash plans/round-44-c2.sh d54109d` (no receipt at BASE) | **0** |
| `c2-forged-sha` | `R44_RECEIPT=fixtures/receipt-wrong-sha.txt ...` | **0** |
| `c2-forged-rev` | `R44_RECEIPT=fixtures/receipt-wrong-rev.txt ...` | **0** |
| `c2-real` (candidate) | `bash plans/round-44-c2.sh <cand>` | **1** |

**No-work control:** at the claim BASE no receipt exists (`receipt_absent` prefreeze row = 0), so
the do-nothing reading is 0; both forged fixtures read 0 (wrong hash, unknown revision).

**Kill rule:** C2 is not admitted if (a) N ≠ 1 at the candidate; (b) either forged fixture ≠ 0
re-measured at the candidate; (c) the receipt-production run's clone shows a dirty controls
directory after the run (restore duty); (d) the instrument pin (C1 (d)) is not rc 0; (e) the gate
pin (C1 (e)) is not rc 0 at landing.

**Declared ceilings:** a fabricated receipt naming a real green revision passes the counter — the
receipt's provenance is reviewed as code, and the counter's own re-execution (leg c) is the
load-bearing fact; a gate edited after the receipt's revision invalidates the hash binding and the
counter reads 0 (that is the intended freshness behaviour, not a defect); the counter does not
schedule anything.

## C3 — freshness: the three drifted round-42-era control receipts are named and superseded by a committed, re-executable register

**Improves:** round-43 verifier spot-check item 3: `round-42/controls/c1-base.txt` (committed 4,
re-derives 5), `round-42/controls/c2-base.txt` (committed 0, re-derives 1) and
`round-42/controls/c2-worktree-at-base.txt` (written by no committed runner) are disclosed in
`.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` but no committed record supersedes
their reading; the round-43 C2 gate excludes them from its manifest by design, so the drift is
named in receipts only. Corrections are new records, never rewrites (fleet `CORPUS.md`; registry
rule 2 per S094): the filed bytes stay untouched.

**Candidate rule (executor's work):** the register
`.ufo/waves/round-44/controls/receipt-corrections.md` lands with exactly the three frozen rows
(content = the committed fixture `fixtures/register-full/receipt-corrections.md`, whose row cells
are the measured values below), its Basis line cites S099 (the sourced-claim duty), and
`plans/round-44-c3.sh` re-executes every leg at the candidate.

**Frozen predicate** (the same sentence appears in `plans/round-44-c3.sh`'s header): the counter
prints ONE unsigned integer N in 0..3 = the number of the three drifted receipts whose correction
row satisfies every leg: rows 1–2 (c1-base.txt, c2-base.txt) — cells in the frozen shape, the
`committed` cell equal to the receipt's last line at the pinned revision, the EXECUTED
re-derivation (fresh shared clone at `5f3566c4cfe65a74da4d201d74d28b403929807b`, delete both
receipts, re-run `plans/round-42-controls.sh` rc 0, produced last lines equal the `re-derived`
cells, restore byte-identical), and the disposition cell exactly `superseded-by: <path>` with that
path existing at the candidate; row 3 (c2-worktree-at-base.txt) — cells, committed value 3, the
EXECUTED sweep (`git grep c2-worktree-at-base <rev> -- 'plans/*.sh' 'corpus/*.sh'` prints nothing
at the pinned revision), and the disposition token
`not-written-by-any-committed-runner`. The register holds exactly three rows in the frozen order
(anything else fails closed). `re-derive-at` is the pinned revision
`5f3566c4cfe65a74da4d201d74d28b403929807b` in every row. A candidate without the register reads 0.
**Target: N = 3 at the candidate.**

**Matrix (values measured this round; the re-derivations re-executed by the counter at the BASE):**

| row | committed (measured at `5f3566c`) | re-derived (executed) | disposition |
|---|---|---|---|
| c1-base.txt | 4 | 5 | superseded-by `.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` |
| c2-base.txt | 0 | 1 | superseded-by `.ufo/waves/round-41/controls/c2-base-19025d9.txt` |
| c2-worktree-at-base.txt | 3 | — | not-written-by-any-committed-runner (sweep empty) |

| receipt | command (shape) | value |
|---|---|---|
| `c3-base` | `bash plans/round-44-c3.sh d54109d` (no register at BASE) | **0** |
| `c3-pos` | `R44_REGISTER_ROOT=fixtures/register-full ...` | **3** |
| `c3-wrongvals` | `R44_REGISTER_ROOT=fixtures/register-wrongvals ...` | **1** |
| `c3-real` (candidate) | `bash plans/round-44-c3.sh <cand>` | **3** |

**No-work control:** at the claim BASE the register does not exist (`register_absent` prefreeze row
= 0); `c3-pos` = 3 proves the full register is verifiable with the executed legs at the BASE tree;
`c3-wrongvals` = 1 proves the executed re-derivation leg is load-bearing (wrong re-derived values
drop rows 1–2, only the sweep row counts).

**Kill rule:** C3 is not admitted if (a) N ≠ 3 at the candidate; (b) `c3-pos` ≠ 3 or
`c3-wrongvals` ≠ 1 re-measured at the candidate; (c) any BASE receipt `c3-base` re-measured ≠ 0;
(d) the instrument pin (C1 (d)) is not rc 0; (e) the re-derivation's restore duty fails at the
candidate (the counter exits 2 — fail closed).

**Declared ceilings:** the counter re-executes the re-derivation at the pinned revision only; the
register's `committed` values are pinned to `5f3566c` bytes, not to the round-42 claim BASEs the
receipts were first measured at (the revenger seat reconstructs that history for the lesson; the
drift explanation is historical, not part of the frozen predicate); a forged register pairing
matching values with a wrong `via` runner is outside the counter (the runner path is checked by
execution: the legs run the named `via` file, so a nonexistent runner fails the leg — a wrong
runner that still produces the values passes; reviewed as code, named).

## Controls and receipts

All committed with this plan under `.ufo/waves/round-44/controls/` (measured at
`d54109d943abc900e71613a02e5a7a2e46453c3a`, recorded in `measured-at.txt`): `c1-base` (0),
`c1-skipfix` (0), `c2-base` (0), `c2-forged-sha` (0), `c2-forged-rev` (0), `c3-base` (0), `c3-pos`
(3), `c3-wrongvals` (1), `prefreeze-base.txt` (`PREFREEZE: CLEAN (controls=13 mismatch=0)` exit 0),
`census-start.txt` (`kagi ok`, exit 0), `smoke-matrix.txt`, `smoke-revs.txt`, and the four fixtures
under `fixtures/`. Commands: `bash plans/round-44-controls.sh base d54109d...`;
`bash corpus/prefreeze-control.sh run --base d54109d... --controls plans/round-44.controls.tsv`;
counters `bash plans/round-44-c1.sh`, `bash plans/round-44-c2.sh`, `bash plans/round-44-c3.sh`
(argument = the measured revision). Final receipts are measured in a clone of the landing tip by
`bash plans/round-44-controls.sh final <tip>` and copied into the lane's
`.ufo/waves/round-44/final/` (the r43 A2-3 pattern).

## Pre-freeze mistakes mined this round (lesson carries the table)

- **M44-1** — the C3 register's row-2 `superseded-by` path was written from memory as
  `.ufo/waves/round-42/controls/c2-base-19025d9.txt`; the corrected round-42 receipt lives under
  `.ufo/waves/round-41/controls/` (it is a member of the round-43 eight-receipt manifest), and the
  c3-pos control read 2 instead of 3 until the path was fixed. Captured-by: the counter's own
  disposition-existence leg (c3-pos 3 expected, 2 measured — the fixture control did its job before
  any candidate existed). Fix: path verified with `git cat-file -e` before freeze; the predeclaration
  carries the corrected register.

## Routed (named, not claimed this round)

1. The owed appended erratum to the round-40 report (round-41 routed item 3, carried through 43) —
   still carried: the L1 write scope covers `.ufo/reports/round-44/kagi.md` only.
2. The 6-key answer-key ceiling of the round-43 C1 instrument (routed item 7) — a shape-level
   control is a predicate amendment; no slot.
3. C3 counter defects M40-9 / M40-10 / M40-17 (round-40 instruments; rewriting them is a re-freeze).
4. `expect-journal.sh` `*.json` discovery failing closed on a wave directory (r43 routed 1).
5. Open L0 lines 284 (r32 SD6), 327 (r38 R38-03 policy), 349 (r39 wave), 359 (r40 admission), 368
   (r42 DELETED retirement form) — routed around, never assumed answered.

## Wave contract

One v1 wave of the 11 seats above, dispatched after this predeclaration lands. Every seat works in
its own scratch sandbox at the predeclaration commit, never edits the lane tree, delivers files +
receipts under `.ufo/waves/round-44/build/<seat>/`, and yields an explicit per-seat liveness status
(QM47). The L1 integrates, applies any pre-measurement amendments (A1, A2, ... — before any
candidate measurement), measures the final receipts, and lands the round.

## Amendment A1 (predeclaration, before any candidate measurement; closes the wave's pre-measurement attacks)

The wave (11 seats, `.ufo/waves/round-44/build/`, WAVE-DONE received) attacked the predeclaration. Each
defect below is closed by the text or code named here. No predicate, target, counter name, BASE reading or
kill-rule threshold moves; each code change preserves every declared value (re-measured in §A1-evidence).
The instrument pin of kill clauses C1(d) and C3(d) is **re-anchored from `ae9e9eb` to the A1 commit** (the
commit that carries this section): the round-43 A2 pattern, declared before any candidate measurement.

- **A1-1 (reviewer C1 F1, LOW operational, code):** `plans/round-44-c1.sh` and `plans/round-44-controls.sh`
  clear `CONTROLS_REPLAY_GATE` from the ambient environment at entry. An exported override previously reached
  the P0 leg and could read 0 on a valid candidate (degrading toward 0 only; never a false green).
- **A1-2 (sentinel F1, MEDIUM, code):** `plans/round-44-controls.sh` refuses a REV that is not a full
  commit id of the repository (`^[0-9a-f]{40}$` and `cat-file -e <rev>^{commit}`) with rc 2 **before** any
  receipt is written. Previously `base --help` overwrote the eight committed receipts and exited 0.
- **A1-3 (reviewer C2C3 F1 and critic D2, MEDIUM, code):** `plans/round-44-c3.sh` reads the `via` cell:
  rows 1–2 must name exactly `plans/round-42-controls.sh`, row 3 must name `none`. The §C3 ceiling sentence
  "the legs run the named `via` file" was false before A1 and is now true for the cell check; the executed
  runner remains the hardcoded `plans/round-42-controls.sh` (named ceiling: a wrong runner that still
  produces the values passes; reviewed as code).
- **A1-4 (reviewer C2C3 F2 and F4, LOW, code):** the C3 counter requires each row to carry exactly six cells
  (8 awk fields), the `receipt` cell to equal the frozen path exactly (no substring match), and the
  `superseded-by` target to be a **blob** (`git cat-file -t` = `blob`), so a tree (`…/controls`) or a
  pipe-truncated disposition cannot satisfy the leg.
- **A1-5 (critic D1, LOW, code):** the C3 counter's register-wide leg (w2): exactly three register lines
  begin `| .ufo/waves/round-42/controls/`; any other row count fails closed with rc 2.
- **A1-6 (critic D7, sourced-claim duty, code):** the C3 counter's register-wide leg (w1): the register
  carries a `Basis: … S099 …` line; without it every row is uncounted (reads 0). The landed register carries
  the line.
- **A1-7 (reviewer C2C3 F3, LOW, code):** `plans/round-44-c2.sh` refuses a receipt with any fifth line,
  including an unterminated one (`sed -n '5,$p'` must be empty), in addition to the four-line count.
- **A1-8 (critic D5, code):** `plans/round-44-c2.sh` fails closed (rc 2) when the candidate's gate blob is
  absent (`cat-file -e CAND:corpus/controls-replay.sh`), instead of hashing an empty stream.
- **A1-9 (critic D3, comment-only code):** the C1/C2 counter headers no longer claim the predicate sentence
  appears "in the receipt labels" (no receipt carries it).
- **A1-10 (critic D8, code, value-preserving):** the C3 row-3 sweep pathspec widens from `plans/*.sh
  corpus/*.sh` to `'*.sh'` (the seat measured 0 `.sh` files at the claim BASE carrying the token).
- **A1-11 (plan text, no code, the ceilings the wave corrected):**
  - *D4 (C1 ceiling):* a constant counter is caught by the battery itself (echo-1 reads 0 through the R-leg;
    echo-2 is refused by the recipe guard, rc 2). The BASE no-work control establishes the battery-absent
    zero only. A name- or gate-keyed counter forgery survives the battery and is caught only by the gate pin.
  - *D6 (C1 no-work):* at the claim BASE no tree reaches N = 2 because the battery file is absent. Every
    candidate carries the battery, so the candidate reading re-executes the pre-committed discrimination; its
    load-bearing content is P0 and the pins.
  - *D9 (C2 ceiling, measured):* the receipt's revision window is `65f66e17…` → the A1 commit (gate bytes
    identical, sha `fab42e1d…740f`). Any ancestor in the window passes leg (b) by design; the counter cannot
    check that R equals the landing parent.
  - *D10 (evidence):* `smoke-matrix.txt` names fixture revisions (`17826e5…`, `edecb28…`) whose scratch clones
    were deleted; its readings are receipt-only evidence, corroborated by the BASE receipts and this section's
    red-witness receipt `controls/amend-a1-redwitness.txt`.
  - *B1 (mutation-tester; routed, not claimed):* dropping the battery's always-refuse conjunct
    `[ "$Y1_AL" = "0" ]` changes no frozen receipt; the gate-ignoring y1 counter (`OVER=`) is credited only
    without that conjunct. A receipt that exercises the blanket conjunct needs a gate-ignoring counter fixture
    and a runner slot; routed to round 45.
  - *D7 (ceiling, now code):* see A1-6; the Basis line is checked as text, not as the S099 row's truth.

**A1-evidence (measured after the A1 code, before any candidate):** prefreeze `PREFREEZE: CLEAN (controls=13
mismatch=0)`; BASE runner `base d54109d…` reads c1-base 0, c1-skipfix 0, c2-base 0, c2-forged-sha 0,
c2-forged-rev 0, c3-base 0, c3-pos 3, c3-wrongvals 1 (all unchanged); `base --help` refused rc 2 with the
committed receipts byte-untouched; red-witness probes `.ufo/waves/round-44/controls/amend-a1-redwitness.txt`:
extra row → rc 2 (structural), bogus via → 2, tree disposition → 2, no Basis → 0, unterminated fifth line → 0,
gate-absent candidate → rc 2, clean valid receipt → 1 (positive control), runner `--help` → rc 2.

**Instrument pin, re-anchored:** kill clauses C1(d) and C3(d) now read
`git diff --quiet <A1-commit> HEAD -- plans/round-44-c1.sh plans/round-44-c2.sh plans/round-44-c3.sh plans/round-44-controls.sh plans/round-44.controls.tsv` (rc 0). The lane's predeclaration commit `ae9e9eb` remains the predeclaration record.

**Round-44 verdict basis:** the frozen targets (C1 2, C2 1, C3 3) and kill rules are unchanged; A1 changes
only the instrument checks that were false or fail-open, verified above.
