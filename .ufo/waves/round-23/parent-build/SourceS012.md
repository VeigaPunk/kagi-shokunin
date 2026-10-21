# SourceS012 — S012 provenance audit (round 23, attempt 1)

Seat: `SourceS012` (reviewer, leaf, read-only). Axes: **calibration**, **freshness**,
**operability**. Scope: row S012 only, plus its declared used-by entry and the actual
consumers needed to establish closure; supersession checked only through S022. No gate,
census, ledger, or feature-claims execution; no edits beyond this file.

- Observed revision (file digests, read 2026-10-21; no git/JJ operation performed):
  `corpus/SOURCES.md` = `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`
  (118 lines, 23 rows; S012 at line 18, row-line sha256 `6bfac7df…f0057d2a` incl. LF);
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` = `4932f37f…b17298`;
  `corpus/feature-claims.json` = `a66acbfb…38449b`; `corpus/claim-ledger.tsv` = `e6806968…ce8305`.
  `plans/round-23.md` names base `d218603b…`; not re-verified via git.
- Method: exact registered URL reopened (read + curl GET only), canonical and
  `#jwt-verification` anchor fetched, quote located in rendered text, row compared to
  the page and to S022. No live command, vault, account, or deployment probe.

## 1. Reopen record (2026-10-21)

| field | observed |
|---|---|
| URL (exact registered) | `https://developer.hashicorp.com/vault/docs/auth/jwt` |
| HTTP | `200`, `content-type: text/html; charset=utf-8`, `content-length: 386400` |
| Raw body sha256 | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` (386,400 B) |
| Anchor reopen | `…/jwt#jwt-verification` returns a byte-identical body (fragments are not transmitted); `id="jwt-verification"`, `id="bound-claims"`, `id="claims-as-metadata"` each occur once |
| Article-text sha256 | `ba24a54810062d6c48622b83782888b8bebad0cd38a04e14b538af7da9ee4b6a` — reproduces the round-22 record exactly |
| Anchored-section sha256 | `684d31324f52f770ac1c1af99ea0ed7f70ada1d7161409d358a1f828bdea8390` (`id="jwt-verification"` → `id="tutorial"`) — reproduces round-22 exactly |
| Page metadata | `dateModified` `2026-04-15T00:14:24.000Z`; no displayed article date |
| Docs version selector | button label `v2.x (latest)`; versions array begins `latest/v2.x`, `v1.21.x`, `v1.20.x` |
| Transport metadata | `etag: "989fbb89c19fdad8a8a4da184f1acb16"`, `x-vercel-cache: HIT` — transport only, not identity |
| Latest Vault release | stable `2.2.0`, published `2026-10-15T16:17:57Z` (releases API); `2.1.0` `2026-09-01` |

Normalization used for the two text digests (and reproducible): remove `<script>`/`<style>`,
replace tags with a space, `html.unescape`, collapse whitespace, strip; article boundaries
`<h1>` → `Edit this page on GitHub`; section boundaries `id="jwt-verification"` → `id="tutorial"`.
Both match round-22, so the representation is now pinned by a second independent fetch.

## 2. Scoped fields rechecked (row line 18)

| field / assertion | observed public text | verdict |
|---|---|---|
| `teaches`: “Vault requires an exact role audience match when a presented JWT has an audience claim.” | true only for roles of type `jwt`; the same page says OIDC roles keep it optional | **refuted as unqualified; supported when scoped to `jwt` roles**; S022 is the explicit supersession |
| Quote “must exactly match at least one of the `aud` claims declared for the JWT.” | present twice, in the introduction Note and §JWT verification; rendered text has code markup, no backticks | **supported as rendered text** (see F3 for the stripped subject) |
| `anchor`: “§JWT verification, §Bound claims, and §Claims as metadata; latest page as served 2026-10-19, newest pinned version v1.21.x; audience note applies starting Vault 1.17” | all three section ids exist; latest served label is `v2.x (latest)`, `v1.21.x` is a non-latest pin; the 1.17 gate exists only in the introduction Note, not §JWT verification | **sections supported; version stamp refuted; gate location imprecise** |
| `scope`: “Vault JWT/OIDC signature and audience validation for role authentication” | signature methods and audience/claims are documented; audience requirement is role-type-specific | **acceptable; the merged wording invited the overclaim** |
| `status: mined` | cited by its declared used-by entry (`source:` line 3) and by the census obligation R21-02 | **supported** |
| `tier: A` | official HashiCorp Vault product documentation, GA/stable, not Enterprise-gated | **supported** (`feature-claims.py` validates source schema, not tier) |
| `opened: 2026-10-19`, `recheck: on-release` | Vault 2.2.0 released 2026-10-15, four days before the row opened; no later stable release | **clock already tripped at open; content not re-curated to it** |
| `used-by`: `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | entry exists and cites S012; the entry's final correction (lines 160–170) scopes the rule to JWT roles | **supported, with additional undeclared consumers (F4)** |

Quotes (each ≤25 words; heading / date / URL):

| heading | quote | words |
|---|---|---|
| Introduction Note | “the associated `bound_audiences` for the "jwt" role must exactly match at least one of the `aud` claims declared for the JWT” | 21 |
| §JWT verification | “the associated `bound_audiences` for the role must exactly match at least one of the `aud` claims declared for the JWT” | 20 |
| §Configuration → §Bound claims | “For roles of type "jwt": the `bound_audiences` parameter is required when an `aud` claim is set” | 16 |
| §OIDC configuration troubleshooting | “`bound_audiences` is optional for OIDC roles and typically not required” | 10 |
| §JWT verification | “You can only configure one JWT signature verification method per mounted backend” | 12 |

All: https://developer.hashicorp.com/vault/docs/auth/jwt, 2026-10-21.

## 3. Findings by severity

**F1 (high, calibration).** S012's teaches sentence is an overclaim as written: it merges
the `jwt`-role rule with OIDC roles. The page separates them (Bound claims: “For roles of
type "jwt"”; OIDC troubleshooting: optional). S022 (`SOURCES.md:28`) explicitly supersedes
S012 for this scope, and the entry's final correction says the same. Neither S012's row
text nor its digest was rewritten — correct immutability — but any active consumer must
read the JWT-role scope, not the row's bare sentence.

**F2 (high, freshness/provenance).** The row's `Fetch sha256`
`ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45` is not reproducible
under any recorded representation: today's raw body is `9a65b9d1…`, byte-identical to
round-22's 2026-10-20 fetch, while round-22 recorded an off-site control (S011) reproducing
exactly [inherited observation, not re-run here].
The row records no representation, method, status, byte count, or date domain. Worse,
`plans/round-23.md` §2 scopes the new `source-fetches.tsv`/`SC_FETCH` work to “the seven
mined rows that lack it” — S012 already carries a `Fetch sha256:` (16 of 23 rows do), so
the planned check never re-examines it. `corpus/feature-claims.py:341` validates only the
64-hex shape, and R22-01/R22-02 execute that validator; a stale digest therefore passes
a CLEAN gate. This is the claim-count-assurance pattern C1 rejects, one level down.

**F3 (medium, calibration/provenance).** The quote is a sentence fragment whose
grammatical subject is outside the quoted span: §JWT verification says “the associated
`bound_audiences` for **the role** must exactly match…”, and the role type (“jwt”) plus
the Vault 1.17 gate live in the introduction Note. The row's locator
“§JWT verification, Vault 1.17 note” merges two locations; §JWT verification restates the
rule *without* the version gate. A quote-location check keyed on the three named sections
passes while the scope- and version-determining words remain outside the excerpt. The
entry's `recheck:` line (line 5) repeats the problem: it says re-open “S012 §JWT
verification (audience rule, verification options)” and never names the introduction Note.

**F4 (medium, C1 closure).** S012 has actual consumers outside its `used-by` field:
`corpus/feature-claims.json:63–77` (source record with the stale digest, quote
`S012-audience`, and three bindings to `vault_jwt_login`) and `:915–932` (boundary record
`OUT-OF-SCOPE-VAULT-JWT`, including `release_status` evidence); `corpus/README.md:78`
(reading pointer “SOURCES.md S012–S016”); `corpus/lessons/round-21.md:66` (historical
lesson quote). The census only checks declared `used-by` paths and entry cite-back
(`SC_USEDBY_NOCITE`, `SC_ENTRY_CITE`), so a closure checker that trusts `used-by` cannot
see the machine catalog that an executed gate consumes. No claim-ledger command row cites
S012 directly (43 rows checked; zero references to `S012`, `vault_jwt`, or the entry path).

**F5 (medium, freshness).** The anchor's “newest pinned version v1.21.x” is refuted by the
served selector: `v2.x (latest)`, then `v1.21.x`. `SOURCES.md:82–85` already caveats this
as a historical locator, and S022 was opened 2026-10-20, so the correction exists; the
stale stamp remains in the historical row by design. Operability gap: the `on-release`
clock was already due at `opened: 2026-10-19` (2.2.0 on 2026-10-15), and the recheck text
does not say “also re-read the docs version label”.

**F6 (low, provenance binding).** The boundary record binds `release_status:
"version_scoped"` to `S012-audience`, but that sentence states no release status; the
version scope comes from the separate introduction Note. `feature-claims.json` contains
no S022/S023 entry (0 matches), so the superseded reading and its digest remain the only
machine-readable S012 evidence. The record is labelled `unjudgeable-scope-boundary`, which
bounds the damage, but C2 should not treat field-level attribution to one fragment as
adequate evidence for a different field.

Deployment proof: none. The page is documentation; the `v2.x (latest)` selector is a docs
route label and `dateModified` is page metadata. Nothing here proves a deployed Vault
version or runtime audience behaviour.

## 4. Planned C2 — exact representation/anchor/hash expectations

1. **Identity:** row id + exact registered URL (no query, no fragment — verified the
   fragment fetch is byte-identical), plus the row-line sha256 so a provenance row cannot
   drift to another row.
2. **Representation, one label per hash.** `raw-html-body` = HTTP entity body after
   content decoding; record `fetched_at` UTC, status, `content-type`, `content-length`,
   `etag` (recorded, never keyed). `article-text` and `anchored-section` as normalized in
   §1, with boundaries and normalization stated. A digest without a representation label
   is not provenance.
3. **Hash + size:** full 64-hex sha256 and exact byte/character count for the declared
   representation. Observed S012 values to record: raw `9a65b9d1…`, 386,400 B; article
   `ba24a548…`, 15,366 chars; section `684d3132…`, 7,275 chars. The registered
   `ec6e7b…` must be marked historical/unverified (no method/date/representation), not
   “current”, and not “drift”.
4. **Anchor + quote:** the anchor must resolve to a literal id in the fetched body
   (`#jwt-verification`, `#bound-claims`, `#claims-as-metadata` all verified). When the
   quoted sentence's subject or version gate lies in the enclosing/unquoted text, the
   provenance row must carry `scope_qualifier` (here `role_type=jwt`, `since=Vault 1.17`,
   `gate_location=page-introduction Note`). A quote-only check must fail closed on a
   missing qualifier, not pass on substring presence.
5. **Supersession state:** S012 is `historical/mined` with `superseded_for_scope_by=S022`.
   Its quote stays active evidence for the JWT-role path; the bare teaches sentence is not
   active evidence for OIDC. C2 must not collapse “row retained” into “claim still
   unqualified”, nor “hash mismatch” into “content drift”.
6. **Real contradiction to score:** the registry, `feature-claims.json` (executed by
   R22-01/R22-02), and the C2 scope all treat S012's digest as provenance-complete, yet
   the value has no recorded representation and does not reproduce, while the same URL's
   bytes are stable across two dates. Counterexample form: a checker that accepts
   `Fetch sha256` presence + 64-hex shape returns CLEAN for S012 today.

## 5. Synthetic minimal failing fixtures (proposal for L1; not executed)

- **C2 representation:** fixture root with a one-row `SOURCES.md` (S012, `Fetch sha256`
  equal to the raw-html value) and a `corpus/source-fetches.tsv` row declaring
  `representation=article-text` but carrying the raw-html digest. Expected finding
  `SC_FETCH_REPRESENTATION` (exit 1). The planned shape/URL/quote checks would pass,
  because both values are 64-hex and the URL matches.
- **C2 scope:** same fixture, quote row uses the fragment
  “must exactly match at least one of the `aud` claims declared for the JWT.” with
  `anchor=§JWT verification` and no `scope_qualifier`. Expected finding
  `SC_FETCH_SCOPE_UNQUALIFIED`; a substring-in-body check passes, which is the false clean.
- **C1 actual-pointer closure:** fixture tree with S012 `status=queued`, `used-by:
  corpus/knowledge/e1.md`, e1's `source:` line citing S012 (declared chain consistent), and
  one `corpus/feature-claims.json` source record `id:S012` bound to a feature. Expected
  finding `SC_ACTUAL_CITE_NOT_MINED`; the current `SC_USEDBY_NOCITE`/`SC_ENTRY_CITE`
  checks pass because they never look outside `used-by`. Keep the existing mutation
  (remove S012 from e1's `source:` line → `SC_USEDBY_NOCITE`) as the control case.

## 6. Residual risk and verification gaps

- The 2026-10-19 bytes are not provable; the Wayback API was already unavailable to round
  22. The registered hash may be a different representation rather than a different
  document — the row does not say, so this report does not call it drift.
- `dateModified` is metadata, not an edit log; pre-2026-10-19 raw bytes are not retained.
- No census, ledger, feature-claims, or closure checker was executed (contract). C1/C2
  fixture expectations are specifications, not observed pass/fail runs.
- S022 was read for supersession only; S023 and all other source rows were not audited.
- `feature-claims.py` was read, not run; its pinned digests (`PINNED_SOURCES_SHA256`,
  `PINNED_BOUNDARY_SHA256`) will need re-pinning if L1 adds S022 or changes S012's record.

## 7. Handoff checks for the parent

1. R21-02's expected census line counts S012 as mined and its used-by cite; if any row is
   added (e.g. S024), re-measure the exact line rather than editing the count by hand.
2. R22-01/R22-02 consume `feature-claims.json`; adding S022 or a new S012 digest changes
   `PINNED_SOURCES_SHA256`/`PINNED_BOUNDARY_SHA256` and therefore the expected CLEAN lines.
3. If C2 extends to S012, append a representation-qualified `source-fetches.tsv` row and
   keep `ec6e7b…` as prior/historical; do not overwrite the row's captured quote or hash.
4. Treat the entry's `recheck:` instruction as incomplete until it names the introduction
   Note alongside §JWT verification.

**Report: `.ufo/waves/round-23/parent-build/SourceS012.md`**
