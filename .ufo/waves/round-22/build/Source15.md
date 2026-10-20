# Source15 — S015 re-open and claim calibration (round 22)

Axes: **calibration** (feature-bound adjudication of the S015 teaching against E3)
and **freshness** (revision pin: what is reproducible, what is only historic).
Scope: S015 only. No production edits; no source-registry edit; docs only.

Read revision: base `c2cab35bc92e57e39e5489bac3386db078345b3f`.
`corpus/SOURCES.md` S015 row was read at line 21; the row bytes are identical in
`HEAD` and the working tree (line sha256 `9a75576ebd0d6a8ac393dd92ac26f45f4fa5c188a8c2852e1eb64f71e6d86643`).
The working tree changed **concurrently during this audit** (S017–S021 appeared;
file sha256 `ebf8864654b7cf1669ffb8944d7682cdefbea3234bca3adbbcb32157488f4de2`,
66 lines) — the S015 row itself did not.
Entry E3 `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` was read at
worktree sha256 `00c8c4e209b5e07808805943cd8c728044f7466c1fe6f498494e7185d99ea784`
(138 lines, +27 uncommitted lines vs `HEAD`: the round-22 erratum).

## 1. Reopened source, 2026-10-20

URL: `https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/` — fetched
2026-10-20 (HTTP/2 200, `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`,
`etag: "6ad71d3a-da10"`, 55,824 bytes).
Page: `kubernetes`; docs selector **Version 2.7.x** (also offers Development,
2.6.x, 2.5.x). No displayed page date and no frontmatter date. Anchor
"§Kubernetes" resolves to rendered `<h2 id="kubernetes">`.

The scoped teaching is an `info` **Note** callout under §Kubernetes. Located
quotes (each ≤25 words, access 2026-10-20):

- "The JWT auth engine does not use Kubernetes' `TokenReview` API during authentication" — §Kubernetes, above URL (2026-10-20). 12 words.
- "will still be considered valid by OpenBao until their expiry time" — same callout, above URL (2026-10-20). 11 words.
- "use short TTLs for service account tokens or use Kubernetes auth which does use the TokenReview API" — same callout, above URL (2026-10-20). 17 words.

Feature-specific link followed (target verified in the rendered note:
`href=/docs/auth/kubernetes/`):

- `https://openbao.org/docs/auth/kubernetes/` — §How to work with short-lived kubernetes tokens, "Kubernetes auth is specialized to use Kubernetes' TokenReview API" (9 words, 2026-10-20).
- Same page, §Configuring kubernetes: "Otherwise deleted tokens in Kubernetes will not be properly revoked" (10 words, 2026-10-20), immediately after the `--service-account-lookup` requirement.

Path/eligibility statements on the S015 page itself (2026-10-20):
"Must use short-lived service account tokens when logging in." (§Using service
account issuer discovery, 9 words) and "No special Kubernetes RBAC permissions
are required for the service account token." (same section, 12 words).

Release status cross-check: GitHub releases API, repo `openbao/openbao`, read
2026-10-20: latest `v2.7.1`, published `2026-10-01T14:03:19Z`, `prerelease=false`.
Content-bearing file `website/content/docs/auth/jwt/oidc-providers/kubernetes.mdx`
last changed 2026-09-02 (`1b7f4b0f605e`, release/2.7.x), and the same blob
(`ca1129c2…`) is current on `main`.

## 2. Claim adjudication (registry row vs entry)

| # | Claim as written | Evidence | Decision |
|---|---|---|---|
| C1 | S015 quote is verbatim, at §Kubernetes | Note callout, 12-word quote matches exactly | **ADMIT** |
| C2 | Product is OpenBao | openbao.org OpenBao docs; no Vault attribution on the page | **ADMIT** (OpenBao only) |
| C3 | Feature is the JWT/OIDC auth path with Kubernetes as OIDC provider | "Kubernetes can function as an OIDC provider such that OpenBao can validate its service account tokens using JWT/OIDC auth" (§Kubernetes, above URL, 2026-10-20; 19 words) | **ADMIT**, condition = this provider path |
| C4 | Registry teaches "OpenBao JWT verification does not consult Kubernetes TokenReview" | Note says "The JWT auth engine does not use Kubernetes' `TokenReview` API during authentication" — page context is the Kubernetes provider | **ADMIT-BOUNDED**: cite only with the Kubernetes-provider condition; **REFUSE** as authority for other IdPs or for general issuer-revocation detection |
| C5 | "Kubernetes revocation is not immediate through this path" | Source states revoked tokens remain valid "until their expiry time"; no TokenReview check at authentication | **ADMIT-BOUNDED** restated as "not observed at all before expiry"; **REFUSE** the reading "delayed then eventually revoked" |
| C6 | Mitigation "Kubernetes auth … does use TokenReview" | Linked page: "specialized to use Kubernetes' TokenReview API"; depends on `--service-account-lookup` (default true from Kubernetes 1.7) | **ADMIT-BOUNDED**; **REFUSE** as unconditional immediate revocation |
| C7 | Status: OpenBao 2.7.x | Docs selector "Version 2.7.x"; latest release v2.7.1 (2026-10-01, not prerelease) | **ADMIT** version-scoped; **REFUSE** "current/latest" for unopened versions |
| C8 | Eligibility | No license/enterprise gate on page; issuer-discovery prerequisites are cluster-side (ServiceAccountIssuerDiscovery default from 1.20, reachable issuer URL, short-lived SA tokens) | **ADMIT** as path prerequisites; **REFUSE** any product-entitlement inference |
| C9 | E3 line 17: "external JWT validity … the issuer (IdP, Kubernetes) … issuer-side revocation is not seen by OpenBao JWT auth \| S015" | S015 supports Kubernetes only; general IdP is not on the page | **REFUSE** as operational support (historical); already labelled defective by E3's round-22 erratum |
| C10 | E3 line 59: "…an operator must revoke it" (S015+S016 inference) | S015 says validity ends at expiry; S016 says non-root tokens expire and batch tokens are not manually revocable | **REFUSE** the universal "operator must"; accept the clock separation only (withdrawn by E3 round-22 erratum) |
| C11 | E3 §OpenBao + Kubernetes section and erratum line 107 | Both restate the note's bound and the two mitigations; no cross-product extension | **ADMIT** |
| C12 | E3 `verified-at: 2026-10-19` for S015 | Content blob unchanged since 2026-09-02, before 2026-10-19 | **ADMIT** the content verification date |
| C13 | Recorded pin `a0a2b227…` is current evidence | Not reproducible under any declared method (see §3) | **REFUSE** as auditable evidence; do not restamp in place |

Tally: 13 adjudications — 5 plain admits (C1, C2, C3, C11, C12), 5 admittances
carrying an explicit refusal boundary (C4–C8), 3 refusals (C9, C10, C13).
The refusals are scope, precision, and pin evidence, not quote failures. No
row count is claimed as a measure.

Quote locations for the Evidence column: S015 fragments come from the
§Kubernetes `info` Note at the S015 URL above, accessed 2026-10-20 (full
located quotes in §1); linked-page fragments come from the headings named in
§1, same date. Every quote listed is ≤25 words.

## 3. Freshness: pin and revision evidence

Recomputed hashes for the exact page (all 2026-10-20 unless stated):

| artifact | method | sha256 | size |
|---|---|---|---|
| S015 row pin (recorded 2026-10-19) | **undeclared** | `a0a2b227a7a91b7af0033a9fc665d319776d2d03aa09341620f9abee2f195fd4` | — |
| served page | raw HTTP body of `curl -sSL` | `4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f` | 55,824 B |
| served page | tag-stripped (scripts removed), `html.unescape`, whitespace collapsed, case preserved | `a15e9a84edbcd8e10b543516032b582387e79c9a2eb708e09848ba2763bc19fd` | 8,711 chars |
| MDX blob at `1b7f4b0f605e` (release/2.7.x) | raw blob | `ca1129c20ff8dbb7bf3ff93917a976d8f48f828c0f5ee12dd75aed27728b73e1` | 8,874 B |
| same MDX on `main` | raw blob | `ca1129c2…` (identical) | 8,874 B |

Findings:

1. **The recorded pin is unreproducible, not proven stale.** No declared fetch
   or normalization is recorded in the row; the value matches none of raw
   bytes, tag-stripped text, MDX raw, CRLF/no-final-newline/whitespace-collapsed
   MDX, raw blobs on release/2.6.x and release/2.5.x, or the two prior MDX
   revisions (raw). It may have been a served build from 2026-10-19; that
   artifact is not retained.
2. **Today's served bytes differ because the site was rebuilt**, not because
   the note changed. Every OpenBao page checked (S014 `/docs/auth/jwt/`,
   S016 `/docs/concepts/tokens/`, this page, `/docs/auth/kubernetes/`) carries
   the same `last-modified: 2026-10-20T07:50:18Z` and a shared etag prefix
   `6ad71d3a`. This is a build signature.
3. **The content did not drift.** The content-bearing MDX blob has no commit
   after `2026-09-02T18:44:26Z` (`1b7f4b0f605e`), i.e. before the row's
   `opened: 2026-10-19`; the identical blob is on `main`. The quoted note is
   byte-present in both. `recheck: on-release` is not triggered (v2.7.1
   precedes the open); the next OpenBao release triggers it.
4. **This is not S015-specific.** The sibling OpenBao pins fail the same way
   under raw and text methods: S014 recorded `e9472324…` vs today raw
   `449ef132…` / text `5a8cea1a…`; S016 recorded `c083fdca…` vs today raw
   `52295218…` / text `f094ef74…`. The registry has a method-wide pin-debt
   class, not a per-row content incident.
5. **No way to replay yesterday.** Wayback CDX for
   `openbao.org/docs/auth/jwt/oidc-providers/kubernetes/`, 2026-10-01..2026-10-20,
   returned `[]` (no captures); the availability API returned 429 at query
   time. Absence of an archive is therefore the effective block on replaying
   the recorded pin.
6. **`corpus/stamps.tsv` is not stale for `SOURCES.md` at `HEAD`.**
   Expected `db134917… / 43 lines / 14,261 bytes` equals
   `git cat-file -p HEAD:corpus/SOURCES.md` exactly. The working-tree
   divergence is the wave's uncommitted registry additions. Do not "correct"
   that stamp before those edits land — that would launder an in-flight state.
   (The nine dropped stamps are outside this slice; no position taken.)

**No-laundering rule for integration:** keep `a0a2b227…` as the historic
2026-10-19 pin, do not overwrite it, and do not substitute a 2026-10-20 hash
inside S015. Add a superseding row whose pin names the *content artifact*
(MDX blob at commit) and records served-build metadata as observation, with the
fetch/normalization method stated. Ledger expectation migration (proposed
wording for the registry owner): "Pins recorded before 2026-10-20 hash served
HTML by an undeclared normalization and are not replayable; pins from
2026-10-20 name the content blob at a commit; served-build metadata is not a
pin."

## 4. Proposed superseding row

Existing S015 immutable fields (`scope`, `anchor`, `teaches`, pin) cannot be
edited and carry the unqualified subject plus the unreproducible pin, so a
superseding row is needed. Id must be the next free at integration time —
**currently S022**, but S017–S021 were appended concurrently during this audit;
re-check immediately before insertion. Required pairing: E3's `source:` line
must cite the new id in the same change (else `SC_USEDBY_NOCITE` /
`SC_ENTRY_CITE` fail). S015 may remain cited and `mined`; it is the historical
row.

```
| S022 | Kubernetes JWT provider (OpenBao) — https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/ | docs | A | OpenBao 2.7.x, JWT/OIDC auth with Kubernetes as OIDC provider: signature-only verification and no TokenReview; supersedes S015's feature bound and pin, S015 remains historical | §Kubernetes, info Note (anchor id `kubernetes`); docs Version 2.7.x, latest release v2.7.1 (2026-10-01); content openbao/openbao@1b7f4b0f605e (release/2.7.x, 2026-09-02), opened 2026-10-20 | On this path OpenBao verifies JWT signatures with public keys and does not call TokenReview; Kubernetes-revoked service-account tokens stay valid to OpenBao until expiry. Mitigations: short service-account token TTLs, or the separate Kubernetes auth method, whose TokenReview check assumes `--service-account-lookup`. Content sha256 (MDX blob at 1b7f4b0f605e): `ca1129c2…`. | mined | 2026-10-20 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```

E3 source-line addition (proposal): keep S015 as historical and add
`S022 (https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/,
§Kubernetes info Note, Version 2.7.x; content openbao/openbao@1b7f4b0f605e,
opened 2026-10-20)`, then extend `recheck:` to name S022's TokenReview note.
If the owner prefers no new id, the fallback is an appended registry
"pin/scope correction" note; the row's teaching would then remain unqualified
and I do not recommend it.

## 5. Falsifier

S015's claim is falsified by an OpenBao 2.7.x-or-later page for this provider
stating that JWT auth consults TokenReview during authentication, or that
Kubernetes-revoked service-account tokens are rejected before expiry; removal
of the note withdraws (does not falsify) the teaching. The bounded control is
falsified by a Kubernetes auth page presenting TokenReview use as
instant/unconditional without the `--service-account-lookup` dependency. The
pin verdict is falsified by a retained 2026-10-19 served artifact that
reproduces `a0a2b227…` under a declared method; absent that, the correct state
is "unreproducible historic pin", never "content changed".

## 6. Limits

- Documentation only; no OpenBao or Kubernetes process was run. The engine's
  actual behavior is not measured — the note's text is the authority.
- The recorded pin's original artifact is unknown and no 2026-10-19 archive
  exists, so the pin cannot be classified as valid or invalid, only
  unreproducible.
- GitHub API was queried unauthenticated; the commit `1b7f4b0f605e` was
  resolved by raw fetch (short SHA) and the latest-release call succeeded.
- The wave was editing `corpus/SOURCES.md` and E3 concurrently; line numbers
  are as of the stated hashes, and the proposed id must be re-checked.
- No claim is made about the nine dropped stamps, other sources' pins, or any
  runtime Vault behavior.

## Trailer

Files read (all relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`):
`corpus/SOURCES.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`,
`corpus/stamps.tsv`, `plans/round-21.md`, `plans/round-22.md`,
`corpus/lessons/round-21.md`, `corpus/sources-census.sh`,
`.ufo/waves/round-22/build-spec.json`,
`.ufo/waves/round-22/build/swarm-registry.json`.

No repository files outside this report were written; fetched pages stayed in
`/tmp`. No installs, no package transactions, no vault/account/credential
operations.

Checks the parent should run after the registry/entry edit lands (not run here):
`bash corpus/sources-census.sh` (row shape, id pairing, used-by citation);
`bash corpus/sources-census.sh --selftest` (if the row shape change is claimed);
`bash corpus/drift-pins.sh` (file pins); `git diff --check`.
