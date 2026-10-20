# ReviewE3 — E3 product provenance and KV boundaries

## Read revision and limits

- Frozen base / `HEAD`: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
- Reviewed the current uncommitted round-22 diff as visible in `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, `corpus/SOURCES.md`, and `corpus/QUALITY.md`, plus the current `corpus/lessons/round-22.md` and `corpus/knowledge/feature-bound-credential-review.md`. These are not a committed final revision.
- `lsp` is unavailable (`read xd://lsp` returned “No such tool”); this is a document/source review, with no caller or code-semantic claims. No build, test, lint, formatter, ledger verifier or host-private gate was run.

## Findings by severity

### High — C2: the changed E3 entry still has its pre-change revision pin

`corpus/knowledge/vault-openbao-token-lease-lifecycle.md` is modified by the round-22 erratum (+27 lines; now through line 138), but `corpus/stamps.tsv:32` remains unchanged at SHA-256 `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb`, `lines=111`, `bytes=8597`. The current diff does not include `stamps.tsv`. This is a concrete stale pin for the E3 change, not merely a vendor-source freshness question.

**Required correction:** update the E3 pin only with a migration record preserving its exact old and new row values, reason, and observed check (QM14). The historical round-21 migration record must not be used as proof that this new round-22 edit is pinned. Do not report C2 clean until the E3 row and the other stale rows are reconciled without dropping membership.

### Medium — C1: keep OpenBao dynamic-secret lease claims narrower than the cited token page

The authoritative round-21 E3 erratum (`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:109`) labels a row “lease on a dynamic secret” and cites OpenBao S016 only for an expiring token revoking “its associated leases.” S016/S021 are OpenBao **token** pages; `SOURCES.md:27` scopes S021 to token TTL/associated leases, not dynamic-secret lease issuance. The round-22 erratum says the product-separated round-21 erratum is authoritative (`:115-126`), so the active correction should not imply that S016 alone establishes the complete OpenBao dynamic-secret lease contract.

Direct source read for this review, not yet in the registry: OpenBao 2.7.x, §“Lease, renew, and revoke”, `https://openbao.org/docs/concepts/lease/`, read 2026-10-20: “With every dynamic secret and `service` type authentication token, OpenBao creates a *lease*.” The same section says its KV backend does not issue leases. This is the product-specific source needed to admit that broader OpenBao lease control. Otherwise narrow the E3 statement to the token-associated lease revocation fact actually supported by S016/S021. Vault S013 remains Vault-only.

### Medium — C1: “no KV lease” must not become “no expiry/deletion,” and Vault KV v2 evidence is not yet registered

The round-22 E3 erratum correctly marks the original “nothing expires” row and the first “Does not establish” bullet as historical defective readings, then says no KV value-retention guarantee is admitted (`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:110, 115-133`). `corpus/SOURCES.md:46` still lists the Vault KV v2 API and overview as unopened leads; the round-22 additions S017–S021 do not add a KV source. Thus the current correction safely withdraws the overclaim, but there is no corpus-source-backed positive KV deletion control yet.

Primary-source evidence opened for this attack, not registered in `SOURCES.md`:

- Vault, “Key/Value v2 plugin”, `https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2`, read 2026-10-20: “The `kv` v2 plugin uses soft deletes to make data inaccessible while allowing data recovery.” The page also distinguishes permanent deletion/destroy.
- Vault KV v2 API, “Configure the KV engine” (`delete_version_after`), `https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2`, read 2026-10-20: “If set, specifies the length of time before a version is deleted.” It also documents `max_versions` permanently deleting the oldest version above the configured limit.

**C1 acceptance condition / falsifier:** reject a typed claim that “Vault/OpenBao static KV never expires or changes only by write” when its sole support is S013’s Vault statement that KV does not issue leases. Admit a bounded Vault-KV-v2 control only after adding the Vault-specific API/overview evidence to `SOURCES.md`, and state deletion/soft-delete/destroy separately from dynamic-secret lease expiry. Do not infer OpenBao KV retention or deletion behavior from Vault pages. As a separate valid product-bound control, OpenBao 2.7.x non-root token TTL can be admitted on S021; it must not be relabeled as Vault TTL or KV retention.

## Calibration acceptance and residual risk

- The historical outside spot-check is decisive: `corpus/lessons/round-21-verifier-spotcheck.md:12-17` records E1/E3 both disagreed with as landed (0/2 admit agreement), while its three sampled rejects agreed (3/3). `corpus/lessons/round-21.md:105-118` records that the E3 cross-product/KV overclaim was real and QA9 was added because the prior bar allowed it through.
- Current QA9/QA10 and QM13 (`corpus/QUALITY.md:59, 71-72`) give the right test shape: product/path/eligibility/status-specific evidence, a known-bad admit refused, a bounded valid control retained, and correctness measured as decisions rather than authored rows. The new `feature-bound-credential-review.md:19, 33-35` is a useful bounded OpenBao-token control and explicitly disclaims Vault-token and OpenBao-KV conclusions.
- `corpus/lessons/round-22.md:25` correctly says this round has not self-attested its outside spot-check. Therefore current edits establish corrections, not independent C1 closure or an axis move. A non-author holdout must challenge both the bad no-lease⇒no-deletion inference and a correctly scoped positive control.
- The change record must preserve the rejected historical E3 reading as history; do not retroactively convert the round-21 admission to a pass. Re-stamping bytes cannot establish vendor-source currentness.

## Verification gaps / parent checks

After integration, have the parent verify the E3 pin and migration record under QM14 and perform QM12's safe-row/stamp substitute rather than invoking a host-private full ledger run. Obtain the separate non-author C1 decision record. No package or tool installs were made.