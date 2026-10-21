# ClockS013 — C3 release clock for SOURCES S013 (round 25)

Seat ClockS013 (leaf, no subagents). observed_at 2026-10-21. Lane BASE 4587c61a348e4528717404a68912c373f3ef4d03: a sandbox clone is checked out at BASE, and SOURCES.md, source-fetches.tsv, rendered-text-v1.py and inrow-pins.tsv hash-equal the lane tree. No lane writes. No installs (curl 8.23.0, Python 3.14.8, git 2.56.0 already present).

## 1. Row under test
- SOURCES.md:19 S013: docs, tier A, mined, recheck on-release, opened 2026-10-19. Anchor: "current Vault docs have no displayed version/date". In-row pin ae321512d37a… (non-reproducing, see §2).
- SOURCES.md:29 S023 supersedes S013 on the version locator (same URL, on-release).
- source-fetches.tsv:66 capture: raw ac99140f11ac… (261632 B); normalized 0e62e05612ea….

## 2. Fetch evidence (2026-10-21)
- `curl -sSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)'`: exit 0, HTTP 200, no redirect. (No -f, so the status is captured; a 200 makes -f moot.)
- Decoded body sha256 ac99140f11acbae6debf592f08fffaaadecb67d6b406a4044a3254e30d4dcdeb, 261632 B = capture (reproduces).
- rendered-text-v1 (lane script copied to sandbox; `--selftest` exit 0, cases=22): normalized sha256 0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 = capture (reproduces).
- Default curl UA: same raw digest. Wire bytes, no decode (Accept-Encoding gzip, deflate, br, zstd): 736de1ed6bd1eb8c…, 40415 B.
- In-row pin ae321512… matches none of raw, normalized, wire or default-UA. It stays unexplained.
- Companion: the S012 JWT page reproduces its capture (raw 62556bf024c4…, 386435 B).

## 3. Release identity: decision (a), versioned docs with an official feed
- Visible text (tag-stripped; CSS visibility not evaluated): "Lease, Renew, and Revoke v2.x (latest) Vault v2.x (latest) v1.21.x v1.20.x …". aria-label "Currently viewing v2.x (latest)"; "Edit this page on GitHub" links to content/vault/v2.x/. So the row's "no displayed version/date" is false (S023 already withdraws it). (b) rejected: the doc set is versioned.
- Feed: https://api.github.com/repos/hashicorp/vault/releases/latest (the vendor's own repo): HTTP 200; decoded sha256 8deb527d2bb6879f…, 102014 B; normalized 895a793c7177…, 101903 B.
- Latest: tag_name "v2.2.0", published_at "2026-10-15T16:17:18Z", prerelease false, draft false.
- /releases?per_page=5 (HTTP 200, sha256 efdb4055…): v2.2.0 (10-15), v2.2.0-rc1 (10-08, prerelease), v2.1.2 (10-07), v2.1.1 (09-16), v2.1.0 (09-01). Nothing dated after 10-15.
- CHANGELOG.md raw main (HTTP 200, sha256 8b0bc48a…, 596973 B): lines 6–7 "## 2.2.0" / "### October 15, 2026"; the top entry of the file.
- Anchor: S013 names no version, so I anchor to v2.x, the route label the page displays (S023 names the same route). v1.21.x is the newest non-latest entry in the same switcher, so it is not the anchor. Whether the 2026-10-19 body showed the switcher cannot be proved (no archive) [INFERENCE].

## 4. Verdict: NOT FIRED
- Comparator (proposed, line-level): fired iff the latest GA release leaves the anchored line, or a GA release is dated after the row opened (2026-10-19). v2.2.0 is on line v2.x and dated 2026-10-15, so neither test fires.
- Proposed corpus/release-clocks.tsv line (tab-separated: id, clock, feed_url, anchored_version, observed_version, observed_at, verdict):
```
S013	feed	https://api.github.com/repos/hashicorp/vault/releases/latest	v2.x	v2.2.0	2026-10-21	not-fired
```
- Companion (recorded, not the clock): rendered-quote located count=1 for the lease quote and count=1 for the KV note on 2026-10-21.

## 5. SOURCES candidate: S033 (id free: `S03[3-9]` matched nothing in SOURCES.md, source-fetches.tsv, inrow-pins.tsv)
kind `code` because the census enum has no `feed`; tier A because the repo is the vendor's own.
```
| S033 | Vault latest GA release (GitHub releases API) — https://api.github.com/repos/hashicorp/vault/releases/latest | code | A | Latest non-prerelease Vault tag and publish date for the on-release clocks of Vault docs rows S013 and S023 | release object keys tag_name and published_at (opened 2026-10-21); CHANGELOG.md "## 2.2.0" / "### October 15, 2026" | Latest GA Vault release is v2.2.0, published 2026-10-15. Quotes: "tag_name":"v2.2.0"; "published_at":"2026-10-15T16:17:18Z" (release object, top level; each located count=1 by rendered-text-v1). | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv |
```
source-fetches.tsv candidate (16 columns). Row identity = sha256 of "S033\tmined\t<URL>\n" = 67b3587d2d77a8f396a0b1f3b94a67801b1ff7078b0a835a8a781aaf60b34d48. The same formula reproduces S013's stored identity 58ca84c2….
```
S033	mined	67b3587d2d77a8f396a0b1f3b94a67801b1ff7078b0a835a8a781aaf60b34d48	https://api.github.com/repos/hashicorp/vault/releases/latest	https://api.github.com/repos/hashicorp/vault/releases/latest	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	8deb527d2bb6879fe76ae53a9f979d45f4fcfe620447e9cbc9f12d444428c338	102014	-	"tag_name":"v2.2.0"	rendered-text-v1	895a793c7177044256f609113080537457e04d612c112b0568fa5f68c04ca61d	release object, key tag_name
```
Land S033 together with release-clocks.tsv: a mined row whose used-by path is missing fails SC_USEDBY_MISSING.

## 6. S013 teaches: still holds. Anchor text: wrong (S023 supersedes it)
- "All dynamic secrets in Vault are required to have a lease." — count=1 on the 2026-10-21 v2.x page (§Lease, renew, and revoke); count=1 on developer.hashicorp.com/vault/docs/v1.21.x/concepts/lease (HTTP 200, 262620 B, sha256 e159d742…).
- KV note "does not issue leases" — count=1 on both pages.
- No v2.x CHANGELOG entry changes either statement. Lease-touching lines (CHANGELOG.md; "release" substring matches excluded): 2.2.0 → 285, 453, 483, 528, 536, 606; 2.1.0 → 790, 810; 2.0.1 → 1031, 1035; 2.0.0 → 1179, 1244. None restates or alters the required-lease rule or the KV note.

## 7. Calibration, operability, freshness
- Calibration: S013's "no displayed version/date" is false (visible switcher). Stop citing its anchor; S023 is the corrected row.
- Operability: the C3 spec's "the version the row's anchor names" cannot apply literally (S013 names none). L1 must accept page-label anchoring or amend the anchor (SOURCES is L1-only).
- Freshness: a line-level clock cannot see a v2.x patch that edits lease text. Each observation should record rendered-quote counts beside the feed verdict.
- Coverage: the latest-release endpoint returns one object. Enterprise-only 1.x patches (CHANGELOG.md:1305 "## 1.21.12 Enterprise", 2026-10-07) are absent from the 5-entry list [INFERENCE: not public GitHub releases]. A v1.x-route clock must read CHANGELOG.md.
- Double binding: S023 (SOURCES.md:29, same URL, on-release) needs the same line under id S023. Not bound here; L1 decides whether superseded S013 keeps its clock.
- developer.hashicorp.com/vault/docs/release-notes and /release-notes/2.2.0: HTTP 404 (exit 0). Not used as the feed.

## 8. Commands and exit codes
- Sandbox /fast/scratch/kagi-r25/ClockS013, `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`. curl exit 0 with HTTP 200: S013 (-A, default UA, wire), S012, S013 v1.21.x, releases/latest, releases?per_page=5, CHANGELOG raw. Release-notes index and 2.2.0: exit 0, HTTP 404.
- rendered-text-v1 --selftest exit 0 (22/22); digest exit 0; locate exit 0 (counts above).
- git clone and checkout 4587c61a: exit 0 each; HEAD 4587c61a348e4528717404a68912c373f3ef4d03.

## 9. UNRUN
- corpus/release-clock.py, corpus/release-clocks.tsv and the --observe receipt: absent at BASE; not run.
- Lane gate verify/cells: not run (forbidden on the lane tree; not assigned).
- No SOURCES, tsv or lane edits by this seat.
