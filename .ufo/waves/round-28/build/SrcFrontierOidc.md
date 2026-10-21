# SrcFrontierOidc — GitHub Actions OIDC page, round-28 frontier opening

BASE `3553d499577084a6c98d7078906017840bbf7b28`; `git diff --stat BASE -- corpus/` → 0 lines,
so every `corpus/` line cited below is BASE-identical.

## Findings

**F1 — ADMIT, tier A.** The opened page grounds the identity-claim half of the frontier lead
(`corpus/README.md:112`, lead text at `corpus/SOURCES.md:80`): trust-policy validation compares a
token's subject and other claims to conditions preconfigured on the cloud role. It is GitHub's own
vendor documentation for the issuer/claim model, so tier A (primary) is right; a third party
describing it would be B, this is not.

**F2 — the requested URL is not the page.** Requested
`/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect`
returns **301** to `https://docs.github.com/en/actions/concepts/security/openid-connect` (200).
Exact title is **`OpenID Connect`** (H1, exactly one `<h1>`); `og:title` = `OpenID Connect - GitHub Docs`.
The legacy title string `About security hardening with OpenID Connect` occurs **0** times in the
served body (`grep -c` exit 1). Register the **final** URL; record the legacy path in the anchor so a
re-open through it is not later mistaken for a second source. Registering the legacy path would
also make an exact-URL duplicate check blind to a second row on this same target.

**F3 — audience binding is NOT stated in prose.** The page mentions no `aud` rule. Audience appears
only as claim data in two token examples (`"aud": "https://github.com/octo-org"`;
`"aud": "https://github.com/my-org"`). Rendered-text counts: `"aud"` 2, `"iss"` 1, the words
`audience`/`issuer` 0 each. A row that asserts "the audience must match the configured
value" would be **unsupported by this page** — that wording exists in the lane only for Vault
(`corpus/SOURCES.md:18`, S012/S022). Keep the row's `scope`/`teaches` on subject+claims, or open
`/en/actions/reference/security/oidc` first (not opened this round).

**F4 — calibration hazard: the `sub` example is self-declared stale.** Under §Understanding the OIDC
token the page carries the note: "The sub claim in this example uses the previous format." and
"Repositories created after July 15, 2026 use an immutable default subject format that includes owner
and repository IDs (not available on GitHub Enterprise Server)." Concrete counterexample: the example
`sub` `repo:octo-org/octo-repo:environment:prod` is not the current default subject for a repository
created after 2026-07-15. Any row quoting it as *the* subject format is wrong for new repos; the row
must either date-qualify the example or teach only the binding rule.

**F5 — no duplicate URL (no W04).** `grep -c 'docs.github.com' corpus/SOURCES.md` → **0** (exit 1);
recursive `corpus/**/*.md|tsv` → 0. The only `github.com` URLs in the registry are the four release
feeds S033–S037 (lines 39–42, 45: `getsops/sops`, `hashicorp/vault`, `openbao/openbao`,
`whatwg/html`), different host path and different kind. Next free id is **S044** (last registry row
S043 at `corpus/SOURCES.md:50`; header at `:5`).

**F6 — freshness is byte-pinned only.** The page is unversioned: no `datePublished`, no
`Last-Modified`/`ETag` in headers, `content-length: 357518` matching the saved body,
`cache-control: public, max-age=60`, `age: 31`, `x-cache: MISS, HIT`. The hash pins the served bytes,
not an origin revision. Propose `90d` (the established value for unversioned docs rows, S001–S004),
not `on-release` — this page has no release feed.

## Located quote (verbatim, 21 words, ASCII only)

> the cloud provider checks if the OIDC token's subject and other claims are a match for the conditions that were preconfigured

- Locator: §**Understanding the OIDC token**, anchor `#understanding-the-oidc-token`.
- Verified: `rendered_text.count(quote) == 1`; the containing full sentence is 32 words (over the
  25-word cap) and ends `…preconfigured on the cloud role's OIDC trust definition.`; apostrophe is
  U+0027; no non-ASCII in the quote.
- Audience datum (example line, not prose): `"aud": "https://github.com/octo-org"` in the same
  section's example token; `iss` is `https://token.actions.githubusercontent.com`.

## Proposed row (single line, schema at `corpus/SOURCES.md:5`)

```
| S044 | OpenID Connect — https://docs.github.com/en/actions/concepts/security/openid-connect | docs | A | GitHub Actions OIDC token claim model for workload-federation trust policy: subject and other claims bound to a cloud role's preconfigured trust definition; issuer/audience shown only as token-example values, no matching rule | §Understanding the OIDC token (#understanding-the-oidc-token); unversioned live page, legacy how-to path 301s to this URL, no displayed version/date, opened 2026-10-21 | Trust-policy validation compares the token's subject and other claims against conditions preconfigured on the cloud role; the example token carries `iss` `https://token.actions.githubusercontent.com`, `aud` `https://github.com/octo-org`, `sub` `repo:octo-org/octo-repo:environment:prod` (example marked “the previous format”). Quote: “the cloud provider checks if the OIDC token's subject and other claims are a match for the conditions that were preconfigured” (§Understanding the OIDC token, rendered text). Fetch sha256: `816896969778514c93dea2fe9fce1758e978b7624a2545d3a2147c38911cfda8`. | mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |
```

Scope wording deliberately excludes: audience equality (F3), per-provider trust configuration
(AWS/GCP/Vault how-tos), and any claim that GitHub validates `iss` in prose (only the claim value is
shown). If the Gate needs an audience-bearing row this round, **REJECT this row as insufficient** and
open the OIDC reference page instead — this page cannot carry that claim.

## Commands run

| command | exit | result |
|---|---|---|
| `curl -sS -L -o oidc-raw.html -w ...` (requested URL) | 0 | 200, final `…/concepts/security/openid-connect`, 357518 B, `text/html; charset=utf-8` |
| `curl -o /dev/null -w %{http_code}/%{redirect_url} <legacy>` | 0 | 301 → `https://docs.github.com/en/actions/concepts/security/openid-connect` |
| `curl -o /dev/null -w %{http_code} <final>` | 0 | 200 |
| `curl -sSI <final>` | 0 | no ETag/Last-Modified; max-age=60, age=31, x-cache MISS, HIT |
| `sha256sum oidc-raw.html` | 0 | `816896969778514c93dea2fe9fce1758e978b7624a2545d3a2147c38911cfda8` (357518 B) |
| python3 rendered-text projection (`renderedPage` JSON, tags stripped) | 0 | 9386 B, sha256 `b94d42cbed8a8b6e0763fbe226457cbe012e2e854134c559d739dc9cea4ae308` |
| quote/sentence/note counts (same script) | 0 | quote 1, sentence 1 (32 words), note 1 (24 words), `sub` previous-format note 1, `<h1>` 1 |
| `grep -c 'docs.github.com' corpus/SOURCES.md` | 1 | 0 matches |
| `grep -rn 'docs.github.com' corpus/` | 1 | 0 lines |
| `grep -o 'https\?://…github\.com…' corpus/SOURCES.md` | 0 | 4 URLs, all release feeds |
| `grep -c 'About security hardening with OpenID Connect' oidc-raw.html` | 1 | 0 matches |
| `git diff --stat BASE -- corpus/ \| wc -l` | 0 | 0 (BASE == worktree for corpus) |
| `awk` recheck-values census | 0 | 30 `on-release`, 11 `90d`, 2 `180d` |

Artifacts: `.ufo/waves/round-28/sandboxes/SrcFrontierOidc/oidc-raw.html`,
`…/oidc-rendered.txt`. No tool installs or upgrades were needed.

## Not checked

- Did not open `/en/actions/reference/security/oidc` or the OIDC-in-AWS/Azure/GCP/Vault how-tos, so
  audience-matching semantics and per-provider trust conditions remain unverified (F3).
- Did not execute page JavaScript or compare against a browser DOM; the article text came from the
  SSR `renderedPage` payload embedded in the fetched body. Client-only widgets were not rendered.
- Did not check localized (`/ja`, `/es`…) or GitHub Enterprise Server variants; the immutable-subject
  note is explicitly not available on GHES.
- Did not fetch GitHub's docs changelog, so the page's last real edit is unknown (no header/date).
- Did not run any lane gate, census, selftest or release-clock command in the lane checkout, and did
  not edit `corpus/SOURCES.md` — the row above is a proposal for L1.
