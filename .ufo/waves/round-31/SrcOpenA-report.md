# SrcOpenA — C2 in-round re-open of the first five staged OIDC sources

**Seat:** SrcOpenA (executor/lane seat, round-31 BUILD wave `kagi-r31-build`)
**Item:** C2 coverage — re-open, in-round, the five staged sources of
`oidc-federation-trust-policy.md` that fall to group A (staged S052–S056 → lane S061–S065)
**Date:** 2026-11-03 · **Host:** Arch Linux (omp), python3 3.14.8, curl from the base system
**Fetch profile (declared, single shape):** `curl -fsSL --max-time 30 '<url>'`

**Result in one line:** 5/5 HTTP 200 at the registered URL, 5/5 staged quotes locate in today's
decoded bodies (one only after `rendered-text-v1` normalization), zero REFUSED rows; the five
capture rows are drafted, digest-pinned against the final S-ids, and field-checked against the
census's own rules. Two rows carry `decoded-http-body-volatile-v1` (per-request CSP nonce);
**0/5 staged sha16 prefixes reproduce** and, under the declared profile, no variant was sought.

## Deliverables

| path | content |
|---|---|
| `.ufo/waves/round-31/src-open/group-a.tsv` | 5 draft capture rows, 16 columns, `A1..A5` in column 1, final-id digest in column 3 |
| `.ufo/waves/round-31/src-open/group-a-receipts.txt` | per-URL receipts (argv, exit, HTTP, final URL, raw sha/size, two stability probes, normalized digest, quote + word count, locate counts, location) plus a READY-TO-APPEND block with `S061..S065` already substituted |
| this report | scoped findings, digest-drift attribution, hazards for the entry/registry seats |

No lane production file was touched. Nothing was installed; no `op`, vault, account, handler or
CDP contact occurred. Scratch `/fast/scratch/hyaku/kagi-r31/src-opena/` held the five bodies and
was removed after the receipts were written (see §Scratch).

## Rows

`locate` = `python3 corpus/rendered-text-v1.py locate <body> '<quote>'`; `raw` = `grep -c -F` on
the decoded body; `flat` = `tr '\n' ' ' | grep -c -F` (same needle, newlines only).

| draft → final | URL (registered) | HTTP | bytes | sha256 (run 1) | repr | quote | words | locate / raw / flat | location |
|---|---|---|---|---|---|---|---|---|---|
| A1 → S061 | `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html` | 200 | 51283 | `141dd4819db34dc2…d94332508` | v1 | “The aud claim must match the Audience value” | 8 | 1 / 1 / 1 | §Create an OpenID Connect (OIDC) identity provider in IAM, `claims_supported` list, `aud` bullet (line 158) |
| A2 → S062 | `https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html` | 200 | 185044 | `fb5b2e35ec37c18b…24190ae3` | v1 | “the OIDC condition context key can only be used in a role trust policy for the initial AssumeRoleWithWebIdentity authentication” | 19 | 1 / **0** / **0** | §Available keys for AWS OIDC federation, available-in-session paragraph above the IdP selector |
| A3 → S063 | `https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html` | 200 | 51850 | `a08888ce4d86adf2…4126d27c` | v1 | “The intended audience (also known as client ID) of the web identity token” | 13 | 1 / 1 / 1 | §Request Parameters, `Audience` description (line 347) |
| A4 → S064 | `https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation` (301 → `docs.cloud.google.com/…`) | 200 | 211206 | `116398b3807c1016…c7edc7c45` | volatile | “the same external identity might be represented as multiple different IAM principals, or several external identities could map to the same IAM principal” | 23 | 1 / **0** / 1 | §Protecting against spoofing threats (h2), identity-ambiguity paragraph |
| A5 → S065 | `https://docs.cloud.google.com/iam/docs/workload-identity-federation?hl=ja` | 200 | 174357 | `0179cc57506a632e…5f2ab99c348f` | volatile | “属性条件は、アサーション属性とターゲット属性をチェックする CEL 式です。” | 3 | 1 / 1 / 1 | heading 属性条件 (h3), attribute-condition definition, first paragraph (line 4095) |

Full digests and the exact argv lines are in the receipts file; the TSV carries the complete
64-hex values. `revision` is `-` on all five (no `raw.githubusercontent.com` URL, no moving-ref
registry URL). `normalization` is `rendered-text-v1` on all five, each with its normalized digest
(`37de7130…`, `5db9d803…`, `c9927f89…`, `92c7db2c…`, `7a5a1c57…`) computed by
`corpus/rendered-text-v1.py digest`.

## Digest-drift attribution: 0/5 staged prefixes reproduce

The staged entry pins 16-hex page-fetch prefixes from 2026-10-23. Today, at the declared
profile, the first 16 hex of the raw body are:

| row | staged sha16 | today sha16 | match |
|---|---|---|---|
| A1/S061 | `c69aea104f5fb072` | `141dd4819db34dc2` | no |
| A2/S062 | `c65b05feaf7e5140` | `fb5b2e35ec37c18b` | no |
| A3/S063 | `e5349f6cbfdbc717` | `a08888ce4d86adf2` | no |
| A4/S064 | `ac85362d89649e66` | `116398b3807c1016` | no |
| A5/S065 | `97c3149df09fbc90` | `0179cc57506a632e` | no |

They differ from the first byte, so the staged digests are not a truncated/offset variant of
today's bodies. Two further facts keep this from being read as content drift:

1. **Every staged quote still locates** at its authored anchor — the teachings the entry draws on
   are present (and A1 even reproduces the staged `recheck` needle exactly: raw `grep -c` = 1).
2. **A4/A5 are nonce-bearing**: three fetches of A4 gave three different raw digests
   (`116398…`, `6a64b1…`, `14bd37…`) with the **same normalized text digest**
   (`92c7db2c…de722`); A5 gave two raw digests with one normalized digest (`7a5a1c57…a6c12`).
   The served markup carries a per-request CSP `nonce`, so a raw-byte pin on these two pages is
   un-reproducible by construction and must be declared `decoded-http-body-volatile-v1`.

I did **not** probe User-Agent / `Accept-Encoding` variants to force a staged prefix to reappear:
the round's network declaration limits me to the declared profile. Under that profile the staged
prefixes are un-attributable from this host; that is a property of the record, not of the page's
teachings. A1–A3 *are* byte-stable (three fetches identical), so for them the 2026-10-23 capture
simply predates a page rebuild.

## Findings for the L1 and for the entry seats

1. **A2's quote cannot be grepped raw.** AWS hard-wraps the sentence and wraps
   `AssumeRoleWithWebIdentity` in an `<a>`: `grep -c -F` on the decoded body is **0** while
   `rendered-text-v1.py locate` is **1**. If a `recheck:` needle is authored from this row, it
   must run through the normalizer (or normalize newlines *and* tags); a plain grep will read 0
   and look like drift. This is the same hazard class the round-30 seat named for markup-sensitive
   needles.
2. **A4's quote is line-wrapped** (`…IAM principals,\nor several…`): raw one-line grep 0,
   newline-flattened grep 1, rendered locate 1. Same advice as (1) but for whitespace only.
3. **A4's anchor label in the staged entry is imprecise.** The entry attributes its subject-
   collision sentence to a §"Best practices" bullet list. The page's *title* is "Best practices for
   using Workload Identity Federation"; the sentence sits in the **h2 "Protecting against spoofing
   threats"** prose, not in a bullet list. The quote itself is intact; only the label moves. The
   same page carries h3 **"Use the URL of the workload identity pool provider as the audience"**,
   whose body states that Workload Identity Federation verifies `aud` against "the allowed audience
   setting of the provider" and that the default expected audience is the
   `https://iam.googleapis.com/projects/PROJECT_NUMBER/…/providers/PROVIDER_ID` URL — that h3, not
   the ambiguity paragraph, is the right anchor for the entry's *audience* cell if it cites S064.
4. **A1 supports the entry's issuer sentence, but not in the entry's words.** The page says
   "The URL must begin with https://", "path components are allowed but query parameters are not",
   and "The URL should not contain a port number." The staged phrasing "with no query parameters and
   normally no port" turns a directive ("should not") into a normality claim ("normally no"). The
   citation survives; the paraphrase should be re-grounded to the page's wording — a cheap,
   honest flip candidate for the entry-level gate.
5. **A4's registered URL is a 301.** `cloud.google.com/...` answers `HTTP/2 301` with
   `location: https://docs.cloud.google.com/...`; the final response is the 200 capture. The
   registry URL must stay the staged one (`cloud.google.com`), because the census compares the
   capture row's `url` against the registry, not `final-url`. Row A4 records both.
6. **A5 keeps the native Japanese rendering** (`?hl=ja`): heading `### 属性条件` exists as
   h3 and the definition sentence is byte-contiguous in the raw body, so S065 is a clean
   `raw-literal`-grade anchor inside an otherwise `rendered-text-v1` row.
7. **Digest convention is a trap if the ids move.** Column 3 of every draft row is
   `sha256("S061\tmined\t<registered url>\n")` (census line 262), i.e. it is already computed
   against the final id while column 1 still reads `A1`. Substituting column 1 alone is correct
   only for the documented map (A1→S061 … A5→S065); any other assignment requires recomputing
   column 3. The receipts file ends with a READY-TO-APPEND block already in final-id form.

## Verification actually run (and what was not)

* `curl -fsSL --max-time 30 '<url>'` three times per URL (run 1 attested, runs 2–3 stability
  probes). Exit 0 and HTTP 200 on every run; no retries were needed.
* `python3 corpus/rendered-text-v1.py digest` on runs 1 and 2 of every body (proves the
  volatile rows' *text* is stable while their *bytes* are not).
* `python3 corpus/rendered-text-v1.py locate` plus raw and newline-flattened greps on run 1
  (locate counts 1/1/1/1/1).
* A scratch reimplementation of the census's 14 per-field rules
  (`corpus/sources-census.sh:264-283`) over `group-a.tsv`: **5/5 rows PASS all 14**, exit 0.
  This is a field-level check, not the lane census: the census itself cannot pass until the
  S061–S065 registry rows exist, and my seat does not edit `corpus/SOURCES.md`.
* Not run, by design: the lane census, any gate, any build/lint/test. The L1 owns integration
  and post-integration gates.

## Scratch

`/fast/scratch/hyaku/kagi-r31/src-opena/` (five bodies × 3 runs + header files + probes) was
deleted after `group-a.tsv` and `group-a-receipts.txt` were written; the scratch directory no
longer exists. No receipts live only in scratch — every pasted value is in the wave dir.
