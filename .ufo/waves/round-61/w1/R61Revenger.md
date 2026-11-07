# R61Revenger — scoped findings (round 61, w1)

Full artifact: `.ufo/waves/round-61/build/R61Revenger/rekey.md` (reproduction, raw
responses, binary evidence, alternative-routes table, custody consequence).

Binary: OpenBao v2.7.2 `9e0a0d3c3504a0a00b45e61355afac5e35c78379`, sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (scratch copy).

Servers (throwaway, `setpriv --pdeathsig KILL`, `tls_disable = 1`, scratch storage,
each init 5 shares / threshold 3 and unsealed with 3):

| id | port | storage | listener config | role |
|---|---|---|---|---|
| raft | 8210 | `storage "raft"` (node_id `r61n1`) | default (no rekey key) | reproduction + full `rotate-keys` rotation |
| inmem | 8220 | `storage "inmem"` | default | backend independence + full `rotate-keys` rotation |
| raft2 | 8230 | `storage "raft"` (node_id `r61n2`) | `disable_unauthed_rekey_endpoints = false` | decisive experiment + full `operator rekey` rotation |
| raft3 | 8240 | `storage "raft"` (node_id `r61n3`) | `disable_unauthed_rekey_endpoints = true` | control (must read 405) |

## Finding

`sys/rekey/init` is **not removed and not a stub**. The 405 is a registration gate:

1. `internal/http/handler.go:181-195` mounts `/v1/sys/rekey/{init,update,verify}` and
   the `rekey-recovery-key/*` routes **only if** the listener sets
   `disable_unauthed_rekey_endpoints = false` explicitly. Default (absent) and `true`
   both leave them unmounted.
2. Unmounted, the request falls through to the logical layer.
   `internal/vault/logical_system_paths.go` `rekeyPaths()` registers `rekey/init`
   (Read/Update/Delete), `rekey/update` (Update) and `rekey/verify`
   (Read/Delete/Update) with schema but **no `Callback:`**; `rekey/backup$` and
   `rekey/recovery-key-backup$` keep their callbacks.
3. `sdk/framework/backend.go:239-273` maps a nil callback to
   `logical.ErrUnsupportedOperation` → HTTP **405 `{"errors":["unsupported operation"]}`**.
4. `internal/vault/logical_system.go:108-121` declares those paths
   `Unauthenticated`, so the 405 is returned **before any token check** (anonymous and
   bogus-token requests also get 405, not 403).

Measured: 405 for POST/PUT/GET/DELETE on `sys/rekey/init`, POST `sys/rekey/update`,
GET/POST `sys/rekey/verify`, on both raft and inmem, with root, bogus and no token.
Controls: `PATCH` → 400 `mime: no media type` (handler ran); `GET /v1/sys/rekey/backup`
→ 400 `no backed-up keys found`; `DELETE /v1/sys/rekey/backup` → 204; anon
`GET /v1/sys/rotate/keyring` → 403 (not unauthenticated).

## Alternative routes (measured)

| route | default | flag=false | flag=true |
|---|---|---|---|
| `operator rekey -init` → `PUT /v1/sys/rekey/init` | 405, rc 2 | **200 + nonce, rc 0** | 405 |
| `operator rekey -init -target=recovery` → `PUT /v1/sys/rekey-recovery-key/init` | **404 unsupported path** | 400 `recovery rekeying not supported` | 404 |
| `operator rekey -verify` → `GET /v1/sys/rekey/verify` | 405 | rc 1 client-side | 405 |
| `operator rekey -cancel` → `DELETE /v1/sys/rekey/init` | 405 | 204 | 405 |
| `operator rekey -backup-retrieve` → `GET /v1/sys/rekey/backup` | 400 no backed-up keys | 400 | 400 |
| `operator rotate-keys -init` → `POST /v1/sys/rotate/root/init` | 200 nonce, 0/3, t=2 n=3 | 200 | 200 |
| `operator rotate-keys -init -target=recovery` → `POST /v1/sys/rotate/recovery/init` | 400 `recovery keys not supported` | 400 | 400 |
| `operator rotate-keys -verify` | client-side rc 1 `No rotation is in progress.` | — | — |
| `operator rotate-keys -cancel` → `DELETE /v1/sys/rotate/root/init` | 204 | 204 | 204 |
| `GET /v1/sys/rotate/root/init` | 200 status | 200 | 200 |
| `GET /v1/sys/rotate/root/backup` | 400 `no backed-up keys found` | — | — |
| `GET /v1/sys/rotate/root/verify` | 400 `no rotation configuration found` | — | — |
| `POST /v1/sys/rotate` / `…/keyring` / `…/root` | 204 | — | — |
| `GET /v1/sys/rotate/root` / `…/keyring` | 405 (UpdateOperation only) | — | — |
| `GET /v1/sys/rotate/config` | 200 | — | — |

`rotate-keys` **completes a full rotation** (raft and inmem): init 5/3 → 3/2, three
current shares, new 3-key set, seal, old shares refused at reconstruction
(`400 invalid key: failed to decrypt keys from storage: cipher: message authentication
failed`), new shares unseal (`sealed=false t=2 n=3`), root token still valid. A single
old share is accepted as `1/2` — shares are accumulated, not validated individually.

## Custody consequence

- Change shares/threshold on this build: `bao operator rotate-keys -init
  -key-shares=N -key-threshold=M` + `threshold` current shares. Non-destructive,
  measured end-to-end.
- `sys/rotate`, `sys/rotate/keyring`, `sys/rotate/root` rotate encryption keys; `t`/`n`
  unchanged (measured).
- `operator init` on an initialized server: 400 `Vault is already initialized`, rc 2 —
  not a share-change path.
- `-target=recovery` only applies to auto-unseal; on shamir it is 400.
- Legacy `operator rekey` works only with `disable_unauthed_rekey_endpoints = false`
  (listener restart required). While enabled, the endpoints are unauthenticated by
  design: anon init 200, anon status 200, anon update accepted (400 on bogus key), anon
  cancel 204. `[INFERENCE]` enable only for the duration of a planned rotation on a
  listener not reachable by untrusted clients.
- `[INFERENCE]` a runbook following S126 literally fails at step one on a default
  2.7.2 listener; S126 has no occurrence of `disable_unauthed_rekey_endpoints`, `405`,
  `unsupported operation` or `unauthenticated` (`rendered-text-v1.py locate` count=0
  each), while it does carry the deprecation note (count=1).

## Corrections / limits

- String presence is not route evidence: `sys/rekey/init` appears in the binary only
  as the pooled `/v1/sys/rekey/init` literal (client + mux) and a doc string; the
  server-side sys pattern is relative (`rekey/init`). My first reading of that absence
  was wrong and is recorded in the artifact.
- The flag gate is established by source-at-commit + binary HCL key + three-way
  experiment; the instruction-level nil-pointer branch is `[INFERENCE]`.
- Auto-unseal recovery-key rekey and seal migration were not exercised.

SEAT-STATUS: complete
