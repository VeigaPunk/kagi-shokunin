# OpenBao transit: `vault:v<n>:` ciphertext, rotate/rewrap migration, `min_decryption_version` retirement, and convergent determinism

source: S121 (https://openbao.org/docs/secrets/transit/, §Usage — the ciphertext prefix, rotate and rewrap; §Working set management; §Convergent encryption; §Key types; §Bring your own key (BYOK); OpenBao docs Version 2.7.x, opened 2026-11-07); S122 (https://openbao.org/docs/api/secret/transit/, §Create key, §Update key configuration, §Rotate key, §Encrypt data, §Decrypt data, §Rewrap data, §Trim key; Version 2.7.x, opened 2026-11-07)
verified-at: 2026-11-07 (both pages fetched as decoded bodies and read as rendered text; every quoted page sentence below is located by `python3 corpus/rendered-text-v1.py locate <capture> QUOTE` against the round-59 capture, except the two D6 JSON fragments, which are sample-payload text — one located raw, one decoded from the page's base64 backup sample; the five T-mechanics were executed against OpenBao 2.7.2 by `corpus/openbao-transit-trial.sh`, whose receipt lines are the only behavioural evidence in §Mechanics)
recheck: on-release — on an OpenBao release, re-open S121 §Usage/§Working set management/§Convergent encryption and S122 §Rotate key/§Update key configuration/§Rewrap data, compare the docs `Version` label to 2.7.x, and re-run `bash corpus/openbao-transit-trial.sh --work <scratch dir>` against the new binary
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the executed trial named there is the behaviour check.)

Scope: OpenBao 2.7.2 only, the transit secrets engine at its default `transit/` mount, and the
single key type the trial creates (the documented default); a Vault fact is never extended to
OpenBao or the reverse. This entry is written in two voices and keeps them apart: the documented
mechanics are the pages' sentences, each with a located quote, while §Measured is only what a
receipt line from the round-59 run shows. Where a page sentence has no receipt behind it, the
entry says so and the claim stays documented, not measured.

## Why it matters for secrets operations

Transit is encryption-as-a-service: the application sends plaintext, OpenBao returns ciphertext,
and OpenBao stores none of it — the caller owns the data store. That split is what makes the
ciphertext prefix the most important six characters in the system: `vault:v1:` names the key
version that encrypted the value, so a ciphertext is self-describing and survives a rotation of
the key that produced it. Rotation therefore does not re-encrypt anything that is already
stored: it adds a key version to the keyring, and the old ciphertext keeps decrypting until an
operator retires the version. The three migration tools are easy to confuse — `rotate` advances
the version, `rewrap` moves an existing ciphertext to the newest version without the client ever
holding the plaintext, and `min_decryption_version` decides which versions may still be
decrypted. Getting that order wrong is how a runbook either strands old ciphertext or silently
keeps a compromised version decryptable. Convergent encryption adds a second, sharper edge: it
makes ciphertext deterministic for equal plaintext and context, which is an equality oracle the
application may want and an offline guessing surface it must accept.

## Documented mechanics (S121/S122, Version 2.7.x, opened 2026-11-07)

Captures: `.ufo/waves/round-59/capture/S121.body`, decoded body sha256
`d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19` (48604 B),
rendered-text-v1 sha256
`3f49303cd3fe01869413193006b2a45e146115f5a80692f8b382f698a57503b6` (14163 B); and
`.ufo/waves/round-59/capture/S122.body`, decoded body sha256
`ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e` (267984 B),
rendered-text-v1 sha256
`a1636fb2ad54212a50bef35857a3ade11a6f65380a4986ca53439fa938193312` (62185 B). Both pages
carry the label `Version 2.7.x`. The captures were fetched by the round-59 scout with a desktop
browser user agent; the scribe's independent fetch produced byte-identical bodies (same raw
sha256), and every header file states the QM72 removals (no cookie was present; the server-issued
request ids were replaced). The normalizer is the one declared in `corpus/rendered-text-v1.py`;
it replaces every HTML tag with a space, so a quote that spans an inline `<code>` element shows
that space. Each quote below was located against the capture named here; where a sentence occurs
in more than one parameter list, the count is stated. The per-quote locate index (quote → capture
→ count) is recorded beside this draft as
`.ufo/waves/round-59/build/R59ScribeEntry/quote-locations.md`.

| # | mechanic | documented rule (anchor, located quote) | what the executed trial asserts (frozen in `plans/round-59.md` §C2) |
|---|---|---|---|
| T1 | a round trip returns the exact plaintext, and the ciphertext names its key version | §Usage: "The returned ciphertext starts with vault:v1:"; "The first prefix ( vault ) identifies that it has been wrapped by OpenBao."; "The v1 indicates the key version 1 was used to encrypt the plaintext"; and "therefore, when you rotate keys, OpenBao knows which version to use for decryption". §Encrypt data / §Decrypt data: "This endpoint encrypts the provided plaintext using the named key." / "This endpoint decrypts the provided ciphertext using the named key." | A round trip returns the exact plaintext, the ciphertext carries a `vault:v1:` prefix and does not contain the plaintext, and one base64 character changed in the ciphertext is refused with a decrypt error. |
| T2 | `rotate` adds a key version; older ciphertext stays decryptable | §Rotate key: "This endpoint rotates the version of the named key." and "After rotation, new plaintext requests will be encrypted with the new version of the key."; §Usage: "Future encryptions will use this new key." and "Old data can still be decrypted due to the use of a key ring." | After one rotation a fresh encryption carries `vault:v2:` while the pre-rotation `vault:v1:` ciphertext still decrypts. |
| T3 | `rewrap` migrates ciphertext to the newest version without the client supplying plaintext | §Rewrap data: "This endpoint rewraps the provided ciphertext using the latest version of the named key." and "Because this never returns plaintext, it is possible to delegate this functionality to untrusted users or scripts."; §Usage: "OpenBao will decrypt the value using the appropriate key in the keyring and then encrypted the resulting plaintext with the newest key in the keyring." and "This process does not reveal the plaintext data." | After rewrap the ciphertext carries `vault:v2:` and decrypts; raising `min_decryption_version` to 2 afterwards still decrypts the rewrapped value while the original `vault:v1:` ciphertext is refused (so the rewrap did not need a client decrypt). |
| T4 | `min_decryption_version` is the retirement control | §Update key configuration: "Specifies the minimum version of ciphertext allowed to be decrypted."; §Working set management: "Key versions that are earlier than a key's specified min_decryption_version gets archived"; "in an emergency the min_decryption_version can be moved back to allow for legitimate decryption". | Raising it to 2 refuses version-1 ciphertext with a named error; lowering it back to 1 makes the same ciphertext decrypt again. |
| T5 | convergent encryption makes ciphertext deterministic for equal plaintext+context | §Convergent encryption: "Convergent encryption is a mode where the same set of plaintext+context always result in the same ciphertext."; §Create key: "If enabled, the key will support convergent encryption, where the same plaintext creates the same ciphertext." and "This requires derived to be set to true ." | Identical plaintext + identical context gives byte-identical ciphertext; a different context gives different ciphertext; a non-convergent key gives different ciphertext for identical plaintext. |

### The prefix is the key version, not a format version

The two prefix sentences are the whole version scheme: `vault` is the wrapper marker, and the
`v1` after it is the key version that encrypted this value (13 of the page's words, located
above), so a later `v2` is the same ciphertext format under a newer key version, not a new
encoding. The page also states the payload shape: "The rest is a base64 concatenation of the
initialization vector (IV) and ciphertext." The trial reads only the prefix and the base64 body
it must echo back; it does not parse the IV out of the body (see §Bounds).

The page's storage sentence is the other half of the design: "OpenBao doesn't store the data
sent to the secrets engine." The primary use case it names is caller-side storage — "The primary
use case for transit is to encrypt data from applications while still storing that encrypted
data in some primary data store." A transit operator therefore never rotates data at rest by
rotating a key; the data store is the caller's to rewrap.

### Rotation vs rewrap vs retirement

`rotate` and `rewrap` look interchangeable in a runbook and are not. The rotate endpoint's own
text says "To upgrade ciphertext to be encrypted with the latest version of the key, use the
rewrap endpoint." — rotation changes what new encryptions use and leaves every stored
ciphertext exactly as it was. The rewrap endpoint takes ciphertext in and returns ciphertext
out, and the page is explicit that it is safe to hand to a low-trust caller for exactly that
reason: "Because this never returns plaintext, it is possible to delegate this functionality to
untrusted users or scripts." (S121's usage section describes the same operation as an internal
decrypt followed by an encrypt with the newest keyring entry; the page writes `encrypted` where
`encrypts` is meant.)

`min_decryption_version` is the reversible retirement switch. The working-set paragraph explains
the intent — old versions are archived, and "by disallowing decryption of old versions of keys,
found ciphertext corresponding to obsolete (but sensitive) data can not be decrypted by most
users" — while keeping an emergency path, "in an emergency the min_decryption_version can be
moved back to allow for legitimate decryption". The API page sets the rotation-policy framing:
"Adjusting this as part of a key rotation policy can prevent old copies of ciphertext from being
decrypted, should they fall into the wrong hands." A different endpoint does the irreversible
version: §Trim key says "Once trimmed, previous versions of the key cannot be recovered." and
"All versions before this version will be permanently deleted.", with the constraint that the
value "can at most be equal to the lesser of min_decryption_version and min_encryption_version ."
Trim is documented here and not exercised by the trial (see §Bounds): it is the one-way door the
reversible `min_decryption_version` is not.

### Convergent encryption is an equality oracle

The mode's definition is one sentence: "Convergent encryption is a mode where the same set of
plaintext+context always result in the same ciphertext." The create-key endpoint adds the
precondition — the key "will support convergent encryption, where the same plaintext creates the
same ciphertext" and "This requires derived to be set to true ." — and the derivation parameter
says that when derivation is enabled, "all encrypt/decrypt requests to this named key must
provide a context" (count=2: the create-key and import-key parameter lists). The context is
therefore part of the key-derivation input, not an optional salt.

The page documents why the history matters. Version 1 required a client nonce and is described as
"highly flexible but if done incorrectly can be dangerous"; version 2 used an algorithmic
approach whose algorithm "was susceptible to offline plaintext-confirmation attacks"; version 3
"uses a different algorithm designed to be resistant to offline plaintext-confirmation attacks"
and "is similar to AES-SIV in that it uses a PRF to generate the nonce from the plaintext."
A version-2 key "can be upgraded by simply performing a rotate operation to a new key version"
and existing values "can then be rewrapped against the new key version and will use the version 3
algorithm" — which is the rotation/rewrap pair used as a security migration, not just a hygiene
step.

There is a documentation tension to read carefully: the API page's *encrypt* parameter list
describes `convergent_encryption` as a value "only be used when a key is expected to be created"
and continues that the mode "will require all requests to carry both a context and 96-bit" plus
a nonce — "96-bit (12-byte) for AES and ChaCha20 or 192-bit (24-byte) for XChaCha20 nonce" — and
that "The given nonce will be used in place of a randomly generated nonce." That paragraph
describes the upsert path (a client-supplied nonce), while the create-key endpoint and the
concept page describe the key-level mode (a derived nonce). The two readings differ in what the
client must send; §Measured records which one the binary followed, and §Docs-vs-binary keeps the
discrepancy.

### Key types and what they gate

S121's §Key types list is the coverage map: `aes128-gcm96` and `aes256-gcm96` (the default),
`chacha20-poly1305` support encryption, decryption, derivation and convergent encryption;
`ed25519` and `ecdsa-p256/p384/p521` support signing/verification (Ed25519 also derivation);
`rsa-2048/3072/4096` support encryption, decryption, signing and verification; `mldsa-44/65/87`
support signing and verification; `hmac` supports HMAC; `external-key` references HSM/KMS-backed
material. "All key types support HMAC operations"; the API page adds that "each transit
key version has an independent, random 256-bit HMAC secret key" and that RSA operations use OAEP
(encrypt/decrypt), PSS (sign/verify) and PKCS#1v1.5 (sign/verify). The two pages disagree on one
row: S122's type lists include `xchacha20-poly1305`, which S121's list omits. Both pages mark
`external-key` as limited: "External keys do not support auto-rotation, exporting, convergent
encryption, or context-derived keys."

Two documented operational constraints belong beside the type table even though the trial does
not touch them: the plaintext is base64 by contract ("All plaintext data must be base64-encoded";
both pages), and the HTTP API imposes a maximum request size of 32MB by default. The rotation guidance also
has a number in it — for AES-GCM keys, "rotation should occur before approximately 2 32
encryptions have been performed by a key version" — which is a design bound, not a measurement
this round.

### Bring your own key is a separate custody path

§Bring your own key documents key import: `transit/wrapping_key` returns a wrapping key, "The
wrapping key will be a 4096-bit RSA public key.", and the operator wraps the target key under it
themselves (HSM PKCS#11 mechanisms or the manual AES-KWP + RSA-OAEP steps). The API page adds the
`import` / `import_version` endpoints, the 512-byte split of the ciphertext field, and the
warning that a rotated imported key "will not support further import operations". This is the
path by which key material can enter or leave OpenBao, and it is not measured here (§Bounds).

## Mechanics (measured, round 59 — OpenBao 2.7.2 dev server, 127.0.0.1, transit engine)

Executed by `corpus/openbao-transit-trial.sh` (round 59): a throwaway `bao server -dev` bound to
127.0.0.1 under `setpriv --pdeathsig KILL`, in-memory storage, a per-run random dev root token
delivered through the environment, `bao` resolved through PATH only, and the plaintext, context
and ciphertext carried in JSON request bodies on stdin (never on argv, never printed). Receipts:
`.ufo/waves/round-59/build/R59ExecTrial/receipt-ref-real.txt` and `receipt-ref-real2.txt` (two
independent runs; the two files are byte-identical, sha256
`097798f1c0c36357cac9ae562e03b530eb941ada70a6ac83c8a23156abcbf40a`), the five shim runs
`receipt-shim-SH1.txt`–`receipt-shim-SH5.txt`, the fail-closed leg `receipt-none.txt`, and the
clean-room driver `receipt-cleanroom.txt`. The lines below are quoted from the real-run receipts;
no number in this table comes from a page.

| # | mechanic | measured on 2.7.2 | receipt line |
|---|---|---|---|
| T1 | encrypt/decrypt round trip, `vault:v1:` prefix, no plaintext in the ciphertext, tampered ciphertext refused | the round trip returned the exact plaintext; the ciphertext carried `vault:v1:`; the plaintext marker was not a substring of it; one changed base64 character was refused (the trial accepts only the server's own `message authentication failed`/`Code: 400` text as the refusal) | `TRIAL T1 HOLDS roundtrip=1 prefix-v1=1 no-pt-in-ct=1 tamper-refused=1` |
| T2 | `rotate` advances the version while older ciphertext stays decryptable | after one rotate the key read `latest_version=2`; a fresh encryption carried `vault:v2:`; the pre-rotation `vault:v1:` ciphertext and the fresh `vault:v2:` ciphertext both decrypted | `TRIAL T2 HOLDS fresh-v2=1 latest=2 old-v1-decrypts=1 new-v2-decrypts=1` |
| T3 | `rewrap` migrates ciphertext to the newest version without a client decrypt | with only the ciphertext supplied, rewrap returned a different value carrying `vault:v2:`; it decrypted before and after `min_decryption_version` was raised to 2, while the original `vault:v1:` ciphertext was refused at that point | `TRIAL T3 HOLDS rewrapped-v2=1 changed=1 rewrapped-decrypts=1 rewrapped-decrypts-after-min2=1 old-v1-refused-after-min2=1` |
| T4 | `min_decryption_version` refuses older ciphertext and lowering it re-enables the same value | after the raise the key read `min_decryption_version=2` and the `vault:v1:` ciphertext was refused on the server's own too-old error text; after lowering to 1 the key read `min_decryption_version=1` and the same ciphertext decrypted | `TRIAL T4 HOLDS pre-v1=1 min-after-raise=2 v1-refused-named-error=1 min-after-lower=1 v1-re-enabled=1` |
| T5 | convergent encryption is deterministic for equal plaintext+context and separates on context and key mode | two encrypt requests with the same plaintext and same context returned byte-identical ciphertext; a different context produced different ciphertext; a second, non-convergent key produced different ciphertext for the same plaintext | `TRIAL T5 HOLDS equal-ctx-byte-identical=1 diff-ctx-differs=1 nonconv-plain-differs=1` |

Both runs end `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` and exit 0.

The five shims each flip exactly their designated test and nothing else: SH1 makes T1 read
`TRIAL T1 BROKEN roundtrip=1 prefix-v1=1 no-pt-in-ct=1 tamper-refused=0`; SH2 makes T2 read
`… old-v1-decrypts=0 …`; SH3 makes T3 read `… old-v1-refused-after-min2=0`; SH4 makes T4 read
`… v1-refused-named-error=0 …`; SH5 makes T5 read `… diff-ctx-differs=0 …`; each shim run's
summary is `holds=4 broken=1 error=0`. A PATH with no `bao` prints
`OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH` and exits 2 with no `TRIAL` line
(`receipt-none.txt`); the trial is therefore not silently scoring a missing binary.

The clean-room leg (`receipt-cleanroom.txt`) starts a second, independent `bao server -dev`
with its own port, its own process and its own fresh in-memory storage, then attempts to decrypt
the first server's T1 ciphertext: the attempt is `REFUSED (rc=2)` with
`Code: 400. Errors:` / `* encryption key not found`, and the driver prints
`CLEANROOM_DRIVER: PASS rc=0`. The T1 ciphertext's length (85) is recorded there; the value
itself is not printed.

## Docs-vs-binary (what the page says and what the run shows)

These rows are the places where a page sentence and the executed run pull apart, or where the
page is narrower than what the trial had to do. The binary side of each row cites a receipt or
the trial's own code; the page side cites a located quote.

| # | topic | page says | run shows | reading |
|---|---|---|---|---|
| D1 | what a convergent-key encrypt request must carry | the API page's *encrypt* parameter list puts `convergent_encryption` under the upsert path: it is a value "only be used when a key is expected to be created" and the mode "will require all requests to carry both a context and 96-bit" plus a nonce, with "The given nonce will be used in place of a randomly generated nonce." | the trial created the key with `derived=true convergent_encryption=true` and sent only `plaintext` and `context` (no `nonce`) on each request, and T5 measured `equal-ctx-byte-identical=1` | the page is narrower: it documents the client-nonce upsert variant, not the key-level convergent mode the create-key endpoint and the concept page describe (deterministic nonce derived by the server). A reader who implements the encrypt-parameter paragraph would send a nonce the trial shows is not needed. |
| D2 | rewrap and the client's plaintext | S121 describes the operation as internal: "OpenBao will decrypt the value using the appropriate key in the keyring and then encrypted the resulting plaintext with the newest key in the keyring." S122 adds "Because this never returns plaintext, it is possible to delegate this functionality to untrusted users or scripts." | the trial's rewrap request body carried only the ciphertext; the response was a different, `vault:v2:` value, and it still decrypted after `min_decryption_version` was raised to 2 while the original v1 ciphertext was refused (`TRIAL T3 HOLDS …`) | no contradiction, but S121 alone is narrower: it describes a server-internal decrypt and invites the misreading that the client must decrypt first. The measured sequence (rewrap, then raise the retirement floor) is the migration the page's pieces imply but does not state as an order. |
| D3 | tamper detection | S122 documents the AEAD ciphers and an `associated_data` field ("Specifies base64 encoded associated data (also known as additional data or AAD) to also be authenticated with AEAD ciphers", count=3 across the encrypt, decrypt and datakey parameter lists), but neither page states that modifying the ciphertext body is detected and refused | T1's tampered copy (one base64 body character changed) was refused, and the trial counts the refusal only when the server's `message authentication failed`/`Code: 400` text appears (`tamper-refused=1`) | the page is narrower: authenticated encryption is documented as an option (`associated_data`) and as a cipher property, not as an observable refusal. The refusal itself is measured, not documented. |
| D4 | a ciphertext's portability between servers | S121 says "OpenBao doesn't store the data sent to the secrets engine", but neither page says whether a ciphertext can be decrypted by a different OpenBao server | a second dev server with its own storage refused the first server's ciphertext with `Code: 400. Errors:` / `* encryption key not found` (`receipt-cleanroom.txt`) | the page is narrower: the sentence that the caller stores the data is true, and the complementary fact — the key material is server-local, so the ciphertext is not portable without the key — follows only from the run. |
| D5 | the raise's precondition | S122's config parameter text says `min_decryption_version (int: 0) – Specifies the minimum version of ciphertext allowed to be decrypted.` and states no relation to the latest key version | the trial rotates the key before raising the minimum (T4's `pre-v1=1` is the pre-rotation ciphertext, and the raise targets version 2); the trial's header records that the API refuses `min_decryption_version > latest_version` with a 400 | a page gap: the constraint is real in the trial author's record but **no receipt line prints it**, so this entry does not raise it to a measured row. It is named here because a runbook that sets the floor before rotating will hit it. |
| D6 | the default of `min_decryption_version` | the same parameter text says `int: 0`, while the read-key sample response contains `"min_decryption_version" : 1` and the page's backup sample base64-decodes to a policy with `"min_decryption_version":1` | T4 reads the value only after setting it (`min-after-raise=2`, `min-after-lower=1`); the run does not read the pre-set default | a page-internal inconsistency (parameter default 0 vs both samples' 1) that this run did not resolve. Do not treat either number as measured. |
| D7 | the key-type list | S121's §Key types list has no `xchacha20-poly1305`, while S122's create-key and import type lists both include it (`xchacha20-poly1305 – XChaCha20-Poly1305 AEAD (symmetric, supports derivation and convergent encryption)`, count=2); S122 also carries the `external-key` restriction "External keys do not support auto-rotation, exporting, convergent encryption, or context-derived keys." that S121 states only as "available operations are dependent on the underlying key type" | no key-type comparison was run: every key in the trial is the default `aes256-gcm96` (the create calls pass no `type`) | a page-vs-page difference, not a page-vs-binary one. Both readings stay documented; the run cannot arbitrate because it never creates a second type. |

### Page gaps the trial had to measure (scout G1–G10, re-checked here)

The round-59 scout's §4 lists the C2 sub-assertions that neither page states; this seat re-ran the
absence checks against the same two captures (locate counts below) and keeps the list here,
because each gap is another place where the page is narrower than the run. The scout's table is
`.ufo/waves/round-59/build/R59ScoutSources/sources.md` §4; the counts are this seat's, against
`.ufo/waves/round-59/capture/S121.body` and `S122.body`.

| gap | page does not state | absence check on both captures | measured row that fills it |
|---|---|---|---|
| G1 | the named error for ciphertext below the floor | `failed to decrypt`, `invalid ciphertext`, `cannot decrypt`, `permission denied`, `forbidden`, `disallowed by policy`, `too old` each locate `count=0` on S121 and S122 | T4 `v1-refused-named-error=1` (the trial classifies the refusal on the server's `disallowed by policy`/`too old` text; the exact printed string is in the trial header, not a receipt) |
| G2 | that a modified ciphertext is refused | `tamper`, `message authentication failed`, `corrupted` each `count=0` | T1 `tamper-refused=1` (see D3) |
| G3 | that the plaintext is absent from the ciphertext | `does not contain`, `not contain the plaintext` each `count=0`; the nearest page statement is the IV‖ciphertext sentence | T1 `no-pt-in-ct=1` |
| G4/G9 | that a different context gives different ciphertext | `different context`, `different ciphertext` each `count=0` | T5 `diff-ctx-differs=1` |
| G5 | that a non-convergent key gives different ciphertext for equal plaintext | `non-convergent`, `nonconvergent` each `count=0` | T5 `nonconv-plain-differs=1` |
| G6/G7 | the post-rotation result in one sentence (v1 still decrypts; a fresh encryption is v2) | `after rotation` `count=0`; `vault:v2:` occurs only in the rewrap sample response bodies (S121 count=1, S122 count=1) | T2 `fresh-v2=1 latest=2 old-v1-decrypts=1` |
| G8 | that key-level convergent mode needs no client nonce | `without a nonce`, `no nonce`, `nonce is optional` each `count=0`; the encrypt-parameter paragraph says a nonce is required | T5 `equal-ctx-byte-identical=1` (see D1) |
| G10 | the rewrap-then-raise sequence | no sentence; `after rotation` `count=0` | T3 `rewrapped-decrypts-after-min2=1 old-v1-refused-after-min2=1` |

These are not page statements that support the measured rows; they are the page-shaped holes the
rows fill. A later release could close any of them, and the `recheck:` line is what would notice.

One page/binary agreement is worth stating because the whole scheme rests on it: the pages call
the `v1` after `vault:` the key version, and the run's post-rotation encryption carried `v2`
while the pre-rotation ciphertext still decrypted (`TRIAL T2 HOLDS … latest=2 …`). Nothing in
the run contradicted the prefix's meaning.

### What the trial's setup itself shows

The T1 key is never pre-created: the first `transit/encrypt/r59-t1` call is the first write on
that name, and it returned a ciphertext, so the encrypt endpoint auto-created the key with
default values — the documented upsert path (`transit/encrypt/:name` "will be upserted with
default values" when the caller has `create`). T2–T5 create their keys explicitly. The default
type is therefore the type of every key in the run, and the default key is what §Bounds calls
the one measured type.

## Bounds (does not establish)

- One binary (OpenBao 2.7.2), one host, one throwaway `bao server -dev` per real run with
  in-memory storage and a dev root token created for the run, plus the trial's second
  clean-room dev server for the cross-server leg. No seal/unseal, no HA, no namespaces, no
  performance, no listener or request-size tuning.
- One key type: the trial's key is the documented default (`aes256-gcm96`, symmetric AEAD). No
  RSA key type, no ECDSA/Ed25519/ML-DSA type, no `aes128-gcm96`, `chacha20-poly1305` or
  `xchacha20-poly1305` variant, no `hmac` type and no `external-key` is exercised; the key-type
  table above is documented, not compared. `plans/round-59.md` names `RSA/AES key types` as a
  ceiling for exactly this reason: the trial does not vary the type.
- Signing, signature verification and HMAC generation/verification are documented and **not
  measured**: no `transit/sign`, `transit/verify`, `transit/hmac`, hash or random-bytes call is
  part of T1–T5.
- Key import/export and custody movement are documented and **not measured**: `import`,
  `import_version`, `transit/wrapping_key`, `transit/export`, the BYOK export endpoints,
  `backup`/`restore` and `soft-delete` are outside the trial. The backup endpoint's plaintext
  key material ("The backup contains all the configuration data and keys of all the versions
  along with the HMAC key.") is a custody fact this entry does not exercise.
- Re-encryption of stored data is **not measured**. Transit stores no data; `rewrap` moves a
  caller-held ciphertext to the newest version. No test rewrites rows in a data store, and the
  entry's migration statement is about ciphertext, never about data at rest.
- `trim` is documented and **not measured**: the irreversible deletion of old key versions, its
  interaction with `min_decryption_version`/`min_encryption_version` being zero, and whether a
  trimmed version stays gone are all unexercised. T4 moves the minimum down within the same run;
  it does not test whether an archived version survives a `trim`.
- Convergent-encryption *internals* are not measured: the trial observes determinism and
  context separation, not the nonce-derivation construction, the version-1/2/3 history, or the
  offline plaintext-confirmation resistance the page claims for version 3. Low-entropy plaintext
  guessability (the documented version-2 weakness) is not probed.
- `associated_data` (AAD), `batch_input`, `key_version`-pinned encryption, `nonce` injection,
  `auto_rotate_period`, `disable_upsert`, the transit cache config and the 32 MB request limit
  are documented and **not measured**.
- One page label: both pages say Version 2.7.x; a later release can change any rule above, and
  the `recheck:` line is the clock that would notice.

## Falsifiers

Each line names an observation that would break the measured claim it sits under.

- T1: a round trip that does not return the exact plaintext; a ciphertext without the
  `vault:v<digits>:` prefix; a ciphertext that contains the plaintext as a substring; a
  one-character base64 change that still decrypts.
- T2: after a rotation, a fresh encryption still carrying `vault:v1:`; a pre-rotation
  `vault:v1:` ciphertext that stops decrypting without any `min_decryption_version` change; a
  rotation that leaves the read-key `keys` map at one version.
- T3: a rewrap response that carries `vault:v1:` (no version advance); a rewrapped value that
  fails to decrypt; a client that must send plaintext for a rewrap; a rewrapped value refused
  after `min_decryption_version` is raised to 2, or an original `vault:v1:` ciphertext still
  accepted at that point (which would show the rewrap did not reach version 2).
- T4: raising `min_decryption_version` to 2 while a `vault:v1:` ciphertext still decrypts;
  lowering it back to 1 while the same ciphertext stays refused; a refusal with no named error
  (a transport failure or a hang would not count as the retirement control firing).
- T5: two identical plaintext+context requests under a convergent key producing different
  ciphertext; two different contexts producing the same ciphertext; a non-convergent key
  producing identical ciphertext for identical plaintext; a convergent key that refuses an
  encrypt request because no client-supplied nonce was sent (which is the page's encrypt-
  parameter wording and would falsify the measured retrieval path in §Docs-vs-binary D1).
- Clean-room leg: a second, independently started dev server decrypting the first server's T1
  ciphertext, or a clean-room reading produced against the same server process (the leg would
  then measure nothing).
- Shims and fail-closed legs: any shim whose run changes a test other than its designated one,
  or changes none; a real run that reads BROKEN or ERROR; a PATH without `bao` that prints any
  `TRIAL` line, exits 0, or still reports a summary with `holds=5`.
- Prefix reading: a `vault:v2:` value decrypting only after a rotate that was never run, or a
  `vault:v1:` value decrypting after version 1 was retired — either would mean the prefix is not
  the key version this entry says it is.
- Determinism reading: a convergent key that demands a client-supplied nonce for an ordinary
  encrypt (the API page's encrypt-parameter wording), or one that returns different ciphertext
  for identical plaintext+context without a nonce — either falsifies the measured side of
  §Docs-vs-binary.
- Bounds: any claim here that signing, HMAC, import/export, a non-default key type, `trim`, AAD
  or stored-data re-encryption was exercised by this round.
