# SrcOpenB — round-31 BUILD, group B src-open (staged S057 / S064 / S065 → S066 / S067 / S068)

Seat: SrcOpenB (executor, leaf). Wave `kagi-r31-build`. Date 2026-11-03.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (BASE `655e620651808ac04bb59bfa35b81227f62a031b`).
Read-only staged source: `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/oidc-federation-trust-policy.md` (entry 1, 8 staged sources; this seat owns its last three by document order, SrcOpenA confirmed by message that it took S052–S056).

Deliverables written (all inside the wave dir):

- `.ufo/waves/round-31/src-open/group-b.tsv` — three 16-column capture-row drafts.
- `.ufo/waves/round-31/src-open/group-b-receipts.txt` — per-URL fetch receipts (command, exit, HTTP, final URL, bytes, sha256, normalized digest, locate output, stability probe, profile control).
- `.ufo/waves/round-31/SrcOpenB-report.md` (this file).
- `.ufo/waves/round-31/build/SrcOpenB.md` — scoped findings for the L1.

Nothing else was written. No lane git/jj command was run. No credential, vault, account, handler or `op` contact; no secret material appears in these artifacts. No installs. Network use was exactly the three declared URLs plus the same-URL control/refetch probes.

## Method

Canonical capture command (the profile named in the seat brief):

    curl -fsSL --max-time 30 '<registered url>'

Control (the command the `curl-fsSL-compressed-v1` column label in `corpus/source-fetches.tsv` describes):

    curl -fsSL --max-time 30 --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' '<registered url>'

Both were run for every URL (3 canonical + 3 control), and the control was run a second time as the stability probe (3 refetches; 9 GETs total). Every GET exited 0 with HTTP 200 and `final-url` equal to the registered URL (no redirects). Quotes were located with the lane's own normalizer:

    python3 corpus/rendered-text-v1.py digest <body>
    python3 corpus/rendered-text-v1.py locate <body> '<quote>'

## The three draft rows

| draft id | final id | staged | url | rep | bytes | raw sha256 (16) | norm sha256 (16) | quote words | locate |
|---|---|---|---|---|---|---|---|---|---|
| B1 | S066 | S057 | https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp | decoded-http-body-volatile-v1 | 95137 | `0e2d9afdfda461bd` | `8b21f8346902b086` | 6 | 1 |
| B2 | S067 | S064 | https://openid.net/specs/openid-connect-core-1_0.html | decoded-http-body-v1 | 437508 | `4d016752a645e8a3` | `c2ba57c4adaaeb9a` | 25 | 1 |
| B3 | S068 | S065 | https://www.rfc-editor.org/rfc/rfc9700.txt | decoded-http-body-v1 | 124673 | `9919d061d40a9788` | `ab2871e3ae367bce` | 18 | 1 |

Full digests, byte counts and the normalized digests are in `group-b.tsv`; the receipts repeat each one with its generating command.

Column 1 carries the draft seat id (`B1`…`B3`), matching the wave's `group-a.tsv` convention (`A1`…). Column 3 is `sha256(id<TAB>mined<TAB>url<LF>)` over the **final** S-id (`S066`/`S067`/`S068`, dispatch map `S057→S066, S064→S067, S065→S068`), so it verifies once the L1 replaces column 1; both digest forms (final-id and draft-id) are in the receipts, so a renumber is one substitution. The comment block in `group-b.tsv` says the same. Revision is `-` for all three (no `raw.githubusercontent.com` URL).

## Evidence per row

### S066 — Alibaba RAM, 创建可信实体为身份提供商的RAM角色 (zh)

- 200; body 95,137 B, sha256 `0e2d9afdfda461bde4dfe33c1b1a300b5db70090f354f6454092726c8f3b3a0b`; normalized sha256 `8b21f8346902b086a2bc778d34a854625a4662c8f6496f49ed725f735d3e23d4` (6,877 B normalized).
- Quote (located, count=1): `OIDC 受众（Audience）。用来扮演角色的 OIDC 令牌中的 aud 字段值必须满足该限制条件要求，角色才允许被扮演。`
- Location: `§创建OIDC身份提供商的RAM角色 → 操作步骤, 限制条件表 oidc:aud row`.
- Auxiliary evidence for the entry's structural claim, same table (`限制条件关键字 说明 是否必选 示例`), all read from today's bytes:
  - `oidc:iss` row ends `…角色才允许被扮演。 该限定条件必须使用 StringEquals 作为条件操作类型，条件值只能是您在 OIDC 身份提供商中填写的颁发者 URL。 … 是 https://dev-xxxxxx.okta.com`
  - `oidc:aud` row ends `…该限定条件必须使用 StringEquals 作为条件操作类型，您可选择在 OIDC 身份提供商中配置的一个或多个客户端 ID（Client ID）作为条件值。 … 是 0oa294vi1vJoClev****`
  - `oidc:sub` row ends `…该限定条件可以使用任何 String 类的条件操作类型，且您可以最多设置 10 个 OIDC 主体作为条件值。 … 您也可以不指定该限制条件。 否 00u294e3mzNXt4Hi****`
  So “iss and aud mandatory, sub optional; aud must use StringEquals; sub at most 10” is still true today.
- **Finding 1 — anchor label drift.** The staged anchor cell says `§信任策略 → 限制条件表`. The string `信任策略` occurs **0** times in all three fetched bodies (canonical plain, and both profiled copies); the page `<h1>` is `创建可信实体为身份提供商的RAM角色` and the table is introduced by `在编辑器中设置限制条件。 支持的服务级限制条件如下表所示：` inside `创建OIDC身份提供商的RAM角色 → 操作步骤`. The quote is locatable, so the row is **not** refused; the SOURCES anchor cell should cite the real section name. The adopted entry's sentence “The Chinese-market table is explicit…” stays true.
- **Finding 2 — the staged campaign pin is stale.** Staged sha16 `48173805d3c27af4` (fetched 2026-10-23) matches neither today's canonical body (`0e2d9afd…`) nor either profiled body (`edb1278d…`, `1074eb86…`). Page meta `last-modified` is `2026-06-05T09:45:25+08:00`, i.e. the article date predates the campaign; the digest moved in the served chrome/build, not in the article date. The table text the entry uses is unchanged. Treat the old pin as a point attestation, not a drift pin — exactly the round-23 lesson's rule.
- **Finding 3 — volatility, measured.** Two consecutive profiled GETs differ (`edb1278d…`, 95,135 B vs `1074eb86…`, 95,135 B); the only difference is the number of leading CRLF bytes (2 vs 1). The normalized digest is identical for both (`8b21f83…`), and identical again for the plain-profile body. This is the textbook case for `decoded-http-body-volatile-v1` with the normalized digest as the stable attestation.

### S067 — OpenID Connect Core 1.0

- 200; body 437,508 B, sha256 `4d016752a645e8a3c259baa4173b5a90cb6c82898ce868fc8444adde262a5aed`; normalized sha256 `c2ba57c4adaaeb9a8283e1d93efbe2ae0a60c37168e137e9caca7aa50bf24743` (258,083 B normalized).
- Document identity verified: `<title>Final: OpenID Connect Core 1.0 incorporating errata set 2</title>`, also in the body.
- Quote (located, count=1): `aud REQUIRED. Audience(s) that this ID Token is intended for. It MUST contain the OAuth 2.0 client_id of the Relying Party as an audience value.`
- Location: `§2 ID Token, aud claim paragraph (aud REQUIRED)`.
- **Finding 4 — staged section is wrong.** The staged cell says `§3.1.3.6 "ID Token", aud claim`. §3.1.3.6's actual body reads: `The contents of the ID Token are as described in Section 2 ( ID Token ) . When using the Authorization Code Flow, these additional requirements for the following ID Token Claims apply: at_hash …` — the `aud` claim definition and the quoted sentence are in **§2 ID Token** (unique in the document: locate count 1). The URL and the quote are right; only the section label must move to §2 in the SOURCES anchor cell and in the entry's citation.
- **Finding 5 — 25-word ceiling, no margin.** The chosen quote is exactly 25 words under `LC_ALL=C wc -w` (`printf '%s' "$q" | wc -w` → 25), which passes `<=25` but any added word fails. If the L1 wants margin, the shorter alternative `It MUST contain the OAuth 2.0 client_id of the Relying Party as an audience value.` (17 words) locates 1 as well and drops only the `aud REQUIRED.` prefix; keep `aud REQUIRED` in the anchor cell instead.
- Representation `decoded-http-body-v1`: two same-day GETs are byte-identical under both profiles, the document is a frozen “Final … errata set 2” spec page, and the fetched body carries no current-date string (grep for `2026-11-03` → 0), so nothing per-response was observed. If the L1 prefers the lane's conservative HTML default, flipping the class string to `decoded-http-body-volatile-v1` changes nothing else — the normalized digest is the same.

### S068 — RFC 9700 (BCP 240)

- 200; body 124,673 B, sha256 `9919d061d40a97886ca866b51c69389b6c81c65cd4b979056c14fdbebfcf622a`; normalized sha256 `ab2871e3ae367bceb8db57c4e9786f196060d261d23e2383fd683a0fdd68ff36` (110,683 B normalized).
- Identity verified from the fetched header: `Request for Comments: 9700`, `BCP: 240`, `Category: Best Current Practice`, `January 2025`, title `Best Current Practice for OAuth 2.0 Security`. The body carries a UTF-8 BOM at byte 0 (included in the raw digest).
- Quote (located, count=1 in rendered text): `If the access token fails the intended audience validation, the resource server refuses to serve the respective request.`
- Location: `§4.10.2 Audience-Restricted Access Tokens, lines 1666-1668`.
- **Finding 6 — normalization choice is forced by the hard wrap.** In the raw bytes the sentence is split across lines 1666–1668 (`…the resource` / `…server refuses…`), and a TSV cell cannot hold a newline, so a raw-literal quote would have to be a fragment. I declared `rendered-text-v1` and committed the normalized digest, which makes the full sentence checkable with the lane's own locate. Caveat, stated plainly: rendered-text-v1 is an HTML-oriented normalizer (it deletes `<…>` spans), so on a plain-text RFC it is a declared transform, not a faithful rendering; the raw sha256 remains the primary attestation. If the L1 prefers the S052 raw-literal precedent, the single-line alternative `In general, audience restriction limits the impact of token leakage.` is a byte-level substring today (grep -cF → 1), with normalization `raw-literal-v1` and normalized digest `-`; it supports the same section but not the refusal clause.
- **Finding 7 — the staged in-text quotation is partial.** The entry writes “if the token fails the intended audience validation, the resource server refuses to serve the respective request”. Today's bytes read `If the access token fails …` (adds “access token”, capitalizes “If”). Not a contradiction; the adopted entry should either quote the exact sentence or mark its version as a paraphrase.

## Profile-label nuance (for the L1, not fixed here)

`corpus/source-fetches.tsv` labels the profile `curl-fsSL-compressed-v1`, and its header defines that label as `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`; the seat brief and round-30's receipts name the plain `curl -fsSL --max-time 30 <url>`. The canonical bodies recorded here were fetched with the plain command (seat brief + round-30 precedent), and the profiled control is recorded in the receipts. The difference is observable only where the representation is volatile: for S067 and S068 both profiles return byte-identical bodies; for S066 the profiles differ only in leading CRLF count and the normalized digest is equal. A swap to the profiled digest domain is one substitution per row and does not touch any other column.

## Contract compliance and honest negatives

- No fetch failed; no staged anchor quote was unlocatable; **no row is REFUSED**. Two anchors are mislabelled (S066's heading, S067's section) and one campaign pin is stale (S066) — all three are label/pin drift, not evidence failure, and each is named above for the L1's `SOURCES.md` anchor cells.
- I did not touch `corpus/SOURCES.md`, `source-fetches.tsv`, the knowledge entries, the staged tree, or any sibling lane. No `git`/`jj` command ran in the lane. No `agent://all` message.
- Scope was confirmed with SrcOpenA by direct message before fetching (A = S052–S056, B = S057/S064/S065, C = entry 2's three), so the 11-row split has no overlap and no gap.
- Installs/upgrades: none. Tools used: `/usr/bin/python3` 3.14.8, `curl`, coreutils. `op` untouched (no version read needed this seat).
- Scratch `/fast/scratch/hyaku/kagi-r31/srcopenb` (fetched bodies, headers, generator, digests) was removed with `rm -rf` after the receipts were copied into the wave dir; it is gone, and the bodies are deliberately not retained (the receipts carry digests, byte counts, document stamps, and the exact reproduction commands; re-fetch reproduces them, with S066 volatile by declared class).
