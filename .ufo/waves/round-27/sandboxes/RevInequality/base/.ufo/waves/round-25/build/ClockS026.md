# ClockS026 — S026 per-row release clock (C3, round 25)

Scope: SOURCES row S026 (`corpus/SOURCES.md:32`), fetch row (`corpus/source-fetches.tsv:53`). Access date 2026-10-21.
Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03. Sandbox clone HEAD = BASE. Lane `SOURCES.md` and `source-fetches.tsv` sha256 equal BASE (`git show BASE:… | sha256sum`). Lane: read-only, no writes. Sandbox: /fast/scratch/kagi-r25/ClockS026. Tool installs: none.

## Verdict
- Governing identity: (a) feed. S026 is a versioned docs line, not unversioned live docs.
- S026 clock = **not-fired**. Newest non-prerelease OpenBao release is v2.7.1, inside the anchored 2.7.x line.
- S026 teaches (parent-token revocation revokes child tokens and their leases) **still holds** on the 2.7.x docs. The quote locates once in the fresh page under §Token hierarchies and orphan tokens. The body is byte-identical to the recorded capture.

## Proposed release-clocks.tsv (tab-separated)
```
id	clock	feed_url	anchored_version	observed_version	observed_at	verdict
S026	feed	https://github.com/openbao/openbao/releases/latest	2.7.x	v2.7.1	2026-10-21	not-fired
```

## Why (a), not (b)
The page declares its version: `docs-version-2.7.x` on `<html>` (fresh body line 1), navbar "Version 2.7.x" active, "Development" → /docs/next/ (line 4), edit link to branch `release/2.7.x` (line 231). OpenBao publishes an official release feed on its own GitHub repo. (b) was also run as corroboration: located count=1.

## Fetch evidence (artifacts in /fast/scratch/kagi-r25/ClockS026/)
1. `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://openbao.org/docs/concepts/tokens/`: exit 0, http_code=200, num_redirects=0, decoded sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`, 47384 bytes. Equals recorded `body_sha256` (tsv:53 col 10). The round-25 UA fetch gave identical bytes (python `==` True).
2. Row identity: sha256("S026\tmined\thttps://openbao.org/docs/concepts/tokens/\n") = `0be2cff9…` = tsv:53 col 3.
3. `python3 corpus/rendered-text-v1.py digest tokens.decoded.html`: exit 0, `normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608`. Equals recorded normalized digest (tsv:53 col 14).
4. `… locate tokens.decoded.html 'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'`: `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0. Normalized offsets: heading "Token hierarchies and orphan tokens" at 4713, quote at 4921. Heading "Token Time-To-Live" at 7302.
5. `… --selftest`: `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0.
6. API feed `api.github.com/repos/openbao/openbao/releases/latest`: HTTP 200 earlier (decoded 347747 B). Tag v2.7.1, published_at 2026-10-01T14:03:19Z, prerelease false. Minutes later the same IP returned **403** ("API rate limit exceeded"). `/rate_limit` core remaining 0, reset 1792581901 (11:25:01Z). The API is unusable as a fleet clock feed (60/h unauthenticated, shared egress).
7. `curl -sS -D - https://github.com/openbao/openbao/releases/latest`: HTTP/2 302, `location: https://github.com/openbao/openbao/releases/tag/v2.7.1`. No API quota.
8. Resolved page (profile UA): exit 0, http 200, num_redirects=1, 227521 B, sha256 `295f71b2f00df966ceef72d1cbffdb2031094cc9f13aa25b4207e9f8e06d4890`. `<relative-time … datetime="2026-10-01T14:03:19Z">` at line 626, in the v2.7.1 release byline. The `<title>` contains U+00B7 (non-ASCII), so it is not used as the quote.
9. `git ls-remote --tags https://github.com/openbao/openbao 'refs/tags/v2.7*' 'refs/tags/v2.8*' 'refs/tags/v2.9*' 'refs/tags/v3*' 'refs/tags/v2.10*'`: exit 0. Tags: v2.7.0, v2.7.0-beta20260909, v2.7.1 (`a5db72cef75c24b920ade02065b18dd8eb666bac`, equal to API target_commitish). No v2.8, v2.9, v2.10 or v3 tag.
10. API releases list (per_page=30): newest prerelease is v2.7.0-beta20260909 (2026-09-09). Nothing newer than v2.7.1.
11. `github.com/openbao/openbao/releases.atom`: 200, 506783 B. Noisy: includes submodule entries (`api/v2.7.1: …`, `sdk/v2.7.1: …`). Not a clock feed.

Verdict logic: 2.7.1 ∈ 2.7.x, so not-fired. Three agreeing sources: redirect, tags, releases list. Valid only for the 2026-10-21 observation.

## Proposed SOURCES row (S033 = next free id at BASE; max is S032 at SOURCES.md:38; L1 assigns, peers may also propose S033+)
```
| S033 | OpenBao latest release page — https://github.com/openbao/openbao/releases/latest | docs | A | Newest non-prerelease OpenBao release tag and publish time; the feed behind S026's 2.7.x clock | Release page reached from /releases/latest: tag v2.7.1, Latest label, publish time 2026-10-01; observed 2026-10-21 | Newest non-prerelease tag is v2.7.1, published 2026-10-01T14:03:19Z; git ls-remote finds no v2.8, v2.9, v2.10 or v3 tag. Quote: “datetime="2026-10-01T14:03:19Z"” (release v2.7.1 page, publish-time element). | mined | 2026-10-21 | 90d | corpus/lessons/round-25.md |
```
Quote: 1 ASCII word, `datetime="2026-10-01T14:03:19Z"`, page line 626. Kind `docs`: the census enum has no feed kind. Tier A: maintainer's own repository. Recheck `90d`, not on-release: an on-release feed row would need its own clock binding and would change the on_release=28 count.

Fetch row (insert after tsv:53):
```
S033	mined	01005e5ad4c6af83a65fa76fbd80366016baf0d018992e789aeae944dd5a5690	https://github.com/openbao/openbao/releases/latest	https://github.com/openbao/openbao/releases/tag/v2.7.1	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	295f71b2f00df966ceef72d1cbffdb2031094cc9f13aa25b4207e9f8e06d4890	227521	a5db72cef75c24b920ade02065b18dd8eb666bac	datetime="2026-10-01T14:03:19Z"	raw-literal-v1	-	release v2.7.1 page, publish-time element beside the release byline
```
Revision column = `a5db72ce…`: a moving-ref URL needs a 40-hex revision. Representation is volatile: the page chrome changes per response, so this is a point attestation.

## Sandbox census (operability; sandbox copy only)
- BASE: `env -i PATH=/usr/bin:/bin HOME=…/home bash corpus/sources-census.sh verify --root <sandbox lane>` → `SOURCES_CENSUS: CLEAN (rows=32 A=30 B=0 C=2 queued=1 mined=29 rejected=2 entries_sourced=4 legacy=21 captures=32 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0.
- Staged S033 rows, used-by stub without a `source:` line → `FINDING SC_USEDBY_NOCITE id=S033 path=corpus/lessons/round-25.md`, exit 1 (sources-census.sh:231 requires the id on the used-by file's column-1 `source:` line).
- Stub with `source: S033 (…)` → `SOURCES_CENSUS: CLEAN (rows=33 A=31 B=0 C=2 queued=1 mined=30 rejected=2 entries_sourced=4 legacy=21 captures=33 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0.
- Integration needs `corpus/lessons/round-25.md` with a column-1 `source:` line naming the final feed id. It is not on disk at BASE.

## Notes for L1
1. Use the github.com `releases/latest` URL for every feed clock. api.github.com is quota-limited for the fleet (ClockS016-2 saw the same; I replied to concur). Observe with a non-following request (`curl -sI`, parse the `location:` tag). Do not parse the page body.
2. `anchored_version` `2.7.x` is a line, not a version. release-clock.py must treat `v2.7.N` as inside the line. The plan does not define this rule. [INFERENCE from plan text; no implementation on disk]
3. `feed_url` should equal its `feed` SOURCES row URL. Do not use releases.atom: it mixes submodule tags.
4. c3-measure.py counts only `verdict == "fired"` (`.ufo/waves/round-25/tools/c3-measure.py:153`), so `not-fired` is safe. Required columns: id, observed_at, verdict (:15).
5. The feed does not observe docs-route changes. Round-23 lesson recheck text names "a release or docs version route" (`corpus/lessons/round-23.md:3`). Optional: check the `docs-version-` marker as a second signal. The plan does not require it.
6. The fetch-table UA literal is round-23 (tsv:14-15). Both UAs gave identical page bytes, and the row uses the literal.

## Teaches status
Holds on the anchored 2.7.x docs at 2026-10-21. No clock fired, so there is no new-release text to compare. The page text is byte-identical to the capture. Lesson trigger (round-23.md:3) not met.

## UNRUN
- `corpus/release-clock.py` and `--observe`: not on disk at BASE. No receipts written.
- `.ufo/waves/round-25/tools/c3-measure.py`: not run.
- Census or verify on the real lane tree: not run. Census was run only in the sandbox.
- Tool installs: none.
