# Source13 — S013 re-open: Vault lease page

Axes: **C1 calibration** (does S013 support the claims it is cited for, at the right product/status/path bounds) and **C2 freshness** (reconcile the 2026-10-19 revision stamp without deleting, restamping, or laundering it). Read-only: no registry/entry edits, no Vault/OpenBao runtime, no installs, no host gates.

## Read revision and concurrent state

- `HEAD` = frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD` matched). Working tree already carried sibling appends (`git status`: modified `corpus/SOURCES.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, `corpus/QUALITY.md`; untracked `.ufo/waves/`, `corpus/lessons/round-22.md`, `plans/round-22.md`).
- `corpus/SOURCES.md`: live `ebf88646…` (66 lines, 18,222 B) vs frozen `db134917…` (43, 14,261 B). The **S013 row is byte-identical in both** (line 19; `git show c2cab35:corpus/SOURCES.md | grep '^| S013 '` matched live). Other seats appended S017–S021; no `supersedes S013` row existed at read.
- Entry `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`: frozen `5fd53351…` (111 lines, 8,597 B = `corpus/stamps.tsv:32`); live `00c8c4e2…` (138 lines, 10,131 B), the difference being a sibling round-22 erratum appended at lines 113–138. The base `source:` line, four-clocks table, §Vault leases, and §Does not establish text are unchanged live. I adjudicate the frozen claims and the appended erratum separately.
- Live hashes re-snapshotted 2026-10-20T21:41:09Z. Re-hash before citing; integration was in flight.

## Re-open record (S013)

- URL: https://developer.hashicorp.com/vault/docs/concepts/lease
- Access date **2026-10-20**; fetches 21:33:58Z–21:39:48Z. HTTP/2 200 through Vercel/Next.js.
- Rendered HTML, **v2.x (latest)** track: 261,632 B, sha256 `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802`. Five saved fetches plus two URL-variant fetches (`/lease/`, `?x=1`) were byte-identical; response `etag: "mhehieftta5lvi"`, `x-vercel-cache: HIT`, `age: 16541`, `content-length: 261632`, `cache-control: public, max-age=0, must-revalidate`. The `date` header (`Tue, 20 Oct 2026 17:04:06 GMT`) is the cached object's generation time, not a page revision.
- Rendered HTML, **v1.21.x** pinned track (`/vault/docs/v1.21.x/concepts/lease`): 262,620 B, sha256 `7c18d310a9c73a1aaa9d76b4128a0a957cff0ce08473c967e0d05ab062d7d048`. Article body text is **identical** to v2.x (see C2).
- Content source advertised by the page's "Edit this page on GitHub": `hashicorp/web-unified-docs` @ `28d67d3308eb58e3c64976d52f612f847bb62985`, path `content/vault/v2.x/content/docs/concepts/lease.mdx`, 4,450 B, sha256 `7e2129bfc100dabc5e0bd7341abcce27fdca6f7b539c706c8a178f568749c480` (fetch at that commit byte-identical to `main`). Front matter: `created_at: 2026-04-15T00:14:52.000Z`, `last_modified: 2026-04-15T00:14:52.000Z`.
- Machine revision: JSON-LD `datePublished` and `dateModified` both `2026-04-15T00:14:52.000Z`. Version selector JSON: `{"name":"latest","label":"v2.x (latest)","isLatest":true,"releaseStage":"stable","version":"v2.x","found":true}`, then `v1.21.x` (newest pinned, `found:true`) down to `v1.4.x`. Rendered aria-label: "Choose a Vault Documentation version. Currently viewing v2.x (latest)."
- Anchor resolves: H1 `Lease, renew, and revoke`; H2s `Lease IDs`, `Lease durations and renewal`, `Prefix-based revocation`. The KV note sits in the intro (page-level section), immediately before §Lease IDs.

### Located quotes (each ≤25 words)

| location | quote | words |
|---|---|---|
| §Lease, renew, and revoke, intro (before §Lease IDs; mdx L28–31) | “All dynamic secrets in Vault are required to have a lease.” | 9 |
| §Lease, renew, and revoke, intro last paragraph (KV note) | “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration” | 20 |
| §Lease, renew, and revoke, revocation paragraph | “When a token is revoked, Vault will revoke all leases that were created using that token.” | 16 |
| §Lease durations and renewal | “The requested increment is completely advisory.” | 7 |
| §Lease, renew, and revoke, opening sentence | “With every dynamic secret and service type authentication token, Vault creates a lease” | 14 |

### Qualifiers that must travel

- **Status:** public vendor documentation, no login or entitlement gate; docs track `v2.x (latest)` with `releaseStage: stable`; no preview/beta label. No rendered last-updated text; JSON-LD `datePublished`/`dateModified` = `2026-04-15T00:14:52Z`.
- **Eligibility:** none stated for reading; the page is not Enterprise-only and draws no HCP-versus-self-managed distinction. Its subject is Vault dynamic secrets and `service` type authentication tokens; it says nothing about batch tokens, token TTL, or KV value retention.
- **Product:** HashiCorp Vault only. It cannot support OpenBao KV, OpenBao token, or cross-product parity claims.
- **Path:** `/vault/docs/concepts/lease`; H1 `Lease, renew, and revoke`, H2s `Lease IDs`, `Lease durations and renewal`, `Prefix-based revocation`; the KV note is the last intro paragraph before §Lease IDs. Registry path chain S012 → S013 → S014; entry E3.

## C1 — registry row vs source

| row field (frozen, unchanged live) | verdict | evidence |
|---|---|---|
| scope: "dynamic-secret and service-token lease lifecycle" | ACCEPT (wording qualifier) | Page says `service` type authentication token; it says nothing about batch tokens or token TTL. |
| scope: "static KV exception" | ACCEPT with qualifier | Page language is "arbitrary secrets" and "does not issue leases although it will sometimes return a lease duration"; "static" is the author's gloss, not page wording. |
| anchor §Lease, renew, and revoke | ACCEPT | H1 present; quotes located in it. |
| anchor "current Vault docs have no displayed version/date" | **REJECT on version; ACCEPT-with-qualifier on date** | Visible selector "v2.x (latest)", newest pinned v1.21.x. No rendered last-updated date, but JSON-LD dates exist. |
| teaches "requires leases for dynamic secrets; distinguishes static KV values from leased data" | ACCEPT (bounded) | First clause verbatim; second is exactly "KV issues no leases, may return a lease duration". |
| quote | ACCEPT | Verbatim at the cited section. |
| tier A / status `mined` | ACCEPT | Vendor docs on its own product, opened, quoted, cited by the named entry. |
| `Fetch sha256: ae3215…` | **UNVERIFIABLE today** | Matches no representation measured; see C2. Method/representation were never recorded. |
| `used-by: corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | ACCEPT | Entry's `source:` line cites S013. |

**Finding C1-S013-1 (anchor, medium).** The anchor clause "current Vault docs have no displayed version/date" is false on the version half. The page displays a version selector reading "v2.x (latest)" and lists newest pinned `v1.21.x`; the JSON declares `releaseStage: stable`. This was already true before the row was written: Wayback captures 2026-09-23T01:13:38Z and 2026-10-07T18:51:12Z both carry the same `versions` array and the same `datePublished/dateModified`. It is not 2026-10-20 drift. Consequence: the row fails the contract's anchor rule ("exact section … plus revision (version, commit, or publication date)"). Correction cannot be in-place (contract: only `status`, `recheck`, `used-by` change in place) — see the proposed superseding row.

**Finding C1-S013-2 (scope, low).** "static KV exception" and "distinguishes static KV values from leased data" are admissible only with the page's own qualifier: KV "does not issue leases although it will sometimes return a lease duration". Do not read the row as "KV has no lease semantics" or "KV values never expire". The 1.21.x and v2.x tracks carry the same text, so this is not version-conditional.

**Finding C1-S013-3 (product/eligibility, low).** S013 is HashiCorp Vault only. Nothing on the page supports OpenBao KV, OpenBao token TTL, Vault batch-token behavior, or Vault token TTL; the page never says "batch" or "token type" (0 occurrences each). Cross-product use of S013 is a reject class, as the critic's mutation case states.

## C1 — associated entry claims (`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`)

| claim (line) | verdict | evidence |
|---|---|---|
| line 19 Vault lease clock: expiry/revocation, token revocation revokes its leases | ACCEPT | Quotes 1 and 3 verbatim; "automatically revoke" on expiry present. |
| line 20 "static value in KV … only a write; no lease, nothing expires" attributed to S013 | **REJECT as S013 support** | S013 establishes only "does not issue leases (… may return a lease duration)". Retention/deletion semantics are not on this page. Withdrawn by the round-21 erratum (line 110) and marked historical by the round-22 erratum (lines 115–118). |
| line 67–72 §Vault leases quotes | ACCEPT | All four quotes verbatim; KV quote exact. Minor: page wording is "requested increment", the entry paraphrases "renewal increments". |
| line 109 "leases on dynamic secrets and service tokens" | ACCEPT | Page says every dynamic secret and `service` type auth token gets a lease. |
| line 110 "§Does not establish, first bullet, reads accordingly: a KV read carries no lease" | **REJECT (false description of the file)** | The bullet at lines 84–85 still reads "only a write does"; it was never rewritten ("text above unchanged"). The erratum's superseding reading exists only in the erratum, not in the bullet it claims to describe. |
| lines 113–138 round-22 erratum: product-separated support, no KV retention guarantee, missing source = withdrawn | ACCEPT | Matches this re-open; it supplies the bounded control. |

**Bounded decision set (decisions, not rows):**

| decision | label | basis |
|---|---|---|
| "A Vault KV read carries no lease" (S013, Vault-scoped) | **ADMIT** | KV note, verbatim; Vault-only. |
| "A Vault KV read carries a lease" | **REJECT** | Contradicted verbatim ("does not issue leases"). |
| "A KV value never expires / changes only by a write, per S013" | **REJECT** | S013 silent; KV API/delete operations were not opened. |
| "S013 supports OpenBao KV or token claims" | **REJECT** | Cross-product; page is Vault docs only. |
| "S013 covers Vault batch-token leases/TTL" | **REJECT** | Page silent; no "batch", no "token type". |

**Proposed append-only addition (do not rewrite lines 84–85 or 110):**

> Round-22 S013 re-open: the round-21 erratum's sentence "§Does not establish, first bullet, reads accordingly: a KV read carries no lease" is itself inaccurate — the first bullet was never rewritten and remains historical defective text. Operative bounded control: a Vault KV read carries no lease; the KV backend "does not issue leases although it will sometimes return a lease duration" [S013, Vault-scoped]. No KV retention, deletion, or write-only-mutation rule follows from S013.

## C2 — freshness and pin reconciliation

**Historic statements, preserved and not overwritten:**

- S013 row (2026-10-19): `Fetch sha256: ae321512d37ae70bc19e7b8698217ce8af0d3000bb76fe04039870bff25b8bf5`, no representation, download mode, or normalization recorded.
- `corpus/stamps.tsv:54` `corpus/SOURCES.md` = `db134917…`, 43 lines, 14,261 B (frozen base).
- `corpus/stamps.tsv:32` entry = `5fd53351…`, 111 lines, 8,597 B (frozen base; matches `git show c2cab35:…`).

**2026-10-20 measurements (new statements, not replacements):**

- Rendered v2.x HTML: `de5f8836…`, 261,632 B, `etag "mhehieftta5lvi"`, stable across five saved fetches.
- Rendered v1.21.x HTML: `7c18d310…`, 262,620 B, article body text identical to v2.x.
- Content source `lease.mdx` @ `web-unified-docs` `28d67d3…`: `7e2129bf…`, 4,450 B; front matter `last_modified 2026-04-15T00:14:52Z`.
- Live working tree stamps (append-driven, expected): `corpus/SOURCES.md` `ebf88646…`, 66 lines, 18,222 B; entry `00c8c4e2…`, 138 lines, 10,131 B.

**Content-stability evidence (historic, not hash-reverification).** Article body slice from "With every dynamic secret" to "Was this page helpful" is 4,195 chars with text sha256 prefix `f7a910c3d73c61d7…` identically in: Wayback 2026-09-23T01:13:38Z (id_ raw `6307873add48e968dd6791fb641abdb90b0acc6a283cb37cddbd54a082c8a946`), Wayback 2026-10-07T18:51:12Z (id_ raw `6d7203361325397e9b5ab2a65ac13f9d50d9ab681b61a512d37503c23e45862f`), live v2.x, and live v1.21.x. The only 2026-10-07 → 2026-10-20 text difference is site chrome (nav "Menu" and SCIM entries); the raw Wayback hashes differ from each other and from live, confirming that **raw HTML byte pins are shell-sensitive**, while the doc body and its `last_modified` did not change across 27 days. Wayback rewrites URLs, so archived raw bytes are not comparable to live raw bytes; only the extracted body comparison is used.

**Pin verdict.** `ae3215…` is not reproducible on 2026-10-20. It matches none of: v2.x rendered HTML, tag-stripped page text, article body slice, the v1.21.x page, the OpenBao lease page (`519dc0fc…`), or the `.md` alternate (404). This is a **method/representation gap plus shell drift**, not evidence that the teaching changed. Retain the 2026-10-19 pin as a historic statement; never present it as verified, and never restamp S013 to "clear" it.

**Expectation migrations to journal (old → new, exact):**

1. `S013 anchor`: "§Lease, renew, and revoke; current Vault docs have no displayed version/date, opened 2026-10-19" → "§Lease, renew, and revoke (H1; KV note before §Lease IDs) and §Lease durations and renewal; Vault docs v2.x (latest), releaseStage stable, newest pinned v1.21.x; page datePublished/dateModified 2026-04-15T00:14:52Z; content `lease.mdx` sha256 `7e2129bf…` at web-unified-docs `28d67d3…`; reopened 2026-10-20".
2. `S013 pin`: `ae3215…` (2026-10-19, method unrecorded) → retained historic; add rendered pin `de5f8836…` (261,632 B, etag `mhehieftta5lvi`) and content pin `7e2129bf…` at `28d67d3…`.
3. `stamps.tsv:32` entry: `5fd53351…/111/8597` → `00c8c4e2…/138/10131`; motivation = round-22 erratum appended lines 113–138. Migrate in the same commit as the append; do not silently auto-repin.
4. `stamps.tsv:54` SOURCES.md: `db134917…/43/14261` → `ebf88646…/66/18222`; motivation = S017–S021 appended by other seats. Integration owner re-stamps after the final append.

A superseding row is **needed for the anchor** (immutable field, contract rule 2) but **not for the teaching**. Adding it changes registry cardinality; `R21-02`'s `rows=16` expectation must migrate via a successor row and be counted as an expectation migration, not as authored-row quality.

### Proposed superseding row (exact cells; id = next unused at read, `S022`)

```md
| S022 | Lease, renew, and revoke — https://developer.hashicorp.com/vault/docs/concepts/lease | docs | A | Vault dynamic-secret and service-type auth-token leases; KV backend issues no leases (Vault-only) | §Lease, renew, and revoke (H1; KV note before §Lease IDs) and §Lease durations and renewal; Vault docs v2.x (latest) releaseStage stable, newest pinned v1.21.x; page datePublished/dateModified 2026-04-15T00:14:52Z; lease.mdx sha256 `7e2129bfc100dabc5e0bd7341abcce27fdca6f7b539c706c8a178f568749c480` at web-unified-docs `28d67d3308eb58e3c64976d52f612f847bb62985`; reopened 2026-10-20 | supersedes S013 — Vault requires a lease for every dynamic secret and `service` type authentication token; the KV backend issues no leases although it may return a lease duration. Quotes: “All dynamic secrets in Vault are required to have a lease.” (§Lease, renew, and revoke); “does not issue leases although it will sometimes return a lease duration” (KV note). Fetch sha256: `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802` (261,632 B rendered HTML, etag `mhehieftta5lvi`, 2026-10-20); content pin `7e2129bf…` as above. Prior S013 pin `ae321512d37ae70bc19e7b8698217ce8af0d3000bb76fe04039870bff25b8bf5` (2026-10-19, method unrecorded) retained historic, not reproducible on 2026-10-20. | mined | 2026-10-20 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```

Dependency: for `mined` to hold, the entry's single `source:` line must gain `; S022` (append to the citation list, one line kept) and the erratum sentence above, in the same integration. If the integrator refuses to touch the entry, mark S022 `queued` with `used-by: —` and leave S013 operative — the anchor defect then remains.

## Falsifier

Any Vault docs revision on the v2.x-latest or pinned tracks where (a) the KV note no longer says the backend "does not issue leases", (b) dynamic secrets no longer require a lease, or (c) revoking a token no longer revokes leases created with it. Also: a Vault KV v2 API page showing a lease issued on read (would falsify the bounded "KV read carries no lease" control, while a documented KV delete/destroy path would only delimit retention, which S013 never claimed), or the version selector no longer displaying "v2.x (latest)" (would falsify the revision descriptor in S022).

## Limits

No Vault or OpenBao was run; no KV API/delete pages were opened; no other docs page was compared beyond the 1.21.x lease page. Wayback has no 2026-10-19/20 capture, so the exact bytes behind `ae3215…` cannot be reconstructed; its method is unknown. Archived raw bytes are Wayback-rewritten and were not compared as bytes. Report only; registry, stamps, entries, and lane state were not written.

Report: `.ufo/waves/round-22/build/Source13.md`
