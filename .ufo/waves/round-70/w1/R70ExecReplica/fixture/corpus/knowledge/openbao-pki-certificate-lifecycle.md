# OpenBao PKI: an internal CA key never leaves the mount, a role's max_ttl clamps (not refuses) a longer request, allowed_domains refuses outside names, revocation lands on the CRL, and no_store certificates cannot be found by serial

source: S170 (https://openbao.org/docs/api/secret/pki/, the PKI secrets-engine API page — the old path /api-docs/secret/pki/ is a meta-refresh stub to it; §Generate key, §Create/Update role (`max_ttl`, `allowed_domains`, `allow_any_name`, `no_store`), §Generate certificate and key (`ttl`), §Revoke certificate; opened 2026-11-08); S171 (https://openbao.org/docs/secrets/pki/, the engine overview's short-TTL/revocation rationale; opened 2026-11-08)
verified-at: 2026-11-08 (both pages fetched as decoded bodies and read as rendered text; the five behaviours below executed against OpenBao 2.7.2 by `corpus/openbao-pki-trial.sh`)
recheck: on-release — on an OpenBao release, re-open S170 §Create/Update role and §Generate certificate and key, compare the documented defaults, and re-run `bash corpus/openbao-pki-trial.sh --work <scratch dir>` against the new binary
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the trial is the behaviour check.)

Scope: OpenBao 2.7.2 only, one `pki` mount on a throwaway `bao server -dev` (127.0.0.1, in-memory
storage, random root token kept in scratch). HashiCorp Vault's PKI API page (opened and
rejected this round, `corpus/lessons/round-70.md` §Gate) is not used as evidence for OpenBao behaviour, and the reverse does not
follow. The trial never touches a deployed CA, a real certificate, an HSM/KMS key or an ACME
client; it measures the binary's own engine on synthetic names under `r70.test`.

## Why it matters for secrets operations

A PKI mount is a credential issuer: every certificate it signs is a bearer credential for a
name. Four settings decide how much damage a leaked or over-broad issuance can do. Where the CA
key lives (`internal` keeps it inside the mount — S170: "if it is internal the private key will
not be returned and cannot be retrieved later"), how long a leaf lives (the role's `max_ttl`),
which names a role may sign (`allowed_domains` and its matching flags), and whether a leaf can be
revoked by serial at all (`no_store`). S171's design rationale is the operational reason short
lifetimes matter: "By keeping TTLs relatively short, revocations are less likely to be needed,
keeping CRLs short". The checklist consequence for an operator:

| decision | safe default | what the trial measured | failure if wrong |
|---|---|---|---|
| CA key generation | `root/generate/internal` (or an external KMS) | T1: response has `certificate`, no `private_key` | `exported` returns the CA private key in an API response — it is then in logs, shells and clipboards |
| leaf lifetime | role `max_ttl` set explicitly | T2: a 24h request on a `max_ttl=1h` role is **issued**, clamped to 1h, with a warning | callers that read only the exit status believe they got 24h; without `max_ttl` the mount/system max applies |
| names a role may sign | `allowed_domains` + `allow_subdomains`, never `allow_any_name` | T3: `evil.example` refused, `ok.r70.test` issued | `allow_any_name=true` lets the role sign any CN |
| revocation | stored certificates; revoke by serial | T4: the revoked serial is on the mount CRL | a revoke that never reached the server leaves the serial off the CRL |
| `no_store` | only for short-lived, never-revoked leaves | T5: the `no_store` leaf is not readable at `cert/<serial>` and not listed; a stored control is | a `no_store` leaf cannot be revoked by serial — the only bound left is its TTL |

## Measured (round 70 — OpenBao 2.7.2 dev server, 127.0.0.1, one pki mount)

Command: `bash corpus/openbao-pki-trial.sh --work <scratch dir>` (exit 0, `OPENBAO_PKI_TRIAL:
HOLDS holds=5 broken=0 error=0`), and the frozen counter `bash plans/round-70-c1.sh <rev>`, which
runs the same trial under five falsifier shims (each shim breaks its own test and no other).

- T1 root-internal — OpenBao 2.7.2: `pki/root/generate/internal` returned `certificate`, `issuer_id`, `key_id` and no `private_key` field; the same call on `.../exported` returns `private_key` and `private_key_type` (probe and shim SH1).
- T2 ttl-clamp — OpenBao 2.7.2: a `ttl=24h` request on a role with `max_ttl=1h` exited 0 and issued a leaf whose notAfter − notBefore is 3630 s (1h plus the engine's 30 s notBefore backdate), with the response warning `TTL "24h0m0s" is longer than permitted maxTTL "1h0m0s", so maxTTL is being used`. The API page's "Cannot be greater than the role's max_ttl value" is therefore enforced as a clamp, not a refusal.
- T3 domain-refuse — OpenBao 2.7.2: with `allowed_domains=r70.test allow_subdomains=true`, `common_name=evil.example` was refused (non-zero exit) while `ok.r70.test` was issued; with `allow_any_name=true` added (shim SH3) the outside name is issued.
- T4 revoke-crl — OpenBao 2.7.2: `pki/revoke serial_number=<serial>` returned `state revoked`, and the serial appears in `openssl crl -text` of the CRL read from `pki/cert/crl`.
- T5 no-store — OpenBao 2.7.2: a leaf from a `no_store=true` role is absent from `pki/certs` and `pki/cert/<serial>` answers "No value found"; a leaf from an otherwise identical stored role is listed and readable.

## Does not establish

- Anything about HashiCorp Vault's PKI engine, Vault Enterprise features, or OpenBao releases
  other than 2.7.2.
- Intermediate CAs, cross-signing, multiple issuers' chain building, `leaf_not_after_behavior`,
  ACME, OCSP responses, delta CRLs, auto-tidy, BYOC revocation or revocation with a private key.
- That a client honours the CRL: T4 shows the serial is on the CRL the mount publishes, not that
  any relying party fetches or enforces it.
- `allowed_domains` matching beyond one exact domain with subdomains (no globs, bare domains,
  wildcards, IP or URI SANs).
- Performance or storage effects of `no_store` at scale (the API page's stated motivation).

## Falsifiers

Each would show the entry wrong, and each is what the round-70 counter's shims simulate:

1. `root/generate/internal` returns a `private_key` field (SH1 turns the call into `exported`).
2. A `ttl` above the role's `max_ttl` yields a longer lifetime or is refused outright (SH2 drops
   `max_ttl` from the role — the leaf then lives the requested 24h).
3. A CN outside `allowed_domains` is issued without `allow_any_name` (SH3 adds it).
4. A revoked serial is missing from the CRL (SH4 swallows the revoke).
5. A `no_store` leaf is readable or listed by serial (SH5 drops `no_store`).
