# R59ScribeEntry — per-quote locate index for `openbao-transit-engine.md`

Every double-quoted span in the draft that is presented as a page sentence, with the capture it
was located against and the `count` the lane's normalizer printed. Command, run from
`/home/vgpnk/Projects/shokunin/kagi-shokunin`:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-59/capture/<S121|S122>.body "<quote>"
```

A quote is listed once even when the draft repeats it. `count=0` would mean not located; no row
below has that. Spans of one or two words that are parameter names or JSON keys are marked, not
treated as page quotes.

Captures: S121 `.ufo/waves/round-59/capture/S121.body` (raw sha256
`d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19`, 48604 B; normalized
`3f49303cd3fe01869413193006b2a45e146115f5a80692f8b382f698a57503b6`, 14163 B); S122
`.ufo/waves/round-59/capture/S122.body` (raw sha256
`ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e`, 267984 B; normalized
`a1636fb2ad54212a50bef35857a3ade11a6f65380a4986ca53439fa938193312`, 62185 B).

| # | words | quote | capture locate |
|---|---|---|---|
| 1 | 6 | "The returned ciphertext starts with vault:v1:" | S121 count=1 (located) |
| 2 | 14 | "The first prefix ( vault ) identifies that it has been wrapped by OpenBao." | S121 count=1 (located) |
| 3 | 13 | "The v1 indicates the key version 1 was used to encrypt the plaintext" | S121 count=1 (located) |
| 4 | 13 | "therefore, when you rotate keys, OpenBao knows which version to use for decryption" | S121 count=1 (located) |
| 5 | 10 | "This endpoint encrypts the provided plaintext using the named key." | S122 count=1 (located) |
| 6 | 10 | "This endpoint decrypts the provided ciphertext using the named key." | S122 count=1 (located) |
| 7 | 9 | "This endpoint rotates the version of the named key." | S122 count=1 (located) |
| 8 | 15 | "After rotation, new plaintext requests will be encrypted with the new version of the key." | S122 count=1 (located) |
| 9 | 7 | "Future encryptions will use this new key." | S121 count=1 (located) |
| 10 | 14 | "Old data can still be decrypted due to the use of a key ring." | S121 count=1 (located) |
| 11 | 14 | "This endpoint rewraps the provided ciphertext using the latest version of the named key." | S122 count=1 (located) |
| 12 | 17 | "Because this never returns plaintext, it is possible to delegate this functionality to untrusted users or scripts." | S122 count=1 (located) |
| 13 | 25 | "OpenBao will decrypt the value using the appropriate key in the keyring and then encrypted the resulting plaintext with the newest key in the keyring." | S121 count=1 (located) |
| 14 | 8 | "This process does not reveal the plaintext data." | S121 count=1 (located) |
| 15 | 10 | "Specifies the minimum version of ciphertext allowed to be decrypted." | S122 count=1 (located) |
| 16 | 12 | "Key versions that are earlier than a key's specified min_decryption_version gets archived" | S121 count=1 (located) |
| 17 | 14 | "in an emergency the min_decryption_version can be moved back to allow for legitimate decryption" | S121 count=1 (located) |
| 18 | 17 | "Convergent encryption is a mode where the same set of plaintext+context always result in the same ciphertext." | S121 count=1 (located) |
| 19 | 16 | "If enabled, the key will support convergent encryption, where the same plaintext creates the same ciphertext." | S122 count=1 (located) |
| 20 | 9 | "This requires derived to be set to true ." | S122 count=1 (located) |
| 21 | 13 | "The rest is a base64 concatenation of the initialization vector (IV) and ciphertext." | S121 count=1 (located) |
| 22 | 10 | "OpenBao doesn't store the data sent to the secrets engine." | S121 count=1 (located) |
| 23 | 23 | "The primary use case for transit is to encrypt data from applications while still storing that encrypted data in some primary data store." | S121 count=1 (located) |
| 24 | 17 | "To upgrade ciphertext to be encrypted with the latest version of the key, use the rewrap endpoint." | S122 count=1 (located) |
| 25 | 23 | "by disallowing decryption of old versions of keys, found ciphertext corresponding to obsolete (but sensitive) data can not be decrypted by most users" | S121 count=1 (located) |
| 26 | 25 | "Adjusting this as part of a key rotation policy can prevent old copies of ciphertext from being decrypted, should they fall into the wrong hands." | S122 count=1 (located) |
| 27 | 10 | "Once trimmed, previous versions of the key cannot be recovered." | S122 count=1 (located) |
| 28 | 9 | "All versions before this version will be permanently deleted." | S122 count=1 (located) |
| 29 | 13 | "can at most be equal to the lesser of min_decryption_version and min_encryption_version ." | S122 count=1 (located) |
| 30 | 12 | "will support convergent encryption, where the same plaintext creates the same ciphertext" | S122 count=1 (located) |
| 31 | 11 | "all encrypt/decrypt requests to this named key must provide a context" | S122 count=2 (located; create-key and import-key parameter lists) |
| 32 | 9 | "highly flexible but if done incorrectly can be dangerous" | S121 count=1 (located) |
| 33 | 6 | "was susceptible to offline plaintext-confirmation attacks" | S121 count=1 (located) |
| 34 | 12 | "uses a different algorithm designed to be resistant to offline plaintext-confirmation attacks" | S121 count=1 (located) |
| 35 | 17 | "is similar to AES-SIV in that it uses a PRF to generate the nonce from the plaintext." | S121 count=1 (located) |
| 36 | 14 | "can be upgraded by simply performing a rotate operation to a new key version" | S121 count=1 (located) |
| 37 | 16 | "can then be rewrapped against the new key version and will use the version 3 algorithm" | S121 count=1 (located) |
| 38 | 11 | "only be used when a key is expected to be created" | S122 count=1 (located) |
| 39 | 11 | "will require all requests to carry both a context and 96-bit" | S122 count=1 (located) |
| 40 | 12 | "96-bit (12-byte) for AES and ChaCha20 or 192-bit (24-byte) for XChaCha20 nonce" | S122 count=1 (located) |
| 41 | 13 | "The given nonce will be used in place of a randomly generated nonce." | S122 count=1 (located) |
| 42 | 6 | "All key types support HMAC operations" | S121 count=1 (located) |
| 43 | 12 | "each transit key version has an independent, random 256-bit HMAC secret key" | S122 count=1 (located) |
| 44 | 12 | "External keys do not support auto-rotation, exporting, convergent encryption, or context-derived keys." | S122 count=1 (located) |
| 45 | 6 | "All plaintext data must be base64-encoded" | S121 count=1, S122 count=1 (located in both) |
| 46 | 15 | "rotation should occur before approximately 2 32 encryptions have been performed by a key version" | S121 count=1 (located) |
| 47 | 10 | "The wrapping key will be a 4096-bit RSA public key." | S121 count=1 (located) |
| 48 | 6 | "will not support further import operations" | S122 count=1 (located) |
| 49 | 19 | "Specifies base64 encoded associated data (also known as additional data or AAD) to also be authenticated with AEAD ciphers" | S122 count=3 (located; encrypt, decrypt and datakey parameter lists) |
| 50 | 10 | "OpenBao doesn't store the data sent to the secrets engine" | S121 count=1 (located) |
| 51 | 9 | "available operations are dependent on the underlying key type" | S121 count=1, S122 count=1 (located in both) |
| 52 | 6 | "will be upserted with default values" | S122 count=1 (located) |
| 53 | 18 | "The backup contains all the configuration data and keys of all the versions along with the HMAC key." | S122 count=1 (located) |
| 54 | 2 | "min_decryption_version" | parameter name, not a page quote; S121 count=2, S122 count=5 |
| 55 | 2 | "min_decryption_version" | JSON key in the D6 samples, not a page quote (the surrounding sample text is quoted separately in the row below) |
| 56 | 3 | `"min_decryption_version" : 1` | read-key sample response, S122 count=1 (located) |
| 57 | 2 | `"min_decryption_version":1` | decoded from the page's backup sample (base64-decoded by hand; not a raw-text locate) |

The D5 quote `min_decryption_version (int: 0) – Specifies the minimum version of ciphertext
allowed to be decrypted.` is 14 words and located S122 count=1; it is included in the draft
inside backticks rather than double quotes and is listed here for completeness.
