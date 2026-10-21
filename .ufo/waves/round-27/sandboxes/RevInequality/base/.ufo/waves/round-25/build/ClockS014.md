# ClockS014 — S014 release clock (round-25 C3)

Seat KagiR25.ClockS014-2 (leaf). Observed 2026-10-21. Lane base 4587c61a348e4528717404a68912c373f3ef4d03 (lane files read only). Sandbox /fast/scratch/kagi-r25/ClockS014.

## Verdict
- Governing identity: (a) feed. The page is OpenBao docs labelled `Version: Version 2.7.x`; its footer edit link is `https://github.com/openbao/openbao/blob/release/2.7.x/website/content/docs/auth/jwt/index.mdx`.
- Feed `https://github.com/openbao/openbao/releases/latest`: newest stable **v2.7.1**, published 2026-10-01 14:03 UTC, commit a5db72cef75c24b920ade02065b18dd8eb666bac. Anchor `2.7.x` => **not-fired**. No stable release is newer than the S014 open date (2026-10-19).
- S014 teaches **holds** (below). Its stored quote is a case variant and locates only case-insensitively; S025 carries the located quote.

## Proposed release-clocks.tsv line
Header (tab-separated): `id	clock	feed_url	anchored_version	observed_version	observed_at	verdict`
```
S014	feed	https://github.com/openbao/openbao/releases/latest	2.7.x	v2.7.1	2026-10-21	not-fired
```
S015, S016, S025 and S026 are anchored `2.7.x` on the same docs host: same feed, same observation, one line each.

## SOURCES candidate: S033 (next free id at BASE, max S032; renumber if taken)
```
| S033 | OpenBao latest release (GitHub) — https://github.com/openbao/openbao/releases/latest | docs | A | OpenBao release identity for the 2.7.x docs line: newest stable tag and publish date | GitHub "Latest" release route; tag v2.7.1, published 2026-10-01 14:03 UTC; opened 2026-10-21 | The newest stable OpenBao release is v2.7.1, published 2026-10-01; the 2.7.x docs line that S014, S015, S016, S025 and S026 cite is current. Quote: “released this 01 Oct 14:03 Immutable release. Only release title and notes can be modified.” (release page, v2.7.1 header). | mined | 2026-10-21 | 90d | corpus/lessons/round-25.md |
```
- kind `docs`: `feed` is not in the census enum (sources-census.sh:33, :191). Tier A: openbao/openbao is the project's own repo, linked from the docs footer.
- recheck `90d`, not `on-release`: otherwise the feed row joins the 28-row population and needs its own clock.
- used-by `corpus/lessons/round-25.md` must carry `S033` on its `source:` line (SC_USEDBY_NOCITE, sources-census.sh:229-231).
- Paste requirements for corpus/lessons/round-25.md (checked as a sourced entry): the file must exist before paste (SC_USEDBY_MISSING, contract header :35); exactly one lower-case `source:` line citing only ids whose used-by lists this path (SC_ENTRY_CITE, sources-census.sh:49-51), so S033 alone unless the other rows are re-pointed; `verified-at:` and `recheck:` header lines (SC_ENTRY_HEADER, sources-census.sh:47-48). The sandbox probe (S033 only, both headers) passed; the multi-id case is untested.
- Capture row for source-fetches.tsv (16 tab-separated columns; field 3 = sha256 of `S033\tmined\t<url>\n`):
```
S033	mined	01005e5ad4c6af83a65fa76fbd80366016baf0d018992e789aeae944dd5a5690	https://github.com/openbao/openbao/releases/latest	https://github.com/openbao/openbao/releases/tag/v2.7.1	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	d52e47591ec0cac466c57eef875497d261923e77edb5dbe38fd92756a03fe297	227521	a5db72cef75c24b920ade02065b18dd8eb666bac	released this 01 Oct 14:03 Immutable release. Only release title and notes can be modified.	rendered-text-v1	95ba591b745624a7ae00b49fcb68dce0ab9a4aa17b5f0de55575f3c56a0b318d	v2.7.1 release page header
```

## Fetch evidence (curl -fsSL --compressed; exit 0 unless noted)
- S014 `https://openbao.org/docs/auth/jwt/`: HTTP 200 under the contract UA and under the declared round-23 UA (`cmp` equal). Decoded 63046 B, sha256 449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9 = source-fetches.tsv:67 raw digest (reproduces). rendered-text-v1: normalized ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403, 15942 B (= row's normalized digest).
- In-row pin e94723241fbc… (SOURCES.md:20) matches neither representation (known; inrow-pins.tsv:20; S025 supersedes).
- `rendered-text-v1.py locate`: S014 stored quote (uppercase JWT) count=0 exact (exit 1), count=1 case-insensitive; S025 quote count=1 (exit 0).
- Version evidence: raw `Version: Version 2.7.x`; switcher lists 2.7.x, Development 2.7.x, 2.6.x, 2.5.x (no 2.8.x).
- REST `api.github.com/repos/openbao/openbao/releases/latest`: HTTP 200 on first try (decoded 347747 B, sha256 a771067e6ff39a58a83f0abc7744825c94068c509c87e3daa4ea74ec6f5e8bc1). Retry under the declared UA: **HTTP 403** (curl exit 22); `x-ratelimit-limit: 60`, `remaining: 0`, reset 1792581901 = 2026-10-21T11:25:01Z. The unauthenticated quota on this egress is exhausted; REST is not usable as the clock feed.
- REST `/releases?per_page=30` (200, sha256 0b9edcab476e4159ecd0b7d391e5ce2b13fce84242e8926e940c956bf8242454): newest stable v2.7.1; newest prerelease v2.7.0-beta20260909 (2026-09-09); no 2.8 or 3.x.
- Atom `https://github.com/openbao/openbao/releases.atom` (200, 506783 B, sha256 1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f): 10-entry window; `api/v2.7.1` and `sdk/v2.7.1` interleave; first stable v2.7.1 has `<updated>` 2026-10-01T18:32:18Z (edit time, later than publish). Rejected: a burst of submodule tags can push the main tag out of the window.
- `releases/latest` HTML (200; final URL `…/releases/tag/v2.7.1`; decoded 227521 B, transfer 37564 B; sha256 d52e47591ec0cac466c57eef875497d261923e77edb5dbe38fd92756a03fe297; normalized 95ba591b745624a7ae00b49fcb68dce0ab9a4aa17b5f0de55575f3c56a0b318d, 6254 B). Quote locate count=1 (exit 0). "Latest" badge on v2.7.1; commit a5db72cef75c24b920ade02065b18dd8eb666bac linked.

## Teaches check (S014 text unchanged)
- "OpenBao 2.7.x supports OIDC and direct-JWT authentication": H1 text "The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT".
- "configured signature verification": §JWT verification, "JWT signatures will be verified against public keys from the issuer" (three methods, one configured per backend).
- "claim handling": §Bound claims and §Claims as metadata (`claim_mappings`).
- 2.7.0/2.7.1 notes: no auth/jwt entry. 2.7.1 touches `auth/kubernetes` renewal (GHSA-gf3j-hm38-jhh5); 2.7.0 touches `auth/oidc` and the OIDC provider UI. Side note for the S015 owner: the kubernetes renewal fix is a different mount from the JWT engine S015 quotes; not verified against S015.

## Calibration and operability notes
1. Line vs exact tag: `2.7.x` read as a wildcard means a 2.7.2 would not fire the clock; exact-tag anchoring (v2.7.1, newest at the open date) would. Both say not-fired today. release-clock.py needs one rule; strip a leading `v` before comparing.
2. Stored-quote hazard: bound as rendered-quote, S014 would read MISSING today (case-variant locator), a false fire. The feed clock avoids this.
3. Feed choice: REST is quota-limited (403); Atom holds 10 entries; `releases/latest` is GitHub's own Latest pointer, with the version readable from the final URL and no HTML scraping. Recommended.
4. Census, sandbox clone at BASE (`env -i`, `bash corpus/sources-census.sh`): BASE `SOURCES_CENSUS: CLEAN (rows=32 A=30 ... captures=32 ...)` exit 0. With S033 used-by = the knowledge doc: `SC_USEDBY_NOCITE id=S033`, `SOURCES_CENSUS: FAILED (findings=1 rows=33)`, exit 1. With used-by = corpus/lessons/round-25.md carrying a `source: S033 ...` line (sandbox probe file only): `SOURCES_CENSUS: CLEAN (rows=33 A=31 B=0 C=2 queued=1 mined=30 rejected=2 entries_sourced=4 legacy=21 captures=33 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0.
5. Receipt vocabulary: the scribe's `--observe` outcome reads `unchanged`; this table reads `not-fired`. Planner picks one.
6. Binding key: corpus/release-clocks.tsv binds each row by id; the recheck cell only sets population membership (on-release = 28 rows; 90d = outside). No registry cell is rewritten (ScribeKnowledgeClock.md, Class 7 and Block C "Release clocks"). L1 adds the fixed-recheck sentence to Block D: a feed row keeps its own recheck (90d).

## Lane hygiene, tools, unrun
- No lane writes. Sandbox only: /fast/scratch/kagi-r25/ClockS014/{home,fetch,lane}. Lane clone via `git clone -q --no-hardlinks` then `checkout -q 4587c61a…`.
- Disclosure: one read-only `git -C <lane> status --short` ran on the real lane (may refresh the index stat cache). Output: `?? .ufo/waves/round-25/`, `?? corpus/__pycache__/`, `?? plans/round-25.md`. rendered-text-v1.py ran only as a direct script on the lane path (writes no bytecode); imports ran on sandbox copies.
- Installs: none (curl, git, python3 already present).
- UNRUN: release-clock.py and release-clocks.tsv (not on disk); c3-measure.py; lane-tree census; claim-ledger verify/cells (forbidden on lane).
