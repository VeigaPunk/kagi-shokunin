source: S022 (https://developer.hashicorp.com/vault/docs/auth/jwt, introduction Vault 1.17 note and OIDC configuration troubleshooting); S023 (https://developer.hashicorp.com/vault/docs/concepts/lease, Lease renew and revoke / KV note and Edit this page source route)
verified-at: 2026-10-20 (author opened both public pages after the fresh-wave findings; no deployment or account/vault operation)
recheck: on-release — reopen the JWT-role versus OIDC-role qualifiers and the Vault lease/KV note; compare the served source route rather than inferring a deployment version.

# Round 22 — late source-qualifier errata

These are corrections to existing held ground prompted by fresh-wave
ReopenSource12/ReopenSource13, not a new C1 feature or new coverage claim.
The frozen H1 source rows remain history. Original S001–S016 rows stay
byte-identical; correction rows supersede only the named scope/locator.

## Gate

| new row | URL | access date | located quote (at most 25 words) | disposition |
|---|---|---|---|---|
| S022 | https://developer.hashicorp.com/vault/docs/auth/jwt | 2026-10-20 | Introduction Vault 1.17 note: “the associated `bound_audiences` for the "jwt" role must exactly match at least one of the `aud` claims declared for the JWT.” | Admit only for JWT roles when the presented JWT has an audience claim; reject an OIDC-wide mandatory-audience inference |
| S022 | same URL | 2026-10-20 | OIDC configuration troubleshooting: “`bound_audiences` is optional for OIDC roles and typically not required.” | Retain the separate OIDC qualifier |
| S023 | https://developer.hashicorp.com/vault/docs/concepts/lease | 2026-10-20 | H1 section KV note: “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration” | Admit no-lease only; reject value-deletion/retention and OpenBao inferences |

The lease page's observed **Edit this page** link names
`content/vault/v2.x/content/docs/concepts/lease.mdx`. That is a served
source-route locator, not proof of a deployed Vault version. The reader
representation does not display every version-selector control; the fresh
source reports record the rendered v2.x selector. S012's most-recent
non-latest pinned v1.21.x label is not contradicted merely by a v2.x latest
route. S013's categorical no-displayed-version locator is withdrawn.

Source search: two targeted primary pages identified, screened and included;
zero excluded. Stop: the missing role-type qualifier and the KV/locator
boundary resolved; no JWT deployment or token operation was added.
New rows S022/S023 are A/mined, used-by this lesson. No existing
status/recheck/used-by field changes in this operation.

## Mistakes

| class | evidence pointer | captured-by | fix |
|---|---|---|---|
| Role-type qualifier omitted from a source-backed JWT audience claim | `kagi-shokunin/.ufo/waves/round-22/falsify/ReopenSource12.md` and the source's OIDC-optional counterexample | QA9/QA10 | S022 and the appended E3 correction keep JWT and OIDC roles distinct; JWT login remains outside C1's closed profile, not a new countable fixture |
| Displayed-version absence overclaimed from a reader representation | `kagi-shokunin/.ufo/waves/round-22/falsify/ReopenSource13.md` | QA6/QA9 | S023 corrects the locator while preserving the valid Vault mechanism and original source row; no raw-hash mismatch called semantic drift |

Outside spot-check for the final corrected rows remains the parent's
non-author closure duty. Fresh source seats are asked to compare these rows
with their already-opened pages; their findings remain lane-authored
falsification, not independent admission.
