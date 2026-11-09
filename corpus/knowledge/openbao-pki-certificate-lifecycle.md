# OpenBao 2.7.2 PKI, one dev mount: `root/generate/internal` returned no CA private key, a 24h request on a `max_ttl=1h` role was issued clamped (not refused), a CN outside `allowed_domains` (one domain + subdomains) was refused, a revoked serial was on the mount CRL, and a `no_store` leaf was not found by serial

source: S170 (https://openbao.org/docs/api/secret/pki/, the PKI secrets-engine API page — the old path /api-docs/secret/pki/ is a meta-refresh stub to it; §Generate key, §Create/Update role (`max_ttl`, `allowed_domains`, `allow_any_name`, `no_store`), §Generate certificate and key (`ttl`), §Revoke certificate; opened 2026-11-08); S171 (https://openbao.org/docs/secrets/pki/, the engine overview's short-TTL/revocation rationale; opened 2026-11-08)
verified-at: 2026-11-08 (both pages fetched as decoded bodies and read as rendered text; the five behaviours below executed against OpenBao 2.7.2 by `corpus/openbao-pki-trial.sh`)
recheck: on-release — on an OpenBao release, re-open S170 §Create/Update role and §Generate certificate and key, compare the documented defaults, and re-run `bash corpus/openbao-pki-trial.sh --work <scratch dir>` against the new binary
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the trial is the behaviour check.)

Scope: OpenBao 2.7.2 only, one `pki` mount on a throwaway `bao server -dev` (127.0.0.1, in-memory
storage, random root token held only in the trial's environment — never on an argv, never stored; `setpriv --pdeathsig KILL`; the listening port checked to belong to the server the trial started). HashiCorp Vault's PKI API page (opened and
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
keeping CRLs short". The table separates what the trial measured (column 3; the counter flips each
verdict with a falsifier shim) from the operator consequence (column 4), which is documentation
(S170/S171) or the lane's own inference, marked as such — not a measurement.

| decision | safe default | what the trial measured (T-verdict) | consequence if wrong (source) |
|---|---|---|---|
| CA key generation | `root/generate/internal` (or an external KMS) | T1: the internal call's response carries `certificate` and no `private_key` | `exported` returns the CA private key in the API response (S170: "If the path ends with exported, the private key will be returned in the response"); where it then travels — logs, shells, clipboards — is [INFERENCE] |
| leaf lifetime | role `max_ttl` set explicitly | T2: a 24h request on a `max_ttl=1h` role is issued with a lifetime ≤ 3660 s | without `max_ttl` the role falls back to the system maximum lease TTL (S170 role `max_ttl`: "If not set, defaults to the system maximum lease TTL"); a caller that reads only the exit status cannot tell it was clamped [INFERENCE] |
| names a role may sign | `allowed_domains` + `allow_subdomains`, never `allow_any_name` | T3: `evil.example` refused while `ok.r70.test` issued, for one exact domain with subdomains | with `allow_any_name` "this attribute has no effect" (S170 `allowed_domains`) |
| revocation | stored certificates; revoke by serial | T4: the revoked serial is listed in the mount CRL read from `pki/cert/crl` | a revoke that never reached the server leaves the serial off the CRL (shim SH4) |
| `no_store` | only for short-lived, never-revoked leaves | T5: the `no_store` leaf is not found by serial (the trial checks both read and list; the counter enforces that at least one of them refuses — R70MutTester MT-1) while a stored control is found | S170: such certificates "cannot be enumerated or revoked via serial number"; the TTL is then the remaining bound [INFERENCE] |

## Measured (round 70 — OpenBao 2.7.2 dev server, 127.0.0.1, one pki mount)

Command: `bash corpus/openbao-pki-trial.sh --work <scratch dir>` (exit 0, `OPENBAO_PKI_TRIAL:
HOLDS holds=5 broken=0 error=0`), and the frozen counter `bash plans/round-70-c1.sh <rev>`, which
runs the same trial under five falsifier shims (each shim breaks its own test and no other).
Each line below says what the counter enforces; "observed" details come from the L1 probe receipt
`.ufo/waves/round-70/final/l1-probe-observations.txt` (one run, not counter-enforced).

- T1 root-internal — OpenBao 2.7.2: enforced — the `root/generate/internal` response has a non-empty `certificate` and no `private_key` key; shim SH1 (internal → exported) flips it. Observed: the response keys were `certificate expiration issuer_id issuer_name issuing_ca key_id key_name serial_number`; the `exported` call added `private_key` and `private_key_type`.
- T2 ttl-clamp — OpenBao 2.7.2: enforced — a `ttl=24h` request on a `max_ttl=1h` role succeeds and the leaf's notAfter − notBefore is ≤ 3660 s; shim SH2 (role without `max_ttl`) flips it. Observed: lifetime 3630 s (notBefore 01:11:41, notAfter 02:12:11 UTC) and the response warning `TTL "24h0m0s" is longer than permitted maxTTL "1h0m0s", so maxTTL is being used`. S170's "Cannot be greater than the role's max_ttl value" is thus a clamp on 2.7.2, not a refusal.
- T3 domain-refuse — OpenBao 2.7.2: enforced — with `allowed_domains=r70.test allow_subdomains=true` the issue for `evil.example` fails and the issue for `ok.r70.test` succeeds; shim SH3 (role gains `allow_any_name=true`) flips it. Observed: the refusal text `common name evil.example not allowed by this role`, client exit 2.
- T4 revoke-crl — OpenBao 2.7.2: enforced — after `pki/revoke serial_number=<serial>` the serial (colons stripped, upper-case) is a `Serial Number:` line of `openssl crl -text` over the CRL read from `pki/cert/crl`; shim SH4 (revoke never sent) flips it. Observed: the revoke response carried `state revoked` and a `revocation_time`.
- T5 no-store — OpenBao 2.7.2: enforced — a leaf from a `no_store=true` role is not found by serial (the counter's shim SH5 flips the verdict; MT-1 shows the counter accepts a trial that checks only read or only list, so the conjunction rests on the landed trial's code), while a stored control leaf is readable and listed. Observed: `No value found at pki/cert/<serial>`, client exit 2.

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
- Revocation of a leaf signed by a non-default issuer: T4 uses the default issuer's CRL only
  (R70Scout SC-1 observed such a leaf on its own issuer's CRL and absent from the default one —
  a frontier lead, unmeasured by this trial).
- That *any* trial passing the round-70 counter executes these mechanics: the counter reads the
  trial's verdict words under shims and is satisfiable by forgeries that never start a server
  (R70Revenger RE-1, forgeries A/C/D). That the landed `corpus/openbao-pki-trial.sh` does execute
  them through the `bao` CLI, with no shim detection, rests on non-author reading of its code
  (R70Reviewer RV-5, R70Critic CR-14, R70Revenger RE-2), not on the count.

## Falsifiers

Each would show the entry wrong, and each is what the round-70 counter's shims simulate:

1. `root/generate/internal` returns a `private_key` field (SH1 turns the call into `exported`).
2. A `ttl` above the role's `max_ttl` yields a longer lifetime or is refused outright (SH2 drops
   `max_ttl` from the role — the leaf then lives the requested 24h).
3. A CN outside `allowed_domains` is issued without `allow_any_name` (SH3 adds it).
4. A revoked serial is missing from the CRL (SH4 swallows the revoke).
5. A `no_store` leaf is readable or listed by serial (SH5 drops `no_store`).
