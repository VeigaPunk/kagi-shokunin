# Round 23 — S014 source-bound provenance audit (scout)

Scope: EXACT registry row **S014** in `corpus/SOURCES.md`, its public canonical URL and
named anchors, its `used-by` pointer, and its standing under the planned C2 fetch+quote
provenance contract. Read-only; no registry/entry/stamp edit; no gate run; no OpenBao or
Vault deployment, account, or probe; no installs.

- Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (`git log -1`, 2026-10-20
  21:11:59 -0300, "round-22 verifier spot-check (integrator, hyaku): non-author admit/reject").
- Base digests at audit time (2026-10-21T03:44:48Z):
  `corpus/SOURCES.md` = `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`
  (118 lines); `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` =
  `4932f37f6e4bc0cf312f9d844b1ab215cb66248846664715515e0fa8d7b17298` (176 lines).
- Access: page fetched 2026-10-21 ~03:4xZ over HTTPS, `Accept-Encoding: identity`, no
  cookies/auth, both via the reader and a direct `urllib` GET. Nothing was executed on the
  target; no command from any ledger or source body was run.

## 1. Row under audit (verbatim, `corpus/SOURCES.md:20`)

```
| S014 | JWT/OIDC auth method — https://openbao.org/docs/auth/jwt/ | docs | A | OpenBao JWT/OIDC authentication and role claim validation | §JWT/OIDC auth method and §JWT verification; OpenBao 2.7.x | OpenBao 2.7.x supports OIDC and direct-JWT authentication with configured signature verification and claim handling. Quote: “The JWT auth method can be used to authenticate with OpenBao using OIDC” (§JWT/OIDC auth method). Fetch sha256: `e94723241fbcbdd0b2741c569f6ce51befe39e526cd736cebe4023fbca1cb0b1`. | mined | 2026-10-19 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```

## 2. What was opened (observed)

| item | observation |
|---|---|
| URL | `https://openbao.org/docs/auth/jwt/` — HTTP 200, final URL identical (no redirect), `text/html; charset=utf-8` |
| transport | `Server: GitHub.com`; `Last-Modified: Tue, 20 Oct 2026 07:50:18 GMT`; `ETag: "6ad71d3a-f646"`; `Cache-Control: max-age=600`; `Vary: Accept-Encoding` |
| body | 63,046 bytes; raw sha256 `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` |
| normalized text | strip `script`/`style`, tags→single space, `html.unescape`, collapse whitespace → 15,911 chars; sha256 `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403` |
| version | on-page `Version: Version 2.7.x`; `meta-docsearch:version: 2.7.x`; selector also lists `next` (Development) and 2.6.x/2.5.x |
| headings present | H1 `JWT/OIDC auth method`; H2 `JWT authentication` → H3 `JWT verification` (`id=jwt-verification`); H3 `Bound claims` (`id=bound-claims`); H3 `Claims as metadata` (`id=claims-as-metadata`); H2 `Configuration` (`id=configuration`); H3 `Claim specifications and JSON pointer` |
| upstream source | `website/content/docs/auth/jwt/index.mdx` on `release/2.7.x` — 16,220 bytes, sha256 `8d0aeba8cc43a4d1abe9e9eb0dacbefe7350847dcc6dca4167a2bac1593b0965`; still contains the anchored sentence verbatim as ``The `jwt` auth method …`` |
| `next` route | `https://openbao.org/docs/next/auth/jwt/` (200) still carries Q1, the three-methods sentence and the optional-mapping sentence — no imminent drift, but `next` is not this row's pin |
| releases | GitHub releases API latest = `v2.7.1`, published 2026-10-01T14:03:19Z |

Quotes (each ≤25 words; heading/date/URL above):

- Q1 — “The jwt auth method can be used to authenticate with OpenBao using OIDC or by
  providing a JWT” (H1 *JWT/OIDC auth method*; rendered as `<code>jwt</code>`).
- Q2 — “This process can be done in three different ways, though only one method may be
  configured for a single backend” (§JWT verification).
- Q3 — “Data from claims can be copied into the resulting auth token and alias metadata by
  configuring claim_mappings.” (§Claims as metadata).
- Q4 — “If a claim is configured in claim_mappings, it must exist in the JWT when using
  JSON pointer syntax” (§Claims as metadata).
- Q5 — “Claim mappings which do not begin with a / are optional.” (§Claims as metadata).

## 3. Scoped recheck: teaches / scope / tier / status

| field | verdict | basis |
|---|---|---|
| `teaches` "supports OIDC and direct-JWT authentication" | **supported** | Q1; the page documents both an OIDC browser flow and a direct-JWT flow, with the method chosen per role |
| `teaches` "configured signature verification" | **supported** | §JWT verification: static keys, JWKS, OIDC Discovery; Q2 bounds it to one method per backend |
| `teaches` "claim handling" | **supported** | §Bound claims (bound parameters validated after signature/expiry), §Claims as metadata (Q3/Q4/Q5), §Claim specifications and JSON pointer |
| `scope` "OpenBao JWT/OIDC authentication and role claim validation" | **supported** | H1 + §Bound claims; no Vault statement on the page (the `vault` strings are example claim URIs and the `/ui/vault/...` path) |
| `anchor` "§JWT/OIDC auth method and §JWT verification" | **not false, under-declared** | both exist; the `used-by` entry also cites §Configuration, §Bound claims, §Claims as metadata (`…-lifecycle.md:3`), which the row does not name |
| `tier` A | **supported** | vendor primary documentation; no community/secondary source involved |
| `status` mined | **supported, unchanged** | page carries the teaching; no superseding row exists (see §5); census handshake intact (see §6) |
| `recheck` on-release | **clock not fired** | latest release `v2.7.1` (2026-10-01) predates `opened` 2026-10-19; docs label still 2.7.x |
| deployed-product proof | **none, and none claimed** | the row asserts documentation-level support for the 2.7.x line; "2.7.x" is a docs version route, not an observed binary. Recommend wording "OpenBao 2.7.x documentation specifies" if the field is ever revised |

## 4. Hash provenance: recorded digest vs current bytes

The recorded `Fetch sha256: e9472324…` is **not reproducible** on the current page under any
of seven tested representations:

| representation | sha256 | matches `e9472324…` |
|---|---|---|
| raw response body (identity encoding) | `449ef132ba380948…` | no |
| tags→space, unescape, whitespace-collapse | `ca496ad8f8226d84…` | no |
| tags→space, no unescape, collapse | `f77b1fd9daa5ddc1…` | no |
| tag-strip without space, collapse | `b8f763fb2abd6272…` | no |
| unescape-then-strip | `8859017ec94ce9f4…` | no |
| `<article>` region only | `9ca33d075a4f7866…` | no |
| gzip(raw) with mtime=0 | `229ab695637a5ce5…` | no |

Two facts bound this:

1. The current raw and normalized digests are **byte-identical to the round-22 re-open**
   (`kagi-shokunin/.ufo/waves/round-22/build/Source14.md` §1: 63,046 bytes,
   `449ef132…`, 15,911 chars, `ca496ad8…`) and the upstream MDX digest is identical too.
   So no redeploy occurred between 2026-10-20T21:37Z and this audit; the observed content
   identity is stable, not incidental.
2. The 2026-10-19 bytes remain unrecoverable (round-22 found no Wayback capture and no
   built-site history). The recorded `e9472324…` is therefore a **historical point
   observation whose representation is undocumented** — neither proof of drift nor a
   re-verifiable expected value.

The raw-HTML digest is deployment-coupled in this site: `Last-Modified` is site-wide
(2026-10-20T07:50:18Z for `/docs/auth/jwt/`, `/docs/concepts/tokens/`, `/docs/` and `/` in
round-22), the `ETag` is `<mtime-hex>-<size-hex>`, and the HTML serializes attributes
unquoted (`id=jwt-verification`), so byte-level identity is a transport artifact, not
content identity. The stable content anchors are the anchored text (Q1–Q5) and the upstream
MDX file at a named ref.

## 5. Supersession and disposition

- **No row supersedes S014.** The registry's explicit supersessions are S019→S007,
  S020→S006, S022→S012, S023→S013 (`corpus/SOURCES.md:25–29`); S021 is the OpenBao *tokens*
  re-open of S016, not of S014.
- Round-22's `Source14.md` §5 proposed a **superseding row "S021 (re-open of S014)"**. That
  proposal was **not integrated**: the S021 id was consumed by the tokens row, and no row
  now carries S014's corrected quote/anchor. The only surviving records of the correction are
  prose caveats — `corpus/SOURCES.md:86` ("S014's uppercased JWT quote is normalized
  text, not a case-literal excerpt") and the round-22 build artifact.
- Consequence: S014 remains `mined`, keeps a quote that is **not a literal substring** of
  the served page, and keeps an anchor narrower than its own entry's citation. It is not
  rejected or queued, and this report does not admit or reject anything.

## 6. Used-by pointer follow (local, one hop)

`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`

- `:3` single `source:` line cites S014 with "§JWT verification, §Bound claims, §Claims as
  metadata, OpenBao docs Version 2.7.x" → census `SC_USEDBY_NOCITE` / `SC_ENTRY_CITE`
  handshake would hold (I did not run the gate; this is a read of the two files only).
- `:33` "three methods — static keys, JWKS, OIDC Discovery — one per backend" → **supported**
  by Q2.
- `:34–35` claims copied "into the resulting auth token and alias metadata"; pointer-mapped
  claims required to exist, non-pointer mappings optional → **supported by Q3/Q4/Q5**; the
  entry's own round-22 erratum (`:144–148`) already narrows the pointer wording.
- `:40` "Claims gate the login and become metadata." → **overbroad as worded** and still
  present: under S014, bound parameters gate *authorization after* signature/expiry
  validation, `user_claim`/`groups_claim` map Identity aliases, and claims become metadata
  only via `claim_mappings` (Q3). Round-22 `Source14.md` §3 item 5 rejected this sentence
  "as worded", but the entry's appended erratum does not retract it explicitly. Downstream
  carrier gap, not a source-row defect.
- `corpus/stamps.tsv:35` records the entry at `4932f37f…` / 176 lines, matching the live
  file — no stamp mismatch.
- No `corpus/claim-ledger.tsv` row cites S014 or the entry (grep, 0 hits), so the closure
  for S014 is: row → one knowledge entry. `corpus/lessons/round-21.md:68` additionally
  reproduces the same non-literal quote, which is where the row's quote was transcribed
  from.

## 7. Planned C2 fetch+quote provenance — exact expectations

For this row (and as the general record shape), a fetch record must carry:

```
url_final        https://openbao.org/docs/auth/jwt/            # post-redirect, recorded final
http_status      200
captured_at      2026-10-21T03:44:48Z                          # UTC, seconds
representation   normalized_text@v1
                 recipe: decode UTF-8; drop <script>/<style> bodies; each remaining tag -> one
                 space; html.unescape; collapse [\t\r\n\f ]+ -> " "; strip ends
digest_sha256    ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403   (len 15911)
transport_note   Last-Modified 2026-10-20T07:50:18Z; ETag "6ad71d3a-f646"  # recorded, never a check
content_pin      repo openbao/openbao, ref release/2.7.x,
                 path website/content/docs/auth/jwt/index.mdx,
                 sha256 8d0aeba8cc43a4d1abe9e9eb0dacbefe7350847dcc6dca4167a2bac1593b0965
anchor           heading_path, e.g. ["JWT/OIDC auth method"] (H1, no URL fragment id) or
                 ["JWT authentication","JWT verification"] (fragment #jwt-verification)
quote            text "The jwt auth method can be used to authenticate with OpenBao using
                 OIDC or by providing a JWT"
                 normalization: [tag_flatten(code), whitespace_collapse]; case_fold: false
                 literal_in_anchor_scope: true
```

Rules the checker must enforce:

1. **A digest must name its representation and recipe.** A bare `sha256` is not a
   verifiable expectation; S014's `e9472324…` is exactly the failure mode.
2. **A quote must be a literal substring of the named anchor's normalized text** after only
   the declared normalizations. Case folding is never implicit: a case-folded match must be
   reported as `normalized`, not as a located quote (QM14 keeps the old value in the
   migration record).
3. **Anchor resolution is by heading path, not URL fragment alone** — the H1 carries no id,
   and Docusaurus attribute quoting is not stable (`id=jwt-verification` unquoted).
4. **Raw-HTML/`ETag`/`Last-Modified` digests are transport artifacts.** A mismatch is never
   semantic drift; only the quote + anchor + upstream source pin decide content.
5. **Historical rows are not failed for being historical.** A `mined` row's original
   `opened`/hash/quote stay as recorded; corrections land in a superseding row (lane
   convention: S019/S020, S022/S023). The checker compares the *active* row, and reports an
   uncorrected non-literal quote as `historical-unreconciled`, not as a new contradiction.

**One real contradiction (live, reproducible):** the registered S014 quote
“The JWT auth method can be used to authenticate with OpenBao using OIDC” has **0 literal
occurrences** in the served page; the page renders ``The `jwt` auth method …`` — 1
occurrence case-insensitively. The quote is also a truncated sentence (the page continues
"or by providing a JWT"). Fix: supersede S014 with a new row (next free id at read time:
**S024**) carrying Q1 verbatim with `tag_flatten` declared, anchors §JWT/OIDC auth method,
§JWT verification, §Bound claims, §Claims as metadata, §Configuration, and the
`normalized_text@v1` digest above plus the `release/2.7.x` MDX pin; S014's row is retained
unchanged as the historical 2026-10-19 record. A second, weaker instance: the recorded
`e9472324…` matches none of the seven representations in §4, so any C2 that recomputes a
raw-HTML digest will flag every row after each site redeploy — the 2026-10-20 redeploy
already did exactly that.

## 8. Synthetic minimal failing fixture for L1 (proposal, not a result)

Model on `corpus/sources-census.sh --selftest` (fixture tree under `mktemp -d`, one mutation
per finding id, asserted exit code + finding id + count). Offline; no network.

```
fixture-c2/
  registry.md              # one 13-field (11-cell) row: S900 | docs | A | … | mined | 2026-10-21 | on-release | corpus/knowledge/k.md
  corpus/knowledge/k.md    # source: S900 (…) + verified-at:/recheck: lines
  page.html                # served bytes: <p>The <code>jwt</code> auth method can be used to authenticate with OpenBao using OIDC</p>
  fetch.json               # {"url":"page.html","representation":"raw_html","sha256":"<sha of a DIFFERENT string>",
                           #  "quote":"The JWT auth method can be used to authenticate with OpenBao using OIDC",
                           #  "anchor":"JWT/OIDC auth method"}
```

Expected: exit non-zero, one line per finding —
`C2_QUOTE_NOT_LITERAL` (case-mangled quote, 0 case-sensitive matches in the anchor text),
`C2_DIGEST_MISMATCH` / `C2_REPRESENTATION_UNDECLARED` (recorded digest recomputed over
`raw_html` differs from the fixture's declared representation), and
`C2_ANCHOR_MISSING` when the anchor heading is removed. Control fixture: same tree with
quote `The jwt auth method …` and a digest computed over the declared representation →
exit 0. The fixture must fail on the *first* run; no fabricated passing output.

## 9. Falsifier

S014's teaching is falsified if, on a future open: Q1 or the two-flow description is gone;
§JWT verification offers other than three methods or allows more than one per backend;
§Claims as metadata copies claims without `claim_mappings` or inverts Q4/Q5; the docs version
label leaves 2.7.x on a release; or the `release/2.7.x` MDX file changes an anchored
sentence. The recorded quote/hash defects are falsified by any 2026-10-19 capture that
renders `JWT` capitalized and hashes to `e9472324…` under a declared representation.

## 10. Limits

- Read-only: no registry/entry/stamp edit, no gate execution (`corpus/sources-census.sh` was
  read, never run), no Vault/OpenBao deployment or probe, no vault/account/credential access,
  no Wayback query this round (round-22's empty CDX result is cited, not re-measured).
- Only S014's URL was opened; the `next` route and the upstream MDX were opened as
  representations of the same page. Other rows' pages were not opened; supersession was read
  from the registry text.
- The recorded `e9472324…` representation cannot be recovered from the repo; seven candidate
  representations were tested and none matched, which is evidence of an undocumented
  representation, not proof of which one it was.
- No tools installed; nothing to record under the tooling directive.
