# PROVINCE.md — proposed round-71 Core line

Proposal, not an edit. Integration appends this bullet directly after the round-70 Core bullet
(`- **Core, round 70 — OpenBao PKI certificate lifecycle, executed:** …`, PROVINCE.md line 97),
inside the `## Core / Frontier / Adjacent` section, before the `**Adjacent**` bullet. The
`<FINAL COUNTER LINE>` placeholder is filled only from the final counter reading on the landed
revision; until then the line must not be committed with a number.

- **Core, round 71 — OpenBao PKI issuer and revocation channels, executed:** `corpus/openbao-pki-issuer-trial.sh` runs four mechanics of `knowledge/openbao-pki-issuer-revocation-channels.md` on the pinned OpenBao 2.7.2 binary against a throwaway `bao server -dev` (127.0.0.1, in-memory storage, random root token only in the environment and never on an argv, `setpriv --pdeathsig KILL`, the port checked to be held by the started server's pid, synthetic names under `r71.test`): T6 an issuer set to `truncate` issues a 10h leaf from a 2h issuer with the issuer's NotAfter, T7 a revoked leaf of a non-default issuer is on its own issuer's CRL and absent from the default issuer's, T8 token-less OCSP requests report `revoked` and `good`, T9 a `no_store` leaf is refused revocation by serial and revoked by proof of possession. Each verdict is flipped by its own falsifier shim and each public artifact is re-checked with openssl (`plans/round-71-c1.sh`; counter reading `<FINAL COUNTER LINE>`). Sources S173 (OpenBao PKI considerations) and S170 (OpenBao PKI API), opened 2026-11-08. Not established: `permit`, intermediate CAs, cross-signing, issuer revocation, an issuer that has left the mount, relying-party CRL or OCSP fetching, and any OpenBao release other than 2.7.2.
