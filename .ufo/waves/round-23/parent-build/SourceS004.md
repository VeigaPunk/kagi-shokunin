# SourceS004 — S004 source-bound provenance audit (round 23, parent build)

Seat `SourceS004` (leaf scout, no dispatch). Axes: **calibration, freshness, operability**.
Read-only on production. The only file I wrote is this report. Commands I ran: public GETs of the S004 URL,
its declared markdown alternate, and the Internet Archive; local reads; read-only `awk`/`grep`/`sha256sum`
over committed files. I ran no census, gate, selftest, handler, vault or account command. Nothing was
installed (tools used: curl 8.23.0, Python 3.14.8, both preinstalled). This report is advisory and is not
admission.

## 0. Exact revision and inputs

| item | observed |
|---|---|
| HEAD (= `plans/round-23.md` base) | `d218603b74099ddca0bd8f869516fc41db0979bf` |
| `corpus/SOURCES.md` @HEAD | `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30` · 118 L · 22,843 B |
| S004 row, `corpus/SOURCES.md:10` (line bytes + LF) | `405a8b0331b7e1568989ebbe143c981bda90323a001bf695b8a69c36afa64b1a`. Byte-identical at `c41af82` (row introduced 2026-10-19T19:29:35-03:00), at HEAD, and in the working tree at 03:53Z |
| `corpus/knowledge/onepassword-machine-credentials.md` @HEAD | `8380b35927e96b89fc0da7832516ecaff2a8e097660b47c599f560344709cf48` |
| `corpus/claim-ledger.tsv` @HEAD | `e6806968436375870067d0e587fb1e8ea27e5d3304b8bb563e3f484c1dce8305` |
| `corpus/sources-census.sh` @HEAD | `03fb300a74157232978525c6bc4b028d7ed9159bccbb47d32333deb48ba76b3c` (no `SC_FETCH`) |
| `corpus/QUALITY.md` @HEAD | `284c321e81ee9ef3892c252606d57e2f69b80fed354e9a95e8f254a77ac9285c` |
| L1 in-flux, **not frozen** (2026-10-21T03:53:29Z) | `corpus/sources-census.sh` `bf56b1a4…` (has `SC_FETCH`); `corpus/source-fetches.tsv` `e2f40132…`; `corpus/SOURCES.md` +3 rows (S024–S026), S004 row unchanged |

I read the in-flux files only to align §5–§7 with the planned C2 contract. No finding treats them as integrated state.

## 1. Public reopen: what opened and what failed

All of these opened (HTTP 200). None failed.

| what | observation (2026-10-21 UTC) |
|---|---|
| Registry URL https://www.1password.dev/service-accounts/security, decoded HTML (`curl -fsSL --compressed`) | sha256 `beb67f2d0b8b4e77108766f134fb9bf21943331d9ab4d9bdbe083f655336b055`, 1,221,922 B. Identical across ≥7 GETs from 03:44 to 03:56:26Z and three User-Agents (curl default, a Chrome string, the round-23 profile UA) |
| Canonical / redirects | `<link rel="canonical">` and `og:url` both equal the registry URL. The legacy `developer.1password.com/docs/service-accounts/security`, the apex host and the trailing-slash form each redirect in one hop to the registry URL |
| Transport headers | `cf-cache-status: HIT`, `age` 10,813 → 11,521 s, `cache-control: no-store…`, `vary: rsc, accept-encoding, Accept, User-Agent`, weak ETag |
| Embedded build data | Vercel deployment `dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`; Next.js buildId `6ad68a298cdc29c1c7fdf7e9`; JSON-LD `dateModified` `2026-10-19T21:23:27.830Z` (machine metadata, not displayed) |
| Declared markdown alternate `/service-accounts/security.md` (`rel="alternate" type="text/markdown"`) | `24b22be063adedda0731fed48ce7dc835ed0c79d856f09c5daa110d1b0e5ab5d`, 8,390 B. Same value with and without `--compressed` and under two UAs. Raw gzip transfer bytes hash to `940bf539…` (transport artifact). `last-modified` equals the request time |
| `rendered-text-v1`, my implementation of the round-23 lesson prose (§5) | `ed6f87eb0ff199bba950554fe7cffae41a0f8b52e50b1571a7425f1c6e309c4a` (8,654 B, ends trimmed) or `63218059ef86aa21769e893e1c60d77ad64995b47c2bd3bc1a6430d84b017b44` (ends not trimmed) |
| Internet Archive CDX, 2026-09-01..2026-10-21 | Three HTML captures (2026-10-14 ×2, 2026-10-17T15:06:51Z). None between 2026-10-17 and today. The `.md` URL was never captured (`[]`) |
| Archive capture `20261017150651id_` | gzip body 255,006 B `e6c4b32e…`; decoded 1,214,500 B `aec7e640cbde3edc9930d6480fa03a663d9eb27683162f88ec870c369936b847`; `dpl_EFphLEJeewGjC2efg7rUSgtJDD7Q`; JSON-LD `dateModified` `2026-10-16T17:24:37.406Z` |

Round 22's Wayback availability lookup returned 429. Today it returned 200 and named the 10-17 capture, so round 22's "no snapshot" applies only to its 10-18+ window. Not reopened here: the linked `manage-service-accounts` page (round 22 already covered it; re-auditing it is out of my scope).

Located quotes. These are the row's own two quotes, 20 words in total. I quote nothing else from this source.
- §Access control (H2 `#access-control`; `.md` heading at line 9, quote at line 11), 2026-10-21, https://www.1password.dev/service-accounts/security: “you choose the vaults it can access and its level of access.” (12 words)
- §Token rotation and revocation (H3 `#token-rotation-and-revocation` under H2 “Service accounts and token generation”; `.md` heading at line 88, quote at line 90), same date and URL: “You can rotate or revoke service account tokens.” (8 words)

Both strings are exact substrings of the decoded HTML, the `.md` and the `rendered-text-v1` text. They are also present in the 2026-10-17 archive capture.

## 2. Row recheck: teaches, status, tier, anchor, supersession

| field | observation | verdict |
|---|---|---|
| source title / URL | H1 is “1Password Service Account security”; the URL is canonical | **supported** |
| kind / tier `docs` / A | Vendor's own canonical developer documentation | **supported** |
| scope / teaches: vault scope and token rotation/revocation are “separate controls” | Two separately headed sections carry the two quotes. §Security model (paraphrased) fixes vault access at creation and lists token lifecycle facts separately. So the separation reading holds as **separately documented controls**. The page documents no expiry, immediacy or session-termination mechanics, and the row claims none | **supported** (current semantic support) |
| anchor locator “current page has no displayed version/date” | No visible date or version. A machine `dateModified` exists in JSON-LD only. Not refuted literally; see §3 for why it is not a revision clock | **supported** (literal) |
| status `mined` · opened 2026-10-19 · recheck `90d` | used-by resolves (§4). The next due date is 2027-01-17; 2 days have elapsed | **supported / fresh** |
| supersession | At HEAD, rows supersede only S006, S007, S012 and S013. In flux, S024–S026 target KV v2, S014 and S016. **Nothing supersedes S004** | S004 remains an active row |

Decision (advisory): keep S004's teaching, quotes, anchors, tier and status unchanged. No re-curation is warranted.

## 3. Four-way distinction

1. **Historical bytes.** `Fetch sha256: 19bcf13e…` is a 2026-10-19 point observation of an undocumented representation. None of the following reproduces it:
   - decoded HTML on 10-17 (archive), 10-20 (round 22: `7e6f0408…`, 1,221,617 B) and 10-21 (`beb67f2d…`);
   - the 10-17 gzip transfer bytes;
   - the `.md` (`24b22be0…`), the `.md` without its final LF (`678b6554…`), the BOM-prefixed `.md` (`21c8ce7c…`) and the gzip `.md`;
   - `rendered-text-v1` with or without trimming.

   No archive capture exists between 10-17 and 10-21, so the 10-19 bytes cannot be recovered publicly. **New nuance:** the page's declared build moved on the open date itself (`dateModified` 10-16 → 2026-10-19T21:23:27.830Z, 66 min before the row commit at 22:29:35Z). The historical digest therefore cannot even be assigned to one build. Keep it as history; never compare it, never "correct" it.
2. **Current semantic support.** The article text is identical between the 10-17 archive and 10-21 live: 136 extracted lines with zero diff, 32/32 `href`s equal, and equal heading ids. Only framework-generated `base-ui-_R_…` ids differ. The row's reading holds whichever build the author fetched.
3. **Transport / raw-HTML volatility.** Decoded HTML changed between 10-20 and 10-21 (`7e6f0408…` → `beb67f2d…`, +305 B; deployment `dpl_CTd5b4…` → `dpl_8AUWT8…`). Over that interval the buildId, `dateModified` and article text were unchanged, so the raw HTML is **deployment-coupled**. Two round-22 wave statements are refuted by this. The committed `.ufo/waves/round-22/falsify/ReopenSource04.md` §2 called the raw HTML a “current stable representation”; it was stable within a session, not across a redeploy. `.ufo/waves/round-22/build/Source04.md` §3.2 proposed JSON-LD `dateModified` as S004's “revision clock”; it moved 10-16 → 10-19 with no content change, so it is a site-build stamp. This gives a direct before/after pair for round-22 `Source01.md`'s inference. `git grep` shows neither proposal entered `corpus/`.
4. **Deployed-product proof.** None. This is a documentation page only. No account, service account, vault or token was exercised. Neither the row nor the entry claims deployed behaviour.

## 4. Used-by pointer chain (followed locally, read-only)

- `SOURCES.md:10` used-by → `corpus/knowledge/onepassword-machine-credentials.md` exists. Its line-2 `source:` cites S004 with the same URL, anchors and opened date (the `SC_USEDBY_NOCITE` condition holds by reading). Line 4 `recheck: 90d for S001–S004` matches the row. Line 5 `Reverify: R21-02`.
- `R21-02` (`corpus/claim-ledger.tsv:52`) expects `rows=23 A=21 B=0 C=2 queued=1 mined=21 rejected=1 entries_sourced=4 legacy=21`. A read-only `awk` over the HEAD registry plus a `source:`-line listing of 25 knowledge files gives the same values. This is a derivation, not a census run. **Obligation pointer for L1:** the in-flux S024–S026 rows change these counts, so `R21-02` needs a QM14 old/new migration at integration.
- Entry item 2 (line 12) compresses “vaults → returned information” and “access level → operations”. Round 22 already routed this as a precision note (`build/Source04.md` D8), so it is not new here. The “Does not establish” bullet (line 24), the falsifier (line 30) and the round-22 appended bounds are consistent with S004.
- `corpus/lessons/round-21.md:58` (S004 quote row), `plans/round-21.md:27` (allocation) and `SOURCES.md:33` (path S001 → **S004** → …) are all consistent.

## 5. C2 expectations for S004 (exact)

Under the in-flux design, S004 is covered by its legacy in-row digest and gets no TSV row. If L1 gives S004 a provenance row (this is the plan's literal “for every mined row” reading, and peer S016's recommendation), the expected values are:

| column | S004 value (fetched 2026-10-21, last confirmed 03:56:26Z) |
|---|---|
| id / status | `S004` / `mined` |
| row_line_sha256 | `405a8b0331b7e1568989ebbe143c981bda90323a001bf695b8a69c36afa64b1a` |
| url / final_url | `https://www.1password.dev/service-accounts/security` (both) |
| http_status / request_profile | `200` / `curl-fsSL-compressed-v1` |
| representation | `decoded-http-body-volatile-v1`. **Not** `-v1`: a redeploy alone changed the bytes between 10-20 and 10-21 |
| sha256 / bytes | `beb67f2d0b8b4e77108766f134fb9bf21943331d9ab4d9bdbe083f655336b055` / `1221922`. A point attestation of a CDN-cached object, not a drift pin |
| revision | `-` |
| quote / location | q1 at `§Access control` or q2 at `§Token rotation and revocation` (anchor ids above) |
| normalization / normalized_sha256 | `rendered-text-v1` / `ed6f87eb0ff199bba950554fe7cffae41a0f8b52e50b1571a7425f1c6e309c4a` |

- **Normalized-digest stability: supported.** `ed6f87eb…` is identical for the 10-17 archive (a different build) and 10-21 live, and under all three UAs. For this URL, the TSV header's claim that the normalized digest is the stable identity of a volatile page holds across at least two builds.
- **Normalizer under-specified.** My implementation:
  - `re.sub(r'<script\b[^>]*>.*?</script\s*>',' ',t,flags=S|I)`, and the same for `style`;
  - `re.sub(r'<[^>]+>',' ',t)`;
  - `html.unescape`;
  - `re.sub(r'\s+',' ',t)` followed by `.strip()`, with sha256 over UTF-8.

  Without `.strip()` the digest is `63218059…`. Unescaping before tag stripping gives `4aadd991…`. ASCII-only versus Unicode whitespace makes no difference on this page (no U+00A0; the 11 U+200B characters survive both). No committed normalizer code exists (`rendered-text-v1` appears only as prose in the lesson, census header and TSV header). Commit the normalizer or state the trimming rule; otherwise no one can re-derive these digests independently.
- **`.md` cross-check (not an allowed representation).** `24b22be0…` / 8,390 B equals round 22's 10-20 `.md` digest, so it reproduced across two days. Useful as a reviewer cross-check only.
- **Two-anchor limit.** The row's teaching needs both anchors. The TSV allows one quote and location per id (`duplicate-provenance`), so one of the two anchors would be left unattested. This corroborates S013/S018's multi-quote point; I claim no novelty for it.
- **Never:** rewrite the immutable row's legacy digest, pin the raw HTML or `.md` as a drift pin, treat `dateModified` as a revision, or store normalized text. The S004 page text contains a vendor sample credential (§6).

## 6. One real contradiction (C2 operability/calibration; S004 is the witness)

**Claim.** The planned C2 provenance column can admit a vendor sample credential from S004's page as a “located ≤25-word quote” and still print CLEAN. That contradicts the lane's credential-hygiene contract: `SC_CREDENTIAL` exists, and this round's contract says never to copy vendor sample secrets.

**Evidence** (code read, nothing executed; the in-flux census is `bf56b1a4…`):
- `cred_scan` is called only on `corpus/SOURCES.md` (L307) and on sourced entries (L333). It is never called on `corpus/source-fetches.tsv`, which adds a free-text `quote` column.
- `CRED_RE` (L129–135) covers seven families: 1Password secret references, PEM private-key headers, GitHub personal tokens, AWS access-key ids, Slack tokens, age secret keys and Vault service tokens. It has **no alternative for the 1Password service-account token format**. The vendor states that format's four-character prefix exists so that code analyzers can find exposed tokens.
- The `SC_FETCH` quote bound is `wc -w` ≤ 25 (L271–272). S004's §Service accounts and token generation contains an encoded sample service-account token: one whitespace-free string of **634 characters, which counts as 1 word**. It is the longest run on the page; the next-longest is 89 characters. The token's bytes are not reproduced here.
- Result: a provenance row whose quote cell is that sample, located under §Service accounts and token generation, passes every quote and location check, and no credential scan reads the file. The fail-open also holds if the same string were pasted into `SOURCES.md`, because no needle matches it.

**Fix.**
1. Call `cred_scan "$fetchf" "corpus/source-fetches.tsv"`.
2. Add a fragment-built alternative for the service-account token format, e.g. `'op''s_[A-Za-z0-9_-]{40,}'`, plus a selftest needle built at runtime the way existing needles are.
3. Bound quotes by characters as well as words, e.g. ≤ 300 characters, so a single huge “word” cannot pass.

**Synthetic minimal failing fixture for L1** (a proposal; not run, and no passing result is claimed):
- Start from the census selftest base tree, extended with one valid 16-column `source-fetches.tsv` row.
- Mutation `m_fetch_quote_satoken` replaces that row's `quote` cell with a runtime-built string: `printf '%s%s' 'op' "s_$(rep A 600)"`. That is one 604-character word with the documented prefix and no vendor bytes. Set `location` to `§Service accounts and token generation`.
- Expected after the fix: exit 1 with `SC_CREDENTIAL corpus/source-fetches.tsv:<n>`, and also `SC_FETCH id=… quote` if the character cap is adopted.
- On the in-flux code this case should print CLEAN (exit 0), so the new case fails. That failure is the demonstration of the gap.

## 7. Additional calibration finding (QM3; the branch is corroborative, the grounding is new)

The in-flux `SC_FETCH` accepts the legacy in-row branch for coverage without comparing it to anything (L295–301, header “required for coverage, never compared”). The CLEAN verdict line (L338) does not count that branch. S004 is one of the 16 rows on it, and its legacy digest is affirmatively unreproduced (§3.1), not merely uncompared.

`corpus/QUALITY.md` QM3 requires every unverified branch to be counted in the verdict line or to fail the run; round-21 M3's precedent is a separate `UNVERIFIED` verdict. The census's own precedent counts a stated bound: legacy entries appear as `legacy=N`.

Fix: either add `fetch_tsv=N fetch_inrow_legacy=16` to the CLEAN line, with a QM14 migration of the `R21-02` regex, or move S004 to the TSV using the §5 values. Peers S012, S013 and S016 raised the disjunction itself. The QM3 and verdict-line angle is the new part here.

## 8. Limits

- One client (curl 8.23.0) from one CDN edge (GRU per `cf-ray`). Captures were CDN-cached objects; other edges and times were not sampled.
- The archive capture was made by the archive's crawler. The page varies on User-Agent; text identity was verified, raw bytes differ.
- `rendered-text-v1` digests come from my implementation of prose. L1's tool, if one exists, is uncommitted and unseen.
- In-flux files were observed at stated timestamps and may change after this report.
- No census, gate or selftest was executed. Counts are read-only derivations.
- Documentation only: no product behaviour was exercised. The 2026-10-19 bytes remain unrecoverable.

Report: `.ufo/waves/round-23/parent-build/SourceS004.md`
