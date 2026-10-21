# SourceS021 — provenance audit of row S021 (OpenBao token lifecycle, product-bound review)

Seat: `SourceS021`, reviewer, leaf. Read-only. This report gives advice only. It does not admit, judge or integrate anything. Axes: calibration, freshness, operability.
Tools installed or updated: **none** (curl, python3 and the read tool were already present).

## 1. Observed revision and inputs

- **Frozen base:** `d218603b74099ddca0bd8f869516fc41db0979bf` (`plans/round-23.md:3`).
  - `git show HEAD:corpus/SOURCES.md` has sha256 `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30` and 118 lines.
  - S021 is at `:27`.
  - The S021 row line has sha256 `b5206c177a460aa8027e5b9507537d934252b92219989db69d0febabd8cf332e`. This value is identical at its introducing commit `8ada17a` and in the working tree, so the row bytes have never changed.
- **Pointed files at HEAD, all with clean working copies:**
  - `corpus/knowledge/feature-bound-credential-review.md` has sha256 `53a24710…` (60 lines / 5386 bytes). This equals `corpus/stamps.tsv:20`.
  - `corpus/lessons/round-22.md` has sha256 `0bb9d105…` (270 lines / 21481 bytes). This equals `stamps.tsv:47`.
  - `corpus/feature-claims.json` has sha256 `a66acbfb…`.
  - `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` has sha256 `4932f37f…`.
- **In-flight L1 tree (not frozen):** the production tree changed while this audit was running.
  - SOURCES.md went from 118 to 121 lines (S024–S026 added).
  - New or modified: `corpus/source-fetches.tsv`, `corpus/sources-census.sh`, `corpus/lessons/round-23.md`, `corpus/closure-dispositions.*`.
  - Snapshot cited below, taken at 2026-10-21T03:57Z:
    - `source-fetches.tsv`: `ccc9ae6e0b4f…`
    - `sources-census.sh`: `4e60d5e0…`
    - `round-23.md`: `d5520988…`
  - An earlier snapshot of `source-fetches.tsv`, `e2f40132…`, enforced a same-URL normalized-digest agreement rule. The 03:57Z census has dropped that rule.
  - Everything I say about the in-flight tree is pre-integration advice and may already be out of date.

## 2. What I opened (public and read-only, 2026-10-21 UTC)

| target | result |
|---|---|
| `https://openbao.org/docs/concepts/tokens/` (read tool, rendered) | 200 |
| same URL, curl identity GET ×2 (03:42:55Z, 03:48:16Z) | 200. Both bodies byte-identical: sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`, 47384 B. `ETag "6ad71d3a-b918"`; `Last-Modified: Tue, 20 Oct 2026 07:50:18 GMT`. The ETag decodes to mtime 2026-10-20T07:50:18Z and size 0xb918 = 47384. |
| same URL with `Accept-Encoding: gzip` | 200. Wire body 12527 B, sha256 `5ae6661f…`, weak ETag `W/"6ad71d3a-b918"`. The decoded body is the same `5229521…`. |
| `…/docs/concepts/tokens` (no slash) and `http://…/` | 301 to the canonical slash URL on https |
| `/docs/2.7.x/concepts/tokens/` | **404**. Today there is no version-pinned 2.7.x route. |
| `/docs/2.6.x/concepts/tokens/` | 200. `/docs/next/concepts/tokens/` is also 200. |
| GitHub raw `release/2.7.x/website/content/docs/concepts/tokens.mdx` | 200. 15269 B, sha256 `f05ae2ba…`, git blob `5849b188fb7aac8223563e2ff181637a2de88d26`. The last commit touching the file is `ec6ba09f484bf01d5892e3bcac63084127be2f27` (2026-08-10). |
| GitHub API: `release/2.7.x` head | `720135eda5b60d20b0f0a251dc9d429c965b5f8f` (2026-10-15). This was also the head at the 2026-10-20 deploy. The same blob `5849b188…` is at that commit. |
| GitHub: `website/Makefile`, `docusaurus.config.ts`, `doc-versions.json`, `.github/workflows/docs-deploy.yml` | read |
| GitHub Actions runs for `docs-deploy.yml` | Run 2026-10-20T07:47:26Z–07:50:41Z was triggered by main `edf79a4e31833b5b7ba37197fea1196e73b0c115`, which modified only `website/content/docs/audit/index.mdx`. |
| GitHub releases | Latest is v2.7.1 (2026-10-01). v2.7.0 was released 2026-09-23. Nothing has been released since S021 was opened (2026-10-20). |
| archive.org CDX and `id_` capture `20260918031712` of the exact URL | 200. Gzip body 12493 B, decoded to 47121 B, sha256 `e721ea7e…`. |

Failures: none apart from the 2.7.x-route 404 above. I opened every target I list; none was skipped.

## 3. Field-by-field check of S021 (`corpus/SOURCES.md:27`) against the public page

Quote used for this source, under §Token Time-To-Live, periodic tokens, and explicit max TTLs, opened 2026-10-21 at https://openbao.org/docs/concepts/tokens/: “After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked.” The version badge reads “Version: Version 2.7.x”.

| field | row value | observation | verdict |
|---|---|---|---|
| source / URL | `https://openbao.org/docs/concepts/tokens/` | Canonical and `og:url` are equal to it. The no-slash and http forms 301 to it. | supported |
| kind / tier | docs / A | Official OpenBao documentation (meta-author is the LF project). A fits the scoped documented behaviour; it does not cover deployed behaviour. | supported |
| scope | service-token TTL and associated leases; no Vault-token or KV-retention claim | §Token types states that the following sections apply to service tokens. The TTL sentence quoted above includes the lease clause. I swept the whole rendered page: “Vault” and “KV” do not appear. | supported |
| anchor | Token Time-To-Live…; Token type comparison; Version 2.7.x, opened 2026-10-20 | Heading ids `token-time-to-live-periodic-tokens-and-explicit-max-ttls` and `token-type-comparison` are present, as is the badge. The row omits `#token-types`, which carries the service-token qualifier its scope depends on. | supported, slightly under-cited (round 22 already raised this for the review header as F3, so I am not raising it as new) |
| teaches | non-root TTL and service-versus-batch limits require OpenBao evidence; no Vault/KV inference | The non-root TTL sentence is present. The comparison chart marks batch tokens as not renewable, not manually revocable and fixed-TTL. No Vault or KV content. | supported |
| status / used-by | mined; `round-22.md`, `feature-bound-credential-review.md` | Both files cite S021 on their `source:` field (`round-22.md:2` as a continuation line; `feature-bound-credential-review.md:1`). Both use it in the body (`round-22.md:21`; `feature-bound-credential-review.md:19`). Both match their stamps. | supported |
| opened / recheck | 2026-10-20 / on-release | No OpenBao release since then, so a recheck is not due. | supported; see the residual risk in §7 |

`feature-bound-credential-review.md:19` (the OpenBao service-token row) holds against the current page. It does not overclaim and it keeps the service/batch split.

`round-22.md:21` says the leases appear in the “following sentence”. In fact they are the continuation of the same sentence after the dash. This was already corrected by appended text at `round-22.md:127-129` and `vault-openbao-token-lease-lifecycle.md:172-175`, so it is history, not a defect still in force.

**Supersession.** At the frozen base, no row supersedes S021 and S021 supersedes nothing. Its URL is shared with S016, which is a separate active row with a different scope (parent revocation) and an undocumented-representation digest `c083fdca…`.

In the in-flight tree, S026 (same URL) supersedes S016 only, so S021 stays the active product-bound TTL row. S026's scope cell names “TTL, renewal” without S021's service-token qualifier. L1 should decide whether S026 should cite S021 for TTL or carry the qualifier itself.

## 4. Four things kept separate

1. **Historical bytes.**
   - The S021 row bytes are unchanged since `8ada17a`.
   - `feature-claims.json:197-219` pins S021 at `5229521…`, observed 2026-10-20. I reproduced it twice on 2026-10-21, with the same ETag and Last-Modified.
   - `prior_registry_sha256 c083fdca…` is S016's 2026-10-19 point observation. It is not part of S021's own history and is not evidence of drift.
2. **Current semantic support.**
   - Every S021 claim is present on the page as of 2026-10-21.
   - The article text is identical across all of these once the version label is swapped:
     - 2.7.x
     - 2.6.x
     - Development (`/next/`)
     - the 2026-09-18 capture of the same URL
   - Nothing upstream is pending for this text in the Development docs as of today.
3. **Volatility of the raw-HTML digest.**
   - The raw HTML is tied to deploys, not to content. Every push touching `website/**` on main or `release/**` re-runs `docs-deploy.yml`, and the Makefile rebuilds every version by pulling `release/<v>` at build time.
   - The current Last-Modified matches the deploy for main `edf79a4e…`. That commit edited only the audit page; this page's MDX has been unchanged since 2026-08-10.
   - The digest does not depend on content-coding: identity and gzip-decoded bodies are the same.
   - I have no pre-deploy capture with a documented representation, so I make no claim about this page's bytes changing between deploys.
4. **Proof of the deployed product.** None. “Version 2.7.x” is a documentation-family label, not a binary. Latest release is v2.7.1. No OpenBao server, vault, account or host was contacted.

## 5. What C2 provenance for S021 should record

- **URL / final URL / status:** exactly `https://openbao.org/docs/concepts/tokens/`, 200, no redirect (the no-slash form is a different, 301 URL).
- **Representation:** the decoded entity body, `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` / 47384 B. This is valid only for the deploy epoch `ETag "6ad71d3a-b918"` / `Last-Modified 2026-10-20T07:50:18Z`. Recording ETag and Last-Modified would make the epoch checkable.
- **Quote:**
  - Use the 20-word TTL sentence above (ASCII `--`), under heading id `#token-time-to-live-periodic-tokens-and-explicit-max-ttls`.
  - It is **not** a raw-byte substring: the raw HTML has line breaks after “the” and “associated”. It matches only after normalization.
  - The 12-word quote at `round-22.md:21` and the `S021-ttl` / `S021-service-scope` quotes in `feature-claims.json` behave the same way. `S021-nonroot-ttl` is a raw-byte substring.
- **Normalization:** `rendered-text-v1` *with trimming of both ends* gives `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` (14571 chars). Without the trim it gives `f094ef74…` (14573). The in-flight spec now includes the trim, and my independent computation confirms its recorded value.
- **Revision:**
  - The URL is a moving ref (see §6). The content revision is `release/2.7.x` `720135eda5b60d20b0f0a251dc9d429c965b5f8f` (file blob `5849b188…`).
  - The page chrome comes separately from main, at `edf79a4e…` for this epoch.
- **In-flight `source-fetches.tsv:41` (S021):** I re-derived each of the following and it matches:
  - `row_identity_sha256` `c921ab09…`
  - URL, status 200, digest and byte count
  - quote (20 words) and `ed949658…`
  - The only difference is `revision` = `-`.

## 6. The one real contradiction

**The in-flight C2 tree treats S021's URL as a fixed ref, but the URL is observably a moving version route.**

- **Evidence.**
  - The archive.org `id_` capture `20260918031712` of the exact URL carries the badge “Version: Version 2.6.x”, Docusaurus class `docs-version-2.6.x` and edit link `release/2.6.x`. Today the same URL serves 2.7.x.
  - `/docs/2.7.x/concepts/tokens/` is 404.
  - `doc-versions.json` and `docs-deploy.yml` show the route moves whenever a version is added.
- **What it contradicts.**
  - The schema defines `revision` as a 40-hex value for a moving-ref URL (`source-fetches.tsv:24`).
  - The census detects moving refs only by URL pattern: `raw.githubusercontent.com` or `/main/` (`sources-census.sh:269-270`). So S021, and S026 on the same URL, pass with `-`.
  - The S021 row's own anchor names a version family (2.7.x) that its URL does not contain.
- **Same root, in the documentation.**
  - `source-fetches.tsv:19-21` still calls the normalized digest “the stable declared identity” and describes same-URL raw agreement.
  - `round-23.md:61` still says SC_FETCH enforces same-URL agreement.
  - The current census header (`sources-census.sh:64-67`) says no cross-capture equality is enforced because chrome changes.
  - Measured for S021: `rendered-text-v1` includes about 1503 chars of chrome (14571 total vs 13068 for the `<article>` text). The 2026-09-18 same-URL capture normalizes to `6a77cb9c…` (14531), not `ed949658…`, even though the article is identical apart from the label. The chrome differences include a removed “Version 2.4.x” dropdown entry and a reordered sidebar.
- **Fix (L1 decides).**
  - Require a revision when the registry anchor names a version family the URL lacks. For S021, set it to `720135eda5b60d20b0f0a251dc9d429c965b5f8f`.
  - Change the TSV header and `round-23.md:61` to “point attestation; no same-URL or cross-capture equality”.
  - Keep `S021-version` as the version witness.
  - If a stable identity is wanted, define an article-scoped normalization. The version badge sits inside the article, so a version flip would still show up in it.

## 7. Secondary findings (low)

- **C1 pointer coverage.** The second clause of round-22 D7 (`round-22-verifier-spotcheck.md:180-181`) says the §Gate prose “S017–S020 added” at `round-22.md:23` leaves out S021. The in-flight `closure-dispositions.json` D7 entry is `fixed` with the single pointer `corpus/source-fetches.tsv`, which fixes only the digest half. Following that pointer does not reach the stale-prose half; within the frozen tree, only the later `round-22.md:89` touches it.
- **Freshness of the recheck trigger.** `on-release` misses documentation-only pushes to `release/2.7.x`. `docs-deploy.yml` redeploys on `release/**` + `website/**` without any release tag. Consider `on-release or on a release/2.7.x tokens.mdx commit` (detectable through the public commits API using a path filter).

## 8. Synthetic minimal failing fixture (proposal for L1; not run)

- **Registry row:** `| S001 | Doc one — https://example.invalid/docs/concepts/tokens/ | docs | A | topic one | §TTL; Version 2.7.x, opened 2026-10-21 | teaches one | mined | 2026-10-21 | on-release | corpus/knowledge/e1.md |`
- **Provenance row** (TAB-separated):
  - `S001`
  - `mined`
  - `5b69289691a8b091a47a2f476a820d71b65f9e7e4933aa29f3292f0cc376f0b2`
  - `https://example.invalid/docs/concepts/tokens/` (url)
  - same as url (final_url)
  - `200`
  - `curl-fsSL-compressed-v1`
  - `2026-10-21`
  - `decoded-http-body-volatile-v1`
  - `c66b2b1b3ba89a39c4715f66d210652a4d76c6541ddf7cb5fe9944b569015f7a`
  - `113`
  - `-`
  - `alpha beta gamma.`
  - `rendered-text-v1`
  - `dbbb9db6aa07541bd81d57ccd1421a13178ae5bf6b7f9c5df7f801318c83a5c4`
  - `TTL section`
- **Synthetic page the digests come from:** `<html><body><nav>Version 2.7.x</nav><article><h2 id=ttl>TTL</h2><p>alpha\nbeta gamma.</p></article></body></html>\n`.
- **Expected result after the fix:** `FINDING SC_FETCH id=S001 moving-ref-revision`, exit 1. With any 40-hex revision in place of `-`, the control comes out CLEAN.
- **Expected result with the current code:** no finding. I got this by reading `sources-census.sh:269`, not by running it.
- **Twin page for chrome coupling:** the same page with nav `Version 2.8.x Version 2.7.x`, same article. It normalizes to `0a839dca…` instead of `dbbb9db6…`. This shows normalized digests from different epochs must not be compared.

## 9. Limits

- I ran no gate, census, selftest or handler, and I make no pass claim.
- archive.org is a third-party archive; I used its `id_` original bytes only as dated evidence.
- I did not audit the other rows; S016 and S026 were read only for supersession.
- I copied no example credential strings from the page.
- Checks L1 should run after integration: `bash corpus/sources-census.sh` and `--selftest` (with the proposed case), and `python3 corpus/closure-dispositions.py`.
