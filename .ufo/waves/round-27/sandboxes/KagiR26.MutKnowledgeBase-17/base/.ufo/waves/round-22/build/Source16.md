# Source16 — S016 re-open, E3 claim adjudication, pin debt

Axes: calibration (C1), freshness (C2). Read-only: no source-registry edit, no entry edit, no
stamp, no restamp; nothing installed; no vault/account operation.

Report: `.ufo/waves/round-22/build/Source16.md`

## 1. Read revision (exact)

| item | value |
|---|---|
| lane HEAD | `c2cab35bc92e57e39e5489bac3386db078345b3f` |
| `corpus/SOURCES.md` as read (worktree, 2026-10-20) | `e4afe6d080b97741942c9e8a75e3d6df4284e983b53f54d5e7e88b88b4cebe3f` |
| frozen base `corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` |
| frozen base HEAD blob of `SOURCES.md` | `db134917…` (same as frozen copy; worktree has concurrent S017–S020 additions only) |
| S016 row | line 22, byte-identical to the frozen-base row (diff clean apart from the `grep -n` prefix) |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (E3) read | `00c8c4e209b5e07808805943cd8c728044f7466c1fe6f498494e7185d99ea784`, 138 lines, 10 131 bytes |
| E3 at HEAD `c2cab35` (= `stamps.tsv` = frozen-before) | `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb`, 111 lines, 8 597 bytes |

The E3 worktree delta is exactly the uncommitted round-22 erratum (27 added lines / 1 534 bytes,
`diff` HEAD blob, lines 112–138). The `stamps.tsv` row is **not** an unexplained stale stamp: it
verifies the committed base blob, and the later change is claimed text.

## 2. Source capture — S016

- URL: <https://openbao.org/docs/concepts/tokens/> — accessed 2026-10-20 (HTTP 200).
- Page label: `Version 2.7.x`; version switcher offers 2.7.x, 2.6.x, 2.5.x plus Development.
- Docs build: `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `etag: "6ad71d3a-b918"`,
  `content-length: 47384`. Raw sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`
  (two consecutive fetches byte-identical). Tag-stripped/unescaped/whitespace-collapsed text:
  14 571 chars, sha256 `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`.
- Upstream provenance (the page's own "Edit this page" link): `openbao/openbao`, branch
  `release/2.7.x`, `website/content/docs/concepts/tokens.mdx`; newest commit touching it
  `ec6ba09f484bf01d5892e3bcac63084127be2f27`, 2026-08-10T12:13:56Z ("Refactor api-docs into docs
  for better versions (#3725)"); mdx sha256
  `f05ae2babff6eb97b51a7f21943c3279f50da033469540badb46c7780812ab28`, identical at that commit and
  at branch head.

### Located quotes (≤25 words, heading + date)

1. "When a parent token is revoked, all of its child tokens -- and all of their leases -- are
   revoked as well." — §Token hierarchies and orphan tokens, 2026-10-20.
2. "Every non-root token has a time-to-live (TTL) associated with it" — §Token Time-To-Live,
   periodic tokens, and explicit max TTLs, 2026-10-20.
3. "The features in the following sections all apply to service tokens" — §Token types, 2026-10-20.
4. "This value is allowed to override the system max TTL -- it can be longer or shorter" —
   §The general case, 2026-10-20.
5. "This has an effect even when using periodic tokens to escape the normal TTL mechanism." —
   §Explicit max TTLs, 2026-10-20.
6. "Leases created by service tokens (including child tokens' leases) are tracked along with the
   service token and revoked when the token expires." — §Service vs. batch token lease handling,
   2026-10-20.
7. "as long as the token is successfully renewed within each of these periods of time, it will
   never expire" — §Periodic tokens, 2026-10-20.
8. "By logging in with any other (non-token) auth method" — §Token hierarchies and orphan
   tokens, 2026-10-20. (Rendered page inserts inline-code spacing around `token`.)

### Qualifiers carried by the page

- **Product**: OpenBao only. No Vault token page is opened or cited here; S016 cannot support any
  "Vault/OpenBao" token claim.
- **Version/status**: docs labelled Version 2.7.x; no preview/beta/public-preview label; no
  publication date displayed. Recheck clock `on-release` is not yet triggered by a newer docs
  version on the page.
- **Feature path / token type**: the TTL, renewal, periodic, explicit-max and parent-hierarchy
  sections apply to **service tokens**; batch-token applicability is deferred to §Token type
  comparison and §Service vs. batch token lease handling.
- **Eligibility for creating periodic tokens**: root/sudo on `auth/token/create`, token store
  roles, or an auth method that supports them (e.g. AppRole).
- **Batch-token limits**: not renewable, not manually revocable, not periodic, cannot carry an
  explicit max TTL (fixed TTL), no accessors, "Stops Working" on parent revocation, lease
  assignment to parent (if not orphan).
- **Channel**: vendor documentation, not runtime behaviour; no deployment or probe.

## 3. Claim adjudication — S016 scoped teaching vs E3 (`knowledge/vault-openbao-token-lease-lifecycle.md`)

13 feature-specific decisions: **6 ADMIT, 2 ADMIT-with-qualifier, 5 REJECT.** Confidence is
high where the page text is quoted; the pin/stamp items are mechanical observations.

| # | Claim (E3 locus) | Verdict | Bound / reason |
|---|---|---|---|
| D1 | Policies control what the holder may do (L51) | **ADMIT** | S016 §Tokens: "These policies control what the token holder is allowed to do within OpenBao." OpenBao 2.7.x. |
| D2 | Tokens opaque; structure volatile (L51–52) | **ADMIT** | §Tokens: "Tokens are opaque values so their structure is undocumented and subject to change." |
| D3 | Every non-root token has a TTL; expiry revokes token + associated leases (L53–55) | **ADMIT-Q** | Exact page sentence (quote 2) and following sentence. Qualifier: renewal/periodic machinery is service-token scoped (quote 3); batch tokens always use a fixed TTL. |
| D4 | "Renewal is bounded by system max TTL (default 32 days …), mount tuning, and the auth method's value" (L54–56) | **REJECT as phrased** | The page makes system max one *factor*, not a bound: a mount max "is allowed to override the system max TTL -- it can be longer or shorter" (quote 4); the auth-method value may be shorter, not longer; the effective max is computed at renewal. Correct form: effective max = f(system max 32 d default, mount max [may override], auth-method suggested value [≤ the applicable max]). |
| D5 | "an explicit max TTL is a hard cap" (L56) | **ADMIT** | §Explicit max TTLs: "hard limit … no matter what the values in (1), (2), and (3) … cannot live past this explicitly-set value." Batch tokens cannot have one. |
| D6 | "periodic tokens renew indefinitely" (L56) | **REJECT as unconditional** | Only "as long as the token is successfully renewed within each of these periods" (quote 7) and only where no explicit max TTL is set: the explicit max "has an effect even when using periodic tokens" (quote 5). Correct form: periodic tokens have no inherent lifetime limit when renewed each period, but an explicit max TTL still caps them. |
| D7 | "outside of direct operator interaction, OpenBao will never revoke a token before the returned TTL has expired" (L57–58) | **ADMIT** | Verbatim §The general case. Scope: that subsection = neither period nor explicit max; page preamble = service tokens. |
| D8 | Login via any other (non-token) auth method yields an orphan token; parent-tree revocation does not reach it (L60–61) | **ADMIT** | §Token hierarchies list item 4 (quote 8); orphan tokens "have no parent". |
| D9 | Batch tokens not renewable and not manually revocable (L63) | **ADMIT** | §Token type comparison: "Can be Renewable: No", "Manually Revocable: No"; same table also bars periodic and explicit max TTL. |
| D10 | Table owner "role / mount / system max TTL" (L18) | **REJECT as compression** | S016 names: system max (default 32 d), mount max (may override), auth-method suggested value configured per-role/group/user, plus explicit max. "role" alone conflates the auth-method suggestion with role-issued tokens and omits explicit max. |
| D11 | Table "lease on a dynamic secret … S016 (OpenBao)" (L19, erratum L109) | **ADMIT-Q** | True but token-type split required: service-token leases are "revoked when the token expires" (quote 6); batch leases are constrained to the batch token's remaining TTL and, if not orphan, tracked by the parent, revoked at batch TTL expiry or parent revocation. Do not generalise service-token lease semantics to batch. |
| D12 | S016 `Fetch sha256` is verifiable today | **REJECT** | `c083fdca…` does not reproduce from raw bytes (`52295218…`), from a 32-combination normalization matrix (script/style strip, tag strip, unescape, whitespace collapse, lowercase), or from `main`/`article` extraction. The 2026-10-19 byte snapshot is not in the lane. |
| D13 | S016 teaching is stale because the page was rebuilt 2026-10-20T07:50Z | **REJECT as content staleness** | Docs `Last-Modified` is a site build (the three OpenBao docs pages checked — tokens, auth/jwt, Kubernetes provider — all show `2026-10-20T07:50:18Z`); the upstream mdx last changed 2026-08-10 (commit `ec6ba09f…`), before the 2026-10-19 open and unchanged at branch head. Only the rendered-byte pin drifts. |

Net: the known round-21 E3 product overclaim is correctly withdrawn by the erratum (D1–D3, D7
product bounds). The remaining calibration gaps are feature-scope and mechanism-precision, not
cross-product attribution: **D4, D6, D10 are overclaims/compressions to correct; D11 needs the
service/batch split.** D12/D13 are freshness, not vendor-fact, defects.

## 4. Scoped teaching/anchor vs entry citation

- `S016` row anchor is "§Tokens and §Token Time-To-Live, periodic tokens, and explicit max TTLs".
  Its own quote is from **§Token hierarchies and orphan tokens**, which the anchor does not name;
  the entry's `source:` line and `corpus/lessons/round-21.md:70` do name it. A reviewer checking
  only the registry row cannot locate the quote.
- The row `teaches` sentence covers only parent-revocation; E3 also draws TTL/renewal/expiry and
  batch-token facts from §Token type comparison and §Service vs. batch token lease handling, which
  neither the row anchor nor the row scope names. Source-bound binding for those claims exists only
  on the entry's own `source:` line.
- The row has no service-vs-batch qualifier. Given §Token types (quote 3) that is a missing
  feature-scope qualifier, not a wrong fact.
- Entry citation itself is correct as far as it goes: it names §Token hierarchies and orphan
  tokens, §Token Time-To-Live …, §Token type comparison, Version 2.7.x; it omits §The general case
  (the section of the D7 quote) and §Service vs. batch token lease handling (D11).

## 5. Freshness and pin-debt reconciliation (S016 and E3)

Observations only; no deletion, no silent re-pin, no stamp change.

- **S016 page bytes**: pinned `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`
  (row, 2026-10-19) vs raw `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`
  and normalized text `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`
  (2026-10-20). No candidate recipe matches, so the historic pin is **non-reproducible**, not
  proven stale. Do not assert a content change; the upstream mdx is unchanged since 2026-08-10.
- **Root cause is not established** [INFERENCE]. Two candidates fit the observations: (a) the
  2026-10-20 07:50:18Z site rebuild changed rendered bytes even though content did not, and/or
  (b) the 2026-10-19 pin used an extraction method the row never recorded. A rendered-HTML byte
  pin is the wrong expectation class for this source either way.
- **Expectation migration proposed**: pin the upstream source revision instead of (or in addition
  to) rendered bytes — `openbao/openbao` `release/2.7.x` commit
  `ec6ba09f484bf01d5892e3bcac63084127be2f27`, mdx sha256
  `f05ae2babff6eb97b51a7f21943c3279f50da033469540badb46c7780812ab28`. Keep the 2026-10-19 pin as
  historic text; do not overwrite it.
- **E3 stamp**: `stamps.tsv` row `5fd53351… / 111 / 8597` matches the HEAD blob and the
  frozen-before copy exactly; the worktree is `00c8c4e2… / 138 / 10131` because the uncommitted
  round-22 erratum (27 lines) was appended. This is a knowable later change, not an unexplained
  stale stamp. After integration commits the erratum, refresh the stamp to the reviewed bytes and
  record the delta as "round-22 erratum, lines 112–138" — that is the documented migration, not a
  deletion.
- The frozen `expected.json` still declares the base input hash `5fd53351…`; a round-22 post-
  integration verification must expect the new hash only after the erratum commit, or it will read
  a false stale on an intended change.

## 6. Proposed correction (integration owner decides; no edits made here)

**(a) Superseding registry row** — needed for a locatable anchor and a reproducible pin; S016
stays as the 2026-10-19 historic row. Next free id at read revision is S021; confirm no collision
before inserting.

```markdown
| S021 | Tokens — https://openbao.org/docs/concepts/tokens/ | docs | A | OpenBao 2.7.x token policies, service-versus-batch token types, TTL/renewal/expiry, orphan-token creation, and parent-revocation lease handling | §Tokens; §Token hierarchies and orphan tokens; §Token Time-To-Live, periodic tokens, and explicit max TTLs (§The general case, §Explicit max TTLs, §Periodic tokens); §Token type comparison; §Service vs. batch token lease handling; page label Version 2.7.x; upstream `openbao/openbao` `release/2.7.x` `website/content/docs/concepts/tokens.mdx` commit `ec6ba09f484bf01d5892e3bcac63084127be2f27` (2026-08-10), re-opened 2026-10-20 | Supersedes S016's anchor and pin only; the S016 fact is unchanged. TTL/renewal/periodic/explicit-max features are service-token scoped; batch tokens are not renewable or manually revocable and always use a fixed TTL. Quote: “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.” (§Token hierarchies and orphan tokens). Source sha256 (mdx at commit): `f05ae2babff6eb97b51a7f21943c3279f50da033469540badb46c7780812ab28`; rendered-page raw sha256 2026-10-20: `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`; the S016 pin `c083fdca…` was not reproducible (raw or normalized), do not overwrite it. | mined | 2026-10-20 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```

Integration must also add `S021` to E3's `source:` line (otherwise `sources-census.sh` reports
`SC_MINED_UNUSED` / `SC_USEDBY_NOCITE`), e.g. append:
`; S021 (https://openbao.org/docs/concepts/tokens/, §Token hierarchies and orphan tokens, §Token Time-To-Live …, §Token type comparison, §Service vs. batch token lease handling, Version 2.7.x, re-opened 2026-10-20)`.

**(b) E3 erratum addendum** (append; do not rewrite existing text). Exact proposed replacement for
the two defective sentences at L54–56:

> Renewal is governed by a dynamically computed maximum TTL: the system max (default 32 days,
> configurable), a mount max TTL that may override the system value (longer or shorter), and an
> auth-method suggested value (per role/group/user) that may be shorter but not longer; an explicit
> max TTL is a hard cap, and it also limits periodic tokens. Absent an explicit max TTL, a periodic
> token has no inherent lifetime limit while it is renewed within each configured period. These
> TTL/renewal features describe service tokens; batch tokens are not renewable, not manually
> revocable, cannot be periodic, and always use a fixed TTL.

And qualify the lease row: "service-token leases are revoked when the token expires; batch-token
leases are constrained to the batch token's remaining TTL and, if not orphan, are tracked by the
parent and revoked when the batch token or its parent is revoked."

**(c) Pin expectation**: add the S016 pin-recipe failure and the upstream-commit pin to the round-22
lessons/log entry so that a future detector distinguishes "site rebuild" from "content change" and
does not silently restamp.

## 7. Falsifier (for the S016 teaching as re-scoped)

A 2.7.x `concepts/tokens` page that (a) removes or alters the parent-revocation sentence; (b) states
that mount tuning cannot exceed the system max TTL; (c) states that an explicit max TTL does not
constrain periodic tokens; (d) states that batch tokens are renewable or manually revocable; or
(e) shows a docs version other than 2.7.x at an on-release recheck. A rendered page whose raw
bytes change without a corresponding commit in `openbao/openbao` `release/2.7.x` does **not**
falsify the teaching — it only re-opens the pin question.

## 8. Limits / remaining unknowns

- No 2026-10-19 byte snapshot of the page exists in the lane (grep for the pin finds only
  `SOURCES.md` and the frozen copy), so the historic pin cannot be replayed; the failure is
  "non-reproducible", not "proven stale".
- The pin extraction recipe was never documented; a 32-combination normalization matrix and
  `main`/`article` extraction were tried and none reproduce it.
- GitHub REST API returned 403 rate-limit; commit history was taken from the repository Atom feed.
  Internet Archive returned 429; no Wayback replay was possible.
- Vault was not re-opened (out of scope): D1–D13 are OpenBao-only; nothing here establishes Vault
  token parity, OpenBao KV evidence, or any runtime behaviour.
- The E3 file is being edited concurrently (uncommitted erratum); the read hash above is the
  snapshot used. Re-read before integrating.

## 9. Checks the parent should run after integration

1. `bash corpus/sources-census.sh` — expect CLEAN, or only the new `S021` citation finding if E3's
   `source:` line was not updated.
2. `bash corpus/claim-ledger.sh verify` (or the row audit) — confirm the E3 stamp matches the
   post-erratum bytes and that the migration is the only stamp delta.
3. Confirm `S021` is unused before insertion and that `SOURCES.md` has no other concurrent
   `S021` row.
4. Re-fetch `https://openbao.org/docs/concepts/tokens/` once and record raw sha256 + docs
   `last-modified`; do not re-pin to the rendered page.
