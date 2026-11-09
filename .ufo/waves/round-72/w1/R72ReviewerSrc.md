Author: R72ReviewerSrc (reviewer — non-author source spot-check of registry delta and re-check ledger)

# R72ReviewerSrc — round 72 w1 non-author spot-check

Seat scope: (1) reopen the Vault/OpenBao release feeds; (2) semantic teaching re-check (U1) on the ten re-armed ids against today's pages; (3) S174/S175 vs QUALITY.md and CORPUS.md SOURCES contract. I did not run the frozen C1/C2 counters (other seats cover them); all hashes below are my own fetches read against committed bytes.

## 1. Live feed re-open (my fetches, curl -fsSL --compressed, browser UA)

| feed | my live bytes | sha256 | committed capture | verdict |
|---|---|---|---|---|
| `https://github.com/hashicorp/vault/releases.atom` | 297455 B | `3ead3d0f906c3a6a4467080bb991b747fa29a2604e10411921090b2e7a0e6ffc` | `.ufo/waves/round-72/capture/S174.body` 297455 B | byte-identical (`cmp` clean) |
| `https://github.com/openbao/openbao/releases.atom` | 543805 B | `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e` | `.ufo/waves/round-72/capture/S175.body` 543805 B | byte-identical (`cmp` clean) |

Newest STABLE server releases today: Vault **v2.2.1** (first entry, byte offset 503, `<id>…/v2.2.1</id>`, `<link …/releases/tag/v2.2.1>`, `<updated>2026-10-23T17:34:44Z</updated>`), OpenBao **v2.7.2** (byte offset 505, `<link …/releases/tag/v2.7.2>`, `<updated>2026-10-26T20:24:37Z</updated>`). Both match the S174/S175 anchor cells exactly. Ignored correctly: `v2.2.0`, `v2.2.0-rc1`, `sdk/v0.26.0` (Vault); `v2.6.5`, `v2.7.1`, `api/v2.7.1: …`, `sdk/…`, `v2.7.0-beta20260909` (OpenBao — note OpenBao feeds interleave 2.6.x, so "first entry" is the stable test, not "highest version": v2.6.5 < v2.7.2 numerically but appears second). Feed quote `<title>v2.2.1</title>` / `<title>v2.7.2</title>` occurs exactly once each in the raw bytes (raw-literal-v1), 1 word (≤25). Caveat, matching the lane's own convention: `corpus/rendered-text-v1.py locate` on the feeds returns `count=0` (markup is stripped before matching) — the feeds are located raw-literal, not rendered, which is why `source-fetches.tsv` declares `raw-literal-v1` for S174/S175. The plan truthfully says LIVE binds vendor state at measurement time (U3); today's live state still reads 2.2.1/2.7.2, so the re-arm has not yet been overtaken.

## 2. Ten-id re-check (my re-fetches, 6 distinct URLs)

My live fetches and the committed `capture/<id>.page.body` files are byte-identical for all ten ids (`cmp` clean, sha256 equal):

| page | bytes | sha256 (prefix) |
|---|---|---|
| Vault lease | 261663 | `5c41c27a…` |
| OpenBao JWT | 63046 | `893f33e4…` |
| OpenBao k8s provider | 55824 | `7007e9e4…` |
| OpenBao tokens | 47384 | `ea9bdafe…` |
| Vault JWT | 386868 | `16c44654…` |
| Vault KV v2 | 586212 | `eeeee4cb…` |

Quote location with `python3 corpus/rendered-text-v1.py locate <my-live-body> '<declared quote>'`:

| id | declared quote (source-fetches col 13) | locate count | matches clock-rearm.tsv? |
|---|---|---|---|
| S013 | All dynamic secrets in Vault are required to have a lease. | 1 | yes |
| S014 | The jwt auth method can be used … or by providing a JWT | 1 | yes |
| S015 | The JWT auth engine does not use Kubernetes' TokenReview API during authentication | 1 | yes |
| S016 | When a parent token is revoked … revoked as well. | 1 | yes |
| S021 | After the current TTL is up, the token will no longer function … revoked. | 1 | yes |
| S022 | the associated bound_audiences for the "jwt" role must exactly match … | 1 | yes |
| S023 | All dynamic secrets in Vault are required to have a lease. | 1 | yes |
| S024 | max_versions (int: 0) – The number of versions to keep per key. | 3 | yes |
| S025 | The jwt auth method can be used … or by providing a JWT | 1 | yes |
| S026 | When a parent token is revoked … revoked as well. | 1 | yes |

Semantic check U1 — does each id's `teaches` cell still hold on today's page (read the surrounding rendered text)? **All ten teaching-holds**:

- S013/S023 (lease): quote sits in the lease-requirement paragraph; page still teaches Vault leases for dynamic secrets with the static-KV distinction. holds.
- S014/S025 (JWT): quote is the opening of "JWT/OIDC auth method"; page header still reads "Version 2.7.x"; supports OIDC + direct-JWT reading holds.
- S015 (TokenReview): quote is inside the "Note:" block; following sentences still state revoked tokens remain valid until expiry. holds.
- S016/S026 (parent token): quote under "Token hierarchies and orphan tokens"; surrounding text still about nested revocation trees. holds.
- S021 (TTL): quote in "Token Time-To-Live" section; still about non-root token expiry + lease revocation. holds.
- S022 (audience): quote is the Vault 1.17 note sentence "Starting in Vault 1.17, if the JWT … contains an aud claim …"; still teaches exact bound-audience matching for JWT roles (the page separately states `bound_audiences is optional for OIDC roles`, consistent with the teaches cell's JWT-vs-OIDC split). holds.
- S024 (max_versions): quote in `POST /:secret-mount-path/config` parameter list; surrounding text still about retained-version capping. holds.

No teaching-changed verdicts. The round-47 semantic leg ("same releases, teaching-holds") and the round-72 quote-location leg agree on today's pages.

## 3. S174/S175 vs QUALITY.md and the SOURCES contract

- **Tier/scope (QA1, CORPUS.md tier A = primary source for scope):** kind `code`, tier A, scope "release identity (newest stable X.Y.Z tag)" — the GitHub release feed is the authoritative primary source for the tag, and S034/S035 already set this precedent. Admit.
- **Anchor (CORPUS.md: exact section + revision, never bare homepage):** anchor cell names entry title, tag link and `updated` timestamp — all verified in §1 against my live bytes. Admit.
- **Quote (≤25 words, located):** `<title>v2.2.1</title>` / `<title>v2.7.2</title>` — 1 word each, raw-located exactly once in the committed captures. Admit (with the raw-literal caveat above, which the lane declares openly).
- **Supersedes wording (CORPUS.md rule 2, append-only):** both rows open `teaches` with `supersedes S034 —` / `supersedes S035 —`; S034/S035 are untouched. Admit.
- **used-by (contract: mined ⇒ cited by ≥1 path):** `corpus/lessons/round-72.md` exists and its first line reads `source: S174, S175`. Admit, but see SR-3 (the lesson is a 3-line draft with no `## Gate` section).
- **status/opened/recheck:** `mined`, `2026-11-09`, `90d` — within contract (opened = the round that wrote the row; `on-release` would be the wrong cadence for a feed row whose clocks already carry the release trigger; 90d matches S034/S035/S089/S090 precedent). Admit.

**Chain duplication — the one structural wobble.** At BASE there were already S089/S090: same URLs, same anchors (v2.2.1 / v2.7.2), same "supersedes S034/S035" wording, `mined`, opened 2026-11-05, used-by round-37 lesson. S174/S175 add a second "current anchor" pair for the same two feeds at the same versions. Contract rule 2 says a correction is a new row superseding the old — S174/S175 supersede S034/S035, but nothing supersedes S089/S090, and the S174/S175 scope cells ("re-armed derived clocks") overlap S089/S090's scope ("on-release clocks of S012, S013 and S022-S024", etc.). The counter is blind to this (SOURCED only requires "not in BASE registry"), so the candidate reaches 10 with two co-equal current anchors in the registry. Note S089/S090 are already unused by `release-clocks.tsv` (their clocks re-pointed to S034/S035 post-round-37), so S174/S175 are not making a live binding worse — they continue a pattern. This is a registry-coherence debt, not a C1-number defect. SR-4.

## 4. Ledger / receipt / C2 spot evidence (not counters, one-lane reads)

- **Receipt pin (GATE):** gate's `DEFAULT_RECEIPT_SHA256 = 022e8299…` equals the committed `.ufo/waves/round-72/final/observe-r72.json` sha256; receipt has 32 observations, all `observed_at` 2026-11-09T04:01Z; F ids parse to 2.2.1 (×4) / 2.7.2 (×6), equal to their anchors. Holds.
- **base anchors:** BASE had all ten fired at 2.2.0/2.7.1 on S034/S035 — re-arm delta confirmed.
- **fired-reverify.tsv:** 10 of its 11 rows are the F ids, all `teaching-holds` at 2.2.1/2.7.2 (matches §2 today).
- **C2 numbers:** `SKILL.md` and `PROVINCE.md` both read 181 stamps + 102 claims, consistent with the C2 receipts (`claims=63 stale=0`). Holds on the candidate tree.
- **R36-03 (ledger row the plan's integration duties name):** `corpus/claim-ledger.tsv` matches gate output only via the summary `fired=14` expectation in column 3, while the live gate prints `fired=4` (ten clocks re-armed). `bash plans/round-36-c3.sh` exits 0 printing `CLEAN … fired=4 …`, but the ledger row's stored regex still expects `fired=14`, and the candidate diff does not touch `corpus/claim-ledger.tsv` (0 lines) and adds no expectation-migration journal — contrary to the plan's own integration duty ("an expectation-migration journal for every ledger row the move changes (at least R36-03, whose pinned line reads `fired=14`)"). The claim gate therefore runs red on the candidate until the close-out. The C1 counter does not read this row, so C1=10 is unaffected; the defect is the missing journal, not the clock math. SR-1.

## Findings

FINDING SR-1 falsifies-wording The plan's integration duty requires an expectation-migration journal for R36-03 (pinned `fired=14` → now `fired=4`); the candidate diff leaves corpus/claim-ledger.tsv untouched, so the claim gate is red on the landed tree until close-out.
FINDING SR-2 neutral S174/S175 feed quotes locate count=0 under corpus/rendered-text-v1.py (markup stripped); the lane declares raw-literal-v1 and the raw quotes locate exactly once — consistent, but a reader re-running the rendered-text locate on the feeds gets 0 and should not mistake it for a location failure.
FINDING SR-3 neutral corpus/lessons/round-72.md is a 3-line draft ("source: S174, S175" + heading) with no ## Gate section, so used-by resolves but the contract's Gate/Gate-review leg has no content to check this round.
FINDING SR-4 neutral S089/S090 already carry the same v2.2.1/v2.7.2 anchors and supersedes wording at the same feed URLs; S174/S175 add a second co-equal current-anchor pair with nothing superseding S089/S090 — registry-coherence debt the counter does not see (C1 number unaffected).
FINDING SR-5 neutral All ten re-armed ids teaching-holds on today's pages (round-47 semantic leg and round-72 quote leg agree), and both live feeds still read v2.2.1 / v2.7.2 byte-identical to the committed captures — no defect; recorded as the seat's positive non-author confirmation.
SEAT-STATUS: complete Round-72 source spot-check finished: feeds reopened byte-identical, all ten quotes located and teaching-holds verified on today's pages, S174/S175 admitted; one open item (missing R36-03 journal) reported for close-out.

Tooling: installed/upgraded none (curl, python3, rendered-text-v1.py, cmp, sha256sum only).
