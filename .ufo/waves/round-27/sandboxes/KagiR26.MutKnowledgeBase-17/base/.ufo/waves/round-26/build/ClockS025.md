# ClockS025 — round 26 C1 freshness re-verification (S025, OpenBao JWT/OIDC)

Seat: KagiR26.ClockS025 (scout, lane-authored advice; not non-author closure).
Observed BASE: `git rev-parse HEAD` in kagi-shokunin = `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE). Worktree untracked only: `.ufo/waves/round-26/`, `plans/round-26.md`.
Access: 2026-10-21T13:36:36Z (UTC). Production files read only; no registry/production writes.

## Bounded result

**S025: unchanged — quote located, teaching holds, clock `not-fired` still correct at v2.7.1.** No drift, no superseding row warranted. S025 is an OpenBao row; the Python S027/S028 3.15.1 comparison is outside this seat's target and was not inspected here.

## Rows under test

- `corpus/SOURCES.md:31` S025 — URL `https://openbao.org/docs/auth/jwt/`; anchor §JWT authentication → §JWT verification, §Bound claims, §Claims as metadata, §Configuration; Version 2.7.x; clock `on-release`.
- `corpus/release-clocks.tsv:22` — `S025 feed S035 https://github.com/openbao/openbao/releases.atom 2.7.1 2.7.1 2026-10-21 not-fired`.
- Recorded fetch `corpus/source-fetches.tsv:52` — body sha256 `449ef132…1785d9`, 63046 bytes, rendered-text-v1 sha256 `ca496ad8…52a403`.

## Source re-open (docs page)

Command: `curl -fsSL --compressed -D jwt.headers -o jwt.html -w 'code=%{http_code} url=%{url_effective} size=%{size_download}\n' https://openbao.org/docs/auth/jwt/`

- Observed: `code=200 url=https://openbao.org/docs/auth/jwt/` (no redirect), wire size 13325, decoded 63046 bytes.
- Decoded body sha256 `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9`, which is **byte-identical** to the recorded fetch.
- rendered-text-v1 is computed as: strip script/style, replace tags with a single space, `html.unescape`, collapse whitespace, trim, UTF-8. The result has sha256 `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403` (15911 chars), which is **identical** to the recorded value.
- Headers: `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `etag: W/"6ad71d3a-f646"`, `cache-control: max-age=600`, `x-cache: HIT`, `age: 3`, `date: Wed, 21 Oct 2026 13:36:36 GMT`.
- Quote (18 words, ≤25), found exactly once in the rendered text, under H1 "JWT/OIDC auth method": “The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT”. In the raw HTML the method name is `<code>jwt</code>` and OIDC is a link, which matches the row's correction note.
- Declared anchors present as headings: H2 JWT authentication, H3 JWT verification, H2 Configuration, H3 Bound claims, H3 Claims as metadata. The §Claims as metadata text still teaches `claim_mappings` copying claims into token/alias metadata, as the row says.
- Version selector: the page renders `Version: Version 2.7.x` as current. The dropdown also lists 2.6.x and 2.5.x. No 2.8.x or newer docs series is offered.

Teaching (bounded to the quote plus the named section headings, not whole-page coverage): the jwt method authenticates via OIDC or a directly supplied JWT, and claim-to-metadata mapping lives under §Claims as metadata. This still holds, because the bytes are unchanged.

## Clock re-open (S035 feed)

Command: `curl -fsSL --compressed -D feed.headers -o releases.atom … https://github.com/openbao/openbao/releases.atom`

- Observed: `code=200`, no redirect, 506783 bytes, sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`, `etag: W/"1f0bb338e341cfe8eb797a20bb663285"`, `date: Wed, 21 Oct 2026 13:36:28 GMT`.
- Newest entries:
  - `2026-10-01T18:32:18Z v2.7.1` at `/releases/tag/v2.7.1`
  - `2026-10-01T13:59:14Z v2.6.4`
  - `2026-10-01T13:24:26Z api/v2.7.1` (module tag, excluded by S035)
  - `2026-09-23T17:39:54Z v2.7.0`
  - `v2.6.3`
  - `sdk/v2.7.1`, `sdk/v2.6.3` (module tags, excluded)
  - `v2.7.0-beta20260909` (beta, excluded)
- The newest stable server release is still **v2.7.1**, with the same entry and timestamp that S035 records. The anchored version equals the observed version, 2.7.1, so the verdict `not-fired` holds.

## Limits (explicit, not passing claims)

- Docs-only limitation: the page labels only the series `2.7.x`. It cannot distinguish v2.7.0 from v2.7.1, so the 2.7.1 anchor is derived from the feed, as the TSV note says.
- Feed limitation: the Atom feed attests release identity only, not doc semantics. A doc edit without a release would not fire this clock. The byte-identical body digest is what covers that case today.
- CDN cache HIT (age 3s). The digest equality is the authority, not origin freshness.
- `v2.6.4` was published the same day but is an older-series backport. It is not a counterexample to "newest stable = v2.7.1".
- No build, lint, test, or gate was run. Production verification is L1's job.

## Actionable counterexamples

None found within the inspected scope: S025 URL, its rendered quote and section anchors, the version label, and the S035 feed's newest entries.

## Artifacts

Saved under `.ufo/waves/round-26/build/ClockS025-artifacts/`: `jwt.html`, `jwt.headers`, `releases.atom`, `feed.headers`.

## Tooling

No installs or updates. Tools used: system `curl`, `python3`, `sha256sum`.
