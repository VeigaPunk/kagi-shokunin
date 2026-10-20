# Source03 — S003 re-open and entry calibration

Axes: **calibration** (C1) and **freshness** (C2). Read-only source re-open; no registry edits, no entry edits, no account/vault operations, no installs.

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD` matched). Live worktree at read time carried concurrent sibling edits: `corpus/SOURCES.md` `a4edd52c…` (53 lines / 16757 B) against frozen/stamped `db134917…` (43 / 14261); `corpus/knowledge/onepassword-machine-credentials.md` `e885081e…` (68 / 8328) against frozen `7635be81…` (35 / 6240, which matches `corpus/stamps.tsv:23`). The S003 registry line and E1 item 3 are byte-identical at HEAD and live (verified); line citations below use the frozen entry and the live `.md` rendering.

## Reopen record (S003)

- URL: https://www.1password.dev/connect/get-started
- Access date: 2026-10-20, first fetch 21:33:44 GMT, last refetch 21:36:21 GMT.
- Representations:
  - HTML: 1,369,361 B, sha256 `0daffd88fb69359d0fe6947f6521c45f0a11224ec16edbdc72ad5a9dad44a451`; `cache-control: no-store`, weak `etag: W/"97ausnh5grtcet"`, no content `Last-Modified`.
  - Markdown alternate, advertised by the page's own `<link rel="alternate" type="text/markdown" href="/connect/get-started.md"/>`: 14,652 B, sha256 `66831901561602872d7dba73a4a0ed52fd374d6a6f62fb823ae4a78be17092c6`; byte-identical across three fetches 21:33–21:36Z. Its `last-modified` header equals request time (`age: 0`), so it is not a content revision stamp.
- Machine-readable revision: JSON-LD `WebPage` node `@id …#webpage` carries `dateModified: 2026-10-19T21:23:28.013Z`; `https://www.1password.dev/sitemap.xml` carries the identical `lastmod`. No displayed version/date exists in the rendered page.
- Anchor resolves: `### Step 1: Create a Secrets Automation workflow` (line 37) and `### Step 3: Set up applications and services to get information from 1Password` (line 211).

### Located quotes (each ≤25 words)

| location (markdown alternate line) | quote | words |
|---|---|---|
| §Deployment, Step 1 (line 41) | “credentials necessary to deploy 1Password Connect Server” | 7 |
| §Deployment, Step 1 (line 42) | “An access token. Use this in your applications or services to authenticate with the Connect REST API.” | 17 |
| §Deployment, Step 3 (line 213) | “Create a new token for each application or service you use.” | 11 |
| §Requirements (line 18) | “Connect servers can't access your built-in Personal, Private, or Employee vault, or your default Shared vault.” | 15 |

Source date: page served 2026-10-20 with `dateModified 2026-10-19T21:23:28.013Z`; no displayed version.

## C1 — registry row vs source

| row field (frozen) | verdict | evidence |
|---|---|---|
| scope: “Connect deployment credentials versus client API tokens” | ACCEPT | Step 1 creates the credentials file and an access token; Step 3 routes apps through tokens. |
| anchor: “§Deployment, Step 1 and Step 3” | ACCEPT | Both headings present at the cited numbers; quotes at lines 41, 42, 213. |
| teaches quote 1 | ACCEPT | Verbatim at line 41. |
| teaches quote 2 | ACCEPT | Rendered text at line 213; link markup sits between “token” and “for”, so a raw-bytes grep for the full sentence fails. |
| “current page has no displayed version/date” | ACCEPT literally, INCOMPLETE | No visible date, but a machine-readable `dateModified` exists and should be carried in the pin. |
| tier A / status `mined` | ACCEPT | Vendor setup mechanics, opened and quoted. |
| `Fetch sha256: 7f6d3b49…` | UNVERIFIABLE today | See freshness section; method and representation were never recorded. |

## C1 — associated entry claim (E1 item 3, frozen line 14)

Text: “Connect setup creates deployment credentials for the server and a separate access token for applications or services to authenticate to its REST API; the setup guide recommends a separate token for each application or service [S002, S003]. The deployment credential and caller token therefore occupy different custody boundaries [S003].”

| proposition | verdict | evidence |
|---|---|---|
| setup creates deployment credentials for the server | SUPPORTED | Step 1: `1password-credentials.json` contains the credentials necessary to deploy the server. |
| a separate access token lets applications/services authenticate to the REST API | SUPPORTED | Step 1 token bullet; Step 2 curl example uses `Authorization: Bearer $OP_API_TOKEN`. |
| guide recommends a separate token per application or service | SUPPORTED, S003-only | Step 3 instruction is an imperative, not an enforced per-app identity; the CLI creates a token per server and vault, and the page states no per-application enforcement. S002 does not carry this clause. |
| “therefore occupy different custody boundaries [S003]” | **INFERENCE, not S003** | S003 documents different artifact roles; it does not state a custody separation or an access-control boundary. The closest token-side controls are on the linked manage page, which is not S003 and not a registry row. |

**Finding C1-S003-1 (calibration, low–medium).** The last sentence is an analytic inference tagged with a bare `[S003]`, the same class as QA1/M12 (a citation whose target does not carry the claim). It does not make a false vendor statement, but it reads as source-backed. Proposed append-only correction for E1 (the live entry is concurrently gaining a round-22 erratum from DraftE1; do not rewrite item 3 in place):

> Erratum (round 22, S003 re-open): item 3's final sentence is `[INFERENCE]`. S003 documents two artifacts with different roles: the credentials JSON deploys the server, the access token authenticates applications to the REST API, and a separate token per application or service is instructed. S003 does not state a custody boundary. Token vault scope is fixed at creation and expiry is optional on `/connect/manage-connect` (§Create a token, §Set a token expiration), which is not currently a registry row.

**Finding C1-S003-2 (attribution, low).** Split the joint citation: the REST/token boundary is `[S002, S003]`; the per-application recommendation is `[S003]` only. Exact replacement for the first sentence: “Connect setup creates deployment credentials for the server and a separate access token for applications or services to authenticate with its REST API [S002, S003]; the setup guide instructs creating a new token for each application or service [S003].”

**What S003 does not establish.** Any plan or release status for Connect (neither preview, beta, GA, nor a plan tier appears); automatic token expiry; per-application token isolation; any vault-access scope beyond the default-shared-vault prerequisite.

## Qualifiers that must travel (C1)

- **Product:** 1Password Connect server, “a type of Secrets Automation workflow”; REST API; official images `1password/connect-api` and `1password/connect-sync`.
- **Status:** no preview/beta/GA label and no version number on S003; setup guide only. Served stamp `2026-10-19T21:23:28.013Z`.
- **Eligibility (S003 §Requirements):** 1Password account; a vault for the server to access; built-in Personal, Private, Employee and the default Shared vault are inaccessible; membership in a group permitted to manage Secrets Automation; Docker or Kubernetes deployment environment (kubectl and Helm for the Kubernetes path).
- **Path:** dashboard wizard or `op connect` CLI (`op connect server create`, `op connect token create`); Docker Compose vs Kubernetes Helm chart, without Helm, or alongside the Operator. Step 2's test uses `http://localhost:8080/v1/vaults` with a Bearer token.
- **Linked-page additions (not S003):** permission management “With 1Password Business or 1Password Teams” (`/connect/manage-connect` §Manage permissions); token vault access cannot be edited after creation and must be revoked/recreated (`§Create a token`); optional expiration of 30, 90, or 180 days with revocation on expiry (`§Set a token expiration`); up to 100 vaults per token (same section). These make “Connect is Business-only” and “tokens expire automatically” both rejectable readings.

## Freshness and pin debt (C2)

Exact historic evidence, preserved and not overwritten:

- R21 row: `opened 2026-10-19`, `Fetch sha256: 7f6d3b49ac3019073c37360c4771ebad2bad43a0f87ce314eb94bb0e0debe7ff`, no representation or download mode.
- 2026-10-20 re-open: `.md` alternate `66831901561602872d7dba73a4a0ed52fd374d6a6f62fb823ae4a78be17092c6` (14,652 B, stable across three fetches); HTML `0daffd88…` (1,369,361 B).
- Neither today's `.md` nor HTML matches `7f6d3b49…`. A spot-check of S001, S002, and S004 shows the same pattern: none of their recorded digests matches today's `.md` or HTML bytes. This is a corpus-wide **method/representation gap**, not evidence that S003 changed. The old digest is therefore retained as historic and is not usable as a drift detector.
- HTTP cannot pin the content: the `.md` `last-modified` equals request time and the HTML is `no-store` with a weak ETag. The only machine-readable stamp is `dateModified`/`lastmod` `2026-10-19T21:23:28.013Z`.
- That stamp is a **build stamp, not an editorial date** `[INFERENCE]`: the sitemap has 370 URLs, 275 unique `lastmod` values, 256 URLs dated 2026-10-19, with three URLs sharing each exact millisecond. It is same-day as the row's `opened`, so it cannot prove whether R21 read pre- or post-21:23Z bytes; today's text still carries both quotes, so the teaching survives regardless. Do not launder the build stamp into “page revised 2026-10-19”.

Expectation migration (append-only, no deletion):

- Old expectation: `opened` date + opaque digest.
- New expectation: `reopened 2026-10-20T21:33Z; GET /connect/get-started.md (rel=alternate text/markdown); sha256 66831901561602872d7dba73a4a0ed52fd374d6a6f62fb823ae4a78be17092c6; 14652 B; served WebPage dateModified 2026-10-19T21:23:28.013Z (batch build stamp, not editorial)`.
- Keep `opened 2026-10-19` and `7f6d3b49…` as the historic record; add, never replace.

Entry pin cross-check: at HEAD the entry hash/lines/bytes match `stamps.tsv` (`7635be81…`, 35, 6240), so the base pin was current; the live sibling append (`e885081e…`, 68, 8328) is uncommitted and will need re-stamping at integration. Not my edit.

## Superseding row decision

**Not needed.** No immutable field of S003 (scope, anchor, teaching, tier, status) is false; both quotes and the anchor still resolve. A superseding row would duplicate the source identity to change only an unrecorded digest method. The minimal honest fix is the append-only pin migration above. If integration policy nevertheless requires an in-row reproducible pin, the smallest supersede is:

> `| S003b | Get started with a 1Password Connect server — https://www.1password.dev/connect/get-started | docs | A | Connect deployment credentials versus client API tokens | §Deployment, Step 1 and Step 3; served WebPage dateModified 2026-10-19T21:23:28.013Z (batch build stamp) | Supersedes S003's unrecorded digest; same teaching. Quotes unchanged. Markdown alternate sha256 `66831901561602872d7dba73a4a0ed52fd374d6a6f62fb823ae4a78be17092c6` (14652 B, accessed 2026-10-20); historic R21 digest `7f6d3b49…` retained as unreproduced. | mined | 2026-10-19 | 90d | corpus/knowledge/onepassword-machine-credentials.md |`

## Falsifier

S003 is falsified if a re-open shows Step 1 no longer states the credentials file carries the credentials needed to deploy the server, or no longer describes a separate access token for applications/services; if Step 3 no longer instructs a new token per application or service; if Step 1/Step 3 are renamed or removed so the anchor no longer resolves; or if the page gains a preview/beta/plan qualifier that contradicts a generally available setup. E1 item 3 is falsified independently if the final sentence continues to carry `[S003]` without an inference label or without a source that actually states the custody boundary.

## Limits

One page plus one linked feature page (`/connect/manage-connect`, not registered) were opened for adjudication; S001, S002, and S004 were fetched only to compare digests, and the sitemap only for revision metadata. No account, vault, CLI, or API call was exercised. No registry, entry, plan, or lane state was edited; no installs. Digest-method identification is bounded to the representations and transformations tested (`.md` bytes, raw HTML, tags-stripped HTML, read-header variants); the original R21 method remains unknown.

Report: `.ufo/waves/round-22/build/Source03.md`
