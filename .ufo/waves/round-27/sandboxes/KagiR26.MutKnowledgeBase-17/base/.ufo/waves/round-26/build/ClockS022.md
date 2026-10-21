# ClockS022 — round 26 C1 freshness re-verification of S022

Seat: `KagiR26.ClockS022` (scout, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` in `kagi-shokunin` → `1bf3eec48d3761580ffd375c88143232485ae814` (equals frozen BASE; untracked only `.ufo/waves/round-26/`, `plans/round-26.md`).
Access: 2026-10-21T13:36:40Z (UTC, `date -u` immediately before fetch).
Writes: this report, plus fetched bytes in `.ufo/waves/round-26/sandboxes/ClockS022/` (`jwt.html`, `jwt.headers`, `feed.atom`, `feed.headers`). No production, registry, Git or jj writes. No tool installs.

## Verdict

**Not fired. The teaching holds, and the normalized page is byte-identical to the registered capture.** S022 is a Vault row, not Python. The Python 3.15.1 / 3.15.0 comparison in the assignment applies to S027/S028 only; nothing in it applies here.

## Rows inspected (read-only)

- `corpus/SOURCES.md:28`. S022 teaches: from Vault 1.17, a JWT role's `bound_audiences` must exactly match at least one `aud` claim when the JWT carries one. Separately, `bound_audiences` is optional for OIDC roles. Clock: `on-release`.
- `corpus/release-clocks.tsv:19`: `S022 feed S034 https://github.com/hashicorp/vault/releases.atom 2.2.0 2.2.0 2026-10-21 not-fired`.
- `corpus/source-fetches.tsv:49`: decoded sha256 `9a65b9d1…`, 386400 bytes, `decoded-http-body-volatile-v1`. Normalized (`rendered-text-v1`) sha256 `06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431`. Anchor: "Introduction, Vault 1.17 Note".

## Clock check (feed S034)

The fetch command was `curl -fsSL --compressed -D feed.headers -o feed.atom https://github.com/hashicorp/vault/releases.atom`:

- HTTP/2 200, `date: Wed, 21 Oct 2026 13:36:37 GMT`, `etag: W/"e41bc5793403136a07c68d7d107fe3e9"`, 303995 bytes, sha256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`.
- Calling the committed `parse_latest_version` (imported read-only from `corpus/release-clock.py`) on these bytes returned `2.2.0`.
- The first six entries in feed order are: `v2.2.0` (2026-10-15T18:50:14Z), `v2.2.0-rc1`, `v2.1.2`, `sdk/v0.26.0`, `v2.1.1`, `v2.1.0`. The parser correctly skips the rc prerelease and the `sdk/` module tag.
- The anchored version is 2.2.0 and the observed version is 2.2.0, so the clock has **not fired**. There is no Vault release drift since round 25.

## Source check (S022 page)

The fetch command was `curl -fsSL --compressed -D jwt.headers -o jwt.html https://developer.hashicorp.com/vault/docs/auth/jwt`:

- HTTP/2 200, no redirect (`url_effective` is the same URL), `content-type: text/html; charset=utf-8`.
- Headers: `date: Wed, 21 Oct 2026 11:20:47 GMT`, `age: 8152`, `x-vercel-cache: HIT`, `etag: W/"6jrzli4u098a69"`.
- Decoded body: 386435 bytes, sha256 `4b4a151d5f0c92925e89a1c44a2478de602c5742568c60dab53a1b3843b2638e`. This differs from the registered `9a65b9d1…`/386400, which the row already declares as volatile.
- `python3 corpus/rendered-text-v1.py digest jwt.html` printed `normalized_sha256=06d2508c959bf32976b70965d254fb75b745ecc43d99970aed35088eecb4a431 normalized_bytes=18609`. That is **equal** to the registered normalized digest.

Both located quotes are verbatim and 25 words or fewer:

- **Introduction, Vault 1.17 Note**: "the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT." `locate` returned `count=1`. The sentence opens with "Starting in Vault 1.17, if the JWT in the authentication request contains an aud claim (typical case)".
- **OIDC configuration troubleshooting** (`id="oidc-configuration-troubleshooting"`): "bound_audiences is optional for OIDC roles and typically not required." `locate` returned `count=1`.
- Served version selector: "JWT/OIDC v2.x (latest) … v1.21.x … v1.16.x". This is the `v2.x (latest)` route, the same as recorded in round 25.

## Bounded result

- Both halves of S022's teaching hold as written on the page served 2026-10-21: the JWT-role exact-match rule (conditioned on an `aud` claim being present) and the OIDC-optional qualifier.
- This covers two located quotes only. It does not cover the whole page.

## Limitations and possible counterexamples

1. **The docs page cannot pin a patch release.** The page is the floating `v2.x (latest)` route, so the docs alone cannot show that the teaching holds at exactly v2.2.0.
   - The "2.2.0" comes from the feed, and the "holds" comes from the docs. The verdict combines two sources and is not evidence from one.
   - I did not open the v2.0.0–v2.2.0 changelog this round. Round 25's ClockS012 reported no audience-handling change there, and I have not re-checked that.
2. **The page came from an edge cache.** The response was a CDN hit (`age: 8152`, origin date 11:20:47Z, about 2h16m before access). An origin edit made after 11:20Z would not be visible in this fetch.
3. **The anchor's version number dates the feature, not the page.** "Vault 1.17" says when the rule started. `release-clocks.tsv:19`'s note already says this, so no correction is needed.
4. **What would flip this verdict:**
   - a feed entry newer than `v2.2.0` that is stable and not under `sdk/`;
   - a page where the normalized digest moves and either quote's `locate` returns count 0;
   - a v2.x changelog line that changes JWT `aud`/`bound_audiences` matching.

   None of these was observed.

## Recommendation to L1

- Record S022 in the new round-26 receipt as follows:
  - verdict: `not-fired`, observed 2.2.0 at 2026-10-21;
  - teaching re-verified, normalized digest unchanged (`06d2508c…`);
  - raw digest volatile.
- No new superseding registry row is warranted. Leave the round-25 receipt as it is.

## Commands not run

No build, lint, test, formatter, or `release-clock.py --observe` run was done. The normalizer was run only with `digest` and `locate` on sandbox files. The committed feed parser was only imported and called on the sandbox bytes.
