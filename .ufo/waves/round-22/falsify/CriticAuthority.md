# CriticAuthority — round-22 falsification of feature decisions and revision accounting

Seat: KagiR22.CriticAuthority (critic, read-only). Axes: **calibration**, **freshness**.
Question assigned: is adversarial decision correctness more than artifact
self-agreement? Compare the typed gate contract to the claims it decides and
to the outside rejection it encodes.

## Read revision and observed input hashes

Measured integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
(`git rev-parse HEAD` matches). Frozen inputs read and hashed per
`integration-manifest.json` (sha256
`31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`):

| input | observed sha256 vs manifest |
|---|---|
| `corpus/feature-claims.py` | `9f6a7e35…d074af` match |
| `corpus/feature-claims.json` | `a506cea7…b503aa` match |
| `corpus/revision-audit.py` | `ac19e186…f71ed1f8977` match |
| `corpus/stamps.tsv` | `88bbe15b…` (worktree, 69 members) |
| `corpus/claim-ledger.tsv` | `87fed349…c3989a` match |
| `corpus/lessons/round-21-verifier-spotcheck.md` | `6e4fa622…1ffb` match |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58…a24fe` match |

No production bytes modified; probe fixtures lived only under `/tmp/fc-probe`.
Public documentation GETs only (2026-10-20); no account/vault/host-private
surface, no launchers/package tools, no loopback probes.

## Verdict: holds-with-limit. No decision-breaking counterexample found.

### 1. External grounding of the typed contract — verified live (not artifact-internal)

The gate's declared limit is "consistency with pinned quote bindings, not
source truth." I tested whether the admitted controls are also externally
correct by re-fetching the four feature-defining pages on 2026-10-20:

- `…/brokered-access/github-actions/` H1 verbatim: *"…GitHub Actions at
  runtime (public preview)"* — matches S017-title and the catalog status.
- `…/brokered-access/custom-workflow/` H1 verbatim: *"…custom workflows at
  runtime (public beta)"* — matches S018-title. The E1 status conflation the
  gate rejects (`BEFORE-E1-STATUS`, `reject:false-claim`/`FC-STATUS-MISMATCH`)
  is genuinely false on live bytes today, so both the rejection and the
  `AFTER-CUSTOM-BETA-BOUNDED` admit are externally-correct decisions.
- S018 Step 1 ("latest beta release of the 1Password desktop app") and the
  JavaScript-SDK-only note are verbatim in the live page (needle absent in raw
  HTML only because of interleaved markup; stripped text carries the sentence).
- S019 exclusion/requirement quotes (GitHub.com hosting, Enterprise
  Server/data-residency exclusion, Free private-repository limit, Business
  account) all verbatim-present.
- `openbao.org/docs/concepts/tokens/` (2.7.x): S021-ttl sentence verbatim —
  "the token will no longer function -- it, and its associated leases, are
  revoked" — and the service-token scope sentence present.

So the typed gate's `admit` class is not merely artifact-closed: its four
admitted claims' load-bearing qualifiers currently agree with the pages.
This closes the strongest available contradiction path (stale/incorrect
catalog producing false admits).

### 2. Executed decision accounting — matches declared targets exactly

On the frozen bytes (authorized fixture executions):

- `--phase before` → exit 1: all 10 records decided as expected — 2
  `reject:false-claim` (status conflation, same-page status swap), 8
  `reject:bar-fail`; `false_admissions=0`.
- `--phase after` → exit 0: 4 admits, `misses=0`.
- `--phase boundary` → exit 2: 3 `cannot-evaluate` with the pinned findings,
  scored `no`.
- `--selftest` not rerun (recorded PASS cases=10 in `repaired-checks.json`).

Independent `--input` probes (`/tmp/fc-probe`, against the unmodified pinned
catalog): wrong-status → `reject:false-claim`/exit 1; cross-product fact
quote → `reject:bar-fail`/`FC-CROSS-PRODUCT`; unknown eligibility field →
`cannot-evaluate`; path claim citing a *catalog-bound but non-required* quote
(S007-guide-title) → `reject:bar-fail`/`FC-EVIDENCE-MISSING`. Correct under
the typed contract.

### 3. C2 revision accounting — independently verified against git objects

- Membership diff `aea7a4301`→`e1544c19` on `corpus/stamps.tsv` computed
  directly: **0 removed, 7 added, 9 changed** — the "nine dropped stamps" were
  nine replaced lines for the same paths, exactly as `round21-migrations.json`
  records. Spot-verified four old/new tuples (LOG, PROVINCE, SKILL,
  op-ref-probe.sh) byte-for-byte against `git show`: all match the artifact.
- Claim-ledger expectation migrations confirmed from the raw diff: R12-02
  29→36 cases, R12-03 56→63 rows, R13-01 20→23, R14-01 21/18→24/21;
  R13-02's change is note-only (still `^35$`). R21-03's 40→47 spans
  `c41af82`→`e1544c19` as `historical-migrations.json` documents.
- Live audit: `python3 corpus/revision-audit.py --history c2cab35…` →
  `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`,
  exit 0 — verbatim the R22-03 expectation and manifest `added=6`.
- `stamps.tsv` now has 69 non-blank rows; R12-03 is re-pinned `^69$` with the
  documented "original 63 retained plus six additions" note — the
  count-guard migration is itself evidenced, not silent.
- The before-state is honest: `before.json`/`before-runnable.json` record six
  stale records at `c2cab35` (one more than the verifier's five), and
  `pin-only-ablation.json` shows the isolated restamp→0 exit-0 ablation.
  No laundered historic claim found: `aea`/`e15` historic statements remain
  in `round21-migrations.json`, not rewritten.

### 4. Counterexamples / residual defects (fixable, none decision-breaking)

- **A. Closed-world admit class is a singleton projection (limit, partially
  undisclosed).** `evidence_requirements` is enforced as set *equality*
  (`feature-claims.py:736`): a fully correct claim that adds one additional
  valid citation, or cites a different catalog-bound quote for a field, is
  rejected `FC-EVIDENCE-MISSING` (probed). Likewise a *conservative* claim
  asserting a strict subset of qualifiers (e.g. dropping `javascript_sdk_only`)
  is `reject:bar-fail`. "Correct decision" therefore means "equal to the
  catalog projection," not "source-satisfiable." Impacted axis: calibration.
  This caps the axis's meaning but is a tradeoff a judge may accept — the
  singleton admit keeps the mechanism falsifiable and is what the
  `expected_decision` pins encode. Smallest safe correction, if the contract
  intends "at least": require `reference_set ⊇ required_references` for admit
  and define a distinct outcome for superset; otherwise document the
  singleton-admit convention in the artifact's `limits` (it currently says
  only "required qualifiers and pinned quote bindings match").
- **B. `eligibility.scope` has no evidence obligation (small real gap).**
  `EVIDENCE_FIELDS` covers `eligibility.plans|requirements|
  documented_exclusions` but not `scope` (`feature-claims.py:35-51`), so a
  claim asserting `scope:"source_bounded"` is admitted with zero quote binding
  for that field, and the catalog validator cannot attach one. The claim's
  scope must equal the catalog's, so the failure mode needs catalog complicity
  — but the same is true of every other field, which *does* get binding.
  Impacted axis: calibration (asymmetric evidence bar). Smallest correction:
  add `eligibility.scope` to `EVIDENCE_FIELDS` and bind scope for
  `source_bounded` features (e.g. S018-intro "connected an OIDC provider…"),
  or declare scope non-evidential.
- **C. Quote text is never checked against bound values (disclosed limit,
  one concrete edge).** Bindings assert (feature, field, value) ↔ quote_id;
  nothing checks the quote's bytes support the value. Mostly cosmetic —
  catalog is digest-pinned — but there is one over-specific binding:
  `openbao_token_ttl` fact string contains `nonroot`; no S021 quote carries
  a non-root qualifier (checked the dumped quote list; "nonroot" is true of
  OpenBao token semantics but not in the cited bytes). Impacted axis:
  calibration, minor. Correction: rename the fact to the quote-bounded
  `openbao_service_token_ttl_revokes_token_and_associated_leases` or add an
  S021 quote that establishes the root-token exclusion.
- **D. Decision-kind asymmetry on status under-assertion (cosmetic).**
  Claiming `not_asserted` where the catalog pins `public_beta` →
  `reject:false-claim` (`FC-STATUS-MISMATCH`, probed), while asserting a
  status where the catalog has none → `reject:bar-fail`
  (`FC-STATUS-UNSUPPORTED`). Both reject; the *kind* labels an under-claim as
  "false claim" but the more dangerous over-claim merely "bar-fail." If cell
  accounting ever weights kinds, the severity ordering is inverted. Not
  decision-breaking today (both reject; all expected decisions still match).
- **E. C2 laundering boundary — holds with limit.** `ADDED` findings never
  raise exit code; membership growth is recorded only in `.ufo` wave JSON,
  which is itself outside the stamped set. A member added with no historic
  record reads CLEAN. This is the intended "new content is not drift"
  semantics and the lessons justify mutable-snapshot vs append-only
  distinction, so it holds — but the migration evidence chain is by design
  unverifiable *by* the pointer system it feeds; it is verifiable only by
  independent `git show` comparison (which I did, and it checks out).
- Overlap disclosure: the FIFO-hang on `--input`/`--claims` (missing
  `O_NONBLOCK` at `_read_beneath` final open) is SentinelClaimInput's finding;
  not credited here.

### 5. Checks the parent should run after integration (not run by this seat)

- `python3 corpus/feature-claims.py --selftest` (recorded PASS cases=10).
- `python3 corpus/revision-audit.py --selftest` (manifest expects cases=11;
  I verified logic and the live `--history` run, not the fixture suite).
- `bash corpus/claim-ledger.sh --selftest` (manifest expects 108) and the
  R21-02 census row — host-bound rows stay skipped per contract.
- `bash corpus/sources-census.sh` for R21-02's `rows=21 … entries_sourced=4
  legacy=21` expectation — grep-verified row counts (43 `R\d` ledger rows,
  69 stamp rows) but the census itself was not executed.

### Limits

Public GETs were `read`/curl page fetches; I compared text presence, not the
pinned byte digests (earlier Fetch-hash representation is undisclosed, and
the lessons explicitly treat those as unrepeatable point observations). My
GETs confirm qualifier text and feature titles, so they bound the
decision-relevant semantics but cannot certify `source.sha256` cells. I did
not rerun whole suites; only the three phase runs, one audit run, and six
`--input` probes were executed.
