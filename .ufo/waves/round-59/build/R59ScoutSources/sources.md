# R59ScoutSources — round 59 source reconnaissance: the two declared OpenBao transit sources, opened live

Seat: scout (source reconnaissance). Lane: `kagi-shokunin`, branch `master`.
BASE claimed: `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`. Frozen predeclaration read first:
`plans/round-59.md` (commit `af7b6651`), plus `corpus/lessons/round-58-verifier-spotcheck.md`.
**No frozen predicate, target, POP, kill rule or item condition was amended.**

Read-only on git/jj: no `git add/commit/stash/push`, no mutating `jj`, no write into the fleet root,
a sibling lane, the lane's jj/git index, or any lane file outside this seat's own paths. The L1
(`KagiR59`) remains the sole integration owner and committer.

Tools: `curl` and `python3` 3.14.8 (stdlib only) — both preinstalled system binaries. **No install or
upgrade was made** (all pacman transactions are PAUSED host-wide by the orchestrator ruling of
2026-10-20, so no `pacman`/`uv tool install`/`npx`/binary install was attempted or needed).

## 1. The two declared sources, opened live

Fetched 2026-11-07 with `curl -sS -D headers -o body` and a desktop browser User-Agent
`Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36`.
Neither URL redirected (one status block per header file).

| id | URL | access date | HTTP status | content-length (header) | bytes (body) | sha256 (body) |
|---|---|---|---|---|---|---|
| S121 | https://openbao.org/docs/secrets/transit/ | 2026-11-07 | 200 | 48604 | 48604 | `d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19` |
| S122 | https://openbao.org/docs/api/secret/transit/ | 2026-11-07 | 200 | 267984 | 267984 | `ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e` |

- **S121** — https://openbao.org/docs/secrets/transit/
  - capture body: `.ufo/waves/round-59/capture/S121.body` (48604 bytes)
  - capture headers: `.ufo/waves/round-59/capture/S121.headers`
  - lane-normalizer digest: `RENDERED_TEXT_V1: raw_sha256=d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19 bytes=48604 normalized_sha256=3f49303cd3fe01869413193006b2a45e146115f5a80692f8b382f698a57503b6 normalized_bytes=14163`
  - page marker: OpenBao docs **Version 2.7.x** (`Version: Version 2.7.x`; body class
    `docs-version-2.7.x`) — the same docs branch as the measured binary OpenBao v2.7.2.
- **S122** — https://openbao.org/docs/api/secret/transit/
  - capture body: `.ufo/waves/round-59/capture/S122.body` (267984 bytes)
  - capture headers: `.ufo/waves/round-59/capture/S122.headers`
  - lane-normalizer digest: `RENDERED_TEXT_V1: raw_sha256=ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e bytes=267984 normalized_sha256=a1636fb2ad54212a50bef35857a3ade11a6f65380a4986ca53439fa938193312 normalized_bytes=62185`
  - page marker: OpenBao docs **Version 2.7.x** (`Version: Version 2.7.x`; body class
    `docs-version-2.7.x`) — the same docs branch as the measured binary OpenBao v2.7.2.

### Header-removal note

In **both** header files every `set-cookie:` / `cookie:` line was removed before the file was
written. **0 such lines were present in either response** — the upstream served no `Set-Cookie` and
no `Cookie` header — so nothing was actually stripped. The two server-issued per-request
correlation ids per file (`x-github-request-id`, `x-fastly-request-id`) were additionally replaced
by a placeholder (2 lines per file). No cookie value, session id or credential-shaped token is
present in either header file. The one-line removal note is appended at the **end** of each
`.headers` file, as this seat's spec requires.

## 2. Located quotes — every mechanic the plan's C2 table needs

Verifier: the lane's own committed normalizer, run **from the lane root** against **this seat's own
capture** (not a prior round's):

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-59/capture/<id>.body '<quote>'
```

Exit 0 iff `count >= 1`. Every quote is ≤ 25 words and reproduced verbatim from the page. Raw
outputs are in `locate.txt` (same directory). **A quote is called located only where the locate
command above printed it located against this capture.**

| id | src | mechanic | quote (verbatim) | w | locate output |
|---|---|---|---|---|---|
| Q01 | S121 | vault:v prefix | “The returned ciphertext starts with vault:v1:” | 6 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q02 | S121 | vault:v prefix | “The v1 indicates the key version 1 was used to encrypt the plaintext” | 13 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q03 | S121 | vault:v prefix | “The first prefix ( vault ) identifies that it has been wrapped by OpenBao.” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q04 | S121 | rotate | “This will generate a new encryption key and add it to the keyring for the named key” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q05 | S121 | rotate | “Future encryptions will use this new key.” | 7 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q06 | S121 | rotate | “Old data can still be decrypted due to the use of a key ring.” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q07 | S121 | rewrap | “This process does not reveal the plaintext data.” | 8 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q08 | S122 | rotate | “This endpoint rotates the version of the named key.” | 9 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q09 | S122 | rotate / rewrap | “To upgrade ciphertext to be encrypted with the latest version of the key, use the rewrap endpoint.” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q10 | S121 | convergent + context | “Convergent encryption is a mode where the same set of plaintext+context always result in the same ciphertext.” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q11 | S122 | convergent + context | “If enabled, the key will support convergent encryption, where the same plaintext creates the same ciphertext.” | 16 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q12 | S122 | convergent + context | “This requires derived to be set to true” | 8 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q13 | S122 | convergent + context | “context (string: "") – Specifies the base64 encoded context for key derivation. This is required if key derivation is enabled for this key.” | 23 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q14 | S121 | min_decryption_version | “in an emergency the min_decryption_version can be moved back to allow for legitimate decryption.” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q15 | S122 | min_decryption_version | “Specifies the minimum version of ciphertext allowed to be decrypted.” | 10 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q16 | S121 | min_decryption_version | “Key versions that are earlier than a key's specified min_decryption_version gets archived, and the rest of the key versions belong to the working set.” | 24 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q17 | S122 | rewrap | “This endpoint rewraps the provided ciphertext using the latest version of the named key.” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q18 | S122 | rewrap | “Because this never returns plaintext, it is possible to delegate this functionality to untrusted users or scripts.” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q19 | S121 | base64 plaintext | “All plaintext data must be base64-encoded” | 6 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q20 | S121 | ciphertext format | “OpenBao does not store any of this data.” | 8 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q21 | S121 | ciphertext format | “The rest is a base64 concatenation of the initialization vector (IV) and ciphertext.” | 13 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q22 | S122 | min_decryption_version | “Must be 0 (which will use the latest version) or a value greater or equal to min_decryption_version” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q23 | S122 | min_decryption_version | “This is not allowed to be set when either min_encryption_version or min_decryption_version is set to zero.” | 16 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q24 | S122 | convergent + context | “External keys do not support auto-rotation, exporting, convergent encryption, or context-derived keys.” | 12 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q25 | S122 | decrypt failure | “Be warned that some failures (such as failure to decrypt) could be indicative of a security breach” | 17 | `RENDERED_TEXT_V1_LOCATE: count=2` (rc=0) |
| Q26 | S122 | convergent + context | “As a result, when the same context and nonce are supplied, the same ciphertext is generated.” | 16 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q27 | S121 | convergent + context | “Keys using version 2 can be upgraded by simply performing a rotate operation to a new key version” | 18 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q28 | S121 | context | “Key derivation is supported, which allows the same key to be used for multiple purposes by deriving a new key” | 20 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q29 | S122 | convergent + context | “This is only supported when using a key with key derivation enabled and will require all requests to carry both a context and 96-bit (12-byte)” | 25 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q30 | S121 | convergent + context | “In this mode, convergent encryption can optionally be supported, which allows the same input values to produce the same ciphertext.” | 20 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q31 | S122 | key creation | “The values set here cannot be changed after key creation.” | 10 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q32 | S122 | convergent + context | “When enabled, each encryption(/decryption/rewrap/datakey) operation will derive a nonce value rather than randomly generate it.” | 15 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q33 | S122 | decrypt | “This endpoint decrypts the provided ciphertext using the named key.” | 10 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q34 | S121 | rewrap | “OpenBao will decrypt the value using the appropriate key in the keyring and then encrypted the resulting plaintext with the newest key in the keyring.” | 25 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q35 | S122 | convergent + context | “It is very important when using this mode that you ensure that all nonces are unique for a given context.” | 20 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q36 | S122 | rotate | “This endpoint rotates the version of the named key. After rotation, new plaintext requests will be encrypted with the new version of the key.” | 24 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q37 | S122 | key creation | “This parameter will only be used when a key is expected to be created.” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q38 | S122 | context | “If enabled, all encrypt/decrypt requests to this named key must provide a context which is used for key derivation.” | 19 | `RENDERED_TEXT_V1_LOCATE: count=2` (rc=0) |
| Q39 | S122 | min_decryption_version | “Adjusting this as part of a key rotation policy can prevent old copies of ciphertext from being decrypted, should they fall into the wrong hands.” | 25 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q40 | S122 | rotate | “This is only supported with keys that support encryption and decryption operations.” | 12 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q41 | S122 | rewrap | “{ "data" : { "ciphertext" : "vault:v2:abcdefgh" } }” | 9 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q42 | S122 | min_decryption_version | “All versions before this version will be permanently deleted.” | 9 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q43 | S122 | min_decryption_version | “This value can at most be equal to the lesser of min_decryption_version and min_encryption_version” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q44 | S121 | setup | “Enable the Transit secrets engine: $ bao secrets enable transit” | 10 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q45 | S121 | setup | “Create a named encryption key: $ bao write -f transit/keys/my-key” | 10 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q46 | S121 | base64 plaintext | “The resulting data is base64-encoded” | 5 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q47 | S122 | endpoint path | “Method Path POST /transit/encrypt/:name” | 4 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q48 | S122 | endpoint path | “Method Path POST /transit/decrypt/:name” | 4 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q49 | S122 | endpoint path | “Method Path POST /transit/rewrap/:name” | 4 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q50 | S122 | endpoint path | “Method Path POST /transit/keys/:name/rotate” | 4 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q51 | S122 | endpoint path | “Method Path POST /transit/keys/:name/config” | 4 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q53 | S122 | endpoint path | “Method Path POST /transit/keys/:name/trim” | 4 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q54 | S122 | rotate narrowing | “For imported keys, rotation is only supported if the allow_rotation field was set to true on import.” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q55 | S121 | request cap | “OpenBao HTTP API imposes a maximum request size of 32MB to prevent a denial of service attack.” | 17 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q56 | S122 | rotate narrowing | “The following operations will not work on the :name 'd key until the key is restored:” | 16 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q57 | S122 | min_decryption_version | “This endpoint allows tuning configuration values for a given key.” | 10 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q58 | S122 | key creation | “This endpoint creates a new named encryption key of the specified type.” | 12 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q60 | S121 | convergent version | “Version 1 required the client to provide their own nonce, which is highly flexible but if done incorrectly can be dangerous.” | 21 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q62 | S122 | rotate | “For algorithms with a configurable key size, the rotated key will use the same key size as the previous version.” | 20 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |
| Q63 | S121 | rotate | “Periodic rotation of the encryption keys is recommended, even in the absence of compromise.” | 14 | `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0) |

All 60 quotes locate at `count>=1` (rc=0) against `.ufo/waves/round-59/capture/`; the
maximum quote length is 25 words.

### Coverage against the plan's five C2 mechanics

| plan mechanic (plans/round-59.md C2 table) | quotes that carry it |
|---|---|
| vault:v prefix | Q01, Q02, Q03 (prefix shape), Q41 (`vault:v2:` sample response) |
| rotate | Q04, Q05, Q06, Q08, Q36, Q40, Q54, Q62, Q63 |
| rewrap | Q07, Q09, Q17, Q18, Q34, Q41, Q49 |
| min_decryption_version | Q14, Q15, Q16, Q22, Q23, Q39, Q42, Q43, Q51, Q57 |
| convergent_encryption + context | Q10, Q11, Q12, Q13, Q24, Q26, Q27, Q28, Q29, Q30, Q32, Q35, Q37, Q38, Q60 |

Endpoint paths the trial will call, each located on S122: `POST /transit/encrypt/:name` (Q47),
`POST /transit/decrypt/:name` (Q48), `POST /transit/rewrap/:name` (Q49),
`POST /transit/keys/:name/rotate` (Q50), `POST /transit/keys/:name/config` (Q51),
`POST /transit/keys/:name/trim` (Q53). Setup steps on S121: `bao secrets enable transit` (Q44),
`bao write -f transit/keys/my-key` (Q45).

## 3. Page statements that contradict, narrow or are more specific than the plan's five mechanics

These are the load-bearing ones for the C2 trial design. Each is a located quote (§2) plus the
consequence for the trial. **Reported, not resolved by this seat** — the frozen plan is not mine
to amend.

### N1 — `min_decryption_version` is documented as a *rotation-policy* control, and it is reversible

> “Adjusting this as part of a key rotation policy can prevent old copies of ciphertext from being
> decrypted, should they fall into the wrong hands.” (Q39, S122)
>
> “in an emergency the min_decryption_version can be moved back to allow for legitimate decryption.”
> (Q14, S121)

The plan's T4 says raising it to 2 **refuses** version-1 ciphertext and lowering it back to 1 makes
the same ciphertext decrypt again. The pages support the *reversible* half explicitly (Q14) and
support the refusal half as a *policy effect* (Q39) — the pages never state a named error, a status
code or a refusal string. **T4's "refuses … with a named error" has no page support for the error
name.** See G1.

### N2 — `min_decryption_version` and `min_encryption_version` are coupled, and `trim` is a separate, destructive control

> “Must be 0 (which will use the latest version) or a value greater or equal to
> min_decryption_version” (Q22, S122)
>
> “This is not allowed to be set when either min_encryption_version or min_decryption_version is set
> to zero.” (Q23, S122)
>
> “All versions before this version will be permanently deleted.” (Q42, S122)
>
> “This value can at most be equal to the lesser of min_decryption_version and
> min_encryption_version” (Q43, S122)

The plan's T3 says raising `min_decryption_version` to 2 afterwards **still decrypts the rewrapped
value** while the original v1 ciphertext is refused. The pages show the two version floors are
coupled (Q22) and that `min_encryption_version` must be ≥ `min_decryption_version` — so a trial that
raises only `min_decryption_version` to 2 while `min_encryption_version` stays 0 is a legal but
**distinct** state the pages describe; the pages also make `trim` (Q42) the destructive operation
and `min_decryption_version` the archival one (Q16: versions earlier than it "gets archived", not
deleted). The plan's T3/T4 use of the floor as a *refusal* is therefore an archive-and-refuse, not a
delete — Q16 says explicitly that the min_decryption_version boundary *archives* older versions and
keeps the rest in the working set.

### N3 — `rewrap` re-encrypts under the newest key version, but it is not a pure key-version migration

> “OpenBao will decrypt the value using the appropriate key in the keyring and then encrypted the
> resulting plaintext with the newest key in the keyring.” (Q34, S121)
>
> “This process does not reveal the plaintext data.” (Q07, S121)
>
> “Because this never returns plaintext, it is possible to delegate this functionality to untrusted
> users or scripts.” (Q18, S122)

The plan's T3 calls rewrap a migration "without a decrypt round trip". The S121 page states the
server **does** decrypt and re-encrypt internally (Q34) — what it avoids is *revealing* the
plaintext to the caller (Q07, Q18). So the plan's observable "the rewrap did not need a decrypt" is
**narrower than the page text**: no client-side plaintext round trip, but a server-side one. This is
the single most load-bearing narrowing for T3 and should be reflected in the trial's wording.

### N4 — `convergent_encryption` requires `derived`, and it is only settable at key creation

> “This requires derived to be set to true” (Q12, S122)
>
> “The values set here cannot be changed after key creation.” (Q31, S122)
>
> “This parameter will only be used when a key is expected to be created.” (Q37, S122)

The plan's T5 says "`convergent_encryption: true` with a `context`". The pages narrow this: the flag
requires `derived=true`, and the flag is a **key-creation** value that cannot be changed afterwards
(Q31). A trial that creates a plain key and later tries to switch on convergent encryption cannot;
the convergent key must be created with `convergent_encryption` and `derived` in one call.

### N5 — convergent mode carries a nonce requirement and a nonce-reuse hazard

> “This is only supported when using a key with key derivation enabled and will require all requests
> to carry both a context and 96-bit (12-byte) for AES and ChaCha20 or 192-bit (24-byte) for
> XChaCha20 nonce.” (Q29, S122)
>
> “As a result, when the same context and nonce are supplied, the same ciphertext is generated.”
> (Q26, S122)

> “It is very important when using this mode that you ensure that all nonces are unique for a given
> context.” (Q35, S122)

> “When enabled, each encryption(/decryption/rewrap/datakey) operation will derive a nonce value
> rather than randomly generate it.” (Q32, S122)

Two consequences for T5. (a) The pages state the deterministic equality for a *fixed*
plaintext+context+nonce triple (Q26) — the plan's T5 says "identical plaintext + identical
context gives byte-identical ciphertext", which is the **derived-nonce** mode (Q32), a different
statement from the client-supplied-nonce mode of Q29/Q26. (b) The pages also place a nonce-length
requirement on the request (96-bit / 192-bit), so the trial's `context`/nonce handling must satisfy
that, not just "a context". The plan's T5 does not mention a nonce at all.

### N6 — a stated rewrap/rotate *limitation* on key types

> “This is only supported with keys that support encryption and decryption operations.” (Q40, S122)

> “For imported keys, rotation is only supported if the allow_rotation field was set to true on
> import.” (Q54, S122)

> “External keys do not support auto-rotation, exporting, convergent encryption, or context-derived
> keys.” (Q24, S122)

The plan's T2/T3/T5 use the default `aes256-gcm96` key implicitly. The pages state per-key-type
limits, and in particular that **external keys cannot do convergent encryption or context-derived
keys at all** (Q24) — so T5's convergent leg is only reachable with a non-external key.

### N7 — convergent encryption has three historical versions with different upgrade rules

> “Version 1 required the client to provide their own nonce, which is highly flexible but if done
> incorrectly can be dangerous.” (Q60, S121)
>
> “Keys using version 2 can be upgraded by simply performing a rotate operation to a new key version”
> (Q27, S121)

The pages distinguish convergent-encryption *versions* (1 client nonce / 2 upgradeable / 3 resistant)
from *key* versions. The plan's T5 uses "version" only in the key-version sense (`vault:v2:`).
Trial and lesson wording should keep the two senses apart.

### N8 — plaintext and ciphertext encodings are load-bearing for the trial's assertions

> “All plaintext data must be base64-encoded” (Q19, S121)
>
> “The resulting data is base64-encoded” (Q46, S121)
>
> “The rest is a base64 concatenation of the initialization vector (IV) and ciphertext.” (Q21, S121)
>
> “OpenBao does not store any of this data.” (Q20, S121)

The plan's T1 asserts the ciphertext "does not contain the plaintext". The pages support that only
indirectly (Q21: the payload is IV‖ciphertext; Q20: the server stores nothing) — there is **no**
page sentence stating that the plaintext is absent from the ciphertext. That assertion is a
measurement, not a documentation quote. Also, Q19/Q46 mean a plaintext round trip must compare
**base64-decoded** bytes, not the raw `plaintext` field.

### N9 — the `vault:v1:` prefix is a *key-version* prefix, and it changes on rotation

> “The returned ciphertext starts with vault:v1:” (Q01, S121)
>
> “The v1 indicates the key version 1 was used to encrypt the plaintext; therefore, when you rotate
> keys, OpenBao knows which version to use for decryption.” (Q02, S121)
>
> “The first prefix ( vault ) identifies that it has been wrapped by OpenBao.” (Q03, S121)

The pages say the prefix encodes the **key version**, and that `vault` is the product prefix —
not that the prefix is a fixed literal `vault:v1:`. The plan's T1/T2/T3 phrasing "carries a
`vault:v1:` prefix" is right for a fresh key and "carries `vault:v2:`" right after one rotation,
which the pages support; the pages also show a `vault:v2:` rewrap response body (Q41).

### N10 — request-size and keyring constraints

> “OpenBao HTTP API imposes a maximum request size of 32MB to prevent a denial of service attack.”
> (Q55, S121)
>
> “Old data can still be decrypted due to the use of a key ring.” (Q06, S121)
>
> “The following operations will not work on the :name 'd key until the key is restored:” (Q56, S122)

Q06 is the page's own statement of the T2 mechanic ("older ciphertext still decrypts" after a
rotation). Q56 shows a soft-deleted key blocks encrypt/decrypt/rotate — a state the trial must not
accidentally create.

## 4. §Gaps — mechanics I could NOT find on the two pages

Each gap names a plan mechanic (or a sub-assertion of one) for which **neither S121 nor S122
carries a located sentence**. These are the parts of the C2 table that must be *measured*, not
documented — the trial has to supply the evidence the pages do not.

| # | plan mechanic / sub-assertion | what the pages do NOT say | closest located page statement |
|---|---|---|---|
| G1 | T4 — `min_decryption_version` raising to 2 "refuses version-1 ciphertext **with a named error**" | no error name, no status code, no refusal string for a version below the floor appears anywhere on either page. A full-text scan of both captures for `failed to decrypt`, `invalid ciphertext`, `cannot decrypt`, `not permitted`, `permission denied`, `forbidden` returns **0** matches each. | Q39 (the effect: "can prevent old copies of ciphertext from being decrypted"); Q14 (reversibility) |
| G2 | T1 — a ciphertext with one base64 character changed "is refused with a decrypt error" | no tamper-detection sentence, no error name, no GCM-authentication-failure wording. The pages say nothing about what a corrupted ciphertext returns. | Q25 ("some failures (such as failure to decrypt) could be indicative of a security breach") — a warning about *batch* failures, not a tamper contract |
| G3 | T1 — the ciphertext "does not contain the plaintext" | no page sentence states that the plaintext is absent from the ciphertext. The pages only describe the wire format as IV‖ciphertext and that the server stores none of it. | Q21 (IV‖ciphertext), Q20 ("OpenBao does not store any of this data") |
| G4 | T5 — "a **different context** gives different ciphertext" | the pages state the forward direction (equal plaintext+context ⇒ equal ciphertext) but never the converse: no sentence says a different context yields a different ciphertext. | Q10 ("the same set of plaintext+context always result in the same ciphertext"), Q28 (derivation is by user-supplied context) |
| G5 | T5 — "a **non-convergent** key gives different ciphertext for identical plaintext" | no page sentence states that a non-convergent key produces different ciphertext for equal plaintext. The pages only describe what convergent mode does; the non-convergent case is never stated as a contrast. | Q30 ("convergent encryption can optionally be supported"), Q11 (convergent ⇒ same plaintext ⇒ same ciphertext) |
| G6 | T2 — the older `vault:v1:` ciphertext "still decrypts" **after** the rotation, specifically | the pages state the general keyring property ("Old data can still be decrypted due to the use of a key ring"), and that the prefix records the key version, but never state the post-rotation v1-ciphertext-still-decrypts result in one sentence. | Q06, Q02 |
| G7 | T2/T3 — that the **new** ciphertext after one rotation carries the literal prefix `vault:v2:` | the pages show `vault:v1:` (encrypt example) and `vault:v2:` (a rewrap sample response body), and say the prefix is the key version, but no sentence states "after one rotation a fresh encryption carries `vault:v2:`". | Q01, Q02, Q41, Q36 |
| G8 | T5 — that `convergent_encryption` may be set **without** supplying a client nonce | the pages' upsert parameter text ties convergent mode to a client-supplied nonce of a fixed length (Q29/Q26) and the key-creation text says the nonce is derived (Q32); no page sentence states that `convergent_encryption: true` alone yields determinism with no nonce in the request. The plan's T5 omits any nonce. | Q29, Q26, Q32, Q12 |
| G9 | T5 — that a **different** `context` with the *same* plaintext breaks determinism (as opposed to a different context *with* a different plaintext) | not stated on either page in any form. | Q10 |
| G10 | T3 — that raising `min_decryption_version` to 2 **after** a rewrap still decrypts the rewrapped value while refusing the original v1 ciphertext | the pages document the floor and the coupling (Q22, Q23) and that the floor archives rather than deletes (Q16), but never state the rewrap-then-raise sequence. | Q16, Q22, Q23, Q43 |

**Net:** every one of the five mechanics has located page support for its *core* claim (prefix
shape, rotate-adds-a-version, rewrap-uses-the-newest-version, `min_decryption_version` is a floor,
convergent mode is deterministic for equal plaintext+context). What the pages do **not** supply is
the **named error** (G1, G2), the **absence of the plaintext in the ciphertext** (G3), the
**contrapositive/converse** halves of the determinism claims (G4, G5, G9), the explicit
**post-rotation and post-rewrap** end-to-end results (G6, G7, G10), and the **no-nonce** form of
convergent mode (G8). Those are exactly the legs the trial must measure.

Also noted (not a gap, a freshness note): both pages are the **2.7.x** docs branch and both were
served `last-modified: Fri, 06 Nov 2026 09:07:02 GMT` — one day before this capture — with
`x-origin-cache: HIT`, i.e. the CDN copy was fresh at fetch time. The registry rows the L1 appends
should carry recheck `180d`, not `90d`.

### A note on the round-58 capture of the same id

`corpus/SOURCES.md` ends at **S120**; there is no `S121` row at BASE. The round-58 capture
directory contains a file named `.ufo/waves/round-58/capture/S121.body`, but that is the
**token CLI** page (`https://openbao.org/docs/commands/token/`, 32638 B, sha256
`37e706c2b2047d474dc84ad20f09b6f35c5d5c328f4fcff1298079c1c17ead28`) — it was **rejected** in
round 58 (duplicate scope, S016/S021) and never received a registry row. The round-59 plan
re-assigns S121/S122 to the two transit pages, and this seat's captures live under
`.ufo/waves/round-59/capture/`, so there is no collision on disk. **But the id `S121` is used by
two different URLs across two rounds' capture trees**; a checker that resolves a capture by id
rather than by path will read the wrong body.

**L1 decision (KagiR59, 2026-11-07):** keep S121 = the transit concepts page and S122 = the
transit API page. The registry is the SSOT and both ids are free there; the round-58 file is an
unreferenced staging capture of a page round 58 rejected and gave no row, and no manifest
(`corpus/quote-bodies.tsv`, `corpus/recheck-captures.tsv`, `corpus/source-fetches.tsv`) binds it.
The mitigation the L1 lands in the registry: each new row's anchor cell names the capture path
explicitly and states that the round-58 staging file of the same id is the rejected token-CLI page,
not this source. Nothing changes in this seat's captures.

## 5. Reproduction

```
mkdir -p ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ScoutSources
cd ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ScoutSources
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
curl -sS -L --max-time 90 -A "$UA" -D S121.headers -o S121.body 'https://openbao.org/docs/secrets/transit/'
curl -sS -L --max-time 90 -A "$UA" -D S122.headers -o S122.body 'https://openbao.org/docs/api/secret/transit/'
sha256sum S121.body S122.body
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-59/capture/S121.body '<quote>'
```

The raw locate outputs of every quote in §2 are in `locate.txt` beside this file.

## 6. Tools

- `curl` (preinstalled), `python3` 3.14.8 stdlib only, `sha256sum` (GNU coreutils, preinstalled).
- **No tool was installed or upgraded.** The operator directive permits it, but the pacman channel is
  PAUSED host-wide by the orchestrator ruling of 2026-10-20 and nothing here needed an install, so
  no `pacman`/`uv tool install`/`npx`/binary install was performed. Nothing was downgraded and no
  host service was restarted.

SEAT-STATUS: complete
