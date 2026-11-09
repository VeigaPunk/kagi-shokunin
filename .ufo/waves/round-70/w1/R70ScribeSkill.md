Author: R70ScribeSkill (scribe — skill text draft for the L1 to integrate)

# R70ScribeSkill — lane-facing draft for the round-70 OpenBao PKI capability

**Seat role.** Draft the lane-facing text for the new capability. The L1 (`KagiR70`) integrates;
this seat lands nothing outside its own directory. Deliverable:
`.ufo/waves/round-70/w1/R70ScribeSkill/skill-draft.md`.

**Verdict.** The draft is complete: four surfaces drafted (PROVINCE.md Core line, SKILL.md
vault-ops decision-table rows, corpus/README.md coverage-map line, SCORECARD.md capabilities-table
row), every sentence traced to the entry's §Measured section, plus integration notes for the L1
that are measured rather than asserted.

## What was drafted

1. **PROVINCE.md** — one `**Core, round 70 — OpenBao PKI certificate lifecycle, executed:**`
   bullet, in the style of the round-48/49/51/57 bullets, inserted after the round-57 bullet in
   the `## Core / Frontier / Adjacent (round 21)` list. It carries the trial path, the pinned
   OpenBao 2.7.2 binary, the dev-server scope (127.0.0.1, in-memory storage, random root token in
   scratch, synthetic names under `r70.test`), what T1–T5 measure, the per-shim flip, and the
   refusal (no deployed CA, real certificate, HSM/KMS key or ACME client).
2. **SKILL.md** — four rows for the `## Vault-ops decision table` (four columns: `Intent |
   Correct surface | Never | Notes / expected output`), one per custody decision the entry
   measures: internal vs exported CA key; role `max_ttl` clamp-not-refuse; `allowed_domains` vs
   `allow_any_name`; `no_store` vs serial revocability (T5 + T4). Each cites
   `corpus/knowledge/openbao-pki-certificate-lifecycle.md` §Measured.
3. **corpus/README.md** — one `## Coverage map` row in the shape of the neighbouring OpenBao
   (executed) rows.
4. **SCORECARD.md** — one `## Capabilities` row in the shape of the round-57/58/59/60/61 OpenBao
   trial rows, first-working round **70**, with the counter verdict and the BASE reading as the
   evidence pointer.

## Evidence discipline

Every sentence in the four drafts is supported by
`corpus/knowledge/openbao-pki-certificate-lifecycle.md` §Measured (round 70 — OpenBao 2.7.2 dev
server, 127.0.0.1, one pki mount) or by the frozen counter `plans/round-70-c1.sh` (sha256
`8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed`, matching the committed
`.ufo/waves/round-70/controls/receipts/counter.sha256`). Three deliberate exclusions, each
recorded in the draft:

- The **operator consequence** of the T2 clamp (a caller that reads only the exit status cannot
  tell it was clamped) is not in §Measured — the entry itself marks it `[INFERENCE]` — so it is
  **not** in the SKILL.md row.
- The **"any relying party honours the CRL"** claim is excluded by the entry's §Does-not-establish
  bullet; the T4/T5 row says only what was measured (the serial is on the mount's published CRL).
- The **`allowed_domains` matching scope** is stated as "one exact domain with subdomains only",
  because that is the scope of the measurement.

Two clauses in the drafted PROVINCE.md line (127.0.0.1 / in-memory storage / random root token in
scratch / synthetic names under `r70.test`, and the no-deployed-CA refusal) come from the entry's
§Scope rather than §Measured; the draft says so explicitly and does not restate them as
measurements. The binary sha256 digest is **not** in the draft's PROVINCE.md line — it belongs to
the counter's `PIN_BAO`, not to the entry, so a draft that cited it under the entry would be
misattributed; the draft notes this.

## Measured integration notes for the L1 (from `skill-draft.md` §5)

All measured by this seat, read-only, in scratch copies of the lane tree.

- **The two new files have no stamp rows on the working tree.** `bash corpus/claim-ledger.sh docs`
  reads `DOC_AUDIT: BROKEN (entries=50 row_linked=47 by_hand=3 undeclared=0 missing_ids=0
  unpinned=1 duplicate_reasons=0 floor=25)` — `UNPINNED
  corpus/knowledge/openbao-pki-certificate-lifecycle.md (knowledge entry is not a row in the
  stamps file)`. At BASE (`7bd34832`, `git archive` extraction) the same gate reads `DOC_AUDIT:
  CLEAN (entries=49 row_linked=46 by_hand=3 undeclared=0 missing_ids=0 unpinned=0
  duplicate_reasons=0 floor=25)`, so this is **introduced by the candidate**, not inherited. Adding
  the two rows (`corpus/knowledge/openbao-pki-certificate-lifecycle.md`,
  `corpus/openbao-pki-trial.sh`) to `corpus/stamps.tsv` restores `DOC_AUDIT: CLEAN` in a scratch
  copy. The sibling trials `corpus/openbao-audit-trial.sh` and `corpus/openbao-policy-trial.sh`
  both have stamp rows; the PKI trial has none.
- **The stamp count is a bound number, so adding rows makes three current-tense sentences
  stale.** `corpus/self-counts.tsv` binds `RD-STAMPS` to the README's `| Revision stamps (data) |`
  row (**173 rows** today) and `SC-SKILL-STAMPS` / `PV-STAMPS` to the SKILL.md and PROVINCE.md
  **`164`** figures. Measured: one new stamp row ⇒ live 174 (`STALE RD-STAMPS … claimed=173
  live=174`), two ⇒ live 175 (`claimed=173 live=175`). The `164` pair is **already** stale at BASE
  (measured on a `git archive` extraction of `7bd34832`: `STALE SC-SKILL-STAMPS SKILL.md:46
  claimed=164 live=173` and the same for `PV-STAMPS`), so it is inherited debt; the README `173`
  figure is current at BASE and goes stale **only** if the L1 adds stamp rows. The L1 must decide
  and journal (QUALITY QM14) rather than let the number drift.
- **The README knowledge-entry counts line up once the stamps land.** The working tree's README
  already says 47 row-linked / 3 by-hand / 50 pinned; with the two stamp rows present, a scratch
  tree reads `OK RD-DOCS-ROWLINKED … claimed=47 live=47`, `OK RD-DOCS-BYHAND … claimed=3 live=3`,
  `OK RD-DOCS-ENTRIES … claimed=50 live=50`. Without the stamps the same three read `SETUP`
  (`ledger:R14-01 exit=1`) because the docs gate is red.
- **`corpus/claims-declared.sh` needs the manifest row and the plan heading together.** With the
  working tree's `corpus/claims-declared.tsv` row `70 C1 coverage` but the frozen plan's heading
  spelled `## Claim C1 — coverage (capability acquisition): …`, a scratch tree reads `MISMATCH 70
  C1 plan-heading-not-coverage` — the contract's heading form is `## <claim> — <axis>:` and the
  word "Claim" before `C1` breaks the match. The working tree's plan Amendment A2 supplies that
  heading; with both in place the gate reads only the two inherited round-69 mismatches
  (`MISMATCH 69 C1 tagged-rows-0`, `MISMATCH 69 C2 tagged-rows-0`), which are also present at BASE
  (`CLAIMS_DECLARED: MISMATCH (claims=65 mismatch=2)` at `7bd34832`).
- **The `## Round 70 — post-move` SCORECARD row needs the tag `[C1]` and `coverage` as its first
  cell.** The declared-axis gate's post-move leg counts rows carrying the literal `[C1]` inside
  `## Round 70 — post-move` and compares that row's first cell to the manifest axis. The
  round-69 rows are tagged `[C1, missed]` / `[C2, missed]`, which is why the gate reports
  `tagged-rows-0` for round 69 at BASE — a spelling the round-70 rows must not copy.
- **The self-description sweep's SD5 and SD8 counts are inherited; SD6 is not comparable across
  the two trees.** The live tree reads `SELF_DESCRIPTION: MISMATCH n=42 (SD1=0 SD2=0 SD3=0
  SD4=0 SD5=4 SD6=37 SD7=0 SD8=1 SD9=0)`. A `git archive` extraction of BASE reads `n=312 (SD5=4
  SD6=307 SD8=1)`, but SD6 is **not** a like-for-like comparison: SD6 counts the `UNRESOLVED`
  lines of `claim-ledger.sh citations`, and an archive extraction carries none of the untracked
  `.ufo/waves/round-6x/` artifacts, so its citation population is a different set (BASE's 307
  break down as 274 `ufo`, 27 `sibling`, 5 `local`, 1 `shorthand`). What **is** comparable: SD5's
  four red ids (`R25-02`, `R29-01`, `R29-02`, `R38-03`) and SD8's `SCORECARD.md:1701` range
  `'M44-1..M44-3'` row are the same four/one at BASE and on the live tree — both inherited. One
  live-tree SD6 line does name a round-70 path: `.ufo/waves/round-70/capture/S17x.body` — a
  **placeholder** in the round-70 lesson (the committed captures are `S170.body`, `S171.body`,
  `S172.body`), so it resolves to nothing. That is a lane-text defect the L1 owns, not a gate
  regression.
- **Every other round-70 citation resolves on the live tree; one pointer does not.** `bash
  corpus/claim-ledger.sh citations` on the live tree reads `CITATION_GATE: BROKEN (cites=5542
  docs=180 unresolved=36 ephemeral=1 labeled=26)` and **no** `UNRESOLVED` line names a round-70
  path — the entry's `.ufo/waves/round-70/final/l1-probe-observations.txt`, the lesson's
  `.ufo/waves/round-70/final/c1-candidate.txt`, `.ufo/waves/round-70/w1/R70Connector.md`,
  `.ufo/waves/round-70/w1/R70Scout/frontier.md` and the two
  `.ufo/waves/round-70/w1/R70ScribeLesson/check-*.py` scripts all exist on disk and resolve. The
  36 unresolved lines are the lane's inherited set (a scratch-tree run reports far more only
  because a `git archive` extraction carries none of the untracked wave artifacts — an artefact of
  the measurement, not of lane state). The one exception is in the L1's hands: the round-70
  **SCORECARD capability row** cites `.ufo/waves/round-70/final/` as a *directory*, and the
  citations gate reads that token as `UNRESOLVED` — the pointer must name a **file**
  (`.ufo/waves/round-70/final/c1-candidate.txt`), not the directory.
- **The L1's working-tree edits leave seven stamp rows STALE.** `bash corpus/claim-ledger.sh
  verify` on the live tree reads `STALE corpus/QUALITY.md sha=497a67ec2cdc->b823b5f2d9f3
  lines=338->339 bytes=82317->83506` and the same for `corpus/README.md`,
  `corpus/source-fetches.tsv`, `corpus/SOURCES.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`.
  Measured attribution: for all seven the stamp's digest equals the **BASE** blob's digest
  (`git show 7bd34832:<path>`), so the stamps were last pinned at BASE and every edit since —
  the candidate's three rows each in `corpus/SOURCES.md` and `corpus/source-fetches.tsv`, plus the
  L1's working-tree edits to `PROVINCE.md`, `SCORECARD.md`, `corpus/README.md`,
  `corpus/QUALITY.md`, `LOG.md` — leaves the row stale. A reviewed re-pin
  `bash corpus/claim-ledger.sh stamp <paths>`) at landing is what the lane's own QUALITY QM5
  requires ("a pin that lags the artifact's bytes is a defect, not inherited debt"). Attribution,
  measured by running `verify` on a `git archive` extraction of the candidate (`0d225553`): the
  **candidate commit itself** leaves two stamp rows stale —
  `STALE corpus/source-fetches.tsv sha=d5af7ba9e9d7->5d0516e9e2ab lines=203->206` and
  `STALE corpus/SOURCES.md sha=9ca0ffaa3ad0->34d37d9085ed lines=322->325` — because it added three
  rows to each without re-pinning; the live tree's other five (`corpus/QUALITY.md`,
  `corpus/README.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`) are stale because of the **L1's
  working-tree edits**, not the candidate.
- **`corpus/claim-ledger.sh verify` reads FAIL rows, and only one of them changes reason because
  of this round.** Measured on the live tree: `FAIL R11-08 reason=exit-mismatch exit=1 want=0`
  (the citations gate, whose `unresolved=0` expectation the lane does not meet), `FAIL R12-03
  reason=verdict-not-final exit=0` (the stamps-count row still expects `^125$` against a live 173),
  `FAIL R13-01 reason=verdict-not-final exit=0` (the round-heading cardinality row still expects
  `^73$`), and `FAIL R14-01 reason=exit-mismatch exit=1 want=0` (the docs gate — the unpinned entry
  above). At BASE the same rows already read FAIL: `R11-08 exit-mismatch`, `R12-03
  verdict-not-final`, `R13-01 verdict-not-final`, and `R14-01 reason=verdict-not-final exit=0`
  (the docs gate was CLEAN at BASE but its *expectation* — `DOC_AUDIT: CLEAN (entries=38
  row_linked=35 …)` — no longer matches the live `entries=49 row_linked=46`). So **R14-01 was
  already red at BASE**; what this round changes is its **reason** — from a stale expectation
  (`verdict-not-final`) to a broken gate (`exit-mismatch`, exit 1) — and the fix is the same
  reviewed re-pin the stale expectation needs plus the two new stamp rows. The other FAIL rows
  (R21-02, R22-03, R24-05, R24-06, R24-15, R25-02, R31-02, R33-02, R34-03 and the rest) are
  present at BASE too; the QM12 substitute applies to the host-touching rows.
- **The `claim-ledger.sh cells` gate is red at BASE too and the round-70 section adds nothing to
  it.** The live tree exits 2 with `claim-ledger: scorecard section '## Round 69 — pre-move (repo
  `264917a`, round-68 spot-check tip)' does not carry all six axes exactly once (found=0
  missing=depth coverage operability freshness calibration adjacency)` plus a set of `UNCITED
  SCORECARD.md:<line>` rows. A BASE extraction reads the **same** messages: normalising away the
  line numbers, the two runs are identical (32 operability, 24 calibration, 22 freshness, 22
  adjacency, 14 depth, 4 coverage UNCITED rows, and the same round-69 pre-move section error), and
  no message in the live run names a round-70 section or row. So the cells gate carries no
  round-70-specific message; its redness is inherited debt about the round-69 pre-move section.

## Drafts that the L1 has already written independently

The working tree already carries L1 drafts of three of the four surfaces (`PROVINCE.md` +1
bullet, `corpus/README.md` coverage row + knowledge-entry counts 47/3/50, `SCORECARD.md` +1
capability row + a `## Round 70 — pre-move` / `## Round 70 — post-move` section, and
`corpus/claims-declared.tsv` +`70 C1 coverage`). This seat's drafts are the independent
lane-facing text for the same surfaces; they are **not** a second edit to apply on top. The
L1's versions and this seat's were compared clause by clause and agree on every measured fact
(the T1–T5 wording, the ≤ 3660 s bound, the `r70.test` synthetic-name scope, the counter verdict
string, the BASE reading, first-working round 70). They differ in phrasing only, and this seat's
draft carries two clauses the L1's does not: the entry-path citation on each SKILL.md row and the
explicit `[INFERENCE]`-marked exclusions. The L1 picks.

## Falsifiers for this seat's draft (each would make it wrong)

1. The entry's §Measured section changes so that a drafted clause no longer matches — then the
   clause is withdrawn, not reworded.
2. `bash corpus/claim-ledger.sh docs` reads `DOC_AUDIT: CLEAN` at the landing revision without
   stamp rows for the two new files — then the "no stamp rows" integration note is void (the gate
   would have to be satisfied another way).
3. A counter run on the landed revision returns `value < 5` — then the "first-working round 70"
   capability row is void; it enters only through demonstrated execution.
4. `bash corpus/claims-declared.sh --root .` reads a new mismatch beyond the two inherited
   round-69 rows once the manifest row and the A2 heading are both present — then the drafted
   heading form is wrong and the L1's is right.

## Provenance and hygiene

- Read (absolute paths, from the fleet root): `plans/round-70.md`, `plans/round-70-c1.sh`,
  `plans/round-70-controls.sh`, `.ufo/waves/round-70/controls/receipts/{README.txt,
  counter.sha256, f0-base.txt, p1.txt}`, `corpus/openbao-pki-trial.sh`,
  `corpus/knowledge/openbao-pki-certificate-lifecycle.md`, `corpus/QUALITY.md`,
  `corpus/SOURCES.md` rows S170–S172, `corpus/source-fetches.tsv`, `corpus/lessons/round-70.md`,
  `SKILL.md`, `PROVINCE.md`, `SCORECARD.md`, `corpus/README.md`, `corpus/self-counts.tsv`,
  `corpus/claims-declared.tsv`, `corpus/claim-ledger.tsv`, `corpus/stamps.tsv`,
  `corpus/claims-declared.sh`, `corpus/claim-ledger.sh`, `corpus/self-counts.py`,
  `corpus/self-description-sweep.sh`.
- Measured by this seat (read-only; no mutating git or jj in the lane or the fleet repo; the only
  git calls were `log`, `show`, `archive`, `ls-files`, `status`):
  `bash corpus/claim-ledger.sh docs` on the live tree and on a `git archive` extraction of
  `7bd34832`; `bash corpus/claim-ledger.sh verify` on the live tree and on `git archive`
  extractions of `7bd34832` and `0d225553`; `bash corpus/claim-ledger.sh cells` on the live tree
  and on a `git archive` extraction of `7bd34832`; `bash corpus/claim-ledger.sh citations` on the
  live tree and on a scratch tree; `python3 corpus/self-counts.py` on the live tree, on a `git
  archive` extraction of `7bd34832`, and on four scratch trees (candidate + working-tree
  overlays, with and without the two stamp rows, and with the entry-only stamp row);
  `bash corpus/claims-declared.sh --root .` on the live tree and on scratch extractions of
  `7bd34832` and `0d225553` with and without a `70 C1 coverage` manifest row;
  `bash corpus/self-description-sweep.sh --root .` on the live tree and on a `git archive`
  extraction of `7bd34832`; `bash corpus/sources-census.sh` (live tree) ⇒ `SOURCES_CENSUS: CLEAN
  (rows=163 A=145 B=2 C=16 queued=3 mined=141 rejected=19 entries_sourced=29 legacy=21
  captures=163 inrow=16 inrow_only=0 inrow_nonreproducing=12)`; `sha256sum` of
  `plans/round-70-c1.sh` (matches the committed `counter.sha256`) and of the candidate's
  `corpus/openbao-pki-trial.sh` (identical to the P1 positive control's copy,
  `200efcb2850df8e729631de1772f4423ef0ac90a8bb1b9a06e4fc499bdc8023d`).
  The lane's own gate readings quoted above were **not** re-derived by a fresh counter run: the
  frozen counter was not re-run by this seat (its receipts and the candidate reading already
  exist, and the plan forbids re-interpreting them), so the `value=5` / `value=0 absent=1` figures
  in this report are the **committed receipts'** readings, cited to their paths.
- **Files written by this seat** (write scope: own report file + own directory only):
  `.ufo/waves/round-70/w1/R70ScribeSkill.md` (this file) and
  `.ufo/waves/round-70/w1/R70ScribeSkill/skill-draft.md`, plus copies of the four cited receipts
  under `.ufo/waves/round-70/w1/R70ScribeSkill/receipts/`. Nothing else in the lane, the fleet
  repo, a sibling lane or `~/.omp` was written.
- **Scratch**: `/fast/scratch/hyaku/kagi-r70/R70ScribeSkill` (scratch trees, removed on exit).
  No `bao server -dev` was started by this seat (no run was needed: the counter's own receipts
  carry the candidate reading), so no server had to be killed. No CPU burner or load generator was
  started. No host sysctl, `/boot`, systemd unit or other out-of-scratch path was touched. No tool
  was installed or upgraded by this seat, so no tool/version/channel/reason record is owed.
- No secret, vault, `op` item, `~/.vault-token`, `~/.ssh` or credential file was read or printed;
  the only token-shaped strings in evidence are the dev-server root tokens the prefreeze control
  receipts already mask as `r70-<redacted-dead-dev-token>`.

## Out of scope for this seat

The C1 counter, the trial, the entry wording, the plan amendments, the manifest row, the SCORECARD
post-move section and the lesson are the L1's and the attack seats' surfaces; this seat did not
edit them. The counter was not re-run (its frozen receipts and the candidate reading already
exist, and the plan forbids re-interpreting them).



FINDING SS-1 neutral the knowledge entry and the new trial have no rows in corpus/stamps.tsv, so `claim-ledger.sh docs` reads DOC_AUDIT: BROKEN unpinned=1 on the working tree while it reads CLEAN at BASE 7bd34832
FINDING SS-2 neutral adding one or two stamp rows moves the live stamp count to 174 or 175 and makes the README's bound "Revision stamps (data) 173 rows" sentence STALE, so the L1 must re-pin it through a journal
FINDING SS-3 neutral the SKILL.md and PROVINCE.md "164 stamps" figures are already stale against the live 173 at BASE, so that gap is inherited debt and not a round-70 move
FINDING SS-4 neutral corpus/claims-declared.sh reads "MISMATCH 70 C1 plan-heading-not-coverage" unless the plan carries the contract's "## C1 — coverage:" heading form alongside the manifest row, and the working tree's Amendment A2 supplies it
FINDING SS-5 neutral the round-70 SCORECARD post-move row must be tagged [C1] with coverage as its first cell; the round-69 spelling "[C1, missed]" is what makes the gate report tagged-rows-0 at BASE
FINDING SS-6 neutral the self-description sweep's SD5 and SD8 counts are identical at BASE and on the working tree; its SD6 count is not comparable across the two trees because an archive extraction carries none of the untracked .ufo/waves artifacts
FINDING SS-7 neutral the claim-ledger cells gate is red at BASE with the same message set after normalising line numbers, so the round-70 post-move section adds no cells-gate message
FINDING SS-8 neutral the round-70 lesson cites the placeholder path .ufo/waves/round-70/capture/S17x.body, which resolves to nothing; the committed captures are S170.body, S171.body and S172.body
FINDING SS-9 neutral the candidate commit leaves two stamp rows stale on its own (corpus/SOURCES.md and corpus/source-fetches.tsv, three rows added each without a re-pin) and the L1's working-tree edits leave five more
FINDING SS-10 neutral the round-70 SCORECARD capability row cites the directory .ufo/waves/round-70/final/ and the citations gate reads a directory token as UNRESOLVED, so the pointer must name the file c1-candidate.txt
FINDING SS-11 neutral claim-ledger.sh verify reads the same FAIL rows at BASE and on the live tree; only R14-01 changes reason, from a stale expectation (verdict-not-final) to a broken docs gate (exit-mismatch, exit 1) because of this round's unpinned entry
FINDING SS-12 neutral the drafted SKILL.md rows cite the entry path on every row and omit the two operator-consequence claims the entry itself marks as inference
FINDING SS-13 neutral this seat drafted the same four surfaces the L1 has already drafted uncommitted, and the two versions agree on every measured fact but differ in phrasing and in the entry-path citations
FINDING SS-14 neutral no tool was installed or upgraded by this seat and no dev server was started, so no tool record and no server kill are owed
SEAT-STATUS: complete