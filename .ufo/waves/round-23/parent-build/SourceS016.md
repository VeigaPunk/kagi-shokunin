# SourceS016 — S016 provenance audit (round 23)

Read-only audit of exactly one registry row: **S016**. No edits, no gate execution, no
re-curation, no admission authority. This report is advisory; L1 (KagiR23) decides.

## 0. Revision opened

| item | observed value |
|---|---|
| lane HEAD | `d218603b74099ddca0bd8f869516fc41db0979bf` |
| `corpus/SOURCES.md` working tree and HEAD blob | `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30` (118 lines) |
| last commit touching `SOURCES.md` | `254d632ed2f6174e1ffcfe636a17b5e18284212f`, 2026-10-20T20:19:12-03:00 |
| S016 row | line 22, sha256 `2452a1c2562216df7261e2f9e263f6d348451838898afa08c5803f51fc640e06`, 685 chars |
| row history | byte-identical at `HEAD`, `HEAD~1`, `254d632e`, `254d632e^` — unchanged since round 21 |
| used-by entry | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, 176 lines, sha256 `4932f37f6e4bc0cf312f9d844b1ab215cb66248846664715515e0fa8d7b17298` |
| corrected active entry | `corpus/knowledge/feature-bound-credential-review.md`, 60 lines, sha256 `53a24710f9b3f5c7355bbb0f7af622fbed6783dc7954234114d0c6c9ab2b42d8` |
| registry population | 23 rows: mined 21, queued 1, rejected 1 |

## 1. Row under audit (line 22, verbatim fields)

- source: `Tokens — https://openbao.org/docs/concepts/tokens/`; kind `docs`; tier `A`.
- scope: “OpenBao token policies, TTL, renewal, and revocation lifecycle”.
- anchor: “§Tokens and §Token Time-To-Live, periodic tokens, and explicit max TTLs; OpenBao 2.7.x”.
- teaches: “OpenBao documents token policy and TTL/renewal behavior, including revocation of a
  token's child tokens and associated leases.”
- quote: “When a parent token is revoked, all of its child tokens -- and all of their leases --
  are revoked as well.” (§Token hierarchies and orphan tokens).
- pin: `Fetch sha256: c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`.
- status `mined`; opened `2026-10-19`; recheck `on-release`; used-by as in §0.

## 2. Public reopen — 2026-10-21 (HTTP 200, no target execution)

| item | observed |
|---|---|
| final URL | `https://openbao.org/docs/concepts/tokens/` (canonical identical, status 200) |
| `last-modified` | `Tue, 20 Oct 2026 07:50:18 GMT` |
| `etag` | `W/"6ad71d3a-b918"` (weak; suffix `b918` = 47,384) |
| transfer | `content-encoding: gzip`, `content-length: 12527` |
| decoded entity | 47,384 bytes, sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` |
| normalized text | 14,571 chars, sha256 `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` |
| version label | “Version 2.7.x” (navbar + `meta-docusaurus_version`); no preview/beta label (0 occurrences) |
| heading ids | `token-hierarchies-and-orphan-tokens`, `token-time-to-live-periodic-tokens-and-explicit-max-ttls`, `service-vs-batch-token-lease-handling`, `token-type-comparison` (h2/h3, **unquoted** `id=` attributes) |
| quote location | raw byte offset 29,523; normalized offset 4,921; exactly 1 match after whitespace collapse |

Quote (22 whitespace tokens): “When a parent token is revoked, all of its child tokens -- and all
of their leases -- are revoked as well.” — §Token hierarchies and orphan tokens, opened
2026-10-21, <https://openbao.org/docs/concepts/tokens/>.

Release clock: the latest OpenBao release is **v2.7.1, 2026-10-01** (release feed; release notes
“Release date: October 1, 2026”). It predates the row's 2026-10-19 open, so `on-release` is not
triggered and no release exists after the open date.

## 3. Scoped teaching / tier / status against observed text

- **teaches — supported.** The page states policies control what the holder may do, every
  non-root token has a TTL, expiry revokes the token and its associated leases, and parent
  revocation reaches child tokens and their leases. The quoted sentence is present. Product is
  OpenBao only; the row does not extend it to Vault.
- **tier A — supported.** Vendor documentation for the product's own behavior, `kind=docs`, not
  `community`; no tier inflation.
- **status mined — supported for the fact, unresolved for disposition.** Round-22 prose calls
  S001–S016 “history” (`corpus/lessons/round-22-source-errata.md:9`), but no machine field carries
  that: `status` is still `mined` and the census treats it as an active cited row. “Historical” is
  prose, not a pointer a checker can follow.
- **anchor — incomplete.** The row's quote is from §Token hierarchies and orphan tokens, which the
  `anchor` column does not name; it appears only in the teaches parenthetical. A checker validating
  the anchor column against the page would not find the quote's section there.
- **scope compression — unresolved.** “renewal” and “revocation lifecycle” are not qualified by
  token type. The page says “The features in the following sections all apply to service tokens,
  and their applicability to batch tokens is discussed later.” (20 words). The comparison table
  gives batch tokens “Can be Renewable: No” and “Manually Revocable: No”. The quote's parent
  revocation does reach batch children unless orphan. This is a qualifier gap, not a false fact.
- **deployed-product proof — none.** “OpenBao 2.7.x” is a docs label. The v2.7.1 tag exists, but no
  deployed instance, binary, or runtime behavior is evidenced here, and the row does not claim one.

## 4. Pin and quote provenance — the real contradictions

**C2 contradiction A (digest).** The recorded pin `c083fdca…` is not reproducible from any
representation observable in this lane. Observed today: decoded HTML entity `52295218…` (47,384 B);
normalized text `ed949658…` (14,571 chars); gzip transfer entity `5ae6661f…` (12,527 B); CRLF
variant `11053405…`; zero-width-stripped `c3d072d7…`; upstream `tokens.mdx` `f05ae2ba…` (15,269 B).
The 2026-10-20 capture recorded the same entity and normalized hashes, so the current bytes are
stable across two days. The 2026-10-19 pin remains **non-reproducible**, not proven stale; no
2026-10-19 snapshot exists in the lane (Wayback availability returned HTTP 429 today). Worse, the
round-22 correction row for the same URL, **S021 (line 27), carries no `Fetch sha256:` at all**
(16 of 23 rows carry one; S017–S023 do not). So the ledger's only pin for this URL is
non-reproducible and its correction row has none.

**C2 contradiction B (quote contiguity).** The row presents the sentence between quotation marks
as verbatim, but it is not byte-contiguous in the served representation: 0 exact matches in raw
HTML, 0 after HTML-unescape, 1 only after whitespace collapse. In the upstream mdx it is also
line-wrapped (0 exact, 1 collapsed). The row records no normalization. A strict “quote present”
check fails this row; a lenient one passes without recording why.

**Transport/raw-HTML volatility.** The served HTML embeds build-scoped names
(`anchorTargetStickyNavbar_B866`, `/assets/css/styles.f040e9fc.css`, `/assets/js/main.aa34622e.js`),
so raw-HTML digests change per site build while content does not. The `content-length: 12527` is
the compressed transfer size; the decoded entity is 47,384 bytes. `etag` is weak (`W/`), so it is
not a byte-equality validator. The upstream mdx at `release/2.7.x` tip and at commit
`ec6ba09f484bf01d5892e3bcac63084127be2f27` (2026-08-10) is identical: `f05ae2ba…`, 15,269 bytes —
a stable source-level pin that the rendered page cannot provide.

**C1 pointer contradiction.** S021 shares S016's URL but its `teaches` never says `supersedes`;
every other correction row (S019/S020/S022/S023) does. The Paths line
(`corpus/SOURCES.md:35`) still routes `S012 → S013 → S014 → S015 → S016` although S012 and S013
are explicitly superseded by S022/S023. E3's machine-read `source:` line cites S016 and not S021;
S021 appears only in E3 prose (line 172). `feature-bound-credential-review.md` cites S021 (line 1,
row line 19). A pointer-following checker therefore resolves E3 to S016 and finds no supersession
edge; there is no field that says “S016's fact remains, its anchor/pin are superseded”.

## 5. C2 provenance spec for `corpus/source-fetches.tsv` + `SC_FETCH`

Record one row per fetch, append-only; one *active* row per `(id, representation)`. Tab-separated,
exact expectations:

| column | expectation | S016 observed value |
|---|---|---|
| `id` | resolves to exactly one registry row; duplicate active row fails | `S016` |
| `url` | equals the URL extracted from the `source` cell after canonicalization (lowercase scheme/host, no default port, no fragment, preserve path **and** trailing slash) | `https://openbao.org/docs/concepts/tokens/` |
| `fetch_date` | ISO date of the actual GET; ≤ today; a later fetch is a new row, never an overwrite | `2026-10-21` |
| `status` | HTTP status; `200` required for a mined row | `200` |
| `representation` | closed enum: `http-entity/html`, `normalized-text`, `upstream-src`; names the bytes hashed | `http-entity/html` |
| `sha256` | 64 lowercase hex of **decoded** entity bytes (after `content-encoding` removal) for HTML; never the gzip transfer body | `52295218…` |
| `bytes` | decimal length of the same decoded bytes; `content-length` is not this value when compressed | `47384` |
| `quote` | ≤25 whitespace-separated tokens; substring of the declared representation after the declared normalization | 22 tokens |
| `quote_normalization` | closed enum: `none`, `whitespace-collapse`, `whitespace-collapse+html-unescape`; required when `none` does not match | `whitespace-collapse+html-unescape` |
| `anchor` | visible heading + DOM id, id parsed from **unquoted** `id=` attributes or a DOM parser | `Token hierarchies and orphan tokens` / `token-hierarchies-and-orphan-tokens` |
| `anchor_offset` | optional byte offset in the declared representation | raw 29523 / normalized 4921 |
| `proof_class` | `docs-label`, `release-artifact`, or `deployed`; separates docs version from deployed-product proof | `docs-label` (`Version 2.7.x`) |
| `disposition` | `active`, `historical`, or `superseded-by:<id>`; `<id>` must be a mined row and must name the superseded scope in its `teaches` | `active` for the fact; anchor/pin need an explicit edge |

Fail-closed checks, one finding id each: missing provenance for a mined row; URL inequality; digest
shape; byte-count mismatch against a committed fixture; quote >25 tokens; quote absent under the
declared normalization; anchor absent from the representation (unquoted-attribute parse — a
`id="…"` regex finds 0 of 9 h2 ids here and would false-fail); duplicate/conflicting active rows;
`superseded-by` target not mined or not naming the scope.

Two design warnings from the observed row:

1. The plan's “in-row `Fetch sha256:` **or** a complete provenance row” disjunction passes S016's
   non-reproducible pin with no representation, byte count, date, or normalization. Treat an in-row
   pin alone as `legacy-pin` and raise `SC_FETCH_UNVERIFIABLE`; require the provenance row for every
   mined row, using the in-row pin only as a cross-check.
2. Do not treat a digest as a content-drift pin. It is a point attestation of the bytes fetched at
   `fetch_date`; the upstream commit pin (`ec6ba09f…` / `f05ae2ba…`) is the durable content anchor.

## 6. Synthetic minimal failing fixture for L1 (proposal, not a result)

Build under `mktemp -d` (never in the lane), one mined row and one fixture file:

- `corpus/SOURCES.md`: `| S900 | Tokens — https://openbao.org/docs/concepts/tokens/ | docs | A |
  OpenBao token policies | §Token hierarchies and orphan tokens | Quote: “When a parent token is
  revoked, all of its child tokens -- and all of their leases -- are revoked as well.” | mined |
  2026-10-19 | on-release | corpus/knowledge/e1.md |` (one line; no other rows needed for SC_FETCH).
- `corpus/knowledge/e1.md`: `source: S900 (…); verified-at: 2026-10-19; recheck: on-release`.
- `corpus/source-fetches.tsv`: `S900 <TAB> https://openbao.org/docs/concepts/tokens/ <TAB> 2026-10-21
  <TAB> http-entity/html <TAB> <sha256 of the fixture file> <TAB> 47384 <TAB> "When a parent token is
  revoked, all of its child tokens -- and all of their leases -- are revoked as well."
  <TAB> <empty quote_normalization> <TAB> token-hierarchies-and-orphan-tokens <TAB> docs-label
  <TAB> active`.
- `corpus/fixtures/s016/tokens.html`: the observed fragment with the real line break,
  `… all of its child tokens -- and all` + LF + `of their leases -- are revoked as well. …`.

Expect `SC_FETCH_QUOTE` (declared raw representation, quote not byte-contiguous, no normalization
declared). Control: set `quote_normalization=whitespace-collapse` and expect CLEAN. Two cheap
mutations: provenance URL without the trailing slash → `SC_FETCH_URL`; 63-hex digest →
`SC_FETCH_DIGEST`. Optional C1 fixture: an obligation `D7` disposed `fixed` with pointer
`corpus/SOURCES.md` (the file exists) while no provenance row exists — the checker must fail on the
obligation predicate, not merely on pointer existence; otherwise a resolved path certifies a false fix.

## 7. Recommended L1 actions (no edits made here)

1. Add a provenance row for S016 and S021 (representation, decoded bytes, sha256, fetch date,
   `quote_normalization`, anchor id, `proof_class`, `disposition`). Keep `c083fdca…` as `legacy-pin`;
   do not silently overwrite it.
2. Add `§Token hierarchies and orphan tokens` to S016's `anchor` column, or quote a contiguous
   fragment (e.g. “When a parent token is revoked, all of its child tokens”, 11 tokens).
3. Add the missing supersession edge: S021's `teaches` should say it supersedes S016's **anchor and
   pin only** (the fact is unchanged), or add a `disposition` field to S016. Update the Paths line
   (`SOURCES.md:35`) to the active chain or mark the superseded hops.
4. Tighten `SC_FETCH` as in §5; specifically remove the in-row-pin-or-row disjunction and parse
   anchors with an unquoted-attribute-tolerant parser.
5. Record `proof_class` so a docs label (`2.7.x`) is never read as deployed-product proof; v2.7.1
   is a release artifact, not a deployment.

## 8. Limits / honest opens and failures

- Reopened today: the docs page (HTTP 200), the release notes page (HTTP 200), the releases feed
  (HTTP 200), the upstream mdx at branch tip and at the named commit (both HTTP 200).
- Failed: Wayback availability API returned **HTTP 429**; no 2026-10-19 snapshot could be replayed,
  so the historic pin's exact recipe remains unknown. “Non-reproducible”, not “stale”.
- No gate was run (`sources-census.sh`, claim ledger, stamps, selftest): read-only audit. No
  behavioral or live-substrate command was executed.
- No deployed OpenBao/Vault instance, account, token, or vault was contacted or inspected.
- Did not audit S012–S015 or S017–S023 beyond supersession/pointer facts needed for S016.
- No tool installed or updated; no package/service/host mutation.
- This report does not change S016's `mined` status or S021's; rejected/queued rows are untouched.
  It is not admission, not re-curation, and not an outside-agreement claim.

## 9. Parent checks after integration (suggested, not run)

1. `bash corpus/sources-census.sh` — expect CLEAN; then add/verify the new `SC_FETCH` cases.
2. Verify the new provenance row reproduces: fetch the URL once, require 47,384 decoded bytes and
   `52295218…`, and compare the upstream mdx at commit `ec6ba09f…` to `f05ae2ba…`.
3. Confirm the S016/S021 disposition edge is machine-readable and that Paths no longer traverses
   superseded S012/S013 without an annotation.
4. Confirm `grep -c 'Fetch sha256:' corpus/SOURCES.md` reaches 23 of 23 or that every remaining
   in-row-only pin is reported as `legacy-pin` rather than passing as verified provenance.
