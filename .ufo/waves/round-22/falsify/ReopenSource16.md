# ReopenSource16 — S016 reopen, S017–S020 feature status, and revision accounting

## Assigned decision and axes

C1 calibration and C2 freshness, seat `ReopenSource16` (leaf scout; no delegation).
Scope: reopen S016's exact URL; verify its teaching and located anchor; compare the
immutable original row and round-22 lesson usage; examine S017–S020 feature-specific
status/eligibility separately; confirm no immutable-field mutation in original rows.
One concrete supported claim and one scope limit are named below.

No production implementation, corpus, lane, or host state was edited. The only file
written by this task is this report. No W1 seat is credited; the missing/dead W1
scribes remain uncredited, and every observation below is my own reopen.

## Frozen identity measured

Lane edits are frozen; the input bytes below are the ones actually read.

| Input | SHA-256 | Lines | Bytes |
|---|---|---:|---:|
| git HEAD (`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, 2026-10-20 18:30:53 -0300) | commit id | — | — |
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` | 378 | 12,749 |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 | 19,721 |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 | 15,700 |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` | 10 | 1,804 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | 7,213 |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 | 17,770 |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 43 | 4,440 |
| `corpus/knowledge/onepassword-machine-credentials.md` | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` | 80 | 9,048 |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | `f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610` | 158 | 11,319 |
| `corpus/SOURCES.md` at base `c2cab35…` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` | 43 | 14,261 |
| `.ufo/waves/round-22/frozen/before/corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` | 43 | 14,261 |

The integrated `SOURCES.md` digest matches the manifest entry, the `stamps.tsv` row,
and the current bytes; the frozen-before copy is byte-identical to the base revision.
No current byte was inferred from a mid-build report.

## F1 — S016 independently reopens and verifies (calibration)

URL reopened 2026-10-20 by public GET: `https://openbao.org/docs/concepts/tokens/`.
The response canonical is the same URL; the page title is `Tokens | OpenBao` and the
page displays `Version: Version 2.7.x` (also `meta-docsearch:version: 2.7.x`).

Located anchors and exact text:

| URL, date | Heading | Quote (≤25 words) |
|---|---|---|
| `https://openbao.org/docs/concepts/tokens/`, opened 2026-10-20 | Token hierarchies and orphan tokens | “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.” |
| same page | Token Time-To-Live, periodic tokens, and explicit max TTLs | “After the current TTL is up, the token will no longer function” |
| same page | The general case | “This value is allowed to override the system max TTL -- it can be longer or shorter” |
| same page | Token type comparison | table distinguishes service from batch tokens (renewable, manually revocable, periodic, explicit max TTL) |

The row's `teaches` field — OpenBao documents token policy and TTL/renewal behavior,
including revocation of child tokens and their leases — is supported by these sections.
The row's quote is exact (22 words by `wc -w`, counting the double hyphen as a token),
and both named anchor sections exist verbatim.
The page carries no displayed publication date; that is consistent with the row's
`OpenBao 2.7.x` anchor, which is a version rather than a date claim.

**Concrete supported claim.** “When a parent token is revoked, all of its child tokens
-- and all of their leases -- are revoked as well.” (OpenBao docs, §Token hierarchies
and orphan tokens, Version 2.7.x, reopened 2026-10-20.)

**Scope limit.** The quote and its page establish OpenBao 2.7.x token-hierarchy
revocation and service-token TTL behavior only. They do not establish Vault token
mechanics, KV secret-value retention/deletion, or parity between service and batch
tokens; the page's own comparison says batch tokens are not renewable and not manually
revocable. The row's stored `Fetch sha256: c083fdca…` could not be independently
reproduced from the reader representation and was not treated as a drift verdict; it
remains a historical point observation, exactly as the round-22 lesson states.

## F2 — Original rows are not mutated (freshness)

`git show c2cab35…:corpus/SOURCES.md` filtered to `S001`–`S016` versus the current file
filtered the same way: `diff` is empty. All sixteen original registry rows are
byte-identical, including `opened`, `recheck`, `status`, `used-by`, and the stored
`Fetch sha256` fields. `S006` and `S007` are also unchanged even though `S019`/`S020`
now supersede their incomplete qualifier coverage in prose.

Registry delta base → current: 16 rows → 21 rows; added `S017`–`S021`; removed 0.
The added rows are all tier A and `mined`, matching `sources-census.sh`.

## F3 — Round-22 lesson usage of S016 (freshness/calibration)

- `corpus/lessons/round-22.md` line 1 names `S017, S018, S019, S020`; line 2 names
  `S021 (OpenBao token lifecycle, Version 2.7.x)`. `S016` is correctly not re-listed
  as a newly opened round-22 source; it remains an original row.
- The lesson's statement “original S001–S016 fields did not change” is independently
  confirmed byte-for-byte (F2).
- The E3 erratum in `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` reopens
  S016 on 2026-10-20 and confines the reading to OpenBao token evidence; it explicitly
  withdraws cross-product TTL parity and KV value-retention. The active corrected
  review cites `S021` for the OpenBao token decision, not `S016`, and the old S016 row
  is preserved rather than rewritten.
- No old header was rewritten to make the census stand in for semantic review; the
  lesson says this in §“Additional bounded findings” and the headers bear it out.

## F4 — S017–S020 feature-specific status and eligibility (calibration)

Each page was reopened independently on 2026-10-20, away from the parent guide.

| Row | URL, date | Observed status anchor | Eligibility observed | Row claim |
|---|---|---|---|---|
| S017 | `https://www.1password.dev/brokered-access/github-actions/`, 2026-10-20 | H1 ends “(public preview)”; badge “Public Preview” | “If an administrator has connected your GitHub organization to your 1Password Business account” | Verified |
| S018 | `https://www.1password.dev/brokered-access/custom-workflow/`, 2026-10-20 | H1 ends “(public beta)”; badge “Beta” | “connected an OIDC provider to your 1Password Business account”; Step 1 “latest beta release of the 1Password desktop app” | Verified |
| S019 | `https://www.1password.dev/brokered-access`, 2026-10-20 | Guide H1 ends “(public preview)”; linked pages carry their own statuses | “administrators can set up a supported integration in their 1Password Business account”; GitHub.com only; Enterprise Server and Enterprise Cloud with data residency unsupported; GitHub Free private-repository workflows unsupported | Verified |
| S020 | `https://1password.com/blog/1password-credential-broker-public-preview`, published 2026-07-28, reopened 2026-10-20 | “New in this release: Custom OIDC workflows” | “available for all Enterprise Password Manager Business customers”; custom OIDC “slowly rolling out … in beta” | Verified |

Exact quotes, each ≤25 words:

| Source heading, URL/date | Quote |
|---|---|
| S017 title, `https://www.1password.dev/brokered-access/github-actions/`, 2026-10-20 | “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” |
| S018 title, `https://www.1password.dev/brokered-access/custom-workflow/`, 2026-10-20 | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” |
| S018 Step 3 note, same URL/date | “1Password Credential Broker is only supported in the 1Password JavaScript SDK at this time.” |
| S019 introduction, `https://www.1password.dev/brokered-access`, 2026-10-20 | “administrators can set up a supported integration in their 1Password Business account” |
| S020 §New in this release, `https://1password.com/blog/1password-credential-broker-public-preview`, published 2026-07-28 | “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” |

The critic's same-page attack is confirmed and correctly handled: the custom-workflow
page's shared chrome and “Related topics” list contain “(public preview)” strings, but
its own H1 and badge say public beta. Applying QA10 at the named status anchor, rather
than by whole-page substring, is the supportable method. The guide's own preview label
does not transfer to the custom-workflow feature.

All four rows' `used-by` values name both `corpus/lessons/round-22.md` and
`corpus/knowledge/feature-bound-credential-review.md`, and the read-only census
confirmed those citations resolve (`entries_sourced=4`). `S017`–`S020` carry no
stored `Fetch sha256`; this is an explicit round-22 choice and is discussed under
limits below.

## F5 — C2 accounting checks in this span (freshness)

Independent recomputation, not a restatement of the integrated transcripts:

- **Base stale set.** Reading `git show c2cab35…:corpus/stamps.tsv` and fingerprinting
  each file from the base tree independently gives 63 stamp rows and exactly six stale
  records: `corpus/knowledge/config-layering.md`,
  `corpus/knowledge/handler-on-disk-state.md`,
  `corpus/knowledge/handler-trust-boundary.md`,
  `corpus/knowledge/janitor-env-contract.md`, `corpus/lessons/round-18.md`, `LOG.md`.
  This matches `.ufo/waves/round-22/before.json` and supports the “six, not five”
  statement. `SOURCES.md` was not stale at base.
- **Current pins.** Recomputing SHA-256, LF count and byte count for every current
  `stamps.tsv` row gives 69 rows, 0 stale, 0 missing. `SOURCES.md`'s row
  `3ba44518…/86/19721` is exact.
- **SOURCES.md migration.** `pin-migrations-integration.json` records
  `old_stamp: corpus/SOURCES.md db134917… 43 14261`,
  `base_observed: db134917… 43 14261`, and
  `new_stamp: corpus/SOURCES.md 3ba44518… 86 19721`. The migration is documented with
  exact historical evidence rather than a silent restamp; the digest change is caused
  by the five appended registry rows and the appended lead/erratum sections.
- **Nine-line reconciliation.** For `aea7a4301` → `e1544c19…`, first-column set
  difference on `corpus/stamps.tsv` is **0 removed paths** and 7 added paths
  (`QUALITY.md`, `SOURCES.md`, three knowledge entries, `lessons/round-21.md`,
  `sources-census.sh`). `round21-migrations.json` records `removed_members: []`,
  nine `changed_stamp_records`, and five `rewritten_claim_rows`. The nine changed
  paths match the lesson table exactly. The diff is 9 deleted and 16 added stamp lines:
  nine replacements plus seven new records, not nine lost members.
- **Expectation migrations.** The four changed expectations match the lesson exactly:
  R12-02 `29→36`, R12-03 `56→63`, R13-01 `20→23`, R14-01 `21/18→24/21`. The fifth row,
  R13-02, retains `^35$` and changes only its explanatory note. All five old/new tuples
  are present in `round21-migrations.json`.
- **Downstream counts.** Current stamps = 69, matching R12-03 `^69$`. SCORECARD
  `^## Round ` headings = 25, matching R13-01 `^25$`. `corpus/knowledge/*.md` files = 25,
  matching R14-01 `entries=25`. No stale expectation found in these checked rows.
- **Census.** `bash corpus/sources-census.sh` (read-only; no network) returned
  `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1
  entries_sourced=4 legacy=21)`, exit 0.

## F6 — Measurement scope limit on “16→21 rows”

The 21 registry rows resolve to **18 distinct URLs**, because:
`S006`/`S020` share the announcement URL, `S007`/`S019` share the setup-guide URL, and
`S016`/`S021` share the OpenBao token URL. Base had 16 rows and 16 distinct URLs;
current has 21 rows and 18 distinct URLs.

So “16→21 rows” is correct as a registry-row count, but five added rows comprise two
new distinct pages (`S017`, `S018`) and three reopens of already-registered URLs
(`S019`, `S020`, `S021`). The round-end census also counts rows. This is not a defect
in the lesson's wording, which says “rows”, but any C2 narrative that treats the +5 as
five new sources would overread the measurement. Proposed wording precision (no
production edit): “five new registry rows; two new distinct URLs and three reopens.”

## F7 — Limits and what was not verified

- The stored `Fetch sha256` values (S016 and all originals) are historical point
  observations with undocumented fetch representation; I did not reproduce them and
  did not call any raw-byte difference semantic drift. `S017`–`S021` carry no Fetch
  hash at all, so their freshness evidence is the dated reopen and claim text, not a
  content digest.
- I can establish that today's reopened pages match the registered claims; I cannot
  prove the pages were unchanged between 2026-10-19/2026-07-28 and today beyond the
  surviving published date and exact quotes.
- No account, vault, workflow, SDK, or host-private endpoint was contacted. No live
  lane state or Git index was modified. No installation or package transaction ran.
- I did not rerun the full revision audit or claim-ledger/feature-claims selftests;
  those are other seats' evidence. I recomputed the stamp and expectation arithmetic
  directly in read-only Python and ran only the read-only source census.

## Proposed correction

None required for S016–S020: the row verifies, the anchor verifies, original rows are
unmutated, and the round-22 usage is appropriately bounded. The only proposed change
is documentation precision in any C2 summary that cites source growth: qualify 16→21
as registry rows, and state that three of the five are reopens of already-registered
URLs. This is a wording precision for the parent, not a production edit.

## Checks the parent should run after integration

- `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`
  (manifest expectation: CLEAN, stale=0 missing=0 dropped=0 added=6 invalid=0).
- `bash corpus/sources-census.sh` (this run: CLEAN, rows=21, entries_sourced=4).
- `bash corpus/claim-ledger.sh selftest` and the feature-claims selftest, if not owned
  by another falsification seat.
- Confirm the only new working-tree path from this seat is this report.

## Evidence commands (executed, read-only unless noted)

```text
git -C … show c2cab35…:corpus/SOURCES.md
diff <(git show c2cab35…:corpus/SOURCES.md | grep -E '^\| S0(0[1-9]|1[0-6]) ') \
     <(grep -E '^\| S0(0[1-9]|1[0-6]) ' corpus/SOURCES.md)
sha256sum corpus/SOURCES.md; wc -lc corpus/SOURCES.md
sha256sum .ufo/waves/round-22/frozen/before/corpus/SOURCES.md
git show c2cab35…:corpus/SOURCES.md | sha256sum
git show c2cab35…:corpus/stamps.tsv   # then fingerprint every row against base blobs
python3 -  # recompute current stamps.tsv SHA/line/byte for all 69 rows
LC_ALL=C comm -23 <(git show aea7a4301:corpus/stamps.tsv | cut -f1 | sort -u) \
                  <(git show e1544c19…:corpus/stamps.tsv | cut -f1 | sort -u)
git diff --numstat aea7a4301 e1544c19… -- corpus/stamps.tsv corpus/claim-ledger.tsv
bash corpus/sources-census.sh
```

Public page opens on 2026-10-20: S016, S017, S018, S019, S020 (URLs above). No private
or authenticated endpoint was used.

## Installations

None. No tool, package, launcher, or version manager was invoked.
