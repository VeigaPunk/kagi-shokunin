# R59LabratContext — bounded probe: `transit/rewrap` on a convergent key, and `min_decryption_version`

Seat: R59LabratContext (attack share, round 59 wave 1). Read-only on the lane: this file and the
receipts beside it are the only writes.
Date: 2026-11-07. Host: linux 7.2.11-arch1-1.
Binary: `/home/vgpnk/.local/bin/bao`, OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379),
sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (matches the pinned hash).
Engine: throwaway `bao server -dev`, `127.0.0.1:<ephemeral>`, in-memory storage,
`setpriv --pdeathsig KILL`, `-dev-no-store-token`; one server is started and destroyed per run;
the dev root token is generated per run, reaches the server via `BAO_DEV_ROOT_TOKEN_ID` and the
client via `BAO_TOKEN` only, and appears on no argv and in no printed line.
Three independent runs: run2, run3 (same legs, same summaries), run4 (canonical, adds the
determinism attribution controls). All legs below cite `transcript-run4.txt`, line anchors in
`[N]`.

Receipts (this directory): `transcript-run4.txt` (630 lines, canonical), `transcript-run3.txt`,
`transcript-run2.txt`, `probe.sh` (re-runnable: `bash probe.sh <empty-work-dir>`; each run creates
its own dev server and deletes nothing outside that dir).
Scratch used: `/fast/scratch/hyaku/kagi-r59/R59LabratContext/` (deleted before yield).

## Hypothesis

> On OpenBao 2.7.2 a convergent key refuses `transit/rewrap` without the original `context`, and a
> rewrap of a version-1 ciphertext under a key whose `min_decryption_version` already excludes that
> version is refused.

Split for measurement:

- **H1** — a key created with `convergent_encryption: true` refuses `transit/rewrap` when the
  request omits the `context` used at encryption.
- **H2** — a `transit/rewrap` of a `vault:v1:` ciphertext under a key whose
  `min_decryption_version` is 2 is refused.

## Setup

`transit/` enabled [3]. Keys:

| key | create command | observed |
|---|---|---|
| `conv` | `bao write transit/keys/conv convergent_encryption=true` | **refused**, 400, `* convergent encryption requires derivation to be enabled` [12–24] |
| `convd` | `bao write transit/keys/convd derived=true convergent_encryption=true` | created; `derived=true convergent_encryption=true kdf=hkdf_sha256 type=aes256-gcm96 convergent_encryption_version=-1 min_decryption_version=1` [35–64] |
| `plain` | `bao write -f transit/keys/plain` | created, defaults (`derived=false`) [66–92] |
| `dv` | `bao write transit/keys/dv derived=true` | created, `convergent_encryption=false` [94–123] |

Contexts are base64 of the ASCII strings `r59-context-alpha` (`CTX_A`) and `r59-context-beta`
(`CTX_B`); the plaintext is base64 of the marker `r59-probe-plaintext`. No value is a secret.

Convergence controls, before any rewrap: two encryptions of the marker under `convd` with `CTX_A`
return **byte-identical** ciphertext [125–161], a third with `CTX_B` returns a different one
[149–162], both `vault:v1:` [163]. So the key is demonstrably convergent and `context` demonstrably
feeds the derivation.

## Results

`rc` is the `bao` CLI exit status; the HTTP status is the `Code:` field of the error block.
`prefix` is the `vault:v<n>:` prefix of the returned ciphertext (`—` = no ciphertext returned).

| leg | command shape | rc / HTTP | raw response (verbatim) | prefix |
|---|---|---|---|---|
| **a** rewrap, no context | `bao write transit/rewrap/convd ciphertext=vault:v1:CXtPyI/Z3d92Q325UlnZEy4rW4bx8JqOyEFqNXajXlPiuwFxizvWzUG/A4Od/Pw=` [165] | 2 / 400 | `* missing 'context' for key derivation; the key was created using a derived key, which means additional, per-request information must be included in order to perform operations with the key` | — |
| **b** rewrap, wrong context (`CTX_B`) | `bao write transit/rewrap/convd ciphertext=… context=cjU5LWNvbnRleHQtYmV0YQ==` [180] | 2 / 400 | `* cipher: message authentication failed` | — |
| **c** rewrap, right context (`CTX_A`) | `bao write transit/rewrap/convd ciphertext=… context=cjU5LWNvbnRleHQtYWxwaGE=` [195] | 0 / 200 | `ciphertext vault:v1:CXtPyI/Z3d92Q325UlnZEy4rW4bx8JqOyEFqNXajXlPiuwFxizvWzUG/A4Od/Pw=` — **byte-identical to the input** | `vault:v1` |
| c′ decrypt of c | `bao write transit/decrypt/convd …` [207] | 0 / 200 | `plaintext cjU5LXByb2JlLXBsYWludGV4dA==` (= `r59-probe-plaintext`) | — |
| **d0** rotate, then rewrap the v1 ciphertext | `bao write -f transit/keys/convd/rotate` [219] then `bao write transit/rewrap/convd … context=$CTX_A` [293] | 0 / 200 | `ciphertext vault:v2:Xwal+zHOGL5yrCyWSNFvpl2wHmzNlZ0luGc1e/GGrad7dK3O2zJJbEBztVLrsqc=` — **byte-identical to a fresh encryption of the same plaintext+context at v2** (`enc-after-rotate` [281]) | `vault:v2` |
| d0′ decrypt of d0 | `bao write transit/decrypt/convd …` [305] | 0 / 200 | the marker | — |
| **d** raise `min_decryption_version=2` [317], then rewrap the v1 ciphertext | `bao write transit/rewrap/convd ciphertext=vault:v1:CXtPyI/Z3d92Q325UlnZEy4rW4bx8JqOyEFqNXajXlPiuwFxizvWzUG/A4Od/Pw= context=$CTX_A` [379] | 2 / 400 | `* ciphertext or signature version is disallowed by policy (too old)` | — |
| d2 control: rewrap the v2 ciphertext at mdv=2 | `bao write transit/rewrap/convd ciphertext=vault:v2:Xwal+zHOGL5yrCyWSNFvpl2wHmzNlZ0luGc1e/GGrad7dK3O2zJJbEBztVLrsqc=` [393] | 0 / 200 | identical v2 ciphertext | `vault:v2` |
| d2b precedence: v1 + wrong context at mdv=2 | [405] | 2 / 400 | `* ciphertext or signature version is disallowed by policy (too old)` | — |
| d2c precedence: v1 + no context at mdv=2 | [419] | 2 / 400 | `* ciphertext or signature version is disallowed by policy (too old)` | — |
| d3 control: decrypt the v1 ciphertext at mdv=2 | [433] | 2 / 400 | `* ciphertext or signature version is disallowed by policy (too old)` | — |
| d4 control: lower mdv to 1 [447], decrypt v1 | [478] | 0 / 200 | the marker | — |
| **e** isolation: plain key, rewrap no context | `bao write transit/rewrap/plain ciphertext=vault:v1:S8+6TwyT5oF28Y0vUYeBlUXH6TYdAwJZwvtkxM9ySyHO8V5CrwlJci4AktcHuHc=` [514] | 0 / 200 | **succeeds**, different ciphertext (random nonce) | `vault:v1` |
| e2: plain key, rewrap **with** context | [526] | 0 / 200 | succeeds; context accepted and ignored | `vault:v1` |
| **f** isolation: derived but **non**-convergent key, rewrap no context | `bao write transit/rewrap/dv ciphertext=vault:v1:r/krqafkCcsfWnaAqgqJMNmz3zinLz0vgUbDs80gRcgtdaBr3mXkoUHEtHtv0WE=` [562] | 2 / 400 | `* missing 'context' for key derivation; the key was created using a derived key, …` — **byte-identical error to leg a** | — |
| f2: same key, right context | [576] | 0 / 200 | succeeds, different ciphertext (random nonce) | `vault:v1` |
| f3: same key, wrong context | [588] | 2 / 400 | `* cipher: message authentication failed` | — |
| g: rewrap v1 again after mdv lowered back to 1 | [603] | 0 / 200 | identical to d0 (deterministic) | `vault:v2` |

Determinism controls [615–618]: `rewrap-deterministic-after-rotate=yes`,
`rewrap-v2-equals-fresh-encrypt=yes`,
`nonconvergent-plain-encrypt-twice-identical=no`,
`derived-nonconvergent-encrypt-twice-identical=no`.

## Verdict

**HOLDS as stated (both conjuncts), with one mechanism correction and one adjacent inference
falsified.**

- **H1 — holds.** A convergent key (which in 2.7.2 must be created with `derived=true`; the create
  without it is refused `400 * convergent encryption requires derivation to be enabled`) refuses
  `transit/rewrap` without the context: `400 * missing 'context' for key derivation…`. Wrong
  context is refused `400 * cipher: message authentication failed`; the right context succeeds and
  round-trips.
  **Correction of the causal story:** the refusal is the *derived-key* rule, not the convergence
  flag. Evidence: a derived, **non-convergent** key (`dv`) refuses identically, with the
  byte-identical error text (leg f), and the error text itself names derivation
  ("the key was created using a derived key"). Convergence cannot be separated from derivation in
  2.7.2 because create-time refuses it (leg `conv`). So the true sentence is: *every convergent key
  is a derived key, and every derived key requires `context` on rewrap.*
- **H2 — holds.** `transit/rewrap` of a `vault:v1:` ciphertext under `min_decryption_version=2` is
  refused `400 * ciphertext or signature version is disallowed by policy (too old)`, and the
  refusal is not a context artefact: it fires with the right context [379], with a wrong context
  [405] and with no context [419]. The version gate is evaluated **before** the context check and
  before the MAC check. Lowering `min_decryption_version` back to 1 makes the same v1 ciphertext
  decrypt again [478], and a v2 ciphertext rewraps normally [393].

**Adjacent claim falsified (this is the attack).** The round-59 plan's T3 carries the parenthetical
"(so the rewrap did not need a decrypt)". The observable T3 uses cannot support it, and the probe
refutes its literal reading: `transit/rewrap` is subject to the *decryption* gates — it demands the
derivation `context` (leg a), it fails authentication on the wrong `context` (leg b), and it is
refused by `min_decryption_version` exactly like `transit/decrypt` (leg d vs d3). Rewrap therefore
unwraps/decrypts internally and re-encrypts under the latest version; what is true is the weaker
and testable statement *"the client never supplies the plaintext"*.
The docs are consistent with the measured gates: S122 `transit/rewrap` — "context … This is
required if key derivation is enabled"; S122 `convergent_encryption` — "each
encryption(/decryption/rewrap/datakey) operation will derive a nonce value rather than randomly
generate it". S122's `derived` parameter sentence names only "encrypt/decrypt requests", and S122's
`min_decryption_version` says "minimum version of ciphertext allowed to be decrypted" — neither
sentence names rewrap, which is why the behaviour is worth recording.

## Falsifiers that would overturn the verdict

- **H1:** any run where a key with `convergent_encryption=true` (necessarily `derived=true`) accepts
  `transit/rewrap` without `context` and returns a ciphertext that decrypts under that same
  context; or a key with `convergent_encryption=true` that can be created without `derived=true` and
  then accepts a context-free rewrap. (Neither was observed on 2.7.2.)
- **H1 mechanism:** a derived, non-convergent key that accepts a context-free rewrap with a
  decryptable result — that would move the cause back onto convergence. Leg f refutes it.
- **H2:** any run where a `vault:v1:` ciphertext rewraps successfully under `min_decryption_version=2`
  (a returned `vault:v2:`), or where the refusal is reported as a context/MAC error rather than the
  version error.
- **Harness artefacts that would void the readings:** a `context` value that is not the base64 the
  engine expects (refuted by the success legs c/f2 and by the convergence controls), a key that is
  not actually convergent (refuted by the byte-identical double encryption), a leaked ambient
  `BAO_*`/`VAULT_*` environment (the harness unsets them before start), or a reply from a server
  other than the one this run started (the port is bound by the run's own pid and re-checked).

## What T1–T5 must add or narrow

| test | change | evidence |
|---|---|---|
| T1 | none. | round trip, `vault:v1:` prefix and tamper refusal are unaffected by this probe. |
| T2 | none. | rotate → fresh `vault:v2:` while the v1 ciphertext still decrypts [219–305]. |
| T3 | **delete the parenthetical "(so the rewrap did not need a decrypt)"** — it is not observable and its literal reading is false. Replace with the measured statement that rewrap is gated by the decrypt-path controls. Keep T3's ordering (rewrap **before** raising `min_decryption_version`); if a rewrap-after-retirement leg is added, it must expect `400 * ciphertext or signature version is disallowed by policy (too old)`. | legs a, b, d, d2, d3 |
| T3 (optional sharpening) | on a convergent key, the rewrapped ciphertext is byte-identical to a fresh encryption of the same plaintext+context under the newest version [293 vs 281] — a stronger, cheap observable than "prefix changed". | [615–616] |
| T4 | pin the named error text `ciphertext or signature version is disallowed by policy (too old)` and note that the same gate applies to `transit/rewrap`, not only `transit/decrypt`. | [379, 433, 478] |
| T5 | add `derived=true` to the key creation (convergent alone is refused `400 * convergent encryption requires derivation to be enabled`), and scope the determinism claim to **one key version**: after a rotation the same plaintext+context encrypts to a different ciphertext (`vault:v2:`), so "identical plaintext + identical context gives byte-identical ciphertext" holds only while `latest_version` is unchanged. | [12–24], [125–163], [281] |
| T5 (optional) | add the convergent-rewrap legs this probe measured: context-free rewrap on a convergent key → 400 missing context; right-context rewrap idempotent at the current version; deterministic across repeats. | legs a, c, g |

Also worth carrying into the lane's lesson (not a predicate change): the key read shows
`convergent_encryption_version = -1` for a key created with `convergent_encryption=true` on 2.7.2.
S122 does not define that field's value; *inference*: `-1` marks the key as not on a numbered
convergence scheme; this was not measured further and should not be cited as a fact.

## Bounds

One binary (OpenBao 2.7.2), one host, in-memory dev storage, `aes256-gcm96` only, one plaintext and
two contexts per key, three server lifetimes. Not measured: signing/HMAC, asymmetric key types,
`key_version=` overrides on rewrap, `min_encryption_version`, key import/export, rotation of an
already-retired version, `batch_input` on rewrap, and whether a non-`derived` convergent key can be
created by any other route (e.g. import). The three runs are independent servers with fresh keys;
the summaries agree.

SEAT-STATUS: complete
