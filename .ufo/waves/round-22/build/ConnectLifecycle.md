# ConnectLifecycle — S012–S016 chain vs E3 lifecycle attribution

Axes: calibration, freshness.
Seat: KagiR22.ConnectLifecycle (read-only). Installs: none.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD equals this base).
Round cache: `.ufo/waves/round-22/before.json`, `.ufo/waves/round-22/frozen/before/expected.json`, frozen copies of `corpus/SOURCES.md`, `corpus/QUALITY.md`, `corpus/stamps.tsv`, and `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`.

## Proposed move

C1 must admit or reject each E3 clock by product, feature, path, and the pinned source sentence. The round-21 erratum cell that fills OpenBao’s dynamic-secret lease from S016 is a **reject**. S016 stays an OpenBao token-hierarchy quote. C2 must keep the committed lifecycle pin as the historic witness of that file and must not treat a later hash as a reopen of S012–S016.

## Evidence

Committed `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` matches its stamp and the freeze digest.

| surface | value |
|---|---|
| stamp row | `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb`, 111 lines, 8597 bytes |
| `git show c2cab35:…lifecycle.md` and frozen copy | same sha256, 111 lines, 8597 bytes |
| `.ufo/waves/round-22/before.json` `stale_stamps` | six paths; this file is absent |
| `expected.json` `outside_admission.E3` | `reject` |
| `expected.json` `expected_source_rows` | 16 (S001–S016) |

Working tree, uncommitted, measured this pass: the lifecycle file is 138 lines, 10131 bytes, sha256 `00c8c4e209b5e07808805943cd8c728044f7466c1fe6f498494e7185d99ea784`. `corpus/stamps.tsv` is unmodified, so the pin still names the committed triple. `git diff -U0 -- corpus/SOURCES.md` inserts rows after S016 and a lead note; S012–S016 cells and the path bullet are not in that diff.

Chain at frozen `corpus/SOURCES.md:28` (working tree line 32, same text): S012 → S013 → S014 → S015 → S016 ends at OpenBao token TTL and revocation. The four-clock table in the committed entry assigns the dynamic-secret lease row to `S013 (Vault), S016 (OpenBao)` and the token-TTL row to `Vault/OpenBao` with source `S016 (OpenBao)` only. The round-21 erratum in that same stamped file says the OpenBao half of the lease clock is S016, “an expiring token is revoked with its associated leases.”

Pinned registry sentences (opened 2026-10-19; this seat did not re-fetch):

- S013, [Lease, renew, and revoke](https://developer.hashicorp.com/vault/docs/concepts/lease), 2026-10-19: “All dynamic secrets in Vault are required to have a lease.”
- S016, [Token hierarchies and orphan tokens](https://openbao.org/docs/concepts/tokens/), OpenBao 2.7.x, 2026-10-19: “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.”
- S015, [Kubernetes note](https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/), OpenBao 2.7.x, 2026-10-19: “The JWT auth engine does not use Kubernetes' `TokenReview` API during authentication.”
- S012, [JWT verification, Vault 1.17 note](https://developer.hashicorp.com/vault/docs/auth/jwt), page as served 2026-10-19: “must exactly match at least one of the `aud` claims declared for the JWT.”

S013’s `teaches` cell says Vault “distinguishes static KV values from leased data.” That clause is not the pinned quote. S016’s scope cell is token policy, TTL, renewal, and revocation. `SKILL.md` decision row for a short-lived claim assigns dynamic-secret leases to Vault only and OpenBao’s clock to token TTL (`SKILL.md` around the “Judge a short-lived claim” row). Frozen QA9 withdraws a part with no source and flags a `Vault/OpenBao` or `IdP, Kubernetes` label. It still accepts a cited source. S016 is a cited OpenBao source, so QA9 does not withdraw the lease cell. Frozen QUALITY has no QA10.

`corpus/lessons/round-21.md` records E3 as admitted at landing and the merged clock table as a post-landing miss. `corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication records the outside result as disagreement with E3 as landed. `plans/round-22.md` separates the axes: qualifier adjudication does not depend on restamping, and the pin audit does not adjudicate vendor facts.

## Contradiction

These statements are all present and are not the same decision:

1. Freeze `expected.json` sets E3’s outside admission to reject. The committed file that carries that rejection already contains the round-21 product-separated erratum, including the OpenBao lease cell. The erratum did not flip the outside result.
2. The path bullet and the SKILL decision row keep S016 on OpenBao token TTL and revocation, and keep dynamic-secret leases on Vault (S013).
3. The four-clock lease row and the round-21 lease bullet use S016 as OpenBao’s dynamic-secret lease source.
4. The uncommitted round-22 append calls that round-21 erratum authoritative and also says the 2026-10-20 S016 reading supports OpenBao token claims only. Uncommitted `corpus/lessons/round-22.md` calls the product-separated reading an admitted correction and rejects “OpenBao TTL supported solely by Vault docs” and “no-lease interpreted as never-deleted.” It does not reject S016’s lease collateral as a dynamic-secret lease requirement. Its gate table reopens S017–S020 only. There is no new S016 digest, `opened` date, or superseding id. S012–S016 remain `opened` 2026-10-19.

Same-product, wrong-feature citation is the residual E3 miss. A gate that only fails “OpenBao claim cites a Vault page” admits this cell.

## Affected axes

- Calibration: expected decisions below improve C1. They leave C2’s pin identity alone.
- Freshness: the committed lifecycle pin is already a match, so it is not one of the six stale paths and it is not a missing stamp row. Using a new hash to mark S012–S016 current would harm freshness. Leaving the old pin in place while recording any kept append as old→new pointer migration improves freshness accounting and does not change the C1 decisions.

## Expected C1 decisions

Bound each row to the registry quote id. A missing or different sentence fails closed. These are typed decisions, not a scrape of the first table and not a `sources-census` result (that gate checks the citation chain, not page content).

| id | product | feature | path | evidence sentence | decision |
|---|---|---|---|---|---|
| e3-vault-dyn-lease | Vault | dynamic-secret lease required | — | S013 pinned quote | admit |
| e3-obao-parent-revoke | OpenBao | token-hierarchy revocation | parent token | S016 pinned quote | admit |
| e3-obao-k8s-tokenreview | OpenBao | issuer revocation invisible to JWT auth | Kubernetes JWT provider | S015 pinned quote | admit |
| e3-vault-aud | Vault | audience exact match | JWT that carries `aud`, Vault ≥1.17 | S012 pinned quote | admit |
| e3-obao-dyn-lease | OpenBao | dynamic-secret lease required | — | S016 pinned quote or “associated leases” | reject |
| e3-joint-token-ttl | Vault and OpenBao | token TTL | — | S016 only | reject |
| e3-idp-revocation | OpenBao | issuer revocation | any IdP | S015 | reject |
| e3-kv-retention | Vault | KV never expires, or changes only by a write, or a KV read carries no lease | — | S013 pinned quote, or the `teaches` cell | reject |

KV “does not issue leases” is entry prose in the committed file, not the S013 quote field. This seat did not re-open the page. Until a new source id pins that full sentence, the KV feature stays reject / cannot-evaluate. Do not edit S013 in place.

The uncommitted append’s TTL sentence, “After the current TTL is up, the token will no longer function,” is working-tree text attributed to OpenBao §Token Time-To-Live on 2026-10-20. It is not a registry quote. It cannot be an admit input until a superseding row records it.

## C2 journal if the append is kept

Record both triples. Do not delete the old row. Do not describe the new hash as re-verification of S012–S015 or of S016’s fetch sha256 `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`.

- old: `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb`, 111, 8597, revision `c2cab35bc92e57e39e5489bac3386db078345b3f`
- new, only if the working-tree bytes land unchanged: `00c8c4e209b5e07808805943cd8c728044f7466c1fe6f498494e7185d99ea784`, 138, 10131

This file is outside the nine-deletion set: its stamp row is present. This seat did not re-count those nine deletions.

Index sentences that still bundle the chain as one Vault/OpenBao lease-and-KV fact, dated 2026-10-19, fall under the same reject rule if used as claims: `corpus/README.md` Vault/OpenBao row and `PROVINCE.md` core bullet. They are not a second workstream.

## Risks

- Treating the round-21 erratum as the good control admits `e3-obao-dyn-lease` and leaves the outside E3 reject untested.
- A cross-product-only fixture misses S016→lease, S015→any IdP, and S013 `teaches`→KV retention, while the stamp stays green.
- Restamping the dirty file without the old/new journal makes a fresh hash stand in for a source reopen. That couples C2 to C1 and breaks the separability rule in `plans/round-22.md`.
- Rejecting the lease cell leaves the erratum bytes in the append-only file. The reject is the decision record; the paragraph stays historic.

## Limits

No vendor page was opened on this pass. No census, ledger, vault, or host gate was run. Working-tree `QUALITY.md`, `SOURCES.md`, the lifecycle append, and untracked `corpus/lessons/round-22.md` are observed dirty state, not the frozen base. Authorship of those edits was not assigned.

## Verification for the parent

After integration, compare `sha256sum` and `wc -lc` of the lifecycle file with `corpus/stamps.tsv` and with the journal triple above. Run the typed-claim selftest and require the eight decisions in the table, including reject on `e3-obao-dyn-lease`. Keep `corpus/sources-census.sh` off the C1 verdict path. Do not run a live Vault or OpenBao probe.
