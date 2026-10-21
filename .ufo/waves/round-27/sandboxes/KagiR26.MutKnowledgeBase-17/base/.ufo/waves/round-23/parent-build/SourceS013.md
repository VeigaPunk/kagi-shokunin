# SourceS013 — row S013 provenance audit (Vault lease page)

Axes: **calibration / freshness / operability**. Read-only; own report is the only write.
No gate/handler/op/vault/host command was executed; no account, deployment, or target
execution. Public URLs only. No tool install or update was needed (system `curl`, `python3`).

## Revision and frozen state (observed)

- `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf` (round-22 non-author spot-check), working
  tree clean for `corpus/` (`git status --porcelain` showed only untracked `.ufo/waves/round-23/`,
  `plans/round-23.md`).
- `corpus/SOURCES.md` = `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`, 118 lines,
  23 rows (all43/all23 frozen population's source half).
- S013 row: `corpus/SOURCES.md:19`, row bytes `b9e834712b7b1b2a0e129b0efbc3cc659b34c17fde403869ffb237ad75cc15b9`
  — byte-identical to `git show d218603:corpus/SOURCES.md` (same sha256). Not mutated by any later seat.
- Superseding row: S023 at `corpus/SOURCES.md:29`; path/errata prose at `:35`, `:82–:102`;
  errata lesson `corpus/lessons/round-22-source-errata.md`.
- Prior seat evidence read (not re-run): `.ufo/waves/round-22/build/Source13.md`,
  `.ufo/waves/round-22/falsify/ReopenSource13.md`.

## Opens performed this seat (2026-10-21, all HTTP 200 unless stated)

| target | representation | bytes | sha256 |
|---|---|---|---|
| `https://developer.hashicorp.com/vault/docs/concepts/lease` | server-rendered HTML, content-decoded | 261,632 | `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802` |
| same URL, cache-busted `?cb=<epoch>` | same | 261,632 | `de5f88…` (byte-identical to above) |
| reader/text extraction of the same URL (host `read` tool) | extracted text | 7,354 (collapsed text) | `0e62e056…` (not a byte pin; representation differs) |
| `…/vault/docs/concepts/lease` content source: `web-unified-docs@28d67d3308eb58e3c64976d52f612f847bb62985` `content/vault/v2.x/content/docs/concepts/lease.mdx` | raw `.mdx` | 4,450 | `7e2129bfc100dabc5e0bd7341abcce27fdca6f7b539c706c8a178f568749c480` |
| `…/vault/docs/concepts/lease/` (trailing slash) | none (308 redirect, not followed) | 15 | — |
| `…/vault/docs/concepts/lease.md` | none (404) | 5,496 | — |
| `…/vault/docs/v1.21.x/concepts/lease` (pinned track) | server-rendered HTML, decoded | 262,620 | `7c18d310a9c73a1aaa9d76b4128a0a957cff0ce08473c967e0d05ab062d7d048` |
| Wayback CDX `from=20261001&to=20261021` | — | — | no capture; newest is `20261007185112` |

Response headers (first fetch): `etag: W/"mhehieftta5lvi"`, `x-vercel-cache: HIT`,
`age: 38317`, `date: Tue, 20 Oct 2026 17:04:06 GMT` (cached-object time, not a page revision),
`content-encoding: br` (wire 40,416 B vs decoded 261,632 B — byte-count ambiguity for C2).
No visible "last updated" text (`grep -ci 'last[ -]?updated'` = 0); machine dates exist:
JSON-LD `datePublished` = `dateModified` = `2026-04-15T00:14:52.000Z` on v2.x; the v1.21.x track
carries its own `dateModified` = `2025-10-22T20:53:42.000Z`.

Quotes (≤25 words each, all verbatim, heading + access date 2026-10-21 + URL above):
- §Lease, renew, and revoke: “All dynamic secrets in Vault are required to have a lease.” (11 words)
- §Lease, renew, and revoke (KV note, last intro paragraph before §Lease IDs): “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration” (20)
- §Lease, renew, and revoke: “When a token is revoked, Vault will revoke all leases that were created using that token.” (16)
- §Lease durations and renewal: “The requested increment is completely advisory.” (7)
- page chrome (aria-label): “Choose a Vault Documentation version. Currently viewing v2.x (latest).” (8)

## Row verdict, field by field

| S013 field | verdict | evidence |
|---|---|---|
| `scope` = “dynamic-secret and service-token lease lifecycle; static KV exception” | SUPPORTED WITH QUALIFIER | Page says "`service` type authentication token" and the KV note’s lease-duration caveat. Page contains 0 occurrences of `static`, `batch`, `token type`; "static" is the author’s gloss. |
| `anchor` = “§Lease, renew, and revoke; current Vault docs have no displayed version/date, opened 2026-10-19” | **PARTLY REFUTED (version half); date half true only as "no rendered date"** | Server-rendered HTML carries the disclosure `Choose a Vault Documentation version. Currently viewing v2.x (latest).` and a versions JSON declaring `{"name":"latest","label":"v2.x (latest)","isLatest":true,"releaseStage":"stable"}` plus pinned `v1.21.x`. No rendered last-updated text, but JSON-LD dates exist. |
| `teaches` clause 1 (leases required for dynamic secrets) | SUPPORTED | 11-word quote above; verbatim. |
| `teaches` clause 2 (“distinguishes static KV values from leased data”) | SUPPORTED WITH QUALIFIER | KV note above; supports *no lease on KV*, not retention/write-only mutation. |
| `quote` | SUPPORTED, verbatim, ≤25 words | 11 words by computation. Note: `.ufo/waves/round-22/build/Source13.md` and `falsify/ReopenSource13.md` both record "9 words" — a miscount; the bound holds either way, but word counts must be computed, not hand-copied (C2 `quote bound` check should recompute). |
| `tier A` | SUPPORTED | Vendor’s own product documentation, no entitlement gate, quote located. |
| `status mined` | SUPPORTED (convention) | Superseded rows keep `mined` (S006/S007/S012 precedent); S023 (`:29`) supersedes only the locator, and the used-by entry still cites S013 on its single `source:` line. |
| `used-by` = `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | POINTER VALID; target carries a live unresolved inversion | Entry line 3 cites S013; line 19 leases row correct; line 20 and lines 84–85 still read "only a write does"/"nothing expires", while erratum line 110 claims the bullet "reads accordingly: a KV read carries no lease" — the bullet was never rewritten. Already documented in `build/Source13.md`; persists at `a5e1c13e`. |
| `Fetch sha256: ae3215…` | **UNREPRODUCIBLE / CONTRADICTED elsewhere** | See F1. Matches none of: decoded HTML (`de5f88…`), tag-stripped text (`0e62e0…`/lower `a1d66f…`), `.mdx` (`7e2129bf…`), v1.21.x page (`7c18d310…`); `.md` alternate is 404 and Wayback has no 2026-10-01→21 capture, so the 2026-10-19 bytes cannot be reconstructed. |

Supersession check: S023’s withdrawal of the “no displayed version” locator is **warranted** and
its two scope limits (served v2.x route ≠ deployment proof; no KV retention guarantee) are
correct against observed bytes. The closure spot-check (`corpus/lessons/round-22-verifier-spotcheck.md:105`)
re-opened this page and agreed; my independent measurement adds the exact selector string, the
per-track `dateModified` values, and the URL-variant/representation facts below. No admission or
verdict is claimed here — recommendation only.

## C2 expectation spec for S013 (for the planned `source-fetches.tsv` / `SC_FETCH`)

Exact, as observed (use decoded bytes, never wire bytes):

| field | expected value for S013 |
|---|---|
| `source_id` / `url` | `S013` / `https://developer.hashicorp.com/vault/docs/concepts/lease` (exact canonical from the page’s own `canonical` meta; the trailing-slash form is a 308, so URL equality must normalize `/` before comparing) |
| `fetch_date` | `2026-10-21` (this reopen); `digest_observed_at 2026-10-20` already stands in `corpus/feature-claims.json:80–85` |
| `representation` | `rendered-html/decoded` (mandatory enum; `.md` alternate is 404, so no markdown representation exists) |
| `bytes` | `261632` (decoded body; the same response is 40,416 B on the wire with `content-encoding: br` — a bare numeric byte check will fail if the column is not representation-qualified) |
| `sha256` | `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802` (64-hex shape; reproduced twice today and equal to the 2026-10-20 capture) |
| secondary content pin | `content/vault/v2.x/content/docs/concepts/lease.mdx` @ `28d67d3…`, 4,450 B, `7e2129bf…`, front matter `last_modified 2026-04-15T00:14:52Z` — chrome-independent semantic anchor |
| revision descriptor | displayed `v2.x (latest)`, `releaseStage: stable`, newest pinned `v1.21.x`; JSON-LD `dateModified 2026-04-15T00:14:52.000Z` (no rendered date) |
| `quote` + `location` | “All dynamic secrets in Vault are required to have a lease.” (11 words) at §Lease, renew, and revoke; **plus** a second quote for the KV clause (20-word KV note above) since S013’s `teaches` has two clauses and one quote cannot cover both |
| historical value | `ae3215…` must be retained as **superseded/historical**, not restamped, with `prior_registry_sha256` semantics |

One real contradiction, exactly: `corpus/SOURCES.md:19` states `Fetch sha256: ae3215…` for this URL
while `corpus/feature-claims.json:83–84` states `sha256: de5f88…` with
`prior_registry_sha256: ae3215…` for the same URL. The round-23 plan’s fail-closed check
(`plans/round-23.md:20–31`) accepts “in-row `Fetch sha256:` **or** a complete provenance row …
digest shape”, and `corpus/sources-census.sh` currently contains zero matches for `Fetch` or
`sha256` (grep, this seat) — so, [INFERENCE from the plan text; the checker is not yet implemented],
a shape-only `SC_FETCH` would pass S013 on `ae3215…`, certifying a
digest the repository itself records as prior and unreproducible, while a new TSV row would carry
`de5f88…` with no check that the two disagree. Fix: make the TSV row authoritative for the URL, and
fail `SC_FETCH` when an in-row digest differs from the TSV digest unless the in-row value is
explicitly marked historical/superseded.
Synthetic minimal failing fixture proposal for L1 (do not add as a passing case): a fixture tree
whose `SOURCES.md` mined row carries `Fetch sha256: <64 hex A>` and whose
`source-fetches.tsv` row for the same id/URL carries `sha256: <64 hex B>` (both shape-valid, same
URL, quote and location present) must exit 1 with an `SC_FETCH` finding naming the digest
disagreement; the paired passing control uses one shared digest. Not executed here.

## Findings by severity

**F1 — High (freshness/operability, C2).** Registry digest `ae3215…` is unreproducible and
contradicts the committed provenance record (`de5f88…`); the planned shape-only `SC_FETCH` would
bless it. Fix as specified above; then S013’s operative digest lives in the TSV and the in-row value
becomes an explicit historical statement.

**F2 — Medium (calibration/freshness).** S013’s anchor clause “current Vault docs have no displayed
version/date” is false on the version half in the server-rendered representation; it was a
text-extraction artifact (the host `read` extraction drops the selector). S023 (`:29`) already
withdraws the locator — warranted. Recommend the operative descriptor elsewhere carry the exact
selector string and JSON-LD `dateModified` so the URL has one revision descriptor; note the v2.x and
v1.21.x tracks differ in `dateModified` (2026-04-15 / 2025-10-22) while the article text slice
(“With every dynamic secret” → “Edit this page”, tag-stripped, whitespace-collapsed) is identical on
both: 3,892 chars, sha256 `1bf218c5adbcdc6e19f8c537315338ef3be6ee491cc69b45d6baf4685c372c7c` (measured this seat).

**F3 — Low (calibration), already routed.** The used-by entry’s line 84–85 bullet vs erratum line
110 pointer inversion persists unchanged; it is documented in `build/Source13.md` and the
product-separated erratum is authoritative, but a reader of the bullet still sees the unsupported
“only a write does”. Recommendation for L1: land the proposed append-only correction rather than
rewriting the bullet.

**F4 — Low (operability).** S013/S023 share one URL (as S012/S022 do). A per-row TSV creates
duplicate-URL rows; assert same-URL digests agree, or key provenance by URL with a row-id list —
otherwise “URL equality” passes while one URL carries two operative digests.

**F5 — Low (operability).** One ≤25-word quote cannot cover S013’s two-clause `teaches`; allow a
second quote/location per provenance row.

## Limits and verification gaps

- I did not run `corpus/sources-census.sh`, `closure-dispositions.py`, `feature-claims.py`, or any
  gate/handler (contract); census behaviour above is read from its source and the plan, not executed.
- I did not re-fetch Wayback capture bodies (only CDX availability), did not open the Vault KV
  backend page or the KV v2 API (leads, not evidence), and did no Vault/OpenBao runtime, account, or
  API operation.
- `de5f88…`/`7c18d310…`/`7e2129bf…` are point observations of today’s served bytes; the digest for
  2026-10-19 (`ae3215…`) cannot be reconstructed because its representation/method was never recorded
  and no archive covers that date. No claim is made that the page’s semantic content changed.
- Deployed-product proof: none exists and none is claimed; the page is vendor documentation at a
  docs track (`v2.x (latest)`, `releaseStage: stable`) and names no Vault binary version. The page
  is silent on batch tokens and token TTL (0 occurrences of `batch`, `token type`), so S013 supports
  no such claim and no OpenBao/cross-product claim.
- Reported to `agent://KagiR23`: the F1 digest contradiction (registry vs `feature-claims.json`),
  since it directly affects the planned C2 checker.
- Write disclosure: besides this report, the seat saved its public fetches as five scratch files in
  `/tmp` (`s013-a.html`, `s013-b.html`, `s013-c.html`, `s013.mdx`, `s013-hdr.txt`). It deleted them
  before finishing. The other `/tmp/s013*` files (`s013.html`, `s013.txt`, `s013b.html`) were not
  created by this seat and were left untouched.
- Tools: none installed or updated; used the system `curl` and `python3`.