# OpenBao 2.7.2 PKI, one dev mount with two roots: a `truncate` issuer clipped a 10h leaf to its own NotAfter, a revoked leaf of a non-default issuer was on its own issuer's CRL and not the default's, token-less OCSP answered `revoked`/`good`, and a `no_store` leaf refused by serial was revoked by proof of possession

source: S173 (https://openbao.org/docs/secrets/pki/considerations/, §Always configure a default issuer; opened 2026-11-08); S170 (https://openbao.org/docs/api/secret/pki/, §Update issuer (`leaf_not_after_behavior`, POST overwrite note), §Set revocation configuration (`ocsp_disable`), §OCSP request, §Revoke certificate with private key, §Create/Update role (`no_store`, `issuer_ref`); re-opened 2026-11-08, byte-identical to its round-70 capture)
verified-at: 2026-11-08 (both pages fetched as decoded bodies and read as rendered text; the four behaviours below executed against OpenBao 2.7.2 by `corpus/openbao-pki-issuer-trial.sh`)
recheck: on-release — on an OpenBao release, re-open S170 §Update issuer and §Set revocation configuration and S173 §Always configure a default issuer, compare the documented defaults, and re-run `bash corpus/openbao-pki-issuer-trial.sh --work <scratch dir> --evidence <dir>` against the new binary
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the trial is the behaviour check.)

Scope: OpenBao 2.7.2 only, one `pki` mount holding two self-signed roots (`r71root` default,
`r71second`) and one short-lived root (`r71short`, 2h), on a throwaway `bao server -dev`
(127.0.0.1, in-memory storage, random root token held only in the trial's environment — never on
an argv, never stored; `setpriv --pdeathsig KILL`; the listening port checked to belong to the
server the trial started). No intermediate CA, no cross-signing, no relying party: the trial
measures what the mount issues and publishes on synthetic names under `r71.test`. Extends
`corpus/knowledge/openbao-pki-certificate-lifecycle.md` (round 70, one default issuer).

## Why it matters for secrets operations

A mount with more than one issuer — the normal shape during a CA rotation — has custody rules
that a single-issuer reading misses. Which issuer signs a leaf decides which CRL a revocation
lands on; S173: "For backwards compatibility, the default issuer is used to service PKI endpoints
without an explicit issuer (either via path selection or role-based selection)". An issuer's own
`leaf_not_after_behavior` decides whether a leaf may claim a lifetime its issuer cannot vouch for
(S170: "Behavior of a leaf's NotAfter field during issuance", default `err`). Revocation status
reaches relying parties over two channels, the CRL and the OCSP responder, and S170 states the
OCSP paths "are unauthenticated endpoints". A `no_store` leaf "cannot be enumerated or revoked via
serial number" yet S170 adds "Certificates may still be revoked via BYOC revocation". The table
separates what the trial measured (column 3; the counter flips each verdict with a falsifier shim
and re-checks the public artifacts with openssl) from the operator consequence (column 4), which
is documentation (S170/S173) or the lane's own inference, marked as such.

| decision | safe default | what the trial measured (T-verdict) | consequence if wrong (source) |
|---|---|---|---|
| issuer NotAfter policy | `truncate` on intermediates, `err` where a refusal is wanted | T6: on a `truncate` issuer whose own lifetime is under 10h (2h requested), a leaf requested at `ttl=10h` is issued with NotAfter equal to the issuer's (the counter checks the dates and the <10h issuer lifetime; the requested TTLs are the trial's) | under `permit` a leaf outlives its issuer; S170: "Not all values result in leaf certificates that can be validated through the entire validity period" |
| updating one issuer field | `bao patch`, or re-send every field | observed while building T6: `bao write pki/issuer/<ref> leaf_not_after_behavior=…` reset `issuer_name` to `""` | S170: POST "does not update only the provided fields" and "Note that bao write uses POST"; a later reference by the lost name fails (`unable to find PKI issuer for reference`, observed) |
| which CRL a revocation lands on | relying parties fetch the CRL of the leaf's own issuer (`pki/issuer/<ref>/crl`) | T7: a revoked leaf signed by the non-default issuer (role `issuer_ref`) is on its issuer's CRL and absent from the default issuer's CRL | a client that fetches only the default CRL sees that serial as live [INFERENCE]; S173 sends revocations to the default CRL only when the issuer has left the mount |
| OCSP responder | enabled (`ocsp_disable=false`, the documented default) | T8: token-less OCSP requests report the revoked leaf `revoked` and an unrevoked control `good`, both responses signed by the issuer | with `ocsp_disable=true` "the OCSP responder will always respond with an Unauthorized OCSP response" (S170); anyone can query a serial's status without a token, which is what a revocation channel is for [INFERENCE] |
| revoking a `no_store` leaf | keep the leaf's key where the revoker can prove possession, or do not use `no_store` for revocable leaves | T9: revoke-by-serial of a `no_store` leaf is refused; `pki/revoke-with-key` with its certificate and key revokes it and the serial is on the issuer's CRL | without the key the leaf cannot be revoked at all and its TTL is the only bound [INFERENCE] |

## Measured (round 71 — OpenBao 2.7.2 dev server, 127.0.0.1, one pki mount, two roots)

Command: `bash corpus/openbao-pki-issuer-trial.sh --work <scratch dir> --evidence <dir>` (exit 0,
`OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0 error=0`), and the frozen counter
`bash plans/round-71-c1.sh <rev>`, which runs the same trial under four falsifier shims (each shim
breaks its own test and no other) and re-checks the real run's public artifacts with openssl.
Each line says what the counter enforces; "observed" details are from the L1 build runs (receipts
under `.ufo/waves/round-71/final/`), not counter-enforced.

- T6 notafter-truncate — OpenBao 2.7.2: enforced — the trial's verdict, flipped by shim SH6 (the issuer write loses `leaf_not_after_behavior`, so the default `err` refuses the 10h leaf), and the artifact check: the leaf verifies against the 2h issuer and its notAfter equals the issuer's. Observed: the issuer read back `leaf_not_after_behavior: err` before the write.
- T7 nondefault-crl — OpenBao 2.7.2: enforced — the trial's verdict, flipped by shim SH7 (the role loses `issuer_ref`, so the leaf comes from the default issuer and lands on the default CRL), and the artifact check: the leaf verifies against the second issuer and not the default; the second issuer's CRL (signature verified against it) lists the serial; the default issuer's CRL (signature verified) does not.
- T8 ocsp-unauth — OpenBao 2.7.2: enforced — the trial's verdict, flipped by shim SH8 (`pki/config/crl` gets `ocsp_disable=true`), and the artifact check: both DER responses verify against the issuer and report `revoked` for the revoked leaf and `good` for the control. The requests carried no token (the trial's `openssl ocsp` runs with `BAO_TOKEN` unset; openssl does not read it in any case).
- T9 revoke-with-key — OpenBao 2.7.2: enforced — the trial's verdict, flipped by shim SH9 (the `revoke-with-key` call loses `private_key`), and the artifact check: the leaf verifies against the issuer and the issuer-signed CRL lists its serial. The refusal of revoke-by-serial is part of the landed trial's HOLDS condition only: no shim and no artifact leg tests it, and a trial that never attempts the serial revoke also reads `value=4` (R71MutTester MT-1, fixture f-m11).

## Does not establish

- Anything about HashiCorp Vault's PKI engine or OpenBao releases other than 2.7.2.
- `permit` behaviour, intermediate CAs, cross-signing, chain building, issuer revocation
  (`pki/issuer/<ref>/revoke`), an issuer that has left the mount (the S173 default-CRL case),
  unified or delta CRLs, auto-tidy, ACME, CEL roles.
- That any relying party fetches the right CRL or queries OCSP: the trial reads what the mount
  publishes.
- OCSP nonces, GET-form requests, multi-serial requests (S170: "Only a single serial number within
  the request will appear in the response"), or responder behaviour for unknown serials.
- That *any* trial passing the round-71 counter executes these mechanics through OpenBao: a
  same-uid trial can read the wrapper bytes to learn the active shim and mint look-alike
  artifacts with local openssl (the counter's named ceiling, `plans/round-71.md`; R71Revenger
  forgery A reaches `value=4`), can drive the server over HTTP instead of the CLI (forgery B), or
  can compute its verdicts from config read-backs and call statuses while its artifacts are real
  (forgery C): the counter does not bind a verdict to the artifact it checks (plan Amendment A1).
  That the landed trial does execute them through the `bao` CLI, with verdicts taken from the
  mechanic's own output, rests on non-author reading of its code (R71Reviewer RV-5, R71Revenger
  RE-4).
- That no secret leaves the trial in any encoding: the counter's NOSECRET leg is a fixed regex
  (`PRIVATE KEY`, four token prefixes, the dev-token shape) over output and evidence; it would miss
  a raw DER or bare base64 key (R71Sentinel SE-7, who found the landed evidence clean in every
  encoding). Leaf private keys sit in the trial's `umask 077` scratch until its EXIT trap; a
  SIGKILL of the trial leaves them there (SE-1).

## Falsifiers

1. A leaf from a `truncate` issuer outlives the issuer, or is refused (SH6 removes the setting —
   the default `err` then refuses it).
2. A revoked non-default-issuer leaf appears on the default CRL or is missing from its own (SH7
   drops `issuer_ref`, so the leaf is signed by the default issuer).
3. A token-less OCSP request for a revoked leaf does not return `revoked` (SH8 disables OCSP).
4. A `no_store` leaf is revocable by serial, or not revocable with its own key (SH9 drops the key).
