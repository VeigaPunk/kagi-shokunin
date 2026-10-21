# ReviewLedger — round 22 (in-place pinned expectation rewrites + append-only contract)

Seat: reviewer, read-only. Axes: **C1 calibration**, **C2 freshness**. No production edits, no installs (nothing to install), no host commands beyond read-only measurement (`jj --ignore-working-copy`, `sha256sum`, `diff`).

## Exact read revision

- Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f` ("Integrate remote documentation; preserve local round log").
- Working copy `@` at read time: `34dc1454c6e42c8afdcd4da64476963eeee27d14` (empty description); `stamps.tsv` and `claim-ledger.tsv` byte-identical to base (claim-ledger pin sha `8a4019cfc1eec916f30a8958fbc3ca2d30e59632e0f1d5d843cea6d1c24faa97`).
- The integration landed **during** this review: S021 (SOURCES.md:27), QUALITY.md QA10/QM13/QM14 (lines 71–73), the E3 correction (vault-openbao entry lines 115–138), `corpus/lessons/round-22.md`, `corpus/knowledge/feature-bound-credential-review.md`, `corpus/claim-ledger.sh` (1319 → 1371 lines), `corpus/revision-audit.py` (547 lines) appeared between successive reads. Every claim below names which state it was verified against; the falsify wave must re-measure on the one frozen integrated tree.

## Measured state

**Live stamp drift (8 of 63 rows, mid-wave), classified:**

| class | paths |
|---|---|
| stale at base (6) | `corpus/knowledge/config-layering.md`, `corpus/knowledge/handler-on-disk-state.md`, `corpus/knowledge/handler-trust-boundary.md`, `corpus/knowledge/janitor-env-contract.md`, `corpus/lessons/round-18.md`, `LOG.md` |
| round-22's own edits (2) | `corpus/knowledge/onepassword-machine-credentials.md` (E1 correction), `corpus/SOURCES.md` (S017–S021) |

Matches `.ufo/waves/round-22/before.json` (six at base = five named debt + LOG) and lessons/round-22.md §Revision accounting.

**The nine, reconciled.** Outside verifier (`kaika-w3/kagi-review.md` check 2): "`corpus/stamps.tsv` (9 lines deleted)" for `aea7a4301 → e1544c194f`. Three independent measurements agree this is **nine replaced lines, zero removed members**:

1. Path-set diff of `corpus/stamps.tsv` across all nine content-revisions of its history (`301b9ec6f5 … e1544c194f`): no path ever present is absent now.
2. `.ufo/waves/round-22/round21-migrations.json`: `removed_members: []`; nine `changed_stamp_records` (LOG, PROVINCE, SCORECARD, SHONEN, SKILL, corpus/README, claim-ledger.tsv, op-ref-consumption, op-ref-probe), each old/new line preserved.
3. Reproducing the verifier's other count (its check table: "9 mismatches" at base): aea7a43's own 56-row stamps.tsv vs the aea7a43 tree yields exactly 9 stale rows — the five named-debt files + `corpus/op-ref-probe.sh` + `corpus/README.md` + `LOG.md` + `SCORECARD.md`. Round 21 re-pinned the four it had itself edited and left five as named debt (LOG.md §21, round-21 lesson line 85). The plan's "nine previously dropped stamps" and the verifier's "9 lines deleted" are the same nine under two framings; both are expectation migrations, not membership loss.

Nothing was deleted; nothing needs "restoration" of old values. `round21-migrations.json` interpretation is correct: "Values require individual motivating evidence, not restoration to stale pins."

## Findings by severity

### High

**H1 — C1 gate artifacts absent while the verifier already allowlists them.** `corpus/feature-claims.py` and `corpus/feature-claims.json` do not exist on disk (`ls` ENOENT at read time), but integrated `corpus/claim-ledger.sh` restricts `python3` to exactly those two paths (`ALLOWED_RE`/`PYTHON_SCRIPT_RE`, lines 160–176), and BuildQualifierGate's handoff says "Only these two files owned". Until they land, C1 has no runnable typed-claim review — the round's own declared before-state persists — and the two allowlisted row shapes are unrunnable. Integration must land both files before the falsify wave; the falsify wave must treat their absence as a C1 failure, not a skip.

**H2 — the ledger/stamp migration set is entirely pending and is the C2 acceptance surface.** `claim-ledger.tsv`/`stamps.tsv` are still base-identical while their subject artifacts moved. Exact rewrites required (values **measured at the integrated tree**, never computed):

| row | now pins | must become (measured expectation) |
|---|---|---|
| R11-09 + R18-03 | `PASS (97 cases)` | measured selftest count (FixCellParser static handoff: 108 = 97 + 2 cells + 9 python-policy); both rows must move to the same measured value; notes keep "97 until round 22…" |
| R21-02 | `rows=16 A=14 … mined=14 … entries_sourced=3 legacy=21` | rows=21, A=19, mined=19, entries_sourced=4, legacy=21 unchanged (no legacy-header claim) |
| R14-01 | `entries=24 row_linked=21` | entries=25 row_linked=22 (feature-bound entry declares `source:` + `Reverify: R21-02`) |
| R12-03 | `63` | measured (adds: round-22 lesson, feature-bound entry, revision-audit.py, feature-claims.py/.json, and round-21-verifier-spotcheck.md only if stamped — see M2) |
| R21-04 | `39` | measured after new R22-xx rows append |
| R13-01 | `^23$` — unchanged | note-only migration (see M1) |
| R13-02 | `^35$` | unchanged |

Every rewrite follows the corpus pattern (R12-02's note chain): old value retained in the note, rationale cited (QM14), value taken from actual run output at the integrated tree. `SKILL.md` row 46's "(63 stamps + 39 claims + claim ids, round 21)" needs the same in-place count correction.

### Medium

**M1 — R13-01's note becomes false by this round's own fix.** The note says "so `cells` refuses the scorecard since 93ab9a5 — named debt, round-21 lesson". After the cells fix (on disk, verified: `BLOCKED_ATTEMPT_RE` exempts only the exact heading; `cells-malformed-score-after-blocked` still fails other malformed headings) that clause is obsolete. Migrate the note in place (expectation `^23$` unchanged; heading bytes never rewritten), naming the exemption and the new selftest case ids. Also record R13-03's FAIL→PASS as a measured migration — do not touch its expectation.

**M2 — `corpus/lessons/round-21-verifier-spotcheck.md` is cited but unstamped.** It is consumed by lessons/round-22.md §Mistakes M22-1 (and by the falsify wave via `frozen/before`), is not in `stamps.tsv` (63 rows lack it), and no policy sentence declares the exclusion. Integrator-authored (commit `1e9e67ff3f8f`, protocol-shokunin), so outside lane ownership is a fair reason — but QM14's laundering shape is exactly silent omission: stamp it in the round-22 restamp, or record the exclusion with its reason in the migration record.

**M3 — five named-debt restamps must not precede their QM1 dispositions.** round-21 lesson line 85: "re-pinning them without review would bless edits no round claimed"; M1's fix: "mark those lines historical in an append-only erratum; never expand `af8873ca…`". At read time `config-layering.md` and `round-18.md` carry no round-22 marking (grep 0 matches). Required order: per-path disposition appended to LOG.md (mark-historical erratum lands, or an explicit claimed-edit decision), then the restamp. A bare restamp launders QM1 debt and fails C2.

### Low

- **L1 — LOG.md's sixth stale pin is by design, not debt:** the append-only log moves after every stamp refresh. Declare pin-at-commit semantics (pin only in the commit that stops appending) in the migration record; never chase live bytes.
- **L2 — static handoff vs measurement:** FixCellParser states 108; my static count of `^  tcase ` lines is 105 plus `tcase_last` rows, so 108 is plausible but unverified. The pin is the measured number; a mismatch is itself a finding.
- **L3 — census wrap hazard withdrawn:** the new entry's single wrapped `source:` line parses (`sources-census.sh` `src_field()` line 121 + selftest `m_continuation`); S017–S021 all tier A so SC_ENTRY_CITE holds; used-by handshake verified in SOURCES.md (S017–S020 → lesson + entry; S021 → both).

## Acceptance conditions

### C1 calibration (correct decisions, not authored rows)

1. `corpus/feature-claims.py` + `.json` land; their ledger rows run via the exact allowlisted tokens; exit contract 0 clean / 1 failed / 2 cannot-evaluate; unknown feature/field/source fails closed at 1, not 2.
2. Holdout decisions include, at minimum, the three known bad admits — E1 eligibility-free admit (S006's integration-key wording is not "no standing vault access" for Broker delivery), E1 Actions-preview-for-custom-OIDC conflation (S017 preview vs S018 beta vs S019 guide-level label), E3 Vault-supports-OpenBao (S012/S013 are Vault; OpenBao needs S014–S016/S021) — and bounded valid controls (S015 TokenReview-scoped note; S016 OpenBao 2.7.x parent-token revocation; S017 with Business prerequisite; S018 beta + JavaScript-SDK-only). Gate contract floor: ≥8 bad + ≥4 good.
3. Metric is decision correctness against independent source-grounded expected decisions, including false-admission count (QM13); authored artifact/row totals are not evidence.
4. QA10/QM13/QM14 sit in QUALITY.md append-only below QM12, each citing `corpus/lessons/round-22.md` §Mistakes (M22-1/2/3) — landed, ids match.
5. `feature-bound-credential-review.md` is the active corrected reading; older bodies stay as history (verified); no new coverage-map claim (it corrects held ground); counted by R14-01/R21-02 migrations above.

### C2 freshness (reconciliation without laundering)

1. `stamps.tsv` regenerates as a whole-row-set reviewed commit (`stamp` mode; shrink refused; `--prune` only with recorded justification). Row-set guard untouched.
2. Every changed row carries a QM14 migration record (old sha + new sha + the round/commit that moved the bytes). `round21-migrations.json` covers aea7a43→e1544c194 and `historical-migrations.json` the R21-03 span; round 22's own span needs its own record — no reuse of the round-21 files for round-22 changes.
3. Five named-debt dispositions land per M3 ordering; `af8873ca…`-class historic assertions stay historical (restoring a pin never re-verifies the claim).
4. Expectation rewrites per the H2 table: measured values only, old values retained in notes, both selftest pins moving together.
5. `revision-audit.py` (on disk, 547 lines): read-only (verified: stdin DEVNULL, `GIT_OPTIONAL_LOCKS=0`), stdlib-only, fail-closed on malformed/duplicate/path-escape (SAFE_PATH/HEX_DIGEST/DECIMAL), `--history` via read-only `git show` (verified working on this colocated jj checkout), stable STALE/MISSING/DROPPED ids, no auto-restamp, selftest fixture arm pinned by an R22 row.
6. No depth booking; no legacy-header count claim (`legacy=21` stays in R21-02; header migration is ReviewHeaders' separate risk, not C2 evidence).
7. Causal separability holds: C1 files (feature-claims, the entry, SOURCES rows) carry zero stamps/revision-audit dependencies; revision-audit reads no SOURCES/knowledge content. Restamping never adjudicates vendor facts; qualifier adjudication never depends on restamping.

## Falsifier C2 must withstand (designated)

**Silent-laundering restamp probe** — run on a scratch clone of the integrated tree, never production:

1. Replace the six base-stale rows' sha/lines/bytes in `stamps.tsv` with the current live files' digests, no migration record. Run `bash corpus/claim-ledger.sh verify` and `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`. Required: verify goes green (pins match files) **while the audit reports each six as a finding** — pin sha matching a live file but no committed revision and no journal line — exit 1. If the audit is CLEAN because it compares pins only to live bytes, the laundering detection does not exist and C2 fails.
2. Mirror probe: restore the five old named-debt pins verbatim. Required: STALE persists (old pins mismatch live bytes), and no mode reports "restored/clean" — restoration of stale expectations is a non-resolution (round21-migrations.json interpretation).
3. Honesty probe: with history membership, the audit must report `dropped=0` against all nine historic stamps.tsv revisions — zero removed members is the measured truth; reporting "nine dropped" would be manufacturing the finding the plan's framing suggests.

C1 secondary falsifier: a claim with schema-perfect provenance (real tier-A row, real URL, real quote) binding S013 (Vault §Lease, renew, and revoke) to an OpenBao token-TTL claim must REJECT; the same claim bound to S021 must ADMIT. A gate that passes on representation alone fails C1.

## Residual risk and verification gaps

- The tree moved during review; every measured number above is pinned to the read moment, not to the frozen integrated tree. The falsify wave re-measures everything on one tree (its spec already requires recording observed hashes).
- `feature-claims.py/.json` content was never observed — acceptance conditions 1–3 are contract-level (from the seat prompt), not implementation-level.
- `revision-audit.py` was skimmed (header/contract only, lines 1–63); its DROPPED logic was not executed or fully read.
- The selftest count 108 is a static handoff, never run (seat contract: parent runs post-integration).
- FixCellParser's `/tmp/kagi-shokunin` clone-path incident is recorded in lessons/round-22.md M22-4; no lane mutation was claimed; nothing for this seat to add.

## Checks parent should run after integration

1. `bash corpus/claim-ledger.sh --selftest` → pin R11-09/R18-03 to the measured count (expect ≈108; mismatch = finding).
2. `bash corpus/claim-ledger.sh cells` → exit 0 CLEAN on the real scorecard (R13-03 green; R13-01 note migrated).
3. `bash corpus/sources-census.sh` → CLEAN, rows=21, entries_sourced=4, legacy=21 → then rewrite R21-02 from that line.
4. `bash corpus/claim-ledger.sh docs` → entries=25 row_linked=22 → R14-01.
5. `python3 corpus/revision-audit.py --selftest` and `python3 corpus/feature-claims.py --selftest` after the C1 files land.
6. Whole-set `bash corpus/claim-ledger.sh stamp <all paths>` + QM14 journal + LOG.md round-22 entry, one reviewed commit; host-bound rows (R18-01 class) skipped per QM12 with ids listed.
7. Then dispatch the falsify wave (`falsify-spec.json`) against the frozen tree.

---
Report: `.ufo/waves/round-22/build/ReviewLedger.md` (relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`). Read revision: base `c2cab35bc92e57e39e5489bac3386db078345b3f`, `@` `34dc1454c6e42c8afdcd4da64476963eeee27d14`, in-flight disk state as dated above; no production files, live lane jj state, or host configuration touched.
