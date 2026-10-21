# RecapS014-2 — round-24 BUILD wave 1 — legacy row S014 recapture (freshness)

Row: `S014 | JWT/OIDC auth method — https://openbao.org/docs/auth/jwt/ | docs | A`
(`corpus/SOURCES.md:20`). Scope: "OpenBao JWT/OIDC authentication and role claim
validation"; anchor "§JWT/OIDC auth method and §JWT verification; OpenBao 2.7.x";
in-row pin (legacy, historical in-row `Fetch sha256:`):
`e94723241fbcbdd0b2741c569f6ce51befe39e526cd736cebe4023fbca1cb0b1`.

## Fetch (declared profile, scratch seat dir)

Command (exact):
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D s014-headers.txt -w '%{url_effective} %{http_code}\n' -o s014-body.html https://openbao.org/docs/auth/jwt/`

- final URL: `https://openbao.org/docs/auth/jwt/` (no redirect); HTTP `200`; curl exit 0.
- decoded body: 63046 bytes (gzip `content-encoding`; `-o` file is the decoded body;
  `wc -c` agrees). `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`; `date: Wed, 21 Oct 2026 06:15:36 GMT`.
- Scratch: `/fast/scratch/kagi-r24/seats/RecapS014-2/{s014-body.html,s014-headers.txt,s014-normalized.txt,explore.py}`.

## Digests — committed normalizer, single declaration

`python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py --selftest`
→ `RENDERED_TEXT_V1_SELFTEST: PASS (cases=20)`, rc=0.

`python3 …/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS014-2/s014-body.html`
→ `RENDERED_TEXT_V1: raw_sha256=449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9 bytes=63046 normalized_sha256=ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403 normalized_bytes=15942`, rc=0.

| pin `e9472324…cb0b1` vs | value | match? |
|---|---|---|
| raw sha256 | `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` | **no** |
| normalized sha256 | `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403` | **no** |

Pin matches neither digest. Consistent with the round-22 registry caveat that
"Original Fetch hashes remain historical point observations with undocumented
representation" — the pin is a stale point observation, not reproducible under
the committed normalizer.

## Locate — in-row quote

`python3 …/corpus/rendered-text-v1.py locate s014-body.html 'The JWT auth method can be used to authenticate with OpenBao using OIDC'`
→ `RENDERED_TEXT_V1_LOCATE: count=0`, rc=1 (locate is case-sensitive; the quote is
only whitespace-collapsed).

Cause: the page renders the method name in code style, lowercase `jwt`; the in-row
quote uppercases it. This is exactly the recorded erratum ("S014's uppercased JWT
quote is normalized text, not a case-literal excerpt", `corpus/SOURCES.md` search-log
erratum) and S025's superseding corrected quote.

count=0 branch — closest live sentence (verbatim in normalized text, 18 words):

> "The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT"

Nearest heading before the first hit: `h1` **"JWT/OIDC auth method"** (normalized-text
positions: heading 619, sentence 640; the page-title copy of the same H1 sits at 0;
"Version: Version 2.7.x" immediately precedes the heading, matching the row's 2.7.x
anchor). Verified counts on my capture: lowercase-jwt short variant count=1; the full
S025 sentence with "or by providing a JWT" count=1 — S025's corrected locator
reproduces on today's live page.

## Does the scope/teaches still hold? — yes

Teaches: "OpenBao 2.7.x supports OIDC and direct-JWT authentication with configured
signature verification and claim handling." Live page (2.7.x displayed) grounds each part:

- OIDC + direct JWT — "The jwt auth method can be used to authenticate with OpenBao
  using OIDC or by providing a JWT" (§JWT/OIDC auth method).
- Configured signature verification — "JWT signatures will be verified against public
  keys from the issuer. This process can be done in three different ways, though only
  one method may be configured for a single backend: Static Keys … JWKS … OIDC
  Discovery" (§JWT verification).
- Claim handling — "Once a JWT has been validated as being properly signed and not
  expired, the authorization flow will validate that any configured \"bound\"
  parameters match" (§Bound claims; §Claims as metadata present at normalized pos 13202).

All anchor headings the row names (§JWT/OIDC auth method, §JWT verification) exist on
the live page. Verdict: **yes** — scope/teaches holds unchanged; only the quote's case
and the digest pin are stale, which row S025 (opened 2026-10-21) already supersedes.
No content drift found beyond the documented case-normalization issue.

## Operability notes

- No tool installs or upgrades were needed; pacman untouched (transactions paused host-wide).
- Lane untouched except this report; analysis ran on scratch copies, the normalizer
  executed read-only from `corpus/rendered-text-v1.py` (selftest + digest + locate only).
- Axes: operability clean (profile fetch 200/exit 0, normalizer PASS); freshness —
  pin stale on both digests, quote superseded exactly as S025 records; calibration —
  not in this item's scope (no identity row touched).
