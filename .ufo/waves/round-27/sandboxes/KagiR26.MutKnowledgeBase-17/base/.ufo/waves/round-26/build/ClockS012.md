# ClockS012 — round 26 C1 freshness re-verification of SOURCES S012 (Vault JWT/OIDC)

Lane `kagi-shokunin`, observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`, exit 0; worktree differs from BASE only by untracked `.ufo/waves/round-26/` and `plans/round-26.md`). Observed 2026-10-21T13:36:45Z (`date -u`). Seat sandbox: `.ufo/waves/round-26/sandboxes/ClockS012/` (bodies `*.body`, headers `*.hdr`). Production files were not edited. Tools: none installed or upgraded (curl 8.23.0 and python3 were already on the host).

Godspeed axes: **freshness** (was the declared clock and source teaching re-opened this round, and does it still hold?) and **calibration** (is the verdict sized to the evidence, with limits stated?).

## Verdict
- **Clock (S034 feed):** still `fired`, and nothing has changed since round 25. The newest stable release is still `v2.2.0`. The feed's decoded body digest `e41bc579…` is byte-identical to the S012 observation in both `.ufo/waves/round-25/observe-1.json` (11:31:50Z) and `.ufo/waves/round-26/observe-1.json` (13:36:32Z). No new Vault release has appeared.
- **Teaching:** it **still holds**, within its JWT-role scope (S022's existing correction covers OIDC roles). On the served `v2.x (latest)` page, the rendered-text-v1 normalized digest `06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431` (18609 B) exactly equals `corpus/source-fetches.tsv:65`. In other words, the normalized page text has not changed since round 25.
- **Python 3.15.1 drift:** it does not apply to S012. S012 is a Vault row governed by the Vault feed (S034), not the Python feed (S036). The round-26 receipt's 3.15.1 `fired` verdicts belong to S027/S028 and were not inspected here.
- **Bounded result:** S012 has a carried-forward fired condition with an unchanged teaching. Its stale `v1.21.x` anchor is already recorded in `corpus/lessons/round-25.md:118-127`. No new superseding row is needed.

## Fetch evidence (2026-10-21, this seat)
Profile: `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home curl -q -fsSL --compressed -A 'kagi-shokunin-round26/1.0 (documentation verification)' -D <hdr> -o <body> -w '... http=%{http_code} url=%{url_effective} dl=%{size_download}'`. Every fetch returned exit 0, and every final URL equalled the request URL.

| URL | HTTP | wire / decoded B | decoded sha256 | headers of note |
|---|---|---|---|---|
| https://developer.hashicorp.com/vault/docs/auth/jwt (S012) | 200 | 53360 / 386435 | `4b4a151d5f0c92925e89a1c44a2478de602c5742568c60dab53a1b3843b2638e` | date 11:20:47 GMT, `age: 8157`, etag `W/"6jrzli4u098a69"` |
| https://developer.hashicorp.com/vault/docs/v1.21.x/auth/jwt (anchored route) | 200 | 52064 / 379583 | `bc67ab470b8036568e2801886ce25b92c54b17cc3376b0b858dbafb15c9cf924` | `age: 0`, etag `W/"loqgt9y0qm84vx"` |
| https://github.com/hashicorp/vault/releases.atom (S034, the declared clock) | 200 | 303995 / 303995 | `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba` | etag `W/"e41bc579…"` |
| https://raw.githubusercontent.com/hashicorp/vault/main/CHANGELOG.md | 200 | 170365 / 596973 | `8b0bc48a521b33f5e00b41ee915864932942d6eeb06ae66a8ec91df4b8951e23` | `x-cache: MISS` |

- **S012 page, normalized:** `python3 corpus/rendered-text-v1.py digest page.body` gives `normalized_sha256=06d2508c…a431 normalized_bytes=18609`, exit 0. This equals the source-fetches.tsv:65 normalized digest.
- **S012 page, raw:** `4b4a151d…` differs from the recorded `62556bf0…`, even though the byte count is the same (386435). This is the known chrome-volatile raw representation (`decoded-http-body-volatile-v1`), not drift.
- **v1.21.x route, normalized:** `eca20e0c7eb5ade353955bf5202198316b37f5628d478678c7681732964124da` (18004 B). No earlier normalized value is recorded for this route, so it cannot be compared.
- **Feed parse:** the production parser `parse_latest_version` (imported from `corpus/release-clock.py`) returns `2.2.0`. The feed has 10 entries. The v2.2.0 entry is updated `2026-10-15T18:50:14Z`; the same feed also carries `v2.2.0-rc1` and `sdk/v0.26.0`, which the parser correctly ignores.
- **Changelog:** the sha256 is identical to round 25's (`8b0bc48a…`, `.ufo/waves/round-25/build/ClockS012.md:31`). The top section is still `## 2.2.0` (line 6).
- **Source routes:** the Edit-on-GitHub path on the latest page is `content/vault/v2.x/content/docs/auth/jwt/index.mdx`. On the anchored route it is `content/vault/v1.21.x/...`. The switcher labels `v2.x (latest)` 4 times and `v1.21.x` 5 times.

## Teaching check (rendered-text-v1 `locate`; offsets are character positions in this seat's normalized latest-page text)
Located quote (21 words, introduction, Vault 1.17 note, offset 3436): "the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT."

Locate counts are shown as latest page / v1.21.x route:

| query | latest | v1.21.x |
|---|---|---|
| source-fetches.tsv:65 quote (above) | 1, exit 0 | 1, exit 0 |
| SOURCES.md:18 quote as written (with backticks around `aud`) | **0, exit 1** | **0, exit 1** |
| same quote, backticks removed | 2, exit 0 | 2, exit 0 |
| `Starting in Vault 1.17` | 1 | 1 |
| `bound_audiences is optional for OIDC roles and typically not required.` (offset 9116) | 1 | 1 |
| `the bound_audiences parameter is required when an aud claim is set.` (§Bound claims, offset 15300) | 1 | 1 |

§JWT verification restates the rule without a version qualifier, at offset 11959: "If the JWT in the authentication request contains an aud claim, the associated bound_audiences for the role must exactly match …".

**Release-change check.** A case-insensitive search of CHANGELOG.md for `audience|bound_aud|\baud\b` matched only lines 4730, 5508 and 5572, which are all pre-2.x entries (1.16/1.17, HCSEC-2024-11 and its revert). There is no match in 2.0.x–2.2.0 (lines 6–~1304). The v2.2.0 feed entry content (112043 chars) has 0 audience matches. Its 6 `auth/jwt` mentions are a plugin bump to v0.27.1, EdDSA/Ed25519 for the OAuth resource server, RAR parameter fields, OAuth/RAR audit fixes, ceiling-policy HTTP status codes, and JOSE-header-only `typ` validation. None of them changes role audience matching.

## Actionable counterexamples (calibration; for the planner, no production edit made)
1. **Possible double count:** S012's `fired` in the round-26 receipt is the same condition that round 25 already recorded and re-verified. The feed body is identical, and so is the parsed version (2.2.0). If the round-26 drift count compares receipts and counts every `fired` verdict as a drift disposition, S012 would be counted again without any new drift. It should be dispositioned as "carried-forward fired, teaching unchanged", distinct from S027/S028's new 3.15.0 → 3.15.1 firing.
2. **Registry quote still does not locate:** SOURCES.md:18's quote still contains markdown backticks, so it locates 0 times on both routes. This was first reported in round 25 (`round-25/build/ClockS012.md:56`, `lessons/round-25.md:62`). The plain form in source-fetches.tsv:65 does locate (count 1).
3. **Anchor label is wrong:** SOURCES.md:18 places the quote at "§JWT verification, Vault 1.17 note". The 1.17 note is in the introduction (offset 3436); §JWT verification (offset 11959) has the version-free restatement.
4. **Stale "newest pinned" anchor:** the `v1.21.x` anchor names the switcher's second entry. It is still served, and the quote still locates there, but it is not the newest stable release. This round adds no new evidence about it. The record stays append-only in the round-25 lesson; `corpus/inrow-pins.tsv:18` pin `ec6e7b25…` remains `non-reproducing`.
5. **Volatile raw digest:** the S012 raw digest moved again (`62556bf0…` → `4b4a151d…`) at the same length. Only the normalized digest attests the page content. Any check that compares raw S012 digests across captures will spuriously flag drift.

## Limits and checks not run
- The S012 response came from a CDN cache (`age: 8157` s, origin date 11:20:47 GMT). It shows what was served, not a fresh origin render.
- Docs routes and CHANGELOG `main` describe documentation and source. They are not a deployed binary (S023 caveat). No Vault instance was tested.
- I compared only the normalized digest against BASE. I did not do a full-page semantic diff, and I did not check other S012 sections (§Claims as metadata, verification options) beyond the quotes listed above.
- Not run: `release-clock.py --observe`, `rendered-text-v1.py --selftest`, any gate, build, lint or test. The Python S027/S028 3.15.1 documentation was not fetched, because this seat's row is S012. No git/jj mutation; no credential, vault, account, handler or CDP contact.
