# CriticNoTrade — C1/C2 causal separability, no-harm, and index correction coverage

Read revision: frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD);
`.ufo/waves/round-22/before.json`, `frozen/before/expected.json`,
`plans/round-22.md`, build-spec item prompts, `corpus/claim-ledger.{sh,tsv}`,
`corpus/stamps.tsv`, `SCORECARD.md`, `corpus/README.md`, `SKILL.md`,
`PROVINCE.md`, `corpus/QUALITY.md` (working-tree), `corpus/lessons/round-22.md`
(working-tree), `corpus/SOURCES.md` (working-tree),
`corpus/knowledge/feature-bound-credential-review.md` (working-tree), and the
fleet verifier `/home/vgpnk/Projects/shokunin/.ufo/waves/kaika-w3/kagi-review.md`
line 19. All commands below are read-only (`git show/diff/log`, `grep`,
`sha256sum` recomputation). No host gates were run. Read-only seat; findings +
this report only.

## Counterexample (the strongest available): the wave cannot land either claim
on the frozen base it is scored against

Commit exactly what the wave's declared file-level deliverables produce today —
the partial integration already staged in the working tree (E1/E3 errata,
QUALITY QM13/QM14/QA10, SOURCES S017–S021, `lessons/round-22.md`,
`corpus/knowledge/feature-bound-credential-review.md`) plus
FixCellParser's `claim-ledger.sh` edit and BuildQualifierGate's
`corpus/feature-claims.{py,json}` — **without** a synchronized
`stamps.tsv`/`claim-ledger.tsv` reconciliation commit. That is precisely the
landing the "causally separable" sentence in `plans/round-22.md` §8 invites:
C1 lands source adjudication, C2 lands pin audit, each independently.

### Expected failure (all four ledger modes red; both axes' evidence dead)

1. **`docs` mode fails UNPINNED + the count expectation is stale.**
   `claim-ledger.sh:833+` (`doc_audit`) requires every `corpus/knowledge/*.md`
   file to be a row in `stamps.tsv` (comment L58, verdict UNPINNED). The
   working-tree `feature-bound-credential-review.md` (carries `source:` +
   `Reverify: R21-02`, `grep` confirms no stamps.tsv row) → `UNPINNED`, exit 1.
   Simultaneously `R14-01` (`claim-ledger.tsv:32`) expects
   `entries=24 row_linked=21`; the true post-integration value is
   `entries=25 row_linked=22` (the new entry is row-linked through R21-02).
   This expectation migration is in **no** wave item's deliverable.

2. **`verify` cannot reach CLEAN — even after a C2 restamp.** `verify` runs
   `verify_stamps` + `verify_claims` + `idref_audit` (L941–944). Today ten rows
   are byte-stale, not six: `before.json`'s six (config-layering,
   handler-on-disk-state, handler-trust-boundary, janitor-env-contract,
   lessons/round-18.md, LOG.md) **plus** QUALITY.md, SOURCES.md,
   onepassword-machine-credentials.md, vault-openbao-token-lease-lifecycle.md
   (recomputed sha256/lines/bytes on the working tree — all ten mismatch).
   FixCellParser's edit adds `corpus/claim-ledger.sh` itself as an eleventh.
   Worse, `verify_claims` re-runs `R13-03` (`bash corpus/claim-ledger.sh cells`
   expecting `CELL_AUDIT: CLEAN … stale_pointers=0 …`, row at
   `claim-ledger.tsv:38`): it dies at `claim-ledger.sh:715` on the round-20
   heading `## Round 20 — interactive attempt; blocked, not completed
   (2026-10-15)` (SCORECARD.md:558) which matches `^## Round ` but not
   `SEC_RE='^## Round [0-9]+ — (pre|post)-move'` (L671). So C2-only
   reconciliation leaves `verify` red on a **C1** defect — the separability
   axiom is false in both directions.

3. **`cells` (the repaired C1 audit) cannot print CLEAN until C2 restamps.**
   After the parser repair admits the round-20 heading as non-score prose,
   `cells_evidence` (`claim-ledger.sh:802–813`) runs `stamp_cmp` over every
   stamped path a scored cell cites. SCORECARD cells cite `corpus/QUALITY.md`
   (calibration cell, L642), `corpus/README.md` (coverage cell, L643),
   `PROVINCE.md` (adjacency cell, L646), `corpus/lessons/round-18.md` (round-18
   cells L314/325/326) — every one of them stale at integration →
   `STALE-POINTER`/`MISSING-POINTER` → `CELL_AUDIT: BROKEN`, exit 1. And
   `cells_evidence` re-runs cited claim rows: `R21-02` (cited at L643/645)
   expects `rows=16 … mined=14 … entries_sourced=3`, while working-tree
   SOURCES.md holds 21 rows/19 mined/4 sourced → `row_failures>0`. FixCellParser
   alone produces a **newly visible red**, not a green.

4. **C1 forces an undocumented C2 expectation migration.** FixCellParser adds
   selftest cases ⇒ `R11-09` and `R18-03` (`^SELFTEST: PASS \(97 cases\)$`,
   rows 23/50) must migrate to 97+N; new claim rows for `feature-claims.py`
   migrate `R13-02` (`^35$` → 36+) and `R21-04` (`^39$` → 40+); R21-02 migrates
   to `rows=21 A=19 … entries_sourced=4`; R14-01 to `entries=25 row_linked=22`.
   `DraftHistory` is scoped to the *nine rows + claim-ledger.tsv provenance*
   only; the wave spec contains no seat that journals the C1-induced rewrites.
   Left to the integrator ad hoc, each rewrite is exactly the
   "expectation rewrites with no old-value evidence" weak signal QM14 (already
   staged in QUALITY.md) declares a defect.

### The "nine dropped stamps" provenance is a diff artifact, not a membership loss

`git diff aea7a4301 e1544c194 -- corpus/stamps.tsv` on this checkout is `16 9`
(numstat): **nine `-` lines are row rewrites, zero are membership drops** —
membership grew 56→63 with no path ever removed (verified over every
reachable revision; an ever-stamped vs HEAD `comm` is empty). The nine are:
`corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`,
`corpus/op-ref-probe.sh`, `corpus/README.md`, `LOG.md`, `PROVINCE.md`,
`SCORECARD.md`, `SHONEN.md`, `SKILL.md` — the round-21 commits touched those
files and their pin values moved with them. If `corpus/revision-audit.py` is
built as specified (membership diff vs `--history`) it will report `dropped=0`
at HEAD, and a "restore missing pins" implementation that adds nine rows for
these paths will duplicate live rows — a new `DUP`-class defect laundered as
C2 repair. This is the correction-coverage hole: the plan's C2 text ("restore
missing pins") encodes the verifier's *line-diff* vocabulary as a *membership*
fact.

## Impacted axes

- **Calibration:** R13-03 (the scorecard-evidence claim) is un-CLEAN-able on
  the frozen base until C2 restamps the cited pins; the wave's own C1
  acceptance evidence (`cells` green) is downstream of the "independent" axis.
- **Freshness:** C1's gate edits force claim-expectation migrations the C2
  migration journal does not cover; and restamping the nine rewritten rows
  without per-row old→new evidence repeats the round-21 defect M22-3 names.

## Smallest safe correction (bounded)

1. **One atomic reconciliation step** (integrator-owned, after all seats land):
   regenerate `stamps.tsv` and migrate `claim-ledger.tsv` in the same commit;
   record every changed `expect`/`exit` column and every stamp row as
   `id/path — old → new — commit` in `lessons/round-22.md` §Revision
   accounting. No separate-file ownership for the pair.
2. **`revision-audit.py` must classify three disjoint findings** —
   `dropped` (path present in `--history`, absent now), `rewritten` (present
   both, any column changed), `stale-content` (row vs live bytes) — emitting
   each row's old→new values, and must run its history diff on the verifier's
   own range `aea7a4301..e1544c194` to demonstrate the nine rows are
   `rewritten`, not `dropped`. "Restore" applies only to true `dropped`
   members (there are zero on this checkout); `rewritten` rows get migration
   notes, not re-added rows.
3. **Landing order for the evidence chain:** E1/E3/index edits → FixCellParser
   → `docs`/`citations`/`cells` clean under new stamps → restamp **last**
   (new files must be byte-final first — `lessons/round-22.md` will be stamped
   only after its own revision-accounting section is complete).
4. **Index corrections (allowed, required):** append the round-22 row to
   `corpus/README.md` §Coverage map (feature-claims gate + new entry +
   revision-audit), and give the gate bullets in SKILL.md/PROVINCE.md
   round-scoped counts — never update bare present-tense counts
   (`97 cases`, `63 stamps`, `39 claims`, `16 rows` in R21-02's note) to new
   totals; freeze them as "at round 21" per the no-legacy-header-count
   constraint. This keeps C2 honest without a count-proxy move.

## Limits

- I did not run `claim-ledger.sh` in any mode (host-gate prohibition); failure
  verdicts above are derived from the mechanism lines cited.
- The fleet verifier's diff range was reproduced exactly; if the fleet's
  `aea7a4301` differs from local `aea7a43`, `revision-audit.py`'s `--history`
  parameterization is precisely where that discrepancy must surface.
- Checks for the parent after integration: `claim-ledger.sh docs`, `cells`,
  `citations`, then `verify` (rows R11-09/R13-02/R13-03/R14-01/R18-03/R21-02/
  R21-04 re-pinned with journal entries), plus `sha256sum --check` over
  `stamps.tsv` per QM12.
