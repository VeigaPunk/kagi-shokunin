# kagi round 39 — plan (frozen claims)

Round 39, attempt 1. Lane: kagi (secrets & vault ops). Owned axes: freshness + calibration.

Claim BASE (lane HEAD before the round): `06144518d3b3745e7fdf82d4207b4a3b5532a7a7` (round-38 spot-check tip).
Predeclaration (instruments, pins, frozen counters, controls, declared-axis manifest):
`1909e3876341cc90246516886def37a7c9ea92f9`. Pre-freeze gate over it:
`PREFREEZE: CLEAN (controls=4 mismatch=0)`, rows `c1_nowork 0`, `c1_positive_three 3`, `c2_nowork 0`,
`c2_positive_three 3` (run by `corpus/prefreeze-control.sh run --base 1909e38… --controls plans/round-39.controls.tsv`).
This file is committed alone after that gate; no data is scored into it.

## Read before freezing

- Round 38 closed as `verifier-spotcheck` (`corpus/lessons/round-38-verifier-spotcheck.md`, the non-author
  integrator): C1 verified (located-quote 0 → 5), C2 **not verified as declared** because its axis was
  calibration in the plan and operability in the SCORECARD (CD-1, CD-2). Routed items R38-D1..D6 are
  dispositioned in this round's claims and lesson; R38-D3, D5 and D6 are not claimed here.
- Not a fresh-start round: round 36, 37 and 38 closed `ok`; no rejected closure in the last three.
- Measured at BASE (no instrument present): `bash corpus/self-description-sweep.sh` reads
  `SELF_DESCRIPTION: MISMATCH n=3 (SD6=3)`, all three SD6 rows inside verifier-owned spot-check files
  (`round-30`, `round-32`, `round-33`); not lane-owned, not claimed. `bash plans/round-36-c1.sh` reads 0.
- Release clocks (`python3 -I -B corpus/release-clock.py` at BASE): `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`.
  The 15 fired clocks sit on Vault (S034 family, S012/S013/S022–S024), OpenBao (S035 family,
  S014–S016/S021/S025/S026) and Python (S036/S039 family, S027/S028/S040/S041). Re-pointing them is
  R37-V2, which round 38 measured as a DERIVATION failure. Not claimed here.
- Registry anchor cells of the superseded feed rows S034, S035 and S039 are the only anchors the
  round-37 counter (`plans/round-37-c2.sh`) cannot see changing in place: that counter only asks
  whether *some* current row exists (S089–S091), so a rewritten superseded anchor reads unchanged
  (R37-V4; round-38 lesson §Routed item R37-V4).

## Why these two claims

All six axes stand at 9 (round-38 close). The lowest-axis obligation is met by a tie on the owned
freshness axis (C1). C2 is calibration, the other owned axis; it addresses the one calibration failure
the round-38 verifier measured (R38-D1). The two claims are causally separable: C1 touches only
`corpus/anchor-pins.sh`, `corpus/anchor-pins.tsv` and `plans/round-39-c1.sh`; C2 touches only
`corpus/claims-declared.sh`, `corpus/claims-declared.tsv` and `plans/round-39-c2.sh` (plus the round-39
plan and SCORECARD headings it reads). Neither verifies through the other.

## C1 — freshness: anchor-pin gate detects in-place rewrites of superseded feed anchors, 0 → 3

**Declared claim.** `bash plans/round-39-c1.sh` prints one integer: `detected=N`, the number of the three
frozen in-place anchor rewrites (M1 S034 `v2.2.0`→`v2.2.1`; M2 S035 `v2.7.1`→`v2.7.2`; M3 S039
`Python 3.15.1`→`3.15.2`) that `corpus/anchor-pins.sh` reports as `DRIFT` on a scratch copy. Target **3**;
BASE **0** (no instrument). The count is printed only when the unmutated tree is `ANCHOR_PINS: CLEAN`.

**Frozen predicate (identical sentence in `corpus/anchor-pins.sh`'s header, the counter, and the receipt label):**
`ANCHOR_PINS: CLEAN (pins=N)` — for every row of `corpus/anchor-pins.tsv`, the anchor cell (SOURCES.md
column 6, whitespace-trimmed) of the registry row with that id has the sha256 the pin records; any other
value, or no such row, prints `DRIFT <id>` and the run exits 1.

**Pins (computed from the claim BASE registry, committed in the predeclaration):**
S034 `5e10a867…d443811`, S035 `0ddd47c0…683d33a`, S039 `772e58b2…fef4230` (full digests in
`corpus/anchor-pins.tsv`).

**Controls (frozen, `plans/round-39.controls.tsv`, executed at `1909e38`, CLEAN 4/4):**
- `c1_nowork` (no anchor-pin instrument in the tree) → 0.
- `c1_positive_three` (the counter on the predeclaration tree, all three mutants) → 3.

**Kill rules (frozen).**
- The landing revision's `bash corpus/anchor-pins.sh` prints anything other than `ANCHOR_PINS: CLEAN (pins=3)` → C1 unmet.
- `bash plans/round-39-c1.sh` at the landing revision prints anything other than 3 → C1 unmet.
- Any change to `corpus/anchor-pins.tsv` or to the anchor cells of S034/S035/S039 in the landing revision
  → C1 unmet (the pins are frozen; a pin change is a new claim).
- The lane's `bash corpus/sources-census.sh` not `CLEAN` at landing → C1 unmet.

**Ceiling, named before data.** The gate binds the anchor cell to a committed sha256 pin. A pin rewritten
together with its row passes it; that is outside what the gate detects (named as a ceiling, QM40). It
does not check that an anchor is true on the live vendor feed, and it does not cover any registry row
other than the three pinned ones.

**Sourced claim.** C1 rests on the append-only rule of the registry contract, `CORPUS.md` §SOURCES.md
rule 2 (line 116: “Only `status`, `recheck` and `used-by` change in place”), opened this round by the
lane (own-work row S094, Gate block in the round lesson, access 2026-11-05). The rule is the reason an
in-place anchor rewrite is a defect the gate must catch.

## C2 — calibration: declared-axis conformance gate detects relabels, 0 → 3

**Declared claim.** `bash plans/round-39-c2.sh` prints one integer: `detected=N`, the number of three planted
declared-axis relabels (X1 the tagged SCORECARD row's axis calibration→operability; X2 the plan
heading's axis calibration→operability; X3 the tag removed from a claim row) that
`corpus/claims-declared.sh` reports as `MISMATCH` on a self-contained fixture lane in scratch. Target
**3**; BASE **0** (no instrument). The count is printed only when the unmutated fixture is `CLAIMS_DECLARED: CLEAN`.

**Frozen predicate (identical sentence in `corpus/claims-declared.sh`'s header, the counter, and the receipt label):**
`CLAIMS_DECLARED: CLEAN (claims=N)` — for every row `round<TAB>claim<TAB>axis` of
`corpus/claims-declared.tsv`: (a) `plans/round-<round>.md` carries the heading `## <claim> — <axis>:`;
(b) SCORECARD.md's `## Round <round> — post-move` section holds exactly one table row tagged `[<claim>]`,
and that row's first cell equals `<axis>`. Any other reading prints `MISMATCH <round> <claim> <reason>`
and exits 1.

**Controls (frozen, `plans/round-39.controls.tsv`, CLEAN 4/4 at `1909e38`):**
- `c2_nowork` (no declared-axis instrument in the tree) → 0.
- `c2_positive_three` (the counter on the predeclaration tree, three mutants) → 3.

**Kill rules (frozen).**
- The landing revision's `bash corpus/claims-declared.sh --root .` prints anything other than
  `CLAIMS_DECLARED: CLEAN (claims=2)` → C2 unmet (real round-39 rows: C1 freshness, C2 calibration).
- `bash plans/round-39-c2.sh` at the landing revision prints anything other than 3 → C2 unmet.
- A round-39 SCORECARD row tagged `[C1]` or `[C2]` whose axis differs from the manifest → C2 unmet.
- Changing the axis of either claim after the candidate scores is an amendment: C2 is then unmet, not re-declared.

**Ceiling, named before data.** The gate checks that the declared axis and the tagged SCORECARD row agree.
It does not judge whether the axis is the right one for the move, and it cannot detect an untagged
relabel of a row that was never tagged (history before round 39 is not gated: round 38's untagged row
is recorded in the round-39 lesson as an unrecorded mismatch, not claimed as fixed).

**Calibration reading.** The claim is an instrument, not an assertion: its detections are planted
mutants of the lane's own text, and its do-nothing control (no instrument) reads 0. The round-38
mismatch is measured on the lane's own text by the gate's history run (`bash corpus/claims-declared.sh`
against the round-38 SCORECARD section, not in the manifest), and reported honestly, not counted.

## Routed, not claimed

- R38-D3 (`observe-r38.json` is evidence, not a pin; 30 `RECEIPT-MISMATCH` on `observed_at`): not re-pinned.
  A re-pin is a separate declared claim.
- R38-D4 (frozen-counter gaps: symlink-body confinement, superscript traceback, duplicate ids, surviving
  quote mutants M2/M3/M5/M6, surviving guard mutant G3): routed to round 40 as frozen-counter amendments
  with their red witnesses; the round-38 counter `plans/round-38-c1.sh` and `corpus/quote-locate.py` are unchanged.
- R38-D5 (ledger row `R38-03`, POLICY pending the operator's allowlist decision for `corpus/quote-locate.py`):
  operator-owned; L0 question already open (`kagi | round-38`).
- R38-D6 / R37-V2 (release-clock re-point of the 15 fired clocks): not claimed; the derivation dependence
  measured at round 38 stands.
- R37-V4 anchor-immutability for S034/S035/S039 is claimed as C1 (above). The 2.2.10 boundary control
  (round-37 mutant M5) is not claimed: the round-37 counter already reads the boundary correctly on the
  fixture class I measured, so it is a control gap, not a detection gap; routed.
- R38-EG-1 (the guard's documented `run LANE -- CMD` usage is refused; the implemented form is
  `run -- LANE -- CMD`): corrected in the header as a documentation fix in this round's candidate, not a claim.

## Frontier step (§2b)

- Census before (START, this round): `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` →
  exit 0 (`kagi ok …/corpus/SOURCES.md`, W04 duplicate-URL warnings); lane `bash corpus/sources-census.sh` →
  `SOURCES_CENSUS: CLEAN (rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
  Receipts: `/fast/scratch/hyaku/kagi-r39/l1/census/start-fleet.txt`, `start-lane.txt` (copied to the wave dir).
- Census after: recorded at the landing revision; expected rows=94 with S094 (own-work), `entries_sourced` unchanged.
- Rows added: S094 (own-work, `CORPUS.md` §SOURCES.md rule 2). Rows touched old→new: none.
- Mistakes mined into `corpus/lessons/round-39.md` `## Mistakes`: M39-1 (R38 CD-1: a claim axis relabelled after
  data, captured-by `none`; fixed by C2), M39-2 (laneguard usage line documented the form the code refuses;
  captured-by `none`; fixed by the header correction, shown able to fail by the probe run that refused it).
- Assimilation: none (the eight `kagi` rows of the absent-defect register remain quarantined, unchanged).
- considerthese: no `considerthese/` proposal taken this round; not claimed.

## Wave

One v1 wave of 10 seats (band 8–16; L2 floor 8): executor ×3 (K39ExecAnchor, K39ExecDeclared,
K39ExecSources), scribe ×1 (K39ScribeTrial), scout ×1 (K39ScoutFired), connector ×1 (K39ConnOverlap),
reviewer ×2 (K39ReviewAnchor, K39ReviewDeclared), critic ×1 (K39CriticClaims), mutation-tester ×1 (K39MutInstruments).
Attack seats = reviewer 2 + critic 1 + mutation-tester 1 = 4/10 = 40 % (≥25 %); connector 1 (≤2). The
canonical planner seat is held by the L1 (the validator rejects `planner`; deviation recorded as in rounds 33, 37, 38).
Every seat writes only under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-39/build/<seat>/`.
