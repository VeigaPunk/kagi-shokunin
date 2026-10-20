# CriticAdmission — round-22 attack on E1/E3 admit/reject under feature-specific docs

Seat: KagiR22.CriticAdmission (critic, read-only). Axes: calibration, freshness.
Exact read revision: frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`
plus uncommitted working-tree material observed mid-flight (`corpus/QUALITY.md`
QA10/QM13/QM14; `corpus/SOURCES.md` S017–S020; `corpus/lessons/round-22.md`;
E1/E3 round-22 errata; `.ufo/waves/round-22/{expected,*}migrations*.json`,
`before.json`, `falsify-spec.json`). Live re-open of the three public
1Password.dev Broker pages and the OpenBao tokens page on 2026-10-20
(fetches below); no account, vault, or host-private surface touched.
Sibling coverage avoided: CriticCalibration owns the authored-label/metric
attack; this seat owns admission-decision integrity under the
feature-specific documentation itself.

## Counterexample (verified on live bytes, not hypothetical)

**Claim under test:** "Credential Broker custom workflows remain accessible
in public preview" — cite `S018` (the *correct* feature-specific row:
`https://www.1password.dev/brokered-access/custom-workflow/`).

I fetched that page today (HTTP 200, sha256 `d0890c11edaa85d3…`, 2026-10-20).
Stripped page text contains:

- `public preview` ×4 — including the shared site navigation that every
  page in the section renders: "Credential Broker (public preview)"
  appears in the nav block on the *custom-workflow page itself*, plus
  `.op-status-badge` CSS comments ("Beta, Early Access, Public Preview").
- `public beta` ×3 — the true status, but located **only** in the page
  `<title>`/`<h1>`: "…custom workflows at runtime (public beta)".

So the cited feature-specific page literally carries the *wrong* status
string, at a different anchor (shared navigation, not the feature's own
title). Any admission mechanism whose evidence check operates at page
granularity — "the cited feature-specific page exists and contains the
claimed status" — **admits** the false claim. The status is bound to the
page, not to a named anchor region, so "feature-specific docs" is a
page-level discriminator and the E1 defect (guide-level label generalised
to a feature) recurs one level down: nav-level label generalised to the
page's own feature. The S018 `anchor` cell ("Page title, introduction,
Step 1, Step 3 note") is prose; nothing typed binds feature → status →
anchor region.

This is the same defect class the round exists to refuse, at finer
granularity: the corrected corpus can be cited for the exact overclaim
it was built to kill.

## Supporting evidence — two duplicate-authority/provenance holes

1. **Supersession is prose-only.** S019's `teaches` cell reads
   "supersedes S007", but S007 remains a live tier-A `mined` row whose
   `anchor` still advertises "Page title (public preview)". Under the
   typed census (`bash corpus/sources-census.sh` →
   `SOURCES_CENSUS: CLEAN (rows=20 A=18 … mined=18 …)` — run today,
   read-only), both authorities are equally live. A claim "both workflows
   are public preview [S007]" — the original E1 overclaim — still resolves
   to a valid tier-A anchor. The refusal exists only in the reviewer
   reading `teaches` prose; no field retires S007's status authority.
   Symmetric failure: a checker that *does* honour "supersedes S007"
   wholesale also kills S007's still-true mechanism facts (claims-match,
   workflow-duration, integration-key custody) that E1 §Does-not-establish
   still cites — false reject. Both decisions are wrong, produced by the
   same untyped `supersedes` prose.

2. **Correction rows carry no byte provenance.** All 16 round-21 rows
   (S001–S016) record `Quote:` + `Fetch sha256:`; S017–S020 record
   neither (verified: `grep -c 'Fetch sha256' corpus/SOURCES.md` → 16).
   Consequences:
   - The admitted E1/E3 corrections cannot be reified from the corpus:
     if the feature page relabels beta→preview before `recheck: on-release`
     fires, nothing proves today's reading — the recheck trigger has no
     baseline bytes.
   - The E1 erratum asserts "Enterprise Server and Enterprise Cloud with
     data residency are unsupported; GitHub Free organizations cannot use
     this integration for private-repository workflows [S019]" — true on
     the live guide page (verified today: "hosted on GitHub Enterprise
     Server or GitHub Enterprise Cloud with data residency aren't
     currently supported"), but **no located quote exists anywhere in the
     corpus** for it. The bounded control repeats E1's original landing
     defect: a qualifier resting on page text never carried into the
     evidence record (QA6/QA9 shape).
   - E3's erratum quote ("After the current TTL is up, the token will no
     longer function") verified live on the OpenBao 2.7.x tokens page —
     but again with no digest pinned in the corpus.

## Expected failure

- A feature-claims adjudicator keyed on "feature-specific row cited +
  page contains status" **admits** "custom workflows are public preview
  [S018]" — an E1-class status conflation counted as a correct admit or,
  in a labelled fixture, scored as the gate agreeing with an author who
  also read the nav badge. The round's C1 claim ("known bad admits
  refused") fails on a same-page status swap, not just the cross-page
  conflation it was tested against.
- Under strict QA10/QA6 replay (qualifier must cite a row whose recorded
  quote carries it), the admitted corrections themselves **fail
  admission**: S017–S020 hold no recorded quote/digest, and the E1
  erratum's deployment restrictions have no located quote. The correction
  is admitted on less provenance than the rows it supersedes.
- Freshness: undigest-ed `opened 2026-10-20` provenance plus an
  unretired stale authority means the `recheck:`/`Reverify:` clocks can
  never distinguish "vendor changed status" from "record was prose".

## Impacted axes

- **calibration (primary):** wrong admit on the discriminating same-page
  case; possible wrong reject of the corrected controls under strict
  replay; stale authority S007 still admits the original overclaim.
- **freshness (secondary):** status provenance without byte digests is
  un-reifiable at recheck; supersedes-in-prose leaves the ledger's
  authority set ambiguous over time.

## Smallest safe correction (bounded, three items)

1. **Anchor-region status binding.** On S017/S018 (and in QA10), record
   the status quote *with its region* — `anchor: <title>` — and require a
   status claim to match the quote's region, not the page's bytes. Add one
   fixture row: "public preview [S018]" must reject because the title
   quote says beta even though the page contains "preview". Kills the
   nav/footer/sidebar laundering of feature status.
2. **Carry `Quote:` + `Fetch sha256:` on S017–S020** (the contract permits
   them; all prior rows have them), including the guide-page sentences
   backing the E1 erratum's Enterprise-Server/GitHub-Free restrictions.
   The admitted control becomes reifiable instead of prose-only; the
   `recheck` trigger gets baseline bytes.
3. **Type the supersession.** A `supersedes:` field (or `status:
   superseded` + `superseded-by:` id) naming *which qualifier* retires —
   S007's status authority ends; its mechanism authority stays live.
   Neither "both rows live" (false admit) nor "whole row dead" (false
   reject) remains reachable.

Fixable defect, not a judge-must-reject tradeoff: the correction is
additive typing on existing rows plus two fixture rows; nothing needs
deletion.

## Limits

- Fetches are today (2026-10-20); the row author's 2026-10-20 fetch may
  differ in bytes — which is precisely why the missing `Fetch sha256`
  matters. No tool installed; pacman untouched (host pause honoured).
- The corrected claims' *content* verified true on live pages (beta
  title, Business eligibility, Enterprise/GitHub-Free restrictions,
  OpenBao 2.7.x TTL sentence). The defect is demonstrability and binding
  granularity, not proposition truth.
- `stamps.tsv` pins for the four modified corpus files are stale
  mid-flight (QUALITY.md, SOURCES.md, both knowledge entries) — expected
  before integration; only a defect if landed without a QM14 migration
  record. `R21-02`'s `rows=16 A=14` expectation will fail against the
  landed 20-row registry and needs exactly that migration record.
- Checks the parent should run after integration:
  `bash corpus/sources-census.sh` (expect `rows=20` — pin migration for
  `R21-02` required); `bash corpus/claim-ledger.sh cells` (post
  FixCellParser); the feature-claims fixture must include the same-page
  status-swap row above and score it reject.

Counterexample: "custom workflows are public preview [S018]" — the cited
feature-specific page's fetched bytes contain the claimed status at the
wrong anchor (shared nav, not the feature title). Expected failure:
admitted as an E1-class conflation by any page-granularity evidence
check, while the strict-evidence replay simultaneously rejects the
digest-less correction rows. Required bounded fix: anchor-region status
binding, `Quote:`/`Fetch sha256:` on S017–S020, and a typed, qualifier-
scoped `supersedes:` — the three items above.
