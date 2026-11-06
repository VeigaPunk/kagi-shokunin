# K49ExecSources — proposed registry, fetch and quote-bodies rows (round 49, NOT applied)

Seat K49ExecSources, 2026-11-06. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE
`89afe91878f10805921d3caa67d28d21b33226da`, predeclaration `082bfb3f6baa2407df2a23c0489043495b4dce4d`.
Everything below is **proposed text copied into the report directory**: no lane file was edited. The
registry rows are written by the L1; this seat captured and located.

Captures sit next to this file: `S016.body`, `S105.body`, `S106.body`; machine evidence is in
`fetch-log.tsv` (id, url, http_status, sha256, bytes, utc) and `locators.tsv`
(id, quote, count, rendered offset, section).

## 1. Live fetch results

| id | url | http | raw sha256 | bytes | rendered-text-v1 sha256 | norm bytes | captured (UTC) |
|---|---|---|---|---|---|---|---|
| S016 | https://openbao.org/docs/concepts/tokens/ | 200 | `ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef` | 47384 | `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` | 14608 | 2026-11-06T21:11:29Z |
| S105 | https://github.com/openbao/openbao/releases/tag/v2.7.2 | 200 | `4ab07b472d0e2b2bbb40970492b8735178b32f36200cd683709d0220feebb736` | 187539 | `0d4ef14ab1d884b95dab490b2e5042d8834905758770a3b4e94e3afecabdb717` | 6532 | 2026-11-06T21:11:29Z |
| S106 | https://openbao.org/docs/api/secret/pki/ | 200 | `9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123` | 620683 | `0419f2a3d02027386efc54a746e4ba7df502afbda6ab512802e111ff766eae93` | 164032 | 2026-11-06T21:11:30Z |

Request profile for all three: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`
(`curl-fsSL-compressed-v1`); final URL equals the registered URL for all three (no redirect).

- **S016 re-open.** The docs page still carries `Version: Version 2.7.x` (count 1, rendered offset 838)
  and the rendered-text digest `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` **reproduces the digest recorded on the 2026-10-21 capture**
  exactly. The decoded body is byte-identical to `corpus/fired-reverify.tsv`'s round-47 capture
  (`ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef`, 47384 bytes, 2026-11-06T19:34:14Z) and to every S016 fetch this seat made today (four requests, 21:08:33Z-21:11:29Z). The raw
  digest recorded in `corpus/source-fetches.tsv` for S016 is `52295218…` (2026-10-21): the raw HTML
  changed since then, the teaching text did not.
- **S105 volatility measured.** Three captures of the release page within three minutes gave three
  different raw digests (`475f4e88…`, `73097736…`, `4ab07b47…`), all 187539 bytes, while the
  rendered-text digest stayed `0d4ef14ab1d884b95dab490b2e5042d8834905758770a3b4e94e3afecabdb717` and the title offset stayed 0. GitHub release pages are
  per-response volatile; cite the located quote, never a raw digest equality.
- **S106 stability measured.** Two captures minutes apart were byte-identical (`9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123`). The docs site's
  raw body is still build-coupled (S016's own raw digest moved between 2026-10-21 and 2026-11-06 while
  its rendered text did not), so the fetch row declares `decoded-http-body-volatile-v1`.

## 2. Quotes the trial cites — located, with counts

`count` is `python3 corpus/rendered-text-v1.py locate <body> '<quote>'` on the capture named above;
`offset` is the rendered-text character offset. Full machine rows: `locators.tsv`.

| test | quote (≤25 words) | count | rendered offset | section |
|---|---|---|---|---|
| T1/T2/T5 | Every non-root token has a time-to-live | 1 | 7363 | §Token Time-To-Live, periodic tokens, and explicit max TTLs |
| T1 | After the current TTL is up, the token will no longer function | 1 | 7661 | same section |
| T1/T5 | it, and its associated leases, are revoked | 1 | 7727 | same section |
| T1 control | outside of direct operator interaction, OpenBao will never revoke a token before the returned TTL has expired | 1 | 9574 | §The general case |
| T2 | This value becomes a hard limit on the token's lifetime | 1 | 9754 | §Explicit max TTLs |
| T4 | logging in with any other (non- token ) auth method | 1 | 5523 | §Token hierarchies and orphan tokens |
| T4 | These tokens have no parent -- they are the root of their own token tree | 1 | 5231 | same section |
| T3 | Can be Renewable Yes No | 1 | 12941 | §Token type comparison |
| T3 | Manually Revocable Yes No | 1 | 12965 | same section |

Quote forms that **do not** locate, and must not be used (count 0 each, measured):
`(non-token)`, `(non-token )`, `logging in with any other (non-token)`, `Batch tokens are not renewable`,
`Batch tokens are not manually revocable`. The rendered text of the orphan bullet is
`logging in with any other (non- token ) auth method` — the raw markup is
`(non-<code>token</code>)`, and rendered-text-v1 step 3 replaces each tag with one space, so the
located form carries a space after `non-` and before `)`. The batch limits exist only as the comparison-table rows
`Can be Renewable Yes No` / `Manually Revocable Yes No`; there is no prose sentence saying they are
not renewable or not manually revocable.

The explicit-max-TTL hard-cap sentence, in full, is: “Tokens can have an explicit max TTL set on them.
This value becomes a hard limit on the token's lifetime -- no matter what the values in (1), (2), and (3)
from the general case are, the token cannot live past this explicitly-set value.”

## 3. Proposed registry rows (append after S104, `corpus/SOURCES.md`; 11 columns)

```
| S105 | OpenBao release page v2.7.2, GitHub — https://github.com/openbao/openbao/releases/tag/v2.7.2 | code | A | OpenBao server release identity: the v2.7.2 tag is the stable release the round-49 C1 trial runs against, the tag the installed `bao` binary is sha256-pinned to; release metadata only, not OpenBao behaviour | Release page title, Latest badge, release line “released this 26 Oct 20:24” and release commit 9e0a0d3; fetched 2026-11-06 (decoded body, raw sha256 4ab07b47…feebb736, 187539 bytes; the raw body is per-response volatile, the rendered-text digest and the title offset were stable across three same-day captures) | the release page marks v2.7.2 Latest and S090's feed lists v2.7.2 as the first stable entry, so a bao binary reporting v2.7.2 is the documented release rather than a local build. Quote: “Release v2.7.2 · openbao/openbao · GitHub” | mined | 2026-11-06 | 90d | corpus/lessons/round-49.md |
| S106 | PKI secrets engine (API) — https://openbao.org/docs/api/secret/pki/ | docs | A | OpenBao PKI role parameter `generate_lease`: a role decides whether certificates it issues or signs carry OpenBao leases, the lease the round-49 C1 T5 test revokes through its token | §Create/Update role, §Parameters, `generate_lease` entry and the CRL sentence that follows it; title PKI secrets engine (API), docs Version 2.7.x; fetched 2026-11-06 (decoded body, raw sha256 9fa76939…5e5c1123, 620683 bytes) | `generate_lease` defaults to false; when true, certificates issued or signed against the role have OpenBao leases attached, and a lease is revoked by `bao revoke <lease_id>`. Quote: “Specifies if certificates issued/signed against this role will have OpenBao leases attached to them” | mined | 2026-11-06 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```

Landing prerequisites these two rows inherit from `corpus/sources-census.sh`:

1. `used-by` must match `^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\.md$`, the file must exist, and the
   file must carry the id literally (SC_USEDBY_MISSING / SC_USEDBY_NOCITE). S105 names
   `corpus/lessons/round-49.md`, which does not exist yet; S106 names the existing knowledge entry.
2. If the entry's `source:` line gains S106, S106's `used-by` must list that exact path (SC_ENTRY_CITE).
   S016's row already lists the entry.
3. Each `mined` row needs exactly one 16-column fetch row (SC_FETCH) and a `used-by` that is not `-`.

## 4. Proposed fetch rows (`corpus/source-fetches.tsv`, 16 tab-separated columns)

```
S105	mined	eb16ed531a0f074dfb15fdb121e43db05737ee17a507a794c4acf8a2d943e19a	https://github.com/openbao/openbao/releases/tag/v2.7.2	https://github.com/openbao/openbao/releases/tag/v2.7.2	200	curl-fsSL-compressed-v1	2026-11-06	decoded-http-body-volatile-v1	4ab07b472d0e2b2bbb40970492b8735178b32f36200cd683709d0220feebb736	187539	-	Release v2.7.2 · openbao/openbao · GitHub	rendered-text-v1	0d4ef14ab1d884b95dab490b2e5042d8834905758770a3b4e94e3afecabdb717	release page title, rendered-text offset 0
S106	mined	31544569b76741f31d98a9e0e3671de1ea6d1932d6aa17fc635f95b9af9f4d27	https://openbao.org/docs/api/secret/pki/	https://openbao.org/docs/api/secret/pki/	200	curl-fsSL-compressed-v1	2026-11-06	decoded-http-body-volatile-v1	9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123	620683	-	Specifies if certificates issued/signed against this role will have OpenBao leases attached to them	rendered-text-v1	0419f2a3d02027386efc54a746e4ba7df502afbda6ab512802e111ff766eae93	§Create/Update role, §Parameters, generate_lease entry, rendered-text offset 120622
```

Both verify: row-identity digest = sha256(`id<TAB>status<TAB>url<LF>`) recomputed here; status matches
the proposed registry status; quote ≤25 words; `location` ≥8 characters; one row per id.

## 5. Proposed quote-bodies row (`corpus/quote-bodies.tsv`, 4 tab-separated columns)

```
S105	.ufo/waves/round-49/build/K49ExecSources/S105.body	17278	Release v2.7.2 · openbao/openbao · GitHub
```

`quote-locate.py` requires a manifest row's quote to equal the same id's fetch row quote (column 13),
its body sha256/bytes to equal the fetch row's (columns 10/11), and the quote to appear verbatim in the
registry row. This row satisfies all three: `S105.body` is the exact body the fetch row records, the
quote is the fetch quote, and the proposed S105 row carries that string. Offset 17278 is the
byte offset of `Release v2.7.2 · openbao/openbao · GitHub` inside the `<title>` element, which opens
at 17271; the untagged text is what the fetch row's quote column carries, so the manifest and the
fetch row agree exactly.

Not proposed: a manifest row for **S106** — the `generate_lease` sentence does **not** occur verbatim in
the decoded body (raw search returns -1), so no raw-literal offset exists; S103 and S104 are in the same
position and have no manifest row either.

### Optional: refresh S016's capture row — do not apply this half-way

The current S016 fetch row is the 2026-10-21 capture (`52295218…`, 47384 bytes). A refresh is **coupled
to two other files** and only safe as one atomic change:

```
S016	mined	0162a916441e5f602393cb312cb4d1b16cdf4b91672a323660b3c02879b5ac2b	https://openbao.org/docs/concepts/tokens/	https://openbao.org/docs/concepts/tokens/	200	curl-fsSL-compressed-v1	2026-11-06	decoded-http-body-volatile-v1	ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef	47384	-	Every non-root token has a time-to-live	rendered-text-v1	ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3	§Token Time-To-Live, periodic tokens, and explicit max TTLs, rendered-text offset 7363
```

1. `corpus/inrow-pins.tsv` requires `capture_fetched` to equal the S016 fetch row's `fetched` column, so
   the date must move from `2026-10-21` to `2026-11-06` in the same commit, or SC_INROW fires
   `capture-date`. The verdict stays `non-reproducing` (neither the new raw `ea9bdafe7410…` nor the
   normalized `ed949658b434…` equals the in-row pin `c083fdca8645…`).
2. A quote-bodies row for S016 requires the fetch quote (column 13) to change to the manifest quote,
   and that same sentence must appear verbatim in the S016 registry row, which today quotes the
   parent-revocation sentence instead. Applying only part of this trio breaks `quote-locate.py`.
3. The default recommendation is to **leave S016 as captured on 2026-10-21** and record the 2026-11-06
   re-open (rendered digest identical, body identical to the round-47 capture) as corroboration in the
   round-49 lesson. Nothing in C1 needs the fetch row refreshed.

## 6. Duplicate finding — S105 collides with S093

`S093` already registers the **same URL** for the same release: S093 opened 2026-11-05, capture
`.ufo/waves/round-38/capture/S093-openbao-tag.body` (`a69db256…`, 192563 bytes, rendered digest
`624fd300e307ace5a25a4189887c57e332a1eabc32f8b95f22cd18847d706c18`), with quote
`<title>Release v2.7.2 · openbao/openbao · GitHub</title>` and, in `corpus/quote-bodies.tsv`, byte
offset 21886.

Options, in preference order:

1. **Reuse S093 and add nothing.** C1's release identity is satisfied by S093 (and by S090's feed entry);
   S105 then adds no identity the lane lacks. My capture stands as corroboration in the report.
2. **Add S105 as a superseding row** (the lane's S026→S016 / S090→S035 pattern) if the L1 wants a
   round-49-dated capture. Then S093 should be marked superseded in its own row text, and S105's
   `kind` should be `code` to match S103/S104 (S093 used `docs` for the same page).
3. Never overwrite `S093-openbao-tag.body` with a new capture without recomputing the manifest offset:
   the title sits at 21886 in the 192563-byte body and at 17271 in this round's 187539-byte body.

## 7. Recorded fetch failures and non-findings

- `https://openbao.org/api-docs/secret/pki/` (the legacy API-docs path) returns **HTTP 200** but only a
  328-byte meta-refresh stub (`<meta http-equiv="refresh" content="0; url=/docs/api/secret/pki/">`);
  `curl -L` does not follow a meta refresh, so the stub carries no lease text. The row must cite
  `https://openbao.org/docs/api/secret/pki/`, which is what S106 proposes. Stub bytes were not kept as a
  capture (it is a redirect shell, not a source).
- The GitHub release page has no working `Release v2.7.2` "Latest" *text* other than the badge repeated
  twice (`Latest Latest`, rendered offsets 1981 and 1988); the release line is
  `github-actions released this 26 Oct 20:24` (offset 2198) and the release commit is `9e0a0d3`.
  `released this 26 Oct 20:24` does **not** occur verbatim in the raw body (count 0 raw, 1 rendered).
- The OpenBao docs site emits U+200B ZERO WIDTH SPACE after every heading, so the rendered text reads
  `…explicit max TTLs ​ Every non-root…`. The normalizer keeps U+200B (it is not Unicode
  whitespace), so a locator that joins a heading to its body with one space reads count 0 (measured);
  a heading alone is ambiguous — `Token Time-To-Live, periodic tokens, and explicit max TTLs` reads
  count 2 (table of contents and body heading).
- Nothing was probed: no `bao` process, no vault, no account, no token was created, printed or stored by
  this seat.

## 8. Where this fails to help C1

S016 and S106 support T1–T5 as *documented* behaviour only. Neither page shows that the shipped
v2.7.2 binary still behaves that way; that is what the trial must measure, and this seat did not run it.

