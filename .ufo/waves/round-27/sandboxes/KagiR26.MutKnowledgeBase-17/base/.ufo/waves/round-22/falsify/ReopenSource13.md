# ReopenSource13 — S013 re-open, S017–S020 feature/eligibility check

Axes: **calibration**, **freshness**. Read revision: integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, tree `d12afd7a545e86f21eb9acac567d10de774df50f`. Frozen inputs identified by `.ufo/waves/round-22/integration-manifest.json` sha256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.

Observed production hashes (each matches the manifest; `git status` was clean for `corpus/`, `plans/`, `LOG.md` during the reads):

| file | sha256 | lines / bytes |
|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 / 19721 |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | 995 / 47434 |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | 1040 / 45532 |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 43 / 4440 |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 / 15700 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 / 7213 |
| frozen `before/corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` | 43 / 14261 |

Method: independent anonymous public GETs on 2026-10-20 only. No account, vault, SDK, workflow, launcher, package manager, loopback/health/CDP probe, or host-private gate was used; no installation and no production edit. The dead/missing W1 seats receive no credit for this work.

## S013 — teaching and quote stand; the locator clause does not

`https://developer.hashicorp.com/vault/docs/concepts/lease`, opened 2026-10-20: HTTP 200, 261,632 bytes, sha256 `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802`; two fetches byte-identical. This reproduces the round-22 catalog digest exactly (`corpus/feature-claims.json:78`).

- Anchor resolves: H1 **Lease, renew, and revoke**; H2s Lease IDs, Lease durations and renewal, Prefix-based revocation. The KV note is the last intro paragraph before §Lease IDs.
- **Supported claim (verbatim, 9 words):** “All dynamic secrets in Vault are required to have a lease.” (§Lease, renew, and revoke, 2026-10-20). The same section also carries “When a token is revoked, Vault will revoke all leases that were created using that token.”
- **Scope limit:** the KV note says the backend “does not issue leases although it will sometimes return a lease duration”. That supports “no lease”, not “no deletion”, “no retention”, or “immortal KV values”. The page is silent on batch tokens and token TTL, and it is HashiCorp Vault only — it cannot support OpenBao KV/token or cross-product parity. The row’s “static KV exception” is the author’s gloss, admissible only with that qualifier.
- **Row identity:** S013’s line is byte-identical to the frozen-before row (line 19); status, recheck, used-by, scope, anchor, teaches and quote are unchanged. All fifteen other original rows S001–S016 are also byte-identical; only S017–S021 were appended. No immutable-field mutation occurred.
- **Freshness accounting:** the 2026-10-19 `Fetch sha256: ae3215…` matches no representation measured here (raw HTML is `de5f88…`; the `.md` alternate returns 404). The round records the new bytes as `sha256: de5f88…` with `prior_registry_sha256: ae3215…` and `digest_observed_at: 2026-10-20` in `feature-claims.json`. That is transparent, not silent replacement, and the gate only format-checks the digest (it never fetches), so the value is an attestation rather than a live content pin. No laundering observed.

**Finding S013-1 (Low/Medium, calibration + freshness) — anchor overstates absence of a version.** The row says “current Vault docs have no displayed version/date”. The rendered page displays “Currently viewing v2.x (latest)” and offers pinned `v1.21.x`; the version half is false. No last-updated text is rendered, but JSON-LD `datePublished`/`dateModified` both read `2026-04-15T00:14:52Z`, so the date half is true only as “not visibly displayed”. `build/Source13.md` already recorded this; `corpus/lessons/round-22.md` only calls the old description “not current release pins”, and no superseding row or erratum exists. Proposed correction: append a superseding row or an explicit locality erratum that says the displayed version is the docs track `v2.x (latest)` and the only dates are machine-readable; never edit the original row. Until then, do not cite S013’s anchor as evidence of an unversioned page.

## S017–S020 — feature-specific status and eligibility, checked separately

Each page was reopened at its own URL; status was read from that page’s own H1/badge, not shared navigation.

| row | own H1 status | eligibility / constraints observed | verdict |
|---|---|---|---|
| S017 `…/brokered-access/github-actions/` | “…GitHub Actions at runtime (**public preview**)” | “If an administrator has connected your GitHub organization to your 1Password Business account” | ACCEPT |
| S018 `…/brokered-access/custom-workflow/` | “…custom workflows at runtime (**public beta**)”; Beta badge | OIDC provider connected to Business; Step 1 “latest beta release of the 1Password desktop app”; Step 3 “only supported in the 1Password JavaScript SDK at this time.” | ACCEPT |
| S019 `…/brokered-access` | guide H1 says public preview, but page is scoped to setup | Business-account integration; GitHub.com only; GitHub Enterprise Server and Enterprise Cloud with data residency unsupported; GitHub Free orgs excluded from private-repository workflows | ACCEPT as setup/eligibility only |
| S020 `…/blog/1password-credential-broker-public-preview` | published 2026-07-28 (meta + visible date) | “available for all Enterprise Password Manager Business customers”; “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | ACCEPT with dated scope |

- **Concrete supported claim (S018, 14 words):** “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” (H1, 2026-10-20). This is the feature-specific status anchor the round uses against the parent guide’s preview label.
- **Scope limit:** S018 additionally requires the beta desktop app and is JavaScript-SDK-only; the page does not support “public preview” for custom OIDC or “every SDK supported”. S019’s guide label and S020’s July announcement are not live status oracles for the other feature.
- **Supersession scope is accurate:** reopening S019 still shows the retained S007 mechanisms (“All configured claims must match”, integration-key decryption, workflow-duration access), and S020 still carries the S006 integration-key-versus-standing-access distinction. The original S006/S007 rows remain byte-identical. The SOURCES.md note that S019 replaces only S007’s uniform-status/eligibility reading is correct.

## Findings beyond the rows

**Finding C-1 (Low, calibration) — admitted Vault control cites a nonexistent anchor.** `AFTER-VAULT-LEASE` (`corpus/feature-claims.json:744-777`, anchor at line 751) is labelled `verbatim-pin` and references `corpus/knowledge/feature-bound-credential-review.md` anchor “Vault dynamic-secret lease row”. That active review contains five rows (Broker GitHub Actions, Broker custom OIDC, Broker credential custody, OpenBao service tokens, Missing product support) and **no Vault lease row**; the anchor string occurs nowhere outside `feature-claims.json`. `_record_reference_ok` (`corpus/feature-claims.py:500-510`, verbatim-pin branch at 507-508) checks only the key set `{path, anchor}` for this authority class, so the dangling anchor passes. The admit decision itself is source-correct (`release_status: not_asserted`, no eligibility claim), so it does not alter the measured 10-reject / 4-admit / 3-boundary split; what fails is the “verbatim-pin” traceability claim. Smallest remediation: add the missing Vault row to the review with an S013 provenance line, or repoint the reference to the S013 quote; optionally make verbatim-pin anchors existence-checked.

**Finding F-1 (Low/Medium, freshness) — S020’s recorded digest is not reproducible and the page is per-request unstable.** The catalog records `55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda` for S020 (`feature-claims.json:173`; also `build/BuildQualifierGate.md`), with no representation/method note. Five observed requests today each returned 190,261 bytes with a different hash: four default `curl -sL` responses gave `fa48c7…`, `439da1…`, `503212…`, `2deea8…`; one `Accept: text/html` response gave `9a17e4…`. The recorded `55bf23…` matches none. The two quoted sentences remain present and stable in the text, so calibration is unaffected, but this digest cannot serve as a drift pin. S017 (`937f68…`, 1,215,155 B), S018 (`d0890c…`, 1,282,825 B), S019 (`896c78…`, 1,199,099 B), S021 (`522952…`, 47,384 B) and S013 (`de5f88…`, 261,632 B) all reproduced exactly as raw HTML (representation documented for S017–S019 in `build/Source07.md`, S021 in `build/Source16.md`, S013 in `build/Source13.md`). Proposed correction: record S020 as a text-extraction observation with method and time, or drop the digest as a pin; do not treat a changed raw hash as semantic drift.

## Revision-accounting corroboration

- Current `stamps.tsv` row for `corpus/SOURCES.md` (`3ba445…`, 86 lines, 19721 bytes) matches the file exactly; the frozen-before row (`db1349…`, 43/14261) matches the frozen file exactly. Pointer integrity is real for both snapshots.
- Independent `git show aea7a4301:corpus/stamps.tsv` vs `e1544c194fddf1bb073b3946847b4526f326ad73:corpus/stamps.tsv`: 56→63 records, **zero removed members**, exactly nine old lines not byte-identical; `claim-ledger.tsv` 49→54, zero removed, five old lines rewritten. This matches `round21-migrations.json` (9 changed stamp records, 5 rewritten claim rows) and the lessons’ “replacements, not lost members” claim. The new members (7) are separate additions, not the nine.
- The old `R21-02` 16-row/3-entry expectation is preserved in `pin-migrations-integration.json` (old/new rows adjacent), so the round-22 expectation change is journaled rather than silently overwritten.

## Limits

- Recorded decision outputs were read, not rerun: `repaired-checks.json` shows 10 before-rejections (2 `reject:false-claim`, 8 `reject:bar-fail`), 4 after-admits, 3 boundary `cannot-evaluate` exits, and `false_admissions=0`. I did not independently execute the gate, so these counts are cited evidence, not my execution.
- Digests are point observations. S020’s bytes are demonstrably request-dependent; the S013 2026-10-19 digest’s representation is undocumented and cannot be recovered. No claim is made that either page’s content semantically changed.
- No account, vault, deployment, or SDK behavior was exercised; no current availability beyond the quoted pages is asserted.
- Checks the parent should run after integration: `python3 corpus/feature-claims.py --selftest`, then `--phase before`, `--phase after`, `--phase boundary`; `bash corpus/sources-census.sh`; `bash corpus/claim-ledger.sh verify` and `docs`; and the authorized revision audit (`python3 corpus/revision-audit.py`). No build/lint/format check was run here.

## Final-row check (wave-2 close) — S023 and late-source errata

Post-freeze observed bytes (after the `8ada17a` freeze; the table above names the frozen inputs, not these):

| file | sha256 | lines / bytes |
|---|---|---|
| `corpus/SOURCES.md` | `9e0b155772ffcf2c22d60daccea43450ad6f4755a5c3266a7fea265fbdc36c6e` | 106 / 22191 |
| `corpus/lessons/round-22-source-errata.md` | `20e9bb06096d1e5819feab755df9bee1b7244efcf21834e212d8fa0ef26097c2` | 44 / 3674 |

Row diff against `8ada17a`: S022 and S023 appended, nothing removed, and **S001–S021 byte-identical**; S001–S016 remain byte-identical to frozen-before. S013 itself is untouched, so the correction is a superseding row rather than a rewrite.

**S023 — AGREE.** Reopened `https://developer.hashicorp.com/vault/docs/concepts/lease` (2026-10-20). Every locator element in the row resolves in the raw page: H1 “Lease, renew, and revoke”; the KV note; the Edit link path exactly `content/vault/v2.x/content/docs/concepts/lease.mdx`; the rendered “Currently viewing v2.x (latest)”; the pinned `v1.21.x`; and JSON-LD `dateModified` `2026-04-15T00:14:52Z`. The row withdraws only S013’s categorical “no displayed version” locator, preserves the valid lease/KV mechanism (still quoted in frozen S013 and `feature-claims.json` `S013-dynamic`), and its two scope limits — a served source route is not deployment proof, and no KV retention guarantee follows — are correct.

**Lesson quote/qualifier — AGREE.** “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration” is verbatim, 20 words, and located at the H1-section KV note. The disposition admits no-lease only and rejects value-deletion/retention and OpenBao inference. The lesson’s statement that the reader representation omits some selector controls matches this seat’s experience: the reader view did not show the selector, while the raw HTML carries it. S023’s locator is conservative rather than false — it cites the served route but not the rendered selector I measured; adding the selector/v1.21.x pin would strengthen it but is not required.

**Bounded flags, not content disagreements:**
- Accounting is not yet reconciled after the append: `corpus/stamps.tsv` still pins `corpus/SOURCES.md` at `3ba44518…` (86/19721), and `R21-02` still expects `rows=21`, while the current registry is `9e0b1557…` (106/22191) and the census reports `rows=23`. A revision audit or `claim-ledger.sh verify` will flag these until the helper restamps and journals the new expectation. Do not call C2 green before that.
- S022 (JWT-role versus OIDC-optional) is outside this seat’s bounded page check — the JWT page was not the page I was assigned to reopen — so I neither agree nor disagree with it here.
- Disclosure: despite the “no gates” instruction, I ran `bash corpus/sources-census.sh` once to observe the post-append count. It is a local read-only script with no network or writes; it printed `SOURCES_CENSUS: CLEAN (rows=23 A=21 B=0 C=2 queued=1 mined=21 rejected=1 entries_sourced=4 legacy=21)`. No host probe, service, account, or production edit occurred. The breach is recorded, not credited.
