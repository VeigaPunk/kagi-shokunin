# kagi round 38 — plan (frozen claims)

Round 38, attempt 1. Lane: kagi (secrets & vault ops). Owned axes: freshness + calibration.

Lane HEAD before the round (claim BASE): `a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c`.
Predeclaration (instruments, frozen controls, capture bodies, live re-observation receipt, START census
receipts): `8c48b7df71066b969ac078205b5ed18cf5f53286`. Shipped pre-freeze gate over that commit:
`PREFREEZE: CLEAN (controls=7 mismatch=0)` (`.ufo/waves/round-38/controls/prefreeze-gate.txt`).
Frozen counters measured on the claim BASE extraction `a916f4a` (counter scripts copied in; the
instruments are absent there): C1 = 0, C2 = 0 (no manifest, no guard).

## Read before freezing (fresh-start check, not a fresh-start round)

Kagi r37 closed as non-author `verifier-spotcheck` (`corpus/lessons/round-37-verifier-spotcheck.md`):
C2 verified (`freshness` improved), discernment improved, conformance defect R37-V1 (a transcribed
freeze hash prefix), and routed debt R37-V2..V5 handed to round 38. This round reads that closure and
the round-37 lesson; the release-clock table (R37-V2) was measured before any claim was chosen.

Measured before choosing claims (committed receipts, `.ufo/waves/round-38/controls/`):
- `verify-base.txt`: `python3 corpus/release-clock.py` at the claim BASE reads `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`, exit 0.
- `observe-r38.json` (live full-tree observation, 2026-11-05T09:08Z, 30 records, failed=0): 30 of 30 records
  carry the same parsed version, verdict and located flag as the pinned round-36 receipt. No clock moved.
- Re-pointing the 15 clocks bound to superseded feed rows (S034/S035/S036/S039) is not a freshness move:
  for `derived:` clocks the anchored version must equal the feed anchor cell (DERIVATION, QM28), so a
  re-point to S089–S091 changes the clock's anchor and verdict (a fired clock would stop firing). That is
  why R37-V2 is not claimed here; its disposition is recorded in the round lesson with measured evidence.
- `scripts/hyaku/`: the drift substrate is absent on this Linux host (`~/.local/bin/the-janitor` absent);
  `drift-pins.sh` and `surface-census.sh` read DRIFT by absence, a documented host condition, not a claim.
- LANE-GUARD: `grep -rn LANE-GUARD` over committed tracked files finds no mechanism; the round-37 lesson
  and report describe a battery line the committed battery does not print (routed M37-2 mismatch).

## Why these two claims
All six axes stand at 9 (round-37 close); the lowest-axis obligation is met by a tie on the owned
freshness axis. The two claims are causally separable: C1 touches `corpus/quote-locate.py`,
`corpus/quote-bodies.tsv`, the S092/S093 rows and their captures; C2 touches `corpus/laneguard.sh`
and its counter. Neither verifies through the other.

## C1 — freshness: located-quote gate over committed capture bodies, 0 → 5

**Declared claim.** `bash plans/round-38-c1.sh` prints one integer: the located count of the rows of
`corpus/quote-bodies.tsv` (`corpus/quote-locate.py`). Target **5** (S089, S090, S091, S092, S093); BASE **0**.

**Frozen predicate (identical sentence in `corpus/quote-locate.py`'s header, the counter, and the receipt label):**
the located count `located=N` is the number of rows of corpus/quote-bodies.tsv whose declared quote is found byte-for-byte in the committed capture body at its declared offset, where the body sha256 and byte count equal the capture row's (corpus/source-fetches.tsv columns 10 and 11), the declared quote equals the capture row's quote (column 13), and the quote occurs verbatim in that id's registry row in corpus/SOURCES.md.

**Sourced claim.** C1 rests on two rows opened in this round, S092 (Vault release tag page v2.2.1) and S093
(OpenBao release tag page v2.7.2), each with a located quote in the committed body
(`.ufo/waves/round-38/capture/`), and on the re-opened feed captures S089–S091 (round-37 bodies).

**Controls (frozen, `plans/round-38.controls.tsv`, executed at `8c48b7d`, CLEAN 7/7):**
- `c1_nowork` (no manifest) → 0; `c1_positive_full` (five rows) → 5;
- `c1_forge_quote` (S090 manifest quote replaced by a string not in the body) → 4;
- `c1_forge_bytes` (one byte of the S091 body changed after capture) → 4;
- `c1_forge_registry` (S092 quote removed from its registry row) → 4.

**Kill rules (frozen).**
- The landing revision's `bash plans/round-38-c1.sh` prints anything other than 5 → C1 unmet, not admitted.
- `bash corpus/quote-locate.py` at the landing revision prints `FAIL` → C1 unmet.
- A committed capture body under `.ufo/waves/round-38/capture/` or `.ufo/waves/round-37/capture/` changed after the predeclaration → C1 fails.
- A registry row (S092/S093) lacking its quote, or the lane census `bash corpus/sources-census.sh` not `CLEAN` → C1 unmet.

**Ceiling, named before data.** The gate checks committed bytes against committed captures. It does not
re-fetch a live page, and it does not check that a quote supports the row's teaching; those are the
wave's independent re-fetch and reviewer duties.

## C2 — calibration: lane-tree write guard closes the round-37 M37-2 self-description, 0 → 3

**Declared claim.** `bash plans/round-38-c2.sh` prints one integer: `detected=N` of `bash corpus/laneguard.sh --selftest`. Target **3**; BASE **0**.

**Frozen predicate (identical sentence in `corpus/laneguard.sh`'s header, the counter, and the receipt label):**
`LANE_GUARD_SELFTEST detected=N` — N is the number of planted lane-tree writes (a tracked edit, an untracked file, a new commit) that `laneguard.sh run` reports as VIOLATION with exit 1, in fixture repositories created under scratch; the clean control must pass (CLEAN, exit 0) for the selftest to count any detection.

**Controls (frozen):** `c2_nowork` (planted writes replaced by `true`) → 0; `c2_positive` → 3.

**Kill rules (frozen).**
- Any planted write not reported as VIOLATION at the landing revision → C2 unmet.
- The clean control reports VIOLATION or a non-zero exit → C2 unmet (a guard that cries wolf does not count).
- The selftest touches any repository other than its own fixtures (checked by `git status --porcelain` of the lane before and after the selftest, which must be unchanged) → C2 unmet.

**Calibration reading.** Round 37's lesson stated that the battery prints a `LANE-GUARD` line; the committed
battery does not. The measured move is that a committed guard now exists, and a self-description that names
it can be checked against it. The claim is not an assertion: the counter fails on the do-nothing control.

## Routed, not claimed

- R37-V1 (transcribed freeze hash prefix `e2030d2794…` in the round-37 report and lesson): corrected by an
  appended erratum in this round's lesson and report with the full hash `e2030d2799cf46e77dcfef0369d79d8da4130e05`.
  The filed round-37 bytes are not rewritten.
- R37-V4 (anchor-immutability check; boundary control for `2.2.10`): routed to round 39 as a frozen-counter
  amendment, not claimed here.
- R37-V5: the round-37 lesson's `## Non-author spot-check` gets an appended pointer to the closure.
- R36-4 and the calibration reviewer conditions: unchanged; not re-claimed.

## Frontier step (§2b)

- Census before (START): `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` →
  exit 0 (`kagi ok …/corpus/SOURCES.md`, 19 W04 duplicate-URL warnings); lane `bash corpus/sources-census.sh` →
  `SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 …)`.
  Receipts: `.ufo/waves/round-38/controls/start-census-fleet.txt`, `start-census-lane.txt`.
- Census after: recorded at the landing revision (same two commands); expected rows=93 with S092 and S093.
- Rows added: S092, S093 (tier A, mined, scope = release identity of the tag). Rows touched old→new: none.
- Mistakes mined into `corpus/lessons/round-38.md` `## Mistakes`: M38-1 (R37-V1 transcription), M38-2
  (LANE-GUARD described, not committed), M38-3 (Gate quotes checked by hand only).
- Quarantine: the eight `kagi` rows of the absent-defect register remain quarantined; none is appended
  (`Assimilation: none`; the register's S090/S091 ids collide in spelling with this lane's rows, so any future
  adoption runs the id-collision guard first).
- considerthese: no proposal is taken this round (the round-37 plan records the 2026-10-26 proposals as implemented or discharged).

## Wave

One v1 wave of 10 seats (band 8–16; L2 floor 8): executor ×3 (K38ExecQuote, K38ExecGuard, K38ExecSources),
scribe ×1 (K38ScribeLedger), scout ×1 (K38ScoutRelease), connector ×1 (K38ConnOverlap), reviewer ×2
(K38ReviewQuote, K38ReviewGuard), critic ×1 (K38CriticClaims), mutation-tester ×1 (K38MutInstruments).
Attack seats = reviewer 2 + critic 1 + mutation-tester 1 = 4/10 = 40 % (≥25 %); connector 1 (≤2). The
canonical planner seat is held by the L1 (the validator rejects `planner`; the deviation is recorded here, as in rounds 33 and 37).
Every seat writes only under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-38/build/<seat>/`.
