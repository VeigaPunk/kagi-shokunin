# ConnectEvidence — integrated cross-axis contract audit

Axes attacked: **calibration (C1)** and **freshness (C2)**. Seat: read-only
connector; no delegation, no production edits, no installs, no launcher or
package-manager use, no host-private gate. One exact wording mismatch found;
everything else in the source-row / errata / QUALITY / claims / capability
chain reproduces.

## Exact read revision and freeze

Measured integration landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
(`git rev-parse HEAD`). The historical base `c2cab35…` is **before**, not the
execution input. Freeze authority: `.ufo/waves/round-22/integration-manifest.json`,
observed SHA-256
`31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
All **71/71** manifest inputs re-hashed and match; no production file was
modified by this seat.

| Input | Observed SHA-256 (matches manifest) |
|---|---|
| `integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` |
| `SCORECARD.md` | `748790b416547fbbc66dcdc33907c7a2aa3fcb01badb1dd99965398a82bf132d` |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` |
| `corpus/QUALITY.md` | `dc2f5fe27935c3e238c0992cb14a4285bbee5edd902e2174b963561bcc84c09d` |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |

## Executed contract checks (read-only local fixtures)

| Command | Exit | Observed line / result | Contract match |
|---|---:|---|---|
| `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)` | exact `R21-02` / manifest |
| `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (47 cases)` | exact `R21-03` |
| `python3 corpus/feature-claims.py --phase before` | 1 | `FEATURE_CLAIMS: FAILED phase=before false_claims=2 bar_failures=8 false_admissions=0 misses=0`; ten decision rows, two `outside-verifier` | expected red rejection run |
| `python3 corpus/feature-claims.py --phase after` | 0 | `FEATURE_CLAIMS: CLEAN phase=after admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0` | exact `R22-01` |
| `python3 corpus/feature-claims.py --phase boundary` | 2 | `FEATURE_CLAIMS: CANNOT_EVALUATE phase=boundary unjudgeable=3` | expected boundary, excluded from score |
| `python3 corpus/feature-claims.py --selftest` | 0 | `FEATURE_CLAIMS_SELFTEST: PASS cases=10` | exact `R22-02` |
| `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` | 0 | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`; `ADDED` list is exactly the six reviewed members | exact `R22-03` / manifest |
| `python3 corpus/revision-audit.py --selftest` | 0 | `REVISION_AUDIT_SELFTEST: PASS (cases=11 failed=0)` | exact `R22-04` |
| `bash corpus/claim-ledger.sh docs` | 0 | `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`; ratio floor `13` | exact `R14-01` prefix / current contract |
| `bash corpus/claim-ledger.sh --selftest` | 0 | `SELFTEST: PASS (108 cases)` | exact `R11-09` / `R18-03` |

Static counts also match: `stamps.tsv` non-blank rows **69** (`R12-03`),
`^## Round ` headings **25** (`R13-01`), knowledge entries **25** and
legacy-missing-`source:` **21**, claim rows **43** (`R21-04`), `^R1` rows
**35** (`R13-02`), `[substrate]` rows **11** (`R18-02`). The 21 legacy
entries still lack `verified-at:`/`recheck:` (0 have either), so the README
§Known gaps header sentence remains accurate.

## Freshness reconciliation re-derived against Git

| Record | Result |
|---|---|
| `before-runnable.json` | six stale, zero missing/dropped/added/invalid, exit 1; matches `before.json` list |
| `pin-only-ablation.json` | 63 members stamped, same audit clean `stale=0 dropped=0 added=0`, exit 0 |
| `round21-migrations.json` (`aea7a4301` → `e1544c194…`) | 9/9 changed stamp records and 5/5 rewritten claim rows byte-identical to `git show`; path set: **0 removed, 7 added**; the nine deleted diff lines are same-path rewrites, not lost members |
| `historical-correction-pins.json` (`c41af82` → `e1544c194…`) | 13/13 changed stamp records byte-identical; 0 added/removed |
| `historical-migrations.json` | R21-03 old/new row byte-identical; `deleted_stamps: []` consistent |
| `pin-migrations-integration.json` (base → HEAD) | 38/38 stamp changes (32 changed + 6 added) and 12/12 claim changes (8 changed + 4 added) byte-identical; `removed_members: []` |

The nine-line claim is therefore exact: **nine replaced tuples, zero dropped
members**; the seven additions are the round-21 membership growth already
recorded in the migration record's old `R12-03` note. Restamping proves local
byte/pointer integrity only, not source currentness; the lesson states that
bound and the before/ablation pair demonstrates it.

## Exact mismatch: capability wording under a grown table

`SCORECARD.md:682-688` currently reads:

- table rows at `:684-686` — three capabilities: op-only dotenv byte probe
  (first-working **21**), source registry + census gate (**21**),
  feature-bound typed credential review (**22**);
- `:688` — “Rows enter only through a round that demonstrates the capability
  running (`AXES.md` §Capabilities); **both rows** entered with the
  round-21 runs quoted above. The 2026-10-16 rollout added none.”

The sentence is false/unqualified against its own table: there are three
rows, and the third entered in round 22. `corpus/lessons/round-22.md:190-192`
explains that the note “refers to the two round-21 rows,” but the explanation
lives in a different file; the scorecard sentence itself still miscredits the
round-22 feature-review capability to round 21.

Affected axes: **freshness** (declared capability accounting not reconciled
with the table) and **calibration** (a capability-provenance claim is wrong).
No scalar score move is claimed for this wording repair.

## Proposed move (one, bounded)

For the integration owner, after the falsify freeze: replace the aggregate
sentence at `SCORECARD.md:688` with a per-row provenance statement, e.g.:

> Rows enter only through a round that demonstrates the capability running
> (`AXES.md` §Capabilities): the two round-21 rows entered with the round-21
> runs quoted above; the feature-bound typed credential review entered in
> round 22 (`R22-01`/`R22-02`; `repaired-checks.json`). The 2026-10-16
> rollout added none.

Use per-row provenance rather than a new count (“three rows”) so the sentence
does not become another countable proxy; `QM13` rejects authored counts as
calibration.

Risks: wording only; no evidence, gate, stamp or score changes. The edit must
not be made on frozen inputs during this wave.

Verification: `grep -n 'both rows' SCORECARD.md` returns no output; a read of
`SCORECARD.md:682-689` shows three rows and a matching per-row sentence;
`R22-01`/`R22-02` already execute as recorded above.

## Bounded corroborations / non-blocking notes

- **Source rows, errata, QUALITY and active review agree.** S017–S021 are
  A/mined and cited both ways by `corpus/lessons/round-22.md` and
  `corpus/knowledge/feature-bound-credential-review.md`; S019/S020 supersede
  only the qualifier reading of S006/S007; the original rows remain. The
  active review matches the E1/E3 round-22 errata on Actions preview, custom
  OIDC beta, Business/EPM eligibility, GitHub deployment exclusions, beta
  desktop app, JavaScript-SDK-only, retained integration key, OpenBao
  service-token TTL/leases, and no Vault/KV parity. `QA10`/`QM13`/`QM14` each
  cite the corresponding M22 row, and the executed gates supply the decision
  evidence they demand.
- **EPM Business precision (not a defect).** `feature-claims.json` binds
  `enterprise_password_manager_business` to both Broker features via
  `S020-epm-plan`; the active review states the Business-account requirement
  in the two feature rows and names EPM Business in the product-level custody
  row. The build reports (`Source05.md:110`, `Source07.md:70-71`) treat
  “Business account” and “EPM Business” as compatible, and no source
  contradicts the catalog. If `QA10` is read as requiring the plan in every
  feature row, the two feature rows are less explicit than the catalog; this
  is a precision note, not a false claim.
- **OpenBao sentence-boundary wording (non-blocking).** The E3 erratum says
  “Its following sentence includes associated leases,” while the catalog
  pins `S021-ttl` as one sentence with a dash (“… no longer function -- it,
  and its associated leases, are revoked”). The lesson at
  `corpus/lessons/round-22.md` already explains the phrase means the same
  sentence’s continuation. If that erratum is touched again, “the same
  sentence after the dash” is the exact form. No admitted fact or score
  changes.
- **No depth/header-count claim.** `grep -L '^source:' corpus/knowledge/*.md`
  is 21 and none of those files gained `verified-at:`/`recheck:`; README
  §Frontier still records the legacy-header gap; the round explicitly
  disclaims a header-count move.

## Limits

No vendor page was re-opened by this seat; source content is the frozen
registry/catalog plus advisory build reports, so this is not source-currentness
or vendor-truth verification. The gate executions are local read-only checks;
they do not establish outside-verifier agreement, an accuracy scalar, or a
score change. No host-private gate, deployment, account, vault, browser/CDP,
service or credential operation was used. Installs/updates: **none**.

Report: .ufo/waves/round-22/falsify/ConnectEvidence.md
