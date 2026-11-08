# Round 65 — kagi (secrets & vault ops)

Lane: kagi. Round 65, attempt 1. Claim BASE `b17887f03179b61d49e3e0f10ce1a9add21829e7`
(round-64 verifier spot-check tip). Frozen predeclaration `plans/round-65.md`
(landed `ab1cedc4`, with Amendments A1–A3 recorded before the respective
readings). Wave `kagi-r65-w1`, 16 seats (plan §Wave).

Claims: **C1 calibration** — the held-out population becomes a class matrix and
the polarity grammar gains a measured sentence-level clash class
(`C1_MATRIX` 5 → 0 over population 8). **C2 operability** — the routed-leg
population stops expecting a receipt no tree holds (`C2_POPULATION` mismatch
1 → 0). **C3 freshness** — the volatile BioC carrier's re-verification becomes
reproducible (`C3_VOLATILE` 0 → 1).

## Gate (rows written this round)

Two sources were opened this round. One admitted, one rejected.

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S155 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml | 2026-11-08 | "In the current version of ConText there are 17 pseudo-triggers for negated (e.g., "no increase", "not cause")" (§3.1.2 Trigger Terms, Pseudo-Trigger Terms, and Termination Terms; 21 words) | admit, tier A | the deposit is byte-identical to S135's pin (189603 B, sha256 `cdbb4173…`), so the pseudo-trigger class the idiom list is bounded by is re-verified, not re-asserted |
| S156 | https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode | 2026-11-08 | the served body: `{"error": "Rate limit exceeded.", "detail": "Maximum 3 requests per second per user."}` (899 B, sha256 `037c2dbe…`) | reject, tier C | two attempts 20 s apart both answered HTTP 429, so the live carrier cannot ground a live re-verification; flip: a 200 response serving the BioC XML deposit |

Registry effect: `corpus/SOURCES.md` 153 → 155 data rows (S155 `mined`, S156
`rejected`). No existing row's `status`, `recheck` or `used-by` cell changed.
`corpus/source-fetches.tsv` gains the two captures. The admitted entry is
`corpus/knowledge/claim-instrument-class-matrix.md`.

Search log: one bounded search (round-65 frontier) over the lane's existing
BioC/ConText carriers and the OpenBao docs tree. Identified 3 candidates,
screened 3, included 1 (S155), excluded 2 (S156 rate-limited; the OpenBao
tokens page carries no statement about the round's claims). Stop rationale: the
claim's evidence need is one re-verified carrier plus one honest rejection.

## Claims and readings

### C1 — calibration (`C1_MATRIX`, matrix 5 → 0, population 8)

The instrument landed is a shared sentence-level clash detector
(`_line_clash` in `plans/round-61-c1-check.py`) applied to every correction line
an item selects, plus the class-matrix fixture table
(`plans/round-65-heldout.tsv`, sealed `84436425…`). Readings are in the report's
**Before → after measurements** section; the counter is `plans/round-65-c1.sh`.

### C2 — operability (`C2_POPULATION`, mismatch 1 → 0)

BASE: the round-63 lesson's §Routed dispositions row D-B expects **six**
receipts under `.ufo/waves/round-63/final/`, `controls` among them, and that
directory holds **five** — the battery's receipt lives under
`build/R63ExecControls/`. The leg's expectation was therefore unsatisfiable on
every tree (QM57).

**Correction record (this round supersedes that expectation).** The round-63
D-B expectation of six final receipts is superseded: the corrected population is
the **five** receipts the round-63 tree actually holds — `c1-residual`,
`c2-refusal`, `release-clock`, `doc-audit`, `claims-declared` — and the
`controls` receipt is not a `.ufo/waves/round-63/final/` member (its battery
receipt is `build/R63ExecControls/`). `plans/round-65-routed.sh` derives the
expectation from the lesson row instead of hand-writing it, prints the derived
versus held sets, and keeps the old six-receipt expectation as a `--legacy` leg
that must still read `mismatch=1` — the correction is the only delta.

### C3 — freshness (`C3_VOLATILE`, 0 → 1)

`corpus/volatile-shape.py` re-verifies the S148 carrier from the committed
capture (identity + date stamp + element counts). The live endpoint is
rate-limited on this host (S156, measured twice), so a live-fetch predicate
would have been unfalsifiable; Amendment A1 records that measurement and moves
the carrier to the committed bytes before any scoring.

## Mistakes

### M65-1 — a target a do-nothing control already reaches

- **class**: `vacuous`
- **evidence**: the first §C2 predicate pointed d3 at the six *round-64* final
  receipts; those were committed by round 64, so a no-work tree reads `d3=1`.
  Caught before the wave's candidate scoring and re-frozen as Amendment A2
  (`plans/round-65.md`).
- **captured-by**: `plans/round-65.md` §9 sizing rule ("a target must be one a
  do-nothing control cannot reach") — the rule existed and was not applied when
  the predicate was first written.
- **fix**: the re-frozen predicate measures the round-63 D-B population
  mismatch, which reads 1 at BASE. Shown able to fail: `bash
  plans/round-65-routed.sh` ⇒ `ROUTED: d1=1 d2=1 d3=0` at BASE, `d3=1` only
  after the correction lands.

### M65-2 — a fixture class no item reads

- **class**: `vacuous`
- **evidence**: `R65-H5`'s first version rewrote a round-60 line
  ("The round-59 lesson reused `R20`…") that no `itemN` reads, so it could
  never be a class the checker claims. Measured: the forged copy read
  `value=0` with the same item vector as the clean tree.
- **captured-by**: `plans/round-65.md` §C1 ("each forgery fixture exercises one
  distinct mechanism the checker claims") — the rule was written and the fixture
  selection did not honour it.
- **fix**: the fixture was replaced with an I5-class forgery on the LOG wave
  line and the table resealed (`84436425…`, Amendment A3). Shown able to fail:
  the new fixture reads `value=1` on the candidate and `value=0` at BASE.

### M65-3 — an impossible predicate direction, written and frozen

- **class**: `scope`
- **evidence**: §C1 guard leg (e) said the structural lookup vehicle must read
  `matrix=0` on the held-out set. A lookup carries only the strings it was
  fitted to, so it returns `accept` on fresh strings and cannot read 0 there —
  the leg as written would fail every candidate, including a correct one.
- **captured-by**: `none` (no criterion in `corpus/QUALITY.md` required a guard
  direction to be checked for satisfiability before freezing). New criterion QM87 below.
- **fix**: Amendment A3 restates the leg in the falsifying direction
  (`matrix>=1`); `plans/round-65-c1.sh` measures it that way and reads
  `vehicle=1` only when the vehicle is shown to fail.

### M65-4 — a capture file's name does not match its registry id

- **class**: `attribution` / `reference-drift`
- **evidence**: `.ufo/waves/round-64/capture/S148.body` holds the arXiv
  1909.02196 body, while the registry's `S148` is the BioC deposit — whose
  bytes are stored as `capture/S143.body`. Round 64 numbered the captures by
  draft id; the registry renumbered before commit.
- **captured-by**: `none` for capture filenames (the census checks registry
  cells, not capture names). New criterion QM88 below.
- **fix**: the round-65 counter binds `DEFAULT_CAPTURE` to
  `.ufo/waves/round-64/capture/S143.body` with a comment naming the drift, and
  the sha check makes a wrong path fail closed rather than read empty.

## Routed dispositions

| id | what | state |
|---|---|---|
| D-C65-1 | round-63 D-B population expectation unsatisfiable (six receipts, five held) | corrected this round (`plans/round-65-routed.sh` d3; this lesson's correction record) |
| D-C65-2 | capture filename ≠ registry id for S148 | named (M65-4), bound to the measured path; a rename is not a repair that rewrites a committed capture |
| D-C65-3 | live BioC carrier rate-limited (429) | measured, registered as S156; the committed capture is the carrier |

## Gate result

Two candidates considered at the frontier step, one admitted (S155) and one
rejected (S156) for the recorded reason. Author spot-check of the pair agrees
with both decisions; the non-author spot-check is the closure's duty.
