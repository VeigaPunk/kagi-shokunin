# Source02 — S002 re-open: calibration verdicts and freshness reconciliation

Axes: **C1 calibration** (S002-bound source/status/eligibility/product/path adjudication against the associated entry claims) and **C2 freshness** (stale pin reconciliation with exact historic evidence, no silent deletion or laundering).
Scope: source S002 only (`https://www.1password.dev/connect`) plus its own `.md` representation. S003 was **not** re-opened; deployment-credential support is therefore assessed only as “S002 does not carry it,” not as a re-verification of S003. No registry edits, no entry edits, no account/vault/CLI/API execution.
Access: 2026-10-20, 21:29–21:43Z (`HTTP Date: Tue, 20 Oct 2026 21:34:31 GMT`; later header read 21:41:28 GMT).

## Read revision

- Base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD` matched).
- Live worktree at read time carried concurrent sibling edits, not mine:
  - `corpus/SOURCES.md` — 21 rows (S001–S021), 18,222 B, sha256 `ebf8864654b7cf1669ffb8944d7682cdefbea3234bca3adbbcb32157488f4de2`; frozen base `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` (14,261 B).
  - `corpus/knowledge/onepassword-machine-credentials.md` — 9,048 B, sha256 `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80`; frozen base `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb` (6,240 B). The growth is the round-22 erratum plus an “Additional source-attribution bounds (round 22)” subsection.
- **S002's row itself is byte-identical frozen vs live**: line sha256 `41b6308840538d24f9b876d79744a7ec5d9259ec66320a1044632d73e12d9a78` in both; `git diff` shows no S002 line change. Item 3 of the entry (line 14) is also unchanged at HEAD and live.

## S002 reopen record

| field | value |
|---|---|
| URL | `https://www.1password.dev/connect` (no query, no fragment; HTTP 200) |
| Title | `1Password Connect - 1Password Developer` |
| Accessed | 2026-10-20, 21:29–21:43Z |
| HTML representation | 1,186,550 B; sha256 `9e00e86dafcf8058332a74dfff983bd242c5d62b62109ffb6d495fd35c5b1cea`; weak `ETag: W/"ewomuil5oqpffw"`; `cf-cache-status: HIT`, `age: 11462`; `x-mintlify-client-version: 0.0.3902`; no content `Last-Modified`; byte-identical across four fetches (plain, repeat, `--compressed`, trailing slash) |
| Markdown representation | page advertises `<link rel="alternate" type="text/markdown" href="/connect.md"/>`; `GET /connect.md` = 3,792 B, sha256 `ee60a0dfb3d41e15d52e8229b7b7a00a8b9dabfed181c0a5acb6057f1c60fe48`; byte-identical on two fetches; its `last-modified` header is `21:41:29Z` against a `Date` of `21:41:28Z`, so it postdates the request by one second and is not a revision stamp |
| Anchor | Page introduction and Connect-server diagram caption (the caption is the **image `alt` text**, not visible body prose) |
| Quote (20 words) | “The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API.” |
| Locus | HTML `img alt` on `connect-diagram.png` (serialized twice: JSON payload and `alt=`); `.md` line 21; visible body text does not contain the sentence |
| Product | 1Password Connect server (Secrets Automation); self-hosted in the customer's infrastructure; private REST API |
| Path | App/service → Connect server over HTTP via the private REST API and access tokens; Go/Python/JavaScript SDKs or a custom integration; server caches data in the customer's infrastructure; internal rate limits apply on first fetch (e.g., server start) |
| Status | No maturity badge, no version, no displayed date. `Beta`/`Early Access`/`Public Preview` occur only in an embedded CSS comment defining `.op-status-badge` styles (3 CSS occurrences, zero badge elements); `LivePreview`/`isLivePreviewRoute` are build/runtime metadata. The “New! … Credential Broker” banner is site chrome for a **different product** |
| Eligibility | No plan or eligibility prerequisite is stated on S002; its two `account` mentions are use-case examples, not requirements. `Business` and `Enterprise` occur **zero** times in the HTML and `.md`; the single `teams` match is the `teamspace` feature flag, not “1Password Teams” |
| Revision metadata | `pageMetadata.lastModified` `2026-10-19T21:23:28.086Z`; `originalFileLocation` `connect.mdx`; `gitLastModified` `$undefined` — present in serialized HTML, not displayed |

Secondary located quotes (each ≤25 words):

- Intro, `.md` line 7: “access your 1Password items and vaults in your company's apps and cloud infrastructure using a private REST API” (18 words).
- Caching, `.md` line 9: “they allow unlimited re-requests after the server fetches your secrets” (10 words).
- Quotas, `.md` line 11: “These only apply when a Connect server fetches secrets for the first time” (13 words).

## C1 — adjudicated decisions (10)

Scored on review decisions, not rows authored: **5 accept, 5 reject**. Each control is failable from S002 alone.

| # | claim (source of claim) | verdict | reason |
|---|---|---|---|
| A1 | S002 scope = “Connect server and application REST API access boundary” (registry row) | **ACCEPT** | Intro states a private REST API for company apps; caption states apps communicate via access tokens and the REST API |
| A2 | S002 teaches “Connect application access uses the server REST API and an access token” (registry row) | **ACCEPT** | Exact paraphrase of the caption; no extra mechanism imported |
| A3 | Quote and anchor locate the teaching (registry row) | **ACCEPT, with locus precision** | Quote is verbatim in the caption/alt text and `.md` line 21; the **introduction alone does not contain “access token.”** A reader who strips tags must read attributes or the `.md`; label the anchor as “diagram caption (image alt text)” in any future note |
| A4 | E1 item 3, S002-supported half: applications/services authenticate to the Connect server's REST API using access tokens | **ACCEPT** | Caption + intro; S002 also establishes self-hosting and caching |
| A5 | Correctly bounded control not currently used: “Connect caches data in your infrastructure, and internal rate limits apply only on first fetch” | **ACCEPT** | `.md` lines 9–11. Keep it separate from token lifetime: this is request accounting, not credential expiry |
| R1 | “[S002, S003] jointly support ‘Connect setup creates deployment credentials for the server’” | **REJECT as an S002 claim** | S002 has no setup step and no deployment-credential, credentials-file, or token-creation instruction. Its `deploy` uses describe hosting Connect servers or deploying code in CI/CD, and its one `credential` use is a database credential in a use-case example. Deployment-credential creation is S003-bound (not re-opened here). The sentence is not false, but the joint bracket over-attributes it |
| R2 | S002 supports “the setup guide recommends a separate token for each application or service” | **REJECT** | No per-application recommendation exists on S002; the caption says only “access tokens” generically. S003-bound |
| R3 | S002 supports “the deployment credential and caller token occupy different custody boundaries” | **REJECT** | S002 documents a communication path, not a custody property. The entry's new round-22 bounds subsection already labels the conclusion `[INFERENCE]`; this decision agrees with that append |
| R4 | S002 establishes Connect release status (preview/beta/GA) or plan eligibility | **REJECT** | No badge/version/displayed date; `Business`/`Enterprise` zero occurrences; maturity strings are CSS only; do not import EPM Business eligibility or the Credential Broker preview |
| R5 | S002 establishes Connect token rotation, expiry, vault scope, or per-application isolation | **REJECT** | S002's only `token` mention is “access tokens” and its only `vault` mention is “items and vaults”; it has no rotation, expiry, scope, or isolation text. Those belong to S004 or the unregistered `/connect/manage-connect` page |

### Proposed append to the entry (not applied; registry row not superseded)

Under the existing “Additional source-attribution bounds (round 22)” subsection, add:

> Item 3, first sentence — split the bracket. S002 supports only the app→REST/token boundary (“communicates to Your Apps using access tokens and a REST API”). S002 has no deployment-credential, setup, per-application-token, or custody text. Read the sentence as: apps/services authenticate to the REST API with access tokens `[S002, S003]`; setup creates deployment credentials and instructs a new token per application or service `[S003]`. The “different custody boundaries” conclusion remains `[INFERENCE]`.

No superseding S00x row: no immutable S002 field (scope, anchor, teaching, tier, status, opened, recheck, used-by) is false. The only correction is the entry's citation precision and the pin below.

## C2 — freshness reconciliation

### Pin state

| derivation | digest | note |
|---|---|---|
| recorded in `corpus/SOURCES.md` S002, opened 2026-10-19 | `68017d4cf1655abb55baec982c2ed89b5a73731bba0275ca2426a25dfcd9d2a6` | no representation recorded; **not reproduced** today |
| current HTML, `curl -sL --compressed https://www.1password.dev/connect` | `9e00e86dafcf8058332a74dfff983bd242c5d62b62109ffb6d495fd35c5b1cea` (1,186,550 B) | **stable across 4 fetches**; same value as the independent S001/S003 lane's cross-source control |
| current Markdown alternate, `GET /connect.md` | `ee60a0dfb3d41e15d52e8229b7b7a00a8b9dabfed181c0a5acb6057f1c60fe48` (3,792 B) | content-bearing, no `_next/static` assets; stability across deploys **unproven** |
| 2026-10-06 Wayback replay (`id_`, decompressed) | `75407e6185d4ac5c59f23daf7ceb99e2388db0ddca46955172925363b243edce` | replay bytes, not origin bytes |
| 2026-10-10 Wayback replay (`id_`, decompressed) | `95bc16f51142a2a8feeb51e5bc7b2348ec10b157fe4966eefcdb7ed75d28962f` | replay bytes, not origin bytes |

**Method control (independently reproduced):** the registry's working representation is decompressed HTML — the S009 and S010 registry pins reproduce exactly today under the same command (`a840727e…`, `fed6b2e1…`). Under that method S002 is **STALE**: the current bytes are reproducible and stable, while the recorded pin differs. It is **not** “unreproducible” in the S001 sense. The old bytes are not recoverable from the indexed captures (CDX lists 2026-08-30, 2026-10-06, 2026-10-10 only), so the 2026-10-19 revision's exact content diff is **UNKNOWN**.

### The page's machine stamp is a build stamp, not an editorial date

- Today's serialized `pageMetadata.lastModified` is `2026-10-19T21:23:28.086Z`; it sits inside the sub-second cluster the S001/S003 lanes independently measured across unrelated 1password.dev pages.
- The 2026-10-06 capture carries `2026-10-05T17:44:42.809Z`; the 2026-10-10 capture carries `2026-10-09T22:00:10.274Z`.
- The extracted prose region is identical across all three (digest below), so the stamp advances with builds without a prose revision. Do **not** record `2026-10-19T21:23:28.086Z` as “page revised 2026-10-19.”

### Semantic evidence: teaching unchanged in every recoverable revision

- Body-only text nodes (intro through “Learn how to get started…”, excluding nav/footer, attributes, and script payload) have sha256 `f0eab7289c468945c9ed1846629b294f65a2c42248dc3b0ea363a26095153da8` in the 2026-10-06 capture, the 2026-10-10 capture, and today's live page — **identical**.
- The 2026-10-06 and 2026-10-10 captures also share a full extracted-text digest (`2969d6de…`); today differs only by three navigation lines (`Go`, `Node.js`, `Python` added to the SDK menu), i.e., site chrome, not page body.
- Extraction limit: it covers server-rendered text nodes only. The client-rendered use-case cards live in the serialized payload; the `Reduce latency and downtime` heading is present in all three captures and today, but those cards were not byte-diffed.
- The quoted caption is present (twice in serialized HTML) in the 2026-10-06 and 2026-10-10 captures and today; the intro sentence is verbatim in all three.
- Therefore the S002 teaching, anchor, product, status, and eligibility readings above are stable across every revision this lane could recover. The recorded 2026-10-19 pin cannot be matched to any available bytes; that is expected for a build-coupled HTML pin, and it is not evidence of mechanism drift.

### Expectation migration (append-only, no deletion)

Proposed registry note — keep `opened 2026-10-19` and `68017d4c…` as history; add, never replace:

> S002 pin reconciliation (2026-10-20): the recorded pin `68017d4c…` (opened 2026-10-19, representation unrecorded) is retained as historic and is not reproduced today. Current decompressed HTML (`curl -sL --compressed https://www.1password.dev/connect`, no query) is `9e00e86dafcf8058332a74dfff983bd242c5d62b62109ffb6d495fd35c5b1cea` (1,186,550 B; `ETag W/"ewomuil5oqpffw"`; four fetches identical, 2026-10-20T21:34Z). Content serialization `/connect.md` is `ee60a0dfb3d41e15d52e8229b7b7a00a8b9dabfed181c0a5acb6057f1c60fe48` (3,792 B). Served `pageMetadata.lastModified` `2026-10-19T21:23:28.086Z` (`connect.mdx`; `gitLastModified` undefined) is a **site build stamp**, not an editorial date: the 2026-10-06 capture (stamp `2026-10-05T17:44:42.809Z`), the 2026-10-10 capture (stamp `2026-10-09T22:00:10.274Z`), and today's page share body-text digest `f0eab728…`, and all contain the quoted caption. The 2026-10-19 bytes are not archived, so that revision's exact diff is `UNKNOWN`. No silent replacement: the old pin stays in history.

Old expectation: `opened` date + opaque raw-HTML digest.
New expectation: `opened` date + raw-HTML digest **with declared derivation** + `.md` content pin + served build stamp labeled as such + semantic-diff state (`UNKNOWN` unless an archived prior revision proves otherwise).

### Gate gap

`corpus/sources-census.sh` has **zero** `sha256` and zero `digest` references (`grep -c` = 0, 0); it enforces row shape, `verified-at:`/`recheck:`, and the `used-by` handshake only. No gate recomputes a source pin, so a stale or unreproducible pin is invisible. A `--pins` mode that distinguishes `SC_PIN_STALE` (same declared representation, different digest) from `SC_PIN_UNREPRODUCIBLE` (no declared representation matches) and never rewrites would make this class auditable.

## Falsifier

S002 is falsified if a re-open shows the Connect diagram caption no longer states that the server communicates with apps using access tokens and a REST API; if the introduction stops describing a private REST API; if the diagram/caption is removed so the token claim has no located evidence; if Connect gains a maturity badge or a plan/eligibility prerequisite that contradicts the “no status/no plan” reading; or if `Business`/`Enterprise` becomes a documented prerequisite on this page. A changed pin alone does not falsify the teaching — under this page's build-coupled HTML, only a recovered semantic diff can.

## Limits and unknowns

- Edge cache: `cf-cache-status: HIT`, `age: 11,462 s` at the header read; values are as served to this host, and origin may differ.
- Wayback `id_` replay bytes are not origin bytes; the 2026-10-06/10-10 HTML digests are not comparable to registry pins and are used only for text.
- Body-text extraction strips attributes, so the caption was verified separately in raw serialized HTML and `.md`; the body digest covers prose/headings, not the image alt text.
- No 2026-10-19 capture is indexed (CDX lists 2026-08-30, 2026-10-06, 2026-10-10); that revision's exact bytes and content diff remain unknown.
- S003 was not re-opened; the statement “deployment credentials are S003-bound” rests on S002's silence plus the entry's own citation, not on a fresh S003 read.
- One page plus its `.md` representation were fetched; the `/connect/manage-connect`, `/connect/get-started`, and SDK pages were not opened. No account, vault, CLI, or API call was exercised. No installs or upgrades.

## Checks the parent should run after integration

1. `bash corpus/sources-census.sh` — exit 0/1/2; confirm the appended S002 pin note does not break row shape or `used-by` resolution, and that S017–S021 still resolve.
2. `curl -sL --compressed https://www.1password.dev/connect | sha256sum` → `9e00e86d…` (expect drift at the next site build; do not treat drift as content change).
3. `curl -sL --compressed https://www.1password.dev/connect.md | sha256sum` → `ee60a0df…` (content representation; cross-deploy stability unproven).
4. Re-run the S009/S010 method control (`a840727e…`, `fed6b2e1…`) before accepting any pin classification.
5. If the entry append is adopted, verify only the new note was added and item 3's historical bytes remain unchanged.

No packages installed, no upgrades, no account/vault/credential operations; only HTTP GETs, two Wayback CDX queries, and two capture replays.

Report: .ufo/waves/round-22/build/Source02.md
