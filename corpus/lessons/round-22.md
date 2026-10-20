source: S017, S018, S019, S020
  S021 (OpenBao token lifecycle, Version 2.7.x)
verified-at: 2026-10-20 (public documentation opened; no account or vault probe)
recheck: on-release — reopen both feature-specific Broker pages independently and the setup eligibility requirements.

# Round 22 — qualifier calibration and revision-accounting repair

Frozen starting revision: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Claims frozen in `plans/round-22.md`: C1 calibration (feature-bound admit/reject decisions, not authored row counts); C2 freshness (revision mismatch/deletion accounting, not source currentness by restamping). The outside round-21 verdict remains **REJECTED-HONEST-STOP**; this correction never changes its historical admission result. No depth claim is made.

## Gate

Public pages opened by the author 2026-10-20; all quotes below are at most 25 words and name their location:

| new row | URL | located quote | admission scope |
|---|---|---|---|
| S017 | https://www.1password.dev/brokered-access/github-actions/ | title: “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | Actions feature status only; Business-account prerequisite from introduction |
| S018 | https://www.1password.dev/brokered-access/custom-workflow/ | title: “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | Custom-workflow status independently of the setup guide; Step 1 beta desktop app and Step 3 JavaScript SDK note also opened |
| S019 | https://www.1password.dev/brokered-access | introduction: “administrators can set up a supported integration in their 1Password Business account” | Business eligibility and GitHub Actions requirements; not a uniform status label |
| S020 | https://1password.com/blog/1password-credential-broker-public-preview | §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | announcement-time feature split; introduction names EPM Business eligibility |
| S021 | https://openbao.org/docs/concepts/tokens/ | §Token Time-To-Live: “After the current TTL is up, the token will no longer function” | OpenBao 2.7.x token TTL; following sentence includes associated leases; no Vault-token or KV-retention support |

S017–S020 added A/mined; registry changes to existing status/recheck/used-by fields: **none**. S019/S020 explicitly supersede S007/S006's incomplete qualifier coverage while preserving their original rows. The custom-workflow unopened lead is advanced by an appended disposition note rather than erased. Search: question = whether the two Broker paths share status/eligibility; where = setup guide, its two feature links, vendor announcement; identified/screened/included = 4/4/4, excluded = 0. Stop: each named feature status and setup prerequisite resolved; no unrelated OIDC federation or scanning research absorbed.

Admitted corrections: E1's appended round-22 erratum (Actions public preview, custom OIDC public beta, Business eligibility, deployment/SDK restrictions); E3's appended round-22 reading (product-separated source support, no Vault-to-OpenBao inference and no KV retention guarantee). These correct held ground, not new coverage-map entries. Rejected: uniform Broker preview status; eligibility-free Broker availability; OpenBao TTL supported solely by Vault docs; no-lease interpreted as never-deleted. Reasons: QA9/QA10, QA2/QA8. The source-registry/citation checker is not a content verifier.

Outside spot-check for this round is not self-attested. L2 seats belong to the author lane; independent non-author closure is the parent's subsequent duty. The previous outside admit disagreement is accepted as evidence of failure, not called agreement because the verifier agreed with the diagnosis.

## Mistakes

| id | class | evidence pointer | captured-by before | fix |
|---|---|---|---|---|
| M22-1 | feature-status link and eligibility omission; cross-product attribution | `corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication; E1/E3 appended errata | QA9 stated qualifier preservation but lacked explicit feature-link traversal | QA10 requires opening each feature-specific status link and each product's own support; C1 targets known bad admits and bounded valid controls |
| M22-2 | authored row count mistaken for calibration | same outside adjudication: C2 failed, score held 9 | none | QM13 rejects count-of-criteria/header proxies; correctness and false admissions must be measured against source-grounded expected decisions |
| M22-3 | dropped revision-pin membership and unexplained expectation rewrites | same outside adjudication; `kagi-shokunin/.ufo/waves/round-22/frozen/before/corpus/stamps.tsv` and `claim-ledger.tsv` | QM5/QM12 required updates but not preserved migration reasoning | QM14 requires old/new migration evidence, membership restoration or itemized justification; byte hashes never promote absent source facts to current |
| M22-4 | collision-risk scratch extraction | parent notice concerning FixCellParser's `/tmp/kagi-shokunin` extraction | assigned unique private-clone contract | preserve unexpected directory; same identity confined to `/tmp/kagi-r22-FixCellParser`; no unsupported loss/restoration claim and no reported live-lane mutation |

## Revision accounting

Before measurement `kagi-shokunin/.ufo/waves/round-22/before.json` observes **six**, not five, stale stamp records at the starting revision: the four historical-source errata entries, round-18 lesson and LOG. The outside verifier's five-stamp observation is historical; the current extra LOG mismatch is recorded, not hidden. Compare hash, newline count and byte count to each recorded row; this measures pointer integrity only. Frozen before inputs carry SHA-256 digests in `kagi-shokunin/.ufo/waves/round-22/frozen/before/expected.json`.

No live host-private gate is authorized here. QM12's safe-row substitute is used only if executed and recorded after integration; host-bound rows must remain explicitly skipped. `cells` parser repair must preserve all actual scored-section completeness guards and treat the explicitly blocked interactive attempt as non-score prose, never delete its heading.

### Nine deleted diff lines: replacements, not nine lost members

The outside reviewer compared `aea7a4301` → `e1544c194fddf1bb073b3946847b4526f326ad73`.
`kagi-shokunin/.ufo/waves/round-22/round21-migrations.json` preserves each old and new TSV
record from `git show <revision>:corpus/stamps.tsv` and
`git show <revision>:corpus/claim-ledger.tsv`. Exact first-column set
difference gives **zero removed stamp members**, not nine; nine old lines
were replaced by new pins for the same paths:

| path | reason the active snapshot changed |
|---|---|
| LOG.md | round-21 appended work record; the current sixth stale pin is separately recorded |
| PROVINCE.md | documented knowledge core/frontier and sibling-boundary map appended |
| SCORECARD.md | round-21 evidence/claims and capabilities added |
| SHONEN.md | canonical checklist replaced author-only checked boxes with assertions |
| SKILL.md | source-census and machine-credential/lifecycle decision rows |
| corpus/README.md | three admitted-entry index rows, frontier/gaps and source gate index |
| corpus/claim-ledger.tsv | byte-probe and source-census expectations changed with measured behavior |
| corpus/knowledge/op-ref-consumption.md | six byte observations and bounded reading appended |
| corpus/op-ref-probe.sh | inherited byte arm adopted and remeasured, not authored anew |

The same artifact preserves the **four changed expectations**: R12-02
29→36 executed selftest cases; R12-03 56→63 stamp records; R13-01 20→23
round headings; R14-01 21/18→24/21 declarations. A fifth row, R13-02,
changed its explanatory note but retained expectation 35. A separate
`kagi-shokunin/.ufo/waves/round-22/historical-migrations.json` covers only the later
post-landing correction span, where R21-03 changed 40→47 selftest cases;
it is not substituted for the full-span record.

**Append-only justification:** LOG, lessons, QUALITY and immutable source-row
fields retain history. The two TSVs are **current executable snapshots**:
claim-ledger's documented `stamp` mode replaces the unique-path table and
refuses membership shrink unless explicitly pruned; duplicate active rows
would be malformed, not an append-only history. Restoring old digest/count
values would deliberately reinstall stale expectations. Instead this round
preserves every old/new line and rationale in committed evidence, keeps
every member and records future migrations separately (QM14). This is not
permission to rewrite filed narrative or to select a new expectation merely
because it makes a run green. Actual post-integration outputs must match.

### Active reading and source-consumption update

The four-page Broker search above remains its bounded search. A separate
targeted OpenBao token recheck opened S021 on 2026-10-20 (one identified,
screened and included page; zero excluded) because E3 borrowed product
scope. Total author-opened source rows added this round: S017–S021,
all A/mined. Count by source identifiers in the Gate table, or run the
round-end source census and compare 16→21 rows.

After the first four rows were drafted, their `used-by` changed:
S017, S018, S019, S020 each
`corpus/lessons/round-22.md` →
`corpus/lessons/round-22.md, corpus/knowledge/feature-bound-credential-review.md`.
Their status/recheck did not change; original S001–S016 fields did not
change. S021's initial used-by includes both files.

`corpus/knowledge/feature-bound-credential-review.md` is the **active corrected
reading** of the defective Broker and token table rows. It carries the
provenance trio first, per-feature eligibility/status and explicit per-product
limits in its own sentences. It does not rely on an erratum to rescue a
still-defective active sentence. Older bodies are preserved history; no
new-coverage expansion is claimed. No full-page content digest is inferred
from a read-tool representation: earlier undocumented Fetch hashes are
historical point observations, not presently reproducible drift pins.

The build wave read a frozen base but L1 appended corrections while its
read-only research was in flight. Seats explicitly recorded that movement;
their live-tree mismatch totals are **not** the before measurement. The
frozen commit and before snapshot are authoritative. Production integration
is frozen for the later falsification wave so its evidence names one tree.

### Additional bounded findings and dispositions

- CriticAdmission's same-page attack is retained: the custom-workflow page
  also contains public-preview words in shared chrome. The feature's own
  title says public beta. QA10 is applied at the named status anchor, not
  by whole-page substring. Its rejection/control belongs to C1's executable
  demonstration, not a claim that keyword scanning proves vendor truth.
- The source handshake for the preserved E1/E3 headers still covers their
  original source fields, not later erratum body citations. That bound is
  explicit: the new **active** corrected entry carries S017–S021 on its
  provenance field and every corresponding used-by link. No old header is
  silently rewritten to make the census stand in for semantic review.
- E3's “following sentence” wording in the early round-22 note means the
  continuation of the same TTL sentence after the dash, not an independent
  source statement. “No lease” establishes no value-deletion guarantee.
- The current header-migration plan is intentionally not executed:
  ReviewHeaders found the legacy corpus's schematic reference prose would
  enter the census credential detector. Neither weakening that detector
  nor counting appended headers is a freshness/depth improvement.
- The helper-only sandbox gate was released by Main after its parsing,
  sandbox and live-recovery verification notice. No lane commit/recover
  was attempted while the hold applied; all landing remains helper-owned.
- Build observation boundary breaches are disclosed, not credited:
  Entry07's launcher version probe triggered mise installation of
  node@26.12.0 and npx resolution of opencode-ai; Entry03/Entry16 made
  refused passive loopback health/CDP observations. No account/vault action
  was reported. These were unnecessary to static corpus research; the
  falsification context expressly prohibits launchers/package tools and
  host loopback probes. No host rollback or recovery is claimed.

Source-epoch accounting: the early four-page Gate search and later single
OpenBao recheck are distinct. Existing raw Fetch hashes are unrepeatable
point observations where the representation/build is unknown; they are not
silently replaced or called unchanged content. For full post-landing
correction pin values, not just the net nine-line range, see
`kagi-shokunin/.ufo/waves/round-22/historical-correction-pins.json`.

### Executed gate development and causal separation

The first integrated invocations were genuinely red:
`kagi-shokunin/.ufo/waves/round-22/initial-checks.json` records
FC-FEATURE-SCHEMA and revision selftest failure. Two scoped implementation
corrections fixed the causes, not the symptoms: unasserted status has no
evidence obligation, while asserted statuses still require their bindings;
the Git-root check accepts the command's normal newline. The same failed
commands then passed their intended checks in `repaired-checks.json`
within that evidence directory. Ledger/source selftests were not rerun
just to reconfirm their already-observed green results.

| id | class | evidence pointer | captured-by before | fix |
|---|---|---|---|---|
| M22-5 | unexercised new gate rejected its valid control | `kagi-shokunin/.ufo/waves/round-22/initial-checks.json` | QM3/QM9 require real failure/dispatch evidence, not static case totals | preserve red output; correct unasserted-status obligation and newline semantics; `repaired-checks.json` records feature 10-case and revision 11-case selftests green |

The independent-input interface is essential: changing a pinned authority
manifest is a tamper/setup test, **not** a held-out qualifier adjudication.
`--input` accepts one unlabeled typed record under the root against the
unchanged trusted catalog. Its valid, omitted-eligibility, same-page status,
cross-product, under-citation and reordered-set cases actually execute.
The source/catalog/control digest pins do not authorize arbitrary prose
or infer vendor truth.

C1 before phase: ten bad records rejected, with two false-claim and eight
bar-fail outcomes; after: four bounded controls admitted; boundary: three
unjudgeable records return 2 and are excluded. Authority labels distinguish
prior outside findings from construction/verbatim controls; no new outside
agreement or overall accuracy scalar is claimed.

C2 red-before is `before-runnable.json`: the frozen-base clone has six stale
records, zero missing/dropped/added/invalid, exit 1. `pin-only-ablation.json`
changes **only** that isolated clone's stamp snapshot and the same audit
returns zero stale/dropped/added, exit 0; no C1 files were copied there.
C1's working demonstration occurred while live pins were still stale.
The two mechanisms are therefore causally separable despite atomic shared
bookkeeping. Restamping proves pointer integrity only, never currentness.

The original SCORECARD “both rows” capability note refers to the two
round-21 rows. The new feature-review row first worked in round 22 and is
supported by execution, not inserted as a promise.

### Fresh-wave closure and corrections

The genuine second wave returned all 66 reports after reading helper-landed
H1 `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. All 71 manifest inputs stayed
byte-identical through the wave. The four independent typed-input mutants
(eligibility omission, status swap, cross-product attribution and missing
authority) were killed while paired valid controls remained admitted.
Those are bounded semantic/bar decisions, not manifest-tamper refusals.
The two waves contain 130 unique seats; all four dead Haiku scribes remain
uncredited. Resumed original identities implement corrections, not new seats.

| class | evidence pointer | captured-by | disposition |
|---|---|---|---|
| FIFO blocked before regular-file check | `kagi-shokunin/.ufo/waves/round-22/falsify/SentinelClaimInput.md` | QM3/QM9 | nonblocking same-descriptor open, explicit FIFO self-invocation refusals; a watchdog timeout never counts as pass |
| malformed/case-variant H2 scores disappeared while other cells kept CLEAN | `kagi-shokunin/.ufo/waves/round-22/falsify/RunCellsMalformed.md` | QM9 and all-axis/vacuity contract | CommonMark H2 recognition, reserved Round-word guard and complete pre/post token; exact blocked attempt remains the only exception |
| administrative metadata/hardlink fingerprint boundary; long SHA256 abbreviation accepted | `kagi-shokunin/.ufo/waves/round-22/falsify/SentinelHistoryInput.md` | QA5/QM9 | admin/hardlink refusal and canonical full-ID equality; old false-clean fixture results preserved |
| ignored positional mode invoked full verify; summary contradicted parser/membership arithmetic | `kagi-shokunin/.ufo/waves/round-22/review-evidence-quarantine-closure.json` | QM2/QM13 | pre-surface argument rejection; unsupported review checks withdrawn and uncredited, no rerun used to invent missing receipts |
| reference metadata copied into build reports | `kagi-shokunin/.ufo/waves/round-22/privacy-redactions.json` | QA5 | four spans removed before H1; counts-only red-before/repaired evidence retains no original reference path |
| pre-existing non-author verifier looked like newly authored content in migration journal | `kagi-shokunin/.ufo/waves/round-22/pin-migration-errata.json` | QM14 | old stamp remains null, but base-observed digest/disposition restored in a separate correction record |

Safety is **not** certified clean: two fresh seats acknowledged full-verify
invocations against the no-host-gate boundary, including untagged R18-01.
No complete per-row private-surface receipt survives from the unreliable
review seat, and no clean whole-round secret-access attestation is inferred.
No private/account data was re-read to resolve that uncertainty. Main's
final checks use only explicitly safe rows; the unauthorized checks are
not credited. The indirect Node installation and scratch-clone collision
also remain disclosed. Admission belongs to the parent's independent
non-author closure, not this lane's engineering verdict.

The original CriticNoTrade name collided across waves; the actual task
tool created fresh `KagiR22.CriticNoTrade-2`. Registry correction uses the
original spawn receipt, never a replacement/respawn task. A registry-only
rerender reset the mistaken assignment and was **not dispatched**.
`task-receipt-build.json`, `task-receipt-falsify.json` and
`assignment-correction.json` in the round evidence preserve the distinction.

Late S022/S023 source corrections are consumed by
`corpus/lessons/round-22-source-errata.md`; the original rows stay immutable.
The same fresh source identities compared the final rows with their
already-opened primary pages. Counts remain 10 bad / 4 bounded / 3 boundary
records in C1; JWT login remains out of profile. Catalog limitations and
inert reference/quote-binding corrections are explicit, not new metrics.
