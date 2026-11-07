
## Measured (round 51 — OpenBao 2.7.2 dev server, 127.0.0.1, response wrapping)

source: S108 (https://openbao.org/docs/concepts/response-wrapping/, Version 2.7.x, opened 2026-11-07)

`bash corpus/openbao-wrap-trial.sh --work <scratch>` drives the `bao` CLI against a throwaway `bao server -dev` (in-memory, random root token kept in scratch, `setpriv --pdeathsig KILL`); wrapped values are random `r51-` nonces in the dev server's KV v2 `secret/` mount.

- T1 single use (OpenBao 2.7.2): the first `bao unwrap` of a wrapped `kv get` returns the value; a second unwrap of the same token is refused (`wrapping token is not valid or does not exist`).
- T2 wrap TTL (OpenBao 2.7.2): a `-wrap-ttl=2s` token can no longer be unwrapped after 4 s while the KV secret itself stays readable.
- T3 lookup (OpenBao 2.7.2): `sys/wrapping/lookup` with no client token reports `creation_path` `secret/data/t3` and does not consume the token; after the unwrap the same lookup is refused.
- T4 rewrap (OpenBao 2.7.2): `sys/wrapping/rewrap` returns a different token that unwraps to the same value; the old token is refused.
- T5 creation path (OpenBao 2.7.2): a value read out and wrapped again through `sys/wrapping/wrap` carries creation path `sys/wrapping/wrap`, not `secret/data/t5`, so a client that checks the exact path detects the re-wrap.
