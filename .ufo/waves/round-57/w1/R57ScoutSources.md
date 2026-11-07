# R57ScoutSources — round 57, seat report (scout: ground C2's five tests in the vendor docs)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master (detached HEAD
`7aa1f4726e1f6bcdc8411d1a8b21828d49785173`), BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`
present (`git cat-file -t` → `commit`). Read-only git; no lane mutation by this seat.

Predeclaration read before work: `plans/round-57.md` (C2 POP T1–T5), `plans/round-57-c1-check.py`,
`plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`.
No instrument was amended.

Answering model observed for this seat: **minimax-code/MiniMax-M3.1-Flash** (harness-declared
model id; the report is my own work, not a delegated answer).

Tools / versions / channel / reason (no installs were made; ALL pacman transactions are PAUSED):

| tool | version | channel | reason |
|---|---|---|---|
| `curl` | 8.23.0 (x86_64-pc-linux-gnu), OpenSSL/3.6.5, zlib/1.3.2 | system binary (preinstalled) | live GET of the vendor pages, per the assignment's exact command shape |
| `sha256sum` | GNU coreutils (sha256sum on PATH) | system binary | byte identity of the fetched bodies |
| `python3` | 3.14.8 (GCC 16.2.1) | system binary | HTML→text extraction for quoting only; no library installs |
| `bao` | OpenBao v2.7.2 (`9e0a0d3c3504a0a00b45e61355afac5e35c78379`, committed 2026-10-26) | `/home/vgpnk/.local/bin/bao` (preinstalled) | the binary the C2 trial measures; one throwaway `bao server -dev` probe was run to check that the doc wording matches mechanics |

Refusal boundary honoured: only public documentation GETs; **no response headers or cookies were
captured** (bodies written with `-o`, status/bytes read from `-w`); no vault material, token or
secret was read, printed or written — the probe used a fixed throwaway dev token that was never
echoed to any artifact, and the saved probe evidence records only the *shape* of values
(`hmac-sha256:<64hex>` / `PLAINTEXT`), never the values. Both probe dev servers were killed
(ports 8298/8299 confirmed closed; `ps` shows only a sibling seat's server).

---

## 1. Fetch records (acceptance: URL, UA, status, bytes, sha256)

Command shape used verbatim for every fetch:
`curl -fsSL --compressed --max-time 60 -A "<browser UA>" -o <file> -w '%{http_code} %{size_download} %{url_effective}' <URL>`
(browser UA: `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36`).
`bytes` is given both ways: **wire** = curl `size_download` (compressed transfer size) and
**file** = `wc -c` of the saved body (decompressed).

| # | URL | UA | HTTP | wire bytes | file bytes | sha256 of body | rc |
|---|---|---|---|---|---|---|---|
| F1 | https://openbao.org/docs/audit/ | browser | 200 | 10378 | 41787 | `76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6` | 0 |
| F2 | https://openbao.org/docs/audit/ | default (curl/8.23.0) | 200 | 10378 | 41787 | `76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6` | 0 |
| F3 | https://openbao.org/docs/commands/audit/ | browser | 200 | 6852 | 33338 | `3dc8873201fdb3a971eb5fb1c1cee6a804462510c962ea5df6121cad0d9905ce` | 0 |
| F4 | https://openbao.org/docs/commands/audit/ | default (curl/8.23.0) | 200 | 6852 | 33338 | `3dc8873201fdb3a971eb5fb1c1cee6a804462510c962ea5df6121cad0d9905ce` | 0 |

**F1≡F2 and F3≡F4 byte-for-byte.** The plan's open item "default UA: not yet tested" is now
closed: the site serves the identical body to the default curl UA, so the *default* UA is a
legitimate registry-grade fetch and the browser UA adds nothing. The plan's "browser UA" wording
can stand, but it is not a freshness requirement — no UA-dependent variant exists.

Both pages carry the docs-version marker `Version: Version 2.7.x` (line 43 of
`openbao-docs-audit.browser.txt`, line 75 of `openbao-docs-commands-audit.browser.txt`), i.e.
they are the **2.7.x** branch docs — the same branch as the measured binary OpenBao v2.7.2.
`Copyright © 2026 OpenBao`.

Supporting vendor pages fetched the same way (bodies under `.ufo/waves/round-57/w1/R57ScoutSources.d/fetch/`):

| URL | HTTP | file bytes | sha256 |
|---|---|---|---|
| https://openbao.org/docs/api/system/audit-hash/ | 200 | 35071 | `bca1461ee6a1a2a3ca0658f815535878de29446b9459fe2283f3c0e62beeaca9` |
| https://openbao.org/docs/audit/file/ | 200 | 26216 | `726c323f601383968a8eec046f9c4fc810bad6e3c0d4cfbbd57eeb476d47c3af` |
| https://openbao.org/docs/commands/audit/enable/ | 200 | 30665 | `cca04ec2ce83adc4123aa55f1d4f4c300558845abd0331a3c322592f02eba3fa` |
| https://openbao.org/docs/commands/audit/list/ | 200 | 31968 | `4541db71c1ec2fc44f0a2890a65602105fe418c96bdac2dfaf12d07543b7224b` |
| https://openbao.org/docs/commands/audit/disable/ | 200 | 30987 | `5e5045b0cfb681a9aa3287d71bc06353e9cf3a01eb309a5c9149a847464949d5` |
| https://openbao.org/docs/commands/status/ | 200 | 32063 | `ea66dd4924d56dfac1ae082d276602fe2f704c3b1027a067646227b1968fc5f8` |
| https://openbao.org/docs/api/system/seal-status/ | 200 | 42816 | `8abb8603eb7d6baab47b59cb46475e2e1a54435baa9e6293500a9108802ae0e2` |
| https://openbao.org/docs/configuration/audit/ | 200 | 30556 | `23024447e1a9b008d1642bc664f0bdf130cd3249795507146fe8a621e8ab9919` |
| https://openbao.org/docs/api/system/audit/ | 200 | 43161 | `1693a4dbd493a848b337803d7f4f7c038b254b2f90032ff37474905c4fd853f0` |

Receipt file with the exact commands: `.ufo/waves/round-57/w1/R57ScoutSources.d/fetch-receipt.txt`
(sha256 `b62477b20d113480acabb358c5df87e13fc88cf4ed4f5f852b179c94f25662ec`), which also carries
the byte offset of every quoted sentence inside the saved bodies.

---

## 2. Quote table (test → heading → ≤25-word quote)

All quotes are verbatim from the saved bodies. "S115" = `https://openbao.org/docs/audit/`
(`openbao-docs-audit.browser.html`, sha256 `76339ff7…`), "S116" =
`https://openbao.org/docs/commands/audit/` (`openbao-docs-commands-audit.browser.html`, sha256
`3dc88732…`). Headings are the docs' own section headings.

### Grounding the six items the assignment named

| # | Item | Source | Heading | Quote (≤25 words) | byte offset |
|---|---|---|---|---|---|
| Q1 | HMAC-SHA256 with a salt over request/response strings | S115 | **Sensitive information** | "Most strings contained within requests and responses are hashed with a salt using HMAC-SHA256." | 22293 |
| Q2 | non-audited paths list | S115 | **Audit devices** (intro, before *Enabling multiple devices*) | "The non-audited paths are: sys/init sys/seal-status sys/seal sys/unseal sys/leader sys/health sys/storage/raft/bootstrap sys/storage/raft/join" | 17753 |
| Q3 | `log_raw` | S115 | **Common configuration options** | "log_raw (bool: false) - If enabled, logs the security sensitive information without hashing, in the raw format." | 30953 |
| Q4 | `hmac_accessor` | S115 | **Common configuration options** | "hmac_accessor (bool: true) - If enabled, enables the hashing of token accessor." | 30820 |
| Q5 | disabling + re-enabling creates a new salt | S115 (also verbatim in S116 at 29100) | **Enabling/Disabling audit devices** (warning) | "This is true even if you re-enable the audit device at the same path, as a new salt will be created for hashing." | 28493 |
| Q5b | corollary of the same warning | S115 | **Enabling/Disabling audit devices** (warning) | "Once an audit device is disabled, you will no longer be able to HMAC values for comparison with entries in the audit logs." | 28300 |
| Q6a | multiple-device failure rule (non-blocking) | S115 | **Blocked audit devices** | "When multiple audit devices are enabled, if any of them fail in a non-blocking fashion, OpenBao requests can still complete successfully" | 29352 |
| Q6b | multiple-device failure rule (blocking) | S115 | **Blocked audit devices** | "If any of the audit devices fail in a blocking fashion however, OpenBao requests will hang until the blocking is resolved." | 29521 |
| Q6c | request success = logged to ≥1 device | S115 | **Enabling multiple devices** | "OpenBao considers a request to be successful if it can log to at least one configured audit device" | 20172 |

### Additional quotes each planned test leans on

| Test | Source | Heading | Quote | byte offset |
|---|---|---|---|---|
| T1 | S116 | **Examples** | "$ bao audit enable file file_path=/tmp/my-file.txt" → "Success! Enabled the file audit device at: file/" | 26808 |
| T1 | S116 | **Examples** (`bao audit list` output) | "file/    file    n/a" | 27665 |
| T1 | S115 | **Enabling/Disabling audit devices** (Note) | "the unsafe_allow_api_audit_creation = true option must be set in the server configuration starting with OpenBao v2.3.2." | 26370 |
| T2 | S115 | **Format** | "Currently, only two types exist: request and response." | 21573 |
| T2 | S115 | **Sensitive information** | "The purpose of the hash is so that secrets aren't in plaintext within your audit logs." | 22423 |
| T2 | S115 | **Sensitive information** (warning) | "Currently, only strings that come from JSON or returned in JSON are HMAC'd." | 23259 |
| T2 | https://openbao.org/docs/api/system/audit-hash/ | **Sample response** | "hash": "hmac-sha256:08ba35..." | 31752 / 31904 |
| T3 | S115 | **Enabling multiple devices** | "When multiple audit devices are enabled, OpenBao will attempt to send the audit logs to all of them." | 19946 |
| T3 | https://openbao.org/docs/commands/audit/enable/ | **Usage** | "-path (string: "") - Place where the audit device will be accessible. This must be unique across all audit devices." | 27944 |
| T5 | S115 | **Audit devices** (intro) | "except for a few paths which do not go via the audit system." | (adjacent to 17753) |
| T5 | https://openbao.org/docs/commands/status/ | **status** | "The status command prints the current state of OpenBao including whether it is sealed and if HA mode is enabled." | — |

---

## 3. Support verdict per planned test (T1–T5)

Method: each test is judged against the quoted vendor sentences, then against one live probe on
OpenBao v2.7.2 (throwaway `bao server -dev`, audit devices written to scratch) to see whether the
docs' wording would make the test ambiguous. Probe artifact (shapes only, no values):
`.ufo/waves/round-57/w1/R57ScoutSources.d/probe-evidence.json`
(sha256 `83b522b3d564e530effff1144e98a7b50d1ed8885a2ad78df920b2be1308054c`).

### T1 — `bao audit enable file file_path=<scratch>` then `bao audit list` names `file/`
**Verdict: SUPPORTED by the docs, but the plan's POP wording is under-specified on one point the
docs make load-bearing.** S116's *Examples* shows exactly this command, its success line
("Success! Enabled the file audit device at: file/") and the `bao audit list` output row
"file/    file    n/a". The device-path convention ("`file/`") and the `file/` mount type are
literally documented.
**Flag:** S115's *Enabling/Disabling audit devices* note says API/CLI audit-device creation
requires `unsafe_allow_api_audit_creation = true` in the server configuration "starting with
OpenBao v2.3.2". My probe confirms the docs are literal, not advisory: on a plain
`bao server -dev` (no `-config`), `bao audit enable file …` returns **HTTP 400 "cannot enable
audit device via API; use declarative, config-based audit device management instead"**; with a
one-line config `unsafe_allow_api_audit_creation = true` merged into `-dev -config=…`, the same
command succeeds and `bao audit list` prints "file/    file    n/a". The plan's POP says only
"a throwaway `bao server -dev`" — a trial that starts the server without that flag will fail T1
for a reason that has nothing to do with the custody property under test. The plan's own landing
text lists `unsafe_allow_api_audit_creation` nowhere. The executor's draft
(`corpus/openbao-audit-trial.sh`, lines 73–84) already writes that config file, so the landing is
correct; the *plan prose* is what is loose. Because the plan is frozen, the fix belongs in the
knowledge entry and the registry note, not in the plan: record the flag as a **precondition of the
trial harness**, quoted from S115.
Also note the S116 *Examples* device path is `file/`, but S115/S116 say nothing about the
*listing* format beyond the example table — the test asserts a substring ("file/"), which the
example supports.

### T2 — a KV write's audit entry exists for request and response, carries the default `hmac-sha256:` value form, plaintext absent
**Verdict: SUPPORTED, with one wording ambiguity worth naming.** S115 *Format* gives the two
record types ("Currently, only two types exist: request and response."), *Sensitive information*
gives the mechanism ("hashed with a salt using HMAC-SHA256") and the plaintext guarantee ("secrets
aren't in plaintext within your audit logs"), and the **`hmac-sha256:` value form itself is
documented in only one place**: the `/sys/audit-hash` sample response (`"hash": "hmac-sha256:08ba35..."`).
Note that the literal token `hmac-sha256` appears **nowhere** in S115 or S116 (grep count 0 in
both) — S115/S116 describe the algorithm in prose ("HMAC-SHA256") but never show the wire form.
**Flag (documentation-source gap):** the plan's C2 source list names only S115 and S116, but the
`hmac-sha256:` *prefix* is grounded only by
`https://openbao.org/docs/api/system/audit-hash/`. If the landing entry cites S115/S116 for the
`hmac-sha256:` string it will be citing a page that does not contain it. The registry should
carry a third row for the audit-hash API page (I fetched it live; sha256 `bca1461e…`).
**Second flag (semantic, narrow):** S115 warns "only strings that come from JSON or returned in
JSON are HMAC'd" — non-string types (integers, booleans) pass through in plaintext. The test's
"the written plaintext does not occur" is therefore a statement about a **string** value; if the
trial writes a non-string, the assertion would be wrong about the product, not about the trial.
Recommend the entry say "a JSON string value".
**Mechanics confirmed live:** the default device's log contained 11 `hmac-sha256:` values and
**zero** occurrences of the written plaintext; the write produced both a `request` and a
`response` record with the value field in `hmac-sha256:<64hex>` form.

### T3 — a second device with `log_raw=true` records the same value in raw form while the default device still HMACs it
**Verdict: SUPPORTED; the docs are explicit about both halves, but the second-device *path* is an
unstated precondition.**
- S115 *Common configuration options* gives the `log_raw` row verbatim (Q3): it logs the
  security-sensitive information "without hashing, in the raw format".
- S115 *Enabling multiple devices* gives the fan-out: "OpenBao will attempt to send the audit logs
  to all of them", plus the "aggregate/union of the logs from each audit device" advice.
**Flag:** S115's `log_raw` row appears under *Common configuration options* — options shared by
every device — while the **path** of a second device must be unique. That requirement is stated
on the `audit enable` page, not on S115: "-path (string: "") - Place where the audit device will
be accessible. This must be unique across all audit devices. This defaults to the 'type' of the
audit device." My probe confirms this is enforced: enabling a second `file` device at the default
path returns **HTTP 400 "path already in use"**; with `-path=raw/` it succeeds and the second
device logs the value in **plaintext** (2 occurrences of the plaintext, 0 `hmac-sha256:`) while
the default device logged 0 plaintext occurrences. The plan's T3 wording ("a second device with
`log_raw=true`") does not say "at a distinct path"; a trial that omits `-path` fails for a path
collision, not for the custody property. Same remedy as T1: state the precondition in the entry.
Also note the docs' multiple-device **failure** rule (Q6a–Q6c) is a *different* property than T3
asserts — it is about one device failing while another still logs — and T3 does not (and need
not) test it.

### T4 — `bao audit disable file/` then re-enable at the same path creates a new salt: the same value's HMAC after re-enable differs from before
**Verdict: SUPPORTED — the strongest of the five.** The warning is stated twice, identically, in
S115 *Enabling/Disabling audit devices* and in S116 *Examples*: "even if you re-enable the audit
device at the same path, as a new salt will be created for hashing" (Q5), plus the corollary that
after a disable you can no longer HMAC values for comparison (Q5b).
**Two flags, both about the *measurement*, not the property:**
1. Q5b ("you will no longer be able to HMAC values for comparison with entries in the audit logs")
   means the *only* correct way to compare is to compute the HMAC **before** the disable and again
   **after** the re-enable — the pre-disable value cannot be recomputed from the old device
   afterwards. My probe: `POST /sys/audit-hash/file` returned
   `hmac-sha256:0dfb13c6…` before the disable and `hmac-sha256:bec1785b…` after the re-enable
   (differ), while the same call **between** disable and re-enable returns **HTTP 400** (the
   device path does not exist). A trial that samples the "before" hash *after* disabling gets a
   400 and will mis-report the property as broken.
2. The *same-value* comparison must use a **distinct value per round** if the trial compares
   log-file bytes, because the file audit device **appends**: https://openbao.org/docs/audit/file/
   says "If a file already exists at the given path, the audit backend will append to it"
   (offset 21443 in `openbao-docs-audit-file.browser.html`). Comparing via `/sys/audit-hash` (as
   the executor's draft does, `hashof()` at `corpus/openbao-audit-trial.sh:117`) avoids this
   entirely, and it also survives the disable (the old entries remain readable in the file).
   My probe on a *stable* input also shows the salt genuinely rotates: after disable+re-enable
   the same path, the newly written value's HMAC changed
   (`hmac-sha256:b0f4ea76…` → `hmac-sha256:b9a48a66…`) and the plaintext never appeared.

### T5 — the documented non-audited `sys/seal-status` path (`bao status`) leaves no audit entry while a KV read in the same window does
**Verdict: SUPPORTED, with one real ambiguity in the parenthetical.**
- The non-audited list in S115 names `sys/seal-status` (Q2) and the page states the general rule
  ("except for a few paths which do not go via the audit system").
- `https://openbao.org/docs/commands/status/` documents the `status` command but **never names
  `sys/seal-status`** — grep for "seal-status" in the status page returns 0 hits. The mapping
  from the *command* `bao status` to the *path* `sys/seal-status` is not stated in either
  registry source. It is stated by the API page
  `https://openbao.org/docs/api/system/seal-status/` ("GET /sys/seal-status", "This endpoint
  returns the seal status of the OpenBao. This is an unauthenticated endpoint."), which the plan
  does not list either.
**Flag (same class as T2):** the plan's T5 wording credits the `sys/seal-status` path to the
`bao status` command; the docs support the *path* (S115) and the *command* (status page) but not
the *linkage*. A third/fourth registry row would close it.
**Second flag, and it is the one that matters for the trial:** `bao status` is **not** a
single-path operation. The CLI's `status` command issues `GET /v1/sys/seal-status` **and**
`GET /v1/sys/leader` (`internal/command/status.go` → `client.Sys().SealStatus()` and
`OutputSealStatus` → `buildSealStatusOutput` → `client.Sys().Leader()`; `api/sys_seal.go` and
`api/sys_leader.go`, upstream `openbao/openbao@main`, fetched 2026-11-07 — sha256
`13af07ab8a3dff4b3d819c63617a40dca7daa41e47025faa85b287b9b5a96af6` (status.go),
`b93c1dc11d88b4fcc6fe9feed39a4273e011b877d5bd5e48718b4f99a48b8d24` (format.go),
`c38ffd35593361ee1825a6b30633ac77d30fa38a3aa4fa9e69a6bf684539d20c` (api/sys_seal.go),
`f43b1f9e8322b30f6432a315d6be713e646a656ab1e35a7bdd3127062ad17524` (api/sys_leader.go)).
`sys/leader` **is** also on the non-audited list (Q2), so the pair is still clean — but a trial
that asserts "no entry whose path is `sys/seal-status`" is asserting less than the docs claim,
and a trial that asserts "no entry at all appeared in the window" is asserting more (it would
also be sensitive to `sys/ha-status`, which is *not* on the non-audited list: my probe of
`GET /v1/sys/ha-status` produced a request/response pair in the log, while the same probe of
`/v1/sys/seal-status` and `/v1/sys/health` produced none). **Recommendation:** the entry should
say the window is checked for the absence of *any* new entry while a KV read in the same window
does produce entries — which is exactly the shape my probe measured (log line count 40 → 40
across three `bao status` calls, and 0 occurrences of "seal-status" in the whole log) — and
should not name `sys/seal-status` as the sole path the command touches.

---

## 4. Summary of findings

1. **Both registry pages are UA-insensitive** (F1≡F2, F3≡F4, byte-identical). The plan's open
   item "default UA: not yet tested" is closed: the default UA is an equally valid fetch. Both
   pages are the **2.7.x** branch, matching the measured binary OpenBao v2.7.2.
2. **All six named grounding items are quoted verbatim with headings and byte offsets**, from
   S115 (`/docs/audit/`) except the salt warning, which appears identically in both S115 and
   S116, and the `hmac-sha256:` value form, which appears in **neither** — it is grounded only by
   `https://openbao.org/docs/api/system/audit-hash/`.
3. **T1–T5 are all supported by the vendor docs.** No test is contradicted by the documentation.
4. **Two registry-row gaps** (the docs ground the property, but not from the two pages the plan
   names): the `hmac-sha256:` literal (T2) lives on the audit-hash API page; the
   `bao status` → `sys/seal-status` linkage (T5) lives on the seal-status API page. Both pages
   were fetched live and are recorded above.
5. **Three harness preconditions the docs make load-bearing** and the plan prose does not state:
   `unsafe_allow_api_audit_creation = true` for any API/CLI audit enable (T1, T3 — otherwise
   HTTP 400); a **distinct `-path`** for the second device (T3 — otherwise "path already in
   use"); and the **before/after ordering** of the salt comparison (T4 — the pre-disable hash
   cannot be recomputed after the disable, HTTP 400 in between; and the file device *appends*).
   The executor's landing draft already implements all three correctly.
6. **T2's plaintext assertion is about JSON *string* values** (S115: "only strings that come from
   JSON or returned in JSON are HMAC'd"); non-string types pass through in plaintext.
7. The **multiple-device failure rule** (Q6a–Q6c, S115 *Blocked audit devices*) is documented but
   is **not** exercised by any of T1–T5 — it is a property of the *failure* path, orthogonal to
   the custody path T3 exercises. It is recorded here so the entry does not imply it is tested.

## 5. Artifacts written by this seat

- `.ufo/waves/round-57/w1/R57ScoutSources.md` — this report.
- `.ufo/waves/round-57/w1/R57ScoutSources.d/fetch-receipt.txt` — the exact commands, UAs, statuses,
  byte counts, sha256s, and the byte offsets of every quoted sentence
  (sha256 `b62477b20d113480acabb358c5df87e13fc88cf4ed4f5f852b179c94f25662ec`).
- `.ufo/waves/round-57/w1/R57ScoutSources.d/probe-evidence.json` — 14 records from the live probe,
  value *shapes* only (`hmac-sha256:<64hex>` / `PLAINTEXT`), no values, no tokens
  (sha256 `83b522b3d564e530effff1144e98a7b50d1ed8885a2ad78df920b2be1308054c`).
- `.ufo/waves/round-57/w1/R57ScoutSources.d/fetch/` — the saved bodies: S115 and S116 under both
  UAs (browser and default), the two text extracts, and the nine supporting vendor pages.

No production file was touched; no plan or instrument was amended; scratch
`/fast/scratch/hyaku/kagi-r57/R57ScoutSources/` was deleted before yielding.

## 6. Unresolved / not covered

- I did not verify the OpenBao **2.6.x / 2.5.x** doc branches; the registry cites 2.7.x, which
  matches the measured binary. If the registry is to claim version-independence, the older
  branches were not fetched.
- The upstream `openbao/openbao@main` sources I read (`internal/vault/logical_system.go`,
  `internal/command/status.go`, `internal/command/format.go`, `api/sys_seal.go`,
  `api/sys_leader.go`, `api/sys_hastatus.go`, `internal/command/server/config.go`) are the
  **main** branch as of 2026-11-07, not the v2.7.2 tag; the 400 responses I observed live on
  v2.7.2 are the empirical anchor, the source is corroboration.
- I did not evaluate whether `sys/ha-status` should be added to the trial's non-audited assertion
  (it is *not* on the docs' list and is audited in practice) — that is a design decision for the
  L1.
