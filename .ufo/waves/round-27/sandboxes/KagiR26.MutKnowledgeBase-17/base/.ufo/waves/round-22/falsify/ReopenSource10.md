# ReopenSource10 — S010 reopen, S017–S020 qualifiers, revision accounting

Seat: `KagiR22.ReopenSource10` (read-only leaf; no subagents, no production edits, no live
account/vault/workflow action). Input under attack: master tip
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`; the frozen input hashes are those named in
`kagi-shokunin/.ufo/waves/round-22/integration-manifest.json`. Base
`c2cab35bc92e57e39e5489bac3386db078345b3f` is historical BEFORE, not the falsification input.
Observed 2026-10-20. The four dead W1 seats are not credited and this report is not their
replacement.

## Frozen bytes observed (all match the integration manifest)

| path | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 | 19721 |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | 995 | 47434 |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | 1040 | 45532 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | 7213 |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` | 548 | 20857 |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 | 15700 |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` | 10 | 1804 |
| `corpus/knowledge/sops-age-key-rotation.md` | `a6b14ff7555fb972368d23e1e57bfb62170daa65ee4f2bd34521ff6819d407a7` | 112 | 7591 |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 43 | 4440 |

## S010 — independent reopen: PASS

URL `https://getsops.io/docs/usage/identities/key-groups/`, reopened 2026-10-20 with
`curl -sS -L` (raw HTML, 36,366 bytes, HTTP 200).

- Anchor: the page carries `<h2 id=key-groups>` with heading “Key groups” (§Key groups), so the
  row's locator resolves to a real heading.
- Quote: “keys from multiple groups are required to decrypt a file.” (§Key groups, URL above,
  2026-10-20). Present verbatim in the section text.
- Locator: footer reads “Last modified May 15, 2026: Add page descriptions. (9b7b84e)”; the row's
  “last modified 2026-05-15, docs commit `9b7b84e…`” is exact.
- Pin: my fetched HTML sha256 is
  `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`, identical to the row's
  recorded `Fetch sha256` from 2026-10-19. For this representation and date the pin is
  reproducible, not merely a point observation.
- Teaching: the section states the data key is split by Shamir's Secret Sharing, each key group
  holds a fragment, and a configurable threshold of fragments is needed; the row's key-group /
  threshold summary is supported. The quoted sentence alone does not establish the default
  threshold or `shamir_threshold`; those come from adjacent sentences under the same anchor.
- Immutable row: the S010 row is byte-identical (`e3feaa5d2ccacf497ba7ef4ec4f25e122ea5c42f1232ad020a64be244f65f0aa`)
  across `c41af82`, `e1544c1`, `8924b2e`, `6697761`, `8103a88`, `c1e1c42`, `a09a7ae`, `2848356`,
  `2039511`, `0b07548`, and `8ada17a`. Base→tip parsing finds **0 changed and 0 removed** existing
  source rows; only S017–S021 were added.

## S017–S020 — feature-specific status and eligibility: PASS, no conflation

All pages were reopened 2026-10-20; the `.md` alternates are linked from the live pages.

| row | observed status anchor | observed eligibility | row claim | verdict |
|---|---|---|---|---|
| S017 | H1: “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”; badge “Public Preview” | intro: “If an administrator has connected your GitHub organization to your 1Password Business account” | preview; administrator first connects the organization to Business | supported |
| S018 | H1: “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)”; badge “Beta” | intro: OIDC provider connected to Business; Step 1: “latest beta release of the 1Password desktop app”; Step 3: “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | beta; OIDC-in-Business; beta desktop app; JavaScript SDK only | supported |
| S019 | H1: guide-level “(public preview)”; intro: “administrators can set up a supported integration in their 1Password Business account” | GitHub.com hosting; GitHub Enterprise Server / Enterprise Cloud with data residency unsupported; GitHub Free private-repository workflows unsupported | supersedes S007's scope; guide label does not settle custom-workflow status; Business and GitHub.com/private-repository qualifiers separate | supported |
| S020 | announcement published 2026-07-28; “available for all Enterprise Password Manager Business customers to start using right now”; “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | EPM Business at product level; announcement-time feature split | EPM Business eligibility; Actions preview versus custom-OIDC beta | supported |

Status separation is real, not a shared-page substring: the guide's “(public preview)” title is
**not** used for the custom-workflow feature. In `feature-claims.json`, the
`op_cb_custom_oidc.release_status` evidence lists `S018-title` and `S020-status-split` only;
S019 supplies only the GitHub Actions requirements/exclusions (`S019-business`, `S019-github-com`,
`S019-enterprise-host`, `S019-free-private`). S020 is typed as announcement-time, not a live
status oracle. The pre-existing S006/S007 rows are byte-identical to base.

## Executed checks (authorized local fixtures only)

C1 (`python3 corpus/feature-claims.py …`):

- `--phase before`: exit 1; 10/10 bad records rejected, `false_claims=2 bar_failures=8
  false_admissions=0 misses=0`, including the outside-verifier E1 status-conflation and E3
  Vault-only/cross-product records.
- `--phase after`: exit 0; `CLEAN admitted=4 false_claims=0 bar_failures=0 false_admissions=0`.
- `--phase boundary`: exit 2; 3 unjudgeable records, `scored=no`.
- `--selftest`: exit 0, `PASS cases=10`.

C2 (`python3 corpus/revision-audit.py --history c2cab35…`): exit 0,
`CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`. The added six are the round-22 artifacts
listed in `pin-migrations-integration.json`; nothing was dropped.

Nine-line span (full hashes `aea7a4301034aa9160ada69457a6427f77064169` →
`e1544c194fddf1bb073b3946847b4526f326ad73`): `git show` first-column set difference gives
**0 removed members** and exactly **9 changed stamp records**. Each old/new line in
`round21-migrations.json` matches `git show` byte-for-byte; the nine paths are LOG, PROVINCE,
SCORECARD, SHONEN, SKILL, `corpus/README.md`, `corpus/claim-ledger.tsv`,
`corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`. Current stamps against the
full `aea7a4301` tree: `CLEAN (dropped=0 added=13)`; against base: `added=6 dropped=0`. No silent
deletion or restamp-only promotion was found.

Expectation migrations: `round21-migrations.json` old/new rows match `git show` at both ends
(R12-02 29→36, R12-03 56→63, R13-01 20→23, R14-01 21/18→24/21, R13-02 note-only retained 35).
`pin-migrations-integration.json` `claim_changes` match base and current exactly (R11-09 97→108,
R12-03 63→69, R13-01 23→25, R14-01 24/21→25/22, R18-02 retained 11, R18-03 97→108, R21-02
16→21 rows, R21-04 39→43, plus new R22-01…04). Independent counts: stamps 69, claim rows 43,
R1x rows 35, SCORECARD round headings 25, substrate tags 11, census `rows=21 A=19 C=2
mined=19 rejected=1 entries_sourced=4 legacy=21`; `claim-ledger.sh --selftest` 108 cases,
`claim-ledger.sh docs` `entries=25 row_linked=22 by_hand=3`, `sources-census.sh --selftest` 47
cases, `op-ref-probe.sh --selftest` 36 cases. All match the pinned expectations.

## Concrete supported claim

S010 is faithful to the live page: the §Key groups section carries the quoted requirement that
keys from multiple groups are needed, the footer dates the page May 15, 2026 at docs commit
`9b7b84e…`, and the row's recorded 2026-10-19 fetch digest reproduces exactly today for the raw
HTML representation.

## Scope limit

The typed plan value `enterprise_password_manager_business` for both Broker features is sourced
only from S020's product-level announcement; S017/S018/S019 say “1Password Business account.”
No reopened page states that “1Password Business” and “Enterprise Password Manager Business” are
interchangeable. The active review keeps the two descriptions verbally separate, but the typed
catalog composes them into one canonical plan set; a correct page-derived claim using the docs'
label would be rejected as outside the set. Confidence high on the textual mismatch; the
equivalence itself is an inference, not an observed vendor statement.

Secondary limits (not falsifications): (1) S020's catalog digest
`55bf23fe6e56375a…` is not reproducible — three consecutive fetches returned three different
byte hashes (the S006 note in `Entry15.md` already records this); only a meta-only digest is
stable, so the catalog value is a point observation, not a drift pin. (2) S018/S019 quote text is
normalized rendered text (markdown link markup removed; one whitespace-adjacent punctuation
normalization), not a raw-byte substring; S017–S019 raw HTML digests do reproduce. (3) The active
SOPS entry's last bullet still says “independent custodians” while S010 says nothing about who
holds fragments; only the appended round-21 erratum supersedes it, so the active body alone
overreads S010.

No falsifying contradiction was found in the assigned scope: no false S017–S020 status or
eligibility decision, no false admission in the 10-record before phase, no unexplained stamp
deletion, and no expectation mismatch.

## Proposed correction (not applied; production inputs are frozen)

1. Add a representation/type field beside each catalog `sha256` (or label S020's value
   “point observation; page non-byte-stable”) so no future check treats it as a drift pin; use the
   stable meta digest plus the dated quotes as the durable pair.
2. License or split the plan vocabulary: either cite a vendor page equating “1Password Business”
   with “Enterprise Password Manager Business”, or carry two plan identifiers with a documented
   composition, so a correct page-derived claim is not false-rejected.
3. In the SOPS entry, point the active “independent custodians” bullet at the appended erratum
   (or change it to “independent key groups” when production edits resume).

## Checks the parent should re-run after integration

`python3 corpus/feature-claims.py --phase before|after|boundary` and `--selftest`;
`python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`;
`bash corpus/claim-ledger.sh --selftest`; `bash corpus/claim-ledger.sh docs`;
`bash corpus/sources-census.sh` and `--selftest`; `bash corpus/op-ref-probe.sh --selftest`.
Do **not** run host-bound R12-01/R21-01; they require `op` and host state.

## Limits

Public documentation GETs and local fixtures only; no account, vault, workflow, SDK, deployment or
host loopback was exercised. S020's page is per-request dynamic; quote checks used the rendered
markdown/HTML representations, with link markup stripped for comparison. The S010 hash match is
for the raw-HTML representation and the 2026-10-20 fetch, not a claim that the page is immutable.

## Exact read revision and files

Revision `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. Read: `corpus/SOURCES.md`,
`corpus/feature-claims.json`, `corpus/feature-claims.py` (schema and selftest sections),
`corpus/stamps.tsv`, `corpus/claim-ledger.tsv`, `corpus/revision-audit.py`,
`corpus/knowledge/sops-age-key-rotation.md`, `corpus/knowledge/feature-bound-credential-review.md`,
`corpus/knowledge/onepassword-machine-credentials.md`, `corpus/lessons/round-22.md`,
`corpus/lessons/round-21-verifier-spotcheck.md`, `plans/round-22.md`, and the round-22 integration,
migration and check evidence JSONs. Live pages: S010, S017, S018, S019, S020 (all listed above).
