# ClockS022 — S022 per-row release clock (round-25 C3)

Seat KagiR25.ClockS022-2 · BASE 4587c61a348e4528717404a68912c373f3ef4d03 · observed 2026-10-21 · sandbox /fast/scratch/kagi-r25/ClockS022-2
Tools: curl 8.23.0, python 3.14.8, git (all preinstalled); no installs. No lane git/jj mutation, no credentials, public docs only.
Lane copies sha-equal to BASE: corpus/rendered-text-v1.py 7d6bfe81…, corpus/SOURCES.md f37e7cdd…, corpus/source-fetches.tsv 2e21e649….

## Verdict
- Release identity: (a) versioned product docs with official feeds (Vault). Clock = `feed`, feed = vendor release-notes page.
- Anchor 1.17 (SOURCES.md:28) vs observed 2.2.0, Released 2026-10-15: FIRED under the plan's literal rule. Re-verified: claim holds on the new release; no row text change needed.
- S022 teaches still holds on the current release (docs switcher "v2.x (latest)", release 2.2.0).
- Decision for L1: the literal 1.17 anchor fires on every release after 1.17, so it cannot discriminate. See §5.

## 1. Proposed release-clocks.tsv line (id, clock, feed_url, anchored_version, observed_version, observed_at, verdict)
```
S022	feed	https://developer.hashicorp.com/vault/docs/updates/release-notes	1.17	2.2.0	2026-10-21	fired
```
Parse rule for release-clock.py (first match wins, on rendered-text-v1 output): `Vault (\d+\.\d+\.\d+)(?: Enterprise)? Released : (\d{4}-\d{2}-\d{2})`. Run on 2026-10-21: 9 matches, first = 2.2.0 / 2026-10-15.

## 2. Feed SOURCES candidate (provisional id S033; no S033+ row exists in the lane, L1 assigns)
```
| S033 | Vault release notes (vendor) — https://developer.hashicorp.com/vault/docs/updates/release-notes | docs | A | Vault product release identities and release dates, newest first; feed for the S022 release clock | §Vault 2.2.0 (#vault-2-2-0), served 2026-10-21; Released : 2026-10-15 | Newest listed release is Vault 2.2.0, released 2026-10-15; the first "Vault X.Y.Z Released :" entry is the observation. Quote: “Vault 2.2.0 Released : 2026-10-15” (§Vault 2.2.0, rendered text; located count=1). | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv |
```
Fetch row (source-fetches.tsv, 16 columns; row_identity formula reproduces S022's 4e184ddb… exactly):
```
S033	mined	47b24a3518fa1c9d34837685943de9f229091793a6b22ddff27da0b5adfae346	https://developer.hashicorp.com/vault/docs/updates/release-notes	https://developer.hashicorp.com/vault/docs/updates/release-notes	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	f8133cb0e7aa65c8cfb409f917c81f56934f4f63020006d83aa05fe388e893b5	421487	-	Vault 2.2.0 Released : 2026-10-15	rendered-text-v1	f212dd5b788f07ee4c2dc5f724d83e6e9ff26ddfb212b0aba2b299554e550c18	§Vault 2.2.0
```

## 3. Fetch evidence (2026-10-21)
- S022 page, `env -i … curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' <url>`, two fetches: exit 0, HTTP 200 both, identical decoded sha256 62556bf024c400fd06878657748a0f76958f7c3b7d538e432694df31a3768292, 386435 decoded bytes (53362 wire).
- rendered-text-v1 from the BASE copy: normalized sha256 06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431, 18609 B. `--selftest`: RENDERED_TEXT_V1_SELFTEST: PASS (cases=22), rc 0.
- vs S022 row (source-fetches.tsv:49): normalized digest EQUAL; raw digest differs (row 9a65b9d1…, 386400 B), which is chrome-only volatility as the TSV header allows. S012 row (:65) raw digest EQUAL to today's capture.
- `locate` (rc / count): S022 quote 0 / 1; OIDC sentence 0 / 1; Note sentence (1.17) 0 / 1; errata OIDC quote written with markdown backticks (round-22-source-errata.md:17) 1 / 0.
- Feeds opened: vendor release-notes /vault/docs/updates/release-notes HTTP 200, sha f8133cb0…, 421487 B (CHOSEN). /vault/docs/release-notes and /release-notes/2.2.0: HTTP 404 (curl -sS exit 0; with -f exit 22).
- GitHub API repos/hashicorp/vault/releases/latest: HTTP 200 (v2.2.0, published_at 2026-10-15T16:17:18Z). But api.github.com/rate_limit: core remaining 0/60, reset 2026-10-21T11:25:01Z, so the API is unusable from this IP now.
- github.com/hashicorp/vault/releases/latest: 302 → /releases/tag/v2.2.0 (no API quota). github.com/hashicorp/vault/releases.atom: HTTP 200; top stable v2.2.0 (updated 2026-10-15T18:50:14Z), but also v2.2.0-rc1 and sdk/v0.26.0, so it needs a ^v\d+\.\d+\.\d+$ filter.
- releases.hashicorp.com/vault/index.json: HTTP 200, 2.2.0 artifacts present, no dates. CHANGELOG main: HTTP 200, "## 2.2.0 / October 15, 2026" (lines 6–7). CHANGELOG at tag v2.2.0: HTTP 200 but has NO 2.2.0 section (first heading 2.1.1; grep `2\.2\.0` = 0 matches).

## 4. Teaches verdict: S022 still holds
- Fresh page, located once each. Introduction Note: "Starting in Vault 1.17, if the JWT in the authentication request contains an aud claim (typical case) the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT."
- Fresh page, located once: "bound_audiences is optional for OIDC roles and typically not required." (OIDC troubleshooting passage.)
- 1.17 upgrade guide (HTTP 200, sha 63883fda…), located once: "If the JWT's aud claim is not set, then the role's bound_audiences parameter is not required."
- Counter-evidence search, none found: 2.2.0 release notes (Atom content lines 8–693) have zero aud/audience hits; JWT entries are the plugin bump v0.27.1, EdDSA, RAR fields and typ-header validation. CHANGELOG lines 6–4724 (2.2.0 down to 1.17.1) have zero `\baud\b|audience|bound_aud` hits.
- vault-plugin-auth-jwt CHANGELOG (raw main, sha a69c9c6d…): the only audience change is v0.20.3 (line 167, "Invalidate JWT with single non-empty string aud on empty bound audiences"); v0.21.0–v0.27.1 have none.
- HCSEC-2024-11 (discuss topic 67770 JSON, sha 04bce28c…): affected 0.11.0 to 1.16.2; fixed in 1.17.0, 1.16.3, 1.15.9; published 2024-06-12.
- Scope caveats, not falsifiers: the fix also shipped in 1.16.3 and 1.15.9 (CHANGELOG line 5572, advisory), while the row claims 1.17+ only. CHANGELOG line 5508 (1.16.6 Enterprise): "auth/jwt: Revert GH-295 which changed the way JWT aud claims were validated." The 1.16 Enterprise line is not monotonic, so any 1.16-scoped claim needs its own check.

## 5. Calibration finding for L1 (plan rule, not S022 text)
- The plan binds "the version the anchor names". S022's anchor names 1.17, a feature-introduction version, so every release after 1.17 fires this clock. "Fired" today is a re-verification trigger, not a content change.
- Verified-snapshot identity is recoverable: the 2026-10-21 capture's normalized digest covers the switcher text ("v2.x (latest)") and equals today's page; 2.2.0 predates the 2026-10-20 open. Under an amended rule (anchored = release identity of the verified snapshot), the line becomes `S022	feed	https://developer.hashicorp.com/vault/docs/updates/release-notes	2.2.0	2.2.0	2026-10-21	not-fired`. That is a re-pin: record it explicitly, do not apply it silently.
- [INFERENCE] the 2026-10-20 content (row open date) was not separately captured; equality is shown for 2026-10-21 only.

## 6. Other findings (outside this seat's write scope)
- round-22-source-errata.md:17: the OIDC quote uses markdown backticks, so locate gives 0. The rendered form locates 1. Fix the errata quote.
- SOURCES.md:18 (S012) says "newest pinned version v1.21.x" (2026-10-19). Today's switcher labels v2.x "latest" and v1.21.x as the newest non-latest entry, consistent only under that reading [INFERENCE]. Pin the wording.
- source-fetches.tsv header hard-codes the round-23 UA; round-25 fetches used the round-25 UA per contract. The profile name is unchanged; decide whether the profile text drops the UA.
- rendered-text-v1 renders `<strong>Released</strong>: X` as "Released : X" (tag-to-space rule). Quotes must use rendered spacing; say so in the normalizer declaration.
- The GitHub unauthenticated quota is per IP and was 0/60 on this host; keep api.github.com out of release-clock bindings.

## 7. Exit codes and UNRUN
- `git clone -q --no-hardlinks` + `checkout -q 4587c61a…` into sandbox: exit 0; rev-parse = 4587c61a….
- curl S022 ×2, vendor release-notes, GitHub API, rate_limit, releases index, Atom, CHANGELOG main and tag, upgrade guide, HCSEC JSON, plugin CHANGELOG: all exit 0 (HTTP 200); the two /vault/docs/release-notes routes 404.
- normalizer: `digest` rc 0; `locate` S022 rc 0; errata backticks rc 1 (count 0); `--selftest` rc 0 (PASS, cases=22).
- UNRUN: corpus/release-clock.py and corpus/release-clocks.tsv do not exist in the lane (ls reports "cannot access" for both); not created here. No lane gates run (contract).
- For main agent after integration: `python3 corpus/release-clock.py --root <tree>` and `.ufo/waves/round-25/tools/c3-measure.py <rev>`; re-open the vendor page once to confirm the Released parse on 2.2.0.
