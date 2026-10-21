# Source S004 — Service Account security: calibration and pin reconciliation

Axes: **C1 calibration** and **C2 freshness**. Read-only source scout. No production file, registry row, stamp, ledger, or git/jj state was edited; no installs or host gates were run.

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD), with the frozen base inputs in `.ufo/waves/round-22/frozen/before/`. Other round-22 lanes were writing the working tree while this read ran (observed at `2026-10-20T21:39:46Z`: `corpus/SOURCES.md`, `corpus/QUALITY.md`, the E1/E3 entries modified, new `corpus/lessons/round-22.md`, `plans/round-22.md`, `corpus/knowledge/feature-bound-credential-review.md`). The S004 row itself is byte-identical to the frozen base (`405a8b0331b7e1568989ebbe143c981bda90323a001bf695b8a69c36afa64b1a`), so none of those appends touched it.

## 1. Fresh source evidence

| item | observation |
|---|---|
| URL | https://www.1password.dev/service-accounts/security (HTML; Mintlify canonical `.md` at the same path plus `.md`) |
| access date | **2026-10-20** (HTML HTTP `Date` 2026-10-20T21:33:43Z; `.md` 2026-10-20T21:38:28Z) |
| HTTP / size | 200; HTML 1,221,617 bytes; `.md` 8,390 bytes |
| canonical text pin | `.md` sha256 `24b22be063adedda0731fed48ce7dc835ed0c79d856f09c5daa110d1b0e5ab5d` (two fetches identical) |
| HTML fetch pin | sha256 `7e6f04088407b7ae388a4a27c33b6575c3819586aeac746910a96176f8924923`; carries `dpl_CTd5b4pFwfRrzK28Ja6L7zK5VbfH` and `buildId 6ad68a298cdc29c1c7fdf7e9` — deployment artifacts, not content |
| registry pin | `19bcf13eacd212b54db578ed7b1fdaa7341756ab73a6bd4f61d4b0012c7d2d60` (row, 2026-10-19) — **not reproduced** by any present representation tested |
| page-declared revision | JSON-LD `"dateModified":"2026-10-19T21:23:27.830Z"` |
| scoped headings | `§Access control`, `§Service accounts and token generation`, `§Security model`, `§Token rotation and revocation` |

All quotes below are located at the named heading on https://www.1password.dev/service-accounts/security, fetched 2026-10-20:

| heading | located quote (≤25 words) |
|---|---|
| §Access control | “When creating a service account, you choose the vaults it can access and its level of access.” (17) |
| §Access control | “The service account only returns information from vaults it can access.” (11) |
| §Token rotation and revocation | “You can rotate or revoke service account tokens.” (8) |
| §Service accounts and token generation | “The service account token allows a service account to authenticate with 1Password CLI.” (13) |
| §Security model | “A service account can only read items from vaults it has READ access to.” (14) |
| §Security model | “A service account can only update, delete, and create items for vaults it has WRITE access to.” (17) |

The row's two quotes are exact substrings of those sections; the scoped teaching and anchors resolve unchanged.

### Feature-specific link opened

https://www.1password.dev/service-accounts/manage-service-accounts, §Rotate a service account token, §Revoke a service account token, and §Manage service account settings; fetched **2026-10-20** (`.md`, 7,731 bytes, sha256 `6856bcc45026d43db0d5e0d462fb2b6823cb178fbfeb5f332ad3b3a7f30232a4`):

| heading | located quote (≤25 words) |
|---|---|
| §Rotate a service account token | “Rotating a service account token generates a new token with the same permissions.” (13) |
| §Rotate a service account token | “You can also specify an expiration for the current token” (10) |
| §Revoke a service account token | “Revoking a service account token immediately removes its access to 1Password vaults.” (12) |
| §Manage service account settings | “With 1Password Teams and 1Password Business, you can manage who on your team can create service accounts and which vaults the service accounts can access.” (25) |

### Qualifiers carried with the evidence

- **Status:** S004 carries no preview, beta, draft, or version label in the scoped sections. It is current product documentation; do not upgrade that to “generally available” from this page alone.
- **Eligibility:** S004 states **no plan or edition eligibility** for Service Accounts. The linked management guide names 1Password Teams and 1Password Business for management controls and the default owner/administrator role; it does **not** state Service Account availability for those or any other plan, and does not mention Enterprise. Absence is not a contradiction—record “not established”, not “unavailable”.
- **Product:** 1Password Service Accounts. Not Connect server deployment credentials, not application REST tokens, and not Broker integration keys. The token is described for 1Password CLI/services and tools.
- **Path:** Service Account token → 1Password CLI authentication. S004 does **not** describe `op run` delivery; that process-scope claim belongs to S001.
- **Role:** by default owners/administrators create Service Accounts; owners/administrators can view details and delete, but cannot view a generated token; rotation/revocation are console actions on 1Password.com.

### Falsifier

This scoped teaching is falsified if the re-opened page no longer scopes returned information to accessible vaults or no longer documents token rotation/revocation; if `dateModified` advances past `2026-10-19T21:23:27.830Z` while those sentences change; or if the feature-specific link reverses same-permissions rotation, operator-set expiry, or immediate revocation. A plan or release-status qualifier added to S004 would falsify any unqualified eligibility reading, not the vault-scope/token teaching.

## 2. C1 calibration — decisions, not row counts

| # | candidate claim | decision | source-grounded reason |
|---|---|---|---|
| D1 | At creation the operator chooses the vaults and access level; the account only returns information from accessible vaults. | **ADMIT** | Exact §Access control sentences; §Security model repeats the READ/WRITE boundary. |
| D2 | Service Account tokens can be rotated and revoked. | **ADMIT** | Exact §Token rotation and revocation sentence. |
| D3 | Rotation issues a new token with the same permissions and lets the operator expire the current token. | **ADMIT only via the linked feature page** | §Rotate says both; S004's own sentence does not carry expiry mechanics. If the entry adds this, it needs its own source row for the linked page. |
| D4 | Revocation immediately removes vault access. | **ADMIT only via the linked feature page** | §Revoke exact sentence; same new-row caveat as D3. |
| D5 | “`op run` makes the Service Account token short-lived / the token expires when the child process ends.” | **REJECT — known E1 overclaim** | S004 describes the token as an authentication string (AUK/SRP/keyset serialized) and documents only rotate/revoke; it never links token lifetime to a process. Process scope is S001's delivered environment. QA8 boundary collapse. |
| D6 | “Service Account tokens expire automatically / have a fixed short lifetime.” | **REJECT as not established** | No automatic expiry is documented. Rotation's expiry option applies to the *current* token at operator action. Do not overcorrect to “never expires”—that is also not established. |
| D7 | “Service Accounts are available on every 1Password plan / on Enterprise.” | **REJECT as unsupported** | S004 has no eligibility statement; the linked guide's Teams/Business sentence is about management controls. QA10 missing-qualifier failure; absence ≠ contradiction. |
| D8 | “Vault scope and access level bound the information the account can return.” | **ADMIT, with a precision note** | Vault scope bounds which items are returned; READ/WRITE bounds which operations are permitted. The entry's compressed sentence is supportable, but a split is clearer if the entry is amended. |
| D9 | Owners/administrators create and manage; a generated token cannot be viewed later. | **ADMIT as a role/custody qualifier** | Exact §Security model sentences. Not required by the current entry. |
| D10 | The token authenticates to 1Password CLI/services and tools. | **ADMIT as product/path qualifier** | Exact §Service accounts and token generation and §Service account token sentences. Matches the entry's CLI/`op run` use. |

### Entry verdict

- **Item 1** (`op run` process delivery vs token lifetime) correctly cites S001 for process scope and does not attribute it to S004.
- **Item 2** is admitted as bounded. Its compression of “returned information” and “access level” is a precision issue, not a known E1 overclaim.
- The **“does not establish”** line is correct and is precisely the known E1 rejection: S004 documents no automatic or process-linked expiry; the linked rotation page's operator-set expiry does not support “short-lived with `op run`”.
- The entry makes **no S004 eligibility claim**, so no S004 eligibility erratum is required. If the entry is expanded, add the limit rather than inferring plan scope.
- S004 must not support Connect or Broker claims; those are S002/S003/S005–S007/S017–S020 territory.

## 3. C2 freshness — content revision vs raw-byte pin

### 3.1 What changed and what did not

- The page's own `dateModified` is `2026-10-19T21:23:27.830Z`; the S004 row was introduced in `c41af82` at `2026-10-19T22:29:35Z` (1 h 06 m later). Today's scoped text matches the row's quotes. **[OBSERVED]** no scoped content change; **[INFERENCE]** the declared revision is not newer than the row.
- The recorded raw-HTML pin `19bcf13e…` is **not reproducible** from today's HTML (`7e6f0408…`), the canonical `.md` (`24b22be0…`), extracted text, whitespace-normalized text, or Markdown-index-stripped text. **[OBSERVED]** the old bytes are unavailable, so the cause cannot be decided between a site redeploy and a different fetch representation.
- The HTML body embeds a deployment id and Next.js build id; the `.md` is text. The `.md`'s `Last-Modified` header was one second after `Date` (2026-10-20T21:38:29Z), so it is not a content clock; only the JSON-LD `dateModified` and the text are used.
- Wayback has no snapshot for this URL in the relevant window (CDX query returned `[]`; availability endpoint returned 429), so the 2026-10-19 bytes cannot be recovered there.

**Decision:** this is a **pin-expectation mismatch, not source drift**. Do not mark S004 content stale, do not rewrite the row's digest in place, and do not present a new hash as re-verification of vendor behaviour.

### 3.2 Ledger expectation migration (exact, preserve history)

| field | historical expectation | current expectation |
|---|---|---|
| representation | raw fetched HTML bytes | canonical Mintlify `.md` bytes |
| digest | `19bcf13eacd212b54db578ed7b1fdaa7341756ab73a6bd4f61d4b0012c7d2d60` | `24b22be063adedda0731fed48ce7dc835ed0c79d856f09c5daa110d1b0e5ab5d` |
| size | not recorded | 8,390 bytes |
| revision clock | “no displayed version/date” | JSON-LD `dateModified` `2026-10-19T21:23:27.830Z` |
| HTML artifact | the old pin's presumed object | `7e6f04088407b7ae388a4a27c33b6575c3819586aeac746910a96176f8924923` (retained as a fetch artifact, not a pin) |

The old digest remains in the historical row and in this report; it is not deleted or “corrected”. The `.md` digest is a reproducible text pin, not a content notarization. Any restamp must record old→new and the reason, per QM14.

### 3.3 Stamp ledger and the “nine dropped stamps”

- **Base `c2cab35`:** `corpus/stamps.tsv` = `0ce7fa4f…` (63 rows). `corpus/SOURCES.md` was `db134917…` 43 lines / 14,261 bytes and matched its stamp; the S004 entry was `7635be81…` 35 lines / 6,240 bytes and matched its stamp. Neither path is in the base stale set (six: `config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md`, `lessons/round-18.md`, `LOG.md`).
- **The nine deleted lines are rewrites, not lost members.** Between `aea7a4301` and `e1544c1`, `git diff` on `stamps.tsv` has exactly nine deleted lines, all old values of paths still present: `claim-ledger.tsv`, `op-ref-consumption.md`, `op-ref-probe.sh`, `README.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`. The complete path set has **seven additions and zero removals**; `round21-migrations.json` records `removed_members: []`, `historical-migrations.json` records `deleted_stamps: []`, and its interpretation states the outside reviewer reported “nine deleted lines in diff, not nine lost stamp members.” The S004 entry row was one of the seven **additions** at `c41af82`, never a deletion. Preserve that wording; do not restore stale pins.
- **Current working tree (observed 2026-10-20T21:39:46Z, concurrent lanes still writing):** `SOURCES.md` `ebf88646…` 66 / 18,222 vs stamp `db134917…` 43 / 14,261; the S004 entry `e885081e…` 68 / 8,328 vs stamp `7635be81…` 35 / 6,240; `QUALITY.md` `3753d4fb…` 73 / 12,551 vs stamp `7425f091…` 65 / 10,642; E3 entry `00c8c4e2…` 138 / 10,131 vs stamp `5fd53351…` 111 / 8,597. `stamps.tsv` itself is still `0ce7fa4f…` and has not been regenerated.
- **Attribution:** those mismatches come from the round-22 appends in the working tree, not from S004 content. The S004 row hash is unchanged; the entry stamp changes only because another lane appended the round-22 E1 erratum.
- **Post-integration expectation:** one reviewed restamp of exactly the changed paths, preserving all 63 members, recording old/new for each; do not use `--prune`. New untracked files (`lessons/round-22.md`, `plans/round-22.md`, `knowledge/feature-bound-credential-review.md`) join only if the ledger's cited-artifact policy requires them; that is a policy decision, not an automatic re-pin.

### 3.4 No superseding row

A pin-successor row (for example `S021`) is **not needed and would be harmful here**. The census requires a mined row's `used-by` entry to cite it on the entry's `source:` line (`SC_USEDBY_NOCITE`); adding a row only for a pin would force rewriting the entry's citation/verification header, risking exactly the laundering C2 forbids. The correct migration is the expectation table above in the round's migration record, with the S004 row untouched. If the parent nevertheless adopts a row-level pin, it must also append a dated erratum and update the entry's `source:` line deliberately—never silently—and update the census count expectation `R21-02` (`rows=16`, `entries_sourced=3`) as a separate ledger migration.

## 4. Proposed correction (for the parent; nothing written)

1. **Keep S004's teaching, quotes, anchors, and status unchanged.** The scoped content matches.
2. **Do not restamp S004 in place.** Record the pin migration in the round-22 migration artifact with the exact old/new values above; keep the old digest as history.
3. **Optional E1 precision append** if the entry is being touched anyway: “§Access control bounds *which items* a Service Account can return by vault scope; READ/WRITE access bounds *which operations* it may perform [S004 §Access control, §Security model]. S004 states no plan or release-status eligibility; the linked management guide's Teams/Business sentence addresses management controls, not availability.”
4. **If the entry adds rotation/revocation mechanics or role/plan details**, open a separate row for https://www.1password.dev/service-accounts/manage-service-accounts (quotes above) rather than stretching S004's sentence.
5. **Post-integration stamps:** one reviewed commit, 63 members preserved, old→new recorded; S004's row needs no content change.

## 5. Limits

- Only S004 and its linked management page were opened; no other sources were re-opened, and no content from other lanes was adjudicated.
- `dateModified` is platform metadata, not a vendor-signed content hash; the raw HTML contains deployment/build identifiers, and the `.md` `Last-Modified` is fetch-time-like. The `.md` digest is a text pin, not proof of vendor truth.
- The 2026-10-19 raw bytes and any archive snapshot are unavailable, so the exact cause of the old-pin mismatch (redeploy vs representation method) cannot be recovered. The content decision does not depend on it.
- The working tree changed during this read; all working-tree hashes are timestamped observations, not integration-state claims. The S004 row hash stayed stable across the observation window.
- No registry, corpus, stamp, ledger, production, or host state was edited; no gates or installs were run.

Report: `.ufo/waves/round-22/build/Source04.md`
