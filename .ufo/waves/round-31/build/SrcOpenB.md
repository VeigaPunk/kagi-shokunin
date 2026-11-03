# SrcOpenB — scoped findings (round-31 C2 src-open, group B)

Full report: `.ufo/waves/round-31/SrcOpenB-report.md`. Draft rows: `.ufo/waves/round-31/src-open/group-b.tsv`. Receipts: `.ufo/waves/round-31/src-open/group-b-receipts.txt`.

## Rows ready to register

| draft id | final id | staged | url | rep | bytes | raw sha16 | norm sha16 | quote words | locate |
|---|---|---|---|---|---|---|---|---|---|
| B1 | S066 | S057 | https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp | decoded-http-body-volatile-v1 | 95137 | `0e2d9afdfda461bd` | `8b21f8346902b086` | 6 | 1 |
| B2 | S067 | S064 | https://openid.net/specs/openid-connect-core-1_0.html | decoded-http-body-v1 | 437508 | `4d016752a645e8a3` | `c2ba57c4adaaeb9a` | 25 | 1 |
| B3 | S068 | S065 | https://www.rfc-editor.org/rfc/rfc9700.txt | decoded-http-body-v1 | 124673 | `9919d061d40a9788` | `ab2871e3ae367bce` | 18 | 1 |

All 200, no redirects, `revision = -`. Column 1 is the draft id `B1`…`B3` (same convention as `group-a.tsv`); column 3 is computed over the final S-id (`S066`/`S067`/`S068`), so it verifies after you replace column 1. Both digest forms are in the receipts. No row is REFUSED.

## Four things to change on integration (evidence, not preference)

1. **S066 anchor cell.** Staged says `§信任策略 → 限制条件表`. `信任策略` occurs 0 times in today's bytes (all three fetched copies). The table is under `创建OIDC身份提供商的RAM角色 → 操作步骤`, introduced by `在编辑器中设置限制条件。 支持的服务级限制条件如下表所示：`. Use the real section name in both `SOURCES.md` and the entry's in-text citation; the quote itself is verbatim and locates 1.
2. **S066 campaign pin is stale.** Staged sha16 `48173805d3c27af4` (2026-10-23) matches neither the canonical body (`0e2d9afd…`) nor either profiled copy (`edb1278d…`, `1074eb86…`). Page meta `last-modified` is `2026-06-05T09:45:25+08:00`, so this is served-chrome/build movement, not an article change; the `oidc:iss`/`oidc:aud`/`oidc:sub` table text still says 是/是/否, aud `StringEquals`, sub ≤10 and optional. Keep the old pin out of the new anchor cell.
3. **S067 section is wrong.** The aud claim is **§2 ID Token**, not §3.1.3.6. §3.1.3.6's body defers (“The contents of the ID Token are as described in Section 2”) and adds only `at_hash`; the quoted sentence is unique to §2 (locate 1). Fix the anchor cell and the entry's `[S064]` citation to §2.
4. **S068 normalization is declared, not hidden.** The staged sentence spans a hard wrap (raw lines 1666–1668) and a TSV cell cannot hold a newline, so the row uses `rendered-text-v1` + normalized digest. If you prefer the S052 raw-literal precedent, swap to the single-line substring `In general, audience restriction limits the impact of token leakage.` (grep -cF → 1) and set the normalized column to `-`; that quote supports the section but not the refusal clause.

## Judgment calls (flip-ready)

- **Representation S067/S068 = `decoded-http-body-v1`.** Two same-day GETs byte-identical under both profiles; S067 is a frozen “Final … errata set 2” page, S068 a plain `.txt`. Flip to volatile if you want the conservative HTML default — nothing else in the row changes.
- **S066 = volatile is measured, not assumed.** Two profiled GETs differ (`edb1278d…` vs `1074eb86…`) in leading CRLF bytes only; normalized digest identical across all three bodies (`8b21f83…`).
- **S067 quote is exactly 25 words** (the census cap) under `printf '%s' … | wc -w`. Shorter 17-word alternative that still locates 1: `It MUST contain the OAuth 2.0 client_id of the Relying Party as an audience value.` — put `aud REQUIRED` in the anchor cell.
- **S068 staged in-text quote is partial** (drops “access token”, “If the”). Quote the exact sentence or mark it as a paraphrase.

## Profile-label nuance

Canonical bodies were fetched with the brief's plain `curl -fsSL --max-time 30 '<url>'`; the column label `curl-fsSL-compressed-v1` is the lane's legacy name (its header documents the `--compressed -A …` command). The profiled control is recorded per row: S067/S068 identical, S066 differs only by leading CRLF and has an equal normalized digest. No other column depends on the choice.

## Hygiene

No production-file writes, no lane git/jj, no `agent://all`, no credential/vault/`op` contact, no installs, no refused work. Scratch `/fast/scratch/hyaku/kagi-r31/srcopenb` deleted with `rm -rf` after receipts were copied out; fetched bodies deliberately not retained (digests + exact re-fetch commands are in the receipts).
