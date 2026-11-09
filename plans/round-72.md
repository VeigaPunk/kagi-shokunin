# Round 72 — kagi (secrets & vault ops) — predeclaration (frozen)

Lane: kagi. Round 72, attempt 1. L1 `KagiR72` (holds the §3 planner seat; the validator rejects a
`planner` swarm role). Claim BASE `b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9` (lane tip at round
start = round-71 spot-check tip). Host: this Linux/omp host; network used for live feed and page
reads only (no vault, no `op`, no credential).

## Pre-move state

All six axes stand at 9 (SCORECARD `## Round 71 — post-move`); any claim meets the lowest-axis
duty. A capability entered at round 71, so the stagnation nudge does not fire. This prompt names the
lane axes freshness + calibration; both claims sit on those axes. Measured BASE facts:

- `python3 corpus/release-clock.py` (default = round-54 receipt, observed 2026-11-07) →
  `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`. A
  live `--observe` made at round start (2026-11-09T03:56Z) cannot be accepted by the table: all 32
  rows read `RECEIPT-MISMATCH` because the table's `observed_at` is 2026-11-07. Of the 14 fired rows,
  ten are DERIVED Vault/OpenBao clocks (S013, S022–S024 on S034; S014–S016, S021, S025, S026 on
  S035) whose anchors 2.2.0 / 2.7.1 sit one release behind the observed 2.2.1 / 2.7.2. Their
  teaching was re-verified at exactly those releases in round 47 (`corpus/fired-reverify.tsv`,
  10 of its 11 rows), but the clocks were never re-armed: a fired clock stays `fired` when the
  NEXT release ships, so for these ten rows the lane cannot see Vault 2.2.2 or OpenBao 2.7.3.
- `python3 corpus/self-counts.py` → `SELF_COUNTS: POLICY (claims=63 stale=4 unlocated=0
  ambiguous=0 policy=2 setup=0)`; the four STALE rows are SC-SKILL-STAMPS / SC-SKILL-CLAIMS
  (`SKILL.md:46` says 164 stamps + 101 claims; live 181 / 102) and PV-STAMPS / PV-CLAIMS
  (`PROVINCE.md:73`, same numbers) — routed as carried by the round-71 closure §5 item 4. The two
  POLICY rows (PV-FEEDTOKEN-SHAPES / PV-FEEDTOKEN-SELFTEST = ledger R29-02 / R29-01) are the
  operator-routed boundary and are retained, never migrated.

## C1 — freshness: re-arm the ten derived Vault/OpenBao release clocks at the observed releases

Surface moved: the lane's release-clock table and its default receipt. After the move the ten
derived clocks are anchored at the currently observed releases (Vault 2.2.1, OpenBao 2.7.2) through
two new feed rows opened this round (S174 supersedes S034, S175 supersedes S035), each re-arm is
backed by a round-72 page re-fetch with the id's declared quote located (`corpus/clock-rearm.tsv`),
and the gate's default receipt is a live observation of 2026-11-09 (`.ufo/waves/round-72/final/observe-r72.json`).
Command that would show it unmoved: the frozen counter on BASE (`value=0`).

**Doctrine fit (QM23, QM24, QM28).** The ten rows are `derived:` clocks: QM28 binds their anchor to
the feed row's anchor cell, not to the teaching row (whose own anchor names the 2.7.x series or no
version and stays true). So the QM24 "successor bound at its named current release" is, for a
derived clock, a successor FEED row naming the current release (S174, S175), and the teaching rows
keep their ids, URLs and `on-release` cadence. The old feed rows S034/S035 stay in the registry
(S012 stays on S034 and stays fired: its own anchor names `v1.21.x`; S027/S028 and S072 stay fired —
none is in F). The re-pin is explicit, not silent (QM23): each re-arm cites the round-47 semantic
re-verification at the same release and a round-72 re-fetch. Integration duties (not counted):
an expectation-migration journal for every ledger row the move changes (at least R36-03, whose
pinned line reads `fired=14`), the round-54 receipt retained as history (`--receipt`), and a
later-release fixture showing a re-armed clock fires (QM24 last sentence; wave labrat item).

**Frozen predicate (the same sentence as the header of `plans/round-72-c1.sh`):**
`C1_CLOCK_REARM: value = number of ids in F = {S013 S014 S015 S016 S021 S022 S023 S024 S025 S026}
(the ten derived Vault/OpenBao release clocks that read fired at BASE b2f3dd66) that are ARMED,
VERIFIED, SOURCED and LIVE, when GATE = 1, FRESH = 1 and CENSUS = 1, else 0; target 10 (BASE 0).`
The leg definitions are the counter header's, verbatim: ARMED (row `not-fired`, `derived:` note,
anchor = observed = the default receipt's parsed version, newer than the BASE anchor), SOURCED (feed
row absent from the BASE registry, `mined`, opened ≥ 2026-11-09, URL = the row's feed URL), VERIFIED
(exactly one `corpus/clock-rearm.tsv` row bound to a committed round-72 capture by sha256 and bytes,
fetched in [2026-11-09T00:00Z, run time], the id's BASE fetch quote located ≥ 1 and exactly
quote_count times by the BASE-pinned `corpus/rendered-text-v1.py`), LIVE (this counter run's own
live observation through the BASE-pinned gate parses the same version; network failure is SETUP),
GATE (default receipt = the round-72 file with matching sha256; BASE-pinned gate with that receipt
and T's shipped gate both CLEAN rc 0), FRESH (every receipt observation dated ≥ 2026-11-09), CENSUS
(BASE-identical `corpus/sources-census.sh` CLEAN rc 0). Missing/empty/SETUP producer output fails
closed (exit 2, value 0) — never an awk zero.

- Counter: `plans/round-72-c1.sh`. Counting command: `bash plans/round-72-c1.sh <landed lane revision>`
  (~20 s, network). Target `value=10`, rc 0. **Kill rule:** `value < 10` on the landed revision →
  C1 missed (honest stop; never narrowed after landing).
- Sourced claim (§2b item 4): S174 and S175, opened 2026-11-09.

**Forgery and control classes, enumerated before the wave (routed item 3 of the round-71 closure).**
Executed by `plans/round-72-controls.sh` with the expected verdict written into the runner before
the first run (receipts `.ufo/waves/round-72/controls/receipts/`):

| id | class | expected |
|---|---|---|
| F0 | do-nothing (BASE) | value=0 rc 1 |
| P1 | positive reference (the candidate tree) | value=10 rc 0 |
| F1 | anchor bump only (table re-armed on S034/S035, no new feed row, no ledger) | value=0 (gate DERIVATION) |
| F2 | re-arm without the re-check ledger | value=0 |
| F3 | stale receipt pin (shipped gate still defaults to round 54) | value=0 (gate=0) |
| F4 | forged capture digest in one ledger row | value=9 |
| F5 | verdict without evidence: ledger says `quote-located` but the capture lacks the quote | value=9 |
| F6 | fabricated future release, self-consistent (feed anchor, table, receipt, ledger all 2.7.3; receipt re-pinned) | value=4 (LIVE kills the six OpenBao rows) |
| F7 | in-place anchor edit of the BASE feed row S035 instead of a new opened row | value=4 (SOURCED kills six) |
| F8 | weakened shipped gate hiding a real receipt mismatch | value=0 (BASE-pinned gate run) |
| F9 | census instrument swapped | SETUP rc 2 |
| F10 | default receipt deleted | value=0 |

**Uncounted conjuncts (named, not counted; judged by non-author reading):** (U1) semantic teaching —
quote location is not semantics; the semantic leg is the round-47 `teaching-holds` judgment at the
same releases, which this counter does not re-judge; (U2) the receipt's 22 non-F observations are
checked by the gates' shape/consistency rules and the FRESH date, not re-read live by the counter;
(U3) LIVE binds the vendor state at measurement time — a later Vault/OpenBao release makes the
landed claim read `live=` mismatches (that is the re-armed clock working, not a regression);
(U4) the counter trusts the BASE-pinned gate's feed parser.

## C2 — calibration: the four carried self-count mismatches

Surface moved: `SKILL.md` decision-table row "Re-run a claim…" and `PROVINCE.md`'s
`corpus/claim-ledger.sh` line, whose current-tense stamp/claim counts disagree with the ledger.

**Frozen predicate (the same sentence as the header of `plans/round-72-c2.sh`):**
`C2_SELF_COUNTS: value = the stale= count the lane's own self-count gate prints for tree T, when
PINS = 1 (corpus/self-counts.py and corpus/self-counts.tsv byte-identical to BASE b2f3dd66) and
SHAPE = 1 (one summary line SELF_COUNTS: POLICY (claims=63 stale=S unlocated=0 ambiguous=0 policy=2
setup=0), gate exit 2, exactly the two POLICY ids PV-FEEDTOKEN-SHAPES and PV-FEEDTOKEN-SELFTEST, OK +
STALE lines = 61); otherwise SETUP (exit 2). Target 0 (BASE 4).`

- Counter: `plans/round-72-c2.sh`. Counting command: `bash plans/round-72-c2.sh <landed lane revision>`.
  Target `value=0`, rc 0. **Kill rule:** `value > 0` on the landed revision → C2 missed.
- Change: the two numbers on each line are set to the measured revision's live counts (ledger
  R12-03 stamp membership and R21-04 claim rows). Because C1's integration may add stamps, C2 lands
  last and is measured on the final revision.
- Controls (same runner): G0 BASE value=4 rc 1; Q1 BASE + C2 change only value=0 rc 0 (separability:
  C2 holds without C1); Q2 candidate + C2 value=0 rc 0; G1 binding dropped from the table → SETUP;
  G2 gate replaced by an echo → SETUP; G3 the SKILL line deleted → SETUP (shape); G4 one number off
  by one → value=1; G5 the R29-01 POLICY boundary moved → SETUP.
- Uncounted: the two `claims-declared.sh` MISMATCH rows for round 69 (honest-stop rows tagged
  `[C1, missed]`) are a different instrument and are not in this population; carried.

## Separability

C1 touches `corpus/release-clocks.tsv`, `corpus/release-clock.py` (default receipt pin and help
text), `corpus/SOURCES.md` (S174/S175), `corpus/source-fetches.tsv`, `corpus/clock-rearm.tsv` and
round-72 captures/receipt. C2 touches two lines of `SKILL.md` and `PROVINCE.md`. C1's counter reads
neither line; C2's counter reads no C1 file except through the stamp count it binds, and Q1 shows C2
reaching 0 on BASE without C1. Neither claim is exploratory.

## Wave

ONE v1 wave `w1`, 8–16 seats, ≥ 25 % attack seats, ≤ 2 connectors (spec and dispatch in
`.ufo/waves/round-72/`). Seats re-run both counters and the controls, attack the wording, re-open
S174/S175 and the ten pages, review the integration, and replicate the re-arm independently.
