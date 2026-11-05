# kagi round 40 — plan (frozen claims)

Round 40, attempt 1. Lane: kagi (secrets & vault ops). Owned axes: freshness + calibration.
Fresh-start round (operator "Authorize all", 2026-11-05; the last three closures hold two
rejected rounds — 36 and 38 — plus admitted 37, and round 39 closed verified).

Claim BASE (lane tip before the round): `6cc8850dfc5757927699e5a53a876f47c8df21aa` (round-39
verifier-spotcheck commit). Predeclaration (instruments, gate amendments, pins, capture bodies,
frozen counters, controls, measured BASE receipts): the commit before this file. Pre-freeze gate
over the predeclaration: `PREFREEZE: CLEAN (controls=9 mismatch=0)` run by
`corpus/prefreeze-control.sh run --base <predec> --controls plans/round-40.controls.tsv`
(rows: c1_nowork 6, c1_mutant_const 0, c2_nowork 0, c2_positive_pin 1, c2_forge_rows 1,
c3_nowork 0, c3_selftest_anchor 8, c3_selftest_claims 8, c3_forge_missing_gate 0).
This file is committed alone after that gate; no data is scored into it.

## Read before freezing (rejection history and routed debt)

- **Round 38 (rejected, CD-1):** a claim's declared axis is frozen with its predicate; round 38
  declared C2 calibration and reported the move under operability. `corpus/claims-declared.sh`
  now governs this; round 40 declares the axis on every claim below and tags the SCORECARD row
  with the same axis (`corpus/claims-declared.tsv` gains the three round-40 rows).
- **Round 36 (rejected):** a counter whose population is self-declared admits no-work paths its
  controls do not cover. Round 40's C1 population is the ledger's own machinery (verify re-runs
  every row's command), not a lane-asserted census; its fail-closed branches refuse a deleted
  row, a missing verify summary, or a constant counter (control `c1_mutant_const`).
- **Round 34 (rejected, C1/C3 coupled populations):** every claim below has its own population
  and its own counter; no counter reads another claim's artifact. C1 reads only
  `corpus/claim-ledger.tsv` rows through verify; C2 reads only pins/registry/captures; C3 reads
  only SKILL.md's registry table and the two selftests.
- **Round-39 non-author spot-check routed items** (this round's work list): (1) gate-registry
  rows absent for `anchor-pins.sh`/`claims-declared.sh` → C3; (2) no selftest mode on either →
  C3; (3) six failing ledger rows → C1; (4) S036 unpinned fourth superseded anchor (M39-7) →
  C2 item1; S040/S041 documentation refresh → C2 items 2–3; M39-6 constant-counter survivor →
  the C1 counter's fail-closed branches + control `c1_mutant_const` + both selftests' constant-
  mutant cases; M39-12 false-clean paths → gate amendments F1/F2/F3/F6 and D1/D2/D3/D5 with
  red witnesses in the two selftests (F4/F5 pin attenuation is covered at the counter level by
  C2 item1's literal pins=4; F7 co-rewrite and D4 conspiratorial relabel stay named ceilings
  QM40/QM41); S094 row precision → lesson erratum + QM42, the row cell is not edited
  (append-only); the LOG-39 citation gap → no action, per the spotcheck.
- **Measured at BASE (committed receipts, `.ufo/waves/round-40/controls/`):**
  `bash plans/round-40-c1.sh` → 6 (verify receipt `base-verify-at-tip.txt`); `bash plans/round-40-c2.sh`
  → 1 with the predeclaration's S036 pin in place and 0 without it (`c2_nowork`); the C2 items
  2–3 read 0 (no S095/S096 rows exist); `bash plans/round-40-c3.sh` → 0 (no registry rows).
  `bash corpus/anchor-pins.sh` → `ANCHOR_PINS: CLEAN (pins=4)` at the predeclaration;
  both selftests `PASS (8 cases)`.
- The-janitor substrate remains absent on this host; no host probe is claimed. R25-02 (FAIL),
  R29-01/R29-02 (POLICY), R38-03 (POLICY), R11-08/R22-03/R24-15/R36-03 (FAIL) are outside
  every population below and are not touched; the lane's calibration row keeps naming them.

## Why these three claims

All six axes stood at 9 at the round-39 close. The lowest-axis obligation is met by C2 (the
owned freshness axis; the routed python-currency debt is drift-detection and currency work).
C1 is calibration (the other owned axis): the ledger's self-description is re-bound to the
committed tree. C3 is operability: two instruments gain committed self-invocation modes and
their registry rows, clearing the two routed conformance defects. The claims are causally
separable: C1 verifies without C2 or C3 having landed (its set is fixed and its migrations are
defined against whatever the tree holds); C2 verifies without C1 or C3; C3 verifies without C1
or C2. No counter reads another claim's artifact.

## C1 — calibration: the six debt rows re-run green at the landing tree, 6 → 0

**Declared claim.** `bash plans/round-40-c1.sh` prints one integer: the number of rows among
the frozen debt set {R13-01, R21-02, R24-06, R31-02, R33-02, R34-03} that
`bash corpus/claim-ledger.sh verify` reports with a FAIL, STALE, MISSING or MISSING-ID line at
the current tree. Target **0** at the landing; BASE **6** (measured, receipt committed).
Fail-closed: exit 2 (no integer) when verify produces no `CLAIM_LEDGER:` summary, verify dies,
or any of the six ids is absent from `corpus/claim-ledger.tsv`.

**Frozen predicate (identical sentence in the counter, this file, and the receipt label):**
the count is over exactly the six named ids; no other row's state enters the number; the
migrations are round-38-style measured rebindings — each of the six rows' `expect` moves to the
value its command produces at the measured tree, with every old→new pair recorded in
`.ufo/waves/round-40/expectation-migrations.json`. R13-01: `^50$` → the measured heading count
(52 at BASE + the two round-40 headings). R24-06: count 50 → 54 with the new identity sha.
R21-02/R31-02/R33-02/R34-03: the census summary rows=93 → the measured landing summary
(rows=96 after the two C2 registry appends, captures=96). The three operator-owned reds
(R25-02 FAIL, R29-01/R29-02 POLICY) and the other inherited FAIL rows (R11-08, R22-03, R24-15,
R36-03) stay outside the set and unchanged.

**Controls (frozen, `plans/round-40.controls.tsv`, executed at the predeclaration, CLEAN):**
- `c1_nowork` → 6 (the tree before any round-40 work; a do-nothing round cannot reach 0).
- `c1_mutant_const` → 0 (a counter replaced by the constant 0 does not match the no-work
  expectation 6 — the M39-6 class is caught by the battery, red witness committed).

**Kill rules (frozen).**
- The landing revision's `bash plans/round-40-c1.sh` prints anything other than 0 → C1 unmet.
- The landing revision's `bash plans/round-40-c1.sh` exits 2, or prints its integer after any
  of the six ids was removed from the ledger → C1 unmet.
- Any `expect` moved without a matching old→new record in `expectation-migrations.json` → C1
  unmet (the migration journal is the auditable work, and the closure re-derives both sides).
- A set row left failing at the landing (target 0 unmet) is an honest stop; no target narrowing
  after data.

**Ceiling, named before data.** The claim re-binds self-description; it does not certify that
each migrated number is the *right* historical claim — only that it is the value the committed
tree re-derives today, with the old value recorded. It does not close the historical MISSING-ID
errata classes (R32-1..R32-5, R33-1..7, R34-2/3, R35-1, R36-1..5) cited by verifier-owned
lesson files; those stay outside every population.

## C2 — freshness: python-currency routed debt closed, 0 → 3

**Declared claim.** `bash plans/round-40-c2.sh` prints one integer N in 0..3, the number of
satisfied items. Target **3** at the landing; BASE **0** (measured without the pin;
`c2_nowork` receipt). The items:
1. the S036 pin (M39-7): `corpus/anchor-pins.tsv` carries S036 with the sha256 of the trimmed
   anchor cell recomputed at the tree, and `bash corpus/anchor-pins.sh` prints
   `ANCHOR_PINS: CLEAN (pins=4)`;
2. S095 (documentation refresh, supersedes S040): a tier-A docs registry row whose
   `corpus/source-fetches.tsv` row's sha equals the committed capture body
   `.ufo/waves/round-40/capture/S095.body`, whose verbatim quote (U+201C..U+201D in the teaches
   cell) locates in that body after whitespace normalization, and whose teaches cell names
   S040 as superseded;
3. the same for S096 (supersedes S041, body `.ufo/waves/round-40/capture/S096.body`).

**Frozen predicate (identical sentence in the counter, this file, and the receipt label):**
`python-currency debt items present and evidenced` as enumerated above; the two registry rows
S040 and S041 are NOT edited in place (CORPUS.md rule 2) — the refresh is new rows S095/S096
opened 2026-11-05 on the served Python 3.15.2 documentation, and the C2 counter's sha check
plus the census's capture handshake are what make a forged row unable to count (control
`c2_forge_rows` → 1, red witness).

**Sources (this round).** Both pages fetched 2026-11-05 with `curl -fsSL`:
- S095 `https://docs.python.org/3/library/re.html` — served `<title>re — Regular expression
  operations — Python 3.15.2 documentation</title>`; located quote “Matches Unicode whitespace
  characters (as defined by” (raw body byte offset 75897); capture sha256
  `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1` (257722 bytes).
- S096 `https://docs.python.org/3/library/html.html` — served `<title>html — HyperText Markup
  Language support — Python 3.15.2 documentation</title>`; located quote “This function uses
  the rules defined by the HTML 5 standard” (raw body byte offset 13521); capture sha256
  `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5` (20100 bytes).
Both captures are committed in the predeclaration. The Gate block of
`corpus/lessons/round-40.md` records both openings with access dates and ≤25-word quotes.

**Controls (frozen, executed at the predeclaration, CLEAN):** `c2_nowork` → 0 (pin removed);
`c2_positive_pin` → 1 (the pin item counts; items 2–3 cannot exist pre-data);
`c2_forge_rows` → 1 (registry-only forgeries do not reach the target).

**Kill rules (frozen).**
- The landing revision's `bash plans/round-40-c2.sh` prints anything other than 3 → C2 unmet.
- Any in-place edit of the S040/S041 rows (any cell) at the landing → C2 unmet (the refresh is
  successor rows; `git diff <BASE> <landing> -- corpus/SOURCES.md` must not touch their lines).
- `bash corpus/sources-census.sh` not CLEAN at the landing → C2 unmet.
- The S095/S096 quotes failing to locate in their committed bodies → C2 unmet.

**Ceiling, named before data.** The counter binds rows to committed capture bytes; it cannot
prove the capture equals the live page at closure time (fetch-time evidence only), and it does
not judge whether the teaching is still semantically current — only that the documented
teaching locates verbatim on the served 3.15.2 page as fetched. Pin/row co-rewrite (F7/QM40)
remains undetected by the gate.

## C3 — operability: gate-registry conformance for the two round-39 gates, 0 → 2

**Declared claim.** `bash plans/round-40-c3.sh` prints one integer N in 0..2: the number of the
gates `corpus/anchor-pins.sh` and `corpus/claims-declared.sh` that BOTH (a) have a row in
SKILL.md's `## Gate registry` table naming the script path, and (b) pass their committed
selftest right now (`*_SELFTEST: PASS (8 cases)`, exit 0). Target **2** at the landing;
BASE **0** (no registry rows; measured, `c3_nowork` receipt).

**Frozen predicate (identical sentence in the counter, this file, and the receipt label):**
`gate-registry conformance: registered and self-proven`; a registry row without a passing
selftest, or a passing selftest without a registry row, does not count; a gate script missing
while its registry row exists refuses the counter (exit 2, `c3_forge_missing_gate` red witness).

**Instrument bytes land in the predeclaration:** both gates gain their `--selftest` modes
(8 cases each; the false-clean classes F1 dup, F2 shape, F3 schema, F6 no-final-newline for
anchor-pins; D1 dup-row, D2 fence/comment heading, D3 section-missing, D5 padded axis cell for
claims-declared; each gate's case 8 proves a constant-CLEAN mutant diverges from the real gate
— the M39-6 class at the gate level). The registry rows and the three round-40 rows appended
to `corpus/claims-declared.tsv` (so the declared-axis gate governs this round too) land in the
candidate, after the freeze.

**Controls (frozen, executed at the predeclaration, CLEAN):** `c3_nowork` → 0;
`c3_selftest_anchor` → 8; `c3_selftest_claims` → 8; `c3_forge_missing_gate` → 0.

**Kill rules (frozen).**
- The landing revision's `bash plans/round-40-c3.sh` prints anything other than 2 → C3 unmet.
- A registry row whose named selftest does not exist or does not pass at the landing → C3 unmet.
- Weakening a selftest after data (renaming a verdict token, dropping cases) is an amendment:
  C3 is then unmet, not re-declared.

**Ceiling, named before data.** The selftests prove the gates fail on their committed fixture
classes; they do not prove the gates cover every false-clean class (F4/F5 are counter-covered,
F7/D4 are named ceilings), and a registry row is a declaration, not a scheduling mechanism:
nothing runs any gate on a schedule.

## Routed, not claimed

- S012 rendered-text locate failure (census class, recorded): not claimed.
- R37-V2 release-clock re-point (15 fired clocks; the round-38 DERIVATION measurement stands):
  not claimed.
- R38-03 POLICY (operator-owned `PYTHON_SCRIPT_RE` registration; L0 `kagi | round-38` open):
  untouched.
- R38-D4's surviving quote/guard mutants (M2, M3, M5, M6, G3) with their round-38 red
  witnesses: not claimed this round; the round-38 instruments are not amended.
- The six new W04 duplicate-URL warnings the two new rows add (S095/S096 share URLs with
  S040/S041 across scopes, the round-37 precedent): warnings, not findings; recorded in the
  census receipts.

## Frontier step (§2b)

- Census before (START, this round): fleet
  `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
  → exit 0, `kagi ok` (19 W04 duplicate-URL warnings); lane `bash corpus/sources-census.sh` →
  `SOURCES_CENSUS: CLEAN (rows=94 A=90 B=2 C=2 queued=1 mined=90 rejected=3 entries_sourced=14
  legacy=21 captures=94 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0. Receipts:
  `.ufo/waves/round-40/census/start-fleet.txt`, `start-lane.txt`.
- Census after: recorded at the landing revision; expected rows=96 A=92 captures=96
  (S095, S096), `entries_sourced` unchanged at 14.
- Rows added: S095, S096 (both tier A, docs, opened 2026-11-05). Rows touched old→new: none
  (S040/S041 are not edited; S036's anchor is pinned, its cells unchanged).
- Mistakes mined into `corpus/lessons/round-40.md` `## Mistakes`: M40-1 (S094 teaches cell
  mixed the verbatim quote with a derived clause; the lesson said "9 words" where the whitespace
  count is 8; captured-by `none`; fixed by QM42 + the S095/S096 rows applying it; the S094 cell
  is append-only and is not edited). M40-2 (fresh-start re-measurement: every BASE population
  measured and committed before the freeze, the r33 "BASE never measured" class; captured-by the
  r33 spotcheck; fix re-applied with the committed receipts).
- Assimilation: none (the eight `kagi` rows of the absent-defect register remain quarantined;
  no `merge/kagi/` theme is taken this round).
- considerthese: no proposal taken this round; not claimed.

## Wave

One v1 wave of 10 seats (band 8–16; L2 floor 8): executor ×3 (K40ExecLedger, K40ExecCurrency,
K40ExecGates), scribe ×1 (K40ScribeLesson), scout ×1 (K40ScoutDocs), connector ×1
(K40ConnOverlap), reviewer ×2 (K40ReviewLedger, K40ReviewGates), critic ×1 (K40CriticClaims),
mutation-tester ×1 (K40MutGates). Attack seats = reviewer 2 + critic 1 + mutation-tester 1 =
4/10 = 40 % (≥25 %); connector 1 (≤2). The canonical planner seat is held by the L1 (the
validator rejects `planner`; the same recorded deviation as rounds 33, 37, 38, 39). Every seat
writes only under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-40/build/<seat>/`.
