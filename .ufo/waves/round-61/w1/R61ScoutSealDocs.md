# R61ScoutSealDocs — round 61 wave 1 (scout): seal / seal-key documentation capture, located quotes

Seat: `R61ScoutSealDocs` (scout). Round 61, attempt 1, wave 1, v1 (16 seats, §Wave plan).
Lane: `kagi-shokunin`. Scope: open the three seal / seal-key documentation sources this
round declares, live, and produce the located-quote evidence the registry rows (S125/S126/S127)
and the lesson `## Gate` need. Non-goals (not done): no edit to `corpus/SOURCES.md`, no
trial design, no `corpus/lessons/*` edit, no plan/instrument edit, no git/jj mutation.

## 1. What I produced

| path | what |
|---|---|
| `.ufo/waves/round-61/capture/S125.body` | decoded HTTP body of `https://openbao.org/docs/concepts/seal/`, 44279 B, sha256 `643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65` |
| `.ufo/waves/round-61/capture/S126.body` | decoded HTTP body of `https://openbao.org/docs/commands/operator/rekey/`, 44328 B, sha256 `53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a` |
| `.ufo/waves/round-61/capture/S127.body` | decoded HTTP body of `https://openbao.org/docs/commands/operator/generate-root/`, 38368 B, sha256 `4adb6eb414a8119225e2b3936b99ffb395966cea347f2964f43cedfbe26459aa` |
| `.ufo/waves/round-61/capture/notes.md` | the located-quote evidence: one section per source, the five mechanics, byte offsets + line numbers + the resolving command for every quote, and the NOT STATED ledger (990 lines) |
| `.ufo/waves/round-61/build/R61ScoutSealDocs/fetch-record.txt` | HTTP status, final URL, wire bytes, body bytes, sha256, fetch command, access date, UA for each source |
| `.ufo/waves/round-61/build/R61ScoutSealDocs/digest.txt` | `sha256sum` + `wc -c` receipt over the three lane bodies |
| `.ufo/waves/round-61/build/R61ScoutSealDocs/cookie-hygiene.txt` | the cookie-hygiene receipt (QM72) |
| `.ufo/waves/round-61/build/R61ScoutSealDocs/verify_quotes.py` | end-to-end quote checker (34 rows) |
| `.ufo/waves/round-61/build/R61ScoutSealDocs/quote-resolution.txt` | its receipt: `QUOTE_RESOLUTION: rows=34 mismatches=0`, plus the 12 NOT-STATED negative measurements |

## 2. Fetch record

```
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
curl -fsSL --compressed -A "$UA" -D <sid>.rawheaders -o <sid>.body \
     -w '%{http_code} %{url_effective} %{size_download}\n' "<url>"
```

| id | url | status | final_url | wire B (gzip) | decoded B | sha256 | access date |
|---|---|---|---|---|---|---|---|
| S125 | `https://openbao.org/docs/concepts/seal/` | 200 | unchanged (no redirect) | 11421 | 44279 | `643c78c9…3ff65` | 2026-11-07 |
| S126 | `https://openbao.org/docs/commands/operator/rekey/` | 200 | unchanged (no redirect) | 8434 | 44328 | `53a4574a…630a` | 2026-11-07 |
| S127 | `https://openbao.org/docs/commands/operator/generate-root/` | 200 | unchanged (no redirect) | 7893 | 38368 | `4adb6eb4…459aa` | 2026-11-07 |

* User agent string (verbatim): `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36`.
* Request profile is `curl -fsSL --compressed` **with that desktop browser UA** — the
  representation is the lane's `decoded-http-body-v1` (Content-Encoding removed by curl),
  so the digest/byte-count columns are comparable with the S120–S124 rows.
* Access date 2026-11-07; the server `date:` header on all three responses is
  `Sat, 07 Nov 2026 19:50:51 GMT`.
* **No cookie was present to remove**: no response carries a `set-cookie:` or `cookie:`
  header (`grep -in cookie` over the three raw header files ⇒ 0 matches, exit 1). Nothing in
  any written file is a cookie, session id, OTP, key share or root token.
* **Pages opened: exactly these three.** No fourth URL was fetched this round.
* All three pages are `docs-version-2.7.x` (sidebar reads `Version: Version 2.7.x`),
  matching the plan's "OpenBao docs 2.7.x".

## 3. The five mechanics — where each is documented, and the located quote

Each quote is ≤ 25 words and resolves **in the captured body**, with the resolving command
shown. Two locator families, both against the captured `.body` bytes:

* **raw-literal** — the anchor is a literal byte substring of the body; resolved with
  `grep -c -F '<anchor>' <body>`; byte offset and line given.
* **rendered-v1** — the quoted prose is resolved with the lane's own committed normalizer
  `python3 corpus/rendered-text-v1.py locate <body> '<quote>'` (reads only the named file,
  no network, no writes), **plus** a raw-literal anchor that *is* a byte substring of the
  same body with its byte offset and line, so the quote's position is verifiable without
  normalizing.

Full detail — every command, every offset, the resolution ledger and the NOT STATED
measurements — is in `.ufo/waves/round-61/capture/notes.md`. Summary:

| mechanic | source | status | notes.md |
|---|---|---|---|
| **M1** Shamir shares, threshold, custody, seal/unseal state machine | S125 | LOCATED (9 quotes) | §1.1 |
| **M1** the share count / threshold numbers (`5` / `3`) | S125 | **NOT STATED** | §1.1 |
| **M1** whether the server stores the shares | S125 | **NOT STATED** | §1.1 (1d) |
| **M2** what the unseal progress counter means | S125 | **NOT STATED** | §1.2 (2c) |
| **M2** the nonce | S125 | **NOT STATED** (stated on S126/S127) | §1.2 (2c) |
| **M2** whether a repeated share counts | S125 | **NOT STATED** | §1.2 (2d) |
| **M3** `operator rekey` command shape | S126 | LOCATED | §2.1 (3b) |
| **M3** `-init` / `-nonce` / `-verify` | S126 | LOCATED (all three) | §2.1 (3c–3e) |
| **M3** stated **seal** restriction | S126 | LOCATED (`-target=recovery` ⇒ HSM/Auto Unseal) | §2.1 (3g) |
| **M3** stated **backend** restriction | S126 | **NOT STATED** | §2.1 (3i) |
| **M4** OTP role | S127 | LOCATED | §3.1 (4b) |
| **M4** what the encoded token is XORed with | S127 | LOCATED (the OTP value itself) | §3.1 (4b) |
| **M4** `-decode` | S127 | LOCATED | §3.1 (4c) |
| **M4** `required` / `progress` / `complete` fields | S127 | **NOT STATED** | §3.1 (4e) |
| **M5** rekey / generate-root unsupported, refused or unavailable on a backend | S126 + S127 | **NOT STATED** on both | §4 |

### M1 — Shamir shares, threshold, custody, seal/unseal state machine (S125)

* "A certain threshold of shares is required to reconstruct the unseal key, which is then
  used to decrypt the root key." — §Shamir seals (21 words); raw anchor at **S125 byte
  24781, line 30**.
* "OpenBao uses an algorithm known as Shamir's Secret Sharing to split the key into shares."
  — §Shamir seals (15 words); raw anchor at **S125 byte 24751, line 30**.
* "This allows each share of the root key to be on a distinct client machine for better
  security." — §Unsealing (18 words); raw anchor at **S125 byte 25527, line 39**.
* "When an OpenBao server is started, it starts in a sealed state." — §Seal/Unseal intro
  (12 words); raw anchor at **S125 byte 22528, line 5**.
* "The only possible operations are to unseal the OpenBao and check the status of the seal."
  — §Seal/Unseal intro (16 words); raw anchor at **S125 byte 23059, line 12**.
* "Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:"
  — §Unsealing (15 words); raw anchor at **S125 byte 25795, line 43**; the three exits are
  "It is resealed via the API (see below)." (**byte 25910, line 46**), "The server is
  restarted." (**byte 25977, line 49**) and "OpenBao's storage layer encounters an
  unrecoverable error." (raw anchor at **S125 byte 26029, line 52**).
* "This will throw away the root key in memory and require another unseal process to
  restore it." — §Sealing (17 words); raw anchor at **S125 byte 27392, line 64**.
* "Sealing only requires a single operator with root privileges." — §Sealing (9 words);
  raw anchor at **S125 byte 27464, line 65**.
* "It can't be accessed again without access to the root key shares." — §Sealing (12 words);
  raw anchor at **S125 byte 27671, line 68**.

**NOT STATED on S125 (measured, not inferred):**

* *the share count and threshold* — S125 writes no `key-shares`/`key-threshold` pair at all
  (`grep -c -E 'key-shares|key-threshold'` ⇒ **0**). It names only `recovery-shares` /
  `recovery-threshold`, and only for the **auto-unseal** recovery key under
  §Initialization (`grep -c -E 'recovery-shares|recovery-threshold'` ⇒ **2**).
  **S125 alone cannot support the trial's `t=3 n=5`.** The `5`/`3` defaults are documented
  on **S126** (see below) — that is where the numbers must be cited from.
* *whether the server stores the shares* — `grep -c -iE 'not stored|never stored|stored on
  disk|persist'` ⇒ **0**. The page says nothing about persisting the Shamir unseal shares;
  its `stored` hits are about data, the keyring and the root key.

### M2 — unseal progress/nonce, and whether a repeated share counts (S125)

* "This process is stateful: each key can be entered via multiple mechanisms from multiple
  client machines and it will work." — §Unsealing (20 words); raw anchor at **S125 byte
  25370, line 37**.
* "the shares are added one at a time (in any order) until enough shares are present to
  reconstruct the key and decrypt the root key." — §Shamir seals (25 words); raw anchor at
  **S125 byte 24942, line 32**.
* "each node must be unsealed with the required threshold of shares. Partial unsealing of
  each node is not distributed across the cluster." — §Unsealing (22 words); raw anchor at
  **S125 byte 25670, line 41**.

**NOT STATED on S125:**

* *the unseal progress counter* — `grep -c -iE 'progress|required=|complete=|seal-status'`
  ⇒ **0**. The page never names a progress field, a `required=N`, a `complete=true` or an
  `n=`/`t=` seal-status shape.
* *the nonce* — `grep -c -i nonce` ⇒ **0** on S125. The nonce is documented on **S126** and
  **S127** instead: "Nonce value provided at initialization. The same nonce value must be
  provided with each unseal key." — §Command options (16 words); raw anchor at **S126 byte
  39274, line 72** (S127 has the same sentence at byte 34359, line 69).
* *whether a repeated share counts* — `grep -c -iE 'duplicate|repeat|already|twice'` ⇒
  **0** on S125. No sentence decides the duplicate case; the closest is "added one at a time
  … until enough shares are present", which does not say a repeat is refused.
  **A trial that submits the same share twice and measures whether the counter moves is
  measuring behaviour the docs do not state — it must not be cited to S125.**

### M3 — the `operator rekey` command shape, its flags and its stated restrictions (S126)

* "The operator rekey command generates a new set of unseal keys." — page intro (11 words);
  raw anchor at **S126 byte 29249, line 14**.
* "This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of
  existing unseal keys are provided." — page intro (21 words); raw anchor at **S126 byte
  29458, line 16**. This is the page's **only** precondition sentence.
* "Initialize a rekey: $ bao operator rekey \ -init \ -key-shares=15 \ -key-threshold=9" —
  §Examples (13 words); raw anchor at **S126 byte 30003, line 23**.
* "-init (bool: false) - Initialize the rekeying operation. This can only be done if
  there's not one in progress." — §Command options (19 words); raw anchor at **S126 byte
  38527, line 57**.
* "-nonce (string: \"\") - Nonce value provided at initialization. The same nonce value must
  be provided with each unseal key." — §Command options (20 words); raw anchor at **S126
  byte 39274, line 72**.
* "-verify (bool: false) - Indicate during the phase -init that the verification process is
  activated for the rekey." — §Command options (18 words); raw anchor at **S126 byte 40279,
  line 91**. The same section adds: "Along with -nonce option it indicates that the nonce
  given is for the verification process."
* "Perform the verification of the rekey using the verification nonce: $ bao operator rekey
  -verify -nonce=\"...\"" — §Examples (16 words); raw anchor at **S126 byte 37145, line 40**.
* "-key-shares (int: 5) - Number of key shares to split the generated master key into. This
  is the number of \"unseal keys\" to generate." — §Command options (24 words); raw anchor at
  **S126 byte 38832, line 62**.
* "-key-threshold (int: 3) - Number of key shares required to reconstruct the root key. This
  must be less than or equal to -key-shares." — §Command options (23 words); raw anchor at
  **S126 byte 39056, line 67**. **These are the `5`/`3` numbers, and they are on S126, not
  S125.**
* "-target (string: \"barrier\") - Target for rekeying. \"recovery\" only applies when HSM
  support is enabled or using Auto Unseal" — §Command options (19 words); raw anchor at
  **S126 byte 39999, line 86**. This is the stated **seal** restriction.
* "This option is only available if the PGP keys were provided and the backup has not been
  deleted." — §Backup options (18 words); raw anchor at **S126 byte 41312, line 109**. The
  stated **option** restriction.
* "operator rekey command is deprecated, please use rotate-keys instead." — §warning Note
  (9 words); raw anchor at **S126 byte 29121, line 13**.

**NOT STATED on S126:**

* *any backend restriction* — `grep -c -iE '\bunsupported\b|not supported|\brefused\b|
  \bunavailable\b|not available|not implemented|\b405\b'` ⇒ **0**, and
  `grep -c -iE '\binmem\b|raft storage|storage backend|file storage'` ⇒ **0**. The page's
  only two `raft` hits are the sidebar navigation entry and the footer "Previous raft"
  link — neither is a statement about behaviour. The page documents `operator rekey` as a
  working command with **no backend caveat at all**.

### M4 — generate-root: OTP, `required`/`progress`/`complete`, `-decode`, the XOR (S127)

* "The operator generate-root command generates a new root token by combining a quorum of
  share holders." — page intro (16 words); raw anchor at **S127 byte 28968, line 11**.
* "A base64-encoded one-time-password (OTP) provided via the -otp flag. Use the
  -generate-otp flag to generate a usable value." — page intro (18 words); raw anchor at
  **S127 byte 29339, line 17**.
* "The resulting token is XORed with this value when it is returned." — page intro (12
  words); raw anchor at **S127 byte 29489, line 18**. **The XOR operand is the OTP value
  itself** — the preceding bullet defines "this value" as the base64-encoded OTP supplied
  via `-otp`.
* "Use the -decode flag to output the final value." — page intro (9 words); raw anchor at
  **S127 byte 29555, line 19**.
* "-decode (string: \"\") - Decode and output the generated root token. This option requires
  the -otp flag be set to the OTP used during initialization." — §Command options (25
  words); raw anchor at **S127 byte 33739, line 56**.
* "-generate-otp (bool: false) - Generate and print a high-entropy one-time-password (OTP)
  suitable for use with the \"-init\" flag." — §Command options (18 words); raw anchor at
  **S127 byte 34050, line 62**.
* "Generate an OTP code for the final token: $ bao operator generate-root -generate-otp" —
  §Examples (13 words); raw anchor at **S127 byte 30719, line 33**.
* "-nonce (string: \"\") - Nonce value provided at initialization. The same nonce value must
  be provided with each unseal key." — §Command options (20 words); raw anchor at **S127
  byte 34359, line 69**.

**NOT STATED on S127:**

* *the `required` / `progress` / `complete` status fields* — `grep -c -iE '\brequired\b|
  \bcomplete\b'` ⇒ **0**. The three `progress` hits (`grep -c -i progress` ⇒ **3**) are the
  English word in prose ("Enter an unseal key to progress root token generation", "-cancel
  … Reset the root token generation progress", "-init … one in progress"), not a status
  field name.
* Context the page does record: as of v2.6.0 the command uses the new authenticated
  `/sys/generate-root-token` endpoint instead of the deprecated unauthenticated
  `/sys/generate-root` endpoint — raw literal `/sys/generate-root-token` at **S127 byte
  28706, line 7** (`grep -c -F` ⇒ 1).

### M5 — any sentence stating a rekey or generate-root operation is unsupported, refused or unavailable on a backend

**NOT STATED on S126 and NOT STATED on S127.** Neither page contains a sentence saying the
operation is unsupported, refused, unavailable or not-implemented on any backend.
Measured over both captured bodies (word-bounded so asset-filename substrings cannot
false-positive):

```
S126  \bunsupported\b|not supported|\brefused\b|\bunavailable\b|not available|not implemented|\b405\b   => 0
S126  \binmem\b|raft storage|storage backend|file storage                                                => 0
S127  \bunsupported\b|not supported|\brefused\b|\bunavailable\b|not available|not implemented|\b405\b   => 0
S127  \binmem\b|raft storage|storage backend|file storage                                                => 0
```

The nearest true statements are the **seal** restriction (`-target=recovery` ⇒ HSM/Auto
Unseal), the **option** restriction (`-backup-retrieve` ⇒ PGP keys + undeleted backup) and
the deprecation notice — none of them is a backend refusal.

## 4. Consequences for C2's T1–T5 (named to the L1; no frozen item changed)

* **T1 (`t=3 n=5`, share custody).** The `5`/`3` numbers are documented on **S126**
  (`-key-shares (int: 5)`, `-key-threshold (int: 3)`), **not** on S125. The claim that the
  server does not persist the shares is **not documented anywhere** on S125/S126/S127 —
  it is a custody property the trial must *measure* on the storage path.
* **T2 (duplicate share).** Whether a repeated share counts is **NOT STATED** on all three
  pages. The trial's refusal leg must be reported as a measurement, not a citation.
* **T3 (seal).** S125 supports the state machine qualitatively: sealed at start, unseal
  yields the root key, seal discards it from memory and needs another unseal, one operator
  with root privileges suffices. The HTTP 503-while-sealed shape is **not** documented on
  S125 (no status codes on the page) — measure it.
* **T4 (generate-root).** S127 supports the OTP role, the XOR-with-the-OTP and `-decode`.
  The `required=3` / `progress` / `complete=true` field names are **NOT STATED** — the
  trial's expectations there are measurements of the CLI output, not doc citations.
* **T5 (rekey refused).** This is the sharpest one: **S126 documents `operator rekey` as a
  working command with no backend caveat whatsoever.** A measured HTTP 405 `unsupported
  operation` on a raft or inmem build is therefore a **docs-vs-binary divergence, and it
  cannot be sourced to a doc sentence** — the docs say the opposite. The registry row for
  S126 must not be written as if the docs said rekey is unsupported on a backend.

## 5. Verification I ran

```
sha256sum .ufo/waves/round-61/capture/S125.body .ufo/waves/round-61/capture/S126.body .ufo/waves/round-61/capture/S127.body
wc -c    .ufo/waves/round-61/capture/S125.body .ufo/waves/round-61/capture/S126.body .ufo/waves/round-61/capture/S127.body
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-61/capture/S125.body 'A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key.'
grep -c -F 'A certain threshold of shares is required to' .ufo/waves/round-61/capture/S125.body
python3 .ufo/waves/round-61/build/R61ScoutSealDocs/verify_quotes.py
python3 corpus/rendered-text-v1.py --selftest
cmp /fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/S125.body .ufo/waves/round-61/capture/S125.body
```

Results:

* the three `sha256sum` values equal the ones recorded in `notes.md` and in
  `build/R61ScoutSealDocs/digest.txt`; the byte counts are 44279 / 44328 / 38368;
* the locator prints `RENDERED_TEXT_V1_LOCATE: count=1`; the `grep -c -F` prints `1`;
* the seat's checker prints `QUOTE_RESOLUTION: rows=34 mismatches=0` (exit 0) — every one of
  the 34 quotes resolves **both** as a raw-literal byte substring (count 1) **and** through
  the lane's normalizer (`count=1`);
* the lane normalizer's own selftest prints `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`;
* the three lane bodies are byte-identical to the scratch copies that were fetched (`cmp`
  clean);
* every byte offset and line number stated in `notes.md` was re-measured against the
  captured bodies — **42 "byte N, line M" claims, 0 mismatches** (each claimed offset lands
  exactly on that line boundary in the body it names);
* all 12 NOT-STATED negative measurements were re-run against the captured body bytes and
  all 12 returned the expected count (receipt:
  `build/R61ScoutSealDocs/quote-resolution.txt`).

## 6. Secret discipline

* No secret value, unseal key, root token, OTP, cookie, session id or vault/item/field
  name was written by this seat. The captured bodies are public documentation HTML; the
  notes contain only documentation prose, byte offsets, line numbers and counts.
* No Set-Cookie/Cookie value existed to redact (0 occurrences across the three raw header
  files).
* Scratch (`/fast/scratch/hyaku/kagi-r61/R61ScoutSealDocs/`) deleted before yield; no
  citable evidence was written under `/tmp`.

## 7. Tools

No tool was installed, upgraded or removed by this seat — the work needed only `curl`,
`python3` and the lane's committed `corpus/rendered-text-v1.py`, all already present. No
pacman / uv / cargo / npm transaction; nothing to record on the tooling channel.

## 8. Notes for the L1 (no frozen item changed)

* Registry rows S125/S126/S127 can now be written from `notes.md`, each with the located
  quote (≤ 25 words, quote-cell bound holds for every one of the 34) and the located byte
  offset + line. The three digests are in `notes.md` §0 and in `build/R61ScoutSealDocs/digest.txt`.
* **S125's registry row must not claim** that it documents the `5`/`3` share counts, the
  unseal progress counter, the nonce, or the duplicate-share rule — it documents none of
  them. Its strongest true content is the Shamir threshold concept, the per-node threshold
  rule, the custody sentence and the seal/unseal state machine.
* **S126's registry row must not claim** a backend restriction; its true content is the
  command shape, the `-init`/`-nonce`/`-verify`/`-key-shares`/`-key-threshold`/`-target`
  flags, the unsealed+quorum precondition, the deprecation notice, and the `5`/`3`
  defaults.
* **S127's registry row must not claim** the `required`/`progress`/`complete` field names;
  its true content is the OTP role, the XOR-with-the-OTP, `-decode`, `-generate-otp`, the
  nonce rule and the v2.6.0 endpoint switch.
* Two honest gaps to carry into the lesson Gate: the **share-persistence** property and
  the **duplicate-share** behaviour are undocumented on all three pages — both are
  measurement obligations for the trial, not citation obligations.
* `notes.md` is the only file this seat authored under `capture/`; the three `.body` files
  are the fetched bytes.

SEAT-STATUS: complete
