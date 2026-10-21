# ClockS012 — C3 release clock for SOURCES S012 (Vault JWT/OIDC)

Lane `kagi-shokunin` at BASE `4587c61a348e4528717404a68912c373f3ef4d03` (`git rev-parse HEAD`, exit 0). Observed 2026-10-21. Experiments in `/fast/scratch/kagi-r25/ClockS012`. Fetch profile: `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home curl -q -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o <file> -w <fields> <url>` (`-q` skips any curlrc; no auth, no cookies). Tools: none installed or upgraded.

## Verdict
- Governing identity: (a), the Vault product release. The page is version-routed: its switcher labels `v2.x (latest)` then `v1.21.x`; its Edit-on-GitHub source is `content/vault/v2.x/content/docs/auth/jwt/index.mdx`. Feed: GitHub releases API for `hashicorp/vault`.
- Clock: **fired**. Anchor `v1.21.x`; feed latest stable `v2.2.0`, published `2026-10-15T16:17:18Z`.
- Timing: the feed passed the anchor four days before S012 was opened (2026-10-19). The `on-release` clock was never bound, so nothing could fire.
- Teaches "Vault requires an exact role audience match when a presented JWT has an audience claim": **still holds** for JWT roles (OIDC optional, as S022 already records).

## Proposed `corpus/release-clocks.tsv` line (tab-separated)
```
S012	feed	https://api.github.com/repos/hashicorp/vault/releases/latest	v1.21.x	v2.2.0	2026-10-21	fired
```

## Feed SOURCES candidates (planner assigns ids; S033/S034 if unclaimed after S032)
- S033 | Vault latest stable release, GitHub release API (hashicorp/vault) — https://api.github.com/repos/hashicorp/vault/releases/latest | code | A | latest non-prerelease, non-draft Vault release identity (tag, publish time, target commit) for the S012 clock; not behaviour evidence | release object: tag_name v2.2.0, published_at 2026-10-15T16:17:18Z, prerelease false, draft false; opened 2026-10-21 | Vault's latest stable release is v2.2.0, published 2026-10-15; S012's v1.21.x anchor is behind it. Quote: `"tag_name":"v2.2.0"` (top-level release object) | mined | 2026-10-21 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md
- S034 | GitHub REST, Get the latest release — https://docs.github.com/en/rest/releases/releases | docs | A | defines "latest" used by S033 | section "Get the latest release"; served 2026-10-21 | "latest" is GitHub's definition, not the highest version number. Quote: "The latest release is the most recent non-prerelease, non-draft release, sorted by the created_at attribute." (section "Get the latest release"; rendered-text-v1 locate count=1) | mined | 2026-10-21 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md
- Fetch rows for source-fetches.tsv (row identity via row-identity.sh; no `-L`, so final_url = url):
  - S033: 200; representation decoded-http-body-volatile-v1; sha256 `8deb527d2bb6879fe76ae53a9f979d45f4fcfe620447e9cbc9f12d444428c338`; bytes 102014; revision `2891bfd23893ebd302307050edaf03d871ea8351` (target_commitish of v2.2.0); normalization raw-literal-v1.
  - S034: 200; representation decoded-http-body-volatile-v1; sha256 `1ed00b47619a34dbc6472eae4c753ef8df38a50d2a43f77ce01ccf57bad753e8`; bytes 469759; normalization rendered-text-v1; normalized_sha256 `05a02388729ca82d49f093f4ee25917d9f47b3c56fe00091daaf52e2d53f928f`.

## Fetch evidence (2026-10-21)
| URL | HTTP / exit | decoded bytes | sha256 |
|---|---|---|---|
| developer.hashicorp.com/vault/docs/auth/jwt (S012) | 200 / 0 | 386435 | 62556bf024c400fd06878657748a0f76958f7c3b7d538e432694df31a3768292 |
| developer.hashicorp.com/vault/docs/v1.21.x/auth/jwt (anchored route) | 200 / 0 | 379672 | 77004123073fe7ce67f2d5415fb7f014de5c08a9c283a6dc1cf92f7639540dd4 |
| api.github.com/repos/hashicorp/vault/releases/latest | 200 / 0 | 102014 (wire 37844) | 8deb527d2bb6879fe76ae53a9f979d45f4fcfe620447e9cbc9f12d444428c338 |
| releases.hashicorp.com/vault/index.json | 200 / 0 | 2691686 | 85a2c038aea3d1d6ac5d8715de83251532d71a5c65be3fba215b8720d3bbcfdc |
| releases.hashicorp.com/vault/ | 200 / 0 | 145849 | 6cf08c3e9b61d7e13f9e6b922b9924f05377264dc9c386163435d8fd7afa92b6 |
| raw.githubusercontent.com/hashicorp/vault/main/CHANGELOG.md | 200 / 0 | 596973 (wire 170365) | 8b0bc48a521b33f5e00b41ee915864932942d6eeb06ae66a8ec91df4b8951e23 |
| docs.github.com/en/rest/releases/releases | 200 / 0 | 469759 (wire 29397) | 1ed00b47619a34dbc6472eae4c753ef8df38a50d2a43f77ce01ccf57bad753e8 |
| developer.hashicorp.com/vault/docs/release-notes | 404 / 22 | — | not usable; not cited |

- S012 page equals its recorded row: raw `62556bf0…` (386435 B) and normalized `06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431` (18609 B) match source-fetches.tsv:65.
- Same-day S022 capture of the same URL: raw `9a65b9d1…` (386400 B), normalized `06d2508c…` identical. Raw digest is chrome-volatile; the normalized digest is the attestation.
- Index: 1374 keys, 246 plain x.y.z, highest `2.2.0` (no `+`/`-`). Releases HTML lists `vault_2.2.0` with no dates. CHANGELOG.md:6-7: `## 2.2.0` / `### October 15, 2026`.
- `rendered-text-v1.py --selftest`: PASS (cases=22), exit 0.

## Teaches check (rendered-text-v1 locate; char offsets in normalized 2.x-route text)
- Fetch-row quote `the associated bound_audiences for the "jwt" role must exactly match …`: count=1, exit 0.
- Registry quote as written, with markdown backticks around `aud`: count=0, exit 1. Backticks removed: count=2, exit 0.
- Intro note (3436): "Starting in Vault 1.17, if the JWT in the authentication request contains an aud claim (typical case) the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT."
- §JWT verification (12038, unversioned): "If the JWT in the authentication request contains an aud claim, the associated bound_audiences for the role must exactly match…"
- §Bound claims (15304): "For roles of type "jwt": the bound_audiences parameter is required when an aud claim is set."
- OIDC scope (9116): "bound_audiences is optional for OIDC roles and typically not required."
- Anchored v1.21.x route: fetch-row quote count=1, exit 0; its Edit route is `content/vault/v1.21.x`.

## Did the claim survive the new release?
- Full-file grep of CHANGELOG.md for `audience|bound_aud|\baud\b` (case-insensitive) returns only lines 4730, 5508, 5572, all in 1.16/1.17 sections. Nothing in 2.0.0–2.2.0 (lines 6–1304). The v2.2.0 release body has no match. 2.x JWT entries cover EdDSA (:220), RAR fields (:221), `typ` validation (:469), and token revocation (:84); none touches role audience matching.
- Pre-2.x history: audience validation changed in patch-level plugin releases: :4730 (1.17.0 SECURITY, plugin v0.20.3, HCSEC-2024-11), :5572 (1.16.3, same fix), :5508 (1.16.6: "Revert GH-295 which changed the way JWT aud claims were validated"). This is why a live feed clock matters.
- Limit: docs routes and switcher show documentation source, not a deployed binary (S023 caveat). No running Vault was tested.

## Calibration findings on the S012 row (lane files untouched; planner applies)
1. SOURCES.md:18 quote contains markdown backticks, so it does not locate (count=0). Use the plain form, which source-fetches.tsv:65 already uses.
2. SOURCES.md:18 location "§JWT verification, Vault 1.17 note": the 1.17 note is in the Introduction (3436); §JWT verification restates it unversioned (12038). Relabel.
3. Anchor "newest pinned version v1.21.x" is the switcher's second entry, not latest (latest is v2.x). The row's 2026-10-19 capture is not retained, so the 10-19 state is UNVERIFIABLE here.
4. The anchor was already behind the feed when mined (v2.2.0 published 2026-10-15). Any observation after 2026-10-15 would have fired. This is the C3 gap in one row.
5. source-fetches.tsv:14-15 declares the round-23 UA; this round's captures used the round-25 UA from the brief. Declare the UA per row or add a round-25 profile.
6. corpus/knowledge/vault-openbao-token-lease-lifecycle.md:3 and :5 repeat "newest pinned entry v1.21.x" and the on-release wording; update on integration.

## Not run
- UNRUN: any Vault or OpenBao behaviour test; the 2026-10-19 capture (not retained); `corpus/release-clock.py` (absent at BASE).
- No lane file edited; no gate `verify`/`cells`; no git/jj mutation; no credential, vault, CDP or account action; no `--allow-host-rows`.
