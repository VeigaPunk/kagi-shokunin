# SKILL.md — proposed decision-table rows (round 71, C1 depth)

Proposal, not an edit. Integration inserts these four rows into the `## Vault-ops decision table`
immediately after the round-70 PKI row that begins `| Keep a certificate revocable by serial, or
knowingly give that up (OpenBao PKI) |` (SKILL.md line 55), before the blank line and the
`## Control-plane trust boundary` heading (line 57). Column shape is the table's own:
`Intent | Correct surface | Never | Notes / expected output`. Each row cites the round-71 entry.
Each row cites only what the four counted verdicts measured (T6–T9) or what the entry labels as
documentation or inference. No cell carries a pipe character other than the column separators.

Placement check: no row adds a `M<r>-<n>..` range token (SD8) and no row names a PKI theme in a
Frontier bullet (SD1/SD2). The table's row count is not bound by `corpus/self-counts.tsv`.

| Keep a leaf from claiming a lifetime its issuer cannot cover (OpenBao PKI issuer) | the issuer's `leaf_not_after_behavior` left at its default `err`, or `truncate` only where a clipped leaf is acceptable; then read the leaf's notAfter and compare it with the issuer's | `truncate` on an issuer whose callers read the requested TTL as the leaf's lifetime; `permit` (not measured in round 71; documentation only) | T6, OpenBao 2.7.2 dev server: on a 2h issuer set to `truncate`, a 10h leaf is issued with NotAfter equal to the issuer's, and the leaf verifies against that issuer under openssl; the default `err` refuses the same request per the entry (`corpus/knowledge/openbao-pki-issuer-revocation-channels.md` §Measured; `bash corpus/openbao-pki-issuer-trial.sh --work <scratch dir> --evidence <dir>`) |
| Find a revoked leaf of a non-default issuer on that issuer's CRL (OpenBao PKI) | the CRL of the issuer that signed the leaf (`pki/issuer/<ref>/crl`; the role's `issuer_ref` selects the signer), checked for the serial | fetching only the default issuer's CRL to decide that a serial is live | T7: a revoked leaf of the second issuer (role `issuer_ref`) is listed on that issuer's CRL and absent from the default issuer's CRL, both CRL signatures verified with openssl. Not shown: that any relying party fetches that CRL (entry §Does not establish). S173's move of revocations to the default CRL applies only when the issuer has left the mount; that case is not measured |
| Let a token-less client query a leaf's revocation status (OpenBao PKI OCSP) | the mount's OCSP responder with `pki/config/crl` `ocsp_disable=false` (the documented default), queried without a token | `ocsp_disable=true` on a mount whose relying parties depend on OCSP (S170: the responder then answers Unauthorized); a token on a status query (T8 sent none) | T8: token-less OCSP requests return `revoked` for the revoked leaf and `good` for the unrevoked control, and both DER responses verify against the issuer; shim SH8 (`ocsp_disable=true`) flips T8 to BROKEN. Not measured: nonces, GET requests, multi-serial requests and unknown-serial behaviour (`corpus/knowledge/openbao-pki-issuer-revocation-channels.md` §Does not establish) |
| Revoke a `no_store` leaf that must stay revocable (OpenBao PKI) | `pki/revoke-with-key` with the leaf's certificate and private key, passed by `@file` (proof of possession); the key stays under the revoker's custody and out of any evidence | `pki/revoke` by serial on a `no_store` leaf (refused); a `no_store` leaf whose key no revoker holds. Refines the round-70 `no_store` row above it | T9: revoke-by-serial of a `no_store` leaf is refused; revoke-with-key with its certificate and key revokes it, and the issuer-signed CRL lists its serial; shim SH9 (key dropped) flips T9 to BROKEN; no private key reaches the evidence directory (NOSECRET). Without the key the trial measured no revocation route, so the leaf's TTL is its only bound [INFERENCE] |

Notes for integration:
- The first two cells of each row name the object (issuer, CRL, responder, leaf), per the round-70
  rows' pattern and QUALITY QA2 (a claim names its object, product, path and version).
- The falsifier shims and the counted verdicts are named in the knowledge entry; the rows do not
  claim that a relying party behaves in any way (the entry's ceiling).
- Gate registry (SKILL.md `## Gate registry` sections): round 70 added no row for
  `corpus/openbao-pki-trial.sh` or `plans/round-70-c1.sh`, and this draft adds none for
  `corpus/openbao-pki-issuer-trial.sh` or `plans/round-71-c1.sh`. Integration decides whether a
  registry row is wanted; the counter is a frozen claim counter, not a registered gate.
