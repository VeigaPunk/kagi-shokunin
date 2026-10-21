# SourceS023: provenance audit of exact row S023, Vault lease page (read-only, advisory)

Axes: calibration, freshness, operability. This report is a recommendation from the row owner. It does not admit anything, issue a verdict, or re-curate any row. I made no production edits; the only file I wrote is this report.

## 1. Observed revision

**Frozen start (before round-23 changes)**

- Git `HEAD` was `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20T21:11:59-03:00).
- `corpus/SOURCES.md`: `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`, 118 lines / 22,843 B. This equals `corpus/stamps.tsv:61`.
- **S023 is at `corpus/SOURCES.md:29`.** Line sha256 `9863fb49ce8b1356b726020cd011081510915f371a7473db2906b945739f1f5b`. The line was introduced in `4be5da3` and is byte-equal at `HEAD`.
- Used-by file `corpus/lessons/round-22-source-errata.md`: `20e9bb06096d1e5819feab755df9bee1b7244efcf21834e212d8fa0ef26097c2` (44 lines / 3,674 B). This equals `stamps.tsv:48`.
- Unchanged throughout the audit:
  - `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` `4932f37f…`
  - `corpus/feature-claims.json` `a66acbfb57181bc12582e685e7b33510e74415fb7bfa80a08ea76d240138449b`

**In-flight L1 integration, observed 2026-10-21 03:54:03Z → 04:02:36Z**

| file | earlier hash | later hash | what changed |
|---|---|---|---|
| `corpus/SOURCES.md` | — | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` (121 / 24,995 B) | S024–S026 appended. **The S023 line is still `9863fb49…`, unchanged.** |
| `corpus/source-fetches.tsv` | `e2f40132…` (S023 at `:42`) | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` (S023 at `:43`) | — |
| `corpus/sources-census.sh` | `bf56b1a4…`, then `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` (03:58:45Z–03:59:40Z) | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` (04:02:36Z) | see F1 |
| `corpus/lessons/round-23.md` | `e8821701…`, then `d5520988…` | `88d0c7dcd9ecd9fdc03177534cad88cf6e5ed7e8723be0a69425db034ea2fc56` (04:03:49Z) | — |
| `plans/round-23.md` | — | `cb1287ba…` | — |

In-flight statements below carry these hashes and times. They may have changed since.

## 2. Pages opened (2026-10-21, anonymous public GETs; none failed)

**1. Canonical URL** `https://developer.hashicorp.com/vault/docs/concepts/lease`

- HTTP 200, `text/html; charset=utf-8`, **261,632 B decoded**, sha256 `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802`.
- The bytes were identical across all of these requests:
  - default curl ×3;
  - `Accept: text/html`;
  - a Firefox user agent;
  - a Chrome user agent with `Accept-Language: en-US`;
  - `Accept-Language: de-DE`;
  - `--compressed`;
  - the TSV's declared profile (`-fsSL --compressed` plus its user agent), which transferred 40,416 B on the wire.
- Cache headers:
  - `etag "mhehieftta5lvi"` (weak `W/` when compressed);
  - `date: Tue, 20 Oct 2026 17:04:06 GMT`;
  - `age` 38,748 → 39,056;
  - `x-vercel-cache: HIT`;
  - `x-matched-path: /vault/docs/[...page]`.
- `/lease/` returns a 308 redirect to the canonical URL. `<link rel=canonical>` equals the registered URL.

**2. Reader view (the `read` tool)**

- The H1, the KV note and the GitHub edit link are present.
- **No version switcher is shown.** This matches errata lesson lines 22–23.

**3. Content source: `hashicorp/web-unified-docs`, path `content/vault/v2.x/content/docs/concepts/lease.mdx`**

- At `main` and at `7893d59cfd1097cf1f7853bbe66a1541bede088e`: HTTP 200, 4,450 B, sha256 `7e2129bfc100dabc5e0bd7341abcce27fdca6f7b539c706c8a178f568749c480`.
- Contents-API blob: `ed9054405118822f32f70c4531d3a34f5e61ca55`.
- The commits API shows **exactly one commit on this path**: `7893d59…`, 2026-04-15T00:13:42Z, "Remove rc tag".
- `main` HEAD was `28d67d3308eb58e3c64976d52f612f847bb62985` (2026-10-20T16:46:38Z).

**4. v1.21.x source (`content/vault/v1.21.x/…/lease.mdx` on `main`)**

- HTTP 200, 4,452 B.
- **The body after front matter is byte-identical to v2.x:** sha256 `2cb1ca0ce756931c4c869591f8b1c44a22c8d328a50a75ae8f9534a512aa060f`, 4,118 B.
- Only the auto-generated `created_at`/`last_modified` fields differ.

**5. Wayback CDX (captures since 2026-09-01)**

- Two captures exist. Both raw (`id_`) fetches returned 200:
  - `20260923011338`: 244,806 B, sha256 `6307873add48e968dd6791fb641abdb90b0acc6a283cb37cddbd54a082c8a946`.
  - `20261007185112`: stored gzip; decoded 245,553 B, sha256 `6d7203361325397e9b5ab2a65ac13f9d50d9ab681b61a512d37503c23e45862f`.
- **There is no capture on 2026-10-19.**

**6. Vault release API (`api.releases.hashicorp.com`)**

- Newest entries: the 2.2.0 family, GA (non-prerelease) from 2026-10-15T16:17:57.396Z.
- 2.2.0-rc1: 2026-10-08.
- 2.0.0 GA: 2026-04-14T20:08:55.580Z.

**Not reopened:** the `.md` alternate route (the prior round reported a 404).

## 3. Row S023 verdict (`corpus/SOURCES.md:29`)

| field | verdict | evidence |
|---|---|---|
| URL / kind `docs` / tier A | SUPPORTED | The vendor's own documentation, with no login gate. Canonical URL matches exactly. |
| scope (dynamic-secret/service-token leases; static-KV no-lease note; version-route locator only) | SUPPORTED | The H1 intro says leases are created for dynamic secrets and for `service`-type auth tokens. "Service-token" is a fair gloss of that. The KV note is present. |
| anchor | SUPPORTED | Exactly one H1, "Lease, renew, and revoke" (`id="lease-renew-and-revoke"`). The KV note is the last `<p>` before `<h2 id="lease-ids">`. The edit-link href ends in the row's exact path. Its link text extends the row's paraphrase "Edit this page" with "on GitHub". |
| teaches: withdraw S013's categorical no-displayed-version locator | SUPPORTED | The served HTML shows the version-switcher button with the `v2.x` track flagged `isLatest:true`. It appears twice in rendered text, but not in the reader view. Newest pinned track: `v1.21.x`. S013's *date* half still holds: there is no visible date, only JSON-LD dates (`2026-04-15T00:14:52.000Z`). S023 rightly withdraws only the version half. |
| teaches: route is not deployment proof and not a KV retention guarantee | SUPPORTED | See §4. The KV note makes no retention statement. In-flight S024 (KV v2 version-deletion parameters, not audited here) is consistent with this. |
| status `mined`, used-by `corpus/lessons/round-22-source-errata.md` | SUPPORTED | The lesson's `source:` line cites S023. Its Gate row (`:18`) quote is verbatim under rendered text, 20 words. |
| opened 2026-10-20, recheck `on-release` | SUPPORTED / FRESH | No Vault release has appeared since S023 was opened (newest is 2026-10-15). The source file is unchanged since 2026-04-15. The article slice is unchanged across three dated captures (§4). |

**Located quote.** Section H1 "Lease, renew, and revoke", Note paragraph, observed 2026-10-21, https://developer.hashicorp.com/vault/docs/concepts/lease:

> “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration”

**Supersession.** S023 supersedes only S013's locator. S013 (`:19`) is untouched and keeps its legacy pin `ae3215…`. That pin belongs to the S013 owner (`SourceS013.md` F1) and is not re-audited here.

## 4. Four kinds of evidence for this URL, kept separate

**Historical bytes**

- S013's in-row `ae3215…` (2026-10-19) has no recorded representation. I tried 20 candidate representations of today's page (raw, stripped, and 16 text normalizations, with and without lowercasing, trimming and a trailing newline) plus both source tracks. None matched.
- No Wayback capture exists for that day.
- [INFERENCE] It is probably an earlier CDN object, from before the `17:04:06Z` regeneration. It can only be history, never an expected value.
- The Wayback captures `6307873a…` (2026-09-23) and `6d720336…` (2026-10-07) are also history.

**Current support for the content**

- **The article slice is identical in all three captures (2026-09-23, 2026-10-07, 2026-10-21).** I took rendered-text-v1 from the first `<h1 ` up to the `<a` that opens the GitHub edit link. Its sha256 is `ebe088de2f2f87b7f7beac8784b0f14f58880061ac657f4a14a9fd6711ac9c0e` (3,916 chars) each time.
- The source blob `ed90544…` is unchanged since 2026-04-15.
- The KV quote and the dynamic-secrets sentence each occur exactly once in rendered text.
- In raw bytes, the KV quote occurs **zero** times, because "Key Value Backend" sits inside an `<a>` tag. In the raw MDX it also occurs zero times, because of the link markup and line wrapping.

**Transport and raw-HTML volatility**

- The three dates give three different raw digests and sizes, all under one Next.js `buildId`, `build-TfctsWXpff2fKS`.
- The whole-page rendered-text-v1 digests also differ:

| capture | rendered-text-v1 sha256 | chars |
|---|---|---|
| 2026-09-23 | `d9df70141aa04c7dd84bf974cd7ecb4846a37c52812d83a7f8c38da43ec7e7fd` | 6,623 |
| 2026-10-07 | `80d6c61dec61b0f480f1d07e15dd6a3d0450d4a60bb77c3e0463d009dde6a666` | 6,643 |
| 2026-10-21 | `0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76` | 7,354 |

- From 2026-10-07 to 2026-10-21, the only differences are page chrome: a new top-menu product block, a new navigation section label, and a new SCIM-provisioning sidebar item.
- Every "reproduction" on 2026-10-20 and 2026-10-21 hit the same CDN object (same etag, same `date` header). This includes the round-22 Source13 capture (age 16,541), mine, and the TSV's. **So "reproduced" here does not mean the page renders deterministically.**

**Proof of a deployed product: none**

- The docs label is a rolling major-version track.
- The v2.x path appeared about 4 h after 2.0.0 GA, via "Remove rc tag".
- JSON-LD `dateModified` is directory metadata, not a content edit; the body equals v1.21.x.
- Public 2.2.0 GA binaries exist, but that says nothing about any host. The used-by knowledge entry (`:76–78`) says kagi runs neither product.

## 5. C2 provenance expectations for S023

| field | expected for S023 | in-flight `source-fetches.tsv:43` | verdict |
|---|---|---|---|
| id / status / `row_identity_sha256` | `S023` / `mined` / sha256 of `S023\tmined\t<url>\n` = `131e6a2015a202cebc9305a0943b4d62d66de343bfc97e2211ad7fc66cfed5b2` | same | ✓ recomputed |
| url / final_url / http_status | registered URL, no redirect, 200 | same | ✓ |
| request_profile / fetched | `curl-fsSL-compressed-v1` / 2026-10-21 | same | ✓ reproduced with the declared user agent |
| representation | `decoded-http-body-volatile-v1` (tied to page chrome/regeneration, not to each response) | same | ✓ as a class. The header's justification overclaims (§6). |
| sha256 / bytes | `de5f8836…` / 261632 | same | ✓ point attestation. Record `etag` plus the `date` header. |
| revision | `-` for this URL. Add a separate content pin: web-unified-docs `7893d59…`, blob `ed90544…`, sha256 `7e2129bf…` | `-` | ✓ / gap |
| quote | **S023's own located quote, the KV note** (errata `:18`) | the dynamic-secrets sentence, i.e. S013's in-row quote (`SOURCES.md:19`) | ✗ F3 |
| normalization / normalized_sha256 | rendered-text-v1 **with trim** → `0e62e056…`. Literal untrimmed → `6643929d139eb809cd2853bf984c58b2fbbbb9d3c7183aaca69b1b2215adbd73` | trim now declared (`TSV:27`, `census:74`, `round-23.md:41`), value `0e62e056…` | ✓ value. ✗ the "stable identity" claim (§6). |
| location | H1 "Lease, renew, and revoke" → Note paragraph (last `<p>` before `h2#lease-ids`) | "Lease, renew, and revoke" | partial |
| locator (not in the schema) | edit href exactly `https://github.com/hashicorp/web-unified-docs/blob/main/content/vault/v2.x/content/docs/concepts/lease.mdx`; switcher `v2.x` flagged latest; newest pinned `v1.21.x` | absent | gap. S023's teaching *is* a locator. |
| stable identity (proposed) | article-slice sha256 `ebe088de…` as defined in §4 | absent | proposal |

## 6. The one real contradiction (C2)

**Claim versus observation**

- `corpus/source-fetches.tsv:18–20` (`ccc9ae6e…`) says that for `decoded-http-body-volatile-v1`, "the normalized digest is the stable declared identity".
- The `corpus/sources-census.sh` comment says that site chrome changes "the bytes, not the article" (`:275–277` in `24d834cc…`; was `:280–283` in `80966e20…`).
- For S023's URL, public bytes show the **whole-page rendered-text-v1 digest changed three times** (2026-09-23, 2026-10-07, 2026-10-21). Over the same period the article slice stayed byte-identical. The cause is chrome text: navigation and sidebar.
- This is provable from bytes and is not semantic drift.
- **Production now contradicts itself.** At 04:03:49Z, in-flight `lessons/round-23.md:184–188` (`88d0c7dc…`) concedes that page chrome moved S023's normalized digest between days while the article did not. Yet `source-fetches.tsv:18–20` (`ccc9ae6e…`) and the census `FNRM` rule (`24d834cc…`) are unchanged.

**Consequence**

- The same-URL normalized-agreement rule (`FNRM`, `sources-census.sh:285–290` in `24d834cc…`) will raise a false `same-url-normalized-disagreement` the first time a second row for this URL is captured after a chrome change. That could be an S013 re-capture or a future S023 on-release recheck row.
- The pressure to clear it is to copy the old digest, which attests bytes that were never fetched.

**Fix**

- Call the whole-page normalized digest a point attestation.
- Add an anchor-bounded `article_sha256`, or compare normalized digests only within one fetch date plus cache identity (`etag`, `date`).
- Keep the content pin (blob `ed90544…`) as the stable identity for this URL.

**Synthetic minimal failing fixture** (a proposal for L1; I did not execute it):

- Page A: `<nav>Docs</nav><h1 id="x">T</h1><p>Body &amp; note.</p><a href="https://example.invalid/src/x.mdx">Edit source</a>`
- Page B: the same, with `<nav>Docs SCIM</nav>`.
- Page C: B with `changed.` in place of `note.`.

| page | rendered-text-v1 (trimmed) | slice from `<h1 ` to that `<a` |
|---|---|---|
| A | `fcf54fb0b65d9a837b4a9c5307cf1ab3a8ccb64f058ece2847051cff01bce402` | `a1dda73a0a3d2631c4201e638eacb20653ae28c5acd2d53ebb411f1d54f82004` |
| B | `36526df8643c51c393dbbd5e0f72329af67db79c83297046061255823a42b61a` | `a1dda73a…` (same as A) |
| C | `005af4cf865847857f6c297ad427590a55fbe13b0867f7ec6b27f3ef202d0056` | `08b93279ee7ebad8b9919c9d023c20b4a49469bffd4b9b34489fa1ed8ae84930` |

1. **False red today.** Two provenance rows for the same URL, both volatile and rendered-text-v1, fetched 2026-10-07 (A) and 2026-10-21 (B). The in-flight census would exit 1 with `SC_FETCH id=<second> same-url-normalized-disagreement` (deduced from the code, not run). After the fix it must be CLEAN.
2. **True red.** A versus C must fail with an article/slice disagreement finding.
3. **Supersession-parse guard.** Add to the base fixture a row whose teaches cell starts `supersedes S001 — …`. It must be CLEAN. The selftest had no `supersedes` row (`80966e20…` matched only at `:245`), so it could not have caught F1. `24d834cc…` no longer parses supersession at all; keep this guard for any future reintroduction.
4. **Trim vector, kept as a guard.** `<p> A&amp;B </p>` → `A&B`, sha256 `ea99df94f7292f22c4e78b37bb92889fa7fb5fc8fb5b07a8458a8e4bb73d5fd9`. Untrimmed ` A&B ` gives `2f6d82cbcf7a4b540c6f1c96220010cb32d38f9a737d746c69984965b07dbddb`.

## 7. Findings by severity

**F1. Resolved in flight (was High; operability)**

- In census `80966e20…` (seen at 03:58:45Z and 03:59:40Z), `:229` no longer declared `SUPERSEDED` with `declare -A`, but `:242` still assigned `SUPERSEDED[$fid]=1`.
- Under `set -uo pipefail` (`:107`), bash would create an indexed array and evaluate `S007` arithmetically. The census would abort with "unbound variable" on the first of six `supersedes` rows (S019).
- I verified the semantics with a scratch `bash -c 'set -u; f(){ X[$1]=1; }; f S013'`, not by running the census.
- Sent to `agent://KagiR23` around 03:59Z.
- **At 04:02:36Z, `24d834cc…` had removed both the writer and its awk.** Neither `SUPERSEDED` nor `supersedes` matches any more. Whether that was a response to my message is unknown.
- **Residual (Low):** in the earlier `bf56b1a4…`, the map was filled but never read. The census now has no notion of superseded rows. S013's legacy `ae3215…` passes `SC_FETCH` on shape alone. C2's "distinguish superseded" duty is carried only by prose and the TSV header bound.
- Fix: report superseded legacy pins by id in the CLEAN line, or state that bound explicitly in the plan's after-condition.

**F2. Medium (calibration/operability)**

The §6 contradiction.

**F3. Medium (calibration)**

- S023's provenance quote re-attests S013's retained quote.
- The two things S023 itself contributes are unattested by C2:
  - the KV-note quote, which is the one quote that is *not* present in the raw bytes;
  - the edit-route locator.
- Fix: bind the KV note, with the location from §5. Also allow a second quote/locator per row, or a locator assertion column.

**F4. Low (calibration; frozen, pre-r23)**

- `corpus/feature-claims.json:86` records the S013 catalog title in lowercase.
- That string occurs 0 times in the `de5f8836…` bytes the same record pins (`:83`), and 0 times in both Wayback captures.
- The served `<title>` and `og:title` capitalize the second and third words; each occurs 3 times.
- `feature-claims.py:339` only checks that the title is a string.
- Fix: record the served title verbatim. This changes the pinned source digest, so the pin migration must be journaled.

**F5. Low (freshness)**

- Reproducing a digest from the same CDN object is not a determinism check.
- Fix: record `etag` and the `date` header for volatile rows.

**F6. Low (calibration)**

- S023 has consumers outside its used-by list:
  - knowledge entry `:166–169` (body);
  - `corpus/README.md:140–141`;
  - in-flight `lessons/round-23.md:1` and `source-fetches.tsv:43`.
- The census cannot see these, because it walks only `source:` lines in knowledge entries.
- M23-2 (`round-23.md:142` in `88d0c7dc…`) names consumers for S012/S018 only.
- Fix: add S023's consumers to that routed debt, or record them as machine-readable edges.

**Resolved in flight, before I sent my message**

- rendered-text-v1 did not say "trim". The literal reading gives `6643929d…`; the declared value is `0e62e056…`.
- The trim is now declared in `TSV:27`, `census:74` and `round-23.md:41`.
- My message's point 3 about the trim was therefore already stale when I sent it.

## 8. Residual risk, gaps and limits

- I ran no census, selftest, gate, ledger or feature-claims run. Every `SC_FETCH` behaviour above is deduced statically from the hashed in-flight code. Fixture digests come from a scratch Python snippet.
- The Wayback copies are third-party. Equal article slices show no change at three moments, not continuously. The representation behind `ae3215…` can no longer be recovered.
- The release API shows publication, not deployment.
- **Version-control disclosure:** at the start I ran `jj log -r @ --no-graph` once, which can snapshot the working copy; it reported `(empty)`. I also ran `git status --porcelain -- <paths>` once, which can refresh the index stat cache. After that I used only object reads (`git log`, `git show`, `git rev-parse`). No commits.
- Scratch captures under `/tmp/s023-*` were deleted after use.
- Tools: **none installed or updated.** curl, python3 and bash were already present.
- Total quoted words from the lease page: 22. That is the 20-word KV note plus "on GitHub".
- **Checks for L1 after integration (not run here):**
  - `bash corpus/sources-census.sh` on the real tree (confirms the F1 fix);
  - `bash corpus/sources-census.sh --selftest` with cases 1–3 added;
  - if F4 is fixed, `python3 corpus/feature-claims.py --selftest` and `--phase after`, with pin migration.
