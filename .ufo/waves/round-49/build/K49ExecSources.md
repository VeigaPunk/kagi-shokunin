# K49ExecSources — C1 sources captured and located (round 49, attempt 1)

Seat K49ExecSources. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE
`89afe91878f10805921d3caa67d28d21b33226da`, predeclaration `082bfb3f6baa2407df2a23c0489043495b4dce4d`.
Scratch: `/fast/scratch/hyaku/kagi-r49/K49ExecSources` (removed before yield). Nothing in `corpus/`,
`plans/`, the registry, `MANIFEST.json`, `.ufo/state` or any sibling repo was written; read-only
elsewhere.

## Deliverables (this directory)

| file | what |
|---|---|
| `K49ExecSources/S016.body` | live re-open of the registered S016 URL (47384 bytes) |
| `K49ExecSources/S105.body` | live capture of the OpenBao v2.7.2 release page (187539 bytes) |
| `K49ExecSources/S106.body` | live capture of the OpenBao PKI API doc (620683 bytes) |
| `K49ExecSources/fetch-log.tsv` | id, url, http_status, sha256, bytes, utc — one row per capture |
| `K49ExecSources/locators.tsv` | id, quote, count, rendered offset, normalization, section, note |
| `K49ExecSources/rows-proposed.md` | proposed registry rows, fetch rows and quote-bodies row, in the lane's exact formats, **not applied** |

## Captures

| id | url | http | raw sha256 | bytes | rendered-text-v1 sha256 | norm bytes | utc |
|---|---|---|---|---|---|---|---|
| S016 | https://openbao.org/docs/concepts/tokens/ | 200 | `ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef` | 47384 | `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` | 14608 | 2026-11-06T21:11:29Z |
| S105 | https://github.com/openbao/openbao/releases/tag/v2.7.2 | 200 | `4ab07b472d0e2b2bbb40970492b8735178b32f36200cd683709d0220feebb736` | 187539 | `0d4ef14ab1d884b95dab490b2e5042d8834905758770a3b4e94e3afecabdb717` | 6532 | 2026-11-06T21:11:29Z |
| S106 | https://openbao.org/docs/api/secret/pki/ | 200 | `9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123` | 620683 | `0419f2a3d02027386efc54a746e4ba7df502afbda6ab512802e111ff766eae93` | 164032 | 2026-11-06T21:11:30Z |

Profile for all three: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`;
final URL equals the registered URL (no redirect). `bytes` is the decoded body (`%{size_download}`
reports the compressed transfer: 12525 / 35648 / 68891).

### S016 re-open is content-identical to the recorded capture

- Docs `Version` label: `Version: Version 2.7.x`, count 1, rendered offset 838 (page title
  `Tokens | OpenBao`).
- Rendered-text digest `ed949658b434…` **reproduces the 2026-10-21 digest recorded in
  `corpus/source-fetches.tsv` exactly**; normalized bytes 14608.
- The decoded body is byte-identical to `corpus/fired-reverify.tsv`'s round-47 capture
  (`ea9bdafe7410…`, 47384 bytes, 2026-11-06T19:34:14Z) and to all four S016 requests this seat made
  today (21:08:33Z, 21:10:44Z, 21:11:29Z, plus one UA-fidelity check).
- The raw digest in the fetch row is `52295218…` (2026-10-21). The raw HTML changed between
  2026-10-21 and 2026-11-06; the teaching text did not. S016's row and its in-row pin are therefore
  still valid as a point attestation, and the round-49 on-release recheck is satisfied by content.

### S105 raw body is per-response volatile; the located quote is not

Three captures within three minutes produced three raw digests, all 187539 bytes:
`475f4e88…` (21:08:33Z), `73097736…` (21:10:44Z), `4ab07b47…` (21:11:29Z). The rendered-text digest
stayed `0d4ef14a…` and the title offset stayed 0. The round-38 capture `a69db256…` (2026-11-05,
192563 bytes) normalizes to `624fd300…` (6531 bytes) against today's 6532 bytes; a diff of the two
rendered texts is pure GitHub chrome:

- `…tasks, projects and automated work…` → `…tasks, projects, and automated work…`
- `Pull requests 75 ( 75 )` → `Pull requests 73 ( 73 )`

So a GitHub release row must be adjudicated on a located quote, never on page-digest equality, and a
raw byte offset is capture-specific (see the S093 note below).

### S106 is the page that grounds T5

Under §Create/Update role → §Parameters (heading at rendered 106321 and 107700):

> `generate_lease (bool: false) - Specifies if certificates issued/signed against this role will have
> OpenBao leases attached to them. Certificates can be added to the CRL by bao revoke <lease_id> when
> certificates are associated with leases.`

Both sentences locate count 1 (rendered offsets 120622 and 120723). Two captures minutes apart were
byte-identical (`9fa76939…`), but the docs site's raw body is build-coupled (S016 moved between
2026-10-21 and 2026-11-06), so the proposed fetch row declares `decoded-http-body-volatile-v1`.

## Every quote the trial cites, located with its count

`python3 corpus/rendered-text-v1.py locate <body> '<quote>'`, all count 1:

| test | quote | count | rendered offset | section |
|---|---|---|---|---|
| T1/T2/T5 | Every non-root token has a time-to-live | 1 | 7363 | §Token Time-To-Live, periodic tokens, and explicit max TTLs |
| T1 | After the current TTL is up, the token will no longer function | 1 | 7661 | same |
| T1/T5 | it, and its associated leases, are revoked | 1 | 7727 | same |
| T1 control | outside of direct operator interaction, OpenBao will never revoke a token before the returned TTL has expired | 1 | 9574 | §The general case |
| T2 | This value becomes a hard limit on the token's lifetime | 1 | 9754 | §Explicit max TTLs |
| T4 | logging in with any other (non- token ) auth method | 1 | 5523 | §Token hierarchies and orphan tokens |
| T4 | These tokens have no parent -- they are the root of their own token tree | 1 | 5231 | same |
| T3 | Can be Renewable Yes No | 1 | 12941 | §Token type comparison |
| T3 | Manually Revocable Yes No | 1 | 12965 | same |

Measured **count 0** (must not be used in the trial text or a registry quote):
`(non-token)`, `(non-token )`, `logging in with any other (non-token)`, `Batch tokens are not renewable`,
`Batch tokens are not manually revocable`. The orphan bullet's raw markup is
`(non-<code>token</code>)`, and rendered-text-v1 step 3 turns each tag into a space, hence
`(non- token )`. The batch limits exist only as the comparison-table rows; the page has no prose
sentence asserting them.

The full explicit-max-TTL hard cap sentence: “Tokens can have an explicit max TTL set on them. This
value becomes a hard limit on the token's lifetime -- no matter what the values in (1), (2), and (3)
from the general case are, the token cannot live past this explicitly-set value.”

## Proposed rows (details and exact bytes in `rows-proposed.md`)

- **S105** — OpenBao release page v2.7.2, `kind=code`, `tier=A`, `opened=2026-11-06`, `recheck=90d`,
  `used-by=corpus/lessons/round-49.md`. Evidence: page title, `Latest` badge (rendered offsets 1981 and
  1988), release line `github-actions released this 26 Oct 20:24`, release commit `9e0a0d3`,
  fetched 2026-11-06, raw `4ab07b47…`, 187539 bytes, normalized `0d4ef14a…`.
- **S106** — PKI secrets engine (API), `kind=docs`, `tier=A`, `opened=2026-11-06`,
  `recheck=on-release`, `used-by=corpus/knowledge/vault-openbao-token-lease-lifecycle.md`. Evidence:
  §Create/Update role §Parameters `generate_lease` entry; fetched 2026-11-06, raw `9fa76939…`,
  620683 bytes, normalized `0419f2a3…`.
- **Fetch rows** for both (16 columns, row-identity digests recomputed here and verified, quote ≤25
  words, location ≥8 characters).
- **Quote-bodies row** for S105 only: `.ufo/waves/round-49/build/K49ExecSources/S105.body`, byte offset
  17278, quote `Release v2.7.2 · openbao/openbao · GitHub`. Simulated `quote-locate.py` conditions all
  pass (body sha256/bytes equal the fetch row, manifest quote equals fetch quote, quote appears
  verbatim in the proposed registry row, bytes present at the offset).
- **No manifest row for S106**: its sentence does not occur verbatim in the decoded body (raw search
  −1), so no raw-literal offset exists — same position as S103/S104.

## Two findings that change the L1's landing plan

1. **S105 duplicates S093.** `S093` already registers the same URL, the same release and a tagged-title
   quote (capture `a69db256…`, 192563 bytes; manifest offset 21886). Recommendation, in preference
   order: (a) add nothing and reuse S093 plus S090's feed entry — C1 needs no new identity; (b) if a
   round-49-dated capture is wanted, add S105 as a *superseding* row (the S026→S016 / S090→S035
   pattern), mark S093 superseded, and keep S105's `kind=code` (S093 used `docs` for the same page);
   (c) if `S093-openbao-tag.body` is ever replaced, its manifest offset must be recomputed (21886 in
   the old body, 17271 in this round's body).
2. **S016's capture row must not be half-refreshed.** `corpus/inrow-pins.tsv` pins
   `capture_fetched=2026-10-21` for S016 and the census requires it to equal the fetch row's `fetched`.
   Refreshing the fetch row to 2026-11-06 therefore requires editing `inrow-pins.tsv` in the same
   commit (verdict stays `non-reproducing`; the in-row pin `c083fdca…` matches neither the new raw
   `ea9bdafe…` nor the normalized `ed949658…`). A quote-bodies row for S016 additionally requires the
   fetch quote (column 13) to equal the manifest quote *and* that sentence to appear in the S016
   registry row. Default: leave S016 as captured and record this re-open as corroboration.

Landing prerequisites from `corpus/sources-census.sh`: `used-by` must match
`^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\.md$`, the file must exist and carry the id literally
(SC_USEDBY_MISSING / SC_USEDBY_NOCITE); `corpus/lessons/round-49.md` does not exist yet, so S105's row
cannot land before that lesson exists; if the entry's `source:` line gains S106, S106's `used-by` must
list that exact entry path (SC_ENTRY_CITE).

## Recorded failures and non-findings

- `https://openbao.org/api-docs/secret/pki/` → HTTP 200 but only a **328-byte meta-refresh stub**
  (sha256 `169c82ad24610da6ab24d40aa51eac11a51d3d0d516164c5ac86c9042eb88819`,
  `<meta http-equiv="refresh" content="0; url=/docs/api/secret/pki/">`). `curl -L` does not follow a
  meta refresh, so the legacy URL carries no lease text; S106 cites the canonical
  `/docs/api/secret/pki/`. The stub was not kept as a capture (redirect shell, not a source).
- `released this 26 Oct 20:24` does not occur verbatim in the raw body (count 0 raw, 1 rendered).
- The docs pages emit U+200B ZERO WIDTH SPACE after each heading (`…explicit max TTLs ​ Every…`); the
  normalizer keeps U+200B, so a locator joining heading and body with one space reads count 0, and a
  heading alone is ambiguous (`Token Time-To-Live, periodic tokens, and explicit max TTLs` count 2:
  table of contents and body heading).
- Nothing was probed: no `bao` process, no server, no vault, no account, no token created, printed or
  stored. No host setting, service, package or PATH entry was touched; no tool was installed (none was
  needed), so there is no install to record.

## Commands run (exact, with exit codes and last output line)

| # | command | rc | last output line |
|---|---|---|---|
| 1 | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o S016.body -w '%{http_code} %{url_effective} %{size_download}' https://openbao.org/docs/concepts/tokens/` | 0 | `200 https://openbao.org/docs/concepts/tokens/ 12525` |
| 2 | same for `https://github.com/openbao/openbao/releases/tag/v2.7.2` → `S105.body` | 0 | `200 https://github.com/openbao/openbao/releases/tag/v2.7.2 35648` |
| 3 | same for `https://openbao.org/docs/api/secret/pki/` → `S106.body` | 0 | `200 https://openbao.org/docs/api/secret/pki/ 68891` |
| 4 | `python3 corpus/rendered-text-v1.py digest <body>` ×3 | 0 | `RENDERED_TEXT_V1: … normalized_sha256=ed949658…` / `…0d4ef14a…` / `…0419f2a3…` |
| 5 | `python3 corpus/rendered-text-v1.py locate <body> '<quote>'` ×16 | 0 (count 1) | `RENDERED_TEXT_V1_LOCATE: count=1` |
| 6 | same, the five non-locating forms | 1 (count 0) | `RENDERED_TEXT_V1_LOCATE: count=0` |
| 7 | `sha256sum` on the three bodies, on `.ufo/waves/round-47/capture/S016.body`, and on `.ufo/waves/round-38/capture/S093-openbao-tag.body` | 0 | `ea9bdafe…` S016 = round-47 capture; `4ab07b47…` S105; `9fa76939…` S106 |
| 8 | `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-38/capture/S093-openbao-tag.body` | 0 | `RENDERED_TEXT_V1: … normalized_sha256=624fd300… normalized_bytes=6531` |
| 9 | `curl -sS -o S106.body -L --compressed https://openbao.org/api-docs/secret/pki/` (legacy path probe) | 0 | HTTP 200, 328-byte meta-refresh stub (digest above) |

Format checks run against the proposed rows before writing this report: registry rows split on `|`
into 13 fields (11 cells); fetch rows split on tab into 16 columns with the row-identity digest
recomputing to column 3, `bytes` numeric, quote word counts 6 and 14, `location` lengths 42 and 62;
quote-bodies row has 4 columns with the quote present at its declared byte offset (count 1).

## Limits

This seat located documentation; it did not run `corpus/openbao-token-trial.sh`, the C1 counter or any
self-count. Whether the shipped v2.7.2 binary still behaves as S016 and S106 say is exactly what T1–T5
must measure, and that measurement is not in this report.

SEAT-STATUS: complete
