# R61Revenger — reverse-engineering the measured rekey refusal

Seat: `R61Revenger` (revenger). Round 61, attempt 1. Lane `kagi-shokunin`, BASE
`c940f51689d702f1786989d56ad4663833c1452e`. Read-only on host binaries: every
binary operation ran on a copy in scratch.

Binary under test: `/home/vgpnk/.local/bin/bao` → copy at
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61Revenger/bin/bao`,
sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`
(the authorized digest), `OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379),
committed 2026-10-26T20:32:27Z`, ELF x86-64 statically linked, **with debug_info,
not stripped**.

## 0. Answer

`sys/rekey/init` is **not removed and not unimplemented**. OpenBao 2.7.2 compiles the
entire rekey stack (HTTP handlers, core `BarrierRekeyInit`/`RekeyUpdate`/`RekeyVerify`,
sys-backend path schema) and can execute a full rekey. The 405 is a **registration
gate**:

1. `internal/http/handler.go` mounts `/v1/sys/rekey/{init,update,verify}` and
   `/v1/sys/rekey-recovery-key/{init,update,verify}` **only if** the listener sets
   `disable_unauthed_rekey_endpoints = false` explicitly. Default (key absent, or
   `true`) leaves them unmounted.
2. Unmounted, the request falls through to the logical layer. `rekeyPaths()` in
   `internal/vault/logical_system_paths.go` still registers `rekey/init`,
   `rekey/update`, `rekey/verify` with Fields/Responses/DisplayAttrs but **no
   `Callback:`** on any of their operations.
3. `framework.Backend.HandleRequest` maps a nil callback to
   `logical.ErrUnsupportedOperation` (`sdk/framework/backend.go:239-273`), which the
   HTTP layer renders as **405 `{"errors":["unsupported operation"]}`**.
4. Those same paths are declared in `PathsSpecial.Unauthenticated`
   (`internal/vault/logical_system.go:108-121`), so the 405 is returned **before any
   token check** — anonymous and bogus-token requests get 405, not 403.

The supported successor `sys/rotate/root/init` (CLI `operator rotate-keys`) is fully
wired and completes a real rotation; `sys/rotate` and `sys/rotate/root` rotate
encryption keys and do not change share count/threshold.

## 1. Reproduction

### 1.1 Servers (throwaway, scratch storage, 127.0.0.1 only)

All started under `setpriv --pdeathsig KILL`, `tls_disable = 1`, storage in
`/fast/scratch/hyaku/kagi-r61/R61Revenger/srv/`:

| server | port | storage | listener config |
|---|---|---|---|
| raft | 8210 | `storage "raft"` (node_id `r61n1`, api_addr/cluster_addr set) | default (no rekey key) |
| inmem | 8220 | `storage "inmem"` | default |
| raft2 | 8230 | `storage "raft"` (node_id `r61n2`) | `disable_unauthed_rekey_endpoints = false` |
| raft3 | 8240 | `storage "raft"` (node_id `r61n3`) | `disable_unauthed_rekey_endpoints = true` |

Each initialized `-key-shares=5 -key-threshold=3` and unsealed with 3 shares
(`sys/seal-status` ⇒ `initialized=true sealed=false t=3 n=5`). No real vault, account
or secret touched; all share/token material lived in scratch and is deleted with it.

### 1.2 Raw HTTP on the default-config servers (raft 8210 and inmem 8220)

Request (identical on both backends, root token present):

```
POST /v1/sys/rekey/init
X-Vault-Token: <root>
Content-Type: application/json

{"secret_shares":3,"secret_threshold":2}
```

Raw response (headers + body, `curl -D`):

```
HTTP/1.1 405 Method Not Allowed
Cache-Control: no-store
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains
Date: Sat, 07 Nov 2026 19:53:05 GMT
Content-Length: 37

{"errors":["unsupported operation"]}
```

The same 405/`unsupported operation` was measured for **every** method and both
backends:

| method | path | raft 8210 | inmem 8220 |
|---|---|---|---|
| POST | `/v1/sys/rekey/init` | 405 | 405 |
| PUT | `/v1/sys/rekey/init` | 405 | 405 |
| GET | `/v1/sys/rekey/init` | 405 | 405 |
| DELETE | `/v1/sys/rekey/init` | 405 | 405 |
| POST | `/v1/sys/rekey/update` | 405 | 405 |
| GET/POST | `/v1/sys/rekey/verify` | 405 | 405 |
| POST | `/v1/sys/rekey/init` **no token** | 405 | 405 |
| POST | `/v1/sys/rekey/init` **bogus token** | 405 | 405 |

Controls that prove this is not a method-router artefact:

| request | result | reading |
|---|---|---|
| `PATCH /v1/sys/rekey/init` (no content type) | 400 `mime: no media type` | the HTTP handler ran and parsed the body |
| `OPTIONS /v1/sys/rekey/init` | 400 `cannot handle internal-only request operation` | logical-operation validation ran |
| `LIST /v1/sys/rekey/init` | 404 `unsupported path` | LIST is a different operation |
| `GET /v1/sys/rekey/backup` | 400 `no backed-up keys found` | callback present ⇒ executes |
| `DELETE /v1/sys/rekey/backup` | 204 | callback present ⇒ executes |
| `ANON GET /v1/sys/rotate/keyring` | 403 `permission denied` | not an unauthenticated path |
| `ROOT GET /v1/sys/rotate/keyring` | 405 `1 error occurred: * unsupported operation` | path has no ReadOperation |

### 1.3 CLI on the default-config server

```
$ BAO_ADDR=http://127.0.0.1:8210 bao operator rekey -init -key-shares=3 -key-threshold=2
Error initializing rekey: Error making API request.
URL: PUT http://127.0.0.1:8210/v1/sys/rekey/init
Code: 405. Errors:
* unsupported operation
rc=2
```

| CLI invocation | route reached | rc | result |
|---|---|---|---|
| `operator rekey -init` | `PUT /v1/sys/rekey/init` | 2 | 405 unsupported operation |
| `operator rekey -init -target=recovery` | `PUT /v1/sys/rekey-recovery-key/init` | 2 | **404 `unsupported path`** (route not registered at all) |
| `operator rekey -verify -nonce=…` | `GET /v1/sys/rekey/verify` | 2 | 405 unsupported operation |
| `operator rekey -cancel` | `DELETE /v1/sys/rekey/init` | 2 | 405 unsupported operation |
| `operator rekey -backup-retrieve` | `GET /v1/sys/rekey/backup` | 2 | 400 `no backed-up keys found` — the only rekey subcommand that reaches a live route |
| `operator rotate-keys -init` | `POST /v1/sys/rotate/root/init` | 0 | 200 + nonce, `0/3`, new 3 shares / threshold 2 |
| `operator rotate-keys -init -target=recovery` | `POST /v1/sys/rotate/recovery/init` | 2 | 400 `recovery keys not supported` (shamir seal) |
| `operator rotate-keys -verify -nonce=…` | client-side | 1 | `No rotation is in progress.` |
| `operator rotate-keys -cancel` | `DELETE /v1/sys/rotate/root/init` (route confirmed raw: 204 with and without a rotation in progress) | 0 | `Success! Canceled rotation (if it was started)` |

## 2. Binary evidence

All commands run from the scratch dir against `bin/bao` (the copy), never the host file.

### 2.1 Symbols (`go tool nm bin/bao`)

Present and linked: `internal/http.handleSysRekeyInitGet|Put|Delete`,
`handleSysRekeyUpdate`, `handleSysRekeyVerifyGet|Put|Delete`,
`internal/vault.(*SystemBackend).rekeyPaths`, `(*SystemBackend).rotatePaths`,
`(*SystemBackend).handleRotateInitGet|Put|Delete`, `handleRotateUpdate`,
`handleRotateVerifyGet|Put|Delete`, `handleRotateRoot`, `handleRotate`,
`(*Core).RekeyInit`, `BarrierRekeyInit`, `RecoveryRekeyInit`, `BarrierRekeyUpdate`,
`RecoveryRekeyUpdate`, `performBarrierRekey`, `performRecoveryRekey`, `RekeyVerify`,
`RekeyCancel`, `RekeyConfig`, `RekeyProgress`, `RekeyThreshold`,
`RekeyRetrieveBackup`, `RekeyDeleteBackup`.

### 2.2 The handlers are real, not stubs

`go tool objdump -s 'http.handleSysRekeyInitPut' bin/bao` shows calls to
`parseJSONRequest`, `(*Core).RekeyInit`, `handleSysRekeyInitGet`, and four
`logical.RespondError` sites — a full implementation. `(*Core).RekeyInit` dispatches
to `RecoveryRekeyInit` or `BarrierRekeyInit`; `BarrierRekeyInit` (objdump at
`rekey.go:167-221`) validates the seal config, takes `stateLock`/`rotationLock`,
rejects `rekey already in progress`, and generates a UUID nonce. **No rekey function
returns `ErrUnsupportedOperation`** — `go tool objdump` renders data references by
symbol name (verified on `framework.(*Backend).HandleRequest`, which prints
`MOVQ github.com/openbao/openbao/sdk/v2/logical.ErrUnsupportedOperation(SB)`), and a
scan of `RekeyInit`, `BarrierRekeyInit`, `RekeyConfig`, `RekeyUpdate`, `RekeyVerify`
and `RekeyCancel` for that symbol returns 0 in each.

### 2.3 The sys-backend path table has no callbacks

`go tool objdump -s 'SystemBackend\).rekeyPaths' bin/bao` shows the function building
10 path entries (`logical_system_paths.go:709-751`), including the `Fields` schema map
(keys resolved from the instruction stream: `nounce`, `started`, `t`, `n`, …).

Source at the exact binary commit
(`https://raw.githubusercontent.com/openbao/openbao/9e0a0d3c3504a0a00b45e61355afac5e35c78379/internal/vault/logical_system_paths.go`,
sha256 of the fetched file recorded in §8) — `rekeyPaths()`:

| path (line) | operations | `Callback:` |
|---|---|---|
| `rekey/init` (753) | Read (783), Update (796), Delete (809) | **none** |
| `rekey/update` (933) | Update (947) | **none** |
| `rekey/verify` (1006) | Read (1024), Delete (1058), Update (1092) | **none** |
| `rekey/backup$` (824) | Read (833), Delete (860) | `b.handleRekeyRetrieveBarrier` / `b.handleRekeyDeleteBarrier` |
| `rekey/recovery-key-backup$` (880) | Read (889), Delete (915) | `b.handleRekeyRetrieveRecovery` / `b.handleRekeyDeleteRecovery` |

The measured behaviour matches this table exactly: the three callback-less paths
return 405, the two callback-bearing paths execute (400/204).

### 2.4 The framework turns a nil callback into `ErrUnsupportedOperation`

`sdk/framework/backend.go:239-273` (same commit):

```go
var callback OperationFunc
if path.Operations != nil {
    if op, ok := path.Operations[req.Operation]; ok {
        ...
        callback = op.Handler()      // PathOperation.Handler() returns p.Callback
    }
} else {
    callback = path.Callbacks[req.Operation]
}
ok := callback != nil
if !ok { ... }
if !ok {
    return nil, logical.ErrUnsupportedOperation
}
```

`sdk/framework/path.go:291-306`: `PathOperation.Callback` is field 0 and
`Handler()` returns it. `logical.ErrUnsupportedOperation` maps to HTTP 405 with the
body `{"errors":["unsupported operation"]}` — byte-identical to the measured response.

### 2.5 The HTTP mux registers the endpoints only behind a listener flag

`internal/http/handler.go:181-195` (same commit):

```go
// Register without unauthenticated rekey, if necessary.
if props.ListenerConfig != nil && props.ListenerConfig.DisableUnauthedRekeyEndpoints != nil &&
    !*props.ListenerConfig.DisableUnauthedRekeyEndpoints {
    mux.Handle("/v1/sys/rekey/init",  handleForwardIfStandby(core, handleAuditNonLogical(core, handleSysRekeyInit(core, false))))
    mux.Handle("/v1/sys/rekey/update", ...)
    mux.Handle("/v1/sys/rekey/verify", ...)
    mux.Handle("/v1/sys/rekey-recovery-key/init", ...)
    mux.Handle("/v1/sys/rekey-recovery-key/update", ...)
    mux.Handle("/v1/sys/rekey-recovery-key/verify", ...)
}
```

Corroborated in the binary: `go tool objdump -s 'internal/http.handler$' bin/bao`
contains 98 `rekey`-attributed instructions, including construction of
`handleSysRekeyInit.func1` (`sys_rekey.go:19`) and `handleSysRekeyUpdate.func1`
(`sys_rekey.go:140`) — i.e. the route closures are built there, inside the gated
block. The HCL key is present in the binary's type metadata as
`DisableUnauthedRekeyEndpointsRaw` with `hcl:"disable_unauthed_rekey_endpoints"`, and
the parser error string `invalid value for disable_unauthed_rekey_endpoints: %w`.

### 2.6 The paths are declared unauthenticated

`internal/vault/logical_system.go:90-121` (same commit) lists in
`PathsSpecial.Unauthenticated`:

```go
// These endpoints are unauthenticated only with the
// "disable_unauthed_rekey_endpoints" listener property explicitly
// set to false. Note that they are not routable through the normal
// SystemBackend calls but are instead specially handled by http.
"rekey/init",
"rekey/update",
"rekey/verify",
"rekey-recovery-key/init",
"rekey-recovery-key/update",
"rekey-recovery-key/verify",
```

This is why the 405 arrives **before** the token check: an anonymous or bogus-token
request to `sys/rekey/init` is dispatched as an unauthenticated request and reaches
the backend, which returns `ErrUnsupportedOperation`; a non-unauthenticated sys path
(`sys/rotate/keyring`) returns 403 to the same anonymous request.

## 3. Root-cause chain (each link measured or located)

```
client: operator rekey -init
  → PUT /v1/sys/rekey/init
  → mux has no entry (flag absent/true)            [handler.go:181-195 + flag experiment §5]
  → generic logical handler → core.HandleRequest
  → path declared Unauthenticated                  [logical_system.go:108-121]
  → SystemBackend.HandleRequest → framework
  → rekey/init operations have Callback == nil     [logical_system_paths.go:753-809]
  → logical.ErrUnsupportedOperation                [sdk/framework/backend.go:239-273]
  → HTTP 405 {"errors":["unsupported operation"]}  [measured, §1.2]
```

## 4. Alternative routes (measured on raft 8210 unless noted)

| route | default config | `disable_unauthed_rekey_endpoints = false` | `= true` |
|---|---|---|---|
| `POST /v1/sys/rekey/init` | 405 unsupported operation | **200** `{"nonce":<uuid>,"started":true,"t":2,"n":3,"progress":0,"required":3,"pgp_fingerprints":null,"backup":false,"verification_required":false}` | 405 |
| `GET /v1/sys/rekey/init` | 405 | 200 status (`started`, `progress`, `required`) | 405 |
| `POST /v1/sys/rekey/update` | 405 | 400 `no barrier rekey in progress` (bogus key) | 405 |
| `POST /v1/sys/rekey/verify` | 405 | 400 `'key' must be specified in request body as JSON` | 405 |
| `DELETE /v1/sys/rekey/init` | 405 | 204 | 405 |
| `PUT /v1/sys/rekey-recovery-key/init` | 404 unsupported path | 400 `recovery rekeying not supported` (shamir) | 404 |
| `POST /v1/sys/rotate/root/init` | 200 nonce, `0/3`, t=2 n=3 | 200 | 200 |
| `GET /v1/sys/rotate/root/init` | 200 status | 200 | 200 |
| `POST /v1/sys/rotate/recovery/init` | 400 `recovery keys not supported` | 400 | 400 |
| `POST /v1/sys/rotate` | 204 | — | — |
| `POST /v1/sys/rotate/keyring` | 204 | — | — |
| `POST /v1/sys/rotate/root` | 204 (root key rotation, no shares) | — | — |
| `GET /v1/sys/rotate/root` | 405 (path has only UpdateOperation) | — | — |
| `GET /v1/sys/rotate/keyring` | 405 (path has only UpdateOperation) | — | — |
| `GET /v1/sys/rotate/config` | 200 `{"enabled":true,"interval":0,…}` | — | — |
| `GET /v1/sys/rotate/root/backup` | 400 `no backed-up keys found` | — | — |
| `GET /v1/sys/rotate/root/verify` | 400 `no rotation configuration found` | — | — |

`operator rotate-keys` **completes a full rotation** — it does not stop at init.
Measured end-to-end on raft 8210 and inmem 8220 (5 shares / threshold 3 → 3 shares /
threshold 2):

1. `rotate-keys -init -key-shares=3 -key-threshold=2` ⇒ rc 0, nonce, `Progress 0/3`,
   `New Shares 3`, `New Threshold 2`.
2. Three current shares via `rotate-keys -nonce=<nonce> <share>` ⇒ each rc 0; final
   call prints `Key 1..3` and `OpenBao unseal keys rotated to 3 key shares and a key
   threshold of 2`.
3. `operator seal` ⇒ `sealed=true t=2 n=3`.
4. Old share 1 ⇒ `Unseal Progress 1/2` (shares are accumulated, not validated
   individually); old share 2 ⇒ **400 `unable to retrieve stored keys: invalid key:
   failed to decrypt keys from storage: cipher: message authentication failed`**,
   progress reset to 0. Old shares are refused at reconstruction.
5. New share 1 + new share 2 ⇒ `sealed=false t=2 n=3`; the existing root token still
   authenticates (`sys/seal-status` 200).

The same sequence was repeated on raft2 (8230) through the `operator rekey` CLI with
the flag false: init rc 0, three shares, new key set, old shares refused with the same
`invalid key … message authentication failed`, new shares unseal, `t=2 n=3`.

## 5. The decisive experiment

| server | listener config | `operator rekey -init` | anon `POST /v1/sys/rekey/init` |
|---|---|---|---|
| raft 8210 | key absent | rc 2, 405 | 405 |
| inmem 8220 | key absent | rc 2, 405 | 405 |
| raft2 8230 | `disable_unauthed_rekey_endpoints = false` | **rc 0, nonce, 0/3** | **200, nonce issued** |
| raft3 8240 | `disable_unauthed_rekey_endpoints = true` | rc 2, 405 | 405 |

Only the explicit `false` mounts the endpoints. This also means: while enabled, the
rekey endpoints are **unauthenticated by design** — an anonymous client can start a
rekey (200), read its status (200), submit shares (400 on a bogus key, i.e. the
endpoint accepts submissions), and cancel it (204). Completing a rekey still requires
`threshold` current shares, so an anonymous client cannot change the key set alone,
but it can start/cancel rekeys without a token.

## 6. Custody consequence

What an operator does on this build to change share count/threshold:

| option | measured result | verdict |
|---|---|---|
| `bao operator rotate-keys -init -key-shares=N -key-threshold=M`, then `threshold` current shares | full rotation, old shares refused, new shares unseal, root token survives (raft and inmem) | **the supported, non-destructive path** |
| `bao operator rekey …` | 405 under default config; works only with `disable_unauthed_rekey_endpoints = false` | legacy path, off by default |
| `bao operator init` on an initialized server | 400 `Vault is already initialized`, rc 2 | cannot change shares; it only initializes fresh storage |
| `sys/rotate` / `sys/rotate/keyring` / `sys/rotate/root` | 204; `sys/seal-status` keeps `t=2 n=3` | rotates encryption keys, **not** share count/threshold |
| `-target=recovery` | 400 `recovery keys not supported` (shamir) / `recovery rekeying not supported` | only meaningful under auto-unseal; not a shamir share change |
| re-init a new cluster and migrate data | not measured | `[INFERENCE]` the only remaining option if `rotate-keys` were unavailable; it is available, so this is not required |

Operational notes grounded in measurement:

- The docs (S126) present `operator rekey` as merely deprecated
  (`RENDERED_TEXT_V1_LOCATE: count=1` for `operator rekey command is deprecated` and
  for `rotate-keys instead`; capture `raw_sha256=53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a`,
  `bytes=44328`). The capture contains **no** occurrence of
  `disable_unauthed_rekey_endpoints`, `405`, `unsupported operation` or
  `unauthenticated` (`locate` count=0 for each), so the docs-vs-binary divergence is
  not just "deprecated": the documented command hard-fails under the default
  configuration and the documentation does not say so.
- `[INFERENCE]` A runbook that follows S126 literally will fail at step one on a
  default 2.7.2 listener; the runbook must either use `rotate-keys` or set the
  listener flag and restart.
- `[INFERENCE]` Enabling the flag widens the attack surface (unauthenticated
  start/status/update/cancel). It should be enabled only for the duration of a
  planned rotation, on a listener that is not reachable by untrusted clients.
- `[INFERENCE]` Because individual shares are not validated on submission (old share
  1 was accepted as `1/2`), a custody drill that checks "is this share still valid?"
  cannot answer from a single submission; it must reach threshold and observe the
  reconstruction failure.

## 7. What I could not resolve / corrections

- I did not decompile the exact nil-pointer comparison on
  `DisableUnauthedRekeyEndpoints` at instruction level. The gate is established by
  (a) the source at the exact binary commit, (b) the binary's HCL key and parser
  error string, and (c) the three-way flag experiment (absent/true → 405, false →
  200). The instruction-level branch is `[INFERENCE]` from those three.
- My first string scan looked for `sys/rekey/init` and found only the client path and
  a doc string; that was **not** evidence of an absent server route. The server-side
  pattern is relative (`rekey/init` in the sys backend) and the mux literal
  `/v1/sys/rekey/init` is pooled with the API client's identical literal. Recorded
  here as a correction: string presence/absence is not route evidence.
- `-target=recovery` was measured only on shamir seals (400). Auto-unseal recovery-key
  rekey needs a KMS/HSM and was not exercised; the recovery-key routes are registered
  under the same flag and their handlers exist, but their success path is unmeasured.
- Seal migration (shamir → auto-unseal) and `operator migrate` were not exercised;
  they are storage/seal-mode operations, not share-count changes.
- The `disable_mlock` field is rejected by 2.7.2 as an unknown configuration field
  (warning only: `unknown or unsupported field disable_mlock found in configuration`).

## 8. Reproduction commands (verbatim, scratch-relative)

```bash
SCR=/fast/scratch/hyaku/kagi-r61/R61Revenger
cp /home/vgpnk/.local/bin/bao $SCR/bin/bao && sha256sum $SCR/bin/bao
$SCR/bin/bao version

# servers (each under setpriv --pdeathsig KILL, configs in $SCR/srv/*.hcl)
setpriv --pdeathsig KILL $SCR/bin/bao server -config=$SCR/srv/raft.hcl
setpriv --pdeathsig KILL $SCR/bin/bao server -config=$SCR/srv/inmem.hcl
setpriv --pdeathsig KILL $SCR/bin/bao server -config=$SCR/srv/raft2.hcl   # flag=false
setpriv --pdeathsig KILL $SCR/bin/bao server -config=$SCR/srv/raft3.hcl   # flag=true

# init + unseal (3 of 5)
$SCR/bin/bao operator init -address=http://127.0.0.1:8210 -key-shares=5 -key-threshold=3 -format=json
$SCR/bin/bao operator unseal -address=http://127.0.0.1:8210 <share>   # x3

# the 405
curl -sS -D - -X POST -H "X-Vault-Token: $ROOT" -H 'Content-Type: application/json' \
  -d '{"secret_shares":3,"secret_threshold":2}' http://127.0.0.1:8210/v1/sys/rekey/init

# binary evidence
go tool nm $SCR/bin/bao | grep -iE 'rekey|rotate'
go tool objdump -s 'http.handleSysRekeyInitPut' $SCR/bin/bao
go tool objdump -s 'SystemBackend\).rekeyPaths' $SCR/bin/bao
go tool objdump -s 'internal/http\.handler$' $SCR/bin/bao | grep -i rekey
strings -n 4 $SCR/bin/bao | grep -oE '[^ "]{0,40}sys/rekey/[a-z]+'
python3 - <<'EOF'   # byte scan for relative patterns and the HCL key
data=open('bin/bao','rb').read()
for pat in [b'rekey/init', b'rotate/root/init', b'disable_unauthed_rekey_endpoints']:
    print(pat, data.count(pat))
EOF
```

Provenance files fetched at the binary's commit
`9e0a0d3c3504a0a00b45e61355afac5e35c78379` (kept in scratch, not citable evidence
outside it): `internal/vault/logical_system_paths.go`,
`internal/vault/logical_system_rotate.go`, `internal/vault/logical_system.go`,
`internal/vault/rekey.go`, `internal/vault/request_handling.go`,
`internal/http/handler.go`, `internal/http/sys_rekey.go`, `sdk/framework/path.go`,
`sdk/framework/backend.go`.

SEAT-STATUS: complete
