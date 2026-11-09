# Round 69 — kagi (secrets & vault ops)

Lane: kagi. Round 69, attempt 3 (integration). Claim BASE `264917aa8fc9e71b6595d0d5166c4b615120fb8b`
(round-68 verifier spot-check tip). Predeclaration `plans/round-69.md` (frozen,
landed `adb6972668d176768a0f1d9ffecd25d32f1070f0`; attempt 1 died on a provider 429
before dispatch and its plan stands unchanged). Wave `kagi-r69-w1`, 16 seats,
dispatched by attempt 2 (`KagiR69a2`); attempt 2 and the wave's settlement died
with the orchestrator session (SIGTERM), and attempt 3 (`KagiR69a3`) integrates
the seats' report files and uncommitted tree edits without re-dispatching.

The seat-written sections below were drafted mid-wave; the `## Claims` readings
and the expansion line are the L1's integration readings (attempt 3).

## Claims

- **C1 calibration — `C1_RECORD: mismatches=0 population=13 guard=1`** (plan §C1).
  BASE extraction reading (frozen counter `plans/round-69-c1.sh`, attempt 3):
  `C1_RECORD: mismatches=13 population=13 guard=0`, every leg printing its
  mismatch detail (guard (c) holds). Landed-tree reading:
  `C1_RECORD: mismatches=1 population=13 guard=0`, rc 1 — L1–L11 and L13 pass;
  **L12 fails**: the plan's `.ufo/waves/round-69/w1-results.json` is absent and the
  driver's settlement `.ufo/waves/round-69/kagi-r69-w1-results.json` lists all 16
  seats with `output: null` (orchestrator kernel restart), which the counter
  rightly refuses as unsettled. guard (b) therefore reads 0. **Target missed —
  honest stop** (`plans/round-69.md` §"Honest stop (attempt 3)"). Receipt:
  `.ufo/waves/round-69/final/c1-candidate.txt`, `.ufo/waves/round-69/final/c1-base.txt`.
- **C2 operability — `C2_TEETH: subfloor=1 ledger=1 guard=1`** (plan §C2).
  BASE: `subfloor=0 ledger=0`. Landed-tree reading:
  `C2_TEETH: subfloor=0 ledger=0 guard=0`, rc 1 (`.ufo/waves/round-69/final/c2-candidate.txt`).
  subfloor (b) reads 0 because the repair adds three cases (59 → 62, M69-7) where the
  frozen leg demands `N_base + 1`; ledger (a) and (b) read 0 because the gate's
  policy refuses the frozen `true` negative (rc 2 POLICY, not FAIL) and a one-row
  ledger is not CLEAN on the unscoped docs set (M69-6; R69Critic F-C2-1/F-C2-2,
  R69ReviewerLedger). **Target missed — honest stop.** The predicate floor repair
  itself landed and is measured by C1 leg L8 (six vectors executed).

## Gate

One source pair opened this round by hand (curl, browser user agent, access date
2026-11-08). Captures are the registry seat's committed bytes at
`.ufo/waves/round-69/capture/S168.body` and `.ufo/waves/round-69/capture/S169.body`;
my own fetch (scratch) reproduces both sha256 values. Receipt:
`.ufo/waves/round-69/w1/R69ScribeLesson/gate-quotes.txt`.

| row | URL | access date | located quote (≤25 words) | decision | reason / flip | evidence |
|---|---|---|---|---|---|---|
| S168 | https://www.rfc-editor.org/rfc/rfc9162.txt | 2026-11-08 | "Merkle consistency proofs prove the append-only property of the tree." (§2.1.4, 10 words; locate count=1) | admit, tier A, kind spec | RFC 9162 §2.1.4 is the normative statement that the append-only property of a Merkle log is proved by a consistency proof between two tree heads; it grounds the supersession rule (a later record state must be an append-only extension of the earlier one, and the earlier bytes remain checkable). Transposition to lane records is the lane's own: the RFC is about certificate logs. Flip: none on this quote; the certificate-specific sentences (§1 "issued certificates", §4 "submitted certificate", §11.3 rate limits) do not transpose and are not cited. | `.ufo/waves/round-69/capture/S168.body` (128266 B, sha256 `a0e432ce7580c99fcc8faf0cf3f6191f9ce6b4864f949158e020d4ecb295081f`) |
| S169 | https://en.wikipedia.org/wiki/Merkle_tree | 2026-11-08 | "a hash tree or Merkle tree is a tree in which every "leaf" node is labelled with the cryptographic hash of a data block" (24 words; locate count=1) | reject, tier C, kind docs | A tertiary summary: it defines the data structure and states no append-only property, no consistency-proof obligation and no normative keyword (measured on the rendered text: `append-only` 0, `consistency proof` 0, `MUST` 0). It cannot ground a supersession rule. Flip: cite the RFC it summarises (S168), which states the mechanism. | `.ufo/waves/round-69/capture/S169.body` (209875 B, sha256 `ad8de3b95bd73e8bb93ac1bb37fb17f0c050e53660a1f5619dba1136bd36a27c`) |

Recorded caveat, not an action: the Wikipedia revision permalink (`oldid`) fetches
to a different body (213195 B) from `/wiki/Merkle_tree`; a row that pins a
revision must pin its own body digest. Not pinned here.

## In-place registry changes

Two rows appended (no existing row's `status`, `recheck` or `used-by` changed —
`git diff corpus/SOURCES.md` adds lines only):

- S168: (absent) → `mined`, tier A, recheck `180d`, used-by
  `corpus/knowledge/record-supersession.md`; fetch row `mined` in
  `corpus/source-fetches.tsv`.
- S169: (absent) → `rejected`, tier C; fetch row `rejected`; flip: cite S168.

## Mistakes

- **M69-1 — a repair that leaves the fabricated sentence as the only citable line.**
  class: landing (record). evidence: `.ufo/waves/round-69/w1/R69ScribeLesson/erratum-check.txt`
  and the Correction (round 69) block appended to `corpus/lessons/round-68.md`.
  captured-by: QM97 as routed in `corpus/lessons/round-68-verifier-spotcheck.md`
  §7 item 11; not yet landed in `corpus/QUALITY.md` at measurement. fix: the
  append-only correction quotes the superseded sentence verbatim and names the
  receipt (`c2-lane-run.txt:6`) that replaces it; the original bytes are not rewritten.
- **M69-2 — frozen floors stated only in the plan.** class: vacuous (instrument).
  evidence: BASE `predicate_ok` extracted and executed from
  `264917aa:plans/round-68-c1.sh` returns True for `(36,31,6,1,0)` (receipt
  `.ufo/waves/round-69/w1/R69ScribeLesson/base-13-legs.txt`, line D8). captured-by:
  QM98 as routed; not landed. fix: the predicate compares both floors and the
  selftest carries `predicate-subfloor`; the candidate has both, measured in
  R69ExecPredicate's receipts.
- **M69-3 — a ledger row whose expectation the tree never printed.** class:
  landing (ledger). evidence: BASE `corpus/claim-ledger.tsv` row `R68-02`
  expects `^C2_RECORD: mismatches=0 population=3 guard=1$`; the only BASE run of
  its command is `.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt:6`, which
  prints no such line. captured-by: QM99 as routed; not landed. fix: the row is
  repointed to a line the candidate counter prints, through a journaled migration
  (`.ufo/waves/round-69/journals/expectation-migrations.json`, `old_expect` present).
- **M69-4 — expansion credited for widening an existing entry.** class: scope
  (trend). evidence: round-68 spot-check §6 (`expansion — unchanged`, widening of
  `corpus/knowledge/source-capture-binding.md`); the knowledge count is 48 at BASE and
  at measurement (`.ufo/waves/round-69/w1/R69ScribeLesson/expansion-count.txt`).
  captured-by: QM100 as routed; not landed. fix: `expansion` moves only on a new
  admitted entry; the line below derives it.
- **M69-5 (new, measured) — a selftest receipt that does not reproduce from its own blob.**
  class: receipt-integrity. evidence: `.ufo/waves/round-68/w1/R68ExecCounterC1/selftest.txt:13`
  reads `C1_VERIFIED_SELFTEST: PASS (56 cases)`; re-running the committed
  `plans/round-68-c1.sh` (blob `a907fc2a`, identical at `264917aa`, `ef90e98`,
  `0bddda6`, `8342062`) prints `PASS (59 cases)`; the other twelve receipt lines
  match the re-run (`.ufo/waves/round-69/w1/R69ScribeLesson/base-c1-selftest-rerun.txt`).
  The literal `case("…")` call sites number 56, which matches the receipt's count,
  while the run executes 59 cases, so the receipt was not produced by the script
  bytes it sits beside. captured-by: none on the record; QM45 requires a committed
  re-run of a BASE reading, which this receipt lacked. fix: the C2 counter derives
  its BASE count by running the BASE copy (measured: 59); the round-68 receipt is
  routed to the L1 for correction under the append-only rule, not edited here.
- **M69-6 (new, measured) — a kill rule the gate cannot meet as written.**
  class: vacuous (predicate). evidence (`.ufo/waves/round-69/w1/R69ScribeLesson/c2-mid-wave-readings.txt`,
  candidate verbose run): the ledger leg (a) reads
  `verify-reduced: FAIL R68-02 reason=exit-mismatch exit=127 want=0`, because the row's
  command `bash plans/round-69-c1.sh --tree . --legs L1,L3` names a counter that is not
  yet in the tree. The `stale=5` in the same run is not a ledger defect: it names the
  uncommitted seat edits to `corpus/lessons/round-68.md`, `LOG.md`,
  `plans/round-68-c1.sh`, `plans/round-68.md` and `SCORECARD.md`, whose stamps still
  pin committed bytes. The ledger leg (b) negative (`true` as the command) reads
  `verify-true: POLICY R68-02 reason=first-token:true` and
  `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` (rc 2), so the gate's
  allowlist refuses the frozen witness shape; a `FAIL R68-02` line cannot be produced
  by that negative. captured-by: QM87 (satisfiable direction). fix: routed to the L1 as
  a predicate-satisfiability finding (the `true` negative, and whether the row may
  name a counter that lands later); the frozen text is not amended here.
- **M69-7 (new, measured) — a case count the frozen leg does not allow.**
  class: scope (plan–spec conflict). evidence: the candidate `plans/round-68-c1.sh`
  adds three cases after `predicate-defect` (`predicate-subfloor`,
  `predicate-floor-edge`, `predicate-floor-col15`), so `C1_VERIFIED_SELFTEST: PASS (62 cases)`
  against BASE `59`; plan §C2 leg (b) requires `N_cand = N_base + 1`. With only
  `predicate-subfloor` kept the same counter reads `subfloor=1` on the same copy
  (receipt `.ufo/waves/round-69/w1/R69ScribeLesson/c2-mid-wave-readings.txt`: the
  lane-tip reading with three cases reads `tree_cases=62`; the scratch copy with only
  `predicate-subfloor` kept reads `tree_cases=60` and `subfloor=1`). captured-by: QM87 for the leg's direction; the seat
  spec's "three named cases" line was not reconciled with the leg. fix: route to the
  L1 (R69ExecPredicate has flagged it); the plan is not amended.
- **M69-8 (new, measured) — dead citations in the closure lesson.** class: landing
  (citation). evidence: the BASE `corpus/lessons/round-68-verifier-spotcheck.md` is
  read UNRESOLVED on the dead path `.ufo/waves/round-68/final/c1-base.txt` (no longer present; lines 58, 346) and on
  two absolute host paths (lines 202, 290). The lane's own
  `bash corpus/claim-ledger.sh citations` on the BASE extraction reads
  `CITATION_GATE: BROKEN (cites=5369 docs=175 unresolved=19 ephemeral=1 labeled=41)`;
  on the lane tip at this reading it reads `unresolved=32`
  (`.ufo/waves/round-69/w1/R69ScribeLesson/citations-lane-full.txt`). The 13-token
  difference is not attributed here. captured-by: the citations gate exists and is
  not run on landing. fix: routed; this seat did not edit that lesson (its scope is
  `corpus/lessons/round-68.md` append-only and this file).
- **M69-9 (new, measured, attempt 3) — a frozen leg bound to a file name the driver
  does not write.** class: scope (plan–driver contract). evidence: plan §C1 L12 and
  the counter's `RESULTS_REL` name `.ufo/waves/round-69/w1-results.json`; the driver
  wrote `.ufo/waves/round-69/kagi-r69-w1-results.json` (wave name `kagi-r69-w1`), and
  after the orchestrator kill every entry carries `output: null`. L12 reads
  `fail results-absent` on the landed tree (`.ufo/waves/round-69/final/c1-candidate.txt`).
  Even under the driver's name the leg would fail, because no seat output was
  retained — the leg measured a property the lane cannot produce honestly once the
  settlement is lost (the L1 must not synthesise the driver's file). captured-by:
  none. fix: a settlement leg reads `<wave>-results.json` from the `.ready` file's
  `wave` field (derived, never hard-coded) and counts a seat as settled on either a
  retained output or a committed seat report carrying `SEAT-STATUS:`; routed to the
  next round's counter, not amended here (the counter is scored).
- **M69-10 (new, measured, attempt 3) — three frozen legs the instrument cannot
  satisfy, found by the round's own attack seats after the freeze.** class: vacuous
  (predicate satisfiability). evidence: `.ufo/waves/round-69/w1/R69Critic.md`
  F-C2-1 (`true` refused by policy, rc 2), F-C2-2 (one-row ledger FAIL unscoped),
  F-C2-4 (N 59 → 62, not +1); `.ufo/waves/round-69/w1/R69ReviewerLedger.md` (H falsified).
  captured-by: the §9 prefreeze control rule — the plan froze controls it never ran
  against the existing gate (`corpus/claim-ledger.sh` policy allowlist). fix: before
  freezing a leg that drives an existing gate, run the leg's negative through that
  gate once and commit the rc and line (shown able to fail: the `true` run itself
  is that receipt, `.ufo/waves/round-69/w1/R69Critic/ledger1-true.out`).

## Frontier & census

- Round-start census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` read `kagi ok` with exit `0` (`.ufo/waves/round-69/base/census-round-start.txt`). Re-run at mid-wave on the lane tree: `kagi ok`, `EXIT=0`.
- New knowledge entry: `corpus/knowledge/record-supersession.md` (S168-grounded; README
  index row and `## Frontier` bullet "Record supersession — entered in round69").
- expansion: new knowledge entries=1 (derived at integration: 49 files under `corpus/knowledge/` in the landed tree minus 48 at `264917aa`; C1 leg L13 reads `stated=1 here=49 base=48 want=1`). Whether the entry holds new coverage-map ground is the closure's to judge (R69Critic F-C1-5: a file count is not new ground).
- Round-end census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, exit 0 (`.ufo/waves/round-69/final/census-round-end.txt`).

## L1 erratum

The round-68 report (fleet-side, `.ufo/reports/round-68/kagi.md:106`) cites a receipt
that exists in no commit. The dead path, measured absent from every commit and from
the tree, is:

`.ufo/waves/round-68/final/c1-base.txt` (no longer present; cited by the round-68 report and the round-68 spot-check)

Corrected pointer, which exists and carries the BASE reading
`C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0`:

`.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt`

The correction is recorded here and not by editing the fleet-side report. Receipt:
`.ufo/waves/round-69/w1/R69ScribeLesson/erratum-check.txt`.
