# Kagi: workload identity snapshots and revocation boundaries

Curation date: 2026-11-12 UTC. Destination: `VeigaPunk/kagi-shokunin`, `considerthese/2026-11-12-workload-identity-and-revocation.md`.

Status: reading candidates and unperformed exercises. No credentials were generated, retrieved, rotated, installed, revoked, transmitted, or used. No service was started or contacted. This is not training, assimilation, a security certification, or authorization to change authentication.

## Fit and novelty

Kagi owns secrets and vault operations. The live registry already covers 1Password, SOPS, OpenBao/Vault, machine federation, and PKI lifecycles; this dossier contributes an identity-delivery contract and OpenSSH revocation representation rather than another generic key-rotation checklist. The current log reaches round 72 on 2026-11-09. Registry blob inspected: `82a2f4285dc186b2ed8f9771d557cd34b077a000`.

The 412 locally available curation Markdown files, live systems registries, and recent logs were screened. SPIFFE and OpenSSH certificate/KRL families were not found in the curation corpus. JWT-purpose profiles and response-wrapping were already curated; they are adjacent knowledge, not new sources claimed by this batch. Novelty remains relative to the inspected corpus, not every historical branch.

## Source map and chronology

All sources were opened 2026-11-12. The four SPIFFE documents below declare **Stable** at repository commit `5d15e3ee8782e205048d1f206fbf944e075f7bae`, whose committer timestamp is 2026-11-05T18:52:36Z. This dates the pinned repository state, not each specification's first publication. SPIFFE is a project standard, not an IETF RFC.

1. [SPIFFE Workload API](https://github.com/spiffe/spiffe/blob/5d15e3ee8782e205048d1f206fbf944e075f7bae/standards/SPIFFE_Workload_API.md), §§4.3–4.5, 5 and 6. Blob `f56a8761f9f906bc54e3541636253afc700f7696`.
2. [SPIFFE Trust Domain and Bundle](https://github.com/spiffe/spiffe/blob/5d15e3ee8782e205048d1f206fbf944e075f7bae/standards/SPIFFE_Trust_Domain_and_Bundle.md), §§2–4, 6. Blob `33746e4703f8056a5631a1de1cc2d35ffadaff35`.
3. [X.509-SVID](https://github.com/spiffe/spiffe/blob/5d15e3ee8782e205048d1f206fbf944e075f7bae/standards/X509-SVID.md), §§2, 4–6. Blob `cec8b73004a5ea4c90c18478999dfddb1ef841bc`.
4. [JWT-SVID](https://github.com/spiffe/spiffe/blob/5d15e3ee8782e205048d1f206fbf944e075f7bae/standards/JWT-SVID.md), §§2–4, 6–7. Blob `8f0f39c1007ce786b5a7214ac02e21c453081270`.

OpenSSH sources are pinned to `268bdcb0c80876d97abdc74a1ca8992a1fdf7652`, committer timestamp 2026-11-10T23:21:57Z. This is a source snapshot, not a release claim:

5. [ssh-keygen manual source](https://github.com/openssh/openssh-portable/blob/268bdcb0c80876d97abdc74a1ca8992a1fdf7652/ssh-keygen.1), CERTIFICATES and KEY REVOCATION LISTS. Blob `be69bf08acc3b9a644c53635c4eb2edfae7a732c`.
6. [KRL format](https://github.com/openssh/openssh-portable/blob/268bdcb0c80876d97abdc74a1ca8992a1fdf7652/PROTOCOL.krl), sections Overall format and Certificate section. Blob `1b59c76be17eb3400ac8e567f147d9024c15886b`.
7. [sshd configuration manual source](https://github.com/openssh/openssh-portable/blob/268bdcb0c80876d97abdc74a1ca8992a1fdf7652/sshd_config.5), TrustedUserCAKeys, AuthorizedPrincipalsFile, RevokedKeys. Blob `f98cbf8885bdaeab4141e64cc672b7788000683e`.

The older `PROTOCOL.certkeys` locator was absent at this snapshot; it is excluded, not silently treated as read. The current manual and KRL file are the actual evidence.

## 1. Identity stream responses replace state; they are not patches

**Source method.** The Workload API's stream responses contain the full state. Default or empty fields clear previous values; clients must not preserve an old nonempty field merely because an update is empty. Missing data is to be interpreted as redaction according to the specification's stated strength. Bundle updates and identity rotation therefore require replacement semantics, not a map union. A removed federated bundle must not survive accidentally in the consumer.

**Proposed exercise, not run:** an offline reducer over six synthetic stream snapshots, using symbolic certificate and key labels only: initial local plus foreign bundle; new local key overlapping the old one; removal of the old key; removal of the foreign bundle; explicit empty optional map; disconnection followed by a complete replacement snapshot. Include the intentionally wrong map-merge reducer as a negative control. Do not fabricate a structurally invalid empty mandatory SVID set and then call it a valid server response.

**Report contract.** For every snapshot, show input field presence, old/new trust-domain keys, removed entries, and any invalid-message verdict. The merge reducer must retain a revoked/removed entry in at least one case and fail. Distinguish removal delivered to a client from global instantaneous revocation: the API does not prove every workload received an update at the same moment.

## 2. Bind validation material to its trust domain and SVID profile

**Source method.** A trust domain has a set of authoritative keys; the bundle must remain associated with the domain it represents. Reusing one root across domains can erode isolation. Bundle entries have profile-specific uses. X.509-SVID validation adds constraints to ordinary X.509 path validation: exactly one URI SAN identifying the workload, a non-root workload path, and leaf rather than signing-certificate restrictions. A JWT-SVID verifier uses keys designated for JWT-SVID and must not accept an arbitrary trusted key from another profile or domain.

**Proposed exercise, not run:** 12 metadata-only fixtures: correct domain/profile; wrong domain with the same key label; wrong profile; missing bundle; two URI SANs; no URI SAN; root-only workload path; signing certificate presented as a leaf; leaf with keyCertSign; duplicate trust-domain JSON members; foreign bundle removed by update; and valid rotation overlap. Use an ordinary strict JSON parser plus a symbolic decision table, without real PEM or private-key material. Mark parsing ambiguity separately from invalid identity.

**Report contract.** Name the exact rejection layer: structural parse, domain lookup, profile selection, X.509 path validation, or SVID-specific leaf validation. The symbolic exercise can test routing and policy predicates only; it cannot demonstrate cryptographic signature/path verification. Future cryptographic tests must use established libraries and disposable test material, under a separately approved execution scope.

## 3. Audience and expiry narrow bearer-token exposure; they do not eliminate replay

The earlier JWT-purpose-profile note already covers enforced audience/type boundaries under RFC 8725. This unit is a SPIFFE-specific transfer exercise, not a new general JWT principle; its added source contract is the mandated claims, profile-key selection, and explicitly documented multi-audience replay limitation.

**Source method.** JWT-SVID requires `aud` and `exp`, restricts allowed signing algorithms, and binds `sub` to a workload SPIFFE ID. Its security considerations explicitly preserve bearer-token replay risk. A token addressed to multiple services can be replayed by one recipient to another. Keep this separate from a proof-of-possession scheme or a one-time token.

**Proposed exercise, not run:** eight synthetic claim sets, no signatures or usable tokens: single audience; missing audience; wrong audience; multiple audiences; expired; missing expiry; unknown signing algorithm; correct claims with a replayed token identifier. Freeze the local clock in the fixture. A policy validator may accept the last fixture's claims while still marking replay unmitigated; it must not invent replay prevention from successful claim validation.

**Report contract.** State what was checked and what was deliberately not checked. A claim-only checker must never report “authenticated.” Compare broad audience labels with service-specific labels, showing the recipient set rather than asserting a universal maximum token lifetime. The source recommends short validity but specifies no hard upper bound.

## 4. A certificate's validity, principal authorization, and revocation are separate checks

**Source method.** The ssh-keygen manual separates certificate principals, validity intervals, critical options, and CA trust. Unknown critical options cause refusal; ordinary unknown extensions may be ignored. KRLs can identify certificates by serial or key ID in a CA-scoped certificate section. The format also allows an empty CA key to make that section apply to all CAs, a scope distinction a reviewer should not overlook. A generated KRL file is only a representation: enforcement depends on the consumer actually reading the intended revocation file.

**Proposed exercise, not run:** ten offline metadata fixtures across two fake CA names with reused serial numbers, two principals, expired and not-yet-valid intervals, one unknown critical option, explicit-key revocation versus certificate revocation, CA-specific serial revocation, and an all-CA section. Add a stale KRL-version fixture. No real SSH connection, daemon configuration, trust-store installation, or credential generation is part of the exercise.

**Report contract.** Record the revocation lookup as CA plus serial/key ID, alongside certificate identity, selected principal, time predicate, option predicate, matched revocation entry, and consumer configuration evidence if an implementation is ever tested. Do not let serial 7 under CA-A silently revoke serial 7 under CA-B unless the section intentionally spans CAs. A stale but syntactically valid KRL must be described as a freshness problem, not a malformed-format finding.

## Rights, containment, and iteration

The inspected SPIFFE repository LICENSE is Apache 2.0. OpenSSH is not uniformly one license: its LICENCE file describes multiple permissive terms and file-specific notices. This dossier copies no implementation, certificate, key, or source excerpt. Preserve the applicable notices if a later exercise adapts code. A link to a public source is not a license to redistribute unrelated assets.

All proposed fixtures are synthetic and local. No production identity endpoint, vault, keychain, environment-secret file, or account is needed. Each future report should retain source pins, fixture hashes, expected outcomes set before execution, tool versions, actual outcomes, negative controls, unresolved cases, and one scoped revision. A second reviewer should challenge the easiest false-green path before the suite grows. Stop if further cases merely rename the same predicate or require real authority rather than a disposable model. Training and assimilation remain separate decisions.
