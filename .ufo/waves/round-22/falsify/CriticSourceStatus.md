# CriticSourceStatus — round-22 falsification report

Seat: `KagiR22.CriticSourceStatus` (critic). Scope: fresh attack of the
integrated C1/C2 work — feature-specific status and Business-eligibility
correction coverage across E1 / SKILL / PROVINCE / index, history preservation,
and revision accounting. Read revision: **`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`**
(master tip; the measured integration landing). Every attacked file's SHA-256
was recomputed and matches `.ufo/waves/round-22/integration-manifest.json`
(`feature-claims.py`, `feature-claims.json`, `revision-audit.py`,
`stamps.tsv`, `claim-ledger.tsv`, `SOURCES.md`, `QUALITY.md`, `README.md`,
`SKILL.md`, `PROVINCE.md`, both corrected knowledge entries, and
`lessons/round-22.md` — all identical). No production files were modified;
inputs were written only under `.ufo/waves/round-22/falsify/inputs/`.

## Verdict: HOLDS-WITH-LIMIT

No concrete contradiction found in the corrected feature/status/eligibility
coverage or in the revision accounting. One residual gap below is a fixable
documentation defect, not a mechanism break.

## Exercised evidence (all commands run this wave, read-only or fixture)

### C1 mechanism — feature-bound decisions, not row counts

- `python3 corpus/feature-claims.py --phase before` → exit 1, 10/10 records
  rejected (2 `reject:false-claim`, 8 `reject:bar-fail`),
  `false_admissions=0 misses=0`. Matches manifest `feature_before_rejections=10`.
- `--phase after` → exit 0, `admitted=4` (4 bounded verbatim-pin controls).
  `--phase boundary` → exit 2, 3 unjudgeable, all `scored=no`.
- `--selftest` → `FEATURE_CLAIMS_SELFTEST: PASS cases=10` (manifest 10).
- Code pins recomputed from `feature-claims.json`: review/sources/features/
  records/transitions/boundary digests all equal the literals in
  `feature-claims.py:61-66`. Expected decisions are literal constants
  independent of record bodies; tampering the artifact fails
  `FC-SOURCE-MANIFEST`/`FC-FEATURE-MANIFEST`.

### Fresh held-out attacks (`--input`, this wave, 8 records)

| attack | expected | observed |
|---|---|---|
| custom-OIDC claimed `public_preview` (the actual E1 defect) | reject | `reject:false-claim FC-STATUS-MISMATCH` |
| GitHub Actions claimed `public_beta` (reverse swap) | reject | `reject:false-claim FC-STATUS-MISMATCH` |
| GA claim with `plans:[]` (Business eligibility omitted) | reject | `reject:bar-fail FC-ELIGIBILITY-QUALIFIER` |
| GA claim whose status evidence cites only the S020 split (no page-title anchor) | reject | `reject:bar-fail FC-EVIDENCE-ANCHOR` |
| OpenBao TTL claim asserted under `hashicorp_vault` | reject | `reject:false-claim FC-PRODUCT-MISMATCH` |
| Vault-lease claim evidenced by S021 (reverse cross-product) | reject | `reject:bar-fail FC-CROSS-PRODUCT` |
| OpenBao TTL with `service_token_scope` dropped (batch/generalized) | reject | `reject:bar-fail FC-RUNTIME-CONSTRAINT` |
| valid GA control with evidence/requirements lists reordered | admit | `ADMIT FC-ADMITTED` |

All eight adjudicate correctly, including a new held-out *admit* control
(reordered unordered conjunctions), so the gate is not reject-only.

### Correction coverage (E1, SKILL, PROVINCE, index)

- E1 `onepassword-machine-credentials.md`: round-22 erratum separates Actions
  public preview (S017) from custom-OIDC public beta (S018), names EPM
  Business eligibility (S019/S020), deployment exclusions, beta-app and
  JavaScript-only constraints; the defective item-4 sentence is retained as
  history and explicitly superseded. `git diff c2cab35..HEAD` on both E1/E3
  files removes no content line (only trailing blank context consumed) —
  append-only verified.
- E3 `vault-openbao-token-lease-lifecycle.md`: round-21 errata (product-separated
  rows) plus round-22 outside-disagreement retention and S014/S016 reopen
  notes; cross-product parity and KV retention remain withdrawn.
- `SKILL.md:677-682` and `PROVINCE.md:65-80` both name
  `feature-bound-credential-review.md` the **active** reading and mark the
  merged rows historical; `corpus/README.md:124` indexes it the same way. The
  decision table (`SKILL.md:48`) already scopes "Vault: leases only".
- `SOURCES.md`: append-only 16→21 rows; `diff` of S006/S007 rows vs c2cab35 →
  identical (status/recheck/used-by preserved per the lesson claim); S019/S020
  supersession scoped in prose; the unopened custom-workflow lead is
  dispositioned, not erased. `bash corpus/sources-census.sh` →
  `CLEAN (rows=21 A=19 … entries_sourced=4 legacy=21)`, matching manifest.
- `QUALITY.md` QA9/QA10 (+QA10 application note), QM13/QM14 all present and
  phrased as decision/audit rules, not count proxies.

### C2 — revision accounting

- `python3 corpus/revision-audit.py --history c2cab35…` →
  `CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0 — matches
  manifest `revision_audit`. `--selftest` → `PASS (cases=11 failed=0)`.
- Recomputed member sets independently (LC_ALL=C):
  `aea7a4301 → e1544c194` stamps first-column diff = **0 removed, 7 added** —
  the lesson's "zero removed stamp members, nine replaced lines" is true;
  claim-ledger col-1 diff = 0 removed (R21-01..04 + 1 comment added).
  `c2cab35 → HEAD` = 0 removed, 6 added, exactly the audit's `added=6`.
- Base digests verified: `git show c2cab35:corpus/stamps.tsv` sha256 =
  `0ce7fa4f…` = `frozen/before/expected.json`; claim-ledger likewise
  (`8a4019cf…`).
- Expectation migrations: `pin-migrations-integration.json` itemizes all 63
  stamp members 63→69 with old stamp + base-observed + new stamp, and every
  rewritten ledger expectation (R12-03 63→69, R13-01 23→25, R14-01 24→25,
  R21-02 16→21, R21-04 39→43, R11-09/R18-03 97→108, R18-02 note-only) with
  old/new values; `round21-migrations.json` covers the earlier span. Live
  `stamps.tsv` count = 69 = R12-03's `^69$` pin. `cells` now runs
  `CELL_AUDIT: CLEAN … orphans=1` (orphans are informational by contract,
  `claim-ledger.sh:51-52`).
- `before.json`'s six-stale measurement includes the extra LOG entry the
  outside verifier did not list — disclosed, not hidden.

## Residual limits (impacted axes, smallest safe correction)

1. **[fixable doc gap, C2]** `round21-migrations.json` has `removed_members`
   and `changed_stamp_records` but no `added_members` field: the 7 added
   stamp paths in its own `aea7a4301→e1544c194` span are documented only
   implicitly (inside the R12-03 new-row text of `rewritten_claim_rows`).
   Membership accounting is therefore complete only when the two files are
   read together. Smallest correction: add an `added_members` list (or a
   one-line pointer to the R12-03 note) inside that record — a `.ufo`
   evidence-file change, not a production edit.
2. **[disclosed limit, C1]** `EXPECTED_RECORDS` labels: only 2 of 14 are
   `outside-verifier`; the rest are `construction-rule`/`verbatim-pin`, i.e.
   author-derived expected outcomes. The code and lesson both say so, and
   QM13 bars claiming outside agreement — held, but the judge should not
   read the 14-decision pass as independent confirmation.
3. **[tradeoff, C1]** the catalog is closed-vocabulary: a true bounded claim
   phrased with synonyms outside the pinned field values is `reject:bar-fail`
   rather than admit. That is the documented design (typed record, not prose),
   not a defect the Rust judge must reject — but it caps "calibration" at
   vocabulary-exact decisions.

## Checks for the parent to run post-integration

`python3 corpus/feature-claims.py --selftest`, `--phase before|after|boundary`;
`python3 corpus/revision-audit.py --history <base>` and `--selftest`;
`bash corpus/sources-census.sh`; `bash corpus/claim-ledger.sh cells`.
All reproduced green this wave. No installs performed; no host-private gates,
loopback probes, launchers or package tools were invoked.
