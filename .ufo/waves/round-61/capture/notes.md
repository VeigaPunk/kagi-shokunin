# Round-61 seal / seal-key capture notes (S125, S126, S127)

Seat: `R61ScoutSealDocs` (scout, wave-1 of round 61, attempt 1). Lane: `kagi-shokunin`.
Scope: open the three seal / seal-key documentation sources this round declares, live, and record the
located-quote evidence the registry rows (S125/S126/S127) and the lesson `## Gate` need. This seat
edits no registry, lesson, SCORECARD, plan or knowledge file; it only writes the three captured
bodies, this notes file, and its own report + receipts.

## 0. Fetch record (all three sources)

Common request profile — one desktop-browser user agent, `curl -fsSL --compressed`:

```
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
curl -fsSL --compressed -A "$UA" -D <sid>.rawheaders -o <sid>.body \
     -w '%{http_code} %{url_effective} %{size_download}\n' "<url>"
```

The `-w` template above is the fetch command for each source, run from the seat scratch
`/fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/`. `--compressed` makes curl remove
`Content-Encoding: gzip`, so the saved `.body` is the **decoded** HTTP body (lane representation
`decoded-http-body-v1`). The bodies were then copied byte-for-byte to
`.ufo/waves/round-61/capture/<sid>.body` in the lane; `cmp` between the scratch copy and the lane
copy is clean (see §5).

| id | url | http_status | final_url (`%{url_effective}`) | wire bytes (`%{size_download}`, gzip) | decoded body bytes | sha256 of decoded body | access date |
|---|---|---|---|---|---|---|---|
| S125 | `https://openbao.org/docs/concepts/seal/` | `200` | https://openbao.org/docs/concepts/seal/ (unchanged; no redirect) | 11421 | 44279 | `643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65` | 2026-11-07 (server `date:` header `Sat, 07 Nov 2026 19:50:51 GMT`) |
| S126 | `https://openbao.org/docs/commands/operator/rekey/` | `200` | https://openbao.org/docs/commands/operator/rekey/ (unchanged; no redirect) | 8434 | 44328 | `53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a` | 2026-11-07 (server `date:` header `Sat, 07 Nov 2026 19:50:51 GMT`) |
| S127 | `https://openbao.org/docs/commands/operator/generate-root/` | `200` | https://openbao.org/docs/commands/operator/generate-root/ (unchanged; no redirect) | 7893 | 38368 | `4adb6eb414a8119225e2b3936b99ffb395966cea347f2964f43cedfbe26459aa` | 2026-11-07 (server `date:` header `Sat, 07 Nov 2026 19:50:51 GMT`) |

User agent string used verbatim for all three requests:

```
Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36
```

Bodies live at `.ufo/waves/round-61/capture/S125.body`, `…/S126.body`, `…/S127.body`.

Digest/byte-count reproduction (run from the lane root `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

```
sha256sum .ufo/waves/round-61/capture/S125.body .ufo/waves/round-61/capture/S126.body .ufo/waves/round-61/capture/S127.body
wc -c    .ufo/waves/round-61/capture/S125.body .ufo/waves/round-61/capture/S126.body .ufo/waves/round-61/capture/S127.body
```

```
643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65  .ufo/waves/round-61/capture/S125.body
53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a  .ufo/waves/round-61/capture/S126.body
4adb6eb414a8119225e2b3936b99ffb395966cea347f2964f43cedfbe26459aa  .ufo/waves/round-61/capture/S127.body
 44279 .ufo/waves/round-61/capture/S125.body
 44328 .ufo/waves/round-61/capture/S126.body
 38368 .ufo/waves/round-61/capture/S127.body
```

**Secret hygiene (QM72).** No response carries a `set-cookie:` or `cookie:` header:
`grep -in cookie` over the three raw header files returns 0 matches (exit 1), so no cookie value
existed to remove and none is written here or in the captured bodies. Nothing in this file, in the
bodies or in the receipts is a cookie, session id, OTP value, key share or root token — only
shapes, counts and public documentation text. The per-request correlation ids the origin sends
(`x-github-request-id`, `x-fastly-request-id`) are server-issued and are deliberately not copied
into this file.

**Pages opened.** Exactly these three. No fourth URL was fetched this round; the raw-header
files for each are kept in the seat scratch and deleted with it.

**Doc version.** All three pages carry `docs-version-2.7.x` in their `<html class=…>` attribute and
the sidebar shows `Version: Version 2.7.x`, matching the plan's "OpenBao docs 2.7.x".

### How the quotes below resolve

Two locator families, both resolved **against the captured body bytes**:

* **raw-literal** — the anchor is a literal byte substring of the `.body` file (HTML markup
  included where the page wraps the prose in `<em>`, `<code>`, `<a>`). Resolve with
  `grep -c -F '<anchor>' <body>`; the byte offset and line number are given.
* **rendered-v1** — the quoted prose is resolved with the lane's own committed normalizer
  `corpus/rendered-text-v1.py locate <body> '<quote>'` (reads only the named file; no network, no
  writes). Every such quote additionally carries a **raw-literal anchor** that *is* a byte
  substring of the same body, with its byte offset and line, so the quote's position in the
  captured bytes is verifiable without normalizing.

Quote length: every quote below is at most 25 words (the lane's `source-fetches.tsv` quote-cell
bound). Measured word counts are given next to each quote.

---
---

## 1. S125 — `https://openbao.org/docs/concepts/seal/` (Seal/Unseal concept page)

Body: `.ufo/waves/round-61/capture/S125.body`, 44279 B, sha256
`643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65`.

Section headings on this page (h2/h3, by `id`): `Why?` (`why`), `Shamir seals` (`shamir-seals`),
`Unsealing` (`unsealing`), `Sealing` (`sealing`), `Auto unseal` (`auto-unseal`), `Recovery key`
(`recovery-key`), `Initialization` (`initialization`, h3), `Rotation` (`rotation`, h3),
`Seal migration` (`seal-migration`), `Migration steps` (`migration-steps`, h3).

### 1.1 Mechanic 1 — Shamir key shares, the threshold, custody and the seal/unseal state machine

**1a. The shares come from Shamir's Secret Sharing, not from a single key handed to one operator.**

> "OpenBao uses an algorithm known as Shamir's Secret Sharing to split the key into shares."
— §Shamir seals (15 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'OpenBao uses an algorithm known as Shamir'"'"'s Secret Sharing to split the key into shares.'
grep -c -F 'to split the key into shares.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `to split the key into shares.` at **byte 24751, line 30** of `S125.body`.

**1b. A threshold of shares is required to reconstruct the unseal key.**

> "A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key."
— §Shamir seals (21 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key.'
grep -c -F 'A certain threshold of shares is required to
reconstruct the unseal key, which is then used to decrypt the root key.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 24781, line 30** of `S125.body`.

**1c. Custody: each share can live on a distinct client machine; the operator holds the shares.**

> "This allows each share of the root key to be on a distinct client machine for better security."
— §Unsealing (18 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'This allows each share of the root key to be on a distinct client machine for better security.'
grep -c -F 'key to be on a distinct client machine for better security.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 25527, line 39** of `S125.body`.

**1d. Whether the server stores the shares: NOT STATED on S125.** The page never says in so many
words that the shares are or are not persisted on the server, and it never uses the words
"stored", "persisted" or "on disk" about the Shamir *unseal* shares. What it does say about
custody is 1b and 1c above, plus the two statements quoted in 1c/1d of §1.3. The negative is
measured, not assumed:
```
grep -c -iE 'not stored|never stored|stored on disk|persist' .ufo/waves/round-61/capture/S125.body   # => 0
```
(The only `stored` hits on the page are about *data*, the *encryption key* in the keyring and
the *root key* — none about the Shamir shares.)

**1e. The seal/unseal state machine.**

> "When an OpenBao server is started, it starts in a sealed state."
— §Seal/Unseal (page intro) (12 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'When an OpenBao server is started, it starts in a sealed state.'
grep -c -F 'When an OpenBao server is started, it starts in a' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 22528, line 5** of `S125.body`.

> "The only possible operations are to unseal the OpenBao and check the status of the seal."
— §Seal/Unseal (page intro) (16 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'The only possible operations are to unseal the OpenBao and check the status of the seal.'
grep -c -F 'The only possible operations are to unseal the OpenBao and check the status' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 23059, line 12** of `S125.body`.

> "Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:"
— §Unsealing (15 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:'
grep -c -F 'Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 25795, line 43** of `S125.body`. The page then lists the three exits:
"It is resealed via the API (see below)." (8 words), "The server is restarted." (4 words),
"OpenBao's storage layer encounters an unrecoverable error." (8 words).

Resolve for the three list items:
```
grep -c -F 'It is resealed via the API (see below).' .ufo/waves/round-61/capture/S125.body   # => 1   (byte 25910, line 46)
grep -c -F 'The server is restarted.' .ufo/waves/round-61/capture/S125.body   # => 1   (byte 25977, line 49)
grep -c -F "OpenBao's storage layer encounters an unrecoverable error." .ufo/waves/round-61/capture/S125.body   # => 1   (byte 26029, line 52)
```

**1f. Sealing discards the root key from memory and needs another unseal; one operator suffices.**

> "This will throw away the root key in memory and require another unseal process to restore it."
— §Sealing (17 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'This will throw away the root key in memory and require another unseal process to restore it.'
grep -c -F 'key in memory and require another unseal process to restore it.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 27392, line 64** of `S125.body`.

> "Sealing only requires a single operator with root privileges."
— §Sealing (9 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'Sealing only requires a single operator with root privileges.'
grep -c -F 'only requires a single operator with root privileges.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 27464, line 65** of `S125.body`.

> "It can't be accessed again without access to the root key shares."
— §Sealing (12 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'It can'"'"'t be accessed again without access to the root key shares.'
grep -c -F 'access to the root key shares.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 27671, line 68** of `S125.body`.

**The concrete share count (5) and threshold (3) used by the round's trial: NOT STATED on S125.**
The concept page never writes a number of Shamir shares or a threshold value — it only names
`recovery-shares` / `recovery-threshold` for the **auto-unseal** recovery key under
§Initialization, and never a Shamir `key-shares` / `key-threshold` pair:
```
grep -c -E 'key-shares|key-threshold' .ufo/waves/round-61/capture/S125.body   # => 0
grep -c -E 'recovery-shares|recovery-threshold' .ufo/waves/round-61/capture/S125.body   # => 2
```
The `5`/`3` defaults for the rekey command *are* documented, but on S126, not S125 — see §2
(M3.7, M3.8). A citation of S125 alone cannot support the numbers `t=3 n=5`.

### 1.2 Mechanic 2 — what the unseal progress/nonce means, and whether a repeated share counts

**2a. The unseal process is stateful and accumulates shares one at a time.**

> "This process is stateful: each key can be entered via multiple mechanisms from multiple client machines and it will work."
— §Unsealing (20 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'This process is stateful: each key can be entered via multiple mechanisms from multiple client machines and it will work.'
grep -c -F 'This process is stateful: each key can be entered via multiple mechanisms from
multiple client machines and it will work.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 25370, line 37** of `S125.body`.

> "the shares are added one at a time (in any order) until enough shares are present to reconstruct the key and decrypt the root key."
— §Shamir seals (25 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'the shares are added one at a time (in any order) until enough shares are present to reconstruct the key and decrypt the root key.'
grep -c -F 'the shares are added one at a time (in any
order) until enough shares are present to reconstruct the key and
decrypt the root key.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 24942, line 32** of `S125.body`.

**2b. The threshold is per node; partial unsealing is not shared across the cluster.**

> "each node must be unsealed with the required threshold of shares. Partial unsealing of each node is not distributed across the cluster."
— §Unsealing (22 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'each node must be unsealed with the required threshold of shares. Partial unsealing of each node is not distributed across the cluster.'
grep -c -F 'unsealed with the required threshold of shares. Partial unsealing of each node
is not distributed across the cluster.' .ufo/waves/round-61/capture/S125.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 25670, line 41** of `S125.body`.

**2c. What the unseal progress counter means: NOT STATED on S125.** The concept page never
writes the word "progress" and never names a progress field, a `required=N`, a `complete=true`
or an `n=`/`t=` seal-status shape:
```
grep -c -iE 'progress|required=|complete=|seal-status' .ufo/waves/round-61/capture/S125.body   # => 0
```
The page's only statement about *what accumulates* is 2a: shares are added one at a time until
enough are present. The **nonce** semantics are likewise NOT STATED on S125 (`grep -c -i nonce`
⇒ 0); the nonce is documented on S126 and S127 instead (M3.5, M4.6):

> "Nonce value provided at initialization. The same nonce value must be provided with each unseal key."
— §Command options (S126 and S127, identical wording) (16 words)

Resolve (S126):
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key.'
grep -c -F 'Nonce value provided at initialization. The same
nonce value must be provided with each unseal key.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 39274, line 72** of `S126.body` (S127 has the same sentence at byte
34359, line 69).

**2d. Whether a repeated share counts: NOT STATED on S125.** No sentence on the page says what
happens when the *same* share is offered twice; the words "duplicate", "repeat", "already" and
"twice" do not occur on the page at all:
```
grep -c -iE 'duplicate|repeat|already|twice' .ufo/waves/round-61/capture/S125.body   # => 0
```
The only adjacent statement is 2a ("added one at a time … until enough shares are present"),
which does not decide the duplicate case. **A trial that submits the same share twice and
measures whether the progress counter moves is measuring behaviour the docs do not state — it
must not be cited to S125.**

---

## 2. S126 — `https://openbao.org/docs/commands/operator/rekey/` (`operator rekey` command page)

Body: `.ufo/waves/round-61/capture/S126.body`, 44328 B, sha256
`53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a`.

Section headings on this page: `Examples` (`examples`), `Usage` (`usage`), `Output options`
(`output-options`), `Command options` (`command-options`), `Backup options` (`backup-options`),
plus the `warning` admonition at the top of the page (the deprecation note).

### 2.1 Mechanic 3 — the documented `operator rekey` command shape, its `-init`/`-nonce`/`-verify`
flags, and any stated backend or seal restriction

**3a. The command is documented but deprecated.**

> "operator rekey command is deprecated, please use rotate-keys instead."
— §warning Note (top of page) (9 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body 'operator rekey command is deprecated, please use rotate-keys instead.'
grep -c -F 'command is deprecated, please use' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `command is deprecated, please use` at **byte 29121, line 13** of `S126.body`.

**3b. The command shape: it generates a new set of unseal keys and can change share count and
threshold.**

> "The operator rekey command generates a new set of unseal keys."
— §operator rekey (page intro) (11 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body 'The operator rekey command generates a new set of unseal keys.'
grep -c -F 'The <code>operator rekey</code> command generates a new set of unseal keys.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 29249, line 14** of `S126.body`.

> "This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of existing unseal keys are provided."
— §operator rekey (page intro) (21 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body 'This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of existing unseal keys are provided.'
grep -c -F 'This operation is zero downtime,
but it requires the OpenBao is unsealed and a quorum of existing unseal keys are
provided.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 29458, line 16** of `S126.body`. This is the page's **only** precondition
sentence: the cluster must be unsealed and a quorum of existing unseal keys supplied. The
documented example shape:

> "Initialize a rekey: $ bao operator rekey \ -init \ -key-shares=15 \ -key-threshold=9"
— §Examples (13 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body 'Initialize a rekey: $ bao operator rekey \\ -init \\-key-shares=15 \\-key-threshold=9'
grep -c -F 'Initialize a rekey:</p>' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `Initialize a rekey:</p>` at **byte 30003, line 23** of `S126.body` (the `<p>Initialize a rekey:</p>`
label that opens the example block; the code block itself follows on the same line).

**3c. `-init` — start a rekey; only one may be in progress.**

> "-init (bool: false) - Initialize the rekeying operation. This can only be done if there's not one in progress."
— §Command options (19 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-init (bool: false) - Initialize the rekeying operation. This can only be done if there'"'"'s not one in progress.'
grep -c -F 'Initialize the rekeying operation. This can only be
done if there'"'"'s not one in progress.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 38527, line 57** of `S126.body`.

**3d. `-nonce` — the nonce given at init must be repeated with every unseal key.**

> "-nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key."
— §Command options (20 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key.'
grep -c -F 'Nonce value provided at initialization. The same
nonce value must be provided with each unseal key.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 39274, line 72** of `S126.body`.

**3e. `-verify` — activates the verification phase, and the nonce given is the verification nonce.**

> "-verify (bool: false) - Indicate during the phase -init that the verification process is activated for the rekey."
— §Command options (18 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-verify (bool: false) - Indicate during the phase -init that the verification process is activated for the rekey.'
grep -c -F 'verification process is activated for the rekey.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 40279, line 91** of `S126.body`. The same section continues: "Along with
-nonce option it indicates that the nonce given is for the verification process." The documented
verification invocation is:
> "Perform the verification of the rekey using the verification nonce: $ bao operator rekey -verify -nonce=\"...\""
— §Examples (16 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body 'Perform the verification of the rekey using the verification nonce: $ bao operator rekey -verify -nonce="..."'
grep -c -F '$ bao operator rekey -verify -nonce="..."' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 37145, line 40** of `S126.body`.

**3f. The documented share/threshold defaults for a rekey: `-key-shares` 5, `-key-threshold` 3.**

> "-key-shares (int: 5) - Number of key shares to split the generated master key into. This is the number of \"unseal keys\" to generate."
— §Command options (24 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-key-shares (int: 5) - Number of key shares to split the generated master key into. This is the number of "unseal keys" to generate.'
grep -c -F 'Number of key shares to split the generated master
key into. This is the number of "unseal keys" to generate.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 38832, line 62** of `S126.body`.

> "-key-threshold (int: 3) - Number of key shares required to reconstruct the root key. This must be less than or equal to -key-shares."
— §Command options (23 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-key-threshold (int: 3) - Number of key shares required to reconstruct the root key. This must be less than or equal to -key-shares.'
grep -c -F 'Number of key shares required to reconstruct the
root key. This must be less than or equal to -key-shares.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 39056, line 67** of `S126.body`. **These are the `5`/`3` numbers, and they
are on S126, not on S125** — S125 has no `key-shares`/`key-threshold` pair at all (see §1.1).

**3g. The stated *seal* restriction (not a backend restriction): `-target=recovery` only applies
to HSM/Auto-Unseal clusters.**

> "-target (string: \"barrier\") - Target for rekeying. \"recovery\" only applies when HSM support is enabled or using Auto Unseal"
— §Command options (19 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body '-target (string: "barrier") - Target for rekeying. "recovery" only applies when HSM support is enabled or using Auto Unseal'
grep -c -F 'Target for rekeying. "recovery" only applies
when HSM support is enabled or using' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 39999, line 86** of `S126.body`.

**3h. The stated option-level availability restriction: `-backup-retrieve` needs PGP keys and an
undeleted backup.**

> "This option is only available if the PGP keys were provided and the backup has not been deleted."
— §Backup options (18 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S126.body 'This option is only available if the PGP keys were provided and the backup has not been deleted.'
grep -c -F 'option is only available if the PGP keys were provided and the backup has not
been deleted.' .ufo/waves/round-61/capture/S126.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 41312, line 109** of `S126.body`.

**3i. Any stated *backend* restriction on `operator rekey`: NOT STATED on S126.** The page names
no storage backend and no per-backend behaviour. Measured over the captured body:
```
grep -c -iE '\bunsupported\b|not supported|\brefused\b|\bunavailable\b|not available|not implemented|\b405\b' .ufo/waves/round-61/capture/S126.body   # => 0
grep -c -iE '\binmem\b|raft storage|storage backend|file storage' .ufo/waves/round-61/capture/S126.body   # => 0
```
The only two `raft` hits on the page are the sidebar navigation entry and the footer
"Previous raft" link — not a statement about behaviour:

```
grep -o -iE '.{40}raft.{40}' .ufo/waves/round-61/capture/S126.body
```
The page's restrictions are the **seal** restriction (3g) and the **option** restriction (3h),
plus the deprecation (3a) and the unsealed+quorum precondition (3b). **No sentence states that
`operator rekey` is unsupported, refused or unavailable on any backend.** A measured HTTP 405
on a raft or inmem build therefore cannot be sourced to S126 — S126 documents the command as
available, and the divergence is docs-vs-binary, not docs-vs-docs.

---

## 3. S127 — `https://openbao.org/docs/commands/operator/generate-root/` (`operator generate-root` command page)

Body: `.ufo/waves/round-61/capture/S127.body`, 38368 B, sha256
`4adb6eb414a8119225e2b3936b99ffb395966cea347f2964f43cedfbe26459aa`.

Section headings on this page: `Examples` (`examples`), `Usage` (`usage`), `Output options`
(`output-options`), `Command options` (`command-options`), plus the `info` admonition at the top of
the page (the v2.6.0 endpoint note).

### 3.1 Mechanic 4 — generate-root: the OTP role, `required`/`progress`/`complete`, `-decode`, and
what the encoded token is XORed with

**4a. The command combines a quorum of share holders into a new root token.**

> "The operator generate-root command generates a new root token by combining a quorum of share holders."
— §operator generate-root (page intro) (16 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body 'The operator generate-root command generates a new root token by combining a quorum of share holders.'
grep -c -F 'The <code>operator generate-root</code> command generates a new root token by combining a
quorum of share holders.' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 28968, line 11** of `S127.body`.

**4b. The OTP role: a base64 one-time-password is XORed with the returned token, and `-decode`
recovers the final value.**

> "A base64-encoded one-time-password (OTP) provided via the -otp flag. Use the -generate-otp flag to generate a usable value."
— §operator generate-root (page intro) (18 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body 'A base64-encoded one-time-password (OTP) provided via the -otp flag. Use the -generate-otp flag to generate a usable value.'
grep -c -F 'A base64-encoded one-time-password (OTP) provided via the' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 29339, line 17** of `S127.body`.

> "The resulting token is XORed with this value when it is returned."
— §operator generate-root (page intro) (12 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body 'The resulting token is XORed with this value when it is returned.'
grep -c -F 'The resulting token is XORed
with this value when it is returned.' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 29489, line 18** of `S127.body`. **The XOR operand is the OTP value itself**
— the preceding bullet (4b) defines "this value" as the base64-encoded OTP supplied via `-otp`.
The sentence that closes the bullet:

> "Use the -decode flag to output the final value."
— §operator generate-root (page intro) (9 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body 'Use the -decode flag to output the final value.'
grep -c -F 'Use the <code>-decode</code> flag to output the
final value.' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 29555, line 19** of `S127.body`.

**4c. `-decode` — decode and output the generated root token; it requires the OTP used at init.**

> "-decode (string: \"\") - Decode and output the generated root token. This option requires the -otp flag be set to the OTP used during initialization."
— §Command options (25 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body '-decode (string: "") - Decode and output the generated root token. This option requires the -otp flag be set to the OTP used during initialization.'
grep -c -F 'Decode and output the generated root token.' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 33739, line 56** of `S127.body`.

**4d. The OTP generator flag and its documented invocation.**

> "-generate-otp (bool: false) - Generate and print a high-entropy one-time-password (OTP) suitable for use with the \"-init\" flag."
— §Command options (18 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body '-generate-otp (bool: false) - Generate and print a high-entropy one-time-password (OTP) suitable for use with the "-init" flag.'
grep -c -F 'one-time-password (OTP) suitable for use with the "-init" flag.' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 34050, line 62** of `S127.body`.

> "Generate an OTP code for the final token: $ bao operator generate-root -generate-otp"
— §Examples (13 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body 'Generate an OTP code for the final token: $ bao operator generate-root -generate-otp'
grep -c -F '$ bao operator generate-root -generate-otp' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 30719, line 33** of `S127.body`.

**4e. The `required` / `progress` / `complete` status fields: NOT STATED on S127.** The command
page never names those three fields. Measured over the captured body:
```
grep -c -iE '\brequired\b|\bcomplete\b' .ufo/waves/round-61/capture/S127.body   # => 0
grep -c -i 'progress' .ufo/waves/round-61/capture/S127.body   # => 3 (all three are the word in prose, not a status field)
```
The three `progress` hits are prose, not a field name: "Enter an unseal key to progress root
token generation", "-cancel … Reset the root token generation progress", "-init … This can only
be done if there is not currently one in progress." The closest documented statement of the
accumulation mechanic is 4a (a quorum of share holders) and the page's `-nonce` rule (M4.6):

> "-nonce (string: \"\") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key."
— §Command options (20 words)

Resolve:
```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S127.body '-nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key.'
grep -c -F 'Nonce value provided at initialization. The same
nonce value must be provided with each unseal key.' .ufo/waves/round-61/capture/S127.body
```
```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor at **byte 34359, line 69** of `S127.body`.

**4f. The endpoint change the page records (context for the trial's request path).** The `info`
admonition at the top of S127 states that as of v2.6.0 the command uses the new authenticated
`/sys/generate-root-token` endpoint instead of the deprecated unauthenticated
`/sys/generate-root` endpoint. Raw anchor: the `info` admonition block at the head of the
`operator generate-root` body, `grep -c -F '/sys/generate-root-token'` ⇒ 1 in `S127.body`
(byte 28706, line 7).

---

## 4. Mechanic 5 — any sentence stating that a rekey or generate-root operation is unsupported,
refused or unavailable on a backend

**NOT STATED on S126 and NOT STATED on S127.** Neither page contains a sentence saying that
`operator rekey` or `operator generate-root` is unsupported, refused, unavailable or
not-implemented on any backend. Measured over both captured bodies:

```
grep -c -iE '\bunsupported\b|not supported|\brefused\b|\bunavailable\b|not available|not implemented|\b405\b' \
     .ufo/waves/round-61/capture/S126.body   # => 0
grep -c -iE '\bunsupported\b|not supported|\brefused\b|\bunavailable\b|not available|not implemented|\b405\b' \
     .ufo/waves/round-61/capture/S127.body   # => 0
grep -c -iE '\binmem\b|raft storage|storage backend|file storage' \
     .ufo/waves/round-61/capture/S126.body   # => 0
grep -c -iE '\binmem\b|raft storage|storage backend|file storage' \
     .ufo/waves/round-61/capture/S127.body   # => 0
```
The nearest true statements are these, and each is a **seal** or **option** restriction, not a
backend refusal:

| source | quote | resolves at |
|---|---|---|
| S126 §Command options | "-target (string: \"barrier\") - Target for rekeying. \"recovery\" only applies when HSM support is enabled or using Auto Unseal" | byte 39999, line 86 (M3.9) |
| S126 §Backup options | "This option is only available if the PGP keys were provided and the backup has not been deleted." | byte 41312, line 109 (M3.10) |
| S126 page intro | "This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of existing unseal keys are provided." | byte 29458, line 16 (M3.3) |
| S126 warning Note | "operator rekey command is deprecated, please use rotate-keys instead." | byte 29121, line 13 (M3.1) |
| S127 §Command options | "-cancel (bool: false) - Reset the root token generation progress. This will discard any submitted unseal keys or configuration." | byte 33515, line 52 |
| S127 page intro | "A base64-encoded one-time-password (OTP) provided via the -otp flag. Use the -generate-otp flag to generate a usable value." | byte 29339, line 17 (M4.2) |

**Consequence for the round's C2/T5 test.** The plan's T5 asks the trial to observe `operator
rekey` exiting non-zero with HTTP 405 `unsupported operation` on raft and inmem, *"while S126
documents the command — a measured docs-vs-binary divergence, not a citation."* That framing is
exactly what the capture supports: **S126 documents `operator rekey` as a working command with
no backend caveat at all**, so a 405 on a given build is a divergence from the documentation and
cannot be sourced to a doc sentence. The registry row for S126 must therefore be written so it
does *not* claim the docs say rekey is unsupported — they say the opposite.

The same holds for S127: the page documents `operator generate-root` with no backend caveat, and
the only endpoint statement is the v2.6.0 `/sys/generate-root-token` switch (§3.1, 4f).

---

## 5. Reproduction — every quote resolves, every digest matches

Run from the lane root `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

### 5.1 Digests

```
sha256sum .ufo/waves/round-61/capture/S125.body .ufo/waves/round-61/capture/S126.body .ufo/waves/round-61/capture/S127.body
```
```
643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65  .ufo/waves/round-61/capture/S125.body
53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a  .ufo/waves/round-61/capture/S126.body
4adb6eb414a8119225e2b3936b99ffb395966cea347f2964f43cedfbe26459aa  .ufo/waves/round-61/capture/S127.body
```

### 5.2 Bodies are byte-identical to the scratch copies that were fetched

```
cmp /fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/S125.body .ufo/waves/round-61/capture/S125.body && echo S125-identical
cmp /fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/S126.body .ufo/waves/round-61/capture/S126.body && echo S126-identical
cmp /fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/S127.body .ufo/waves/round-61/capture/S127.body && echo S127-identical
```

### 5.3 Every quoted phrase resolves verbatim in its body

The table below is the seat's own resolution ledger: one row per quote (34 rows), with the command that
resolves it and the observed result. `grep -c -F` counts **raw-literal** occurrences in the
captured bytes; `rendered-text-v1.py locate` counts occurrences in the lane's normalized text
of the same bytes. Both are 1 for every row.

| id | body | quote (words) | raw anchor | bytes | line | grep -c -F | rendered locate |
|---|---|---|---|---|---|---|---|
| M1.1 | S125 | A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key. (21) | `A certain threshold of shares is required to
reconstruct the unseal key, which is then …` | 24781 | 30 | 1 | 1 |
| M1.2 | S125 | OpenBao uses an algorithm known as Shamir's Secret Sharing to split the key into shares. (15) | `to split the key into shares.` | 24751 | 30 | 1 | 1 |
| M1.3 | S125 | This allows each share of the root key to be on a distinct client machine for better security. (18) | `key to be on a distinct client machine for better security.` | 25527 | 39 | 1 | 1 |
| M1.4 | S125 | When an OpenBao server is started, it starts in a sealed state. (12) | `When an OpenBao server is started, it starts in a` | 22528 | 5 | 1 | 1 |
| M1.5 | S125 | The only possible operations are to unseal the OpenBao and check the status of the seal. (16) | `The only possible operations are to unseal the OpenBao and check the status` | 23059 | 12 | 1 | 1 |
| M1.6 | S125 | Once an OpenBao node is unsealed, it remains unsealed until one of these things happens: (15) | `Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:` | 25795 | 43 | 1 | 1 |
| M1.7 | S125 | It is resealed via the API (see below). (8) | `It is resealed via the API (see below).` | 25910 | 46 | 1 | 1 |
| M1.8 | S125 | The server is restarted. (4) | `The server is restarted.` | 25977 | 49 | 1 | 1 |
| M1.9 | S125 | This will throw away the root key in memory and require another unseal process to restore it. (17) | `key in memory and require another unseal process to restore it.` | 27392 | 64 | 1 | 1 |
| M1.10 | S125 | Sealing only requires a single operator with root privileges. (9) | `only requires a single operator with root privileges.` | 27464 | 65 | 1 | 1 |
| M1.11 | S125 | It can't be accessed again without access to the root key shares. (12) | `access to the root key shares.` | 27671 | 68 | 1 | 1 |
| M2.1 | S125 | the shares are added one at a time (in any order) until enough shares are present to reconstruct the key and decrypt the root key. (25) | `the shares are added one at a time (in any
order) until enough shares are present to re…` | 24942 | 32 | 1 | 1 |
| M2.2 | S125 | each node must be unsealed with the required threshold of shares. Partial unsealing of each node is not distributed across the cluster. (22) | `unsealed with the required threshold of shares. Partial unsealing of each node
is not d…` | 25670 | 41 | 1 | 1 |
| M2.3 | S125 | This process is stateful: each key can be entered via multiple mechanisms from multiple client machines and it will work. (20) | `This process is stateful: each key can be entered via multiple mechanisms from
multiple…` | 25370 | 37 | 1 | 1 |
| M3.1 | S126 | operator rekey command is deprecated, please use rotate-keys instead. (9) | `command is deprecated, please use` | 29121 | 13 | 1 | 1 |
| M3.2 | S126 | The operator rekey command generates a new set of unseal keys. (11) | `The <code>operator rekey</code> command generates a new set of unseal keys.` | 29249 | 14 | 1 | 1 |
| M3.3 | S126 | This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of existing unseal keys are provided. (21) | `This operation is zero downtime,
but it requires the OpenBao is unsealed and a quorum o…` | 29458 | 16 | 1 | 1 |
| M3.4 | S126 | -init (bool: false) - Initialize the rekeying operation. This can only be done if there's not one in progress. (19) | `Initialize the rekeying operation. This can only be
done if there's not one in progress.` | 38527 | 57 | 1 | 1 |
| M3.5 | S126 | -nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key. (20) | `Nonce value provided at initialization. The same
nonce value must be provided with each…` | 39274 | 72 | 1 | 1 |
| M3.6 | S126 | -verify (bool: false) - Indicate during the phase -init that the verification process is activated for the rekey. (18) | `verification process is activated for the rekey.` | 40279 | 91 | 1 | 1 |
| M3.7 | S126 | -key-shares (int: 5) - Number of key shares to split the generated master key into. This is the number of "unseal keys" to generate. (24) | `Number of key shares to split the generated master
key into. This is the number of "uns…` | 38832 | 62 | 1 | 1 |
| M3.8 | S126 | -key-threshold (int: 3) - Number of key shares required to reconstruct the root key. This must be less than or equal to -key-shares. (23) | `Number of key shares required to reconstruct the
root key. This must be less than or eq…` | 39056 | 67 | 1 | 1 |
| M3.9 | S126 | -target (string: "barrier") - Target for rekeying. "recovery" only applies when HSM support is enabled or using Auto Unseal (19) | `Target for rekeying. "recovery" only applies
when HSM support is enabled or using` | 39999 | 86 | 1 | 1 |
| M3.10 | S126 | This option is only available if the PGP keys were provided and the backup has not been deleted. (18) | `option is only available if the PGP keys were provided and the backup has not
been dele…` | 41312 | 109 | 1 | 1 |
| M3.11 | S126 | Initialize a rekey: $ bao operator rekey \ -init \ -key-shares=15 \ -key-threshold=9 (13) | `Initialize a rekey:</p>` | 30003 | 23 | 1 | 1 |
| M3.12 | S126 | Perform the verification of the rekey using the verification nonce: $ bao operator rekey -verify -nonce="..." (16) | `$ bao operator rekey -verify -nonce="..."` | 37145 | 40 | 1 | 1 |
| M4.1 | S127 | The operator generate-root command generates a new root token by combining a quorum of share holders. (16) | `The <code>operator generate-root</code> command generates a new root token by combining…` | 28968 | 11 | 1 | 1 |
| M4.2 | S127 | A base64-encoded one-time-password (OTP) provided via the -otp flag. Use the -generate-otp flag to generate a usable value. (18) | `A base64-encoded one-time-password (OTP) provided via the` | 29339 | 17 | 1 | 1 |
| M4.3 | S127 | The resulting token is XORed with this value when it is returned. (12) | `The resulting token is XORed
with this value when it is returned.` | 29489 | 18 | 1 | 1 |
| M4.4 | S127 | Use the -decode flag to output the final value. (9) | `Use the <code>-decode</code> flag to output the
final value.` | 29555 | 19 | 1 | 1 |
| M4.5 | S127 | -decode (string: "") - Decode and output the generated root token. This option requires the -otp flag be set to the OTP used during initialization. (25) | `Decode and output the generated root token.` | 33739 | 56 | 1 | 1 |
| M4.6 | S127 | -nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key. (20) | `Nonce value provided at initialization. The same
nonce value must be provided with each…` | 34359 | 69 | 1 | 1 |
| M4.7 | S127 | -generate-otp (bool: false) - Generate and print a high-entropy one-time-password (OTP) suitable for use with the "-init" flag. (18) | `one-time-password (OTP) suitable for use with the "-init" flag.` | 34050 | 62 | 1 | 1 |
| M4.8 | S127 | Generate an OTP code for the final token: $ bao operator generate-root -generate-otp (13) | `$ bao operator generate-root -generate-otp` | 30719 | 33 | 1 | 1 |

Machine-checked form (one loop over all rows):

```
python3 - <<'PY'
import re, subprocess
rows = [ ... the 34 rows of the table above, as (id, body_path, quote, anchor) ... ]
bad = 0
for qid, path, quote, anchor in rows:
    body = open(path,'rb').read()
    n_raw = body.count(anchor.encode())
    n_loc = subprocess.run(['python3','corpus/rendered-text-v1.py','locate',path,quote],
                        capture_output=True,text=True).stdout.strip()
    ok = (n_raw == 1 and n_loc == 'RENDERED_TEXT_V1_LOCATE: count=1')
    if not ok: bad += 1; print('MISMATCH', qid, n_raw, n_loc)
print('QUOTE_RESOLUTION: rows=%d mismatches=%d' % (len(rows), bad))
PY
```
Observed: `QUOTE_RESOLUTION: rows=34 mismatches=0`.

### 5.4 The lane normalizer's own selftest

```
python3 corpus/rendered-text-v1.py --selftest
```
```
RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)
```

---

## 6. Coverage summary for the registry rows and the lesson Gate

| mechanic | source | status | where |
|---|---|---|---|
| 1 — Shamir shares, threshold, custody, state machine | S125 | LOCATED (9 quotes) | §1.1 |
| 1 — share count / threshold numbers (5 / 3) | S125 | **NOT STATED** (numbers live on S126) | §1.1 |
| 1 — are the shares stored by the server | S125 | **NOT STATED** | §1.1 (1d) |
| 2 — unseal progress counter meaning | S125 | **NOT STATED** | §1.2 (2c) |
| 2 — the nonce | S125 | **NOT STATED** (stated on S126/S127) | §1.2 (2c) |
| 2 — does a repeated share count | S125 | **NOT STATED** | §1.2 (2d) |
| 3 — `operator rekey` command shape | S126 | LOCATED | §2.1 (3b) |
| 3 — `-init` | S126 | LOCATED | §2.1 (3c) |
| 3 — `-nonce` | S126 | LOCATED | §2.1 (3d) |
| 3 — `-verify` | S126 | LOCATED | §2.1 (3e) |
| 3 — stated seal restriction | S126 | LOCATED (`-target=recovery` ⇒ HSM/Auto Unseal) | §2.1 (3g) |
| 3 — stated backend restriction | S126 | **NOT STATED** | §2.1 (3i) |
| 4 — OTP role | S127 | LOCATED | §3.1 (4b) |
| 4 — what the encoded token is XORed with | S127 | LOCATED (the OTP value) | §3.1 (4b) |
| 4 — `-decode` | S127 | LOCATED | §3.1 (4c) |
| 4 — `required` / `progress` / `complete` fields | S127 | **NOT STATED** | §3.1 (4e) |
| 5 — rekey/generate-root unsupported or refused on a backend | S126 / S127 | **NOT STATED** on both | §4 |

**Direct answer to mechanic 5.** No sentence on S126 or S127 states that `operator rekey` or
`operator generate-root` is unsupported, refused or unavailable on a backend. S126 documents
rekey as a normal, zero-downtime command requiring an unsealed cluster and a quorum of unseal
keys; its only restrictions are the seal restriction (`-target=recovery` ⇒ HSM/Auto Unseal), the
option restriction (`-backup-retrieve` ⇒ PGP keys + undeleted backup), and a deprecation notice.
S127 documents generate-root with no restriction beyond the OTP requirement and the v2.6.0
endpoint switch.

**What this seat does NOT assert.** No claim is made about what the OpenBao 2.7.2 binary
actually does on raft or inmem — that is the executor/trial seats' measured job (the plan's
T1–T5). This seat only establishes what the three documentation pages do and do not say.
In particular: **S125 alone cannot support `t=3 n=5`**, **no page supports a claim that a
repeated share is refused**, and **no page supports a claim that rekey is unsupported on a
backend** — the last is exactly the docs-vs-binary divergence C2/T5 is meant to measure.

---

## 7. Bounds of this seat

* Files written by this seat, and only these:
  `.ufo/waves/round-61/capture/S125.body`, `…/S126.body`, `…/S127.body`,
  `.ufo/waves/round-61/capture/notes.md` (this file),
  `.ufo/waves/round-61/build/R61ScoutSealDocs/` (receipts),
  `.ufo/waves/round-61/w1/R61ScoutSealDocs.md` (the seat report).
* No edit to `corpus/SOURCES.md`, `corpus/lessons/*`, `corpus/knowledge/*`, `SKILL.md`,
  `SCORECARD.md`, `LOG.md` or any `plans/*` file — the L1 owns those.
* No git/jj mutation of any kind was run in the lane, in a sibling lane or in the fleet repo;
  the lane's index was never touched. Nothing was committed or pushed by this seat.
* Scratch (`/fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/`: the raw-header files, the fetched
  bodies, the scratch copies of the rendered text) is deleted before the seat yields.
* No secret value, cookie, session id, OTP, key share or root token appears in any file this
  seat wrote; the captures are public documentation HTML.
* No tool was installed or upgraded by this seat (curl and python3 were already present), so
  there is no tool/version/channel/reason row to report beyond the versions actually used:
  `curl` and `python3` as shipped on the host, used only to fetch and normalize public pages.