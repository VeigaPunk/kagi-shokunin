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

## Amendment A1 — wording narrowed on the wave's own evidence (after w1, before filing)

The frozen predicates, counters, targets and kill rules are unchanged; the numbers are not
re-scored. These sentences of this plan said more than the counters enforce, and are narrowed
here (each tied to the seat artifact in `.ufo/waves/round-72/claim-falsification.tsv`):

- **A1.1 Release identity (R72Connector CN-2, R72ReviewerSrc SR-4).** "two new feed rows opened
  this round (S174 supersedes S034, S175 supersedes S035)" is true by the counter's letter but
  overstates what the rows add: the registry already held the same identities since round 37
  (S089 Vault v2.2.1, S090 OpenBao v2.7.2, both superseding S034/S035) and never bound them to
  the clocks. S174/S175 are same-URL re-opens on 2026-11-09 that carry the binding; at
  integration their `teaches` cells say `supersedes S089` / `supersedes S090`. C1 as filed: the
  ten clocks are re-armed through rows opened this round; no new release identity is claimed.
- **A1.2 Supersession is not counted (R72Critic CR-1).** SOURCED reads status, opened date,
  BASE absence and URL, never the `supersedes` cell.
- **A1.3 "Blind" pre-move sentence (R72MutLater LB-1/LB-2, R72Critic CR-2).** "for these ten rows
  the lane cannot see Vault 2.2.2 or OpenBao 2.7.3" is false: on BASE a newer observation also
  disagrees with the table (`RECEIPT-MISMATCH` on the next `--observe`). What the re-arm changes
  is the verdict: a re-armed row reads `fired` again only after the table records the newer
  observation, so `fired` once more means "newer than the last re-verified release" for these
  ten rows (on BASE it stayed `fired` either way). No in-round fixture shows a re-armed row going
  from `RECEIPT-MISMATCH` to `fired` through the shipped gate end to end except R72MutLater's
  offline table-updated variant (CAND `fired=14` CLEAN), which BASE bytes reproduce for the same
  table edit; QM24's last sentence is met in that weaker sense only.
- **A1.4 Semantic leg (R72Critic CR-3; U1).** "each re-arm cites the round-47 semantic
  re-verification" is prose in the table notes, not a counted leg (flipping every
  `teaching-holds` still reads value=10). The non-author semantic check of 2026-11-09 is
  R72ReviewerSrc SR-5: ten of ten `teaching-holds` on today's pages.
- **A1.5 Fetch provenance (R72Reviewer RV-2) and feed vendor (RV-1).** VERIFIED counts byte
  binding and quote containment of a committed capture; `fetched_at` is self-declared. LIVE binds
  whatever `feed_url` the row names; that it is the vendor's feed is registry review (SR-1/SR-5:
  both feeds re-fetched byte-identical to the committed captures).
- **A1.6 Integration duties (R72Revenger RE-1/RE-2, R72Critic CR-4, R72ReviewerSrc SR-1).**
  The candidate lacked the expectation-migration journal and left four default-receipt sentences
  naming round 54; both were done at integration (`.ufo/waves/round-72/expectation-migrations.json`:
  R36-02 `^3$`→`^13$`, R36-03 `fired=14`→`fired=4`; SKILL.md rows "Judge whether…" and "source
  release clocks", PROVINCE.md release-clock line, `corpus/release-clock.py --help`).
- **A1.7 Plan gaps for a replica (R72ExecReplica 2/3).** The plan did not say that the 22 non-F
  rows need their `observed_at` refreshed for the new receipt to match, nor the census identity
  rules for the new rows; the replica still reached value=10. Recorded as a lesson, not a number.
- **A1.8 Legs no control proves (R72MutTester MT-1…MT-8).** Six single-leg mutants survive the
  20 frozen controls: C1 ARMED "newer than the BASE anchor", C1 FRESH, C1 VERIFIED quote_count
  equality (a `>= 1` weakening survives); C2 `claims=63` in the shape regex, the two POLICY ids,
  and the gate-exit-2 check. SOURCED, LIVE and the ledger binding are each killed by one control
  only (F7, F6, F4), and C2's pins only through the reason string. The counters still carry every
  leg on the measured bytes, but "enforced" in this plan means present in the counter's code; for
  these legs it does not mean shown by a control. No predicate, counter or target changes.
- **A1.9 Instrument holes a forger could use (R72Sentinel SE-2, SE-3, SE-6).** "BASE-pinned gate"
  pins `corpus/release-clock.py` only: the gate imports the measured tree's own
  `corpus/rendered-text-v1.py`, so a tree that edits that file can forge LIVE (SE-2); the capture
  containment test is lexical, so a committed symlink can redirect the sha check (SE-3); and
  VERIFIED accepts any committed body that contains the quote, e.g. an authored quote-only file
  (SE-6). The counters are frozen and are not repaired this round. On the measured revisions none
  of the three is used: `corpus/rendered-text-v1.py` is byte-identical to BASE, the candidate tree
  has 0 symlink entries, and the ten captures are whole vendor pages of 47 384–586 212 bytes (the
  OpenBao pages byte-identical to their round-47 captures; R72ReviewerSrc re-fetched them)
  (`.ufo/waves/round-72/final/se-ceiling-receipts.txt`). C1 as filed rests on those receipts for
  these three legs, not on the counter alone. The repairs are routed to the next clock counter.
- **A1.10 C2 change set (R72Connector CN-3).** The four BASE-stale numbers were set to the final
  live counts (185 stamps / 102 claims), not the candidate's 181. Stamping the four round-72 files
  also made a fifth binding stale that was fresh at BASE (RD-STAMPS, `corpus/README.md:65`, 181);
  it was updated to 185 with a round-72 history clause. C2's counted population is all 61 OK/STALE
  bindings, so the final reading covers it; the plan's "two numbers on each line" undercounts the
  edits by one line.
